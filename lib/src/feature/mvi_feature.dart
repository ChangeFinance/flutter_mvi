import 'dart:async';
import 'dart:developer';

import 'package:rxdart/rxdart.dart';

import '../element/elements.dart';
import '../utils/disposable.dart';
import '../utils/extensions.dart';

abstract class MviFeature<S extends FeatureState, Effect, Action, SideEffect> implements Disposable {
  Stream<S> get state => _state.distinct();

  Stream<SideEffect> get sideEffects => _sideEffects;

  StreamSink<Action> get actions => _actions.sink;

  final BehaviorSubject<S> _state = BehaviorSubject();
  final PublishSubject<SideEffect> _sideEffects = PublishSubject();
  final PublishSubject<Action> _actions = PublishSubject();

  final DisposableBucket _bucket = DisposableBucket();
  final bool showDebugLogs;

  MviFeature({
    required S initialState,
    required Reducer<S, Effect> reducer,
    required Actor<S, Effect, Action> actor,
    SideEffectProducer<S, Effect, Action, SideEffect>? sideEffectProducer,
    PostProcessor<S, Effect, Action>? postProcessor,
    Bootstrapper<Action>? bootstrapper,
    StreamListener<Action>? streamListener,
    this.showDebugLogs = false,
  }) {
    _state.add(initialState);

    _bucket <= actor;

    _bucket <=
        _actions.listen((action) {
          _log('$this consumed action: $action ');
          _bucket <=
              actor.invoke(_state.value, action).listen((effect) {
                _log('$actor produced effect: $effect ');
                final newState = reducer.invoke(_state.value, effect);
                _state.add(newState);
                _log('$reducer produced new state: $newState ');
                sideEffectProducer?.invoke(newState, effect, action)?.let((sideEffect) {
                  _sideEffects.add(sideEffect);
                  _log('$sideEffectProducer produced side effect: $sideEffect ');
                });
                postProcessor?.invoke(newState, effect, action)?.let((postAction) {
                  actions.add(postAction);
                  _log('$postProcessor produced action: $postAction ');
                });
              });
        });

    bootstrapper?.let((boot) {
      _bucket <=
          boot.invoke().listen((action) {
            actions.add(action);
            _log('$bootstrapper produced action: $action ');
          });
    });

    streamListener?.let((listener) {
      _bucket <= listener;
      _bucket <=
          listener.actions.listen((action) {
            actions.add(action);
            _log('$streamListener produced action: $action ');
          });
    });
  }

  _log(String arg) {
    if (showDebugLogs) {
      log('>>Mvi log: $arg');
    }
  }

  @override
  void dispose() => _bucket.dispose();
}

extension FeatureExtension<S extends FeatureState, Effect, Action, SideEffect> on MviFeature<S, Effect, Action, SideEffect> {
  void operator <=(Action action) {
    actions.add(action);
  }
}
