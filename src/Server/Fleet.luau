--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local Guard=require(game:GetService("ReplicatedStorage").AXZF.Shared.InputGuard)
local Vehicle=require(script.Parent.Vehicle)
local Fleet={}
Fleet.__index=Fleet
function Fleet.start(options: any): any
	assert(RunService:IsServer(),"Fleet runs on server")
	options=options or {}
	local tag=options.tag or "AXZFVehicle"
	local remoteName=options.remoteName or "Control"
	local packageRoot=game:GetService("ReplicatedStorage").AXZF
	assert(not packageRoot:FindFirstChild(remoteName),"Fleet already started")
	-- Prepare presentation for both Bootstrap and applications that start Fleet directly.
	local ui=packageRoot:FindFirstChild("UI")
	if remoteName=="Control" and ui and not packageRoot:FindFirstChild("CockpitTemplate") then
		require(ui.Builder).build()
		local template=game:GetService("StarterGui").AXZFCockpit
		template.Name="CockpitTemplate" template.Enabled=false template.Parent=packageRoot
	end
	local remote=Instance.new("RemoteEvent") remote.Name=remoteName remote.Parent=packageRoot
	local self=setmetatable({vehicles={},pending={},queued={},connections={},buckets={},remote=remote,stopped=false},Fleet)
	if remoteName=="Control" and packageRoot.Parent:FindFirstChild("VFX") then self.effects=require(script.Parent.VFXService).new() end
	local function connect(signal,fn) table.insert(self.connections,signal:Connect(fn)) end
	function self:remove(model)
		self.queued[model]=nil self.pending[model]=nil
		local entry=self.vehicles[model] if not entry then return end
		self.vehicles[model]=nil
		for _,c in ipairs(entry.connections) do c:Disconnect() end
		entry.vehicle:destroy()
	end
	function self:add(model)
		if self.stopped or self.vehicles[model] or self.pending[model] or not model:IsDescendantOf(workspace) then return end
		local token={} self.pending[model]=token
		local ok,vehicle=pcall(function()
			local config=model:FindFirstChild("Tune")
			local overrides=nil
			if config then assert(config:IsA("ModuleScript"),"Tune must be ModuleScript") overrides=require(config) end
			return Vehicle.new(model,overrides)
		end)
		local cancelled=self.pending[model]~=token
		if not cancelled then self.pending[model]=nil end
		if cancelled or self.stopped or not model:IsDescendantOf(workspace) then if ok then vehicle:destroy() end return end
		if not ok then model:SetAttribute("AXZFError",tostring(vehicle)) warn("[A-XZF-Tune] "..model.Name..": "..tostring(vehicle)) return end
		model:SetAttribute("AXZFError",nil)
		if self.effects then vehicle.onEffect=function(name,at,intensity) self.effects:send(name,at,intensity) end end
		for action,key in pairs(vehicle.tune.Controls) do model:SetAttribute("AXZF_Key"..action,key) end
		for _,key in ipairs({"SpeedUnit","SpeedScale","ShowControls","RedlineRPM","IdleRPM","VFX","VFXIntensity"}) do model:SetAttribute("AXZF_Config"..key,vehicle.tune[key]) end
		local entry={vehicle=vehicle,lastSequence=0,driver=nil,connections={}}
		self.vehicles[model]=entry
		local function occupantChanged()
			if entry.driver and not vehicle.rig.seat.Occupant and vehicle.tune.AutoParkOnExit then vehicle:setPark(true) end
			entry.lastSequence=0 entry.vehicle:clearInput()
			local humanoid=vehicle.rig.seat.Occupant
			entry.driver=if humanoid then Players:GetPlayerFromCharacter(humanoid.Parent) else nil
		end
		table.insert(entry.connections,vehicle.rig.seat:GetPropertyChangedSignal("Occupant"):Connect(occupantChanged))
		table.insert(entry.connections,model.AncestryChanged:Connect(function() if not model:IsDescendantOf(workspace) then self:remove(model) end end))
		occupantChanged()
	end
	connect(remote.OnServerEvent,function(player,model,packet)
		local now=os.clock() local bucket=self.buckets[player]
		if not bucket then bucket={tokens=45,time=now} self.buckets[player]=bucket end
		if not Guard.consume(bucket,now) then return end
		if typeof(model)~="Instance" then return end
		local entry=self.vehicles[model] if not entry or entry.driver~=player then return end
		local occupant=entry.vehicle.rig.seat.Occupant
		if not occupant or occupant.Health<=0 or occupant.Parent~=player.Character then return end
		if not Guard.validate(packet,entry.lastSequence) then return end
		entry.lastSequence=packet.seq entry.vehicle:setInput(packet)
	end)
	connect(Players.PlayerRemoving,function(player)
		self.buckets[player]=nil
		for _,entry in pairs(self.vehicles) do if entry.driver==player then entry.driver=nil entry.vehicle:clearInput() end end
	end)
	local function enqueue(model)
		if self.queued[model] or self.vehicles[model] then return end
		self.queued[model]=true
		task.defer(function()
			-- Parenting signals can fire before Roblox finishes rebuilding the assembly.
			RunService.Heartbeat:Wait()
			if self.queued[model] then self.queued[model]=nil self:add(model) end
		end)
	end
	connect(CollectionService:GetInstanceAddedSignal(tag),enqueue)
	connect(CollectionService:GetInstanceRemovedSignal(tag),function(model) self:remove(model) end)
	connect(workspace.DescendantAdded,function(v) if v:IsA("Model") and CollectionService:HasTag(v,tag) then enqueue(v) end end)
	connect(RunService.PreSimulation,function(dt)
		for model,entry in pairs(self.vehicles) do
			local ok,err=pcall(entry.vehicle.step,entry.vehicle,dt)
			if not ok then warn("[A-XZF-Tune] vehicle quarantined: "..tostring(err)) self:remove(model) model:SetAttribute("AXZFError",tostring(err)) end
		end
	end)
	for _,model in ipairs(CollectionService:GetTagged(tag)) do self:add(model) end
	return self
end
function Fleet:get(model: Model): any
	local entry=self.vehicles[model] return if entry then entry.vehicle else nil
end
function Fleet:stop()
	if self.stopped then return end self.stopped=true
	table.clear(self.queued) table.clear(self.pending)
	for _,c in ipairs(self.connections) do c:Disconnect() end
	local models={} for model in pairs(self.vehicles) do table.insert(models,model) end
	for _,model in ipairs(models) do self:remove(model) end
	self.remote:Destroy() table.clear(self.buckets)
	if self.effects then self.effects:destroy() end
end
return Fleet
