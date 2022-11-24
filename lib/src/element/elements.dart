import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../utils/disposable.dart';

abstract class FeatureState{
  const FeatureState();
}


abstract class FeatureAction{
  const FeatureAction();
}

/// Invoked on each new effect.
/// Consumes [effect], produces new state.
/// The only class that can mutate [state].
///
/// State producing is optional for given state/effect.
abstract class Reducer<S extends FeatureState, Effect> {
  S invoke(S state, Effect effect);
}

/// Invoked on each new effect, produces sideEffect.
///
/// Used for SingleLiveEvent like effects.
/// Producing sideEffect is optional state/effect/action.
abstract class SideEffectProducer< Effect, SideEffect> {
  SideEffect? invoke(Effect effect);
}

/// Invoked on each new effect, produces action.
///
/// Used for initialisation of new action -> effect loop for more complex execution logic.
/// Producing action is optional for given state/effect/action.
abstract class PostProcessor<Effect, A extends FeatureAction> {
  A? invoke(Effect effect);
}

/// Invoked on initialisation, produces initial action or actions.
///
/// Used for warmup/bootstrap feature on initialisation
abstract class Bootstrapper<A extends FeatureAction> {
  Stream<A> invoke();
}

/// Listened on initialisation, produces actions.
///
/// Used for listening to streams and disposing subscriptions.
abstract class StreamListener<A extends FeatureAction> implements Disposable {
  Stream<A> get actions => _actions.stream;
  final PublishSubject<A> _actions = PublishSubject();

  final DisposableBucket bucket = DisposableBucket();

  void addAction(A action) {
    _actions.add(action);
  }

  @override
  void dispose() {
    bucket.dispose();
  }
}

/// Invoked on every action, produces effects that are consumed by all other element.
abstract class Actor<S extends FeatureState, Effect, A extends FeatureAction> implements Disposable {
  final DisposableBucket bucket = DisposableBucket();

  Stream<Effect> invoke(S state, A action);

  @override
  void dispose() {
    bucket.dispose();
  }
}
