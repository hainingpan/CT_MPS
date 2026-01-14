using Distributed, ArgParse, CT

@everywhere using CT, ArgParse
@everywhere include("run_CT_MPS_C_m_T.jl")

function parse_my_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--params"; arg_type=String; default=nothing
    end
    return parse_args(s)
end

function main()
    # Try command-line args first, then fall back to environment variable
    raw = parse_my_args()["params"]
    # Fall back to reading from file based on env vars
    if raw === nothing
        params_file = get(ENV, "PARAMS_FILE", nothing)
        line_number = get(ENV, "PARAMS_LINE_NUMBER", nothing)
        
        if params_file !== nothing && line_number !== nothing
            # Read the specific line from the file
            raw = readlines(params_file)[parse(Int, line_number)]
        end
    end
    
    parts  = split(raw, ",")
    tuples = collect(Iterators.partition(parts,5)) .|> T ->
        (parse(Int,     T[3]),
         parse(Float64, T[1]),
         parse(Float64, T[2]),
         parse(Int,     T[4]),
         parse(Int,     T[5]))

    # dispatch everything in parallel, no explicit warm‐up
    pmap(t -> main_interactive(t...), tuples)
end

main()