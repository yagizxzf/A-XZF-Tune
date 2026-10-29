--!strict
local Shared=game:GetService("ReplicatedStorage").AXZF.Shared
local Math=require(Shared.Math)
local Tune=require(Shared.Tune)
local Powertrain=require(Shared.Powertrain)
local Rig=require(script.Parent.Rig)
local Suspension=require(Shared.Suspension)
local Parking=require(Shared.Parking)
local Stability=require(Shared.Stability)
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
	self.parkRequested=tune.ParkOnSpawn
	rig.model:SetAttribute("AXZF_parkRequested",self.parkRequested)
	self.originalPhysics=rig.root.CustomPhysicalProperties
	if tune.Mass>0 then
		local volume=rig.root.Size.X*rig.root.Size.Y*rig.root.Size.Z
		if tune.Mass/volume<.01 or tune.Mass/volume>100 then rig:destroy() error("Mass exceeds the density range for this Chassis size") end
		rig.root.CustomPhysicalProperties=PhysicalProperties.new(tune.Mass/volume,.3,0,100,100)
	end
	self.params=params
	self.wheelbase=math.abs(rig.root.FL.Position.Z-rig.root.RL.Position.Z)
	self.track=math.abs(rig.root.FL.Position.X-rig.root.FR.Position.X)
	for _,wheel in ipairs(rig.wheels) do
		wheel.motor:SetAttribute("AXZF_Radius",tune.Radius)
		wheel.motor:SetAttribute("AXZF_RollAxis",wheel.rotation:VectorToObjectSpace(Vector3.xAxis))
		wheel.motor:SetAttribute("AXZF_ForwardAxis",wheel.rotation:VectorToObjectSpace(Vector3.new(0,0,-1)))
		wheel.motor:SetAttribute("AXZF_Rear",wheel.id=="RL" or wheel.id=="RR")
		game:GetService("CollectionService"):AddTag(wheel.motor,"AXZFWheelVisual")
	end
	return self
end
-- Server integration / NPC seam; callers must supply a validated intent table.
function Vehicle:setInput(packet: any)
	if packet.park~=nil then self:setPark(packet.park) end
	self.input={throttle=packet.throttle,steer=packet.steer,brake=packet.brake,handbrake=packet.handbrake}
	self.inputAge=0 self.idleTime=0 self.sleeping=false
end
function Vehicle:setPark(requested: boolean)
	assert(type(requested)=="boolean","park must be boolean")
	self.parkRequested=requested
	self.rig.model:SetAttribute("AXZF_parkRequested",requested)
end
function Vehicle:clearInput()
	self.input=neutral self.inputAge=0 self.idleTime=0 self.sleeping=false
end
function Vehicle:getTelemetry(): any
	local speed=self.rig.root.AssemblyLinearVelocity.Magnitude
	return {speed=speed,rpm=self.powertrain.rpm,gear=if self.powertrain.direction<0 then -1 else self.powertrain.gear,sleeping=self.sleeping,stepMs=self.lastStepMs,handbrake=self.handbrakeActive==true,parkRequested=self.parkRequested,parkState=Parking.state(self.parkRequested,speed,self.tune.ParkEngageSpeed)}
