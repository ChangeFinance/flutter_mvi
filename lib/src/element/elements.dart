import 'package:flutter_mvi/src/utils/action_effect_pair.dart';
import 'package:rxdart/rxdart.dart';

abstract class Reducer<State, Effect> {
  State invoke(State state, Effect effect);
}

abstract class SideEffectProducer<State, Effect, Action, SideEffect> {
  SideEffect? invoke(State state, Effect effect, Action action);
}

abstract class PostProcessor<State, Effect, Action> {
  Action? invoke(State state, Effect effect, Action action);
}

abstract class Bootstrapper<Action> {
  Stream<Action> invoke();
}

abstract class Actor<State, Effect, Action> {
  final PublishSubject<ActionEffect<Action, Effect>> _effects = PublishSubject();

  Stream<ActionEffect<Action, Effect>> get effects => _effects.stream;

  Action? _currentAction;

  processAction(State state, Action action) {
    _currentAction = action;
  }

  emit(Effect effect) {
    _effects.add(ActionEffect(_currentAction!, effect));
  }
}

