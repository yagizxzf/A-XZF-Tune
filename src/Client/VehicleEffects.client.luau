--!strict
local RunService=game:GetService("RunService")
local folder=game.ReplicatedStorage:WaitForChild("VFX")
local Emit=require(folder:WaitForChild("Emit"))
local remote=game.ReplicatedStorage:WaitForChild("AXZF"):WaitForChild("Effects")
local allowed={AXZFTyreSmoke=true,AXZFSurfaceDust=true}
local preload=task.spawn(function()
	local templates={}
	for name in pairs(allowed) do local t=folder:WaitForChild(name,10) if t then table.insert(templates,t) end end
	if #templates>0 then pcall(function() game:GetService("ContentProvider"):PreloadAsync(templates) end) end
end)
local handles={} local tokens=30 local elapsed=0
local event=remote.OnClientEvent:Connect(function(name,at,intensity)
	if not allowed[name] or typeof(at)~="CFrame" or type(intensity)~="number" then return end
	if tokens<1 or (workspace.CurrentCamera.CFrame.Position-at.Position).Magnitude>180 then return end
	local template=folder:FindFirstChild(name) if not template then return end tokens-=1
	local copy=template:Clone()
	for _,p in ipairs(copy:GetDescendants()) do
		if p:IsA("ParticleEmitter") then p:SetAttribute("EmitCount",math.max(1,math.floor((p:GetAttribute("EmitCount") or 1)*math.clamp(intensity,.1,2)))) end
	end
	local handle=Emit.play(copy,at) copy:Destroy() table.insert(handles,handle)
end)
local step=RunService.Heartbeat:Connect(function(dt)
	tokens=math.min(30,tokens+dt*30) elapsed+=dt
	if elapsed<.5 then return end elapsed=0
	for i=#handles,1,-1 do if handles[i].finished then table.remove(handles,i) end end
end)
script.Destroying:Connect(function() event:Disconnect() step:Disconnect() pcall(task.cancel,preload) for _,h in ipairs(handles) do h:stop() end end)
