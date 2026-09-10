--!strict
-- PhoneUI.luau
-- High-Fidelity Native Roblox Luau UI Component for Sky Phone (Sky Systems iOS 17/18 Architecture)
-- Location: roblox/phone/PhoneUI.luau

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local currentFolder = script.Parent or script
local PhoneTheme = require(currentFolder:WaitForChild("PhoneTheme") :: ModuleScript)

local PhoneUI = {}
PhoneUI.__index = PhoneUI

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function makeCorner(radius: number, parent: Instance): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function makeStroke(color: Color3, thickness: number, parent: Instance): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
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
-- Constructor
--------------------------------------------------------------------------------
function PhoneUI.new(parentGui: ScreenGui)
	local self = setmetatable({}, PhoneUI)

	self.ParentGui = parentGui
	self.State = {
		IsOpen = false,
		IsLocked = true,
		CurrentApp = nil :: string?,
		Balance = 15450,
		BatteryPercent = 94,
		SignalBars = 4,
		WifiConnected = true,
		ActiveCall = nil :: { Number: string, StartTime: number }?,
		DialedNumber = "",
		Volume = 0.75,
		Brightness = 1.0,
		FlashlightOn = false,
		AirplaneMode = false,
		BluetoothOn = true,
		ControlCenterOpen = false,
		IslandExpanded = false,
		IsPlayingMusic = false,
		CurrentSong = { Title = "Blinding Lights", Artist = "The Weeknd" },
		SelectedFrame = "SpaceGray",
		SelectedWallpaper = "DeepMesh",
	}

	-- Callbacks
	self.OnCallStarted = nil :: ((number: string) -> ())?
	self.OnCallEnded = nil :: (() -> ())?
	self.OnMessageSent = nil :: ((recipient: string, text: string) -> ())?
	self.OnTransferMoney = nil :: ((recipient: string, amount: number) -> ())?
	self.OnVehicleAction = nil :: ((vehicleId: string, action: string) -> ())?

	-- Containers
	self.AppContainers = {} :: { [string]: Frame }

	self:BuildUI()
	self:StartClockLoop()

	return self
end

--------------------------------------------------------------------------------
-- Build UI Hierarchy
--------------------------------------------------------------------------------
function PhoneUI:BuildUI()
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions

	-- 1. Outer Container
	local root = Instance.new("Frame")
	root.Name = "SkyPhoneRoot"
	root.Size = UDim2.new(0, D.PhoneWidth, 0, D.PhoneHeight)
	root.AnchorPoint = Vector2.new(1, 1)
	root.Position = UDim2.new(1, -32, 1, 700) -- Hidden off-screen by default
	root.BackgroundTransparency = 1
	root.Parent = self.ParentGui
	self.Root = root

	-- 2. Hardware Chassis (Bezel)
	local bezel = Instance.new("Frame")
	bezel.Name = "PhoneBezel"
	bezel.Size = UDim2.new(1, 0, 1, 0)
	bezel.BackgroundColor3 = C.Frames.SpaceGray
	bezel.BorderSizePixel = 0
	bezel.Parent = root
	self.Bezel = bezel
	makeCorner(D.BezelRadius, bezel)
	makeStroke(C.PhoneBorder, 2, bezel)

	-- Bevel highlight
	local bevel = Instance.new("Frame")
	bevel.Name = "BevelHighlight"
	bevel.Size = UDim2.new(1, -2, 1, -2)
	bevel.Position = UDim2.new(0, 1, 0, 1)
	bevel.BackgroundTransparency = 1
	bevel.BorderSizePixel = 0
	bevel.Parent = bezel
	makeCorner(D.BezelRadius - 1, bevel)
	makeStroke(Color3.fromRGB(80, 80, 95), 1, bevel)

	-- 3. Screen CanvasGroup (Perfect Curved Corner Masking)
	local screen = Instance.new("CanvasGroup")
	screen.Name = "PhoneScreen"
	screen.Size = UDim2.new(1, -(D.BezelPadding * 2), 1, -(D.BezelPadding * 2))
	screen.Position = UDim2.new(0, D.BezelPadding, 0, D.BezelPadding)
	screen.BackgroundColor3 = C.ScreenBg
	screen.BorderSizePixel = 0
	screen.GroupTransparency = 0
	screen.Parent = bezel
	self.Screen = screen
	makeCorner(D.ScreenRadius, screen)

	-- 4. Dynamic Mesh Gradient Wallpaper
	local wallpaper = Instance.new("Frame")
	wallpaper.Name = "PhoneWallpaper"
	wallpaper.Size = UDim2.new(1, 0, 1, 0)
	wallpaper.BackgroundColor3 = C.WallpaperDark
	wallpaper.BorderSizePixel = 0
	wallpaper.ZIndex = 1
	wallpaper.Parent = screen
	self.Wallpaper = wallpaper

	local uigrad = Instance.new("UIGradient")
	uigrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.0, C.WallpaperGradient1),
		ColorSequenceKeypoint.new(0.5, C.WallpaperDark),
		ColorSequenceKeypoint.new(1.0, C.WallpaperGradient2),
	})
	uigrad.Rotation = 45
	uigrad.Parent = wallpaper
	self.WallpaperGradient = uigrad

	-- 5. Subsystems
	self:BuildSpringboard(screen)
	self:BuildDock(screen)
	self:BuildStatusBar(screen)
	self:BuildDynamicIsland(screen)
	self:BuildHomeIndicator(screen)
	self:BuildLockScreen(screen)
	self:BuildControlCenter(screen)
	self:BuildNotificationBanner(screen)

	-- 6. Core Apps
	self:BuildPhoneApp(screen)
	self:BuildMessagesApp(screen)
	self:BuildBankApp(screen)
	self:BuildGarageApp(screen)
	self:BuildSettingsApp(screen)
	self:BuildNotesApp(screen)
	self:BuildCameraApp(screen)
	self:BuildCalculatorApp(screen)
	self:BuildMusicApp(screen)
	self:BuildCryptoApp(screen)
end

