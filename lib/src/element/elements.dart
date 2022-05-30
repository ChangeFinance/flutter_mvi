import '../utils/disposable.dart';

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

abstract class Actor<State, Effect, Action> implements Disposable{

  final DisposableBucket bucket = DisposableBucket();

  Stream<Effect> invoke(State state, Action action);

  @override
  void dispose() {
    bucket.dispose();
  }
}