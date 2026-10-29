--!strict
local storage=game:GetService("ServerStorage")
local rs=game:GetService("ReplicatedStorage")
local tags=game:GetService("CollectionService")
local examples=storage:WaitForChild("AXZFExamples")
if not workspace:FindFirstChildOfClass("SpawnLocation") then
	local spawn=Instance.new("SpawnLocation") spawn.Name="AXZFSpawn" spawn.Anchored=true
	spawn.Size=Vector3.new(5,0.5,5) spawn.CFrame=CFrame.new(0,1,45) spawn.Parent=workspace
end
if not workspace:FindFirstChild("AXZF_TestTrack") then require(examples.TestTrack).create().Parent=workspace end
if not workspace:FindFirstChild("AXZF_Prototype") then
	local car=require(examples.PrototypeCar).create(CFrame.new(-12,5,35))
	car.Parent=workspace tags:AddTag(car,"AXZFVehicle")
end
