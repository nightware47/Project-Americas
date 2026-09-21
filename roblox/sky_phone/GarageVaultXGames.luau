-- ============================================================================
-- 20. GARAGE APP (Matching official_garage.png)
-- ============================================================================
local garageApp = createBaseApp("Garage", Color3.fromRGB(240, 242, 245))
do
    local gScroll = Instance.new("ScrollingFrame", garageApp)
    gScroll.Size = UDim2.new(1, 0, 1, 0)
    gScroll.BackgroundTransparency = 1
    gScroll.ScrollBarThickness = 0
    gScroll.CanvasSize = UDim2.new(0, 0, 0, 680)
    gScroll.ZIndex = 17

    local gTitle = Instance.new("TextLabel", gScroll)
    gTitle.Size = UDim2.new(1, -36, 0, 36)
    gTitle.Position = UDim2.new(0, 18, 0, 48)
    gTitle.Text = "Garage"
    gTitle.Font = Enum.Font.GothamBold
    gTitle.TextSize = 34
    gTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    gTitle.TextXAlignment = Enum.TextXAlignment.Left
    gTitle.BackgroundTransparency = 1
    gTitle.ZIndex = 18

    local gSub = Instance.new("TextLabel", gScroll)
    gSub.Size = UDim2.new(1, -36, 0, 18)
    gSub.Position = UDim2.new(0, 18, 0, 84)
    gSub.Text = "Your vehicle collection"
    gSub.Font = Enum.Font.Gotham
    gSub.TextSize = 13.5
    gSub.TextColor3 = Color3.fromRGB(140, 145, 160)
    gSub.TextXAlignment = Enum.TextXAlignment.Left
    gSub.BackgroundTransparency = 1
    gSub.ZIndex = 18

    -- Hero Card: MY VEHICLES 4
    local heroCard = Instance.new("Frame", gScroll)
    heroCard.Size = UDim2.new(1, -36, 0, 150)
    heroCard.Position = UDim2.new(0, 18, 0, 110)
    heroCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    heroCard.BorderSizePixel = 0
    heroCard.ZIndex = 18
    Instance.new("UICorner", heroCard).CornerRadius = UDim.new(0, 22)
    local hcs = Instance.new("UIStroke", heroCard)
    hcs.Color = Color3.fromRGB(230, 234, 244)

    local hvLabel = Instance.new("TextLabel", heroCard)
    hvLabel.Size = UDim2.new(0.5, 0, 0, 16)
    hvLabel.Position = UDim2.new(0, 18, 0, 16)
    hvLabel.Text = "MY VEHICLES"
    hvLabel.Font = Enum.Font.GothamBold
    hvLabel.TextSize = 11
    hvLabel.TextColor3 = Color3.fromRGB(130, 135, 150)
    hvLabel.TextXAlignment = Enum.TextXAlignment.Left
    hvLabel.BackgroundTransparency = 1
    hvLabel.ZIndex = 19

    local hvCount = Instance.new("TextLabel", heroCard)
    hvCount.Size = UDim2.new(0.5, 0, 0, 40)
    hvCount.Position = UDim2.new(0, 18, 0, 34)
    hvCount.Text = "4"
    hvCount.Font = Enum.Font.GothamBold
    hvCount.TextSize = 36
    hvCount.TextColor3 = Color3.fromRGB(15, 18, 28)
    hvCount.TextXAlignment = Enum.TextXAlignment.Left
    hvCount.BackgroundTransparency = 1
    hvCount.ZIndex = 19

    local carBtn = Instance.new("Frame", heroCard)
    carBtn.Size = UDim2.new(0, 44, 0, 44)
    carBtn.Position = UDim2.new(1, -62, 0, 20)
    carBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    carBtn.BorderSizePixel = 0
    carBtn.ZIndex = 19
    Instance.new("UICorner", carBtn).CornerRadius = UDim.new(0, 12)

    local carBtnTxt = Instance.new("TextLabel", carBtn)
    carBtnTxt.Size = UDim2.new(1, 0, 1, 0)
    carBtnTxt.BackgroundTransparency = 1
    carBtnTxt.Text = "🚗"
    carBtnTxt.TextSize = 22
    carBtnTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    carBtnTxt.ZIndex = 20

    -- 3 Sub-Cards inside Hero
    local function makeHeroSubCard(dotColor, countStr, labelStr, xPos)
        local sc = Instance.new("Frame", heroCard)
        sc.Size = UDim2.new(0.28, 0, 0, 56)
        sc.Position = UDim2.new(xPos, 0, 0, 80)
        sc.BackgroundColor3 = Color3.fromRGB(246, 248, 252)
        sc.BorderSizePixel = 0
        sc.ZIndex = 19
        Instance.new("UICorner", sc).CornerRadius = UDim.new(0, 14)
        local scs = Instance.new("UIStroke", sc)
        scs.Color = Color3.fromRGB(230, 234, 244)

        local dot = Instance.new("Frame", sc)
        dot.Size = UDim2.new(0, 6, 0, 6)
        dot.Position = UDim2.new(0, 10, 0, 14)
        dot.BackgroundColor3 = dotColor
        dot.BorderSizePixel = 0
        dot.ZIndex = 20
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local c = Instance.new("TextLabel", sc)
        c.Size = UDim2.new(1, -26, 0, 16)
        c.Position = UDim2.new(0, 20, 0, 8)
        c.Text = countStr
        c.Font = Enum.Font.GothamBold
        c.TextSize = 14
        c.TextColor3 = Color3.fromRGB(15, 18, 28)
        c.TextXAlignment = Enum.TextXAlignment.Left
        c.BackgroundTransparency = 1
        c.ZIndex = 20

        local l = Instance.new("TextLabel", sc)
        l.Size = UDim2.new(1, -16, 0, 14)
        l.Position = UDim2.new(0, 10, 0, 30)
        l.Text = labelStr
        l.Font = Enum.Font.Gotham
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(130, 135, 150)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.BackgroundTransparency = 1
        l.ZIndex = 20
    end

    makeHeroSubCard(Color3.fromRGB(52, 199, 89), "2", "Parked", 0.04)
    makeHeroSubCard(Color3.fromRGB(255, 149, 0), "1", "Outside", 0.36)
    makeHeroSubCard(Color3.fromRGB(255, 59, 48), "1", "Impound", 0.68)

    -- Search Bar
    local gSearch = Instance.new("Frame", gScroll)
    gSearch.Size = UDim2.new(1, -36, 0, 40)
    gSearch.Position = UDim2.new(0, 18, 0, 275)
    gSearch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    gSearch.BorderSizePixel = 0
    gSearch.ZIndex = 18
    Instance.new("UICorner", gSearch).CornerRadius = UDim.new(0, 20)
    local gss = Instance.new("UIStroke", gSearch)
    gss.Color = Color3.fromRGB(225, 228, 238)

    local gsText = Instance.new("TextLabel", gSearch)
    gsText.Size = UDim2.new(1, -20, 1, 0)
    gsText.Position = UDim2.new(0, 14, 0, 0)
    gsText.BackgroundTransparency = 1
    gsText.Text = "🔍 Search name, plate or garage"
    gsText.Font = Enum.Font.GothamMedium
    gsText.TextSize = 12.5
    gsText.TextColor3 = Color3.fromRGB(150, 155, 170)
    gsText.TextXAlignment = Enum.TextXAlignment.Left
    gsText.ZIndex = 19

    -- Filter Pills
    local filterRow = Instance.new("Frame", gScroll)
    filterRow.Size = UDim2.new(1, -36, 0, 32)
    filterRow.Position = UDim2.new(0, 18, 0, 325)
    filterRow.BackgroundTransparency = 1
    filterRow.ZIndex = 18
    local frLayout = Instance.new("UIListLayout", filterRow)
    frLayout.FillDirection = Enum.FillDirection.Horizontal
    frLayout.Padding = UDim.new(0, 8)

    local function makeFilterPill(name, count, isActive)
        local btn = Instance.new("TextButton", filterRow)
        btn.Size = UDim2.new(0, 68, 1, 0)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(230, 234, 242)
        btn.BorderSizePixel = 0
        btn.Text = name .. " " .. count
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10.5
        btn.TextColor3 = isActive and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(120, 125, 140)
        btn.ZIndex = 19
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makeFilterPill("All", "4", true)
    makeFilterPill("Parked", "2", false)
    makeFilterPill("Outside", "1", false)
    makeFilterPill("Impound", "1", false)

    -- Vehicle Cards List
    local function makeVehicleCard(name, model, statusTxt, statusColor, plateTxt, locTxt, fuelTxt, iconSymbol, yPos)
        local card = Instance.new("Frame", gScroll)
        card.Size = UDim2.new(1, -36, 0, 95)
        card.Position = UDim2.new(0, 18, 0, yPos)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.BorderSizePixel = 0
        card.ZIndex = 18
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 20)
        local cs = Instance.new("UIStroke", card)
        cs.Color = Color3.fromRGB(230, 234, 244)

        local leftPanel = Instance.new("Frame", card)
        leftPanel.Size = UDim2.new(0, 75, 1, 0)
        leftPanel.BackgroundColor3 = Color3.fromRGB(225, 240, 255)
        leftPanel.BorderSizePixel = 0
        leftPanel.ZIndex = 19
        Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 20)

        local statusBadge = Instance.new("Frame", leftPanel)
        statusBadge.Size = UDim2.new(0, 52, 0, 16)
        statusBadge.Position = UDim2.new(0.5, -26, 0, 8)
        statusBadge.BackgroundColor3 = statusColor
        statusBadge.BorderSizePixel = 0
        statusBadge.ZIndex = 20
        Instance.new("UICorner", statusBadge).CornerRadius = UDim.new(1, 0)

        local sbTxt = Instance.new("TextLabel", statusBadge)
        sbTxt.Size = UDim2.new(1, 0, 1, 0)
        sbTxt.Text = statusTxt
        sbTxt.Font = Enum.Font.GothamBold
        sbTxt.TextSize = 8
        sbTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        sbTxt.BackgroundTransparency = 1
        sbTxt.ZIndex = 21

        local iconLbl = Instance.new("TextLabel", leftPanel)
        iconLbl.Size = UDim2.new(1, 0, 0, 36)
        iconLbl.Position = UDim2.new(0, 0, 0, 34)
        iconLbl.Text = iconSymbol
        iconLbl.TextSize = 28
        iconLbl.TextColor3 = Color3.fromRGB(0, 122, 255)
        iconLbl.BackgroundTransparency = 1
        iconLbl.ZIndex = 20

        local t = Instance.new("TextLabel", card)
        t.Size = UDim2.new(0.5, 0, 0, 20)
        t.Position = UDim2.new(0, 85, 0, 12)
        t.Text = name
        t.Font = Enum.Font.GothamBold
        t.TextSize = 15
        t.TextColor3 = Color3.fromRGB(15, 18, 28)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.BackgroundTransparency = 1
        t.ZIndex = 19

        local m = Instance.new("TextLabel", card)
        m.Size = UDim2.new(0.5, 0, 0, 16)
        m.Position = UDim2.new(0, 85, 0, 32)
        m.Text = model
        m.Font = Enum.Font.Gotham
        m.TextSize = 12
        m.TextColor3 = Color3.fromRGB(130, 135, 150)
        m.TextXAlignment = Enum.TextXAlignment.Left
        m.BackgroundTransparency = 1
        m.ZIndex = 19

        local plateBadge = Instance.new("Frame", card)
        plateBadge.Size = UDim2.new(0, 58, 0, 18)
        plateBadge.Position = UDim2.new(1, -70, 0, 14)
        plateBadge.BackgroundColor3 = Color3.fromRGB(244, 246, 250)
        plateBadge.BorderSizePixel = 0
        plateBadge.ZIndex = 19
        Instance.new("UICorner", plateBadge).CornerRadius = UDim.new(1, 0)
        local pbs = Instance.new("UIStroke", plateBadge)
        pbs.Color = Color3.fromRGB(220, 225, 235)

        local pbTxt = Instance.new("TextLabel", plateBadge)
        pbTxt.Size = UDim2.new(1, 0, 1, 0)
        pbTxt.Text = plateTxt
        pbTxt.Font = Enum.Font.GothamBold
        pbTxt.TextSize = 8.5
        pbTxt.TextColor3 = Color3.fromRGB(100, 105, 120)
        pbTxt.BackgroundTransparency = 1
        pbTxt.ZIndex = 20

        local loc = Instance.new("TextLabel", card)
        loc.Size = UDim2.new(0.5, 0, 0, 16)
        loc.Position = UDim2.new(0, 85, 0, 64)
        loc.Text = "📍 " .. locTxt
        loc.Font = Enum.Font.Gotham
        loc.TextSize = 11
        loc.TextColor3 = Color3.fromRGB(120, 125, 140)
        loc.TextXAlignment = Enum.TextXAlignment.Left
        loc.BackgroundTransparency = 1
        loc.ZIndex = 19

        local fuel = Instance.new("TextLabel", card)
        fuel.Size = UDim2.new(0.3, 0, 0, 16)
        fuel.Position = UDim2.new(0.7, -10, 0, 64)
        fuel.Text = "⏱ " .. fuelTxt
        fuel.Font = Enum.Font.Gotham
        fuel.TextSize = 11
        fuel.TextColor3 = Color3.fromRGB(120, 125, 140)
        fuel.TextXAlignment = Enum.TextXAlignment.Right
        fuel.BackgroundTransparency = 1
        fuel.ZIndex = 19
    end

    makeVehicleCard("Midnight", "Karin Sultan RS", "PARKED", Color3.fromRGB(52, 199, 89), "SKY 204", "Legion Square", "94%", "🚗", 370)
    makeVehicleCard("Pfister Comet S2", "comet6", "OUTSIDE", Color3.fromRGB(255, 149, 0), "NOVA 77", "Location unavailable", "81%", "🚗", 475)
    makeVehicleCard("Blue Current", "Pegassi Speeder", "PARKED", Color3.fromRGB(52, 199, 89), "SEA 911", "La Puerta Pier", "82%", "⛵", 580)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Garage"] = function(isLight)
            garageApp.BackgroundColor3 = isLight and Color3.fromRGB(240, 242, 245) or Color3.fromRGB(0, 0, 0)
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(garageApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 21. VAULTX (CRYPTO) APP (Matching official_crypto.png)
-- ============================================================================
local vaultxApp = createBaseApp("VaultX", Color3.fromRGB(12, 15, 20))
do
    local vScroll = Instance.new("ScrollingFrame", vaultxApp)
    vScroll.Size = UDim2.new(1, 0, 1, 0)
    vScroll.BackgroundTransparency = 1
    vScroll.ScrollBarThickness = 0
    vScroll.CanvasSize = UDim2.new(0, 0, 0, 680)
    vScroll.ZIndex = 17

    -- Top Header: Logo + Title
    local vTop = Instance.new("Frame", vScroll)
    vTop.Size = UDim2.new(1, 0, 0, 48)
    vTop.Position = UDim2.new(0, 0, 0, 36)
    vTop.BackgroundTransparency = 1
    vTop.ZIndex = 18

    local vLogo = Instance.new("ImageLabel", vTop)
    vLogo.Size = UDim2.new(0, 28, 0, 28)
    vLogo.Position = UDim2.new(0.5, -55, 0.5, -14)
    vLogo.BackgroundTransparency = 1
    vLogo.Image = "rbxassetid://109613840581618"
    vLogo.ScaleType = Enum.ScaleType.Fit
    vLogo.ZIndex = 19

    local vTitle = Instance.new("TextLabel", vTop)
    vTitle.Size = UDim2.new(0, 80, 1, 0)
    vTitle.Position = UDim2.new(0.5, -20, 0, 0)
    vTitle.Text = "VaultX"
    vTitle.Font = Enum.Font.GothamBold
    vTitle.TextSize = 18
    vTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    vTitle.TextXAlignment = Enum.TextXAlignment.Left
    vTitle.BackgroundTransparency = 1
    vTitle.ZIndex = 19

    -- Hero Card: Profit / loss + Line Chart
    local vHero = Instance.new("Frame", vScroll)
    vHero.Size = UDim2.new(1, -36, 0, 240)
    vHero.Position = UDim2.new(0, 18, 0, 90)
    vHero.BackgroundColor3 = Color3.fromRGB(18, 24, 32)
    vHero.BorderSizePixel = 0
    vHero.ZIndex = 18
    Instance.new("UICorner", vHero).CornerRadius = UDim.new(0, 24)
    local vhs = Instance.new("UIStroke", vHero)
    vhs.Color = Color3.fromRGB(35, 48, 64)

    local plHead = Instance.new("TextLabel", vHero)
    plHead.Size = UDim2.new(0.5, 0, 0, 18)
    plHead.Position = UDim2.new(0, 16, 0, 14)
    plHead.Text = "🛡 Profit / loss"
    plHead.Font = Enum.Font.GothamBold
    plHead.TextSize = 12
    plHead.TextColor3 = Color3.fromRGB(160, 175, 195)
    plHead.TextXAlignment = Enum.TextXAlignment.Left
    plHead.BackgroundTransparency = 1
    plHead.ZIndex = 19

    local fcBtn = Instance.new("TextButton", vHero)
    fcBtn.Size = UDim2.new(0, 72, 0, 24)
    fcBtn.Position = UDim2.new(1, -86, 0, 12)
    fcBtn.BackgroundColor3 = Color3.fromRGB(30, 42, 58)
    fcBtn.Text = "Forecast"
    fcBtn.Font = Enum.Font.GothamBold
    fcBtn.TextSize = 11
    fcBtn.TextColor3 = Color3.fromRGB(180, 205, 235)
    fcBtn.BorderSizePixel = 0
    fcBtn.ZIndex = 19
    Instance.new("UICorner", fcBtn).CornerRadius = UDim.new(1, 0)

    local plAmount = Instance.new("TextLabel", vHero)
    plAmount.Size = UDim2.new(0.6, 0, 0, 36)
    plAmount.Position = UDim2.new(0, 16, 0, 40)
    plAmount.Text = "+$240.92"
    plAmount.Font = Enum.Font.GothamBold
    plAmount.TextSize = 30
    plAmount.TextColor3 = Color3.fromRGB(46, 229, 157)
    plAmount.TextXAlignment = Enum.TextXAlignment.Left
    plAmount.BackgroundTransparency = 1
    plAmount.ZIndex = 19

    local retTxt = Instance.new("TextLabel", vHero)
    retTxt.Size = UDim2.new(0.4, 0, 0, 16)
    retTxt.Position = UDim2.new(0.6, -16, 0, 40)
    retTxt.Text = "↗ 3.18%"
    retTxt.Font = Enum.Font.GothamBold
    retTxt.TextSize = 14
    retTxt.TextColor3 = Color3.fromRGB(46, 229, 157)
    retTxt.TextXAlignment = Enum.TextXAlignment.Right
    retTxt.BackgroundTransparency = 1
    retTxt.ZIndex = 19

    local retSub = Instance.new("TextLabel", vHero)
    retSub.Size = UDim2.new(0.4, 0, 0, 14)
    retSub.Position = UDim2.new(0.6, -16, 0, 56)
    retSub.Text = "Total return"
    retSub.Font = Enum.Font.Gotham
    retSub.TextSize = 10
    retSub.TextColor3 = Color3.fromRGB(140, 155, 175)
    retSub.TextXAlignment = Enum.TextXAlignment.Right
    retSub.BackgroundTransparency = 1
    retSub.ZIndex = 19

    -- Chart Area with Waveform Line
    local chartFrame = Instance.new("Frame", vHero)
    chartFrame.Size = UDim2.new(1, -32, 0, 75)
    chartFrame.Position = UDim2.new(0, 16, 0, 90)
    chartFrame.BackgroundColor3 = Color3.fromRGB(14, 18, 25)
    chartFrame.BorderSizePixel = 0
    chartFrame.ZIndex = 19
    Instance.new("UICorner", chartFrame).CornerRadius = UDim.new(0, 12)

    local chartLine = Instance.new("Frame", chartFrame)
    chartLine.Size = UDim2.new(0.7, 0, 0, 2.5)
    chartLine.Position = UDim2.new(0, 10, 0.5, 0)
    chartLine.BackgroundColor3 = Color3.fromRGB(46, 229, 157)
    chartLine.BorderSizePixel = 0
    chartLine.ZIndex = 20

    local curPos = Instance.new("Frame", chartFrame)
    curPos.Size = UDim2.new(0, 10, 0, 10)
    curPos.Position = UDim2.new(0.7, 5, 0.5, -4)
    curPos.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    curPos.BorderSizePixel = 0
    curPos.ZIndex = 21
    Instance.new("UICorner", curPos).CornerRadius = UDim.new(1, 0)

    local curPosPill = Instance.new("Frame", chartFrame)
    curPosPill.Size = UDim2.new(0, 80, 0, 18)
    curPosPill.Position = UDim2.new(0.7, -35, 0.5, -28)
    curPosPill.BackgroundColor3 = Color3.fromRGB(25, 32, 42)
    curPosPill.BorderSizePixel = 0
    curPosPill.ZIndex = 21
    Instance.new("UICorner", curPosPill).CornerRadius = UDim.new(1, 0)
    local cpTxt = Instance.new("TextLabel", curPosPill)
    cpTxt.Size = UDim2.new(1, 0, 1, 0)
    cpTxt.Text = "Current position"
    cpTxt.Font = Enum.Font.GothamBold
    cpTxt.TextSize = 8
    cpTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    cpTxt.BackgroundTransparency = 1
    cpTxt.ZIndex = 22

    -- Cash and Assets Footer inside Hero
    local acLabel = Instance.new("TextLabel", vHero)
    acLabel.Size = UDim2.new(0.5, 0, 0, 14)
    acLabel.Position = UDim2.new(0, 16, 1, -44)
    acLabel.Text = "Available cash"
    acLabel.Font = Enum.Font.Gotham
    acLabel.TextSize = 10.5
    acLabel.TextColor3 = Color3.fromRGB(140, 155, 175)
    acLabel.TextXAlignment = Enum.TextXAlignment.Left
    acLabel.BackgroundTransparency = 1
    acLabel.ZIndex = 19

    local acVal = Instance.new("TextLabel", vHero)
    acVal.Size = UDim2.new(0.5, 0, 0, 20)
    acVal.Position = UDim2.new(0, 16, 1, -26)
    acVal.Text = "$18,420.00"
    acVal.Font = Enum.Font.GothamBold
    acVal.TextSize = 14
    acVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    acVal.TextXAlignment = Enum.TextXAlignment.Left
    acVal.BackgroundTransparency = 1
    acVal.ZIndex = 19

    local iaLabel = Instance.new("TextLabel", vHero)
    iaLabel.Size = UDim2.new(0.5, 0, 0, 14)
    iaLabel.Position = UDim2.new(0.5, 0, 1, -44)
    iaLabel.Text = "Invested assets"
    iaLabel.Font = Enum.Font.Gotham
    iaLabel.TextSize = 10.5
    iaLabel.TextColor3 = Color3.fromRGB(140, 155, 175)
    iaLabel.TextXAlignment = Enum.TextXAlignment.Left
    iaLabel.BackgroundTransparency = 1
    iaLabel.ZIndex = 19

    local iaVal = Instance.new("TextLabel", vHero)
    iaVal.Size = UDim2.new(0.5, 0, 0, 20)
    iaVal.Position = UDim2.new(0.5, 0, 1, -26)
    iaVal.Text = "$7,820.69"
    iaVal.Font = Enum.Font.GothamBold
    iaVal.TextSize = 14
    iaVal.TextColor3 = Color3.fromRGB(255, 255, 255)
    iaVal.TextXAlignment = Enum.TextXAlignment.Left
    iaVal.BackgroundTransparency = 1
    iaVal.ZIndex = 19

    -- 4 Action Buttons Row
    local actRow = Instance.new("Frame", vScroll)
    actRow.Size = UDim2.new(1, -36, 0, 68)
    actRow.Position = UDim2.new(0, 18, 0, 345)
    actRow.BackgroundTransparency = 1
    actRow.ZIndex = 18
    local actLayout = Instance.new("UIListLayout", actRow)
    actLayout.FillDirection = Enum.FillDirection.Horizontal
    actLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actLayout.Padding = UDim.new(0, 8)

    local function makeCryptoActBtn(symbol, name)
        local btn = Instance.new("Frame", actRow)
        btn.Size = UDim2.new(0.23, 0, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
        btn.BorderSizePixel = 0
        btn.ZIndex = 19
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = Color3.fromRGB(35, 48, 64)

        local s = Instance.new("TextLabel", btn)
        s.Size = UDim2.new(1, 0, 0, 24)
        s.Position = UDim2.new(0, 0, 0, 10)
        s.Text = symbol
        s.TextSize = 18
        s.TextColor3 = Color3.fromRGB(46, 229, 157)
        s.BackgroundTransparency = 1
        s.ZIndex = 20

        local n = Instance.new("TextLabel", btn)
        n.Size = UDim2.new(1, 0, 0, 16)
        n.Position = UDim2.new(0, 0, 0, 38)
        n.Text = name
        n.Font = Enum.Font.GothamBold
        n.TextSize = 10.5
        n.TextColor3 = Color3.fromRGB(220, 230, 245)
        n.BackgroundTransparency = 1
        n.ZIndex = 20
    end

    makeCryptoActBtn("📊", "Trade")
    makeCryptoActBtn("↙", "Deposit")
    makeCryptoActBtn("↗", "Withdraw")
    makeCryptoActBtn("✈", "Send")

    -- Portfolio Allocation Card
    local allocCard = Instance.new("Frame", vScroll)
    allocCard.Size = UDim2.new(1, -36, 0, 85)
    allocCard.Position = UDim2.new(0, 18, 0, 428)
    allocCard.BackgroundColor3 = Color3.fromRGB(18, 24, 32)
    allocCard.BorderSizePixel = 0
    allocCard.ZIndex = 18
    Instance.new("UICorner", allocCard).CornerRadius = UDim.new(0, 20)
    local as = Instance.new("UIStroke", allocCard)
    as.Color = Color3.fromRGB(35, 48, 64)

    local alTitle = Instance.new("TextLabel", allocCard)
    alTitle.Size = UDim2.new(0.6, 0, 0, 14)
    alTitle.Position = UDim2.new(0, 52, 0, 16)
    alTitle.Text = "Portfolio allocation"
    alTitle.Font = Enum.Font.Gotham
    alTitle.TextSize = 10.5
    alTitle.TextColor3 = Color3.fromRGB(140, 155, 175)
    alTitle.TextXAlignment = Enum.TextXAlignment.Left
    alTitle.BackgroundTransparency = 1
    alTitle.ZIndex = 19

    local alSub = Instance.new("TextLabel", allocCard)
    alSub.Size = UDim2.new(0.6, 0, 0, 20)
    alSub.Position = UDim2.new(0, 52, 0, 32)
    alSub.Text = "30% in markets"
    alSub.Font = Enum.Font.GothamBold
    alSub.TextSize = 14
    alSub.TextColor3 = Color3.fromRGB(255, 255, 255)
    alSub.TextXAlignment = Enum.TextXAlignment.Left
    alSub.BackgroundTransparency = 1
    alSub.ZIndex = 19

    local alPct = Instance.new("TextLabel", allocCard)
    alPct.Size = UDim2.new(0.3, 0, 0, 20)
    alPct.Position = UDim2.new(0.7, -16, 0, 24)
    alPct.Text = "70%"
    alPct.Font = Enum.Font.GothamBold
    alPct.TextSize = 18
    alPct.TextColor3 = Color3.fromRGB(46, 229, 157)
    alPct.TextXAlignment = Enum.TextXAlignment.Right
    alPct.BackgroundTransparency = 1
    alPct.ZIndex = 19

    local barBg = Instance.new("Frame", allocCard)
    barBg.Size = UDim2.new(1, -32, 0, 4)
    barBg.Position = UDim2.new(0, 16, 1, -18)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 19
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(0.7, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(46, 229, 157)
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 20
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    -- Bottom Floating Dock
    local vDock = Instance.new("Frame", vaultxApp)
    vDock.Size = UDim2.new(1, -36, 0, 52)
    vDock.Position = UDim2.new(0, 18, 1, -72)
    vDock.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    vDock.BorderSizePixel = 0
    vDock.ZIndex = 25
    Instance.new("UICorner", vDock).CornerRadius = UDim.new(1, 0)
    local vds = Instance.new("UIStroke", vDock)
    vds.Color = Color3.fromRGB(35, 48, 64)

    local vdLayout = Instance.new("UIListLayout", vDock)
    vdLayout.FillDirection = Enum.FillDirection.Horizontal
    vdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    vdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    vdLayout.Padding = UDim.new(0, 16)

    local function makeCryptoTab(txt, iconTxt, isActive)
        local btn = Instance.new("TextButton", vDock)
        btn.Size = isActive and UDim2.new(0, 76, 0, 38) or UDim2.new(0, 56, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(32, 42, 58) or Color3.fromRGB(22, 28, 38)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(46, 229, 157) or Color3.fromRGB(140, 155, 175)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makeCryptoTab("Portfolio", "💼", true)
    makeCryptoTab("Markets", "📈", false)
    makeCryptoTab("Activity", "🕒", false)
    makeCryptoTab("Profile", "👤", false)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["VaultX"] = function(isLight)
            vaultxApp.BackgroundColor3 = isLight and Color3.fromRGB(242, 244, 248) or Color3.fromRGB(12, 15, 20)
            if vDock then
                vDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(16, 20, 28)
                if vds then vds.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(35, 45, 60) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(vaultxApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 22. CYBER SNAKE ARCADE GAME
-- ============================================================================
snakeApp = createBaseApp("Snake", Color3.fromRGB(15, 18, 25))
do
    local sHeader = Instance.new("Frame", snakeApp)
    sHeader.Size = UDim2.new(1, 0, 0, 50)
    sHeader.Position = UDim2.new(0, 0, 0, 35)
    sHeader.BackgroundTransparency = 1
    sHeader.ZIndex = 18

    local sTitle = Instance.new("TextLabel", sHeader)
    sTitle.Size = UDim2.new(1, -36, 1, 0)
    sTitle.Position = UDim2.new(0, 18, 0, 0)
    sTitle.Text = "🐍 Cyber Snake"
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextSize = 22
    sTitle.TextColor3 = Color3.fromRGB(52, 199, 89)
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    sTitle.BackgroundTransparency = 1
    sTitle.ZIndex = 19

    local scoreLbl = Instance.new("TextLabel", sHeader)
    scoreLbl.Size = UDim2.new(0, 80, 1, 0)
    scoreLbl.Position = UDim2.new(1, -98, 0, 0)
    scoreLbl.Text = "Score: 0"
    scoreLbl.Font = Enum.Font.GothamBold
    scoreLbl.TextSize = 14
    scoreLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    scoreLbl.TextXAlignment = Enum.TextXAlignment.Right
    scoreLbl.BackgroundTransparency = 1
    scoreLbl.ZIndex = 19

    local board = Instance.new("Frame", snakeApp)
    board.Name = "Board"
    board.Size = UDim2.new(0, 240, 0, 240)
    board.Position = UDim2.new(0.5, -120, 0, 95)
    board.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
    board.BorderSizePixel = 0
    board.ZIndex = 18
    Instance.new("UICorner", board).CornerRadius = UDim.new(0, 16)
    local bs = Instance.new("UIStroke", board)
    bs.Color = Color3.fromRGB(45, 55, 75)

    -- Snake Game Logic
    local GRID_SIZE = 12
    local CELL_SIZE = 20
    local snake = {{x = 6, y = 6}, {x = 5, y = 6}}
    local dir = {x = 1, y = 0}
    local food = {x = 9, y = 6}
    local score = 0
    local isPlaying = false

    local function spawnFood()
        food.x = math.random(1, GRID_SIZE)
        food.y = math.random(1, GRID_SIZE)
    end

    local cellFrames = {}
    local function redraw()
        for _, f in ipairs(cellFrames) do f:Destroy() end
        cellFrames = {}

        -- Draw Food
        local ff = Instance.new("Frame", board)
        ff.Size = UDim2.new(0, CELL_SIZE - 2, 0, CELL_SIZE - 2)
        ff.Position = UDim2.new(0, (food.x - 1) * CELL_SIZE + 1, 0, (food.y - 1) * CELL_SIZE + 1)
        ff.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
        ff.BorderSizePixel = 0
        ff.ZIndex = 19
        Instance.new("UICorner", ff).CornerRadius = UDim.new(1, 0)
        table.insert(cellFrames, ff)

        -- Draw Snake
        for idx, part in ipairs(snake) do
            local sf = Instance.new("Frame", board)
            sf.Size = UDim2.new(0, CELL_SIZE - 2, 0, CELL_SIZE - 2)
            sf.Position = UDim2.new(0, (part.x - 1) * CELL_SIZE + 1, 0, (part.y - 1) * CELL_SIZE + 1)
            sf.BackgroundColor3 = (idx == 1) and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(40, 160, 70)
            sf.BorderSizePixel = 0
            sf.ZIndex = 19
            Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 4)
            table.insert(cellFrames, sf)
        end
    end

    -- Controls
    local ctrlFrame = Instance.new("Frame", snakeApp)
    ctrlFrame.Size = UDim2.new(0, 180, 0, 130)
    ctrlFrame.Position = UDim2.new(0.5, -90, 0, 355)
    ctrlFrame.BackgroundTransparency = 1
    ctrlFrame.ZIndex = 18

    local function makeArrow(txt, xPos, yPos, dx, dy)
        local btn = Instance.new("TextButton", ctrlFrame)
        btn.Size = UDim2.new(0, 48, 0, 42)
        btn.Position = UDim2.new(0, xPos, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
        btn.Text = txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        btn.ZIndex = 19
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

        btn.MouseButton1Click:Connect(function()
            playTone()
            if not isPlaying then isPlaying = true end
            if dx ~= -dir.x and dy ~= -dir.y then
                dir = {x = dx, y = dy}
            end
        end)
    end

    makeArrow("▲", 66, 0, 0, -1)
    makeArrow("◀", 12, 44, -1, 0)
    makeArrow("▼", 66, 44, 0, 1)
    makeArrow("▶", 120, 44, 1, 0)

    local startBtn = Instance.new("TextButton", snakeApp)
    startBtn.Size = UDim2.new(0, 120, 0, 36)
    startBtn.Position = UDim2.new(0.5, -60, 1, -55)
    startBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    startBtn.Text = "Play Game"
    startBtn.Font = Enum.Font.GothamBold
    startBtn.TextSize = 14
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    startBtn.BorderSizePixel = 0
    startBtn.ZIndex = 20
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(1, 0)

    startBtn.MouseButton1Click:Connect(function()
        playTone()
        snake = {{x = 6, y = 6}, {x = 5, y = 6}}
        dir = {x = 1, y = 0}
        score = 0
        scoreLbl.Text = "Score: 0"
        spawnFood()
        isPlaying = true
        startBtn.Text = "Restart"

        task.spawn(function()
            while isPlaying do
                task.wait(0.2)
                local head = snake[1]
                local newHead = {x = head.x + dir.x, y = head.y + dir.y}

                if newHead.x < 1 or newHead.x > GRID_SIZE or newHead.y < 1 or newHead.y > GRID_SIZE then
                    isPlaying = false
                    startBtn.Text = "Game Over"
                    break
                end

                table.insert(snake, 1, newHead)
                if newHead.x == food.x and newHead.y == food.y then
                    score = score + 10
                    scoreLbl.Text = "Score: " .. score
                    spawnFood()
                else
                    table.remove(snake)
                end
                redraw()
            end
        end)
    end)
    redraw()
end

-- ============================================================================
-- 23. ECOSYSTEM APPS (Rich Layouts for All 20+ Remaining Apps)
-- ============================================================================
local function createEcosystemApp(appName, title, iconSymbol, themeColor, category, descText)
    local app = createBaseApp(appName, Color3.fromRGB(244, 245, 248))
    local aHeader = Instance.new("Frame", app)
    aHeader.Size = UDim2.new(1, 0, 0, 60)
    aHeader.Position = UDim2.new(0, 0, 0, 36)
    aHeader.BackgroundTransparency = 1
    aHeader.ZIndex = 18

    local aIco = Instance.new("Frame", aHeader)
    aIco.Size = UDim2.new(0, 44, 0, 44)
    aIco.Position = UDim2.new(0, 18, 0.5, -22)
    aIco.BackgroundColor3 = themeColor
    aIco.BorderSizePixel = 0
    aIco.ZIndex = 19
    Instance.new("UICorner", aIco).CornerRadius = UDim.new(0, 14)

    local aIcoTxt = Instance.new("TextLabel", aIco)
    aIcoTxt.Size = UDim2.new(1, 0, 1, 0)
    aIcoTxt.Text = iconSymbol
    aIcoTxt.TextSize = 22
    aIcoTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    aIcoTxt.BackgroundTransparency = 1
    aIcoTxt.ZIndex = 20

    local aTitle = Instance.new("TextLabel", aHeader)
    aTitle.Size = UDim2.new(1, -80, 0, 24)
    aTitle.Position = UDim2.new(0, 72, 0, 8)
    aTitle.Text = title
    aTitle.Font = Enum.Font.GothamBold
    aTitle.TextSize = 20
    aTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    aTitle.TextXAlignment = Enum.TextXAlignment.Left
    aTitle.BackgroundTransparency = 1
    aTitle.ZIndex = 19

    local aCat = Instance.new("TextLabel", aHeader)
    aCat.Size = UDim2.new(1, -80, 0, 16)
    aCat.Position = UDim2.new(0, 72, 0, 32)
    aCat.Text = category
    aCat.Font = Enum.Font.Gotham
    aCat.TextSize = 12
    aCat.TextColor3 = Color3.fromRGB(140, 145, 160)
    aCat.TextXAlignment = Enum.TextXAlignment.Left
    aCat.BackgroundTransparency = 1
    aCat.ZIndex = 19

    local aCard = Instance.new("Frame", app)
    aCard.Size = UDim2.new(1, -36, 0, 220)
    aCard.Position = UDim2.new(0, 18, 0, 110)
    aCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    aCard.BorderSizePixel = 0
    aCard.ZIndex = 18
    Instance.new("UICorner", aCard).CornerRadius = UDim.new(0, 20)
    local acs = Instance.new("UIStroke", aCard)
    acs.Color = Color3.fromRGB(230, 234, 244)

    local cText = Instance.new("TextLabel", aCard)
    cText.Size = UDim2.new(1, -32, 0, 60)
    cText.Position = UDim2.new(0, 16, 0, 16)
    cText.Text = descText
    cText.Font = Enum.Font.GothamMedium
    cText.TextSize = 14
    cText.TextColor3 = Color3.fromRGB(40, 45, 60)
    cText.TextWrapped = true
    cText.TextXAlignment = Enum.TextXAlignment.Left
    cText.BackgroundTransparency = 1
    cText.ZIndex = 19

    local actBtn = Instance.new("TextButton", aCard)
    actBtn.Size = UDim2.new(1, -32, 0, 42)
    actBtn.Position = UDim2.new(0, 16, 1, -58)
    actBtn.BackgroundColor3 = themeColor
    actBtn.Text = "Open " .. title
    actBtn.Font = Enum.Font.GothamBold
    actBtn.TextSize = 14
    actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actBtn.BorderSizePixel = 0
    actBtn.ZIndex = 19
    Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 12)
    actBtn.MouseButton1Click:Connect(playTone)

    local function updateTheme(isLight)
        app.BackgroundColor3 = isLight and Color3.fromRGB(244, 245, 248) or Color3.fromRGB(0, 0, 0)
        aTitle.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255)
        aCat.TextColor3 = isLight and Color3.fromRGB(140, 145, 160) or Color3.fromRGB(142, 142, 147)
        aCard.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
        acs.Color = isLight and Color3.fromRGB(230, 234, 244) or Color3.fromRGB(44, 44, 46)
        cText.TextColor3 = isLight and Color3.fromRGB(40, 45, 60) or Color3.fromRGB(220, 224, 235)
    end
    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters[appName] = updateTheme
    end

    return app
end

createEcosystemApp("AppStore", "App Store", "🛍", Color3.fromRGB(0, 122, 255), "Featured & Utilities", "Discover verified applications, games, and city utilities curated for your Sky Phone.")
createEcosystemApp("Map", "Los Santos Maps", "🗺", Color3.fromRGB(52, 199, 89), "Navigation & GPS", "High-definition satellite navigation with turn-by-turn routing across San Andreas.")
createEcosystemApp("Memory", "Memory Match", "⭐", Color3.fromRGB(175, 82, 222), "Arcade & Puzzle", "Test your cognitive reflexes with high-speed card pattern matching.")
createEcosystemApp("2048", "2048 Blocks", "🔢", Color3.fromRGB(255, 149, 0), "Number Puzzle", "Swipe to merge matching numbers and reach the fabled 2048 tile!")
createEcosystemApp("Minesweeper", "Minesweeper", "🚩", Color3.fromRGB(90, 200, 250), "Classic Strategy", "Clear the minefield without detonating hidden explosives.")
createEcosystemApp("TowerStack", "Tower Stack", "🏗", Color3.fromRGB(255, 45, 85), "Reflex Arcade", "Stack moving platforms with millimeter precision to reach the stratosphere.")
createEcosystemApp("SkyFlappy", "Sky Flappy", "🐦", Color3.fromRGB(88, 86, 214), "Flight Arcade", "Navigate through narrow pillars in this intense aerial reaction test.")
createEcosystemApp("NeonDrop", "Neon Drop", "🕹", Color3.fromRGB(0, 195, 255), "Block Puzzle", "Arrange falling neon tetrominoes to clear rows in retro synthwave style.")
createEcosystemApp("CityMarkt", "CityMarkt", "🏷", Color3.fromRGB(255, 149, 0), "Marketplace", "Browse local classifieds, vehicles, properties, and community listings.")
createEcosystemApp("LocalPages", "Local Pages", "📰", Color3.fromRGB(0, 122, 255), "City Directory", "Search business telephone numbers, emergency hotlines, and civic services.")
createEcosystemApp("Radio", "Police & Scanner Radio", "📻", Color3.fromRGB(255, 59, 48), "Communications", "Tune into active patrol channels, dispatch frequencies, and community streams.")
createEcosystemApp("FlipTok", "FlipTok", "▶", Color3.fromRGB(255, 45, 85), "Short-Form Video", "Stream viral city clips, creative shorts, and live creator broadcasts.")
createEcosystemApp("DarkChat", "DarkChat", "🔒", Color3.fromRGB(88, 86, 214), "Encrypted Channels", "End-to-end encrypted messaging channels for discreet operations.")
createEcosystemApp("Picstagram", "Picstagram", "📸", Color3.fromRGB(255, 95, 105), "Photo Social", "Share moments, filter captures, and connect with followers across Vinewood.")
createEcosystemApp("Flare", "Flare", "🔥", Color3.fromRGB(255, 69, 58), "Dating & Meetups", "Swipe and meet active players, crew members, and friends nearby.")
createEcosystemApp("Feather", "Feather", "🪶", Color3.fromRGB(175, 82, 222), "Microblogging", "Post thoughts, news headlines, and join trending discussions in real-time.")
createEcosystemApp("House", "Smart Home", "🏠", Color3.fromRGB(255, 149, 0), "Home Automation", "Control garage gates, interior lighting, and home security locks remotely.")
createEcosystemApp("SkyRide", "SkyRide Taxi", "🚕", Color3.fromRGB(0, 122, 255), "Ride Hail", "Request on-demand transportation anywhere in Los Santos with upfront fare estimates.")
createEcosystemApp("CrewLink", "CrewLink", "👥", Color3.fromRGB(52, 199, 89), "Organizations", "Coordinate organization rosters, event schedules, and bank vaults.")
createEcosystemApp("Companies", "Companies Portal", "🏢", Color3.fromRGB(0, 122, 255), "Enterprise Management", "Manage commercial registries, payroll, employee access, and tax records.")
createEcosystemApp("WeazelNews", "Weazel News", "📰", Color3.fromRGB(255, 59, 48), "Journalism", "Breaking city news alerts, investigative journalism, and traffic reports.")
createEcosystemApp("CityWarn", "CityWarn Alerts", "🚨", Color3.fromRGB(0, 122, 255), "Emergency Civil Defense", "Official broadcast alerts for extreme weather, road closures, and city advisories.")

return { name = "GarageVaultXGames" }
