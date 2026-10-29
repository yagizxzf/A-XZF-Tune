--!strict
return function(t)
	local Doctor=require(game.ServerScriptService.AXZFServer.Doctor)
	local Car=require(game.ServerStorage.AXZFExamples.PrototypeCar) local e=t.expect
	local function withCar(fn) local m=Car.create() local ok,err=pcall(fn,m) m:Destroy() if not ok then error(err) end end
	-- Doctor must explain structural errors before any binding mutation.
	t.test("part-built reference rig accepted",function() withCar(function(m) e.truthy(Doctor.inspect(m).ok) end) end)
	t.test("missing mount rejected",function() withCar(function(m) m.Chassis.FL:Destroy() e.falsy(Doctor.inspect(m).ok) end) end)
	t.test("old chassis script rejected",function() withCar(function(m) Instance.new("Script",m) e.falsy(Doctor.inspect(m).ok) end) end)
	t.test("old constraints rejected",function() withCar(function(m) Instance.new("WeldConstraint",m.Chassis) e.falsy(Doctor.inspect(m).ok) end) end)
	t.test("wheel without hub rejected",function() withCar(function(m) m.Wheels.FL.PrimaryPart=nil e.falsy(Doctor.inspect(m).ok) end) end)
	t.test("swapped left/right layout rejected",function() withCar(function(m) m.Chassis.FL.Position=m.Chassis.FR.Position e.falsy(Doctor.inspect(m).ok) end) end)
	t.test("inspection does not mutate anchored state",function() withCar(function(m) Doctor.inspect(m) e.truthy(m.Chassis.Anchored) end) end)
end
