--!strict
-- Editor-only geometry migration. Never requires legacy Tune/plugins/scripts.
local Doctor=require(script.Parent.Doctor)
local Migration={}
local ids={"FL","FR","RL","RR"}
local function findSource(wrapper)
	local candidates={}
	local all={wrapper} for _,v in ipairs(wrapper:GetDescendants()) do table.insert(all,v) end
	for _,v in ipairs(all) do
		if v:IsA("Model") and v:FindFirstChild("DriveSeat") and v:FindFirstChild("Wheels") and v:FindFirstChild("A-Chassis Tune") then table.insert(candidates,v) end
	end
	assert(#candidates==1,"Select exactly one A-Chassis vehicle (DriveSeat + Wheels + A-Chassis Tune)")
	return candidates[1]
end
local function geometry(instance,report)
	local copy=instance:Clone()
	for _,v in ipairs(copy:GetDescendants()) do
		if not (v:IsA("BasePart") or v:IsA("Model") or v:IsA("Folder") or v:IsA("DataModelMesh") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) then v:Destroy() report.stripped+=1 end
	end
	for _,v in ipairs(copy:GetDescendants()) do if v:IsA("BasePart") then v.Anchored=true end end
	if copy:IsA("BasePart") then copy.Anchored=true end
	return copy
end
function Migration.inspect(wrapper: Model): any
	assert(not game:GetService("RunService"):IsRunning(),"Migrate only in Edit mode")
	local source=findSource(wrapper)
	local scripts=0 local parts=0
	for _,v in ipairs(source:GetDescendants()) do if v:IsA("LuaSourceContainer") then scripts+=1 end if v:IsA("BasePart") then parts+=1 end end
	for _,id in ipairs(ids) do assert(Doctor.hub(source.Wheels:FindFirstChild(id)),"Unsupported wheel "..id..": choose a PrimaryPart before migration") end
	return {source=source,sourcePath=source:GetFullName(),legacyScripts=scripts,sourceParts=parts}
end
function Migration.convert(wrapper: Model, options: any): (Model, any)
	options=options or {}
	local report=Migration.inspect(wrapper) local source=report.source report.source=nil report.stripped=0
	local model=Instance.new("Model") model.Name=options.name or source.Name.."_AXZF"
	local ok,err=pcall(function()
		local wheels=Instance.new("Folder") wheels.Name="Wheels" wheels.Parent=model
		local centers={} local center=Vector3.zero local radius=0
		for _,id in ipairs(ids) do
			local oldWheel=source.Wheels[id] local oldHub=Doctor.hub(oldWheel) :: BasePart
			local hub=oldHub:Clone()
			-- Keep the wheel's render mesh and documented art Parts only. No arms/suspension.
			for _,child in ipairs(hub:GetChildren()) do
				if not child:IsA("DataModelMesh") and child.Name~="Parts" then child:Destroy() end
			end
			local safe=geometry(hub,report) hub:Destroy() hub=safe
			local wheel=Instance.new("Model") wheel.Name=id wheel.Parent=wheels hub.Name="Hub" hub.Parent=wheel wheel.PrimaryPart=hub
			centers[id]=hub.Position center+=hub.Position/4
			radius+=math.max(oldHub.Size.X,oldHub.Size.Y,oldHub.Size.Z)/8
		end
		radius=options.radius or radius
		local forward=((centers.FL+centers.FR)-(centers.RL+centers.RR))/2
		forward=Vector3.new(forward.X,0,forward.Z) assert(forward.Magnitude>.5,"Wheelbase is too short")
		local frame=CFrame.lookAt(center+Vector3.new(0,.7,0),center+Vector3.new(0,.7,0)+forward.Unit)
		local localFL=frame:PointToObjectSpace(centers.FL) local localFR=frame:PointToObjectSpace(centers.FR)
		local localRL=frame:PointToObjectSpace(centers.RL)
		assert(localFL.X<localFR.X,"Legacy wheel labels are mirrored; correct FL/FR first")
		local track=math.abs(localFR.X-localFL.X) local wheelbase=math.abs(localRL.Z-localFL.Z)
		local root=Instance.new("Part") root.Name="Chassis" root.Size=Vector3.new(track*.85,.7,wheelbase*.9)
		root.CFrame=frame root.Anchored=true root.Transparency=1 root.CustomPhysicalProperties=PhysicalProperties.new(1.2,.3,0,100,100) root.Parent=model model.PrimaryPart=root
		local body=Instance.new("Folder") body.Name="Body" body.Parent=model
		for _,group in ipairs({"Body","Misc"}) do
			local sourceGroup=source:FindFirstChild(group)
			if sourceGroup then local copy=geometry(sourceGroup,report) copy.Name="Visual"..group copy.Parent=body end
		end
		local seat=Instance.new("VehicleSeat") seat.Name="DriveSeat" seat.Size=source.DriveSeat.Size seat.CFrame=source.DriveSeat.CFrame
		seat.Anchored=true seat.HeadsUpDisplay=false seat.Parent=model
		local rest=options.restLength or 1.6
		for _,id in ipairs(ids) do
			local mount=Instance.new("Attachment") mount.Name=id mount.Position=frame:PointToObjectSpace(centers[id])+Vector3.new(0,rest,0) mount.Parent=root
		end
		local config=game.ServerStorage.AXZFExamples.VehicleTune:Clone() config.Name="Tune"
		local text=config.Source
		local values={Radius=radius,RestLength=rest,Drive=options.drive or "RWD"}
		for key,value in pairs(values) do
			local literal=if type(value)=="string" then string.format("%q",value) else tostring(value)
			text=string.gsub(text,"(\n%s*"..key.."%s*=%s*)[^,\n]+,",function(prefix) return prefix..literal.."," end,1)
		end
		config.Source=text config.Parent=model
		report.radius=radius report.track=track report.wheelbase=wheelbase report.doctor=Doctor.inspect(model)
		assert(report.doctor.ok,game:GetService("HttpService"):JSONEncode(report.doctor.errors))
		report.parts=report.doctor.parts report.legacyScriptsRemaining=0
		for _,v in ipairs(model:GetDescendants()) do
			if v:IsA("LuaSourceContainer") and v~=config then report.legacyScriptsRemaining+=1 end
		end
		assert(report.legacyScriptsRemaining==0,"Unexpected executable content after migration")
		model:SetAttribute("AXZF_MigratedFrom",report.sourcePath)
		model:SetAttribute("SourceAsset",options.assetId or "user-supplied")
		if options.at then model:PivotTo(options.at) end
	end)
	if not ok then model:Destroy() error(err,2) end
	return model,report
end
-- One Command Bar call on a selected model; original remains in its storage location.
function Migration.fromSelection(options: any): (Model,any)
	assert(not game:GetService("RunService"):IsRunning(),"Migrate only in Edit mode")
	local selected=game:GetService("Selection"):Get()
	assert(#selected==1 and selected[1]:IsA("Model"),"Select one vehicle Model in Explorer")
	local model,report=Migration.convert(selected[1],options)
	model.Parent=workspace
	game:GetService("CollectionService"):AddTag(model,"AXZFVehicle")
	game:GetService("Selection"):Set({model})
	return model,report
end
return Migration
