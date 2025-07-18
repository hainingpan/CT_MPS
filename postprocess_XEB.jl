using Pkg
Pkg.activate("CT")
using CT
using ZipFile
using Serialization
using ProgressMeter
using Printf
using ITensors
using JSON
using ArgParse
using Random

function parse_commandline()
    s = ArgParseSettings()
    
    @add_arg_table s begin
        "p_value"
            help = "Control probability value"
            arg_type = Float64
            required = true
        "L_value"
            help = "System size L"
            arg_type = Int
            required = true
        "--sample-size"
            help = "Monte Carlo sample size"
            arg_type = Int
            default = 10000
        "--seed"
            help = "Random seed"
            arg_type = Int
            default = 0
        "--sm-max"
            help = "Maximum sm value"
            arg_type = Int
            default = 500
    end
    
    return parse_args(s)
end

function calc_(L,pctrl,sC,z,file_index;sm_max=500)
    data_abs2_list = MPS[];
    for sm in 0:sm_max
        filename = @sprintf("MPS_(0,1)_L%d_pctrl%.3f_sC%d_sm%d_XEB.jls", L, pctrl, sC, sm)
        if haskey(file_index, filename)
            data = deserialize(z.files[(file_index[filename])])
            data_abs2 = CT.elementwise_product(data.mps, conj(data.mps); cutoff=1e-5)
            push!(data_abs2_list, data_abs2)
        end
    end
    if isempty(data_abs2_list)
        println("No data found for pctrl=$(pctrl), sC=$(sC)")
        return NaN
    else
        data_abs2_mean_list = CT.sum_mps_tree(data_abs2_list)/length(data_abs2_list)
        return abs(inner(data_abs2_mean_list ,conj(data_abs2_mean_list)))
    end
end

function monte_carlo_abs2(L::Int,pctrl::Float64,sC::Int,sm::Int,z,file_index;sample_size::Int=10000, seed::Int=0, counter::Dict{Int, Int}=Dict{Int, Int}())
    rng = MersenneTwister(seed)
    filename = @sprintf("MPS_(0,1)_L%d_pctrl%.3f_sC%d_sm%d_XEB.jls", L, pctrl, sC, sm)
    @printf("Processing file: %s\n", filename)
    
    if haskey(file_index, filename)
        data = deserialize(z.files[(file_index[filename])])
        for i in 1:sample_size
            sample_ = sample!(rng, data.mps)
            rs = CT.bin2dec(sample_.-1)
            counter[rs] = get(counter, rs, 0) + 1
        end
    end

    return counter
end

function calc_MC(L::Int,pctrl::Float64,sC::Int,z,file_index;sm_max=500, sample_size::Int=10000, seed::Int=0)
    counter = Dict{Int, Int}()
    for sm in 0:sm_max-1
        @printf("Processing sm=%d\n", sm)
        _ = monte_carlo_abs2(L,pctrl,sC,sm,z,file_index;sample_size=sample_size, seed=seed, counter=counter)
    end
    vec = collect(values(counter))
    return sum((vec/sum(vec)).^2)
end

function create_zip_index(zip_reader)
    """
    Create a dictionary mapping filenames to their indices in the ZIP file.
    
    Parameters:
    - zip_reader: ZipFile.Reader object
    
    Returns:
    - Dictionary with filename -> index mapping
    """
    file_index = Dict{String, Int}()
    
    for (i, file) in enumerate(zip_reader.files)
        file_index[file.name] = i
    end
    
    return file_index
end

function get_file_by_name(zip_reader, filename, file_index=nothing)
    """
    Get a file from ZIP by filename using the index dictionary.
    
    Parameters:
    - zip_reader: ZipFile.Reader object
    - filename: Name of the file to retrieve
    - file_index: Optional pre-computed index dictionary
    
    Returns:
    - ZipFile.ReadableFile object or nothing if not found
    """
    if file_index === nothing
        file_index = create_zip_index(zip_reader)
    end
    
    if haskey(file_index, filename)
        index = file_index[filename]
        return zip_reader.files[index]
    else
        println("File '$filename' not found in ZIP")
        return nothing
    end
end

function list_files_in_zip(zip_reader)
    """
    List all files in the ZIP with their indices.
    
    Parameters:
    - zip_reader: ZipFile.Reader object
    """
    println("Files in ZIP:")
    for (i, file) in enumerate(zip_reader.files)
        println("  [$i] $(file.name)")
    end
end

function main()
    # Parse command line arguments
    args = parse_commandline()
    
    p_value = args["p_value"]
    L = args["L_value"]
    sample_size = args["sample-size"]
    seed = args["seed"]
    sm_max = args["sm-max"]
    
    println("Running with parameters:")
    println("  p_value: $(p_value)")
    println("  L: $(L)")
    println("  sample_size: $(sample_size)")
    println("  seed: $(seed)")
    println("  sm_max: $(sm_max)")
    
    start_time = time()
    
    directory = "/p/work/hpan/CT_MPS/"
    path = joinpath(directory, "MPS_0-1_XEB_L$(L).zip")
    z = ZipFile.Reader(path)
    file_index = create_zip_index(z)
    
    # pctrl_list = [.2,.25,.3,.35,.4,.45,.5,.55,.6,.65,.7,.75,.8,.85]
    # sC_list = 1:50
    pctrl_list = [p_value]
    sC_list = 1:49
    
    results = Matrix{Float64}(undef, length(pctrl_list), length(sC_list))
    params = [(i,j,pctrl,sC) for (i,pctrl) in enumerate(pctrl_list) for (j,sC) in enumerate(sC_list)]
    for (i,j,pctrl,sC) in params
        # results[i,j] = calc_(L, pctrl, sC, z, file_index)
        results[i,j] = calc_MC(L, pctrl, sC, z, file_index, sample_size=sample_size, sm_max=sm_max)
    end
    
    open("XEB_q_L$(L)_p$(p_value)_samples$(sample_size)_seed$(seed)_smmax$(sm_max).json", "w") do io
        write(io, JSON.json(Dict(
            "results"=>results, 
            "pctrl_list"=>pctrl_list, 
            "sC_list"=>sC_list, 
            "L"=>L, 
            "p"=>p_value,
            "sample_size"=>sample_size,
            "seed"=>seed,
            "sm_max"=>sm_max
        )))
    end
    
    execution_time = time() - start_time
    println(@sprintf("Total execution time: %.2f seconds (%.2f minutes)", execution_time, execution_time/60))
end

# Run main function if script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end