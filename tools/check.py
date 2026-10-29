"""Compile all Luau, run shared contract cases headlessly, verify package reproducibility."""
from pathlib import Path
import argparse
import re
import subprocess
import tempfile
import build

ROOT = Path(__file__).resolve().parents[1]


def check(compiler, runtime):
    paths = sorted(p for folder in ("src", "tests", "examples") for p in (ROOT/folder).rglob("*.luau"))
    for path in paths:
        subprocess.run([compiler, "--null", str(path)], check=True, capture_output=True, text=True)
    print(f"Compiled {len(paths)} Luau files")
    if runtime:
        with tempfile.TemporaryDirectory(prefix="axzf-contracts-") as directory:
            temp = Path(directory)
            for path in (ROOT/"src/Shared").glob("*.luau"):
                source = path.read_text(encoding="utf-8")
                source = re.sub(r"require\(script.Parent.(\w+)\)", r'require("./\1")', source)
                (temp/path.name).write_text(source, encoding="utf-8")
            names = ["Math_Test", "Tune_Test", "InputGuard_Test", "Powertrain_Test"]
            for name in names:
                source = (ROOT/f"tests/{name}.luau").read_text(encoding="utf-8")
                source = re.sub(r"require\(game.ReplicatedStorage.AXZF.Shared.(\w+)\)", r'require("./\1")', source)
                source = source.replace("local Shared=game.ReplicatedStorage.AXZF.Shared", "local Shared=nil")
                source = re.sub(r"require\(Shared.(\w+)\)", r'require("./\1")', source)
                (temp/f"{name}.luau").write_text(source, encoding="utf-8")
            runner = '''local e={}
function e.equal(a,b) assert(a==b,"values differ") end
function e.truthy(a) assert(a,"expected truthy") end
function e.falsy(a) assert(not a,"expected falsy") end
function e.near(a,b,t) assert(a==a and math.abs(a-b)<=(t or 1e-6),"not near") end
function e.throws(fn) assert(not pcall(fn),"expected error") end
local total,failed=0,0
local t={expect=e}
function t.test(name,fn) total+=1 local ok,err=pcall(fn) if not ok then failed+=1 print("FAIL",name,err) end end
'''
            runner += "\n".join(f'require("./{name}")(t)' for name in names)
            runner += '\nprint("HEADLESS",total,"run",failed,"failed") assert(failed==0)\n'
            (temp/"run.luau").write_text(runner, encoding="utf-8")
            subprocess.run([runtime, str(temp/"run.luau")], check=True, cwd=temp)
    artifacts = [ROOT/"build/A-XZF-Tune.rbxmx", ROOT/"build/A-XZF-Tune-Demo.rbxlx"]
    before = [p.read_bytes() for p in artifacts]
    build.build()
    assert before == [p.read_bytes() for p in artifacts], "Committed packages stale; run tools/build.py"
    print("Deterministic packages verified")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--compiler", required=True)
    p.add_argument("--runtime")
    args = p.parse_args()
    check(str(Path(args.compiler).resolve()), str(Path(args.runtime).resolve()) if args.runtime else None)
