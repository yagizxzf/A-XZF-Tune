--!strict
local Doctor=require(script.Parent.Doctor)
local Rig={}
function Rig.bind(model: Model): any
	assert(not model:GetAttribute("AXZFBound"),"Vehicle already bound")
	local report=Doctor.inspect(model)
	assert(report.ok,"Rig rejected: "..game:GetService("HttpService"):JSONEncode(report.errors))
	local root=model.Chassis :: BasePart
	local self={model=model,root=root,seat=model.DriveSeat,wheels={},created={},snapshots={},destroyed=false}
	local ownership=nil
	if game:GetService("RunService"):IsRunning() and root:CanSetNetworkOwnership() then ownership={automatic=root:GetNetworkOwnershipAuto(),owner=root:GetNetworkOwner()} end
	local function own(instance) table.insert(self.created,instance) return instance end
	local function weld(a,b)
		local w=own(Instance.new("WeldConstraint")) w.Name="AXZF_Weld" w.Part0=a w.Part1=b w.Parent=a
	end
	function self:destroy()
		if self.destroyed then return end self.destroyed=true
		if self.seat.Occupant then self.seat.Occupant.Sit=false end
		local seatWeld=self.seat:FindFirstChild("SeatWeld") if seatWeld then seatWeld:Destroy() end
		for i=#self.created,1,-1 do self.created[i]:Destroy() end
		for p,s in pairs(self.snapshots) do
			if p.Parent then for key,value in pairs(s) do p[key]=value end end
		end
		model:SetAttribute("AXZFBound",nil)
		if ownership and root.Parent and root:CanSetNetworkOwnership() then
			if ownership.automatic then root:SetNetworkOwnershipAuto() else root:SetNetworkOwner(ownership.owner) end
		end
	end
	local ok,err=pcall(function()
		for _,p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				self.snapshots[p]={Anchored=p.Anchored,Massless=p.Massless,CanCollide=p.CanCollide,CanQuery=p.CanQuery,RootPriority=p.RootPriority,CFrame=p.CFrame}
				p.Anchored=true p.Massless=p~=root p.CanCollide=p==root p.CanQuery=p==root
			end
		end
		root.RootPriority=127
		for _,p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") and p~=root and not p:IsDescendantOf(model.Wheels) then weld(root,p) end
		end
		for _,id in ipairs({"FL","FR","RL","RR"}) do
			local wheel=model.Wheels[id] local hub=Doctor.hub(wheel) :: BasePart
			if wheel:IsA("Model") then for _,p in ipairs(wheel:GetDescendants()) do if p:IsA("BasePart") and p~=hub then weld(hub,p) end end end
			local mount=root[id] :: Attachment
			local motor=own(Instance.new("Motor6D")) motor.Name="AXZF_"..id motor.Part0=root motor.Part1=hub
			motor.C0=root.CFrame:ToObjectSpace(hub.CFrame) motor.Parent=root
			local rotation=hub.CFrame.Rotation:ToObjectSpace(root.CFrame.Rotation):Inverse()
			table.insert(self.wheels,{id=id,mount=mount,motor=motor,rotation=rotation,spin=0,load=0,length=0})
		end
		for p in pairs(self.snapshots) do p.Anchored=false end
		if game:GetService("RunService"):IsRunning() then
			local can,reason=root:CanSetNetworkOwnership() assert(can,reason)
			root:SetNetworkOwner(nil)
		end
		model:SetAttribute("AXZFBound",true)
	end)
	if not ok then self:destroy() error(err,2) end
	return self
end
return Rig
