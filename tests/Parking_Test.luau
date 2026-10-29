--!strict
return function(t)
	local P=require(game.ReplicatedStorage.AXZF.Shared.Parking) local e=t.expect
	local G=require(game.ReplicatedStorage.AXZF.Shared.InputGuard)
	t.test("parking brakes while moving",function() e.equal(P.state(true,40,1.5),"Stopping") end)
	t.test("parking engages at low speed",function() e.equal(P.state(true,.2,1.5),"Parked") end)
	t.test("parking releases at any speed",function() e.equal(P.state(false,40,1.5),"Drive") end)
	t.test("parking rebrakes after external push",function() e.equal(P.state(true,4,1.5),"Stopping") end)
	t.test("optional park packet preserves old clients",function() e.truthy(G.validate({seq=1,throttle=0,steer=0,brake=0,handbrake=false},0)) end)
	t.test("park packet must be boolean",function() e.falsy(G.validate({seq=1,throttle=0,steer=0,brake=0,handbrake=false,park=1},0)) end)
end
