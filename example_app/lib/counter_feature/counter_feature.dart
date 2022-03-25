import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mvi/flutter_mvi.dart';
import 'package:rxdart/rxdart.dart';

import 'counter_repo.dart';

class CounterState {
  final int counter;
  final bool loading;

  CounterState({this.counter = 0, this.loading = false});

  @override
  String toString() {
    return "{counter: $counter loading: $loading}";
  }
}

class CounterAction {}

class IncrementClick extends CounterAction {}

class CounterEffect {}

class Increment extends CounterEffect {
  final int result;

  Increment(this.result);

  @override
  String toString() {
    return "{Increment value: $result}";
  }
}

class Loading extends CounterEffect {}

class CounterSideEffect {
  final String message;

  CounterSideEffect(this.message);
}

class CounterFeature extends MviFeature<CounterState, CounterEffect, CounterAction, CounterSideEffect> {
  CounterFeature(CounterRepo repo)
      : super(
          initialState: CounterState(),
          reducer: CounterReducer(),
          actor: CounterActor(repo),
          sideEffectProducer: CounterSideEffectProducer(),
          bootstrapper: CounterBootstrapper(),
        ) {
    debugPrint('Constructor');
  }
}

class CounterReducer extends Reducer<CounterState, CounterEffect> {
  @override
  CounterState invoke(CounterState state, CounterEffect effect) {
    if (effect is Increment) {
      return CounterState(counter: state.counter + effect.result);
    }
    if (effect is Loading) {
      return CounterState(loading: true, counter: state.counter);
    }
    return state;
  }
}

class CounterActor extends Actor<CounterState, CounterEffect, CounterAction> {
  final CounterRepo _repo;

  CounterActor(this._repo);

  final effects = PublishSubject<CounterEffect>();

  @override
  invoke(CounterState state, CounterAction action) {
    if (action is IncrementClick) {
      _onIncrement();
    }
    return effects;
  }

  _onIncrement() async {
    effects.add(Loading());
    final result = await _repo.getInt();
    effects.add(Increment(result));
  }
}

class CounterSideEffectProducer
    extends SideEffectProducer<CounterState, CounterEffect, CounterAction, CounterSideEffect> {
  @override
  invoke(state, effect, action) {
    return CounterSideEffect("Action was: $action and effect is: $effect");
  }
}

class CounterBootstrapper extends Bootstrapper<CounterAction> {
  @override
  Stream<CounterAction> invoke() async* {
    yield IncrementClick();
  }
}
