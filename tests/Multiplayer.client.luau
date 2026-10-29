--!strict
if not game:GetService("RunService"):IsStudio() then return end
local packageRoot=game.ReplicatedStorage:WaitForChild("AXZF")
local remote=packageRoot:WaitForChild("__Prototype_AXZF_Multiplayer",8)
if not remote then return end
local normal=game.Players.LocalPlayer.PlayerScripts:WaitForChild("Driver",5)
if normal then normal.Enabled=false end
remote.OnClientEvent:Connect(function(id,model,kind,sequence)
	local control=packageRoot:WaitForChild("Control")
	for i=1,20 do
		control:FireServer(model,{seq=sequence+i,throttle=if kind=="invalid" then 2 else 1,steer=0,brake=0,handbrake=false}) task.wait(.05)
	end
	remote:FireServer(id)
end)
