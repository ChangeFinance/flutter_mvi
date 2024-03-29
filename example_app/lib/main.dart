import 'package:counter/counter_feature/counter_binder.dart';
import 'package:counter/counter_feature/counter_feature.dart';
import 'package:counter/counter_feature/counter_repo.dart';
import 'package:counter/counter_feature/counter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvi/flutter_mvi.dart';

void main() {
  runApp(const App());
}

final service = CounterService();

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final binder = CounterBinder(context, CounterFeature(CounterRepo(), service));

    return MaterialApp(
      title: 'Flutter Mvi Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(binder: binder),
    );
  }
}

class HomePage extends BoundWidget<CounterUIState, CounterUIEvent> {
  const HomePage({Key? key, required Binder<CounterUIState, CounterUIEvent> binder}) : super(key: key, binder: binder);

  @override
  Widget builder(BuildContext context, Binder<CounterUIState, CounterUIEvent> binder) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Mvi Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            binder.stateBuilder((context, snapshot) {
              var counter = snapshot.counter;
              return Text(counter.toString());
            }),
            binder.stateBuilder((context, snapshot) {
              var loading = snapshot.loading;
              return Text(loading.toString());
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          binder.add(PlusClicked());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterUIState extends UiState{
  final int counter;
  final bool loading;

  CounterUIState({required this.counter, required this.loading});
}

class CounterUIEvent extends UiEvent {}

class PlusClicked extends CounterUIEvent {}
