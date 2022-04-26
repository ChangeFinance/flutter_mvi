import '../element/elements.dart';
import 'mvi_feature.dart';

abstract class ReducerFeature<State, Effect, SideEffect> extends MviFeature<State, Effect, Effect, SideEffect> {
  ReducerFeature({
    required State initialState,
    required Reducer<State, Effect> reducer,
    SideEffectProducer<State, Effect, Effect, SideEffect>? sideEffectProducer,
  }) : super(initialState: initialState, reducer: reducer, actor: BypassActor());
}

class BypassActor<State, Effect> extends Actor<State, Effect, Effect> {
  @override
  Stream<Effect> invoke(State state, Effect action) async* {
    yield action;
  }
}
