import 'package:flutter/widgets.dart';

import 'binder.dart';

abstract class BoundWidget<UiState, UiEvent> extends StatefulWidget {
  final Binder<UiState, UiEvent> binder;

  const BoundWidget({Key? key, required this.binder}) : super(key: key);

  Widget builder(BuildContext context, Binder<UiState, UiEvent> binder);

  @override
  State<StatefulWidget> createState() {
    return BoundWidgetState();
  }
}

class BoundWidgetState<UiState, UiEvent> extends State<BoundWidget> {
  BoundWidgetState();

  @override
  Widget build(BuildContext context) {
    widget.binder.context = context;
    return widget.builder(context, widget.binder);
  }

  @override
  void dispose() {
    widget.binder.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState(){
    super.initState();
  }
}
