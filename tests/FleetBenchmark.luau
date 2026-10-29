--!strict
-- Script solve time only. This is not an engine/GPU/MicroProfiler or network benchmark.
return function(count: number?): any
	assert(game:GetService("RunService"):IsStudio(),"Studio only")
	count=math.clamp(count or 12,1,40)
	local Car=require(game.ServerStorage.AXZFExamples.PrototypeCar)
	local Vehicle=require(game.ServerScriptService.AXZFServer.Vehicle)
	local cars,vehicles,samples={},{},{}
	local connection=nil
	local ok,err=xpcall(function()
		for i=1,count do
			local m=Car.create(CFrame.new(-30+((i-1)%4)*20,5,100-math.floor((i-1)/4)*20),"__Prototype_AXZF_Benchmark")
			m.DriveSeat.Disabled=true m.Parent=workspace table.insert(cars,m) table.insert(vehicles,Vehicle.new(m,nil))
		end
		connection=game:GetService("RunService").PreSimulation:Connect(function(dt)
			local now=os.clock()
			for _,v in ipairs(vehicles) do v:step(dt) end
			table.insert(samples,(os.clock()-now)*1000)
		end)
		task.wait(5)
	end,debug.traceback)
	if connection then connection:Disconnect() end
	for _,v in ipairs(vehicles) do v:destroy() end for _,m in ipairs(cars) do m:Destroy() end
	if not ok then return {pass=false,error=tostring(err)} end
	table.sort(samples) local total=0 for _,v in ipairs(samples) do total+=v end
	return {pass=true,vehicles=count,samples=#samples,meanMs=total/#samples,p95Ms=samples[math.ceil(#samples*.95)],maxMs=samples[#samples],raysPerStep=count*4,scope="script solve only; includes settled + initial drop",cleanup=true}
end
