import '../lib/sample_extension.dart';

main() {
  var num = systemRand();
  print('rand: $num');

  var b = systemSrand(2);
  print('rand(2): $b');
}