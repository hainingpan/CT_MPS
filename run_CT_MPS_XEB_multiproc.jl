using Distributed, ArgParse, CT, Pickle

@everywhere using CT, ArgParse, Pickle
@everywhere include("run_CT_MPS_XEB.jl")

function parse_my_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--params"; arg_type=String
        "--filename"; arg_type=String; default="/p/home/hpan/CT_MPS/all_circuits_L20.pkl"
    end
    return parse_args(s)
end

function main()
    args = parse_my_args()
    raw = args["params"]
    filename = args["filename"]
    
    parts  = split(raw, ",")
    tuples = collect(Iterators.partition(parts,4)) .|> T ->
        (parse(Int,     T[1]),  # L
         parse(Float64, T[2]),  # p_ctrl
         parse(Int,     T[3]),  # seed_C
         parse(Int,     T[4]))  # seed_m

    # Load data once on main process
    println("Loading data from ", filename)
    flush(stdout)
    data = Pickle.load(open(filename, "r"))
    println("Data loaded from ", filename)
    flush(stdout)

    # dispatch everything in parallel
    pmap(tuples) do tup
        L, p_ctrl, seed_C, seed_m = tup
        data_ = get(data, (L, p_ctrl, seed_C, seed_m), nothing)
        if data_ === nothing
            println("No data found for key (L=$L, p_ctrl=$p_ctrl, seed_C=$seed_C, seed_m=$seed_m)")
        else
            main_interactive(L, p_ctrl, seed_C, seed_m, data_)
        end
    end
end

main()