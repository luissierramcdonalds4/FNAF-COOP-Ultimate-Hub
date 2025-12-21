--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--------------------------------------------------
-- ANIMATRONIC HRPS
--------------------------------------------------
local AnimFolder = Workspace:WaitForChild("Animatronics")

local BonnieHRP = AnimFolder:WaitForChild("Bonnie"):WaitForChild("BonnieNPC"):WaitForChild("HumanoidRootPart")
local ChicaHRP  = AnimFolder:WaitForChild("Chica"):WaitForChild("ChicaNPC"):WaitForChild("HumanoidRootPart")
local FreddyHRP = AnimFolder:WaitForChild("Freddy"):WaitForChild("FreddyNPC"):WaitForChild("HumanoidRootPart")

--------------------------------------------------
-- GUI
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "DoorWarningGui"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 150)
main.Position = UDim2.new(0.5, -160, 0.1, 0)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------
do
	local dragging, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	main.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--------------------------------------------------
-- PANEL CREATOR
--------------------------------------------------
local function CreatePanel(name, pos)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.48, 0, 0.45, 0)
	frame.Position = pos
	frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
	frame.BorderSizePixel = 0
	frame.Parent = main
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -8, 1, -8)
	label.Position = UDim2.new(0, 4, 0, 4)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextStrokeTransparency = 0
	label.TextColor3 = Color3.fromRGB(0,255,0)
	label.Text = name .. "\nSAFE"
	label.Parent = frame

	return label
end

--------------------------------------------------
-- PANELS
--------------------------------------------------
local BonnieLabel = CreatePanel("BONNIE",  UDim2.new(0.02,0,0.05,0))
local FoxyLabel   = CreatePanel("FOXY",    UDim2.new(0.02,0,0.52,0))
local ChicaLabel  = CreatePanel("CHICA",   UDim2.new(0.50,0,0.05,0))
local FreddyLabel = CreatePanel("FREDDY",  UDim2.new(0.50,0,0.52,0))

--------------------------------------------------
-- FREDDY KNOCK SOUND
--------------------------------------------------
local FreddyKnock = Instance.new("Sound")
FreddyKnock.SoundId = "rbxassetid://9113420770" -- knocking sound
FreddyKnock.Volume = 1.3
FreddyKnock.Looped = false
FreddyKnock.Parent = SoundService

local FreddyKnockPlaying = false

--------------------------------------------------
-- TIMERS
--------------------------------------------------
local BONNIE_ACTIVE = false
local BonnieStart = nil
local REQUIRED_TIME = 0.6

--------------------------------------------------
-- LOOP
--------------------------------------------------
RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local now = os.clock()

	--------------------------------------------------
	-- BONNIE (UNCHANGED)
	--------------------------------------------------
	local bDist = math.floor((hrp.Position - BonnieHRP.Position).Magnitude)

	if bDist >= 14 and bDist <= 16 then
		if not BonnieStart then BonnieStart = now end
		if now - BonnieStart >= REQUIRED_TIME then
			BonnieLabel.Text = "LEFT DOOR"
			BonnieLabel.TextColor3 = Color3.fromRGB(255,0,0)
		end
	else
		BonnieStart = nil
		BonnieLabel.Text = "BONNIE\nSAFE"
		BonnieLabel.TextColor3 = Color3.fromRGB(0,255,0)
	end

	--------------------------------------------------
	-- FREDDY (WITH KNOCK)
	--------------------------------------------------
	local fDist = math.floor((hrp.Position - FreddyHRP.Position).Magnitude)

	if fDist == 103 then
		FreddyLabel.Text = "CAM-1A"
		FreddyLabel.TextColor3 = Color3.fromRGB(0,255,0)
		FreddyKnockPlaying = false

	elseif (fDist >= 79 and fDist <= 102) and not (fDist >= 86 and fDist <= 92) then
		FreddyLabel.Text = "CAM-1B"
		FreddyLabel.TextColor3 = Color3.fromRGB(0,255,0)
		FreddyKnockPlaying = false

	elseif fDist >= 86 and fDist <= 92 then
		FreddyLabel.Text = "CAM-7"
		FreddyLabel.TextColor3 = Color3.fromRGB(0,255,0)
		FreddyKnockPlaying = false

	elseif fDist >= 40 and fDist <= 60 then
		FreddyLabel.Text = "CAM-6"
		FreddyLabel.TextColor3 = Color3.fromRGB(255,255,0)
		FreddyKnockPlaying = false

	elseif fDist >= 20 and fDist <= 42 then
		FreddyLabel.Text = "CAM-4A"
		FreddyLabel.TextColor3 = Color3.fromRGB(255,165,0)
		FreddyKnockPlaying = false

	elseif fDist < 20 then
		FreddyLabel.Text = "CAM-4B"
		FreddyLabel.TextColor3 = Color3.fromRGB(255,0,0)

		if not FreddyKnockPlaying then
			FreddyKnockPlaying = true
			FreddyKnock:Play()
			task.delay(2, function()
				FreddyKnock:Stop()
				FreddyKnockPlaying = false
			end)
		end
	else
		FreddyLabel.Text = "FREDDY\nSAFE"
		FreddyLabel.TextColor3 = Color3.fromRGB(0,255,0)
		FreddyKnockPlaying = false
	end
end)
