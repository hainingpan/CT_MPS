using Pkg
Pkg.activate("CT")
using CT
using ZipFile
using Serialization
using ProgressMeter
using Printf
using ITensors
using JSON

directory = "/p/work/hpan/CT_MPS/"
L=20
# pctrl_list = [.2,.25,.3,.35,.4,.45,.5,.55,.6,.65,.7,.75,.8,.85]
# sC_list = 1:50
pctrl_list = [.85]
sC_list = 1:9


function calc_(L,pctrl,sC;sm_max=9)
    data_abs2_list = MPS[];
    for sm in 0:sm_max
        filename = @sprintf("MPS_(0,1)_L%d_pctrl%.3f_sC%d_sm%d_XEB.jls", L, pctrl, sC, sm)
        # @printf("Processing file: %s\n", filename)
        if haskey(file_index, filename)
            data = deserialize(z.files[(file_index[filename])]);
            data_abs2 = CT.elementwise_product(data.mps, conj(data.mps); cutoff=1e-5);
            push!(data_abs2_list, data_abs2);
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

path = joinpath(directory, "MPS_0-1_XEB_L$(L).zip")
z = ZipFile.Reader( path);
file_index = create_zip_index(z);

results = Matrix{Float64}(undef, length(pctrl_list), length(sC_list))
@showprogress for (i,pctrl) in enumerate(pctrl_list), (j,sC) in enumerate(sC_list)
    # @printf("Processing pctrl=%.3f, sC=%d\n", pctrl, sC)
    results[i,j] = calc_(L, pctrl, sC)
end

open("L$(L)_XEB_sim.json", "w") do io
    write(io, JSON.json(Dict("results"=>results, "pctrl_list"=>pctrl_list, "sC_list"=>sC_list)))
end


