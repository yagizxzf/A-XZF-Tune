--!strict
local Stability={}
-- Equal and opposite axle load transfer. Preserve total support and nonnegative loads.
function Stability.axle(left: number,right: number,compressionDifference: number,stiffness: number,strength: number,cap: number): (number,number)
	local transfer=math.clamp(compressionDifference*stiffness*strength,math.max(-left,right-cap),math.min(cap-left,right))
	return left+transfer,right-transfer
end
return table.freeze(Stability)
