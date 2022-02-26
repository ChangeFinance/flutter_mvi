import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/disposable.dart';

abstract class Binder<UiState, UiEvent> {
  final Stream<UiState> Function() transformer;
  late BuildContext context;
  Function()? onViewReady;

  final DisposableBucket bucket = DisposableBucket();

  Binder(this.transformer);

  Widget stateBuilder(AsyncWidgetBuilder<UiState> builder) {
    return StreamBuilder<UiState>(builder: builder, stream: transformer());
  }

  void call(UiEvent event);

  void dispose() => bucket.dispose();
}
