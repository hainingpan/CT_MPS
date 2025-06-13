include("run_CT_MPS_XEB.jl")

function parse_my_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--params"
        arg_type = String
        help = "Comma-separated list of values"
    end
    return parse_args(s)
end

function main()
    args = parse_my_args()
    args = split(args["params"],",")
    filename = "../IBM/MICPT_Data-selected/all_circuits.pkl"
    data = Pickle.load(open(filename, "r"))
    for (L,p_ctrl,seed_C,seed_m) in Iterators.partition(args, 4)
        # println("p_ctrl: ", p_ctrl, " L: ", L, " seed_C: ", seed_C, " seed_m: ", seed_m)
        data_ = get(data, (parse(Int,L), parse(Float64,p_ctrl), parse(Int,seed_C), parse(Int,seed_m)), nothing)
        if data_ === nothing
            println("No data found for key (L=$L, p_ctrl=$p_ctrl, seed_C=$seed_C, seed_m=$seed_m)")
        else
            main_interactive(parse(Int,L),parse(Float64,p_ctrl),parse(Int,seed_C),parse(Int,seed_m),data_)
        end
    end
end

if isdefined(Main, :PROGRAM_FILE) && abspath(PROGRAM_FILE) == @__FILE__
    main()
end
# julia run_CT_MPS_XEB_series.jl --params "10,0.5,1,1,10,0.5,1,2"