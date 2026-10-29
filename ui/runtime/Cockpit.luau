--!strict
-- Runtime controller for the approved HTML-exported template; no visual construction here.
local UIS=game:GetService("UserInputService")
local Cockpit={}
Cockpit.__index=Cockpit
local function label(parent,name)
	local node=parent:FindFirstChild(name,true)
	return if node then (if node:IsA("TextLabel") then node else node:FindFirstChildWhichIsA("TextLabel",true)) else nil
end
local function set(parent,name,value)
	local text=label(parent,name)
	if text then text.Text=tostring(value) text.Size=UDim2.fromScale(1,1) text.Position=UDim2.fromOffset(0,0) text.TextScaled=true end
end
local function image(parent,name)
	local node=parent:FindFirstChild(name,true)
	return if node then (if node:IsA("ImageLabel") then node else node:FindFirstChildWhichIsA("ImageLabel",true)) else nil
end
local function physicalState(button,name,on)
	local art=image(button,name.."Art")
	if art then
		art.ImageColor3=if on then Color3.fromRGB(255,188,99) else Color3.new(1,1,1)
		local fallback=button:FindFirstChild(name.."Fallback",true)
		if fallback then fallback.Visible=not art.IsLoaded end
		button.BackgroundTransparency=if art.IsLoaded then 1 else .15
	end
	button.BackgroundColor3=if on then Color3.fromRGB(119,80,31) else Color3.fromRGB(32,46,54)
end
function Cockpit.new(player: Player,action: any): any
	local template=game.ReplicatedStorage.AXZF:WaitForChild("CockpitTemplate",15)
	assert(template,"[A-XZF-Tune] CockpitTemplate missing: start the default Fleet with the UI package installed")
	local gui=template:Clone() gui.Name="AXZFCockpit" gui.IgnoreGuiInset=false gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets
	gui.Enabled=false gui.Parent=player:WaitForChild("PlayerGui")
	local self=setmetatable({gui=gui,root=gui.Root,vehicle=nil,help=true,connections={},pressed={},mobile=UIS.TouchEnabled},Cockpit)
	self.root.Dim.Visible=false
	local dialScale=Instance.new("UIScale") dialScale.Name="DeviceScale" dialScale.Parent=self.root.Mobile.DashboardMobile
	self.dialScale=dialScale
	local images={}
	for _,node in ipairs(self.root.Mobile:GetDescendants()) do if node:IsA("ImageLabel") then table.insert(images,node) end end
	self.preload=task.spawn(function()
		local ok,err=pcall(function() game:GetService("ContentProvider"):PreloadAsync(images) end)
		if not ok and gui.Parent then warn("[A-XZF-Tune] Control images: "..tostring(err)) end
	end)
	local function wire(name,id,toggle)
		local button=gui.Root.Mobile:FindFirstChild(name,true)
		if not button or not button:IsA("TextButton") then return end
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
	set(self.root.HUD.Toggle,"ShowControlsLabel",key("HideControls").."  CONTROLS")
	self:update()
