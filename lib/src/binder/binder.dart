import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mvi/flutter_mvi.dart';
import 'package:rxdart/rxdart.dart';

abstract class UiState {
  const UiState();
}

abstract class UiEvent {}

abstract class Binder<U extends UiState, E extends UiEvent> {
  final Stream<U> Function(BuildContext context) _streamTransformer;
  final U Function(BuildContext context) transform;
  final DisposableBucket bucket = DisposableBucket();
  final PublishSubject<E> _uiEvents = PublishSubject();
  late BuildContext context;

  Binder(this._streamTransformer, this.transform);

  /// Method that provides state to bounded widget
  Widget stateBuilder(WidgetBuilder<U> builder) {
    return FeatureStreamBuilder<U>(
      builder: builder,
      stream: _streamTransformer(context),
      initialState: transform(context),
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

typedef WidgetBuilder<T> = Widget Function(BuildContext context, T uiState);

class FeatureStreamBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final T initialState;
  final WidgetBuilder<T> builder;

  const FeatureStreamBuilder({
    Key? key,
    required this.stream,
    required this.initialState,
    required this.builder,
  }) : super(key: key);

  Widget build(BuildContext context, T uiState) => builder(context, uiState);

  T afterConnected(T uiState) => uiState;

  @override
  State<FeatureStreamBuilder<T>> createState() => _FeatureStreamBuilderState<T>();
}

class _FeatureStreamBuilderState<T> extends State<FeatureStreamBuilder<T>> {
  StreamSubscription<T>? _subscription;
  late T uiState;

  @override
  void initState() {
    super.initState();
    uiState = widget.initialState;
    _subscribe();
  }

  @override
  void didUpdateWidget(FeatureStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.stream.listen((T data) {
      setState(() {
        uiState = data;
      });
    });
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, uiState);
}
