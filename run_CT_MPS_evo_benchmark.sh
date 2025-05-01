#!/usr/bin/env bash
export JULIAUP_NO_UPDATE_CHECK=1

echo "Hello OSPool from Job running $(whoami)@$(hostname)"
grep Mips .machine.ad
grep RemoteHost .job.ad

# drop your CT tree back into place
mkdir -p CT/src
mv Project.toml   CT
mv Manifest.toml  CT
mv CT.jl          CT/src

echo $JULIA_DEPOT_PATH
# parse the seven fields from the single string argument
IFS=',' read -r L PCTRL PPROJ SC SM DM EPS <<< "$1"
echo "Parameters: L=$L, PCTRL=$PCTRL, PPROJ=$PPROJ, SC=$SC, SM=$SM, DM=$DM, EPS=$EPS"

# exactly your include+main_interactive call
julia -q --banner=no --startup-file=no \
  --sysimage "run_CT_MPS_evo_generic.so" \
  --project="CT" \
  -e "include(\"run_CT_MPS_evo.jl\"); main_interactive($L,$PCTRL,$PPROJ,$SC,$SM,$DM,$EPS)"
