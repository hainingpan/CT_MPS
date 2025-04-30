# Does not work well with multithreading because of the GC competition-- any thread can invoke GC to stop all threads, use multiprocessing instead, example: run_CT_MPS_C_m_T_multiproc.jl
using Base.Threads
include("run_CT_MPS_C_m_T.jl")

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
    chunks = collect(Iterators.partition(args, 5))
    prev = GC.enable(false)
    # t_pre = gc_time_ns()
    p_ctrl_str, p_proj_str, L_str, seed_C_str, seed_m_str = popfirst!(chunks)
    main_interactive(parse(Int,L_str),parse(Float64,p_ctrl_str),parse(Float64,p_proj_str),parse(Int,seed_C_str),parse(Int,seed_m_str)) # precompile call
    # t_before = gc_time_ns()
    # println("Total GC time one time: ", (t_before - t_pre)/1e9, " s")

    @threads for (p_ctrl,p_proj,L,seed_C,seed_m) in chunks
        main_interactive(parse(Int,L),parse(Float64,p_ctrl),parse(Float64,p_proj),parse(Int,seed_C),parse(Int,seed_m))
    end
    # t_after = gc_time_ns()
    # println("Total GC time: ", (t_after - t_before)/1e9, " s")
    GC.enable(prev) 

end

if isdefined(Main, :PROGRAM_FILE) && abspath(PROGRAM_FILE) == @__FILE__
    main()
end


# julia run_CT_MPS_C_m_T_series.jl --p_ctrl 0.5 --p_proj 0.0 --L 8 --seed_C 0 --seed_m_min 0 --seed_m_max 1
# julia run_CT_MPS_C_m_T_series.jl --params "0.5,0.0,8,0,0,0.5,0.0,8,0,1"