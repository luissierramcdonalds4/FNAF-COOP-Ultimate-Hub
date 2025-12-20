--------------------------------------------------
-- LOAD RAYFIELD
--------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local AnimFolder = Workspace:WaitForChild("Animatronics")

--------------------------------------------------
-- CONNECTIONS
--------------------------------------------------
local Connections = {}

--------------------------------------------------
-- WINDOW
--------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "FNAF: COOP Ultimate Script",
	LoadingTitle = "FNAF: COOP Ultimate Script",
	LoadingSubtitle = "Ultimate ESP Hub",
	KeySystem = false
})

local FNAFTab = Window:CreateTab("FNAF 1", 4483362458)
local JanitorTab = Window:CreateTab("JanitorTasksESP", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

--------------------------------------------------
-- ANIM CONFIG (ALL OFF)
--------------------------------------------------
local Animatronics = {
	Freddy = { Color = Color3.fromRGB(139,69,19), Enabled = false },
	Bonnie = { Color = Color3.fromRGB(120,0,255), Enabled = false },
	Chica = { Color = Color3.fromRGB(255,255,0), Enabled = false },
	Foxy = { Color = Color3.fromRGB(255,0,0), Enabled = false },
	GoldenFreddy = { Color = Color3.fromRGB(255,215,0), Enabled = false }
}

--------------------------------------------------
-- FULLBRIGHT
--------------------------------------------------
local OriginalLighting = {
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	ClockTime = Lighting.ClockTime
}

local function EnableFullbright()
	Lighting.Brightness = 3
	Lighting.Ambient = Color3.new(1,1,1)
	Lighting.OutdoorAmbient = Color3.new(1,1,1)
	Lighting.ClockTime = 12
end

local function DisableFullbright()
	for k, v in pairs(OriginalLighting) do
		Lighting[k] = v
	end
end

--------------------------------------------------
-- ANIM ESP (NAME + DISTANCE)
--------------------------------------------------
local function ClearAnimESP(npc)
	if npc:FindFirstChild("__AnimHL") then npc.__AnimHL:Destroy() end
	if npc:FindFirstChild("__AnimGUI") then npc.__AnimGUI:Destroy() end
end

local function AddAnimESP(npc, name, color)
	if not npc:FindFirstChild("HumanoidRootPart") then return end

	local hl = Instance.new("Highlight")
	hl.Name = "__AnimHL"
	hl.FillColor = color
	hl.OutlineColor = color
	hl.FillTransparency = 0.85
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = npc
	hl.Parent = npc

	local gui = Instance.new("BillboardGui")
	gui.Name = "__AnimGUI"
	gui.Size = UDim2.new(0,180,0,40)
	gui.StudsOffset = Vector3.new(0,3.2,0)
	gui.AlwaysOnTop = true
	gui.Adornee = npc.HumanoidRootPart
	gui.Parent = npc

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1,0,0.5,0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextSize = 13
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextColor3 = color
	nameLbl.TextStrokeTransparency = 0.3
	nameLbl.Text = name
	nameLbl.Parent = gui

	local dist = Instance.new("TextLabel")
	dist.Name = "Dist"
	dist.Position = UDim2.new(0,0,0.5,0)
	dist.Size = UDim2.new(1,0,0.5,0)
	dist.BackgroundTransparency = 1
	dist.TextSize = 12
	dist.Font = Enum.Font.Gotham
	dist.TextColor3 = Color3.new(1,1,1)
	dist.TextStrokeTransparency = 0.4
	dist.Text = "0 studs"
	dist.Parent = gui
end

local function ApplyAnimESP(name)
	local folder = AnimFolder:FindFirstChild(name)
	if not folder then return end

	for _, npc in ipairs(folder:GetChildren()) do
		ClearAnimESP(npc)
		if Animatronics[name].Enabled then
			AddAnimESP(npc, name, Animatronics[name].Color)
		end
	end
end

--------------------------------------------------
-- DISTANCE UPDATE (FIXED)
--------------------------------------------------
Connections.Distance = RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart.Position

	for _, folder in ipairs(AnimFolder:GetChildren()) do
		for _, npc in ipairs(folder:GetChildren()) do
			if npc:FindFirstChild("__AnimGUI") and npc:FindFirstChild("HumanoidRootPart") then
				local distLabel = npc.__AnimGUI:FindFirstChild("Dist")
				if distLabel then
					distLabel.Text =
						math.floor((root - npc.HumanoidRootPart.Position).Magnitude) .. " studs"
				end
			end
		end
	end
end)

