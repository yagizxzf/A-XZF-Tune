--!strict
-- The exported GUI owns the visuals. The controller binds device layout, input and telemetry.
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local BUTTON_MOTION = TweenInfo.new(.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HELP_MOTION = TweenInfo.new(.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local INTRO_MOTION = TweenInfo.new(.235, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local WHITE = Color3.fromRGB(247, 247, 247)
local KEY_NAMES = {
	Space = "Boşluk", Backspace = "Sil", Return = "Enter",
	LeftShift = "Sol Shift", RightShift = "Sağ Shift",
	LeftControl = "Sol Ctrl", RightControl = "Sağ Ctrl",
	LeftAlt = "Sol Alt", RightAlt = "Sağ Alt",
	Up = "Yukarı", Down = "Aşağı", Left = "Sol", Right = "Sağ",
}

local Cockpit = {}
Cockpit.__index = Cockpit

local function label(parent: Instance, name: string): TextLabel
	local node = parent:FindFirstChild(name, true)
	assert(node and node:IsA("TextLabel"), "Gösterge etiketi eksik: " .. name)
	node.TextScaled = true
	return node
end

local function meter(group)
	local body = group.Cockpit
	local ticks = {}
	for i = 0, 14 do
		table.insert(ticks, body["RPM" .. i])
	end
	return {
		group = group, ticks = ticks,
		speed = label(body, "Speed"), unit = label(body, "Unit"),
		gear = label(body, "Gear"), rpm = label(body, "RPMValue"),
		park = label(body, "ParkStatus"), handbrake = label(body, "HandbrakeStatus"),
	}
end

local function appearance(button)
	local face = button[button.Name .. "Face"]
	local scale = Instance.new("UIScale")
	scale.Name = "PressScale"
	scale.Parent = face
	local art = button:FindFirstChild(button.Name .. "Art")
	return {
		face = face, scale = scale, stroke = face:FindFirstChildWhichIsA("UIStroke"),
		color = face.BackgroundColor3, transparency = face.BackgroundTransparency,
		image = art and art:FindFirstChildWhichIsA("ImageLabel"),
		fallback = button:FindFirstChild(button.Name .. "Icon"),
	}
end

local function setPressed(button, pressed: boolean)
	if button.image and button.fallback then
		button.fallback.Visible = not button.image.IsLoaded
	end
	if button.pressed == pressed then return end
	button.pressed = pressed
	local color = if pressed then WHITE else button.color
	local transparency = if pressed then .77 else button.transparency
	local scale = if pressed then .94 else 1
	if button.scaleTween then button.scaleTween:Cancel() end
	if button.faceTween then button.faceTween:Cancel() end
	button.stroke.Transparency = if pressed then 0 else .61
	if GuiService.ReducedMotionEnabled then
		button.scale.Scale = 1
		button.face.BackgroundColor3 = color
		button.face.BackgroundTransparency = transparency
	else
		button.scaleTween = TweenService:Create(button.scale, BUTTON_MOTION, {Scale = scale})
		button.faceTween = TweenService:Create(button.face, BUTTON_MOTION, {
			BackgroundColor3 = color, BackgroundTransparency = transparency,
		})
		button.scaleTween:Play()
		button.faceTween:Play()
	end
end

local function rpmText(rpm: number): string
	local digits = tostring(math.floor(rpm / 50) * 50)
	if #digits > 3 then
		digits = string.sub(digits, 1, -4) .. "." .. string.sub(digits, -3)
	end
	return digits .. " dev/dk"
end

function Cockpit.new(player: Player, action: any): any
	local template = game.ReplicatedStorage.AXZF:WaitForChild("CockpitTemplate", 15)
	assert(template, "[A-XZF-Tune] Gösterge şablonu yok. UI paketini yükleyip aracı başlatın.")
	local gui = template:Clone()
	gui.Name = "AXZFCockpit"
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.Enabled = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local root = gui.Root
	root.Dim.Visible = false
	root.AnchorPoint = Vector2.zero
	root.Position = UDim2.fromOffset(0, 0)
	root.ClipsDescendants = true
	local helpScale = Instance.new("UIScale")
	helpScale.Name = "DeviceScale"
	helpScale.Parent = root.HUD.Controls
	local self = setmetatable({
		gui = gui, root = root, help = false, vehicle = nil,
		desktopMeter = meter(root.HUD.Dashboard),
		mobileMeter = meter(root.Mobile.DashboardMobile),
		desktopHelp = appearance(root.HUD.Toggle.ShowControls),
		helpScale = helpScale, mobile = UIS.TouchEnabled,
		touch = {}, pressed = {}, connections = {},
	}, Cockpit)

	local function connect(signal, handler)
		table.insert(self.connections, signal:Connect(handler))
	end
	local function wire(name, id, toggle)
		local button = root.Mobile:FindFirstChild(name, true)
		if not button or not button:IsA("TextButton") then return end
		self.touch[id] = appearance(button)
		if toggle then
			connect(button.Activated, function() action(id, true) end)
		else
			connect(button.InputBegan, function(input)
				local kind = input.UserInputType
				if kind == Enum.UserInputType.Touch or kind == Enum.UserInputType.MouseButton1 then
					self.pressed[input] = id
					action(id, true)
				end
			end)
		end
	end
	wire("Throttle", "Forward", false)
	wire("Reverse", "Reverse", false)
	wire("Brake", "Brake", false)
	wire("SteerLeft", "Left", false)
	wire("SteerRight", "Right", false)
	wire("Handbrake", "Handbrake", true)
	wire("Park", "Park", true)
	wire("Exit", "Exit", true)
	wire("ToggleControls", "HideControls", true)
	local images = {}
	for _, button in pairs(self.touch) do
		if button.image then table.insert(images, button.image) end
	end
	self.preload = task.spawn(function()
		pcall(function() game:GetService("ContentProvider"):PreloadAsync(images) end)
	end)

	-- Release also applies when a finger leaves its original button before lifting.
	connect(UIS.InputEnded, function(input)
		local released = {}
		for held, id in pairs(self.pressed) do
			if held == input or (input.UserInputType == Enum.UserInputType.MouseButton1
				and held.UserInputType == input.UserInputType) then
				self.pressed[held] = nil
				released[id] = true
			end
		end
		for _, id in pairs(self.pressed) do released[id] = nil end
		for id in pairs(released) do action(id, false) end
	end)
	connect(UIS.WindowFocusReleased, function() table.clear(self.pressed) end)
	connect(root.HUD.Toggle.ShowControls.Activated, function() action("HideControls", true) end)
	return self
end

function Cockpit:showHelp(visible: boolean, animate: boolean)
	self.help = visible
	local group = self.root.HUD.Controls
	local panel = group.ControlPanel
	if self.helpTween then self.helpTween:Cancel() end
	if not animate or GuiService.ReducedMotionEnabled then
		group.Visible = visible
		panel.Position = UDim2.fromOffset(0, 0)
		return
	end
	local resting = UDim2.fromOffset(0, 0)
	local shifted = UDim2.fromOffset(0, 8)
	if visible and not group.Visible then
		panel.Position = shifted
		group.Visible = true
	end
	local tween = TweenService:Create(panel, HELP_MOTION, {Position = if visible then resting else shifted})
	self.helpTween = tween
	tween.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed and not self.help then group.Visible = false end
	end)
	tween:Play()
end

function Cockpit:toggleHelp()
	if self.vehicle then self:showHelp(not self.help, true) end
end

function Cockpit:setVehicle(model: Model?)
	table.clear(self.pressed)
	if self.introTween then self.introTween:Cancel() end
	self.vehicle = model
	self.gui.Enabled = model ~= nil
	self.layoutViewport = nil
	self:showHelp(model ~= nil and model:GetAttribute("AXZF_ConfigShowControls") == true, false)
	if not model then return end

	local function key(action: string): string
		local value = model:GetAttribute("AXZF_Key" .. action) or action
		return KEY_NAMES[value] or value
	end
	local rows = {
		key("Forward") .. " / " .. key("Reverse"), key("Left") .. " / " .. key("Right"),
		key("Brake"), key("Handbrake"), key("Park"), key("Exit"), key("HideControls"),
	}
	for i, value in ipairs(rows) do
		label(self.root.HUD.Controls, "Key" .. (i - 1)).Text = value
	end
	label(self.root.HUD.Toggle, "ShowControlsLabel").Text = key("HideControls") .. " · Tuşlar"
	self:update()

	if not GuiService.ReducedMotionEnabled then
		local group = (if self.mobile then self.mobileMeter else self.desktopMeter).group
		local target = group.Position
		group.Position = target + UDim2.fromOffset(0, 13)
		self.introTween = TweenService:Create(group, INTRO_MOTION, {Position = target})
		self.introTween:Play()
	end
end

function Cockpit:layout(recovering: boolean)
	local viewport = self.gui.AbsoluteSize
	local mobile = UIS.TouchEnabled
	if self.layoutViewport == viewport and self.mobile == mobile and self.layoutRecovery == recovering then return end
	if self.introTween then self.introTween:Cancel() end
	self.layoutViewport, self.mobile, self.layoutRecovery = viewport, mobile, recovering

	local scale = if mobile then math.clamp(math.min(viewport.X / 840, viewport.Y / 430), 1, 1.1)
		else math.clamp(math.min(viewport.X / 1380, viewport.Y / 800), .72, 1)
	local width, height = viewport.X / scale, viewport.Y / scale
	local root = self.root
	root.FitScale.Scale = scale
	root.Size = UDim2.fromOffset(width, height)
	root.HUD.Dashboard.Visible = not mobile
	root.HUD.Toggle.Visible = not mobile
	root.Mobile.Visible = mobile

	local controls = root.HUD.Controls
	local recovery = root.Recovery.Recovery
	local dashboard = (if mobile then self.mobileMeter else self.desktopMeter).group
	dashboard.AnchorPoint = Vector2.new(.5, .5)
	dashboard.Position = UDim2.fromScale(if mobile then .5 else 1, 1)
	if not mobile then
		self.helpScale.Scale = 1
		controls.AnchorPoint = Vector2.new(0, 1)
		controls.Position = UDim2.new(0, 12, 1, -69)
		recovery.AnchorPoint = Vector2.new(.5, 0)
		recovery.Position = UDim2.new(.5, 0, 0, 8)
		return
	end

	local steering = root.Mobile.TouchLeft
	local pedals = root.Mobile.TouchPedals
	local handbrake = root.Mobile.TouchHandbrake
	local dialWidth = dashboard.Size.X.Offset
	local sideWidth = math.max(steering.Size.X.Offset, pedals.Size.X.Offset)
	local lift = if width < dialWidth + 2 * (sideWidth + 18) then dialWidth / 2 + 8 else 0
	steering.Position = UDim2.new(0, 12, 1, -12 - lift)
	pedals.Position = UDim2.new(1, -12, 1, -12 - lift)
	handbrake.Position = UDim2.new(1, -12, 1, -72 - lift)

	local helpTop = 59
	local utilityWidth = root.Mobile.TouchUtility.Size.X.Offset
	if width >= utilityWidth + recovery.Size.X.Offset + 36 then
		recovery.AnchorPoint = Vector2.new(1, 0)
		recovery.Position = UDim2.new(1, -12, 0, 8)
	else
		recovery.AnchorPoint = Vector2.new(.5, 0)
		recovery.Position = UDim2.new(.5, 0, 0, helpTop)
		if recovering then helpTop += recovery.Size.Y.Offset + 6 end
	end
	if width > height then
		local availableWidth = (width - dialWidth) / 2 - 18
		local availableHeight = height - steering.Size.Y.Offset - lift - helpTop - 18
		self.helpScale.Scale = math.clamp(math.min(availableWidth / controls.Size.X.Offset,
			availableHeight / controls.Size.Y.Offset), .55, 1)
		controls.AnchorPoint = Vector2.zero
		controls.Position = UDim2.fromOffset(12, helpTop)
	else
		self.helpScale.Scale = 1
		controls.AnchorPoint = Vector2.new(.5, 0)
		controls.Position = UDim2.new(.5, 0, 0, helpTop)
	end
end

function Cockpit:update()
	local model = self.vehicle
	if not model then return end
	local recovering = model:GetAttribute("AXZF_recovery") == "Waiting for space"
	self:layout(recovering)
	local current = if self.mobile then self.mobileMeter else self.desktopMeter
	local speed = (model:GetAttribute("AXZF_speed") or 0) * (model:GetAttribute("AXZF_ConfigSpeedScale") or 1)
	local rpm = model:GetAttribute("AXZF_rpm") or 0
	local redline = model:GetAttribute("AXZF_ConfigRedlineRPM") or 7000
	local gear = model:GetAttribute("AXZF_gear") or 1
	local parked = model:GetAttribute("AXZF_parkRequested") == true
	local handbrake = model:GetAttribute("AXZF_handbrake") == true
	local unit = model:GetAttribute("AXZF_ConfigSpeedUnit")
	current.speed.Text = tostring(math.floor(speed + .5))
	current.unit.Text = if unit == nil or unit == "STUD/S" then "stud/sn" else unit
	current.gear.Text = if parked then "P" elseif gear == -1 then "R" else tostring(gear)
	current.rpm.Text = rpmText(rpm)
	current.park.Text = if model:GetAttribute("AXZF_parkState") == "Stopping" then "Duruyor" else "Parkta"
	current.park.Visible = parked
	current.handbrake.Visible = handbrake
	self.root.Recovery.Visible = recovering

	if self.mobile then
		local held = {Park = parked, Handbrake = handbrake, HideControls = self.help}
		for _, id in pairs(self.pressed) do held[id] = true end
		for id, button in pairs(self.touch) do setPressed(button, held[id] == true) end
	else
		setPressed(self.desktopHelp, self.help)
	end
	local reduced = GuiService.ReducedMotionEnabled
	for i, tick in ipairs(current.ticks) do
		local opacity = if (i - 1) / (#current.ticks - 1) <= rpm / redline then 0 else .74
		tick.BackgroundColor3 = WHITE
		tick.BackgroundTransparency = if reduced then opacity
			else tick.BackgroundTransparency + (opacity - tick.BackgroundTransparency) * .38
	end
end

function Cockpit:destroy()
	if self.preload and coroutine.status(self.preload) ~= "dead" then task.cancel(self.preload) end
	if self.introTween then self.introTween:Cancel() end
	if self.helpTween then self.helpTween:Cancel() end
	for _, connection in ipairs(self.connections) do connection:Disconnect() end
	self.gui:Destroy()
end

return Cockpit
