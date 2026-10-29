--!strict
return function(source: Model,overrides: any): any
	local Run=game:GetService("RunService") assert(Run:IsStudio() and Run:IsServer(),"Studio server only")
	local m=source:Clone() game:GetService("CollectionService"):RemoveTag(m,"AXZFVehicle") m.Name="__AXZF_ParkingTest" m.DriveSeat.Disabled=true
	m:PivotTo(CFrame.new(1100,6,50)) m.Parent=workspace
	local floor=Instance.new("Part") floor.Name="__AXZF_ParkFloor" floor.Anchored=true floor.Size=Vector3.new(100,1,500) floor.Position=Vector3.new(1100,0,0) floor.Parent=workspace
	local v=nil local connection=nil local result={}
	local ok,err=xpcall(function()
		v=require(game.ServerScriptService.AXZFServer.Vehicle).new(m,overrides)
		connection=Run.PreSimulation:Connect(function(dt) v:step(dt) end)
		local root=m.Chassis
		local function command(seconds,park,throttle)
			local start=os.clock() repeat v:setInput({throttle=throttle,steer=0,brake=0,handbrake=false,park=park}) task.wait(.05) until os.clock()-start>=seconds
		end
		task.wait(2) root.AssemblyLinearVelocity=root.CFrame.LookVector*45
		v:setPark(true) v:step(1/60) result.moving=v:getTelemetry().parkState
		command(2,true,1) result.parkSpeed=root.AssemblyLinearVelocity.Magnitude result.state=v:getTelemetry().parkState
		v:clearInput() task.wait(.5) result.retained=v.parkRequested
		result.handbrake=v:getTelemetry().handbrake result.anchored=root.Anchored
		command(1,false,1) result.releasedSpeed=root.AssemblyLinearVelocity.Magnitude
		floor.CFrame=CFrame.new(1100,0,0)*CFrame.Angles(math.rad(8),0,0)
		m:PivotTo(CFrame.new(1100,6,0)*CFrame.Angles(math.rad(8),0,0)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
		command(3,true,1) result.slopeSpeed=root.AssemblyLinearVelocity.Magnitude
		result.pass=result.moving=="Stopping" and result.parkSpeed<1.5 and result.state=="Parked" and result.retained and not result.handbrake and not result.anchored and result.releasedSpeed>5 and result.slopeSpeed<.1
	end,debug.traceback)
	if connection then connection:Disconnect() end if v then v:destroy() end m:Destroy() floor:Destroy()
	if not ok then result.pass=false result.error=tostring(err) end return result
end
