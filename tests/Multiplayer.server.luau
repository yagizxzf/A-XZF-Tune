--!strict
-- Only runs under the explicit StudioTestService test invocation below.
local RunService=game:GetService("RunService")
if not RunService:IsStudio() then return end
local testService=game:GetService("StudioTestService")
local args=testService:GetTestArgs()
if type(args)~="table" or args.name~="AXZF" then return end
local packageRoot=game.ReplicatedStorage:WaitForChild("AXZF")
local remote=Instance.new("RemoteEvent") remote.Name="__Prototype_AXZF_Multiplayer" remote.Parent=packageRoot
packageRoot:SetAttribute("__MultiplayerTest",true)
local players=game:GetService("Players")
local tags=game:GetService("CollectionService")
local cars={} local replies={}
local connection=remote.OnServerEvent:Connect(function(player,id) replies[player]=id end)
local report={}
task.delay(45,function() testService:EndTest({pass=false,error="multiplayer watchdog timeout"}) end)
local ok,err=xpcall(function()
	local start=os.clock()
	while #players:GetPlayers()<2 and os.clock()-start<15 do task.wait(.1) end
	local list=players:GetPlayers() assert(#list==2,"Expected exactly two real test clients")
	packageRoot:WaitForChild("Control",10)
	local factory=require(game.ServerStorage.AXZFExamples.PrototypeCar)
	for i,player in ipairs(list) do
		local character=player.Character or player.CharacterAdded:Wait()
		local humanoid=character:WaitForChild("Humanoid")
		local m=factory.create(CFrame.new(if i==1 then -20 else 20,5,20),"__Prototype_AXZF_MP"..i)
		m.Parent=workspace tags:AddTag(m,"AXZFVehicle") table.insert(cars,m)
		task.wait(.2) m.DriveSeat:Sit(humanoid)
	end
	task.wait(2)
	report.twoOccupants=cars[1].DriveSeat.Occupant~=nil and cars[2].DriveSeat.Occupant~=nil
	report.serverOwnership=cars[1].Chassis:GetNetworkOwner()==nil and cars[2].Chassis:GetNetworkOwner()==nil
	local function request(player,id,target,kind,seq)
		replies[player]=nil remote:FireClient(player,id,target,kind,seq)
		local now=os.clock() while replies[player]~=id and os.clock()-now<5 do task.wait(.05) end
		assert(replies[player]==id,"Client did not complete "..id)
	end
	local z=cars[2].Chassis.Position.Z
	request(list[1],"cross-owner",cars[2],"valid",100)
	report.otherDriverRejected=math.abs(cars[2].Chassis.Position.Z-z)<1
	z=cars[1].Chassis.Position.Z
	request(list[1],"malformed",cars[1],"invalid",200)
	report.malformedRejected=math.abs(cars[1].Chassis.Position.Z-z)<1
	request(list[1],"valid",cars[1],"valid",300)
	report.ownDriverMoves=cars[1].Chassis.AssemblyLinearVelocity.Magnitude>10
	z=cars[1].Chassis.Position.Z
	request(list[1],"replay",cars[1],"valid",1)
	task.wait(2) report.replayStops=cars[1].Chassis.AssemblyLinearVelocity.Magnitude<3
	list[1].Character.Humanoid.Sit=false task.wait(.3)
	report.exitClearsSeat=cars[1].DriveSeat.Occupant==nil
	report.pass=true
	for _,key in ipairs({"twoOccupants","serverOwnership","otherDriverRejected","malformedRejected","ownDriverMoves","replayStops","exitClearsSeat"}) do if not report[key] then report.pass=false end end
end,debug.traceback)
connection:Disconnect() remote:Destroy() for _,m in ipairs(cars) do m:Destroy() end
if not ok then report.error=tostring(err) report.pass=false end
testService:EndTest(report)
