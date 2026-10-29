--!strict
local packageRoot=game:GetService("ReplicatedStorage").AXZF
local ui=packageRoot:FindFirstChild("UI")
if ui then
	require(ui.Builder).build()
	local template=game:GetService("StarterGui").AXZFCockpit
	template.Name="CockpitTemplate" template.Enabled=false template.Parent=packageRoot
end
local fleet=require(script.Parent.Fleet).start()
game:BindToClose(function() fleet:stop() end)
