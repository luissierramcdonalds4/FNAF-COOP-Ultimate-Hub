--------------------------------------------------
-- CONFIG
--------------------------------------------------
local REQUIRED_KEY = "5735932"
local KEY_DURATION = 2 * 60 * 60 -- 2 hours

-- IMPORTANT: UNIQUE SAVE FILE FOR THIS SCRIPT ONLY
local SAVE_FILE = "FNAF_COOP_FNAFAUTO_V2_KeyTime.txt"

local SCRIPT_URL = "https://raw.githubusercontent.com/luissierramcdonalds4/FNAF-COOP-Ultimate-Hub/main/fnafautov2.lua"

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
-- AUTO-LOAD IF KEY STILL VALID (FOR THIS SCRIPT ONLY)
--------------------------------------------------
if IsKeyValid() then
	Rayfield:Notify({
		Title = "Access Granted",
		Content = "Key still valid for this script. Launching...",
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
	Name = "FNAF: COOP Auto System",
	LoadingTitle = "FNAF: COOP",
	LoadingSubtitle = "Key Verification",
	KeySystem = false
})

local KeyTab = Window:CreateTab("Key System", 4483362458)
local KeyInput = ""

KeyTab:CreateInput({
	Name = "Enter Access Key",
	PlaceholderText = "Numbers only",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		KeyInput = text
	end
})

KeyTab:CreateButton({
	Name = "Submit Key",
	Callback = function()
		if KeyInput == REQUIRED_KEY then
			SaveKeyTime()

			Rayfield:Notify({
				Title = "Success",
				Content = "Key accepted. Launching script...",
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
-- DISCORD BUTTON (NEW)
--------------------------------------------------
KeyTab:CreateButton({
	Name = "Get Key (Join Discord)",
	Callback = function()
		if setclipboard then
			setclipboard("https://discord.gg/dY6XJ2WDaU")
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
		"This key system is separate from other scripts.\n\n" ..
		"You must re-enter the key every 2 hours\n" ..
		"specifically for this script."
})
