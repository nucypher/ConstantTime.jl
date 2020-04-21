module ConstantTime


# Constant-sized built-in types
const SUPPORTED_TYPES = Union{Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128}


"""
    Value{T}(value::T)
    Value(value::T)

A wrapper for a type `T` that protects it from being used in non-constant-time operations.

This module defines some methods that are (most probably) constant-time.
Namely, for built-in integer types (`Int8...128` and `UInt8...128`), the following methods
are defined: `zero`, `one`, `~`, `+`, `-`, `xor`, `&`, `|`,
`%` (with the second argument being a built-in integer type), `signed`, `unsigned`,
`iseven`, `isodd`, `iszero`, `==`.
Also, `>>` and `<<` are defined for the shift also being a built-in integer.

The functions that would otherwise return `Bool`
will return [`Choice`](@ref) for [`Value`](@ref) objects.

Binary operations on one `Value` and one unwrapped value produce a `Value`.
"""
struct Value{T}
    value :: T

    @inline Value{T}(value::T) where T = new{T}(value)
    @inline Value(value::T) where T = new{T}(value)
end


"""
An object representing a result of a constant-time comparison,
used in [`select`](@ref) and [`swap`](@ref).

Supports `!`.

!!! warning

    Comparison of immutable objects with [`Value`](@ref) fields bypasses the custom `==`,
    and the result is an unwrapped boolean.
"""
struct Choice
    value :: Value{UInt8}
end


"""
    wrap(x)
    wrap(x::Value)

If `x` is a [`Value`](@ref), returns `x`, otherwise wraps `x` in a [`Value`](@ref).
"""
@inline wrap(x::T) where T = Value{T}(x)

@inline wrap(x::Value) = x


"""
    unwrap(x)
    unwrap(x::Value)

If `x` is a [`Value`](@ref), returns the wrapped value.
Otherwise, returns `x`.
"""
@inline unwrap(x) = x

@inline unwrap(x::Value) = x.value


"""
    unwrap(x::Choice)

Returns the wrapped boolean value.

!!! note

    Not constant-time.
"""
@inline unwrap_choice(x::Choice) = !iszero(unwrap(x.value))


# Assuming that all these are constant time


@inline Base.zero(x::Type{Value{T}}) where T = Value{T}(zero(T))
@inline Base.zero(x::Value{T}) where T = zero(Value{T})


@inline Base.one(x::Type{Value{T}}) where T = Value{T}(one(T))
@inline Base.one(x::Value{T}) where T = one(Value{T})


@inline function Base.:~(x::Value{T}) where T <: SUPPORTED_TYPES
    Value{T}(~x.value)
end


