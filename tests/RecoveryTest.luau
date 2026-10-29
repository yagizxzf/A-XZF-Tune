--!strict
return function(): any
	assert(game:GetService("RunService"):IsStudio(),"Studio only")
	local floor=Instance.new("Part") floor.Name="__AXZF_RecoveryFloor" floor.Anchored=true
	floor.Size=Vector3.new(50,1,50) floor.CFrame=CFrame.new(150,0,30) floor.Parent=workspace
	local m=require(game.ServerStorage.AXZFExamples.PrototypeCar).create(CFrame.new(150,5,30))
	m.Name="__Prototype_AXZF_Recovery"
	m.DriveSeat.Disabled=true m.Parent=workspace
	local v=nil local connection=nil local obstruction=nil local r={}
	local ok,err=xpcall(function()
		v=require(game.ServerScriptService.AXZFServer.Vehicle).new(m,{RecoverDelay=.5})
		connection=game:GetService("RunService").PreSimulation:Connect(function(dt) v:step(dt) end)
		task.wait(2) m:PivotTo(CFrame.new(150,4,30)*CFrame.Angles(0,0,math.pi)) m.Chassis.AssemblyLinearVelocity=Vector3.zero m.Chassis.AssemblyAngularVelocity=Vector3.zero
		task.wait(3) r.invertedRecovered=m.Chassis.CFrame.UpVector.Y>.9 and v.recovery.count==1
		local count=v.recovery.count
		m:PivotTo(CFrame.new(150,40,30)*CFrame.Angles(0,0,math.pi)) m.Chassis.AssemblyLinearVelocity=Vector3.new(0,-10,0)
		task.wait(.25) r.airborneNotTeleported=v.recovery.count==count
		m:PivotTo(CFrame.new(150,5,30)) m.Chassis.AssemblyLinearVelocity=Vector3.zero m.Chassis.AssemblyAngularVelocity=Vector3.zero
		task.wait(2) r.uprightUntouched=v.recovery.count==count
		-- Wait out the real cooldown, then block the target upright volume.
		task.wait(5)
		obstruction=Instance.new("Part") obstruction.Name="__AXZF_RecoveryCeiling" obstruction.Anchored=true
		obstruction.Size=Vector3.new(30,1,30) obstruction.CFrame=CFrame.new(150,4.5,30) obstruction.Parent=workspace
		m:PivotTo(CFrame.new(150,1.3,30)*CFrame.Angles(0,0,math.pi)) m.Chassis.AssemblyLinearVelocity=Vector3.zero m.Chassis.AssemblyAngularVelocity=Vector3.zero
		task.wait(1.5) r.blockedSpaceWaits=v.recovery.count==count and m:GetAttribute("AXZF_recovery")=="Waiting for space"
		obstruction:Destroy() obstruction=nil
		task.wait(1.5) r.recoversWhenClear=v.recovery.count==count+1
		r.pass=r.invertedRecovered and r.airborneNotTeleported and r.uprightUntouched and r.blockedSpaceWaits and r.recoversWhenClear
	end,debug.traceback)
	if connection then connection:Disconnect() end if v then v:destroy() end if obstruction then obstruction:Destroy() end m:Destroy() floor:Destroy()
	if not ok then r.pass=false r.error=tostring(err) end
	return r
end
