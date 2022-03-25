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
  final PublishSubject<Pair<Action, Effect>> _effects = PublishSubject();

  Stream<Pair<Action, Effect>> get effects => _effects.stream;

  Action? _currentAction;

  processAction(State state, Action action) {
    _currentAction = action;
  }

  emit(Effect e) {
    _effects.add(Pair(_currentAction!, e));
  }
}

class Pair<A, B> {
  final A a;
  final B b;

  Pair(this.a, this.b);
}
