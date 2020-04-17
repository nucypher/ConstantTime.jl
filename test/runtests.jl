using Jute
using ConstantTime

const CT = ConstantTime


@testgroup "Values" begin


@testcase "iszero(value)" for tp in (UInt64, Int64)
    for val in [typemin(tp), typemax(tp), zero(tp), one(tp), tp(123), -tp(123)]
        wrapped_val = CT.wrap(val)
        z = iszero(wrapped_val)
        @test CT.unwrap(z) == iszero(val)
    end
end


end


exit(runtests())