end
function Cockpit:layout()
	local viewport=self.gui.AbsoluteSize
	local mobile=UIS.TouchEnabled self.mobile=mobile
	local scale=math.clamp(math.min(viewport.X/1100,viewport.Y/700),if mobile then .65 else .65,1)
	self.root.FitScale.Scale=scale self.root.Size=UDim2.fromOffset(viewport.X/scale,viewport.Y/scale)
	self.root.AnchorPoint=Vector2.zero self.root.Position=UDim2.fromOffset(0,0)
	self.root.HUD.Dashboard.Visible=not mobile
	self.root.HUD.Controls.Visible=self.help
	self.root.HUD.Toggle.Visible=not mobile
	self.root.Mobile.Visible=mobile
	local dashboard=if mobile then self.root.Mobile.DashboardMobile else self.root.HUD.Dashboard
	dashboard.Position=if mobile then UDim2.new(.5,0,1,-12) else UDim2.new(1,-25,1,-12)
	self.root.HUD.Controls.Position=UDim2.new(0,25,1,-12)
	self.root.HUD.Toggle.Position=UDim2.new(0,25,1,if self.help then -332 else -12)
	if mobile then
		local portrait=viewport.Y>viewport.X
		dashboard.Position=if portrait then UDim2.new(.5,0,1,-330) else UDim2.new(.5,0,1,-12)
		self.dialScale.Scale=if self.help then .6 else .72
		self.root.HUD.Controls.Position=UDim2.new(.5,0,0,15) self.root.HUD.Controls.AnchorPoint=Vector2.new(.5,0)
		self.root.Mobile.TouchLeft.Position=UDim2.new(0,20,1,-20)
		self.root.Mobile.TouchLeft.Size=UDim2.fromOffset(310,200)
		self.root.Mobile.TouchPedals.Position=UDim2.new(1,-20,1,-20)
		self.root.Mobile.TouchPedals.Size=UDim2.fromOffset(360,285)
		self.root.Mobile.TouchHandbrake.Position=UDim2.new(1,-20,1,-330)
		self.root.Mobile.TouchHandbrake.Size=UDim2.fromOffset(180,180)
		self.root.Mobile.TouchUtility.Position=UDim2.fromOffset(20,105)
		self.root.Mobile.TouchUtility.Size=UDim2.fromOffset(200,172)
		-- Keep every actual touch hit area at least 48 screen pixels.
		for _,v in ipairs(self.root.Mobile:GetDescendants()) do if v:IsA("TextButton") then v.Size=UDim2.fromOffset(math.max(v.Size.X.Offset,74),math.max(v.Size.Y.Offset,74)) end end
	end
end
function Cockpit:update()
	if not self.vehicle then return end
	self:layout()
	local m=self.vehicle
	local dashboard=if self.mobile then self.root.Mobile.DashboardMobile else self.root.HUD.Dashboard
	local speed=(m:GetAttribute("AXZF_speed") or 0)*(m:GetAttribute("AXZF_ConfigSpeedScale") or 1)
	local rpm=m:GetAttribute("AXZF_rpm") or 0 local redline=m:GetAttribute("AXZF_ConfigRedlineRPM") or 7000
	set(dashboard,"Speed",string.format("%03d",math.floor(speed+.5)))
	set(dashboard,"Unit",m:GetAttribute("AXZF_ConfigSpeedUnit") or "STUD/S")
	local gear=m:GetAttribute("AXZF_gear") or 1
	local park=m:GetAttribute("AXZF_parkRequested")==true
	set(dashboard,"Gear",if park then "P" elseif gear==-1 then "R" else gear)
	set(dashboard,"RPM",string.format("%d RPM",math.floor(rpm/50)*50))
	set(dashboard,"ParkStatus",if park then (if m:GetAttribute("AXZF_parkState")=="Stopping" then "P · STOPPING" else "PARK ON") else "DRIVE")
	local handbrake=m:GetAttribute("AXZF_handbrake")==true set(dashboard,"HandbrakeStatus",if handbrake then "HB ON" else "HB OFF")
	local names={Forward="Throttle",Reverse="Reverse",Brake="Brake",Left="SteerLeft",Right="SteerRight"}
	local held={} for _,id in pairs(self.pressed) do held[id]=true end
	for id,name in pairs(names) do
		local button=self.root.Mobile:FindFirstChild(name,true)
		if button then physicalState(button,name,held[id]) end
	end
	for name,on in pairs({Park=park,Handbrake=handbrake,ToggleControls=self.help}) do
		local button=self.root.Mobile:FindFirstChild(name,true)
		if button then physicalState(button,name,on) end
	end
	for i=0,40 do
		local tick=dashboard:FindFirstChild("RPM"..i,true)
		if tick and tick:IsA("Frame") then tick.BackgroundColor3=if i/40<=rpm/redline then (if i>35 then Color3.fromRGB(255,120,106) else Color3.fromRGB(255,188,99)) else Color3.fromRGB(67,87,98) end
	end
	local recovery=m:GetAttribute("AXZF_recovery")
	self.root.Recovery.Visible=recovery=="Waiting for space"
	if recovery then set(self.root.Recovery,"RecoveryText",recovery) end
end
function Cockpit:destroy()
	if self.preload and coroutine.status(self.preload)~="dead" then task.cancel(self.preload) end
	for _,c in ipairs(self.connections) do c:Disconnect() end self.gui:Destroy()
end
return Cockpit
