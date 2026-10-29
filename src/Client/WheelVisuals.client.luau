--!strict
-- Cosmetic only; no forces, ownership changes or client-to-server state.
local Run=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local packageRoot=game.ReplicatedStorage:WaitForChild("AXZF")
local Motion=require(packageRoot:WaitForChild("Shared"):WaitForChild("WheelMotion"))
local wheels={}
local function add(motor)
	if motor:IsA("Motor6D") then wheels[motor]={phase=0} end
end
local function remove(motor)
	wheels[motor]=nil
	if motor.Parent then motor.Transform=CFrame.identity end
end
local added=Tags:GetInstanceAddedSignal("AXZFWheelVisual"):Connect(add)
local removed=Tags:GetInstanceRemovedSignal("AXZFWheelVisual"):Connect(remove)
for _,motor in ipairs(Tags:GetTagged("AXZFWheelVisual")) do add(motor) end
local update=Run.PreSimulation:Connect(function(dt)
	local camera=workspace.CurrentCamera
	if not camera then return end
	for motor,state in pairs(wheels) do
		local root,hub=motor.Part0,motor.Part1
		local radius=motor:GetAttribute("AXZF_Radius")
		local axis=motor:GetAttribute("AXZF_RollAxis") local forward=motor:GetAttribute("AXZF_ForwardAxis")
		if root and hub and root:IsDescendantOf(workspace) and typeof(radius)=="number" and radius>0 and typeof(axis)=="Vector3" and typeof(forward)=="Vector3" then
			if (root.Position-camera.CFrame.Position).Magnitude>250 then continue end
			local frame=root.CFrame*motor.C0
			local direction=frame:VectorToWorldSpace(forward)
			local speed=root:GetVelocityAtPosition(hub.Position):Dot(direction)
			local model=root.Parent
			local rear=motor:GetAttribute("AXZF_Rear")==true
			local locked=(rear and model:GetAttribute("AXZF_handbrake")==true) or model:GetAttribute("AXZF_parkState")=="Parked"
			state.phase=Motion.advance(state.phase,speed,radius,dt,locked)
			motor.Transform=CFrame.fromAxisAngle(axis,state.phase)
		end
	end
end)
script.Destroying:Connect(function()
	update:Disconnect() added:Disconnect() removed:Disconnect()
	for motor in pairs(wheels) do remove(motor) end
end)
