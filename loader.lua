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
-- CREDIT LABEL (ALWAYS VISIBLE)
--------------------------------------------------
local CreditGui = Instance.new("ScreenGui")
CreditGui.Name = "AftonCreditGui"
CreditGui.ResetOnSpawn = false
CreditGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
CreditGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(0,300,0,20)
Credit.Position = UDim2.new(0.5,-150,0.02,0)
Credit.BackgroundTransparency = 1
Credit.Text = "Script by Afton-Robotics"
Credit.Font = Enum.Font.GothamMedium
Credit.TextSize = 14
Credit.TextColor3 = Color3.fromRGB(200,200,200)
Credit.TextStrokeTransparency = 0.6
Credit.Parent = CreditGui

--------------------------------------------------
-- WINDOW
--------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "FNAF: COOP Ultimate Script",
	LoadingTitle = "FNAF: COOP Ultimate Script",
	LoadingSubtitle = "Script by Afton-Robotics",
	KeySystem = false
})

local FNAFTab = Window:CreateTab("FNAF 1", 4483362458)
local NightGuardPlusTab = Window:CreateTab("NightGuard+", 4483362458)
local JanitorTab = Window:CreateTab("JanitorTasks", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

--------------------------------------------------
-- STARTUP NOTIFICATIONS
--------------------------------------------------
Rayfield:Notify({
	Title = "Controls",
	Content = "Open/Close keybind: K",
	Duration = 6
})

Rayfield:Notify({
	Title = "Auto-Unload",
	Content = "Script will automatically unload on death.",
	Duration = 6
})

--------------------------------------------------
-- NIGHTGUARD+ TAB
--------------------------------------------------
NightGuardPlusTab:CreateButton({
	Name = "FNAF1 Door Detection",
	Callback = function()
		loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/luissierramcdonalds4/FNAF-COOP-Ultimate-Hub/main/fnafautov3.lua",
			true
		))()
	end
})

--------------------------------------------------
-- ANIM CONFIG
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
	for k,v in pairs(OriginalLighting) do
		Lighting[k] = v
	end
end

--------------------------------------------------
-- ANIM ESP
--------------------------------------------------
local function ClearAnimESP(npc)
	if npc:FindFirstChild("__AnimHL") then npc.__AnimHL:Destroy() end
	if npc:FindFirstChild("__AnimGUI") then npc.__AnimGUI:Destroy() end
end

local function AddAnimESP(npc,name,color)
	if not npc:FindFirstChild("HumanoidRootPart") then return end

	local hl = Instance.new("Highlight")
	hl.Name="__AnimHL"
	hl.FillColor=color
	hl.OutlineColor=color
	hl.FillTransparency=0.85
	hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee=npc
	hl.Parent=npc

	local gui=Instance.new("BillboardGui")
	gui.Name="__AnimGUI"
	gui.Size=UDim2.new(0,180,0,40)
	gui.StudsOffset=Vector3.new(0,3.2,0)
	gui.AlwaysOnTop=true
	gui.Adornee=npc.HumanoidRootPart
	gui.Parent=npc

	local nameLbl=Instance.new("TextLabel")
	nameLbl.Size=UDim2.new(1,0,0.5,0)
	nameLbl.BackgroundTransparency=1
	nameLbl.Font=Enum.Font.GothamBold
	nameLbl.TextScaled=true
	nameLbl.TextColor3=color
	nameLbl.TextStrokeTransparency=0.3
	nameLbl.Text=name
	nameLbl.Parent=gui

	local dist=Instance.new("TextLabel")
	dist.Name="Dist"
	dist.Position=UDim2.new(0,0,0.5,0)
	dist.Size=UDim2.new(1,0,0.5,0)
	dist.BackgroundTransparency=1
	dist.Font=Enum.Font.Gotham
	dist.TextScaled=true
	dist.TextColor3=Color3.new(1,1,1)
	dist.TextStrokeTransparency=0.4
	dist.Text="0 studs"
	dist.Parent=gui
end

local function ApplyAnimESP(name)
	local folder=AnimFolder:FindFirstChild(name)
	if not folder then return end
	for _,npc in ipairs(folder:GetChildren()) do
		ClearAnimESP(npc)
		if Animatronics[name].Enabled then
			AddAnimESP(npc,name,Animatronics[name].Color)
		end
	end
end

--------------------------------------------------
-- DISTANCE UPDATE
--------------------------------------------------
Connections.Distance=RunService.RenderStepped:Connect(function()
	local char=LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local root=char.HumanoidRootPart.Position

	for _,folder in ipairs(AnimFolder:GetChildren()) do
		for _,npc in ipairs(folder:GetChildren()) do
			if npc:FindFirstChild("__AnimGUI") and npc:FindFirstChild("HumanoidRootPart") then
				local d=npc.__AnimGUI:FindFirstChild("Dist")
				if d then
					d.Text=math.floor((root-npc.HumanoidRootPart.Position).Magnitude).." studs"
				end
			end
		end
	end
end)

