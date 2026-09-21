--!strict
-- src/sky_phone/Router.luau
-- Pure Luau Component: Router, App Navigation, Control Center, Dynamic Island Banner & Global Theme Engine
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Router = {}

local function playTone(pitch: number?)
    task.spawn(function()
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
        snd.Volume = 0.35
        snd.Pitch = pitch or 1.8
        snd.Parent = workspace
        snd:Play()
        Debris:AddItem(snd, 1)
    end)
end

function Router.build(config: {
    screenGui: ScreenGui,
    chassis: Frame,
        toggleBtn: TextButton?,
    screen: Frame,
    appContainer: Frame,
    homeScreen: Frame,
    pagesContainer: Frame?,
    pageLayout: UIPageLayout?,
    dotsContainer: Frame?,
    dock: Frame?,
    island: Frame?,
    statusBar: Frame?,
    homeIndicator: Frame?,
    isPlayMode: boolean,
    showBanner: ((title: string, message: string, iconId: string?, customTime: string?) -> ())?,
    setAirplaneMode: ((enabled: boolean) -> ())?,
    updateMusicWidget: ((track: any) -> ())?,
})
    local screenGui = config.screenGui
    local chassis = config.chassis
    local toggleBtn = config.toggleBtn
    local screen = config.screen
    local appContainer = config.appContainer
    local homeScreen = config.homeScreen
    local pagesContainer = config.pagesContainer
    local pageLayout = config.pageLayout
    local island = config.island
    local statusBar = config.statusBar
    local homeIndicator = config.homeIndicator
    local isPlayMode = config.isPlayMode

    local isOpen = not isPlayMode
    local currentTheme = "dark"
    local activeAppName: string? = nil

    local OPEN_POS = UDim2.new(0.5, 0, 0.5, 0)
    local CLOSED_POS = UDim2.new(0.5, 0, 1.55, 0)
        
    -- Dynamic Island Notification Banner
    local function showNotification(title: string, msg: string)
        if not island then return end
        task.spawn(function()
            playTone(2.4)
            local origSize = UDim2.new(0, 88, 0, 24)
            local expSize = UDim2.new(0, 240, 0, 48)

            local bannerText = island:FindFirstChild("BannerText") :: TextLabel?
            if not bannerText then
                bannerText = Instance.new("TextLabel", island)
                bannerText.Name = "BannerText"
                bannerText.Size = UDim2.new(1, -16, 1, 0)
                bannerText.Position = UDim2.new(0, 8, 0, 0)
                bannerText.BackgroundTransparency = 1
                bannerText.TextColor3 = Color3.fromRGB(255, 255, 255)
                bannerText.Font = Enum.Font.GothamMedium
                bannerText.TextSize = 11
                bannerText.TextWrapped = true
                bannerText.ZIndex = 86
            end
            bannerText.Text = title .. ": " .. msg
            bannerText.Visible = true

            local twOpen = TweenService:Create(island, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = expSize
            })
            twOpen:Play()
            task.wait(2.8)
            bannerText.Visible = false
            local twClose = TweenService:Create(island, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = origSize
            })
            twClose:Play()
        end)
    end

    -- Global Theme Switcher
    local function setTheme(theme: string)
        currentTheme = (theme == "light") and "light" or "dark"
        local isLight = (currentTheme == "light")
        screenGui:SetAttribute("CurrentTheme", currentTheme)

        -- Update Status Bar
        if statusBar then
            for _, d in ipairs(statusBar:GetDescendants()) do
                if d:IsA("TextLabel") then
                    d.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255)
                end
            end
        end

        -- Update Home Indicator
        if homeIndicator then
            homeIndicator.BackgroundColor3 = isLight and Color3.fromRGB(60, 64, 75) or Color3.fromRGB(255, 255, 255)
        end

        -- Update App Theme Handlers
        if _G.SkyPhone_AppThemeUpdaters then
            for appName, updater in pairs(_G.SkyPhone_AppThemeUpdaters) do
                pcall(function() updater(isLight) end)
            end
        end
    end

    -- Open App Implementation
    local function openApp(name: string)
        playTone(1.8)
        if not name or name == "" then return end

        homeScreen.Visible = false
        appContainer.Visible = true

        -- Hide all apps first
        for _, child in ipairs(appContainer:GetChildren()) do
            if child:IsA("Frame") or child:IsA("GuiObject") then
                child.Visible = false
            end
        end

                                        local appAliases: {[string]: string} = {
            ["Map"] = "Maps",
            ["CityMarkt"] = "CityMarkt",
            ["LocalPages"] = "LocalPages",
            ["FlipTok"] = "FlipTok",
            ["Picstagram"] = "Picstagram",
            ["SkyRide"] = "SkyRide",
            ["2048"] = "Game2048",
            ["App2048"] = "Game2048",
            ["CrewLink"] = "CrewLink",
            ["Companies"] = "Companies",
            ["WeazelNews"] = "WeazelNews",
            ["CityWarn"] = "CityWarn",
        }
        if appAliases[name] then
            name = appAliases[name]
        end
        local targetName = name
        if not string.find(targetName, "App$") then
            targetName = targetName .. "App"
        end

        local targetApp = appContainer:FindFirstChild(targetName)
        if not targetApp then targetApp = appContainer:FindFirstChild(name) end

        if not targetApp then
            local lowerName = string.lower(name)
            for _, child in ipairs(appContainer:GetChildren()) do
                local cl = string.lower(child.Name)
                if cl == lowerName or cl == lowerName .. "app" or string.find(cl, lowerName) then
                    targetApp = child
                    break
                end
            end
        end

        if targetApp then
            targetApp.Visible = true
            activeAppName = targetApp.Name
            screenGui:SetAttribute("ActiveApp", activeAppName)
            print("[SkyPhone] Opened App: " .. targetApp.Name)

            local appKey = string.gsub(targetApp.Name, "App$", "")
            if _G.SkyPhone_AppThemeUpdaters and _G.SkyPhone_AppThemeUpdaters[appKey] then
                pcall(function() _G.SkyPhone_AppThemeUpdaters[appKey](currentTheme == "light") end)
            end
        else
            warn("[SkyPhone] App not found in AppContainer: " .. tostring(name))
            showNotification("App", name .. " installed.")
        end
    end

    -- Go Home Implementation
    local function goHome()
        playTone(1.6)
        for _, child in ipairs(appContainer:GetChildren()) do
            if child:IsA("Frame") or child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        appContainer.Visible = false
        homeScreen.Visible = true
        activeAppName = nil
        screenGui:SetAttribute("ActiveApp", "Home")

        if pagesContainer and pageLayout then
            local p1 = pagesContainer:FindFirstChild("Page1")
            if p1 then pageLayout:JumpTo(p1) end
        end
        print("[SkyPhone] Returned to Springboard Home")
    end

    -- Toggle Open / Close
    local function togglePhone()
        isOpen = not isOpen
        playTone(isOpen and 1.8 or 1.2)
        screenGui:SetAttribute("IsOpen", isOpen)

        local targetPos = isOpen and OPEN_POS or CLOSED_POS
        
        if isOpen then
            chassis.Visible = true
                    end

        local twChassis = TweenService:Create(
            chassis,
            isOpen and TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                   or TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = targetPos}
        )
        twChassis:Play()



        if not isOpen then
            task.delay(0.36, function()
                if not isOpen then
                    chassis.Visible = false
                end
            end)
        end
    end

    -- Wire HUD Floating Button
    if toggleBtn then
        toggleBtn.MouseButton1Click:Connect(togglePhone)
    end

    -- Wire IsOpen ScreenGui Attribute
    screenGui:GetAttributeChangedSignal("IsOpen"):Connect(function()
        local req = screenGui:GetAttribute("IsOpen")
        if req == true and not isOpen then
            togglePhone()
        elseif req == false and isOpen then
            togglePhone()
        end
    end)

    -- Wire Keyboard Shortcut 'P'
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.P then
            togglePhone()
        end
    end)

    -- Wire Home Indicator to Go Home
    if homeIndicator then
        local hiHitBox = homeIndicator:FindFirstChild("HitBox") :: TextButton?
        if hiHitBox then
            hiHitBox.MouseButton1Click:Connect(goHome)
        end
    end

    -- Wire Page Dots Navigation
    if dotsContainer and pageLayout and pagesContainer then
        for _, dot in ipairs(dotsContainer:GetChildren()) do
            if dot:IsA("TextButton") and string.find(dot.Name, "^Dot_") then
                local pageNumStr = string.match(dot.Name, "%d+")
                if pageNumStr then
                    local targetPage = pagesContainer:FindFirstChild("Page" .. pageNumStr)
                    if targetPage then
                        dot.MouseButton1Click:Connect(function()
                            playTone(2.0)
                            pageLayout:JumpTo(targetPage)
                        end)
                    end
                end
            end
        end
    end

    -- Wire Replicated Attributes for Automated Testing and Studio API
    screenGui:SetAttribute("IsOpen", isOpen)
    screenGui:SetAttribute("CurrentTheme", currentTheme)
    screenGui:SetAttribute("ActiveApp", "Home")

    screenGui:GetAttributeChangedSignal("TargetApp"):Connect(function()
        local target = screenGui:GetAttribute("TargetApp")
        if target and typeof(target) == "string" and #target > 0 then
            if target == "Home" then
                goHome()
            else
                openApp(target)
            end
        end
    end)

    screenGui:GetAttributeChangedSignal("CurrentTheme"):Connect(function()
        local th = screenGui:GetAttribute("CurrentTheme")
        if th and typeof(th) == "string" then
            setTheme(th)
        end
    end)

    screenGui:GetAttributeChangedSignal("IsOpen"):Connect(function()
        local desired = screenGui:GetAttribute("IsOpen")
        if typeof(desired) == "boolean" and desired ~= isOpen then
            togglePhone()
        end
    end)

    local showBanner = config.showBanner or function(title: string, message: string, iconId: string?, customTime: string?) end
    local setAirplaneMode = config.setAirplaneMode or function(enabled: boolean) end
    local updateMusicWidget = config.updateMusicWidget or function(track: any) end

    -- Attribute listeners for remote automation/testing
    screenGui:GetAttributeChangedSignal("AirplaneMode"):Connect(function()
        local enabled = screenGui:GetAttribute("AirplaneMode")
        if typeof(enabled) == "boolean" then
            setAirplaneMode(enabled)
        end
    end)

    -- Global registry for client scripts
    _G.SkyPhone = {
        Open = openApp,
        Home = goHome,
        Toggle = togglePhone,
        SetTheme = setTheme,
        ShowNotification = showNotification,
        ShowBanner = showBanner,
        SetAirplaneMode = setAirplaneMode,
        UpdateMusicWidget = updateMusicWidget,
    }

    return {
        openApp = openApp,
        goHome = goHome,
        togglePhone = togglePhone,
        setTheme = setTheme,
        showNotification = showNotification,
        showBanner = showBanner,
        setAirplaneMode = setAirplaneMode,
        updateMusicWidget = updateMusicWidget,
    }
end

return Router
