--!strict
-- Road-speed coupled cosmetic rotation. Engine RPM is reduced by gear/final drive.
local Motion={}
function Motion.angularVelocity(speed: number,radius: number,locked: boolean?): number
	-- Forward is local -Z. Rolling about local +X therefore has negative sign.
	return if locked then 0 else -speed/radius
end
function Motion.rpm(speed: number,radius: number): number
	return math.abs(Motion.angularVelocity(speed,radius))*60/(2*math.pi)
end
function Motion.advance(phase: number,speed: number,radius: number,dt: number,locked: boolean?): number
	return (phase+Motion.angularVelocity(speed,radius,locked)*math.max(0,dt))%(2*math.pi)
end
return table.freeze(Motion)