--------------------------------------------------------------------------------
-- Dynamic Island
--------------------------------------------------------------------------------
function PhoneUI:BuildDynamicIsland(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions
	local F = PhoneTheme.Fonts

	local islandBtn = Instance.new("TextButton")
	islandBtn.Name = "DynamicIsland"
	islandBtn.Size = UDim2.new(0, D.IslandWidthCompact, 0, D.IslandHeightCompact)
	islandBtn.AnchorPoint = Vector2.new(0.5, 0)
	islandBtn.Position = UDim2.new(0.5, 0, 0, 10)
	islandBtn.BackgroundColor3 = C.DynamicIsland
	islandBtn.BorderSizePixel = 0
	islandBtn.AutoButtonColor = false
	islandBtn.Text = ""
	islandBtn.ZIndex = 100
	islandBtn.Parent = parent
	self.Island = islandBtn
	makeCorner(D.IslandRadius, islandBtn)
	makeStroke(C.IslandStroke, 1, islandBtn)

	-- Camera lens
	local lens = Instance.new("Frame")
	lens.Name = "CameraLens"
	lens.Size = UDim2.new(0, 9, 0, 9)
	lens.AnchorPoint = Vector2.new(0, 0.5)
	lens.Position = UDim2.new(0, 9, 0.5, 0)
	lens.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
	lens.BorderSizePixel = 0
	lens.Parent = islandBtn
	makeCorner(5, lens)

	-- Activity Dot (Mic / Call / Audio status)
	local dot = Instance.new("Frame")
	dot.Name = "ActivityDot"
	dot.Size = UDim2.new(0, 7, 0, 7)
	dot.AnchorPoint = Vector2.new(1, 0.5)
	dot.Position = UDim2.new(1, -9, 0.5, 0)
	dot.BackgroundColor3 = C.SystemGreen
	dot.BorderSizePixel = 0
	dot.Visible = false
	dot.Parent = islandBtn
	self.IslandDot = dot
	makeCorner(4, dot)

	-- Expandable content container
	local expandedContent = Instance.new("Frame")
	expandedContent.Name = "ExpandedContent"
	expandedContent.Size = UDim2.new(1, -20, 1, 0)
	expandedContent.Position = UDim2.new(0, 10, 0, 0)
	expandedContent.BackgroundTransparency = 1
	expandedContent.Visible = false
	expandedContent.Parent = islandBtn
	self.IslandExpandedContent = expandedContent

	local islandTitle = Instance.new("TextLabel")
	islandTitle.Name = "IslandTitle"
	islandTitle.Size = UDim2.new(0.65, 0, 0.5, 0)
	islandTitle.Position = UDim2.new(0, 20, 0, 10)
	islandTitle.BackgroundTransparency = 1
	islandTitle.Font = F.Bold
	islandTitle.TextSize = 13
	islandTitle.TextColor3 = C.TextPrimary
	islandTitle.TextXAlignment = Enum.TextXAlignment.Left
	islandTitle.Text = "Connected Call"
	islandTitle.Parent = expandedContent
	self.IslandTitle = islandTitle

	local islandSub = Instance.new("TextLabel")
	islandSub.Name = "IslandSub"
	islandSub.Size = UDim2.new(0.65, 0, 0.4, 0)
	islandSub.Position = UDim2.new(0, 20, 0.5, 0)
	islandSub.BackgroundTransparency = 1
	islandSub.Font = F.Regular
	islandSub.TextSize = 11
	islandSub.TextColor3 = C.SystemGreen
	islandSub.TextXAlignment = Enum.TextXAlignment.Left
	islandSub.Text = "00:00"
	islandSub.Parent = expandedContent
	self.IslandSub = islandSub

	-- Tap to toggle expand/collapse
	islandBtn.MouseButton1Click:Connect(function()
		self:ToggleDynamicIsland()
	end)
end

function PhoneUI:ToggleDynamicIsland()
	local D = PhoneTheme.Dimensions
	local T = PhoneTheme.Tweens
	self.State.IslandExpanded = not self.State.IslandExpanded

	if self.State.IslandExpanded then
		TweenService:Create(self.Island, T.IslandExpand, {
			Size = UDim2.new(0, D.IslandWidthExpanded, 0, D.IslandHeightExpanded),
		}):Play()
		task.delay(0.1, function()
			self.IslandExpandedContent.Visible = true
		end)
	else
		self.IslandExpandedContent.Visible = false
		TweenService:Create(self.Island, T.Snappy, {
			Size = UDim2.new(0, D.IslandWidthCompact, 0, D.IslandHeightCompact),
		}):Play()
	end
end

--------------------------------------------------------------------------------
-- Status Bar
--------------------------------------------------------------------------------
function PhoneUI:BuildStatusBar(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions
	local F = PhoneTheme.Fonts

	local bar = Instance.new("Frame")
	bar.Name = "StatusBar"
	bar.Size = UDim2.new(1, 0, 0, D.StatusBarHeight)
	bar.BackgroundTransparency = 1
	bar.ZIndex = 90
	bar.Parent = parent

	-- Time (Left)
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "StatusClock"
	timeLabel.Size = UDim2.new(0, 58, 1, 0)
	timeLabel.Position = UDim2.new(0, 22, 0, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Font = F.Bold
	timeLabel.TextSize = 13
	timeLabel.TextColor3 = C.TextPrimary
	timeLabel.TextXAlignment = Enum.TextXAlignment.Left
	timeLabel.Text = "12:00"
	timeLabel.Parent = bar
	self.StatusClockLabel = timeLabel

	-- Right Platter (Signal, Wifi, Battery) - Clickable to open Control Center!
	local rightBtn = Instance.new("TextButton")
	rightBtn.Name = "StatusRightBtn"
	rightBtn.Size = UDim2.new(0, 80, 1, 0)
	rightBtn.AnchorPoint = Vector2.new(1, 0)
	rightBtn.Position = UDim2.new(1, -16, 0, 0)
	rightBtn.BackgroundTransparency = 1
	rightBtn.Text = ""
	rightBtn.Parent = bar

	local rightLayout = Instance.new("UIListLayout")
	rightLayout.FillDirection = Enum.FillDirection.Horizontal
	rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rightLayout.Padding = UDim.new(0, 4)
	rightLayout.Parent = rightBtn

	local batteryLabel = Instance.new("TextLabel")
	batteryLabel.Size = UDim2.new(0, 32, 1, 0)
	batteryLabel.BackgroundTransparency = 1
	batteryLabel.Font = F.Medium
	batteryLabel.TextSize = 11
	batteryLabel.TextColor3 = C.TextPrimary
	batteryLabel.Text = "94% 🔋"
	batteryLabel.Parent = rightBtn
	self.StatusBatteryLabel = batteryLabel

	local wifiLabel = Instance.new("TextLabel")
	wifiLabel.Size = UDim2.new(0, 18, 1, 0)
	wifiLabel.BackgroundTransparency = 1
	wifiLabel.Font = F.Regular
	wifiLabel.TextSize = 12
	wifiLabel.TextColor3 = C.TextPrimary
	wifiLabel.Text = "📶"
	wifiLabel.Parent = rightBtn

	rightBtn.MouseButton1Click:Connect(function()
		self:ToggleControlCenter()
	end)
end

--------------------------------------------------------------------------------
-- Control Center (Pull-down Overlay)
--------------------------------------------------------------------------------
function PhoneUI:BuildControlCenter(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local cc = Instance.new("Frame")
	cc.Name = "ControlCenter"
	cc.Size = UDim2.new(1, 0, 1, 0)
	cc.Position = UDim2.new(0, 0, -1, 0) -- Hidden above
	cc.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
	cc.BackgroundTransparency = 0.08
	cc.BorderSizePixel = 0
	cc.ZIndex = 85
	cc.Visible = false
	cc.Parent = parent
	self.ControlCenterFrame = cc

	local pad = makePadding(52, 20, 18, 18, cc)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 18
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Control Center"
	title.Parent = cc

	-- 2x2 Network Platter
	local netPlatter = Instance.new("Frame")
	netPlatter.Size = UDim2.new(0.48, 0, 0, 130)
	netPlatter.Position = UDim2.new(0, 0, 0, 32)
	netPlatter.BackgroundColor3 = C.CardBg
	netPlatter.BorderSizePixel = 0
	netPlatter.Parent = cc
	makeCorner(18, netPlatter)
	makeStroke(C.CardStroke, 1, netPlatter)

	local netGrid = Instance.new("UIGridLayout")
	netGrid.CellSize = UDim2.new(0, 50, 0, 50)
	netGrid.CellPadding = UDim2.new(0, 10, 0, 10)
	netGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	netGrid.VerticalAlignment = Enum.VerticalAlignment.Center
	netGrid.Parent = netPlatter

	local function makeCcBtn(glyph: string, activeColor: Color3, isActive: boolean, onClick: () -> ()): TextButton
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = isActive and activeColor or C.KeypadNumberBg
		btn.Text = glyph
		btn.Font = F.Bold
		btn.TextSize = 18
		btn.BorderSizePixel = 0
		btn.Parent = netPlatter
		makeCorner(25, btn)
		btn.MouseButton1Click:Connect(onClick)
		return btn
	end

	local bAirplane = makeCcBtn("✈️", C.SystemOrange, self.State.AirplaneMode, function()
		self.State.AirplaneMode = not self.State.AirplaneMode
		self:ShowNotification("Airplane Mode", self.State.AirplaneMode and "Turned On" or "Turned Off", "✈️")
	end)

	local bWifi = makeCcBtn("📶", C.SystemBlue, self.State.WifiConnected, function()
		self.State.WifiConnected = not self.State.WifiConnected
		self:ShowNotification("Wi-Fi", self.State.WifiConnected and "Connected" or "Disconnected", "📶")
	end)

	local bBluetooth = makeCcBtn("🔷", C.SystemBlue, self.State.BluetoothOn, function()
		self.State.BluetoothOn = not self.State.BluetoothOn
		self:ShowNotification("Bluetooth", self.State.BluetoothOn and "On" or "Off", "🔷")
	end)

	local bData = makeCcBtn("📡", C.SystemGreen, true, function()
		self:ShowNotification("Cellular Data", "5G Ultra Active", "📡")
	end)

	-- Media Player Platter (Top Right)
	local mediaPlatter = Instance.new("Frame")
	mediaPlatter.Size = UDim2.new(0.48, 0, 0, 130)
	mediaPlatter.Position = UDim2.new(0.52, 0, 0, 32)
	mediaPlatter.BackgroundColor3 = C.CardBg
	mediaPlatter.BorderSizePixel = 0
	mediaPlatter.Parent = cc
	makeCorner(18, mediaPlatter)
	makeStroke(C.CardStroke, 1, mediaPlatter)

	local mTitle = Instance.new("TextLabel")
	mTitle.Size = UDim2.new(1, -16, 0, 20)
	mTitle.Position = UDim2.new(0, 8, 0, 12)
	mTitle.BackgroundTransparency = 1
	mTitle.Font = F.Bold
	mTitle.TextSize = 12
	mTitle.TextColor3 = C.TextPrimary
	mTitle.TextTruncate = Enum.TextTruncate.AtEnd
	mTitle.Text = self.State.CurrentSong.Title
	mTitle.Parent = mediaPlatter

	local mArtist = Instance.new("TextLabel")
	mArtist.Size = UDim2.new(1, -16, 0, 16)
	mArtist.Position = UDim2.new(0, 8, 0, 32)
	mArtist.BackgroundTransparency = 1
	mArtist.Font = F.Regular
	mArtist.TextSize = 10
	mArtist.TextColor3 = C.TextSecondary
	mArtist.Text = self.State.CurrentSong.Artist
	mArtist.Parent = mediaPlatter

	local playBtn = Instance.new("TextButton")
	playBtn.Size = UDim2.new(0, 44, 0, 44)
	playBtn.Position = UDim2.new(0.5, -22, 0, 68)
	playBtn.BackgroundColor3 = C.SystemBlue
	playBtn.Text = "▶️"
	playBtn.Font = F.Bold
	playBtn.TextSize = 16
	playBtn.BorderSizePixel = 0
	playBtn.Parent = mediaPlatter
	makeCorner(22, playBtn)

	playBtn.MouseButton1Click:Connect(function()
		self.State.IsPlayingMusic = not self.State.IsPlayingMusic
		playBtn.Text = self.State.IsPlayingMusic and "⏸️" or "▶️"
		self.IslandDot.Visible = self.State.IsPlayingMusic
		self.IslandTitle.Text = self.State.CurrentSong.Title
		self.IslandSub.Text = self.State.CurrentSong.Artist
	end)

	-- Sliders Row (Brightness & Volume)
	local slidersFrame = Instance.new("Frame")
	slidersFrame.Size = UDim2.new(1, 0, 0, 130)
	slidersFrame.Position = UDim2.new(0, 0, 0, 175)
	slidersFrame.BackgroundTransparency = 1
	slidersFrame.Parent = cc

	local function makeSlider(xScale: number, icon: string, currentVal: number, onUpdate: (val: number) -> ()): Frame
		local capsule = Instance.new("Frame")
		capsule.Size = UDim2.new(0.48, 0, 1, 0)
		capsule.Position = UDim2.new(xScale, 0, 0, 0)
		capsule.BackgroundColor3 = C.SliderBg
		capsule.BorderSizePixel = 0
		capsule.Parent = slidersFrame
		makeCorner(20, capsule)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(1, 0, currentVal, 0)
		fill.AnchorPoint = Vector2.new(0, 1)
		fill.Position = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
		fill.BorderSizePixel = 0
		fill.Parent = capsule
		makeCorner(20, fill)

		local ico = Instance.new("TextLabel")
		ico.Size = UDim2.new(1, 0, 0, 30)
		ico.AnchorPoint = Vector2.new(0.5, 1)
		ico.Position = UDim2.new(0.5, 0, 1, -8)
		ico.BackgroundTransparency = 1
		ico.Text = icon
		ico.Font = F.Bold
		ico.TextSize = 16
		ico.Parent = capsule

		return capsule
	end

	makeSlider(0, "☀️", 0.85, function() end)
	makeSlider(0.52, "🔊", 0.70, function() end)

	-- Close Button at bottom
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(1, 0, 0, 44)
	closeBtn.Position = UDim2.new(0, 0, 1, -54)
	closeBtn.BackgroundColor3 = C.CardBg
	closeBtn.Text = "Done"
	closeBtn.Font = F.Bold
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = C.SystemBlue
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = cc
	makeCorner(16, closeBtn)
	makeStroke(C.CardStroke, 1, closeBtn)

	closeBtn.MouseButton1Click:Connect(function()
		self:ToggleControlCenter()
	end)
end

function PhoneUI:ToggleControlCenter()
	local T = PhoneTheme.Tweens
	self.State.ControlCenterOpen = not self.State.ControlCenterOpen

	if self.State.ControlCenterOpen then
		self.ControlCenterFrame.Visible = true
		TweenService:Create(self.ControlCenterFrame, T.SlowSlide, {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
	else
		local tw = TweenService:Create(self.ControlCenterFrame, T.SlowSlide, {
			Position = UDim2.new(0, 0, -1, 0)
		})
		tw:Play()
		tw.Completed:Connect(function()
			if not self.State.ControlCenterOpen then
				self.ControlCenterFrame.Visible = false
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- Springboard (Home App Grid)
--------------------------------------------------------------------------------
function PhoneUI:BuildSpringboard(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions
	local F = PhoneTheme.Fonts

	local springboard = Instance.new("ScrollingFrame")
	springboard.Name = "Springboard"
	springboard.Size = UDim2.new(1, 0, 1, -(D.StatusBarHeight + D.DockHeight + 14))
	springboard.Position = UDim2.new(0, 0, 0, D.StatusBarHeight + 4)
	springboard.BackgroundTransparency = 1
	springboard.ScrollBarThickness = 0
	springboard.CanvasSize = UDim2.new(0, 0, 0, 480)
	springboard.ZIndex = 10
	springboard.Parent = parent
	self.Springboard = springboard

	----------------------------------------------------------------------------
	-- Top Row: Clock Widget (Left) + Weather Widget (Right) (2x2 square cards)
	----------------------------------------------------------------------------
	local topWidgets = Instance.new("Frame")
	topWidgets.Name = "TopWidgetsRow"
	topWidgets.Size = UDim2.new(1, -28, 0, 128)
	topWidgets.AnchorPoint = Vector2.new(0.5, 0)
	topWidgets.Position = UDim2.new(0.5, 0, 0, 8)
	topWidgets.BackgroundTransparency = 1
	topWidgets.Parent = springboard

	-- Clock Widget Unit
	local clockUnit = Instance.new("TextButton")
	clockUnit.Name = "ClockWidgetUnit"
	clockUnit.Size = UDim2.new(0.5, -7, 1, 0)
	clockUnit.Position = UDim2.new(0, 0, 0, 0)
	clockUnit.BackgroundTransparency = 1
	clockUnit.Text = ""
	clockUnit.Parent = topWidgets

	local clockCard = Instance.new("Frame")
	clockCard.Size = UDim2.new(1, 0, 0, 108)
	clockCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
	clockCard.BorderSizePixel = 0
	clockCard.Parent = clockUnit
	makeCorner(20, clockCard)
	makeStroke(Color3.fromRGB(255, 255, 255), 0.08, clockCard)

	local clockDay = Instance.new("TextLabel")
	clockDay.Size = UDim2.new(1, -20, 0, 16)
	clockDay.Position = UDim2.new(0, 12, 0, 10)
	clockDay.BackgroundTransparency = 1
	clockDay.Text = "Thursday"
	clockDay.Font = F.Medium
	clockDay.TextSize = 12
	clockDay.TextColor3 = Color3.fromRGB(142, 142, 147)
	clockDay.TextXAlignment = Enum.TextXAlignment.Left
	clockDay.Parent = clockCard

	local clockTime = Instance.new("TextLabel")
	clockTime.Size = UDim2.new(1, -20, 0, 32)
	clockTime.Position = UDim2.new(0, 12, 0, 26)
	clockTime.BackgroundTransparency = 1
	clockTime.Text = "20:16"
	clockTime.Font = F.LargeTitle
	clockTime.TextSize = 28
	clockTime.TextColor3 = Color3.fromRGB(255, 255, 255)
	clockTime.TextXAlignment = Enum.TextXAlignment.Left
	clockTime.Parent = clockCard

	local clockDate = Instance.new("TextLabel")
	clockDate.Size = UDim2.new(1, -20, 0, 28)
	clockDate.Position = UDim2.new(0, 12, 0, 60)
	clockDate.BackgroundTransparency = 1
	clockDate.Text = "Thursday, September 10"
	clockDate.Font = F.Medium
	clockDate.TextSize = 10
	clockDate.TextColor3 = Color3.fromRGB(142, 142, 147)
	clockDate.TextXAlignment = Enum.TextXAlignment.Left
	clockDate.TextWrapped = true
	clockDate.Parent = clockCard

	local clockLabel = Instance.new("TextLabel")
	clockLabel.Size = UDim2.new(1, 0, 0, 16)
	clockLabel.Position = UDim2.new(0, 0, 0, 110)
	clockLabel.BackgroundTransparency = 1
	clockLabel.Text = "Clock"
	clockLabel.Font = F.Medium
	clockLabel.TextSize = 11
	clockLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	clockLabel.Parent = clockUnit

	clockUnit.MouseButton1Click:Connect(function()
		self:OpenApp("clock")
	end)

	-- Weather Widget Unit
	local weatherUnit = Instance.new("TextButton")
	weatherUnit.Name = "WeatherWidgetUnit"
	weatherUnit.Size = UDim2.new(0.5, -7, 1, 0)
	weatherUnit.Position = UDim2.new(0.5, 7, 0, 0)
	weatherUnit.BackgroundTransparency = 1
	weatherUnit.Text = ""
	weatherUnit.Parent = topWidgets

	local weatherCard = Instance.new("Frame")
	weatherCard.Size = UDim2.new(1, 0, 0, 108)
	weatherCard.BackgroundColor3 = Color3.fromRGB(28, 59, 112)
	weatherCard.BorderSizePixel = 0
	weatherCard.Parent = weatherUnit
	makeCorner(20, weatherCard)
	makeStroke(Color3.fromRGB(255, 255, 255), 0.15, weatherCard)

	local wGrad = Instance.new("UIGradient")
	wGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 65, 125)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 100, 170)),
	})
	wGrad.Rotation = 135
	wGrad.Parent = weatherCard

	local wCity = Instance.new("TextLabel")
	wCity.Size = UDim2.new(1, -20, 0, 16)
	wCity.Position = UDim2.new(0, 12, 0, 10)
	wCity.BackgroundTransparency = 1
	wCity.Text = "Los Santos"
	wCity.Font = F.Headline
	wCity.TextSize = 12
	wCity.TextColor3 = Color3.fromRGB(255, 255, 255)
	wCity.TextXAlignment = Enum.TextXAlignment.Left
	wCity.Parent = weatherCard

	local wTemp = Instance.new("TextLabel")
	wTemp.Size = UDim2.new(1, -20, 0, 34)
	wTemp.Position = UDim2.new(0, 12, 0, 24)
	wTemp.BackgroundTransparency = 1
	wTemp.Text = "24°"
	wTemp.Font = F.LargeTitle
	wTemp.TextSize = 30
	wTemp.TextColor3 = Color3.fromRGB(255, 255, 255)
	wTemp.TextXAlignment = Enum.TextXAlignment.Left
	wTemp.Parent = weatherCard

	local wDesc = Instance.new("TextLabel")
	wDesc.Size = UDim2.new(1, -20, 0, 16)
	wDesc.Position = UDim2.new(0, 12, 0, 62)
	wDesc.BackgroundTransparency = 1
	wDesc.Text = "⛅ Partly Cloudy"
	wDesc.Font = F.Medium
	wDesc.TextSize = 10
	wDesc.TextColor3 = Color3.fromRGB(255, 255, 255)
	wDesc.TextXAlignment = Enum.TextXAlignment.Left
	wDesc.Parent = weatherCard

	local wHl = Instance.new("TextLabel")
	wHl.Size = UDim2.new(1, -20, 0, 14)
	wHl.Position = UDim2.new(0, 12, 0, 78)
	wHl.BackgroundTransparency = 1
	wHl.Text = "H: 24° L: 13°"
	wHl.Font = F.Caption1
	wHl.TextSize = 9
	wHl.TextColor3 = Color3.fromRGB(200, 220, 255)
	wHl.TextXAlignment = Enum.TextXAlignment.Left
	wHl.Parent = weatherCard

	local weatherLabel = Instance.new("TextLabel")
	weatherLabel.Size = UDim2.new(1, 0, 0, 16)
	weatherLabel.Position = UDim2.new(0, 0, 0, 110)
	weatherLabel.BackgroundTransparency = 1
	weatherLabel.Text = "Weather"
	weatherLabel.Font = F.Medium
	weatherLabel.TextSize = 11
	weatherLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	weatherLabel.Parent = weatherUnit

	weatherUnit.MouseButton1Click:Connect(function()
		self:OpenApp("weather")
	end)

	----------------------------------------------------------------------------
	-- Second Row: Wide Music Widget (4x2 card)
	----------------------------------------------------------------------------
	local musicUnit = Instance.new("TextButton")
	musicUnit.Name = "MusicWidgetUnit"
	musicUnit.Size = UDim2.new(1, -28, 0, 96)
	musicUnit.AnchorPoint = Vector2.new(0.5, 0)
	musicUnit.Position = UDim2.new(0.5, 0, 0, 142)
	musicUnit.BackgroundTransparency = 1
	musicUnit.Text = ""
	musicUnit.Parent = springboard

	local musicCard = Instance.new("Frame")
	musicCard.Size = UDim2.new(1, 0, 0, 76)
	musicCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
	musicCard.BackgroundTransparency = 0.15
	musicCard.BorderSizePixel = 0
	musicCard.Parent = musicUnit
	makeCorner(20, musicCard)
	makeStroke(Color3.fromRGB(255, 255, 255), 0.08, musicCard)

	local artBox = Instance.new("Frame")
	artBox.Size = UDim2.new(0, 44, 0, 44)
	artBox.Position = UDim2.new(0, 12, 0, 8)
	artBox.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
	artBox.BorderSizePixel = 0
	artBox.Parent = musicCard
	makeCorner(10, artBox)

	local artGlyph = Instance.new("TextLabel")
	artGlyph.Size = UDim2.new(1, 0, 1, 0)
	artGlyph.BackgroundTransparency = 1
	artGlyph.Text = "🎵"
	artGlyph.TextSize = 20
	artGlyph.Parent = artBox

	local noteGlyph = Instance.new("TextLabel")
	noteGlyph.Size = UDim2.new(0, 20, 0, 20)
	noteGlyph.AnchorPoint = Vector2.new(1, 0)
	noteGlyph.Position = UDim2.new(1, -12, 0, 8)
	noteGlyph.BackgroundTransparency = 1
	noteGlyph.Text = "♫"
	noteGlyph.Font = F.Bold
	noteGlyph.TextSize = 16
	noteGlyph.TextColor3 = Color3.fromRGB(255, 45, 85)
	noteGlyph.Parent = musicCard

	local barTrack = Instance.new("Frame")
	barTrack.Size = UDim2.new(1, -84, 0, 4)
	barTrack.Position = UDim2.new(0, 66, 0, 28)
	barTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	barTrack.BorderSizePixel = 0
	barTrack.Parent = musicCard
	makeCorner(2, barTrack)

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.new(0.35, 0, 1, 0)
	barFill.BackgroundColor3 = Color3.fromRGB(255, 45, 85)
	barFill.BorderSizePixel = 0
	barFill.Parent = barTrack
	makeCorner(2, barFill)

	local musicStatus = Instance.new("TextLabel")
	musicStatus.Size = UDim2.new(1, 0, 0, 16)
	musicStatus.Position = UDim2.new(0, 0, 1, -22)
	musicStatus.BackgroundTransparency = 1
	musicStatus.Text = "No recently played music"
	musicStatus.Font = F.Medium
	musicStatus.TextSize = 11
	musicStatus.TextColor3 = Color3.fromRGB(142, 142, 147)
	musicStatus.Parent = musicCard

	local musicLabel = Instance.new("TextLabel")
	musicLabel.Size = UDim2.new(1, 0, 0, 16)
	musicLabel.Position = UDim2.new(0, 0, 0, 78)
	musicLabel.BackgroundTransparency = 1
	musicLabel.Text = "Music"
	musicLabel.Font = F.Medium
	musicLabel.TextSize = 11
	musicLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	musicLabel.Parent = musicUnit

	musicUnit.MouseButton1Click:Connect(function()
		self:OpenApp("music")
	end)

	----------------------------------------------------------------------------
	-- 8 Hero Springboard Apps (4 columns x 2 rows)
	----------------------------------------------------------------------------
	local gridFrame = Instance.new("Frame")
	gridFrame.Name = "AppGrid"
	gridFrame.Size = UDim2.new(1, -28, 0, 160)
	gridFrame.AnchorPoint = Vector2.new(0.5, 0)
	gridFrame.Position = UDim2.new(0.5, 0, 0, 246)
	gridFrame.BackgroundTransparency = 1
	gridFrame.Parent = springboard

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 56, 0, 72)
	grid.CellPadding = UDim2.new(0, 14, 0, 10)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = gridFrame

	-- Hero App IDs to populate on Page 0
	local heroIds = { "calculator", "bank", "weather", "billing", "mail", "crypto", "notes", "memos" }
	local heroSet = {}
	for _, id in ipairs(heroIds) do heroSet[id] = true end

	for idx, id in ipairs(heroIds) do
		local appDef = nil
		for _, a in ipairs(PhoneTheme.Apps) do
			if a.Id == id then appDef = a; break end
		end

		if appDef then
			local btn = Instance.new("TextButton")
			btn.Name = "App_" .. appDef.Id
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.LayoutOrder = idx
			btn.Parent = gridFrame

			local iconWrap = Instance.new("Frame")
			iconWrap.Size = UDim2.new(0, 52, 0, 52)
			iconWrap.AnchorPoint = Vector2.new(0.5, 0)
			iconWrap.Position = UDim2.new(0.5, 0, 0, 0)
			iconWrap.BackgroundColor3 = appDef.BgColor
			iconWrap.BorderSizePixel = 0
			iconWrap.Parent = btn
			makeCorner(13, iconWrap)

			local glyph = Instance.new("TextLabel")
			glyph.Size = UDim2.new(1, 0, 1, 0)
			glyph.BackgroundTransparency = 1
			glyph.Text = appDef.Glyph
			glyph.TextSize = 24
			glyph.Parent = iconWrap

			if appDef.Badge and appDef.Badge > 0 then
				local badge = Instance.new("TextLabel")
				badge.Size = UDim2.new(0, 18, 0, 18)
				badge.AnchorPoint = Vector2.new(1, 0)
				badge.Position = UDim2.new(1, 4, 0, -4)
				badge.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
				badge.BorderSizePixel = 0
				badge.Text = tostring(appDef.Badge)
				badge.Font = F.Bold
				badge.TextSize = 11
				badge.TextColor3 = Color3.fromRGB(255, 255, 255)
				badge.ZIndex = 5
				badge.Parent = iconWrap
				makeCorner(9, badge)
			end

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 14)
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.new(0.5, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = appDef.Name
			label.Font = F.Medium
			label.TextSize = 11
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.Parent = btn

			btn.MouseButton1Click:Connect(function()
				self:OpenApp(appDef.Id)
			end)
		end
	end

	----------------------------------------------------------------------------
	-- Page Dots (4 dots matching Sky Phone pagination)
	----------------------------------------------------------------------------
	local dots = Instance.new("Frame")
	dots.Name = "PaginationDots"
	dots.Size = UDim2.new(0, 50, 0, 10)
	dots.AnchorPoint = Vector2.new(0.5, 0)
	dots.Position = UDim2.new(0.5, 0, 0, 420)
	dots.BackgroundTransparency = 1
	dots.Parent = springboard

	local dotsLayout = Instance.new("UIListLayout")
	dotsLayout.FillDirection = Enum.FillDirection.Horizontal
	dotsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dotsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dotsLayout.Padding = UDim.new(0, 6)
	dotsLayout.Parent = dots

	for i = 1, 4 do
		local dot = Instance.new("Frame")
		dot.Size = i == 1 and UDim2.new(0, 7, 0, 7) or UDim2.new(0, 6, 0, 6)
		dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dot.BackgroundTransparency = i == 1 and 0 or 0.65
		dot.BorderSizePixel = 0
		dot.Parent = dots
		makeCorner(4, dot)
	end
end

--------------------------------------------------------------------------------
-- Bottom Dock
--------------------------------------------------------------------------------
function PhoneUI:BuildDock(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions

	local dock = Instance.new("Frame")
	dock.Name = "PhoneDock"
	dock.Size = UDim2.new(1, -20, 0, D.DockHeight)
	dock.AnchorPoint = Vector2.new(0.5, 1)
	dock.Position = UDim2.new(0.5, 0, 1, -16)
	dock.BackgroundColor3 = C.DockBg
	dock.BackgroundTransparency = 0.35
	dock.BorderSizePixel = 0
	dock.ZIndex = 20
	dock.Parent = parent
	self.Dock = dock
	makeCorner(28, dock)
	makeStroke(C.CardStroke, 1, dock)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 14)
	layout.Parent = dock

	for idx, appDef in ipairs(PhoneTheme.Apps) do
		if appDef.Dock then
			local btn = Instance.new("TextButton")
			btn.Name = "DockApp_" .. appDef.Id
			btn.Size = UDim2.new(0, D.IconSize, 0, D.IconSize)
			btn.BackgroundColor3 = appDef.BgColor
			btn.BorderSizePixel = 0
			btn.Text = ""
			btn.LayoutOrder = idx
			btn.Parent = dock
			makeCorner(D.IconRadius, btn)

			local glyph = Instance.new("TextLabel")
			glyph.Size = UDim2.new(1, 0, 1, 0)
			glyph.BackgroundTransparency = 1
			glyph.Text = appDef.Glyph
			glyph.TextSize = 24
			glyph.Parent = btn

			btn.MouseButton1Click:Connect(function()
				self:OpenApp(appDef.Id)
			end)
		end
	end
end

--------------------------------------------------------------------------------
-- Lock Screen
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
	lock.ZIndex = 70
	lock.Parent = parent
	self.LockScreen = lock

	local dateLabel = Instance.new("TextLabel")
	dateLabel.Size = UDim2.new(1, 0, 0, 20)
	dateLabel.Position = UDim2.new(0, 0, 0, 58)
	dateLabel.BackgroundTransparency = 1
	dateLabel.Font = F.Medium
	dateLabel.TextSize = 14
	dateLabel.TextColor3 = C.TextSecondary
	dateLabel.Text = "Wednesday, September 10"
	dateLabel.Parent = lock
	self.LockDateLabel = dateLabel

	local clockLabel = Instance.new("TextLabel")
	clockLabel.Size = UDim2.new(1, 0, 0, 72)
	clockLabel.Position = UDim2.new(0, 0, 0, 80)
	clockLabel.BackgroundTransparency = 1
	clockLabel.Font = F.Bold
	clockLabel.TextSize = 64
	clockLabel.TextColor3 = C.TextPrimary
	clockLabel.Text = "12:00"
	clockLabel.Parent = lock
	self.LockClockLabel = clockLabel

	-- Flashlight & Camera Quick Circles
	local function makeCircle(xScale: number, glyph: string, onClick: () -> ())
		local circle = Instance.new("TextButton")
		circle.Size = UDim2.new(0, 48, 0, 48)
		circle.AnchorPoint = Vector2.new(xScale, 1)
		circle.Position = UDim2.new(xScale, xScale == 0 and 24 or -24, 1, -44)
		circle.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
		circle.BackgroundTransparency = 0.3
		circle.Text = glyph
		circle.TextSize = 20
		circle.BorderSizePixel = 0
		circle.Parent = lock
		makeCorner(24, circle)
		circle.MouseButton1Click:Connect(onClick)
	end

	makeCircle(0, "🔦", function()
		self.State.FlashlightOn = not self.State.FlashlightOn
		self:ShowNotification("Flashlight", self.State.FlashlightOn and "On" or "Off", "🔦")
	end)

	makeCircle(1, "📷", function()
		self:Unlock()
		self:OpenApp("camera")
	end)

	-- Unlock Tap
	local unlockBtn = Instance.new("TextButton")
	unlockBtn.Size = UDim2.new(1, 0, 1, 0)
	unlockBtn.BackgroundTransparency = 1
	unlockBtn.Text = ""
	unlockBtn.Parent = lock

	unlockBtn.MouseButton1Click:Connect(function()
		self:Unlock()
	end)
end

--------------------------------------------------------------------------------
-- Home Indicator
--------------------------------------------------------------------------------
function PhoneUI:BuildHomeIndicator(parent: Instance)
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions

	local bar = Instance.new("TextButton")
	bar.Name = "HomeIndicator"
	bar.Size = UDim2.new(0, D.HomeIndicatorWidth, 0, 16)
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.new(0.5, 0, 1, -4)
	bar.BackgroundTransparency = 1
	bar.Text = ""
	bar.ZIndex = 60
	bar.Parent = parent

	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(1, 0, 0, D.HomeIndicatorHeight)
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
			self:Toggle()
		end
	end)
end

--------------------------------------------------------------------------------
-- Notification Banner
--------------------------------------------------------------------------------
function PhoneUI:BuildNotificationBanner(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local banner = Instance.new("Frame")
	banner.Name = "NotificationBanner"
	banner.Size = UDim2.new(1, -24, 0, 62)
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0, -80)
	banner.BackgroundColor3 = C.CardBg
	banner.BorderSizePixel = 0
	banner.ZIndex = 80
	banner.Visible = false
	banner.Parent = parent
	self.NotificationBanner = banner
	makeCorner(16, banner)
	makeStroke(C.CardStroke, 1, banner)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 36, 0, 36)
	icon.Position = UDim2.new(0, 12, 0, 13)
	icon.BackgroundTransparency = 1
	icon.Text = "💬"
	icon.TextSize = 20
	icon.Parent = banner
	self.NotifIcon = icon

	local nTitle = Instance.new("TextLabel")
	nTitle.Size = UDim2.new(1, -64, 0, 18)
	nTitle.Position = UDim2.new(0, 54, 0, 12)
	nTitle.BackgroundTransparency = 1
	nTitle.Font = F.Bold
	nTitle.TextSize = 12
	nTitle.TextColor3 = C.TextPrimary
	nTitle.TextXAlignment = Enum.TextXAlignment.Left
	nTitle.Text = "Notification"
	nTitle.Parent = banner
	self.NotifTitle = nTitle

	local nMsg = Instance.new("TextLabel")
	nMsg.Size = UDim2.new(1, -64, 0, 16)
	nMsg.Position = UDim2.new(0, 54, 0, 32)
	nMsg.BackgroundTransparency = 1
	nMsg.Font = F.Regular
	nMsg.TextSize = 11
	nMsg.TextColor3 = C.TextSecondary
	nMsg.TextXAlignment = Enum.TextXAlignment.Left
	nMsg.TextTruncate = Enum.TextTruncate.AtEnd
	nMsg.Text = "Message content"
	nMsg.Parent = banner
	self.NotifMsg = nMsg
