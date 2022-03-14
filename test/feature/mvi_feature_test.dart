import 'package:flutter_mvi/src/element/elements.dart';
import 'package:flutter_mvi/src/feature/mvi_feature.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'mvi_feature_test.mocks.dart';

@GenerateMocks([TestActor, TestReducer])
void main() {
  when(actor.invoke(any, any)).thenAnswer((_) => PublishSubject<Effect>());
  when(reducer.invoke(any, any)).thenAnswer((_) => State(2));

  group('vmi feature', () {
    test('emit initial state', () {
      final feature = TestFeature();
      feature.state.listen(expectAsync1((State state) {
        expect(state, initialState);
      }, count: 1));
    });

    test('call actor', () async {
      final feature = TestFeature();
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));
      verify(actor.invoke(initialState, action));
    });

    test('call reducer', () async {
      final feature = TestFeature();
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));
      verify(reducer.invoke(initialState, Effect()));
    });


  });
}

final reducer = MockTestReducer();
final actor = MockTestActor();
final testActor = TestActor();
final initialState = State(1);

class TestFeature extends MviFeature<State, Effect, Action, SideEffect> {
  TestFeature() : super(initialState: initialState, reducer: reducer, actor: actor);
}

class TestReducer implements Reducer<State, Effect> {
  @override
  State invoke(State state, Effect effect) {
    return State(2);
  }
}

class TestActor implements Actor<State, Effect, Action> {
  @override
  Stream<Effect> invoke(State state, Action action) async* {
    yield Effect();
  }
}

class Action {}

class Effect {}

class SideEffect {}

class State {
  final int value;

  State(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is State && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
