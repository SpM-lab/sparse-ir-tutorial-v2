build:
	@echo "Installing Python packages..."
	uv sync
	@echo "Installing Julia packages..."
	julia --project=@. --startup-file=no -e "import Pkg;Pkg.instantiate()"
	@echo "Registering kernel for Julia notebooks..."
	julia --project=@. --startup-file=no register_julia_kernel.jl
	@echo "Building HTML files..."
	. .venv/bin/activate && jupyter book build --all -v .

upload:	build
	. .venv/bin/activate && ghp-import -n -p -f _build/html

clean:
	rm -rf _build
