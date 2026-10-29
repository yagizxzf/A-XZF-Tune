-- rbxmk 0.9.1. Preserve native binary mesh/union payloads without XML conversion.
local descriptor=rbxmk.globalDesc
-- Decode raw serialized aliases such as BasePart.size without dropping them.
rbxmk.globalDesc=nil
local place=fs.read("build/AXZF-LocalRuntime.rbxmx","rbxlx")
local assets=fs.read("build/AXZF-CompatibilityCars.rbxm","rbxm")
local folder=assets:GetChildren()[1]
assert(folder.Name=="AXZFCompatibilitySources")
-- rbxmk 0.9.1 cannot round-trip every current PhysicalProperties payload.
-- Preserve our authored 1.2 root density through the supported per-car Tune.
for _,model in ipairs(folder:GetChildren()) do
    local root=model:FindFirstChild("Chassis")
    local tune=model:FindFirstChild("Tune")
    local properties=root[sym.Properties]
    local size=properties.size or properties.Size
    assert(size,"Native Chassis size missing")
    local mass=1.2*size.X*size.Y*size.Z
    tune.Source=tune.Source:gsub("Mass = 0,","Mass = "..tostring(mass)..",",1)
    root.CustomPhysicalProperties=nil
end
folder.Parent=place:FindFirstChild("ServerStorage")
local registration=Instance.new("Script")
registration.Name="LocalCompatibilityDemo"
registration.Source=[==[
local sources=game.ServerStorage.AXZFCompatibilitySources
assert(workspace:WaitForChild("AXZF_TestTrack",15),"Demo track did not initialize")
for i,name in ipairs({"AXZF_AC_Sedan","AXZF_AC_Police","AXZF_AC_SUV","AXZF_ImportedCar"}) do
    local m=sources[name]:Clone()
    m:PivotTo(CFrame.new(-50+i*20,5,70))
    m.Parent=workspace
    game:GetService("CollectionService"):AddTag(m,"AXZFVehicle")
end
]==]
registration.Parent=place:FindFirstChild("ServerScriptService")
rbxmk.globalDesc=descriptor -- service flags are required by the binary place writer
fs.write("build/A-XZF-CompatibilityDemo.rbxl",place,"rbxl")
print("Local compatibility demo written; external art excluded from Git")
