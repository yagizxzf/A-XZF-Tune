--!strict
-- Native ContextActionService touch buttons; no dependency on a particular HUD.
local Players=game:GetService("Players")
local CAS=game:GetService("ContextActionService")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local player=Players.LocalPlayer
local packageRoot=game:GetService("ReplicatedStorage"):WaitForChild("AXZF")
local remote=packageRoot:WaitForChild("Control") :: RemoteEvent
local active: Model?=nil
local sequence=0 local elapsed=0
local state={forward=0,reverse=0,left=0,right=0,brake=0,handbrake=0}
local connections={}
local lifetime={}
local function connect(signal,fn) table.insert(lifetime,signal:Connect(fn)) end
local actions={"forward","reverse","left","right","brake","handbrake","exit"}
local bindings={
	forward={Enum.KeyCode.W,Enum.KeyCode.Up,Enum.KeyCode.ButtonR2},
	reverse={Enum.KeyCode.S,Enum.KeyCode.Down,Enum.KeyCode.ButtonL2},
	left={Enum.KeyCode.A,Enum.KeyCode.Left},right={Enum.KeyCode.D,Enum.KeyCode.Right},
	brake={Enum.KeyCode.B,Enum.KeyCode.ButtonB},handbrake={Enum.KeyCode.Space,Enum.KeyCode.ButtonA},
	exit={Enum.KeyCode.E,Enum.KeyCode.ButtonY},
}
local stick=0
local touchGui: ScreenGui?=nil
local defaultTouch: ScreenGui?=nil
local defaultTouchEnabled=true
local function clear() for key in pairs(state) do state[key]=0 end stick=0 end
local function unbind()
	for _,id in ipairs(actions) do CAS:UnbindAction("AXZF_"..id) end
	CAS:UnbindAction("AXZF_stick") clear()
	if touchGui then touchGui:Destroy() touchGui=nil end
	if defaultTouch then defaultTouch.Enabled=defaultTouchEnabled defaultTouch=nil end
end
local function send()
	if not active then return end sequence+=1
	if UIS:GetFocusedTextBox() then clear() state.brake=1 end
	remote:FireServer(active,{seq=sequence,throttle=state.forward-state.reverse,steer=math.clamp(state.right-state.left+stick,-1,1),brake=state.brake,handbrake=state.handbrake>0})
end
local function setVehicle(model: Model?)
	if active==model then return end
	if active then clear() state.brake=1 send() end
	unbind() active=model sequence=0
	if not active then return end
	local touchFrame=nil
	if UIS.TouchEnabled then
		local native=player:WaitForChild("PlayerGui"):FindFirstChild("TouchGui")
		if native and native:IsA("ScreenGui") then defaultTouch=native defaultTouchEnabled=native.Enabled native.Enabled=false end
		touchGui=Instance.new("ScreenGui") touchGui.Name="AXZFControls" touchGui.ResetOnSpawn=false
		touchGui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets touchGui.Parent=player:WaitForChild("PlayerGui")
		touchFrame=Instance.new("Frame") touchFrame.Name="Controls" touchFrame.Size=UDim2.fromScale(1,1) touchFrame.BackgroundTransparency=1 touchFrame.Parent=touchGui
	end
	for i,id in ipairs(actions) do
		CAS:BindActionAtPriority("AXZF_"..id,function(_,phase,input)
			if UIS:GetFocusedTextBox() then clear() return Enum.ContextActionResult.Pass end
			if id=="exit" then
				if phase==Enum.UserInputState.Begin then local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid") if h then h.Sit=false end end
				return Enum.ContextActionResult.Sink
			end
			if phase==Enum.UserInputState.End or phase==Enum.UserInputState.Cancel then state[id]=0
			elseif input.KeyCode==Enum.KeyCode.ButtonR2 or input.KeyCode==Enum.KeyCode.ButtonL2 then state[id]=math.clamp(input.Position.Z,0,1)
			elseif phase==Enum.UserInputState.Begin then state[id]=1 end
			return Enum.ContextActionResult.Sink
		end,true,3000,table.unpack(bindings[id]))
		CAS:SetTitle("AXZF_"..id,({forward="GO",reverse="REV",left="LEFT",right="RIGHT",brake="BRAKE",handbrake="PARK",exit="EXIT"})[id])
		local position=({forward=UDim2.new(1,-90,1,-240),reverse=UDim2.new(1,-90,1,-165),left=UDim2.new(0,20,1,-165),right=UDim2.new(0,95,1,-165),brake=UDim2.new(1,-165,1,-165),handbrake=UDim2.new(0,20,1,-240),exit=UDim2.new(1,-165,1,-240)})[id]
		CAS:SetPosition("AXZF_"..id,position)
		local button=CAS:GetButton("AXZF_"..id)
		if button and touchFrame then button.Parent=touchFrame button.Position=position button.Size=UDim2.fromOffset(64,64) end
	end
	CAS:BindActionAtPriority("AXZF_stick",function(_,phase,input)
		stick=if phase==Enum.UserInputState.Cancel or phase==Enum.UserInputState.End then 0 else (if math.abs(input.Position.X)>0.12 then input.Position.X else 0)
		return Enum.ContextActionResult.Sink
	end,false,3000,Enum.KeyCode.Thumbstick1)
end
local function hook(character: Model)
	for _,c in ipairs(connections) do c:Disconnect() end table.clear(connections) setVehicle(nil)
	local humanoid=character:WaitForChild("Humanoid") :: Humanoid
	local function refresh()
		local seat=humanoid.SeatPart local model=seat and seat.Parent
		setVehicle(if seat and seat.Name=="DriveSeat" and model and model:IsA("Model") and CollectionService:HasTag(model,"AXZFVehicle") then model else nil)
	end
	table.insert(connections,humanoid.Seated:Connect(refresh))
	table.insert(connections,humanoid.Died:Connect(function() setVehicle(nil) end)) refresh()
end
connect(player.CharacterAdded,hook)
if player.Character then task.spawn(hook,player.Character) end
connect(UIS.WindowFocusReleased,function() clear() state.brake=1 send() end)
connect(UIS.WindowFocused,function() clear() end)
connect(UIS.TextBoxFocused,function() clear() state.brake=1 send() end)
connect(UIS.TextBoxFocusReleased,function() clear() end)
connect(RunService.Heartbeat,function(dt)
	elapsed+=dt if elapsed<1/20 then return end elapsed=0
	if active and not active:IsDescendantOf(workspace) then setVehicle(nil) end
	send()
end)
script.Destroying:Connect(function() setVehicle(nil) for _,c in ipairs(connections) do c:Disconnect() end for _,c in ipairs(lifetime) do c:Disconnect() end end)
