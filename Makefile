setup:
	sh ./bin/setup
	@echo "Setup complete, activate the environment with 'source .venv/bin/activate'"

update_kernel:
	julia --project=@. register_julia_kernel.jl

build:
	. .venv/bin/activate && jupyter book build --all -v .

upload:	build
	. .venv/bin/activate && ghp-import -n -p -f _build/html

clean:
	rm -rf _build
