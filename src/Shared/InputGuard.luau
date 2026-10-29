--!strict
local Math=require(script.Parent.Math)
local Guard={}
local fields={seq=true,throttle=true,steer=true,brake=true,handbrake=true,park=true}
function Guard.validate(packet: any, lastSequence: number): boolean
	if type(packet)~="table" then return false end
	for key in pairs(packet) do if not fields[key] then return false end end
	if not Math.finite(packet.seq) or packet.seq%1~=0 or packet.seq<=lastSequence or packet.seq>2^31-1 then return false end
	for _,key in ipairs({"throttle","steer","brake"}) do
		local v=packet[key]
		if not Math.finite(v) or v > 1 or v < (if key=="brake" then 0 else -1) then return false end
	end
	return type(packet.handbrake)=="boolean" and (packet.park==nil or type(packet.park)=="boolean")
end
function Guard.consume(bucket: any, now: number): boolean
	bucket.tokens=math.min(45,bucket.tokens+math.max(0,now-bucket.time)*30)
	bucket.time=now
	if bucket.tokens<1 then return false end
	bucket.tokens-=1
	return true
end
return table.freeze(Guard)
