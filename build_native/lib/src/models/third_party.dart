import 'package:angel_serialize/angel_serialize.dart';
import 'package:collection/collection.dart';

part 'third_party.g.dart';

part 'third_party.serializer.g.dart';

@Serializable(autoIdAndDateFields: false)
abstract class _ThirdPartyDependency {
  @Alias('url')
  String get webUrl;

  String get md5;

  String get sha256;

  @Alias('git')
  String get gitUrl;

  String get commit;

  String get branch;

  String get tag;

  String get target;

  String get remote;

  String get path;

  @Alias('libraries')
  List<String> get libPaths;

  List<String> get include;

  List<String> get link;

  List<String> get sources;

  bool get isGit => gitUrl?.isNotEmpty == true;

  bool get isWeb => webUrl?.isNotEmpty == true;

  String get formattedTag => tag == null ? null : 'tags/$tag';
}
