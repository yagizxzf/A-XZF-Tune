--!strict
-- Four-contact implicit spring solve. Mobility is J * inverse(M) * transpose(J).
-- All contacts use the SAME pre-step velocity. This avoids wheel-order feedback.
local Suspension={}
function Suspension.solve(contacts: any, cornerMass: number, gravity: number, frequency: number, damping: number, maxLoad: number, dt: number): {number}
	local omega=2*math.pi*frequency
	local k=cornerMass*omega*omega
	local response=2*damping*cornerMass*omega+k*dt
	local loads=table.create(#contacts,0)
	local rows={}
	for i,contact in ipairs(contacts) do
		local row={}
		for j=1,#contacts do row[j]=(if i==j then 1 else 0)+dt*response*contact.mobility[j] end
		rows[i]=row
	end
	-- Projected Gauss-Seidel handles unilateral contact without negative springs.
	for _=1,16 do
		for i,contact in ipairs(contacts) do
			local rhs=k*contact.compression-response*(contact.velocity+dt*contact.gravity)
			for j=1,#contacts do if j~=i then rhs-=rows[i][j]*loads[j] end end
			loads[i]=math.clamp(rhs/rows[i][i],0,cornerMass*gravity*maxLoad)
		end
	end
	return loads
end
return table.freeze(Suspension)
