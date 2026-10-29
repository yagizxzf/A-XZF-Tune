--!strict
-- Partial overrides; pass through Tune.resolve before use.
return table.freeze({
	Street=table.freeze({Drive="RWD"}),
	Touring=table.freeze({Drive="FWD",Grip=1.1,SteerDegrees=28,TorqueScale=3.2}),
	Rally=table.freeze({Drive="AWD",RestLength=2,FrequencyHz=3,Grip=1.35}),
	Drift=table.freeze({Drive="RWD",Grip=0.8,SteerDegrees=45,TorqueScale=5}),
})
