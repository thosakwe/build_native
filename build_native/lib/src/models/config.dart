// ignore_for_file: generic_method_comment
import 'package:angel_serialize/angel_serialize.dart';
import 'package:collection/collection.dart';
import 'third_party.dart';

part 'config.g.dart';

part 'config.serializer.g.dart';

@Serializable(autoIdAndDateFields: false)
abstract class _BuildNativeConfig {
  List<String> get flags;

  Map<String, String> get define;

  List<String> get link;

  List<String> get sources;

  @Alias('third_party')
  List<ThirdPartyDependency> get thirdPartyDependencies;
}
