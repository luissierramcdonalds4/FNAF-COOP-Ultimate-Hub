--------------------------------------------------
-- CONFIG
--------------------------------------------------
local REQUIRED_KEY = "Key2"
local KEY_DURATION = 12 * 60 * 60 -- 12 hours

-- UNIQUE SAVE FILE FOR THIS SCRIPT ONLY
local SAVE_FILE = "ProjectNightShift_KeyTime.txt"

local SCRIPT_URL = "https://pastebin.com/raw/pXmjxjHP"
local DISCORD_INVITE = "https://discord.gg/XPzgkHKW7u"

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local HttpService = game:GetService("HttpService")

--------------------------------------------------
-- FILE HELPERS
--------------------------------------------------
local function GetLastKeyTime()
	if isfile(SAVE_FILE) then
		local success, data = pcall(function()
			return tonumber(readfile(SAVE_FILE))
		end)
		if success and data then
			return data
		end
	end
	return 0
end

local function SaveKeyTime()
	writefile(SAVE_FILE, tostring(os.time()))
end

local function IsKeyValid()
	return (os.time() - GetLastKeyTime()) < KEY_DURATION
end

--------------------------------------------------
-- LOAD SCRIPT
--------------------------------------------------
local function LoadScript()
	loadstring(game:HttpGet(SCRIPT_URL, true))()
end

--------------------------------------------------
-- LOAD RAYFIELD
--------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--------------------------------------------------
-- AUTO LOAD IF KEY STILL VALID
--------------------------------------------------
if IsKeyValid() then
	Rayfield:Notify({
		Title = "Access Granted",
		Content = "Key still valid. Launching Project NightShift...",
		Duration = 5
	})

	task.wait(0.5)
	Rayfield:Destroy()
	LoadScript()
	return
end

--------------------------------------------------
-- KEY WINDOW
--------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "Project NightShift",
	LoadingTitle = "Project NightShift",
	LoadingSubtitle = "Key Verification",
	KeySystem = false
})

local KeyTab = Window:CreateTab("Key System", 4483362458)
local KeyInput = ""

--------------------------------------------------
-- KEY INPUT
--------------------------------------------------
KeyTab:CreateInput({
	Name = "Enter Access Key",
	PlaceholderText = "Enter key here",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		KeyInput = text
	end
})

--------------------------------------------------
-- SUBMIT BUTTON
--------------------------------------------------
KeyTab:CreateButton({
	Name = "Submit Key",
	Callback = function()
		if KeyInput == REQUIRED_KEY then
			SaveKeyTime()

			Rayfield:Notify({
				Title = "Success",
				Content = "Key accepted. Launching Project NightShift...",
				Duration = 5
			})

			task.wait(0.5)
			Rayfield:Destroy()
			LoadScript()
		else
			Rayfield:Notify({
				Title = "Invalid Key",
				Content = "Incorrect key. Please try again.",
				Duration = 4
			})
		end
	end
})

--------------------------------------------------
-- DISCORD BUTTON
--------------------------------------------------
KeyTab:CreateButton({
	Name = "📋 Get Key (Join Discord)",
	Callback = function()
		if setclipboard then
			setclipboard(DISCORD_INVITE)
			Rayfield:Notify({
				Title = "Copied",
				Content = "Discord invite copied to clipboard.",
				Duration = 4
			})
		else
			Rayfield:Notify({
				Title = "Error",
				Content = "Clipboard not supported by your executor.",
				Duration = 4
			})
		end
	end
})

--------------------------------------------------
-- NOTICE
--------------------------------------------------
KeyTab:CreateParagraph({
	Title = "Notice",
	Content =
		"This key system is unique to Afton-Robotics.\n\n" ..
		"💰 Earn ~$60 per minute completely automatically\n" ..
		"⏱ ~18,000 in 6 hours with Janitor\n\n" ..
		"You must re-enter the key every 12 hours\n" ..
		"for this script only."
})
