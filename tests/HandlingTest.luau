--!strict
return function(): any
	assert(game:GetService("RunService"):IsStudio(),"Studio only")
	local Car=require(game.ServerStorage.AXZFExamples.PrototypeCar)
	local Vehicle=require(game.ServerScriptService.AXZFServer.Vehicle)
	local container=Instance.new("Folder") container.Name="__Prototype_AXZF_Handling" container.Parent=workspace
	local m=Car.create(CFrame.new(200,5,80)) m.DriveSeat.Disabled=true m.Parent=container
	local v=nil local connection=nil local result={}
	local ok,err=xpcall(function()
		v=Vehicle.new(m,nil)
		connection=game:GetService("RunService").PreSimulation:Connect(function(dt) v:step(dt) end)
		local root=m.Chassis
		local function command(seconds,throttle,brake,handbrake)
			local now=os.clock() repeat v:setInput({throttle=throttle,steer=0,brake=brake,handbrake=handbrake}) task.wait(.05) until os.clock()-now>=seconds
		end
		task.wait(2)
		-- No ground within ray range: throttle must not accelerate in X/Z.
		m:PivotTo(CFrame.new(200,100,80)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
		command(.3,1,0,false)
		local horizontal=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude
		result.airborne={horizontalSpeed=horizontal,pass=horizontal<.1}
		-- Repeat on a dedicated flat contact surface; reset pose/velocity for each friction level.
		local ground=Instance.new("Part") ground.Name="GripPlate" ground.Anchored=true ground.Size=Vector3.new(60,1,400) ground.CFrame=CFrame.new(200,1,-40) ground.Parent=container
		local function gripTrial(grip)
			ground:SetAttribute("Grip",grip) m:PivotTo(CFrame.new(200,6,100)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
			command(2,0,1,false) command(1,1,0,false)
			return root.AssemblyLinearVelocity.Magnitude
		end
		local normal=gripTrial(1) local ice=gripTrial(.15)
		result.surfaceGrip={normalSpeed=normal,lowGripSpeed=ice,pass=ice<normal*.6}
		ground:SetAttribute("Grip",1) command(3,0,0,true)
		result.handbrake={speed=root.AssemblyLinearVelocity.Magnitude,pass=root.AssemblyLinearVelocity.Magnitude<3}
		m:PivotTo(CFrame.new(200,6,100)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
		command(2,0,1,false) command(1,-.5,0,false)
		result.reverse={signedSpeed=root.AssemblyLinearVelocity:Dot(root.CFrame.LookVector),pass=root.AssemblyLinearVelocity:Dot(root.CFrame.LookVector)<-5}
		command(3,0,1,false)
		-- A moderate slope should remain finite/upright under gravity with brakes held.
		ground.CFrame=CFrame.new(200,1,-40)*CFrame.Angles(math.rad(8),0,0)
		m:PivotTo(CFrame.new(200,8,-40)*CFrame.Angles(math.rad(8),0,0)) root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
		command(3,0,1,false)
		result.slope={upright=root.CFrame.UpVector.Y,speed=root.AssemblyLinearVelocity.Magnitude,pass=root.CFrame.UpVector.Y>.85 and root.AssemblyLinearVelocity.Magnitude<5}
		result.pass=result.airborne.pass and result.surfaceGrip.pass and result.handbrake.pass and result.reverse.pass and result.slope.pass
	end,debug.traceback)
	if connection then connection:Disconnect() end if v then v:destroy() end container:Destroy()
	if not ok then result.pass=false result.error=tostring(err) end
	return result
end