--------------------------------------------------
-- PLAYER ESP
--------------------------------------------------
local PLAYER_COLOR=Color3.fromRGB(0,255,255)

local function ClearPlayerESP(p)
	if p.Character and p.Character:FindFirstChild("__PlayerHL") then
		p.Character.__PlayerHL:Destroy()
	end
end

local function AddPlayerESP(p)
	if p==LocalPlayer then return end
	if not p.Character or p.Character:FindFirstChild("__PlayerHL") then return end

	local hl=Instance.new("Highlight")
	hl.Name="__PlayerHL"
	hl.FillColor=PLAYER_COLOR
	hl.OutlineColor=PLAYER_COLOR
	hl.FillTransparency=0.85
	hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee=p.Character
	hl.Parent=p.Character
end

--------------------------------------------------
-- INSTANT PROMPT
--------------------------------------------------
local InstantPrompt=false
for _,obj in ipairs(Workspace:GetDescendants()) do
	if obj:IsA("ProximityPrompt") and not obj:GetAttribute("OriginalHold") then
		obj:SetAttribute("OriginalHold", obj.HoldDuration)
	end
end

local function ApplyInstantPrompt()
	for _,obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			obj.HoldDuration = InstantPrompt and 0 or obj:GetAttribute("OriginalHold")
		end
	end
end

--------------------------------------------------
-- NIGHT GUARD MODE (P)
--------------------------------------------------
local function GetNightGuardGui()
	return LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NightGuardModeGui")
end

Connections.NightGuardKey=UserInputService.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.KeyCode==Enum.KeyCode.P then
		local gui=GetNightGuardGui()
		if gui then gui.Enabled=not gui.Enabled end
	end
end)

--------------------------------------------------
-- UI
--------------------------------------------------
FNAFTab:CreateToggle({
	Name="Enable All Animatronic ESP",
	CurrentValue=false,
	Callback=function(v)
		for n in pairs(Animatronics) do
			Animatronics[n].Enabled=v
			ApplyAnimESP(n)
		end
	end
})

for n in pairs(Animatronics) do
	FNAFTab:CreateToggle({
		Name=n.." ESP",
		CurrentValue=false,
		Callback=function(v)
			Animatronics[n].Enabled=v
			ApplyAnimESP(n)
		end
	})
end

FNAFTab:CreateToggle({
	Name="Night Guard Mode (Keybind: P)",
	CurrentValue=false,
	Callback=function(v)
		local gui=GetNightGuardGui()
		if gui then gui.Enabled=v end
	end
})

JanitorTab:CreateToggle({
	Name="Instant Interact",
	CurrentValue=false,
	Callback=function(v)
		InstantPrompt=v
		ApplyInstantPrompt()
	end
})

SettingsTab:CreateToggle({
	Name="Player ESP",
	CurrentValue=false,
	Callback=function(v)
		for _,p in ipairs(Players:GetPlayers()) do
			if v then AddPlayerESP(p) else ClearPlayerESP(p) end
		end
	end
})

SettingsTab:CreateToggle({
	Name="Fullbright",
	CurrentValue=false,
	Callback=function(v)
		if v then EnableFullbright() else DisableFullbright() end
	end
})

--------------------------------------------------
-- UNLOAD (FULL CLEAN)
--------------------------------------------------
local function DisableAllFeatures()
	for n,data in pairs(Animatronics) do
		data.Enabled=false
		local f=AnimFolder:FindFirstChild(n)
		if f then
			for _,npc in ipairs(f:GetChildren()) do
				ClearAnimESP(npc)
			end
		end
	end

	for _,p in ipairs(Players:GetPlayers()) do
		ClearPlayerESP(p)
	end

	InstantPrompt=false
	ApplyInstantPrompt()
	DisableFullbright()

	local ng=GetNightGuardGui()
	if ng then ng.Enabled=false end
end

local function UnloadScript(auto)
	DisableAllFeatures()

	for _,c in pairs(Connections) do
		if c then c:Disconnect() end
	end

	if auto then
		Rayfield:Notify({
			Title="Script Unloaded",
			Content="Automatically unloaded on death.",
			Duration=5
		})
		task.wait(1.2)
	end

	Rayfield:Destroy()
	if CreditGui then CreditGui:Destroy() end
end

SettingsTab:CreateButton({
	Name="Unload Script",
	Callback=function()
		UnloadScript(false)
	end
})

--------------------------------------------------
-- DEATH HANDLER
--------------------------------------------------
local function HookDeath(char)
	local hum=char:WaitForChild("Humanoid",5)
	if hum then
		hum.Died:Connect(function()
			UnloadScript(true)
		end)
	end
end

if LocalPlayer.Character then HookDeath(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookDeath)

--------------------------------------------------
-- FINAL NOTIFY
--------------------------------------------------
Rayfield:Notify({
	Title="Loaded",
	Content="All features OFF by default.",
	Duration=5
})
