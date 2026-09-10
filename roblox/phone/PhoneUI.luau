--!strict
-- PhoneUI.lua
-- Native Roblox Luau UI Component for Sky Phone (iOS 17/18 Inset Grouped / Dynamic Island Architecture)
-- Location: roblox/components/PhoneUI.lua

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local currentFolder = script.Parent or script
local PhoneTheme = require(currentFolder:WaitForChild("PhoneTheme") :: ModuleScript)

local PhoneUI = {}
PhoneUI.__index = PhoneUI

export type PhoneState = {
	IsOpen: boolean,
	IsLocked: boolean,
	CurrentApp: string?,
	ActiveCall: { Contact: string, Number: string, StartTime: number }?,
	UnreadMessages: number,
	Balance: number,
	Cash: number,
	AirplaneMode: boolean,
	WifiEnabled: boolean,
	BluetoothEnabled: boolean,
	DarkMode: boolean,
}

function PhoneUI.new(parentGui: ScreenGui?)
	local self = setmetatable({}, PhoneUI)

	self.State = {
		IsOpen = false,
		IsLocked = true,
		CurrentApp = nil,
		ActiveCall = nil,
		UnreadMessages = 2,
		Balance = 12540,
		Cash = 340,
		AirplaneMode = false,
		WifiEnabled = true,
		BluetoothEnabled = true,
		DarkMode = true,
	} :: PhoneState

	-- Callbacks to be hooked by PhoneController
	self.OnCallStarted = nil :: ((number: string) -> ())?
	self.OnCallEnded = nil :: (() -> ())?
	self.OnMessageSent = nil :: ((recipient: string, text: string) -> ())?
	self.OnTransferMoney = nil :: ((recipient: string, amount: number) -> ())?
	self.OnVehicleAction = nil :: ((vehicleId: string, action: string) -> ())?

	self:BuildUI(parentGui)
	self:StartClockLoop()

	return self
end

--------------------------------------------------------------------------------
-- Helper UI Element Constructors
--------------------------------------------------------------------------------
local function makeCorner(radius: number, parent: Instance): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function makeStroke(color: Color3, thickness: number, parent: Instance, transparency: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function makePadding(top: number, bottom: number, left: number, right: number, parent: Instance): UIPadding
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, top)
	pad.PaddingBottom = UDim.new(0, bottom)
	pad.PaddingLeft = UDim.new(0, left)
	pad.PaddingRight = UDim.new(0, right)
	pad.Parent = parent
	return pad
end

--------------------------------------------------------------------------------
-- UI Construction
--------------------------------------------------------------------------------
function PhoneUI:BuildUI(parentGui: ScreenGui?)
	local gui = parentGui
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "SkyPhoneGui"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.DisplayOrder = 100
		local localPlayer = Players.LocalPlayer
		if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
			gui.Parent = localPlayer.PlayerGui
		end
	end
	self.Gui = gui

	local D = PhoneTheme.Dimensions
	local C = PhoneTheme.Colors

	-- 1. Outer Phone Chassis (Hardware Frame)
	local chassis = Instance.new("Frame")
	chassis.Name = "PhoneChassis"
	chassis.Size = UDim2.new(0, D.PhoneWidth, 0, D.PhoneHeight)
	chassis.AnchorPoint = Vector2.new(1, 1)
	chassis.Position = UDim2.new(1, -24, 1, 680) -- Hidden off-screen by default
	chassis.BackgroundColor3 = C.PhoneBezel
	chassis.BorderSizePixel = 0
	chassis.ClipsDescendants = false
	chassis.Parent = gui
	self.Chassis = chassis

	makeCorner(D.BezelRadius, chassis)
	makeStroke(C.PhoneBorder, 2.5, chassis)

	-- Outer Glass Bevel Effect
	local bevelHighlight = Instance.new("Frame")
	bevelHighlight.Name = "BevelHighlight"
	bevelHighlight.Size = UDim2.new(1, -4, 1, -4)
	bevelHighlight.Position = UDim2.new(0, 2, 0, 2)
	bevelHighlight.BackgroundTransparency = 1
	bevelHighlight.BorderSizePixel = 0
	bevelHighlight.Parent = chassis
	makeCorner(D.BezelRadius - 2, bevelHighlight)
	makeStroke(Color3.fromRGB(70, 70, 80), 1, bevelHighlight, 0.6)

	-- 2. Inner Screen Container (CanvasGroup for perfect curved corner clipping)
	local screen = Instance.new("CanvasGroup")
	screen.Name = "Screen"
	screen.Size = UDim2.new(1, -12, 1, -12)
	screen.Position = UDim2.new(0, 6, 0, 6)
	screen.BackgroundColor3 = C.ScreenBg
	screen.BorderSizePixel = 0
	screen.GroupTransparency = 0
	screen.Parent = chassis
	self.Screen = screen
	makeCorner(D.ScreenRadius, screen)

	-- Screen Wallpaper
	local wallpaper = Instance.new("Frame")
	wallpaper.Name = "Wallpaper"
	wallpaper.Size = UDim2.new(1, 0, 1, 0)
	wallpaper.BackgroundColor3 = C.WallpaperDark
	wallpaper.BorderSizePixel = 0
	wallpaper.Parent = screen
	self.Wallpaper = wallpaper

	-- Wallpaper Gradient
	local wallGrad = Instance.new("UIGradient")
	wallGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 45, 65)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 24, 38)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 18)),
	})
	wallGrad.Rotation = 45
	wallGrad.Parent = wallpaper

	-- 3. Dynamic Island (Expandable Hardware Notch)
	self:BuildDynamicIsland(screen)

	-- 4. Status Bar (Time, Wifi, Battery)
	self:BuildStatusBar(screen)

	-- 5. Home Springboard (App Grid & Widgets)
	self:BuildSpringboard(screen)

	-- 6. Frosted Glass Dock (Persistent Hero Apps)
	self:BuildDock(screen)

	-- 7. Lock Screen Overlay
	self:BuildLockScreen(screen)

	-- 8. In-App Screens Container
	local appContainer = Instance.new("Frame")
	appContainer.Name = "AppContainer"
	appContainer.Size = UDim2.new(1, 0, 1, -54)
	appContainer.Position = UDim2.new(0, 0, 0, 36)
	appContainer.BackgroundTransparency = 1
	appContainer.Visible = false
	appContainer.Parent = screen
	self.AppContainer = appContainer

	-- 9. Home Indicator (Bottom Swipe Bar)
	self:BuildHomeIndicator(screen)

	-- 10. Notification Dropdown Banner
	self:BuildNotificationBanner(screen)

	-- Build individual App Pages
	self:BuildPhoneApp()
	self:BuildMessagesApp()
	self:BuildBankApp()
	self:BuildGarageApp()
	self:BuildSettingsApp()
	self:BuildNotesApp()
	self:BuildCameraApp()
end

