import 'dart:math';

class CounterRepo {
  Future<int> getInt() {
    Random random = Random();
    var delay = random.nextInt(3);
    return Future.delayed(Duration(seconds: delay), () => random.nextInt(10));
  }
}