@inline Base.xor(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(xor(x.value, y.value))
@inline Base.xor(x::Value{T}, y::T) where T <: SUPPORTED_TYPES =
    Value{T}(xor(x.value, y))
@inline Base.xor(x::T, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(xor(x, y.value))


@inline Base.:|(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x.value | y.value)
@inline Base.:|(x::Value{T}, y::T) where T <: SUPPORTED_TYPES =
    Value{T}(x.value | y)
@inline Base.:|(x::T, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x | y.value)


@inline Base.:&(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x.value & y.value)
@inline Base.:&(x::Value{T}, y::T) where T <: SUPPORTED_TYPES =
    Value{T}(x.value & y)
@inline Base.:&(x::T, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x & y.value)


@inline Base.:+(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x.value + y.value)
@inline Base.:+(x::Value{T}, y::T) where T <: SUPPORTED_TYPES =
    Value{T}(x.value + y)
@inline Base.:+(x::T, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x + y.value)


@inline Base.:-(x::Value{T}) where T <: SUPPORTED_TYPES = Value{T}(-x.value)
@inline Base.:-(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x.value - y.value)
@inline Base.:-(x::Value{T}, y::T) where T <: SUPPORTED_TYPES =
    Value{T}(x.value - y)
@inline Base.:-(x::T, y::Value{T}) where T <: SUPPORTED_TYPES =
    Value{T}(x - y.value)


@inline Base.:>>(x::Value{T}, shift::Value{V}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{T}(x.value >> shift.value)
@inline Base.:>>(x::Value{T}, shift::SUPPORTED_TYPES) where T <: SUPPORTED_TYPES =
    Value{T}(x.value >> shift)
@inline Base.:>>(x::T, shift::Value{V}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{T}(x >> shift.value)


@inline Base.:<<(x::Value{T}, shift::Value{V}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{T}(x.value << shift.value)
@inline Base.:<<(x::Value{T}, shift::SUPPORTED_TYPES) where T <: SUPPORTED_TYPES =
    Value{T}(x.value << shift)
@inline Base.:<<(x::T, shift::Value{V}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{T}(x << shift.value)


@inline Base.:%(x::Value{T}, ::Type{Value{V}}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{V}(x.value % V)
@inline Base.:%(x::Value{T}, ::Type{V}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{V}(x.value % V)
@inline Base.:%(x::T, ::Type{Value{V}}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES} =
    Value{V}(x % V)


@inline Base.signed(x::Value{T}) where T <: SUPPORTED_TYPES = Value(signed(x.value))


@inline Base.unsigned(x::Value{T}) where T <: SUPPORTED_TYPES = Value(unsigned(x.value))


# Non-trivial functions


@inline Base.:!(x::Choice) = Choice(one(x.value) & ~x.value)


@inline Base.iseven(x::Value{T}) where T <: SUPPORTED_TYPES = iszero(x & one(Value{T}))


@inline Base.isodd(x::Value{T}) where T <: SUPPORTED_TYPES = !iseven(x)


@inline function Base.iszero(x::Value{T}) where T <: SUPPORTED_TYPES
    # If x == 0, then x and -x are both equal to zero;
    # otherwise, one or both will have its high bit set.
    ux = unsigned(x)
    u = (ux | (-ux)) >> ((sizeof(T) << 3) - 1)

    # Result is the opposite of the high bit (now shifted to low).
    Choice(xor(u, one(u)) % UInt8)
end


@inline function Base.:(==)(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    # t == 0 if and only if self == other
    iszero(xor(x, y))
end


"""
    select(choice::Bool, x, y)
    select(choice::Choice, x::Value{T}, y::Value{T})

An analogue of a ternary operator or `ifelse`
(which, at the moment, cannot have methods added to them).

If `choice` is `true`, returns `x`, else `y`.
For `choice` being a [`Choice`](@ref) object,
and `x` and `y` being [`Value`](@ref) objects, the operation is constant-time.
"""
@inline select(choice::Bool, x, y) = choice ? x : y


@inline function select(choice::Choice, x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    # if choice = 0, mask = (-0) = 0000...0000
    # if choice = 1, mask = (-1) = 1111...1111
    mask = -(choice.value % T)
    xor(y, (mask & xor(x, y)))
end


"""
    swap(choice::Bool, x, y)
    swap(choice::Choice, x::Value{T}, y::Value{T})

If `choice` is `true`, returns `(y, x)`, else `(x, y)`.
For `choice` being a [`Choice`](@ref) object,
and `x` and `y` being [`Value`](@ref) objects, the operation is constant-time.
"""
@inline swap(choice::Bool, x, y) = choice ? (y, x) : (x, y)


@inline function swap(choice::Choice, x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    # if choice = 0, mask = (-0) = 0000...0000
    # if choice = 1, mask = (-1) = 1111...1111
    mask = -(choice.value % T)
    t = mask & xor(x, y)
    (xor(x, t), xor(y, t))
end


"""
    getindex(array::Array{Value, 1}, x::Value)

Constant-time array access.

!!! note

    Assumes that index `x` is present in the array.
    If it is not, the first element will be returned.
"""
function Base.getindex(array::Array{V, 1}, x::Value{T}) where {T <: SUPPORTED_TYPES, V <: Value}
    res = array[1]
    for i in T(2):T(length(array))
        res = select(wrap(i) == x, array[i], res)
    end
    res
end


struct Option{T}
    value :: Value{T}
    is_some :: Choice
end


@inline function unwrap(option::Option{T}) where T
    @assert unwrap(option.is_some)
    unwrap(option.value)
end


@inline is_some(option::Option{T}) where T = option.is_some


@inline is_none(option::Option{T}) where T = !is_some(option)


# This returns the underlying value if `is_some`, or the provided value otherwise.
@inline function unwrap_or(option::Option{T}, default::Value{T}) where T
    select(option.is_some, option.value, default)
end


end
