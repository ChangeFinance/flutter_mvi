import 'package:counter/counter_feature/counter_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvi/flutter_mvi.dart';

class CounterUIState {
  final int counter;
  final bool loading;

  CounterUIState({required this.counter, required this.loading});
}

class CounterUIEvent {}

class PlusClicked extends CounterUIEvent {}

class CounterBinder extends Binder<CounterUIState, CounterUIEvent> {
  CounterFeature counterFeature;

  CounterBinder(this.counterFeature)
      : super(
          () => counterFeature.state.map((state) => CounterUIState(counter: state.counter, loading: state.loading)),
        ) {
    bucket <=
        counterFeature.sideEffects.listen(
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.message)));
          },
        );

    bucket <= counterFeature;
  }

  @override
  void call(CounterUIEvent event) {
    if (event is PlusClicked) {
      counterFeature <= (IncrementClick());
    }
  }
}
