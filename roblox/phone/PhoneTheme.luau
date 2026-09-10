--!strict
-- PhoneTheme.lua
-- Design tokens and styling system for the Roblox Sky Phone (iOS 17/18 Dark Appearance)
-- Location: roblox/components/PhoneTheme.lua

local PhoneTheme = {}

PhoneTheme.Colors = {
	-- Backgrounds & Surfaces
	PhoneBezel       = Color3.fromRGB(15, 15, 18),
	PhoneBorder      = Color3.fromRGB(45, 45, 52),
	ScreenBg         = Color3.fromRGB(10, 10, 12),
	WallpaperDark    = Color3.fromRGB(18, 22, 32),
	DynamicIsland    = Color3.fromRGB(0, 0, 0),
	IslandStroke     = Color3.fromRGB(30, 30, 34),
	DockBg           = Color3.fromRGB(32, 32, 36),
	CardBg           = Color3.fromRGB(24, 24, 28),
	CardBgHover      = Color3.fromRGB(34, 34, 40),
	CardStroke       = Color3.fromRGB(44, 44, 52),
	Separator        = Color3.fromRGB(38, 38, 44),
	InputBg          = Color3.fromRGB(28, 28, 34),
	InputStroke      = Color3.fromRGB(50, 50, 60),

	-- System Accent Colors (Apple iOS Dark HIG)
	SystemBlue       = Color3.fromRGB(10, 132, 255),    -- #0A84FF
	SystemBlueHover  = Color3.fromRGB(40, 155, 255),
	SystemGreen      = Color3.fromRGB(48, 209, 88),     -- #30D158 (Phone / Call / Active)
	SystemGreenHover = Color3.fromRGB(68, 225, 108),
	SystemOrange     = Color3.fromRGB(255, 159, 10),    -- #FF9F0A (Notes / Warning)
	SystemRed        = Color3.fromRGB(255, 69, 58),     -- #FF453A (End Call / Danger)
	SystemPurple     = Color3.fromRGB(191, 90, 242),    -- #BF5AF2 (Podcasts / Store)
	SystemIndigo     = Color3.fromRGB(94, 92, 230),     -- #5E5CE6 (Finance / Bank)
	SystemTeal       = Color3.fromRGB(100, 210, 255),   -- #64D2FF (Messages / Weather)
	SystemYellow     = Color3.fromRGB(255, 214, 10),    -- #FFD60A (Notes)
	SystemGray       = Color3.fromRGB(142, 142, 147),   -- #8E8E93
	SystemDarkGray   = Color3.fromRGB(44, 44, 46),      -- #2C2C2E

	-- Typography Colors
	TextPrimary      = Color3.fromRGB(255, 255, 255),
	TextSecondary    = Color3.fromRGB(160, 160, 168),
	TextTertiary     = Color3.fromRGB(110, 110, 120),
	TextPlaceholder  = Color3.fromRGB(90, 90, 100),
	TextInverse      = Color3.fromRGB(0, 0, 0),

	-- Message Bubbles
	BubbleSent       = Color3.fromRGB(10, 132, 255),
	BubbleReceived   = Color3.fromRGB(36, 36, 42),

	-- Controls & Switches
	SwitchOn         = Color3.fromRGB(48, 209, 88),
	SwitchOff        = Color3.fromRGB(58, 58, 64),
	SwitchKnob       = Color3.fromRGB(255, 255, 255),
	HomeIndicator    = Color3.fromRGB(240, 240, 245),
}

PhoneTheme.Fonts = {
	Regular = Enum.Font.Gotham,
	Medium  = Enum.Font.GothamMedium,
	Bold    = Enum.Font.GothamBold,
	Black   = Enum.Font.GothamBlack,
	Mono    = Enum.Font.Code,
}

