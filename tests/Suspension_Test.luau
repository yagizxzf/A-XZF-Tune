--!strict
return function(t)
	local S=require(game.ReplicatedStorage.AXZF.Shared.Suspension) local e=t.expect
	-- Implicit integration must retain the physical static equilibrium.
	t.test("implicit spring supports its static weight",function()
		local w=2*math.pi*3.5
		local result=S.solve({{compression=196.2/(w*w),velocity=0,gravity=-196.2,mobility={.1}}},10,196.2,3.5,.85,4,1/60)
		e.near(result[1],1962,1e-5)
	end)
	-- No contact means no normal force, including while airborne.
	t.test("no contacts produces no suspension forces",function() e.equal(#S.solve({},10,196.2,3.5,.85,4,1/60),0) end)
	-- A tire cannot pull the ground toward the chassis.
	t.test("implicit solver never creates tensile load",function()
		local r=S.solve({{compression=-5,velocity=10,gravity=-196.2,mobility={.1}}},10,196.2,3.5,.85,4,1/60)
		e.equal(r[1],0)
	end)
	-- Permuting contact order must preserve the coupled solution.
	t.test("contact ordering does not change settled loads",function()
		local a={compression=.2,velocity=.1,gravity=-196.2,mobility={.1,.02}}
		local b={compression=.4,velocity=-.2,gravity=-196.2,mobility={.02,.1}}
		local x=S.solve({a,b},10,196.2,3.5,.85,4,1/60)
		local y=S.solve({{compression=.4,velocity=-.2,gravity=-196.2,mobility={.1,.02}},{compression=.2,velocity=.1,gravity=-196.2,mobility={.02,.1}}},10,196.2,3.5,.85,4,1/60)
		e.near(x[1],y[2],1e-4) e.near(x[2],y[1],1e-4)
	end)
end
