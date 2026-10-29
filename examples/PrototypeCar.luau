--!strict
-- Original, fully editable multi-part demonstration car. No external meshes.
local Car={}
local function part(name,size,cf,color,parent)
	local p=Instance.new("Part") p.Name=name p.Size=size p.CFrame=cf p.Color=color
	p.Anchored=true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
function Car.create(at: CFrame?, name: string?): Model
	local frame=at or CFrame.new(0,4,0)
	local m=Instance.new("Model") m.Name=name or "AXZF_Prototype"
	local tune=game.ServerStorage.AXZFExamples:FindFirstChild("VehicleTune")
	if tune then local config=tune:Clone() config.Name="Tune" config.Parent=m end
	local root=part("Chassis",Vector3.new(5.6,0.8,9.5),frame,Color3.fromRGB(27,31,36),m)
	root.CustomPhysicalProperties=PhysicalProperties.new(1.2,0.3,0,100,100)
	root.Transparency=0.5 m.PrimaryPart=root
	local body=Instance.new("Folder") body.Name="Body" body.Parent=m
	local paint=Color3.fromRGB(227,106,36)
	part("Floor",Vector3.new(5.8,0.35,10),frame*CFrame.new(0,0.5,0),paint,body)
	part("Hood",Vector3.new(5.5,0.8,3),frame*CFrame.new(0,1,-3.3),paint,body)
	part("Trunk",Vector3.new(5.5,0.6,2.3),frame*CFrame.new(0,1,3.7),paint,body)
	part("Roof",Vector3.new(5.2,0.25,3.8),frame*CFrame.new(0,3,0.5),paint,body)
	for _,x in ipairs({-2.5,2.5}) do
		part(if x<0 then "DoorLeft" else "DoorRight",Vector3.new(0.25,1.2,4.7),frame*CFrame.new(x,1.1,0.3),paint,body)
		for _,z in ipairs({-1.3,2.3}) do part("Pillar",Vector3.new(0.2,1.8,0.2),frame*CFrame.new(x,2,z),paint,body) end
	end
	for _,x in ipairs({-1.8,1.8}) do
		local lamp=part("Headlamp",Vector3.new(1.1,0.4,0.12),frame*CFrame.new(x,1,-4.84),Color3.fromRGB(255,238,183),body) lamp.Material=Enum.Material.Neon
		part("TailLamp",Vector3.new(1.1,0.35,0.12),frame*CFrame.new(x,1,4.94),Color3.fromRGB(180,26,25),body)
	end
	local seat=Instance.new("VehicleSeat") seat.Name="DriveSeat" seat.Size=Vector3.new(2,0.4,2)
	seat.CFrame=frame*CFrame.new(-1.2,1.3,0.4) seat.Anchored=true seat.Parent=m
	local wheels=Instance.new("Folder") wheels.Name="Wheels" wheels.Parent=m
	for _,id in ipairs({"FL","FR","RL","RR"}) do
		local x=if string.sub(id,2,2)=="L" then -3.1 else 3.1
		local z=if string.sub(id,1,1)=="F" then -3.2 else 3.2
		local mount=Instance.new("Attachment") mount.Name=id mount.Position=Vector3.new(x,0.6,z) mount.Parent=root
		local wheel=Instance.new("Model") wheel.Name=id wheel.Parent=wheels
		local cf=frame*CFrame.new(x,-1,z)
		local tire=part("Tire",Vector3.new(0.8,2.5,2.5),cf,Color3.fromRGB(23,24,27),wheel)
		tire.Shape=Enum.PartType.Cylinder tire.Material=Enum.Material.Rubber wheel.PrimaryPart=tire
		local rim=part("Rim",Vector3.new(0.85,1.6,1.6),cf,Color3.fromRGB(177,186,193),wheel) rim.Shape=Enum.PartType.Cylinder rim.Material=Enum.Material.Metal
	end
	return m
end
return Car
