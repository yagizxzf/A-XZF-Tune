"""Optional local compatibility scene; requires rbxmk 0.9.1 and reviewed native export."""
import argparse
from pathlib import Path
import subprocess

if __name__ == "__main__":
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument("--converter", default=str(root/".tools/rbxmk/rbxmk.exe"))
    parser.add_argument("--descriptor", default=str(root/".tools/rbxmk/API-Descriptor.json"), help="rbxmk-compatible API descriptor; class Service tags are required")
    args = parser.parse_args()
    assert (root/"build/AXZF-CompatibilityCars.rbxm").is_file(), "Export the reviewed source folder from Studio first"
    # rbxmk's older XML parser rejects ElementTree's single-quoted declaration.
    source = (root/"build/A-XZF-Tune-Demo.rbxlx").read_text(encoding="utf-8")
    (root/"build/AXZF-LocalRuntime.rbxmx").write_text(source.split("?>",1)[-1].lstrip(), encoding="utf-8")
    assert Path(args.descriptor).is_file(), "Supply a compatible API descriptor (see docs/ASSETS.md)"
    result = subprocess.run([args.converter, "run", "--desc-file", args.descriptor, "tools/export_compatibility.lua"], cwd=root, check=True, capture_output=True, text=True)
    if "Local compatibility demo written" not in result.stdout:
        raise RuntimeError(result.stderr or result.stdout or "Native export did not complete")
    print(result.stdout, end="")
