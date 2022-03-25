import '../element/elements.dart';
import 'mvi_feature.dart';

abstract class ReducerFeature<State, Effect, SideEffect> extends MviFeature<State, Effect, Effect, SideEffect> {
  ReducerFeature({
    required State initialState,
    required Reducer<State, Effect> reducer,
  }) : super(initialState: initialState, reducer: reducer, actor: BypassActor());
}

class BypassActor<State, Effect> extends Actor<State, Effect, Effect> {
  @override
  Stream<Effect> processAction(State state, Effect action) async* {
    yield action;
  }
}
