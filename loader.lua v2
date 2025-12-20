--------------------------------------------------
-- CONFIG
--------------------------------------------------
local REQUIRED_KEY = "5735932"
local KEY_DURATION = 12 * 60 * 60 -- 12 hours
local SAVE_FILE = "FNAF_COOP_KeyTime.txt"

local HUB_URL = "https://raw.githubusercontent.com/luissierramcdonalds4/FNAF-COOP-Ultimate-Hub/main/loader.lua"

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
-- LOAD HUB
--------------------------------------------------
local function LoadHub()
	loadstring(game:HttpGet(HUB_URL))()
end

--------------------------------------------------
-- LOAD RAYFIELD
--------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--------------------------------------------------
-- AUTO-LOAD HUB IF KEY STILL VALID
--------------------------------------------------
if IsKeyValid() then
	Rayfield:Notify({
		Title = "Access Granted",
		Content = "Key still valid. Launching hub...",
		Duration = 5
	})

	task.wait(0.5)
	Rayfield:Destroy()
	LoadHub()
	return
end

--------------------------------------------------
-- KEY WINDOW
--------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "FNAF: COOP Ultimate Script",
	LoadingTitle = "FNAF: COOP",
	LoadingSubtitle = "Key System",
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
				Content = "Key accepted. Launching hub...",
				Duration = 5
			})

			task.wait(0.5)
			Rayfield:Destroy()
			LoadHub()
		else
			Rayfield:Notify({
				Title = "Invalid Key",
				Content = "Incorrect key. Please try again.",
				Duration = 4
			})
		end
	end
})

KeyTab:CreateParagraph({
	Title = "Notice",
	Content =
		"The access key is required every 12 hours.\n\n" ..
		"If your key expires, the loader will reappear\n" ..
		"and you must enter the key again."
})
