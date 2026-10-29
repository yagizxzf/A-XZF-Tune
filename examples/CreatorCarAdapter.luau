--!strict
-- Editor-only integration recipe for Creator Store asset 14215126016.
-- Third-party geometry is not relicensed or distributed with this MIT kit.
return function(quarantined: Model, at: CFrame?): Model
	assert(not game:GetService("RunService"):IsRunning(),"Adapt external art in Edit mode only")
	local source=quarantined:FindFirstChild("Car") or quarantined
	assert(source:FindFirstChild("Body") and source:FindFirstChild("Chassis"),"Expected reviewed Car asset hierarchy")
	local m=Instance.new("Model") m.Name="AXZF_ImportedCar"
	local ok,err=pcall(function()
		local body=source.Body:Clone()
		for _,v in ipairs(body:GetDescendants()) do
			-- Geometry-only allowlist. SurfaceAppearance/texture dependencies intentionally excluded:
			-- the inspected asset referenced inaccessible/mismatched texture-pack content.
			if not (v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("DataModelMesh")) then v:Destroy()
			elseif v:IsA("MeshPart") then v.TextureID=""
			elseif v:IsA("SpecialMesh") then v.TextureId="" end
		end
		for _,v in ipairs(body:GetChildren()) do v.Parent=m end body:Destroy()
		local wheels={} local center=Vector3.zero
		for _,id in ipairs({"FL","FR","RL","RR"}) do
			local wheel=m[id] wheel.PrimaryPart=wheel:FindFirstChild("tire")
			assert(wheel.PrimaryPart,"Missing tire hub "..id)
			wheels[id]=wheel center+=wheel.PrimaryPart.Position/4
		end
		local root=Instance.new("Part") root.Name="Root" root.Size=Vector3.new(5.8,.8,11.5)
		root.CFrame=CFrame.new(center+Vector3.new(0,.8,0))*source.Chassis.VehicleSeat.CFrame.Rotation
		root.Transparency=1 root.Anchored=true root.CustomPhysicalProperties=PhysicalProperties.new(1.2,.3,0,100,100) root.Parent=m
		local seat=Instance.new("VehicleSeat") seat.Size=Vector3.new(1,.25,1)
		seat.CFrame=source.Chassis.VehicleSeat.CFrame seat.Anchored=true seat.Parent=m
		local report=require(game.ServerScriptService.AXZFServer.Adapter).prepare(m,root,seat,wheels,1.6)
		assert(report.ok,game:GetService("HttpService"):JSONEncode(report.errors))
		m:SetAttribute("SourceAsset","14215126016") m:SetAttribute("SourceCreator","Roblox Resources")
		m:SetAttribute("Redistribution","Not included in MIT source; rights unverified")
		m:PivotTo(at or CFrame.new(12,5,35))
	end)
	if not ok then m:Destroy() error(err,2) end
	return m
end
