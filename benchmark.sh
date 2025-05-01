#!/usr/bin/env bash
export JULIAUP_NO_UPDATE_CHECK=1     # no “new version available” ping
SYSIMG=run_CT_MPS_evo_generic.so; PROJ="CT"
L=10; PCTRL=0.3; PPROJ=0.0; SC=0; SM=0; DM=512
EPS=(1e-8 1e-9 1e-10 1e-15)

for e in "${EPS[@]}"; do
  echo "L=$L PCTRL=$PCTRL PPROJ=$PPROJ SC=$SC SM=$SM DM=$DM EPS=$e"
  /usr/bin/time -f "Time:%e s  RSS:%M KB" \
    julia -q --banner=no --startup-file=no \
      --sysimage "$SYSIMG" --project="$PROJ" \
      -e "include(\"run_CT_MPS_evo.jl\"); main_interactive($L,$PCTRL,$PPROJ,$SC,$SM,$DM,$e)"
done
