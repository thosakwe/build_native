import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:build_native/src/models/third_party.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:scratch_space/scratch_space.dart';
import 'dependency.dart';

class WebDependencyUpdater implements DependencyUpdater {
  const WebDependencyUpdater();

  Directory localBuildNativeDirectory(Directory directory) {
    return new Directory(p.join(directory.path, '.build_native'));
  }

  File archiveNameFile(Directory directory) {
    return new File(
        p.join(localBuildNativeDirectory(directory).path, 'archive_name.txt'));
  }

  /// Although the name says otherwise, here is where'll extract the archive.
  @override
  Future download(
      bool isFresh,
      ThirdPartyDependency dependency,
      Directory directory,
      Future<ScratchSpace> Function() getScratchSpace) async {
    var file = archiveNameFile(directory);
    var archiveFilename = await file.openRead().transform(utf8.decoder).join();
    var archiveFile = new File(
        p.join(localBuildNativeDirectory(directory).path, archiveFilename));

    // Compare the hash, if necessary.
    if (dependency.md5 != null) {
      var bytes = await archiveFile.readAsBytes();
      var md5Hash = hex.encode(md5.convert(bytes).bytes);

      if (md5Hash != dependency.md5) {
        throw 'The hash $md5Hash of ${archiveFile.absolute
            .path} does not equal "${dependency.md5}".';
      }
    }

    var stream = archiveFile.openRead();
    var ext = p.extension(archiveFile.path);
    Archive archive;

    if (ext == '.gz') {
      stream = stream.transform(gzip.decoder);
      ext = p.extension(p.basenameWithoutExtension(archiveFile.path));
    } else if (ext == '.bz2') {
      var bytes = await stream
          .fold<BytesBuilder>(BytesBuilder(), (bb, buf) => bb..add(buf))
          .then((bb) => bb.takeBytes());
      stream = new Stream<List<int>>.fromIterable(
          [new BZip2Decoder().decodeBytes(bytes)]);
      ext = p.extension(p.basenameWithoutExtension(archiveFile.path));
    }

    var bytes = await stream
        .fold<BytesBuilder>(BytesBuilder(), (bb, buf) => bb..add(buf))
        .then((bb) => bb.takeBytes());

    if (ext == '.zip') {
      archive = new ZipDecoder().decodeBytes(bytes);
    } else if (ext == '.tar') {
      archive = new TarDecoder().decodeBytes(bytes);
    } else {
      await stream.drain();
      throw 'Cannot extract file with extension "$ext".';
    }

    // Now that we've decoded the archive, let's extract it.
    Future copyAllFiles(String currentDir, Iterable<ArchiveFile> files) async {}

    await copyAllFiles('.', archive);
  }

  static int handleFailureStatusCode(HttpClientResponse response, String url) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
      throw '$url sent status code ${response.statusCode}.';
    }

    return response.statusCode;
  }

  /// We actually *always* download here.
  @override
  Future<bool> isOutdated(
      ThirdPartyDependency dependency, Directory directory) async {
    // Read the archive file.
    var file = archiveNameFile(directory);
    var client = new HttpClient();

    try {
      if (!await file.exists()) {
        var rq = await client.openUrl('GET', Uri.parse(dependency.webUrl));
        rq.headers.set('accept', '*/*');

        var rs = await rq.close();
        var statusCode = handleFailureStatusCode(rs, dependency.webUrl);

        if (statusCode != 200) {
          throw '${dependency
              .webUrl} sent status code $statusCode; only 200 is allowed.';
        }

        var archiveFile = new File(p.join(
          localBuildNativeDirectory(directory).path,
          p.basename(dependency.webUrl),
        ));

        await archiveFile.create(recursive: true);
        await rs.pipe(archiveFile.openWrite());
        return true;
      } else {
        var archiveFilename =
            await file.openRead().transform(utf8.decoder).join();
        var archiveFile = new File(
            p.join(localBuildNativeDirectory(directory).path, archiveFilename));

        // Get the last touch time, in UTC, and then fetch the resource from the server.
        // Ideally, the file is untouched, and the server returns a 304.
        var stat = await archiveFile.stat();

        var rq = await client.openUrl('GET', Uri.parse(dependency.webUrl));
        rq.headers
          ..set('accept', '*/*')
          ..set('if-modified-since', HttpDate.format(stat.changed));

        var rs = await rq.close();
        var statusCode = handleFailureStatusCode(rs, dependency.webUrl);

        if (statusCode == 304) {
          return false;
        }

        // If the status wasn't 304, then the file was updated.
        //
        // Let's overwrite the current file, and signal that it needs to be
        // extracted again.
        await rs.pipe(archiveFile.openWrite());
        return true;
      }
    } finally {
      client.close(force: true);
    }
  }
}
