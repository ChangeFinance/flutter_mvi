# Flutter Mvi

Mvi state management implementation for dart/flutter projects.
Easily extendable approach based on composition, use only what you need.

### Building blocks and terms

Consists of simple elements. Each element does only **one** job:
* **Actor** consumes *Action*, produces *Effect* .
* **Reducer** consumes *Effect* , produces *State*.
* **SideEffectProducer** consumes *Action*, *State* and *Effect*, produces optional side effect (one time event/ single live event).
* **PostProcessor** consumes *Action*, *State* and *Effect*, produces optional *Action*.
* **Bootstrapper** produces initial *Action*.
* **Feature** class that does all the cross-element communication under the hood.
 ___
* **State** immutable data class *without* any logic, represents feature's current state.
* **Action** an incoming event (IncrementClick, TabSelected, Confirmed etc.)
* **Effect** a result of Actor (Loading, DataLoaded, Error etc.)
* **SideEffect** SLV or one time event (AuthorisationSuccessful, ErrorToast etc.)
  
**MviFeature** base feature class, mother of all features. 

**ReducerFeature** simplest base feature that can handle only synchronous jobs. The only element you have to implement is a *Reducer*.

In general **Actor** does all the heavy lifting (calling repositories, apis) everything that needs outer world communication or asynchronous tasks. All other elements are **synchronous**.
