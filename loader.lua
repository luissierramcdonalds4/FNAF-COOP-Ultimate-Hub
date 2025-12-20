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
local FullbrightEnabled = false
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
	for prop,val in pairs(OriginalLighting) do
		Lighting[prop] = val
	end
end

--------------------------------------------------
-- ANIM ESP HELPERS (NAME + DISTANCE)
--------------------------------------------------
local function ClearAnimESP(npc)
	if npc:FindFirstChild("__AnimHL") then npc.__AnimHL:Destroy() end
	if npc:FindFirstChild("__AnimGUI") then npc.__AnimGUI:Destroy() end
end

local function AddAnimESP(npc, name, color)
	if npc:FindFirstChild("__AnimHL") then return end
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
	gui.Size = UDim2.new(0,160,0,36)
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
-- DISTANCE UPDATE
--------------------------------------------------
Connections.Distance = RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root = char.HumanoidRootPart.Position

	for _, folder in ipairs(AnimFolder:GetChildren()) do
		for _, npc in ipairs(folder:GetChildren()) do
			if npc:FindFirstChild("__AnimGUI") and npc:FindFirstChild("HumanoidRootPart") then
				npc.__AnimGUI.Dist.Text =
					math.floor((root - npc.HumanoidRootPart.Position).Magnitude) .. " studs"
			end
		end
	end
end)

--------------------------------------------------
-- PLAYER ESP (HIGHLIGHT ONLY)
--------------------------------------------------
local PlayerESPEnabled = false
local PLAYER_COLOR = Color3.fromRGB(0,255,255)

local function ClearPlayerESP(player)
	local c = player.Character
	if not c then return end
	if c:FindFirstChild("__PlayerHL") then c.__PlayerHL:Destroy() end
end

local function AddPlayerESP(player)
	if player == LocalPlayer then return end
	local c = player.Character
	if not c then return end
	if c:FindFirstChild("__PlayerHL") then return end

	local hl = Instance.new("Highlight")
	hl.Name = "__PlayerHL"
	hl.FillColor = PLAYER_COLOR
	hl.OutlineColor = PLAYER_COLOR
	hl.FillTransparency = 0.85
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = c
	hl.Parent = c
end

local function UpdatePlayers()
	for _, p in ipairs(Players:GetPlayers()) do
		if PlayerESPEnabled then
			AddPlayerESP(p)
		else
			ClearPlayerESP(p)
		end
	end
end

--------------------------------------------------
-- INSTANT PROMPT (JANITOR)
--------------------------------------------------
local PromptCache = {}
local JanitorFolder =
	Workspace:WaitForChild("GameTriggers")
	:WaitForChild("JanitorTasks")

local function ApplyInstantPrompt(prompt)
	if not PromptCache[prompt] then
		PromptCache[prompt] = {
			HoldDuration = prompt.HoldDuration,
			RequiresLineOfSight = prompt.RequiresLineOfSight,
			MaxActivationDistance = prompt.MaxActivationDistance
		}
	end
	prompt.HoldDuration = 0
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 20
end

local function RestorePrompt(prompt)
	local d = PromptCache[prompt]
	if not d then return end
	prompt.HoldDuration = d.HoldDuration
	prompt.RequiresLineOfSight = d.RequiresLineOfSight
	prompt.MaxActivationDistance = d.MaxActivationDistance
end

--------------------------------------------------
-- UI
--------------------------------------------------
FNAFTab:CreateToggle({
	Name = "Enable All Animatronic ESP",
	CurrentValue = false,
	Callback = function(v)
		for name,data in pairs(Animatronics) do
			data.Enabled = v
			ApplyAnimESP(name)
		end
	end
})

for name,data in pairs(Animatronics) do
	FNAFTab:CreateToggle({
		Name = name .. " ESP",
		CurrentValue = false,
		Callback = function(v)
			data.Enabled = v
			ApplyAnimESP(name)
		end
	})
end

JanitorTab:CreateToggle({
	Name = "Instant Interact",
	CurrentValue = false,
	Callback = function(v)
		for _, obj in ipairs(JanitorFolder:GetDescendants()) do
			if obj:IsA("ProximityPrompt") then
				if v then ApplyInstantPrompt(obj) else RestorePrompt(obj) end
			end
		end
	end
})

SettingsTab:CreateToggle({
	Name = "Player ESP",
	CurrentValue = false,
	Callback = function(v)
		PlayerESPEnabled = v
		UpdatePlayers()
	end
})

SettingsTab:CreateToggle({
	Name = "Fullbright",
	CurrentValue = false,
	Callback = function(v)
		FullbrightEnabled = v
		if v then EnableFullbright() else DisableFullbright() end
	end
})

--------------------------------------------------
-- UNLOAD
--------------------------------------------------
local function UnloadScript()
	for name in pairs(Animatronics) do
		Animatronics[name].Enabled = false
		ApplyAnimESP(name)
	end

	for _, p in ipairs(Players:GetPlayers()) do
		ClearPlayerESP(p)
	end

	DisableFullbright()

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
-- DEATH HANDLER
--------------------------------------------------
local function HookDeath(char)
	local hum = char:WaitForChild("Humanoid",5)
	if not hum then return end

	hum.Died:Connect(function()
		DisableFullbright()
		task.delay(2, UnloadScript)
	end)
end

if LocalPlayer.Character then HookDeath(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookDeath)

--------------------------------------------------
-- NOTIFICATIONS
--------------------------------------------------
Rayfield:Notify({
	Title = "Important Notice",
	Content =
		"Execute this script at the START of the night.\n\n" ..
		"Re-execute if you die or after a night recap.\n\n" ..
		"Do NOT execute during recap.",
	Duration = 8
})

Rayfield:Notify({
	Title = "UI Controls",
	Content = "Toggle the UI with:\n\n• K",
	Duration = 8
})

Rayfield:Notify({
	Title = "Loaded",
	Content = "All features are OFF by default.",
	Duration = 5
})
