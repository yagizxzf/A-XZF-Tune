--!strict
-- Runtime controller for the approved HTML-exported template; no visual construction here.
local UIS=game:GetService("UserInputService")
local AMBER = Color3.fromRGB(255, 188, 99)
local IDLE_RIM = Color3.fromRGB(57, 74, 81)
local REDLINE_RIM = Color3.fromRGB(255, 120, 106)
local Cockpit={}
Cockpit.__index=Cockpit
local function set(parent,name,value)
	local text = parent:FindFirstChild(name, true)
	if text and text:IsA("TextLabel") then
		text.Text = tostring(value)
		text.TextScaled = true
	end
end
local function cacheAppearance(button)
	local face = button:FindFirstChild(button.Name .. "Face")
	local artFrame = button:FindFirstChild(button.Name .. "Art")
	local art = artFrame and artFrame:FindFirstChildWhichIsA("ImageLabel")
	local fallback = button:FindFirstChild(button.Name .. "Fallback", true)
	if fallback and fallback:IsA("TextLabel") then
		fallback.TextScaled = true
	end
	return {
		face = face,
		stroke = face and face:FindFirstChildWhichIsA("UIStroke"),
		restColor = face and face.BackgroundColor3,
		restTransparency = face and face.BackgroundTransparency,
		art = art,
		fallback = fallback,
	}
end
local function physicalState(appearance, on)
	local face, stroke, art = appearance.face, appearance.stroke, appearance.art
	if art and appearance.fallback then
		appearance.fallback.Visible = not art.IsLoaded
	end
	if appearance.on == on then return end
	appearance.on = on
	if face then
		face.BackgroundColor3 = if on then Color3.fromRGB(110, 75, 33) else appearance.restColor
		face.BackgroundTransparency = if on then .12 else appearance.restTransparency
	end
	if stroke then
		stroke.Color = if on then AMBER else Color3.fromRGB(163, 186, 192)
		stroke.Transparency = if on then 0 else .62
	end
end
function Cockpit.new(player: Player,action: any): any
	local template=game.ReplicatedStorage.AXZF:WaitForChild("CockpitTemplate",15)
	assert(template,"[A-XZF-Tune] CockpitTemplate missing: start the default Fleet with the UI package installed")
	local gui=template:Clone()
	gui.Name="AXZFCockpit"
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui")
	local self=setmetatable({
		gui=gui, root=gui.Root, vehicle=nil, help=true, connections={}, pressed={},
		mobile=UIS.TouchEnabled, touchAppearance={},
	},Cockpit)
	self.root.Dim.Visible=false
	self.root.AnchorPoint = Vector2.zero
	self.root.Position = UDim2.fromOffset(0, 0)
	local helpScale = Instance.new("UIScale")
	helpScale.Name = "DeviceScale"
	helpScale.Parent = self.root.HUD.Controls
	self.helpScale = helpScale
	local images={}
	for _,node in ipairs(self.root.Mobile:GetDescendants()) do if node:IsA("ImageLabel") then table.insert(images,node) end end
	self.preload=task.spawn(function()
		local ok,err=pcall(function() game:GetService("ContentProvider"):PreloadAsync(images) end)
		if not ok and gui.Parent then warn("[A-XZF-Tune] Control images: "..tostring(err)) end
	end)
	local function wire(name,id,toggle)
		local button=gui.Root.Mobile:FindFirstChild(name,true)
		if not button or not button:IsA("TextButton") then return end
		self.touchAppearance[id] = cacheAppearance(button)
		if toggle then table.insert(self.connections,button.Activated:Connect(function() action(id,true) end))
		else
			table.insert(self.connections,button.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then self.pressed[input]=id action(id,true) end end))
		end
	end
	wire("Throttle","Forward",false) wire("Reverse","Reverse",false) wire("Brake","Brake",false)
	wire("SteerLeft","Left",false) wire("SteerRight","Right",false)
	wire("Handbrake","Handbrake",true) wire("Park","Park",true) wire("Exit","Exit",true) wire("ToggleControls","HideControls",true)
	-- Global release also catches a finger/mouse dragged off its original button.
	table.insert(self.connections,UIS.InputEnded:Connect(function(input)
		local released={}
		for held,id in pairs(self.pressed) do
			if held==input or (input.UserInputType==Enum.UserInputType.MouseButton1 and held.UserInputType==input.UserInputType) then self.pressed[held]=nil released[id]=true end
		end
		for id in pairs(released) do local stillHeld=false for _,heldId in pairs(self.pressed) do if heldId==id then stillHeld=true end end if not stillHeld then action(id,false) end end
	end))
	table.insert(self.connections,self.root.HUD.Toggle.ShowControls.Activated:Connect(function() action("HideControls",true) end))
	return self