end
function Vehicle:step(rawDt: number)
	if self.destroyed or not self.rig.model:IsDescendantOf(workspace) then return end
	local started=os.clock()
	local dt=math.clamp(rawDt,0,1/30) if dt==0 then return end
	self.inputAge+=rawDt
	local input=if self.inputAge>self.tune.InputTimeout then neutral else self.input
	self.handbrakeActive=input.handbrake
	local rig,t=self.rig,self.tune
	local root=rig.root local cf=root.CFrame local velocity=root.AssemblyLinearVelocity
	if self.recovery:step(rawDt) then self:clearInput() return end
	if not rig.seat.Occupant and input==neutral and velocity.Magnitude<0.15 and root.AssemblyAngularVelocity.Magnitude<0.1 then self.idleTime+=dt else self.idleTime=0 end
	-- Keep spring support active: skipping all rays would remove gravity support.
	-- Sleep only reduces telemetry/visual work; physics contact solving stays correct.
	self.sleeping=self.idleTime>t.SleepAfter
	local up=cf.UpVector local speed=velocity:Dot(cf.LookVector)
	local force,reverseBrake=self.powertrain:step(speed,if self.parkRequested then 0 else input.throttle,dt)
	if self.parkRequested then force=0 end
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
	local byId={} for i,c in ipairs(contacts) do byId[c.wheel.id]=i end
	for _,axle in ipairs({{"FL","FR"},{"RL","RR"}}) do
		local l,r=byId[axle[1]],byId[axle[2]]
		if l and r then loads[l],loads[r]=Stability.axle(loads[l],loads[r],contacts[l].compression-contacts[r].compression,mass*(2*math.pi*t.FrequencyHz)^2,t.AntiRoll,mass*workspace.Gravity*t.MaxLoad) end
	end
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
				if self.parkRequested then brake=math.max(brake,t.ParkBrakeAcceleration) end
				if input.handbrake and not front then brake=math.max(brake,t.HandbrakeAcceleration) end
				local longitudinal=(if driven then force/(if t.Drive=="AWD" then 4 else 2) else 0)+Math.braking(longitudinalSpeed,brake*mass,mass,dt)
				longitudinal+=Math.braking(longitudinalSpeed,load*t.RollingResistance,mass,dt)
				local lateral=-pointVelocity:Dot(side)*mass*t.LateralResponse
				-- Static parking traction also balances downhill gravity. Velocity-only
				-- brakes otherwise need continual creep to produce their holding force.
				if self.parkRequested and pointVelocity.Magnitude<t.ParkEngageSpeed then
					longitudinal=math.clamp(longitudinal+forward.Y*mass*workspace.Gravity,-brake*mass,brake*mass)
					lateral+=side.Y*mass*workspace.Gravity
				end
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
				local support=normal*load*dt local tyre=(forward*longForce+side*sideForce)*dt
				-- Keep yaw leverage, reduce the tyre's vertical roll/pitch lever arm.
				local tyreArm=contact.arm-up*(contact.arm:Dot(up)*(1-t.RollInfluence))
				linearImpulse+=support+tyre
				angularImpulse+=contact.arm:Cross(support)+tyreArm:Cross(tyre)
			end
	end
	-- Persistent world-space actuators let the engine apply support at its own
	-- substeps. Per-frame impulse bursts caused visible gravity/velocity jitter.
	rig.force.Force=linearImpulse/dt-velocity*velocity.Magnitude*t.Drag
	rig.torque.Torque=angularImpulse/dt
	if #contacts>=2 and t.RollDamping>0 then
		local axis=cf.LookVector local inverseInertia=root:TorqueToAngularAcceleration(axis):Dot(axis)
		if inverseInertia>1e-8 then
			local acceleration=math.clamp(-angular:Dot(axis)*t.RollDamping,-50,50)
			rig.torque.Torque+=axis*(acceleration/inverseInertia)
		end
	end
	for _,wheel in ipairs(rig.wheels) do
		if not self.sleeping then
			local angle=if wheel.id=="FL" then left elseif wheel.id=="FR" then right else 0
			-- Server owns suspension/steering. Client Transform owns rolling spin.
			wheel.motor.C0=CFrame.new(wheel.mount.Position-Vector3.new(0,wheel.length,0))*CFrame.Angles(0,-angle,0)*wheel.rotation
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
	for _,key in ipairs({"speed","rpm","gear","sleeping","stepMs","handbrake","parkRequested","parkState","recovery","recoveryCount"}) do self.rig.model:SetAttribute("AXZF_"..key,nil) end
end
return Vehicle
