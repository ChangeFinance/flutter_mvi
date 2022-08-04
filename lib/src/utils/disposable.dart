import 'dart:async';
/// Interface for all the classes that is meant to be added in bucket
abstract class Disposable {
  void dispose();
}

/// Container class collecting all disposables and subscriptions.
/// Simplifies disposing subscriptions etc.
class DisposableBucket {
  final List<StreamSubscription> _subscriptionBucket = List.empty(growable: true);
  final List<Disposable> _disposableBucket = List.empty(growable: true);

  /// Only Disposable and StreamSubscription will be added
  /// all other types will be just ignored
  void add(Object object) {
    if (object is Disposable) {
      if(_disposableBucket.contains(object) == false){
        _disposableBucket.add(object);
      }
    } else if (object is StreamSubscription) {
      if(_disposableBucket.contains(object) == false) {
        _subscriptionBucket.add(object);
      }
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

/// Extension for adding disposable object to bucket with less code
extension BucketExtension on DisposableBucket {
  void operator <=(Object object) {
    add(object);
  }
}
