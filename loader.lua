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
local SettingsTab = Window:CreateTab("Settings", 4483362458)

--------------------------------------------------
-- ANIM CONFIG
--------------------------------------------------
local Animatronics = {
	Freddy = { Color = Color3.fromRGB(139,69,19), Enabled = true },
	Bonnie = { Color = Color3.fromRGB(120,0,255), Enabled = true },
	Chica = { Color = Color3.fromRGB(255,255,0), Enabled = true },
	Foxy = { Color = Color3.fromRGB(255,0,0), Enabled = true },
	GoldenFreddy = { Color = Color3.fromRGB(255,215,0), Enabled = true }
}

--------------------------------------------------
-- ANIM ESP HELPERS
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

--------------------------------------------------
-- APPLY ANIM ESP
--------------------------------------------------
local function ApplyAnimESP(animName)
	local folder = AnimFolder:FindFirstChild(animName)
	if not folder then return end

	for _, npc in ipairs(folder:GetChildren()) do
		if npc:IsA("Model") then
			ClearAnimESP(npc)
			if Animatronics[animName].Enabled then
				AddAnimESP(npc, animName, Animatronics[animName].Color)
			end
		end
	end
end

for name in pairs(Animatronics) do
	ApplyAnimESP(name)
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
-- UI
--------------------------------------------------
for name, data in pairs(Animatronics) do
	FNAFTab:CreateToggle({
		Name = name .. " ESP",
		CurrentValue = true,
		Callback = function(v)
			data.Enabled = v
			ApplyAnimESP(name)
		end
	})
end

SettingsTab:CreateToggle({
	Name = "Player ESP",
	CurrentValue = false,
	Callback = function(v)
		PlayerESPEnabled = v
		UpdatePlayers()
	end
})

--------------------------------------------------
-- UNLOAD FUNCTION
--------------------------------------------------
local function UnloadScript()
	for _, folder in ipairs(AnimFolder:GetChildren()) do
		for _, npc in ipairs(folder:GetChildren()) do
			ClearAnimESP(npc)
		end
	end

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
-- DEATH HANDLER (8s NOTIFY)
--------------------------------------------------
local function HookDeath(character)
	local hum = character:WaitForChild("Humanoid", 5)
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

if LocalPlayer.Character then
	HookDeath(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(HookDeath)

--------------------------------------------------
-- STARTUP WARNING (8s NOTIFY)
--------------------------------------------------
Rayfield:Notify({
	Title = "Important Notice",
	Content =
		"This script MUST be re-executed:\n\n" ..
		"• After every night recap\n" ..
		"• If the player dies\n\n" ..
		"Failure to do so will cause it to stop working.",
	Duration = 8
})

--------------------------------------------------
-- READY
--------------------------------------------------
Rayfield:Notify({
	Title = "Loaded",
	Content = "ESP active.",
	Duration = 5
})
