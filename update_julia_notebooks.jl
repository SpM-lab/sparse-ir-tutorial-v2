#!/usr/bin/env julia

"""
Update Julia notebook metadata to use the custom 'juliabook' kernel.
This script updates all *_jl.ipynb files in the src/ directory.
"""

using JSON
using Glob
using Printf

function find_julia_notebooks(src_dir::String="src")
    """
    Find all Julia notebook files (*_jl.ipynb) in the specified directory.
    """
    pattern = joinpath(src_dir, "*_jl.ipynb")
    return glob(pattern)
end

function update_notebook_kernel(notebook_path::String, kernel_name::String="juliabook")
    """
    Update the kernel specification in a Julia notebook.
    
    Args:
        notebook_path: Path to the notebook file
        kernel_name: Name of the kernel to use (default: 'juliabook')
    
    Returns:
        bool: True if the notebook was updated, False otherwise
    """
    try
        # Read the notebook
        notebook = JSON.parsefile(notebook_path)
        
        # Check if metadata exists
        if !haskey(notebook, "metadata")
            notebook["metadata"] = Dict{String, Any}()
        end
        
        # Update kernelspec
        notebook["metadata"]["kernelspec"] = Dict(
            "display_name" => "Julia 1.11.2",
            "language" => "julia",
            "name" => kernel_name
        )
        
        # Update language_info
        notebook["metadata"]["language_info"] = Dict(
            "file_extension" => ".jl",
            "mimetype" => "application/julia",
            "name" => "julia",
            "version" => "1.11.2"
        )
        
        # Write back the notebook
        open(notebook_path, "w") do io
            JSON.print(io, notebook, 1)
        end
        
        return true
        
    catch e
        @error "Error updating $notebook_path: $e"
        return false
    end
end

function main()
    # Parse command line arguments
    src_dir = length(ARGS) > 0 && startswith(ARGS[1], "--src-dir=") ? 
               split(ARGS[1], "=")[2] : "src"
    kernel_name = length(ARGS) > 1 && startswith(ARGS[2], "--kernel-name=") ? 
                  split(ARGS[2], "=")[2] : "juliabook"
    dry_run = "--dry-run" in ARGS
    
    # Find Julia notebooks
    notebooks = find_julia_notebooks(src_dir)
    
    if isempty(notebooks)
        @printf "No Julia notebooks (*_jl.ipynb) found in %s/\n" src_dir
        return
    end
    
    @printf "Found %d Julia notebook(s) in %s/:\n" length(notebooks) src_dir
    for nb in notebooks
        @printf "  - %s\n" nb
    end
    
    if dry_run
        @printf "\nDry run mode - would update kernel to '%s' for all notebooks\n" kernel_name
        return
    end
    
    # Update notebooks
    updated_count = 0
    failed_count = 0
    
    @printf "\nUpdating kernel metadata to '%s'...\n" kernel_name
    
    for notebook_path in notebooks
        @printf "Updating %s... " basename(notebook_path)
        
        if update_notebook_kernel(notebook_path, kernel_name)
            println("✓")
            updated_count += 1
        else
            println("✗")
            failed_count += 1
        end
    end
    
    println("\nSummary:")
    @printf "  Updated: %d\n" updated_count
    @printf "  Failed:  %d\n" failed_count
    @printf "  Total:   %d\n" length(notebooks)
end

# Main execution
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
