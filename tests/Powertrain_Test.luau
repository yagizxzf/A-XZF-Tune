--!strict
return function(t)
	local Shared=game.ReplicatedStorage.AXZF.Shared local P=require(Shared.Powertrain) local T=require(Shared.Tune) local e=t.expect
	-- Forward/reverse requests must brake before reversing a moving vehicle.
	t.test("forward throttle produces forward force",function() local p=P.new(T.resolve(nil)) local f=p:step(0,1,.02) e.truthy(f>0) end)
	t.test("reverse from rest produces reverse force",function() local p=P.new(T.resolve(nil)) local f=p:step(0,-1,.02) e.truthy(f<0) end)
	t.test("reverse at forward speed brakes first",function() local p=P.new(T.resolve(nil)) local f,b=p:step(30,-1,.02) e.equal(f,0) e.equal(b,1) end)
	t.test("zero throttle supplies zero drive force",function() local p=P.new(T.resolve(nil)) local f=p:step(30,0,.02) e.equal(f,0) end)
	t.test("rev limiter cuts positive force",function() local p=P.new(T.resolve(nil)) p.gear=5 local f=p:step(1000,1,.02) e.equal(f,0) end)
	t.test("automatic gearbox upshifts at high RPM",function() local p=P.new(T.resolve(nil)) p:step(80,1,.02) e.equal(p.gear,2) end)
	t.test("automatic gearbox downshifts at low RPM",function() local p=P.new(T.resolve(nil)) p.gear=3 p:step(1,1,.02) e.equal(p.gear,2) end)
	t.test("shift cooldown prevents gear hunting",function() local p=P.new(T.resolve(nil)) p:step(80,1,.02) p:step(80,1,.02) e.equal(p.gear,2) end)
end
