--!strict
-- Integration harness intentionally kept outside runtime. It refuses live servers.
local RunService=game:GetService("RunService")
local Vehicle=require(game.ServerScriptService.AXZFServer.Vehicle)
return function(source: Model, overrides: any): any
	assert(RunService:IsStudio() and RunService:IsServer(),"Studio server tests only")
	local floor=Instance.new("Part") floor.Name="__AXZF_DriveFloor" floor.Anchored=true
	-- Stay below Roblox's per-part size limit, with a 2,000-stud braking lane.
	floor.Size=Vector3.new(200,1,2000) floor.CFrame=CFrame.new(1000,0,-900) floor.Parent=workspace
	local model=source:Clone() model.Name="__Prototype_AXZF_DriveTest"
	game:GetService("CollectionService"):RemoveTag(model,"AXZFVehicle")
	model.DriveSeat.Disabled=true
	model:PivotTo(CFrame.new(1000,5,20)) model.Parent=workspace
	local vehicle=nil local connection=nil local observations={}
	local ok,err=xpcall(function()
		vehicle=Vehicle.new(model,overrides)
		connection=RunService.PreSimulation:Connect(function(dt) vehicle:step(dt) end)
		local root=model.Chassis
		local function drive(seconds,throttle,steer,brake)
			local start=os.clock()
			repeat vehicle:setInput({throttle=throttle,steer=steer,brake=brake,handbrake=false}) task.wait(.05) until os.clock()-start>=seconds
		end
		drive(3,0,0,1)
		observations.settled={height=root.Position.Y,upright=root.CFrame.UpVector.Y,verticalSpeed=root.AssemblyLinearVelocity.Y}
		drive(5,1,0,0)
		observations.accelerate={speed=root.AssemblyLinearVelocity.Magnitude,position=tostring(root.Position),upright=root.CFrame.UpVector.Y}
		drive(4,0,0,1)
		observations.brake={speed=root.AssemblyLinearVelocity.Magnitude}
		-- Fresh grounded pose avoids carrying acceleration-test position into steering trial.
		model:PivotTo(CFrame.new(1000,5,20)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
		drive(3,0,0,1) local forward=root.CFrame.LookVector
		drive(2,0.35,0.7,0)
		observations.steer={degrees=math.deg(math.acos(math.clamp(forward:Dot(root.CFrame.LookVector),-1,1))),upright=root.CFrame.UpVector.Y}
		vehicle:setInput({throttle=1,steer=0,brake=0,handbrake=false})
		task.wait(.5)
		observations.watchdog={age=vehicle.inputAge,expired=vehicle.inputAge>vehicle.tune.InputTimeout}
		local before=#model:GetDescendants() vehicle:destroy() vehicle:destroy()
		local after=#model:GetDescendants()
		observations.cleanup={before=before,after=after,bound=model:GetAttribute("AXZFBound"),anchored=root.Anchored}
		local v2=Vehicle.new(model,overrides) v2:destroy() observations.rebind=true
		observations.pass=observations.settled.upright>.9 and math.abs(observations.settled.verticalSpeed)<5 and observations.accelerate.speed>10 and observations.accelerate.upright>.8 and observations.brake.speed<3 and observations.steer.degrees>5 and observations.steer.upright>.8 and observations.watchdog.expired and observations.cleanup.anchored and observations.rebind
	end,debug.traceback)
	if connection then connection:Disconnect() end
	if vehicle then vehicle:destroy() end
	model:Destroy() floor:Destroy()
	if not ok then observations.error=tostring(err) observations.pass=false end
	return observations
end
