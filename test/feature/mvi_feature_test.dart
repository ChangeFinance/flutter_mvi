import 'package:flutter_mvi/src/element/elements.dart';
import 'package:flutter_mvi/src/feature/mvi_feature.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'mvi_feature_test.mocks.dart';

@GenerateMocks([TestActor, TestReducer, TestSideEffectProducer, TestPostProcessor, TestBootstrapper])
void main() {
  group('simple mvi feature', () {
    test('emit initial state', () {
      final reducer = MockTestReducer();
      final actor = MockTestActor();

      when(actor.effects).thenAnswer((_) => PublishSubject());
      when(actor.processAction(any, any)).thenReturn(null);

      when(reducer.invoke(any, any)).thenAnswer((_) => initialState);

      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      feature.state.listen(expectAsync1((State state) {
        expect(state, initialState);
      }, count: 1));
    });

    test('call actor', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final action = Action();

      when(actor.effects).thenAnswer((_) => PublishSubject());
      when(actor.processAction(any, any)).thenReturn(null);
      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));

      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      feature <= action;
      await untilCalled(actor.processAction(initialState, action));
    });

    test('call reducer', () async {
      final reducer = MockTestReducer();
      final effect = Effect();

      final actor = TestBypassActor(effect: effect);
      when(reducer.invoke(any, any)).thenReturn(initialState);
      final feature = TestableFeature(initialState: initialState, reducer: reducer, actor: actor);
      feature <= Action();
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
      final action = Action();

      when(actor.effects).thenAnswer((_) async* {
        yield ActionEffect(action, effect);
      });
      when(actor.processAction(any, any)).thenReturn(null);

      when(reducer.invoke(any, any)).thenAnswer((_) => State(2));
      when(sideEffectProducer.invoke(any, any, any)).thenReturn(SideEffect());

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: actor,
        sideEffectProducer: sideEffectProducer,
      );

      feature <= action;

      await untilCalled(sideEffectProducer.invoke(State(2), effect, action));
    });

    test('call PostProcessor', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final postProcessor = MockTestPostProcessor();

      final effect = Effect();
      final action = Action();
      when(actor.effects).thenAnswer((_) async* {
        yield ActionEffect(action, effect);
      });
      when(actor.processAction(any, any)).thenReturn(null);
      when(reducer.invoke(initialState, effect)).thenAnswer((_) => State(2));

      when(postProcessor.invoke(any, any, any)).thenReturn(null);

      final feature = TestableFeature(
        initialState: initialState,
        reducer: reducer,
        actor: actor,
        postProcessor: postProcessor,
      );

      feature <= action;

      await untilCalled(postProcessor.invoke(State(2), effect, action));
    });

    test('call Bootstrapper', () async {
      final reducer = MockTestReducer();
      final actor = MockTestActor();
      final postProcessor = MockTestPostProcessor();
      final bootstrapper = MockTestBootstrapper();
      final effect = Effect();
      final action = Action();
      when(actor.effects).thenAnswer((_) async* {
        yield ActionEffect(action, effect);
      });
      when(actor.processAction(any, any)).thenReturn(null);
      when(reducer.invoke(initialState, effect)).thenAnswer((_) => State(2));

      when(postProcessor.invoke(any, any, any)).thenReturn(null);

      when(bootstrapper.invoke()).thenAnswer((_) async* {
        yield action;
      });

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

class TestBypassActor extends Actor<State, Effect, Action> {
  Effect? _effect;

  TestBypassActor({Effect? effect = null}) {
    _effect = effect;
  }

  @override
  processAction(State state, Action action) {
    super.processAction(state, action);
    emit(_effect == null ? Effect() : _effect!);
  }
}

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
