-- ============================================================================
-- 7. CALCULATOR APP (Matching official_calculator.png: Light Theme + 5x4 Grid)
-- ============================================================================
calcApp = createBaseApp("Calculator", Color3.fromRGB(240, 242, 245))
do
    -- Top circular buttons: History (left) and Tape (right)
    local cHistBtn = Instance.new("TextButton", calcApp)
    cHistBtn.Size = UDim2.new(0, 38, 0, 38)
    cHistBtn.Position = UDim2.new(0, 18, 0, 48)
    cHistBtn.BackgroundColor3 = Color3.fromRGB(225, 228, 235)
    cHistBtn.BorderSizePixel = 0
    cHistBtn.Text = "🕒"
    cHistBtn.TextSize = 16
    cHistBtn.ZIndex = 18
    Instance.new("UICorner", cHistBtn).CornerRadius = UDim.new(1, 0)

    local cTapeBtn = Instance.new("TextButton", calcApp)
    cTapeBtn.Size = UDim2.new(0, 38, 0, 38)
    cTapeBtn.Position = UDim2.new(1, -56, 0, 48)
    cTapeBtn.BackgroundColor3 = Color3.fromRGB(225, 228, 235)
    cTapeBtn.BorderSizePixel = 0
    cTapeBtn.Text = "🖩"
    cTapeBtn.TextSize = 16
    cTapeBtn.ZIndex = 18
    Instance.new("UICorner", cTapeBtn).CornerRadius = UDim.new(1, 0)

    -- Right-aligned display
    local cDisp = Instance.new("TextLabel", calcApp)
    cDisp.Name = "Display"
    cDisp.Size = UDim2.new(1, -40, 0, 90)
    cDisp.Position = UDim2.new(0, 20, 0, 100)
    cDisp.BackgroundTransparency = 1
    cDisp.Text = "0"
    cDisp.TextColor3 = Color3.fromRGB(15, 18, 28)
    cDisp.Font = Enum.Font.Gotham
    cDisp.TextSize = 64
    cDisp.TextXAlignment = Enum.TextXAlignment.Right
    cDisp.ZIndex = 18

    -- 5x4 Grid
    local cGrid = Instance.new("Frame", calcApp)
    cGrid.Name = "Grid"
    cGrid.AnchorPoint = Vector2.new(0.5, 0)
    cGrid.Position = UDim2.new(0.5, 0, 0, 215)
    cGrid.Size = UDim2.new(0, 260, 0, 340)
    cGrid.BackgroundTransparency = 1
    cGrid.ZIndex = 18

    local gLayout = Instance.new("UIGridLayout", cGrid)
    gLayout.CellSize = UDim2.new(0, 54, 0, 54)
    gLayout.CellPadding = UDim2.new(0, 14, 0, 14)
    gLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local currentInput = "0"
    local firstOperand = nil
    local currentOperator = nil
    local shouldResetDisplay = false

    local function updateDisplay()
        cDisp.Text = currentInput
    end

    local function handleCalcBtn(val)
        playTone()
        if tonumber(val) then
            if currentInput == "0" or shouldResetDisplay then
                currentInput = val
                shouldResetDisplay = false
            else
                if #currentInput < 9 then
                    currentInput = currentInput .. val
                end
            end
            updateDisplay()
        elseif val == "," or val == "." then
            if shouldResetDisplay then
                currentInput = "0."
                shouldResetDisplay = false
            elseif not string.find(currentInput, "%.") then
                currentInput = currentInput .. "."
            end
            updateDisplay()
        elseif val == "C" then
            currentInput = "0"
            firstOperand = nil
            currentOperator = nil
            shouldResetDisplay = false
            updateDisplay()
        elseif val == "⌫" then
            if #currentInput > 1 then
                currentInput = string.sub(currentInput, 1, #currentInput - 1)
            else
                currentInput = "0"
            end
            updateDisplay()
        elseif val == "+/−" then
            if currentInput ~= "0" then
                if string.sub(currentInput, 1, 1) == "-" then
                    currentInput = string.sub(currentInput, 2)
                else
                    currentInput = "-" .. currentInput
                end
                updateDisplay()
            end
        elseif val == "%" then
            local num = tonumber(currentInput) or 0
            currentInput = tostring(num / 100)
            updateDisplay()
        elseif val == "÷" or val == "×" or val == "−" or val == "+" then
            firstOperand = tonumber(currentInput)
            currentOperator = val
            shouldResetDisplay = true
        elseif val == "=" then
            if firstOperand and currentOperator then
                local secondOperand = tonumber(currentInput) or 0
                local result = 0
                if currentOperator == "+" then result = firstOperand + secondOperand
                elseif currentOperator == "−" then result = firstOperand - secondOperand
                elseif currentOperator == "×" then result = firstOperand * secondOperand
                elseif currentOperator == "÷" then
                    result = (secondOperand ~= 0) and (firstOperand / secondOperand) or "Error"
                end
                currentInput = tostring(result)
                firstOperand = nil
                currentOperator = nil
                shouldResetDisplay = true
                updateDisplay()
            end
        end
    end

    local calcLayout = {
        {"⌫", "func"}, {"C", "func"}, {"%", "func"}, {"÷", "op"},
        {"7", "num"}, {"8", "num"}, {"9", "num"}, {"×", "op"},
        {"4", "num"}, {"5", "num"}, {"6", "num"}, {"−", "op"},
        {"1", "num"}, {"2", "num"}, {"3", "num"}, {"+", "op"},
        {"+/−", "num"}, {"0", "num"}, {",", "num"}, {"=", "op"}
    }

    local calcFuncBtns = {}
    local calcNumBtns = {}
    local calcStrokes = {}

    for _, item in ipairs(calcLayout) do
        local txt, kind = item[1], item[2]
        local b = Instance.new("TextButton", cGrid)
        b.Size = UDim2.new(0, 54, 0, 54)
        b.Text = txt
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 22
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.ZIndex = 19
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

        if kind == "op" then
            b.BackgroundColor3 = Color3.fromRGB(255, 149, 0)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
        elseif kind == "func" then
            b.BackgroundColor3 = Color3.fromRGB(205, 208, 218)
            b.TextColor3 = Color3.fromRGB(15, 18, 28)
            table.insert(calcFuncBtns, b)
        else
            b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            b.TextColor3 = Color3.fromRGB(15, 18, 28)
            local bs = Instance.new("UIStroke", b)
            bs.Color = Color3.fromRGB(225, 228, 238)
            table.insert(calcNumBtns, b)
            table.insert(calcStrokes, bs)
        end

        b.MouseButton1Click:Connect(function()
            handleCalcBtn(txt)
        end)
    end

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Calculator"] = function(isLight)
            calcApp.BackgroundColor3 = isLight and Color3.fromRGB(240, 242, 245) or Color3.fromRGB(0, 0, 0)
            if cDisp then cDisp.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255) end
            if cHistBtn then
                cHistBtn.BackgroundColor3 = isLight and Color3.fromRGB(225, 228, 235) or Color3.fromRGB(44, 44, 46)
            end
            if cTapeBtn then
                cTapeBtn.BackgroundColor3 = isLight and Color3.fromRGB(225, 228, 235) or Color3.fromRGB(44, 44, 46)
            end
            for _, b in ipairs(calcFuncBtns) do
                b.BackgroundColor3 = isLight and Color3.fromRGB(205, 208, 218) or Color3.fromRGB(165, 165, 165)
                b.TextColor3 = Color3.fromRGB(15, 18, 28)
            end
            for _, b in ipairs(calcNumBtns) do
                b.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(51, 51, 51)
                b.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255)
            end
            for _, s in ipairs(calcStrokes) do
                s.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(51, 51, 51)
            end
        end
    end
