import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mvi/flutter_mvi.dart';
import 'package:rxdart/rxdart.dart';

import 'bound_stream_builder.dart';

abstract class UiState {
  const UiState();
}

abstract class UiEvent {}

abstract class Binder<U extends UiState, E extends UiEvent> {
  final Transformer<U> transformer;
  final DisposableBucket bucket = DisposableBucket();
  final PublishSubject<E> _uiEvents = PublishSubject();
  final BuildContext context;
  U _lastState;

  Binder(this.context, this.transformer) : _lastState = transformer.initialUiState(context) {
    bucket <=
        transformer.uiStateStream(context).listen((state) {
          _lastState = state;
        });
  }

  /// Method that provides state to bounded widget
  Widget stateBuilder(BoundWidgetBuilder<U> builder, {bool Function(U currentState, U nextState)? rebuildWhen = null}) {
    return BoundStreamBuilder<U>(
      builder: builder,
      stream: transformer.uiStateStream(context),
      initialValue: _lastState,
      rebuildWhen: rebuildWhen,
    );
  }

  /// Binding feature side effect to listener function
  /// if listener function is not provided, will still add
  /// feature to bucket.
  ///
  /// Adding feature to bucket is important, so it is mandatory to
  /// call this method.
  void bind<T>(MviFeature feature, {Function(T value)? to}) {
    bucket <= feature;
    to?.let((func) {
      bucket <=
          feature.sideEffects.listen((v) {
            func.call(v);
          });
    });
  }

  /// Binding UiEvent (user interactions) to feature.
  /// Also adding feature to disposable bucket.
  void bindUiEventTo<A extends FeatureAction>(MviFeature feature, {required A? Function(E uiEvent) using}) {
    bucket <= feature;
    bucket <=
        _uiEvents.listen((uiEvent) {
          using(uiEvent)?.let((action) {
            feature <= action;
          });
        });
  }

  void dispose() => bucket.dispose();

  void add(E event) {
    _uiEvents.sink.add(event);
  }
}

class Transformer<U extends UiState> {
  final Stream<U> Function(BuildContext context) uiStateStream;
  final U Function(BuildContext context) initialUiState;

  Transformer({
    required this.uiStateStream,
    required this.initialUiState,
  });
}
