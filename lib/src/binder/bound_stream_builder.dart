import 'dart:async';

import 'package:flutter/widgets.dart';

typedef BoundWidgetBuilder<T> = Widget Function(BuildContext context, T value);

class BoundStreamBuilder<T> extends StatefulWidget {
  final Stream<T> stream;
  final T initialValue;
  final BoundWidgetBuilder<T> builder;

  const BoundStreamBuilder({
    Key? key,
    required this.stream,
    required this.initialValue,
    required this.builder,
  }) : super(key: key);

  Widget build(BuildContext context, T value) => builder(context, value);

  T afterConnected(T value) => value;

  @override
  State<BoundStreamBuilder<T>> createState() => _BoundStreamBuilderState<T>();
}

class _BoundStreamBuilderState<T> extends State<BoundStreamBuilder<T>> {
  StreamSubscription<T>? _subscription;
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    _subscribe();
  }

  @override
  void didUpdateWidget(BoundStreamBuilder<T> oldWidget) {
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
      if (mounted) {
        setState(() {
          value = data;
        });
      }
    });
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(context, value);
}
