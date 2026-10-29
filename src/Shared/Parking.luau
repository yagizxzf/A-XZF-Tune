--!strict
-- A latched parking request survives input expiry and driver changes.
local Parking={}
function Parking.state(requested: boolean,speed: number,engageSpeed: number): string
	return if not requested then "Drive" elseif speed>engageSpeed then "Stopping" else "Parked"
end
return table.freeze(Parking)
