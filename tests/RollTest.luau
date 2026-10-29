--!strict
-- Identical occupied-mass, 55 stud/s left/right turn trials before/after changes.
return function(source: Model, overrides: any): any
	local Run=game:GetService("RunService")
	assert(Run:IsStudio() and Run:IsServer(),"Studio server only")
	local floor=Instance.new("Part") floor.Name="__AXZF_RollFloor" floor.Anchored=true
	floor.Size=Vector3.new(1000,1,1000) floor.Position=Vector3.new(1200,0,-500) floor.Parent=workspace
	local m=source:Clone() game:GetService("CollectionService"):RemoveTag(m,"AXZFVehicle")
	m.Name="__AXZF_RollTest" m.DriveSeat.Disabled=true m:PivotTo(CFrame.new(1200,6,-300)) m.Parent=workspace
	local v=nil local connection=nil local result={trials={}}
	local ok,err=xpcall(function()
		v=require(game.ServerScriptService.AXZFServer.Vehicle).new(m,overrides)
		-- Deterministic seated-rider surrogate; same 24 mass and seat position in both versions.
		local rider=Instance.new("Part") rider.Name="RiderMass" rider.Size=Vector3.new(2,3,2)
		rider.Transparency=1 rider.CanCollide=false rider.CFrame=m.DriveSeat.CFrame*CFrame.new(0,1,0)
		rider.CustomPhysicalProperties=PhysicalProperties.new(2,0,0) rider.Parent=m
		local weld=Instance.new("WeldConstraint") weld.Part0=m.Chassis weld.Part1=rider weld.Parent=rider
		connection=Run.PreSimulation:Connect(function(dt) v:step(dt) end)
		local root=m.Chassis
		for _,trial in ipairs({{55,-1},{55,1},{90,-1},{90,1}}) do
			local entrySpeed,direction=trial[1],trial[2]
			m:PivotTo(CFrame.new(1200,6,-300)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
			local start=os.clock() repeat v:setInput({throttle=0,steer=0,brake=1,handbrake=false}) task.wait(.05) until os.clock()-start>2
			root.AssemblyLinearVelocity=root.CFrame.LookVector*entrySpeed
			local forward=root.CFrame.LookVector local maxRoll,maxSpeed,samples=0,0,0 start=os.clock()
			repeat
				v:setInput({throttle=.35,steer=.65*direction,brake=0,handbrake=false})
				Run.PostSimulation:Wait() samples+=1
				maxRoll=math.max(maxRoll,math.deg(math.abs(math.atan2(root.CFrame.RightVector.Y,root.CFrame.UpVector.Y))))
				maxSpeed=math.max(maxSpeed,root.AssemblyLinearVelocity.Magnitude)
			until os.clock()-start>2.5
			local yaw=math.deg(math.acos(math.clamp(forward:Dot(root.CFrame.LookVector),-1,1)))
			table.insert(result.trials,{entrySpeed=entrySpeed,direction=direction,maxRollDegrees=maxRoll,maxSpeed=maxSpeed,yawDegrees=yaw,samples=samples,pass=maxRoll<12 and yaw>5 and root.CFrame.UpVector.Y>.9})
		end
		result.pass=true for _,trial in ipairs(result.trials) do if not trial.pass then result.pass=false end end
	end,debug.traceback)
	if connection then connection:Disconnect() end if v then v:destroy() end m:Destroy() floor:Destroy()
	if not ok then result.pass=false result.error=tostring(err) end
	return result
end
