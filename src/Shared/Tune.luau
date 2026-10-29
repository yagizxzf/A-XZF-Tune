--!strict
-- All fields use Roblox mass/stud/second units. No kg conversion is implied.
local Math = require(script.Parent.Math)
local Tune = {}
local defaults = {
	SchemaVersion=1, Drive="RWD", Radius=1.25, RestLength=1.6,
	FrequencyHz=3.5, DampingRatio=0.85, MaxLoad=4,
	Grip=1.2, LateralResponse=12, BrakeAcceleration=90, HandbrakeAcceleration=110,
	RollingResistance=0.015, Drag=0.025, SteerDegrees=32, SteerResponse=7,
	SteerFadeSpeed=100, MinSteerFraction=0.28,
	IdleRPM=850, RedlineRPM=7000, ShiftUpRPM=6100, ShiftDownRPM=2100,
	ShiftTime=0.3, FinalDrive=3.7, ReverseRatio=3.1,
	Gears={3.2,2.1,1.5,1.12,0.88}, TorqueCurve={{850,95},{2500,150},{4500,175},{7000,110}},
	TorqueScale=4, InputTimeout=0.35, TelemetryHz=10, SleepAfter=3,
}
local ranges = {
	Radius={0.1,10}, RestLength={0.1,10}, FrequencyHz={1,12}, DampingRatio={0.1,3},
	MaxLoad={1,10}, Grip={0.05,3}, LateralResponse={0.1,40}, BrakeAcceleration={1,500},
	HandbrakeAcceleration={1,500}, RollingResistance={0,0.2}, Drag={0,2},
	SteerDegrees={1,60}, SteerResponse={0.1,30}, SteerFadeSpeed={1,500}, MinSteerFraction={0.05,1},
	IdleRPM={100,5000}, RedlineRPM={1000,20000}, ShiftUpRPM={500,20000}, ShiftDownRPM={100,10000},
	ShiftTime={0.05,3}, FinalDrive={0.1,15}, ReverseRatio={0.1,10}, TorqueScale={0.1,100},
	InputTimeout={0.1,2}, TelemetryHz={1,20}, SleepAfter={0,30},
}
function Tune.resolve(overrides: any): any
	assert(overrides == nil or type(overrides) == "table", "Tune must be a table")
	local result = table.clone(defaults)
	for key, value in pairs(overrides or {}) do
		assert(defaults[key] ~= nil, "Unknown Tune field: "..tostring(key))
		result[key] = value
	end
	assert(result.SchemaVersion == 1, "Unsupported Tune schema")
	assert(result.Drive == "FWD" or result.Drive == "RWD" or result.Drive == "AWD", "Drive must be FWD/RWD/AWD")
	for key, range in pairs(ranges) do
		local v = result[key]
		assert(Math.finite(v) and v >= range[1] and v <= range[2], "Invalid Tune."..key)
	end
	assert(result.IdleRPM < result.ShiftDownRPM and result.ShiftDownRPM < result.ShiftUpRPM and result.ShiftUpRPM < result.RedlineRPM, "RPM thresholds must be idle < down < up < redline")
	assert(type(result.Gears)=="table" and #result.Gears>=1 and #result.Gears<=10, "Gears must have 1..10 ratios")
	local previous=math.huge
	local gears={}
	for i, ratio in ipairs(result.Gears) do
		assert(Math.finite(ratio) and ratio>0 and ratio<previous, "Gear ratios must descend and be positive")
		previous=ratio gears[i]=ratio
	end
	assert(type(result.TorqueCurve)=="table" and #result.TorqueCurve>=2 and #result.TorqueCurve<=32, "TorqueCurve needs 2..32 points")
	previous=-1
	local curve={}
	for i,p in ipairs(result.TorqueCurve) do
		assert(type(p)=="table" and #p==2 and Math.finite(p[1]) and p[1]>previous and Math.finite(p[2]) and p[2]>=0 and p[2]<=1e5, "Invalid torque curve point")
		previous=p[1] curve[i]=table.freeze({p[1],p[2]})
	end
	result.Gears=table.freeze(gears) result.TorqueCurve=table.freeze(curve)
	return table.freeze(result)
end
return table.freeze(Tune)