end
function Cockpit:toggleHelp() self.help=not self.help end
function Cockpit:setVehicle(model: Model?)
	table.clear(self.pressed)
	self.vehicle=model self.gui.Enabled=model~=nil
	-- Keyboard help is opt-in on touch screens; the physical controls stay visible.
	self.help=not UIS.TouchEnabled and (not model or model:GetAttribute("AXZF_ConfigShowControls")~=false)
	if not model then return end
	local function key(name) return model:GetAttribute("AXZF_Key"..name) or name end
	local rows={key("Forward").." / "..key("Reverse"),key("Left").." / "..key("Right"),key("Brake"),key("Handbrake"),key("Park"),key("Exit"),key("HideControls")}
	for i,value in ipairs(rows) do set(self.root.HUD.Controls,"Key"..(i-1),value) end
	set(self.root.HUD.Toggle,"ShowControlsLabel",key("HideControls").." · CONTROLS")
	self:update()
end
function Cockpit:layout(recovering)
	local viewport = self.gui.AbsoluteSize
	local mobile = UIS.TouchEnabled
	if self.mobile ~= mobile then
		self.mobile = mobile
		self.help = not mobile and self.vehicle:GetAttribute("AXZF_ConfigShowControls") ~= false
	end
	if self.layoutViewport == viewport and self.layoutMobile == mobile
		and self.layoutHelp == self.help and self.layoutRecovery == recovering then return end
	self.layoutViewport, self.layoutMobile = viewport, mobile
	self.layoutHelp, self.layoutRecovery = self.help, recovering

	local root = self.root
	-- The exported phone controls already have a minimum 48px hit area at 1x.
	local scale = if mobile then math.clamp(math.min(viewport.X / 840, viewport.Y / 430), 1, 1.16)
		else math.clamp(math.min(viewport.X / 1400, viewport.Y / 820), .72, 1)
	root.FitScale.Scale = scale
	root.Size = UDim2.fromOffset(viewport.X / scale, viewport.Y / scale)
	root.HUD.Dashboard.Visible = not mobile
	root.HUD.Controls.Visible = self.help
	root.HUD.Toggle.Visible = not mobile
	root.Mobile.Visible = mobile

	local controls = root.HUD.Controls
	local recovery = root.Recovery.Recovery
	if mobile then
		local dashboard = root.Mobile.DashboardMobile
		local pedals = root.Mobile.TouchPedals
		local sideWidth = math.max(root.Mobile.TouchLeft.Size.X.Offset, pedals.Size.X.Offset)
		local needsLift = viewport.X / scale < dashboard.Size.X.Offset + 2 * (sideWidth + 20)
		local lift = if needsLift then pedals.Size.Y.Offset + 8 else 0
		dashboard.Position = UDim2.new(.5, 0, 1, -12 - lift)
		local width = viewport.X / scale
		local utility = root.Mobile.TouchUtility.Size
		local helpTop = utility.Y.Offset + 14
		local recoveryFitsOnTop = width >= utility.X.Offset + recovery.Size.X.Offset + 36
		if recoveryFitsOnTop then
			recovery.AnchorPoint = Vector2.new(1, 0)
			recovery.Position = UDim2.new(1, -12, 0, 8)
		else
			recovery.AnchorPoint = Vector2.new(.5, 0)
			recovery.Position = UDim2.new(.5, 0, 0, helpTop)
			if recovering then helpTop += recovery.Size.Y.Offset + 6 end
		end
		if viewport.X > viewport.Y then
			-- Keep optional help on the steering side, above the two driving buttons.
			local availableWidth = (width - dashboard.Size.X.Offset) / 2 - 22
			local availableHeight = viewport.Y / scale - root.Mobile.TouchLeft.Size.Y.Offset - helpTop - 20
			self.helpScale.Scale = math.clamp(math.min(availableWidth / controls.Size.X.Offset,
				availableHeight / controls.Size.Y.Offset), .65, 1)
			controls.AnchorPoint = Vector2.zero
			controls.Position = UDim2.fromOffset(12, helpTop)
		else
			self.helpScale.Scale = 1
			controls.AnchorPoint = Vector2.new(.5, 0)
			controls.Position = UDim2.new(.5, 0, 0, helpTop)
		end
	else
		self.helpScale.Scale = 1
		controls.AnchorPoint = Vector2.new(0, 1)
		controls.Position = UDim2.new(0, 20, 1, -62)
		recovery.AnchorPoint = Vector2.new(.5, 0)
		recovery.Position = UDim2.new(.5, 0, 0, 8)
	end
