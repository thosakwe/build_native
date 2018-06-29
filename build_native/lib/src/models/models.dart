// ignore_for_file: generic_method_comment
import 'package:angel_serialize/angel_serialize.dart';
import 'package:collection/collection.dart';
part 'models.g.dart';
part 'models.serializer.g.dart';

@Serializable(autoIdAndDateFields: false)
abstract class _BuildNativeConfig {
  List<Object> get flags;
  Map<Object, Object> get define;
  List<Object> get link;
  List<Object> get sources;

  /*
  List/*<String>*/ get flags;
  Map/*<String, String>*/ get define;
  List/*<String>*/ get link;
  List/*<String>*/ get sources;
  */
}