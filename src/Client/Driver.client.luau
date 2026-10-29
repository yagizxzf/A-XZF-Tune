--!strict
local Players=game:GetService("Players")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Tags=game:GetService("CollectionService")
local player=Players.LocalPlayer
local packageRoot=game.ReplicatedStorage:WaitForChild("AXZF")
local remote=packageRoot:WaitForChild("Control") :: RemoteEvent
local active: Model?=nil
local state={Forward=0,Reverse=0,Left=0,Right=0,Brake=0}
local park=false local stick=0 local sequence=0 local elapsed=0
local characterConnections={} local lifetime={}
local nativeTouch: ScreenGui?=nil local nativeEnabled=true
local function hideNativeTouch()
	if not nativeTouch then
		local native=player.PlayerGui:FindFirstChild("TouchGui")
		if native and native:IsA("ScreenGui") then nativeTouch=native nativeEnabled=native.Enabled end
	end
	if nativeTouch then nativeTouch.Enabled=false end
end
local cockpit=nil
local defaults={Forward="W",Reverse="S",Left="A",Right="D",Brake="B",Handbrake="Space",Exit="E",HideControls="H"}
local gamepad={Forward=Enum.KeyCode.ButtonR2,Reverse=Enum.KeyCode.ButtonL2,Brake=Enum.KeyCode.ButtonB,Handbrake=Enum.KeyCode.ButtonA,Exit=Enum.KeyCode.ButtonY}
local function connect(signal,fn) table.insert(lifetime,signal:Connect(fn)) end
local function clear() for key in pairs(state) do state[key]=0 end stick=0 end
local function action(name,down,amount)
	if not active then return end
	if name=="Handbrake" then if down then park=not park end
	elseif name=="Exit" then if down then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.Sit=false end end
	elseif name=="HideControls" then if down and cockpit then cockpit:toggleHelp() end
	elseif state[name]~=nil then state[name]=if down then amount or 1 else 0 end
end
cockpit=require(packageRoot.UI.Cockpit).new(player,action)
local function send()
	if not active then return end sequence+=1
	if UIS:GetFocusedTextBox() then clear() state.Brake=1 end
	remote:FireServer(active,{seq=sequence,throttle=state.Forward-state.Reverse,steer=math.clamp(state.Right-state.Left+stick,-1,1),brake=state.Brake,handbrake=park})
end
local function unbind()
	for id in pairs(defaults) do CAS:UnbindAction("AXZF_"..id) end
	CAS:UnbindAction("AXZF_stick") clear() park=false
	if nativeTouch then nativeTouch.Enabled=nativeEnabled nativeTouch=nil end
end
local function setVehicle(model: Model?)
	if active==model then return end
	if active then clear() state.Brake=1 park=false send() end
	unbind() active=model sequence=0 cockpit:setVehicle(model)
	if not model then return end
	hideNativeTouch()
	for id,fallback in pairs(defaults) do
		local key=model:GetAttribute("AXZF_Key"..id) or fallback
		local keys={Enum.KeyCode[key]} if gamepad[id] then table.insert(keys,gamepad[id]) end
		CAS:BindActionAtPriority("AXZF_"..id,function(_,phase,input)
			if UIS:GetFocusedTextBox() then clear() return Enum.ContextActionResult.Pass end
			local began=phase==Enum.UserInputState.Begin
			local ended=phase==Enum.UserInputState.End or phase==Enum.UserInputState.Cancel
			if id=="Handbrake" or id=="Exit" or id=="HideControls" then if began then action(id,true) end
			elseif ended then action(id,false)
			elseif began or phase==Enum.UserInputState.Change then
				local analog=input.KeyCode==Enum.KeyCode.ButtonR2 or input.KeyCode==Enum.KeyCode.ButtonL2
				action(id,true,if analog then math.clamp(input.Position.Z,0,1) else 1)
			end
			return Enum.ContextActionResult.Sink
		end,false,3000,table.unpack(keys))
	end
	CAS:BindActionAtPriority("AXZF_stick",function(_,phase,input)
		stick=if phase==Enum.UserInputState.Cancel or phase==Enum.UserInputState.End then 0 else (if math.abs(input.Position.X)>.12 then input.Position.X else 0)
		return Enum.ContextActionResult.Sink
	end,false,3000,Enum.KeyCode.Thumbstick1)
end
local function hook(character)
	for _,c in ipairs(characterConnections) do c:Disconnect() end table.clear(characterConnections) setVehicle(nil)
	local humanoid=character:WaitForChild("Humanoid")
	local function refresh()
		local seat=humanoid.SeatPart local model=seat and seat.Parent
		setVehicle(if seat and seat.Name=="DriveSeat" and model and model:IsA("Model") and Tags:HasTag(model,"AXZFVehicle") then model else nil)
	end
	table.insert(characterConnections,humanoid.Seated:Connect(refresh))
	table.insert(characterConnections,humanoid.Died:Connect(function() setVehicle(nil) end)) refresh()
end
connect(player.CharacterAdded,hook) if player.Character then task.spawn(hook,player.Character) end
connect(UIS.WindowFocusReleased,function() clear() state.Brake=1 send() end)
connect(UIS.WindowFocused,clear)
connect(UIS.TextBoxFocused,function() clear() state.Brake=1 send() end)
connect(UIS.TextBoxFocusReleased,clear)
connect(RunService.Heartbeat,function(dt)
	elapsed+=dt if elapsed<1/20 then return end elapsed=0
	if active and not active:IsDescendantOf(workspace) then setVehicle(nil) end
	if active then hideNativeTouch() end
	send() cockpit:update()
end)
script.Destroying:Connect(function()
	setVehicle(nil) for _,c in ipairs(characterConnections) do c:Disconnect() end for _,c in ipairs(lifetime) do c:Disconnect() end cockpit:destroy()
end)