end
function Cockpit:update()
	if not self.vehicle then return end
	local m=self.vehicle
	local recovery = m:GetAttribute("AXZF_recovery")
	local recovering = recovery == "Waiting for space"
	self:layout(recovering)
	local dashboard=if self.mobile then self.root.Mobile.DashboardMobile else self.root.HUD.Dashboard
	local speed=(m:GetAttribute("AXZF_speed") or 0)*(m:GetAttribute("AXZF_ConfigSpeedScale") or 1)
	local rpm=m:GetAttribute("AXZF_rpm") or 0 local redline=m:GetAttribute("AXZF_ConfigRedlineRPM") or 7000
	set(dashboard,"Speed",math.floor(speed+.5))
	set(dashboard,"Unit",m:GetAttribute("AXZF_ConfigSpeedUnit") or "STUD/S")
	local gear=m:GetAttribute("AXZF_gear") or 1
	local park=m:GetAttribute("AXZF_parkRequested")==true
	set(dashboard,"Gear",if park then "P" elseif gear==-1 then "R" else gear)
	set(dashboard, "RPM", math.floor(rpm / 50) * 50)
	set(dashboard, "ParkStatus", if m:GetAttribute("AXZF_parkState") == "Stopping" then "STOPPING" else "PARKED")
	dashboard.Cockpit.ParkStatusSlot.ParkStatus.Visible = park
	local handbrake = m:GetAttribute("AXZF_handbrake") == true
	dashboard.Cockpit.HandbrakeStatusSlot.HandbrakeStatus.Visible = handbrake

	if self.mobile then
		local held = {Park=park, Handbrake=handbrake, HideControls=self.help}
		for _, id in pairs(self.pressed) do held[id] = true end
		for id, appearance in pairs(self.touchAppearance) do
			physicalState(appearance, held[id] == true)
		end
	end
	for i=0,20 do
		local tick=dashboard:FindFirstChild("RPM"..i,true)
		if tick and tick:IsA("Frame") then
			tick.BackgroundColor3 = if i/20 <= rpm/redline then (if i >= 18 then REDLINE_RIM else AMBER) else IDLE_RIM
		end
	end
	self.root.Recovery.Visible = recovering
end
function Cockpit:destroy()
	if self.preload and coroutine.status(self.preload)~="dead" then task.cancel(self.preload) end
	for _,c in ipairs(self.connections) do c:Disconnect() end self.gui:Destroy()
end
return Cockpit
