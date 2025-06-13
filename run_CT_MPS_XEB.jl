# using ITensors
# using Random
# using LinearAlgebra
using Pkg
Pkg.activate("CT")
using CT
using MKL
using JSON
using Printf

using ArgParse
using Serialization
using Pickle


# data = Pickle.load(open("data.pkl", "r"))


function run(L::Int , seed_m::Int, data)
    ct=CT.CT_MPS(L=L,seed=0,seed_C=0,seed_m=seed_m,folded=true,store_op=false,store_vec=false,ancilla=0,_maxdim0=60,xj=Set([0]),debug=false,simplified_U=true, x0=0//1,)
    CT.random_control_fixed_circuit!(ct, ct.L, data)
    return ct
end


function main_interactive(L::Int,p_ctrl::Float64, seed_C::Int,seed_m::Int, data)
    start_time = time()
    filename = "MPS_(0,1)_L$(L)_pctrl$(@sprintf("%.3f", p_ctrl))_sC$(seed_C)_sm$(seed_m)_XEB.jls"
    ct = run(L,seed_m,data)
    # /p/work/hpan/CT_MPS/
    save_dir = "MPS_0-1_XEB_L$(L)/"
    serialize(filename, ct)

    elapsed_time = time() - start_time
    println(" L: ", L, "p_ctrl: ", p_ctrl,  " seed_C: ", seed_C, " seed_m: ", seed_m) 
end
# L,p,seed,seed_m = key