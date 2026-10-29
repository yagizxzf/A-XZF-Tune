--!strict
local Doctor={}
local ids={"FL","FR","RL","RR"}
function Doctor.hub(wheel: Instance?): BasePart?
	if wheel and wheel:IsA("BasePart") then return wheel end
	if wheel and wheel:IsA("Model") then return wheel.PrimaryPart end
	return nil
end
function Doctor.inspect(model: any): any
	local errors, warnings={},{}
	local function fail(code,message) table.insert(errors,{code=code,message=message}) end
	if typeof(model)~="Instance" or not model:IsA("Model") then
		fail("MODEL","Expected a Model") return {ok=false,errors=errors,warnings=warnings}
	end
	local root=model:FindFirstChild("Chassis")
	local seat=model:FindFirstChild("DriveSeat")
	local wheels=model:FindFirstChild("Wheels")
	local body=model:FindFirstChild("Body")
	if not root or not root:IsA("BasePart") then fail("ROOT","Add a Chassis BasePart facing local -Z") end
	if not seat or not seat:IsA("VehicleSeat") then fail("SEAT","Add DriveSeat (VehicleSeat)") end
	if not body then fail("BODY","Add Body folder/model containing your separate panels") end
	if not wheels then fail("WHEELS","Add Wheels containing FL/FR/RL/RR") end
	local hubs={}
	for _,id in ipairs(ids) do
		local mount=root and root:FindFirstChild(id)
		if not mount or not mount:IsA("Attachment") then fail("MOUNT_"..id,"Chassis needs Attachment "..id) end
		local hub=Doctor.hub(wheels and wheels:FindFirstChild(id))
		if not hub then fail("HUB_"..id,"Wheel "..id.." must be BasePart or Model with PrimaryPart")
		elseif hubs[hub] then fail("DUPLICATE_HUB","Each wheel needs its own hub") else hubs[hub]=true end
	end
	local count=0
	for _,v in ipairs(model:GetDescendants()) do
		if v:IsA("BasePart") then count+=1 end
		if v:IsA("LuaSourceContainer") and not (v:IsA("ModuleScript") and v.Name=="Tune" and v.Parent==model) then fail("SCRIPT","Remove previous chassis code: "..v:GetFullName()) end
		if v:IsA("Constraint") or v:IsA("WeldConstraint") or v:IsA("JointInstance") or v:IsA("BodyMover") then fail("MECHANICS","Remove previous joints/constraints: "..v.Name) end
	end
	if root and root:IsA("BasePart") then
		local fl,fr,rl,rr=root:FindFirstChild("FL"),root:FindFirstChild("FR"),root:FindFirstChild("RL"),root:FindFirstChild("RR")
		if fl and fr and rl and rr and fl:IsA("Attachment") and fr:IsA("Attachment") and rl:IsA("Attachment") and rr:IsA("Attachment") then
			if fl.Position.X>=fr.Position.X or rl.Position.X>=rr.Position.X or fl.Position.Z>=rl.Position.Z or fr.Position.Z>=rr.Position.Z then fail("LAYOUT","Front = -Z, left = -X; check wheel labels/orientation") end
			if (fl.Position-fr.Position).Magnitude<0.5 or (fl.Position-rl.Position).Magnitude<0.5 then fail("SPACING","Wheel spacing must exceed 0.5 studs") end
		end
	end
	if count>200 then table.insert(warnings,{code="PART_COUNT",message="Over 200 parts; measure replication/render cost"}) end
	return {ok=#errors==0,errors=errors,warnings=warnings,parts=count}
end
return Doctor
