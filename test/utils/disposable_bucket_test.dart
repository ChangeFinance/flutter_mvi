import 'dart:async';

import 'package:flutter_mvi/src/utils/disposable.dart';
import 'package:test/test.dart';

class _CountingDisposable implements Disposable {
  int disposeCalls = 0;

  @override
  void dispose() => disposeCalls++;
}

/// Counts cancellations so a subscription held twice is visible.
class _CountingSubscription implements StreamSubscription<void> {
  int cancelCalls = 0;

  @override
  Future<void> cancel() async => cancelCalls++;

  @override
  void onData(void Function(void)? handleData) {}

  @override
  void onError(Function? handleError) {}

  @override
  void onDone(void Function()? handleDone) {}

  @override
  void pause([Future<void>? resumeSignal]) {}

  @override
  void resume() {}

  @override
  bool get isPaused => false;

  @override
  Future<E> asFuture<E>([E? futureValue]) => Completer<E>().future;
}

void main() {
  group('add', () {
    test('holds the same subscription once, however many times it is added', () async {
      final bucket = DisposableBucket();
      final subscription = _CountingSubscription();

      bucket
        ..add(subscription)
        ..add(subscription)
        ..add(subscription);
      bucket.dispose();

      expect(
        subscription.cancelCalls,
        1,
        reason: 'the duplicate check reads the subscription list, so the same subscription is stored once',
      );
    });

    test('holds the same disposable once, however many times it is added', () {
      final bucket = DisposableBucket();
      final disposable = _CountingDisposable();

      bucket
        ..add(disposable)
        ..add(disposable);
      bucket.dispose();

      expect(disposable.disposeCalls, 1);
    });

    test('keeps distinct entries apart', () {
      final bucket = DisposableBucket();
      final first = _CountingDisposable();
      final second = _CountingDisposable();
      final subscription = _CountingSubscription();

      bucket
        ..add(first)
        ..add(second)
        ..add(subscription);
      bucket.dispose();

      expect(first.disposeCalls, 1);
      expect(second.disposeCalls, 1);
      expect(subscription.cancelCalls, 1);
    });

    test('ignores anything that is neither disposable nor a subscription', () {
      final bucket = DisposableBucket();

      expect(() => bucket.add(Object()), returnsNormally);
      expect(bucket.dispose, returnsNormally);
    });
  });

  group('dispose', () {
    test('lets go of what it held, so a second dispose is a no-op', () {
      final bucket = DisposableBucket();
      final disposable = _CountingDisposable();
      final subscription = _CountingSubscription();

      bucket
        ..add(disposable)
        ..add(subscription);

      bucket.dispose();
      bucket.dispose();

      expect(
        disposable.disposeCalls,
        1,
        reason: 'a bucket that keeps its entries disposes them again on every later call, and holds them alive meanwhile',
      );
      expect(subscription.cancelCalls, 1);
    });

    test('can be filled again after being emptied', () {
      final bucket = DisposableBucket();
      final first = _CountingDisposable();
      final second = _CountingDisposable();

      bucket.add(first);
      bucket.dispose();

      bucket.add(second);
      bucket.dispose();

      expect(first.disposeCalls, 1, reason: 'the first entry was let go when the bucket was emptied');
      expect(second.disposeCalls, 1);
    });
  });
}
