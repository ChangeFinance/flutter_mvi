import 'dart:async';

abstract class Disposable {
  void dispose();
}

class DisposableBucket {
  final List<StreamSubscription> _subscriptionBucket = List.empty(growable: true);
  final List<Disposable> _disposableBucket = List.empty(growable: true);

  void add(Object object) {
    if (object is Disposable) {
      _disposableBucket.add(object);
    } else if (object is StreamSubscription) {
      _subscriptionBucket.add(object);
    }
  }

  void dispose() {
    for (var subscription in _subscriptionBucket) {
      subscription.cancel();
    }
    for (var disposable in _disposableBucket) {
      disposable.dispose();
    }
  }
}

extension BucketExtension on DisposableBucket {
  void operator <=(Object object) {
    add(object);
  }
}
