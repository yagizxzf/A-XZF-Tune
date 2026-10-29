--!strict
local Shared=game:GetService("ReplicatedStorage").AXZF.Shared
local Math=require(Shared.Math)
local Tune=require(Shared.Tune)
local Powertrain=require(Shared.Powertrain)
local Rig=require(script.Parent.Rig)
local Vehicle={}
Vehicle.__index=Vehicle
local neutral=table.freeze({throttle=0,steer=0,brake=1,handbrake=false})
function Vehicle.new(model: Model, overrides: any): any
	local tune=Tune.resolve(overrides)
	assert(tune.RestLength>workspace.Gravity/(2*math.pi*tune.FrequencyHz)^2+0.1,"Suspension travel shorter than static sag; increase FrequencyHz or RestLength")
	local rig=Rig.bind(model)
	local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances={model} params.RespectCanCollide=true
	local self=setmetatable({rig=rig,tune=tune,powertrain=Powertrain.new(tune),input=neutral,inputAge=0,steer=0,telemetryAge=0,idleTime=0,destroyed=false,sleeping=false,lastStepMs=0},Vehicle)
	self.params=params
	self.wheelbase=math.abs(rig.root.FL.Position.Z-rig.root.RL.Position.Z)
	self.track=math.abs(rig.root.FL.Position.X-rig.root.FR.Position.X)
	return self
end
-- Server integration / NPC seam; callers must supply a validated intent table.
function Vehicle:setInput(packet: any)
	self.input={throttle=packet.throttle,steer=packet.steer,brake=packet.brake,handbrake=packet.handbrake}
	self.inputAge=0 self.idleTime=0 self.sleeping=false
end
function Vehicle:clearInput()
	self.input=neutral self.inputAge=0 self.idleTime=0 self.sleeping=false
end
function Vehicle:getTelemetry(): any
	return {speed=self.rig.root.AssemblyLinearVelocity.Magnitude,rpm=self.powertrain.rpm,gear=if self.powertrain.direction<0 then -1 else self.powertrain.gear,sleeping=self.sleeping,stepMs=self.lastStepMs}
end
function Vehicle:step(rawDt: number)
	if self.destroyed or not self.rig.model:IsDescendantOf(workspace) then return end
	local started=os.clock()
	local dt=math.clamp(rawDt,0,1/30) if dt==0 then return end
	self.inputAge+=rawDt
	local input=if self.inputAge>self.tune.InputTimeout then neutral else self.input
	local rig,t=self.rig,self.tune
	local root=rig.root local cf=root.CFrame local velocity=root.AssemblyLinearVelocity
	if not rig.seat.Occupant and input==neutral and velocity.Magnitude<0.15 and root.AssemblyAngularVelocity.Magnitude<0.1 then self.idleTime+=dt else self.idleTime=0 end
	-- Keep spring support active: skipping all rays would remove gravity support.
	-- Sleep only reduces telemetry/visual work; physics contact solving stays correct.
	self.sleeping=self.idleTime>t.SleepAfter
	local up=cf.UpVector local speed=velocity:Dot(cf.LookVector)
	local force,reverseBrake=self.powertrain:step(speed,input.throttle,dt)
	local fade=math.max(t.MinSteerFraction,1-math.abs(speed)/t.SteerFadeSpeed)
	self.steer=Math.approach(self.steer,input.steer*math.rad(t.SteerDegrees)*fade,t.SteerResponse,dt)
	local left,right=Math.ackermann(self.steer,self.wheelbase,self.track)
	local mass=root.AssemblyMass/4
	for _,wheel in ipairs(rig.wheels) do
		local origin=wheel.mount.WorldPosition
		local hit=workspace:Raycast(origin,-up*(t.RestLength+t.Radius),self.params)
		local length=t.RestLength local angle=if wheel.id=="FL" then left elseif wheel.id=="FR" then right else 0
		local load=0
		if hit and hit.Normal:Dot(up)>0.25 then
			length=math.clamp(hit.Distance-t.Radius,0,t.RestLength)
			local normal=hit.Normal
			local groundVelocity=if hit.Instance:IsA("BasePart") then hit.Instance:GetVelocityAtPosition(hit.Position) else Vector3.zero
			local pointVelocity=root:GetVelocityAtPosition(origin)-groundVelocity
			load=Math.spring(mass,workspace.Gravity,t.FrequencyHz,t.DampingRatio,t.RestLength-length,pointVelocity:Dot(normal),t.MaxLoad)
			local forward=(cf*CFrame.Angles(0,-angle,0)).LookVector
			forward=forward-normal*forward:Dot(normal)
			if forward.Magnitude>0.001 then
				forward=forward.Unit local side=forward:Cross(normal).Unit
				local longitudinalSpeed=pointVelocity:Dot(forward)
				local front=wheel.id=="FL" or wheel.id=="FR"
				local driven=t.Drive=="AWD" or (t.Drive=="FWD" and front) or (t.Drive=="RWD" and not front)
				local brake=math.max(input.brake,reverseBrake)*t.BrakeAcceleration
				if input.handbrake and not front then brake=math.max(brake,t.HandbrakeAcceleration) end
				local longitudinal=(if driven then force/(if t.Drive=="AWD" then 4 else 2) else 0)+Math.braking(longitudinalSpeed,brake*mass,mass,dt)
				longitudinal+=Math.braking(longitudinalSpeed,load*t.RollingResistance,mass,dt)
				local lateral=-pointVelocity:Dot(side)*mass*t.LateralResponse
				local surface=hit.Instance:GetAttribute("Grip")
				local grip=if Math.finite(surface) then math.clamp(surface,0.05,3) else 1
				local longForce,sideForce=Math.friction(longitudinal,lateral,load*t.Grip*grip)
				root:ApplyImpulseAtPosition((normal*load+forward*longForce+side*sideForce)*dt,hit.Position)
			end
		end
		wheel.load=load wheel.length=length wheel.spin=(wheel.spin+speed/t.Radius*dt)%(2*math.pi)
		if not self.sleeping then
			wheel.motor.C0=CFrame.new(wheel.mount.Position-Vector3.new(0,length,0))*CFrame.Angles(0,-angle,0)*CFrame.Angles(wheel.spin,0,0)*wheel.rotation
		end
	end
	root:ApplyImpulse(-velocity*velocity.Magnitude*t.Drag*dt)
	self.telemetryAge+=rawDt
	if self.telemetryAge>=1/t.TelemetryHz then
		self.telemetryAge=0
		local state=self:getTelemetry()
		for key,value in pairs(state) do rig.model:SetAttribute("AXZF_"..key,value) end
	end
	self.lastStepMs=(os.clock()-started)*1000
end
function Vehicle:destroy()
	if self.destroyed then return end self.destroyed=true self.rig:destroy()
	for _,key in ipairs({"speed","rpm","gear","sleeping","stepMs"}) do self.rig.model:SetAttribute("AXZF_"..key,nil) end
end
return Vehicle
