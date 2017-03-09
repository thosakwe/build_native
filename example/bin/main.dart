import 'package:example/sample_extension.dart';

main() {
  var num = systemRand();
  print('rand: $num');

  num = systemSrand(2);
  print('rand(2): $num');
}