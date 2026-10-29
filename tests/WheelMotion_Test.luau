--!strict
return function(t)
	local M=require(game.ReplicatedStorage.AXZF.Shared.WheelMotion) local e=t.expect
	t.test("forward roll has correct negative X direction",function() e.near(M.angularVelocity(10,2),-5) end)
	t.test("reverse roll changes direction",function() e.near(M.angularVelocity(-10,2),5) end)
	t.test("double wheel radius halves angular speed",function() e.near(M.angularVelocity(20,2),M.angularVelocity(20,1)/2) end)
	t.test("stationary engine idle does not rotate wheels",function() e.near(M.advance(1,0,1,.5),1) end)
	t.test("locked handbrake wheel holds its phase",function() e.near(M.advance(1,30,1,.5,true),1) end)
	t.test("one circumference gives one complete revolution",function() e.near(M.advance(0,4*math.pi,2,1),0) end)
	t.test("phase integration is frame rate independent",function() local p=0 for _=1,60 do p=M.advance(p,12,1.5,1/60) end e.near(p,M.advance(0,12,1.5,1),1e-6) end)
	t.test("wheel rpm uses road speed rather than crankshaft rpm",function() e.near(M.rpm(2*math.pi*1.5,1.5),60) end)
	t.test("hitch does not use physics dt cap",function() e.near(M.advance(0,-4,2,.1),.2) end)
	t.test("inner and outer wheel speeds can differ",function() e.truthy(M.rpm(20,1)>M.rpm(15,1)) end)
end