end

function PhoneUI:ShowNotification(title: string, msg: string, glyph: string?)
	local T = PhoneTheme.Tweens
	self.NotifTitle.Text = title
	self.NotifMsg.Text = msg
	self.NotifIcon.Text = glyph or "🔔"
	self.NotificationBanner.Visible = true

	TweenService:Create(self.NotificationBanner, T.Spring, {
		Position = UDim2.new(0.5, 0, 0, 16)
	}):Play()

	task.delay(3.5, function()
		if self.NotificationBanner then
			local tw = TweenService:Create(self.NotificationBanner, T.Snappy, {
				Position = UDim2.new(0.5, 0, 0, -80)
			})
			tw:Play()
			tw.Completed:Connect(function()
				self.NotificationBanner.Visible = false
			end)
		end
	end)
end

--------------------------------------------------------------------------------
-- App Container Factory
--------------------------------------------------------------------------------
function PhoneUI:CreateAppContainer(id: string, parent: Instance): Frame
	local C = PhoneTheme.Colors
	local D = PhoneTheme.Dimensions

	local appFrame = Instance.new("Frame")
	appFrame.Name = "App_" .. id
	appFrame.Size = UDim2.new(1, 0, 1, 0)
	appFrame.BackgroundColor3 = C.ScreenBg
	appFrame.BorderSizePixel = 0
	appFrame.ZIndex = 30
	appFrame.Visible = false
	appFrame.Parent = parent
	self.AppContainers[id] = appFrame

	-- Top Header padding to clear Status Bar & Island
	local headerPad = Instance.new("Frame")
	headerPad.Size = UDim2.new(1, 0, 0, D.StatusBarHeight + 10)
	headerPad.BackgroundTransparency = 1
	headerPad.Parent = appFrame

	return appFrame
