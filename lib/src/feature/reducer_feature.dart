import '../element/elements.dart';
import 'mvi_feature.dart';

abstract class ReducerFeature<S extends FeatureState, A extends FeatureAction, SideEffect> extends MviFeature<S, A, A, SideEffect> {
  ReducerFeature({
    required S initialState,
    required Reducer<S, A> reducer,
    SideEffectProducer<S, A, A, SideEffect>? sideEffectProducer,
  }) : super(initialState: initialState, reducer: reducer, actor: BypassActor());
}

class BypassActor<S extends FeatureState, A extends FeatureAction> extends Actor<S, A, A> {
  @override
  Stream<A> invoke(S state, A action) async* {
    yield action;
  }
}
