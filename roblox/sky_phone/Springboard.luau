--!strict
-- src/sky_phone/Springboard.luau
-- Pure Luau Component: Springboard Home Screen, Reference Site & Live Demo Spacing Parity
local Springboard = {}

function Springboard.build(screen: Frame, openAppCallback: (string) -> ())
    local oldHome = screen:FindFirstChild("HomeScreen")
    if oldHome then oldHome:Destroy() end

    local homeScreen = Instance.new("Frame", screen)
    homeScreen.Name = "HomeScreen"
    homeScreen.Size = UDim2.new(1, 0, 1, 0)
    homeScreen.BackgroundTransparency = 1
    homeScreen.BorderSizePixel = 0
    homeScreen.ClipsDescendants = true
    homeScreen.ZIndex = 4

    local homeCorner = Instance.new("UICorner", homeScreen)
    homeCorner.CornerRadius = UDim.new(0.136, 0)

    -- Pages Container
    local pagesContainer = Instance.new("Frame", homeScreen)
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Size = UDim2.new(1, 0, 1, -84)
    pagesContainer.Position = UDim2.new(0, 0, 0, 0)
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.ZIndex = 10

    local pageLayout = Instance.new("UIPageLayout", pagesContainer)
    pageLayout.Circular = false
    pageLayout.ScrollWheelInputEnabled = true
    pageLayout.TouchInputEnabled = true
    pageLayout.GamepadInputEnabled = true
    pageLayout.EasingStyle = Enum.EasingStyle.Quad
    pageLayout.EasingDirection = Enum.EasingDirection.Out
    pageLayout.TweenTime = 0.28

    local function makeAppIcon(parent: Instance, name: string, label: string, iconAsset: string, layoutOrder: number?, badgeNum: number?)
        local btn = Instance.new("TextButton", parent)
        btn.Name = "App_" .. name
        btn.Size = UDim2.new(0, 58, 0, 72)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = layoutOrder or 1
        btn.ZIndex = 12

        local iconImg = Instance.new("ImageLabel", btn)
        iconImg.Name = "Icon"
        iconImg.Size = UDim2.new(0, 54, 0, 54)
        iconImg.Position = UDim2.new(0.5, -27, 0, 0)
        iconImg.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
        iconImg.Image = iconAsset or ""
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.ZIndex = 13
        Instance.new("UICorner", iconImg).CornerRadius = UDim.new(0, 13)

        local lbl = Instance.new("TextLabel", btn)
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1, 8, 0, 14)
        lbl.Position = UDim2.new(0, -4, 0, 56)
        lbl.BackgroundTransparency = 1
        lbl.Text = label or name
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.ZIndex = 13

        if badgeNum and badgeNum > 0 then
            local badge = Instance.new("Frame", btn)
            badge.Name = "Badge"
            badge.AnchorPoint = Vector2.new(1, 0)
            badge.Position = UDim2.new(1, 0, 0, -3)
            badge.Size = UDim2.new(0, 18, 0, 18)
            badge.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
            badge.BorderSizePixel = 0
            badge.ZIndex = 15
            Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

            local bTxt = Instance.new("TextLabel", badge)
            bTxt.Size = UDim2.new(1, 0, 1, 0)
            bTxt.BackgroundTransparency = 1
            bTxt.Text = tostring(badgeNum)
            bTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
            bTxt.Font = Enum.Font.GothamBold
            bTxt.TextSize = 10
            bTxt.ZIndex = 16
        end

        if name == "Calendar" then
            iconImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            iconImg.Image = ""

            local dMon = Instance.new("TextLabel", iconImg)
            dMon.Size = UDim2.new(1, 0, 0, 16)
            dMon.Position = UDim2.new(0, 0, 0, 4)
            dMon.BackgroundTransparency = 1
            dMon.Text = "Mon"
            dMon.TextColor3 = Color3.fromRGB(235, 60, 50)
            dMon.Font = Enum.Font.GothamBold
            dMon.TextSize = 11
            dMon.TextXAlignment = Enum.TextXAlignment.Center
            dMon.ZIndex = 14

            local dDay = Instance.new("TextLabel", iconImg)
            dDay.Size = UDim2.new(1, 0, 0, 26)
            dDay.Position = UDim2.new(0, 0, 0, 19)
            dDay.BackgroundTransparency = 1
            dDay.Text = "21"
            dDay.TextColor3 = Color3.fromRGB(28, 30, 36)
            dDay.Font = Enum.Font.GothamBold
            dDay.TextSize = 22
            dDay.TextXAlignment = Enum.TextXAlignment.Center
            dDay.ZIndex = 14
        end

        btn.MouseButton1Click:Connect(function()
            openAppCallback(name)
        end)
        return btn
    end

    -- =========================================================================
    -- PAGE 1: PICTURE 1 (Clock & Weather Widgets, Music Widget, 8 Apps)
    -- =========================================================================
    local page1 = Instance.new("Frame", pagesContainer)
    page1.Name = "Page1"
    page1.Size = UDim2.new(1, 0, 1, 0)
    page1.BackgroundTransparency = 1
    page1.LayoutOrder = 1
    page1.ZIndex = 11

    local widgetGrid = Instance.new("Frame", page1)
    widgetGrid.Name = "WidgetGrid"
    widgetGrid.Size = UDim2.new(1, -28, 0, 134)
    widgetGrid.Position = UDim2.new(0, 14, 0, 56)
    widgetGrid.BackgroundTransparency = 1
    widgetGrid.ZIndex = 11

    -- Clock Widget
    local wClock = Instance.new("TextButton", widgetGrid)
    wClock.Name = "Widget_Clock"
    wClock.Size = UDim2.new(0.485, 0, 1, 0)
    wClock.Position = UDim2.new(0, 0, 0, 0)
    wClock.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    wClock.BackgroundTransparency = 0.05
    wClock.Text = ""
    wClock.AutoButtonColor = false
    wClock.ZIndex = 12
    Instance.new("UICorner", wClock).CornerRadius = UDim.new(0, 24)
    local ws1 = Instance.new("UIStroke", wClock)
    ws1.Color = Color3.fromRGB(255, 255, 255)
    ws1.Transparency = 0.90
    ws1.Thickness = 1

    local wcDay = Instance.new("TextLabel", wClock)
    wcDay.Size = UDim2.new(1, -24, 0, 16)
    wcDay.Position = UDim2.new(0, 14, 0, 14)
    wcDay.BackgroundTransparency = 1
    wcDay.Text = "Monday"
    wcDay.TextColor3 = Color3.fromRGB(152, 152, 159)
    wcDay.Font = Enum.Font.GothamMedium
    wcDay.TextSize = 12
    wcDay.TextXAlignment = Enum.TextXAlignment.Left
    wcDay.ZIndex = 13

    local wcTime = Instance.new("TextLabel", wClock)
    wcTime.Name = "TimeText"
    wcTime.Size = UDim2.new(1, -24, 0, 44)
    wcTime.Position = UDim2.new(0, 14, 0, 30)
    wcTime.BackgroundTransparency = 1
    wcTime.Text = "18:40"
    wcTime.TextColor3 = Color3.fromRGB(255, 255, 255)
    wcTime.Font = Enum.Font.GothamBold
    wcTime.TextSize = 38
    wcTime.TextXAlignment = Enum.TextXAlignment.Left
    wcTime.ZIndex = 13

    local wcDate = Instance.new("TextLabel", wClock)
    wcDate.Size = UDim2.new(1, -24, 0, 26)
    wcDate.Position = UDim2.new(0, 14, 1, -32)
    wcDate.BackgroundTransparency = 1
    wcDate.Text = "Monday, September" .. string.char(10) .. "21"
    wcDate.TextColor3 = Color3.fromRGB(142, 142, 147)
    wcDate.Font = Enum.Font.Gotham
    wcDate.TextSize = 10
    wcDate.TextWrapped = true
    wcDate.TextXAlignment = Enum.TextXAlignment.Left
    wcDate.ZIndex = 13

    wClock.MouseButton1Click:Connect(function() openAppCallback("Clock") end)

    local lblClock = Instance.new("TextLabel", page1)
    lblClock.Size = UDim2.new(0.485, -14, 0, 14)
    lblClock.Position = UDim2.new(0, 14, 0, 194)
    lblClock.BackgroundTransparency = 1
    lblClock.Text = "Clock"
    lblClock.TextColor3 = Color3.fromRGB(255, 255, 255)
    lblClock.Font = Enum.Font.GothamMedium
    lblClock.TextSize = 11
    lblClock.TextXAlignment = Enum.TextXAlignment.Center
    lblClock.ZIndex = 13

    -- Weather Widget
    local wWeather = Instance.new("TextButton", widgetGrid)
    wWeather.Name = "Widget_Weather"
    wWeather.Size = UDim2.new(0.485, 0, 1, 0)
    wWeather.Position = UDim2.new(0.515, 0, 0, 0)
    wWeather.BackgroundColor3 = Color3.fromRGB(36, 62, 96)
    wWeather.Text = ""
    wWeather.AutoButtonColor = false
    wWeather.ZIndex = 12
    Instance.new("UICorner", wWeather).CornerRadius = UDim.new(0, 24)
    local ws2 = Instance.new("UIStroke", wWeather)
    ws2.Color = Color3.fromRGB(255, 255, 255)
    ws2.Transparency = 0.90
    ws2.Thickness = 1

    local wwCity = Instance.new("TextLabel", wWeather)
    wwCity.Size = UDim2.new(1, -24, 0, 16)
    wwCity.Position = UDim2.new(0, 14, 0, 14)
    wwCity.BackgroundTransparency = 1
    wwCity.Text = "Los Santos"
    wwCity.TextColor3 = Color3.fromRGB(180, 205, 235)
    wwCity.Font = Enum.Font.GothamMedium
    wwCity.TextSize = 12
    wwCity.TextXAlignment = Enum.TextXAlignment.Left
    wwCity.ZIndex = 13

    local wwTemp = Instance.new("TextLabel", wWeather)
    wwTemp.Size = UDim2.new(1, -24, 0, 44)
    wwTemp.Position = UDim2.new(0, 14, 0, 30)
    wwTemp.BackgroundTransparency = 1
    wwTemp.Text = "24°"
    wwTemp.TextColor3 = Color3.fromRGB(255, 255, 255)
    wwTemp.Font = Enum.Font.GothamBold
    wwTemp.TextSize = 40
    wwTemp.TextXAlignment = Enum.TextXAlignment.Left
    wwTemp.ZIndex = 13

    local wwCond = Instance.new("TextLabel", wWeather)
    wwCond.Size = UDim2.new(1, -24, 0, 16)
    wwCond.Position = UDim2.new(0, 14, 1, -36)
    wwCond.BackgroundTransparency = 1
    wwCond.Text = "⛅ Partly Cloudy"
    wwCond.TextColor3 = Color3.fromRGB(220, 235, 255)
    wwCond.Font = Enum.Font.GothamMedium
    wwCond.TextSize = 11
    wwCond.TextXAlignment = Enum.TextXAlignment.Left
    wwCond.ZIndex = 13

    local wwHL = Instance.new("TextLabel", wWeather)
    wwHL.Size = UDim2.new(1, -24, 0, 14)
    wwHL.Position = UDim2.new(0, 14, 1, -20)
    wwHL.BackgroundTransparency = 1
    wwHL.Text = "H: 24°  L: 13°"
    wwHL.TextColor3 = Color3.fromRGB(170, 195, 225)
    wwHL.Font = Enum.Font.Gotham
    wwHL.TextSize = 9.5
    wwHL.TextXAlignment = Enum.TextXAlignment.Left
    wwHL.ZIndex = 13

    wWeather.MouseButton1Click:Connect(function() openAppCallback("Weather") end)

    local lblWeather = Instance.new("TextLabel", page1)
    lblWeather.Size = UDim2.new(0.485, 0, 0, 14)
    lblWeather.Position = UDim2.new(0.515, 14, 0, 194)
    lblWeather.BackgroundTransparency = 1
    lblWeather.Text = "Weather"
    lblWeather.TextColor3 = Color3.fromRGB(255, 255, 255)
    lblWeather.Font = Enum.Font.GothamMedium
    lblWeather.TextSize = 11
    lblWeather.TextXAlignment = Enum.TextXAlignment.Center
    lblWeather.ZIndex = 13

    -- Music Widget (2x4 wide)
    local wMusic = Instance.new("TextButton", page1)
    wMusic.Name = "Widget_Music"
    wMusic.Size = UDim2.new(1, -28, 0, 114)
    wMusic.Position = UDim2.new(0, 14, 0, 218)
    wMusic.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    wMusic.BackgroundTransparency = 0.05
    wMusic.Text = ""
    wMusic.AutoButtonColor = false
    wMusic.ZIndex = 12
    Instance.new("UICorner", wMusic).CornerRadius = UDim.new(0, 24)
    local ws3 = Instance.new("UIStroke", wMusic)
    ws3.Color = Color3.fromRGB(255, 255, 255)
    ws3.Transparency = 0.90
    ws3.Thickness = 1

    local wmArt = Instance.new("Frame", wMusic)
    wmArt.Size = UDim2.new(0, 72, 0, 72)
    wmArt.Position = UDim2.new(0, 16, 0, 14)
    wmArt.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
    wmArt.BorderSizePixel = 0
    wmArt.ZIndex = 13
    Instance.new("UICorner", wmArt).CornerRadius = UDim.new(0, 16)

    local wmArtImg = Instance.new("ImageLabel", wmArt)
    wmArtImg.Name = "ArtImage"
    wmArtImg.Size = UDim2.new(1, 0, 1, 0)
    wmArtImg.BackgroundTransparency = 1
    wmArtImg.ScaleType = Enum.ScaleType.Crop
    wmArtImg.Visible = false
    wmArtImg.ZIndex = 14
    Instance.new("UICorner", wmArtImg).CornerRadius = UDim.new(0, 16)

    local artNote = Instance.new("TextLabel", wmArt)
    artNote.Size = UDim2.new(1, 0, 1, 0)
    artNote.BackgroundTransparency = 1
    artNote.Text = "♪"
    artNote.TextColor3 = Color3.fromRGB(110, 112, 120)
    artNote.Font = Enum.Font.GothamMedium
    artNote.TextSize = 32
    artNote.ZIndex = 14

    local redNote = Instance.new("TextLabel", wMusic)
    redNote.Size = UDim2.new(0, 20, 0, 20)
    redNote.Position = UDim2.new(1, -30, 0, 16)
    redNote.BackgroundTransparency = 1
    redNote.Text = "♪"
    redNote.TextColor3 = Color3.fromRGB(255, 45, 85)
    redNote.Font = Enum.Font.GothamBold
    redNote.TextSize = 18
    redNote.ZIndex = 14

    local wmTrackTitle = Instance.new("TextLabel", wMusic)
    wmTrackTitle.Name = "TrackTitle"
    wmTrackTitle.Size = UDim2.new(1, -125, 0, 18)
    wmTrackTitle.Position = UDim2.new(0, 102, 0, 18)
    wmTrackTitle.BackgroundTransparency = 1
    wmTrackTitle.Text = "Neon Rain"
    wmTrackTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    wmTrackTitle.Font = Enum.Font.GothamBold
    wmTrackTitle.TextSize = 14
    wmTrackTitle.TextXAlignment = Enum.TextXAlignment.Left
    wmTrackTitle.Visible = false
    wmTrackTitle.ZIndex = 14

    local wmArtist = Instance.new("TextLabel", wMusic)
    wmArtist.Name = "Artist"
    wmArtist.Size = UDim2.new(1, -125, 0, 15)
    wmArtist.Position = UDim2.new(0, 102, 0, 36)
    wmArtist.BackgroundTransparency = 1
    wmArtist.Text = "Mirror Park"
    wmArtist.TextColor3 = Color3.fromRGB(142, 142, 147)
    wmArtist.Font = Enum.Font.Gotham
    wmArtist.TextSize = 11
    wmArtist.TextXAlignment = Enum.TextXAlignment.Left
    wmArtist.Visible = false
    wmArtist.ZIndex = 14

    local wmScrubber = Instance.new("Frame", wMusic)
    wmScrubber.Size = UDim2.new(0, 96, 0, 4)
    wmScrubber.Position = UDim2.new(0, 102, 0, 56)
    wmScrubber.BackgroundColor3 = Color3.fromRGB(80, 25, 35)
    wmScrubber.BorderSizePixel = 0
    wmScrubber.ZIndex = 13
    Instance.new("UICorner", wmScrubber).CornerRadius = UDim.new(1, 0)

    local wmScrubberFill = Instance.new("Frame", wmScrubber)
    wmScrubberFill.Name = "Fill"
    wmScrubberFill.Size = UDim2.new(0.45, 0, 1, 0)
    wmScrubberFill.BackgroundColor3 = Color3.fromRGB(255, 45, 85)
    wmScrubberFill.BorderSizePixel = 0
    wmScrubberFill.ZIndex = 14
    Instance.new("UICorner", wmScrubberFill).CornerRadius = UDim.new(1, 0)

    local wmControls = Instance.new("Frame", wMusic)
    wmControls.Name = "Controls"
    wmControls.Size = UDim2.new(0, 72, 0, 24)
    wmControls.Position = UDim2.new(1, -86, 0, 52)
    wmControls.BackgroundTransparency = 1
    wmControls.Visible = false
    wmControls.ZIndex = 14

    local ctrlPlay = Instance.new("TextLabel", wmControls)
    ctrlPlay.Size = UDim2.new(0, 24, 1, 0)
    ctrlPlay.Position = UDim2.new(0, 0, 0, 0)
    ctrlPlay.BackgroundTransparency = 1
    ctrlPlay.Text = "▶"
    ctrlPlay.TextColor3 = Color3.fromRGB(255, 255, 255)
    ctrlPlay.TextSize = 13
    ctrlPlay.ZIndex = 15

    local ctrlNext = Instance.new("TextLabel", wmControls)
    ctrlNext.Size = UDim2.new(0, 24, 1, 0)
    ctrlNext.Position = UDim2.new(0, 32, 0, 0)
    ctrlNext.BackgroundTransparency = 1
    ctrlNext.Text = "⏭"
    ctrlNext.TextColor3 = Color3.fromRGB(255, 255, 255)
    ctrlNext.TextSize = 13
    ctrlNext.ZIndex = 15

    local wmSub = Instance.new("TextLabel", wMusic)
    wmSub.Size = UDim2.new(1, -20, 0, 20)
    wmSub.Position = UDim2.new(0, 10, 1, -24)
    wmSub.BackgroundTransparency = 1
    wmSub.Text = "No recently played music"
    wmSub.TextColor3 = Color3.fromRGB(220, 222, 230)
    wmSub.Font = Enum.Font.GothamBold
    wmSub.TextSize = 11.5
    wmSub.TextXAlignment = Enum.TextXAlignment.Center
    wmSub.ZIndex = 13

    local function updateMusicWidget(track: { title: string, artist: string, image: string?, isPlaying: boolean, progress: number? }?)
        if track and track.title and track.title ~= "" then
            wmSub.Visible = false
            artNote.Visible = false
            wmTrackTitle.Text = track.title
            wmTrackTitle.Visible = true
            wmArtist.Text = track.artist
            wmArtist.Visible = true
            wmControls.Visible = true
            if track.image and track.image ~= "" then
                wmArtImg.Image = track.image
                wmArtImg.Visible = true
            end
            local prog = math.clamp(track.progress or 0.45, 0, 1)
            wmScrubberFill.Size = UDim2.new(prog, 0, 1, 0)
        else
            wmSub.Visible = true
            artNote.Visible = true
            wmArtImg.Visible = false
            wmTrackTitle.Visible = false
            wmArtist.Visible = false
            wmControls.Visible = false
        end
    end

    wMusic.MouseButton1Click:Connect(function() openAppCallback("Music") end)

    local lblMusic = Instance.new("TextLabel", page1)
    lblMusic.Size = UDim2.new(1, 0, 0, 14)
    lblMusic.Position = UDim2.new(0, 0, 0, 338)
    lblMusic.BackgroundTransparency = 1
    lblMusic.Text = "Music"
    lblMusic.TextColor3 = Color3.fromRGB(255, 255, 255)
    lblMusic.Font = Enum.Font.GothamMedium
    lblMusic.TextSize = 11
    lblMusic.TextXAlignment = Enum.TextXAlignment.Center
    lblMusic.ZIndex = 13

    -- Page 1 App Grid (8 apps: 2 rows x 4 cols, perfectly aligned with Rows 5 & 6 of Page 2)
    local page1Grid = Instance.new("Frame", page1)
    page1Grid.Name = "AppGrid"
    page1Grid.Size = UDim2.new(1, -24, 0, 160)
    page1Grid.Position = UDim2.new(0, 12, 0, 360)
    page1Grid.BackgroundTransparency = 1
    page1Grid.ZIndex = 12

    local p1Layout = Instance.new("UIGridLayout", page1Grid)
    p1Layout.CellSize = UDim2.new(0, 58, 0, 72)
    p1Layout.CellPadding = UDim2.new(0, 14, 0, 12)
    p1Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    p1Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local p1Apps = {
        {"Calculator", "Calculator", "rbxassetid://129797552944912", 0},
        {"Banking", "Banking", "rbxassetid://113219823990413", 0},
        {"Weather", "Weather", "rbxassetid://93316242404129", 0},
        {"Billing", "Billing", "rbxassetid://120691943073443", 2},
        {"Mail", "Mail", "rbxassetid://124444731583599", 1},
        {"VaultX", "VaultX", "rbxassetid://75815873536189", 0},
        {"Notes", "Notes", "rbxassetid://126379364685622", 0},
        {"VoiceMemos", "Memos", "rbxassetid://105967486602343", 0},
    }
    for idx, item in ipairs(p1Apps) do
        makeAppIcon(page1Grid, item[1], item[2], item[3], idx, item[4])
    end

    -- =========================================================================
    -- PAGE 2: PICTURE 2 (24 Apps Grid, 6 Rows x 4 Cols, Evenly Spaced)
    -- =========================================================================
    local page2 = Instance.new("Frame", pagesContainer)
    page2.Name = "Page2"
    page2.Size = UDim2.new(1, 0, 1, 0)
    page2.BackgroundTransparency = 1
    page2.LayoutOrder = 2
    page2.ZIndex = 11

    local page2Grid = Instance.new("Frame", page2)
    page2Grid.Name = "AppGrid"
    page2Grid.Size = UDim2.new(1, -24, 0, 492)
    page2Grid.Position = UDim2.new(0, 12, 0, 68)
    page2Grid.BackgroundTransparency = 1
    page2Grid.ZIndex = 12

    local p2Layout = Instance.new("UIGridLayout", page2Grid)
    p2Layout.CellSize = UDim2.new(0, 58, 0, 72)
    p2Layout.CellPadding = UDim2.new(0, 14, 0, 12)
    p2Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    p2Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local page2Apps = {
        -- Row 1: Photos, App Store, Settings, Health
        {"Photos", "Photos", "rbxassetid://76222215665071", 0},
        {"AppStore", "App Store", "rbxassetid://138098392316055", 0},
        {"Settings", "Settings", "rbxassetid://134186256578892", 0},
        {"Health", "Health", "rbxassetid://131644135355880", 0},

        -- Row 2: Map, Snake, Memory, 2048
        {"Maps", "Map", "rbxassetid://87510415537199", 0},
        {"Snake", "Snake", "rbxassetid://98087609718142", 0},
        {"Memory", "Memory", "rbxassetid://81614406065481", 0},
        {"Game2048", "2048", "rbxassetid://73681664605256", 0},

        -- Row 3: Minesweeper, Tower Stack, Sky Flappy, Neon Drop
        {"Minesweeper", "Mineswe...", "rbxassetid://128647845095689", 0},
        {"TowerStack", "Tower Sta...", "rbxassetid://74730984383151", 0},
        {"SkyFlappy", "Sky Flappy", "rbxassetid://123795653808019", 0},
        {"NeonDrop", "Neon Drop", "rbxassetid://90607228374109", 0},

        -- Row 4: CityMarkt (badge 5), Local Pages, Calendar (Mon 21), Radio
        {"CityMarkt", "CityMarkt", "rbxassetid://95951474710933", 5},
        {"LocalPages", "Local Pages", "rbxassetid://130772677041911", 0},
        {"Calendar", "Calendar", "rbxassetid://120088589434683", 0},
        {"Radio", "Radio", "rbxassetid://76034907691302", 0},

        -- Row 5: FlipTok, DarkChat (badge 2), Picstagram, Garage
        {"FlipTok", "FlipTok", "rbxassetid://137548902900974", 0},
        {"DarkChat", "DarkChat", "rbxassetid://120681331774905", 2},
        {"Picstagram", "Picstagram", "rbxassetid://138647675714650", 0},
        {"Garage", "Garage", "rbxassetid://131470370579445", 0},

        -- Row 6: Flare, Feather, House, SkyRide
        {"Flare", "Flare", "rbxassetid://91154694947031", 0},
        {"Feather", "Feather", "rbxassetid://138549145828003", 0},
        {"House", "House", "rbxassetid://128366375527070", 0},
        {"SkyRide", "SkyRide", "rbxassetid://119249104472495", 0},
    }

    for idx, item in ipairs(page2Apps) do
        makeAppIcon(page2Grid, item[1], item[2], item[3], idx, item[4])
    end

    -- =========================================================================
    -- PAGE 3: PICTURE 3 (5 Secondary Apps: Music, CrewLink, Companies, Weazel N..., CityWarn)
    -- =========================================================================
    local page3 = Instance.new("Frame", pagesContainer)
    page3.Name = "Page3"
    page3.Size = UDim2.new(1, 0, 1, 0)
    page3.BackgroundTransparency = 1
    page3.LayoutOrder = 3
    page3.ZIndex = 11

    local page3Grid = Instance.new("Frame", page3)
    page3Grid.Name = "AppGrid"
    page3Grid.Size = UDim2.new(1, -24, 0, 492)
    page3Grid.Position = UDim2.new(0, 12, 0, 68)
    page3Grid.BackgroundTransparency = 1
    page3Grid.ZIndex = 12

    local p3Layout = Instance.new("UIGridLayout", page3Grid)
    p3Layout.CellSize = UDim2.new(0, 58, 0, 72)
    p3Layout.CellPadding = UDim2.new(0, 14, 0, 12)
    p3Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    p3Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local p3Apps = {
        -- Row 1: Music, CrewLink, Companies (badge 2), Weazel N...
        {"Music", "Music", "rbxassetid://127792277672651", 0},
        {"CrewLink", "CrewLink", "rbxassetid://96986862031142", 0},
        {"Companies", "Companies", "rbxassetid://83617015141028", 2},
        {"WeazelNews", "Weazel N...", "rbxassetid://127924170113015", 0},

        -- Row 2: CityWarn
        {"CityWarn", "CityWarn", "rbxassetid://136532607231789", 0},
    }
    for idx, item in ipairs(p3Apps) do
        makeAppIcon(page3Grid, item[1], item[2], item[3], idx, item[4])
    end

    -- =========================================================================
    -- PAGE 4: APP LIBRARY
    -- =========================================================================
    local page4 = Instance.new("Frame", pagesContainer)
    page4.Name = "Page4"
    page4.Size = UDim2.new(1, 0, 1, 0)
    page4.BackgroundTransparency = 1
    page4.LayoutOrder = 4
    page4.ZIndex = 11

    local libTitle = Instance.new("TextLabel", page4)
    libTitle.Size = UDim2.new(1, -28, 0, 32)
    libTitle.Position = UDim2.new(0, 14, 0, 52)
    libTitle.Text = "App Library"
    libTitle.Font = Enum.Font.GothamBold
    libTitle.TextSize = 24
    libTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    libTitle.TextXAlignment = Enum.TextXAlignment.Left
    libTitle.BackgroundTransparency = 1
    libTitle.ZIndex = 12

    local function makeLibraryFolder(name: string, xPos: number, yPos: number, ...: {string})
        local apps = {...}
        local f = Instance.new("Frame", page4)
        f.Size = UDim2.new(0.46, 0, 0, 130)
        f.Position = UDim2.new(xPos, 0, 0, yPos)
        f.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
        f.BackgroundTransparency = 0.5
        f.BorderSizePixel = 0
        f.ZIndex = 12
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 20)

        local t = Instance.new("TextLabel", f)
        t.Size = UDim2.new(1, -16, 0, 20)
        t.Position = UDim2.new(0, 10, 0, 8)
        t.Text = name
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.BackgroundTransparency = 1
        t.ZIndex = 13

        local fGrid = Instance.new("Frame", f)
        fGrid.Size = UDim2.new(1, -20, 1, -36)
        fGrid.Position = UDim2.new(0, 10, 0, 30)
        fGrid.BackgroundTransparency = 1
        fGrid.ZIndex = 13

        local fgLayout = Instance.new("UIGridLayout", fGrid)
        fgLayout.CellSize = UDim2.new(0.46, 0, 0.46, 0)
        fgLayout.CellPadding = UDim2.new(0.08, 0, 0.08, 0)

        for _, a in ipairs(apps) do
            local b = Instance.new("ImageButton", fGrid)
            b.BackgroundColor3 = Color3.fromRGB(36, 38, 50)
            b.Image = a[2]
            b.ScaleType = Enum.ScaleType.Fit
            b.ZIndex = 14
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            b.MouseButton1Click:Connect(function() openAppCallback(a[1]) end)
        end
    end

    makeLibraryFolder("Utilities", 0.035, 94, {"Calculator", "rbxassetid://129797552944912"}, {"Clock", "rbxassetid://103043499972901"}, {"Compass", "rbxassetid://134186256578892"}, {"Settings", "rbxassetid://134186256578892"})
    makeLibraryFolder("Social", 0.51, 94, {"Messages", "rbxassetid://139358287735244"}, {"FlipTok", "rbxassetid://137548902900974"}, {"DarkChat", "rbxassetid://120681331774905"}, {"Picstagram", "rbxassetid://138647675714650"})
    makeLibraryFolder("Entertainment", 0.035, 238, {"Radio", "rbxassetid://76034907691302"}, {"SkyFlappy", "rbxassetid://123795653808019"}, {"NeonDrop", "rbxassetid://90607228374109"}, {"Photos", "rbxassetid://76222215665071"})
    makeLibraryFolder("Finance", 0.51, 238, {"Banking", "rbxassetid://113219823990413"}, {"VaultX", "rbxassetid://75815873536189"}, {"Billing", "rbxassetid://120691943073443"}, {"CityMarkt", "rbxassetid://95951474710933"})

    -- ================= PAGE DOTS (4 DOTS) =================
    local dotsContainer = Instance.new("Frame", homeScreen)
    dotsContainer.Name = "DotsContainer"
    dotsContainer.AnchorPoint = Vector2.new(0.5, 1)
    dotsContainer.Position = UDim2.new(0.5, 0, 1, -112)
    dotsContainer.Size = UDim2.new(0, 72, 0, 16)
    dotsContainer.BackgroundTransparency = 1
    dotsContainer.ZIndex = 14

    local dLayout = Instance.new("UIListLayout", dotsContainer)
    dLayout.FillDirection = Enum.FillDirection.Horizontal
    dLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    dLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    dLayout.Padding = UDim.new(0, 8)

    local dots = {}
    for i = 1, 4 do
        local d = Instance.new("TextButton", dotsContainer)
        d.Name = "Dot_" .. tostring(i)
        d.Size = UDim2.new(0, 7, 0, 7)
        d.BackgroundColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 125, 140)
        d.BackgroundTransparency = (i == 1) and 0 or 0.5
        d.Text = ""
        d.BorderSizePixel = 0
        d.ZIndex = 15
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)

        d.MouseButton1Click:Connect(function()
            local targetPage = pagesContainer:FindFirstChild("Page" .. tostring(i))
            if targetPage then pageLayout:JumpTo(targetPage) end
        end)
        dots[i] = d
    end

    pageLayout.PageEnter:Connect(function(pg)
        local idx = 1
        if pg.Name == "Page2" then idx = 2
        elseif pg.Name == "Page3" then idx = 3
        elseif pg.Name == "Page4" then idx = 4 end
        for i, d in ipairs(dots) do
            d.BackgroundColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 125, 140)
            d.BackgroundTransparency = (i == idx) and 0 or 0.5
        end
    end)

    -- ================= FROSTED GLASS DOCK =================
    local dockFrame = Instance.new("Frame", homeScreen)
    dockFrame.Name = "Dock"
    dockFrame.AnchorPoint = Vector2.new(0.5, 1)
    dockFrame.Position = UDim2.new(0.5, 0, 1, -26)
    dockFrame.Size = UDim2.new(1, -24, 0, 76)
    dockFrame.BackgroundColor3 = Color3.fromRGB(36, 40, 52)
    dockFrame.BackgroundTransparency = 0.50
    dockFrame.BorderSizePixel = 0
    dockFrame.ZIndex = 14
    Instance.new("UICorner", dockFrame).CornerRadius = UDim.new(0, 30)
    local ds = Instance.new("UIStroke", dockFrame)
    ds.Color = Color3.fromRGB(255, 255, 255)
    ds.Transparency = 0.85
    ds.Thickness = 1.0

    local dockLayout = Instance.new("UIListLayout", dockFrame)
    dockLayout.FillDirection = Enum.FillDirection.Horizontal
    dockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    dockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    dockLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dockLayout.Padding = UDim.new(0, 14)

    local function makeDockIcon(parent: Instance, name: string, iconAsset: string, layoutOrder: number)
        local btn = Instance.new("TextButton", parent)
        btn.Name = "App_" .. name
        btn.Size = UDim2.new(0, 54, 0, 54)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder = layoutOrder
        btn.ZIndex = 15

        local iconImg = Instance.new("ImageLabel", btn)
        iconImg.Name = "Icon"
        iconImg.Size = UDim2.new(1, 0, 1, 0)
        iconImg.BackgroundColor3 = Color3.fromRGB(32, 34, 44)
        iconImg.Image = iconAsset
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.ZIndex = 16
        Instance.new("UICorner", iconImg).CornerRadius = UDim.new(0, 13)

        btn.MouseButton1Click:Connect(function()
            openAppCallback(name)
        end)
        return btn
    end

    -- Dock: Phone, Messages, Camera, Clock
    makeDockIcon(dockFrame, "Phone", "rbxassetid://70546187772415", 1)
    makeDockIcon(dockFrame, "Messages", "rbxassetid://139358287735244", 2)
    makeDockIcon(dockFrame, "Camera", "rbxassetid://134300653681700", 3)
    makeDockIcon(dockFrame, "Clock", "rbxassetid://103043499972901", 4)

    return {
        homeScreen = homeScreen,
        pagesContainer = pagesContainer,
        pageLayout = pageLayout,
        dotsContainer = dotsContainer,
        dock = dockFrame,
        updateMusicWidget = updateMusicWidget,
    }
end

return Springboard
