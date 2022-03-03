abstract class Reducer<State, Effect> {
  State invoke(State state, Effect effect);
}

abstract class Actor<State, Effect, Action> {
  Stream<Effect> invoke(State state, Action action);
}

abstract class SideEffectProducer<State, Effect, Action, SideEffect> {
  SideEffect? invoke(State state, Effect effect, Action action);
}

abstract class PostProcessor<State, Effect, Action> {
  Action? invoke(State state, Effect effect, Action action);
}

abstract class Bootstrapper<Action>{
  Stream<Action> invoke();
}