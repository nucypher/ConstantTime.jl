using Jute
using ConstantTime

const CT = ConstantTime


@testgroup "Value" begin


@testcase "wrap()" begin
    @test typeof(CT.wrap(1)) == CT.Value{Int}
    @test typeof(CT.wrap(CT.wrap(1))) == CT.Value{Int}
end


@testcase "unwrap()" begin
    @test CT.unwrap(CT.wrap(1)) == 1
    @test CT.unwrap(1) == 1
end


@testcase "zero()" begin
    @test CT.unwrap(zero(CT.Value{Int})) == 0
    @test CT.unwrap(zero(CT.wrap(1))) == 0
end


@testcase "one()" begin
    @test CT.unwrap(one(CT.Value{Int})) == 1
    @test CT.unwrap(one(CT.wrap(2))) == 1
end


@testcase "unary functions" for func in [~, -], tp in (UInt64, Int64)
    for val in [typemin(tp), typemax(tp), zero(tp), one(tp), tp(123), -tp(123)]
        wrapped_val = CT.wrap(val)
        @test CT.unwrap(func(wrapped_val)) == func(val)
    end
end


@testcase "binary functions" for func in [xor, |, &, +, -], tp in (UInt64, Int64)
    v1 = rand(tp)
    v2 = rand(tp)
    wrapped_v1 = CT.wrap(v1)
    wrapped_v2 = CT.wrap(v2)
    @test CT.unwrap(func(wrapped_v1, wrapped_v2)) == func(v1, v2)
    @test CT.unwrap(func(wrapped_v1, v2)) == func(v1, v2)
    @test CT.unwrap(func(v1, wrapped_v2)) == func(v1, v2)
end


@testcase "shifts" for func in [<<, >>], tp in (UInt64, Int64)
    v1 = rand(tp)
    v2 = rand(Int32(1):Int32(30))
    wrapped_v1 = CT.wrap(v1)
    wrapped_v2 = CT.wrap(v2)
    @test CT.unwrap(func(wrapped_v1, wrapped_v2)) == func(v1, v2)
    @test CT.unwrap(func(wrapped_v1, v2)) == func(v1, v2)
    @test CT.unwrap(func(v1, wrapped_v2)) == func(v1, v2)
end


@testcase "truncation" for source_tp in (UInt64, Int64), res_tp in (UInt16, Int16)
    v = rand(source_tp)
    wrapped_v = CT.wrap(v)
    @test CT.unwrap(wrapped_v % CT.Value{res_tp}) == v % res_tp
    @test CT.unwrap(v % CT.Value{res_tp}) == v % res_tp
    @test CT.unwrap(wrapped_v % res_tp) == v % res_tp
end


@testcase "signed()" begin
    v = rand(UInt64)
    wrapped_v = CT.wrap(v)
    res = signed(wrapped_v)
    @test typeof(res) == CT.Value{Int64}
    @test CT.unwrap(res) == signed(v)
end


@testcase "unsigned()" begin
    v = rand(Int64)
    wrapped_v = CT.wrap(v)
    res = unsigned(wrapped_v)
    @test typeof(res) == CT.Value{UInt64}
    @test CT.unwrap(res) == unsigned(v)
end


end


@testgroup "Choice" begin


@testcase "unwrap_choice()" begin
    @test CT.unwrap_choice(CT.wrap(1) == CT.wrap(1))
    @test !CT.unwrap_choice(CT.wrap(1) == CT.wrap(2))
end


@testcase "!choice" begin
    @test CT.unwrap_choice(!(CT.wrap(1) == CT.wrap(2)))
end


@testcase "iseven()" begin
    @test CT.unwrap_choice(iseven(CT.wrap(1232)))
end


@testcase "isodd()" begin
    @test CT.unwrap_choice(isodd(CT.wrap(123)))
end


@testcase "iszero()" for tp in (UInt64, Int64)
    for val in [typemin(tp), typemax(tp), zero(tp), one(tp), tp(123), -tp(123)]
        wrapped_val = CT.wrap(val)
        z = iszero(wrapped_val)
        @test CT.unwrap_choice(z) == iszero(val)
    end
end


@testcase "select()" begin

    @test CT.select(true, 1, 2) == 1
    @test CT.select(false, 1, 2) == 2

    v1 = CT.wrap(1)
    v2 = CT.wrap(2)
    c = (CT.wrap(123) == CT.wrap(123))
    @test CT.unwrap(CT.select(c, v1, v2)) == CT.unwrap(v1)
    @test CT.unwrap(CT.select(!c, v1, v2)) == CT.unwrap(v2)
end


@testcase "swap()" begin

    @test CT.swap(true, 1, 2) == (2, 1)
    @test CT.swap(false, 1, 2) == (1, 2)

    v1 = CT.wrap(1)
    v2 = CT.wrap(2)
    c = (CT.wrap(123) == CT.wrap(123))
    @test CT.unwrap.(CT.swap(c, v1, v2)) == CT.unwrap.((v2, v1))
    @test CT.unwrap.(CT.swap(!c, v1, v2)) == CT.unwrap.((v1, v2))
end


@testcase "getindex()" begin
    arr = CT.wrap.([1, 2, 3, 4, 5])
    @test CT.unwrap(arr[CT.wrap(2)]) == 2
    @test CT.unwrap(arr[CT.wrap(4)]) == 4
end


end


exit(runtests())
