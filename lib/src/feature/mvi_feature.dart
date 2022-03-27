import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../element/elements.dart';
import '../utils/disposable.dart';
import '../utils/extensions.dart';

abstract class MviFeature<State, Effect, Action, SideEffect> implements Disposable {
  Stream<State> get state => _state;

  Stream<SideEffect> get sideEffects => _sideEffects;

  StreamSink<Action> get actions => _actions.sink;

  final BehaviorSubject<State> _state = BehaviorSubject();
  final PublishSubject<SideEffect> _sideEffects = PublishSubject();
  final PublishSubject<Action> _actions = PublishSubject();

  final DisposableBucket _bucket = DisposableBucket();

  MviFeature({
    required State initialState,
    required Reducer<State, Effect> reducer,
    required Actor<State, Effect, Action> actor,
    SideEffectProducer<State, Effect, Action, SideEffect>? sideEffectProducer,
    PostProcessor<State, Effect, Action>? postProcessor,
    Bootstrapper<Action>? bootstrapper,
  }) {
    _state.add(initialState);

    _bucket <=
        _actions.listen((action) {
          actor.invoke(_state.value, action).listen((effect) {
            final newState = reducer.invoke(_state.value, effect);
            _state.add(newState);
            sideEffectProducer?.invoke(newState, effect, action)?.let((sideEffect) => _sideEffects.add(sideEffect));
            postProcessor?.invoke(newState, effect, action)?.let((postAction) => actions.add(postAction));
          });
        });

    bootstrapper?.let((boot) {
      _bucket <=
          boot.invoke().listen((action) {
            actions.add(action);
          });
    });
  }

  @override
  void dispose() => _bucket.dispose();
}

extension FeatureExtension<State, Effect, Action, SideEffect> on MviFeature<State, Effect, Action, SideEffect> {
  void operator <=(Action action) {
    actions.add(action);
  }
}
