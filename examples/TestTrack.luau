--!strict
local Track={}
function Track.create(): Model
	local m=Instance.new("Model") m.Name="AXZF_TestTrack"
	local function p(name,size,cf,color,grip)
		local a=Instance.new("Part") a.Name=name a.Anchored=true a.Size=size a.CFrame=cf a.Color=color a.Material=Enum.Material.Asphalt
		if grip then a:SetAttribute("Grip",grip) end a.Parent=m return a
	end
	p("Straight",Vector3.new(100,1,800),CFrame.new(0,0,-280),Color3.fromRGB(51,55,60))
	for i=0,15 do p("LaneMark",Vector3.new(0.25,0.02,7),CFrame.new(0,0.51,50-i*40),Color3.fromRGB(233,225,195)) end
	p("LowGrip",Vector3.new(20,0.1,80),CFrame.new(32,0.56,-100),Color3.fromRGB(103,135,153),0.3)
	p("Ramp",Vector3.new(18,1,45),CFrame.new(-30,4,-100)*CFrame.Angles(math.rad(10),0,0),Color3.fromRGB(111,115,121))
	for i=1,8 do p("Bump",Vector3.new(12,0.3,0.6),CFrame.new(28,0.65,-220-i*5),Color3.fromRGB(190,156,55)) end
	return m
end
return Track
