--!strict
return function(t)
	local T=require(game.ReplicatedStorage.AXZF.Shared.Tune) local e=t.expect
	-- Versioned configuration rejects typos instead of silently using defaults.
	t.test("default tune resolves",function() e.equal(T.resolve(nil).SchemaVersion,1) end)
	t.test("unknown field rejected",function() e.throws(function() T.resolve({Gripp=2}) end) end)
	t.test("unknown schema rejected",function() e.throws(function() T.resolve({SchemaVersion=2}) end) end)
	t.test("NaN grip rejected",function() e.throws(function() T.resolve({Grip=0/0}) end) end)
	t.test("negative radius rejected",function() e.throws(function() T.resolve({Radius=-1}) end) end)
	t.test("zero travel rejected",function() e.throws(function() T.resolve({RestLength=0}) end) end)
	t.test("invalid drive rejected",function() e.throws(function() T.resolve({Drive="4x4"}) end) end)
	t.test("RPM hysteresis required",function() e.throws(function() T.resolve({ShiftDownRPM=6500}) end) end)
	t.test("descending ratios required",function() e.throws(function() T.resolve({Gears={1,2}}) end) end)
	t.test("empty ratios rejected",function() e.throws(function() T.resolve({Gears={}}) end) end)
	t.test("curve abscissas strictly increase",function() e.throws(function() T.resolve({TorqueCurve={{1,2},{1,3}}}) end) end)
	t.test("curve requires finite torque",function() e.throws(function() T.resolve({TorqueCurve={{1,2},{2,math.huge}}}) end) end)
	t.test("resolved tune immutable",function() e.throws(function() T.resolve(nil).Grip=0 end) end)
	t.test("caller changes cannot mutate resolved gear ratios",function() local g={3,2,1} local v=T.resolve({Gears=g}) g[1]=9 e.equal(v.Gears[1],3) end)
	t.test("caller changes cannot mutate curve",function() local c={{800,10},{7000,20}} local v=T.resolve({TorqueCurve=c}) c[1][2]=99 e.equal(v.TorqueCurve[1][2],10) end)
end
