import 'package:flutter_mvi/src/element/elements.dart';
import 'package:flutter_mvi/src/feature/mvi_feature.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mvi_feature_test.mocks.dart';

@GenerateMocks([TestActor, TestReducer, TestSideEffectProducer, TestPostProcessor, TestBootstrapper])
void main() {
  group('simple mvi feature', () {
    test('emit initial state', () {
      final feature = SimpleFeature();
      feature.state.listen(expectAsync1((State state) {
        expect(state, initialState);
      }, count: 1));
    });

    test('call actor', () async {
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield Effect();
      });
      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));
      final feature = SimpleFeature();
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));
      verify(actor.invoke(initialState, action));
    });

    test('call reducer', () async {
      final effect = Effect();
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield effect;
      });
      final feature = SimpleFeature();
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));
      verify(reducer.invoke(initialState, effect));
    });
  });

  group('full mvi feature', () {
    test('call SideEffectProducer', () async {
      final effect = Effect();
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield effect;
      });
      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));
      when(sideEffectProducer.invoke(any, any, any)).thenReturn(SideEffect());
      when(postProcessor.invoke(any, any, any)).thenReturn(Action());
      final feature = FullFeature();
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));
      verify(sideEffectProducer.invoke(State(2), effect, action));
    });

  });
}

final reducer = MockTestReducer();
final actor = MockTestActor();
final sideEffectProducer = MockTestSideEffectProducer();
final postProcessor = MockTestPostProcessor();
final bootstrapper = MockTestBootstrapper();

final initialState = State(1);

class SimpleFeature extends MviFeature<State, Effect, Action, SideEffect> {
  SimpleFeature() : super(initialState: initialState, reducer: reducer, actor: actor);
}

class FullFeature extends MviFeature<State, Effect, Action, SideEffect> {
  FullFeature()
      : super(
          initialState: initialState,
          reducer: reducer,
          actor: actor,
          sideEffectProducer: sideEffectProducer,
          // postProcessor: postProcessor,
        // bootstrapper: bootstrapper,
        );
}

abstract class TestReducer implements Reducer<State, Effect> {}

abstract class TestActor implements Actor<State, Effect, Action> {}

abstract class TestSideEffectProducer implements SideEffectProducer<State, Effect, Action, SideEffect> {}

abstract class TestPostProcessor implements PostProcessor<State, Effect, Action> {}

abstract class TestBootstrapper implements Bootstrapper<Action> {}

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
