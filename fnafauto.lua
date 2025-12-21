--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- SAFE HRP FETCHER
--------------------------------------------------
local function GetHRP(animName, npcName)
	local anim = Workspace:FindFirstChild("Animatronics")
	if not anim then return nil end
	local folder = anim:FindFirstChild(animName)
	if not folder then return nil end
	local npc = folder:FindFirstChild(npcName)
	if not npc then return nil end
	return npc:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,320,0,150)
main.Position = UDim2.new(0.5,-160,0.1,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

--------------------------------------------------
-- PANELS
--------------------------------------------------
local function Panel(name,pos)
	local f = Instance.new("Frame",main)
	f.Size = UDim2.new(0.48,0,0.45,0)
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Instance.new("UICorner",f)

	local t = Instance.new("TextLabel",f)
	t.Size = UDim2.new(1,-8,1,-8)
	t.Position = UDim2.new(0,4,0,4)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextStrokeTransparency = 0
	t.TextColor3 = Color3.fromRGB(0,255,0)
	t.Text = name .. "\nSAFE"
	return t
end

local BonnieLabel  = Panel("BONNIE",UDim2.new(0.02,0,0.05,0))
local FoxyLabel    = Panel("FOXY",UDim2.new(0.02,0,0.52,0))
local ChicaLabel   = Panel("CHICA",UDim2.new(0.5,0,0.05,0))
local FreddyLabel  = Panel("FREDDY",UDim2.new(0.5,0,0.52,0))

--------------------------------------------------
-- SOUNDS
--------------------------------------------------
local function NewSound(id, looped)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = 0.5
	s.Looped = looped
	s.Parent = workspace
	return s
end

local BonnieAlarm = NewSound("rbxassetid://6308606116", false)
local ChicaAlarm  = NewSound("rbxassetid://73270405391070", false)
local FoxyAlarm   = NewSound("rbxassetid://5603534974", true)
local FreddyAlarm = NewSound("rbxassetid://134627487275898", false)

--------------------------------------------------
-- STATE
--------------------------------------------------
local playedBonnie = false
local playedChica = false
local foxyActive = false
local freddyActive = false
local chicaKitchenTimer = nil
local bonnieDoorTimer = nil
local chicaDoorTimer = nil

--------------------------------------------------
-- CLEAN UNLOAD
--------------------------------------------------
local unloaded = false
local conn

local function Unload()
	if unloaded then return end
	unloaded = true

	if conn then conn:Disconnect() end

	BonnieAlarm:Stop()
	ChicaAlarm:Stop()
	FoxyAlarm:Stop()
	FreddyAlarm:Stop()

	gui:Destroy()
end

--------------------------------------------------
-- DEATH HANDLER
--------------------------------------------------
local function HookDeath(char)
	local hum = char:WaitForChild("Humanoid",5)
	if hum then
		hum.Died:Connect(Unload)
	end
end

if LocalPlayer.Character then HookDeath(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(HookDeath)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------
conn = RunService.RenderStepped:Connect(function()
	if unloaded then return end

	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	local hrp = char.HumanoidRootPart
	local now = os.clock()

	local BonnieHRP  = GetHRP("Bonnie","BonnieNPC")
	local ChicaHRP   = GetHRP("Chica","ChicaNPC")
	local FoxyHRP    = GetHRP("Foxy","FoxyNPC")
	local FreddyHRP  = GetHRP("Freddy","FreddyNPC")

	--------------------------------------------------
	-- BONNIE (14–16 studs, 1.5s)
	--------------------------------------------------
	if BonnieHRP then
		local d = math.floor((hrp.Position - BonnieHRP.Position).Magnitude)

		if d==14 or d==15 or d==16 then
			if not bonnieDoorTimer then
				bonnieDoorTimer = now
			elseif now - bonnieDoorTimer >= 1.5 then
				BonnieLabel.Text="BONNIE\nLEFT DOOR"
				BonnieLabel.TextColor3=Color3.fromRGB(255,0,0)
				if not playedBonnie then
					playedBonnie = true
					BonnieAlarm:Play()
				end
			end
		else
			bonnieDoorTimer = nil
			playedBonnie = false
			BonnieLabel.Text="BONNIE\nSAFE"
			BonnieLabel.TextColor3=Color3.fromRGB(0,255,0)
		end
	end

	--------------------------------------------------
	-- CHICA (DOOR + KITCHEN)
	--------------------------------------------------
	if ChicaHRP then
		local d = math.floor((hrp.Position - ChicaHRP.Position).Magnitude)

		if d==14 or d==15 or d==16 then
			chicaKitchenTimer = nil
			if not chicaDoorTimer then
				chicaDoorTimer = now
			elseif now - chicaDoorTimer >= 1.5 then
				ChicaLabel.Text="CHICA\nRIGHT DOOR"
				ChicaLabel.TextColor3=Color3.fromRGB(255,0,0)
				if not playedChica then
					playedChica = true
					ChicaAlarm:Play()
				end
			end

		elseif d>=50 and d<=65 then
			chicaDoorTimer = nil
			playedChica = false
			if not chicaKitchenTimer then
				chicaKitchenTimer = now
			elseif now - chicaKitchenTimer >= 1 then
				ChicaLabel.Text="CHICA\nKITCHEN"
				ChicaLabel.TextColor3=Color3.fromRGB(255,221,0)
			end

		else
			chicaDoorTimer = nil
			chicaKitchenTimer = nil
			playedChica = false
			ChicaLabel.Text="CHICA\nSAFE"
			ChicaLabel.TextColor3=Color3.fromRGB(0,255,0)
		end
	end

	--------------------------------------------------
	-- FOXY
	--------------------------------------------------
	if FoxyHRP then
		local d = math.floor((hrp.Position - FoxyHRP.Position).Magnitude)

		if d == 74 then
			FoxyLabel.Text="FOXY\nSTAGE 1"
			FoxyLabel.TextColor3=Color3.fromRGB(0,255,0)
			FoxyAlarm:Stop()
			foxyActive = false

		elseif d == 73 then
			FoxyLabel.Text="FOXY\nSTAGE 2"
			FoxyLabel.TextColor3=Color3.fromRGB(255,255,0)
			FoxyAlarm:Stop()
			foxyActive = false

		elseif d == 67 then
			FoxyLabel.Text="FOXY\nOUTSIDE COVE"
			FoxyLabel.TextColor3=Color3.fromRGB(255,165,0)
			FoxyAlarm:Stop()
			foxyActive = false

		elseif d < 61 then
			FoxyLabel.Text="FOXY\nLEFT DOOR CAM-2A"
			FoxyLabel.TextColor3=Color3.fromRGB(255,0,0)
			if not foxyActive then
				foxyActive = true
				FoxyAlarm:Play()
			end
		end
	end

	--------------------------------------------------
	-- FREDDY
	--------------------------------------------------
	if FreddyHRP then
		local d = math.floor((hrp.Position - FreddyHRP.Position).Magnitude)

		if d < 20 then
			FreddyLabel.Text="FREDDY\nCAM-4B"
			FreddyLabel.TextColor3=Color3.fromRGB(255,0,0)
			if not freddyActive then
				freddyActive = true
				FreddyAlarm:Play()
			end
		else
			FreddyLabel.Text="FREDDY\nSAFE"
			FreddyLabel.TextColor3=Color3.fromRGB(0,255,0)
			freddyActive = false
		end
	end
end)
