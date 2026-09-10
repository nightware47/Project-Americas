--!strict
-- PhonePreview_Plugin.lua
-- Roblox Studio Plugin for Live Previewing & Testing the Sky Phone in Studio
-- Location: roblox/plugins/PhonePreview_Plugin.lua

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local toolbar = plugin:CreateToolbar("Sky Systems")
local previewBtn = toolbar:CreateButton(
	"PreviewSkyPhone",
	"Toggle live preview of the Sky Phone UI",
	"rbxassetid://6031075938" -- Phone icon
)

local currentScreenGui: ScreenGui? = nil
local phoneUIInstance: any = nil

local function cleanup()
	if currentScreenGui then
		currentScreenGui:Destroy()
		currentScreenGui = nil
	end
	phoneUIInstance = nil
end

local function togglePreview()
	if currentScreenGui then
		cleanup()
		previewBtn:SetActive(false)
		print("[Sky Phone Plugin] Preview closed.")
		return
	end

	-- Locate PhoneUI & Theme
	local componentsFolder = script.Parent.Parent:FindFirstChild("components")
	if not componentsFolder then
		warn("[Sky Phone Plugin] Could not find roblox/components folder!")
		return
	end

	local PhoneUIModule = componentsFolder:FindFirstChild("PhoneUI") :: ModuleScript?
	if not PhoneUIModule then
		warn("[Sky Phone Plugin] Could not find PhoneUI module in components!")
		return
	end

	local PhoneUI = require(PhoneUIModule)

	local gui = Instance.new("ScreenGui")
	gui.Name = "SkyPhone_StudioPreview"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 1000
	gui.Parent = CoreGui
	currentScreenGui = gui

	phoneUIInstance = PhoneUI.new(gui)
	phoneUIInstance:SetVisible(true)
	phoneUIInstance:Unlock()

	-- Hook mock callbacks so actions respond visually in Studio preview
	phoneUIInstance.OnCallStarted = function(number: string)
		phoneUIInstance:ShowNotification("Calling...", "Dialing " .. number, "📞")
	end

	phoneUIInstance.OnMessageSent = function(recipient: string, text: string)
		phoneUIInstance:ShowNotification("Message Sent", "Sent to " .. recipient, "💬")
	end

	phoneUIInstance.OnTransferMoney = function(recipient: string, amount: number)
		phoneUIInstance:ShowNotification("Bank", string.format("Sent $%d to %s", amount, recipient), "💸")
	end

	phoneUIInstance.OnVehicleAction = function(vehicleId: string, action: string)
		phoneUIInstance:ShowNotification("Vehicle", "Action: " .. action, "🚗")
	end

	previewBtn:SetActive(true)
	print("[Sky Phone Plugin] Sky Phone Studio Preview active! Click apps or home bar to test.")
end

previewBtn.Click:Connect(togglePreview)
plugin.Unloading:Connect(cleanup)