PhoneTheme.Dimensions = {
	PhoneWidth         = 312,
	PhoneHeight        = 636,
	BezelRadius        = 44,
	ScreenRadius       = 38,
	IslandWidth        = 96,
	IslandHeight       = 24,
	IslandRadius       = 12,
	DockHeight         = 78,
	DockRadius         = 28,
	AppIconSize        = 48,
	AppIconRadius      = 12,
	HomeIndicatorWidth = 112,
	HomeIndicatorHeight= 4,
}

PhoneTheme.Tweens = {
	Fast   = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Normal = TweenInfo.new(0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
	Bounce = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.42, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
}

-- App Registry Metadata
PhoneTheme.Apps = {
	{
		Id = "phone",
		Title = "Phone",
		Icon = "rbxassetid://6031075938", -- Phone / Call handset
		FallbackGlyph = "📞",
		BgColor = PhoneTheme.Colors.SystemGreen,
		InDock = true,
		Category = "Communication",
	},
	{
		Id = "messages",
		Title = "Messages",
		Icon = "rbxassetid://6034335528", -- Speech bubble
		FallbackGlyph = "💬",
		BgColor = PhoneTheme.Colors.SystemGreen,
		InDock = true,
		Category = "Communication",
	},
	{
		Id = "bank",
		Title = "Bank",
		Icon = "rbxassetid://6031075931", -- Credit card / Finance
		FallbackGlyph = "💳",
		BgColor = PhoneTheme.Colors.SystemIndigo,
		InDock = true,
		Category = "Finance",
	},
	{
		Id = "settings",
		Title = "Settings",
		Icon = "rbxassetid://6031280882", -- Gear
		FallbackGlyph = "⚙️",
		BgColor = Color3.fromRGB(115, 115, 125),
		InDock = true,
		Category = "System",
	},
	{
		Id = "garage",
		Title = "Garage",
		Icon = "rbxassetid://6031082533", -- Car / Key
		FallbackGlyph = "🚗",
		BgColor = PhoneTheme.Colors.SystemOrange,
		InDock = false,
		Category = "Utilities",
	},
	{
		Id = "camera",
		Title = "Camera",
		Icon = "rbxassetid://6031075929", -- Camera
		FallbackGlyph = "📷",
		BgColor = Color3.fromRGB(60, 60, 68),
		InDock = false,
		Category = "Media",
	},
	{
		Id = "photos",
		Title = "Photos",
		Icon = "rbxassetid://6031075936", -- Photos flower
		FallbackGlyph = "🖼️",
		BgColor = Color3.fromRGB(245, 245, 245),
		IconColor = Color3.fromRGB(20, 20, 24),
		InDock = false,
		Category = "Media",
	},
	{
		Id = "notes",
		Title = "Notes",
		Icon = "rbxassetid://6031075935", -- Notepad
		FallbackGlyph = "📝",
		BgColor = PhoneTheme.Colors.SystemYellow,
		IconColor = Color3.fromRGB(30, 30, 30),
		InDock = false,
		Category = "Productivity",
	},
	{
		Id = "music",
		Title = "Music",
		Icon = "rbxassetid://6031075934", -- Musical notes
		FallbackGlyph = "🎵",
		BgColor = PhoneTheme.Colors.SystemRed,
		InDock = false,
		Category = "Media",
	},
	{
		Id = "billing",
		Title = "Billing",
		Icon = "rbxassetid://6031075930", -- Document / Invoice
		FallbackGlyph = "🧾",
		BgColor = PhoneTheme.Colors.SystemBlue,
		InDock = false,
		Category = "Finance",
	},
	{
		Id = "appstore",
		Title = "App Store",
		Icon = "rbxassetid://6031075927", -- Store 'A'
		FallbackGlyph = "🅰️",
		BgColor = PhoneTheme.Colors.SystemBlue,
		InDock = false,
		Category = "System",
	},
	{
		Id = "weather",
		Title = "Weather",
		Icon = "rbxassetid://6031075939", -- Sun / Cloud
		FallbackGlyph = "☀️",
		BgColor = PhoneTheme.Colors.SystemTeal,
		InDock = false,
		Category = "Information",
	},
}

return PhoneTheme