end

--------------------------------------------------------------------------------
-- App 1: Phone / Dialer
--------------------------------------------------------------------------------
function PhoneUI:BuildPhoneApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("phone", parent)

	local numberDisplay = Instance.new("TextLabel")
	numberDisplay.Size = UDim2.new(1, -32, 0, 48)
	numberDisplay.Position = UDim2.new(0, 16, 0, 70)
	numberDisplay.BackgroundTransparency = 1
	numberDisplay.Font = F.Bold
	numberDisplay.TextSize = 28
	numberDisplay.TextColor3 = C.TextPrimary
	numberDisplay.Text = ""
	numberDisplay.Parent = frame
	self.DialerDisplay = numberDisplay

	local keypad = Instance.new("Frame")
	keypad.Size = UDim2.new(1, -40, 0, 290)
	keypad.Position = UDim2.new(0, 20, 0, 130)
	keypad.BackgroundTransparency = 1
	keypad.Parent = frame

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 68, 0, 60)
	grid.CellPadding = UDim2.new(0, 24, 0, 12)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = keypad

	local keys = {
		{ "1", "" }, { "2", "ABC" }, { "3", "DEF" },
		{ "4", "GHI" }, { "5", "JKL" }, { "6", "MNO" },
		{ "7", "PQRS" }, { "8", "TUV" }, { "9", "WXYZ" },
		{ "*", "" }, { "0", "+" }, { "#", "" }
	}

	for _, k in ipairs(keys) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = C.KeypadNumberBg
		btn.Text = k[1]
		btn.Font = F.Bold
		btn.TextSize = 22
		btn.TextColor3 = C.KeypadNumberText
		btn.BorderSizePixel = 0
		btn.Parent = keypad
		makeCorner(30, btn)

		btn.MouseButton1Click:Connect(function()
			self.State.DialedNumber ..= k[1]
			numberDisplay.Text = self.State.DialedNumber
		end)
	end

	-- Call & Backspace Controls
	local controls = Instance.new("Frame")
	controls.Size = UDim2.new(1, -40, 0, 64)
	controls.Position = UDim2.new(0, 20, 0, 440)
	controls.BackgroundTransparency = 1
	controls.Parent = frame

	local callBtn = Instance.new("TextButton")
	callBtn.Size = UDim2.new(0, 64, 0, 64)
	callBtn.Position = UDim2.new(0.5, -32, 0, 0)
	callBtn.BackgroundColor3 = C.SystemGreen
	callBtn.Text = "📞"
	callBtn.TextSize = 26
	callBtn.BorderSizePixel = 0
	callBtn.Parent = controls
	makeCorner(32, callBtn)

	callBtn.MouseButton1Click:Connect(function()
		if #self.State.DialedNumber > 0 then
			self:StartCall(self.State.DialedNumber)
		end
	end)

	local backspaceBtn = Instance.new("TextButton")
	backspaceBtn.Size = UDim2.new(0, 44, 0, 44)
	backspaceBtn.Position = UDim2.new(1, -54, 0, 10)
	backspaceBtn.BackgroundTransparency = 1
	backspaceBtn.Text = "⌫"
	backspaceBtn.Font = F.Bold
	backspaceBtn.TextSize = 22
	backspaceBtn.TextColor3 = C.TextSecondary
	backspaceBtn.Parent = controls

	backspaceBtn.MouseButton1Click:Connect(function()
		if #self.State.DialedNumber > 0 then
			self.State.DialedNumber = string.sub(self.State.DialedNumber, 1, #self.State.DialedNumber - 1)
			numberDisplay.Text = self.State.DialedNumber
		end
	end)
end

function PhoneUI:StartCall(number: string)
	self.State.ActiveCall = { Number = number, StartTime = os.clock() }
	self.IslandDot.Visible = true
	self.IslandTitle.Text = "Calling " .. number
	self.IslandSub.Text = "Connected"
	self:ShowNotification("Phone", "Calling " .. number .. "...", "📞")
	if self.OnCallStarted then
		self.OnCallStarted(number)
	end
end

function PhoneUI:EndCall()
	self.State.ActiveCall = nil
	self.IslandDot.Visible = false
	self.IslandTitle.Text = "Call Ended"
	self.IslandSub.Text = "Disconnected"
	self:ShowNotification("Phone", "Call Ended", "📞")
	if self.OnCallEnded then
		self.OnCallEnded()
	end
end

--------------------------------------------------------------------------------
-- App 2: Messages
--------------------------------------------------------------------------------
function PhoneUI:BuildMessagesApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("messages", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 32)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Messages"
	title.Parent = frame

	local chatScroll = Instance.new("ScrollingFrame")
	chatScroll.Size = UDim2.new(1, -24, 0, 420)
	chatScroll.Position = UDim2.new(0, 12, 0, 90)
	chatScroll.BackgroundTransparency = 1
	chatScroll.ScrollBarThickness = 3
	chatScroll.Parent = frame
	self.ChatScroll = chatScroll

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = chatScroll

	self:AddMessageBubble("Hey! Welcome to Sun City.", false)
	self:AddMessageBubble("Your Sky Phone is activated.", false)

	-- Input bar
	local inputBar = Instance.new("Frame")
	inputBar.Size = UDim2.new(1, -24, 0, 44)
	inputBar.Position = UDim2.new(0, 12, 1, -64)
	inputBar.BackgroundColor3 = C.InputBg
	inputBar.BorderSizePixel = 0
	inputBar.Parent = frame
	makeCorner(22, inputBar)
	makeStroke(C.InputStroke, 1, inputBar)

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -54, 1, 0)
	textBox.Position = UDim2.new(0, 14, 0, 0)
	textBox.BackgroundTransparency = 1
	textBox.Font = F.Regular
	textBox.TextSize = 13
	textBox.TextColor3 = C.TextPrimary
	textBox.PlaceholderText = "iMessage..."
	textBox.PlaceholderColor3 = C.TextPlaceholder
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Text = ""
	textBox.ClearTextOnFocus = false
	textBox.Parent = inputBar

	local sendBtn = Instance.new("TextButton")
	sendBtn.Size = UDim2.new(0, 32, 0, 32)
	sendBtn.AnchorPoint = Vector2.new(1, 0.5)
	sendBtn.Position = UDim2.new(1, -6, 0.5, 0)
	sendBtn.BackgroundColor3 = C.SystemBlue
	sendBtn.Text = "↑"
	sendBtn.Font = F.Bold
	sendBtn.TextSize = 18
	sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	sendBtn.BorderSizePixel = 0
	sendBtn.Parent = inputBar
	makeCorner(16, sendBtn)

	local function sendMessage()
		local text = textBox.Text
		if #text > 0 then
			self:AddMessageBubble(text, true)
			textBox.Text = ""
			if self.OnMessageSent then
				self.OnMessageSent("Global", text)
			end
		end
	end

	sendBtn.MouseButton1Click:Connect(sendMessage)
	textBox.FocusLost:Connect(function(enter)
		if enter then sendMessage() end
	end)
