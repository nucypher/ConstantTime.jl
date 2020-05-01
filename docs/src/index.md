# Constant-time primitives

This package contains a number of primitives for writing constant-time algorithms.

**Warning:** at the moment it is not completely certain whether Julia provides constant-time guarantees for the operators the library is based on. It is also not clear if it is a good idea in general to write crypto in Julia. Use this library to prototype branchless algorithms and to control operations on secret data by wrapping it in `ConstantTime.Value` type.

```@meta
CurrentModule = ConstantTime
```


# Types

```@docs
Value
Choice
Selectable
wrap
unwrap
```

# Functions

```@docs
select
swap
getindex
```
