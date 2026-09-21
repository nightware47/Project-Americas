-- ============================================================================
-- 12. NOTES APP (Matching official_notes.png)
-- ============================================================================
local notesApp = createBaseApp("Notes", Color3.fromRGB(242, 244, 248))
do
    local nTitle = Instance.new("TextLabel", notesApp)
    nTitle.Size = UDim2.new(1, -36, 0, 38)
    nTitle.Position = UDim2.new(0, 18, 0, 48)
    nTitle.Text = "Notes"
    nTitle.Font = Enum.Font.GothamBold
    nTitle.TextSize = 34
    nTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    nTitle.TextXAlignment = Enum.TextXAlignment.Left
    nTitle.BackgroundTransparency = 1
    nTitle.ZIndex = 18

    local nCard = Instance.new("Frame", notesApp)
    nCard.Size = UDim2.new(1, -36, 0, 290)
    nCard.Position = UDim2.new(0, 18, 0, 96)
    nCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    nCard.BorderSizePixel = 0
    nCard.ZIndex = 18
    Instance.new("UICorner", nCard).CornerRadius = UDim.new(0, 20)
    local ncs = Instance.new("UIStroke", nCard)
    ncs.Color = Color3.fromRGB(230, 234, 244)

    local function makeNoteRow(title, datePreview, isPinned, yPos)
        local row = Instance.new("Frame", nCard)
        row.Size = UDim2.new(1, 0, 0, 70)
        row.Position = UDim2.new(0, 0, 0, yPos)
        row.BackgroundTransparency = 1
        row.ZIndex = 19

        local t = Instance.new("TextLabel", row)
        t.Size = UDim2.new(1, -90, 0, 20)
        t.Position = UDim2.new(0, 18, 0, 14)
        t.Text = title
        t.Font = Enum.Font.GothamBold
        t.TextSize = 15
        t.TextColor3 = Color3.fromRGB(15, 18, 28)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.BackgroundTransparency = 1
        t.ZIndex = 20

        if isPinned then
            local pin = Instance.new("TextLabel", row)
            pin.Size = UDim2.new(0, 20, 0, 20)
            pin.Position = UDim2.new(1, -70, 0, 14)
            pin.Text = "📌"
            pin.TextSize = 14
            pin.BackgroundTransparency = 1
            pin.ZIndex = 20
        end

        local trash = Instance.new("TextLabel", row)
        trash.Size = UDim2.new(0, 20, 0, 20)
        trash.Position = UDim2.new(1, -40, 0, 14)
        trash.Text = "🗑"
        trash.TextSize = 14
        trash.TextColor3 = Color3.fromRGB(180, 185, 200)
        trash.BackgroundTransparency = 1
        trash.ZIndex = 20

        local dp = Instance.new("TextLabel", row)
        dp.Size = UDim2.new(1, -40, 0, 16)
        dp.Position = UDim2.new(0, 18, 0, 36)
        dp.Text = datePreview
        dp.Font = Enum.Font.Gotham
        dp.TextSize = 12
        dp.TextColor3 = Color3.fromRGB(140, 145, 160)
        dp.TextXAlignment = Enum.TextXAlignment.Left
        dp.TextTruncate = Enum.TextTruncate.AtEnd
        dp.BackgroundTransparency = 1
        dp.ZIndex = 20
    end

    makeNoteRow("Patrol equipment", "Sep 21 · Repair kit Radio Flashlight Two bottles of water", true, 0)
    local nDiv1 = Instance.new("Frame", nCard)
    nDiv1.Size = UDim2.new(1, -36, 0, 1)
    nDiv1.Position = UDim2.new(0, 18, 0, 72)
    nDiv1.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    nDiv1.BorderSizePixel = 0
    nDiv1.ZIndex = 19

    makeNoteRow("CityMarkt viewing", "Sep 21 · Meet Morgan in Vinewood and inspect the Sulta...", true, 72)
    local nDiv2 = Instance.new("Frame", nCard)
    nDiv2.Size = UDim2.new(1, -36, 0, 1)
    nDiv2.Position = UDim2.new(0, 18, 0, 144)
    nDiv2.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    nDiv2.BorderSizePixel = 0
    nDiv2.ZIndex = 19

    makeNoteRow("Call Jamie", "Sep 20 · Call Jamie after the garage inspection and confirm...", false, 144)
    local nDiv3 = Instance.new("Frame", nCard)
    nDiv3.Size = UDim2.new(1, -36, 0, 1)
    nDiv3.Position = UDim2.new(0, 18, 0, 216)
    nDiv3.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    nDiv3.BorderSizePixel = 0
    nDiv3.ZIndex = 19

    makeNoteRow("Photo locations", "Sep 19 · Observatory, Vespucci Pier, Paleto lookout, Sandy...", false, 216)

    -- Bottom Search & Compose Bar
    local nSearch = Instance.new("Frame", notesApp)
    nSearch.Size = UDim2.new(1, -90, 0, 42)
    nSearch.Position = UDim2.new(0, 18, 1, -64)
    nSearch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    nSearch.BorderSizePixel = 0
    nSearch.ZIndex = 18
    Instance.new("UICorner", nSearch).CornerRadius = UDim.new(1, 0)
    local nsStroke = Instance.new("UIStroke", nSearch)
    nsStroke.Color = Color3.fromRGB(225, 228, 238)

    local nsText = Instance.new("TextLabel", nSearch)
    nsText.Size = UDim2.new(1, -20, 1, 0)
    nsText.Position = UDim2.new(0, 14, 0, 0)
    nsText.BackgroundTransparency = 1
    nsText.Text = "🔍 Search Notes"
    nsText.Font = Enum.Font.GothamMedium
    nsText.TextSize = 13.5
    nsText.TextColor3 = Color3.fromRGB(150, 155, 170)
    nsText.TextXAlignment = Enum.TextXAlignment.Left
    nsText.ZIndex = 19

    local nCompose = Instance.new("TextButton", notesApp)
    nCompose.Size = UDim2.new(0, 42, 0, 42)
    nCompose.Position = UDim2.new(1, -60, 1, -64)
    nCompose.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    nCompose.BorderSizePixel = 0
    nCompose.Text = "📝"
    nCompose.TextSize = 20
    nCompose.ZIndex = 18
    Instance.new("UICorner", nCompose).CornerRadius = UDim.new(0, 14)
    local ncsStroke = Instance.new("UIStroke", nCompose)
    ncsStroke.Color = Color3.fromRGB(225, 228, 238)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Notes"] = function(isLight)
            notesApp.BackgroundColor3 = isLight and Color3.fromRGB(242, 244, 248) or Color3.fromRGB(0, 0, 0)
            if nTitle then nTitle.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255) end
            if nCard then
                nCard.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
                if ncs then ncs.Color = isLight and Color3.fromRGB(230, 234, 244) or Color3.fromRGB(44, 44, 46) end
            end
            if nCompose then
                nCompose.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(44, 44, 46)
                if ncsStroke then ncsStroke.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(notesApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 13. MAIL APP (Matching official_mail.png)
-- ============================================================================
local mailApp = createBaseApp("Mail", Color3.fromRGB(242, 244, 248))
do
    local mTopNav = Instance.new("Frame", mailApp)
    mTopNav.Size = UDim2.new(1, 0, 0, 48)
    mTopNav.Position = UDim2.new(0, 0, 0, 36)
    mTopNav.BackgroundTransparency = 1
    mTopNav.ZIndex = 18

    local backBtn = Instance.new("TextButton", mTopNav)
    backBtn.Size = UDim2.new(0, 36, 0, 36)
    backBtn.Position = UDim2.new(0, 18, 0.5, -18)
    backBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "↪"
    backBtn.TextSize = 16
    backBtn.TextColor3 = Color3.fromRGB(120, 125, 140)
    backBtn.ZIndex = 19
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(1, 0)

    local editBtn = Instance.new("TextButton", mTopNav)
    editBtn.Size = UDim2.new(0, 46, 0, 36)
    editBtn.Position = UDim2.new(1, -64, 0.5, -18)
    editBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    editBtn.BorderSizePixel = 0
    editBtn.Text = "Edit"
    editBtn.Font = Enum.Font.GothamMedium
    editBtn.TextSize = 13
    editBtn.TextColor3 = Color3.fromRGB(150, 155, 170)
    editBtn.ZIndex = 19
    Instance.new("UICorner", editBtn).CornerRadius = UDim.new(1, 0)

    local mTitle = Instance.new("TextLabel", mailApp)
    mTitle.Size = UDim2.new(1, -36, 0, 36)
    mTitle.Position = UDim2.new(0, 18, 0, 88)
    mTitle.Text = "Mailboxes"
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 34
    mTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.BackgroundTransparency = 1
    mTitle.ZIndex = 18

    local mEmail = Instance.new("TextLabel", mailApp)
    mEmail.Size = UDim2.new(1, -36, 0, 18)
    mEmail.Position = UDim2.new(0, 18, 0, 126)
    mEmail.Text = "demo@ifruit.com"
    mEmail.Font = Enum.Font.GothamMedium
    mEmail.TextSize = 13.5
    mEmail.TextColor3 = Color3.fromRGB(130, 135, 150)
    mEmail.TextXAlignment = Enum.TextXAlignment.Left
    mEmail.BackgroundTransparency = 1
    mEmail.ZIndex = 18

    local mbCard = Instance.new("Frame", mailApp)
    mbCard.Size = UDim2.new(1, -36, 0, 260)
    mbCard.Position = UDim2.new(0, 18, 0, 154)
    mbCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mbCard.BorderSizePixel = 0
    mbCard.ZIndex = 18
    Instance.new("UICorner", mbCard).CornerRadius = UDim.new(0, 20)
    local mbs = Instance.new("UIStroke", mbCard)
    mbs.Color = Color3.fromRGB(230, 234, 244)

    local function makeMailboxRow(iconSymbol, name, count, yPos)
        local row = Instance.new("Frame", mbCard)
        row.Size = UDim2.new(1, 0, 0, 52)
        row.Position = UDim2.new(0, 0, 0, yPos)
        row.BackgroundTransparency = 1
        row.ZIndex = 19

        local ic = Instance.new("TextLabel", row)
        ic.Size = UDim2.new(0, 24, 0, 24)
        ic.Position = UDim2.new(0, 14, 0.5, -12)
        ic.BackgroundTransparency = 1
        ic.Text = iconSymbol
        ic.TextSize = 18
        ic.TextColor3 = Color3.fromRGB(0, 122, 255)
        ic.ZIndex = 20

        local nl = Instance.new("TextLabel", row)
        nl.Size = UDim2.new(0.6, 0, 1, 0)
        nl.Position = UDim2.new(0, 48, 0, 0)
        nl.Text = name
        nl.Font = Enum.Font.GothamBold
        nl.TextSize = 15
        nl.TextColor3 = Color3.fromRGB(15, 18, 28)
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.BackgroundTransparency = 1
        nl.ZIndex = 20

        local cl = Instance.new("TextLabel", row)
        cl.Size = UDim2.new(0.3, 0, 1, 0)
        cl.Position = UDim2.new(0.7, -18, 0, 0)
        cl.Text = (count and tostring(count) .. "  >" or ">")
        cl.Font = Enum.Font.GothamMedium
        cl.TextSize = 14
        cl.TextColor3 = Color3.fromRGB(150, 155, 170)
        cl.TextXAlignment = Enum.TextXAlignment.Right
        cl.BackgroundTransparency = 1
        cl.ZIndex = 20
    end

    makeMailboxRow("📥", "Inbox", 1, 0)
    makeMailboxRow("✈", "Sent", 1, 52)
    makeMailboxRow("📄", "Drafts", 0, 104)
    makeMailboxRow("🗑", "Trash", 1, 156)
    makeMailboxRow("📁", "Projects", nil, 208)

    for i = 1, 4 do
        local div = Instance.new("Frame", mbCard)
        div.Size = UDim2.new(1, -48, 0, 1)
        div.Position = UDim2.new(0, 48, 0, i * 52)
        div.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
        div.BorderSizePixel = 0
        div.ZIndex = 19
    end

    local mCompose = Instance.new("TextButton", mailApp)
    mCompose.Size = UDim2.new(0, 44, 0, 44)
    mCompose.Position = UDim2.new(1, -62, 1, -64)
    mCompose.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mCompose.BorderSizePixel = 0
    mCompose.Text = "📝"
    mCompose.TextSize = 22
    mCompose.ZIndex = 25
    Instance.new("UICorner", mCompose).CornerRadius = UDim.new(1, 0)
    local mcs = Instance.new("UIStroke", mCompose)
    mcs.Color = Color3.fromRGB(225, 228, 238)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Mail"] = function(isLight)
            mailApp.BackgroundColor3 = isLight and Color3.fromRGB(242, 244, 248) or Color3.fromRGB(0, 0, 0)
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(mailApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 14. MEMOS APP (Matching official_memos.png)
-- ============================================================================
local memosApp = createBaseApp("Memos", Color3.fromRGB(242, 244, 248))
do
    local mTitle = Instance.new("TextLabel", memosApp)
    mTitle.Size = UDim2.new(1, -36, 0, 38)
    mTitle.Position = UDim2.new(0, 18, 0, 48)
    mTitle.Text = "Memos"
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 34
    mTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.BackgroundTransparency = 1
    mTitle.ZIndex = 18

    local memoCard = Instance.new("Frame", memosApp)
    memoCard.Size = UDim2.new(1, -36, 0, 270)
    memoCard.Position = UDim2.new(0, 18, 0, 96)
    memoCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    memoCard.BorderSizePixel = 0
    memoCard.ZIndex = 18
    Instance.new("UICorner", memoCard).CornerRadius = UDim.new(0, 20)
    local mcs = Instance.new("UIStroke", memoCard)
    mcs.Color = Color3.fromRGB(230, 234, 244)

    local function makeMemoRow(title, timeStr, yPos)
        local row = Instance.new("Frame", memoCard)
        row.Size = UDim2.new(1, 0, 0, 90)
        row.Position = UDim2.new(0, 0, 0, yPos)
        row.BackgroundTransparency = 1
        row.ZIndex = 19

        local playBtn = Instance.new("Frame", row)
        playBtn.Size = UDim2.new(0, 42, 0, 42)
        playBtn.Position = UDim2.new(0, 16, 0, 14)
        playBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 238)
        playBtn.BorderSizePixel = 0
        playBtn.ZIndex = 20
        Instance.new("UICorner", playBtn).CornerRadius = UDim.new(1, 0)

        local playTxt = Instance.new("TextLabel", playBtn)
        playTxt.Size = UDim2.new(1, 0, 1, 0)
        playTxt.Text = "▶"
        playTxt.Font = Enum.Font.GothamBold
        playTxt.TextSize = 14
        playTxt.TextColor3 = Color3.fromRGB(255, 59, 48)
        playTxt.BackgroundTransparency = 1
        playTxt.ZIndex = 21

        local t = Instance.new("TextLabel", row)
        t.Size = UDim2.new(1, -80, 0, 20)
        t.Position = UDim2.new(0, 68, 0, 12)
        t.Text = title
        t.Font = Enum.Font.GothamBold
        t.TextSize = 15
        t.TextColor3 = Color3.fromRGB(15, 18, 28)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.BackgroundTransparency = 1
        t.ZIndex = 20

        local s = Instance.new("TextLabel", row)
        s.Size = UDim2.new(1, -80, 0, 16)
        s.Position = UDim2.new(0, 68, 0, 32)
        s.Text = timeStr
        s.Font = Enum.Font.Gotham
        s.TextSize = 11.5
        s.TextColor3 = Color3.fromRGB(140, 145, 160)
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.BackgroundTransparency = 1
        s.ZIndex = 20

        local wave = Instance.new("TextLabel", row)
        wave.Size = UDim2.new(1, -80, 0, 16)
        wave.Position = UDim2.new(0, 68, 0, 52)
        wave.Text = "🔴|||•|||•||||||•||||•|||||||||•||||||||||||||"
        wave.Font = Enum.Font.GothamBold
        wave.TextSize = 10
        wave.TextColor3 = Color3.fromRGB(160, 165, 180)
        wave.TextXAlignment = Enum.TextXAlignment.Left
        wave.BackgroundTransparency = 1
        wave.ZIndex = 20
    end

    makeMemoRow("Night shift briefing", "02:42 AM · 0:42", 0)
    local mDiv1 = Instance.new("Frame", memoCard)
    mDiv1.Size = UDim2.new(1, -68, 0, 1)
    mDiv1.Position = UDim2.new(0, 68, 0, 90)
    mDiv1.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    mDiv1.BorderSizePixel = 0
    mDiv1.ZIndex = 19

    makeMemoRow("Sultan RS inspection", "12:00 AM · 0:18", 90)
    local mDiv2 = Instance.new("Frame", memoCard)
    mDiv2.Size = UDim2.new(1, -68, 0, 1)
    mDiv2.Position = UDim2.new(0, 68, 0, 180)
    mDiv2.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    mDiv2.BorderSizePixel = 0
    mDiv2.ZIndex = 19

    makeMemoRow("Supply reminder", "09/20 · 0:07", 180)

    -- Bottom Search & Red Record Button
    local memoSearch = Instance.new("Frame", memosApp)
    memoSearch.Size = UDim2.new(1, -90, 0, 42)
    memoSearch.Position = UDim2.new(0, 18, 1, -64)
    memoSearch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    memoSearch.BorderSizePixel = 0
    memoSearch.ZIndex = 18
    Instance.new("UICorner", memoSearch).CornerRadius = UDim.new(1, 0)
    local msStroke = Instance.new("UIStroke", memoSearch)
    msStroke.Color = Color3.fromRGB(225, 228, 238)

    local msText = Instance.new("TextLabel", memoSearch)
    nsText = msText
    msText.Size = UDim2.new(1, -20, 1, 0)
    msText.Position = UDim2.new(0, 14, 0, 0)
    msText.BackgroundTransparency = 1
    msText.Text = "🔍 Search Recordings"
    msText.Font = Enum.Font.GothamMedium
    msText.TextSize = 13.5
    msText.TextColor3 = Color3.fromRGB(150, 155, 170)
    msText.TextXAlignment = Enum.TextXAlignment.Left
    msText.ZIndex = 19

    local recBtn = Instance.new("TextButton", memosApp)
    recBtn.Size = UDim2.new(0, 46, 0, 46)
    recBtn.Position = UDim2.new(1, -64, 1, -66)
    recBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    recBtn.BorderSizePixel = 0
    recBtn.Text = "🎤"
    recBtn.TextSize = 22
    recBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    recBtn.ZIndex = 25
    Instance.new("UICorner", recBtn).CornerRadius = UDim.new(1, 0)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Memos"] = function(isLight)
            memosApp.BackgroundColor3 = isLight and Color3.fromRGB(242, 244, 248) or Color3.fromRGB(0, 0, 0)
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(memosApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 15. PHOTOS APP (Matching official_photos.png)
-- ============================================================================
local photosApp = createBaseApp("Photos", Color3.fromRGB(244, 245, 248))
do
    local pHeader = Instance.new("Frame", photosApp)
    pHeader.Size = UDim2.new(1, 0, 0, 48)
    pHeader.Position = UDim2.new(0, 0, 0, 36)
    pHeader.BackgroundTransparency = 1
    pHeader.ZIndex = 18

    local pTitle = Instance.new("TextLabel", pHeader)
    pTitle.Size = UDim2.new(0.5, 0, 0, 26)
    pTitle.Position = UDim2.new(0, 18, 0, 4)
    pTitle.Text = "Library"
    pTitle.Font = Enum.Font.GothamBold
    pTitle.TextSize = 30
    pTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    pTitle.TextXAlignment = Enum.TextXAlignment.Left
    pTitle.BackgroundTransparency = 1
    pTitle.ZIndex = 19

    local pCount = Instance.new("TextLabel", pHeader)
    pCount.Size = UDim2.new(0.5, 0, 0, 14)
    pCount.Position = UDim2.new(0, 18, 0, 32)
    pCount.Text = "42 Objects"
    pCount.Font = Enum.Font.Gotham
    pCount.TextSize = 11
    pCount.TextColor3 = Color3.fromRGB(140, 145, 160)
    pCount.TextXAlignment = Enum.TextXAlignment.Left
    pCount.BackgroundTransparency = 1
    pCount.ZIndex = 19

    local function makePhotoTopBtn(xOffset, txt)
        local btn = Instance.new("TextButton", pHeader)
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = UDim2.new(1, xOffset, 0.5, -16)
        btn.BackgroundColor3 = Color3.fromRGB(120, 125, 135)
        btn.Text = txt
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BorderSizePixel = 0
        btn.ZIndex = 19
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makePhotoTopBtn(-125, "☰")
    makePhotoTopBtn(-85, "⬇")

    local selBtn = Instance.new("TextButton", pHeader)
    selBtn.Size = UDim2.new(0, 52, 0, 32)
    selBtn.Position = UDim2.new(1, -64, 0.5, -16)
    selBtn.BackgroundColor3 = Color3.fromRGB(120, 125, 135)
    selBtn.Text = "Select"
    selBtn.Font = Enum.Font.GothamBold
    selBtn.TextSize = 11.5
    selBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    selBtn.BorderSizePixel = 0
    selBtn.ZIndex = 19
    Instance.new("UICorner", selBtn).CornerRadius = UDim.new(1, 0)

    -- 3x5 Grid of Thumbnails
    local pGrid = Instance.new("Frame", photosApp)
    pGrid.Size = UDim2.new(1, -24, 1, -170)
    pGrid.Position = UDim2.new(0, 12, 0, 90)
    pGrid.BackgroundTransparency = 1
    pGrid.ZIndex = 18
    local pgLayout = Instance.new("UIGridLayout", pGrid)
    pgLayout.CellSize = UDim2.new(0.315, 0, 0, 78)
    pgLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
    pgLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local colors = {
        Color3.fromRGB(45, 95, 115), Color3.fromRGB(185, 110, 45), Color3.fromRGB(35, 75, 145),
        Color3.fromRGB(115, 65, 155), Color3.fromRGB(65, 125, 85), Color3.fromRGB(45, 95, 65),
        Color3.fromRGB(135, 95, 55), Color3.fromRGB(45, 55, 75), Color3.fromRGB(195, 105, 35),
        Color3.fromRGB(155, 75, 45), Color3.fromRGB(75, 55, 105), Color3.fromRGB(85, 95, 115),
        Color3.fromRGB(75, 115, 115), Color3.fromRGB(115, 65, 65), Color3.fromRGB(45, 45, 95)
    }

    for i = 1, 15 do
        local thumb = Instance.new("Frame", pGrid)
        thumb.BackgroundColor3 = colors[i] or Color3.fromRGB(50, 60, 80)
        thumb.BorderSizePixel = 0
        thumb.ZIndex = 19
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

        local sun = Instance.new("Frame", thumb)
        sun.Size = UDim2.new(0, 18, 0, 18)
        sun.Position = UDim2.new(1, -24, 0, 6)
        sun.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
        sun.BackgroundTransparency = 0.2
        sun.BorderSizePixel = 0
        sun.ZIndex = 20
        Instance.new("UICorner", sun).CornerRadius = UDim.new(1, 0)

        if i % 3 == 0 then
            local playBadge = Instance.new("TextLabel", thumb)
            playBadge.Size = UDim2.new(0, 16, 0, 16)
            playBadge.Position = UDim2.new(1, -20, 1, -20)
            playBadge.Text = "▶"
            playBadge.TextSize = 10
            playBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
            playBadge.BackgroundTransparency = 1
            playBadge.ZIndex = 20
        end
    end

    -- Bottom Floating Dock
    local phDock = Instance.new("Frame", photosApp)
    phDock.Size = UDim2.new(1, -36, 0, 52)
    phDock.Position = UDim2.new(0, 18, 1, -72)
    phDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    phDock.BorderSizePixel = 0
    phDock.ZIndex = 25
    Instance.new("UICorner", phDock).CornerRadius = UDim.new(1, 0)
    local phs = Instance.new("UIStroke", phDock)
    phs.Color = Color3.fromRGB(225, 228, 238)

    local phdLayout = Instance.new("UIListLayout", phDock)
    phdLayout.FillDirection = Enum.FillDirection.Horizontal
    phdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    phdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    phdLayout.Padding = UDim.new(0, 16)

    local function makePhotoTab(txt, iconTxt, isActive)
        local btn = Instance.new("TextButton", phDock)
        btn.Size = isActive and UDim2.new(0, 76, 0, 38) or UDim2.new(0, 56, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(235, 238, 245) or Color3.fromRGB(255, 255, 255)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(140, 145, 160)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makePhotoTab("All", "🖼", true)
    makePhotoTab("Photos", "🌄", false)
    makePhotoTab("Videos", "📹", false)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Photos"] = function(isLight)
            photosApp.BackgroundColor3 = isLight and Color3.fromRGB(244, 245, 248) or Color3.fromRGB(0, 0, 0)
            if phDock then
                phDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(24, 24, 26)
                if phs then phs.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(photosApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 16. MUSIC APP (Matching official_music.png)
-- ============================================================================
local musicApp = createBaseApp("Music", Color3.fromRGB(244, 245, 248))
do
    local mTop = Instance.new("Frame", musicApp)
    mTop.Size = UDim2.new(1, 0, 0, 48)
    mTop.Position = UDim2.new(0, 0, 0, 36)
    mTop.BackgroundTransparency = 1
    mTop.ZIndex = 18

    local mTitle = Instance.new("TextLabel", mTop)
    mTitle.Size = UDim2.new(1, 0, 1, 0)
    mTitle.Text = "Music"
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 17
    mTitle.TextColor3 = Color3.fromRGB(20, 25, 35)
    mTitle.BackgroundTransparency = 1
    mTitle.ZIndex = 19

    local plusBtn = Instance.new("TextButton", mTop)
    plusBtn.Size = UDim2.new(0, 36, 0, 36)
    plusBtn.Position = UDim2.new(1, -54, 0.5, -18)
    plusBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.BorderSizePixel = 0
    plusBtn.Text = "+"
    plusBtn.Font = Enum.Font.GothamMedium
    plusBtn.TextSize = 22
    plusBtn.TextColor3 = Color3.fromRGB(20, 25, 35)
    plusBtn.ZIndex = 19
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(1, 0)

    local libTitle = Instance.new("TextLabel", musicApp)
    libTitle.Size = UDim2.new(1, -36, 0, 36)
    libTitle.Position = UDim2.new(0, 18, 0, 88)
    libTitle.Text = "Library"
    libTitle.Font = Enum.Font.GothamBold
    libTitle.TextSize = 34
    libTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    libTitle.TextXAlignment = Enum.TextXAlignment.Left
    libTitle.BackgroundTransparency = 1
    libTitle.ZIndex = 18

    local libSub = Instance.new("TextLabel", musicApp)
    libSub.Size = UDim2.new(1, -36, 0, 18)
    libSub.Position = UDim2.new(0, 18, 0, 126)
    libSub.Text = "Your music, all in one place."
    libSub.Font = Enum.Font.Gotham
    libSub.TextSize = 13.5
    libSub.TextColor3 = Color3.fromRGB(140, 145, 160)
    libSub.TextXAlignment = Enum.TextXAlignment.Left
    libSub.BackgroundTransparency = 1
    libSub.ZIndex = 18

    -- Featured Album Card
    local featCard = Instance.new("Frame", musicApp)
    featCard.Size = UDim2.new(1, -36, 0, 125)
    featCard.Position = UDim2.new(0, 18, 0, 154)
    featCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    featCard.BorderSizePixel = 0
    featCard.ZIndex = 18
    Instance.new("UICorner", featCard).CornerRadius = UDim.new(0, 22)
    local fcs = Instance.new("UIStroke", featCard)
    fcs.Color = Color3.fromRGB(230, 234, 244)

    local tag = Instance.new("TextLabel", featCard)
    tag.Size = UDim2.new(0.6, 0, 0, 14)
    tag.Position = UDim2.new(0, 16, 0, 14)
    tag.Text = "MADE FOR THE CITY"
    tag.Font = Enum.Font.GothamBold
    tag.TextSize = 9
    tag.TextColor3 = Color3.fromRGB(255, 59, 48)
    tag.TextXAlignment = Enum.TextXAlignment.Left
    tag.BackgroundTransparency = 1
    tag.ZIndex = 19

    local aName = Instance.new("TextLabel", featCard)
    aName.Size = UDim2.new(0.55, 0, 0, 36)
    aName.Position = UDim2.new(0, 16, 0, 30)
    aName.Text = "City After\nDark"
    aName.Font = Enum.Font.GothamBold
    aName.TextSize = 18
    aName.TextColor3 = Color3.fromRGB(15, 18, 28)
    aName.TextXAlignment = Enum.TextXAlignment.Left
    aName.BackgroundTransparency = 1
    aName.ZIndex = 19

    local aArt = Instance.new("TextLabel", featCard)
    aArt.Size = UDim2.new(0.55, 0, 0, 14)
    aArt.Position = UDim2.new(0, 16, 0, 68)
    aArt.Text = "Sky Records"
    aArt.Font = Enum.Font.Gotham
    aArt.TextSize = 11.5
    aArt.TextColor3 = Color3.fromRGB(140, 145, 160)
    aArt.TextXAlignment = Enum.TextXAlignment.Left
    aArt.BackgroundTransparency = 1
    aArt.ZIndex = 19

    local playPill = Instance.new("TextButton", featCard)
    playPill.Size = UDim2.new(0, 78, 0, 26)
    playPill.Position = UDim2.new(0, 16, 0, 88)
    playPill.BackgroundColor3 = Color3.fromRGB(255, 240, 242)
    playPill.Text = "▶ Play"
    playPill.Font = Enum.Font.GothamBold
    playPill.TextSize = 11.5
    playPill.TextColor3 = Color3.fromRGB(255, 59, 48)
    playPill.BorderSizePixel = 0
    playPill.ZIndex = 19
    Instance.new("UICorner", playPill).CornerRadius = UDim.new(1, 0)

    local featCover = Instance.new("Frame", featCard)
    featCover.Size = UDim2.new(0, 95, 0, 95)
    featCover.Position = UDim2.new(1, -110, 0.5, -47.5)
    featCover.BackgroundColor3 = Color3.fromRGB(220, 225, 235)
    featCover.BorderSizePixel = 0
    featCover.ZIndex = 19
    Instance.new("UICorner", featCover).CornerRadius = UDim.new(0, 16)

    -- Recently Added 2x2 Grid
    local recTitle = Instance.new("TextLabel", musicApp)
    recTitle.Size = UDim2.new(1, -36, 0, 22)
    recTitle.Position = UDim2.new(0, 18, 0, 290)
    recTitle.Text = "Recently Added"
    recTitle.Font = Enum.Font.GothamBold
    recTitle.TextSize = 16
    recTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    recTitle.TextXAlignment = Enum.TextXAlignment.Left
    recTitle.BackgroundTransparency = 1
    recTitle.ZIndex = 18

    local recGrid = Instance.new("Frame", musicApp)
    recGrid.Size = UDim2.new(1, -36, 0, 150)
    recGrid.Position = UDim2.new(0, 18, 0, 316)
    recGrid.BackgroundTransparency = 1
    recGrid.ZIndex = 18

    local function makeAlbumCard(title, artist, xPos)
        local card = Instance.new("Frame", recGrid)
        card.Size = UDim2.new(0.48, 0, 1, 0)
        card.Position = UDim2.new(xPos, 0, 0, 0)
        card.BackgroundTransparency = 1
        card.ZIndex = 19

        local cover = Instance.new("Frame", card)
        cover.Size = UDim2.new(1, 0, 0, 105)
        cover.BackgroundColor3 = Color3.fromRGB(180, 140, 100)
        cover.BorderSizePixel = 0
        cover.ZIndex = 20
        Instance.new("UICorner", cover).CornerRadius = UDim.new(0, 16)

        local t = Instance.new("TextLabel", card)
        t.Size = UDim2.new(1, 0, 0, 16)
        t.Position = UDim2.new(0, 0, 0, 110)
        t.Text = title
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        t.TextColor3 = Color3.fromRGB(15, 18, 28)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.BackgroundTransparency = 1
        t.ZIndex = 20

        local a = Instance.new("TextLabel", card)
        a.Size = UDim2.new(1, 0, 0, 14)
        a.Position = UDim2.new(0, 0, 0, 126)
        a.Text = artist
        a.Font = Enum.Font.Gotham
        a.TextSize = 10.5
        a.TextColor3 = Color3.fromRGB(140, 145, 160)
        a.TextXAlignment = Enum.TextXAlignment.Left
        a.BackgroundTransparency = 1
        a.ZIndex = 20
    end

    makeAlbumCard("City After Dark", "Sky Records", 0)
    makeAlbumCard("Pacific Drive", "Vespucci FM", 0.52)

    -- Bottom Floating Dock
    local muDock = Instance.new("Frame", musicApp)
    muDock.Size = UDim2.new(1, -36, 0, 52)
    muDock.Position = UDim2.new(0, 18, 1, -72)
    muDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    muDock.BorderSizePixel = 0
    muDock.ZIndex = 25
    Instance.new("UICorner", muDock).CornerRadius = UDim.new(1, 0)
    local muds = Instance.new("UIStroke", muDock)
    muds.Color = Color3.fromRGB(225, 228, 238)

    local mudLayout = Instance.new("UIListLayout", muDock)
    mudLayout.FillDirection = Enum.FillDirection.Horizontal
    mudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mudLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    mudLayout.Padding = UDim.new(0, 16)

    local function makeMusicTab(txt, iconTxt, isActive)
        local btn = Instance.new("TextButton", muDock)
        btn.Size = isActive and UDim2.new(0, 76, 0, 38) or UDim2.new(0, 56, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 240, 242) or Color3.fromRGB(255, 255, 255)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(255, 59, 48) or Color3.fromRGB(140, 145, 160)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makeMusicTab("Library", "📚", true)
    makeMusicTab("Playlists", "📑", false)
    makeMusicTab("Search", "🔍", false)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Music"] = function(isLight)
            musicApp.BackgroundColor3 = isLight and Color3.fromRGB(244, 245, 248) or Color3.fromRGB(0, 0, 0)
            if muDock then
                muDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(24, 24, 26)
                if mus then mus.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(musicApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 17. HEALTH APP (Matching official_health.png)
-- ============================================================================
local healthApp = createBaseApp("Health", Color3.fromRGB(244, 245, 248))
do
    local hTitle = Instance.new("TextLabel", healthApp)
    hTitle.Size = UDim2.new(1, 0, 0, 38)
    hTitle.Position = UDim2.new(0, 0, 0, 48)
    hTitle.Text = "Health"
    hTitle.Font = Enum.Font.GothamBold
    hTitle.TextSize = 18
    hTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    hTitle.BackgroundTransparency = 1
    hTitle.ZIndex = 18

    -- Circular Steps Ring
    local ringFrame = Instance.new("Frame", healthApp)
    ringFrame.Size = UDim2.new(0, 160, 0, 160)
    ringFrame.Position = UDim2.new(0.5, -80, 0, 96)
    ringFrame.BackgroundTransparency = 1
    ringFrame.ZIndex = 18

    local ringCircle = Instance.new("Frame", ringFrame)
    ringCircle.Size = UDim2.new(1, 0, 1, 0)
    ringCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ringCircle.BorderSizePixel = 0
    ringCircle.ZIndex = 19
    Instance.new("UICorner", ringCircle).CornerRadius = UDim.new(1, 0)
    local rStroke = Instance.new("UIStroke", ringCircle)
    rStroke.Color = Color3.fromRGB(255, 59, 92)
    rStroke.Thickness = 12

    local iconFeet = Instance.new("TextLabel", ringFrame)
    iconFeet.Size = UDim2.new(1, 0, 0, 20)
    iconFeet.Position = UDim2.new(0, 0, 0, 30)
    iconFeet.Text = "👣"
    iconFeet.TextSize = 18
    iconFeet.TextColor3 = Color3.fromRGB(255, 59, 92)
    iconFeet.BackgroundTransparency = 1
    iconFeet.ZIndex = 20

    local numSteps = Instance.new("TextLabel", ringFrame)
    numSteps.Size = UDim2.new(1, 0, 0, 40)
    numSteps.Position = UDim2.new(0, 0, 0, 52)
    numSteps.Text = "6,420"
    numSteps.Font = Enum.Font.GothamBold
    numSteps.TextSize = 34
    numSteps.TextColor3 = Color3.fromRGB(15, 18, 28)
    numSteps.BackgroundTransparency = 1
    numSteps.ZIndex = 20

    local lblSteps = Instance.new("TextLabel", ringFrame)
    lblSteps.Size = UDim2.new(1, 0, 0, 16)
    lblSteps.Position = UDim2.new(0, 0, 0, 92)
    lblSteps.Text = "Steps"
    lblSteps.Font = Enum.Font.GothamBold
    lblSteps.TextSize = 13.5
    lblSteps.TextColor3 = Color3.fromRGB(15, 18, 28)
    lblSteps.BackgroundTransparency = 1
    lblSteps.ZIndex = 20

    local ofGoal = Instance.new("TextLabel", ringFrame)
    ofGoal.Size = UDim2.new(1, 0, 0, 14)
    ofGoal.Position = UDim2.new(0, 0, 0, 110)
    ofGoal.Text = "of 8,000"
    ofGoal.Font = Enum.Font.Gotham
    ofGoal.TextSize = 11
    ofGoal.TextColor3 = Color3.fromRGB(140, 145, 160)
    ofGoal.BackgroundTransparency = 1
    ofGoal.ZIndex = 20

    -- 3 Stat Metrics Row
    local hCard = Instance.new("Frame", healthApp)
    hCard.Size = UDim2.new(1, -36, 0, 76)
    hCard.Position = UDim2.new(0, 18, 0, 275)
    hCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hCard.BorderSizePixel = 0
    hCard.ZIndex = 18
    Instance.new("UICorner", hCard).CornerRadius = UDim.new(0, 20)
    local hcs = Instance.new("UIStroke", hCard)
    hcs.Color = Color3.fromRGB(230, 234, 244)

    local function makeHStat(val, lbl, ico, xPos)
        local f = Instance.new("Frame", hCard)
        f.Size = UDim2.new(0.33, 0, 1, 0)
        f.Position = UDim2.new(xPos, 0, 0, 0)
        f.BackgroundTransparency = 1
        f.ZIndex = 19

        local i = Instance.new("TextLabel", f)
        i.Size = UDim2.new(1, 0, 0, 16)
        i.Position = UDim2.new(0, 0, 0, 10)
        i.Text = ico
        i.TextSize = 14
        i.TextColor3 = Color3.fromRGB(255, 59, 92)
        i.BackgroundTransparency = 1
        i.ZIndex = 20

        local v = Instance.new("TextLabel", f)
        v.Size = UDim2.new(1, 0, 0, 18)
        v.Position = UDim2.new(0, 0, 0, 28)
        v.Text = val
        v.Font = Enum.Font.GothamBold
        v.TextSize = 13.5
        v.TextColor3 = Color3.fromRGB(15, 18, 28)
        v.BackgroundTransparency = 1
        v.ZIndex = 20

        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, 0, 0, 14)
        l.Position = UDim2.new(0, 0, 0, 48)
        l.Text = lbl
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(140, 145, 160)
        l.BackgroundTransparency = 1
        l.ZIndex = 20
    end
    makeHStat("4.8 km", "Distance", "📍", 0)
    makeHStat("39 min", "Active", "⏱", 0.33)
    makeHStat("289 kcal", "Energy", "🔥", 0.66)

    -- Weekly Bar Chart
    local twTitle = Instance.new("TextLabel", healthApp)
    twTitle.Size = UDim2.new(1, -36, 0, 22)
    twTitle.Position = UDim2.new(0, 22, 0, 365)
    twTitle.Text = "This week"
    twTitle.Font = Enum.Font.GothamBold
    twTitle.TextSize = 17
    twTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    twTitle.TextXAlignment = Enum.TextXAlignment.Left
    twTitle.BackgroundTransparency = 1
    twTitle.ZIndex = 18

    local chartCard = Instance.new("Frame", healthApp)
    chartCard.Size = UDim2.new(1, -36, 0, 130)
    chartCard.Position = UDim2.new(0, 18, 0, 395)
    chartCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    chartCard.BorderSizePixel = 0
    chartCard.ZIndex = 18
    Instance.new("UICorner", chartCard).CornerRadius = UDim.new(0, 20)
    local ccs = Instance.new("UIStroke", chartCard)
    ccs.Color = Color3.fromRGB(230, 234, 244)

    local days = {
        {"Tu", 0.5, "4,289"}, {"We", 0.75, "6,312"}, {"Th", 0.4, "3,421"},
        {"Fr", 0.85, "7,024"}, {"Sa", 1.0, "8,618"}, {"Su", 0.52, "4,302"}, {"Mo", 0.78, "6,420"}
    }

    for idx, d in ipairs(days) do
        local xOff = (idx - 1) * 0.14 + 0.02
        local col = Instance.new("Frame", chartCard)
        col.Size = UDim2.new(0.12, 0, 1, 0)
        col.Position = UDim2.new(xOff, 0, 0, 0)
        col.BackgroundTransparency = 1
        col.ZIndex = 19

        local dTxt = Instance.new("TextLabel", col)
        dTxt.Size = UDim2.new(1, 0, 0, 14)
        dTxt.Position = UDim2.new(0, 0, 0, 8)
        dTxt.Text = d[1]
        dTxt.Font = Enum.Font.GothamMedium
        dTxt.TextSize = 10.5
        dTxt.TextColor3 = Color3.fromRGB(140, 145, 160)
        dTxt.BackgroundTransparency = 1
        dTxt.ZIndex = 20

        local barBg = Instance.new("Frame", col)
        barBg.Size = UDim2.new(0, 10, 0, 68)
        barBg.Position = UDim2.new(0.5, -5, 0, 28)
        barBg.BackgroundColor3 = Color3.fromRGB(244, 245, 248)
        barBg.BorderSizePixel = 0
        barBg.ZIndex = 20
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

        local barFill = Instance.new("Frame", barBg)
        barFill.Size = UDim2.new(1, 0, d[2], 0)
        barFill.Position = UDim2.new(0, 0, 1 - d[2], 0)
        barFill.BackgroundColor3 = Color3.fromRGB(255, 59, 92)
        barFill.BorderSizePixel = 0
        barFill.ZIndex = 21
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

        local vTxt = Instance.new("TextLabel", col)
        vTxt.Size = UDim2.new(1, 0, 0, 12)
        vTxt.Position = UDim2.new(0, 0, 1, -20)
        vTxt.Text = d[3]
        vTxt.Font = Enum.Font.Gotham
        vTxt.TextSize = 7.5
        vTxt.TextColor3 = Color3.fromRGB(150, 155, 170)
        vTxt.BackgroundTransparency = 1
        vTxt.ZIndex = 20
    end

    -- Bottom Floating Dock
    local hDock = Instance.new("Frame", healthApp)
    hDock.Size = UDim2.new(1, -36, 0, 52)
    hDock.Position = UDim2.new(0, 18, 1, -72)
    hDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hDock.BorderSizePixel = 0
    hDock.ZIndex = 25
    Instance.new("UICorner", hDock).CornerRadius = UDim.new(1, 0)
    local hds = Instance.new("UIStroke", hDock)
    hds.Color = Color3.fromRGB(225, 228, 238)

    local hdLayout = Instance.new("UIListLayout", hDock)
    hdLayout.FillDirection = Enum.FillDirection.Horizontal
    hdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    hdLayout.Padding = UDim.new(0, 16)

    local function makeHealthTab(txt, iconTxt, isActive)
        local btn = Instance.new("TextButton", hDock)
        btn.Size = isActive and UDim2.new(0, 76, 0, 38) or UDim2.new(0, 56, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 240, 242) or Color3.fromRGB(255, 255, 255)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(255, 59, 92) or Color3.fromRGB(140, 145, 160)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makeHealthTab("Today", "📈", true)
    makeHealthTab("Trends", "📊", false)
    makeHealthTab("Medical ID", "📋", false)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Health"] = function(isLight)
            healthApp.BackgroundColor3 = isLight and Color3.fromRGB(244, 245, 248) or Color3.fromRGB(0, 0, 0)
            if hDock then
                hDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(24, 24, 26)
                if hs then hs.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(healthApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 18. CAMERA APP (Matching official_camera.png)
-- ============================================================================
camApp = createBaseApp("Camera", Color3.fromRGB(0, 0, 0))
do
    local cTop = Instance.new("Frame", camApp)
    cTop.Size = UDim2.new(1, 0, 0, 48)
    cTop.Position = UDim2.new(0, 0, 0, 36)
    cTop.BackgroundTransparency = 1
    cTop.ZIndex = 18

    local flashBtn = Instance.new("TextButton", cTop)
    flashBtn.Size = UDim2.new(0, 36, 0, 36)
    flashBtn.Position = UDim2.new(0, 18, 0.5, -18)
    flashBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    flashBtn.Text = "⚡"
    flashBtn.TextSize = 16
    flashBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flashBtn.BorderSizePixel = 0
    flashBtn.ZIndex = 19
    Instance.new("UICorner", flashBtn).CornerRadius = UDim.new(1, 0)

    local urlPill = Instance.new("Frame", cTop)
    urlPill.Size = UDim2.new(0, 160, 0, 28)
    urlPill.Position = UDim2.new(0.5, -80, 0.5, -14)
    urlPill.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    urlPill.BorderSizePixel = 0
    urlPill.ZIndex = 19
    Instance.new("UICorner", urlPill).CornerRadius = UDim.new(1, 0)

    local urlTxt = Instance.new("TextLabel", urlPill)
    urlTxt.Size = UDim2.new(1, 0, 1, 0)
    urlTxt.Text = "🔒 APPS.CAMERA.LOOKKEY"
    urlTxt.Font = Enum.Font.GothamBold
    urlTxt.TextSize = 8.5
    urlTxt.TextColor3 = Color3.fromRGB(220, 225, 235)
    urlTxt.BackgroundTransparency = 1
    urlTxt.ZIndex = 20

    local reloadBtn = Instance.new("TextButton", cTop)
    reloadBtn.Size = UDim2.new(0, 36, 0, 36)
    reloadBtn.Position = UDim2.new(1, -54, 0.5, -18)
    reloadBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    reloadBtn.Text = "↺"
    reloadBtn.TextSize = 18
    reloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    reloadBtn.BorderSizePixel = 0
    reloadBtn.ZIndex = 19
    Instance.new("UICorner", reloadBtn).CornerRadius = UDim.new(1, 0)

    -- Zoom Level Selectors
    local zoomRow = Instance.new("Frame", camApp)
    zoomRow.Size = UDim2.new(0, 180, 0, 36)
    zoomRow.Position = UDim2.new(0.5, -90, 1, -190)
    zoomRow.BackgroundTransparency = 1
    zoomRow.ZIndex = 18
    local zLayout = Instance.new("UIListLayout", zoomRow)
    zLayout.FillDirection = Enum.FillDirection.Horizontal
    zLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    zLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    zLayout.Padding = UDim.new(0, 12)

    local function makeZoomBtn(txt, isActive)
        local b = Instance.new("TextButton", zoomRow)
        b.Size = isActive and UDim2.new(0, 30, 0, 30) or UDim2.new(0, 24, 0, 24)
        b.BackgroundColor3 = isActive and Color3.fromRGB(35, 35, 42) or Color3.fromRGB(0, 0, 0)
        b.BackgroundTransparency = isActive and 0 or 1
        b.Text = txt
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11.5
        b.TextColor3 = isActive and Color3.fromRGB(255, 204, 0) or Color3.fromRGB(255, 255, 255)
        b.BorderSizePixel = 0
        b.ZIndex = 19
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    end
    makeZoomBtn(".5", false)
    makeZoomBtn("1x", true)
    makeZoomBtn("2", false)
    makeZoomBtn("3", false)

    -- Shutter Row
    local thumbPreview = Instance.new("Frame", camApp)
    thumbPreview.Size = UDim2.new(0, 46, 0, 46)
    thumbPreview.Position = UDim2.new(0, 28, 1, -135)
    thumbPreview.BackgroundColor3 = Color3.fromRGB(45, 55, 85)
    thumbPreview.BorderSizePixel = 0
    thumbPreview.ZIndex = 18
    Instance.new("UICorner", thumbPreview).CornerRadius = UDim.new(1, 0)

    local shutterOuter = Instance.new("Frame", camApp)
    shutterOuter.Size = UDim2.new(0, 72, 0, 72)
    shutterOuter.Position = UDim2.new(0.5, -36, 1, -148)
    shutterOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shutterOuter.BorderSizePixel = 0
    shutterOuter.ZIndex = 18
    Instance.new("UICorner", shutterOuter).CornerRadius = UDim.new(1, 0)
    local soStroke = Instance.new("UIStroke", shutterOuter)
    soStroke.Color = Color3.fromRGB(255, 255, 255)
    soStroke.Thickness = 3.5

    local shutterInner = Instance.new("TextButton", shutterOuter)
    shutterInner.Size = UDim2.new(1, -10, 1, -10)
    shutterInner.Position = UDim2.new(0, 5, 0, 5)
    shutterInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shutterInner.Text = ""
    shutterInner.BorderSizePixel = 0
    shutterInner.ZIndex = 19
    Instance.new("UICorner", shutterInner).CornerRadius = UDim.new(1, 0)

    shutterInner.MouseButton1Click:Connect(function()
        playTone()
        local flash = Instance.new("Frame", camApp)
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        flash.ZIndex = 100
        game:GetService("TweenService"):Create(flash, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        game:GetService("Debris"):AddItem(flash, 0.25)
    end)

    local flipCamBtn = Instance.new("TextButton", camApp)
    flipCamBtn.Size = UDim2.new(0, 46, 0, 46)
    flipCamBtn.Position = UDim2.new(1, -74, 1, -135)
    flipCamBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    flipCamBtn.Text = "🔄"
    flipCamBtn.TextSize = 20
    flipCamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flipCamBtn.BorderSizePixel = 0
    flipCamBtn.ZIndex = 18
    Instance.new("UICorner", flipCamBtn).CornerRadius = UDim.new(1, 0)

    -- Mode Switcher Pill
    local modePill = Instance.new("Frame", camApp)
    modePill.Size = UDim2.new(0, 160, 0, 36)
    modePill.Position = UDim2.new(0.5, -80, 1, -64)
    modePill.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    modePill.BorderSizePixel = 0
    modePill.ZIndex = 18
    Instance.new("UICorner", modePill).CornerRadius = UDim.new(1, 0)

    local mPhoto = Instance.new("TextButton", modePill)
    mPhoto.Size = UDim2.new(0.5, 0, 1, 0)
    mPhoto.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    mPhoto.Text = "Photo"
    mPhoto.Font = Enum.Font.GothamBold
    mPhoto.TextSize = 11.5
    mPhoto.TextColor3 = Color3.fromRGB(255, 204, 0)
    mPhoto.BorderSizePixel = 0
    mPhoto.ZIndex = 19
    Instance.new("UICorner", mPhoto).CornerRadius = UDim.new(1, 0)

    local mVideo = Instance.new("TextButton", modePill)
    mVideo.Size = UDim2.new(0.5, 0, 1, 0)
    mVideo.Position = UDim2.new(0.5, 0, 0, 0)
    mVideo.BackgroundTransparency = 1
    mVideo.Text = "Video"
    mVideo.Font = Enum.Font.GothamMedium
    mVideo.TextSize = 11.5
    mVideo.TextColor3 = Color3.fromRGB(150, 155, 170)
    mVideo.ZIndex = 19
end

-- ============================================================================
-- 19. WEATHER APP (Matching official_weather.png)
-- ============================================================================
local weatherApp = createBaseApp("Weather", Color3.fromRGB(45, 85, 135))
do
    local wGrad = Instance.new("UIGradient", weatherApp)
    wGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 110, 175)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 70, 120))
    })
    wGrad.Rotation = 90

    local wTitle = Instance.new("TextLabel", weatherApp)
    wTitle.Size = UDim2.new(1, 0, 0, 24)
    wTitle.Position = UDim2.new(0, 0, 0, 48)
    wTitle.Text = "Weather"
    wTitle.Font = Enum.Font.GothamBold
    wTitle.TextSize = 17
    wTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    wTitle.BackgroundTransparency = 1
    wTitle.ZIndex = 18

    local wCity = Instance.new("TextLabel", weatherApp)
    wCity.Size = UDim2.new(1, 0, 0, 18)
    wCity.Position = UDim2.new(0, 0, 0, 80)
    wCity.Text = "📍 Los Santos"
    wCity.Font = Enum.Font.GothamMedium
    wCity.TextSize = 14
    wCity.TextColor3 = Color3.fromRGB(220, 235, 255)
    wCity.BackgroundTransparency = 1
    wCity.ZIndex = 18

    local wIcon = Instance.new("ImageLabel", weatherApp)
    wIcon.Size = UDim2.new(0, 56, 0, 56)
    wIcon.Position = UDim2.new(0.5, -28, 0, 105)
    wIcon.BackgroundTransparency = 1
    wIcon.Image = "rbxassetid://121853675701505"
    wIcon.ScaleType = Enum.ScaleType.Fit
    wIcon.ZIndex = 18

    local wTemp = Instance.new("TextLabel", weatherApp)
    wTemp.Size = UDim2.new(1, 0, 0, 68)
    wTemp.Position = UDim2.new(0, 0, 0, 165)
    wTemp.Text = "24°"
    wTemp.Font = Enum.Font.GothamBold
    wTemp.TextSize = 64
    wTemp.TextColor3 = Color3.fromRGB(255, 255, 255)
    wTemp.BackgroundTransparency = 1
    wTemp.ZIndex = 18

    local wCond = Instance.new("TextLabel", weatherApp)
    wCond.Size = UDim2.new(1, 0, 0, 20)
    wCond.Position = UDim2.new(0, 0, 0, 235)
    wCond.Text = "Partly Cloudy"
    wCond.Font = Enum.Font.GothamBold
    wCond.TextSize = 17
    wCond.TextColor3 = Color3.fromRGB(255, 255, 255)
    wCond.BackgroundTransparency = 1
    wCond.ZIndex = 18

    local wDesc = Instance.new("TextLabel", weatherApp)
    wDesc.Size = UDim2.new(1, -40, 0, 16)
    wDesc.Position = UDim2.new(0, 20, 0, 256)
    wDesc.Text = "Sunshine mixed with passing clouds."
    wDesc.Font = Enum.Font.Gotham
    wDesc.TextSize = 12.5
    wDesc.TextColor3 = Color3.fromRGB(205, 225, 250)
    wDesc.BackgroundTransparency = 1
    wDesc.ZIndex = 18

    -- 4 Stat Cards in 2x2 Grid
    local gridFrame = Instance.new("Frame", weatherApp)
    gridFrame.Size = UDim2.new(1, -36, 0, 140)
    gridFrame.Position = UDim2.new(0, 18, 0, 285)
    gridFrame.BackgroundTransparency = 1
    gridFrame.ZIndex = 18
    local gl = Instance.new("UIGridLayout", gridFrame)
    gl.CellSize = UDim2.new(0.48, 0, 0, 64)
    gl.CellPadding = UDim2.new(0.04, 0, 0, 12)

    local function makeWeatherCard(tagTxt, valTxt, iconTxt)
        local c = Instance.new("Frame", gridFrame)
        c.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
        c.BackgroundTransparency = 0.2
        c.BorderSizePixel = 0
        c.ZIndex = 19
        Instance.new("UICorner", c).CornerRadius = UDim.new(0, 16)

        local ic = Instance.new("TextLabel", c)
        ic.Size = UDim2.new(0, 24, 0, 24)
        ic.Position = UDim2.new(0, 10, 0, 12)
        ic.Text = iconTxt
        ic.TextSize = 16
        ic.BackgroundTransparency = 1
        ic.ZIndex = 20

        local tl = Instance.new("TextLabel", c)
        tl.Size = UDim2.new(1, -42, 0, 14)
        tl.Position = UDim2.new(0, 38, 0, 10)
        tl.Text = tagTxt
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 9
        tl.TextColor3 = Color3.fromRGB(150, 160, 180)
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.BackgroundTransparency = 1
        tl.ZIndex = 20

        local vl = Instance.new("TextLabel", c)
        vl.Size = UDim2.new(1, -42, 0, 20)
        vl.Position = UDim2.new(0, 38, 0, 26)
        vl.Text = valTxt
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 15
        vl.TextColor3 = Color3.fromRGB(255, 255, 255)
        vl.TextXAlignment = Enum.TextXAlignment.Left
        vl.BackgroundTransparency = 1
        vl.ZIndex = 20
    end
    makeWeatherCard("FEELS LIKE", "23°", "🌡")
    makeWeatherCard("WIND", "12 km/h", "💨")
    makeWeatherCard("HUMIDITY", "53%", "💧")
    makeWeatherCard("PRECIPITATION", "18%", "☂")

    -- Next Hours Forecast Card
    local fCard = Instance.new("Frame", weatherApp)
    fCard.Size = UDim2.new(1, -36, 0, 115)
    fCard.Position = UDim2.new(0, 18, 0, 440)
    fCard.BackgroundColor3 = Color3.fromRGB(28, 30, 36)
    fCard.BackgroundTransparency = 0.2
    fCard.BorderSizePixel = 0
    fCard.ZIndex = 18
    Instance.new("UICorner", fCard).CornerRadius = UDim.new(0, 18)

    local fHead = Instance.new("TextLabel", fCard)
    fHead.Size = UDim2.new(1, -20, 0, 18)
    fHead.Position = UDim2.new(0, 12, 0, 10)
    fHead.Text = "⏱ Next Hours"
    fHead.Font = Enum.Font.GothamBold
    fHead.TextSize = 11.5
    fHead.TextColor3 = Color3.fromRGB(220, 230, 245)
    fHead.TextXAlignment = Enum.TextXAlignment.Left
    fHead.BackgroundTransparency = 1
    fHead.ZIndex = 19

    local hRow = Instance.new("Frame", fCard)
    hRow.Size = UDim2.new(1, -24, 0, 72)
    hRow.Position = UDim2.new(0, 12, 0, 32)
    hRow.BackgroundTransparency = 1
    hRow.ZIndex = 19
    local hrLayout = Instance.new("UIListLayout", hRow)
    hrLayout.FillDirection = Enum.FillDirection.Horizontal
    hrLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    hrLayout.Padding = UDim.new(0, 8)

    local hourly = {
        {"Now", "⛅", "24°", nil}, {"18", "🌧", "19°", "82%"},
        {"19", "🌧", "17°", "82%"}, {"20", "🌧", "16°", "82%"},
        {"21", "🌧", "15°", "82%"}, {"22", "🌧", "13°", "82%"}
    }

    for _, hr in ipairs(hourly) do
        local col = Instance.new("Frame", hRow)
        col.Size = UDim2.new(0.15, 0, 1, 0)
        col.BackgroundTransparency = 1
        col.ZIndex = 20

        local t = Instance.new("TextLabel", col)
        t.Size = UDim2.new(1, 0, 0, 12)
        t.Text = hr[1]
        t.Font = Enum.Font.GothamMedium
        t.TextSize = 10
        t.TextColor3 = Color3.fromRGB(180, 195, 215)
        t.BackgroundTransparency = 1
        t.ZIndex = 21

        local ic = Instance.new("TextLabel", col)
        ic.Size = UDim2.new(1, 0, 0, 18)
        ic.Position = UDim2.new(0, 0, 0, 14)
        ic.Text = hr[2]
        ic.TextSize = 14
        ic.BackgroundTransparency = 1
        ic.ZIndex = 21

        local vl = Instance.new("TextLabel", col)
        vl.Size = UDim2.new(1, 0, 0, 14)
        vl.Position = UDim2.new(0, 0, 0, 48)
        vl.Text = hr[3]
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 11.5
        vl.TextColor3 = Color3.fromRGB(255, 255, 255)
        vl.BackgroundTransparency = 1
        vl.ZIndex = 21
    end

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Weather"] = function(isLight)
            weatherApp.BackgroundColor3 = isLight and Color3.fromRGB(45, 85, 135) or Color3.fromRGB(18, 24, 38)
            if wGrad then
                wGrad.Color = isLight and ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 110, 175)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 70, 120))
                }) or ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 32, 50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 16, 26))
                })
            end
        end
    end
end

return { name = "MediaSuite" }
