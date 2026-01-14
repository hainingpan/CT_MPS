using Distributed, ArgParse, CT

@everywhere using CT, ArgParse
@everywhere include("run_CT_MPS_coherence_T.jl")

function parse_my_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--params"; arg_type=String
    end
    return parse_args(s)
end

function main()
    raw    = parse_my_args()["params"]
    parts  = split(raw, ",")
    tuples = collect(Iterators.partition(parts,6)) .|> T ->
        (parse(Int,     T[1]),
         parse(Float64, T[2]),
         parse(Float64, T[3]),
         parse(Int,     T[4]),
         parse(Int,     T[5]),
         parse(Int,     T[6])
         )

    # dispatch everything in parallel, no explicit warm‐up
    pmap(t -> main_interactive(t...), tuples)
end

main()
