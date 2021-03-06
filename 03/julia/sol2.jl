#!/usr/bin/env julia
using DelimitedFiles

lines = readdlm(stdin, String)
chars = reduce(hcat, split.(lines, ""))
forest = transpose(chars .== "#")

function mask_with_sled(slope)
    indices = 1 : size(forest)[1] ÷ slope[1] - 1
    indices = (i -> 1 .+ (i .* slope) .% size(forest)).(indices)
    indices = CartesianIndex.(indices)
    return sum(forest[indices])
end

masks = mask_with_sled.([(1,1), (1,3), (1,5), (1,7), (2,1)])
println(prod(masks))
