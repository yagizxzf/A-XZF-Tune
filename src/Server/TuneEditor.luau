--!strict
-- Edit-only documented Tune creation/upgrade. Never evaluates an existing ModuleScript.
local Tune=require(game.ReplicatedStorage.AXZF.Shared.Tune)
local Editor={}
local function literal(value): string
	if type(value)=="string" then return string.format("%q",value) end
	if type(value)=="table" then
		local entries={} for _,v in ipairs(value) do table.insert(entries,literal(v)) end
		return "{"..table.concat(entries,",").."}"
	end
	return tostring(value)
end
function Editor.install(model: Model,overrides: any): ModuleScript
	assert(not game:GetService("RunService"):IsRunning(),"Stop Play before editing Tune")
	assert(model:IsA("Model"),"Expected vehicle Model")
	local existing=model:FindFirstChild("Tune")
	assert(not existing or overrides~=nil,"Pass current AXZF overrides explicitly to preserve existing Tune values")
	local resolved=Tune.resolve(overrides)
	local editor=game:GetService("ScriptEditorService")
	local text=editor:GetEditorSource(game.ServerStorage.AXZFExamples.VehicleTune)
	for key,value in pairs(resolved) do
		if key~="Controls" then
			local count
			text,count=string.gsub(text,"(\n\t"..key.." = )([^\n]+)",function(prefix,old)
				return prefix..literal(value)..","..(string.match(old," %-%-.*$") or "")
			end,1)
			assert(count==1,"Template missing "..key)
		end
	end
	local controls={} for key,value in pairs(resolved.Controls) do table.insert(controls,"\t\t"..key.." = "..literal(value)..",") end table.sort(controls)
	text=string.gsub(text,"\n\tControls = {.-\n\t},","\n\tControls = {\n"..table.concat(controls,"\n").."\n\t},",1)
	local config=existing or Instance.new("ModuleScript")
	assert(config:IsA("ModuleScript"),"Tune path collision") config.Name="Tune" config.Parent=model
	editor:UpdateSourceAsync(config,function() return text end)
	return config
end
return Editor