end

function PhoneUI:AddMessageBubble(text: string, isSender: boolean)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.new(0.8, 0, 0, 36)
	bubble.AnchorPoint = Vector2.new(isSender and 1 or 0, 0)
	bubble.Position = UDim2.new(isSender and 1 or 0, 0, 0, 0)
	bubble.BackgroundColor3 = isSender and C.SystemBlue or C.CardBg
	bubble.BorderSizePixel = 0
	bubble.Parent = self.ChatScroll
	makeCorner(16, bubble)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = F.Regular
	lbl.TextSize = 12
	lbl.TextColor3 = C.TextPrimary
	lbl.TextXAlignment = isSender and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
	lbl.TextWrapped = true
	lbl.Text = text
	lbl.Parent = bubble
end

--------------------------------------------------------------------------------
-- App 3: Sun City Bank
--------------------------------------------------------------------------------
function PhoneUI:BuildBankApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("bank", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 28)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Sun City Bank"
	title.Parent = frame

	-- Visa/Platinum Card
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -32, 0, 160)
	card.Position = UDim2.new(0, 16, 0, 90)
	card.BackgroundColor3 = Color3.fromRGB(30, 28, 54)
	card.BorderSizePixel = 0
	card.Parent = frame
	makeCorner(18, card)
	makeStroke(C.SystemIndigo, 1.5, card)

	local cardGrad = Instance.new("UIGradient")
	cardGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(44, 38, 88)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 18, 36)),
	})
	cardGrad.Rotation = 60
	cardGrad.Parent = card

	local chip = Instance.new("Frame")
	chip.Size = UDim2.new(0, 32, 0, 24)
	chip.Position = UDim2.new(0, 18, 0, 18)
	chip.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
	chip.BorderSizePixel = 0
	chip.Parent = card
	makeCorner(6, chip)

	local balTitle = Instance.new("TextLabel")
	balTitle.Size = UDim2.new(1, -36, 0, 16)
	balTitle.Position = UDim2.new(0, 18, 0, 60)
	balTitle.BackgroundTransparency = 1
	balTitle.Font = F.Medium
	balTitle.TextSize = 11
	balTitle.TextColor3 = C.TextSecondary
	balTitle.TextXAlignment = Enum.TextXAlignment.Left
	balTitle.Text = "Total Balance"
	balTitle.Parent = card

	local balAmt = Instance.new("TextLabel")
	balAmt.Size = UDim2.new(1, -36, 0, 32)
	balAmt.Position = UDim2.new(0, 18, 0, 78)
	balAmt.BackgroundTransparency = 1
	balAmt.Font = F.Bold
	balAmt.TextSize = 26
	balAmt.TextColor3 = Color3.fromRGB(255, 255, 255)
	balAmt.TextXAlignment = Enum.TextXAlignment.Left
	balAmt.Text = string.format("$%d", self.State.Balance)
	balAmt.Parent = card
	self.BankBalanceLabel = balAmt

	local cardNum = Instance.new("TextLabel")
	cardNum.Size = UDim2.new(1, -36, 0, 18)
	cardNum.Position = UDim2.new(0, 18, 1, -26)
	cardNum.BackgroundTransparency = 1
	cardNum.Font = F.Medium
	cardNum.TextSize = 12
	cardNum.TextColor3 = Color3.fromRGB(200, 200, 215)
	cardNum.TextXAlignment = Enum.TextXAlignment.Left
	cardNum.Text = "•••• •••• •••• 8842"
	cardNum.Parent = card

	-- Action Buttons
	local btnRow = Instance.new("Frame")
	btnRow.Size = UDim2.new(1, -32, 0, 48)
	btnRow.Position = UDim2.new(0, 16, 0, 265)
	btnRow.BackgroundTransparency = 1
	btnRow.Parent = frame

	local transferBtn = Instance.new("TextButton")
	transferBtn.Size = UDim2.new(1, 0, 1, 0)
	transferBtn.BackgroundColor3 = C.SystemIndigo
	transferBtn.Text = "💸 Quick Transfer ($500)"
	transferBtn.Font = F.Bold
	transferBtn.TextSize = 13
	transferBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	transferBtn.BorderSizePixel = 0
	transferBtn.Parent = btnRow
	makeCorner(14, transferBtn)

	transferBtn.MouseButton1Click:Connect(function()
		if self.State.Balance >= 500 then
			self.State.Balance -= 500
			balAmt.Text = string.format("$%d", self.State.Balance)
			self:ShowNotification("Transfer Sent", "Transferred $500 to contact.", "💸")
			if self.OnTransferMoney then
				self.OnTransferMoney("Contact", 500)
			end
		else
			self:ShowNotification("Declined", "Insufficient funds.", "❌")
		end
	end)
