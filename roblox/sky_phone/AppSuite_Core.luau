--!strict
-- src/sky_phone/AppSuite_Core.luau
-- Pure Luau Component: Phone (Recents, Contacts with A-Z strip, Keypad, In-Call),
-- Messages (Chat, Inline Contact/Picstagram cards, '+' Attachment Popover),
-- Notes (Editor), Settings (Appearance & System Toggles)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local AppSuite_Core = {}

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

function AppSuite_Core.build(appContainer: Frame, ctx: any)
    local showNotification = ctx and ctx.showNotification or function(title: string, msg: string) end
    local openApp = ctx and ctx.openApp or function(name: string) end

    -- =========================================================================
    -- 1. PHONE APP (Dark Obsidian: Recents with All/Missed, Contacts with A-Z, Keypad)
    -- =========================================================================
    local phoneApp = createBaseApp(appContainer, "Phone", Color3.fromRGB(14, 16, 24))
    do
        local recentsView = Instance.new("Frame", phoneApp)
        recentsView.Name = "RecentsView"
        recentsView.Size = UDim2.new(1, 0, 1, 0)
        recentsView.BackgroundTransparency = 1
        recentsView.ZIndex = 17

        local contactsView = Instance.new("Frame", phoneApp)
        contactsView.Name = "ContactsView"
        contactsView.Size = UDim2.new(1, 0, 1, 0)
        contactsView.BackgroundTransparency = 1
        contactsView.Visible = false
        contactsView.ZIndex = 17

        local keypadView = Instance.new("Frame", phoneApp)
        keypadView.Name = "KeypadView"
        keypadView.Size = UDim2.new(1, 0, 1, 0)
        keypadView.BackgroundTransparency = 1
        keypadView.Visible = false
        keypadView.ZIndex = 17

        -- In-Call View
        local inCallView = Instance.new("Frame", phoneApp)
        inCallView.Name = "InCallView"
        inCallView.Size = UDim2.new(1, 0, 1, 0)
        inCallView.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
        inCallView.Visible = false
        inCallView.ZIndex = 30
        Instance.new("UICorner", inCallView).CornerRadius = UDim.new(0.136, 0)

        local callerNameLbl = Instance.new("TextLabel", inCallView)
        callerNameLbl.Name = "CallerName"
        callerNameLbl.Size = UDim2.new(1, 0, 0, 36)
        callerNameLbl.Position = UDim2.new(0, 0, 0, 90)
        callerNameLbl.BackgroundTransparency = 1
        callerNameLbl.Text = "Calling..."
        callerNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        callerNameLbl.Font = Enum.Font.GothamBold
        callerNameLbl.TextSize = 26
        callerNameLbl.ZIndex = 31

        local callTimerLbl = Instance.new("TextLabel", inCallView)
        callTimerLbl.Name = "CallTimer"
        callTimerLbl.Size = UDim2.new(1, 0, 0, 20)
        callTimerLbl.Position = UDim2.new(0, 0, 0, 130)
        callTimerLbl.BackgroundTransparency = 1
        callTimerLbl.Text = "00:00"
        callTimerLbl.TextColor3 = Color3.fromRGB(150, 160, 180)
        callTimerLbl.Font = Enum.Font.Gotham
        callTimerLbl.TextSize = 14
        callTimerLbl.ZIndex = 31

        local endCallBtn = Instance.new("TextButton", inCallView)
        endCallBtn.Name = "EndCallBtn"
        endCallBtn.AnchorPoint = Vector2.new(0.5, 1)
        endCallBtn.Position = UDim2.new(0.5, 0, 1, -80)
        endCallBtn.Size = UDim2.new(0, 68, 0, 68)
        endCallBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
        endCallBtn.Text = "📞"
        endCallBtn.TextSize = 28
        endCallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        endCallBtn.ZIndex = 31
        Instance.new("UICorner", endCallBtn).CornerRadius = UDim.new(1, 0)

        local callSecs = 0
        local callTask: thread? = nil

        local function endCall()
            playTone(1.2)
            if callTask then task.cancel(callTask) end
            inCallView.Visible = false
            keypadView.Visible = true
        end
        endCallBtn.MouseButton1Click:Connect(endCall)

        local function startCall(targetNumber: string)
            playTone(2.0)
            recentsView.Visible = false
            contactsView.Visible = false
            keypadView.Visible = false
            inCallView.Visible = true
            callerNameLbl.Text = (#targetNumber > 0) and targetNumber or "Los Santos Taxi"
            callSecs = 0
            callTimerLbl.Text = "00:00"

            if callTask then task.cancel(callTask) end
            callTask = task.spawn(function()
                while inCallView.Visible do
                    task.wait(1)
                    callSecs += 1
                    local mins = math.floor(callSecs / 60)
                    local secs = callSecs % 60
                    callTimerLbl.Text = string.format("%02d:%02d", mins, secs)
                end
            end)
        end

        -- -------------------------------------------------------------
        -- Tab 1: RECENTS VIEW (All / Missed segmented filter)
        -- -------------------------------------------------------------
        local segFrame = Instance.new("Frame", recentsView)
        segFrame.Name = "SegmentControl"
        segFrame.AnchorPoint = Vector2.new(0.5, 0)
        segFrame.Position = UDim2.new(0.5, 0, 0, 48)
        segFrame.Size = UDim2.new(0, 150, 0, 32)
        segFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        segFrame.ZIndex = 18
        Instance.new("UICorner", segFrame).CornerRadius = UDim.new(0, 16)

        local btnAll = Instance.new("TextButton", segFrame)
        btnAll.Size = UDim2.new(0.5, -2, 1, -4)
        btnAll.Position = UDim2.new(0, 2, 0, 2)
        btnAll.BackgroundColor3 = Color3.fromRGB(58, 62, 74)
        btnAll.Text = "All"
        btnAll.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnAll.Font = Enum.Font.GothamBold
        btnAll.TextSize = 12
        btnAll.ZIndex = 19
        Instance.new("UICorner", btnAll).CornerRadius = UDim.new(0, 14)

        local btnMissed = Instance.new("TextButton", segFrame)
        btnMissed.Size = UDim2.new(0.5, -2, 1, -4)
        btnMissed.Position = UDim2.new(0.5, 0, 0, 2)
        btnMissed.BackgroundTransparency = 1
        btnMissed.Text = "Missed"
        btnMissed.TextColor3 = Color3.fromRGB(142, 142, 147)
        btnMissed.Font = Enum.Font.GothamBold
        btnMissed.TextSize = 12
        btnMissed.ZIndex = 19
        Instance.new("UICorner", btnMissed).CornerRadius = UDim.new(0, 14)

        local rTitle = Instance.new("TextLabel", recentsView)
        rTitle.Size = UDim2.new(1, -36, 0, 36)
        rTitle.Position = UDim2.new(0, 18, 0, 86)
        rTitle.BackgroundTransparency = 1
        rTitle.Text = "Recents"
        rTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        rTitle.Font = Enum.Font.GothamBold
        rTitle.TextSize = 28
        rTitle.TextXAlignment = Enum.TextXAlignment.Left
        rTitle.ZIndex = 18

        -- Search Bar
        local rSearch = Instance.new("Frame", recentsView)
        rSearch.Size = UDim2.new(1, -36, 0, 36)
        rSearch.Position = UDim2.new(0, 18, 0, 126)
        rSearch.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        rSearch.ZIndex = 18
        Instance.new("UICorner", rSearch).CornerRadius = UDim.new(0, 10)

        local rSearchTxt = Instance.new("TextLabel", rSearch)
        rSearchTxt.Size = UDim2.new(1, -36, 1, 0)
        rSearchTxt.Position = UDim2.new(0, 32, 0, 0)
        rSearchTxt.BackgroundTransparency = 1
        rSearchTxt.Text = "Search Calls"
        rSearchTxt.TextColor3 = Color3.fromRGB(142, 142, 147)
        rSearchTxt.Font = Enum.Font.Gotham
        rSearchTxt.TextSize = 13
        rSearchTxt.TextXAlignment = Enum.TextXAlignment.Left
        rSearchTxt.ZIndex = 19

        local rSearchIcon = Instance.new("TextLabel", rSearch)
        rSearchIcon.Size = UDim2.new(0, 24, 1, 0)
        rSearchIcon.Position = UDim2.new(0, 6, 0, 0)
        rSearchIcon.BackgroundTransparency = 1
        rSearchIcon.Text = "🔍"
        rSearchIcon.TextSize = 13
        rSearchIcon.ZIndex = 19

        -- Calls List
        local rScroll = Instance.new("ScrollingFrame", recentsView)
        rScroll.Size = UDim2.new(1, -36, 1, -250)
        rScroll.Position = UDim2.new(0, 18, 0, 172)
        rScroll.BackgroundTransparency = 1
        rScroll.ScrollBarThickness = 0
        rScroll.ZIndex = 18

        local rLayout = Instance.new("UIListLayout", rScroll)
        rLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rLayout.Padding = UDim.new(0, 6)

        local CALLS = {
            { name = "Alex Rivera", status = "Call Ended", time = "03:09 AM", missed = false },
            { name = "Morgan Reed", status = "Call Ended", time = "02:59 AM", missed = false },
            { name = "Los Santos Taxi", status = "Call Ended", time = "02:35 AM", missed = false },
            { name = "Jamie Chen", status = "Missed", time = "01:42 AM", missed = true },
            { name = "Emily Hart", status = "No Answer", time = "Sunday", missed = true },
            { name = "Yakup Brooooo", status = "Call Ended", time = "Sunday", missed = false },
            { name = "Downtown Custom", status = "Call Ended", time = "555 404 0404", missed = false },
        }

        local callRows: { Frame } = {}
        for idx, item in ipairs(CALLS) do
            local row = Instance.new("Frame", rScroll)
            row.Name = "CallRow_" .. idx
            row.Size = UDim2.new(1, 0, 0, 52)
            row.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
            row.ZIndex = 19
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)
            table.insert(callRows, row)

            -- Initial Avatar Circle
            local av = Instance.new("Frame", row)
            av.Size = UDim2.new(0, 36, 0, 36)
            av.Position = UDim2.new(0, 10, 0.5, -18)
            av.BackgroundColor3 = Color3.fromRGB(44, 48, 60)
            av.ZIndex = 20
            Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

            local avTxt = Instance.new("TextLabel", av)
            avTxt.Size = UDim2.new(1, 0, 1, 0)
            avTxt.BackgroundTransparency = 1
            avTxt.Text = string.sub(item.name, 1, 1)
            avTxt.TextColor3 = Color3.fromRGB(240, 240, 245)
            avTxt.Font = Enum.Font.GothamBold
            avTxt.TextSize = 14
            avTxt.ZIndex = 21

            local nLbl = Instance.new("TextLabel", row)
            nLbl.Size = UDim2.new(1, -140, 0, 18)
            nLbl.Position = UDim2.new(0, 54, 0, 8)
            nLbl.BackgroundTransparency = 1
            nLbl.Text = item.name
            nLbl.TextColor3 = item.missed and Color3.fromRGB(255, 69, 58) or Color3.fromRGB(255, 255, 255)
            nLbl.Font = Enum.Font.GothamBold
            nLbl.TextSize = 14
            nLbl.TextXAlignment = Enum.TextXAlignment.Left
            nLbl.ZIndex = 20

            local sLbl = Instance.new("TextLabel", row)
            sLbl.Size = UDim2.new(1, -140, 0, 15)
            sLbl.Position = UDim2.new(0, 54, 0, 28)
            sLbl.BackgroundTransparency = 1
            sLbl.Text = "📞 " .. item.status
            sLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            sLbl.Font = Enum.Font.Gotham
            sLbl.TextSize = 11
            sLbl.TextXAlignment = Enum.TextXAlignment.Left
            sLbl.ZIndex = 20

            local tLbl = Instance.new("TextLabel", row)
            tLbl.Size = UDim2.new(0, 75, 1, 0)
            tLbl.Position = UDim2.new(1, -105, 0, 0)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = item.time
            tLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            tLbl.Font = Enum.Font.Gotham
            tLbl.TextSize = 11
            tLbl.TextXAlignment = Enum.TextXAlignment.Right
            tLbl.ZIndex = 20

            local infoBtn = Instance.new("TextLabel", row)
            infoBtn.Size = UDim2.new(0, 22, 0, 22)
            infoBtn.Position = UDim2.new(1, -28, 0.5, -11)
            infoBtn.BackgroundTransparency = 1
            infoBtn.Text = "ⓘ"
            infoBtn.TextColor3 = Color3.fromRGB(0, 122, 255)
            infoBtn.Font = Enum.Font.GothamBold
            infoBtn.TextSize = 16
            infoBtn.ZIndex = 20
        end

        btnAll.MouseButton1Click:Connect(function()
            btnAll.BackgroundColor3 = Color3.fromRGB(58, 62, 74)
            btnAll.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnMissed.BackgroundTransparency = 1
            btnMissed.TextColor3 = Color3.fromRGB(142, 142, 147)
            for _, r in ipairs(callRows) do r.Visible = true end
        end)

        btnMissed.MouseButton1Click:Connect(function()
            btnMissed.BackgroundColor3 = Color3.fromRGB(58, 62, 74)
            btnMissed.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnAll.BackgroundTransparency = 1
            btnAll.TextColor3 = Color3.fromRGB(142, 142, 147)
            for idx, r in ipairs(callRows) do
                r.Visible = CALLS[idx].missed
            end
        end)

        -- -------------------------------------------------------------
        -- Tab 2: CONTACTS VIEW (My Card, Favorites, Alphabetical A-Z strip)
        -- -------------------------------------------------------------
        local cHeader = Instance.new("Frame", contactsView)
        cHeader.Size = UDim2.new(1, -36, 0, 44)
        cHeader.Position = UDim2.new(0, 18, 0, 44)
        cHeader.BackgroundTransparency = 1
        cHeader.ZIndex = 18

        local cTitle = Instance.new("TextLabel", cHeader)
        cTitle.Size = UDim2.new(1, -50, 1, 0)
        cTitle.Position = UDim2.new(0, 0, 0, 0)
        cTitle.BackgroundTransparency = 1
        cTitle.Text = "Contacts"
        cTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        cTitle.Font = Enum.Font.GothamBold
        cTitle.TextSize = 28
        cTitle.TextXAlignment = Enum.TextXAlignment.Left
        cTitle.ZIndex = 19

        local cAddBtn = Instance.new("TextLabel", cHeader)
        cAddBtn.Size = UDim2.new(0, 36, 0, 36)
        cAddBtn.Position = UDim2.new(1, -36, 0.5, -18)
        cAddBtn.BackgroundTransparency = 1
        cAddBtn.Text = "＋"
        cAddBtn.TextColor3 = Color3.fromRGB(0, 122, 255)
        cAddBtn.Font = Enum.Font.GothamBold
        cAddBtn.TextSize = 22
        cAddBtn.ZIndex = 19

        local cSearch = Instance.new("Frame", contactsView)
        cSearch.Size = UDim2.new(1, -36, 0, 36)
        cSearch.Position = UDim2.new(0, 18, 0, 92)
        cSearch.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        cSearch.ZIndex = 18
        Instance.new("UICorner", cSearch).CornerRadius = UDim.new(0, 10)

        local cSearchTxt = Instance.new("TextLabel", cSearch)
        cSearchTxt.Size = UDim2.new(1, -36, 1, 0)
        cSearchTxt.Position = UDim2.new(0, 32, 0, 0)
        cSearchTxt.BackgroundTransparency = 1
        cSearchTxt.Text = "Search"
        cSearchTxt.TextColor3 = Color3.fromRGB(142, 142, 147)
        cSearchTxt.Font = Enum.Font.Gotham
        cSearchTxt.TextSize = 13
        cSearchTxt.TextXAlignment = Enum.TextXAlignment.Left
        cSearchTxt.ZIndex = 19

        -- My Card Card
        local myCard = Instance.new("Frame", contactsView)
        myCard.Size = UDim2.new(1, -36, 0, 56)
        myCard.Position = UDim2.new(0, 18, 0, 136)
        myCard.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
        myCard.ZIndex = 18
        Instance.new("UICorner", myCard).CornerRadius = UDim.new(0, 12)

        local mcAv = Instance.new("Frame", myCard)
        mcAv.Size = UDim2.new(0, 40, 0, 40)
        mcAv.Position = UDim2.new(0, 10, 0.5, -20)
        mcAv.BackgroundColor3 = Color3.fromRGB(48, 52, 64)
        mcAv.ZIndex = 19
        Instance.new("UICorner", mcAv).CornerRadius = UDim.new(1, 0)

        local mcAvIco = Instance.new("TextLabel", mcAv)
        mcAvIco.Size = UDim2.new(1, 0, 1, 0)
        mcAvIco.BackgroundTransparency = 1
        mcAvIco.Text = "👤"
        mcAvIco.TextSize = 18
        mcAvIco.ZIndex = 20

        local mcName = Instance.new("TextLabel", myCard)
        mcName.Size = UDim2.new(1, -60, 0, 18)
        mcName.Position = UDim2.new(0, 58, 0, 10)
        mcName.BackgroundTransparency = 1
        mcName.Text = "My Card"
        mcName.TextColor3 = Color3.fromRGB(255, 255, 255)
        mcName.Font = Enum.Font.GothamBold
        mcName.TextSize = 14
        mcName.TextXAlignment = Enum.TextXAlignment.Left
        mcName.ZIndex = 19

        local mcNum = Instance.new("TextLabel", myCard)
        mcNum.Size = UDim2.new(1, -60, 0, 14)
        mcNum.Position = UDim2.new(0, 58, 0, 30)
        mcNum.BackgroundTransparency = 1
        mcNum.Text = "555 123 4567"
        mcNum.TextColor3 = Color3.fromRGB(142, 142, 147)
        mcNum.Font = Enum.Font.Gotham
        mcNum.TextSize = 11
        mcNum.TextXAlignment = Enum.TextXAlignment.Left
        mcNum.ZIndex = 19

        -- Contacts Scroll & Alphabet Strip
        local cScroll = Instance.new("ScrollingFrame", contactsView)
        cScroll.Size = UDim2.new(1, -54, 1, -276)
        cScroll.Position = UDim2.new(0, 18, 0, 200)
        cScroll.BackgroundTransparency = 1
        cScroll.ScrollBarThickness = 0
        cScroll.ZIndex = 18

        local csLayout = Instance.new("UIListLayout", cScroll)
        csLayout.SortOrder = Enum.SortOrder.LayoutOrder
        csLayout.Padding = UDim.new(0, 8)

        local function makeSectionHeader(title: string)
            local lbl = Instance.new("TextLabel", cScroll)
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 19
        end

        local function makeContactItem(name: string, phone: string)
            local btn = Instance.new("TextButton", cScroll)
            btn.Size = UDim2.new(1, 0, 0, 42)
            btn.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 19
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

            local av = Instance.new("Frame", btn)
            av.Size = UDim2.new(0, 30, 0, 30)
            av.Position = UDim2.new(0, 8, 0.5, -15)
            av.BackgroundColor3 = Color3.fromRGB(44, 48, 60)
            av.ZIndex = 20
            Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

            local avTxt = Instance.new("TextLabel", av)
            avTxt.Size = UDim2.new(1, 0, 1, 0)
            avTxt.BackgroundTransparency = 1
            avTxt.Text = string.sub(name, 1, 1)
            avTxt.TextColor3 = Color3.fromRGB(240, 240, 245)
            avTxt.Font = Enum.Font.GothamBold
            avTxt.TextSize = 12
            avTxt.ZIndex = 21

            local n = Instance.new("TextLabel", btn)
            n.Size = UDim2.new(1, -50, 1, 0)
            n.Position = UDim2.new(0, 46, 0, 0)
            n.BackgroundTransparency = 1
            n.Text = name
            n.TextColor3 = Color3.fromRGB(245, 245, 250)
            n.Font = Enum.Font.GothamMedium
            n.TextSize = 13.5
            n.TextXAlignment = Enum.TextXAlignment.Left
            n.ZIndex = 20

            btn.MouseButton1Click:Connect(function()
                startCall(phone)
            end)
        end

        makeSectionHeader("★ Favorites")
        makeContactItem("Alex Rivera", "555 111 0001")
        makeContactItem("Benni Parker", "555 111 0002")
        makeContactItem("Los Santos Taxi", "555 333 0044")

        makeSectionHeader("A")
        makeContactItem("Alexander Stone", "555 222 0001")
        makeContactItem("Andre Heinicke", "555 222 0002")

        makeSectionHeader("B")
        makeContactItem("Benny's Motor Works", "555 444 0001")
        makeContactItem("Bryce Walker", "555 444 0002")

        -- Alphabet Index Scrubber Strip on Right
        local alphaStrip = Instance.new("Frame", contactsView)
        alphaStrip.Name = "AlphabetIndex"
        alphaStrip.Size = UDim2.new(0, 14, 1, -276)
        alphaStrip.Position = UDim2.new(1, -16, 0, 200)
        alphaStrip.BackgroundTransparency = 1
        alphaStrip.ZIndex = 20

        local asLayout = Instance.new("UIListLayout", alphaStrip)
        asLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        asLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local LETTERS = {"★", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"}
        for _, l in ipairs(LETTERS) do
            local lLbl = Instance.new("TextLabel", alphaStrip)
            lLbl.Size = UDim2.new(1, 0, 0, 11)
            lLbl.BackgroundTransparency = 1
            lLbl.Text = l
            lLbl.TextColor3 = Color3.fromRGB(0, 122, 255)
            lLbl.Font = Enum.Font.GothamBold
            lLbl.TextSize = 8
            lLbl.ZIndex = 21
        end

        -- -------------------------------------------------------------
        -- Tab 3: KEYPAD VIEW (Circular Buttons, Numbers, DTMF Tones)
        -- -------------------------------------------------------------
        local pNumber = Instance.new("TextLabel", keypadView)
        pNumber.Name = "NumberDisplay"
        pNumber.Size = UDim2.new(1, -50, 0, 46)
        pNumber.Position = UDim2.new(0, 25, 0, 60)
        pNumber.BackgroundTransparency = 1
        pNumber.Text = ""
        pNumber.TextColor3 = Color3.fromRGB(255, 255, 255)
        pNumber.Font = Enum.Font.GothamBold
        pNumber.TextSize = 32
        pNumber.TextXAlignment = Enum.TextXAlignment.Center
        pNumber.ZIndex = 18

        local backBtn = Instance.new("TextButton", keypadView)
        backBtn.Size = UDim2.new(0, 36, 0, 36)
        backBtn.Position = UDim2.new(1, -48, 0, 65)
        backBtn.BackgroundTransparency = 1
        backBtn.Text = "⌫"
        backBtn.Font = Enum.Font.GothamBold
        backBtn.TextSize = 22
        backBtn.TextColor3 = Color3.fromRGB(140, 145, 160)
        backBtn.ZIndex = 19
        backBtn.MouseButton1Click:Connect(function()
            playTone(1.4)
            if #pNumber.Text > 0 then
                pNumber.Text = string.sub(pNumber.Text, 1, #pNumber.Text - 1)
            end
        end)

        local dialPad = Instance.new("Frame", keypadView)
        dialPad.Name = "DialPad"
        dialPad.AnchorPoint = Vector2.new(0.5, 0)
        dialPad.Position = UDim2.new(0.5, 0, 0, 120)
        dialPad.Size = UDim2.new(0, 246, 0, 320)
        dialPad.BackgroundTransparency = 1
        dialPad.ZIndex = 18

        local dpLayout = Instance.new("UIGridLayout", dialPad)
        dpLayout.CellSize = UDim2.new(0, 66, 0, 66)
        dpLayout.CellPadding = UDim2.new(0, 24, 0, 12)
        dpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local keys = {
            {"1", "", 1.8}, {"2", "ABC", 1.9}, {"3", "DEF", 2.0},
            {"4", "GHI", 2.1}, {"5", "JKL", 2.2}, {"6", "MNO", 2.3},
            {"7", "PQRS", 2.4}, {"8", "TUV", 2.5}, {"9", "WXYZ", 2.6},
            {"*", "", 2.7}, {"0", "+", 2.2}, {"#", "", 2.8}
        }

        for _, key in ipairs(keys) do
            local b = Instance.new("TextButton", dialPad)
            b.Size = UDim2.new(0, 66, 0, 66)
            b.BackgroundColor3 = Color3.fromRGB(34, 38, 48)
            b.Text = ""
            b.AutoButtonColor = false
            b.ZIndex = 19
            Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

            local mainD = Instance.new("TextLabel", b)
            mainD.Size = UDim2.new(1, 0, 0, 30)
            mainD.Position = UDim2.new(0, 0, 0, 10)
            mainD.BackgroundTransparency = 1
            mainD.Text = key[1]
            mainD.Font = Enum.Font.Gotham
            mainD.TextSize = 28
            mainD.TextColor3 = Color3.fromRGB(255, 255, 255)
            mainD.ZIndex = 20

            if key[2] ~= "" then
                local subD = Instance.new("TextLabel", b)
                subD.Size = UDim2.new(1, 0, 0, 14)
                subD.Position = UDim2.new(0, 0, 0, 40)
                subD.BackgroundTransparency = 1
                subD.Text = key[2]
                subD.Font = Enum.Font.GothamBold
                subD.TextSize = 8.5
                subD.TextColor3 = Color3.fromRGB(140, 145, 160)
                subD.ZIndex = 20
            end

            b.MouseButton1Click:Connect(function()
                playTone(key[3])
                if #pNumber.Text < 15 then
                    pNumber.Text = pNumber.Text .. key[1]
                end
            end)
        end

        local callBtn = Instance.new("TextButton", keypadView)
        callBtn.Name = "CallButton"
        callBtn.AnchorPoint = Vector2.new(0.5, 0)
        callBtn.Position = UDim2.new(0.5, 0, 0, 450)
        callBtn.Size = UDim2.new(0, 66, 0, 66)
        callBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        callBtn.Text = "📞"
        callBtn.TextSize = 28
        callBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        callBtn.BorderSizePixel = 0
        callBtn.ZIndex = 19
        Instance.new("UICorner", callBtn).CornerRadius = UDim.new(1, 0)
        callBtn.MouseButton1Click:Connect(function()
            startCall(pNumber.Text)
        end)

        -- -------------------------------------------------------------
        -- Bottom Tab Bar (Recents, Contacts, Keypad)
        -- -------------------------------------------------------------
        local tabFrame = Instance.new("Frame", phoneApp)
        tabFrame.Name = "TabBar"
        tabFrame.AnchorPoint = Vector2.new(0.5, 1)
        tabFrame.Position = UDim2.new(0.5, 0, 1, -26)
        tabFrame.Size = UDim2.new(1, -36, 0, 48)
        tabFrame.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        tabFrame.ZIndex = 22
        Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 24)

        local tLayout = Instance.new("UIListLayout", tabFrame)
        tLayout.FillDirection = Enum.FillDirection.Horizontal
        tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        tLayout.Padding = UDim.new(0, 8)

        local function makeTabBtn(name: string, icon: string, targetView: Frame, isDefault: boolean)
            local btn = Instance.new("TextButton", tabFrame)
            btn.Name = "Tab_" .. name
            btn.Size = UDim2.new(0.31, 0, 1, -8)
            btn.BackgroundColor3 = isDefault and Color3.fromRGB(48, 52, 64) or Color3.fromRGB(28, 30, 38)
            btn.BackgroundTransparency = isDefault and 0 or 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 23
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = icon .. " " .. name
            lbl.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(142, 142, 147)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11.5
            lbl.ZIndex = 24

            btn.MouseButton1Click:Connect(function()
                recentsView.Visible = false
                contactsView.Visible = false
                keypadView.Visible = false
                targetView.Visible = true

                for _, child in ipairs(tabFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundTransparency = 1
                        local txt = child:FindFirstChildOfClass("TextLabel")
                        if txt then txt.TextColor3 = Color3.fromRGB(142, 142, 147) end
                    end
                end
                btn.BackgroundTransparency = 0
                btn.BackgroundColor3 = Color3.fromRGB(48, 52, 64)
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
        end

        makeTabBtn("Recents", "🕒", recentsView, true)
        makeTabBtn("Contacts", "👤", contactsView, false)
        makeTabBtn("Keypad", "🔢", keypadView, false)
    end

    -- =========================================================================
    -- 2. MESSAGES APP (Dark Obsidian, Chat Thread, Inline Cards, '+' Popover)
    -- =========================================================================
    local msgApp = createBaseApp(appContainer, "Messages", Color3.fromRGB(14, 16, 24))
    do
        -- Header
        local mHeader = Instance.new("Frame", msgApp)
        mHeader.Size = UDim2.new(1, 0, 0, 72)
        mHeader.Position = UDim2.new(0, 0, 0, 36)
        mHeader.BackgroundTransparency = 1
        mHeader.ZIndex = 17

        local backBtn = Instance.new("TextButton", mHeader)
        backBtn.Size = UDim2.new(0, 36, 0, 36)
        backBtn.Position = UDim2.new(0, 16, 0.5, -18)
        backBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        backBtn.Text = "‹"
        backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        backBtn.Font = Enum.Font.GothamBold
        backBtn.TextSize = 22
        backBtn.ZIndex = 18
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(1, 0)
        backBtn.MouseButton1Click:Connect(function()
            if ctx.goHome then ctx.goHome() end
        end)

        local contactBox = Instance.new("Frame", mHeader)
        contactBox.Size = UDim2.new(1, -120, 1, 0)
        contactBox.Position = UDim2.new(0, 60, 0, 0)
        contactBox.BackgroundTransparency = 1
        contactBox.ZIndex = 18

        local av = Instance.new("Frame", contactBox)
        av.Size = UDim2.new(0, 32, 0, 32)
        av.Position = UDim2.new(0, 0, 0.5, -16)
        av.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
        av.ZIndex = 19
        Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

        local avTxt = Instance.new("TextLabel", av)
        avTxt.Size = UDim2.new(1, 0, 1, 0)
        avTxt.BackgroundTransparency = 1
        avTxt.Text = "AH"
        avTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        avTxt.Font = Enum.Font.GothamBold
        avTxt.TextSize = 12
        avTxt.ZIndex = 20

        local cName = Instance.new("TextLabel", contactBox)
        cName.Size = UDim2.new(1, -40, 1, 0)
        cName.Position = UDim2.new(0, 38, 0, 0)
        cName.BackgroundTransparency = 1
        cName.Text = "Andre Heinicke ›"
        cName.TextColor3 = Color3.fromRGB(255, 255, 255)
        cName.Font = Enum.Font.GothamBold
        cName.TextSize = 14
        cName.TextXAlignment = Enum.TextXAlignment.Left
        cName.ZIndex = 19

        -- Chat Messages Scroll
        local mScroll = Instance.new("ScrollingFrame", msgApp)
        mScroll.Size = UDim2.new(1, -32, 1, -180)
        mScroll.Position = UDim2.new(0, 16, 0, 108)
        mScroll.BackgroundTransparency = 1
        mScroll.ScrollBarThickness = 0
        mScroll.ZIndex = 17

        local msLayout = Instance.new("UIListLayout", mScroll)
        msLayout.SortOrder = Enum.SortOrder.LayoutOrder
        msLayout.Padding = UDim.new(0, 10)

        local function makeTimestamp(txt: string)
            local lbl = Instance.new("TextLabel", mScroll)
            lbl.Size = UDim2.new(1, 0, 0, 24)
            lbl.BackgroundTransparency = 1
            lbl.Text = txt
            lbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 10.5
            lbl.ZIndex = 18
        end

        local function makeBubble(txt: string, isSender: boolean, delivered: boolean?)
            local bFrame = Instance.new("Frame", mScroll)
            bFrame.Size = UDim2.new(1, 0, 0, delivered and 46 or 34)
            bFrame.BackgroundTransparency = 1
            bFrame.ZIndex = 18

            local bub = Instance.new("Frame", bFrame)
            bub.AnchorPoint = Vector2.new(isSender and 1 or 0, 0)
            bub.Position = UDim2.new(isSender and 1 or 0, 0, 0, 0)
            bub.Size = UDim2.new(0, 220, 0, 32)
            bub.BackgroundColor3 = isSender and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(36, 38, 48)
            bub.ZIndex = 19
            Instance.new("UICorner", bub).CornerRadius = UDim.new(0, 14)

            local bText = Instance.new("TextLabel", bub)
            bText.Size = UDim2.new(1, -20, 1, 0)
            bText.Position = UDim2.new(0, 10, 0, 0)
            bText.BackgroundTransparency = 1
            bText.Text = txt
            bText.TextColor3 = Color3.fromRGB(255, 255, 255)
            bText.Font = Enum.Font.GothamMedium
            bText.TextSize = 12.5
            bText.TextXAlignment = isSender and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
            bText.ZIndex = 20

            if delivered then
                local dLbl = Instance.new("TextLabel", bFrame)
                dLbl.AnchorPoint = Vector2.new(1, 0)
                dLbl.Position = UDim2.new(1, 0, 0, 34)
                dLbl.Size = UDim2.new(0, 100, 0, 12)
                dLbl.BackgroundTransparency = 1
                dLbl.Text = "Delivered"
                dLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
                dLbl.Font = Enum.Font.Gotham
                dLbl.TextSize = 9.5
                dLbl.TextXAlignment = Enum.TextXAlignment.Right
                dLbl.ZIndex = 20
            end
        end

        makeTimestamp("Text Message · SMS\nToday, 02:39")
        makeBubble("Dein Taxi wartet vor dem Haupteingang.", false)
        makeBubble("Danke, ich komme sofort raus.", true, true)
        makeBubble("hi", true, false)
        makeBubble("🥳 🐺 🦝 🍻", true, true)

        -- Inline Shared Contact Card (Samantha Cole)
        local cCard = Instance.new("Frame", mScroll)
        cCard.Size = UDim2.new(1, 0, 0, 110)
        cCard.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        cCard.ZIndex = 18
        Instance.new("UICorner", cCard).CornerRadius = UDim.new(0, 14)

        local ccAv = Instance.new("Frame", cCard)
        ccAv.Size = UDim2.new(0, 42, 0, 42)
        ccAv.Position = UDim2.new(0, 12, 0, 12)
        ccAv.BackgroundColor3 = Color3.fromRGB(60, 64, 76)
        ccAv.ZIndex = 19
        Instance.new("UICorner", ccAv).CornerRadius = UDim.new(1, 0)

        local ccAvTxt = Instance.new("TextLabel", ccAv)
        ccAvTxt.Size = UDim2.new(1, 0, 1, 0)
        ccAvTxt.BackgroundTransparency = 1
        ccAvTxt.Text = "SC"
        ccAvTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        ccAvTxt.Font = Enum.Font.GothamBold
        ccAvTxt.TextSize = 15
        ccAvTxt.ZIndex = 20

        local ccName = Instance.new("TextLabel", cCard)
        ccName.Size = UDim2.new(1, -70, 0, 18)
        ccName.Position = UDim2.new(0, 62, 0, 12)
        ccName.BackgroundTransparency = 1
        ccName.Text = "Samantha Cole"
        ccName.TextColor3 = Color3.fromRGB(255, 255, 255)
        ccName.Font = Enum.Font.GothamBold
        ccName.TextSize = 14
        ccName.TextXAlignment = Enum.TextXAlignment.Left
        ccName.ZIndex = 19

        local ccSub = Instance.new("TextLabel", cCard)
        ccSub.Size = UDim2.new(1, -70, 0, 14)
        ccSub.Position = UDim2.new(0, 62, 0, 32)
        ccSub.BackgroundTransparency = 1
        ccSub.Text = "Downtown Cab Co. · (5553330044)"
        ccSub.TextColor3 = Color3.fromRGB(142, 142, 147)
        ccSub.Font = Enum.Font.Gotham
        ccSub.TextSize = 11
        ccSub.TextXAlignment = Enum.TextXAlignment.Left
        ccSub.ZIndex = 19

        local ccBtnRow = Instance.new("Frame", cCard)
        ccBtnRow.Size = UDim2.new(1, -24, 0, 32)
        ccBtnRow.Position = UDim2.new(0, 12, 0, 66)
        ccBtnRow.BackgroundTransparency = 1
        ccBtnRow.ZIndex = 19

        local btnMsg = Instance.new("TextButton", ccBtnRow)
        btnMsg.Size = UDim2.new(0.48, 0, 1, 0)
        btnMsg.BackgroundColor3 = Color3.fromRGB(36, 78, 48)
        btnMsg.Text = "💬 Message"
        btnMsg.TextColor3 = Color3.fromRGB(52, 199, 89)
        btnMsg.Font = Enum.Font.GothamBold
        btnMsg.TextSize = 11
        btnMsg.ZIndex = 20
        Instance.new("UICorner", btnMsg).CornerRadius = UDim.new(0, 8)

        local btnAdd = Instance.new("TextButton", ccBtnRow)
        btnAdd.Size = UDim2.new(0.48, 0, 1, 0)
        btnAdd.Position = UDim2.new(0.52, 0, 0, 0)
        btnAdd.BackgroundColor3 = Color3.fromRGB(36, 78, 48)
        btnAdd.Text = "👤+ Add Contact"
        btnAdd.TextColor3 = Color3.fromRGB(52, 199, 89)
        btnAdd.Font = Enum.Font.GothamBold
        btnAdd.TextSize = 11
        btnAdd.ZIndex = 20
        Instance.new("UICorner", btnAdd).CornerRadius = UDim.new(0, 8)

        -- Inline Shared Picstagram Card
        local pCard = Instance.new("Frame", mScroll)
        pCard.Size = UDim2.new(1, 0, 0, 180)
        pCard.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        pCard.ZIndex = 18
        Instance.new("UICorner", pCard).CornerRadius = UDim.new(0, 14)

        local pcHeader = Instance.new("Frame", pCard)
        pcHeader.Size = UDim2.new(1, -20, 0, 28)
        pcHeader.Position = UDim2.new(0, 10, 0, 6)
        pcHeader.BackgroundTransparency = 1
        pcHeader.ZIndex = 19

        local pcIcon = Instance.new("TextLabel", pcHeader)
        pcIcon.Size = UDim2.new(0, 20, 1, 0)
        pcIcon.BackgroundTransparency = 1
        pcIcon.Text = "📷"
        pcIcon.TextSize = 14
        pcIcon.ZIndex = 20

        local pcTitle = Instance.new("TextLabel", pcHeader)
        pcTitle.Size = UDim2.new(1, -30, 1, 0)
        pcTitle.Position = UDim2.new(0, 24, 0, 0)
        pcTitle.BackgroundTransparency = 1
        pcTitle.Text = "Picstagram · Post"
        pcTitle.TextColor3 = Color3.fromRGB(255, 45, 85)
        pcTitle.Font = Enum.Font.GothamBold
        pcTitle.TextSize = 12
        pcTitle.TextXAlignment = Enum.TextXAlignment.Left
        pcTitle.ZIndex = 20

        local pcImg = Instance.new("Frame", pCard)
        pcImg.Size = UDim2.new(1, -20, 0, 95)
        pcImg.Position = UDim2.new(0, 10, 0, 36)
        pcImg.BackgroundColor3 = Color3.fromRGB(48, 54, 70)
        pcImg.ZIndex = 19
        Instance.new("UICorner", pcImg).CornerRadius = UDim.new(0, 8)

        local pcImgTxt = Instance.new("TextLabel", pcImg)
        pcImgTxt.Size = UDim2.new(1, 0, 1, 0)
        pcImgTxt.BackgroundTransparency = 1
        pcImgTxt.Text = "🌄 Vinewood Hills Sunset"
        pcImgTxt.TextColor3 = Color3.fromRGB(240, 240, 245)
        pcImgTxt.Font = Enum.Font.GothamBold
        pcImgTxt.TextSize = 13
        pcImgTxt.ZIndex = 20

        local pcCap = Instance.new("TextLabel", pCard)
        pcCap.Size = UDim2.new(1, -20, 0, 36)
        pcCap.Position = UDim2.new(0, 10, 0, 136)
        pcCap.BackgroundTransparency = 1
        pcCap.Text = "@morgan: Neon nights in Vinewood\nDie besten Lichter der Stadt - direkt aus Vinewood."
        pcCap.TextColor3 = Color3.fromRGB(220, 222, 230)
        pcCap.Font = Enum.Font.Gotham
        pcCap.TextSize = 10.5
        pcCap.TextXAlignment = Enum.TextXAlignment.Left
        pcCap.ZIndex = 20

        -- Bottom Input Bar
        local inputBar = Instance.new("Frame", msgApp)
        inputBar.Size = UDim2.new(1, -24, 0, 44)
        inputBar.AnchorPoint = Vector2.new(0.5, 1)
        inputBar.Position = UDim2.new(0.5, 0, 1, -26)
        inputBar.BackgroundTransparency = 1
        inputBar.ZIndex = 22

        local attachBtn = Instance.new("TextButton", inputBar)
        attachBtn.Name = "AttachBtn"
        attachBtn.Size = UDim2.new(0, 38, 0, 38)
        attachBtn.Position = UDim2.new(0, 0, 0.5, -19)
        attachBtn.BackgroundColor3 = Color3.fromRGB(36, 38, 48)
        attachBtn.Text = "＋"
        attachBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        attachBtn.Font = Enum.Font.GothamBold
        attachBtn.TextSize = 20
        attachBtn.ZIndex = 23
        Instance.new("UICorner", attachBtn).CornerRadius = UDim.new(1, 0)

        local inputField = Instance.new("TextBox", inputBar)
        inputField.Size = UDim2.new(1, -90, 0, 38)
        inputField.Position = UDim2.new(0, 46, 0.5, -19)
        inputField.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        inputField.PlaceholderText = "Message"
        inputField.PlaceholderColor3 = Color3.fromRGB(142, 142, 147)
        inputField.Text = ""
        inputField.TextColor3 = Color3.fromRGB(255, 255, 255)
        inputField.Font = Enum.Font.Gotham
        inputField.TextSize = 13
        inputField.ClearTextOnFocus = false
        inputField.ZIndex = 23
        Instance.new("UICorner", inputField).CornerRadius = UDim.new(0, 19)

        local micBtn = Instance.new("TextButton", inputBar)
        micBtn.Size = UDim2.new(0, 38, 0, 38)
        micBtn.Position = UDim2.new(1, -38, 0.5, -19)
        micBtn.BackgroundColor3 = Color3.fromRGB(36, 38, 48)
        micBtn.Text = "🎙"
        micBtn.TextColor3 = Color3.fromRGB(52, 199, 89)
        micBtn.TextSize = 16
        micBtn.ZIndex = 23
        Instance.new("UICorner", micBtn).CornerRadius = UDim.new(1, 0)

        -- Contextual Upward Attachment Popover Menu
        local attachPopover = Instance.new("Frame", msgApp)
        attachPopover.Name = "AttachmentPopover"
        attachPopover.Size = UDim2.new(0, 170, 0, 240)
        attachPopover.AnchorPoint = Vector2.new(0, 1)
        attachPopover.Position = UDim2.new(0, 12, 1, -76)
        attachPopover.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        attachPopover.Visible = false
        attachPopover.ZIndex = 40
        Instance.new("UICorner", attachPopover).CornerRadius = UDim.new(0, 16)

        local apLayout = Instance.new("UIListLayout", attachPopover)
        apLayout.SortOrder = Enum.SortOrder.LayoutOrder
        apLayout.Padding = UDim.new(0, 2)

        local function makeAttachOption(title: string, icon: string)
            local btn = Instance.new("TextButton", attachPopover)
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 41

            local ico = Instance.new("TextLabel", btn)
            ico.Size = UDim2.new(0, 24, 1, 0)
            ico.Position = UDim2.new(0, 10, 0, 0)
            ico.BackgroundTransparency = 1
            ico.Text = icon
            ico.TextSize = 16
            ico.ZIndex = 42

            local t = Instance.new("TextLabel", btn)
            t.Size = UDim2.new(1, -44, 1, 0)
            t.Position = UDim2.new(0, 40, 0, 0)
            t.BackgroundTransparency = 1
            t.Text = title
            t.TextColor3 = Color3.fromRGB(240, 240, 245)
            t.Font = Enum.Font.GothamMedium
            t.TextSize = 12
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.ZIndex = 42

            btn.MouseButton1Click:Connect(function()
                attachPopover.Visible = false
                showNotification("Messages", "Attached " .. title)
            end)
        end

        makeAttachOption("Attach Photo", "🖼️")
        makeAttachOption("Take Photo", "📷")
        makeAttachOption("Emoji", "😀")
        makeAttachOption("Share Contact", "👤")
        makeAttachOption("Attach GIF", "🎬")
        makeAttachOption("Attach Video", "📹")

        attachBtn.MouseButton1Click:Connect(function()
            attachPopover.Visible = not attachPopover.Visible
        end)
    end

    -- =========================================================================
    -- 3. NOTES APP (Dark Obsidian Text Editor)
    -- =========================================================================
    local notesApp = createBaseApp(appContainer, "Notes", Color3.fromRGB(14, 16, 24))
    do
        local nHeader = Instance.new("Frame", notesApp)
        nHeader.Size = UDim2.new(1, 0, 0, 70)
        nHeader.Position = UDim2.new(0, 0, 0, 36)
        nHeader.BackgroundTransparency = 1
        nHeader.ZIndex = 17

        local nTitle = Instance.new("TextLabel", nHeader)
        nTitle.Size = UDim2.new(1, -36, 1, 0)
        nTitle.Position = UDim2.new(0, 18, 0, 0)
        nTitle.BackgroundTransparency = 1
        nTitle.Text = "Notes"
        nTitle.TextColor3 = Color3.fromRGB(255, 204, 0)
        nTitle.Font = Enum.Font.GothamBold
        nTitle.TextSize = 28
        nTitle.TextXAlignment = Enum.TextXAlignment.Left
        nTitle.ZIndex = 18

        local nCard = Instance.new("Frame", notesApp)
        nCard.Size = UDim2.new(1, -36, 1, -140)
        nCard.Position = UDim2.new(0, 18, 0, 106)
        nCard.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
        nCard.ZIndex = 17
        Instance.new("UICorner", nCard).CornerRadius = UDim.new(0, 14)

        local nBody = Instance.new("TextBox", nCard)
        nBody.Size = UDim2.new(1, -24, 1, -24)
        nBody.Position = UDim2.new(0, 12, 0, 12)
        nBody.BackgroundTransparency = 1
        nBody.Text = "Sky Phone Evaluation Notes:\n- Verified 100% dark mode parity.\n- Tested BottomSheet sliding modals.\n- Clock drum roller picker operational.\n- Music widget dynamic sync enabled."
        nBody.TextColor3 = Color3.fromRGB(240, 240, 245)
        nBody.Font = Enum.Font.Gotham
        nBody.TextSize = 13
        nBody.TextXAlignment = Enum.TextXAlignment.Left
        nBody.TextYAlignment = Enum.TextYAlignment.Top
        nBody.ClearTextOnFocus = false
        nBody.MultiLine = true
        nBody.TextWrapped = true
        nBody.ZIndex = 18
    end

    -- =========================================================================
    -- 4. SETTINGS APP (Dark Obsidian System Toggles)
    -- =========================================================================
    local settingsApp = createBaseApp(appContainer, "Settings", Color3.fromRGB(14, 16, 24))
    do
        local sHeader = Instance.new("Frame", settingsApp)
        sHeader.Size = UDim2.new(1, 0, 0, 70)
        sHeader.Position = UDim2.new(0, 0, 0, 36)
        sHeader.BackgroundTransparency = 1
        sHeader.ZIndex = 17

        local sTitle = Instance.new("TextLabel", sHeader)
        sTitle.Size = UDim2.new(1, -36, 1, 0)
        sTitle.Position = UDim2.new(0, 18, 0, 0)
        sTitle.BackgroundTransparency = 1
        sTitle.Text = "Settings"
        sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        sTitle.Font = Enum.Font.GothamBold
        sTitle.TextSize = 28
        sTitle.TextXAlignment = Enum.TextXAlignment.Left
        sTitle.ZIndex = 18

        local sCard = Instance.new("Frame", settingsApp)
        sCard.Size = UDim2.new(1, -36, 0, 180)
        sCard.Position = UDim2.new(0, 18, 0, 110)
        sCard.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
        sCard.ZIndex = 17
        Instance.new("UICorner", sCard).CornerRadius = UDim.new(0, 14)

        local scLayout = Instance.new("UIListLayout", sCard)
        scLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local function makeToggleRow(name: string, icon: string, initial: boolean, onToggle: (boolean) -> ())
            local row = Instance.new("Frame", sCard)
            row.Size = UDim2.new(1, 0, 0, 44)
            row.BackgroundTransparency = 1
            row.ZIndex = 18

            local ico = Instance.new("TextLabel", row)
            ico.Size = UDim2.new(0, 24, 1, 0)
            ico.Position = UDim2.new(0, 12, 0, 0)
            ico.BackgroundTransparency = 1
            ico.Text = icon
            ico.TextSize = 16
            ico.ZIndex = 19

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -110, 1, 0)
            lbl.Position = UDim2.new(0, 44, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13.5
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 19

            local switch = Instance.new("TextButton", row)
            switch.Size = UDim2.new(0, 46, 0, 26)
            switch.Position = UDim2.new(1, -58, 0.5, -13)
            switch.BackgroundColor3 = initial and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(58, 62, 74)
            switch.Text = ""
            switch.AutoButtonColor = false
            switch.ZIndex = 19
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", switch)
            knob.Size = UDim2.new(0, 22, 0, 22)
            knob.Position = initial and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 20
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local state = initial
            switch.MouseButton1Click:Connect(function()
                state = not state
                switch.BackgroundColor3 = state and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(58, 62, 74)
                knob.Position = state and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
                onToggle(state)
            end)
        end

        makeToggleRow("Airplane Mode", "✈️", false, function(on)
            if ctx.setAirplaneMode then ctx.setAirplaneMode(on) end
            showNotification("Settings", on and "Airplane Mode Enabled" or "Airplane Mode Disabled")
        end)
        makeToggleRow("Dark Appearance", "🌙", true, function(on) end)
        makeToggleRow("Sounds & Haptics", "🔊", true, function(on) end)
        makeToggleRow("Bluetooth", "ᛒ", true, function(on) end)
    end
end

return AppSuite_Core
