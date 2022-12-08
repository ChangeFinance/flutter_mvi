import 'package:counter/counter_feature/counter_feature.dart';
import 'package:counter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvi/flutter_mvi.dart';

import 'blank_screen.dart';

class CounterBinder extends Binder<CounterUIState, CounterUIEvent> {
  CounterFeature counterFeature;

  CounterBinder(this.counterFeature)
      : super(
          (context) => counterFeature.state.map((state) => stateTransformer(state)),
          (context) => stateTransformer(counterFeature.initialState),
        ) {
    bind<CounterSideEffect>(counterFeature, to: sideEffectListener);
    bindUiEventTo<CounterAction>(counterFeature, using: eventToAction);
  }

  sideEffectListener(CounterSideEffect effect) {
    Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) {
          return BlankScreen();
        },
      ),
    );
  }

  CounterAction? eventToAction(CounterUIEvent uiEvent) {
    if (uiEvent is PlusClicked) {
      return IncrementClick();
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

CounterUIState stateTransformer(CounterState state) {
  return CounterUIState(counter: state.counter, loading: state.loading);
}
