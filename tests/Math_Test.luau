--!strict
return function(t)
	local M=require(game.ReplicatedStorage.AXZF.Shared.Math) local e=t.expect
	-- Non-finite numbers must never enter forces or network commands.
	t.test("finite rejects NaN",function() e.falsy(M.finite(0/0)) end)
	t.test("finite rejects infinity",function() e.falsy(M.finite(math.huge)) end)
	t.test("finite rejects string",function() e.falsy(M.finite("1")) end)
	t.test("finite accepts zero",function() e.truthy(M.finite(0)) end)
	-- Interpolation is bounded at both ends and linear between authored points.
	t.test("curve interpolates midpoint",function() e.near(M.curve({{0,0},{10,20}},5),10) end)
	t.test("curve clamps below range",function() e.equal(M.curve({{0,3},{10,20}},-100),3) end)
	t.test("curve clamps above range",function() e.equal(M.curve({{0,3},{10,20}},100),20) end)
	-- Combined demand cannot exceed the contact traction budget.
	t.test("friction circle caps diagonal force",function() local x,y=M.friction(3,4,2) e.near(math.sqrt(x*x+y*y),2) end)
	t.test("unloaded tire supplies zero force",function() local x,y=M.friction(3,4,0) e.equal(x+y,0) end)
	t.test("friction retains sublimit demand",function() local x,y=M.friction(3,4,10) e.equal(x,3) e.equal(y,4) end)
	-- Suspension force is unilateral and static equilibrium supports corner weight.
	t.test("spring equilibrium supports weight",function() local w=2*math.pi*3.5 e.near(M.spring(10,196.2,3.5,.85,196.2/(w*w),0,4),1962) end)
	t.test("extended spring never pulls downward",function() e.equal(M.spring(10,196.2,3.5,.85,-1,0,4),0) end)
	t.test("spring force respects load cap",function() e.near(M.spring(10,196.2,3.5,.85,100,-100,4),7848) end)
	-- Braking must oppose velocity without crossing through rest in one step.
	t.test("braking cannot reverse velocity",function() local f=M.braking(1,10000,10,.1) e.near(1+f*.1/10,0) end)
	t.test("braking reverses sign in reverse",function() e.truthy(M.braking(-1,100,10,.1)>0) end)
	t.test("braking at rest is zero",function() e.equal(M.braking(0,100,10,.1),0) end)
	-- Steering geometry must tighten the inner wheel and mirror correctly.
	t.test("right inner wheel has greater angle",function() local l,r=M.ackermann(.3,6,5) e.truthy(r>l and l>0) end)
	t.test("Ackermann mirrors left and right",function() local l,r=M.ackermann(.3,6,5) local a,b=M.ackermann(-.3,6,5) e.near(a,-r) e.near(b,-l) end)
	t.test("straight wheels remain straight",function() local a,b=M.ackermann(0,6,5) e.equal(a+b,0) end)
	-- Exponential filtering is independent of frame subdivision.
	t.test("steering smoothing is dt consistent",function() e.near(M.approach(M.approach(0,1,7,.05),1,7,.05),M.approach(0,1,7,.1)) end)
end
