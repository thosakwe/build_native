import 'package:angel_serialize/angel_serialize.dart';
import 'package:collection/collection.dart';

part 'third_party.g.dart';

part 'third_party.serializer.g.dart';

@serializable
abstract class _ThirdPartyDependency {
  @HasAlias('url')
  String get webUrl;

  String get md5;

  String get sha1;

  String get sha256;

  @HasAlias('git')
  String get gitUrl;

  String get commit;

  String get branch;

  String get tag;

  String get target;

  String get remote;

  String get path;

  @HasAlias('libraries')
  List<String> get libPaths;

  List<String> get include;

  List<String> get link;

  List<String> get sources;

  bool get isGit => gitUrl?.isNotEmpty == true;

  bool get isWeb => webUrl?.isNotEmpty == true;

  String get formattedTag => tag == null ? null : 'tags/$tag';
}
