--!strict
return function(t)
	local S=require(game.ReplicatedStorage.AXZF.Shared.Stability) local e=t.expect
	t.test("antiroll preserves total axle load",function() local l,r=S.axle(100,100,.2,100,.5,400) e.near(l+r,200) e.truthy(l>100 and r<100) end)
	t.test("antiroll cannot pull wheel into ground",function() local l,r=S.axle(100,5,100,100,2,400) e.near(l,105) e.near(r,0) end)
	t.test("antiroll cannot exceed load cap",function() local l,r=S.axle(390,200,100,100,2,400) e.near(l,400) e.near(r,190) end)
	t.test("negative transfer also stays bounded",function() local l,r=S.axle(5,390,-100,100,2,400) e.near(l,0) e.near(r,395) end)
	t.test("disabled antiroll preserves loads",function() local l,r=S.axle(60,100,4,100,0,400) e.near(l,60) e.near(r,100) end)
end
