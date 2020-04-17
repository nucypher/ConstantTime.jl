module ConstantTime


# Constant-sized built-in types
const SUPPORTED_TYPES = Union{Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128}


struct Value{T}
    value :: T

    @inline Value{T}(value::T) where T = new{T}(value)
    @inline Value(value::T) where T = new{T}(value)
end


struct Choice
    value :: Value{UInt8}
end


@inline wrap(x::T) where T = Value{T}(x)


@inline unwrap(x::Value) = x.value


@inline unwrap(x::Choice) = !iszero(unwrap(x.value))


# Assuming that all these are constant time


@inline Base.zero(x::Type{Value{T}}) where T = Value{T}(zero(T))
@inline Base.zero(x::Value{T}) where T = zero(Value{T})


@inline Base.one(x::Type{Value{T}}) where T = Value{T}(one(T))
@inline Base.one(x::Value{T}) where T = one(Value{T})


@inline function Base.:~(x::Value{T}) where T <: SUPPORTED_TYPES
    Value{T}(~x.value)
end


@inline function Base.xor(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    Value{T}(xor(x.value, y.value))
end


@inline function Base.:|(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    Value{T}(x.value | y.value)
end


@inline function Base.:&(x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    Value{T}(x.value & y.value)
end


@inline function Base.:-(x::Value{T}) where T <: SUPPORTED_TYPES
    Value{T}(-x.value)
end


@inline function Base.:>>(x::Value{T}, shift::SUPPORTED_TYPES) where T <: SUPPORTED_TYPES
    Value{T}(x.value >> shift)
end


@inline function Base.:%(x::Value{T}, ::Type{V}) where {T <: SUPPORTED_TYPES, V <: SUPPORTED_TYPES}
    Value{V}(x.value % V)
end


@inline Base.signed(x::Value{T}) where T <: SUPPORTED_TYPES = Value(signed(x.value))


@inline Base.unsigned(x::Value{T}) where T <: SUPPORTED_TYPES = Value(unsigned(x.value))


# Non-trivial functions


@inline Base.:!(x::Choice) = Choice(one(x.value) & ~x.value)


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


@inline function select(choice::Choice, x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    # if choice = 0, mask = (-0) = 0000...0000
    # if choice = 1, mask = (-1) = 1111...1111
    mask = -(choice.value % T)
    xor(y, (mask & xor(x, y)))
end


@inline function swap(choice::Choice, x::Value{T}, y::Value{T}) where T <: SUPPORTED_TYPES
    # if choice = 0, mask = (-0) = 0000...0000
    # if choice = 1, mask = (-1) = 1111...1111
    mask = -(choice.value % T)
    t = mask & xor(x, y)
    (xor(x, t), xor(y, t))
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
