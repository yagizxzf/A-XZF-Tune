--!strict
return function(): any
	assert(game:GetService("RunService"):IsStudio(),"Studio only")
	local Fleet=require(game.ServerScriptService.AXZFServer.Fleet)
	local Car=require(game.ServerStorage.AXZFExamples.PrototypeCar)
	local tags=game:GetService("CollectionService")
	local fleet=Fleet.start({tag="__Prototype_AXZF_Fleet",remoteName="__Prototype_AXZF_Control"})
	local m=Car.create(CFrame.new(40,5,80)) m.DriveSeat.Disabled=true
	local report={} local ok,err=xpcall(function()
		tags:AddTag(m,"__Prototype_AXZF_Fleet") m.Parent=workspace task.wait(.1)
		report.preTaggedSpawn=fleet:get(m)~=nil
		fleet:add(m)
		local motors=0 for _,v in ipairs(m:GetDescendants()) do if v:IsA("Motor6D") then motors+=1 end end
		report.duplicateAddSafe=motors==4
		m.Parent=game.ServerStorage task.wait(.1) report.removalClean=fleet:get(m)==nil and not m:GetAttribute("AXZFBound")
		m.Parent=workspace task.wait(.1) report.returnRebind=fleet:get(m)~=nil
		tags:RemoveTag(m,"__Prototype_AXZF_Fleet") task.wait(.1) report.untagClean=fleet:get(m)==nil and m.Chassis.Anchored
		tags:AddTag(m,"__Prototype_AXZF_Fleet") task.wait(.1) report.retag=fleet:get(m)~=nil
		fleet:stop() fleet:stop() report.stopClean=not game.ReplicatedStorage.AXZF:FindFirstChild("__Prototype_AXZF_Control") and not m:GetAttribute("AXZFBound")
		report.pass=true for _,key in ipairs({"preTaggedSpawn","duplicateAddSafe","removalClean","returnRebind","untagClean","retag","stopClean"}) do if not report[key] then report.pass=false end end
	end,debug.traceback)
	fleet:stop() m:Destroy()
	if not ok then report.error=tostring(err) report.pass=false end
	return report
end
