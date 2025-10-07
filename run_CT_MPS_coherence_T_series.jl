include("run_CT_MPS_coherence_T.jl")

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
    for (L, p_ctrl,p_proj,maxbonddim,t,seed) in Iterators.partition(args, 6)
        main_interactive(parse(Int,L),parse(Float64,p_ctrl),parse(Float64,p_proj),parse(Int,maxbonddim),parse(Int,t),parse(Int,seed))
    end
end

if isdefined(Main, :PROGRAM_FILE) && abspath(PROGRAM_FILE) == @__FILE__
    main()
end


# julia run_CT_MPS_coherence_T_series.jl --params "10,0.5,0.0,120,1,0"