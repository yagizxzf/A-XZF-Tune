--!strict
-- Editor-only fixture: no Toolbox code is required or executed.
return function(): any
	assert(game.RunService:IsStudio() and not game.RunService:IsRunning(),"Edit-mode test only")
	local migration=require(game.ServerScriptService.AXZFServer.Migration)
	local m=require(game.ServerStorage.AXZFExamples.PrototypeCar).create()
	local previous=m:FindFirstChild("Tune") if previous then previous:Destroy() end
	local legacy=Instance.new("ModuleScript") legacy.Name="A-Chassis Tune" legacy.Parent=m
	local foreign=Instance.new("Script") foreign.Name="LegacyPlugin" foreign.Disabled=true foreign.Parent=m.Body
	local constraint=Instance.new("WeldConstraint") constraint.Parent=m.Chassis
	local count=#m:GetDescendants() local converted=nil local report={}
	local ok,err=xpcall(function()
		converted=migration.convert(m)
		report.sourcePreserved=#m:GetDescendants()==count and foreign.Parent==m.Body and constraint.Parent==m.Chassis
		local scripts=0 for _,v in ipairs(converted:GetDescendants()) do if v:IsA("LuaSourceContainer") then scripts+=1 end end
		report.onlyAuthoredTune=scripts==1 and converted.Tune:IsA("ModuleScript")
		report.validRig=require(game.ServerScriptService.AXZFServer.Doctor).inspect(converted).ok
		m.Wheels.FL:Destroy() report.missingWheelRejected=not pcall(migration.convert,m)
		local wrapper=Instance.new("Model") m.Parent=wrapper local clone=m:Clone() clone.Parent=wrapper
		report.ambiguousSelectionRejected=not pcall(migration.convert,wrapper)
		m.Parent=nil wrapper:Destroy()
		report.pass=report.sourcePreserved and report.onlyAuthoredTune and report.validRig and report.missingWheelRejected and report.ambiguousSelectionRejected
	end,debug.traceback)
	if converted then converted:Destroy() end m:Destroy()
	if not ok then report.pass=false report.error=tostring(err) end
	return report
end
