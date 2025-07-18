using CT, ArgParse, Pickle
include("run_CT_MPS_XEB.jl")
# do one dummy call so all methods get JIT’ed
filename = "all_circuits_L10_40.pkl"
println("Loading data from ", filename)
data = Pickle.load(open(filename, "r"))
println("Data loaded from ", filename)
L, p_ctrl, seed_C, seed_m = 10, 0.5, 1, 1
data_ = data[L, p_ctrl, seed_C, seed_m]
main_interactive(L, p_ctrl, seed_C, seed_m, data_)

# To run the precompilation, use the following command:
# export JULIA_DEPOT_PATH=~/julia_depot
# export TMPDIR="/tmp" # (optional)
# using PackageCompiler; using Pkg; Pkg.activate("CT")
# create_sysimage(
#     [:CT, :ITensors, :ArgParse,  :MKL,  :JSON,],
#     sysimage_path="ct_xeb.so",
#     precompile_execution_file="precompile_postprocess_XEB.jl"
#   )