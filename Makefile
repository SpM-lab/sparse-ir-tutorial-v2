setup:
	sh ./bin/setup

update_kernel:
	julia --project=@. register_julia_kernel.jl

build:
	. .venv/bin/activate && jupyter book build --all -v .

upload:	build
	. .venv/bin/activate && ghp-import -n -p -f _build/html

clean:
	rm -rf _build
