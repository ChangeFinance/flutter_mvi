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
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      feature.state.listen(expectAsync1((State state) {
        expect(state, initialState);
      }, count: 1));
    });

    test('call actor', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);

      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield Effect();
      });
      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));
      verify(actor.invoke(initialState, action));
      await untilCalled(actor.invoke(initialState, action));
    });

    test('call reducer', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      final effect = Effect();
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield effect;
      });

      when(reducer.invoke(any, any)).thenReturn(initialState);
      feature <= Action();
      await Future.delayed(Duration(milliseconds: 10));
      verify(reducer.invoke(initialState, effect));
      await untilCalled(reducer.invoke(initialState, effect));
    });

    test('call reducer twice', () async {
      final reducer = MockTestReducer();
      when(reducer.invoke(any, any)).thenReturn(initialState);

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: TestBypassActor(),
      );

      feature <= Action();
      feature <= Action();

      await Future.delayed(Duration(milliseconds: 100));
      verify(reducer.invoke(any, any)).called(2);
    });
  });

  group('full mvi feature', () {
    test('call SideEffectProducer', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final sideEffectProducer = MockTestSideEffectProducer();
      final effect = Effect();
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield effect;
      });
      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));
      when(sideEffectProducer.invoke(any, any, any)).thenReturn(SideEffect());

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: actor,
        sideEffectProducer: sideEffectProducer,
      );

      final action = Action();
      feature <= action;

      await Future.delayed(Duration(milliseconds: 10));
      verify(sideEffectProducer.invoke(State(2), effect, action));
      await untilCalled(sideEffectProducer.invoke(State(2), effect, action));
    });

    test('call PostProcessor', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final postProcessor = MockTestPostProcessor();
      final effect = Effect();
      final action = Action();
      when(actor.invoke(initialState, action)).thenAnswer((_) async* {
        yield effect;
      });
      when(reducer.invoke(initialState, effect)).thenAnswer((_) => State(2));

      when(postProcessor.invoke(any, any, any)).thenReturn(null);

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: actor,
        postProcessor: postProcessor,
      );

      feature <= action;

      await Future.delayed(Duration(milliseconds: 10));
      verify(postProcessor.invoke(State(2), effect, action));
      await untilCalled(postProcessor.invoke(State(2), effect, action));
    });

    test('call Bootstrapper', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final postProcessor = MockTestPostProcessor();
      final bootstrapper = MockTestBootstrapper();
      final effect = Effect();
      final action = Action();
      when(actor.invoke(initialState, action)).thenAnswer((_) async* {
        yield effect;
      });
      when(reducer.invoke(initialState, effect)).thenAnswer((_) => State(2));

      when(postProcessor.invoke(any, any, any)).thenReturn(null);

      when(bootstrapper.invoke()).thenAnswer((_) async* {
        yield action;
      });

      TestableFeature(initialState: initialState, reducer: reducer, actor: actor, bootstrapper: bootstrapper);
      await Future.delayed(Duration(milliseconds: 10));
      verify(bootstrapper.invoke());
      TestableFeature(initialState: initialState, reducer: reducer, actor: actor, bootstrapper: bootstrapper);
      await untilCalled(bootstrapper.invoke());
    });
  });
}

final initialState = State(1);

class TestableFeature extends MviFeature<State, Effect, Action, SideEffect> {
  TestableFeature({
    required State initialState,
    required Reducer<State, Effect> reducer,
    required Actor<State, Effect, Action> actor,
    SideEffectProducer<State, Effect, Action, SideEffect>? sideEffectProducer,
    PostProcessor<State, Effect, Action>? postProcessor,
    Bootstrapper<Action>? bootstrapper,
  }) : super(
          initialState: initialState,
          reducer: reducer,
          actor: actor,
          sideEffectProducer: sideEffectProducer,
          postProcessor: postProcessor,
          bootstrapper: bootstrapper,
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

  @override
  String toString() {
    return super.toString();
  }
}

class TestBypassActor extends Actor<State, Effect, Action> {
  @override
  Stream<Effect> invoke(State state, Action action) async* {
    yield (Effect());
  }
}