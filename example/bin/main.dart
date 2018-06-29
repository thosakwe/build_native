import 'package:example/sample_extension.dart';
import 'package:example/say_hello.dart';

main() {
  var num = systemRand();
  print('rand: $num');

  var b = systemSrand(2);
  print('rand(2): $b');

  sayHello();
}
