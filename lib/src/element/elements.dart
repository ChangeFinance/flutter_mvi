import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../utils/disposable.dart';

abstract class FeatureState{}

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
abstract class SideEffectProducer<S extends FeatureState, Effect, Action, SideEffect> {
  SideEffect? invoke(S state, Effect effect, Action action);
}

/// Invoked on each new effect, produces action.
///
/// Used for initialisation of new action -> effect loop for more complex execution logic.
/// Producing action is optional for given state/effect/action.
abstract class PostProcessor<S extends FeatureState, Effect, Action> {
  Action? invoke(S state, Effect effect, Action action);
}

/// Invoked on initialisation, produces initial action or actions.
///
/// Used for warmup/bootstrap feature on initialisation
abstract class Bootstrapper<Action> {
  Stream<Action> invoke();
}

/// Listened on initialisation, produces actions.
///
/// Used for listening to streams and disposing subscriptions.
abstract class StreamListener<Action> implements Disposable {
  Stream<Action> get actions => _actions.stream;
  final PublishSubject<Action> _actions = PublishSubject();

  final DisposableBucket bucket = DisposableBucket();

  void addAction(Action action) {
    _actions.add(action);
  }

  @override
  void dispose() {
    bucket.dispose();
  }
}

/// Invoked on every action, produces effects that are consumed by all other element.
abstract class Actor<S extends FeatureState, Effect, Action> implements Disposable {
  final DisposableBucket bucket = DisposableBucket();

  Stream<Effect> invoke(S state, Action action);

  @override
  void dispose() {
    bucket.dispose();
  }
}
