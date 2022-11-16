import 'package:flutter_mvi/src/element/elements.dart';
import 'package:flutter_mvi/src/feature/mvi_feature.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'mvi_feature_test.mocks.dart';

@GenerateMocks([
  TestActor,
  TestReducer,
  TestSideEffectProducer,
  TestPostProcessor,
  TestBootstrapper,
  TestStreamListener,
])
void main() {
  group('simple mvi feature', () {
    test('emit initial state', () {
      /// arrange
      final reducer = MockTestReducer();
      final actor = MockTestActor();

      /// act
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      feature.state.listen(expectAsync1((State state) {
        /// assert
        expect(state, initialState);
      }, count: 1));
    });

    test('call actor', () async {
      /// arrange
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);

      /// act
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield Effect();
      });
      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));
      final action = Action();
      feature <= action;
      await Future.delayed(Duration(milliseconds: 10));

      /// assert
      verify(actor.invoke(initialState, action));
      await untilCalled(actor.invoke(initialState, action));
    });

    test('call reducer', () async {
      /// arrange
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      final effect = Effect();
      when(actor.invoke(any, any)).thenAnswer((_) async* {
        yield effect;
      });

      when(reducer.invoke(any, any)).thenReturn(initialState);

      /// act
      feature <= Action();

      /// assert
      await Future.delayed(Duration(milliseconds: 10));
      verify(reducer.invoke(initialState, effect));
      await untilCalled(reducer.invoke(initialState, effect));
    });

    test('call reducer twice', () async {
      /// arrange
      final reducer = MockTestReducer();
      when(reducer.invoke(any, any)).thenReturn(initialState);

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: TestBypassActor(),
      );

      /// act
      feature <= Action();
      feature <= Action();

      /// assert
      await Future.delayed(Duration(milliseconds: 100));
      verify(reducer.invoke(any, any)).called(2);
    });
  });

  group('full mvi feature', () {
    test('call SideEffectProducer', () async {
      /// arrange
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

      /// act
      final action = Action();
      feature <= action;

      /// assert
      await Future.delayed(Duration(milliseconds: 10));
      verify(sideEffectProducer.invoke(State(2), effect, action));
      await untilCalled(sideEffectProducer.invoke(State(2), effect, action));
    });

    test('call PostProcessor', () async {
      /// arrange
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

      /// act
      feature <= action;

      /// assert
      await Future.delayed(Duration(milliseconds: 10));
      verify(postProcessor.invoke(State(2), effect, action));
      await untilCalled(postProcessor.invoke(State(2), effect, action));
    });

    test('call Bootstrapper', () async {
      /// arrange
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

      /// act
      TestableFeature(initialState: initialState, reducer: reducer, actor: actor, bootstrapper: bootstrapper);

      /// assert
      await Future.delayed(Duration(milliseconds: 10));
      verify(bootstrapper.invoke());
      TestableFeature(initialState: initialState, reducer: reducer, actor: actor, bootstrapper: bootstrapper);
      await untilCalled(bootstrapper.invoke());
    });

    test('call disposable elements', () async {
      /// arrange
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final postProcessor = MockTestPostProcessor();
      final bootstrapper = MockTestBootstrapper();
      final streamListener = MockTestStreamListener();
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

      when(streamListener.actions).thenAnswer((_) async* {
        yield action;
      });

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: actor,
        bootstrapper: bootstrapper,
        streamListener: streamListener,
      );

      /// act
      feature.dispose();

      /// assert
      verify(actor.dispose());
      verify(streamListener.dispose());
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
    StreamListener<Action>? streamListener,
  }) : super(
          initialState: initialState,
          reducer: reducer,
          actor: actor,
          sideEffectProducer: sideEffectProducer,
          postProcessor: postProcessor,
          bootstrapper: bootstrapper,
          streamListener: streamListener,
        );
}

abstract class TestReducer implements Reducer<State, Effect> {}

abstract class TestActor implements Actor<State, Effect, Action> {}

abstract class TestSideEffectProducer implements SideEffectProducer<State, Effect, Action, SideEffect> {}

abstract class TestPostProcessor implements PostProcessor<State, Effect, Action> {}

abstract class TestBootstrapper implements Bootstrapper<Action> {}

abstract class TestStreamListener implements StreamListener<Action> {}

class Action {}

class Effect {}

class SideEffect {}

class State extends FeatureState{
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
