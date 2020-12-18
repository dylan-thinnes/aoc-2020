#!/usr/bin/env julia
using DelimitedFiles

inp = read(stdin, String)
spec_lines, ticket_line, nearby_lines = split(inp, "\n\n");
ticket_line = ticket_line[14:end]
nearby_lines = nearby_lines[17:end]

specs = eachmatch(r"([^:]+): (\d+)-(\d+) or (\d+)-(\d+)", spec_lines)
specs_s  = [match[1] for match = specs]
specs_l1 = [parse(Int, match[2]) for match = specs]
specs_u1 = [parse(Int, match[3]) for match = specs]
specs_l2 = [parse(Int, match[4]) for match = specs]
specs_u2 = [parse(Int, match[5]) for match = specs]

ticket = readdlm(IOBuffer(ticket_line), ',', Int)
nearby = readdlm(IOBuffer(nearby_lines), ',', Int, '\n')

function resize_comparison(comparison)
    result = reshape(reduce(vcat, comparison'), (reverse(size(comparison))..., size(specs_s)...))
    return result
end

function compare_spec(f, specs)
    comparison = (i -> f.(i, specs)).(nearby)
    return comparison
end

in_l1 = resize_comparison(compare_spec(>=, specs_l1))
in_u1 = resize_comparison(compare_spec(<=, specs_u1))
in_l2 = resize_comparison(compare_spec(>=, specs_l2))
in_u2 = resize_comparison(compare_spec(<=, specs_u2))

within_bounds = in_l1 .& in_u1 .| in_l2 .& in_u2

any_within_bounds = reduce(|, within_bounds, dims=[3])
any_within_bounds = dropdims(any_within_bounds, dims=3)
println(sum(nearby' .* .~ any_within_bounds))
