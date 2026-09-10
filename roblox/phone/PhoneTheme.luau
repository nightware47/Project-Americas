--!strict
-- PhoneTheme.lua
-- Design tokens and styling system for the Roblox Sky Phone (Sky Systems iOS 17/18 Dark Appearance)
-- Location: roblox/components/PhoneTheme.lua

local PhoneTheme = {}

PhoneTheme.Colors = {
	-- Backgrounds & Surfaces
	PhoneBezel       = Color3.fromRGB(18, 18, 22),
	PhoneBorder      = Color3.fromRGB(48, 48, 56),
	ScreenBg         = Color3.fromRGB(10, 10, 14),
	WallpaperDark    = Color3.fromRGB(14, 18, 28),
	WallpaperGradient1 = Color3.fromRGB(16, 24, 48),
	WallpaperGradient2 = Color3.fromRGB(36, 18, 44),
	DynamicIsland    = Color3.fromRGB(0, 0, 0),
	IslandStroke     = Color3.fromRGB(28, 28, 34),
	DockBg           = Color3.fromRGB(26, 26, 32),
	CardBg           = Color3.fromRGB(22, 22, 28),
	CardBgHover      = Color3.fromRGB(32, 32, 38),
	CardStroke       = Color3.fromRGB(42, 42, 50),
	Separator        = Color3.fromRGB(36, 36, 42),
	InputBg          = Color3.fromRGB(28, 28, 34),
	InputStroke      = Color3.fromRGB(50, 50, 60),

	-- Control Center
	ControlCenterBg  = Color3.fromRGB(18, 18, 24),
	SliderBg         = Color3.fromRGB(38, 38, 48),
	SliderFill       = Color3.fromRGB(255, 255, 255),

	-- Frame Color Finishes (Authentic Sky Phone Chassis)
	Frames = {
		SpaceGray   = Color3.fromRGB(24, 24, 28),
		Midnight    = Color3.fromRGB(16, 22, 34),
		DeepPurple  = Color3.fromRGB(42, 26, 52),
		AlpineGreen = Color3.fromRGB(26, 44, 34),
		SierraBlue  = Color3.fromRGB(48, 72, 98),
		ProductRed  = Color3.fromRGB(88, 24, 30),
		TitaniumGold= Color3.fromRGB(68, 58, 42),
		Silver      = Color3.fromRGB(180, 182, 190),
	},

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
	SystemYellow     = Color3.fromRGB(255, 214, 10),    -- #FFD60A (Notes / Star)
	SystemGray       = Color3.fromRGB(142, 142, 147),   -- #8E8E93
	SystemDarkGray   = Color3.fromRGB(44, 44, 46),      -- #2C2C2E

	-- Typography Colors
	TextPrimary      = Color3.fromRGB(255, 255, 255),
	TextSecondary    = Color3.fromRGB(160, 160, 168),
	TextTertiary     = Color3.fromRGB(110, 110, 120),
	TextPlaceholder  = Color3.fromRGB(90, 90, 100),
	TextLink         = Color3.fromRGB(10, 132, 255),

	-- Keypad & Buttons
	KeypadNumberBg   = Color3.fromRGB(36, 36, 42),
	KeypadNumberText = Color3.fromRGB(255, 255, 255),
	KeypadSubText    = Color3.fromRGB(130, 130, 140),

	-- Home Indicator Pill
	HomeIndicator    = Color3.fromRGB(220, 220, 230),
}

PhoneTheme.Dimensions = {
	-- Hardware Chassis
	PhoneWidth          = 320,
	PhoneHeight         = 650,
	BezelRadius         = 46,
	ScreenRadius        = 40,
	BezelPadding        = 10,

	-- Dynamic Island
	IslandWidthCompact  = 104,
	IslandHeightCompact = 26,
	IslandWidthExpanded = 270,
	IslandHeightExpanded= 72,
	IslandRadius        = 13,

	-- Top & Bottom Bars
	StatusBarHeight     = 42,
	DockHeight          = 84,
	HomeIndicatorWidth  = 134,
	HomeIndicatorHeight = 4,

	-- Springboard Icons
	IconSize            = 52,
	IconRadius          = 13,
	IconGridGapX        = 16,
	IconGridGapY        = 18,
	BadgeSize           = 18,
}

PhoneTheme.Fonts = {
	LargeTitle = Enum.Font.GothamBold,
	Title1     = Enum.Font.GothamBold,
	Title2     = Enum.Font.GothamMedium,
	Headline   = Enum.Font.GothamMedium,
	Body       = Enum.Font.Gotham,
	Callout    = Enum.Font.Gotham,
	Subheadline= Enum.Font.Gotham,
	Footnote   = Enum.Font.Gotham,
	Caption1   = Enum.Font.Gotham,
	Caption2   = Enum.Font.Gotham,
	Bold       = Enum.Font.GothamBold,
	Medium     = Enum.Font.GothamMedium,
	Regular    = Enum.Font.Gotham,
	Clock      = Enum.Font.GothamBold,
}

PhoneTheme.Tweens = {
	Spring      = TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	FastSpring  = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Snappy      = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	IslandExpand= TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	SlowSlide   = TweenInfo.new(0.32, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
}

-- Registry of Core Apps for Sky Phone
PhoneTheme.Apps = {
	{ Id = "phone",      Name = "Phone",      Glyph = "📞", BgColor = Color3.fromRGB(48, 209, 88),   Dock = true,  Badge = 0 },
	{ Id = "messages",   Name = "Messages",   Glyph = "💬", BgColor = Color3.fromRGB(10, 132, 255),  Dock = true,  Badge = 2 },
	{ Id = "bank",       Name = "Bank",       Glyph = "💳", BgColor = Color3.fromRGB(94, 92, 230),   Dock = true,  Badge = 0 },
	{ Id = "settings",   Name = "Settings",   Glyph = "⚙️", BgColor = Color3.fromRGB(142, 142, 147), Dock = true,  Badge = 0 },
	{ Id = "garage",     Name = "Garage",     Glyph = "🚗", BgColor = Color3.fromRGB(255, 69, 58),   Dock = false, Badge = 0 },
	{ Id = "calculator", Name = "Calculator", Glyph = "🔢", BgColor = Color3.fromRGB(255, 159, 10),  Dock = false, Badge = 0 },
	{ Id = "music",      Name = "Music",      Glyph = "🎵", BgColor = Color3.fromRGB(255, 45, 85),   Dock = false, Badge = 0 },
	{ Id = "camera",     Name = "Camera",     Glyph = "📷", BgColor = Color3.fromRGB(60, 60, 68),    Dock = false, Badge = 0 },
	{ Id = "notes",      Name = "Notes",      Glyph = "📝", BgColor = Color3.fromRGB(255, 214, 10),  Dock = false, Badge = 0 },
	{ Id = "crypto",     Name = "Crypto",     Glyph = "📈", BgColor = Color3.fromRGB(175, 82, 222),  Dock = false, Badge = 0 },
	{ Id = "maps",       Name = "Maps",       Glyph = "🗺️", BgColor = Color3.fromRGB(50, 180, 120),  Dock = false, Badge = 0 },
	{ Id = "appstore",   Name = "App Store",  Glyph = "🛍️", BgColor = Color3.fromRGB(0, 122, 255),   Dock = false, Badge = 0 },
}

return PhoneTheme