--------------------------------------------------
-- PLAYER ESP
--------------------------------------------------
local PlayerESPEnabled = false
local PLAYER_COLOR = Color3.fromRGB(0,255,255)

local function ClearPlayerESP(p)
	if p.Character and p.Character:FindFirstChild("__PlayerHL") then
		p.Character.__PlayerHL:Destroy()
	end
end

local function AddPlayerESP(p)
	if p == LocalPlayer then return end
	if not p.Character or p.Character:FindFirstChild("__PlayerHL") then return end

	local hl = Instance.new("Highlight")
	hl.Name = "__PlayerHL"
	hl.FillColor = PLAYER_COLOR
	hl.OutlineColor = PLAYER_COLOR
	hl.FillTransparency = 0.85
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = p.Character
	hl.Parent = p.Character
end

--------------------------------------------------
-- JANITOR INSTANT PROMPT
--------------------------------------------------
local InstantPromptEnabled = false

local function ApplyInstantPrompt()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			obj.HoldDuration = InstantPromptEnabled and 0 or obj.HoldDuration
		end
	end
end

--------------------------------------------------
-- NIGHT GUARD MODE (P)
--------------------------------------------------
local function GetNightGuardGui()
	return LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NightGuardModeGui")
end

Connections.NightGuardKey = UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.P then
		local gui = GetNightGuardGui()
		if gui then
			gui.Enabled = not gui.Enabled
		end
	end
end)

--------------------------------------------------
-- UI
--------------------------------------------------
FNAFTab:CreateToggle({
	Name = "Enable All Animatronic ESP",
	CurrentValue = false,
	Callback = function(v)
		for name in pairs(Animatronics) do
			Animatronics[name].Enabled = v
			ApplyAnimESP(name)
		end
	end
})

for name in pairs(Animatronics) do
	FNAFTab:CreateToggle({
		Name = name .. " ESP",
		CurrentValue = false,
		Callback = function(v)
			Animatronics[name].Enabled = v
			ApplyAnimESP(name)
		end
	})
end

FNAFTab:CreateToggle({
	Name = "Night Guard Mode (Keybind: P)",
	CurrentValue = false,
	Callback = function(v)
		local gui = GetNightGuardGui()
		if gui then gui.Enabled = v end
	end
})

JanitorTab:CreateToggle({
	Name = "Instant Interact",
	CurrentValue = false,
	Callback = function(v)
		InstantPromptEnabled = v
		ApplyInstantPrompt()
	end
})

SettingsTab:CreateToggle({
	Name = "Player ESP",
	CurrentValue = false,
	Callback = function(v)
		PlayerESPEnabled = v
		for _, p in ipairs(Players:GetPlayers()) do
			if v then AddPlayerESP(p) else ClearPlayerESP(p) end
		end
	end
})

SettingsTab:CreateToggle({
	Name = "Fullbright",
	CurrentValue = false,
	Callback = function(v)
		if v then EnableFullbright() else DisableFullbright() end
	end
})

--------------------------------------------------
-- UNLOAD
--------------------------------------------------
local function UnloadScript()
	DisableFullbright()

	for _, p in ipairs(Players:GetPlayers()) do
		ClearPlayerESP(p)
	end

	for _, c in pairs(Connections) do
		if c then c:Disconnect() end
	end

	Rayfield:Destroy()
end

SettingsTab:CreateButton({
	Name = "Unload Script",
	Callback = UnloadScript
})

--------------------------------------------------
-- DEATH HANDLER (NOTIFY + UNLOAD)
--------------------------------------------------
local function HookDeath(char)
	local hum = char:WaitForChild("Humanoid",5)
	if not hum then return end

	hum.Died:Connect(function()
		Rayfield:Notify({
			Title = "Script Unloaded",
			Content =
				"You died.\n\n" ..
				"This script MUST be re-executed.\n\n" ..
				"It will not function after death.",
			Duration = 8
		})

		task.delay(8, UnloadScript)
	end)
end

if LocalPlayer.Character then HookDeath(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookDeath)

--------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------
Rayfield:Notify({
	Title = "Important Notice",
	Content = "Execute at the START of the night.\nRe-execute on death or recap.",
	Duration = 8
})

Rayfield:Notify({
	Title = "UI Controls",
	Content = "Toggle UI: K\nNight Guard Mode: P",
	Duration = 8
})

Rayfield:Notify({
	Title = "Loaded",
	Content = "All features are OFF by default.",
	Duration = 5
})
