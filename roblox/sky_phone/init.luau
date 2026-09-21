--!strict
-- src/sky_phone/init.luau
-- Master Pure Luau Coordinator for Sky Phone
-- Constructs 100% of the phone hierarchy dynamically at runtime (Zero pre-baked GUI)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SkyPhone = {}

function SkyPhone.build(screenGui: ScreenGui)
    print("[SkyPhone] Starting 100% pure Luau dynamic construction...")

    -- 1. Determine environment
    local isPlayMode = RunService:IsClient() and (Players.LocalPlayer ~= nil)

    -- 2. Clear ANY existing GUI elements to enforce pure Luau law (Zero pre-baked GUI)
    for _, child in ipairs(screenGui:GetChildren()) do
        if not child:IsA("LocalScript") and not child:IsA("Folder") and not child:IsA("ModuleScript") then
            child:Destroy()
        end
    end

    -- 3. Resolve Modules Folder
    local modulesFolder = screenGui:FindFirstChild("Modules")
    if not modulesFolder then
        local starter = game:GetService("StarterGui"):FindFirstChild("SkyPhone_Emulator")
        if starter then
            modulesFolder = starter:FindFirstChild("Modules")
        end
    end

    local ChassisModule = modulesFolder and modulesFolder:FindFirstChild("Chassis")
    local SpringboardModule = modulesFolder and modulesFolder:FindFirstChild("Springboard")
    local AppSuiteCoreModule = modulesFolder and modulesFolder:FindFirstChild("AppSuite_Core")
    local AppSuiteToolsModule = modulesFolder and modulesFolder:FindFirstChild("AppSuite_Tools")
    local AppSuiteFinGameModule = modulesFolder and modulesFolder:FindFirstChild("AppSuite_Finance_Gaming")
    local AppSuiteEcoModule = modulesFolder and modulesFolder:FindFirstChild("AppSuite_Ecosystem")
    local BottomSheetModule = modulesFolder and modulesFolder:FindFirstChild("BottomSheet")
    local RouterModule = modulesFolder and modulesFolder:FindFirstChild("Router")

    local Chassis = ChassisModule and require(ChassisModule) or nil
    local Springboard = SpringboardModule and require(SpringboardModule) or nil
    local AppSuite_Core = AppSuiteCoreModule and require(AppSuiteCoreModule) or nil
    local AppSuite_Tools = AppSuiteToolsModule and require(AppSuiteToolsModule) or nil
    local AppSuite_Finance_Gaming = AppSuiteFinGameModule and require(AppSuiteFinGameModule) or nil
    local AppSuite_Ecosystem = AppSuiteEcoModule and require(AppSuiteEcoModule) or nil
    local BottomSheet = BottomSheetModule and require(BottomSheetModule) or nil
    local Router = RouterModule and require(RouterModule) or nil

    if not Chassis or not Springboard or not Router then
        error("[SkyPhone] Critical failure: Required Luau modules missing from Modules folder!")
    end

    -- 4. Build Hardware Chassis & Screen Frame
    local cResult = Chassis.build(screenGui, isPlayMode)
    local chassis = cResult.chassis
    local toggleBtn = cResult.toggleBtn
    local screen = cResult.screen
    local appContainer = cResult.appContainer
    local island = cResult.island
    local statusBar = cResult.statusBar
    local homeIndicator = cResult.homeIndicator
    local showBanner = cResult.showBanner
    local setAirplaneMode = cResult.setAirplaneMode

    -- 5. Prepare Context for App Suites & Springboard
    local routerRef: any = nil
    local sResult: any = nil

    local ctx = {
        showNotification = function(title: string, msg: string)
            if routerRef and routerRef.showNotification then
                routerRef.showNotification(title, msg)
            end
        end,
        showBanner = function(title: string, msg: string, iconId: string?, customTime: string?)
            if showBanner then
                showBanner(title, msg, iconId, customTime)
            elseif routerRef and routerRef.showNotification then
                routerRef.showNotification(title, msg)
            end
        end,
        setAirplaneMode = function(enabled: boolean)
            if setAirplaneMode then
                setAirplaneMode(enabled)
            end
        end,
        updateMusicWidget = function(track: any)
            if sResult and sResult.updateMusicWidget then
                sResult.updateMusicWidget(track)
            end
        end,
        openApp = function(name: string)
            if routerRef and routerRef.openApp then
                routerRef.openApp(name)
            end
        end,
        goHome = function()
            if routerRef and routerRef.goHome then
                routerRef.goHome()
            end
        end,
        BottomSheet = BottomSheet,
    }

    -- 6. Build Springboard Home Screen
    local openAppCb = function(appName: string)
        if routerRef and routerRef.openApp then
            routerRef.openApp(appName)
        end
    end
    sResult = Springboard.build(screen, openAppCb)
    local homeScreen = sResult.homeScreen
    local pagesContainer = sResult.pagesContainer
    local pageLayout = sResult.pageLayout
    local dotsContainer = sResult.dotsContainer
    local dock = sResult.dock

    -- 7. Build All Functional App Suites
    if AppSuite_Core then
        local ok, err = pcall(function() AppSuite_Core.build(appContainer, ctx) end)
        if not ok then warn("[SkyPhone] AppSuite_Core build failed:", err) end
    end
    if AppSuite_Tools then
        local ok, err = pcall(function() AppSuite_Tools.build(appContainer, ctx) end)
        if not ok then warn("[SkyPhone] AppSuite_Tools build failed:", err) end
    end
    if AppSuite_Finance_Gaming then
        local ok, err = pcall(function() AppSuite_Finance_Gaming.build(appContainer, ctx) end)
        if not ok then warn("[SkyPhone] AppSuite_Finance_Gaming build failed:", err) end
    end
    if AppSuite_Ecosystem then
        local ok, err = pcall(function() AppSuite_Ecosystem.build(appContainer, ctx) end)
        if not ok then warn("[SkyPhone] AppSuite_Ecosystem build failed:", err) end
    end

    -- 8. Build Router, Navigation & Interaction System
    routerRef = Router.build({
        screenGui = screenGui,
        chassis = chassis,
        toggleBtn = toggleBtn,
        screen = screen,
        appContainer = appContainer,
        homeScreen = homeScreen,
        pagesContainer = pagesContainer,
        pageLayout = pageLayout,
        dotsContainer = dotsContainer,
        dock = dock,
        island = island,
        statusBar = statusBar,
        homeIndicator = homeIndicator,
        isPlayMode = isPlayMode,
        showBanner = showBanner,
        setAirplaneMode = setAirplaneMode,
        updateMusicWidget = sResult.updateMusicWidget,
    })

    print(string.format("[*] Pure Luau Sky Phone Built Successfully! Mounted %d Apps in AppContainer.", #appContainer:GetChildren()))
    return routerRef
end

return SkyPhone
