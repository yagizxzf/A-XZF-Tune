--!strict
-- PostSimulation measurements after warm-up. No pass is inferred from one frame.
return function(source: Model,overrides: any): any
	assert(game:GetService("RunService"):IsStudio(),"Studio only")
	local m=source:Clone() game:GetService("CollectionService"):RemoveTag(m,"AXZFVehicle")
	m.Name="__Prototype_AXZF_Jitter" m.DriveSeat.Disabled=true m:PivotTo(CFrame.new(0,5,80)) m.Parent=workspace
	local v=nil local connection=nil local result={}
	local ok,err=xpcall(function()
		v=require(game.ServerScriptService.AXZFServer.Vehicle).new(m,overrides)
		connection=game:GetService("RunService").PreSimulation:Connect(function(dt) v:step(dt) end)
		task.wait(3)
		local minY,maxY,sumV,sumW=math.huge,-math.huge,0,0
		for _=1,180 do
			game:GetService("RunService").PostSimulation:Wait()
			local root=m.Chassis minY=math.min(minY,root.Position.Y) maxY=math.max(maxY,root.Position.Y)
			sumV+=root.AssemblyLinearVelocity.Y^2 sumW+=root.AssemblyAngularVelocity.Magnitude^2
		end
		result={samples=180,heightRange=maxY-minY,rmsVy=math.sqrt(sumV/180),rmsAngular=math.sqrt(sumW/180)}
		result.pass=result.heightRange<.02 and result.rmsVy<.1 and result.rmsAngular<.1
	end,debug.traceback)
	if connection then connection:Disconnect() end if v then v:destroy() end m:Destroy()
	if not ok then result.pass=false result.error=tostring(err) end
	return result
end
