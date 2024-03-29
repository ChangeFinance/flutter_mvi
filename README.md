# Flutter MVI

Mvi state management implementation for dart/flutter projects.
Easily extendable approach based on composition, use only what you need.

[lucid](https://lucid.app/lucidchart/ac9b33fd-71a3-4e1a-9b3d-9feeda497cf6/edit?viewport_loc=-455%2C-243%2C1876%2C1211%2C0_0&invitationId=inv_0e6ece97-bec9-4017-bfdc-69bd09f6d15b#)

<img src="https://user-images.githubusercontent.com/841716/163926194-edc7fb58-0e99-4901-a431-8f6b8cbcb74e.png" width="700" height="550">


### Building blocks and terms

Mvi consists of several simple element. Each element does only **one** job:
* **Actor**: consumes *Action*, produces *Effect* .
* **Reducer**: consumes *Effect* , produces *State*.
* **SideEffectProducer**: consumes and *Effect*, produces optional side effect (one time event/ single live event).
* **PostProcessor**: consumes *Effect*, produces optional *Action*.
* **Bootstrapper**: produces initial *Action*.
* **StreamListener**: subscribes to stream or streams and produces reactive *Action*s.
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
```dart
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

Binder is a class that connects feature or multiple features to Widget.
Binding is made both ways, **to** feature and **form** feature.

Bindings **from** feature to UI are made with *feature state* transforming to UiState used by widget 

    stateTransformer(counterFeature)

and/or listening to *side effects* 

    bind<CounterSideEffect>(counterFeature.sideEffects, to: sideEffectListener);

Bindings **to** feature are done with mapping UiEvents to feature actions

    bindUiEventTo<CounterAction>(counterFeature, using: eventToAction);

Example bider : 

```dart
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
