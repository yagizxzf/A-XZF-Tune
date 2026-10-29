--!strict
return function(t)
	local G=require(game.ReplicatedStorage.AXZF.Shared.InputGuard) local e=t.expect
	local function p() return {seq=1,throttle=1,steer=-1,brake=0,handbrake=false} end
	-- Network payloads are finite, bounded, exact-shape intents with replay rejection.
	t.test("legal intent accepted",function() e.truthy(G.validate(p(),0)) end)
	t.test("replay rejected",function() e.falsy(G.validate(p(),1)) end)
	t.test("out of order rejected",function() e.falsy(G.validate(p(),2)) end)
	t.test("non-table rejected",function() e.falsy(G.validate("attack",0)) end)
	t.test("missing fields rejected",function() e.falsy(G.validate({seq=1},0)) end)
	t.test("extra authority fields rejected",function() local a=p() a.velocity=100 e.falsy(G.validate(a,0)) end)
	t.test("NaN input rejected",function() local a=p() a.throttle=0/0 e.falsy(G.validate(a,0)) end)
	t.test("infinite input rejected",function() local a=p() a.steer=math.huge e.falsy(G.validate(a,0)) end)
	t.test("negative brake rejected",function() local a=p() a.brake=-.1 e.falsy(G.validate(a,0)) end)
	t.test("overrange throttle rejected",function() local a=p() a.throttle=1.01 e.falsy(G.validate(a,0)) end)
	t.test("fractional sequence rejected",function() local a=p() a.seq=1.5 e.falsy(G.validate(a,0)) end)
	t.test("invalid boolean rejected",function() local a=p() a.handbrake=1 e.falsy(G.validate(a,0)) end)
	-- Token bucket uses injected time and caps stored burst credit.
	t.test("burst limited to 45 commands",function() local b={tokens=45,time=0} for _=1,45 do e.truthy(G.consume(b,0)) end e.falsy(G.consume(b,0)) end)
	t.test("bucket replenishes at 30 per second",function() local b={tokens=0,time=0} e.truthy(G.consume(b,1/30)) e.falsy(G.consume(b,1/30)) end)
	t.test("clock rollback grants no tokens",function() local b={tokens=0,time=5} e.falsy(G.consume(b,4)) end)
end
