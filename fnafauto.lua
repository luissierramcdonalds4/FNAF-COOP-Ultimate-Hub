--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------
-- SAFE HRP FETCHER (CRITICAL FIX)
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
gui.Name = "DoorWarningGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(0,300,0,18)
credit.Position = UDim2.new(0.5,-150,0.06,0)
credit.BackgroundTransparency = 1
credit.Text = "Script made by Afton-Robotics"
credit.Font = Enum.Font.Gotham
credit.TextSize = 14
credit.TextColor3 = Color3.fromRGB(180,180,180)
credit.Parent = gui

local main = Instance.new("Frame")
main.Size = UDim2.new(0,320,0,150)
main.Position = UDim2.new(0.5,-160,0.09,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

--------------------------------------------------
-- PANEL CREATOR
--------------------------------------------------
local function Panel(name,pos)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0.48,0,0.45,0)
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(25,25,25)
	f.BorderSizePixel = 0
	f.Parent = main
	Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1,-8,1,-8)
	t.Position = UDim2.new(0,4,0,4)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextStrokeTransparency = 0
	t.TextColor3 = Color3.fromRGB(0,255,0)
	t.Text = name .. "\nSAFE"
	t.Parent = f
	return t
end

local BonnieLabel  = Panel("BONNIE",  UDim2.new(0.02,0,0.05,0))
local FoxyLabel    = Panel("FOXY",    UDim2.new(0.02,0,0.52,0))
local ChicaLabel   = Panel("CHICA",   UDim2.new(0.50,0,0.05,0))
local FreddyLabel  = Panel("FREDDY",  UDim2.new(0.50,0,0.52,0))

--------------------------------------------------
-- TIMERS
--------------------------------------------------
local BonnieT, ChicaDoorT, ChicaKitchenT = nil,nil,nil
local REQUIRED = 0.6
local KITCHEN = 1.5

--------------------------------------------------
-- MAIN LOOP (FIXED)
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local now = os.clock()

	--------------------------------------------------
	-- FETCH HRPS (EVERY FRAME)
	--------------------------------------------------
	local BonnieHRP  = GetHRP("Bonnie","BonnieNPC")
	local ChicaHRP   = GetHRP("Chica","ChicaNPC")
	local FoxyHRP    = GetHRP("Foxy","FoxyNPC")
	local FreddyHRP  = GetHRP("Freddy","FreddyNPC")

	--------------------------------------------------
	-- BONNIE
	--------------------------------------------------
	if BonnieHRP then
		local d = math.floor((hrp.Position - BonnieHRP.Position).Magnitude)
		if d>=14 and d<=16 then
			if not BonnieT then BonnieT=now end
			if now-BonnieT>=REQUIRED then
				BonnieLabel.Text="LEFT DOOR"
				BonnieLabel.TextColor3=Color3.fromRGB(255,0,0)
			end
		else
			BonnieT=nil
			BonnieLabel.Text="BONNIE\nSAFE"
			BonnieLabel.TextColor3=Color3.fromRGB(0,255,0)
		end
	end

	--------------------------------------------------
	-- CHICA
	--------------------------------------------------
	if ChicaHRP then
		local d = math.floor((hrp.Position - ChicaHRP.Position).Magnitude)
		if d>=14 and d<=16 then
			ChicaKitchenT=nil
			if not ChicaDoorT then ChicaDoorT=now end
			if now-ChicaDoorT>=REQUIRED then
				ChicaLabel.Text="RIGHT DOOR"
				ChicaLabel.TextColor3=Color3.fromRGB(255,0,0)
			end
		elseif d>=50 and d<=65 then
			ChicaDoorT=nil
			if not ChicaKitchenT then ChicaKitchenT=now end
			if now-ChicaKitchenT>=KITCHEN then
				ChicaLabel.Text="CHICA\nKITCHEN"
				ChicaLabel.TextColor3=Color3.fromRGB(255,221,0)
			end
		else
			ChicaDoorT=nil
			ChicaKitchenT=nil
			ChicaLabel.Text="CHICA\nSAFE"
			ChicaLabel.TextColor3=Color3.fromRGB(0,255,0)
		end
	end

	--------------------------------------------------
	-- FOXY
	--------------------------------------------------
	if FoxyHRP then
		local d = math.floor((hrp.Position - FoxyHRP.Position).Magnitude)
		if d==74 then
			FoxyLabel.Text="STAGE 1"
			FoxyLabel.TextColor3=Color3.fromRGB(0,255,0)
		elseif d==73 then
			FoxyLabel.Text="STAGE 2"
			FoxyLabel.TextColor3=Color3.fromRGB(255,255,0)
		elseif d==67 then
			FoxyLabel.Text="OUTSIDE COVE"
			FoxyLabel.TextColor3=Color3.fromRGB(255,165,0)
		elseif d<61 then
			FoxyLabel.Text="LEFT DOOR CAM-2A"
			FoxyLabel.TextColor3=Color3.fromRGB(255,0,0)
		end
	end

	--------------------------------------------------
	-- FREDDY
	--------------------------------------------------
	if FreddyHRP then
		local d = math.floor((hrp.Position - FreddyHRP.Position).Magnitude)
		if d==103 then
			FreddyLabel.Text="CAM-1A"
			FreddyLabel.TextColor3=Color3.fromRGB(0,255,0)
		elseif (d>=79 and d<=102) and not (d>=86 and d<=92) then
			FreddyLabel.Text="CAM-1B"
			FreddyLabel.TextColor3=Color3.fromRGB(0,255,0)
		elseif d>=86 and d<=92 then
			FreddyLabel.Text="CAM-7"
			FreddyLabel.TextColor3=Color3.fromRGB(0,255,0)
		elseif d>=40 and d<=60 then
			FreddyLabel.Text="CAM-6"
			FreddyLabel.TextColor3=Color3.fromRGB(255,255,0)
		elseif d>=20 and d<=42 then
			FreddyLabel.Text="CAM-4A"
			FreddyLabel.TextColor3=Color3.fromRGB(255,165,0)
		elseif d<20 then
			FreddyLabel.Text="CAM-4B"
			FreddyLabel.TextColor3=Color3.fromRGB(255,0,0)
		else
			FreddyLabel.Text="FREDDY\nSAFE"
			FreddyLabel.TextColor3=Color3.fromRGB(0,255,0)
		end
	end
end)
