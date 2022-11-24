import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mvi/flutter_mvi.dart';

import 'counter_repo.dart';
import 'counter_service.dart';

class CounterState extends FeatureState {
  final int counter;
  final bool loading;

  const CounterState({this.counter = 0, this.loading = false});

  @override
  String toString() {
    return "{counter: $counter loading: $loading}";
  }
}

class CounterAction extends FeatureAction {}

class IncrementClick extends CounterAction {}

class SetCountAction extends CounterAction {
  final int count;

  SetCountAction(this.count);

  @override
  String toString() {
    return "{SetCountAction value: $count}";
  }
}

class Bootstrap extends CounterAction {}

class CounterEffect {}

class NavigateEffect extends CounterEffect {}

class Increment extends CounterEffect {
  final int result;

  Increment(this.result);

  @override
  String toString() {
    return "{Increment value: $result}";
  }
}

class SetCountEffect extends CounterEffect {
  final int count;

  SetCountEffect(this.count);

  @override
  String toString() {
    return "{SetCountEffect value: $count}";
  }
}

class Loading extends CounterEffect {}

abstract class CounterSideEffect {}

class CounterMessageSideEffect {
  final String message;

  CounterMessageSideEffect(this.message);
}

class CounterNavigateSideEffect extends CounterSideEffect {}

class CounterFeature extends MviFeature<CounterState, CounterEffect, CounterAction, CounterSideEffect> {
  CounterFeature(CounterRepo repo, CounterService service)
      : super(
          initialState: CounterState(),
          reducer: CounterReducer(),
          actor: CounterActor(repo),
          sideEffectProducer: CounterSideEffectProducer(),
          streamListener: CounterStreamListener(service),
          showDebugLogs: true,
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
    if (effect is SetCountEffect) {
      return CounterState(loading: true, counter: effect.count);
    }
    return state;
  }
}

class CounterActor extends Actor<CounterState, CounterEffect, CounterAction> {
  final CounterRepo _repo;

  CounterActor(this._repo);

  @override
  Stream<CounterEffect> invoke(CounterState state, CounterAction action) async* {
    if (action is IncrementClick) {
      yield* _onIncrement();
    }
    if (action is SetCountAction) {
      yield SetCountEffect(action.count);
    }
  }

  Stream<CounterEffect> _onIncrement() async* {
    yield (Loading());
    final result = await _repo.getInt();
    yield (Increment(result));
  }
}

class CounterSideEffectProducer extends SideEffectProducer<CounterEffect, CounterSideEffect> {
  @override
  invoke(effect) {
    if (effect is NavigateEffect) {
      return CounterNavigateSideEffect();
    }
    return null;
  }
}

class CounterStreamListener extends StreamListener<CounterAction> {
  final CounterService _counterService;

  CounterStreamListener(this._counterService) {
    bucket <=
        _counterService.counterStream.listen((value) {
          print("COUNTER SERVICE TICK! $value");
          addAction(SetCountAction(value));
        });
  }
}
