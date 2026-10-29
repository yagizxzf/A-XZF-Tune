--!strict
local M = {}
function M.finite(value: any): boolean
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
function M.approach(current: number, target: number, rate: number, dt: number): number
	return target + (current - target) * math.exp(-rate * dt)
end
function M.curve(points: {{number}}, x: number): number
	if x <= points[1][1] then return points[1][2] end
	for i = 2, #points do
		local a, b = points[i-1], points[i]
		if x <= b[1] then return a[2] + (b[2]-a[2])*(x-a[1])/(b[1]-a[1]) end
	end
	return points[#points][2]
end
-- Returns longitudinal and lateral demand inside a friction circle.
function M.friction(longitudinal: number, lateral: number, capacity: number): (number, number)
	local magnitude = math.sqrt(longitudinal*longitudinal + lateral*lateral)
	local scale = if magnitude > capacity and magnitude > 0 then capacity/magnitude else 1
	return longitudinal*scale, lateral*scale
end
function M.spring(mass: number, gravity: number, frequency: number, damping: number, compression: number, velocity: number, maxLoad: number): number
	local omega = 2*math.pi*frequency
	return math.clamp(mass*omega*omega*compression - 2*damping*mass*omega*velocity, 0, mass*gravity*maxLoad)
end
function M.braking(speed: number, demand: number, mass: number, dt: number): number
	return -math.sign(speed)*math.min(demand, math.abs(speed)*mass/math.max(dt, 1e-4))
end
-- Positive command turns right; left is then the outer front wheel.
function M.ackermann(angle: number, wheelbase: number, track: number): (number, number)
	if math.abs(angle) < 1e-5 then return 0, 0 end
	local radius = wheelbase/math.tan(math.abs(angle))
	local inner = math.atan(wheelbase/math.max(0.1, radius-track/2))
	local outer = math.atan(wheelbase/(radius+track/2))
	if angle > 0 then return outer, inner end
	return -inner, -outer
end
return table.freeze(M)
