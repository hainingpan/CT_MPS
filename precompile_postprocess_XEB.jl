# precompile_postprocess_XEB.jl
using CT, ArgParse
include("postprocess_XEB.jl")
main_interactive(0.2, 10, 5, sample_size=1, seed=0)

# Dummy calls to compile the functions

# To run the precompilation, use the following command:
# export JULIA_DEPOT_PATH=~/julia_depot
# export TMPDIR="/tmp" # (optional)
# using PackageCompiler; using Pkg; Pkg.activate("CT")
# create_sysimage(
#     [:CT, :ITensors, :ArgParse,  :MKL,  :JSON,],
#     sysimage_path="ct_xeb_postprocess.so",
#     precompile_execution_file="precompile_postprocess_XEB.jl"
#   )

# julia --sysimage ct_xeb_postprocess.so \
#       --project=./CT \
#       -p 2 \
#       postprocess_XEB_multiproc.jl \
#       --params "0.2,10,5,1,0,500,0.2,10,6,1,0,500"