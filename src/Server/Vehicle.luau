--!strict
local Shared=game:GetService("ReplicatedStorage").AXZF.Shared
local Math=require(Shared.Math)
local Tune=require(Shared.Tune)
local Powertrain=require(Shared.Powertrain)
local Rig=require(script.Parent.Rig)
local Suspension=require(Shared.Suspension)
local Recovery=require(script.Parent.Recovery)
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
	self.recovery=Recovery.new(rig,tune)
	self.originalPhysics=rig.root.CustomPhysicalProperties
	if tune.Mass>0 then
		local volume=rig.root.Size.X*rig.root.Size.Y*rig.root.Size.Z
		if tune.Mass/volume<.01 or tune.Mass/volume>100 then rig:destroy() error("Mass exceeds the density range for this Chassis size") end
		rig.root.CustomPhysicalProperties=PhysicalProperties.new(tune.Mass/volume,.3,0,100,100)
	end
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
	return {speed=self.rig.root.AssemblyLinearVelocity.Magnitude,rpm=self.powertrain.rpm,gear=if self.powertrain.direction<0 then -1 else self.powertrain.gear,sleeping=self.sleeping,stepMs=self.lastStepMs,handbrake=self.input.handbrake}
end
function Vehicle:step(rawDt: number)
	if self.destroyed or not self.rig.model:IsDescendantOf(workspace) then return end
	local started=os.clock()
	local dt=math.clamp(rawDt,0,1/30) if dt==0 then return end
	self.inputAge+=rawDt
	local input=if self.inputAge>self.tune.InputTimeout then neutral else self.input
	local rig,t=self.rig,self.tune
	local root=rig.root local cf=root.CFrame local velocity=root.AssemblyLinearVelocity
	if self.recovery:step(rawDt) then self:clearInput() return end
	if not rig.seat.Occupant and input==neutral and velocity.Magnitude<0.15 and root.AssemblyAngularVelocity.Magnitude<0.1 then self.idleTime+=dt else self.idleTime=0 end
	-- Keep spring support active: skipping all rays would remove gravity support.
	-- Sleep only reduces telemetry/visual work; physics contact solving stays correct.
	self.sleeping=self.idleTime>t.SleepAfter
	local up=cf.UpVector local speed=velocity:Dot(cf.LookVector)
	local force,reverseBrake=self.powertrain:step(speed,input.throttle,dt)
	force*=t.Power
	if speed*math.sign(force)>t.MaxSpeed then force=0 end
	local fade=math.max(t.MinSteerFraction,1-math.abs(speed)/t.SteerFadeSpeed)
	self.steer=Math.approach(self.steer,input.steer*math.rad(t.SteerDegrees)*fade,t.SteerResponse,dt)
	local left,right=Math.ackermann(self.steer,self.wheelbase,self.track)
	local assemblyMass=root.AssemblyMass local mass=assemblyMass/4
	local center=root.AssemblyCenterOfMass local angular=root.AssemblyAngularVelocity
	local contacts={}
	self.effectAge=(self.effectAge or 0)+rawDt
	local emitEffects=self.onEffect and t.VFX and t.VFXIntensity>0 and self.effectAge>1/6
	if emitEffects then self.effectAge=0 end
	-- Gather all contacts from one velocity snapshot before applying any impulse.
	for _,wheel in ipairs(rig.wheels) do
		local origin=wheel.mount.WorldPosition
		local hit=workspace:Raycast(origin,-up*(t.RestLength+t.Radius),self.params)
		wheel.length=t.RestLength wheel.load=0
		if hit and hit.Normal:Dot(up)>0.25 then
			local length=math.clamp(hit.Distance-t.Radius,0,t.RestLength)
			local normal=hit.Normal
			local groundVelocity=if hit.Instance:IsA("BasePart") then hit.Instance:GetVelocityAtPosition(hit.Position) else Vector3.zero
			local arm=hit.Position-center
			local pointVelocity=velocity+angular:Cross(arm)-groundVelocity
			wheel.length=length
			table.insert(contacts,{wheel=wheel,hit=hit,normal=normal,arm=arm,pointVelocity=pointVelocity,compression=t.RestLength-length,velocity=pointVelocity:Dot(normal),gravity=-workspace.Gravity*normal.Y,mobility={},angularResponse=root:TorqueToAngularAcceleration(arm:Cross(normal))})
		end
	end
	for _,a in ipairs(contacts) do
		for j,b in ipairs(contacts) do a.mobility[j]=a.normal:Dot(b.normal)/assemblyMass+a.normal:Dot(b.angularResponse:Cross(a.arm)) end
	end
	local loads=Suspension.solve(contacts,mass,workspace.Gravity,t.FrequencyHz,t.DampingRatio,t.MaxLoad,dt)
	local linearImpulse,angularImpulse=Vector3.zero,Vector3.zero
	for i,contact in ipairs(contacts) do
		local wheel=contact.wheel local hit=contact.hit local normal=contact.normal local pointVelocity=contact.pointVelocity
		local load=loads[i] wheel.load=load
		local angle=if wheel.id=="FL" then left elseif wheel.id=="FR" then right else 0
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
				if emitEffects and not front and math.abs(speed)>7 and load>mass*workspace.Gravity*.1 then
					local material=hit.Material
					local dusty=material==Enum.Material.Sand or material==Enum.Material.Grass or material==Enum.Material.Ground or material==Enum.Material.Mud
					local slip=math.abs(pointVelocity:Dot(side))
					if dusty or input.handbrake or slip>6 then
						local at=CFrame.lookAt(hit.Position+normal*.15,hit.Position+normal*.15+forward,normal)
						self.onEffect(if dusty then "AXZFSurfaceDust" else "AXZFTyreSmoke",at,math.clamp((slip+math.abs(speed)*.12)/12,.2,1)*t.VFXIntensity)
					end
				end
				local impulse=(normal*load+forward*longForce+side*sideForce)*dt
				linearImpulse+=impulse angularImpulse+=contact.arm:Cross(impulse)
			end
	end
	-- Persistent world-space actuators let the engine apply support at its own
	-- substeps. Per-frame impulse bursts caused visible gravity/velocity jitter.
	rig.force.Force=linearImpulse/dt-velocity*velocity.Magnitude*t.Drag
	rig.torque.Torque=angularImpulse/dt
	for _,wheel in ipairs(rig.wheels) do
		wheel.spin=(wheel.spin+speed/t.Radius*dt)%(2*math.pi)
		if not self.sleeping then
			local angle=if wheel.id=="FL" then left elseif wheel.id=="FR" then right else 0
			wheel.motor.C0=CFrame.new(wheel.mount.Position-Vector3.new(0,wheel.length,0))*CFrame.Angles(0,-angle,0)*CFrame.Angles(wheel.spin,0,0)*wheel.rotation
		end
	end
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
	if self.rig.root.Parent then self.rig.root.CustomPhysicalProperties=self.originalPhysics end
	for _,key in ipairs({"speed","rpm","gear","sleeping","stepMs","handbrake","recovery","recoveryCount"}) do self.rig.model:SetAttribute("AXZF_"..key,nil) end
end
return Vehicle
