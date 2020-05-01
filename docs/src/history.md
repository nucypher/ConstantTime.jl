# Version history


## Current development version

* CHANGED: `getindex()` changed to `get()`, since we need a default value to be provided.
* ADDED: `Selectable` abstract type to restrict the usage of constant-time `get()`.


## v0.1.0

* ADDED: more method variations to lift unwrapped values
* CHANGED: `unwrap()` for `Choice` renamed to `unwrap_choice()`, to not confuse it with the constant time `unwrap()` for `Value`.


## v0.0.1

Initial version.
