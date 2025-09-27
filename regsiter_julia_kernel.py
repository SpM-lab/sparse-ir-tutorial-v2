import subprocess
import sys
import json
import os

def list_jupyter_kernels():
    """
    jupyter kernelspec list を呼び出して、存在するカーネル名とパスを返す dict。
    例: {'python3': '/usr/.../kernels/python3', 'Julia': '/home/.../kernels/julia-1.10'}
    """
    try:
        # --json オプションで出力形式を JSON にできる場合もある
        proc = subprocess.run(["jupyter", "kernelspec", "list", "--json"], 
                              capture_output=True, text=True, check=True)
        info = json.loads(proc.stdout)
        # info["kernelspecs"] は、kernel 名をキーとし spec 情報を持つ dict
        specs = info.get("kernelspecs", {})
        result = {name: specs[name]["resource_dir"] for name in specs}
        return result
    except subprocess.CalledProcessError:
        # JSON モードが使えない環境もあるので fallback
        proc2 = subprocess.run(["jupyter", "kernelspec", "list"], capture_output=True, text=True, check=True)
        lines = proc2.stdout.splitlines()
        result = {}
        for line in lines:
            line = line.strip()
            if not line or line.startswith("Available kernels:"):
                continue
            parts = line.split()
            # 例行: "Julia     /home/user/.local/share/jupyter/kernels/julia-1.10"
            if len(parts) >= 2:
                name = parts[0]
                path = parts[-1]
                result[name] = path
        return result

def install_julia_kernel(kernel_name: str, julia_executable: str = "julia", project_arg: str = "--project=@."):
    """
    kernel_name がすでに登録されていたらエラーして終了。
    そうでなければ、Julia の IJulia.installkernel を呼んでカーネル登録する。
    """
    kernels = list_jupyter_kernels()
    if kernel_name in kernels:
        print(f"Error: kernel name '{kernel_name}' already exists (path = {kernels[kernel_name]})", file=sys.stderr)
        sys.exit(1)

    # コマンド例: julia -e 'using IJulia; installkernel("JuliaBook", "--project=@.")'
    cmd = [
        julia_executable,
        "-e",
        f'using IJulia; installkernel("{kernel_name}", "{project_arg}")'
    ]
    try:
        subprocess.run(cmd, check=True)
        print(f"Kernel '{kernel_name}' installed successfully.")
    except subprocess.CalledProcessError as e:
        print("Failed to install kernel:", e, file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    # 例：カーネル名を JuliaBook にして登録
    install_julia_kernel("JuliaBook")
