import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_mvi/flutter_mvi.dart';

import 'counter_repo.dart';
import 'counter_service.dart';

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

class SetCount extends CounterEffect {
  final int count;

  SetCount(this.count);

  @override
  String toString() {
    return "{SetCount value: $count}";
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
          actor: CounterActor(repo, service),
          sideEffectProducer: CounterSideEffectProducer(),
          bootstrapper: CounterBootstrapper(),
        ) {
    debugPrint('Constructor');
  }
}

class CounterReducer extends Reducer<CounterState, CounterEffect> {
  @override
  CounterState invoke(CounterState state, CounterEffect effect) {
    // if (effect is Increment) {
    //   return CounterState(counter: state.counter + effect.result);
    // }
    if (effect is Loading) {
      return CounterState(loading: true, counter: state.counter);
    }
    if (effect is SetCount) {
      return CounterState(loading: true, counter: effect.count);
    }
    return state;
  }
}

class CounterActor extends Actor<CounterState, CounterEffect, CounterAction> {
  final CounterRepo _repo;
  final CounterService _counterService;

  CounterActor(this._repo, this._counterService);

  @override
  Stream<CounterEffect> invoke(CounterState state, CounterAction action) async* {
    if (action is IncrementClick) {
      // yield* _onIncrement();
      yield NavigateEffect();
    }

    if (action is Bootstrap) {
      yield* _getTickChanges();
    }
  }

  Stream<CounterEffect> _getTickChanges() {
    return _counterService.counterStream.map((value) {
      print("COUNTER SERVICE TICK! $value");
      return SetCount(value);
    });
  }

  Stream<CounterEffect> _onIncrement() async* {
    yield (Loading());
    final result = await _repo.getInt();
    yield (Increment(result));
  }
}

class CounterSideEffectProducer
    extends SideEffectProducer<CounterState, CounterEffect, CounterAction, CounterSideEffect> {
  @override
  invoke(state, effect, action) {
    if (effect is NavigateEffect) {
      return CounterNavigateSideEffect();
    }
  }
}

class CounterBootstrapper extends Bootstrapper<CounterAction> {
  @override
  Stream<CounterAction> invoke() async* {
    // yield IncrementClick();
    yield Bootstrap();
  }
}
