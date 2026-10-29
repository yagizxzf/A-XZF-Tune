--!strict
local Math=require(script.Parent.Math)
local WheelMotion=require(script.Parent.WheelMotion)
local Powertrain={}
Powertrain.__index=Powertrain
function Powertrain.new(tune: any): any
	return setmetatable({tune=tune,gear=1,rpm=tune.IdleRPM,cooldown=0,direction=1},Powertrain)
end
function Powertrain:step(speed: number, throttle: number, dt: number): (number, number)
	local t=self.tune
	self.cooldown=math.max(0,self.cooldown-dt)
	local direction=if throttle<0 then -1 else 1
	if math.abs(throttle)>0.01 and speed*direction < -2 then return 0,math.abs(throttle) end
	if math.abs(throttle)>0.01 and direction~=self.direction then self.direction=direction self.gear=1 end
	local ratio=if self.direction<0 then t.ReverseRatio else t.Gears[self.gear]
	local wheelRPM=WheelMotion.rpm(speed,t.Radius)
	self.rpm=math.clamp(wheelRPM*ratio*t.FinalDrive,t.IdleRPM,t.RedlineRPM)
	if self.direction>0 and self.cooldown==0 then
		if self.rpm>t.ShiftUpRPM and self.gear<#t.Gears then self.gear+=1 self.cooldown=t.ShiftTime
		elseif self.rpm<t.ShiftDownRPM and self.gear>1 then self.gear-=1 self.cooldown=t.ShiftTime end
	end
	ratio=if self.direction<0 then t.ReverseRatio else t.Gears[self.gear]
	self.rpm=math.clamp(wheelRPM*ratio*t.FinalDrive,t.IdleRPM,t.RedlineRPM)
	local cut=if self.rpm>=t.RedlineRPM then 0 else 1
	local shift=if self.cooldown>0 then 0.35 else 1
	return self.direction*math.abs(throttle)*Math.curve(t.TorqueCurve,self.rpm)*t.TorqueScale*ratio*t.FinalDrive/t.Radius*cut*shift,0
end
return Powertrain
