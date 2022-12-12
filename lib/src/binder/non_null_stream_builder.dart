import 'dart:async';

import 'package:flutter/widgets.dart';

typedef UiWidgetBuilder<T> = Widget Function(BuildContext context, T value);

class NonNullStreamBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final T initialValue;
  final UiWidgetBuilder<T> builder;

  const NonNullStreamBuilder({
    Key? key,
    required this.stream,
    required this.initialValue,
    required this.builder,
  }) : super(key: key);

  Widget build(BuildContext context, T value) => builder(context, value);

  T afterConnected(T value) => value;

  @override
  State<NonNullStreamBuilder<T>> createState() => _NonNullStreamBuilderState<T>();
}

class _NonNullStreamBuilderState<T> extends State<NonNullStreamBuilder<T>> {
  StreamSubscription<T>? _subscription;
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    _subscribe();
  }

  @override
  void didUpdateWidget(NonNullStreamBuilder<T> oldWidget) {
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
        value = data;
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
  Widget build(BuildContext context) => widget.build(context, value);
}
