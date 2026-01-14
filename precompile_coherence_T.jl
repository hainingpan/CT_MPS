# precompile.jl
using CT, ArgParse
include("run_CT_MPS_coherence_T.jl")
# do one dummy call so all methods get JIT’ed
main_interactive(10,0.5,0.0,120,1,0)

# To run the precompilation, use the following command:
# export JULIA_DEPOT_PATH=~/julia_depot
# export TMPDIR="/tmp" # (optional)
# using PackageCompiler; using Pkg; Pkg.activate("CT")
# create_sysimage(
#     [:CT, :ITensors, :ArgParse, :JSON],
#     sysimage_path="coherence_T.so",
#     precompile_execution_file="precompile_coherence_T.jl"
#   )


# Then to start from the sysimage, use: 
# julia --sysimage coherence_T.so --project=.
# > using Pkg
# > Pkg.activate("CT")
# > main_interactive(8, 0.1, 0.2, 1, 1)
#
# Or call the script directly:
# julia --sysimage coherence_T.so \
#       --project=CT \
#       -p 2 \
#       run_CT_MPS_coherence_T_multiproc.jl \
#       --params "10,0.5,0.0,120,1,0,10,0.5,0.0,120,1,1"