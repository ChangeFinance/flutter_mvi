import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mvi/flutter_mvi.dart';
import 'package:rxdart/rxdart.dart';

abstract class UiState{
  const UiState();
}

abstract class UiEvent {}

abstract class Binder<U extends UiState, E extends UiEvent> {
  final Stream<U> Function(BuildContext context) _transformer;
  final DisposableBucket bucket = DisposableBucket();
  final PublishSubject<E> _uiEvents = PublishSubject();
  late BuildContext context;

  Binder(this._transformer);

  /// Method that provides state to bounded widget
  Widget stateBuilder(AsyncWidgetBuilder<U> builder) {
    return StreamBuilder<U>(builder: builder, stream: _transformer(context));
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

  get add => _uiEvents.sink.add;
}
