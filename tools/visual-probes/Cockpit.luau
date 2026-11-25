--!strict
-- Studio Client diagnostic. Seat the local player in an A-XZF vehicle first.
local runService = game:GetService("RunService")
assert(runService:IsStudio() and runService:IsClient(), "Studio Client only")

local player = game:GetService("Players").LocalPlayer
local gui = player.PlayerGui.AXZFCockpit
local root = gui.Root
local mobile = root.Mobile.Visible
local dashboard = if mobile then root.Mobile.DashboardMobile else root.HUD.Dashboard
local topLeftInset, bottomRightInset = game:GetService("GuiService"):GetGuiInset()
local report = {
	enabled = gui.Enabled,
	mobile = mobile,
	viewport = tostring(gui.AbsoluteSize),
	cameraViewport = tostring(workspace.CurrentCamera.ViewportSize),
	insets = tostring(gui.ScreenInsets),
	topLeftInset = { x = topLeftInset.X, y = topLeftInset.Y },
	bottomRightInset = { x = bottomRightInset.X, y = bottomRightInset.Y },
	safePosition = { x = root.AbsolutePosition.X, y = root.AbsolutePosition.Y },
	buttons = {},
	unloaded = {},
	overlap = {},
	outside = {},
	textOverflow = {},
	buttonArea = 0,
	imageCount = 0,
	guiCount = 0,
	help = root.HUD.Controls.Visible,
	recovery = root.Recovery.Visible,
}
local rects = {}
local function measure(node: GuiObject)
	local p, s = node.AbsolutePosition, node.AbsoluteSize
	return { x = p.X, y = p.Y, w = s.X, h = s.Y }
end

local safe = measure(root)
local dial = measure(dashboard)
local clippedX, clippedY = math.max(dial.x, safe.x), math.max(dial.y, safe.y)
local clippedW = math.min(dial.x + dial.w, safe.x + safe.w) - clippedX
local clippedH = math.min(dial.y + dial.h, safe.y + safe.h) - clippedY
rects.Dashboard = { x = clippedX, y = clippedY, w = clippedW, h = clippedH }
report.dashboard = rects.Dashboard
report.dialBounds = dial
report.visibleFraction = clippedW * clippedH / (dial.w * dial.h)
if report.help then rects.Help = measure(root.HUD.Controls) end
if report.recovery then rects.Recovery = measure(root.Recovery.Recovery) end
local side = if mobile then root.Mobile else root.HUD.Toggle
for _, node in side:GetDescendants() do
	if node:IsA("TextButton") then
		local rect = measure(node)
		rects[node.Name] = rect
		report.buttonArea += rect.w * rect.h
		table.insert(report.buttons, { name = node.Name, x = rect.x, y = rect.y, w = rect.w, h = rect.h })
	elseif node:IsA("ImageLabel") then
		report.imageCount += 1
		if not node.IsLoaded then
			table.insert(report.unloaded, { name = node:GetFullName(), image = node.Image })
		end
	end
end

for name, rect in pairs(rects) do
	if rect.x < safe.x - 1 or rect.y < safe.y - 1
		or rect.x + rect.w > safe.x + safe.w + 1 or rect.y + rect.h > safe.y + safe.h + 1 then
		table.insert(report.outside, name)
	end
	for other, candidate in pairs(rects) do
		if name < other
			and math.min(rect.x + rect.w, candidate.x + candidate.w) - math.max(rect.x, candidate.x) > 1
			and math.min(rect.y + rect.h, candidate.y + candidate.h) - math.max(rect.y, candidate.y) > 1 then
			table.insert(report.overlap, name .. "/" .. other)
		end
	end
end

for _, node in root:GetDescendants() do
	if not node:IsA("TextLabel") or node.TextFits then continue end
	local parent = node :: Instance
	local visible = true
	while parent ~= root and parent:IsA("GuiObject") do
		if not parent.Visible then visible = false break end
		parent = parent.Parent
	end
	if visible then table.insert(report.textOverflow, node.Name) end
end
for _, child in gui.Parent:GetChildren() do
	if child.Name == "AXZFCockpit" then report.guiCount += 1 end
end
local gear = dashboard:FindFirstChild("Gear", true)
if gear and not gear:IsA("TextLabel") then gear = gear:FindFirstChildWhichIsA("TextLabel", true) end
report.gear = if gear then gear.Text else nil
return game:GetService("HttpService"):JSONEncode(report)
