#!/bin/bash
#PBS -A ONRDC54450755
#PBS -l walltime=0:10:00
#PBS -q debug
#PBS -l select=1:ncpus=192:mpiprocs=1
#PBS -N L12
#PBS -m abe
#PBS -M hnpanboa@gmail.com
#PBS -r y
#PBS -J 1-2
# cd $WORKDIR/CT_MPS
cd $HOME/CT_MPS

# how many processes?
NP=192

# no threading now—each proc manages its own GC
export JULIA_NUM_THREADS=2
export OPENBLAS_NUM_THREADS=$JULIA_NUM_THREADS

PARAMS_FILE="params_CT_MPS_0_C_m_T_L12_series.txt"
params=$(sed -n "${PBS_ARRAY_INDEX}p" "$PARAMS_FILE")
echo -n "$params" | wc -c

export JULIA_DEPOT_PATH=~/julia_depot
export APPTAINER_BIND="/p/work/hpan"


singularity exec $HOME/julia_itensors_improved.sif \
  julia \
    --sysimage ct_with_wrapper.so \
    --project=./CT \
    -p $((NP / JULIA_NUM_THREADS)) \
    run_CT_MPS_C_m_T_multiproc.jl \
    --params "$params"