--------------------------------------------------------------------------------
-- Dynamic Island
--------------------------------------------------------------------------------
function PhoneUI:BuildDynamicIsland(parent: Instance)
	local D = PhoneTheme.Dimensions
	local C = PhoneTheme.Colors

	local island = Instance.new("TextButton")
	island.Name = "DynamicIsland"
	island.Size = UDim2.new(0, D.IslandWidth, 0, D.IslandHeight)
	island.AnchorPoint = Vector2.new(0.5, 0)
	island.Position = UDim2.new(0.5, 0, 0, 9)
	island.BackgroundColor3 = C.DynamicIsland
	island.Text = ""
	island.AutoButtonColor = false
	island.BorderSizePixel = 0
	island.ZIndex = 50
	island.Parent = parent
	self.DynamicIsland = island

	makeCorner(D.IslandRadius, island)
	makeStroke(C.IslandStroke, 1, island, 0.4)

	-- Camera Lens Circle inside Island
	local lens = Instance.new("Frame")
	lens.Name = "Lens"
	lens.Size = UDim2.new(0, 10, 0, 10)
	lens.AnchorPoint = Vector2.new(1, 0.5)
	lens.Position = UDim2.new(1, -8, 0.5, 0)
	lens.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
	lens.BorderSizePixel = 0
	lens.Parent = island
	makeCorner(5, lens)

	-- Active Status Indicator Dot (Microphone/Call/Camera)
	local dot = Instance.new("Frame")
	dot.Name = "StatusDot"
	dot.Size = UDim2.new(0, 6, 0, 6)
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 10, 0.5, 0)
	dot.BackgroundColor3 = C.SystemGreen
	dot.Visible = false
	dot.BorderSizePixel = 0
	dot.Parent = island
	makeCorner(3, dot)
	self.IslandDot = dot

	-- Center Island Text
	local label = Instance.new("TextLabel")
	label.Name = "IslandLabel"
	label.Size = UDim2.new(1, -36, 1, 0)
	label.Position = UDim2.new(0, 20, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = PhoneTheme.Fonts.Bold
	label.TextSize = 10
	label.TextColor3 = C.TextPrimary
	label.Text = ""
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = island
	self.IslandLabel = label
end

--------------------------------------------------------------------------------
-- Status Bar
--------------------------------------------------------------------------------
function PhoneUI:BuildStatusBar(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local bar = Instance.new("Frame")
	bar.Name = "StatusBar"
	bar.Size = UDim2.new(1, -28, 0, 26)
	bar.Position = UDim2.new(0, 14, 0, 8)
	bar.BackgroundTransparency = 1
	bar.ZIndex = 40
	bar.Parent = parent

	-- Time (Top Left)
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "TimeLabel"
	timeLabel.Size = UDim2.new(0, 48, 1, 0)
	timeLabel.Position = UDim2.new(0, 2, 0, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Font = F.Bold
	timeLabel.TextSize = 12
	timeLabel.TextColor3 = C.TextPrimary
	timeLabel.TextXAlignment = Enum.TextXAlignment.Left
	timeLabel.Text = "12:00"
	timeLabel.Parent = bar
	self.StatusTimeLabel = timeLabel

	-- Right Icons Stack (Signal, Wifi, Battery)
	local rightStack = Instance.new("Frame")
	rightStack.Name = "RightStack"
	rightStack.Size = UDim2.new(0, 68, 1, 0)
	rightStack.AnchorPoint = Vector2.new(1, 0)
	rightStack.Position = UDim2.new(1, 0, 0, 0)
	rightStack.BackgroundTransparency = 1
	rightStack.Parent = bar

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 5)
	list.Parent = rightStack

	-- Cellular Signal Bars
	local signal = Instance.new("TextLabel")
	signal.Name = "Signal"
	signal.Size = UDim2.new(0, 16, 0, 14)
	signal.BackgroundTransparency = 1
	signal.Font = F.Bold
	signal.TextSize = 11
	signal.TextColor3 = C.TextPrimary
	signal.Text = "📶"
	signal.Parent = rightStack

	-- Wi-Fi Icon
	local wifi = Instance.new("TextLabel")
	wifi.Name = "Wifi"
	wifi.Size = UDim2.new(0, 16, 0, 14)
	wifi.BackgroundTransparency = 1
	wifi.Font = F.Bold
	wifi.TextSize = 11
	wifi.TextColor3 = C.TextPrimary
	wifi.Text = "📡"
	wifi.Parent = rightStack

	-- Battery Icon (Outer Pill + Inner Fill)
	local batteryFrame = Instance.new("Frame")
	batteryFrame.Name = "BatteryFrame"
	batteryFrame.Size = UDim2.new(0, 22, 0, 11)
	batteryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
	batteryFrame.BorderSizePixel = 0
	batteryFrame.Parent = rightStack
	makeCorner(3, batteryFrame)
	makeStroke(Color3.fromRGB(150, 150, 160), 1, batteryFrame)

	local batteryFill = Instance.new("Frame")
	batteryFill.Name = "BatteryFill"
	batteryFill.Size = UDim2.new(0.85, 0, 1, -2)
	batteryFill.Position = UDim2.new(0, 1, 0, 1)
	batteryFill.BackgroundColor3 = C.SystemGreen
	batteryFill.BorderSizePixel = 0
	batteryFill.Parent = batteryFrame
	makeCorner(2, batteryFill)
end

--------------------------------------------------------------------------------
-- Home Springboard (App Icon Grid)
--------------------------------------------------------------------------------
function PhoneUI:BuildSpringboard(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts
	local D = PhoneTheme.Dimensions

	local board = Instance.new("ScrollingFrame")
	board.Name = "Springboard"
	board.Size = UDim2.new(1, 0, 1, -114)
	board.Position = UDim2.new(0, 0, 0, 38)
	board.BackgroundTransparency = 1
	board.ScrollBarThickness = 0
	board.CanvasSize = UDim2.new(0, 0, 0, 480)
	board.BorderSizePixel = 0
	board.Parent = parent
	self.Springboard = board

	makePadding(22, 12, 16, 16, board)

	-- Search Bar Widget at Top of Springboard
	local searchCard = Instance.new("TextButton")
	searchCard.Name = "SearchPill"
	searchCard.Size = UDim2.new(1, 0, 0, 34)
	searchCard.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
	searchCard.BackgroundTransparency = 0.35
	searchCard.Text = ""
	searchCard.AutoButtonColor = false
	searchCard.BorderSizePixel = 0
	searchCard.Parent = board
	makeCorner(17, searchCard)
	makeStroke(C.CardStroke, 1, searchCard, 0.5)

	local searchIcon = Instance.new("TextLabel")
	searchIcon.Name = "SearchIcon"
	searchIcon.Size = UDim2.new(0, 24, 1, 0)
	searchIcon.Position = UDim2.new(0, 10, 0, 0)
	searchIcon.BackgroundTransparency = 1
	searchIcon.Font = F.Bold
	searchIcon.TextSize = 13
	searchIcon.TextColor3 = C.TextSecondary
	searchIcon.Text = "🔍"
	searchIcon.Parent = searchCard

	local searchLabel = Instance.new("TextLabel")
	searchLabel.Name = "SearchLabel"
	searchLabel.Size = UDim2.new(1, -44, 1, 0)
	searchLabel.Position = UDim2.new(0, 34, 0, 0)
	searchLabel.BackgroundTransparency = 1
	searchLabel.Font = F.Medium
	searchLabel.TextSize = 12
	searchLabel.TextColor3 = C.TextSecondary
	searchLabel.TextXAlignment = Enum.TextXAlignment.Left
	searchLabel.Text = "Search apps & contacts..."
	searchLabel.Parent = searchCard

	-- 4-Column Grid for Apps
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, 0, 0, 380)
	gridContainer.Position = UDim2.new(0, 0, 0, 48)
	gridContainer.BackgroundTransparency = 1
	gridContainer.BorderSizePixel = 0
	gridContainer.Parent = board

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 58, 0, 76)
	grid.CellPadding = UDim2.new(0, 12, 0, 14)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = gridContainer

	-- Populate Apps (excluding dock apps)
	local order = 0
	for _, app in ipairs(PhoneTheme.Apps) do
		if not app.InDock then
			order += 1
			self:CreateAppIcon(app, gridContainer, order)
		end
	end
end

function PhoneUI:CreateAppIcon(appData: any, parent: Instance, order: number): TextButton
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts
	local D = PhoneTheme.Dimensions

	local button = Instance.new("TextButton")
	button.Name = "App_" .. appData.Id
	button.Size = UDim2.new(0, 58, 0, 76)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.AutoButtonColor = false
	button.LayoutOrder = order
	button.Parent = parent

	-- Squircle Icon Container
	local squircle = Instance.new("Frame")
	squircle.Name = "Squircle"
	squircle.Size = UDim2.new(0, D.AppIconSize, 0, D.AppIconSize)
	squircle.AnchorPoint = Vector2.new(0.5, 0)
	squircle.Position = UDim2.new(0.5, 0, 0, 0)
	squircle.BackgroundColor3 = appData.BgColor or C.SystemBlue
	squircle.BorderSizePixel = 0
	squircle.Parent = button
	makeCorner(D.AppIconRadius, squircle)

	-- Icon Glyph / Asset
	local icon = Instance.new("TextLabel")
	icon.Name = "Glyph"
	icon.Size = UDim2.new(1, 0, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Font = F.Bold
	icon.TextSize = 22
	icon.TextColor3 = appData.IconColor or C.TextPrimary
	icon.Text = appData.FallbackGlyph or "📱"
	icon.Parent = squircle

	-- Unread Notification Badge (Optional)
	if appData.Id == "messages" and self.State.UnreadMessages > 0 then
		local badge = Instance.new("Frame")
		badge.Name = "Badge"
		badge.Size = UDim2.new(0, 18, 0, 18)
		badge.AnchorPoint = Vector2.new(1, 0)
		badge.Position = UDim2.new(1, 4, 0, -4)
		badge.BackgroundColor3 = C.SystemRed
		badge.BorderSizePixel = 0
		badge.ZIndex = 5
		badge.Parent = squircle
		makeCorner(9, badge)

		local count = Instance.new("TextLabel")
		count.Name = "Count"
		count.Size = UDim2.new(1, 0, 1, 0)
		count.BackgroundTransparency = 1
		count.Font = F.Bold
		count.TextSize = 10
		count.TextColor3 = Color3.new(1, 1, 1)
		count.Text = tostring(self.State.UnreadMessages)
		count.Parent = badge
	end

	-- App Label
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 16, 0, 16)
	title.AnchorPoint = Vector2.new(0.5, 1)
	title.Position = UDim2.new(0.5, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Medium
	title.TextSize = 11
	title.TextColor3 = C.TextPrimary
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Text = appData.Title
	title.Parent = button

	-- Click / Press Animation
	button.MouseButton1Down:Connect(function()
		TweenService:Create(squircle, PhoneTheme.Tweens.Fast, {
			Size = UDim2.new(0, D.AppIconSize - 4, 0, D.AppIconSize - 4)
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(squircle, PhoneTheme.Tweens.Bounce, {
			Size = UDim2.new(0, D.AppIconSize, 0, D.AppIconSize)
		}):Play()
		self:OpenApp(appData.Id)
	end)

	return button
end

--------------------------------------------------------------------------------
-- Frosted Glass Dock
--------------------------------------------------------------------------------
function PhoneUI:BuildDock(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions

	local dock = Instance.new("Frame")
	dock.Name = "Dock"
	dock.Size = UDim2.new(1, -28, 0, D.DockHeight)
	dock.AnchorPoint = Vector2.new(0.5, 1)
	dock.Position = UDim2.new(0.5, 0, 1, -24)
	dock.BackgroundColor3 = C.DockBg
	dock.BackgroundTransparency = 0.25
	dock.BorderSizePixel = 0
	dock.ZIndex = 20
	dock.Parent = parent
	self.Dock = dock

	makeCorner(D.DockRadius, dock)
	makeStroke(C.CardStroke, 1, dock, 0.4)

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 16)
	list.Parent = dock

	for order, app in ipairs(PhoneTheme.Apps) do
		if app.InDock then
			local dockBtn = Instance.new("TextButton")
			dockBtn.Name = "Dock_" .. app.Id
			dockBtn.Size = UDim2.new(0, D.AppIconSize, 0, D.AppIconSize)
			dockBtn.BackgroundColor3 = app.BgColor or C.SystemGreen
			dockBtn.Text = ""
			dockBtn.AutoButtonColor = false
			dockBtn.BorderSizePixel = 0
			dockBtn.Parent = dock
			makeCorner(D.AppIconRadius, dockBtn)

			local icon = Instance.new("TextLabel")
			icon.Name = "Glyph"
			icon.Size = UDim2.new(1, 0, 1, 0)
			icon.BackgroundTransparency = 1
			icon.Font = PhoneTheme.Fonts.Bold
			icon.TextSize = 22
			icon.TextColor3 = C.TextPrimary
			icon.Text = app.FallbackGlyph or "📱"
			icon.Parent = dockBtn

			dockBtn.MouseButton1Click:Connect(function()
				self:OpenApp(app.Id)
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- Lock Screen Overlay
--------------------------------------------------------------------------------
function PhoneUI:BuildLockScreen(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local lock = Instance.new("Frame")
	lock.Name = "LockScreen"
	lock.Size = UDim2.new(1, 0, 1, 0)
	lock.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
	lock.BackgroundTransparency = 0.15
	lock.BorderSizePixel = 0
	lock.ZIndex = 30
	lock.Visible = self.State.IsLocked
	lock.Parent = parent
	self.LockScreen = lock

	-- Lock Icon (Top)
	local lockIcon = Instance.new("TextLabel")
	lockIcon.Name = "LockIcon"
	lockIcon.Size = UDim2.new(1, 0, 0, 24)
	lockIcon.Position = UDim2.new(0, 0, 0, 48)
	lockIcon.BackgroundTransparency = 1
	lockIcon.Font = F.Bold
	lockIcon.TextSize = 16
	lockIcon.TextColor3 = C.TextSecondary
	lockIcon.Text = "🔒"
	lockIcon.Parent = lock

	-- Date Text
	local dateLabel = Instance.new("TextLabel")
	dateLabel.Name = "DateLabel"
	dateLabel.Size = UDim2.new(1, 0, 0, 20)
	dateLabel.Position = UDim2.new(0, 0, 0, 74)
	dateLabel.BackgroundTransparency = 1
	dateLabel.Font = F.Medium
	dateLabel.TextSize = 13
	dateLabel.TextColor3 = C.TextSecondary
	dateLabel.Text = "Thursday, September 10"
	dateLabel.Parent = lock
	self.LockDateLabel = dateLabel

	-- Big Clock
	local clockLabel = Instance.new("TextLabel")
	clockLabel.Name = "BigClock"
	clockLabel.Size = UDim2.new(1, 0, 0, 72)
	clockLabel.Position = UDim2.new(0, 0, 0, 94)
	clockLabel.BackgroundTransparency = 1
	clockLabel.Font = F.Black
	clockLabel.TextSize = 64
	clockLabel.TextColor3 = C.TextPrimary
	clockLabel.Text = "19:54"
	clockLabel.Parent = lock
	self.LockClockLabel = clockLabel

	-- Quick Action Buttons at Bottom (Flashlight & Camera)
	local torchBtn = Instance.new("TextButton")
	torchBtn.Name = "TorchBtn"
	torchBtn.Size = UDim2.new(0, 44, 0, 44)
	torchBtn.Position = UDim2.new(0, 32, 1, -84)
	torchBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
	torchBtn.BackgroundTransparency = 0.3
	torchBtn.Text = "🔦"
	torchBtn.Font = F.Bold
	torchBtn.TextSize = 18
	torchBtn.BorderSizePixel = 0
	torchBtn.Parent = lock
	makeCorner(22, torchBtn)

	local camBtn = Instance.new("TextButton")
	camBtn.Name = "CameraBtn"
	camBtn.Size = UDim2.new(0, 44, 0, 44)
	camBtn.Position = UDim2.new(1, -76, 1, -84)
	camBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
	camBtn.BackgroundTransparency = 0.3
	camBtn.Text = "📷"
	camBtn.Font = F.Bold
	camBtn.TextSize = 18
	camBtn.BorderSizePixel = 0
	camBtn.Parent = lock
	makeCorner(22, camBtn)

	camBtn.MouseButton1Click:Connect(function()
		self:Unlock()
		self:OpenApp("camera")
	end)

	-- Unlock Prompt Button
	local unlockBtn = Instance.new("TextButton")
	unlockBtn.Name = "UnlockButton"
	unlockBtn.Size = UDim2.new(1, 0, 0, 30)
	unlockBtn.Position = UDim2.new(0, 0, 1, -34)
	unlockBtn.BackgroundTransparency = 1
	unlockBtn.Font = F.Medium
	unlockBtn.TextSize = 12
	unlockBtn.TextColor3 = C.TextSecondary
	unlockBtn.Text = "Swipe up or tap to unlock"
	unlockBtn.Parent = lock

	unlockBtn.MouseButton1Click:Connect(function()
		self:Unlock()
	end)
end

--------------------------------------------------------------------------------
-- Home Indicator (Bottom Swipe Bar)
--------------------------------------------------------------------------------
function PhoneUI:BuildHomeIndicator(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions

	local bar = Instance.new("TextButton")
	bar.Name = "HomeIndicator"
	bar.Size = UDim2.new(0, D.HomeIndicatorWidth, 0, 14)
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.new(0.5, 0, 1, -4)
	bar.BackgroundTransparency = 1
	bar.Text = ""
	bar.ZIndex = 60
	bar.Parent = parent

	local pill = Instance.new("Frame")
	pill.Name = "Pill"
	pill.Size = UDim2.new(0, D.HomeIndicatorWidth, 0, D.HomeIndicatorHeight)
	pill.AnchorPoint = Vector2.new(0.5, 0.5)
	pill.Position = UDim2.new(0.5, 0, 0.5, 0)
	pill.BackgroundColor3 = C.HomeIndicator
	pill.BorderSizePixel = 0
	pill.Parent = bar
	makeCorner(2, pill)

	bar.MouseButton1Click:Connect(function()
		if self.State.IsLocked then
			self:Unlock()
		elseif self.State.CurrentApp then
			self:GoHome()
		else
			-- On homescreen: minimize/toggle phone
			self:Toggle()
		end
	end)
end

--------------------------------------------------------------------------------
-- Notification Dropdown Banner
--------------------------------------------------------------------------------
function PhoneUI:BuildNotificationBanner(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local banner = Instance.new("Frame")
	banner.Name = "NotificationBanner"
	banner.Size = UDim2.new(1, -24, 0, 62)
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, -80) -- Hidden above
	banner.BackgroundColor3 = C.CardBg
	banner.BorderSizePixel = 0
	banner.ZIndex = 80
	banner.Visible = false
	banner.Parent = parent
	self.NotificationBanner = banner

	makeCorner(16, banner)
	makeStroke(C.CardStroke, 1, banner)

	local icon = Instance.new("TextLabel")
	icon.Name = "NotifIcon"
	icon.Size = UDim2.new(0, 36, 0, 36)
	icon.Position = UDim2.new(0, 12, 0, 13)
	icon.BackgroundColor3 = C.SystemBlue
	icon.Font = F.Bold
	icon.TextSize = 18
	icon.TextColor3 = C.TextPrimary
	icon.Text = "💬"
	icon.Parent = banner
	makeCorner(10, icon)
	self.NotifIcon = icon

	local title = Instance.new("TextLabel")
	title.Name = "NotifTitle"
	title.Size = UDim2.new(1, -64, 0, 18)
	title.Position = UDim2.new(0, 56, 0, 12)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 13
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Sun City Bank"
	title.Parent = banner
	self.NotifTitle = title

	local msg = Instance.new("TextLabel")
	msg.Name = "NotifMsg"
	msg.Size = UDim2.new(1, -64, 0, 16)
	msg.Position = UDim2.new(0, 56, 0, 32)
	msg.BackgroundTransparency = 1
	msg.Font = F.Regular
	msg.TextSize = 11
	msg.TextColor3 = C.TextSecondary
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextTruncate = Enum.TextTruncate.AtEnd
	msg.Text = "You received $500 from Alex Morgan"
	msg.Parent = banner
	self.NotifMsg = msg
end

function PhoneUI:ShowNotification(titleText: string, messageText: string, iconGlyph: string?)
	local banner = self.NotificationBanner
	if not banner then return end

	self.NotifTitle.Text = titleText
	self.NotifMsg.Text = messageText
	if iconGlyph then self.NotifIcon.Text = iconGlyph end

	banner.Visible = true
	banner.Position = UDim2.new(0.5, 0, 0, -80)

	TweenService:Create(banner, PhoneTheme.Tweens.Bounce, {
		Position = UDim2.new(0.5, 0, 0, 14)
	}):Play()

	task.delay(3.5, function()
		if banner and banner.Visible then
			local tween = TweenService:Create(banner, PhoneTheme.Tweens.Fast, {
				Position = UDim2.new(0.5, 0, 0, -80)
			})
			tween:Play()
			tween.Completed:Connect(function()
				banner.Visible = false
			end)
		end
	end)
end

--------------------------------------------------------------------------------
-- In-App Page Builders
--------------------------------------------------------------------------------

-- Helper for Standard App Page Header
local function makeAppHeader(appName: string, parent: Instance, onBack: () -> ()): Frame
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 44)
	header.BackgroundTransparency = 1
	header.BorderSizePixel = 0
	header.Parent = parent

	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackBtn"
	backBtn.Size = UDim2.new(0, 36, 0, 36)
	backBtn.Position = UDim2.new(0, 10, 0, 4)
	backBtn.BackgroundTransparency = 1
	backBtn.Font = F.Bold
	backBtn.TextSize = 18
	backBtn.TextColor3 = C.SystemBlue
	backBtn.Text = "◀"
	backBtn.Parent = header

	backBtn.MouseButton1Click:Connect(onBack)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -96, 1, 0)
	title.Position = UDim2.new(0, 48, 0, 0)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 16
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Text = appName
	title.Parent = header

	return header
end

-- 1. PHONE / CALLS APP
function PhoneUI:BuildPhoneApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_phone"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = C.ScreenBg
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	makeAppHeader("Phone", page, function() self:GoHome() end)

	-- Number Display
	local display = Instance.new("TextLabel")
	display.Name = "NumberDisplay"
	display.Size = UDim2.new(1, -40, 0, 44)
	display.Position = UDim2.new(0, 20, 0, 48)
	display.BackgroundTransparency = 1
	display.Font = F.Bold
	display.TextSize = 28
	display.TextColor3 = C.TextPrimary
	display.Text = ""
	display.Parent = page

	-- Keypad Grid (3x4)
	local keypad = Instance.new("Frame")
	keypad.Name = "Keypad"
	keypad.Size = UDim2.new(0, 220, 0, 310)
	keypad.AnchorPoint = Vector2.new(0.5, 0)
	keypad.Position = UDim2.new(0.5, 0, 0, 96)
	keypad.BackgroundTransparency = 1
	keypad.Parent = page

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 60, 0, 60)
	grid.CellPadding = UDim2.new(0, 20, 0, 12)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = keypad

	local keys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"}
	for _, k in ipairs(keys) do
		local btn = Instance.new("TextButton")
		btn.Name = "Key_" .. k
		btn.BackgroundColor3 = C.CardBg
		btn.Font = F.Bold
		btn.TextSize = 22
		btn.TextColor3 = C.TextPrimary
		btn.Text = k
		btn.BorderSizePixel = 0
		btn.Parent = keypad
		makeCorner(30, btn)

		btn.MouseButton1Click:Connect(function()
			display.Text = display.Text .. k
		end)
	end

	-- Bottom Call & Delete Action Row
	local callBtn = Instance.new("TextButton")
	callBtn.Name = "CallBtn"
	callBtn.Size = UDim2.new(0, 64, 0, 64)
	callBtn.AnchorPoint = Vector2.new(0.5, 0)
	callBtn.Position = UDim2.new(0.5, 0, 0, 420)
	callBtn.BackgroundColor3 = C.SystemGreen
	callBtn.Font = F.Bold
	callBtn.TextSize = 26
	callBtn.TextColor3 = Color3.new(1, 1, 1)
	callBtn.Text = "📞"
	callBtn.BorderSizePixel = 0
	callBtn.Parent = page
	makeCorner(32, callBtn)

	local delBtn = Instance.new("TextButton")
	delBtn.Name = "DeleteBtn"
	delBtn.Size = UDim2.new(0, 44, 0, 44)
	delBtn.Position = UDim2.new(0.5, 52, 0, 430)
	delBtn.BackgroundTransparency = 1
	delBtn.Font = F.Bold
	delBtn.TextSize = 20
	delBtn.TextColor3 = C.TextSecondary
	delBtn.Text = "⌫"
	delBtn.Parent = page

	delBtn.MouseButton1Click:Connect(function()
		local text = display.Text
		if #text > 0 then
			display.Text = string.sub(text, 1, #text - 1)
		end
	end)

	callBtn.MouseButton1Click:Connect(function()
		if #display.Text > 0 then
			self:StartCall(display.Text, display.Text)
		end
	end)

	-- Active Call Overlay Screen
	self:BuildActiveCallOverlay(page)
end

function PhoneUI:BuildActiveCallOverlay(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local overlay = Instance.new("Frame")
	overlay.Name = "CallOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
	overlay.ZIndex = 50
	overlay.Visible = false
	overlay.BorderSizePixel = 0
	overlay.Parent = parent
	self.CallOverlay = overlay

	local avatar = Instance.new("Frame")
	avatar.Name = "Avatar"
	avatar.Size = UDim2.new(0, 84, 0, 84)
	avatar.AnchorPoint = Vector2.new(0.5, 0)
	avatar.Position = UDim2.new(0.5, 0, 0, 80)
	avatar.BackgroundColor3 = C.SystemIndigo
	avatar.BorderSizePixel = 0
	avatar.Parent = overlay
	makeCorner(42, avatar)

	local avatarGlyph = Instance.new("TextLabel")
	avatarGlyph.Name = "Glyph"
	avatarGlyph.Size = UDim2.new(1, 0, 1, 0)
	avatarGlyph.BackgroundTransparency = 1
	avatarGlyph.Font = F.Bold
	avatarGlyph.TextSize = 36
	avatarGlyph.TextColor3 = Color3.new(1, 1, 1)
	avatarGlyph.Text = "👤"
	avatarGlyph.Parent = avatar

	local callerName = Instance.new("TextLabel")
	callerName.Name = "CallerName"
	callerName.Size = UDim2.new(1, -40, 0, 28)
	callerName.Position = UDim2.new(0, 20, 0, 180)
	callerName.BackgroundTransparency = 1
	callerName.Font = F.Bold
	callerName.TextSize = 20
	callerName.TextColor3 = C.TextPrimary
	callerName.Text = "Calling..."
	callerName.Parent = overlay
	self.CallerNameLabel = callerName

	local callTimer = Instance.new("TextLabel")
	callTimer.Name = "CallTimer"
	callTimer.Size = UDim2.new(1, -40, 0, 20)
	callTimer.Position = UDim2.new(0, 20, 0, 210)
	callTimer.BackgroundTransparency = 1
	callTimer.Font = F.Regular
	callTimer.TextSize = 13
	callTimer.TextColor3 = C.TextSecondary
	callTimer.Text = "Connected 00:00"
	callTimer.Parent = overlay
	self.CallTimerLabel = callTimer

	-- End Call Button
	local endBtn = Instance.new("TextButton")
	endBtn.Name = "EndCallBtn"
	endBtn.Size = UDim2.new(0, 68, 0, 68)
	endBtn.AnchorPoint = Vector2.new(0.5, 1)
	endBtn.Position = UDim2.new(0.5, 0, 1, -54)
	endBtn.BackgroundColor3 = C.SystemRed
	endBtn.Font = F.Bold
	endBtn.TextSize = 28
	endBtn.TextColor3 = Color3.new(1, 1, 1)
	endBtn.Text = "🔴"
	endBtn.BorderSizePixel = 0
	endBtn.Parent = overlay
	makeCorner(34, endBtn)

	endBtn.MouseButton1Click:Connect(function()
		self:EndCall()
	end)
end

function PhoneUI:StartCall(contactName: string, number: string)
	self.State.ActiveCall = {
		Contact = contactName,
		Number = number,
		StartTime = os.clock(),
	}

	if self.CallerNameLabel then
		self.CallerNameLabel.Text = contactName
	end
	if self.CallOverlay then
		self.CallOverlay.Visible = true
	end
	if self.IslandDot then
		self.IslandDot.Visible = true
		self.IslandLabel.Text = "📞 In Call"
	end

	if self.OnCallStarted then
		self.OnCallStarted(number)
	end
end

function PhoneUI:EndCall()
	self.State.ActiveCall = nil
	if self.CallOverlay then
		self.CallOverlay.Visible = false
	end
	if self.IslandDot then
		self.IslandDot.Visible = false
		self.IslandLabel.Text = ""
	end

	if self.OnCallEnded then
		self.OnCallEnded()
	end
end

-- 2. MESSAGES APP
function PhoneUI:BuildMessagesApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_messages"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = C.ScreenBg
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	makeAppHeader("Messages", page, function() self:GoHome() end)

	-- Message Bubbles List
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "ChatScroll"
	scroll.Size = UDim2.new(1, -20, 1, -100)
	scroll.Position = UDim2.new(0, 10, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 2
	scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
	scroll.BorderSizePixel = 0
	scroll.Parent = page
	self.ChatScroll = scroll

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = scroll

	-- Sample Messages
	self:AddMessageBubble(scroll, "Hey! Are you meeting at Sun City Bank?", false, 1)
	self:AddMessageBubble(scroll, "Yeah, on my way right now.", true, 2)
	self:AddMessageBubble(scroll, "Great, bring the vehicle from garage.", false, 3)

	-- Bottom Text Input Box
	local inputBar = Instance.new("Frame")
	inputBar.Name = "InputBar"
	inputBar.Size = UDim2.new(1, -16, 0, 40)
	inputBar.AnchorPoint = Vector2.new(0.5, 1)
	inputBar.Position = UDim2.new(0.5, 0, 1, -10)
	inputBar.BackgroundColor3 = C.InputBg
	inputBar.BorderSizePixel = 0
	inputBar.Parent = page
	makeCorner(20, inputBar)
	makeStroke(C.InputStroke, 1, inputBar)

	local textBox = Instance.new("TextBox")
	textBox.Name = "TextBox"
	textBox.Size = UDim2.new(1, -48, 1, 0)
	textBox.Position = UDim2.new(0, 14, 0, 0)
	textBox.BackgroundTransparency = 1
	textBox.Font = F.Regular
	textBox.TextSize = 13
	textBox.TextColor3 = C.TextPrimary
	textBox.PlaceholderColor3 = C.TextPlaceholder
	textBox.PlaceholderText = "iMessage..."
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.ClearTextOnFocus = false
	textBox.Parent = inputBar

	local sendBtn = Instance.new("TextButton")
	sendBtn.Name = "SendBtn"
	sendBtn.Size = UDim2.new(0, 28, 0, 28)
	sendBtn.AnchorPoint = Vector2.new(1, 0.5)
	sendBtn.Position = UDim2.new(1, -6, 0.5, 0)
	sendBtn.BackgroundColor3 = C.SystemBlue
	sendBtn.Font = F.Bold
	sendBtn.TextSize = 14
	sendBtn.TextColor3 = Color3.new(1, 1, 1)
	sendBtn.Text = "⬆"
	sendBtn.BorderSizePixel = 0
	sendBtn.Parent = inputBar
	makeCorner(14, sendBtn)

	local function sendMessage()
		local text = textBox.Text
		if #text > 0 then
			self:AddMessageBubble(scroll, text, true, #scroll:GetChildren())
			textBox.Text = ""
			scroll.CanvasPosition = Vector2.new(0, 9999)
			if self.OnMessageSent then
				self.OnMessageSent("Alex Morgan", text)
			end
		end
	end

	sendBtn.MouseButton1Click:Connect(sendMessage)
	textBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then sendMessage() end
	end)
end

function PhoneUI:AddMessageBubble(parent: Instance, text: string, isSent: boolean, order: number)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local bubble = Instance.new("Frame")
	bubble.Name = "Bubble_" .. order
	bubble.Size = UDim2.new(0, 210, 0, 36)
	bubble.AnchorPoint = Vector2.new(isSent and 1 or 0, 0)
	bubble.Position = UDim2.new(isSent and 1 or 0, 0, 0, 0)
	bubble.BackgroundColor3 = isSent and C.BubbleSent or C.BubbleReceived
	bubble.BorderSizePixel = 0
	bubble.LayoutOrder = order
	bubble.Parent = parent
	makeCorner(14, bubble)

	local label = Instance.new("TextLabel")
	label.Name = "MessageText"
	label.Size = UDim2.new(1, -18, 1, -8)
	label.Position = UDim2.new(0, 9, 0, 4)
	label.BackgroundTransparency = 1
	label.Font = F.Regular
	label.TextSize = 12
	label.TextColor3 = C.TextPrimary
	label.TextXAlignment = isSent and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = text
	label.Parent = bubble
end

-- 3. BANK / WALLET APP
function PhoneUI:BuildBankApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_bank"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = C.ScreenBg
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	makeAppHeader("Sun City Bank", page, function() self:GoHome() end)

	-- Inset Credit Card Balance Graphic
	local card = Instance.new("Frame")
	card.Name = "CreditCard"
	card.Size = UDim2.new(1, -28, 0, 138)
	card.Position = UDim2.new(0, 14, 0, 48)
	card.BackgroundColor3 = C.SystemIndigo
	card.BorderSizePixel = 0
	card.Parent = page
	makeCorner(18, card)

	local cardGrad = Instance.new("UIGradient")
	cardGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 75, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 35, 130)),
	})
	cardGrad.Rotation = 35
	cardGrad.Parent = card

	local bankTitle = Instance.new("TextLabel")
	bankTitle.Name = "BankTitle"
	bankTitle.Size = UDim2.new(1, -32, 0, 20)
	bankTitle.Position = UDim2.new(0, 16, 0, 16)
	bankTitle.BackgroundTransparency = 1
	bankTitle.Font = F.Bold
	bankTitle.TextSize = 13
	bankTitle.TextColor3 = Color3.fromRGB(220, 220, 255)
	bankTitle.TextXAlignment = Enum.TextXAlignment.Left
	bankTitle.Text = "SUN CITY PLATINUM"
	bankTitle.Parent = card

	local balLabel = Instance.new("TextLabel")
	balLabel.Name = "BalanceLabel"
	balLabel.Size = UDim2.new(1, -32, 0, 36)
	balLabel.Position = UDim2.new(0, 16, 0, 46)
	balLabel.BackgroundTransparency = 1
	balLabel.Font = F.Bold
	balLabel.TextSize = 30
	balLabel.TextColor3 = Color3.new(1, 1, 1)
	balLabel.TextXAlignment = Enum.TextXAlignment.Left
	balLabel.Text = string.format("$%s", tostring(self.State.Balance))
	balLabel.Parent = card
	self.BankBalanceLabel = balLabel

	local holderLabel = Instance.new("TextLabel")
	holderLabel.Name = "Holder"
	holderLabel.Size = UDim2.new(1, -32, 0, 18)
	holderLabel.Position = UDim2.new(0, 16, 1, -30)
	holderLabel.BackgroundTransparency = 1
	holderLabel.Font = F.Medium
	holderLabel.TextSize = 11
	holderLabel.TextColor3 = Color3.fromRGB(200, 200, 235)
	holderLabel.TextXAlignment = Enum.TextXAlignment.Left
	holderLabel.Text = "CITIZEN ACCOUNT •••• 4721"
	holderLabel.Parent = card

	-- Quick Transfer Button
	local transferBtn = Instance.new("TextButton")
	transferBtn.Name = "TransferBtn"
	transferBtn.Size = UDim2.new(1, -28, 0, 42)
	transferBtn.Position = UDim2.new(0, 14, 0, 200)
	transferBtn.BackgroundColor3 = C.SystemBlue
	transferBtn.Font = F.Bold
	transferBtn.TextSize = 14
	transferBtn.TextColor3 = Color3.new(1, 1, 1)
	transferBtn.Text = "💸 Transfer Money"
	transferBtn.BorderSizePixel = 0
	transferBtn.Parent = page
	makeCorner(12, transferBtn)

	-- Recent Transactions Header
	local txHeader = Instance.new("TextLabel")
	txHeader.Name = "TxHeader"
	txHeader.Size = UDim2.new(1, -28, 0, 20)
	txHeader.Position = UDim2.new(0, 14, 0, 256)
	txHeader.BackgroundTransparency = 1
	txHeader.Font = F.Bold
	txHeader.TextSize = 12
	txHeader.TextColor3 = C.TextSecondary
	txHeader.TextXAlignment = Enum.TextXAlignment.Left
	txHeader.Text = "RECENT ACTIVITY"
	txHeader.Parent = page

	-- Transactions List Card
	local txCard = Instance.new("Frame")
	txCard.Name = "TxCard"
	txCard.Size = UDim2.new(1, -28, 0, 190)
	txCard.Position = UDim2.new(0, 14, 0, 282)
	txCard.BackgroundColor3 = C.CardBg
	txCard.BorderSizePixel = 0
	txCard.Parent = page
	makeCorner(14, txCard)
	makeStroke(C.CardStroke, 1, txCard)

	local txList = Instance.new("UIListLayout")
	txList.SortOrder = Enum.SortOrder.LayoutOrder
	txList.Parent = txCard

	local sampleTxs = {
		{ Title = "Salary Deposit", Sub = "Government", Amount = "+$1,250", Color = C.SystemGreen },
		{ Title = "Sun City Gas", Sub = "Fuel", Amount = "-$85", Color = C.SystemRed },
		{ Title = "Vehicle Purchase", Sub = "Dealership", Amount = "-$4,200", Color = C.SystemRed },
	}

	for i, tx in ipairs(sampleTxs) do
		local row = Instance.new("Frame")
		row.Name = "Row_" .. i
		row.Size = UDim2.new(1, 0, 0, 52)
		row.BackgroundTransparency = 1
		row.Parent = txCard

		local tLabel = Instance.new("TextLabel")
		tLabel.Size = UDim2.new(0, 140, 0, 20)
		tLabel.Position = UDim2.new(0, 14, 0, 8)
		tLabel.BackgroundTransparency = 1
		tLabel.Font = F.Bold
		tLabel.TextSize = 13
		tLabel.TextColor3 = C.TextPrimary
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Text = tx.Title
		tLabel.Parent = row

		local sLabel = Instance.new("TextLabel")
		sLabel.Size = UDim2.new(0, 140, 0, 16)
		sLabel.Position = UDim2.new(0, 14, 0, 28)
		sLabel.BackgroundTransparency = 1
		sLabel.Font = F.Regular
		sLabel.TextSize = 11
		sLabel.TextColor3 = C.TextSecondary
		sLabel.TextXAlignment = Enum.TextXAlignment.Left
		sLabel.Text = tx.Sub
		sLabel.Parent = row

		local aLabel = Instance.new("TextLabel")
		aLabel.Size = UDim2.new(0, 80, 1, 0)
		aLabel.Position = UDim2.new(1, -94, 0, 0)
		aLabel.BackgroundTransparency = 1
		aLabel.Font = F.Bold
		aLabel.TextSize = 13
		aLabel.TextColor3 = tx.Color
		aLabel.TextXAlignment = Enum.TextXAlignment.Right
		aLabel.Text = tx.Amount
		aLabel.Parent = row

		if i < #sampleTxs then
			local sep = Instance.new("Frame")
			sep.Size = UDim2.new(1, -14, 0, 1)
			sep.Position = UDim2.new(0, 14, 1, -1)
			sep.BackgroundColor3 = C.Separator
			sep.BorderSizePixel = 0
			sep.Parent = row
		end
	end

	transferBtn.MouseButton1Click:Connect(function()
		self:ShowNotification("Bank Transfer", "Transfer simulation: $100 sent!", "💸")
		self.State.Balance -= 100
		if self.BankBalanceLabel then
			self.BankBalanceLabel.Text = string.format("$%s", tostring(self.State.Balance))
		end
		if self.OnTransferMoney then
			self.OnTransferMoney("Alex Morgan", 100)
		end
	end)
end

-- 4. GARAGE / VEHICLES APP
function PhoneUI:BuildGarageApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_garage"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = C.ScreenBg
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	makeAppHeader("Garage", page, function() self:GoHome() end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "VehiclesScroll"
	scroll.Size = UDim2.new(1, -24, 1, -54)
	scroll.Position = UDim2.new(0, 12, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 2
	scroll.Parent = page

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 14)
	list.Parent = scroll

	local sampleVehicles = {
		{ Id = "veh_1", Name = "Karin Sultan RS", Plate = "47AMER88", Health = 100, Fuel = 82, Locked = true },
		{ Id = "veh_2", Name = "Benefactor Schafter V12", Plate = "99SKY001", Health = 94, Fuel = 45, Locked = false },
	}

	for _, veh in ipairs(sampleVehicles) do
		local card = Instance.new("Frame")
		card.Name = "Card_" .. veh.Id
		card.Size = UDim2.new(1, 0, 0, 138)
		card.BackgroundColor3 = C.CardBg
		card.BorderSizePixel = 0
		card.Parent = scroll
		makeCorner(14, card)
		makeStroke(C.CardStroke, 1, card)

		local vName = Instance.new("TextLabel")
		vName.Size = UDim2.new(1, -28, 0, 22)
		vName.Position = UDim2.new(0, 14, 0, 12)
		vName.BackgroundTransparency = 1
		vName.Font = F.Bold
		vName.TextSize = 14
		vName.TextColor3 = C.TextPrimary
		vName.TextXAlignment = Enum.TextXAlignment.Left
		vName.Text = veh.Name
		vName.Parent = card

		local vPlate = Instance.new("TextLabel")
		vPlate.Size = UDim2.new(0, 120, 0, 16)
		vPlate.Position = UDim2.new(0, 14, 0, 36)
		vPlate.BackgroundTransparency = 1
		vPlate.Font = F.Medium
		vPlate.TextSize = 11
		vPlate.TextColor3 = C.SystemBlue
		vPlate.TextXAlignment = Enum.TextXAlignment.Left
		vPlate.Text = "PLATE: " .. veh.Plate
		vPlate.Parent = card

		-- Stats (Fuel & Health)
		local statsLabel = Instance.new("TextLabel")
		statsLabel.Size = UDim2.new(1, -28, 0, 16)
		statsLabel.Position = UDim2.new(0, 14, 0, 58)
		statsLabel.BackgroundTransparency = 1
		statsLabel.Font = F.Regular
		statsLabel.TextSize = 11
		statsLabel.TextColor3 = C.TextSecondary
		statsLabel.TextXAlignment = Enum.TextXAlignment.Left
		statsLabel.Text = string.format("⛽ Fuel: %d%%  |  🛡️ Health: %d%%", veh.Fuel, veh.Health)
		statsLabel.Parent = card

		-- Action Buttons (Lock / GPS Track)
		local lockBtn = Instance.new("TextButton")
		lockBtn.Name = "LockBtn"
		lockBtn.Size = UDim2.new(0, 110, 0, 32)
		lockBtn.Position = UDim2.new(0, 14, 0, 88)
		lockBtn.BackgroundColor3 = veh.Locked and C.SystemOrange or C.SystemGreen
		lockBtn.Font = F.Bold
		lockBtn.TextSize = 12
		lockBtn.TextColor3 = Color3.new(1, 1, 1)
		lockBtn.Text = veh.Locked and "🔒 Locked" or "🔓 Unlocked"
		lockBtn.BorderSizePixel = 0
		lockBtn.Parent = card
		makeCorner(8, lockBtn)

		local gpsBtn = Instance.new("TextButton")
		gpsBtn.Name = "GpsBtn"
		gpsBtn.Size = UDim2.new(0, 110, 0, 32)
		gpsBtn.Position = UDim2.new(1, -124, 0, 88)
		gpsBtn.BackgroundColor3 = C.SystemBlue
		gpsBtn.Font = F.Bold
		gpsBtn.TextSize = 12
		gpsBtn.TextColor3 = Color3.new(1, 1, 1)
		gpsBtn.Text = "📍 Track GPS"
		gpsBtn.BorderSizePixel = 0
		gpsBtn.Parent = card
		makeCorner(8, gpsBtn)

		lockBtn.MouseButton1Click:Connect(function()
			veh.Locked = not veh.Locked
			lockBtn.Text = veh.Locked and "🔒 Locked" or "🔓 Unlocked"
			lockBtn.BackgroundColor3 = veh.Locked and C.SystemOrange or C.SystemGreen
			self:ShowNotification("Vehicle Remote", veh.Name .. " " .. (veh.Locked and "locked" or "unlocked"), "🚗")
			if self.OnVehicleAction then
				self.OnVehicleAction(veh.Id, "toggle_lock")
			end
		end)

		gpsBtn.MouseButton1Click:Connect(function()
			self:ShowNotification("GPS Waypoint", "Waypoint set for " .. veh.Name, "📍")
			if self.OnVehicleAction then
				self.OnVehicleAction(veh.Id, "track_gps")
			end
		end)
	end
end

-- 5. SETTINGS APP
function PhoneUI:BuildSettingsApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_settings"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = C.ScreenBg
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	makeAppHeader("Settings", page, function() self:GoHome() end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "SettingsScroll"
	scroll.Size = UDim2.new(1, -24, 1, -54)
	scroll.Position = UDim2.new(0, 12, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 2
	scroll.Parent = page

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 14)
	list.Parent = scroll

	-- Section 1: Connectivity Card
	local card1 = Instance.new("Frame")
	card1.Name = "Card_Connectivity"
	card1.Size = UDim2.new(1, 0, 0, 138)
	card1.BackgroundColor3 = C.CardBg
	card1.BorderSizePixel = 0
	card1.Parent = scroll
	makeCorner(14, card1)
	makeStroke(C.CardStroke, 1, card1)

	local function addToggleRow(parentCard: Instance, title: string, iconGlyph: string, defaultOn: boolean, yPos: number, callback: (bool: boolean) -> ())
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 44)
		row.Position = UDim2.new(0, 0, 0, yPos)
		row.BackgroundTransparency = 1
		row.Parent = parentCard

		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 28, 0, 28)
		icon.Position = UDim2.new(0, 12, 0, 8)
		icon.BackgroundColor3 = C.SystemBlue
		icon.Font = F.Bold
		icon.TextSize = 14
		icon.TextColor3 = Color3.new(1, 1, 1)
		icon.Text = iconGlyph
		icon.Parent = row
		makeCorner(6, icon)

		local tLabel = Instance.new("TextLabel")
		tLabel.Size = UDim2.new(0, 140, 1, 0)
		tLabel.Position = UDim2.new(0, 48, 0, 0)
		tLabel.BackgroundTransparency = 1
		tLabel.Font = F.Medium
		tLabel.TextSize = 13
		tLabel.TextColor3 = C.TextPrimary
		tLabel.TextXAlignment = Enum.TextXAlignment.Left
		tLabel.Text = title
		tLabel.Parent = row

		-- iOS Toggle Switch
		local togglePill = Instance.new("TextButton")
		togglePill.Size = UDim2.new(0, 44, 0, 24)
		togglePill.Position = UDim2.new(1, -56, 0, 10)
		togglePill.BackgroundColor3 = defaultOn and C.SwitchOn or C.SwitchOff
		togglePill.Text = ""
		togglePill.AutoButtonColor = false
		togglePill.BorderSizePixel = 0
		togglePill.Parent = row
		makeCorner(12, togglePill)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 20, 0, 20)
		knob.Position = defaultOn and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
		knob.BackgroundColor3 = C.SwitchKnob
		knob.BorderSizePixel = 0
		knob.Parent = togglePill
		makeCorner(10, knob)

		local isOn = defaultOn
		togglePill.MouseButton1Click:Connect(function()
			isOn = not isOn
			TweenService:Create(togglePill, PhoneTheme.Tweens.Fast, {
				BackgroundColor3 = isOn and C.SwitchOn or C.SwitchOff
			}):Play()
			TweenService:Create(knob, PhoneTheme.Tweens.Bounce, {
				Position = isOn and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
			}):Play()
			callback(isOn)
		end)
	end

	addToggleRow(card1, "Airplane Mode", "✈️", false, 0, function(on)
		self.State.AirplaneMode = on
		self:ShowNotification("Settings", "Airplane Mode: " .. (on and "Enabled" or "Disabled"), "✈️")
	end)
	addToggleRow(card1, "Wi-Fi", "📡", true, 46, function(on)
		self.State.WifiEnabled = on
	end)
	addToggleRow(card1, "Bluetooth", "🦷", true, 92, function(on)
		self.State.BluetoothEnabled = on
	end)

	-- Section 2: About / Device Card
	local card2 = Instance.new("Frame")
	card2.Name = "Card_About"
	card2.Size = UDim2.new(1, 0, 0, 92)
	card2.BackgroundColor3 = C.CardBg
	card2.BorderSizePixel = 0
	card2.Parent = scroll
	makeCorner(14, card2)
	makeStroke(C.CardStroke, 1, card2)

	local aboutHeader = Instance.new("TextLabel")
	aboutHeader.Size = UDim2.new(1, -24, 0, 24)
	aboutHeader.Position = UDim2.new(0, 12, 0, 10)
	aboutHeader.BackgroundTransparency = 1
	aboutHeader.Font = F.Bold
	aboutHeader.TextSize = 13
	aboutHeader.TextColor3 = C.TextPrimary
	aboutHeader.TextXAlignment = Enum.TextXAlignment.Left
	aboutHeader.Text = "Sky Phone 16 Pro Max"
	aboutHeader.Parent = card2

	local aboutSub = Instance.new("TextLabel")
	aboutSub.Size = UDim2.new(1, -24, 0, 40)
	aboutSub.Position = UDim2.new(0, 12, 0, 36)
	aboutSub.BackgroundTransparency = 1
	aboutSub.Font = F.Regular
	aboutSub.TextSize = 11
	aboutSub.TextColor3 = C.TextSecondary
	aboutSub.TextXAlignment = Enum.TextXAlignment.Left
	aboutSub.TextWrapped = true
	aboutSub.Text = "SkyOS 18.2 (Antigravity Luau Edition)\nStorage: 256 GB (182 GB Available)"
	aboutSub.Parent = card2
end

-- 6. NOTES APP
function PhoneUI:BuildNotesApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_notes"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = C.ScreenBg
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	makeAppHeader("Notes", page, function() self:GoHome() end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "NotesScroll"
	scroll.Size = UDim2.new(1, -24, 1, -54)
	scroll.Position = UDim2.new(0, 12, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 2
	scroll.Parent = page

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 10)
	list.Parent = scroll

	local sampleNotes = {
		{ Title = "Apartment Keypad Code", Content = "Building 4, Code: #4829", Date = "Today" },
		{ Title = "Vehicle Parts List", Content = "1. Twin Turbo Kit\n2. Sport Tires\n3. ECU Tune", Date = "Yesterday" },
		{ Title = "Bank Wire Contacts", Content = "Alex Morgan (555-0142)", Date = "Sep 8" },
	}

	for i, note in ipairs(sampleNotes) do
		local card = Instance.new("Frame")
		card.Name = "Note_" .. i
		card.Size = UDim2.new(1, 0, 0, 72)
		card.BackgroundColor3 = C.CardBg
		card.BorderSizePixel = 0
		card.Parent = scroll
		makeCorner(12, card)
		makeStroke(C.CardStroke, 1, card)

		local nTitle = Instance.new("TextLabel")
		nTitle.Size = UDim2.new(1, -24, 0, 20)
		nTitle.Position = UDim2.new(0, 12, 0, 8)
		nTitle.BackgroundTransparency = 1
		nTitle.Font = F.Bold
		nTitle.TextSize = 13
		nTitle.TextColor3 = C.TextPrimary
		nTitle.TextXAlignment = Enum.TextXAlignment.Left
		nTitle.Text = note.Title
		nTitle.Parent = card

		local nContent = Instance.new("TextLabel")
		nContent.Size = UDim2.new(1, -24, 0, 32)
		nContent.Position = UDim2.new(0, 12, 0, 30)
		nContent.BackgroundTransparency = 1
		nContent.Font = F.Regular
		nContent.TextSize = 11
		nContent.TextColor3 = C.TextSecondary
		nContent.TextXAlignment = Enum.TextXAlignment.Left
		nContent.TextTruncate = Enum.TextTruncate.AtEnd
		nContent.Text = note.Content
		nContent.Parent = card
	end
end

-- 7. CAMERA APP
function PhoneUI:BuildCameraApp()
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local page = Instance.new("Frame")
	page.Name = "App_camera"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = self.AppContainer

	-- Top Camera Controls
	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 48)
	topBar.BackgroundTransparency = 1
	topBar.Parent = page

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.Position = UDim2.new(0, 10, 0, 6)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Font = F.Bold
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Text = "✕"
	closeBtn.Parent = topBar

	closeBtn.MouseButton1Click:Connect(function()
		self:GoHome()
	end)

	-- Viewfinder Crosshair Center
	local reticle = Instance.new("Frame")
	reticle.Size = UDim2.new(0, 60, 0, 60)
	reticle.AnchorPoint = Vector2.new(0.5, 0.5)
	reticle.Position = UDim2.new(0.5, 0, 0.45, 0)
	reticle.BackgroundTransparency = 1
	reticle.Parent = page
	makeCorner(30, reticle)
	makeStroke(Color3.fromRGB(255, 214, 10), 1.5, reticle, 0.5)

	-- Bottom Shutter Row
	local shutterBar = Instance.new("Frame")
	shutterBar.Size = UDim2.new(1, 0, 0, 100)
	shutterBar.AnchorPoint = Vector2.new(0, 1)
	shutterBar.Position = UDim2.new(0, 0, 1, 0)
	shutterBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	shutterBar.BorderSizePixel = 0
	shutterBar.Parent = page

	local shutterRing = Instance.new("Frame")
	shutterRing.Size = UDim2.new(0, 68, 0, 68)
	shutterRing.AnchorPoint = Vector2.new(0.5, 0.5)
	shutterRing.Position = UDim2.new(0.5, 0, 0.5, 0)
	shutterRing.BackgroundTransparency = 1
	shutterRing.Parent = shutterBar
	makeCorner(34, shutterRing)
	makeStroke(Color3.new(1, 1, 1), 3.5, shutterRing)

	local shutterBtn = Instance.new("TextButton")
	shutterBtn.Size = UDim2.new(0, 54, 0, 54)
	shutterBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	shutterBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
	shutterBtn.BackgroundColor3 = Color3.new(1, 1, 1)
	shutterBtn.Text = ""
	shutterBtn.BorderSizePixel = 0
	shutterBtn.Parent = shutterBar
	makeCorner(27, shutterBtn)

	-- Flash effect
	local flash = Instance.new("Frame")
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.BackgroundTransparency = 1
	flash.ZIndex = 100
	flash.BorderSizePixel = 0
	flash.Parent = page

	shutterBtn.MouseButton1Click:Connect(function()
		flash.BackgroundTransparency = 0
		TweenService:Create(flash, PhoneTheme.Tweens.Fast, { BackgroundTransparency = 1 }):Play()
		self:ShowNotification("Camera", "Photo captured and saved to Photos", "📷")
	end)
end

--------------------------------------------------------------------------------
-- Navigation & State Control
--------------------------------------------------------------------------------
function PhoneUI:OpenApp(appId: string)
	local targetApp = self.AppContainer:FindFirstChild("App_" .. appId)
	if not targetApp then
		self:ShowNotification("App Store", "App '" .. appId .. "' installed.", "📱")
		return
	end

	self.State.CurrentApp = appId
	self.Springboard.Visible = false
	self.Dock.Visible = false
	self.AppContainer.Visible = true

	-- Hide all apps then reveal target
	for _, child in ipairs(self.AppContainer:GetChildren()) do
		if child:IsA("Frame") then
			child.Visible = (child.Name == "App_" .. appId)
		end
	end
end

function PhoneUI:GoHome()
	self.State.CurrentApp = nil
	self.AppContainer.Visible = false
	self.Springboard.Visible = true
	self.Dock.Visible = true
end

function PhoneUI:Unlock()
	self.State.IsLocked = false
	local tween = TweenService:Create(self.LockScreen, PhoneTheme.Tweens.Normal, {
		Position = UDim2.new(0, 0, -1, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		self.LockScreen.Visible = false
	end)
end

function PhoneUI:Lock()
	self.State.IsLocked = true
	self:GoHome()
	self.LockScreen.Visible = true
	self.LockScreen.Position = UDim2.new(0, 0, -1, 0)
	TweenService:Create(self.LockScreen, PhoneTheme.Tweens.Normal, {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
end

function PhoneUI:SetVisible(visible: boolean)
	self.State.IsOpen = visible
	local targetPos = visible
		and UDim2.new(1, -24, 1, -20)
		or UDim2.new(1, -24, 1, 680)

	TweenService:Create(self.Chassis, PhoneTheme.Tweens.Normal, {
		Position = targetPos
	}):Play()
end

function PhoneUI:Toggle()
	self:SetVisible(not self.State.IsOpen)
end

--------------------------------------------------------------------------------
-- Real-time Clock Loop
--------------------------------------------------------------------------------
function PhoneUI:StartClockLoop()
	task.spawn(function()
		while true do
			local timeStr = os.date("%H:%M")
			local dateStr = os.date("%A, %B %d")

			if self.StatusTimeLabel then
				self.StatusTimeLabel.Text = timeStr
			end
			if self.LockClockLabel then
				self.LockClockLabel.Text = timeStr
			end
			if self.LockDateLabel then
				self.LockDateLabel.Text = dateStr
			end

			-- Update active call duration
			if self.State.ActiveCall and self.CallTimerLabel then
				local elapsed = math.floor(os.clock() - self.State.ActiveCall.StartTime)
				local mins = math.floor(elapsed / 60)
				local secs = elapsed % 60
				self.CallTimerLabel.Text = string.format("Connected %02d:%02d", mins, secs)
			end

			task.wait(1)
		end
	end)
end

return PhoneUI
