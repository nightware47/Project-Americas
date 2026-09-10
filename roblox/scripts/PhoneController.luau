--!strict
-- PhoneController.lua
-- Client-side controller for the Sky Phone in Roblox (handles keybinds, networking & UI orchestration)
-- Place in: StarterPlayerScripts or StarterGui
-- Location: roblox/scripts/PhoneController.lua

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

-- Locate PhoneUI & Theme components
local componentsFolder = ReplicatedStorage:FindFirstChild("PhoneComponents") or script.Parent
local PhoneUI = require(componentsFolder:WaitForChild("PhoneUI") :: ModuleScript)
local PhoneTheme = require(componentsFolder:WaitForChild("PhoneTheme") :: ModuleScript)

local PhoneController = {}
local phoneInstance: any = nil
local networkFolder: Folder? = nil

--------------------------------------------------------------------------------
-- Procedural Sound Effects
--------------------------------------------------------------------------------
local function playSound(soundType: string)
	local sound = Instance.new("Sound")
	sound.Volume = 0.5
	sound.Parent = SoundService

	if soundType == "click" then
		sound.SoundId = "rbxassetid://9114223175" -- Soft UI click
		sound.Volume = 0.25
	elseif soundType == "notif" then
		sound.SoundId = "rbxassetid://9114221779" -- Notification chime
		sound.Volume = 0.4
	elseif soundType == "ring" then
		sound.SoundId = "rbxassetid://9114221590" -- Phone ringtone
		sound.Looped = true
		sound.Volume = 0.6
	elseif soundType == "whoosh" then
		sound.SoundId = "rbxassetid://9114222883" -- Message sent whoosh
		sound.Volume = 0.35
	end

	sound:Play()
	if not sound.Looped then
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	return sound
end

--------------------------------------------------------------------------------
-- On-Screen Floating Quick Toggle Button (for Mobile & PC convenience)
--------------------------------------------------------------------------------
local function createFloatingWidget(onToggle: () -> ())
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SkyPhoneWidgetGui"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 90
	screenGui.Parent = playerGui

	local pill = Instance.new("TextButton")
	pill.Name = "PhoneTogglePill"
	pill.Size = UDim2.new(0, 48, 0, 48)
	pill.AnchorPoint = Vector2.new(1, 1)
	pill.Position = UDim2.new(1, -24, 1, -24)
	pill.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
	pill.Text = "📱"
	pill.Font = PhoneTheme.Fonts.Bold
	pill.TextSize = 22
	pill.BorderSizePixel = 0
	pill.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 24)
	corner.Parent = pill

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 50, 60)
	stroke.Thickness = 1.5
	stroke.Parent = pill

	pill.MouseButton1Click:Connect(function()
		playSound("click")
		onToggle()
	end)
end

--------------------------------------------------------------------------------
-- Controller Initialization
--------------------------------------------------------------------------------
function PhoneController.Init()
	print("[PhoneController] Initializing Sky Phone Client...")

	-- 1. Create Main Phone ScreenGui
	local phoneGui = Instance.new("ScreenGui")
	phoneGui.Name = "SkyPhoneGui"
	phoneGui.ResetOnSpawn = false
	phoneGui.DisplayOrder = 100
	phoneGui.Parent = playerGui

	-- 2. Mount Phone UI
	phoneInstance = PhoneUI.new(phoneGui)

	-- 3. Setup Quick Toggle Floating Button
	createFloatingWidget(function()
		phoneInstance:Toggle()
	end)

	-- 4. Listen for Toggle Hotkey ('M' key by default)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.M then
			playSound("click")
			phoneInstance:Toggle()
		end
	end)

	-- 5. Hook Phone UI Event Callbacks to Server Remote Events
	networkFolder = ReplicatedStorage:FindFirstChild("PhoneNetwork") :: Folder?

	phoneInstance.OnCallStarted = function(number: string)
		playSound("click")
		if networkFolder and networkFolder:FindFirstChild("StartCall") then
			(networkFolder:FindFirstChild("StartCall") :: RemoteFunction):InvokeServer(number)
		end
	end

	phoneInstance.OnCallEnded = function()
		playSound("click")
		if networkFolder and networkFolder:FindFirstChild("EndCall") then
			(networkFolder:FindFirstChild("EndCall") :: RemoteFunction):InvokeServer()
		end
	end

	phoneInstance.OnMessageSent = function(recipient: string, text: string)
		playSound("whoosh")
		if networkFolder and networkFolder:FindFirstChild("SendMessage") then
			(networkFolder:FindFirstChild("SendMessage") :: RemoteFunction):InvokeServer(recipient, text)
		end
	end

	phoneInstance.OnTransferMoney = function(recipient: string, amount: number)
		playSound("click")
		if networkFolder and networkFolder:FindFirstChild("TransferMoney") then
			(networkFolder:FindFirstChild("TransferMoney") :: RemoteFunction):InvokeServer(recipient, amount)
		end
	end

	phoneInstance.OnVehicleAction = function(vehicleId: string, action: string)
		playSound("click")
		if networkFolder and networkFolder:FindFirstChild("VehicleAction") then
			(networkFolder:FindFirstChild("VehicleAction") :: RemoteFunction):InvokeServer(vehicleId, action)
		end
	end

	-- 6. Listen for Server-Dispatched Push Notifications & Events
	if networkFolder then
		local notifEvent = networkFolder:FindFirstChild("PushNotification") :: RemoteEvent?
		if notifEvent then
			notifEvent.OnClientEvent:Connect(function(title: string, message: string, glyph: string?)
				playSound("notif")
				phoneInstance:ShowNotification(title, message, glyph)
			end)
		end

		local balanceEvent = networkFolder:FindFirstChild("UpdateBalance") :: RemoteEvent?
		if balanceEvent then
			balanceEvent.OnClientEvent:Connect(function(newBalance: number)
				phoneInstance.State.Balance = newBalance
				if phoneInstance.BankBalanceLabel then
					phoneInstance.BankBalanceLabel.Text = string.format("$%s", tostring(newBalance))
				end
			end)
		end
	end

	print("[PhoneController] Sky Phone Client Ready. Press 'M' or tap the phone widget to toggle.")
end

-- Auto-start if placed directly as a LocalScript
if script:IsA("LocalScript") then
	PhoneController.Init()
end

return PhoneController
