-- ============================================================================
-- 4. PHONE APP (Matching official_phone.png: Recents + Keypad + In-Call Timer)
-- ============================================================================
phoneApp = createBaseApp("Phone", Color3.fromRGB(242, 244, 248))
do
    -- Main Recents View Frame
    local recentsFrame = Instance.new("Frame", phoneApp)
    recentsFrame.Name = "RecentsView"
    recentsFrame.Size = UDim2.new(1, 0, 1, 0)
    recentsFrame.BackgroundTransparency = 1
    recentsFrame.ZIndex = 17

    -- Top Segmented Control (All | Missed)
    local segFrame = Instance.new("Frame", recentsFrame)
    segFrame.Name = "SegmentedControl"
    segFrame.AnchorPoint = Vector2.new(0.5, 0)
    segFrame.Position = UDim2.new(0.5, 0, 0, 48)
    segFrame.Size = UDim2.new(0, 140, 0, 32)
    segFrame.BackgroundColor3 = Color3.fromRGB(228, 230, 235)
    segFrame.BorderSizePixel = 0
    segFrame.ZIndex = 18
    Instance.new("UICorner", segFrame).CornerRadius = UDim.new(0, 16)

    local segAll = Instance.new("TextButton", segFrame)
    segAll.Size = UDim2.new(0.5, -2, 1, -4)
    segAll.Position = UDim2.new(0, 2, 0, 2)
    segAll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    segAll.Text = "All"
    segAll.Font = Enum.Font.GothamBold
    segAll.TextSize = 12
    segAll.TextColor3 = Color3.fromRGB(20, 22, 28)
    segAll.BorderSizePixel = 0
    segAll.ZIndex = 19
    Instance.new("UICorner", segAll).CornerRadius = UDim.new(0, 14)

    local segMissed = Instance.new("TextButton", segFrame)
    segMissed.Size = UDim2.new(0.5, -2, 1, -4)
    segMissed.Position = UDim2.new(0.5, 0, 0, 2)
    segMissed.BackgroundTransparency = 1
    segMissed.Text = "Missed"
    segMissed.Font = Enum.Font.GothamMedium
    segMissed.TextSize = 12
    segMissed.TextColor3 = Color3.fromRGB(120, 125, 140)
    segMissed.ZIndex = 19

    -- Header Title: "Recents"
    local pTitle = Instance.new("TextLabel", recentsFrame)
    pTitle.Size = UDim2.new(1, -36, 0, 38)
    pTitle.Position = UDim2.new(0, 18, 0, 88)
    pTitle.BackgroundTransparency = 1
    pTitle.Text = "Recents"
    pTitle.Font = Enum.Font.GothamBold
    pTitle.TextSize = 34
    pTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    pTitle.TextXAlignment = Enum.TextXAlignment.Left
    pTitle.ZIndex = 18

    -- Search Calls Pill
    local pSearch = Instance.new("Frame", recentsFrame)
    pSearch.Size = UDim2.new(1, -36, 0, 36)
    pSearch.Position = UDim2.new(0, 18, 0, 134)
    pSearch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pSearch.BorderSizePixel = 0
    pSearch.ZIndex = 18
    Instance.new("UICorner", pSearch).CornerRadius = UDim.new(0, 18)
    local pSearchStroke = Instance.new("UIStroke", pSearch)
    pSearchStroke.Color = Color3.fromRGB(225, 228, 238)
    pSearchStroke.Thickness = 1

    local pSearchText = Instance.new("TextLabel", pSearch)
    pSearchText.Size = UDim2.new(1, -24, 1, 0)
    pSearchText.Position = UDim2.new(0, 12, 0, 0)
    pSearchText.BackgroundTransparency = 1
    pSearchText.Text = "🔍 Search Calls"
    pSearchText.Font = Enum.Font.GothamMedium
    pSearchText.TextSize = 13
    pSearchText.TextColor3 = Color3.fromRGB(145, 150, 165)
    pSearchText.TextXAlignment = Enum.TextXAlignment.Left
    pSearchText.ZIndex = 19

    -- Call List ScrollFrame
    local callScroll = Instance.new("ScrollingFrame", recentsFrame)
    callScroll.Size = UDim2.new(1, 0, 1, -250)
    callScroll.Position = UDim2.new(0, 0, 0, 180)
    callScroll.BackgroundTransparency = 1
    callScroll.ScrollBarThickness = 0
    callScroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    callScroll.ZIndex = 18

    local callList = Instance.new("UIListLayout", callScroll)
    callList.FillDirection = Enum.FillDirection.Vertical
    callList.SortOrder = Enum.SortOrder.LayoutOrder
    callList.Padding = UDim.new(0, 1)

    local function makeCallRow(name, statusTxt, timeTxt, avatarType, isMissed, order)
        local row = Instance.new("TextButton", callScroll)
        row.Size = UDim2.new(1, 0, 0, 64)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = order
        row.ZIndex = 19

        local av = Instance.new("Frame", row)
        av.Size = UDim2.new(0, 44, 0, 44)
        av.Position = UDim2.new(0, 18, 0.5, -22)
        av.BackgroundColor3 = Color3.fromRGB(100, 105, 120)
        av.BorderSizePixel = 0
        av.ZIndex = 20
        Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

        if avatarType == "car" then
            local img = Instance.new("ImageLabel", av)
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://131470370579445"
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 21
            Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        elseif avatarType == "taxi" then
            local img = Instance.new("ImageLabel", av)
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://87510415537199"
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 21
            Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        else
            local avLetter = Instance.new("TextLabel", av)
            avLetter.Size = UDim2.new(1, 0, 1, 0)
            avLetter.BackgroundTransparency = 1
            avLetter.Text = avatarType
            avLetter.Font = Enum.Font.GothamBold
            avLetter.TextSize = 18
            avLetter.TextColor3 = Color3.fromRGB(255, 255, 255)
            avLetter.ZIndex = 21
        end

        local nLabel = Instance.new("TextLabel", row)
        nLabel.Size = UDim2.new(1, -170, 0, 20)
        nLabel.Position = UDim2.new(0, 72, 0, 12)
        nLabel.BackgroundTransparency = 1
        nLabel.Text = name
        nLabel.Font = Enum.Font.GothamBold
        nLabel.TextSize = 16
        nLabel.TextColor3 = isMissed and Color3.fromRGB(255, 59, 48) or Color3.fromRGB(15, 18, 28)
        nLabel.TextXAlignment = Enum.TextXAlignment.Left
        nLabel.ZIndex = 20

        local sLabel = Instance.new("TextLabel", row)
        sLabel.Size = UDim2.new(1, -170, 0, 16)
        sLabel.Position = UDim2.new(0, 72, 0, 34)
        sLabel.BackgroundTransparency = 1
        sLabel.Text = statusTxt
        sLabel.Font = Enum.Font.Gotham
        sLabel.TextSize = 12
        sLabel.TextColor3 = Color3.fromRGB(140, 145, 160)
        sLabel.TextXAlignment = Enum.TextXAlignment.Left
        sLabel.ZIndex = 20

        local tLabel = Instance.new("TextLabel", row)
        tLabel.Size = UDim2.new(0, 75, 0, 16)
        tLabel.Position = UDim2.new(1, -128, 0.5, -8)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = timeTxt
        tLabel.Font = Enum.Font.Gotham
        tLabel.TextSize = 12
        tLabel.TextColor3 = Color3.fromRGB(140, 145, 160)
        tLabel.TextXAlignment = Enum.TextXAlignment.Right
        tLabel.ZIndex = 20

        -- Circular info (i) button
        local infoBtn = Instance.new("TextButton", row)
        infoBtn.Size = UDim2.new(0, 28, 0, 28)
        infoBtn.Position = UDim2.new(1, -44, 0.5, -14)
        infoBtn.BackgroundColor3 = Color3.fromRGB(242, 244, 248)
        infoBtn.BackgroundTransparency = 0
        infoBtn.Text = "ⓘ"
        infoBtn.Font = Enum.Font.GothamMedium
        infoBtn.TextSize = 16
        infoBtn.TextColor3 = Color3.fromRGB(140, 145, 165)
        infoBtn.ZIndex = 20
        Instance.new("UICorner", infoBtn).CornerRadius = UDim.new(1, 0)
        local isStroke = Instance.new("UIStroke", infoBtn)
        isStroke.Color = Color3.fromRGB(220, 224, 236)
        isStroke.Thickness = 1

        local div = Instance.new("Frame", row)
        div.Size = UDim2.new(1, -72, 0, 1)
        div.Position = UDim2.new(0, 72, 1, -1)
        div.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
        div.BorderSizePixel = 0
        div.ZIndex = 20
    end

    makeCallRow("Alex Rivera", "📞 Call Ended", "02:52 AM", "car", false, 1)
    makeCallRow("Morgan Reed", "📞 Call Ended", "02:42 AM", "M", false, 2)
    makeCallRow("Los Santos Taxi", "📞 Call Ended", "02:18 AM", "taxi", false, 3)
    makeCallRow("Jamie Chen", "📞 Missed", "01:25 AM", "J", true, 4)
    makeCallRow("Emily Hart", "📞 No Answer", "Sunday", "E", true, 5)
    makeCallRow("Yakup Broooooo", "📞 Call Ended", "Sunday", "Y", false, 6)

    -- KEYPAD VIEW (Hidden by default, toggled via bottom dock)
    local keypadFrame = Instance.new("Frame", phoneApp)
    keypadFrame.Name = "KeypadView"
    keypadFrame.Size = UDim2.new(1, 0, 1, 0)
    keypadFrame.BackgroundTransparency = 1
    keypadFrame.Visible = false
    keypadFrame.ZIndex = 17

    local pNumber = Instance.new("TextLabel", keypadFrame)
    pNumber.Name = "NumberDisplay"
    pNumber.Size = UDim2.new(1, -50, 0, 50)
    pNumber.Position = UDim2.new(0, 25, 0, 70)
    pNumber.BackgroundTransparency = 1
    pNumber.Text = ""
    pNumber.TextColor3 = Color3.fromRGB(15, 18, 28)
    pNumber.Font = Enum.Font.GothamBold
    pNumber.TextSize = 34
    pNumber.TextXAlignment = Enum.TextXAlignment.Center
    pNumber.ZIndex = 18

    local backBtn = Instance.new("TextButton", keypadFrame)
    backBtn.Size = UDim2.new(0, 36, 0, 36)
    backBtn.Position = UDim2.new(1, -48, 0, 78)
    backBtn.BackgroundTransparency = 1
    backBtn.Text = "⌫"
    backBtn.Font = Enum.Font.GothamBold
    backBtn.TextSize = 22
    backBtn.TextColor3 = Color3.fromRGB(140, 145, 160)
    backBtn.ZIndex = 19
    backBtn.MouseButton1Click:Connect(function()
        playTone()
        if #pNumber.Text > 0 then
            pNumber.Text = string.sub(pNumber.Text, 1, #pNumber.Text - 1)
        end
    end)

    local dialPad = Instance.new("Frame", keypadFrame)
    dialPad.Name = "DialPad"
    dialPad.AnchorPoint = Vector2.new(0.5, 0)
    dialPad.Position = UDim2.new(0.5, 0, 0, 140)
    dialPad.Size = UDim2.new(0, 250, 0, 330)
    dialPad.BackgroundTransparency = 1
    dialPad.ZIndex = 18

    local dpLayout = Instance.new("UIGridLayout", dialPad)
    dpLayout.CellSize = UDim2.new(0, 68, 0, 68)
    dpLayout.CellPadding = UDim2.new(0, 22, 0, 14)
    dpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local keys = {
        {"1", ""}, {"2", "ABC"}, {"3", "DEF"},
        {"4", "GHI"}, {"5", "JKL"}, {"6", "MNO"},
        {"7", "PQRS"}, {"8", "TUV"}, {"9", "WXYZ"},
        {"*", ""}, {"0", "+"}, {"#", ""}
    }

    for idx, key in ipairs(keys) do
        local b = Instance.new("TextButton", dialPad)
        b.Size = UDim2.new(0, 68, 0, 68)
        b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = ""
        b.AutoButtonColor = false
        b.ZIndex = 19
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        local bs = Instance.new("UIStroke", b)
        bs.Color = Color3.fromRGB(225, 228, 238)

        local mainD = Instance.new("TextLabel", b)
        mainD.Size = UDim2.new(1, 0, 0, 32)
        mainD.Position = UDim2.new(0, 0, 0, 10)
        mainD.BackgroundTransparency = 1
        mainD.Text = key[1]
        mainD.Font = Enum.Font.Gotham
        mainD.TextSize = 28
        mainD.TextColor3 = Color3.fromRGB(15, 18, 28)
        mainD.ZIndex = 20

        if key[2] ~= "" then
            local subD = Instance.new("TextLabel", b)
            subD.Size = UDim2.new(1, 0, 0, 14)
            subD.Position = UDim2.new(0, 0, 0, 42)
            subD.BackgroundTransparency = 1
            subD.Text = key[2]
            subD.Font = Enum.Font.GothamBold
            subD.TextSize = 8.5
            subD.TextColor3 = Color3.fromRGB(140, 145, 160)
            subD.ZIndex = 20
        end

        b.MouseButton1Click:Connect(function()
            playTone()
            pNumber.Text = pNumber.Text .. key[1]
        end)
    end

    -- Call Button
    local callActionBtn = Instance.new("TextButton", keypadFrame)
    callActionBtn.AnchorPoint = Vector2.new(0.5, 0)
    callActionBtn.Position = UDim2.new(0.5, 0, 0, 490)
    callActionBtn.Size = UDim2.new(0, 68, 0, 68)
    callActionBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    callActionBtn.Text = "📞"
    callActionBtn.Font = Enum.Font.GothamBold
    callActionBtn.TextSize = 28
    callActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    callActionBtn.ZIndex = 19
    Instance.new("UICorner", callActionBtn).CornerRadius = UDim.new(1, 0)

    -- IN-CALL ACTIVE SCREEN WITH DURATION TIMER
    local inCallFrame = Instance.new("Frame", phoneApp)
    inCallFrame.Name = "InCallScreen"
    inCallFrame.Size = UDim2.new(1, 0, 1, 0)
    inCallFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    inCallFrame.Visible = false
    inCallFrame.ZIndex = 30

    local inCallContact = Instance.new("TextLabel", inCallFrame)
    inCallContact.Size = UDim2.new(1, 0, 0, 36)
    inCallContact.Position = UDim2.new(0, 0, 0, 100)
    inCallContact.BackgroundTransparency = 1
    inCallContact.Text = "Alex Rivera"
    inCallContact.Font = Enum.Font.GothamBold
    inCallContact.TextSize = 28
    inCallContact.TextColor3 = Color3.fromRGB(255, 255, 255)
    inCallContact.ZIndex = 31

    local inCallTimer = Instance.new("TextLabel", inCallFrame)
    inCallTimer.Size = UDim2.new(1, 0, 0, 24)
    inCallTimer.Position = UDim2.new(0, 0, 0, 142)
    inCallTimer.BackgroundTransparency = 1
    inCallTimer.Text = "00:00"
    inCallTimer.Font = Enum.Font.GothamMedium
    inCallTimer.TextSize = 16
    inCallTimer.TextColor3 = Color3.fromRGB(160, 165, 185)
    inCallTimer.ZIndex = 31

    local inCallEndBtn = Instance.new("TextButton", inCallFrame)
    inCallEndBtn.AnchorPoint = Vector2.new(0.5, 1)
    inCallEndBtn.Position = UDim2.new(0.5, 0, 1, -60)
    inCallEndBtn.Size = UDim2.new(0, 72, 0, 72)
    inCallEndBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    inCallEndBtn.Text = "📞"
    inCallEndBtn.Font = Enum.Font.GothamBold
    inCallEndBtn.TextSize = 30
    inCallEndBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    inCallEndBtn.ZIndex = 32
    Instance.new("UICorner", inCallEndBtn).CornerRadius = UDim.new(1, 0)

    local isCalling = false
    local callSeconds = 0

    local function startCall(name)
        inCallContact.Text = name or (#pNumber.Text > 0 and pNumber.Text or "Alex Rivera")
        inCallFrame.Visible = true
        isCalling = true
        callSeconds = 0
        task.spawn(function()
            while isCalling do
                task.wait(1)
                callSeconds = callSeconds + 1
                local m = math.floor(callSeconds / 60)
                local s = callSeconds % 60
                inCallTimer.Text = string.format("%02d:%02d", m, s)
            end
        end)
    end

    callActionBtn.MouseButton1Click:Connect(function()
        playTone()
        startCall(pNumber.Text)
    end)

    inCallEndBtn.MouseButton1Click:Connect(function()
        playTone()
        isCalling = false
        inCallFrame.Visible = false
    end)

    -- Bottom Floating Dock (Recents | Contacts | Keypad)
    local phoneDock = Instance.new("Frame", phoneApp)
    phoneDock.Name = "PhoneDock"
    phoneDock.AnchorPoint = Vector2.new(0.5, 1)
    phoneDock.Position = UDim2.new(0.5, 0, 1, -20)
    phoneDock.Size = UDim2.new(1, -36, 0, 52)
    phoneDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    phoneDock.BorderSizePixel = 0
    phoneDock.ZIndex = 25
    Instance.new("UICorner", phoneDock).CornerRadius = UDim.new(1, 0)
    local pds = Instance.new("UIStroke", phoneDock)
    pds.Color = Color3.fromRGB(225, 228, 238)

    local pdLayout = Instance.new("UIListLayout", phoneDock)
    pdLayout.FillDirection = Enum.FillDirection.Horizontal
    pdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    pdLayout.Padding = UDim.new(0, 16)

    local function makePhoneDockTab(txt, iconTxt, isActive, onClick)
        local btn = Instance.new("TextButton", phoneDock)
        btn.Size = isActive and UDim2.new(0, 72, 0, 38) or UDim2.new(0, 56, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(235, 238, 245) or Color3.fromRGB(255, 255, 255)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(140, 145, 160)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        btn.MouseButton1Click:Connect(function()
            playTone()
            onClick()
        end)
    end

    makePhoneDockTab("Recents", "🕒", true, function()
        recentsFrame.Visible = true
        keypadFrame.Visible = false
    end)
    makePhoneDockTab("Contacts", "👤", false, function()
        recentsFrame.Visible = true
        keypadFrame.Visible = false
    end)
    makePhoneDockTab("Keypad", "📞", false, function()
        recentsFrame.Visible = false
        keypadFrame.Visible = true
    end)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Phone"] = function(isLight)
            phoneApp.BackgroundColor3 = isLight and Color3.fromRGB(242, 244, 248) or Color3.fromRGB(0, 0, 0)
            if segFrame then segFrame.BackgroundColor3 = isLight and Color3.fromRGB(228, 230, 235) or Color3.fromRGB(36, 36, 38) end
            if segAll then
                segAll.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(99, 99, 102)
                segAll.TextColor3 = isLight and Color3.fromRGB(20, 22, 28) or Color3.fromRGB(255, 255, 255)
            end
            if segMissed then
                segMissed.TextColor3 = isLight and Color3.fromRGB(120, 125, 140) or Color3.fromRGB(160, 165, 175)
            end
            if pTitle then pTitle.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255) end
            if pSearch then
                pSearch.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
                if pSearchStroke then pSearchStroke.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if pSearchText then pSearchText.TextColor3 = isLight and Color3.fromRGB(145, 150, 165) or Color3.fromRGB(142, 142, 147) end
            if phoneDock then
                phoneDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(24, 24, 26)
                if pds then pds.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(phoneApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 5. MESSAGES APP (Matching official_messages.png: Light Theme + Dots + Chat)
-- ============================================================================
msgApp = createBaseApp("Messages", Color3.fromRGB(248, 249, 252))
do
    local msgListView = Instance.new("Frame", msgApp)
    msgListView.Name = "MessagesListView"
    msgListView.Size = UDim2.new(1, 0, 1, 0)
    msgListView.BackgroundTransparency = 1
    msgListView.ZIndex = 17

    -- Top Right Menu Button "···"
    local mMenu = Instance.new("TextButton", msgListView)
    mMenu.Size = UDim2.new(0, 38, 0, 38)
    mMenu.Position = UDim2.new(1, -54, 0, 48)
    mMenu.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mMenu.BorderSizePixel = 0
    mMenu.Text = "···"
    mMenu.Font = Enum.Font.GothamBold
    mMenu.TextSize = 20
    mMenu.TextColor3 = Color3.fromRGB(15, 18, 28)
    mMenu.ZIndex = 18
    Instance.new("UICorner", mMenu).CornerRadius = UDim.new(1, 0)
    local mms = Instance.new("UIStroke", mMenu)
    mms.Color = Color3.fromRGB(225, 228, 238)

    -- Title: Messages
    local mTitle = Instance.new("TextLabel", msgListView)
    mTitle.Size = UDim2.new(1, -36, 0, 38)
    mTitle.Position = UDim2.new(0, 18, 0, 88)
    mTitle.BackgroundTransparency = 1
    mTitle.Text = "Messages"
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 34
    mTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.ZIndex = 18

    -- Contact Rows
    local mScroll = Instance.new("ScrollingFrame", msgListView)
    mScroll.Size = UDim2.new(1, 0, 1, -210)
    mScroll.Position = UDim2.new(0, 0, 0, 138)
    mScroll.BackgroundTransparency = 1
    mScroll.ScrollBarThickness = 0
    mScroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    mScroll.ZIndex = 18

    local msLayout = Instance.new("UIListLayout", mScroll)
    msLayout.FillDirection = Enum.FillDirection.Vertical
    msLayout.Padding = UDim.new(0, 1)

    local chatThreadView = Instance.new("Frame", msgApp)
    chatThreadView.Name = "ChatThreadView"
    chatThreadView.Size = UDim2.new(1, 0, 1, 0)
    chatThreadView.BackgroundColor3 = Color3.fromRGB(248, 249, 252)
    chatThreadView.Visible = false
    chatThreadView.ZIndex = 25

    local function makeMsgRow(name, previewTxt, timeTxt, avatarType, hasGreenDot, order)
        local row = Instance.new("TextButton", mScroll)
        row.Size = UDim2.new(1, 0, 0, 68)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = order
        row.ZIndex = 19

        if hasGreenDot then
            local dot = Instance.new("Frame", row)
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = UDim2.new(0, 8, 0.5, -4)
            dot.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
            dot.BorderSizePixel = 0
            dot.ZIndex = 20
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        end

        local av = Instance.new("Frame", row)
        av.Size = UDim2.new(0, 44, 0, 44)
        av.Position = UDim2.new(0, 24, 0.5, -22)
        av.BackgroundColor3 = Color3.fromRGB(48, 108, 185)
        av.BorderSizePixel = 0
        av.ZIndex = 20
        Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

        if avatarType == "car" then
            local img = Instance.new("ImageLabel", av)
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://131470370579445"
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 21
            Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        elseif avatarType == "taxi" then
            local img = Instance.new("ImageLabel", av)
            img.Size = UDim2.new(1, 0, 1, 0)
            img.BackgroundTransparency = 1
            img.Image = "rbxassetid://87510415537199"
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 21
            Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
        else
            local l = Instance.new("TextLabel", av)
            l.Size = UDim2.new(1, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text = avatarType
            l.Font = Enum.Font.GothamBold
            l.TextSize = 16
            l.TextColor3 = Color3.fromRGB(255, 255, 255)
            l.ZIndex = 21
        end

        local nl = Instance.new("TextLabel", row)
        nl.Size = UDim2.new(1, -170, 0, 20)
        nl.Position = UDim2.new(0, 78, 0, 14)
        nl.BackgroundTransparency = 1
        nl.Text = name
        nl.Font = Enum.Font.GothamBold
        nl.TextSize = 16
        nl.TextColor3 = Color3.fromRGB(15, 18, 28)
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.ZIndex = 20

        local pl = Instance.new("TextLabel", row)
        pl.Size = UDim2.new(1, -170, 0, 16)
        pl.Position = UDim2.new(0, 78, 0, 36)
        pl.BackgroundTransparency = 1
        pl.Text = previewTxt
        pl.Font = Enum.Font.Gotham
        pl.TextSize = 12.5
        pl.TextColor3 = Color3.fromRGB(130, 135, 150)
        pl.TextXAlignment = Enum.TextXAlignment.Left
        pl.ZIndex = 20

        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(0, 80, 0, 16)
        tl.Position = UDim2.new(1, -95, 0, 14)
        tl.BackgroundTransparency = 1
        tl.Text = timeTxt .. " >"
        tl.Font = Enum.Font.GothamMedium
        tl.TextSize = 12
        tl.TextColor3 = Color3.fromRGB(140, 145, 160)
        tl.TextXAlignment = Enum.TextXAlignment.Right
        tl.ZIndex = 20

        row.MouseButton1Click:Connect(function()
            playTone()
            msgListView.Visible = false
            chatThreadView.Visible = true
        end)
    end

    makeMsgRow("Alex Rivera", "🔗 Neon nights in Vinewood", "02:56", "car", true, 1)
    makeMsgRow("Los Santos Taxi", "Danke, ich komme sofort raus.", "02:24", "taxi", true, 2)
    makeMsgRow("Jamie Chen", "Bin in zehn Minuten bei dir.", "01:25", "JC", true, 3)
    makeMsgRow("Morgan Reed", "Ja, passt. Ich bin puenktlich da.", "Yesterday", "MR", false, 4)
    makeMsgRow("Downtown Customs", "Perfekt, ich komme heute Abend vorbei.", "Yesterday", "DC", false, 5)
    makeMsgRow("Jenica Chong", "Ja, gib mir fünf Minuten.", "8/6", "JC", true, 6)

    -- Bottom Search & Compose Bar
    local bSearch = Instance.new("Frame", msgListView)
    bSearch.Size = UDim2.new(1, -90, 0, 42)
    bSearch.Position = UDim2.new(0, 18, 1, -64)
    bSearch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bSearch.BorderSizePixel = 0
    bSearch.ZIndex = 18
    Instance.new("UICorner", bSearch).CornerRadius = UDim.new(1, 0)
    local bsStroke = Instance.new("UIStroke", bSearch)
    bsStroke.Color = Color3.fromRGB(225, 228, 238)

    local bsText = Instance.new("TextLabel", bSearch)
    bsText.Size = UDim2.new(1, -20, 1, 0)
    bsText.Position = UDim2.new(0, 14, 0, 0)
    bsText.BackgroundTransparency = 1
    bsText.Text = "🔍 Search"
    bsText.Font = Enum.Font.GothamMedium
    bsText.TextSize = 13.5
    bsText.TextColor3 = Color3.fromRGB(150, 155, 170)
    bsText.TextXAlignment = Enum.TextXAlignment.Left
    bsText.ZIndex = 19

    local composeBtn = Instance.new("TextButton", msgListView)
    composeBtn.Size = UDim2.new(0, 42, 0, 42)
    composeBtn.Position = UDim2.new(1, -60, 1, -64)
    composeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    composeBtn.BorderSizePixel = 0
    composeBtn.Text = "📝"
    composeBtn.TextSize = 20
    composeBtn.ZIndex = 18
    Instance.new("UICorner", composeBtn).CornerRadius = UDim.new(0, 14)
    local csStroke = Instance.new("UIStroke", composeBtn)
    csStroke.Color = Color3.fromRGB(225, 228, 238)

    -- Chat Thread View Inner
    local ctTop = Instance.new("Frame", chatThreadView)
    ctTop.Size = UDim2.new(1, 0, 0, 75)
    ctTop.Position = UDim2.new(0, 0, 0, 25)
    ctTop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ctTop.BorderSizePixel = 0
    ctTop.ZIndex = 26

    local ctBack = Instance.new("TextButton", ctTop)
    ctBack.Size = UDim2.new(0, 90, 0, 36)
    ctBack.Position = UDim2.new(0, 12, 0.5, -18)
    ctBack.BackgroundTransparency = 1
    ctBack.Text = "‹ Messages"
    ctBack.Font = Enum.Font.GothamBold
    ctBack.TextSize = 16
    ctBack.TextColor3 = Color3.fromRGB(0, 122, 255)
    ctBack.ZIndex = 27
    ctBack.MouseButton1Click:Connect(function()
        playTone()
        chatThreadView.Visible = false
        msgListView.Visible = true
    end)

    local ctName = Instance.new("TextLabel", ctTop)
    ctName.Size = UDim2.new(1, -160, 1, 0)
    ctName.Position = UDim2.new(0, 80, 0, 0)
    ctName.BackgroundTransparency = 1
    ctName.Text = "Alex Rivera"
    ctName.Font = Enum.Font.GothamBold
    ctName.TextSize = 16
    ctName.TextColor3 = Color3.fromRGB(15, 18, 28)
    ctName.ZIndex = 27

    local ctHistory = Instance.new("ScrollingFrame", chatThreadView)
    ctHistory.Size = UDim2.new(1, -24, 1, -160)
    ctHistory.Position = UDim2.new(0, 12, 0, 105)
    ctHistory.BackgroundTransparency = 1
    ctHistory.ScrollBarThickness = 0
    ctHistory.CanvasSize = UDim2.new(0, 0, 0, 360)
    ctHistory.ZIndex = 26

    local function makeBubble(txt, isMe, yPos)
        local b = Instance.new("Frame", ctHistory)
        b.Size = UDim2.new(0, 180, 0, 38)
        b.Position = isMe and UDim2.new(1, -190, 0, yPos) or UDim2.new(0, 10, 0, yPos)
        b.BackgroundColor3 = isMe and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(235, 238, 245)
        b.BorderSizePixel = 0
        b.ZIndex = 27
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 16)

        local t = Instance.new("TextLabel", b)
        t.Size = UDim2.new(1, -16, 1, 0)
        t.Position = UDim2.new(0, 8, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = txt
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 12.5
        t.TextColor3 = isMe and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(15, 18, 28)
        t.TextWrapped = true
        t.ZIndex = 28
    end

    makeBubble("Yo! Where are you at?", false, 10)
    makeBubble("On my way to Vinewood now!", true, 55)
    makeBubble("Grab the Sultan RS keys.", false, 100)
    makeBubble("Already in my pocket.", true, 145)

    local ctInputBar = Instance.new("Frame", chatThreadView)
    ctInputBar.Size = UDim2.new(1, -24, 0, 42)
    ctInputBar.Position = UDim2.new(0, 12, 1, -55)
    ctInputBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ctInputBar.BorderSizePixel = 0
    ctInputBar.ZIndex = 26
    Instance.new("UICorner", ctInputBar).CornerRadius = UDim.new(1, 0)
    local cis = Instance.new("UIStroke", ctInputBar)
    cis.Color = Color3.fromRGB(225, 228, 238)

    local ctBox = Instance.new("TextBox", ctInputBar)
    ctBox.Size = UDim2.new(1, -50, 1, 0)
    ctBox.Position = UDim2.new(0, 14, 0, 0)
    ctBox.BackgroundTransparency = 1
    ctBox.PlaceholderText = "iMessage"
    ctBox.Text = ""
    ctBox.Font = Enum.Font.Gotham
    ctBox.TextSize = 13
    ctBox.TextColor3 = Color3.fromRGB(15, 18, 28)
    ctBox.TextXAlignment = Enum.TextXAlignment.Left
    ctBox.ZIndex = 27

    local ctSend = Instance.new("TextButton", ctInputBar)
    ctSend.Size = UDim2.new(0, 32, 0, 32)
    ctSend.Position = UDim2.new(1, -38, 0.5, -16)
    ctSend.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    ctSend.Text = "↑"
    ctSend.Font = Enum.Font.GothamBold
    ctSend.TextSize = 18
    ctSend.TextColor3 = Color3.fromRGB(255, 255, 255)
    ctSend.ZIndex = 27
    Instance.new("UICorner", ctSend).CornerRadius = UDim.new(1, 0)

    ctSend.MouseButton1Click:Connect(function()
        if #ctBox.Text > 0 then
            playTone()
            makeBubble(ctBox.Text, true, 200)
            ctBox.Text = ""
            task.delay(1, function()
                makeBubble("Sounds good! See you soon.", false, 245)
            end)
        end
    end)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Messages"] = function(isLight)
            msgApp.BackgroundColor3 = isLight and Color3.fromRGB(248, 249, 252) or Color3.fromRGB(0, 0, 0)
            if chatThreadView then
                chatThreadView.BackgroundColor3 = isLight and Color3.fromRGB(248, 249, 252) or Color3.fromRGB(0, 0, 0)
            end
            if mTitle then mTitle.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255) end
            if mMenu then
                mMenu.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
                mMenu.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255)
                if mms then mms.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(msgApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 6. SETTINGS APP (Matching official_settings.png: Inset Grouped Cards + Toggles)
-- ============================================================================
setApp = createBaseApp("Settings", Color3.fromRGB(240, 242, 245))
do
    local setScroll = Instance.new("ScrollingFrame", setApp)
    setScroll.Size = UDim2.new(1, 0, 1, -20)
    setScroll.Position = UDim2.new(0, 0, 0, 20)
    setScroll.BackgroundTransparency = 1
    setScroll.ScrollBarThickness = 0
    setScroll.CanvasSize = UDim2.new(0, 0, 0, 720)
    setScroll.ZIndex = 17

    -- Title: Settings
    local sTitle = Instance.new("TextLabel", setScroll)
    sTitle.Size = UDim2.new(1, -36, 0, 38)
    sTitle.Position = UDim2.new(0, 18, 0, 48)
    sTitle.BackgroundTransparency = 1
    sTitle.Text = "Settings"
    sTitle.Font = Enum.Font.GothamBold
    sTitle.TextSize = 34
    sTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    sTitle.ZIndex = 18

    -- Search Pill
    local sSearch = Instance.new("Frame", setScroll)
    sSearch.Size = UDim2.new(1, -36, 0, 36)
    sSearch.Position = UDim2.new(0, 18, 0, 96)
    sSearch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sSearch.BorderSizePixel = 0
    sSearch.ZIndex = 18
    Instance.new("UICorner", sSearch).CornerRadius = UDim.new(0, 18)
    local ssStroke = Instance.new("UIStroke", sSearch)
    ssStroke.Color = Color3.fromRGB(225, 228, 238)

    local ssText = Instance.new("TextLabel", sSearch)
    ssText.Size = UDim2.new(1, -20, 1, 0)
    ssText.Position = UDim2.new(0, 12, 0, 0)
    ssText.BackgroundTransparency = 1
    ssText.Text = "🔍 Search"
    ssText.Font = Enum.Font.GothamMedium
    ssText.TextSize = 13
    ssText.TextColor3 = Color3.fromRGB(145, 150, 165)
    ssText.TextXAlignment = Enum.TextXAlignment.Left
    ssText.ZIndex = 19

    -- CARD 1: Sky Cloud Profile
    local c1 = Instance.new("Frame", setScroll)
    c1.Size = UDim2.new(1, -36, 0, 68)
    c1.Position = UDim2.new(0, 18, 0, 146)
    c1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    c1.BorderSizePixel = 0
    c1.ZIndex = 18
    Instance.new("UICorner", c1).CornerRadius = UDim.new(0, 20)
    local c1s = Instance.new("UIStroke", c1)
    c1s.Color = Color3.fromRGB(225, 228, 238)

    local c1Av = Instance.new("Frame", c1)
    c1Av.Size = UDim2.new(0, 44, 0, 44)
    c1Av.Position = UDim2.new(0, 14, 0.5, -22)
    c1Av.BackgroundColor3 = Color3.fromRGB(140, 145, 160)
    c1Av.BorderSizePixel = 0
    c1Av.ZIndex = 19
    Instance.new("UICorner", c1Av).CornerRadius = UDim.new(1, 0)

    local c1AvTxt = Instance.new("TextLabel", c1Av)
    c1AvTxt.Size = UDim2.new(1, 0, 1, 0)
    c1AvTxt.BackgroundTransparency = 1
    c1AvTxt.Text = "👤"
    c1AvTxt.TextSize = 22
    c1AvTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    c1AvTxt.ZIndex = 20

    local c1Title = Instance.new("TextLabel", c1)
    c1Title.Size = UDim2.new(1, -120, 0, 20)
    c1Title.Position = UDim2.new(0, 68, 0, 14)
    c1Title.BackgroundTransparency = 1
    c1Title.Text = "Sky Cloud"
    c1Title.Font = Enum.Font.GothamBold
    c1Title.TextSize = 16
    c1Title.TextColor3 = Color3.fromRGB(15, 18, 28)
    c1Title.TextXAlignment = Enum.TextXAlignment.Left
    c1Title.ZIndex = 19

    local c1Sub = Instance.new("TextLabel", c1)
    c1Sub.Size = UDim2.new(1, -120, 0, 16)
    c1Sub.Position = UDim2.new(0, 68, 0, 36)
    c1Sub.BackgroundTransparency = 1
    c1Sub.Text = "Important Data & Cloud"
    c1Sub.Font = Enum.Font.Gotham
    c1Sub.TextSize = 12
    c1Sub.TextColor3 = Color3.fromRGB(140, 145, 160)
    c1Sub.TextXAlignment = Enum.TextXAlignment.Left
    c1Sub.ZIndex = 19

    local c1Chev = Instance.new("TextLabel", c1)
    c1Chev.Size = UDim2.new(0, 20, 0, 20)
    c1Chev.Position = UDim2.new(1, -30, 0.5, -10)
    c1Chev.BackgroundTransparency = 1
    c1Chev.Text = ">"
    c1Chev.Font = Enum.Font.GothamMedium
    c1Chev.TextSize = 14
    c1Chev.TextColor3 = Color3.fromRGB(180, 185, 200)
    c1Chev.ZIndex = 19

    -- CARD 2: Airplane Mode & Streamer Mode Toggles
    local c2 = Instance.new("Frame", setScroll)
    c2.Size = UDim2.new(1, -36, 0, 104)
    c2.Position = UDim2.new(0, 18, 0, 226)
    c2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    c2.BorderSizePixel = 0
    c2.ZIndex = 18
    Instance.new("UICorner", c2).CornerRadius = UDim.new(0, 20)
    local c2s = Instance.new("UIStroke", c2)
    c2s.Color = Color3.fromRGB(225, 228, 238)

    local function makeToggleRow(parent, iconBg, iconSymbol, labelTxt, yPos)
        local ic = Instance.new("Frame", parent)
        ic.Size = UDim2.new(0, 30, 0, 30)
        ic.Position = UDim2.new(0, 14, 0, yPos + 10)
        ic.BackgroundColor3 = iconBg
        ic.BorderSizePixel = 0
        ic.ZIndex = 19
        Instance.new("UICorner", ic).CornerRadius = UDim.new(0, 7)

        local ict = Instance.new("TextLabel", ic)
        ict.Size = UDim2.new(1, 0, 1, 0)
        ict.BackgroundTransparency = 1
        ict.Text = iconSymbol
        ict.TextSize = 16
        ict.TextColor3 = Color3.fromRGB(255, 255, 255)
        ict.ZIndex = 20

        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, -140, 0, 20)
        l.Position = UDim2.new(0, 54, 0, yPos + 15)
        l.BackgroundTransparency = 1
        l.Text = labelTxt
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 15
        l.TextColor3 = Color3.fromRGB(15, 18, 28)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 19

        -- Animated Toggle Switch
        local sw = Instance.new("TextButton", parent)
        sw.Size = UDim2.new(0, 48, 0, 28)
        sw.Position = UDim2.new(1, -62, 0, yPos + 11)
        sw.BackgroundColor3 = Color3.fromRGB(225, 228, 235)
        sw.BorderSizePixel = 0
        sw.Text = ""
        sw.AutoButtonColor = false
        sw.ZIndex = 19
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", sw)
        knob.Size = UDim2.new(0, 24, 0, 24)
        knob.Position = UDim2.new(0, 2, 0.5, -12)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.ZIndex = 20
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local isOn = false
        sw.MouseButton1Click:Connect(function()
            playTone()
            isOn = not isOn
            if isOn then
                sw.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
                knob:TweenPosition(UDim2.new(1, -26, 0.5, -12), "Out", "Quad", 0.18, true)
            else
                sw.BackgroundColor3 = Color3.fromRGB(225, 228, 235)
                knob:TweenPosition(UDim2.new(0, 2, 0.5, -12), "Out", "Quad", 0.18, true)
            end
        end)
    end

    makeToggleRow(c2, Color3.fromRGB(255, 149, 0), "✈", "Airplane Mode", 0)
    local c2Div = Instance.new("Frame", c2)
    c2Div.Size = UDim2.new(1, -54, 0, 1)
    c2Div.Position = UDim2.new(0, 54, 0, 52)
    c2Div.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    c2Div.BorderSizePixel = 0
    c2Div.ZIndex = 19
    makeToggleRow(c2, Color3.fromRGB(175, 82, 222), "🚫", "Streamer Mode", 52)

    -- CARD 3: Notifications & Sounds
    local c3 = Instance.new("Frame", setScroll)
    c3.Size = UDim2.new(1, -36, 0, 104)
    c3.Position = UDim2.new(0, 18, 0, 342)
    c3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    c3.BorderSizePixel = 0
    c3.ZIndex = 18
    Instance.new("UICorner", c3).CornerRadius = UDim.new(0, 20)
    local c3s = Instance.new("UIStroke", c3)
    c3s.Color = Color3.fromRGB(225, 228, 238)

    local function makeNavRow(parent, iconBg, iconSymbol, labelTxt, subTxt, yPos)
        local ic = Instance.new("Frame", parent)
        ic.Size = UDim2.new(0, 30, 0, 30)
        ic.Position = UDim2.new(0, 14, 0, yPos + 10)
        ic.BackgroundColor3 = iconBg
        ic.BorderSizePixel = 0
        ic.ZIndex = 19
        Instance.new("UICorner", ic).CornerRadius = UDim.new(0, 7)

        local ict = Instance.new("TextLabel", ic)
        ict.Size = UDim2.new(1, 0, 1, 0)
        ict.BackgroundTransparency = 1
        ict.Text = iconSymbol
        ict.TextSize = 16
        ict.TextColor3 = Color3.fromRGB(255, 255, 255)
        ict.ZIndex = 20

        local l = Instance.new("TextLabel", parent)
        l.Size = UDim2.new(1, -160, 0, 20)
        l.Position = UDim2.new(0, 54, 0, yPos + 15)
        l.BackgroundTransparency = 1
        l.Text = labelTxt
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 15
        l.TextColor3 = Color3.fromRGB(15, 18, 28)
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 19

        local ch = Instance.new("TextLabel", parent)
        ch.Size = UDim2.new(0, 80, 0, 20)
        ch.Position = UDim2.new(1, -95, 0, yPos + 15)
        ch.BackgroundTransparency = 1
        ch.Text = (subTxt and subTxt .. " >" or ">")
        ch.Font = Enum.Font.GothamMedium
        ch.TextSize = 14
        ch.TextColor3 = Color3.fromRGB(160, 165, 180)
        ch.TextXAlignment = Enum.TextXAlignment.Right
        ch.ZIndex = 19
        local rowBtn = Instance.new("TextButton", parent)
        rowBtn.Name = "Row_" .. labelTxt
        rowBtn.Size = UDim2.new(1, 0, 0, 50)
        rowBtn.Position = UDim2.new(0, 0, 0, yPos)
        rowBtn.BackgroundTransparency = 1
        rowBtn.Text = ""
        rowBtn.ZIndex = 22
        return rowBtn
    end

    makeNavRow(c3, Color3.fromRGB(255, 59, 48), "🔔", "Notifications", nil, 0)
    local c3Div = Instance.new("Frame", c3)
    c3Div.Size = UDim2.new(1, -54, 0, 1)
    c3Div.Position = UDim2.new(0, 54, 0, 52)
    c3Div.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    c3Div.BorderSizePixel = 0
    c3Div.ZIndex = 19
    makeNavRow(c3, Color3.fromRGB(255, 45, 85), "🔊", "Sounds & Haptics", nil, 52)

    -- CARD 4: Connectivity, Focus, Security, General, Appearance
    local c4 = Instance.new("Frame", setScroll)
    c4.Size = UDim2.new(1, -36, 0, 255)
    c4.Position = UDim2.new(0, 18, 0, 458)
    c4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    c4.BorderSizePixel = 0
    c4.ZIndex = 18
    Instance.new("UICorner", c4).CornerRadius = UDim.new(0, 20)
    local c4s = Instance.new("UIStroke", c4)
    c4s.Color = Color3.fromRGB(225, 228, 238)

    makeNavRow(c4, Color3.fromRGB(0, 122, 255), "📶", "Connectivity", nil, 0)
    makeNavRow(c4, Color3.fromRGB(88, 86, 214), "🌙", "Focus", "Off", 51)
    makeNavRow(c4, Color3.fromRGB(52, 199, 89), "🔑", "Passcode & Security", "Off", 102)
    makeNavRow(c4, Color3.fromRGB(142, 142, 147), "⚙", "General Settings", nil, 153)
    local appRowBtn = makeNavRow(c4, Color3.fromRGB(0, 122, 255), "☀", "Appearance", nil, 204)

    for i = 1, 4 do
        local div = Instance.new("Frame", c4)
        div.Size = UDim2.new(1, -54, 0, 1)
        div.Position = UDim2.new(0, 54, 0, i * 51)
        div.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
        div.BorderSizePixel = 0
        div.ZIndex = 19
    end

    -- Sub-View: Appearance (Pixel-Perfect match to media_1789960289904 and media_1789960310158)
    local appearanceView = Instance.new("Frame", setApp)
    appearanceView.Name = "AppearanceSubView"
    appearanceView.Size = UDim2.new(1, 0, 1, 0)
    appearanceView.Position = UDim2.new(0, 0, 0, 0)
    appearanceView.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    appearanceView.BorderSizePixel = 0
    appearanceView.Visible = false
    appearanceView.ZIndex = 25
    Instance.new("UICorner", appearanceView).CornerRadius = UDim.new(0.125, 0)

    -- Top Bar
    local appTopBar = Instance.new("Frame", appearanceView)
    appTopBar.Name = "TopBar"
    appTopBar.Size = UDim2.new(1, 0, 0, 44)
    appTopBar.Position = UDim2.new(0, 0, 0, 44)
    appTopBar.BackgroundTransparency = 1
    appTopBar.ZIndex = 26

    local setBackBtn = Instance.new("TextButton", appTopBar)
    setBackBtn.Name = "BackButton"
    setBackBtn.Position = UDim2.new(0, 16, 0.5, -18)
    setBackBtn.Size = UDim2.new(0, 36, 0, 36)
    setBackBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    setBackBtn.Text = "‹"
    setBackBtn.Font = Enum.Font.GothamBold
    setBackBtn.TextSize = 24
    setBackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setBackBtn.AutoButtonColor = false
    setBackBtn.ZIndex = 27
    Instance.new("UICorner", setBackBtn).CornerRadius = UDim.new(1, 0)

    local appTitleLbl = Instance.new("TextLabel", appTopBar)
    appTitleLbl.Name = "Title"
    appTitleLbl.Size = UDim2.new(1, 0, 1, 0)
    appTitleLbl.Position = UDim2.new(0, 0, 0, 0)
    appTitleLbl.BackgroundTransparency = 1
    appTitleLbl.Text = "Appearance"
    appTitleLbl.Font = Enum.Font.GothamBold
    appTitleLbl.TextSize = 17
    appTitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    appTitleLbl.ZIndex = 26

    setBackBtn.MouseButton1Click:Connect(function()
        playTone()
        appearanceView.Visible = false
        setScroll.Visible = true
    end)

    if appRowBtn then
        appRowBtn.MouseButton1Click:Connect(function()
            playTone()
            setScroll.Visible = false
            appearanceView.Visible = true
        end)
    end

    local appScroll = Instance.new("ScrollingFrame", appearanceView)
    appScroll.Name = "ScrollContent"
    appScroll.Size = UDim2.new(1, 0, 1, -96)
    appScroll.Position = UDim2.new(0, 0, 0, 92)
    appScroll.BackgroundTransparency = 1
    appScroll.ScrollBarThickness = 0
    appScroll.CanvasSize = UDim2.new(0, 0, 0, 620)
    appScroll.ZIndex = 26

    -- Section 1: Graphics Mode
    local s1Lbl = Instance.new("TextLabel", appScroll)
    s1Lbl.Size = UDim2.new(1, -56, 0, 20)
    s1Lbl.Position = UDim2.new(0, 24, 0, 6)
    s1Lbl.BackgroundTransparency = 1
    s1Lbl.Text = "Graphics Mode"
    s1Lbl.Font = Enum.Font.GothamMedium
    s1Lbl.TextSize = 12.5
    s1Lbl.TextColor3 = Color3.fromRGB(142, 142, 147)
    s1Lbl.TextXAlignment = Enum.TextXAlignment.Left
    s1Lbl.ZIndex = 27

    local gCard = Instance.new("Frame", appScroll)
    gCard.Name = "GraphicsCard"
    gCard.Size = UDim2.new(1, -36, 0, 128)
    gCard.Position = UDim2.new(0, 18, 0, 30)
    gCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    gCard.BorderSizePixel = 0
    gCard.ZIndex = 27
    Instance.new("UICorner", gCard).CornerRadius = UDim.new(0, 18)
    local gCardStroke = Instance.new("UIStroke", gCard)
    gCardStroke.Color = Color3.fromRGB(44, 44, 46)

    -- Row: Performance Mode
    local btnPerf = Instance.new("TextButton", gCard)
    btnPerf.Size = UDim2.new(1, 0, 0, 64)
    btnPerf.Position = UDim2.new(0, 0, 0, 0)
    btnPerf.BackgroundTransparency = 1
    btnPerf.Text = ""
    btnPerf.ZIndex = 28

    local tPerf = Instance.new("TextLabel", btnPerf)
    tPerf.Size = UDim2.new(1, -60, 0, 20)
    tPerf.Position = UDim2.new(0, 16, 0, 10)
    tPerf.BackgroundTransparency = 1
    tPerf.Text = "Performance Mode"
    tPerf.Font = Enum.Font.GothamBold
    tPerf.TextSize = 15
    tPerf.TextColor3 = Color3.fromRGB(255, 255, 255)
    tPerf.TextXAlignment = Enum.TextXAlignment.Left
    tPerf.ZIndex = 29

    local subPerf = Instance.new("TextLabel", btnPerf)
    subPerf.Size = UDim2.new(1, -60, 0, 28)
    subPerf.Position = UDim2.new(0, 16, 0, 30)
    subPerf.BackgroundTransparency = 1
    subPerf.Text = "Blur-free glass simulation for better CEF performance"
    subPerf.Font = Enum.Font.Gotham
    subPerf.TextSize = 11.5
    subPerf.TextColor3 = Color3.fromRGB(142, 142, 147)
    subPerf.TextWrapped = true
    subPerf.TextXAlignment = Enum.TextXAlignment.Left
    subPerf.ZIndex = 29

    local chkPerf = Instance.new("TextLabel", btnPerf)
    chkPerf.Size = UDim2.new(0, 30, 0, 30)
    chkPerf.Position = UDim2.new(1, -38, 0.5, -15)
    chkPerf.BackgroundTransparency = 1
    chkPerf.Text = "✓"
    chkPerf.Font = Enum.Font.GothamBold
    chkPerf.TextSize = 16
    chkPerf.TextColor3 = Color3.fromRGB(0, 122, 255)
    chkPerf.Visible = false
    chkPerf.ZIndex = 29

    local gDiv = Instance.new("Frame", gCard)
    gDiv.Size = UDim2.new(1, -32, 0, 1)
    gDiv.Position = UDim2.new(0, 16, 0, 64)
    gDiv.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    gDiv.BorderSizePixel = 0
    gDiv.ZIndex = 28

    -- Row: Ultimate Mode
    local btnUlt = Instance.new("TextButton", gCard)
    btnUlt.Size = UDim2.new(1, 0, 0, 64)
    btnUlt.Position = UDim2.new(0, 0, 0, 64)
    btnUlt.BackgroundTransparency = 1
    btnUlt.Text = ""
    btnUlt.ZIndex = 28

    local tUlt = Instance.new("TextLabel", btnUlt)
    tUlt.Size = UDim2.new(1, -60, 0, 20)
    tUlt.Position = UDim2.new(0, 16, 0, 10)
    tUlt.BackgroundTransparency = 1
    tUlt.Text = "Ultimate Mode"
    tUlt.Font = Enum.Font.GothamBold
    tUlt.TextSize = 15
    tUlt.TextColor3 = Color3.fromRGB(255, 255, 255)
    tUlt.TextXAlignment = Enum.TextXAlignment.Left
    tUlt.ZIndex = 29

    local subUlt = Instance.new("TextLabel", btnUlt)
    subUlt.Size = UDim2.new(1, -60, 0, 28)
    subUlt.Position = UDim2.new(0, 16, 0, 30)
    subUlt.BackgroundTransparency = 1
    subUlt.Text = "Full blur and glass effects for compatible FiveM clients"
    subUlt.Font = Enum.Font.Gotham
    subUlt.TextSize = 11.5
    subUlt.TextColor3 = Color3.fromRGB(142, 142, 147)
    subUlt.TextWrapped = true
    subUlt.TextXAlignment = Enum.TextXAlignment.Left
    subUlt.ZIndex = 29

    local chkUlt = Instance.new("TextLabel", btnUlt)
    chkUlt.Size = UDim2.new(0, 30, 0, 30)
    chkUlt.Position = UDim2.new(1, -38, 0.5, -15)
    chkUlt.BackgroundTransparency = 1
    chkUlt.Text = "✓"
    chkUlt.Font = Enum.Font.GothamBold
    chkUlt.TextSize = 16
    chkUlt.TextColor3 = Color3.fromRGB(0, 122, 255)
    chkUlt.Visible = true
    chkUlt.ZIndex = 29

    btnPerf.MouseButton1Click:Connect(function()
        playTone()
        chkPerf.Visible = true
        chkUlt.Visible = false
    end)
    btnUlt.MouseButton1Click:Connect(function()
        playTone()
        chkPerf.Visible = false
        chkUlt.Visible = true
    end)

    -- Section 2: Appearance Mode
    local s2Lbl = Instance.new("TextLabel", appScroll)
    s2Lbl.Size = UDim2.new(1, -56, 0, 20)
    s2Lbl.Position = UDim2.new(0, 24, 0, 172)
    s2Lbl.BackgroundTransparency = 1
    s2Lbl.Text = "Appearance Mode"
    s2Lbl.Font = Enum.Font.GothamMedium
    s2Lbl.TextSize = 12.5
    s2Lbl.TextColor3 = Color3.fromRGB(142, 142, 147)
    s2Lbl.TextXAlignment = Enum.TextXAlignment.Left
    s2Lbl.ZIndex = 27

    local aCard = Instance.new("Frame", appScroll)
    aCard.Name = "AppearanceCard"
    aCard.Size = UDim2.new(1, -36, 0, 144)
    aCard.Position = UDim2.new(0, 18, 0, 196)
    aCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    aCard.BorderSizePixel = 0
    aCard.ZIndex = 27
    Instance.new("UICorner", aCard).CornerRadius = UDim.new(0, 18)
    local aCardStroke = Instance.new("UIStroke", aCard)
    aCardStroke.Color = Color3.fromRGB(44, 44, 46)

    -- Automatic
    local btnAuto = Instance.new("TextButton", aCard)
    btnAuto.Size = UDim2.new(1, 0, 0, 48)
    btnAuto.Position = UDim2.new(0, 0, 0, 0)
    btnAuto.BackgroundTransparency = 1
    btnAuto.Text = ""
    btnAuto.ZIndex = 28

    local tAuto = Instance.new("TextLabel", btnAuto)
    tAuto.Size = UDim2.new(1, -60, 1, 0)
    tAuto.Position = UDim2.new(0, 16, 0, 0)
    tAuto.BackgroundTransparency = 1
    tAuto.Text = "Automatic"
    tAuto.Font = Enum.Font.GothamMedium
    tAuto.TextSize = 15
    tAuto.TextColor3 = Color3.fromRGB(255, 255, 255)
    tAuto.TextXAlignment = Enum.TextXAlignment.Left
    tAuto.ZIndex = 29

    local chkAuto = Instance.new("TextLabel", btnAuto)
    chkAuto.Size = UDim2.new(0, 30, 0, 30)
    chkAuto.Position = UDim2.new(1, -38, 0.5, -15)
    chkAuto.BackgroundTransparency = 1
    chkAuto.Text = "✓"
    chkAuto.Font = Enum.Font.GothamBold
    chkAuto.TextSize = 16
    chkAuto.TextColor3 = Color3.fromRGB(0, 122, 255)
    chkAuto.Visible = false
    chkAuto.ZIndex = 29

    local aDiv1 = Instance.new("Frame", aCard)
    aDiv1.Size = UDim2.new(1, -32, 0, 1)
    aDiv1.Position = UDim2.new(0, 16, 0, 48)
    aDiv1.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    aDiv1.BorderSizePixel = 0
    aDiv1.ZIndex = 28

    -- Light
    local btnLight = Instance.new("TextButton", aCard)
    btnLight.Size = UDim2.new(1, 0, 0, 48)
    btnLight.Position = UDim2.new(0, 0, 0, 48)
    btnLight.BackgroundTransparency = 1
    btnLight.Text = ""
    btnLight.ZIndex = 28

    local tLight = Instance.new("TextLabel", btnLight)
    tLight.Size = UDim2.new(1, -60, 1, 0)
    tLight.Position = UDim2.new(0, 16, 0, 0)
    tLight.BackgroundTransparency = 1
    tLight.Text = "Light"
    tLight.Font = Enum.Font.GothamMedium
    tLight.TextSize = 15
    tLight.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLight.TextXAlignment = Enum.TextXAlignment.Left
    tLight.ZIndex = 29

    local chkLight = Instance.new("TextLabel", btnLight)
    chkLight.Size = UDim2.new(0, 30, 0, 30)
    chkLight.Position = UDim2.new(1, -38, 0.5, -15)
    chkLight.BackgroundTransparency = 1
    chkLight.Text = "✓"
    chkLight.Font = Enum.Font.GothamBold
    chkLight.TextSize = 16
    chkLight.TextColor3 = Color3.fromRGB(0, 122, 255)
    chkLight.Visible = false
    chkLight.ZIndex = 29

    local aDiv2 = Instance.new("Frame", aCard)
    aDiv2.Size = UDim2.new(1, -32, 0, 1)
    aDiv2.Position = UDim2.new(0, 16, 0, 96)
    aDiv2.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    aDiv2.BorderSizePixel = 0
    aDiv2.ZIndex = 28

    -- Dark
    local btnDark = Instance.new("TextButton", aCard)
    btnDark.Size = UDim2.new(1, 0, 0, 48)
    btnDark.Position = UDim2.new(0, 0, 0, 96)
    btnDark.BackgroundTransparency = 1
    btnDark.Text = ""
    btnDark.ZIndex = 28

    local tDark = Instance.new("TextLabel", btnDark)
    tDark.Size = UDim2.new(1, -60, 1, 0)
    tDark.Position = UDim2.new(0, 16, 0, 0)
    tDark.BackgroundTransparency = 1
    tDark.Text = "Dark"
    tDark.Font = Enum.Font.GothamMedium
    tDark.TextSize = 15
    tDark.TextColor3 = Color3.fromRGB(255, 255, 255)
    tDark.TextXAlignment = Enum.TextXAlignment.Left
    tDark.ZIndex = 29

    local chkDark = Instance.new("TextLabel", btnDark)
    chkDark.Size = UDim2.new(0, 30, 0, 30)
    chkDark.Position = UDim2.new(1, -38, 0.5, -15)
    chkDark.BackgroundTransparency = 1
    chkDark.Text = "✓"
    chkDark.Font = Enum.Font.GothamBold
    chkDark.TextSize = 16
    chkDark.TextColor3 = Color3.fromRGB(0, 122, 255)
    chkDark.Visible = true
    chkDark.ZIndex = 29

    -- Section 3: Screen Brightness
    local s3Header = Instance.new("Frame", appScroll)
    s3Header.Size = UDim2.new(1, -48, 0, 20)
    s3Header.Position = UDim2.new(0, 24, 0, 356)
    s3Header.BackgroundTransparency = 1
    s3Header.ZIndex = 27

    local s3Title = Instance.new("TextLabel", s3Header)
    s3Title.Size = UDim2.new(0.6, 0, 1, 0)
    s3Title.BackgroundTransparency = 1
    s3Title.Text = "Screen Brightness"
    s3Title.Font = Enum.Font.GothamMedium
    s3Title.TextSize = 15
    s3Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    s3Title.TextXAlignment = Enum.TextXAlignment.Left
    s3Title.ZIndex = 28

    local s3Pct = Instance.new("TextLabel", s3Header)
    s3Pct.Size = UDim2.new(0.4, 0, 1, 0)
    s3Pct.Position = UDim2.new(0.6, 0, 0, 0)
    s3Pct.BackgroundTransparency = 1
    s3Pct.Text = "100%"
    s3Pct.Font = Enum.Font.GothamMedium
    s3Pct.TextSize = 15
    s3Pct.TextColor3 = Color3.fromRGB(142, 142, 147)
    s3Pct.TextXAlignment = Enum.TextXAlignment.Right
    s3Pct.ZIndex = 28

    local bCard = Instance.new("Frame", appScroll)
    bCard.Name = "BrightnessCard"
    bCard.Size = UDim2.new(1, -36, 0, 58)
    bCard.Position = UDim2.new(0, 18, 0, 380)
    bCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    bCard.BorderSizePixel = 0
    bCard.ZIndex = 27
    Instance.new("UICorner", bCard).CornerRadius = UDim.new(0, 18)
    local bCardStroke = Instance.new("UIStroke", bCard)
    bCardStroke.Color = Color3.fromRGB(44, 44, 46)

    local bIconLow = Instance.new("TextLabel", bCard)
    bIconLow.Size = UDim2.new(0, 24, 0, 24)
    bIconLow.Position = UDim2.new(0, 14, 0.5, -12)
    bIconLow.BackgroundTransparency = 1
    bIconLow.Text = "☼"
    bIconLow.TextSize = 16
    bIconLow.TextColor3 = Color3.fromRGB(142, 142, 147)
    bIconLow.ZIndex = 28

    local bTrack = Instance.new("Frame", bCard)
    bTrack.Size = UDim2.new(1, -96, 0, 4)
    bTrack.Position = UDim2.new(0, 48, 0.5, -2)
    bTrack.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    bTrack.BorderSizePixel = 0
    bTrack.ZIndex = 28
    Instance.new("UICorner", bTrack).CornerRadius = UDim.new(1, 0)

    local bThumb = Instance.new("Frame", bTrack)
    bThumb.Size = UDim2.new(0, 28, 0, 16)
    bThumb.AnchorPoint = Vector2.new(0.5, 0.5)
    bThumb.Position = UDim2.new(1, 0, 0.5, 0)
    bThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bThumb.BorderSizePixel = 0
    bThumb.ZIndex = 29
    Instance.new("UICorner", bThumb).CornerRadius = UDim.new(1, 0)

    local bIconHigh = Instance.new("TextLabel", bCard)
    bIconHigh.Size = UDim2.new(0, 24, 0, 24)
    bIconHigh.Position = UDim2.new(1, -38, 0.5, -12)
    bIconHigh.BackgroundTransparency = 1
    bIconHigh.Text = "☀"
    bIconHigh.TextSize = 20
    bIconHigh.TextColor3 = Color3.fromRGB(142, 142, 147)
    bIconHigh.ZIndex = 28

    -- Section 4: Phone Scale
    local s4Header = Instance.new("Frame", appScroll)
    s4Header.Size = UDim2.new(1, -48, 0, 20)
    s4Header.Position = UDim2.new(0, 24, 0, 452)
    s4Header.BackgroundTransparency = 1
    s4Header.ZIndex = 27

    local s4Title = Instance.new("TextLabel", s4Header)
    s4Title.Size = UDim2.new(0.6, 0, 1, 0)
    s4Title.BackgroundTransparency = 1
    s4Title.Text = "Phone Scale"
    s4Title.Font = Enum.Font.GothamMedium
    s4Title.TextSize = 15
    s4Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    s4Title.TextXAlignment = Enum.TextXAlignment.Left
    s4Title.ZIndex = 28

    local s4Pct = Instance.new("TextLabel", s4Header)
    s4Pct.Size = UDim2.new(0.4, 0, 1, 0)
    s4Pct.Position = UDim2.new(0.6, 0, 0, 0)
    s4Pct.BackgroundTransparency = 1
    s4Pct.Text = "100%"
    s4Pct.Font = Enum.Font.GothamMedium
    s4Pct.TextSize = 15
    s4Pct.TextColor3 = Color3.fromRGB(142, 142, 147)
    s4Pct.TextXAlignment = Enum.TextXAlignment.Right
    s4Pct.ZIndex = 28

    local scCard = Instance.new("Frame", appScroll)
    scCard.Name = "ScaleCard"
    scCard.Size = UDim2.new(1, -36, 0, 58)
    scCard.Position = UDim2.new(0, 18, 0, 476)
    scCard.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    scCard.BorderSizePixel = 0
    scCard.ZIndex = 27
    Instance.new("UICorner", scCard).CornerRadius = UDim.new(0, 18)
    local scCardStroke = Instance.new("UIStroke", scCard)
    scCardStroke.Color = Color3.fromRGB(44, 44, 46)

    local scIconSmall = Instance.new("TextLabel", scCard)
    scIconSmall.Size = UDim2.new(0, 24, 0, 24)
    scIconSmall.Position = UDim2.new(0, 14, 0.5, -12)
    scIconSmall.BackgroundTransparency = 1
    scIconSmall.Text = "📱"
    scIconSmall.TextSize = 14
    scIconSmall.TextColor3 = Color3.fromRGB(142, 142, 147)
    scIconSmall.ZIndex = 28

    local scTrack = Instance.new("Frame", scCard)
    scTrack.Size = UDim2.new(1, -96, 0, 4)
    scTrack.Position = UDim2.new(0, 48, 0.5, -2)
    scTrack.BackgroundColor3 = Color3.fromRGB(70, 75, 85)
    scTrack.BorderSizePixel = 0
    scTrack.ZIndex = 28
    Instance.new("UICorner", scTrack).CornerRadius = UDim.new(1, 0)

    local scFill = Instance.new("Frame", scTrack)
    scFill.Size = UDim2.new(0.48, 0, 1, 0)
    scFill.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    scFill.BorderSizePixel = 0
    scFill.ZIndex = 28
    Instance.new("UICorner", scFill).CornerRadius = UDim.new(1, 0)

    local scThumb = Instance.new("Frame", scTrack)
    scThumb.Size = UDim2.new(0, 28, 0, 16)
    scThumb.AnchorPoint = Vector2.new(0.5, 0.5)
    scThumb.Position = UDim2.new(0.48, 0, 0.5, 0)
    scThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scThumb.BorderSizePixel = 0
    scThumb.ZIndex = 29
    Instance.new("UICorner", scThumb).CornerRadius = UDim.new(1, 0)

    local scIconBig = Instance.new("TextLabel", scCard)
    scIconBig.Size = UDim2.new(0, 24, 0, 24)
    scIconBig.Position = UDim2.new(1, -38, 0.5, -12)
    scIconBig.BackgroundTransparency = 1
    scIconBig.Text = "📱"
    scIconBig.TextSize = 18
    scIconBig.TextColor3 = Color3.fromRGB(142, 142, 147)
    scIconBig.ZIndex = 28

    -- Section 5: Phone Frame
    local s5Lbl = Instance.new("TextLabel", appScroll)
    s5Lbl.Size = UDim2.new(1, -56, 0, 20)
    s5Lbl.Position = UDim2.new(0, 24, 0, 548)
    s5Lbl.BackgroundTransparency = 1
    s5Lbl.Text = "Phone Frame"
    s5Lbl.Font = Enum.Font.GothamMedium
    s5Lbl.TextSize = 12.5
    s5Lbl.TextColor3 = Color3.fromRGB(142, 142, 147)
    s5Lbl.TextXAlignment = Enum.TextXAlignment.Left
    s5Lbl.ZIndex = 27

    -- Collections for live theme changes
    local themeCards = {c1, c2, c3, c4, gCard, aCard, bCard, scCard}
    local themeStrokes = {c1s, c2s, c3s, c4s, gCardStroke, aCardStroke, bCardStroke, scCardStroke}
    local themeTexts = {sTitle, c1Title, tPerf, tUlt, tAuto, tLight, tDark, s3Title, s4Title, appTitleLbl}
    local themeDivs = {c2Div, c3Div, gDiv, aDiv1, aDiv2}

    _G.SkyPhone_ApplyGlobalTheme = function(mode)
        playTone()
        local isLight = (mode == "light")
        _G.SkyPhone_CurrentTheme = mode

        chkAuto.Visible = (mode == "auto")
        chkLight.Visible = (mode == "light")
        chkDark.Visible = (mode == "dark")

        local appBg = isLight and Color3.fromRGB(242, 242, 247) or Color3.fromRGB(0, 0, 0)
        local cardBg = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
        local textCol = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255)
        local strokeCol = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46)
        local divCol = isLight and Color3.fromRGB(235, 238, 245) or Color3.fromRGB(44, 44, 46)
        local backBtnBg = isLight and Color3.fromRGB(230, 230, 235) or Color3.fromRGB(44, 44, 46)
        local backBtnText = isLight and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)

        if setApp then setApp.BackgroundColor3 = appBg end
        if appearanceView then appearanceView.BackgroundColor3 = appBg end
        if setBackBtn then
            setBackBtn.BackgroundColor3 = backBtnBg
            setBackBtn.TextColor3 = backBtnText
        end

        for _, card in ipairs(themeCards) do
            if card and card:IsA("Frame") then card.BackgroundColor3 = cardBg end
        end
        for _, str in ipairs(themeStrokes) do
            if str and str:IsA("UIStroke") then str.Color = strokeCol end
        end
        for _, txt in ipairs(themeTexts) do
            if txt and txt:IsA("TextLabel") then txt.TextColor3 = textCol end
        end
        for _, div in ipairs(themeDivs) do
            if div and div:IsA("Frame") then div.BackgroundColor3 = divCol end
        end

        -- Update all registered apps in _G.SkyPhone_AppThemeUpdaters
        if _G.SkyPhone_AppThemeUpdaters then
            for appName, updater in pairs(_G.SkyPhone_AppThemeUpdaters) do
                pcall(function() updater(isLight) end)
            end
        end

        -- Pass generic app themer to any remaining apps in appContainer
        if appContainer then
            for _, child in ipairs(appContainer:GetChildren()) do
                if child:IsA("Frame") or child:IsA("GuiObject") then
                    local appKey = string.gsub(child.Name, "App$", "")
                    if _G.SkyPhone_AppThemeUpdaters and not _G.SkyPhone_AppThemeUpdaters[appKey] then
                        pcall(function()
                            if _G.SkyPhone_ApplyGenericAppTheme then
                                _G.SkyPhone_ApplyGenericAppTheme(child, isLight)
                            end
                        end)
                    end
                end
            end
        end

        -- Status bar theme
        if appContainer and appContainer.Visible then
            if _G.SkyPhone_SetTheme then
                _G.SkyPhone_SetTheme(isLight)
            end
        else
            if _G.SkyPhone_SetTheme then
                _G.SkyPhone_SetTheme(false)
            end
        end
    end

    btnAuto.MouseButton1Click:Connect(function()
        _G.SkyPhone_ApplyGlobalTheme("auto")
    end)
    btnLight.MouseButton1Click:Connect(function()
        _G.SkyPhone_ApplyGlobalTheme("light")
    end)
    btnDark.MouseButton1Click:Connect(function()
        _G.SkyPhone_ApplyGlobalTheme("dark")
    end)
end

return { name = "PhoneMessagesSettings" }