end

--------------------------------------------------------------------------------
-- App 4: Garage
--------------------------------------------------------------------------------
function PhoneUI:BuildGarageApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("garage", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 28)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "My Garage"
	title.Parent = frame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -24, 0, 480)
	scroll.Position = UDim2.new(0, 12, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.Parent = frame

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 12)
	list.Parent = scroll

	local vehicles = {
		{ Id = "veh_01", Name = "Karin Sultan RS", Plate = "SKY-882", Fuel = 85, Health = 100, Locked = true },
		{ Id = "veh_02", Name = "Grotti Turismo R", Plate = "AMG-007", Fuel = 45, Health = 92, Locked = false },
		{ Id = "veh_03", Name = "Pfister Comet S2", Plate = "PCH-911", Fuel = 98, Health = 100, Locked = true },
	}

	for _, v in ipairs(vehicles) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 100)
		card.BackgroundColor3 = C.CardBg
		card.BorderSizePixel = 0
		card.Parent = scroll
		makeCorner(16, card)
		makeStroke(C.CardStroke, 1, card)

		local vName = Instance.new("TextLabel")
		vName.Size = UDim2.new(0.65, 0, 0, 20)
		vName.Position = UDim2.new(0, 14, 0, 12)
		vName.BackgroundTransparency = 1
		vName.Font = F.Bold
		vName.TextSize = 14
		vName.TextColor3 = C.TextPrimary
		vName.TextXAlignment = Enum.TextXAlignment.Left
		vName.Text = v.Name
		vName.Parent = card

		local vPlate = Instance.new("TextLabel")
		vPlate.Size = UDim2.new(0.65, 0, 0, 16)
		vPlate.Position = UDim2.new(0, 14, 0, 32)
		vPlate.BackgroundTransparency = 1
		vPlate.Font = F.Medium
		vPlate.TextSize = 11
		vPlate.TextColor3 = C.TextSecondary
		vPlate.TextXAlignment = Enum.TextXAlignment.Left
		vPlate.Text = "Plate: " .. v.Plate
		vPlate.Parent = card

		local vStats = Instance.new("TextLabel")
		vStats.Size = UDim2.new(0.65, 0, 0, 16)
		vStats.Position = UDim2.new(0, 14, 0, 52)
		vStats.BackgroundTransparency = 1
		vStats.Font = F.Regular
		vStats.TextSize = 10
		vStats.TextColor3 = C.SystemGreen
		vStats.TextXAlignment = Enum.TextXAlignment.Left
		vStats.Text = string.format("⛽ Fuel: %d%%  |  🛡️ Health: %d%%", v.Fuel, v.Health)
		vStats.Parent = card

		local lockBtn = Instance.new("TextButton")
		lockBtn.Size = UDim2.new(0, 38, 0, 38)
		lockBtn.Position = UDim2.new(1, -88, 0, 14)
		lockBtn.BackgroundColor3 = v.Locked and C.SystemRed or C.SystemGreen
		lockBtn.Text = v.Locked and "🔒" or "🔓"
		lockBtn.TextSize = 18
		lockBtn.BorderSizePixel = 0
		lockBtn.Parent = card
		makeCorner(12, lockBtn)

		lockBtn.MouseButton1Click:Connect(function()
			v.Locked = not v.Locked
			lockBtn.BackgroundColor3 = v.Locked and C.SystemRed or C.SystemGreen
			lockBtn.Text = v.Locked and "🔒" or "🔓"
			self:ShowNotification("Vehicle Key", (v.Locked and "Locked " or "Unlocked ") .. v.Name, "🚗")
			if self.OnVehicleAction then
				self.OnVehicleAction(v.Id, v.Locked and "lock" or "unlock")
			end
		end)

		local gpsBtn = Instance.new("TextButton")
		gpsBtn.Size = UDim2.new(0, 38, 0, 38)
		gpsBtn.Position = UDim2.new(1, -44, 0, 14)
		gpsBtn.BackgroundColor3 = C.SystemBlue
		gpsBtn.Text = "📍"
		gpsBtn.TextSize = 18
		gpsBtn.BorderSizePixel = 0
		gpsBtn.Parent = card
		makeCorner(12, gpsBtn)

		gpsBtn.MouseButton1Click:Connect(function()
			self:ShowNotification("GPS Marked", "Waypoint set to " .. v.Name, "📍")
			if self.OnVehicleAction then
				self.OnVehicleAction(v.Id, "gps")
			end
		end)
	end
end

