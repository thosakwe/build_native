import 'package:example/sample_extension.dart';

main() {
  var num = systemRand();
  print('rand: $num');

  var b = systemSrandBoolean(2);
  print('rand(2): $b');
}
