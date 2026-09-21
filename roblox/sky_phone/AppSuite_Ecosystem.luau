--!strict
-- src/sky_phone/AppSuite_Ecosystem.luau
-- Pure Luau Component: Photos (Multi-Select & Share Sheet), EasyShare (AirDrop Radar),
-- Billing (Disputed Invoices), Voice Memos, Contacts, Mail & Complete 32-App Ecosystem
-- Ground-truth port matching NVIDIA ShadowPlay video evaluation (00:16 - 07:39)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local AppSuite_Ecosystem = {}

local function createBaseApp(appContainer: Frame, name: string, bgColor: Color3)
    local old = appContainer:FindFirstChild(name .. "App")
    if old then old:Destroy() end

    local app = Instance.new("Frame", appContainer)
    app.Name = name .. "App"
    app.Size = UDim2.new(1, 0, 1, 0)
    app.BackgroundColor3 = bgColor
    app.BorderSizePixel = 0
    app.Visible = false
    app.ZIndex = 16
    app.ClipsDescendants = true
    Instance.new("UICorner", app).CornerRadius = UDim.new(0.136, 0)
    return app
end

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

function AppSuite_Ecosystem.build(appContainer: Frame, ctx: any)
    local showNotification = ctx and ctx.showNotification or function(title: string, msg: string) end
    local showBanner = ctx and ctx.showBanner or function(title: string, msg: string, icon: string?, t: string?) end
    local openApp = ctx and ctx.openApp or function(name: string) end
    local BottomSheet = ctx and ctx.BottomSheet

    -- =========================================================================
    -- 1. PHOTOS APP (Multi-Select 1..5 Badges, Import Sheet & iOS Share Sheet)
    -- Video Ground Truth (00:27 - 00:50)
    -- =========================================================================
    local photosApp = createBaseApp(appContainer, "Photos", Color3.fromRGB(10, 12, 18))
    do
        local isSelectMode = false
        local selectedItems = {} -- indices

        -- Top Nav Header
        local pHeader = Instance.new("Frame", photosApp)
        pHeader.Size = UDim2.new(1, 0, 0, 75)
        pHeader.Position = UDim2.new(0, 0, 0, 36)
        pHeader.BackgroundTransparency = 1
        pHeader.ZIndex = 17

        local pTitle = Instance.new("TextLabel", pHeader)
        pTitle.Size = UDim2.new(0.4, 0, 0, 32)
        pTitle.Position = UDim2.new(0, 20, 0, 24)
        pTitle.Text = "Photos"
        pTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        pTitle.Font = Enum.Font.GothamBold
        pTitle.TextSize = 28
        pTitle.TextXAlignment = Enum.TextXAlignment.Left
        pTitle.BackgroundTransparency = 1
        pTitle.ZIndex = 18

        -- Import Button (Video 00:27)
        local importBtn = Instance.new("TextButton", pHeader)
        importBtn.Size = UDim2.new(0, 68, 0, 32)
        importBtn.Position = UDim2.new(1, -164, 0, 24)
        importBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 40)
        importBtn.Text = "Import"
        importBtn.TextColor3 = Color3.fromRGB(10, 132, 255)
        importBtn.Font = Enum.Font.GothamBold
        importBtn.TextSize = 13
        importBtn.BorderSizePixel = 0
        importBtn.ZIndex = 19
        Instance.new("UICorner", importBtn).CornerRadius = UDim.new(0, 8)

        -- Select / Cancel Toggle (Video 00:31)
        local selectBtn = Instance.new("TextButton", pHeader)
        selectBtn.Size = UDim2.new(0, 68, 0, 32)
        selectBtn.Position = UDim2.new(1, -88, 0, 24)
        selectBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 40)
        selectBtn.Text = "Select"
        selectBtn.TextColor3 = Color3.fromRGB(10, 132, 255)
        selectBtn.Font = Enum.Font.GothamBold
        selectBtn.TextSize = 13
        selectBtn.BorderSizePixel = 0
        selectBtn.ZIndex = 19
        Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 8)

        -- Photo Grid Container
        local gridScroll = Instance.new("ScrollingFrame", photosApp)
        gridScroll.Size = UDim2.new(1, -24, 1, -180)
        gridScroll.Position = UDim2.new(0, 12, 0, 115)
        gridScroll.BackgroundTransparency = 1
        gridScroll.ScrollBarThickness = 0
        gridScroll.ZIndex = 17
        local pGrid = Instance.new("UIGridLayout", gridScroll)
        pGrid.CellSize = UDim2.new(0.31, 0, 0, 96)
        pGrid.CellPadding = UDim2.new(0.035, 0, 0, 10)

        local photoAssets = {
            "rbxassetid://134300653681700",
            "rbxassetid://103043499972901",
            "rbxassetid://13854583196",
            "rbxassetid://70546187772415",
            "rbxassetid://139358287735244",
            "rbxassetid://113219823990413",
            "rbxassetid://75815873536189",
            "rbxassetid://120691943073443",
            "rbxassetid://95951474710933",
        }

        local photoCards = {}

        -- Bottom Action Bar for Share Sheet (Appears when 1 or more items selected)
        local bottomBar = Instance.new("Frame", photosApp)
        bottomBar.Size = UDim2.new(1, -24, 0, 56)
        bottomBar.Position = UDim2.new(0, 12, 1, -74)
        bottomBar.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
        bottomBar.BorderSizePixel = 0
        bottomBar.Visible = false
        bottomBar.ZIndex = 25
        Instance.new("UICorner", bottomBar).CornerRadius = UDim.new(0, 16)
        local bbStroke = Instance.new("UIStroke", bottomBar)
        bbStroke.Color = Color3.fromRGB(255, 255, 255)
        bbStroke.Transparency = 0.9

        local selCountLbl = Instance.new("TextLabel", bottomBar)
        selCountLbl.Size = UDim2.new(0.5, 0, 1, 0)
        selCountLbl.Position = UDim2.new(0, 16, 0, 0)
        selCountLbl.Text = "0 Selected"
        selCountLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        selCountLbl.Font = Enum.Font.GothamMedium
        selCountLbl.TextSize = 13
        selCountLbl.TextXAlignment = Enum.TextXAlignment.Left
        selCountLbl.BackgroundTransparency = 1
        selCountLbl.ZIndex = 26

        local shareBtn = Instance.new("TextButton", bottomBar)
        shareBtn.Size = UDim2.new(0, 80, 0, 36)
        shareBtn.Position = UDim2.new(1, -96, 0, 10)
        shareBtn.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
        shareBtn.Text = "Share ⎋"
        shareBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        shareBtn.Font = Enum.Font.GothamBold
        shareBtn.TextSize = 13
        shareBtn.BorderSizePixel = 0
        shareBtn.ZIndex = 26
        Instance.new("UICorner", shareBtn).CornerRadius = UDim.new(0, 10)

        local function updateSelectionDisplay()
            local count = #selectedItems
            selCountLbl.Text = tostring(count) .. " Photos Selected"
            bottomBar.Visible = isSelectMode and (count > 0)

            for idx, card in ipairs(photoCards) do
                local badge = card:FindFirstChild("Badge") :: Frame?
                local numLbl = badge and badge:FindFirstChild("Num") :: TextLabel?
                local selPos = table.find(selectedItems, idx)
                if badge and numLbl then
                    if selPos then
                        badge.Visible = true
                        badge.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
                        numLbl.Text = tostring(selPos)
                    elseif isSelectMode then
                        badge.Visible = true
                        badge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        numLbl.Text = ""
                    else
                        badge.Visible = false
                    end
                end
            end
        end

        selectBtn.MouseButton1Click:Connect(function()
            playTone(1.8)
            isSelectMode = not isSelectMode
            selectBtn.Text = isSelectMode and "Cancel" or "Select"
            if not isSelectMode then
                selectedItems = {}
            end
            updateSelectionDisplay()
        end)

        -- Build Photo Thumbnails
        for idx, assetId in ipairs(photoAssets) do
            local card = Instance.new("TextButton", gridScroll)
            card.Name = "Photo_" .. idx
            card.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
            card.BorderSizePixel = 0
            card.Text = ""
            card.AutoButtonColor = false
            card.ZIndex = 18
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

            local img = Instance.new("ImageLabel", card)
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
            img.Image = assetId
            img.ScaleType = Enum.ScaleType.Crop
            img.ZIndex = 19
            Instance.new("UICorner", img).CornerRadius = UDim.new(0, 12)

            -- Selection Circular Badge (Numbered 1..5)
            local badge = Instance.new("Frame", card)
            badge.Name = "Badge"
            badge.Size = UDim2.new(0, 24, 0, 24)
            badge.Position = UDim2.new(1, -28, 0, 6)
            badge.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            badge.BackgroundTransparency = 0.3
            badge.BorderSizePixel = 0
            badge.Visible = false
            badge.ZIndex = 21
            Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
            local bStroke = Instance.new("UIStroke", badge)
            bStroke.Color = Color3.fromRGB(255, 255, 255)
            bStroke.Thickness = 1.5

            local numLbl = Instance.new("TextLabel", badge)
            numLbl.Name = "Num"
            numLbl.Size = UDim2.new(1, 0, 1, 0)
            numLbl.BackgroundTransparency = 1
            numLbl.Text = ""
            numLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            numLbl.Font = Enum.Font.GothamBold
            numLbl.TextSize = 12
            numLbl.ZIndex = 22

            card.MouseButton1Click:Connect(function()
                playTone(2.2)
                if isSelectMode then
                    local existing = table.find(selectedItems, idx)
                    if existing then
                        table.remove(selectedItems, existing)
                    else
                        if #selectedItems < 5 then
                            table.insert(selectedItems, idx)
                        end
                    end
                    updateSelectionDisplay()
                else
                    showBanner("Photos", "Viewing item " .. idx .. " in high-res.", assetId, "03:48")
                end
            end)

            table.insert(photoCards, card)
        end

        -- Import Sheet (Video 00:27): Media Archive vs Event CDN
        importBtn.MouseButton1Click:Connect(function()
            playTone(2.0)
            if not BottomSheet then return end
            local sheet = BottomSheet.create(photosApp, { height = 230, showHandle = true })
            local parent = sheet.contentFrame

            local iTitle = Instance.new("TextLabel", parent)
            iTitle.Size = UDim2.new(1, -40, 0, 24)
            iTitle.Position = UDim2.new(0, 20, 0, 6)
            iTitle.Text = "Import Photos"
            iTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            iTitle.Font = Enum.Font.GothamBold
            iTitle.TextSize = 18
            iTitle.TextXAlignment = Enum.TextXAlignment.Left
            iTitle.BackgroundTransparency = 1
            iTitle.ZIndex = 84

            local function makeImportOption(yPos: number, icon: string, name: string, desc: string)
                local opt = Instance.new("TextButton", parent)
                opt.Size = UDim2.new(1, -40, 0, 56)
                opt.Position = UDim2.new(0, 20, 0, yPos)
                opt.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
                opt.Text = ""
                opt.BorderSizePixel = 0
                opt.ZIndex = 85
                Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 12)

                local icn = Instance.new("TextLabel", opt)
                icn.Size = UDim2.new(0, 40, 1, 0)
                icn.Position = UDim2.new(0, 8, 0, 0)
                icn.Text = icon
                icn.TextSize = 22
                icn.BackgroundTransparency = 1
                icn.ZIndex = 86

                local n = Instance.new("TextLabel", opt)
                n.Size = UDim2.new(1, -60, 0, 20)
                n.Position = UDim2.new(0, 52, 0, 8)
                n.Text = name
                n.TextColor3 = Color3.fromRGB(255, 255, 255)
                n.Font = Enum.Font.GothamBold
                n.TextSize = 13.5
                n.TextXAlignment = Enum.TextXAlignment.Left
                n.BackgroundTransparency = 1
                n.ZIndex = 86

                local d = Instance.new("TextLabel", opt)
                d.Size = UDim2.new(1, -60, 0, 16)
                d.Position = UDim2.new(0, 52, 0, 28)
                d.Text = desc
                d.TextColor3 = Color3.fromRGB(142, 142, 147)
                d.Font = Enum.Font.Gotham
                d.TextSize = 11.5
                d.TextXAlignment = Enum.TextXAlignment.Left
                d.BackgroundTransparency = 1
                d.ZIndex = 86

                opt.MouseButton1Click:Connect(function()
                    playTone(2.4)
                    sheet.close()
                    showBanner("Photos", "Imported 4 new photos from " .. name, "rbxassetid://134300653681700", "03:48")
                end)
            end

            makeImportOption(42, "📁", "Media Archive", "Import from local captures and device cache")
            makeImportOption(108, "☁️", "Event CDN", "Synchronize album with Los Santos cloud stream")
        end)

        -- Authentic iOS Share Sheet (Video 00:36 - 00:50)
        shareBtn.MouseButton1Click:Connect(function()
            playTone(2.0)
            if not BottomSheet then return end
            local sheet = BottomSheet.create(photosApp, { height = 340, showHandle = true })
            local parent = sheet.contentFrame

            local sTitle = Instance.new("TextLabel", parent)
            sTitle.Size = UDim2.new(1, -40, 0, 22)
            sTitle.Position = UDim2.new(0, 20, 0, 6)
            sTitle.Text = string.format("%d Photos Selected", #selectedItems)
            sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sTitle.Font = Enum.Font.GothamBold
            sTitle.TextSize = 18
            sTitle.TextXAlignment = Enum.TextXAlignment.Left
            sTitle.BackgroundTransparency = 1
            sTitle.ZIndex = 84

            -- Row 1: AirDrop Contacts (GC, HB, IP, KA - Video 00:36)
            local airDropRow = Instance.new("Frame", parent)
            airDropRow.Size = UDim2.new(1, -20, 0, 84)
            airDropRow.Position = UDim2.new(0, 10, 0, 36)
            airDropRow.BackgroundTransparency = 1
            airDropRow.ZIndex = 84
            local al = Instance.new("UIListLayout", airDropRow)
            al.FillDirection = Enum.FillDirection.Horizontal
            al.Padding = UDim.new(0, 12)

            local airdropUsers = {
                {initials = "GC", name = "Gray Carter", color = Color3.fromRGB(10, 132, 255)},
                {initials = "HB", name = "Harper Brooks", color = Color3.fromRGB(175, 82, 222)},
                {initials = "IP", name = "Isaac Price", color = Color3.fromRGB(52, 199, 89)},
                {initials = "KA", name = "Kira Adams", color = Color3.fromRGB(255, 149, 0)},
            }

            for _, u in ipairs(airdropUsers) do
                local uBtn = Instance.new("TextButton", airDropRow)
                uBtn.Size = UDim2.new(0, 64, 0, 78)
                uBtn.BackgroundTransparency = 1
                uBtn.Text = ""
                uBtn.ZIndex = 85

                local av = Instance.new("Frame", uBtn)
                av.Size = UDim2.new(0, 48, 0, 48)
                av.Position = UDim2.new(0.5, -24, 0, 4)
                av.BackgroundColor3 = u.color
                av.BorderSizePixel = 0
                av.ZIndex = 86
                Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

                local inLbl = Instance.new("TextLabel", av)
                inLbl.Size = UDim2.new(1, 0, 1, 0)
                inLbl.Text = u.initials
                inLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                inLbl.Font = Enum.Font.GothamBold
                inLbl.TextSize = 16
                inLbl.BackgroundTransparency = 1
                inLbl.ZIndex = 87

                local nameLbl = Instance.new("TextLabel", uBtn)
                nameLbl.Size = UDim2.new(1, 0, 0, 16)
                nameLbl.Position = UDim2.new(0, 0, 0, 56)
                nameLbl.Text = string.split(u.name, " ")[1]
                nameLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
                nameLbl.Font = Enum.Font.GothamMedium
                nameLbl.TextSize = 11.5
                nameLbl.BackgroundTransparency = 1
                nameLbl.ZIndex = 86

                uBtn.MouseButton1Click:Connect(function()
                    playTone(2.4)
                    sheet.close()
                    showBanner("EasyShare", string.format("Sent %d photos to %s", #selectedItems, u.name), "rbxassetid://134300653681700", "03:49")
                end)
            end

            -- Row 2: App Action Row (EasyShare, Messages, DarkChat, Flare)
            local appRow = Instance.new("Frame", parent)
            appRow.Size = UDim2.new(1, -20, 0, 84)
            appRow.Position = UDim2.new(0, 10, 0, 126)
            appRow.BackgroundTransparency = 1
            appRow.ZIndex = 84
            local apl = Instance.new("UIListLayout", appRow)
            apl.FillDirection = Enum.FillDirection.Horizontal
            apl.Padding = UDim.new(0, 12)

            local shareApps = {
                {name = "EasyShare", icon = "📡", color = Color3.fromRGB(10, 132, 255), app = "EasyShare"},
                {name = "Messages", icon = "💬", color = Color3.fromRGB(52, 199, 89), app = "Messages"},
                {name = "DarkChat", icon = "🕶️", color = Color3.fromRGB(20, 22, 30), app = "DarkChat"},
                {name = "Flare", icon = "🔥", color = Color3.fromRGB(255, 69, 58), app = "Flare"},
            }

            for _, sa in ipairs(shareApps) do
                local aBtn = Instance.new("TextButton", appRow)
                aBtn.Size = UDim2.new(0, 64, 0, 78)
                aBtn.BackgroundTransparency = 1
                aBtn.Text = ""
                aBtn.ZIndex = 85

                local aBox = Instance.new("Frame", aBtn)
                aBox.Size = UDim2.new(0, 48, 0, 48)
                aBox.Position = UDim2.new(0.5, -24, 0, 4)
                aBox.BackgroundColor3 = sa.color
                aBox.BorderSizePixel = 0
                aBox.ZIndex = 86
                Instance.new("UICorner", aBox).CornerRadius = UDim.new(0, 13)

                local aIcn = Instance.new("TextLabel", aBox)
                aIcn.Size = UDim2.new(1, 0, 1, 0)
                aIcn.Text = sa.icon
                aIcn.TextSize = 22
                aIcn.BackgroundTransparency = 1
                aIcn.ZIndex = 87

                local aLbl = Instance.new("TextLabel", aBtn)
                aLbl.Size = UDim2.new(1, 0, 0, 16)
                aLbl.Position = UDim2.new(0, 0, 0, 56)
                aLbl.Text = sa.name
                aLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
                aLbl.Font = Enum.Font.GothamMedium
                aLbl.TextSize = 11.5
                aLbl.BackgroundTransparency = 1
                aLbl.ZIndex = 86

                aBtn.MouseButton1Click:Connect(function()
                    playTone(2.0)
                    sheet.close()
                    openApp(sa.app)
                end)
            end

            -- Cancel button at bottom of sheet
            local cBtn = Instance.new("TextButton", parent)
            cBtn.Size = UDim2.new(1, -40, 0, 44)
            cBtn.Position = UDim2.new(0, 20, 1, -54)
            cBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
            cBtn.Text = "Cancel"
            cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            cBtn.Font = Enum.Font.GothamBold
            cBtn.TextSize = 14
            cBtn.BorderSizePixel = 0
            cBtn.ZIndex = 85
            Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 12)
            cBtn.MouseButton1Click:Connect(sheet.close)
        end)
    end

    -- =========================================================================
    -- 2. EASYSHARE (AirDrop Proximity Radar Sheet)
    -- Video Ground Truth (04:28 - 04:44): Mia Santos 2.4m, Noah Walker 7.8m
    -- =========================================================================
    local easyShareApp = createBaseApp(appContainer, "EasyShare", Color3.fromRGB(12, 14, 22))
    do
        local eHeader = Instance.new("Frame", easyShareApp)
        eHeader.Size = UDim2.new(1, 0, 0, 75)
        eHeader.Position = UDim2.new(0, 0, 0, 36)
        eHeader.BackgroundTransparency = 1
        eHeader.ZIndex = 17

        local eTitle = Instance.new("TextLabel", eHeader)
        eTitle.Size = UDim2.new(1, -40, 0, 32)
        eTitle.Position = UDim2.new(0, 20, 0, 24)
        eTitle.Text = "EasyShare"
        eTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        eTitle.Font = Enum.Font.GothamBold
        eTitle.TextSize = 28
        eTitle.TextXAlignment = Enum.TextXAlignment.Left
        eTitle.BackgroundTransparency = 1
        eTitle.ZIndex = 18

        -- Concentric Radar Animation Frame
        local radarBox = Instance.new("Frame", easyShareApp)
        radarBox.Size = UDim2.new(0, 180, 0, 180)
        radarBox.Position = UDim2.new(0.5, -90, 0, 115)
        radarBox.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
        radarBox.BorderSizePixel = 0
        radarBox.ZIndex = 18
        Instance.new("UICorner", radarBox).CornerRadius = UDim.new(1, 0)
        local rs = Instance.new("UIStroke", radarBox)
        rs.Color = Color3.fromRGB(10, 132, 255)
        rs.Transparency = 0.6

        local rRing1 = Instance.new("Frame", radarBox)
        rRing1.Size = UDim2.new(0.65, 0, 0.65, 0)
        rRing1.Position = UDim2.new(0.175, 0, 0.175, 0)
        rRing1.BackgroundTransparency = 1
        rRing1.ZIndex = 19
        Instance.new("UICorner", rRing1).CornerRadius = UDim.new(1, 0)
        local rr1Stroke = Instance.new("UIStroke", rRing1)
        rr1Stroke.Color = Color3.fromRGB(10, 132, 255)
        rr1Stroke.Transparency = 0.75

        local rCenter = Instance.new("TextLabel", radarBox)
        rCenter.Size = UDim2.new(0, 48, 0, 48)
        rCenter.Position = UDim2.new(0.5, -24, 0.5, -24)
        rCenter.Text = "📡"
        rCenter.TextSize = 28
        rCenter.BackgroundTransparency = 1
        rCenter.ZIndex = 20

        local radarSub = Instance.new("TextLabel", easyShareApp)
        radarSub.Size = UDim2.new(1, -40, 0, 20)
        radarSub.Position = UDim2.new(0, 20, 0, 305)
        radarSub.Text = "Scanning nearby Los Santos devices..."
        radarSub.TextColor3 = Color3.fromRGB(142, 142, 147)
        radarSub.Font = Enum.Font.GothamMedium
        radarSub.TextSize = 12.5
        radarSub.BackgroundTransparency = 1
        radarSub.ZIndex = 18

        -- Nearby Players List (Ground Truth: Mia Santos 2.4m, Noah Walker 7.8m, Jamie Rivera 14.6m)
        local dScroll = Instance.new("ScrollingFrame", easyShareApp)
        dScroll.Size = UDim2.new(1, -36, 1, -345)
        dScroll.Position = UDim2.new(0, 18, 0, 335)
        dScroll.BackgroundTransparency = 1
        dScroll.ScrollBarThickness = 0
        dScroll.ZIndex = 18
        local dl = Instance.new("UIListLayout", dScroll)
        dl.Padding = UDim.new(0, 10)

        local devices = {
            {name = "Mia Santos", distance = "2.4 m", icon = "iPhone 15 Pro", initial = "MS"},
            {name = "Noah Walker", distance = "7.8 m", icon = "SkyPhone Max", initial = "NW"},
            {name = "Jamie Rivera", distance = "14.6 m", icon = "MacBook Air", initial = "JR"},
        }

        for _, dev in ipairs(devices) do
            local row = Instance.new("Frame", dScroll)
            row.Size = UDim2.new(1, 0, 0, 60)
            row.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
            row.BorderSizePixel = 0
            row.ZIndex = 19
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 14)
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Color3.fromRGB(255, 255, 255)
            rowStroke.Transparency = 0.92

            local av = Instance.new("Frame", row)
            av.Size = UDim2.new(0, 42, 0, 42)
            av.Position = UDim2.new(0, 10, 0, 9)
            av.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
            av.BorderSizePixel = 0
            av.ZIndex = 20
            Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

            local avTxt = Instance.new("TextLabel", av)
            avTxt.Size = UDim2.new(1, 0, 1, 0)
            avTxt.Text = dev.initial
            avTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
            avTxt.Font = Enum.Font.GothamBold
            avTxt.TextSize = 14
            avTxt.BackgroundTransparency = 1
            avTxt.ZIndex = 21

            local nLbl = Instance.new("TextLabel", row)
            nLbl.Size = UDim2.new(0.5, 0, 0, 18)
            nLbl.Position = UDim2.new(0, 62, 0, 12)
            nLbl.Text = dev.name
            nLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nLbl.Font = Enum.Font.GothamBold
            nLbl.TextSize = 14
            nLbl.TextXAlignment = Enum.TextXAlignment.Left
            nLbl.BackgroundTransparency = 1
            nLbl.ZIndex = 20

            local distLbl = Instance.new("TextLabel", row)
            distLbl.Size = UDim2.new(0.5, 0, 0, 14)
            distLbl.Position = UDim2.new(0, 62, 0, 32)
            distLbl.Text = dev.distance .. " · " .. dev.icon
            distLbl.TextColor3 = Color3.fromRGB(52, 199, 89)
            distLbl.Font = Enum.Font.Gotham
            distLbl.TextSize = 11.5
            distLbl.TextXAlignment = Enum.TextXAlignment.Left
            distLbl.BackgroundTransparency = 1
            distLbl.ZIndex = 20

            local sendBtn = Instance.new("TextButton", row)
            sendBtn.Size = UDim2.new(0, 74, 0, 32)
            sendBtn.Position = UDim2.new(1, -84, 0, 14)
            sendBtn.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
            sendBtn.Text = "Share"
            sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            sendBtn.Font = Enum.Font.GothamBold
            sendBtn.TextSize = 12
            sendBtn.BorderSizePixel = 0
            sendBtn.ZIndex = 20
            Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 10)

            sendBtn.MouseButton1Click:Connect(function()
                playTone(2.4)
                sendBtn.Text = "Waiting..."
                sendBtn.BackgroundColor3 = Color3.fromRGB(255, 149, 0)
                task.delay(2.2, function()
                    playTone(2.8)
                    sendBtn.Text = "Accepted ✓"
                    sendBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
                    showBanner("EasyShare", dev.name .. " accepted the shared file.", "rbxassetid://134300653681700", "03:50")
                end)
            end)
        end
    end

    -- =========================================================================
    -- 3. BILLING APP (Disputed Invoices, Benny's Motor Works UUID #1098D704)
    -- Video Ground Truth (06:09 - 06:48): $999 invoice, dispute banner
    -- =========================================================================
    local billingApp = createBaseApp(appContainer, "Billing", Color3.fromRGB(12, 14, 22))
    do
        local bScroll = Instance.new("ScrollingFrame", billingApp)
        bScroll.Size = UDim2.new(1, 0, 1, 0)
        bScroll.BackgroundTransparency = 1
        bScroll.ScrollBarThickness = 0
        bScroll.ZIndex = 17
        bScroll.CanvasSize = UDim2.new(0, 0, 0, 680)

        local bHeader = Instance.new("Frame", bScroll)
        bHeader.Size = UDim2.new(1, 0, 0, 75)
        bHeader.Position = UDim2.new(0, 0, 0, 36)
        bHeader.BackgroundTransparency = 1
        bHeader.ZIndex = 18

        local bTitle = Instance.new("TextLabel", bHeader)
        bTitle.Size = UDim2.new(1, -40, 0, 32)
        bTitle.Position = UDim2.new(0, 20, 0, 24)
        bTitle.Text = "Billing & Invoices"
        bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        bTitle.Font = Enum.Font.GothamBold
        bTitle.TextSize = 28
        bTitle.TextXAlignment = Enum.TextXAlignment.Left
        bTitle.BackgroundTransparency = 1
        bTitle.ZIndex = 19

        -- Filter Tabs: All, Pending, Disputed
        local tabRow = Instance.new("Frame", bScroll)
        tabRow.Size = UDim2.new(1, -36, 0, 34)
        tabRow.Position = UDim2.new(0, 18, 0, 106)
        tabRow.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
        tabRow.BorderSizePixel = 0
        tabRow.ZIndex = 18
        Instance.new("UICorner", tabRow).CornerRadius = UDim.new(0, 10)

        local tabs = {"All", "Pending", "Disputed"}
        for i, t in ipairs(tabs) do
            local tb = Instance.new("TextButton", tabRow)
            tb.Size = UDim2.new(0.333, 0, 1, 0)
            tb.Position = UDim2.new((i - 1) * 0.333, 0, 0, 0)
            tb.BackgroundTransparency = (i == 3) and 0 or 1
            tb.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
            tb.Text = t
            tb.TextColor3 = Color3.fromRGB(255, 255, 255)
            tb.Font = Enum.Font.GothamBold
            tb.TextSize = 12
            tb.BorderSizePixel = 0
            tb.ZIndex = 19
            Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
        end

        -- Detailed Invoice Card: Benny's Motor Works ($999 Disputed - Ground Truth 06:15)
        local invCard = Instance.new("Frame", bScroll)
        invCard.Size = UDim2.new(1, -36, 0, 260)
        invCard.Position = UDim2.new(0, 18, 0, 154)
        invCard.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
        invCard.BorderSizePixel = 0
        invCard.ZIndex = 18
        Instance.new("UICorner", invCard).CornerRadius = UDim.new(0, 18)
        local isStroke = Instance.new("UIStroke", invCard)
        isStroke.Color = Color3.fromRGB(255, 255, 255)
        isStroke.Transparency = 0.92

        -- Status Pill
        local statusBadge = Instance.new("Frame", invCard)
        statusBadge.Size = UDim2.new(0, 84, 0, 24)
        statusBadge.Position = UDim2.new(1, -100, 0, 16)
        statusBadge.BackgroundColor3 = Color3.fromRGB(255, 149, 0)
        statusBadge.BorderSizePixel = 0
        statusBadge.ZIndex = 19
        Instance.new("UICorner", statusBadge).CornerRadius = UDim.new(1, 0)

        local sbTxt = Instance.new("TextLabel", statusBadge)
        sbTxt.Size = UDim2.new(1, 0, 1, 0)
        sbTxt.Text = "Disputed"
        sbTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        sbTxt.Font = Enum.Font.GothamBold
        sbTxt.TextSize = 11
        sbTxt.BackgroundTransparency = 1
        sbTxt.ZIndex = 20

        local invVendor = Instance.new("TextLabel", invCard)
        invVendor.Size = UDim2.new(0.65, 0, 0, 22)
        invVendor.Position = UDim2.new(0, 16, 0, 16)
        invVendor.Text = "Benny's Original Motor Works"
        invVendor.TextColor3 = Color3.fromRGB(255, 255, 255)
        invVendor.Font = Enum.Font.GothamBold
        invVendor.TextSize = 15
        invVendor.TextXAlignment = Enum.TextXAlignment.Left
        invVendor.BackgroundTransparency = 1
        invVendor.ZIndex = 19

        local invDesc = Instance.new("TextLabel", invCard)
        invDesc.Size = UDim2.new(0.65, 0, 0, 16)
        invDesc.Position = UDim2.new(0, 16, 0, 38)
        invDesc.Text = "Vehicle repair & performance tuning"
        invDesc.TextColor3 = Color3.fromRGB(142, 142, 147)
        invDesc.Font = Enum.Font.Gotham
        invDesc.TextSize = 12
        invDesc.TextXAlignment = Enum.TextXAlignment.Left
        invDesc.BackgroundTransparency = 1
        invDesc.ZIndex = 19

        local invAmount = Instance.new("TextLabel", invCard)
        invAmount.Size = UDim2.new(1, -32, 0, 36)
        invAmount.Position = UDim2.new(0, 16, 0, 68)
        invAmount.Text = "$999.00"
        invAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
        invAmount.Font = Enum.Font.GothamBold
        invAmount.TextSize = 28
        invAmount.TextXAlignment = Enum.TextXAlignment.Left
        invAmount.BackgroundTransparency = 1
        invAmount.ZIndex = 19

        -- Metadata Rows with Teal/Blue bullets (Ground Truth 06:22)
        local function makeMetaRow(y: number, key: string, val: string)
            local row = Instance.new("Frame", invCard)
            row.Size = UDim2.new(1, -32, 0, 18)
            row.Position = UDim2.new(0, 16, 0, y)
            row.BackgroundTransparency = 1
            row.ZIndex = 19

            local k = Instance.new("TextLabel", row)
            k.Size = UDim2.new(0.35, 0, 1, 0)
            k.Text = key
            k.TextColor3 = Color3.fromRGB(142, 142, 147)
            k.Font = Enum.Font.Gotham
            k.TextSize = 11.5
            k.TextXAlignment = Enum.TextXAlignment.Left
            k.BackgroundTransparency = 1
            k.ZIndex = 20

            local v = Instance.new("TextLabel", row)
            v.Size = UDim2.new(0.65, 0, 1, 0)
            v.Position = UDim2.new(0.35, 0, 0, 0)
            v.Text = val
            v.TextColor3 = Color3.fromRGB(220, 225, 240)
            v.Font = Enum.Font.GothamMedium
            v.TextSize = 11.5
            v.TextXAlignment = Enum.TextXAlignment.Left
            v.BackgroundTransparency = 1
            v.ZIndex = 20
        end

        makeMetaRow(112, "Invoice ID", "#1098D704-A8E7-4050-99C9")
        makeMetaRow(134, "Issued Date", "Sep 18, 2026 · 14:22")
        makeMetaRow(156, "Due Date", "Sep 25, 2026 (Past Due)")

        -- Dispute Button (Video 06:35: triggers "The invoice was disputed." toast)
        local disputeBtn = Instance.new("TextButton", invCard)
        disputeBtn.Size = UDim2.new(1, -32, 0, 40)
        disputeBtn.Position = UDim2.new(0, 16, 0, 202)
        disputeBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 58)
        disputeBtn.Text = "Dispute Invoice"
        disputeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        disputeBtn.Font = Enum.Font.GothamBold
        disputeBtn.TextSize = 13.5
        disputeBtn.BorderSizePixel = 0
        disputeBtn.ZIndex = 20
        Instance.new("UICorner", disputeBtn).CornerRadius = UDim.new(0, 12)

        disputeBtn.MouseButton1Click:Connect(function()
            playTone(2.4)
            -- Trigger the exact Dynamic Island toast seen at 06:40
            showBanner("Billing", "The invoice was disputed.", "rbxassetid://120691943073443", "03:52")
        end)

        -- Secondary Paid Bills
        local function makeMiniBill(y: number, vendor: string, date: string, amt: string)
            local mb = Instance.new("Frame", bScroll)
            mb.Size = UDim2.new(1, -36, 0, 60)
            mb.Position = UDim2.new(0, 18, 0, y)
            mb.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
            mb.BorderSizePixel = 0
            mb.ZIndex = 18
            Instance.new("UICorner", mb).CornerRadius = UDim.new(0, 14)

            local v = Instance.new("TextLabel", mb)
            v.Size = UDim2.new(0.6, 0, 0, 18)
            v.Position = UDim2.new(0, 16, 0, 12)
            v.Text = vendor
            v.TextColor3 = Color3.fromRGB(255, 255, 255)
            v.Font = Enum.Font.GothamBold
            v.TextSize = 13.5
            v.TextXAlignment = Enum.TextXAlignment.Left
            v.BackgroundTransparency = 1
            v.ZIndex = 19

            local d = Instance.new("TextLabel", mb)
            d.Size = UDim2.new(0.6, 0, 0, 14)
            d.Position = UDim2.new(0, 16, 0, 32)
            d.Text = date
            d.TextColor3 = Color3.fromRGB(52, 199, 89)
            d.Font = Enum.Font.Gotham
            d.TextSize = 11.5
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.BackgroundTransparency = 1
            d.ZIndex = 19

            local a = Instance.new("TextLabel", mb)
            a.Size = UDim2.new(0.35, 0, 1, 0)
            a.Position = UDim2.new(0.65, -16, 0, 0)
            a.Text = amt
            a.TextColor3 = Color3.fromRGB(255, 255, 255)
            a.Font = Enum.Font.GothamBold
            a.TextSize = 14
            a.TextXAlignment = Enum.TextXAlignment.Right
            a.BackgroundTransparency = 1
            a.ZIndex = 19
        end

        makeMiniBill(430, "Mors Mutual Insurance", "Paid · Policy #49821", "$450.00")
        makeMiniBill(502, "Dynasty 8 Luxury Living", "Paid · Eclipse Penthouse", "$1,200.00")
    end

    -- =========================================================================
    -- 4. VOICE MEMOS (MEMOS) APP
    -- Video Ground Truth (07:29 - 07:39): Clicks Memos -> "The microphone is unavailable."
    -- =========================================================================
    local memosApp = createBaseApp(appContainer, "VoiceMemos", Color3.fromRGB(12, 14, 20))
    do
        local mHeader = Instance.new("Frame", memosApp)
        mHeader.Size = UDim2.new(1, 0, 0, 75)
        mHeader.Position = UDim2.new(0, 0, 0, 36)
        mHeader.BackgroundTransparency = 1
        mHeader.ZIndex = 17

        local mTitle = Instance.new("TextLabel", mHeader)
        mTitle.Size = UDim2.new(1, -40, 0, 32)
        mTitle.Position = UDim2.new(0, 20, 0, 24)
        mTitle.Text = "Voice Memos"
        mTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        mTitle.Font = Enum.Font.GothamBold
        mTitle.TextSize = 28
        mTitle.TextXAlignment = Enum.TextXAlignment.Left
        mTitle.BackgroundTransparency = 1
        mTitle.ZIndex = 18

        -- Audio Waveform Mock
        local waveBox = Instance.new("Frame", memosApp)
        waveBox.Size = UDim2.new(1, -36, 0, 140)
        waveBox.Position = UDim2.new(0, 18, 0, 120)
        waveBox.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
        waveBox.BorderSizePixel = 0
        waveBox.ZIndex = 18
        Instance.new("UICorner", waveBox).CornerRadius = UDim.new(0, 16)

        local wLbl = Instance.new("TextLabel", waveBox)
        wLbl.AnchorPoint = Vector2.new(0.5, 0.5)
        wLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
        wLbl.Size = UDim2.new(1, -20, 0, 24)
        wLbl.Text = "All Recordings (0)"
        wLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
        wLbl.Font = Enum.Font.GothamMedium
        wLbl.TextSize = 14
        wLbl.BackgroundTransparency = 1
        wLbl.ZIndex = 19

        -- Circular Red Record Button
        local recBtn = Instance.new("TextButton", memosApp)
        recBtn.Size = UDim2.new(0, 72, 0, 72)
        recBtn.Position = UDim2.new(0.5, -36, 1, -110)
        recBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
        recBtn.Text = "●"
        recBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        recBtn.Font = Enum.Font.GothamBold
        recBtn.TextSize = 32
        recBtn.BorderSizePixel = 0
        recBtn.ZIndex = 20
        Instance.new("UICorner", recBtn).CornerRadius = UDim.new(1, 0)
        local rRing = Instance.new("UIStroke", recBtn)
        rRing.Color = Color3.fromRGB(255, 255, 255)
        rRing.Thickness = 2.5

        local function triggerMicUnavailable()
            playTone(1.4)
            -- Exact ground truth banner from video at 07:35
            showBanner("Memos", "The microphone is unavailable.", "rbxassetid://13854583196", "03:55")
        end

        recBtn.MouseButton1Click:Connect(triggerMicUnavailable)

        -- Also create alias MemosApp pointing to same behavior
        local mAppAlias = createBaseApp(appContainer, "Memos", Color3.fromRGB(12, 14, 20))
        local mClone = recBtn:Clone()
        mClone.Parent = mAppAlias
        mClone.MouseButton1Click:Connect(triggerMicUnavailable)
    end

    -- =========================================================================
    -- 5. CONTACTS APP (Full Alphabetical Directory)
    -- =========================================================================
    local contactsApp = createBaseApp(appContainer, "Contacts", Color3.fromRGB(12, 14, 20))
    do
        local cHeader = Instance.new("Frame", contactsApp)
        cHeader.Size = UDim2.new(1, 0, 0, 75)
        cHeader.Position = UDim2.new(0, 0, 0, 36)
        cHeader.BackgroundTransparency = 1
        cHeader.ZIndex = 17

        local cTitle = Instance.new("TextLabel", cHeader)
        cTitle.Size = UDim2.new(1, -40, 0, 32)
        cTitle.Position = UDim2.new(0, 20, 0, 24)
        cTitle.Text = "Contacts"
        cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        cTitle.Font = Enum.Font.GothamBold
        cTitle.TextSize = 28
        cTitle.TextXAlignment = Enum.TextXAlignment.Left
        cTitle.BackgroundTransparency = 1
        cTitle.ZIndex = 18

        local cScroll = Instance.new("ScrollingFrame", contactsApp)
        cScroll.Size = UDim2.new(1, -36, 1, -120)
        cScroll.Position = UDim2.new(0, 18, 0, 115)
        cScroll.BackgroundTransparency = 1
        cScroll.ScrollBarThickness = 0
        cScroll.ZIndex = 17
        local cl = Instance.new("UIListLayout", cScroll)
        cl.Padding = UDim.new(0, 8)

        local contactData = {
            {name = "Alex Rivera", phone = "555-0192"},
            {name = "Andre Heinicke", phone = "555-0819"},
            {name = "Emily Hart", phone = "555-0481"},
            {name = "Jamie Chen", phone = "555-0723"},
            {name = "Los Santos Taxi", phone = "555-0100"},
            {name = "Michael De Santa", phone = "555-0182"},
            {name = "Samantha Cole", phone = "555-0144"},
            {name = "Sofia Turner", phone = "555-0349"},
            {name = "Trevor Philips", phone = "555-0133"},
            {name = "Vincent Cole", phone = "555-0612"},
        }

        for _, contact in ipairs(contactData) do
            local card = Instance.new("Frame", cScroll)
            card.Size = UDim2.new(1, 0, 0, 52)
            card.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
            card.BorderSizePixel = 0
            card.ZIndex = 18
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

            local avatar = Instance.new("Frame", card)
            avatar.Size = UDim2.new(0, 36, 0, 36)
            avatar.Position = UDim2.new(0, 8, 0, 8)
            avatar.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
            avatar.BorderSizePixel = 0
            avatar.ZIndex = 19
            Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

            local avTxt = Instance.new("TextLabel", avatar)
            avTxt.Size = UDim2.new(1, 0, 1, 0)
            avTxt.Text = string.sub(contact.name, 1, 1)
            avTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
            avTxt.Font = Enum.Font.GothamBold
            avTxt.TextSize = 15
            avTxt.BackgroundTransparency = 1
            avTxt.ZIndex = 20

            local nameLbl = Instance.new("TextLabel", card)
            nameLbl.Size = UDim2.new(0.6, 0, 0, 18)
            nameLbl.Position = UDim2.new(0, 52, 0, 8)
            nameLbl.Text = contact.name
            nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLbl.Font = Enum.Font.GothamMedium
            nameLbl.TextSize = 13.5
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.BackgroundTransparency = 1
            nameLbl.ZIndex = 19

            local phoneLbl = Instance.new("TextLabel", card)
            phoneLbl.Size = UDim2.new(0.6, 0, 0, 14)
            phoneLbl.Position = UDim2.new(0, 52, 0, 28)
            phoneLbl.Text = contact.phone
            phoneLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            phoneLbl.Font = Enum.Font.Gotham
            phoneLbl.TextSize = 11.5
            phoneLbl.TextXAlignment = Enum.TextXAlignment.Left
            phoneLbl.BackgroundTransparency = 1
            phoneLbl.ZIndex = 19

            local callBtn = Instance.new("TextButton", card)
            callBtn.Size = UDim2.new(0, 32, 0, 32)
            callBtn.Position = UDim2.new(1, -40, 0, 10)
            callBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
            callBtn.Text = "📞"
            callBtn.TextSize = 13
            callBtn.BorderSizePixel = 0
            callBtn.ZIndex = 20
            Instance.new("UICorner", callBtn).CornerRadius = UDim.new(1, 0)

            callBtn.MouseButton1Click:Connect(function()
                playTone(2.4)
                openApp("Phone")
            end)
        end
    end

    -- =========================================================================
    -- 6. MAIL APP (Dark Theme Inbox)
    -- =========================================================================
    local mailApp = createBaseApp(appContainer, "Mail", Color3.fromRGB(12, 14, 20))
    do
        local mHeader = Instance.new("Frame", mailApp)
        mHeader.Size = UDim2.new(1, 0, 0, 75)
        mHeader.Position = UDim2.new(0, 0, 0, 36)
        mHeader.BackgroundTransparency = 1
        mHeader.ZIndex = 17

        local mTitle = Instance.new("TextLabel", mHeader)
        mTitle.Size = UDim2.new(1, -40, 0, 32)
        mTitle.Position = UDim2.new(0, 20, 0, 24)
        mTitle.Text = "Inbox"
        mTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        mTitle.Font = Enum.Font.GothamBold
        mTitle.TextSize = 28
        mTitle.TextXAlignment = Enum.TextXAlignment.Left
        mTitle.BackgroundTransparency = 1
        mTitle.ZIndex = 18

        local mScroll = Instance.new("ScrollingFrame", mailApp)
        mScroll.Size = UDim2.new(1, -36, 1, -120)
        mScroll.Position = UDim2.new(0, 18, 0, 115)
        mScroll.BackgroundTransparency = 1
        mScroll.ScrollBarThickness = 0
        mScroll.ZIndex = 17
        local ml = Instance.new("UIListLayout", mScroll)
        ml.Padding = UDim.new(0, 10)

        local emails = {
            {sender = "Dynasty 8 Realty", subject = "Lease Agreement Renewal", snippet = "Your Eclipse Towers luxury apartment lease is ready for review.", unread = true},
            {sender = "Maze Bank", subject = "Monthly e-Statement Ready", snippet = "Your checking account statement for September 2026 is available.", unread = false},
            {sender = "Los Santos Customs", subject = "Vehicle Tuning Complete", snippet = "Your Pfister Comet S2 has been fitted with the Stage 4 turbo.", unread = false},
        }

        for _, em in ipairs(emails) do
            local card = Instance.new("Frame", mScroll)
            card.Size = UDim2.new(1, 0, 0, 76)
            card.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
            card.BorderSizePixel = 0
            card.ZIndex = 18
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

            local sLbl = Instance.new("TextLabel", card)
            sLbl.Size = UDim2.new(0.8, 0, 0, 18)
            sLbl.Position = UDim2.new(0, 14, 0, 10)
            sLbl.Text = (em.unread and "🔵 " or "") .. em.sender
            sLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            sLbl.Font = em.unread and Enum.Font.GothamBold or Enum.Font.GothamMedium
            sLbl.TextSize = 13.5
            sLbl.TextXAlignment = Enum.TextXAlignment.Left
            sLbl.BackgroundTransparency = 1
            sLbl.ZIndex = 19

            local subLbl = Instance.new("TextLabel", card)
            subLbl.Size = UDim2.new(1, -28, 0, 16)
            subLbl.Position = UDim2.new(0, 14, 0, 30)
            subLbl.Text = em.subject
            subLbl.TextColor3 = Color3.fromRGB(200, 205, 220)
            subLbl.Font = Enum.Font.GothamMedium
            subLbl.TextSize = 12
            subLbl.TextXAlignment = Enum.TextXAlignment.Left
            subLbl.BackgroundTransparency = 1
            subLbl.ZIndex = 19

            local snipLbl = Instance.new("TextLabel", card)
            snipLbl.Size = UDim2.new(1, -28, 0, 16)
            snipLbl.Position = UDim2.new(0, 14, 0, 48)
            snipLbl.Text = em.snippet
            snipLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            snipLbl.Font = Enum.Font.Gotham
            snipLbl.TextSize = 11
            snipLbl.TextXAlignment = Enum.TextXAlignment.Left
            snipLbl.TextTruncate = Enum.TextTruncate.AtEnd
            snipLbl.BackgroundTransparency = 1
            snipLbl.ZIndex = 19
        end
    end

    -- =========================================================================
    -- 7. REMAINING ECOSYSTEM APPS (Consistent Dark Theme)
    -- =========================================================================
    local standardApps = {
        Memory = {title = "Memory Match", icon = "⭐", color = Color3.fromRGB(175, 82, 222), desc = "Card Matching Challenge\nPairs Found: 8/8 • Best Time: 0:42"},
        Game2048 = {title = "2048 Puzzle", icon = "🔢", color = Color3.fromRGB(237, 142, 53), desc = "Join numbers to reach 2048\nHigh Score: 4,096"},
        Minesweeper = {title = "Minesweeper", icon = "🚩", color = Color3.fromRGB(52, 199, 89), desc = "Flag all hidden mines\nDifficulty: Intermediate (40 mines)"},
        TowerStack = {title = "Tower Stack", icon = "🧱", color = Color3.fromRGB(255, 45, 85), desc = "Stack blocks perfectly high\nBest Height: 48 Floors"},
        SkyFlappy = {title = "Sky Flappy", icon = "🐦", color = Color3.fromRGB(52, 199, 89), desc = "Tap to Flap through Pipes\nBest Score: 28"},
        NeonDrop = {title = "Neon Drop", icon = "🕹️", color = Color3.fromRGB(0, 122, 255), desc = "Neon Block Drop & Clear\nScore: 18,400"},
        CityMarkt = {title = "CityMarkt", icon = "🏷️", color = Color3.fromRGB(245, 166, 35), desc = "Classified Marketplace (5 New Deals)\nVehicles, Real Estate, Gear & Items"},
        LocalPages = {title = "Local Pages", icon = "📰", color = Color3.fromRGB(30, 144, 255), desc = "Los Santos Daily News & Directory\nTrending: Downtown Vinewood Expo"},
        Radio = {title = "Los Santos Radio", icon = "📻", color = Color3.fromRGB(0, 122, 255), desc = "Live Broadcast: Radio Los Santos\n106.1 FM • Hip Hop & Hits"},
        FlipTok = {title = "FlipTok", icon = "🎵", color = Color3.fromRGB(18, 20, 26), desc = "Trending Clips & Short Videos\nViral: Vinewood Drift Challenge"},
        Picstagram = {title = "Picstagram", icon = "📸", color = Color3.fromRGB(225, 48, 108), desc = "Stories & Photo Feed\n@alex_morgan: Rockford Hills Sunset"},
        Flare = {title = "Flare", icon = "🔥", color = Color3.fromRGB(255, 69, 58), desc = "Social Discovery & Meetups\n5 New Connections Nearby in Los Santos"},
        Feather = {title = "Feather", icon = "🪶", color = Color3.fromRGB(175, 82, 222), desc = "Creative Journal & Poetry\nReflections and daily thoughts"},
        House = {title = "Dynasty 8 Real Estate", icon = "🏠", color = Color3.fromRGB(255, 149, 0), desc = "Luxury Mansions & Penthouses\nProperties: Eclipse Towers, Vinewood Hills"},
        SkyRide = {title = "SkyRide", icon = "🚗", color = Color3.fromRGB(0, 122, 255), desc = "On-Demand Ride Hail\nDriver arriving in 3 mins • Benefactor Schafter"},
        Flashlight = {title = "Flashlight", icon = "🔦", color = Color3.fromRGB(255, 204, 0), desc = "Ultra-bright LED Beam\nMode: Constant • Strobe: Off"},
        Emergency = {title = "Emergency 911", icon = "🚨", color = Color3.fromRGB(255, 59, 48), desc = "Emergency Dispatch\nPolice, Paramedics, Fire Rescue"},
        CrewLink = {title = "CrewLink", icon = "👥", color = Color3.fromRGB(0, 168, 150), desc = "Heist Crew & Syndicate Directory\nOnline: Alex, Morgan, Sofia"},
        Companies = {title = "Companies", icon = "🏢", color = Color3.fromRGB(0, 122, 255), desc = "Dynasty 8 Executive & Corporate Holdings\n2 Pending Contracts"},
        WeazelNews = {title = "Weazel News", icon = "📰", color = Color3.fromRGB(190, 30, 45), desc = "Los Santos Breaking News & Broadcast\nLive: Maze Bank Helicopter Chase"},
        CityWarn = {title = "CityWarn", icon = "🚨", color = Color3.fromRGB(0, 122, 255), desc = "Los Santos Public Safety & Alerts\nAll Systems Operational"},
        Calendar = {title = "Calendar", icon = "📅", color = Color3.fromRGB(255, 59, 48), desc = "September 2026\nEvents: Heist Meeting 8:00 PM"},
        AppStore = {title = "App Store", icon = "🛍️", color = Color3.fromRGB(18, 120, 245), desc = "Today's Top Apps & Games\n42 Apps Installed & Up to Date"},
        Health = {title = "Health", icon = "❤️", color = Color3.fromRGB(255, 45, 85), desc = "Daily Steps: 8,420\nHeart Rate: 72 BPM\nSleep: 7h 45m"},
        Wallet = {title = "Wallet", icon = "💳", color = Color3.fromRGB(28, 30, 36), desc = "Apple Pay: Active\nBoarding Pass: LSX to LCY"},
        Twitter = {title = "Twitter", icon = "🐦", color = Color3.fromRGB(29, 161, 242), desc = "Feed: Trending in Los Santos\n#Vinewood #MazeBankHeist"},
        Instagram = {title = "Instagram", icon = "📸", color = Color3.fromRGB(225, 48, 108), desc = "Stories & Reels\n@alex_morgan: New Pfister in the garage!"},
        TikTok = {title = "TikTok", icon = "🎵", color = Color3.fromRGB(0, 0, 0), desc = "Trending Audio: Vinewood Sunset\nWatch Viral Los Santos Stunts"},
        YouTube = {title = "YouTube", icon = "▶️", color = Color3.fromRGB(255, 0, 0), desc = "Subscriptions\nWeazel News Live: Chase on Del Perro Fwy"},
        Discord = {title = "Discord", icon = "💬", color = Color3.fromRGB(88, 101, 242), desc = "Servers: Los Santos Syndicate\nVoice Channel: Heist Room (4)"},
        WhatsApp = {title = "WhatsApp", icon = "🟢", color = Color3.fromRGB(37, 211, 102), desc = "Encrypted Chats (5)\nGroup: Vinewood Crew"},
        Uber = {title = "Uber", icon = "🚗", color = Color3.fromRGB(0, 0, 0), desc = "Where to?\nDestination: Rockford Hills Club"},
        Deliveroo = {title = "Deliveroo", icon = "🍔", color = Color3.fromRGB(0, 205, 180), desc = "Burgers, Tacos & Cluckin' Bell\nEstimated delivery: 15-20 min"},
        Valet = {title = "Valet", icon = "🔑", color = Color3.fromRGB(245, 166, 35), desc = "Summon Vehicle to GPS Location\nActive: Benefactor Schafter V12"},
        Marketplace = {title = "Marketplace", icon = "🏷️", color = Color3.fromRGB(24, 119, 242), desc = "Classified Listings: 1,420 items\nCars, Real Estate, Collectibles"},
        News = {title = "Weazel News", icon = "📰", color = Color3.fromRGB(190, 30, 45), desc = "Breaking: Diamond Casino Jackpot Hit!\nTraffic update: Downtown congestion"},
        FaceTime = {title = "FaceTime", icon = "📹", color = Color3.fromRGB(52, 199, 89), desc = "Start Video Call\nAvailable contacts: Alex, Morgan, Sofia"},
        Files = {title = "Files", icon = "📁", color = Color3.fromRGB(18, 120, 245), desc = "iCloud Drive (24.8 GB free)\nDocuments, Car Tuning Specs"},
        Compass = {title = "Compass", icon = "🧭", color = Color3.fromRGB(18, 20, 28), desc = "342° NNW\nElevation: 42m • Los Santos, SA"},
        Shortcuts = {title = "Shortcuts", icon = "⚡", color = Color3.fromRGB(255, 45, 85), desc = "Automations\n- Summon Valet on Exit\n- Night Mode at 9 PM"},
        DarkChat = {title = "DarkChat", icon = "🕶️", color = Color3.fromRGB(15, 18, 24), desc = "Anonymous Tor Routing: Connected\nRoom #420-Shadow"},
        Stocks = {title = "Stocks", icon = "📈", color = Color3.fromRGB(0, 0, 0), desc = "BAWSAQ: 14,280 (+1.8%)\nLifeinvader: $42.50 (+4.2%)"},
        Podcasts = {title = "Podcasts", icon = "🎙️", color = Color3.fromRGB(142, 68, 173), desc = "Vinewood Underground Ep. 42\nChakra Attack Live"},
        Books = {title = "Books", icon = "📚", color = Color3.fromRGB(245, 166, 35), desc = "Reading Now\nThe Art of the Heist (Ch. 4)"},
        Reminders = {title = "Reminders", icon = "📋", color = Color3.fromRGB(18, 120, 245), desc = "To-Do (4 items)\n☑ Buy ammo at Ammu-Nation\n☐ Meet Lester"},
        Safari = {title = "Safari", icon = "🧭", color = Color3.fromRGB(18, 120, 245), desc = "Search or enter website name\nBookmarks: Eyefind, Dynasty8, Lifeinvader"},
        Maps = {title = "Maps", icon = "🗺️", color = Color3.fromRGB(52, 199, 89), desc = "Los Santos & Blaine County\nGPS Navigation: Ready"},
    }

    for appKey, data in pairs(standardApps) do
        local appFrame = createBaseApp(appContainer, appKey, Color3.fromRGB(12, 14, 20))
        do
            local header = Instance.new("Frame", appFrame)
            header.Size = UDim2.new(1, 0, 0, 75)
            header.Position = UDim2.new(0, 0, 0, 36)
            header.BackgroundTransparency = 1
            header.ZIndex = 17

            local title = Instance.new("TextLabel", header)
            title.Size = UDim2.new(1, -40, 0, 32)
            title.Position = UDim2.new(0, 20, 0, 24)
            title.Text = data.title
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 28
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.BackgroundTransparency = 1
            title.ZIndex = 18

            local hCard = Instance.new("Frame", appFrame)
            hCard.Size = UDim2.new(1, -36, 0, 160)
            hCard.Position = UDim2.new(0, 18, 0, 115)
            hCard.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
            hCard.BorderSizePixel = 0
            hCard.ZIndex = 18
            Instance.new("UICorner", hCard).CornerRadius = UDim.new(0, 18)
            local cs = Instance.new("UIStroke", hCard)
            cs.Color = Color3.fromRGB(255, 255, 255)
            cs.Transparency = 0.92

            local icn = Instance.new("TextLabel", hCard)
            icn.Size = UDim2.new(0, 48, 0, 48)
            icn.Position = UDim2.new(0, 16, 0, 16)
            icn.Text = data.icon
            icn.TextSize = 36
            icn.BackgroundTransparency = 1
            icn.ZIndex = 19

            local dLbl = Instance.new("TextLabel", hCard)
            dLbl.Size = UDim2.new(1, -80, 0, 60)
            dLbl.Position = UDim2.new(0, 72, 0, 16)
            dLbl.Text = data.desc
            dLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
            dLbl.Font = Enum.Font.GothamMedium
            dLbl.TextSize = 13
            dLbl.TextXAlignment = Enum.TextXAlignment.Left
            dLbl.TextYAlignment = Enum.TextYAlignment.Top
            dLbl.TextWrapped = true
            dLbl.BackgroundTransparency = 1
            dLbl.ZIndex = 19

            local actionBtn = Instance.new("TextButton", hCard)
            actionBtn.Size = UDim2.new(1, -32, 0, 38)
            actionBtn.Position = UDim2.new(0, 16, 1, -48)
            actionBtn.BackgroundColor3 = data.color
            actionBtn.Text = "Open " .. data.title
            actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            actionBtn.Font = Enum.Font.GothamBold
            actionBtn.TextSize = 13
            actionBtn.BorderSizePixel = 0
            actionBtn.ZIndex = 20
            Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 10)

            actionBtn.MouseButton1Click:Connect(function()
                playTone(2.0)
                showBanner(data.title, data.title .. " feature online.", "", "03:55")
            end)
        end
    end
end

return AppSuite_Ecosystem
