import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:build_native/src/models/third_party.dart';
import 'package:build_native/src/common.dart';
import 'package:path/path.dart' as p;
import 'package:scratch_space/scratch_space.dart';
import 'dependency.dart';

class GitDependencyUpdater implements DependencyUpdater {
  const GitDependencyUpdater();

  @override
  Future download(
      bool isFresh,
      ThirdPartyDependency dependency,
      Directory directory,
      Future<ScratchSpace> Function() getScratchSpace) async {
    var branch = dependency.commit ??
        dependency.formattedTag ??
        dependency.branch ??
        'master';
    var remote = 'origin'; // dependency.remote ?? 'origin';

    if (isFresh) {
      // Freshly clone the project.
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }

      var parentDir = new Directory(p.dirname(directory.path));
      await parentDir.create(recursive: true);

      await expectExitCode0(
          'git',
          [
            'clone',
            '--depth',
            '1',
            dependency.gitUrl,
            p.basename(directory.path)
          ],
          parentDir.absolute.path);

      // Checkout the branch/tag/commit.
      await expectExitCode0(
          'git', ['checkout', branch, '.'], directory.absolute.path);
    } else {
      // Fetch from the remote.
      await expectExitCode0('git', ['fetch', remote], directory.absolute.path);

      // Pull the current branch.
      await expectExitCode0(
          'git', ['pull', '--force', remote, branch], directory.absolute.path);
    }
  }

  @override
  Future<bool> isOutdated(
      ThirdPartyDependency dependency, Directory directory) async {
    // Check if the .git dir exists.
    var gitDir = new Directory(p.join(directory.path, '.git'));

    if (!await gitDir.exists()) return true;

    // Update all remotes.
    await expectExitCode0('git', ['fetch', '--all'], directory.absolute.path);

    // See if there are any changed files.
    var porcelainStdout = await execProcess(
        'git', ['status', '--porcelain'], directory.absolute.path);

    var porcelain = await porcelainStdout.transform(utf8.decoder).join();

    // If the output is empty, then everything is up-to-date.
    return porcelain.trim().isNotEmpty;
  }
}
