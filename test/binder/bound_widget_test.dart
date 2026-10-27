import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_mvi/flutter_mvi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundWidget binder lifecycle', () {
    testWidgets('disposes the replaced binder when the element is updated with a new binder', (tester) async {
      final first = _BinderProbe();
      final second = _BinderProbe();

      await tester.pumpWidget(_host(first.create, 'first'));
      await tester.pumpWidget(_host(second.create, 'second'));

      expect(find.text('second'), findsOneWidget);
      expect(first.binder!.disposeCalls, 1, reason: 'the replaced binder must be disposed exactly once');
      expect(first.tracked.disposed, isTrue, reason: 'disposables owned by the replaced binder must be released');
      expect(first.streamCancelled, isTrue, reason: 'stream subscriptions of the replaced binder must be cancelled');
      expect(second.binder!.disposeCalls, 0, reason: 'the current binder must stay alive');
      expect(second.streamCancelled, isFalse);
    });

    testWidgets('keeps the binder alive when the same instance is passed again', (tester) async {
      final probe = _BinderProbe();

      await tester.pumpWidget(_host(probe.create, 'first'));
      await tester.pumpWidget(_host(probe.create, 'second'));

      expect(find.text('second'), findsOneWidget);
      expect(probe.binder!.disposeCalls, 0);
      expect(probe.tracked.disposed, isFalse);
      expect(probe.streamCancelled, isFalse);
    });

    testWidgets('disposes the current binder once when the widget is unmounted', (tester) async {
      final first = _BinderProbe();
      final second = _BinderProbe();

      await tester.pumpWidget(_host(first.create, 'first'));
      await tester.pumpWidget(_host(second.create, 'second'));
      await tester.pumpWidget(const SizedBox());

      expect(first.binder!.disposeCalls, 1, reason: 'the replaced binder must not be disposed a second time');
      expect(second.binder!.disposeCalls, 1);
      expect(second.tracked.disposed, isTrue);
      expect(second.streamCancelled, isTrue);
    });
  });
}

Widget _host(_TestBinder Function(BuildContext context) create, String label) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Builder(
      builder: (context) => _TestBoundWidget(binder: create(context), label: label),
    ),
  );
}

/// Owns one [_TestBinder] and the resources it holds, so a test can assert
/// whether that binder was released.
class _BinderProbe {
  final _TrackedDisposable tracked = _TrackedDisposable();
  late final StreamController<_TestUiState> _states = StreamController<_TestUiState>.broadcast(
    onCancel: () => streamCancelled = true,
  );

  bool streamCancelled = false;
  _TestBinder? binder;

  _TestBinder create(BuildContext context) => binder ??= _TestBinder(context, tracked: tracked, states: _states.stream);
}

class _TrackedDisposable implements Disposable {
  bool disposed = false;

  @override
  void dispose() => disposed = true;
}

class _TestBinder extends Binder<_TestUiState, _TestUiEvent> {
  _TestBinder(
    BuildContext context, {
    required _TrackedDisposable tracked,
    required Stream<_TestUiState> states,
  }) : super(
          context,
          Transformer<_TestUiState>(
            uiStateStream: (_) => states,
            initialUiState: (_) => const _TestUiState(0),
          ),
        ) {
    bucket <= tracked;
  }

  int disposeCalls = 0;

  @override
  void dispose() {
    disposeCalls++;
    super.dispose();
  }
}

class _TestBoundWidget extends BoundWidget<_TestUiState, _TestUiEvent> {
  const _TestBoundWidget({
    Key? key,
    required Binder<_TestUiState, _TestUiEvent> binder,
    required this.label,
  }) : super(key: key, binder: binder);

  final String label;

  @override
  Widget builder(BuildContext context, Binder<_TestUiState, _TestUiEvent> binder) => Text(label);
}

class _TestUiState extends UiState {
  const _TestUiState(this.value);

  final int value;
}

class _TestUiEvent extends UiEvent {}
