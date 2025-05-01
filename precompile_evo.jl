# precompile.jl
using CT, ArgParse
include("run_CT_MPS_evo.jl")
# do one dummy call so all methods get JIT’ed
main_interactive(10,0.5,0.,0,0,1024,1e-10)

# using PackageCompiler; using Pkg; Pkg.activate("CT")
# create_sysimage(
#     [:CT, :ITensors, :ArgParse, :JSON, :MKL],
#     sysimage_path="run_CT_MPS_evo.so",
#     precompile_execution_file="precompile_evo.jl"
#   )
