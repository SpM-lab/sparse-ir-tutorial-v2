#!/usr/bin/env julia

"""
Julia kernel registration script for Jupyter Book.
This script registers a custom Julia kernel without automatic version suffix.
"""

using Pkg
using IJulia
using Printf
using JSON

function list_jupyter_kernels()
    """
    List all registered Jupyter kernels.
    Returns a dictionary mapping kernel names to their paths.
    """
    try
        # Get kernelspec directory
        kernel_dir = IJulia.kerneldir()
        
        if !isdir(kernel_dir)
            return Dict{String, String}()
        end
        
        kernels = Dict{String, String}()
        for item in readdir(kernel_dir)
            kernel_path = joinpath(kernel_dir, item)
            if isdir(kernel_path)
                kernels[item] = kernel_path
            end
        end
        
        return kernels
    catch e
        @warn "Failed to list kernels: $e"
        return Dict{String, String}()
    end
end

function remove_existing_kernel(kernel_name::String)
    """
    Remove existing kernel with the given name.
    """
    kernels = list_jupyter_kernels()
    
    if haskey(kernels, kernel_name)
        @printf "Warning: Kernel '%s' already exists at %s\n" kernel_name kernels[kernel_name]
        println("Removing existing kernel...")
        
        try
            kernel_path = kernels[kernel_name]
            if isdir(kernel_path)
                rm(kernel_path, recursive=true, force=true)
                @printf "Removed existing kernel directory: %s\n" kernel_path
            end
        catch e
            @error "Failed to remove existing kernel: $e"
            return false
        end
    end
    
    return true
end

function get_julia_version()
    """
    Get Julia version string.
    """
    return string(VERSION)
end

function create_custom_kernel_spec(kernel_name::String, julia_executable::String="julia", project_arg::String="--project=@.")
    """
    Create a custom kernel specification without version suffix.
    """
    # Get Julia version
    julia_version = get_julia_version()
    @printf "Julia version: %s\n" julia_version
    
    # Ensure kernel directory exists
    kernel_dir = joinpath(IJulia.kerneldir(), kernel_name)
    mkpath(kernel_dir)
    
    # Create kernel.json
    kernel_spec = Dict(
        "display_name" => "Julia $(julia_version)",
        "argv" => [
            julia_executable,
            "-i",
            "--color=yes",
            project_arg,
            "-e",
            "import IJulia; IJulia.run_kernel()",
            "{connection_file}"
        ],
        "language" => "julia",
        "env" => Dict{String, String}(),
        "interrupt_mode" => "signal"
    )
    
    # Write kernel.json
    kernel_json_path = joinpath(kernel_dir, "kernel.json")
    open(kernel_json_path, "w") do io
        JSON.print(io, kernel_spec, 2)
    end
    
    @printf "Kernel '%s' installed successfully at %s\n" kernel_name kernel_dir
end

function register_julia_kernel(kernel_name::String, julia_executable::String="julia", project_arg::String="--project=@.")
    """
    Register a Julia kernel with custom name (no version suffix).
    """
    # List existing kernels
    kernels = list_jupyter_kernels()
    @printf "Existing kernels: %s\n" join(keys(kernels), ", ")
    
    # Remove existing kernel if it exists
    if !remove_existing_kernel(kernel_name)
        @error "Failed to remove existing kernel"
        return false
    end
    
    # Create custom kernel specification
    try
        create_custom_kernel_spec(kernel_name, julia_executable, project_arg)
        return true
    catch e
        @error "Failed to create kernel specification: $e"
        return false
    end
end

# Main execution
if abspath(PROGRAM_FILE) == @__FILE__
    # Register kernel with name "juliabook"
    success = register_julia_kernel("juliabook")
    
    if success
        println("✓ Kernel registration completed successfully")
    else
        println("✗ Kernel registration failed")
        exit(1)
    end
end
