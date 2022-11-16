import '../element/elements.dart';
import 'mvi_feature.dart';

abstract class ReducerFeature<S extends FeatureState, Action, SideEffect> extends MviFeature<S, Action, Action, SideEffect> {
  ReducerFeature({
    required S initialState,
    required Reducer<S, Action> reducer,
    SideEffectProducer<S, Action, Action, SideEffect>? sideEffectProducer,
  }) : super(initialState: initialState, reducer: reducer, actor: BypassActor());
}

class BypassActor<S extends FeatureState, Action> extends Actor<S, Action, Action> {
  @override
  Stream<Action> invoke(S state, Action action) async* {
    yield action;
  }
}
