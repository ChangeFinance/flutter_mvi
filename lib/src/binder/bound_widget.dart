import 'package:flutter/widgets.dart';

import 'binder.dart';

abstract class BoundWidget<U extends UiState,  E extends UiEvent> extends StatefulWidget {
  final Binder<U, E> binder;

  const BoundWidget({Key? key, required this.binder}) : super(key: key);

  Widget builder(BuildContext context, Binder<U, E> binder);

  @override
  State<StatefulWidget> createState() {
    return BoundWidgetState();
  }
}

class BoundWidgetState<U, E> extends State<BoundWidget> {
  BoundWidgetState();

  @override
  Widget build(BuildContext context) {
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
