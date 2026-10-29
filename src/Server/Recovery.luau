--!strict
local Recovery={}
Recovery.__index=Recovery
function Recovery.new(rig: any,tune: any): any
	return setmetatable({rig=rig,tune=tune,inverted=0,cooldown=0,count=0},Recovery)
end
function Recovery:step(dt: number): boolean
	local root=self.rig.root local t=self.tune
	self.cooldown=math.max(0,self.cooldown-dt)
	if not t.AutoRecover or self.cooldown>0 or root.CFrame.UpVector.Y>0.2 or root.AssemblyLinearVelocity.Magnitude>t.RecoverMaxSpeed then
		if self.rig.model:GetAttribute("AXZF_recovery")=="Waiting for space" then self.rig.model:SetAttribute("AXZF_recovery",nil) end
		self.inverted=0 return false
	end
	local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
	local excluded={self.rig.model}
	if self.rig.seat.Occupant then table.insert(excluded,self.rig.seat.Occupant.Parent) end
	params.FilterDescendantsInstances=excluded params.RespectCanCollide=true
	local ground=workspace:Raycast(root.Position,Vector3.new(0,-12,0),params)
	if not ground or ground.Normal.Y<0.7 or math.abs(root.AssemblyLinearVelocity.Y)>3 then self.inverted=0 return false end
	self.inverted+=dt
	if self.inverted<t.RecoverDelay then return false end
	local oldRoot=root.CFrame
	local box,size=self.rig.model:GetBoundingBox()
	local offset=oldRoot:ToObjectSpace(box)
	local forward=Vector3.new(oldRoot.LookVector.X,0,oldRoot.LookVector.Z)
	if forward.Magnitude<0.1 then forward=Vector3.new(0,0,-1) end
	local orientation=CFrame.lookAt(Vector3.zero,forward.Unit)
	local transformed=orientation*offset
	local verticalExtent=(math.abs(transformed.RightVector.Y)*size.X+math.abs(transformed.UpVector.Y)*size.Y+math.abs(transformed.LookVector.Y)*size.Z)/2
	local height=verticalExtent-transformed.Position.Y+0.35
	local target=CFrame.new(ground.Position+Vector3.new(0,height,0))*orientation
	local overlap=OverlapParams.new() overlap.FilterType=Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances=excluded overlap.RespectCanCollide=true
	if #workspace:GetPartBoundsInBox(target*offset,size+Vector3.new(.1,.1,.1),overlap)>0 then
		self.rig.model:SetAttribute("AXZF_recovery","Waiting for space") return false
	end
	self.rig.model:PivotTo(target*oldRoot:Inverse()*self.rig.model:GetPivot())
	root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
	self.count+=1 self.cooldown=5 self.inverted=0
	self.rig.model:SetAttribute("AXZF_recoveryCount",self.count)
	self.rig.model:SetAttribute("AXZF_recovery","Recovered")
	return true
end
return Recovery
