--!strict
-- src/sky_phone/Chassis.luau
-- Pure Luau Component: Phone Hardware Chassis, Shadow, Bezel, Machined Buttons, Screen & HUD Toggle
local Chassis = {}

function Chassis.build(screenGui: ScreenGui, isPlayMode: boolean)
    -- Clean up any prior chassis/shadow/toggle if present
    for _, name in ipairs({"PhoneChassis", "PhoneShadow", "PhoneToggle"}) do
        local old = screenGui:FindFirstChild(name)
        if old then old:Destroy() end
    end

    -- 1. Phone Shadow Removed for Uniform Bezel on All Sides
    -- Any prior PhoneShadow is explicitly cleaned up

    -- 2. Hardware Chassis Frame
    local phoneChassis = Instance.new("Frame")
    phoneChassis.Name = "PhoneChassis"
    phoneChassis.AnchorPoint = Vector2.new(0.5, 0.5)
    phoneChassis.Position = isPlayMode and UDim2.new(0.5, 0, 1.55, 0) or UDim2.new(0.5, 0, 0.5, 0)
    phoneChassis.Size = UDim2.new(1, 0, 0.94, 0)
    phoneChassis.BackgroundColor3 = Color3.fromRGB(34, 36, 42)
    phoneChassis.BorderSizePixel = 0
    phoneChassis.Visible = not isPlayMode
    phoneChassis.ZIndex = 1
    phoneChassis.Parent = screenGui

    local aspect = Instance.new("UIAspectRatioConstraint", phoneChassis)
    aspect.AspectRatio = 0.4387

    local chassisCorner = Instance.new("UICorner", phoneChassis)
    chassisCorner.CornerRadius = UDim.new(0.145, 0)

    local chassisBgGrad = Instance.new("UIGradient", phoneChassis)
    chassisBgGrad.Rotation = 90
    chassisBgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(52, 56, 64)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 30, 36)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(48, 52, 60)),
    })

    -- Titanium Outer Highlight Chamfer
    local chassisStroke = Instance.new("UIStroke", phoneChassis)
    chassisStroke.Color = Color3.fromRGB(255, 255, 255)
    chassisStroke.Thickness = 2.4

    local strokeGrad = Instance.new("UIGradient", chassisStroke)
    strokeGrad.Rotation = 65
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(235, 240, 252)),
        ColorSequenceKeypoint.new(0.18, Color3.fromRGB(145, 150, 162)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(68, 72, 82)),
        ColorSequenceKeypoint.new(0.72, Color3.fromRGB(95, 100, 112)),
        ColorSequenceKeypoint.new(0.90, Color3.fromRGB(175, 180, 195)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(225, 230, 245)),
    })

    -- Inner Bezel Frame
    local innerBezel = Instance.new("Frame", phoneChassis)
    innerBezel.Name = "InnerBezel"
    innerBezel.AnchorPoint = Vector2.new(0.5, 0.5)
    innerBezel.Position = UDim2.new(0.5, 0, 0.5, 0)
    innerBezel.Size = UDim2.new(1, -6, 1, -6)
    innerBezel.BackgroundColor3 = Color3.fromRGB(12, 13, 16)
    innerBezel.BorderSizePixel = 0
    innerBezel.ZIndex = 2
    Instance.new("UICorner", innerBezel).CornerRadius = UDim.new(0.140, 0)

    -- 3. Screen Viewport
    local screen = Instance.new("Frame", phoneChassis)
    screen.Name = "Screen"
    screen.AnchorPoint = Vector2.new(0.5, 0.5)
    screen.Position = UDim2.new(0.5, 0, 0.5, 0)
    screen.Size = UDim2.new(1, -12, 1, -12)
    screen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    screen.BorderSizePixel = 0
    screen.ClipsDescendants = true
    screen.ZIndex = 3

    local screenCorner = Instance.new("UICorner", screen)
    screenCorner.CornerRadius = UDim.new(0.136, 0)

    -- Official Wallpaper (Official deep space purple/navy gradient)
    local wallpaper = Instance.new("ImageLabel", screen)
    wallpaper.Name = "Wallpaper"
    wallpaper.Size = UDim2.new(1, 0, 1, 0)
    wallpaper.Position = UDim2.new(0, 0, 0, 0)
    wallpaper.BackgroundColor3 = Color3.fromRGB(12, 14, 28)
    wallpaper.Image = "rbxassetid://82226915452893"
    wallpaper.ScaleType = Enum.ScaleType.Crop
    wallpaper.BorderSizePixel = 0
    wallpaper.ZIndex = 3
    local wpCorner = Instance.new("UICorner", wallpaper)
    wpCorner.CornerRadius = UDim.new(0.136, 0)

    -- 4. 3D Machined Side Hardware Buttons
    local sideButtons = Instance.new("Folder", phoneChassis)
    sideButtons.Name = "SideButtons"

    local function makeButton(name, xPos, yPos, w, h, isLeft)
        local btn = Instance.new("TextButton", phoneChassis)
        btn.Name = name
        btn.Position = UDim2.new(xPos, isLeft and -w or 0, yPos, 0)
        btn.Size = UDim2.new(0, w, 0, h)
        btn.BackgroundColor3 = Color3.fromRGB(42, 44, 52)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.ZIndex = 0
        btn.AutoButtonColor = false
        btn.Parent = sideButtons

        local c = Instance.new("UICorner", btn)
        c.CornerRadius = UDim.new(0, 3)

        local st = Instance.new("UIStroke", btn)
        st.Color = Color3.fromRGB(130, 135, 150)
        st.Thickness = 1.0

        return btn
    end

    local actionBtn = makeButton("Action", 0, 0.14, 4, 30, true)
    local volUpBtn = makeButton("VolUp", 0, 0.22, 4, 48, true)
    local volDownBtn = makeButton("VolDown", 0, 0.31, 4, 48, true)
    local powerBtn = makeButton("Power", 1, 0.24, 4, 76, false)

    -- Antenna Bands
    local function makeAntennaBand(yScale, isLeft)
        local band = Instance.new("Frame", phoneChassis)
        band.Name = "AntennaBand"
        band.Size = UDim2.new(0, 2, 0, 4)
        band.Position = UDim2.new(isLeft and 0 or 1, isLeft and 0 or -2, yScale, 0)
        band.BackgroundColor3 = Color3.fromRGB(72, 75, 86)
        band.BorderSizePixel = 0
        band.ZIndex = 2
    end
    makeAntennaBand(0.08, true)
    makeAntennaBand(0.88, true)
    makeAntennaBand(0.08, false)
    makeAntennaBand(0.88, false)

    -- 5. Floating HUD Toggle Button (📱)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "PhoneToggle"
    toggleBtn.AnchorPoint = Vector2.new(1, 1)
    toggleBtn.Position = UDim2.new(1, -75, 1, -75)
    toggleBtn.Size = UDim2.new(0, 56, 0, 56)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    toggleBtn.Text = "📱"
    toggleBtn.TextSize = 28
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.AutoButtonColor = false
    toggleBtn.ZIndex = 500
    toggleBtn.Parent = screenGui

    local tbCorner = Instance.new("UICorner", toggleBtn)
    tbCorner.CornerRadius = UDim.new(1, 0)
    local tbStroke = Instance.new("UIStroke", toggleBtn)
    tbStroke.Color = Color3.fromRGB(80, 85, 105)
    tbStroke.Thickness = 2

    -- 6. Dynamic Island Pill
    local island = Instance.new("Frame", screen)
    island.Name = "DynamicIsland"
    island.AnchorPoint = Vector2.new(0.5, 0)
    island.Position = UDim2.new(0.5, 0, 0, 11)
    island.Size = UDim2.new(0, 88, 0, 24)
    island.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    island.BorderSizePixel = 0
    island.ZIndex = 80
    Instance.new("UICorner", island).CornerRadius = UDim.new(1, 0)

    local camLens = Instance.new("Frame", island)
    camLens.Name = "CameraLens"
    camLens.AnchorPoint = Vector2.new(1, 0.5)
    camLens.Position = UDim2.new(1, -7, 0.5, 0)
    camLens.Size = UDim2.new(0, 10, 0, 10)
    camLens.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    camLens.BorderSizePixel = 0
    camLens.ZIndex = 81
    Instance.new("UICorner", camLens).CornerRadius = UDim.new(1, 0)

    local sensDot = Instance.new("Frame", island)
    sensDot.Name = "SensorDot"
    sensDot.AnchorPoint = Vector2.new(0, 0.5)
    sensDot.Position = UDim2.new(0, 7, 0.5, 0)
    sensDot.Size = UDim2.new(0, 7, 0, 7)
    sensDot.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    sensDot.BorderSizePixel = 0
    sensDot.ZIndex = 81
    Instance.new("UICorner", sensDot).CornerRadius = UDim.new(1, 0)

    -- Dynamic Island Content (for active calls or music)
    local islandContent = Instance.new("Frame", island)
    islandContent.Name = "Content"
    islandContent.Size = UDim2.new(1, -36, 1, 0)
    islandContent.Position = UDim2.new(0, 18, 0, 0)
    islandContent.BackgroundTransparency = 1
    islandContent.Visible = false
    islandContent.ZIndex = 81

    local islandText = Instance.new("TextLabel", islandContent)
    islandText.Name = "Text"
    islandText.Size = UDim2.new(1, 0, 1, 0)
    islandText.BackgroundTransparency = 1
    islandText.Text = ""
    islandText.TextColor3 = Color3.fromRGB(52, 199, 89)
    islandText.Font = Enum.Font.GothamBold
    islandText.TextSize = 10
    islandText.TextTruncate = Enum.TextTruncate.AtEnd
    islandText.ZIndex = 82

    -- 7. Status Bar
    local statusBar = Instance.new("Frame", screen)
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -36, 0, 32)
    statusBar.Position = UDim2.new(0, 18, 0, 7)
    statusBar.BackgroundTransparency = 1
    statusBar.ZIndex = 70

    local timeLabel = Instance.new("TextLabel", statusBar)
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(0, 54, 1, 0)
    timeLabel.Position = UDim2.new(0, 2, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "18:40"
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.TextSize = 13.5
    timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.ZIndex = 71

    local statusIcons = Instance.new("Frame", statusBar)
    statusIcons.Name = "StatusIcons"
    statusIcons.AnchorPoint = Vector2.new(1, 0)
    statusIcons.Position = UDim2.new(1, 0, 0, 0)
    statusIcons.Size = UDim2.new(0, 70, 1, 0)
    statusIcons.BackgroundTransparency = 1
    statusIcons.ZIndex = 71

    local cellLbl = Instance.new("TextLabel", statusIcons)
    cellLbl.Name = "Cellular"
    cellLbl.Size = UDim2.new(0, 14, 1, 0)
    cellLbl.Position = UDim2.new(0, 4, 0, 0)
    cellLbl.BackgroundTransparency = 1
    cellLbl.Text = "📶"
    cellLbl.TextSize = 11
    cellLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    cellLbl.ZIndex = 72

    local wifiLbl = Instance.new("TextLabel", statusIcons)
    wifiLbl.Name = "WiFi"
    wifiLbl.Size = UDim2.new(0, 14, 1, 0)
    wifiLbl.Position = UDim2.new(0, 22, 0, 0)
    wifiLbl.BackgroundTransparency = 1
    wifiLbl.Text = "🛜"
    wifiLbl.TextSize = 11
    wifiLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    wifiLbl.ZIndex = 72

    -- Battery Pill
    local batt = Instance.new("Frame", statusIcons)
    batt.Name = "Battery"
    batt.Size = UDim2.new(0, 22, 0, 11)
    batt.Position = UDim2.new(0, 42, 0.5, -5.5)
    batt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    batt.BorderSizePixel = 0
    batt.ZIndex = 72
    Instance.new("UICorner", batt).CornerRadius = UDim.new(0, 3)

    local battStroke = Instance.new("UIStroke", batt)
    battStroke.Color = Color3.fromRGB(255, 255, 255)
    battStroke.Thickness = 1.0

    local battFill = Instance.new("Frame", batt)
    battFill.Name = "Fill"
    battFill.Size = UDim2.new(0.85, 0, 1, -2)
    battFill.Position = UDim2.new(0, 1, 0, 1)
    battFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    battFill.BorderSizePixel = 0
    battFill.ZIndex = 73
    Instance.new("UICorner", battFill).CornerRadius = UDim.new(0, 2)

    -- 8. Home Indicator (Home Bar)
    local homeIndicator = Instance.new("Frame", screen)
    homeIndicator.Name = "HomeIndicator"
    homeIndicator.AnchorPoint = Vector2.new(0.5, 1)
    homeIndicator.Position = UDim2.new(0.5, 0, 1, -8)
    homeIndicator.Size = UDim2.new(0, 134, 0, 5)
    homeIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    homeIndicator.BackgroundTransparency = 0.2
    homeIndicator.BorderSizePixel = 0
    homeIndicator.ZIndex = 100
    Instance.new("UICorner", homeIndicator).CornerRadius = UDim.new(1, 0)

    -- Invisible tap hitbox for comfortable interaction
    local hiHitBox = Instance.new("TextButton", homeIndicator)
    hiHitBox.Name = "HitBox"
    hiHitBox.AnchorPoint = Vector2.new(0.5, 0.5)
    hiHitBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    hiHitBox.Size = UDim2.new(1, 60, 1, 32)
    hiHitBox.BackgroundTransparency = 1
    hiHitBox.Text = ""
    hiHitBox.ZIndex = 101

    local airplaneLbl = Instance.new("TextLabel", statusIcons)
    airplaneLbl.Name = "Airplane"
    airplaneLbl.Size = UDim2.new(0, 14, 1, 0)
    airplaneLbl.Position = UDim2.new(0, 4, 0, 0)
    airplaneLbl.BackgroundTransparency = 1
    airplaneLbl.Text = "✈"
    airplaneLbl.TextSize = 11
    airplaneLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    airplaneLbl.Visible = false
    airplaneLbl.ZIndex = 72

    local function setAirplaneMode(enabled: boolean)
        cellLbl.Visible = not enabled
        airplaneLbl.Visible = enabled
    end

    -- Container for all Apps (With matching UICorner to prevent square corner bleeding)
    local appContainer = Instance.new("Frame", screen)
    appContainer.Name = "AppContainer"
    appContainer.Size = UDim2.new(1, 0, 1, 0)
    appContainer.Position = UDim2.new(0, 0, 0, 0)
    appContainer.BackgroundTransparency = 1
    appContainer.Visible = false
    appContainer.ZIndex = 10
    appContainer.ClipsDescendants = true
    Instance.new("UICorner", appContainer).CornerRadius = UDim.new(0.136, 0)

    -- 9. Dynamic Island Push Notification Banner
    local bannerFrame = Instance.new("Frame", screen)
    bannerFrame.Name = "NotificationBanner"
    bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
    bannerFrame.Position = UDim2.new(0.5, 0, 0, -84)
    bannerFrame.Size = UDim2.new(1, -24, 0, 62)
    bannerFrame.BackgroundColor3 = Color3.fromRGB(26, 28, 36)
    bannerFrame.BorderSizePixel = 0
    bannerFrame.ZIndex = 90
    bannerFrame.ClipsDescendants = true
    Instance.new("UICorner", bannerFrame).CornerRadius = UDim.new(0, 20)

    local bannerStroke = Instance.new("UIStroke", bannerFrame)
    bannerStroke.Color = Color3.fromRGB(255, 255, 255)
    bannerStroke.Transparency = 0.88
    bannerStroke.Thickness = 1

    local bIcon = Instance.new("ImageLabel", bannerFrame)
    bIcon.Name = "AppIcon"
    bIcon.Size = UDim2.new(0, 36, 0, 36)
    bIcon.Position = UDim2.new(0, 12, 0.5, -18)
    bIcon.BackgroundColor3 = Color3.fromRGB(44, 46, 56)
    bIcon.BorderSizePixel = 0
    bIcon.ZIndex = 91
    Instance.new("UICorner", bIcon).CornerRadius = UDim.new(0, 9)

    local bAppTitle = Instance.new("TextLabel", bannerFrame)
    bAppTitle.Name = "AppTitle"
    bAppTitle.Size = UDim2.new(1, -120, 0, 16)
    bAppTitle.Position = UDim2.new(0, 56, 0, 12)
    bAppTitle.BackgroundTransparency = 1
    bAppTitle.Text = "Notification"
    bAppTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    bAppTitle.Font = Enum.Font.GothamBold
    bAppTitle.TextSize = 12
    bAppTitle.TextXAlignment = Enum.TextXAlignment.Left
    bAppTitle.ZIndex = 91

    local bTime = Instance.new("TextLabel", bannerFrame)
    bTime.Name = "TimeText"
    bTime.Size = UDim2.new(0, 50, 0, 16)
    bTime.Position = UDim2.new(1, -62, 0, 12)
    bTime.BackgroundTransparency = 1
    bTime.Text = "now"
    bTime.TextColor3 = Color3.fromRGB(142, 142, 147)
    bTime.Font = Enum.Font.Gotham
    bTime.TextSize = 10
    bTime.TextXAlignment = Enum.TextXAlignment.Right
    bTime.ZIndex = 91

    local bMsg = Instance.new("TextLabel", bannerFrame)
    bMsg.Name = "Message"
    bMsg.Size = UDim2.new(1, -68, 0, 24)
    bMsg.Position = UDim2.new(0, 56, 0, 28)
    bMsg.BackgroundTransparency = 1
    bMsg.Text = "Alert message content"
    bMsg.TextColor3 = Color3.fromRGB(220, 222, 230)
    bMsg.Font = Enum.Font.Gotham
    bMsg.TextSize = 11.5
    bMsg.TextXAlignment = Enum.TextXAlignment.Left
    bMsg.TextTruncate = Enum.TextTruncate.AtEnd
    bMsg.ZIndex = 91

    local TweenService = game:GetService("TweenService")

    local function showBanner(title: string, message: string, iconId: string?, customTime: string?)
        bAppTitle.Text = title
        bMsg.Text = message
        bTime.Text = customTime or timeLabel.Text
        if iconId and iconId ~= "" then
            bIcon.Image = iconId
            bIcon.Visible = true
        else
            bIcon.Image = ""
        end

        local tweenIn = TweenService:Create(bannerFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 12)
        })
        tweenIn:Play()

        task.delay(3.5, function()
            local tweenOut = TweenService:Create(bannerFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -84)
            })
            tweenOut:Play()
        end)
    end

    return {
        chassis = phoneChassis,
        toggleBtn = toggleBtn,
        screen = screen,
        appContainer = appContainer,
        island = island,
        statusBar = statusBar,
        timeLabel = timeLabel,
        homeIndicator = homeIndicator,
        sideButtons = sideButtons,
        showBanner = showBanner,
        setAirplaneMode = setAirplaneMode,
        wallpaper = wallpaper,
    }
end

return Chassis