end

-- ============================================================================
-- 8. BANKING APP (Matching official_banking.png: Light Gradient + Hero Card)
-- ============================================================================
bankApp = createBaseApp("Banking", Color3.fromRGB(240, 244, 249))
do
    -- Top Header: Alex Morgan
    local bHeader = Instance.new("Frame", bankApp)
    bHeader.Size = UDim2.new(1, 0, 0, 55)
    bHeader.Position = UDim2.new(0, 0, 0, 36)
    bHeader.BackgroundTransparency = 1
    bHeader.ZIndex = 18

    local bUser = Instance.new("TextLabel", bHeader)
    bUser.Size = UDim2.new(1, 0, 0, 22)
    bUser.Position = UDim2.new(0, 0, 0, 8)
    bUser.Text = "Alex Morgan"
    bUser.Font = Enum.Font.GothamBold
    bUser.TextSize = 17
    bUser.TextColor3 = Color3.fromRGB(20, 24, 35)
    bUser.BackgroundTransparency = 1
    bUser.ZIndex = 19

    local bWelcome = Instance.new("TextLabel", bHeader)
    bWelcome.Size = UDim2.new(1, 0, 0, 16)
    bWelcome.Position = UDim2.new(0, 0, 0, 30)
    bWelcome.Text = "Welcome back"
    bWelcome.Font = Enum.Font.GothamMedium
    bWelcome.TextSize = 12
    bWelcome.TextColor3 = Color3.fromRGB(140, 145, 160)
    bWelcome.BackgroundTransparency = 1
    bWelcome.ZIndex = 19

    -- Hero Card: Total Balance $24,787
    local heroCard = Instance.new("Frame", bankApp)
    heroCard.Size = UDim2.new(1, -36, 0, 130)
    heroCard.Position = UDim2.new(0, 18, 0, 96)
    heroCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    heroCard.BorderSizePixel = 0
    heroCard.ZIndex = 18
    Instance.new("UICorner", heroCard).CornerRadius = UDim.new(0, 22)
    local hs = Instance.new("UIStroke", heroCard)
    hs.Color = Color3.fromRGB(230, 234, 244)

    local hbLabel = Instance.new("TextLabel", heroCard)
    hbLabel.Size = UDim2.new(0.6, 0, 0, 18)
    hbLabel.Position = UDim2.new(0, 18, 0, 16)
    hbLabel.Text = "Total Balance"
    hbLabel.Font = Enum.Font.GothamMedium
    hbLabel.TextSize = 13
    hbLabel.TextColor3 = Color3.fromRGB(130, 135, 150)
    hbLabel.TextXAlignment = Enum.TextXAlignment.Left
    hbLabel.BackgroundTransparency = 1
    hbLabel.ZIndex = 19

    local pillBadge = Instance.new("Frame", heroCard)
    pillBadge.Size = UDim2.new(0, 42, 0, 24)
    pillBadge.Position = UDim2.new(1, -56, 0, 14)
    pillBadge.BackgroundColor3 = Color3.fromRGB(244, 246, 250)
    pillBadge.BorderSizePixel = 0
    pillBadge.ZIndex = 19
    Instance.new("UICorner", pillBadge).CornerRadius = UDim.new(1, 0)
    local pbs = Instance.new("UIStroke", pillBadge)
    pbs.Color = Color3.fromRGB(220, 225, 235)

    local pbText = Instance.new("TextLabel", pillBadge)
    pbText.Size = UDim2.new(1, 0, 1, 0)
    pbText.Text = "#42"
    pbText.Font = Enum.Font.GothamBold
    pbText.TextSize = 11
    pbText.TextColor3 = Color3.fromRGB(130, 135, 150)
    pbText.BackgroundTransparency = 1
    pbText.ZIndex = 20

    local hbAmount = Instance.new("TextLabel", heroCard)
    hbAmount.Size = UDim2.new(1, -36, 0, 44)
    hbAmount.Position = UDim2.new(0, 18, 0, 42)
    hbAmount.Text = "$24,787"
    hbAmount.Font = Enum.Font.GothamBold
    hbAmount.TextSize = 36
    hbAmount.TextColor3 = Color3.fromRGB(15, 18, 28)
    hbAmount.TextXAlignment = Enum.TextXAlignment.Left
    hbAmount.BackgroundTransparency = 1
    hbAmount.ZIndex = 19

    local hbActivity = Instance.new("TextLabel", heroCard)
    hbActivity.Size = UDim2.new(1, -36, 0, 18)
    hbActivity.Position = UDim2.new(0, 18, 0, 92)
    hbActivity.Text = "+$4,000 in recent activity"
    hbActivity.Font = Enum.Font.GothamBold
    hbActivity.TextSize = 12
    hbActivity.TextColor3 = Color3.fromRGB(52, 199, 89)
    hbActivity.TextXAlignment = Enum.TextXAlignment.Left
    hbActivity.BackgroundTransparency = 1
    hbActivity.ZIndex = 19

    -- Translucent Send Action Button
    local sendBtn = Instance.new("TextButton", bankApp)
    sendBtn.Size = UDim2.new(1, -36, 0, 48)
    sendBtn.Position = UDim2.new(0, 18, 0, 238)
    sendBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.BackgroundTransparency = 0.5
    sendBtn.BorderSizePixel = 0
    sendBtn.Text = "✈  Send  >"
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.TextSize = 14
    sendBtn.TextColor3 = Color3.fromRGB(150, 155, 170)
    sendBtn.AutoButtonColor = false
    sendBtn.ZIndex = 18
    Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 20)
    local sbs = Instance.new("UIStroke", sendBtn)
    sbs.Color = Color3.fromRGB(230, 234, 244)

    -- Accounts Card
    local accTitle = Instance.new("TextLabel", bankApp)
    accTitle.Size = UDim2.new(1, -36, 0, 22)
    accTitle.Position = UDim2.new(0, 22, 0, 298)
    accTitle.Text = "Accounts"
    accTitle.Font = Enum.Font.GothamBold
    accTitle.TextSize = 16
    accTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    accTitle.TextXAlignment = Enum.TextXAlignment.Left
    accTitle.BackgroundTransparency = 1
    accTitle.ZIndex = 18

    local accCard = Instance.new("Frame", bankApp)
    accCard.Size = UDim2.new(1, -36, 0, 100)
    accCard.Position = UDim2.new(0, 18, 0, 326)
    accCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    accCard.BorderSizePixel = 0
    accCard.ZIndex = 18
    Instance.new("UICorner", accCard).CornerRadius = UDim.new(0, 20)
    local as = Instance.new("UIStroke", accCard)
    as.Color = Color3.fromRGB(230, 234, 244)

    local function makeAccRow(iconSymbol, name, amount, yPos)
        local ic = Instance.new("TextLabel", accCard)
        ic.Size = UDim2.new(0, 24, 0, 24)
        ic.Position = UDim2.new(0, 14, 0, yPos + 12)
        ic.BackgroundTransparency = 1
        ic.Text = iconSymbol
        ic.TextSize = 18
        ic.TextColor3 = Color3.fromRGB(0, 122, 255)
        ic.ZIndex = 19

        local nl = Instance.new("TextLabel", accCard)
        nl.Size = UDim2.new(0.5, 0, 0, 20)
        nl.Position = UDim2.new(0, 48, 0, yPos + 14)
        nl.BackgroundTransparency = 1
        nl.Text = name
        nl.Font = Enum.Font.GothamMedium
        nl.TextSize = 15
        nl.TextColor3 = Color3.fromRGB(15, 18, 28)
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.ZIndex = 19

        local al = Instance.new("TextLabel", accCard)
        al.Size = UDim2.new(0.4, 0, 0, 20)
        al.Position = UDim2.new(0.6, -18, 0, yPos + 14)
        al.BackgroundTransparency = 1
        al.Text = amount
        al.Font = Enum.Font.GothamMedium
        al.TextSize = 15
        al.TextColor3 = Color3.fromRGB(100, 105, 120)
        al.TextXAlignment = Enum.TextXAlignment.Right
        al.ZIndex = 19
    end

    makeAccRow("💳", "Bank account", "$24,787", 0)
    local accDiv = Instance.new("Frame", accCard)
    accDiv.Size = UDim2.new(1, -48, 0, 1)
    accDiv.Position = UDim2.new(0, 48, 0, 50)
    accDiv.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    accDiv.BorderSizePixel = 0
    accDiv.ZIndex = 19
    makeAccRow("💵", "Cash", "$2,350", 50)

    -- Latest Transactions
    local ltHeader = Instance.new("Frame", bankApp)
    ltHeader.Size = UDim2.new(1, -36, 0, 22)
    ltHeader.Position = UDim2.new(0, 18, 0, 438)
    ltHeader.BackgroundTransparency = 1
    ltHeader.ZIndex = 18

    local ltTitle = Instance.new("TextLabel", ltHeader)
    ltTitle.Size = UDim2.new(0.6, 0, 1, 0)
    ltTitle.Text = "Latest Transactions"
    ltTitle.Font = Enum.Font.GothamBold
    ltTitle.TextSize = 16
    ltTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    ltTitle.TextXAlignment = Enum.TextXAlignment.Left
    ltTitle.BackgroundTransparency = 1
    ltTitle.ZIndex = 19

    local ltViewAll = Instance.new("TextLabel", ltHeader)
    ltViewAll.Size = UDim2.new(0.4, 0, 1, 0)
    ltViewAll.Position = UDim2.new(0.6, 0, 0, 0)
    ltViewAll.Text = "View all"
    ltViewAll.Font = Enum.Font.GothamMedium
    ltViewAll.TextSize = 12
    ltViewAll.TextColor3 = Color3.fromRGB(0, 122, 255)
    ltViewAll.TextXAlignment = Enum.TextXAlignment.Right
    ltViewAll.BackgroundTransparency = 1
    ltViewAll.ZIndex = 19

    local txCard = Instance.new("Frame", bankApp)
    txCard.Size = UDim2.new(1, -36, 0, 110)
    txCard.Position = UDim2.new(0, 18, 0, 466)
    txCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    txCard.BorderSizePixel = 0
    txCard.ZIndex = 18
    Instance.new("UICorner", txCard).CornerRadius = UDim.new(0, 20)
    local txs = Instance.new("UIStroke", txCard)
    txs.Color = Color3.fromRGB(230, 234, 244)

    local function makeTxRow(arrowSym, name, dateTxt, amountTxt, isIncome, yPos)
        local arr = Instance.new("TextLabel", txCard)
        arr.Size = UDim2.new(0, 24, 0, 24)
        arr.Position = UDim2.new(0, 12, 0, yPos + 14)
        arr.BackgroundTransparency = 1
        arr.Text = arrowSym
        arr.TextSize = 18
        arr.TextColor3 = Color3.fromRGB(0, 122, 255)
        arr.ZIndex = 19

        local nl = Instance.new("TextLabel", txCard)
        nl.Size = UDim2.new(0.5, 0, 0, 18)
        nl.Position = UDim2.new(0, 44, 0, yPos + 10)
        nl.BackgroundTransparency = 1
        nl.Text = name
        nl.Font = Enum.Font.GothamBold
        nl.TextSize = 14
        nl.TextColor3 = Color3.fromRGB(15, 18, 28)
        nl.TextXAlignment = Enum.TextXAlignment.Left
        nl.ZIndex = 19

        local dl = Instance.new("TextLabel", txCard)
        dl.Size = UDim2.new(0.5, 0, 0, 14)
        dl.Position = UDim2.new(0, 44, 0, yPos + 30)
        dl.BackgroundTransparency = 1
        dl.Text = dateTxt
        dl.Font = Enum.Font.Gotham
        dl.TextSize = 11
        dl.TextColor3 = Color3.fromRGB(140, 145, 160)
        dl.TextXAlignment = Enum.TextXAlignment.Left
        dl.ZIndex = 19

        local al = Instance.new("TextLabel", txCard)
        al.Size = UDim2.new(0.4, 0, 0, 20)
        al.Position = UDim2.new(0.6, -14, 0, yPos + 16)
        al.BackgroundTransparency = 1
        al.Text = amountTxt .. " >"
        al.Font = Enum.Font.GothamBold
        al.TextSize = 14
        al.TextColor3 = isIncome and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 59, 48)
        al.TextXAlignment = Enum.TextXAlignment.Right
        al.ZIndex = 19
    end

    makeTxRow("↙", "Sofia Turner", "Sep 21, 02:15", "+$3,200", true, 0)
    local txDiv = Instance.new("Frame", txCard)
    txDiv.Size = UDim2.new(1, -44, 0, 1)
    txDiv.Position = UDim2.new(0, 44, 0, 55)
    txDiv.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    txDiv.BorderSizePixel = 0
    txDiv.ZIndex = 19
    makeTxRow("↗", "Vincent Cole", "Sep 20, 22:00", "-$680", false, 55)

    -- Bottom Floating Dock (Home | Activity)
    local bDock = Instance.new("Frame", bankApp)
    bDock.Size = UDim2.new(1, -36, 0, 52)
    bDock.Position = UDim2.new(0, 18, 1, -72)
    bDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bDock.BorderSizePixel = 0
    bDock.ZIndex = 25
    Instance.new("UICorner", bDock).CornerRadius = UDim.new(1, 0)
    local bds = Instance.new("UIStroke", bDock)
    bds.Color = Color3.fromRGB(225, 228, 238)

    local bdLayout = Instance.new("UIListLayout", bDock)
    bdLayout.FillDirection = Enum.FillDirection.Horizontal
    bdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    bdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    bdLayout.Padding = UDim.new(0, 16)

    local bTab1 = Instance.new("TextButton", bDock)
    bTab1.Size = UDim2.new(0, 80, 0, 38)
    bTab1.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    bTab1.Text = "🏠\nHome"
    bTab1.Font = Enum.Font.GothamBold
    bTab1.TextSize = 9.5
    bTab1.TextColor3 = Color3.fromRGB(0, 122, 255)
    bTab1.BorderSizePixel = 0
    bTab1.ZIndex = 26
    Instance.new("UICorner", bTab1).CornerRadius = UDim.new(1, 0)

    local bTab2 = Instance.new("TextButton", bDock)
    bTab2.Size = UDim2.new(0, 80, 0, 38)
    bTab2.BackgroundTransparency = 1
    bTab2.Text = "📊\nActivity"
    bTab2.Font = Enum.Font.GothamBold
    bTab2.TextSize = 9.5
    bTab2.TextColor3 = Color3.fromRGB(140, 145, 160)
    bTab2.BorderSizePixel = 0
    bTab2.ZIndex = 26

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Banking"] = function(isLight)
            bankApp.BackgroundColor3 = isLight and Color3.fromRGB(240, 244, 249) or Color3.fromRGB(0, 0, 0)
            if bUser then bUser.TextColor3 = isLight and Color3.fromRGB(20, 24, 35) or Color3.fromRGB(255, 255, 255) end
            if heroCard then
                heroCard.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
                if hs then hs.Color = isLight and Color3.fromRGB(230, 234, 244) or Color3.fromRGB(44, 44, 46) end
            end
            if hbAmount then hbAmount.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255) end
            if bDock then
                bDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(24, 24, 26)
                if bds then bds.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(bankApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 9. BILLING APP (Matching official_billing.png)
-- ============================================================================
local billingApp = createBaseApp("Billing", Color3.fromRGB(242, 244, 248))
do
    local bHeader = Instance.new("Frame", billingApp)
    bHeader.Size = UDim2.new(1, 0, 0, 48)
    bHeader.Position = UDim2.new(0, 0, 0, 36)
    bHeader.BackgroundTransparency = 1
    bHeader.ZIndex = 18

    local bTitle = Instance.new("TextLabel", bHeader)
    bTitle.Size = UDim2.new(1, 0, 1, 0)
    bTitle.Text = "🧾 Billing"
    bTitle.Font = Enum.Font.GothamBold
    bTitle.TextSize = 22
    bTitle.TextColor3 = Color3.fromRGB(255, 95, 105)
    bTitle.BackgroundTransparency = 1
    bTitle.ZIndex = 19

    local bStatRow = Instance.new("Frame", billingApp)
    bStatRow.Size = UDim2.new(1, -24, 0, 82)
    bStatRow.Position = UDim2.new(0, 12, 0, 88)
    bStatRow.BackgroundTransparency = 1
    bStatRow.ZIndex = 18
    local bStatLayout = Instance.new("UIListLayout", bStatRow)
    bStatLayout.FillDirection = Enum.FillDirection.Horizontal
    bStatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    bStatLayout.Padding = UDim.new(0, 8)

    local function makeBillingStatCard(label, val)
        local card = Instance.new("Frame", bStatRow)
        card.Size = UDim2.new(0.31, 0, 1, 0)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.BorderSizePixel = 0
        card.ZIndex = 19
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)
        local cs = Instance.new("UIStroke", card)
        cs.Color = Color3.fromRGB(235, 238, 245)

        local l = Instance.new("TextLabel", card)
        l.Size = UDim2.new(1, -10, 0, 16)
        l.Position = UDim2.new(0, 5, 0, 14)
        l.Text = label
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 10
        l.TextColor3 = Color3.fromRGB(140, 145, 160)
        l.BackgroundTransparency = 1
        l.ZIndex = 20

        local v = Instance.new("TextLabel", card)
        v.Size = UDim2.new(1, -10, 0, 26)
        v.Position = UDim2.new(0, 5, 0, 36)
        v.Text = val
        v.Font = Enum.Font.GothamBold
        v.TextSize = 17
        v.TextColor3 = Color3.fromRGB(20, 24, 35)
        v.BackgroundTransparency = 1
        v.ZIndex = 20
    end

    makeBillingStatCard("Open invoices", "2")
    makeBillingStatCard("Amount due", "2,299 $")
    makeBillingStatCard("Overdue", "1")

    -- Invoice Source Segmented Control
    local segCard = Instance.new("Frame", billingApp)
    segCard.Size = UDim2.new(1, -24, 0, 54)
    segCard.Position = UDim2.new(0, 12, 0, 178)
    segCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    segCard.BorderSizePixel = 0
    segCard.ZIndex = 18
    Instance.new("UICorner", segCard).CornerRadius = UDim.new(0, 18)
    local segStroke = Instance.new("UIStroke", segCard)
    segStroke.Color = Color3.fromRGB(235, 238, 245)

    local isLabel = Instance.new("TextLabel", segCard)
    isLabel.Size = UDim2.new(1, -20, 0, 12)
    isLabel.Position = UDim2.new(0, 12, 0, 6)
    isLabel.Text = "INVOICE SOURCE"
    isLabel.Font = Enum.Font.GothamBold
    isLabel.TextSize = 8.5
    isLabel.TextColor3 = Color3.fromRGB(160, 165, 180)
    isLabel.TextXAlignment = Enum.TextXAlignment.Left
    isLabel.BackgroundTransparency = 1
    isLabel.ZIndex = 19

    local recPill = Instance.new("TextButton", segCard)
    recPill.Size = UDim2.new(0.48, 0, 0, 28)
    recPill.Position = UDim2.new(0, 8, 0, 20)
    recPill.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    recPill.Text = "📥 Received  2"
    recPill.Font = Enum.Font.GothamBold
    recPill.TextSize = 11.5
    recPill.TextColor3 = Color3.fromRGB(255, 255, 255)
    recPill.BorderSizePixel = 0
    recPill.ZIndex = 20
    Instance.new("UICorner", recPill).CornerRadius = UDim.new(0, 12)

    local sentPill = Instance.new("TextButton", segCard)
    sentPill.Size = UDim2.new(0.48, 0, 0, 28)
    sentPill.Position = UDim2.new(0.51, 0, 0, 20)
    sentPill.BackgroundTransparency = 1
    sentPill.Text = "✈ Sent"
    sentPill.Font = Enum.Font.GothamMedium
    sentPill.TextSize = 11.5
    sentPill.TextColor3 = Color3.fromRGB(0, 122, 255)
    sentPill.ZIndex = 20

    -- Payment Center Section
    local pcHeader = Instance.new("Frame", billingApp)
    pcHeader.Size = UDim2.new(1, -24, 0, 32)
    pcHeader.Position = UDim2.new(0, 12, 0, 240)
    pcHeader.BackgroundTransparency = 1
    pcHeader.ZIndex = 18

    local pcSub = Instance.new("TextLabel", pcHeader)
    pcSub.Size = UDim2.new(1, 0, 0, 12)
    pcSub.Text = "PAYMENT CENTER"
    pcSub.Font = Enum.Font.GothamBold
    pcSub.TextSize = 8.5
    pcSub.TextColor3 = Color3.fromRGB(160, 165, 180)
    pcSub.TextXAlignment = Enum.TextXAlignment.Left
    pcSub.BackgroundTransparency = 1
    pcSub.ZIndex = 19

    local pcTitle = Instance.new("TextLabel", pcHeader)
    pcTitle.Size = UDim2.new(0.6, 0, 0, 18)
    pcTitle.Position = UDim2.new(0, 0, 0, 12)
    pcTitle.Text = "Needs attention"
    pcTitle.Font = Enum.Font.GothamBold
    pcTitle.TextSize = 15
    pcTitle.TextColor3 = Color3.fromRGB(20, 24, 35)
    pcTitle.TextXAlignment = Enum.TextXAlignment.Left
    pcTitle.BackgroundTransparency = 1
    pcTitle.ZIndex = 19

    local pcViewAll = Instance.new("TextLabel", pcHeader)
    pcViewAll.Size = UDim2.new(0.4, 0, 0, 18)
    pcViewAll.Position = UDim2.new(0.6, 0, 0, 12)
    pcViewAll.Text = "View all invoices"
    pcViewAll.Font = Enum.Font.GothamMedium
    pcViewAll.TextSize = 11
    pcViewAll.TextColor3 = Color3.fromRGB(0, 122, 255)
    pcViewAll.TextXAlignment = Enum.TextXAlignment.Right
    pcViewAll.BackgroundTransparency = 1
    pcViewAll.ZIndex = 19

    -- Invoices List
    local invScroll = Instance.new("ScrollingFrame", billingApp)
    invScroll.Size = UDim2.new(1, -24, 1, -345)
    invScroll.Position = UDim2.new(0, 12, 0, 276)
    invScroll.BackgroundTransparency = 1
    invScroll.ScrollBarThickness = 0
    invScroll.CanvasSize = UDim2.new(0, 0, 0, 180)
    invScroll.ZIndex = 18

    local function makeInvoiceCard(title, sender, due, amount, isOverdue, yPos)
        local card = Instance.new("Frame", invScroll)
        card.Size = UDim2.new(1, 0, 0, 72)
        card.Position = UDim2.new(0, 0, 0, yPos)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.BorderSizePixel = 0
        card.ZIndex = 19
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)
        local cs = Instance.new("UIStroke", card)
        cs.Color = Color3.fromRGB(235, 238, 245)

        local ico = Instance.new("Frame", card)
        ico.Size = UDim2.new(0, 42, 0, 42)
        ico.Position = UDim2.new(0, 12, 0.5, -21)
        ico.BackgroundColor3 = Color3.fromRGB(255, 95, 105)
        ico.BorderSizePixel = 0
        ico.ZIndex = 20
        Instance.new("UICorner", ico).CornerRadius = UDim.new(0, 14)

        local icoTxt = Instance.new("TextLabel", ico)
        icoTxt.Size = UDim2.new(1, 0, 1, 0)
        icoTxt.Text = "🏢"
        icoTxt.TextSize = 20
        icoTxt.BackgroundTransparency = 1
        icoTxt.ZIndex = 21

        local t = Instance.new("TextLabel", card)
        t.Size = UDim2.new(0.55, 0, 0, 16)
        t.Position = UDim2.new(0, 62, 0, 12)
        t.Text = title
        t.Font = Enum.Font.GothamBold
        t.TextSize = 13
        t.TextColor3 = Color3.fromRGB(20, 24, 35)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.BackgroundTransparency = 1
        t.ZIndex = 20

        local s = Instance.new("TextLabel", card)
        s.Size = UDim2.new(0.55, 0, 0, 14)
        s.Position = UDim2.new(0, 62, 0, 28)
        s.Text = sender
        s.Font = Enum.Font.GothamMedium
        s.TextSize = 10.5
        s.TextColor3 = Color3.fromRGB(130, 135, 150)
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.BackgroundTransparency = 1
        s.ZIndex = 20

        local d = Instance.new("TextLabel", card)
        d.Size = UDim2.new(0.55, 0, 0, 14)
        d.Position = UDim2.new(0, 62, 0, 44)
        d.Text = "Due " .. due
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextColor3 = Color3.fromRGB(150, 155, 170)
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.BackgroundTransparency = 1
        d.ZIndex = 20

        local badge = Instance.new("Frame", card)
        badge.Size = UDim2.new(0, 52, 0, 18)
        badge.Position = UDim2.new(1, -64, 0, 12)
        badge.BackgroundColor3 = isOverdue and Color3.fromRGB(255, 240, 242) or Color3.fromRGB(235, 245, 255)
        badge.BorderSizePixel = 0
        badge.ZIndex = 20
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 6)

        local badgeTxt = Instance.new("TextLabel", badge)
        badgeTxt.Size = UDim2.new(1, 0, 1, 0)
        badgeTxt.Text = isOverdue and "Overdue" or "Open"
        badgeTxt.Font = Enum.Font.GothamBold
        badgeTxt.TextSize = 9.5
        badgeTxt.TextColor3 = isOverdue and Color3.fromRGB(255, 60, 75) or Color3.fromRGB(0, 122, 255)
        badgeTxt.BackgroundTransparency = 1
        badgeTxt.ZIndex = 21

        local a = Instance.new("TextLabel", card)
        a.Size = UDim2.new(0, 80, 0, 20)
        a.Position = UDim2.new(1, -94, 0, 36)
        a.Text = amount .. " >"
        a.Font = Enum.Font.GothamBold
        a.TextSize = 13.5
        a.TextColor3 = Color3.fromRGB(20, 24, 35)
        a.TextXAlignment = Enum.TextXAlignment.Right
        a.BackgroundTransparency = 1
        a.ZIndex = 20
    end

    makeInvoiceCard("Vehicle repair", "Benny's Motorworks", "09/20/2026", "999 $", true, 0)
    makeInvoiceCard("Medical treatment", "Los Santos Medical", "09/23/2026", "1,300 $", false, 80)

    -- Bottom Floating Dock
    local bDock = Instance.new("Frame", billingApp)
    bDock.Size = UDim2.new(1, -36, 0, 52)
    bDock.Position = UDim2.new(0, 18, 1, -72)
    bDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bDock.BorderSizePixel = 0
    bDock.ZIndex = 25
    Instance.new("UICorner", bDock).CornerRadius = UDim.new(1, 0)
    local bds = Instance.new("UIStroke", bDock)
    bds.Color = Color3.fromRGB(225, 228, 238)

    local bdLayout = Instance.new("UIListLayout", bDock)
    bdLayout.FillDirection = Enum.FillDirection.Horizontal
    bdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    bdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    bdLayout.Padding = UDim.new(0, 16)

    local function makeBillingTab(txt, iconTxt, isActive, badgeNum)
        local btn = Instance.new("TextButton", bDock)
        btn.Size = isActive and UDim2.new(0, 76, 0, 38) or UDim2.new(0, 56, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(235, 238, 245) or Color3.fromRGB(255, 255, 255)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(140, 145, 160)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        if badgeNum then
            local b = Instance.new("Frame", btn)
            b.Size = UDim2.new(0, 14, 0, 14)
            b.Position = UDim2.new(1, -12, 0, -2)
            b.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
            b.BorderSizePixel = 0
            b.ZIndex = 27
            Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
            local bt = Instance.new("TextLabel", b)
            bt.Size = UDim2.new(1, 0, 1, 0)
            bt.Text = tostring(badgeNum)
            bt.Font = Enum.Font.GothamBold
            bt.TextSize = 8.5
            bt.TextColor3 = Color3.fromRGB(255, 255, 255)
            bt.BackgroundTransparency = 1
            bt.ZIndex = 28
        end
    end

    makeBillingTab("Overview", "🏠", true, nil)
    makeBillingTab("Inbox", "📥", false, 2)
    makeBillingTab("History", "🕒", false, nil)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Billing"] = function(isLight)
            billingApp.BackgroundColor3 = isLight and Color3.fromRGB(242, 244, 248) or Color3.fromRGB(0, 0, 0)
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(billingApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 10. CALENDAR APP (Matching official_calendar.png)
-- ============================================================================
local calendarApp = createBaseApp("Calendar", Color3.fromRGB(255, 255, 255))
do
    local cTopNav = Instance.new("Frame", calendarApp)
    cTopNav.Size = UDim2.new(1, 0, 0, 48)
    cTopNav.Position = UDim2.new(0, 0, 0, 36)
    cTopNav.BackgroundTransparency = 1
    cTopNav.ZIndex = 18

    local backYear = Instance.new("TextButton", cTopNav)
    backYear.Size = UDim2.new(0, 72, 0, 32)
    backYear.Position = UDim2.new(0, 16, 0.5, -16)
    backYear.BackgroundColor3 = Color3.fromRGB(244, 245, 248)
    backYear.Text = "‹ 2026"
    backYear.Font = Enum.Font.GothamBold
    backYear.TextSize = 13
    backYear.TextColor3 = Color3.fromRGB(25, 30, 40)
    backYear.BorderSizePixel = 0
    backYear.ZIndex = 19
    Instance.new("UICorner", backYear).CornerRadius = UDim.new(1, 0)

    local function makeTopCircleBtn(xPos, txt)
        local btn = Instance.new("TextButton", cTopNav)
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = UDim2.new(1, xPos, 0.5, -16)
        btn.BackgroundColor3 = Color3.fromRGB(244, 245, 248)
        btn.Text = txt
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(25, 30, 40)
        btn.BorderSizePixel = 0
        btn.ZIndex = 19
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makeTopCircleBtn(-120, "📅")
    makeTopCircleBtn(-78, "🔍")
    makeTopCircleBtn(-36, "+")

    local mTitle = Instance.new("TextLabel", calendarApp)
    mTitle.Size = UDim2.new(1, -36, 0, 36)
    mTitle.Position = UDim2.new(0, 18, 0, 88)
    mTitle.Text = "September"
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextSize = 32
    mTitle.TextColor3 = Color3.fromRGB(15, 18, 28)
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.BackgroundTransparency = 1
    mTitle.ZIndex = 18

    -- Weekday Headers: M T W T F S S
    local wHeader = Instance.new("Frame", calendarApp)
    wHeader.Size = UDim2.new(1, -24, 0, 20)
    wHeader.Position = UDim2.new(0, 12, 0, 130)
    wHeader.BackgroundTransparency = 1
    wHeader.ZIndex = 18
    local whLayout = Instance.new("UIGridLayout", wHeader)
    whLayout.CellSize = UDim2.new(0.14, 0, 1, 0)
    whLayout.CellPadding = UDim2.new(0.003, 0, 0, 0)
    whLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    for _, day in ipairs({"M", "T", "W", "T", "F", "S", "S"}) do
        local l = Instance.new("TextLabel", wHeader)
        l.Text = day
        l.Font = Enum.Font.GothamBold
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(140, 145, 160)
        l.BackgroundTransparency = 1
        l.ZIndex = 19
    end

    -- Month Days Grid with Day 21 Highlighted
    local mGrid = Instance.new("Frame", calendarApp)
    mGrid.Size = UDim2.new(1, -24, 0, 360)
    mGrid.Position = UDim2.new(0, 12, 0, 154)
    mGrid.BackgroundTransparency = 1
    mGrid.ZIndex = 18
    local mgLayout = Instance.new("UIGridLayout", mGrid)
    mgLayout.CellSize = UDim2.new(0.14, 0, 0, 68)
    mgLayout.CellPadding = UDim2.new(0.003, 0, 0, 2)
    mgLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    for i = 1, 35 do
        local cell = Instance.new("Frame", mGrid)
        cell.BackgroundTransparency = 1
        cell.ZIndex = 19

        local dNum = i - 0
        if dNum >= 1 and dNum <= 30 then
            local numLbl = Instance.new("TextLabel", cell)
            numLbl.Size = UDim2.new(1, 0, 0, 24)
            numLbl.Text = tostring(dNum)
            numLbl.Font = Enum.Font.GothamBold
            numLbl.TextSize = 14
            numLbl.TextColor3 = Color3.fromRGB(20, 25, 35)
            numLbl.BackgroundTransparency = 1
            numLbl.ZIndex = 20

            if dNum == 21 then
                local redCircle = Instance.new("Frame", cell)
                redCircle.Size = UDim2.new(0, 26, 0, 26)
                redCircle.Position = UDim2.new(0.5, -13, 0, -1)
                redCircle.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
                redCircle.BorderSizePixel = 0
                redCircle.ZIndex = 19
                Instance.new("UICorner", redCircle).CornerRadius = UDim.new(1, 0)
                numLbl.TextColor3 = Color3.fromRGB(255, 255, 255)

                local evTag = Instance.new("TextLabel", cell)
                evTag.Size = UDim2.new(1, 0, 0, 26)
                evTag.Position = UDim2.new(0, 0, 0, 26)
                evTag.Text = "Team bri...\nCityMar..."
                evTag.Font = Enum.Font.Gotham
                evTag.TextSize = 7.5
                evTag.TextColor3 = Color3.fromRGB(255, 59, 48)
                evTag.BackgroundTransparency = 1
                evTag.ZIndex = 20
            elseif dNum == 19 then
                local evTag = Instance.new("TextLabel", cell)
                evTag.Size = UDim2.new(1, 0, 0, 14)
                evTag.Position = UDim2.new(0, 0, 0, 26)
                evTag.Text = "Beach cr..."
                evTag.Font = Enum.Font.Gotham
                evTag.TextSize = 7.5
                evTag.TextColor3 = Color3.fromRGB(255, 59, 48)
                evTag.BackgroundTransparency = 1
                evTag.ZIndex = 20
            elseif dNum == 22 then
                local evTag = Instance.new("TextLabel", cell)
                evTag.Size = UDim2.new(1, 0, 0, 14)
                evTag.Position = UDim2.new(0, 0, 0, 26)
                evTag.Text = "Garage ..."
                evTag.Font = Enum.Font.Gotham
                evTag.TextSize = 7.5
                evTag.TextColor3 = Color3.fromRGB(255, 59, 48)
                evTag.BackgroundTransparency = 1
                evTag.ZIndex = 20
            end
        end
    end

    local todayBtn = Instance.new("TextButton", calendarApp)
    todayBtn.Size = UDim2.new(0, 76, 0, 36)
    todayBtn.Position = UDim2.new(0, 18, 1, -54)
    todayBtn.BackgroundColor3 = Color3.fromRGB(244, 245, 248)
    todayBtn.Text = "Today"
    todayBtn.Font = Enum.Font.GothamBold
    todayBtn.TextSize = 13
    todayBtn.TextColor3 = Color3.fromRGB(20, 25, 35)
    todayBtn.BorderSizePixel = 0
    todayBtn.ZIndex = 25
    Instance.new("UICorner", todayBtn).CornerRadius = UDim.new(1, 0)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Calendar"] = function(isLight)
            calendarApp.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
            if todayBtn then
                todayBtn.BackgroundColor3 = isLight and Color3.fromRGB(244, 245, 248) or Color3.fromRGB(44, 44, 46)
                todayBtn.TextColor3 = isLight and Color3.fromRGB(20, 25, 35) or Color3.fromRGB(255, 255, 255)
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(calendarApp, isLight)
            end
        end
    end
end

-- ============================================================================
-- 11. CLOCK APP (Matching official_clock.png: Stopwatch Engine + Tabs)
-- ============================================================================
local clockApp = createBaseApp("Clock", Color3.fromRGB(244, 245, 248))
do
    local cCity = Instance.new("TextLabel", clockApp)
    cCity.Size = UDim2.new(1, 0, 0, 24)
    cCity.Position = UDim2.new(0, 0, 0, 80)
    cCity.Text = "Los Santos"
    cCity.Font = Enum.Font.GothamMedium
    cCity.TextSize = 18
    cCity.TextColor3 = Color3.fromRGB(120, 125, 140)
    cCity.BackgroundTransparency = 1
    cCity.ZIndex = 18

    local cBigTime = Instance.new("TextLabel", clockApp)
    cBigTime.Size = UDim2.new(1, 0, 0, 72)
    cBigTime.Position = UDim2.new(0, 0, 0, 114)
    cBigTime.Text = "03:00"
    cBigTime.Font = Enum.Font.Gotham
    cBigTime.TextSize = 64
    cBigTime.TextColor3 = Color3.fromRGB(15, 18, 25)
    cBigTime.BackgroundTransparency = 1
    cBigTime.ZIndex = 18

    local cZone = Instance.new("TextLabel", clockApp)
    cZone.Size = UDim2.new(1, 0, 0, 18)
    cZone.Position = UDim2.new(0, 0, 0, 186)
    cZone.Text = "GMT+3"
    cZone.Font = Enum.Font.GothamMedium
    cZone.TextSize = 13
    cZone.TextColor3 = Color3.fromRGB(140, 145, 160)
    cZone.BackgroundTransparency = 1
    cZone.ZIndex = 18

    -- Precision Stopwatch Engine Frame
    local swContainer = Instance.new("Frame", clockApp)
    swContainer.Size = UDim2.new(1, -30, 0, 240)
    swContainer.Position = UDim2.new(0, 15, 0, 230)
    swContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    swContainer.BorderSizePixel = 0
    swContainer.ZIndex = 18
    Instance.new("UICorner", swContainer).CornerRadius = UDim.new(0, 20)
    local swStroke = Instance.new("UIStroke", swContainer)
    swStroke.Color = Color3.fromRGB(235, 238, 245)

    local swLabel = Instance.new("TextLabel", swContainer)
    swLabel.Size = UDim2.new(1, 0, 0, 20)
    swLabel.Position = UDim2.new(0, 0, 0, 14)
    swLabel.Text = "⏱ PRECISION STOPWATCH"
    swLabel.Font = Enum.Font.GothamBold
    swLabel.TextSize = 11
    swLabel.TextColor3 = Color3.fromRGB(140, 145, 165)
    swLabel.BackgroundTransparency = 1
    swLabel.ZIndex = 19

    local swDisplay = Instance.new("TextLabel", swContainer)
    swDisplay.Size = UDim2.new(1, 0, 0, 50)
    swDisplay.Position = UDim2.new(0, 0, 0, 42)
    swDisplay.Text = "00:00.0"
    swDisplay.Font = Enum.Font.GothamBold
    swDisplay.TextSize = 42
    swDisplay.TextColor3 = Color3.fromRGB(15, 18, 28)
    swDisplay.BackgroundTransparency = 1
    swDisplay.ZIndex = 19

    local swBtnRow = Instance.new("Frame", swContainer)
    swBtnRow.Size = UDim2.new(1, -30, 0, 48)
    swBtnRow.Position = UDim2.new(0, 15, 0, 110)
    swBtnRow.BackgroundTransparency = 1
    swBtnRow.ZIndex = 19
    local swbLayout = Instance.new("UIListLayout", swBtnRow)
    swbLayout.FillDirection = Enum.FillDirection.Horizontal
    swbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    swbLayout.Padding = UDim.new(0, 16)

    local swStartBtn = Instance.new("TextButton", swBtnRow)
    swStartBtn.Size = UDim2.new(0.44, 0, 1, 0)
    swStartBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
    swStartBtn.Text = "Start"
    swStartBtn.Font = Enum.Font.GothamBold
    swStartBtn.TextSize = 14
    swStartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    swStartBtn.BorderSizePixel = 0
    swStartBtn.ZIndex = 20
    Instance.new("UICorner", swStartBtn).CornerRadius = UDim.new(1, 0)

    local swResetBtn = Instance.new("TextButton", swBtnRow)
    swResetBtn.Size = UDim2.new(0.44, 0, 1, 0)
    swResetBtn.BackgroundColor3 = Color3.fromRGB(235, 238, 245)
    swResetBtn.Text = "Reset"
    swResetBtn.Font = Enum.Font.GothamBold
    swResetBtn.TextSize = 14
    swResetBtn.TextColor3 = Color3.fromRGB(100, 105, 120)
    swResetBtn.BorderSizePixel = 0
    swResetBtn.ZIndex = 20
    Instance.new("UICorner", swResetBtn).CornerRadius = UDim.new(1, 0)

    local swRunning = false
    local swElapsed = 0

    swStartBtn.MouseButton1Click:Connect(function()
        playTone()
        swRunning = not swRunning
        if swRunning then
            swStartBtn.Text = "Stop"
            swStartBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
            task.spawn(function()
                while swRunning do
                    task.wait(0.1)
                    swElapsed = swElapsed + 0.1
                    local mins = math.floor(swElapsed / 60)
                    local secs = math.floor(swElapsed % 60)
                    local tenths = math.floor((swElapsed * 10) % 10)
                    swDisplay.Text = string.format("%02d:%02d.%d", mins, secs, tenths)
                end
            end)
        else
            swStartBtn.Text = "Start"
            swStartBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        end
    end)

    swResetBtn.MouseButton1Click:Connect(function()
        playTone()
        swRunning = false
        swElapsed = 0
        swStartBtn.Text = "Start"
        swStartBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        swDisplay.Text = "00:00.0"
    end)

    -- Bottom Floating Dock
    local clkDock = Instance.new("Frame", clockApp)
    clkDock.Size = UDim2.new(1, -36, 0, 52)
    clkDock.Position = UDim2.new(0, 18, 1, -72)
    clkDock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    clkDock.BorderSizePixel = 0
    clkDock.ZIndex = 25
    Instance.new("UICorner", clkDock).CornerRadius = UDim.new(1, 0)
    local cdStroke = Instance.new("UIStroke", clkDock)
    cdStroke.Color = Color3.fromRGB(225, 228, 238)

    local cdLayout = Instance.new("UIListLayout", clkDock)
    cdLayout.FillDirection = Enum.FillDirection.Horizontal
    cdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cdLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    cdLayout.Padding = UDim.new(0, 14)

    local function makeClockTab(txt, iconTxt, isActive)
        local btn = Instance.new("TextButton", clkDock)
        btn.Size = isActive and UDim2.new(0, 68, 0, 38) or UDim2.new(0, 52, 0, 38)
        btn.BackgroundColor3 = isActive and Color3.fromRGB(255, 244, 230) or Color3.fromRGB(255, 255, 255)
        btn.Text = iconTxt .. "\n" .. txt
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9.5
        btn.TextColor3 = isActive and Color3.fromRGB(255, 149, 0) or Color3.fromRGB(120, 125, 140)
        btn.BorderSizePixel = 0
        btn.ZIndex = 26
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    end
    makeClockTab("Clock", "🌐", true)
    makeClockTab("Alarm", "⏰", false)
    makeClockTab("Stopwatch", "⏱", false)
    makeClockTab("Timer", "⏲", false)

    if _G.SkyPhone_AppThemeUpdaters then
        _G.SkyPhone_AppThemeUpdaters["Clock"] = function(isLight)
            clockApp.BackgroundColor3 = isLight and Color3.fromRGB(244, 245, 248) or Color3.fromRGB(0, 0, 0)
            if cBigTime then
                cBigTime.TextColor3 = isLight and Color3.fromRGB(15, 18, 25) or Color3.fromRGB(255, 255, 255)
            end
            if cCity then
                cCity.TextColor3 = isLight and Color3.fromRGB(120, 125, 140) or Color3.fromRGB(160, 165, 180)
            end
            if swContainer then
                swContainer.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(28, 28, 30)
            end
            if swStroke then
                swStroke.Color = isLight and Color3.fromRGB(235, 238, 245) or Color3.fromRGB(44, 44, 46)
            end
            if swDisplay then
                swDisplay.TextColor3 = isLight and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(255, 255, 255)
            end
            if swResetBtn then
                swResetBtn.BackgroundColor3 = isLight and Color3.fromRGB(235, 238, 245) or Color3.fromRGB(44, 44, 46)
                swResetBtn.TextColor3 = isLight and Color3.fromRGB(100, 105, 120) or Color3.fromRGB(200, 205, 215)
            end
            if clkDock then
                clkDock.BackgroundColor3 = isLight and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(24, 24, 26)
                if cdStroke then cdStroke.Color = isLight and Color3.fromRGB(225, 228, 238) or Color3.fromRGB(44, 44, 46) end
            end
            if _G.SkyPhone_ApplyGenericAppTheme then
                _G.SkyPhone_ApplyGenericAppTheme(clockApp, isLight)
            end
        end
    end
end

return { name = "CalcBankingSuite" }
