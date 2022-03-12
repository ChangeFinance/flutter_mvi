import 'package:counter/counter_feature/counter_feature.dart';
import 'package:counter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvi/flutter_mvi.dart';

class CounterBinder extends Binder<CounterUIState, CounterUIEvent> {
  CounterFeature counterFeature;

  CounterBinder(this.counterFeature) : super(stateTransformer(counterFeature)) {
    bind<CounterSideEffect>(counterFeature.sideEffects, to: sideEffectListener);
    bindUiEventTo<CounterAction>(counterFeature, using: eventToAction);
  }

  sideEffectListener(CounterSideEffect effect) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(effect.message)));
  }

  CounterAction? eventToAction(CounterUIEvent uiEvent) {
    if (uiEvent is PlusClicked) {
      return IncrementClick();
    }
    return null;
  }
}

Stream<CounterUIState> Function() stateTransformer(CounterFeature counterFeature) {
  return () => counterFeature.state.map((state) => CounterUIState(counter: state.counter, loading: state.loading));
}
