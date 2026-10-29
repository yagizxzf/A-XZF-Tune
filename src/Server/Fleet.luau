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
	local remote=Instance.new("RemoteEvent") remote.Name=remoteName remote.Parent=packageRoot
	local self=setmetatable({vehicles={},connections={},buckets={},remote=remote,stopped=false},Fleet)
	local function connect(signal,fn) table.insert(self.connections,signal:Connect(fn)) end
	function self:remove(model)
		local entry=self.vehicles[model] if not entry then return end
		self.vehicles[model]=nil
		for _,c in ipairs(entry.connections) do c:Disconnect() end
		entry.vehicle:destroy()
	end
	function self:add(model)
		if self.vehicles[model] or not model:IsDescendantOf(workspace) then return end
		local ok,vehicle=pcall(function()
			local config=model:FindFirstChild("Tune")
			local overrides=nil
			if config then assert(config:IsA("ModuleScript"),"Tune must be ModuleScript") overrides=require(config) end
			return Vehicle.new(model,overrides)
		end)
		if not ok then model:SetAttribute("AXZFError",tostring(vehicle)) warn("[A-XZF-Tune] "..model.Name..": "..tostring(vehicle)) return end
		model:SetAttribute("AXZFError",nil)
		local entry={vehicle=vehicle,lastSequence=0,driver=nil,connections={}}
		self.vehicles[model]=entry
		local function occupantChanged()
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
	connect(CollectionService:GetInstanceAddedSignal(tag),function(model) self:add(model) end)
	connect(CollectionService:GetInstanceRemovedSignal(tag),function(model) self:remove(model) end)
	connect(workspace.DescendantAdded,function(v) if v:IsA("Model") and CollectionService:HasTag(v,tag) then self:add(v) end end)
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
	for _,c in ipairs(self.connections) do c:Disconnect() end
	local models={} for model in pairs(self.vehicles) do table.insert(models,model) end
	for _,model in ipairs(models) do self:remove(model) end
	self.remote:Destroy() table.clear(self.buckets)
end
return Fleet
