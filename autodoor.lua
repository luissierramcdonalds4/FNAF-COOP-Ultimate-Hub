-- Auto Door + Foxy Staller by Afton-Robotics
-- Based on Dark332 FINAL STABLE Auto Door Script
-- Auto Door Logic UNCHANGED

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- SAFE HRP FETCH (UNCHANGED)
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
-- STATE
--------------------------------------------------

local autoDoorEnabled = false
local foxyStallerEnabled = false

local doorState = { Left = false, Right = false }
local cooldown = { Left = 0, Right = 0 }

local bonnieTimer = nil
local chicaTimer = nil

local connections = {}

--------------------------------------------------
-- DARK332 DOOR CLICK (UNCHANGED)
--------------------------------------------------

local function clickDoor(side, close)
    local now = tick()
    if cooldown[side] > now then return end
    if doorState[side] == close then return end

    pcall(function()
        local buttons = Workspace.GameTriggers.OfficeButtons
        local button = buttons:FindFirstChild(side .. "DoorButton")
        if not button or not button:FindFirstChild("Part") then return end

        local part = button.Part

        if part:FindFirstChild("ProximityPrompt") then
            fireproximityprompt(part.ProximityPrompt)
        end

        if part:FindFirstChild("ClickDetector") then
            fireclickdetector(part.ClickDetector)
        end

        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
        if remotes and remotes:FindFirstChild("playerUsedClickOnObjectEvent") then
            remotes.playerUsedClickOnObjectEvent:FireServer(part)
        end

        doorState[side] = close
        cooldown[side] = now + 0.8
    end)
end

--------------------------------------------------
-- AUTO DOOR LOGIC (UNCHANGED)
--------------------------------------------------

local function autoDoor()
    if not autoDoorEnabled then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local now = os.clock()

    local BonnieHRP = GetHRP("Bonnie","BonnieNPC")
    local ChicaHRP  = GetHRP("Chica","ChicaNPC")
    local FoxyHRP   = GetHRP("Foxy","FoxyNPC")

    -- LEFT DOOR
    local closeLeft = false

    if BonnieHRP then
        local d = math.floor((hrp.Position - BonnieHRP.Position).Magnitude)
        if d == 14 or d == 15 or d == 16 then
            if not bonnieTimer then
                bonnieTimer = now
            elseif now - bonnieTimer >= 1.5 then
                closeLeft = true
            end
        else
            bonnieTimer = nil
        end
    else
        bonnieTimer = nil
    end

    if FoxyHRP then
        local d = math.floor((hrp.Position - FoxyHRP.Position).Magnitude)
        if d <= 61 then
            closeLeft = true
        end
    end

    -- RIGHT DOOR
    local closeRight = false

    if ChicaHRP then
        local d = math.floor((hrp.Position - ChicaHRP.Position).Magnitude)
        if d == 14 or d == 15 or d == 16 then
            if not chicaTimer then
                chicaTimer = now
            elseif now - chicaTimer >= 2.5 then
                closeRight = true
            end
        else
            chicaTimer = nil
        end
    else
        chicaTimer = nil
    end

    clickDoor("Left", closeLeft)
    clickDoor("Right", closeRight)
end

--------------------------------------------------
-- FOXY STALLER (UNCHANGED)
--------------------------------------------------

task.spawn(function()
    while true do
        if foxyStallerEnabled then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.07)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            task.wait(0.07)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.07)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            task.wait(1.5)
        else
            task.wait(0.1)
        end
    end
end)

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,160)
frame.Position = UDim2.new(0.5,-130,0.5,-80)
frame.BackgroundColor3 = Color3.fromRGB(10,10,15)
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.new(1,1,1)
stroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Auto Door + Foxy Staller"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(180,120,255)

--------------------------------------------------
-- FOXY WARNING POPUP
--------------------------------------------------

local warningFrame = Instance.new("Frame", gui)
warningFrame.Size = UDim2.new(0,300,0,120)
warningFrame.Position = UDim2.new(0.5,-150,0.5,-60)
warningFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
warningFrame.Visible = false
warningFrame.ZIndex = 10
Instance.new("UICorner", warningFrame)

local wStroke = Instance.new("UIStroke", warningFrame)
wStroke.Color = Color3.fromRGB(255,170,0)
wStroke.Thickness = 2

local warningText = Instance.new("TextLabel", warningFrame)
warningText.Size = UDim2.new(1,-20,1,-50)
warningText.Position = UDim2.new(0,10,0,10)
warningText.BackgroundTransparency = 1
warningText.TextWrapped = true
warningText.Text = "⚠ Put your camera on CAM 4B before toggling Foxy Staller"
warningText.Font = Enum.Font.GothamBold
warningText.TextSize = 14
warningText.TextColor3 = Color3.fromRGB(255,200,80)
warningText.ZIndex = 11

local okButton = Instance.new("TextButton", warningFrame)
okButton.Size = UDim2.new(0.5,-15,0,30)
okButton.Position = UDim2.new(0.25,0,1,-40)
okButton.Text = "OK"
okButton.Font = Enum.Font.GothamBold
okButton.TextSize = 14
okButton.BackgroundColor3 = Color3.fromRGB(60,60,80)
okButton.TextColor3 = Color3.fromRGB(255,200,80)
okButton.ZIndex = 11
Instance.new("UICorner", okButton)

--------------------------------------------------
-- TOGGLES
--------------------------------------------------

local function makeToggle(text, yPos, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = UDim2.new(0,10,0,yPos)
    btn.Text = text .. ": OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.TextColor3 = Color3.fromRGB(180,120,255)
    Instance.new("UICorner", btn)

    local state = false
    local acknowledged = false

    btn.MouseButton1Click:Connect(function()
        if text == "Foxy Staller" and not acknowledged then
            warningFrame.Visible = true
            return
        end

        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)

    if text == "Foxy Staller" then
        okButton.MouseButton1Click:Connect(function()
            acknowledged = true
            warningFrame.Visible = false
        end)
    end
end

makeToggle("Auto Door", 40, function(v)
    autoDoorEnabled = v
end)

makeToggle("Foxy Staller", 80, function(v)
    foxyStallerEnabled = v
end)

--------------------------------------------------
-- LOOP + CLEAN UNLOAD
--------------------------------------------------

connections[#connections+1] = RunService.Heartbeat:Connect(autoDoor)

LocalPlayer.CharacterAdded:Connect(function()
    autoDoorEnabled = false
    foxyStallerEnabled = false
    for _,c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    gui:Destroy()
end)

print("Auto Door + Foxy Staller loaded successfully")
