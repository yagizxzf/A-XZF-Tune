--!strict
-- Server decides grounded slip; clients render. Never handles client requests.
local Players=game:GetService("Players")
local VFXService={}
VFXService.__index=VFXService
function VFXService.new(): any
	local folder=game.ReplicatedStorage.VFX
	local build=require(folder.Build)
	local recipes=game:GetService("HttpService"):JSONDecode(require(folder.VehicleRecipes))
	for name,steps in pairs(recipes) do
		local previous=folder:FindFirstChild(name) if previous then previous:Destroy() end
		local _,report=build.run("game.ReplicatedStorage.VFX."..name,steps)
		assert(string.find(report,"0 errors",1,true),report)
		folder[name]:SetAttribute("EffectDuration",1.2)
	end
	local remote=Instance.new("UnreliableRemoteEvent") remote.Name="Effects" remote.Parent=game.ReplicatedStorage.AXZF
	return setmetatable({remote=remote,sent=0},VFXService)
end
function VFXService:send(name: string,at: CFrame,intensity: number)
	for _,player in ipairs(Players:GetPlayers()) do
		local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if root and (root.Position-at.Position).Magnitude<180 then self.remote:FireClient(player,name,at,math.clamp(intensity,.1,2)) self.sent+=1 end
	end
end
function VFXService:destroy() self.remote:Destroy() end
return VFXService
