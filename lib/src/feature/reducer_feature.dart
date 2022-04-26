import '../element/elements.dart';
import 'mvi_feature.dart';

abstract class ReducerFeature<State, Action, SideEffect> extends MviFeature<State, Action, Action, SideEffect> {
  ReducerFeature({
    required State initialState,
    required Reducer<State, Action> reducer,
    SideEffectProducer<State, Action, Action, SideEffect>? sideEffectProducer,
  }) : super(initialState: initialState, reducer: reducer, actor: BypassActor());
}

class BypassActor<State, Action> extends Actor<State, Action, Action> {
  @override
  Stream<Action> invoke(State state, Action action) async* {
    yield action;
  }
}