--------------------------------------------------------------------------------
-- App 5: Calculator (Interactive)
--------------------------------------------------------------------------------
function PhoneUI:BuildCalculatorApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("calculator", parent)

	local calcDisplay = Instance.new("TextLabel")
	calcDisplay.Size = UDim2.new(1, -32, 0, 64)
	calcDisplay.Position = UDim2.new(0, 16, 0, 68)
	calcDisplay.BackgroundTransparency = 1
	calcDisplay.Font = F.Bold
	calcDisplay.TextSize = 38
	calcDisplay.TextColor3 = C.TextPrimary
	calcDisplay.TextXAlignment = Enum.TextXAlignment.Right
	calcDisplay.Text = "0"
	calcDisplay.Parent = frame

	local keypad = Instance.new("Frame")
	keypad.Size = UDim2.new(1, -32, 0, 360)
	keypad.Position = UDim2.new(0, 16, 0, 150)
	keypad.BackgroundTransparency = 1
	keypad.Parent = frame

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 60, 0, 60)
	grid.CellPadding = UDim2.new(0, 12, 0, 12)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = keypad

	local calcVal = "0"
	local prevVal = 0
	local curOp = ""

	local buttons = {
		{ "AC", C.SystemGray, Color3.fromRGB(0, 0, 0) },
		{ "+/-", C.SystemGray, Color3.fromRGB(0, 0, 0) },
		{ "%", C.SystemGray, Color3.fromRGB(0, 0, 0) },
		{ "÷", C.SystemOrange, Color3.fromRGB(255, 255, 255) },
		{ "7", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "8", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "9", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "×", C.SystemOrange, Color3.fromRGB(255, 255, 255) },
		{ "4", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "5", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "6", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "-", C.SystemOrange, Color3.fromRGB(255, 255, 255) },
		{ "1", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "2", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "3", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "+", C.SystemOrange, Color3.fromRGB(255, 255, 255) },
		{ "0", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ ".", C.KeypadNumberBg, Color3.fromRGB(255, 255, 255) },
		{ "=", C.SystemOrange, Color3.fromRGB(255, 255, 255) },
	}

	for _, b in ipairs(buttons) do
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = b[2]
		btn.Text = b[1]
		btn.Font = F.Bold
		btn.TextSize = 20
		btn.TextColor3 = b[3]
		btn.BorderSizePixel = 0
		btn.Parent = keypad
		makeCorner(30, btn)

		btn.MouseButton1Click:Connect(function()
			local t = b[1]
			if t == "AC" then
				calcVal = "0"
				prevVal = 0
				curOp = ""
			elseif t == "+/-" then
				local n = tonumber(calcVal) or 0
				calcVal = tostring(-n)
			elseif t == "%" then
				local n = tonumber(calcVal) or 0
				calcVal = tostring(n / 100)
			elseif t == "+" or t == "-" or t == "×" or t == "÷" then
				prevVal = tonumber(calcVal) or 0
				curOp = t
				calcVal = "0"
			elseif t == "=" then
				local cur = tonumber(calcVal) or 0
				if curOp == "+" then calcVal = tostring(prevVal + cur)
				elseif curOp == "-" then calcVal = tostring(prevVal - cur)
				elseif curOp == "×" then calcVal = tostring(prevVal * cur)
				elseif curOp == "÷" then calcVal = cur ~= 0 and tostring(prevVal / cur) or "Error"
				end
				curOp = ""
			else
				if calcVal == "0" and t ~= "." then
					calcVal = t
				else
					calcVal ..= t
				end
			end
			calcDisplay.Text = calcVal
		end)
	end
end

--------------------------------------------------------------------------------
-- App 6: Music Player
--------------------------------------------------------------------------------
function PhoneUI:BuildMusicApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("music", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 28)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Music"
	title.Parent = frame

	-- Album Art Vinyl
	local art = Instance.new("Frame")
	art.Size = UDim2.new(0, 220, 0, 220)
	art.Position = UDim2.new(0.5, -110, 0, 90)
	art.BackgroundColor3 = Color3.fromRGB(34, 30, 48)
	art.BorderSizePixel = 0
	art.Parent = frame
	makeCorner(28, art)
	makeStroke(C.CardStroke, 1, art)

	local artGrad = Instance.new("UIGradient")
	artGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 85)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 86, 214)),
	})
	artGrad.Rotation = 45
	artGrad.Parent = art

	local artIco = Instance.new("TextLabel")
	artIco.Size = UDim2.new(1, 0, 1, 0)
	artIco.BackgroundTransparency = 1
	artIco.Text = "🎵"
	artIco.TextSize = 72
	artIco.Parent = art

	local songTitle = Instance.new("TextLabel")
	songTitle.Size = UDim2.new(1, -40, 0, 24)
	songTitle.Position = UDim2.new(0, 20, 0, 330)
	songTitle.BackgroundTransparency = 1
	songTitle.Font = F.Bold
	songTitle.TextSize = 18
	songTitle.TextColor3 = C.TextPrimary
	songTitle.Text = self.State.CurrentSong.Title
	songTitle.Parent = frame

	local artist = Instance.new("TextLabel")
	artist.Size = UDim2.new(1, -40, 0, 18)
	artist.Position = UDim2.new(0, 20, 0, 356)
	artist.BackgroundTransparency = 1
	artist.Font = F.Medium
	artist.TextSize = 13
	artist.TextColor3 = C.TextSecondary
	artist.Text = self.State.CurrentSong.Artist
	artist.Parent = frame

	-- Scrub Bar
	local scrub = Instance.new("Frame")
	scrub.Size = UDim2.new(1, -48, 0, 4)
	scrub.Position = UDim2.new(0, 24, 0, 395)
	scrub.BackgroundColor3 = C.SliderBg
	scrub.BorderSizePixel = 0
	scrub.Parent = frame
	makeCorner(2, scrub)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0.42, 0, 1, 0)
	fill.BackgroundColor3 = C.TextPrimary
	fill.BorderSizePixel = 0
	fill.Parent = scrub
	makeCorner(2, fill)

	-- Transport Controls
	local transport = Instance.new("Frame")
	transport.Size = UDim2.new(1, -60, 0, 64)
	transport.Position = UDim2.new(0, 30, 0, 420)
	transport.BackgroundTransparency = 1
	transport.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 28)
	layout.Parent = transport

	local prevBtn = Instance.new("TextButton")
	prevBtn.Size = UDim2.new(0, 44, 0, 44)
	prevBtn.BackgroundTransparency = 1
	prevBtn.Text = "⏮️"
	prevBtn.TextSize = 24
	prevBtn.Parent = transport

	local playBig = Instance.new("TextButton")
	playBig.Size = UDim2.new(0, 60, 0, 60)
	playBig.BackgroundColor3 = C.SystemBlue
	playBig.Text = "▶️"
	playBig.TextSize = 22
	playBig.BorderSizePixel = 0
	playBig.Parent = transport
	makeCorner(30, playBig)

	local nextBtn = Instance.new("TextButton")
	nextBtn.Size = UDim2.new(0, 44, 0, 44)
	nextBtn.BackgroundTransparency = 1
	nextBtn.Text = "⏭️"
	nextBtn.TextSize = 24
	nextBtn.Parent = transport

	playBig.MouseButton1Click:Connect(function()
		self.State.IsPlayingMusic = not self.State.IsPlayingMusic
		playBig.Text = self.State.IsPlayingMusic and "⏸️" or "▶️"
		self.IslandDot.Visible = self.State.IsPlayingMusic
		self.IslandTitle.Text = self.State.CurrentSong.Title
		self.IslandSub.Text = self.State.CurrentSong.Artist
	end)
end

--------------------------------------------------------------------------------
-- App 7: Crypto Wallet
--------------------------------------------------------------------------------
function PhoneUI:BuildCryptoApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("crypto", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 28)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Crypto Wallet"
	title.Parent = frame

	local coins = {
		{ Name = "Bitcoin", Symbol = "BTC", Price = "$64,280", Change = "+4.2%", Up = true },
		{ Name = "Ethereum", Symbol = "ETH", Price = "$3,450", Change = "+1.8%", Up = true },
		{ Name = "SkyCoin", Symbol = "SKY", Price = "$14.80", Change = "-0.6%", Up = false },
	}

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -24, 0, 460)
	scroll.Position = UDim2.new(0, 12, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.Parent = frame

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.Parent = scroll

	for _, coin in ipairs(coins) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 72)
		card.BackgroundColor3 = C.CardBg
		card.BorderSizePixel = 0
		card.Parent = scroll
		makeCorner(16, card)
		makeStroke(C.CardStroke, 1, card)

		local cName = Instance.new("TextLabel")
		cName.Size = UDim2.new(0.5, 0, 0, 20)
		cName.Position = UDim2.new(0, 14, 0, 14)
		cName.BackgroundTransparency = 1
		cName.Font = F.Bold
		cName.TextSize = 14
		cName.TextColor3 = C.TextPrimary
		cName.TextXAlignment = Enum.TextXAlignment.Left
		cName.Text = coin.Name .. " (" .. coin.Symbol .. ")"
		cName.Parent = card

		local cPrice = Instance.new("TextLabel")
		cPrice.Size = UDim2.new(0.4, 0, 0, 20)
		cPrice.Position = UDim2.new(1, -120, 0, 14)
		cPrice.BackgroundTransparency = 1
		cPrice.Font = F.Bold
		cPrice.TextSize = 14
		cPrice.TextColor3 = C.TextPrimary
		cPrice.TextXAlignment = Enum.TextXAlignment.Right
		cPrice.Text = coin.Price
		cPrice.Parent = card

		local cChange = Instance.new("TextLabel")
		cChange.Size = UDim2.new(0.4, 0, 0, 16)
		cChange.Position = UDim2.new(1, -120, 0, 36)
		cChange.BackgroundTransparency = 1
		cChange.Font = F.Medium
		cChange.TextSize = 11
		cChange.TextColor3 = coin.Up and C.SystemGreen or C.SystemRed
		cChange.TextXAlignment = Enum.TextXAlignment.Right
		cChange.Text = coin.Change
		cChange.Parent = card
	end
end

