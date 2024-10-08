using ITensors
using Random
using LinearAlgebra
using MKL
using Pkg
using JSON
Pkg.activate("CT")
using CT
using Printf

using ArgParse
using Serialization
""" compute domain wall as a function of t"""

function run_dw_t(L::Int,p_ctrl::Float64,p_proj::Float64,seed::Int)
    ct=CT.CT_MPS(L=L,seed=seed,folded=true,store_op=false,store_vec=false,ancilla=0,xj=Set([0]),x0=1//2^L)
    # x0=1//2^(L÷2+1)
    i=L
    tf=(ct.ancilla ==0) ? 2*ct.L^2 : div(ct.L^2,2)
    coh_mat=zeros(tf+1,L+1,L+1)
    fdw=zeros(tf+1,L+1)
    coh_mat[1,:,:], fdw[1,:] = CT.get_coherence_matrix(ct,i)
    for idx in 1:tf
        println(idx,':',i)
        i=CT.random_control!(ct,i,p_ctrl,p_proj)
        coh_mat[idx+1,:,:], fdw[idx+1,:] = CT.get_coherence_matrix(ct,i)
    end
    return Dict("coh_mat"=>coh_mat,"fdw"=>fdw)
end


function parse_my_args()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "--p_ctrl"
        arg_type = Float64
        default = 0.5
        help = "control rate"
        "--p_proj"
        arg_type = Float64
        default = 0.0
        help = "projection rate"
        "--L", "-L"
        arg_type = Int
        default = 8
        help = "system size"
        "--seed", "-s"
        arg_type = Int
        default = 0
        help = "random seed"
    end
    return parse_args(s)
end

function main()
    println("Uses threads: ",BLAS.get_num_threads())
    println("Uses backends: ",BLAS.get_config())
    args = parse_my_args()
    results = run_dw_t(args["L"], args["p_ctrl"], args["p_proj"], args["seed"])

    filename = "MPS_(0,1)_L$(args["L"])_pctrl$(@sprintf("%.3f", args["p_ctrl"]))_pproj$(@sprintf("%.3f", args["p_proj"]))_s$(args["seed"])_coherence.json"
    data_to_serialize = merge(results, Dict("args" => args))
    json_data = JSON.json(data_to_serialize)
    open(filename, "w") do f
        write(f, json_data)
    end
end

if isdefined(Main, :PROGRAM_FILE) && abspath(PROGRAM_FILE) == @__FILE__
    main()
end




# julia --sysimage ~/.julia/sysimages/sys_itensors.so run_CT_MPS_coherence.jl --p_ctrl 0.5 --p_proj 0.0 --L 8 --seed 0 