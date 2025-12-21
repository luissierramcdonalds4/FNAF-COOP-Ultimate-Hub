--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- STATE
--------------------------------------------------
local unloaded = false

--------------------------------------------------
-- GUI SETUP
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "SeatRequirementGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0.6, 0, 0.35, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

--------------------------------------------------
-- TEXT
--------------------------------------------------
local text = Instance.new("TextLabel")
text.Size = UDim2.new(0.9, 0, 0.45, 0)
text.Position = UDim2.new(0.5, 0, 0.3, 0)
text.AnchorPoint = Vector2.new(0.5, 0.5)
text.BackgroundTransparency = 1
text.TextWrapped = true
text.TextScaled = true
text.Font = Enum.Font.GothamMedium
text.TextColor3 = Color3.new(1,1,1)
text.Text =
	"For this script to function\n" ..
	"you must be seated in the office chair"
text.Parent = main

--------------------------------------------------
-- BUTTON
--------------------------------------------------
local button = Instance.new("TextButton")
button.Size = UDim2.new(0.4, 0, 0.2, 0)
button.Position = UDim2.new(0.5, 0, 0.75, 0)
button.AnchorPoint = Vector2.new(0.5, 0.5)
button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
button.BorderSizePixel = 0
button.Text = "I'm Seated"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.TextColor3 = Color3.fromRGB(0, 255, 0)
button.Parent = main
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

--------------------------------------------------
-- CLEAN UNLOAD
--------------------------------------------------
local function FullUnload()
	if unloaded then return end
	unloaded = true
	if gui then gui:Destroy() end
end

--------------------------------------------------
-- DEATH HANDLER (INSTANT UNLOAD)
--------------------------------------------------
local function HookDeath(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then return end

	humanoid.Died:Connect(function()
		FullUnload()
	end)
end

if LocalPlayer.Character then
	HookDeath(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(HookDeath)

--------------------------------------------------
-- BUTTON LOGIC
--------------------------------------------------
button.MouseButton1Click:Connect(function()
	if unloaded then return end

	gui:Destroy()

	loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/luissierramcdonalds4/FNAF-COOP-Ultimate-Hub/main/fnafauto.lua",
		true
	))()
end)