--------------------------------------------------------------------------------
-- App 8: Settings (Appearance, Wallpapers, Chassis)
--------------------------------------------------------------------------------
function PhoneUI:BuildSettingsApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("settings", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 28)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Settings"
	title.Parent = frame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -24, 0, 480)
	scroll.Position = UDim2.new(0, 12, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 3
	scroll.Parent = frame

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 14)
	list.Parent = scroll

	-- Profile Card
	local prof = Instance.new("Frame")
	prof.Size = UDim2.new(1, 0, 0, 68)
	prof.BackgroundColor3 = C.CardBg
	prof.BorderSizePixel = 0
	prof.Parent = scroll
	makeCorner(16, prof)

	local pAva = Instance.new("TextLabel")
	pAva.Size = UDim2.new(0, 44, 0, 44)
	pAva.Position = UDim2.new(0, 12, 0.5, -22)
	pAva.BackgroundColor3 = C.SystemBlue
	pAva.Text = "👤"
	pAva.TextSize = 22
	pAva.BorderSizePixel = 0
	pAva.Parent = prof
	makeCorner(22, pAva)

	local pName = Instance.new("TextLabel")
	pName.Size = UDim2.new(1, -74, 0, 20)
	pName.Position = UDim2.new(0, 66, 0, 14)
	pName.BackgroundTransparency = 1
	pName.Font = F.Bold
	pName.TextSize = 14
	pName.TextColor3 = C.TextPrimary
	pName.TextXAlignment = Enum.TextXAlignment.Left
	pName.Text = "Citizen Account"
	pName.Parent = prof

	local pSub = Instance.new("TextLabel")
	pSub.Size = UDim2.new(1, -74, 0, 16)
	pSub.Position = UDim2.new(0, 66, 0, 36)
	pSub.BackgroundTransparency = 1
	pSub.Font = F.Regular
	pSub.TextSize = 11
	pSub.TextColor3 = C.TextSecondary
	pSub.TextXAlignment = Enum.TextXAlignment.Left
	pSub.Text = "SkyOS 18 · Antigravity"
	pSub.Parent = prof

	-- Frame Color Picker Card
	local frameCard = Instance.new("Frame")
	frameCard.Size = UDim2.new(1, 0, 0, 80)
	frameCard.BackgroundColor3 = C.CardBg
	frameCard.BorderSizePixel = 0
	frameCard.Parent = scroll
	makeCorner(16, frameCard)

	local fcTitle = Instance.new("TextLabel")
	fcTitle.Size = UDim2.new(1, -24, 0, 20)
	fcTitle.Position = UDim2.new(0, 12, 0, 8)
	fcTitle.BackgroundTransparency = 1
	fcTitle.Font = F.Bold
	fcTitle.TextSize = 12
	fcTitle.TextColor3 = C.TextPrimary
	fcTitle.TextXAlignment = Enum.TextXAlignment.Left
	fcTitle.Text = "Chassis Color Finish"
	fcTitle.Parent = frameCard

	local swatches = Instance.new("Frame")
	swatches.Size = UDim2.new(1, -24, 0, 36)
	swatches.Position = UDim2.new(0, 12, 0, 32)
	swatches.BackgroundTransparency = 1
	swatches.Parent = frameCard

	local sList = Instance.new("UIListLayout")
	sList.FillDirection = Enum.FillDirection.Horizontal
	sList.Padding = UDim.new(0, 10)
	sList.Parent = swatches

	local finishes = {
		{ Name = "SpaceGray", Color = C.Frames.SpaceGray },
		{ Name = "DeepPurple", Color = C.Frames.DeepPurple },
		{ Name = "AlpineGreen", Color = C.Frames.AlpineGreen },
		{ Name = "SierraBlue", Color = C.Frames.SierraBlue },
		{ Name = "ProductRed", Color = C.Frames.ProductRed },
		{ Name = "TitaniumGold", Color = C.Frames.TitaniumGold },
	}

	for _, f in ipairs(finishes) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 32, 0, 32)
		b.BackgroundColor3 = f.Color
		b.Text = ""
		b.BorderSizePixel = 0
		b.Parent = swatches
		makeCorner(16, b)
		makeStroke(Color3.fromRGB(80, 80, 90), 1, b)

		b.MouseButton1Click:Connect(function()
			self.Bezel.BackgroundColor3 = f.Color
			self:ShowNotification("Chassis Updated", "Finish: " .. f.Name, "🎨")
		end)
	end
end

--------------------------------------------------------------------------------
-- App 9: Notes
--------------------------------------------------------------------------------
function PhoneUI:BuildNotesApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("notes", parent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 28)
	title.Position = UDim2.new(0, 16, 0, 52)
	title.BackgroundTransparency = 1
	title.Font = F.Bold
	title.TextSize = 22
	title.TextColor3 = C.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Notes"
	title.Parent = frame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -24, 0, 460)
	scroll.Position = UDim2.new(0, 12, 0, 90)
	scroll.BackgroundTransparency = 1
	scroll.Parent = frame

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = scroll

	local sampleNotes = {
		{ Title = "Penthouse Gate Code", Text = "#9842 - Don't share with anyone" },
		{ Title = "Garage Parts List", Text = "Turbo stage 3, sport slicks, carbon diffuser" },
		{ Title = "Weazel News Tip", Text = "Meeting informant at dock warehouse 12" },
	}

	for _, n in ipairs(sampleNotes) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 60)
		card.BackgroundColor3 = C.CardBg
		card.BorderSizePixel = 0
		card.Parent = scroll
		makeCorner(14, card)
		makeStroke(C.CardStroke, 1, card)

		local tLbl = Instance.new("TextLabel")
		tLbl.Size = UDim2.new(1, -20, 0, 20)
		tLbl.Position = UDim2.new(0, 12, 0, 10)
		tLbl.BackgroundTransparency = 1
		tLbl.Font = F.Bold
		tLbl.TextSize = 13
		tLbl.TextColor3 = C.TextPrimary
		tLbl.TextXAlignment = Enum.TextXAlignment.Left
		tLbl.Text = n.Title
		tLbl.Parent = card

		local dLbl = Instance.new("TextLabel")
		dLbl.Size = UDim2.new(1, -20, 0, 16)
		dLbl.Position = UDim2.new(0, 12, 0, 30)
		dLbl.BackgroundTransparency = 1
		dLbl.Font = F.Regular
		dLbl.TextSize = 11
		dLbl.TextColor3 = C.TextSecondary
		dLbl.TextXAlignment = Enum.TextXAlignment.Left
		dLbl.Text = n.Text
		dLbl.Parent = card
	end
end

--------------------------------------------------------------------------------
-- App 10: Camera
--------------------------------------------------------------------------------
function PhoneUI:BuildCameraApp(parent: Instance)
	local C = PhoneTheme.Colors
	local F = PhoneTheme.Fonts

	local frame = self:CreateAppContainer("camera", parent)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

	-- Viewfinder Reticle
	local reticle = Instance.new("Frame")
	reticle.Size = UDim2.new(0, 64, 0, 64)
	reticle.AnchorPoint = Vector2.new(0.5, 0.5)
	reticle.Position = UDim2.new(0.5, 0, 0.45, 0)
	reticle.BackgroundTransparency = 1
	reticle.Parent = frame
	makeStroke(Color3.fromRGB(255, 214, 10), 1, reticle)

	-- Shutter Button
	local shutter = Instance.new("TextButton")
	shutter.Size = UDim2.new(0, 68, 0, 68)
	shutter.AnchorPoint = Vector2.new(0.5, 1)
	shutter.Position = UDim2.new(0.5, 0, 1, -48)
	shutter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	shutter.Text = ""
	shutter.BorderSizePixel = 0
	shutter.Parent = frame
	makeCorner(34, shutter)
	makeStroke(Color3.fromRGB(80, 80, 80), 4, shutter)

	shutter.MouseButton1Click:Connect(function()
		-- Screen flash animation
		local flash = Instance.new("Frame")
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		flash.BorderSizePixel = 0
		flash.ZIndex = 99
		flash.Parent = frame

		local tw = TweenService:Create(flash, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		tw:Play()
		tw.Completed:Connect(function()
			flash:Destroy()
		end)
		self:ShowNotification("Camera", "Photo saved to Photos.", "📷")
	end)
end

--------------------------------------------------------------------------------
-- Navigation & App Switching
--------------------------------------------------------------------------------
function PhoneUI:OpenApp(appId: string)
	local T = PhoneTheme.Tweens
	local container = self.AppContainers[appId]
	if not container then return end

	if self.State.CurrentApp and self.AppContainers[self.State.CurrentApp] then
		self.AppContainers[self.State.CurrentApp].Visible = false
	end

	self.State.CurrentApp = appId
	self.Springboard.Visible = false
	self.Dock.Visible = false
	container.Visible = true
	container.Position = UDim2.new(0, 0, 1, 0)

	TweenService:Create(container, T.Spring, {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
end

function PhoneUI:GoHome()
	local T = PhoneTheme.Tweens
	if self.State.CurrentApp and self.AppContainers[self.State.CurrentApp] then
		local current = self.AppContainers[self.State.CurrentApp]
		local tw = TweenService:Create(current, T.FastSpring, {
			Position = UDim2.new(0, 0, 1, 0)
		})
		tw:Play()
		tw.Completed:Connect(function()
			current.Visible = false
		end)
	end

	self.State.CurrentApp = nil
	self.Springboard.Visible = true
	self.Dock.Visible = true
end

function PhoneUI:Unlock()
	local T = PhoneTheme.Tweens
	self.State.IsLocked = false
	local tw = TweenService:Create(self.LockScreen, T.FastSpring, {
		Position = UDim2.new(0, 0, -1, 0)
	})
	tw:Play()
	tw.Completed:Connect(function()
		self.LockScreen.Visible = false
	end)
end

function PhoneUI:Lock()
	local T = PhoneTheme.Tweens
	self.State.IsLocked = true
	self.LockScreen.Visible = true
	TweenService:Create(self.LockScreen, T.FastSpring, {
		Position = UDim2.new(0, 0, 0, 0)
	}):Play()
end

function PhoneUI:SetVisible(visible: boolean)
	local T = PhoneTheme.Tweens
	self.State.IsOpen = visible

	if visible then
		TweenService:Create(self.Root, T.Spring, {
			Position = UDim2.new(1, -32, 1, -32)
		}):Play()
	else
		TweenService:Create(self.Root, T.FastSpring, {
			Position = UDim2.new(1, -32, 1, 700)
		}):Play()
	end
end

function PhoneUI:Toggle()
	self:SetVisible(not self.State.IsOpen)
end

function PhoneUI:StartClockLoop()
	task.spawn(function()
		while true do
			local timeStr = os.date("%H:%M")
			local dateStr = os.date("%A, %B %d")

			if self.StatusClockLabel then
				self.StatusClockLabel.Text = timeStr
			end
			if self.LockClockLabel then
				self.LockClockLabel.Text = timeStr
			end
			if self.LockDateLabel then
				self.LockDateLabel.Text = dateStr
			end

			task.wait(1)
		end
	end)
end

return PhoneUI
