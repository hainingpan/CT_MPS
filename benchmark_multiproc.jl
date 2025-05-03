using Distributed

# 1) bring your main_interactive definition onto every process
@everywhere include("run_CT_MPS_evo.jl")

# 2) load and parse the parameter file
if length(ARGS) < 1
    error("Usage: julia run_CT_parallel.jl <params.csv>")
end
param_file = ARGS[1]
lines = filter(l -> !isempty(strip(l)), readlines(param_file))

params = map(lines) do line
    parts = split(chomp(line), ',')
    L     = parse(Int,     parts[1])
    PCTRL = parse(Float64, parts[2])
    PPROJ = parse(Float64, parts[3])
    SC    = parse(Int,     parts[4])
    SM    = parse(Int,     parts[5])
    DM    = parse(Int,     parts[6])
    EPS   = parse(Float64, parts[7])
    (L, PCTRL, PPROJ, SC, SM, DM, EPS)
end

# 3) dispatch across workers
timings = pmap(params) do tup
    L,PCTRL,PPROJ,SC,SM,DM,e = tup
    println("→ ε = ", e, " on $(myid())")
    t = @elapsed main_interactive(L,PCTRL,PPROJ,SC,SM,DM,e)
    println("   done in ", round(t, digits=3), " s")
    t
end

println("All runs complete; timings = ", timings)
