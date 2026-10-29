--!strict
local Doctor=require(script.Parent.Doctor)
local Adapter={}
-- Explicit geometry adapter. Author retains responsibility for removing old mechanics.
-- root/seat must be descendants; wheel references must be distinct sibling parts/models.
function Adapter.prepare(model: Model, root: BasePart, seat: VehicleSeat, wheels: any, restLength: number): any
	assert(not model:GetAttribute("AXZFBound"),"Cannot adapt a running vehicle")
	assert(root:IsDescendantOf(model) and seat:IsDescendantOf(model),"Root/seat must belong to model")
	assert(restLength>0 and restLength<=10,"Invalid rest length")
	assert(not model:FindFirstChild("Wheels") and not model:FindFirstChild("Body"),"Adapter expects unconfigured geometry; use Doctor on an existing rig")
	local seen={}
	for _,id in ipairs({"FL","FR","RL","RR"}) do
		local wheel=wheels[id]
		assert(wheel and wheel:IsDescendantOf(model) and wheel~=root and wheel~=seat and not seen[wheel],"Invalid/duplicate wheel "..id)
		assert(Doctor.hub(wheel),"Wheel needs a hub: "..id)
		seen[wheel]=true
	end
	-- All assertions above happen before mutating the supplied geometry.
	local body=Instance.new("Folder") body.Name="Body"
	local folder=Instance.new("Folder") folder.Name="Wheels"
	root.Name="Chassis" root.Parent=model seat.Name="DriveSeat" seat.Parent=model
	for _,id in ipairs({"FL","FR","RL","RR"}) do
		local wheel=wheels[id] local hub=Doctor.hub(wheel) :: BasePart
		local mount=Instance.new("Attachment") mount.Name=id
		mount.Position=root.CFrame:PointToObjectSpace(hub.Position)+Vector3.new(0,restLength,0)
		mount.Parent=root wheel.Name=id wheel.Parent=folder
	end
	for _,v in ipairs(model:GetChildren()) do
		if v~=root and v~=seat and not v:IsA("LuaSourceContainer") then v.Parent=body end
	end
	body.Parent=model folder.Parent=model model.PrimaryPart=root
	return Doctor.inspect(model)
end
return Adapter
