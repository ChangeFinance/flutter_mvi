# Flutter Mvi

Mvi state management implementation for dart/flutter projects.
Easily extendable approach based on composition, use only what you need.

![Mvi data flow ](https://user-images.githubusercontent.com/841716/163852339-85e684ea-d87f-4711-897d-9dd20ae212b4.png)


### Building blocks and terms

Mvi consists of several simple element. Each element does only **one** job:
* **Actor**: consumes *Action*, produces *Effect* .
* **Reducer**: consumes *Effect* , produces *State*.
* **SideEffectProducer**: consumes *Action*, *State* and *Effect*, produces optional side effect (one time event/ single live event).
* **PostProcessor**: consumes *Action*, *State* and *Effect*, produces optional *Action*.
* **Bootstrapper**: produces initial *Action*.
* **Feature**: class that does all the cross-element communication under the hood.
 ___
* **State**: immutable data class *without* any logic, represents feature's current state.
* **Action**: an incoming event (IncrementClick, TabSelected, Confirmed etc.)
* **Effect**: a result of Actor (Loading, DataLoaded, Error etc.)
* **SideEffect**: a one time event (AuthorisationSuccessful, ErrorToast etc.)
  
**MviFeature**: base feature class, mother of all features. 

**ReducerFeature**: simplest base feature that can handle only synchronous jobs. The only element you have to implement is a *Reducer*.

In general **Actor** does all the heavy lifting (calling repositories, apis) everything that needs outer world communication or asynchronous tasks. All other elements are **synchronous**.

Simple feature with actor : 
```
class CounterFeature extends MviFeature<CounterState, CounterEffect, CounterAction, CounterSideEffect> {  
  CounterFeature(CounterRepo repo)  
      : super(  
          initialState: CounterState(),  
	  reducer: CounterReducer(),  
	  actor: CounterActor(repo),  
  );  
}
```

## Binder

Bider is a class that connects feature or multiple features to Widget.
Binding is made both ways, **to** feature and **form** feature.

Bindings **from** feature to UI are made with *feature state* transforming to UiState used by widget 

    stateTransformer(counterFeature)

and/or listening to *side effects* 

    bind<CounterSideEffect>(counterFeature.sideEffects, to: sideEffectListener);

Bindings **to** feature are done with mapping UiEvents to feature actions

    bindUiEventTo<CounterAction>(counterFeature, using: eventToAction);

Example bider : 

```
class CounterBinder extends Binder<CounterUIState, CounterUIEvent> {  
  CounterFeature counterFeature;  
  
  CounterBinder(this.counterFeature) : super(stateTransformer(counterFeature)) {  
    bind<CounterSideEffect>(counterFeature.sideEffects, to: sideEffectListener);  
  bindUiEventTo<CounterAction>(counterFeature, using: eventToAction);  
  }  
  
  sideEffectListener(CounterSideEffect effect) {  
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(effect.message)));  
  }  
  
  CounterAction? eventToAction(CounterUIEvent uiEvent) {  
    if (uiEvent is PlusClicked) {  
      return IncrementClick();  
  }  
    return null;  
  }
```

For example app see [example app github](https://github.com/ChangeFinance/flutter_mvi/tree/master/example_app)
