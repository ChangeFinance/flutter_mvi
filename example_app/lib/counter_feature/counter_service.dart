import 'dart:async';

import 'package:rxdart/rxdart.dart';

class CounterService {
  Stream<int> counterStream = PublishSubject();
  var _count = 0;

  CounterService() {
    counterStream = Stream.periodic(const Duration(seconds: 5), (_) {
      // Code returning a value every 2 seconds.
      _count++;
      return _count;
    });
  }
}
