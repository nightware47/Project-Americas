--!strict
-- src/sky_phone/AppSuite_Finance_Gaming.luau
-- Pure Luau Component: Banking, VaultX, Music, Garage & Arcade Snake
-- Ground-truth port matching NVIDIA ShadowPlay video evaluation (03:47 - 03:55)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local AppSuite_Finance_Gaming = {}

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

function AppSuite_Finance_Gaming.build(appContainer: Frame, ctx: any)
    local showNotification = ctx and ctx.showNotification or function(title: string, msg: string) end
    local showBanner = ctx and ctx.showBanner or function(title: string, msg: string, icon: string?, t: string?) end
    local updateMusicWidget = ctx and ctx.updateMusicWidget or function(track: any) end
    local BottomSheet = ctx and ctx.BottomSheet

    -- =========================================================================
    -- 1. BANKING APP (Dark Obsidian Palette #0E101C + Inset Grouped Cards)
    -- Video Ground Truth (05:26 - 06:08): $24,787 balance, Account #42, Send Money Sheet
    -- =========================================================================
    local bankApp = createBaseApp(appContainer, "Banking", Color3.fromRGB(14, 16, 28))
    do
        local bScroll = Instance.new("ScrollingFrame", bankApp)
        bScroll.Size = UDim2.new(1, 0, 1, 0)
        bScroll.BackgroundTransparency = 1
        bScroll.ScrollBarThickness = 0
        bScroll.ZIndex = 17
        bScroll.CanvasSize = UDim2.new(0, 0, 0, 680)

        -- Top Header: Alex Morgan & Account #42
        local bHeader = Instance.new("Frame", bScroll)
        bHeader.Size = UDim2.new(1, 0, 0, 64)
        bHeader.Position = UDim2.new(0, 0, 0, 36)
        bHeader.BackgroundTransparency = 1
        bHeader.ZIndex = 18

        local bUser = Instance.new("TextLabel", bHeader)
        bUser.Size = UDim2.new(0.7, 0, 0, 22)
        bUser.Position = UDim2.new(0, 20, 0, 8)
        bUser.Text = "Alex Morgan"
        bUser.Font = Enum.Font.GothamBold
        bUser.TextSize = 19
        bUser.TextColor3 = Color3.fromRGB(255, 255, 255)
        bUser.TextXAlignment = Enum.TextXAlignment.Left
        bUser.BackgroundTransparency = 1
        bUser.ZIndex = 19

        local bWelcome = Instance.new("TextLabel", bHeader)
        bWelcome.Size = UDim2.new(0.7, 0, 0, 16)
        bWelcome.Position = UDim2.new(0, 20, 0, 30)
        bWelcome.Text = "Maze Bank Premium · Account #42"
        bWelcome.Font = Enum.Font.Gotham
        bWelcome.TextSize = 12
        bWelcome.TextColor3 = Color3.fromRGB(142, 142, 147)
        bWelcome.TextXAlignment = Enum.TextXAlignment.Left
        bWelcome.BackgroundTransparency = 1
        bWelcome.ZIndex = 19

        -- Notification bell icon in top right
        local bellBtn = Instance.new("TextButton", bHeader)
        bellBtn.Size = UDim2.new(0, 36, 0, 36)
        bellBtn.Position = UDim2.new(1, -56, 0, 8)
        bellBtn.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
        bellBtn.Text = "🔔"
        bellBtn.TextSize = 16
        bellBtn.BorderSizePixel = 0
        bellBtn.ZIndex = 19
        Instance.new("UICorner", bellBtn).CornerRadius = UDim.new(1, 0)
        local bellStroke = Instance.new("UIStroke", bellBtn)
        bellStroke.Color = Color3.fromRGB(255, 255, 255)
        bellStroke.Transparency = 0.9

        bellBtn.MouseButton1Click:Connect(function()
            playTone(2.0)
            showBanner("Banking", "No unread financial alerts.", "rbxassetid://113219823990413", "03:50")
        end)

        -- Hero Balance Card ($24,787 matching video at 05:26)
        local currentBalance = 24787
        local heroCard = Instance.new("Frame", bScroll)
        heroCard.Size = UDim2.new(1, -36, 0, 140)
        heroCard.Position = UDim2.new(0, 18, 0, 106)
        heroCard.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
        heroCard.BorderSizePixel = 0
        heroCard.ZIndex = 18
        Instance.new("UICorner", heroCard).CornerRadius = UDim.new(0, 20)
        local hs = Instance.new("UIStroke", heroCard)
        hs.Color = Color3.fromRGB(255, 255, 255)
        hs.Transparency = 0.92
        hs.Thickness = 1.0

        local cardGrad = Instance.new("UIGradient", heroCard)
        cardGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(26, 30, 44)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(18, 20, 28)),
        })
        cardGrad.Rotation = 45

        local hbLabel = Instance.new("TextLabel", heroCard)
        hbLabel.Size = UDim2.new(0.6, 0, 0, 18)
        hbLabel.Position = UDim2.new(0, 20, 0, 18)
        hbLabel.Text = "TOTAL BALANCE"
        hbLabel.Font = Enum.Font.GothamBold
        hbLabel.TextSize = 11
        hbLabel.TextColor3 = Color3.fromRGB(142, 142, 147)
        hbLabel.TextXAlignment = Enum.TextXAlignment.Left
        hbLabel.BackgroundTransparency = 1
        hbLabel.ZIndex = 19

        local hbAmount = Instance.new("TextLabel", heroCard)
        hbAmount.Size = UDim2.new(1, -40, 0, 42)
        hbAmount.Position = UDim2.new(0, 20, 0, 38)
        hbAmount.Text = "$24,787.00"
        hbAmount.Font = Enum.Font.GothamBold
        hbAmount.TextSize = 34
        hbAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
        hbAmount.TextXAlignment = Enum.TextXAlignment.Left
        hbAmount.BackgroundTransparency = 1
        hbAmount.ZIndex = 19

        local hbAcct = Instance.new("TextLabel", heroCard)
        hbAcct.Size = UDim2.new(1, -40, 0, 18)
        hbAcct.Position = UDim2.new(0, 20, 0, 96)
        hbAcct.Text = "Checking Account  •••• 0042  ·  Active"
        hbAcct.Font = Enum.Font.Gotham
        hbAcct.TextSize = 12
        hbAcct.TextColor3 = Color3.fromRGB(100, 210, 120)
        hbAcct.TextXAlignment = Enum.TextXAlignment.Left
        hbAcct.BackgroundTransparency = 1
        hbAcct.ZIndex = 19

        local function updateBalanceDisplay()
            hbAmount.Text = string.format("$%'d.00", currentBalance)
        end

        -- Action Buttons Bar (Send Money, Request, Cards)
        local actionRow = Instance.new("Frame", bScroll)
        actionRow.Size = UDim2.new(1, -36, 0, 64)
        actionRow.Position = UDim2.new(0, 18, 0, 258)
        actionRow.BackgroundTransparency = 1
        actionRow.ZIndex = 18

        -- Transactions Container
        local txSection = Instance.new("Frame", bScroll)
        txSection.Size = UDim2.new(1, -36, 0, 300)
        txSection.Position = UDim2.new(0, 18, 0, 334)
        txSection.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
        txSection.BorderSizePixel = 0
        txSection.ZIndex = 18
        Instance.new("UICorner", txSection).CornerRadius = UDim.new(0, 18)
        local ts = Instance.new("UIStroke", txSection)
        ts.Color = Color3.fromRGB(255, 255, 255)
        ts.Transparency = 0.92

        local txTitle = Instance.new("TextLabel", txSection)
        txTitle.Size = UDim2.new(1, -30, 0, 36)
        txTitle.Position = UDim2.new(0, 16, 0, 10)
        txTitle.Text = "Recent Transactions"
        txTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        txTitle.Font = Enum.Font.GothamBold
        txTitle.TextSize = 15
        txTitle.TextXAlignment = Enum.TextXAlignment.Left
        txTitle.BackgroundTransparency = 1
        txTitle.ZIndex = 19

        local txList = Instance.new("ScrollingFrame", txSection)
        txList.Size = UDim2.new(1, -16, 1, -54)
        txList.Position = UDim2.new(0, 8, 0, 48)
        txList.BackgroundTransparency = 1
        txList.ScrollBarThickness = 0
        txList.ZIndex = 19
        local tlLayout = Instance.new("UIListLayout", txList)
        tlLayout.Padding = UDim.new(0, 6)

        local function addTransactionRow(name: string, subtitle: string, amountStr: string, isIncome: boolean)
            local row = Instance.new("Frame", txList)
            row.Size = UDim2.new(1, 0, 0, 50)
            row.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
            row.BorderSizePixel = 0
            row.ZIndex = 20
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

            local iconCircle = Instance.new("Frame", row)
            iconCircle.Size = UDim2.new(0, 36, 0, 36)
            iconCircle.Position = UDim2.new(0, 8, 0, 7)
            iconCircle.BackgroundColor3 = isIncome and Color3.fromRGB(20, 45, 30) or Color3.fromRGB(45, 20, 25)
            iconCircle.BorderSizePixel = 0
            iconCircle.ZIndex = 21
            Instance.new("UICorner", iconCircle).CornerRadius = UDim.new(1, 0)

            local icn = Instance.new("TextLabel", iconCircle)
            icn.Size = UDim2.new(1, 0, 1, 0)
            icn.Text = isIncome and "↓" or "↑"
            icn.TextColor3 = isIncome and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 69, 58)
            icn.Font = Enum.Font.GothamBold
            icn.TextSize = 16
            icn.BackgroundTransparency = 1
            icn.ZIndex = 22

            local tName = Instance.new("TextLabel", row)
            tName.Size = UDim2.new(0.5, 0, 0, 18)
            tName.Position = UDim2.new(0, 52, 0, 7)
            tName.Text = name
            tName.TextColor3 = Color3.fromRGB(255, 255, 255)
            tName.Font = Enum.Font.GothamMedium
            tName.TextSize = 13.5
            tName.TextXAlignment = Enum.TextXAlignment.Left
            tName.BackgroundTransparency = 1
            tName.ZIndex = 21

            local tSub = Instance.new("TextLabel", row)
            tSub.Size = UDim2.new(0.5, 0, 0, 14)
            tSub.Position = UDim2.new(0, 52, 0, 27)
            tSub.Text = subtitle
            tSub.TextColor3 = Color3.fromRGB(142, 142, 147)
            tSub.Font = Enum.Font.Gotham
            tSub.TextSize = 11
            tSub.TextXAlignment = Enum.TextXAlignment.Left
            tSub.BackgroundTransparency = 1
            tSub.ZIndex = 21

            local tAmt = Instance.new("TextLabel", row)
            tAmt.Size = UDim2.new(0.4, -12, 1, 0)
            tAmt.Position = UDim2.new(0.6, 0, 0, 0)
            tAmt.Text = amountStr
            tAmt.TextColor3 = isIncome and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(255, 255, 255)
            tAmt.Font = Enum.Font.GothamBold
            tAmt.TextSize = 14
            tAmt.TextXAlignment = Enum.TextXAlignment.Right
            tAmt.BackgroundTransparency = 1
            tAmt.ZIndex = 21
        end

        addTransactionRow("Diamond Casino & Resort", "Jackpot Payout", "+$5,000.00", true)
        addTransactionRow("Benny's Motor Works", "Vehicle Repair (Disputed)", "−$999.00", false)
        addTransactionRow("Dynasty 8 Realty", "Apartment Lease", "−$2,500.00", false)
        addTransactionRow("Los Santos Customs", "Performance Parts", "−$450.00", false)

        -- Open Send Money Bottom Sheet Modal (Video 05:26 - 06:08)
        local function openSendMoneySheet()
            playTone(2.0)
            if not BottomSheet then
                showBanner("Banking", "Sheet service unavailable.", "", "03:52")
                return
            end

            local sheet = BottomSheet.create(bankApp, {
                height = 380,
                showHandle = true,
            })
            local parent = sheet.contentFrame

            local sTitle = Instance.new("TextLabel", parent)
            sTitle.Size = UDim2.new(1, -40, 0, 26)
            sTitle.Position = UDim2.new(0, 20, 0, 6)
            sTitle.Text = "Send Money"
            sTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sTitle.Font = Enum.Font.GothamBold
            sTitle.TextSize = 20
            sTitle.TextXAlignment = Enum.TextXAlignment.Left
            sTitle.BackgroundTransparency = 1
            sTitle.ZIndex = 84

            local sSub = Instance.new("TextLabel", parent)
            sSub.Size = UDim2.new(1, -40, 0, 16)
            sSub.Position = UDim2.new(0, 20, 0, 32)
            sSub.Text = "Instant peer-to-peer wire transfer"
            sSub.TextColor3 = Color3.fromRGB(142, 142, 147)
            sSub.Font = Enum.Font.Gotham
            sSub.TextSize = 12
            sSub.TextXAlignment = Enum.TextXAlignment.Left
            sSub.BackgroundTransparency = 1
            sSub.ZIndex = 84

            -- Contact Quick Chips
            local chipScroll = Instance.new("ScrollingFrame", parent)
            chipScroll.Size = UDim2.new(1, -30, 0, 56)
            chipScroll.Position = UDim2.new(0, 15, 0, 56)
            chipScroll.BackgroundTransparency = 1
            chipScroll.ScrollBarThickness = 0
            chipScroll.ZIndex = 84
            local cLayout = Instance.new("UIListLayout", chipScroll)
            cLayout.FillDirection = Enum.FillDirection.Horizontal
            cLayout.Padding = UDim.new(0, 8)

            local recipientBox = Instance.new("TextBox", parent)
            recipientBox.Size = UDim2.new(1, -40, 0, 42)
            recipientBox.Position = UDim2.new(0, 20, 0, 122)
            recipientBox.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
            recipientBox.Text = ""
            recipientBox.PlaceholderText = "Recipient phone # or username"
            recipientBox.PlaceholderColor3 = Color3.fromRGB(140, 145, 160)
            recipientBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            recipientBox.Font = Enum.Font.GothamMedium
            recipientBox.TextSize = 13.5
            recipientBox.BorderSizePixel = 0
            recipientBox.ZIndex = 84
            Instance.new("UICorner", recipientBox).CornerRadius = UDim.new(0, 12)
            local rPadding = Instance.new("UIPadding", recipientBox)
            rPadding.PaddingLeft = UDim.new(0, 14)

            local contacts = {
                {name = "Alex Rivera", phone = "555-0192"},
                {name = "Emily Hart", phone = "555-0481"},
                {name = "Vincent Cole", phone = "555-0612"},
                {name = "Samantha Cole", phone = "555-0144"},
            }

            for _, c in ipairs(contacts) do
                local chip = Instance.new("TextButton", chipScroll)
                chip.Size = UDim2.new(0, 110, 0, 42)
                chip.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
                chip.Text = ""
                chip.BorderSizePixel = 0
                chip.ZIndex = 85
                Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 21)
                local cs = Instance.new("UIStroke", chip)
                cs.Color = Color3.fromRGB(255, 255, 255)
                cs.Transparency = 0.9

                local av = Instance.new("Frame", chip)
                av.Size = UDim2.new(0, 30, 0, 30)
                av.Position = UDim2.new(0, 6, 0.5, -15)
                av.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
                av.BorderSizePixel = 0
                av.ZIndex = 86
                Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

                local avTxt = Instance.new("TextLabel", av)
                avTxt.Size = UDim2.new(1, 0, 1, 0)
                avTxt.Text = string.sub(c.name, 1, 1)
                avTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
                avTxt.Font = Enum.Font.GothamBold
                avTxt.TextSize = 13
                avTxt.BackgroundTransparency = 1
                avTxt.ZIndex = 87

                local cLbl = Instance.new("TextLabel", chip)
                cLbl.Size = UDim2.new(1, -44, 1, 0)
                cLbl.Position = UDim2.new(0, 40, 0, 0)
                cLbl.Text = string.split(c.name, " ")[1]
                cLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                cLbl.Font = Enum.Font.GothamMedium
                cLbl.TextSize = 12
                cLbl.TextXAlignment = Enum.TextXAlignment.Left
                cLbl.BackgroundTransparency = 1
                cLbl.ZIndex = 86

                chip.MouseButton1Click:Connect(function()
                    playTone(2.2)
                    recipientBox.Text = c.name .. " (" .. c.phone .. ")"
                end)
            end

            -- Amount Box
            local amountBox = Instance.new("TextBox", parent)
            amountBox.Size = UDim2.new(1, -40, 0, 48)
            amountBox.Position = UDim2.new(0, 20, 0, 174)
            amountBox.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
            amountBox.Text = ""
            amountBox.PlaceholderText = "Amount ($)"
            amountBox.PlaceholderColor3 = Color3.fromRGB(140, 145, 160)
            amountBox.TextColor3 = Color3.fromRGB(52, 199, 89)
            amountBox.Font = Enum.Font.GothamBold
            amountBox.TextSize = 18
            amountBox.BorderSizePixel = 0
            amountBox.ZIndex = 84
            Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 12)
            local aPadding = Instance.new("UIPadding", amountBox)
            aPadding.PaddingLeft = UDim.new(0, 14)

            -- Quick Amount Chips ($50, $100, $500, Max)
            local amtRow = Instance.new("Frame", parent)
            amtRow.Size = UDim2.new(1, -40, 0, 30)
            amtRow.Position = UDim2.new(0, 20, 0, 230)
            amtRow.BackgroundTransparency = 1
            amtRow.ZIndex = 84

            local quickAmounts = {50, 100, 500, 1000}
            for i, val in ipairs(quickAmounts) do
                local qb = Instance.new("TextButton", amtRow)
                qb.Size = UDim2.new(0.23, 0, 1, 0)
                qb.Position = UDim2.new((i - 1) * 0.256, 0, 0, 0)
                qb.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
                qb.Text = "+$" .. tostring(val)
                qb.TextColor3 = Color3.fromRGB(255, 255, 255)
                qb.Font = Enum.Font.GothamMedium
                qb.TextSize = 12
                qb.BorderSizePixel = 0
                qb.ZIndex = 85
                Instance.new("UICorner", qb).CornerRadius = UDim.new(0, 8)
                qb.MouseButton1Click:Connect(function()
                    playTone(2.0)
                    local current = tonumber(amountBox.Text) or 0
                    amountBox.Text = tostring(current + val)
                end)
            end

            -- Confirm Send Button
            local sendBtn = Instance.new("TextButton", parent)
            sendBtn.Size = UDim2.new(1, -40, 0, 46)
            sendBtn.Position = UDim2.new(0, 20, 0, 276)
            sendBtn.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
            sendBtn.Text = "Transfer Funds"
            sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            sendBtn.Font = Enum.Font.GothamBold
            sendBtn.TextSize = 15
            sendBtn.BorderSizePixel = 0
            sendBtn.ZIndex = 85
            Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 14)

            sendBtn.MouseButton1Click:Connect(function()
                local amt = tonumber(amountBox.Text)
                local rec = recipientBox.Text
                if not amt or amt <= 0 then
                    amountBox.Text = ""
                    amountBox.PlaceholderText = "Enter valid amount!"
                    return
                end
                if amt > currentBalance then
                    amountBox.Text = ""
                    amountBox.PlaceholderText = "Insufficient balance!"
                    return
                end
                if #rec == 0 then rec = "Vincent Cole" end

                currentBalance -= amt
                updateBalanceDisplay()
                addTransactionRow(rec, "Instant Transfer", string.format("−$%'d.00", amt), false)
                sheet.close()
                playTone(2.5)
                showBanner("Banking", string.format("Sent $%'d.00 to %s", amt, rec), "rbxassetid://113219823990413", "03:52")
            end)
        end

        local function makeBankAction(parent: Instance, label: string, icon: string, xPos: number, callback: () -> ())
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(0.31, 0, 1, 0)
            b.Position = UDim2.new(xPos, 0, 0, 0)
            b.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
            b.Text = ""
            b.BorderSizePixel = 0
            b.ZIndex = 19
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 14)
            local bs = Instance.new("UIStroke", b)
            bs.Color = Color3.fromRGB(255, 255, 255)
            bs.Transparency = 0.92

            local icn = Instance.new("TextLabel", b)
            icn.Size = UDim2.new(1, 0, 0, 24)
            icn.Position = UDim2.new(0, 0, 0, 10)
            icn.Text = icon
            icn.TextSize = 20
            icn.BackgroundTransparency = 1
            icn.ZIndex = 20

            local lbl = Instance.new("TextLabel", b)
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.Position = UDim2.new(0, 0, 0, 36)
            lbl.Text = label
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 11
            lbl.BackgroundTransparency = 1
            lbl.ZIndex = 20

            b.MouseButton1Click:Connect(callback)
            return b
        end

        makeBankAction(actionRow, "Send Money", "💸", 0.0, openSendMoneySheet)
        makeBankAction(actionRow, "Request", "📥", 0.345, function()
            playTone(1.8)
            showBanner("Banking", "Payment link copied: pay.mazebank.com/alex42", "rbxassetid://113219823990413", "03:52")
        end)
        makeBankAction(actionRow, "Cards", "💳", 0.69, function()
            playTone(1.8)
            showBanner("Cards", "Maze Bank Virtual Debit Card: Active", "rbxassetid://113219823990413", "03:52")
        end)
    end

    -- =========================================================================
    -- 2. VAULTX CRYPTO APP (Aurora AUR $128.50, Timeframe Switching, Stats)
    -- Video Ground Truth (06:49 - 07:28): Aurora token, 1D..1Y pills, Buy/Sell
    -- =========================================================================
    local vaultApp = createBaseApp(appContainer, "VaultX", Color3.fromRGB(10, 12, 18))
    do
        local vScroll = Instance.new("ScrollingFrame", vaultApp)
        vScroll.Size = UDim2.new(1, 0, 1, 0)
        vScroll.BackgroundTransparency = 1
        vScroll.ScrollBarThickness = 0
        vScroll.ZIndex = 17
        vScroll.CanvasSize = UDim2.new(0, 0, 0, 680)

        local vHeader = Instance.new("Frame", vScroll)
        vHeader.Size = UDim2.new(1, 0, 0, 64)
        vHeader.Position = UDim2.new(0, 0, 0, 36)
        vHeader.BackgroundTransparency = 1
        vHeader.ZIndex = 18

        local vTitle = Instance.new("TextLabel", vHeader)
        vTitle.Size = UDim2.new(0.6, 0, 0, 32)
        vTitle.Position = UDim2.new(0, 20, 0, 16)
        vTitle.Text = "VaultX"
        vTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        vTitle.Font = Enum.Font.GothamBold
        vTitle.TextSize = 28
        vTitle.TextXAlignment = Enum.TextXAlignment.Left
        vTitle.BackgroundTransparency = 1
        vTitle.ZIndex = 19

        -- Token Focus: Aurora (AUR)
        local tokenCard = Instance.new("Frame", vScroll)
        tokenCard.Size = UDim2.new(1, -36, 0, 180)
        tokenCard.Position = UDim2.new(0, 18, 0, 102)
        tokenCard.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
        tokenCard.BorderSizePixel = 0
        tokenCard.ZIndex = 18
        Instance.new("UICorner", tokenCard).CornerRadius = UDim.new(0, 20)
        local ts = Instance.new("UIStroke", tokenCard)
        ts.Color = Color3.fromRGB(255, 255, 255)
        ts.Transparency = 0.92

        local tokenIcon = Instance.new("Frame", tokenCard)
        tokenIcon.Size = UDim2.new(0, 38, 0, 38)
        tokenIcon.Position = UDim2.new(0, 16, 0, 16)
        tokenIcon.BackgroundColor3 = Color3.fromRGB(175, 82, 222)
        tokenIcon.BorderSizePixel = 0
        tokenIcon.ZIndex = 19
        Instance.new("UICorner", tokenIcon).CornerRadius = UDim.new(1, 0)

        local tGrad = Instance.new("UIGradient", tokenIcon)
        tGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(190, 90, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(100, 60, 240)),
        })

        local tGlyph = Instance.new("TextLabel", tokenIcon)
        tGlyph.Size = UDim2.new(1, 0, 1, 0)
        tGlyph.Text = "✦"
        tGlyph.TextColor3 = Color3.fromRGB(255, 255, 255)
        tGlyph.Font = Enum.Font.GothamBold
        tGlyph.TextSize = 18
        tGlyph.BackgroundTransparency = 1
        tGlyph.ZIndex = 20

        local tName = Instance.new("TextLabel", tokenCard)
        tName.Size = UDim2.new(0.5, 0, 0, 20)
        tName.Position = UDim2.new(0, 62, 0, 16)
        tName.Text = "Aurora"
        tName.TextColor3 = Color3.fromRGB(255, 255, 255)
        tName.Font = Enum.Font.GothamBold
        tName.TextSize = 16
        tName.TextXAlignment = Enum.TextXAlignment.Left
        tName.BackgroundTransparency = 1
        tName.ZIndex = 19

        local tTicker = Instance.new("TextLabel", tokenCard)
        tTicker.Size = UDim2.new(0.5, 0, 0, 16)
        tTicker.Position = UDim2.new(0, 62, 0, 36)
        tTicker.Text = "AUR · Layer 1 Ecosystem"
        tTicker.TextColor3 = Color3.fromRGB(142, 142, 147)
        tTicker.Font = Enum.Font.Gotham
        tTicker.TextSize = 11.5
        tTicker.TextXAlignment = Enum.TextXAlignment.Left
        tTicker.BackgroundTransparency = 1
        tTicker.ZIndex = 19

        local tPrice = Instance.new("TextLabel", tokenCard)
        tPrice.Size = UDim2.new(1, -32, 0, 34)
        tPrice.Position = UDim2.new(0, 16, 0, 64)
        tPrice.Text = "$128.50"
        tPrice.TextColor3 = Color3.fromRGB(255, 255, 255)
        tPrice.Font = Enum.Font.GothamBold
        tPrice.TextSize = 28
        tPrice.TextXAlignment = Enum.TextXAlignment.Left
        tPrice.BackgroundTransparency = 1
        tPrice.ZIndex = 19

        local tChange = Instance.new("TextLabel", tokenCard)
        tChange.Size = UDim2.new(1, -32, 0, 18)
        tChange.Position = UDim2.new(0, 16, 0, 98)
        tChange.Text = "+$5.92 (+4.82%) Today"
        tChange.TextColor3 = Color3.fromRGB(52, 199, 89)
        tChange.Font = Enum.Font.GothamBold
        tChange.TextSize = 13
        tChange.TextXAlignment = Enum.TextXAlignment.Left
        tChange.BackgroundTransparency = 1
        tChange.ZIndex = 19

        -- Timeframe Selector Pills: 1D, 1W, 1M, 6M, 1Y (Video 06:55)
        local tfRow = Instance.new("Frame", tokenCard)
        tfRow.Size = UDim2.new(1, -32, 0, 32)
        tfRow.Position = UDim2.new(0, 16, 0, 132)
        tfRow.BackgroundColor3 = Color3.fromRGB(26, 28, 40)
        tfRow.BorderSizePixel = 0
        tfRow.ZIndex = 19
        Instance.new("UICorner", tfRow).CornerRadius = UDim.new(0, 10)

        local timeframes = {"1D", "1W", "1M", "6M", "1Y"}
        local activeTfBtn: TextButton? = nil

        -- Chart Visual Container
        local chartFrame = Instance.new("Frame", vScroll)
        chartFrame.Size = UDim2.new(1, -36, 0, 120)
        chartFrame.Position = UDim2.new(0, 18, 0, 292)
        chartFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
        chartFrame.BorderSizePixel = 0
        chartFrame.ZIndex = 18
        Instance.new("UICorner", chartFrame).CornerRadius = UDim.new(0, 16)
        local cs = Instance.new("UIStroke", chartFrame)
        cs.Color = Color3.fromRGB(255, 255, 255)
        cs.Transparency = 0.94

        -- Vector Candlestick/Line Simulator
        local chartBars = {}
        local numBars = 16
        local chartHeights = {
            ["1D"] = {40, 48, 45, 52, 60, 58, 68, 72, 70, 78, 85, 82, 90, 94, 98, 100},
            ["1W"] = {60, 55, 58, 64, 62, 70, 68, 75, 80, 78, 86, 88, 92, 89, 95, 105},
            ["1M"] = {30, 35, 42, 48, 55, 50, 62, 68, 74, 78, 82, 88, 95, 92, 102, 110},
            ["6M"] = {20, 28, 36, 45, 40, 58, 65, 72, 80, 85, 90, 88, 98, 104, 112, 118},
            ["1Y"] = {15, 22, 30, 40, 48, 56, 68, 75, 84, 92, 96, 102, 108, 114, 120, 128},
        }

        local function renderChart(tf: string)
            for _, b in ipairs(chartBars) do b:Destroy() end
            chartBars = {}

            local heights = chartHeights[tf] or chartHeights["1D"]
            local barWidth = (chartFrame.AbsoluteSize.X > 0 and chartFrame.AbsoluteSize.X or 290) / numBars

            for i = 1, numBars do
                local h = heights[i] or 50
                local bar = Instance.new("Frame", chartFrame)
                bar.Size = UDim2.new(0, math.max(6, barWidth - 6), 0, h)
                bar.Position = UDim2.new((i - 1) / numBars, 4, 1, -h - 8)
                bar.BackgroundColor3 = Color3.fromRGB(175, 82, 222)
                bar.BackgroundTransparency = 0.25
                bar.BorderSizePixel = 0
                bar.ZIndex = 19
                Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

                local bg = Instance.new("UIGradient", bar)
                bg.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(190, 90, 255)),
                    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(52, 199, 89)),
                })
                bg.Rotation = 90
                table.insert(chartBars, bar)
            end
        end

        for i, tf in ipairs(timeframes) do
            local tfBtn = Instance.new("TextButton", tfRow)
            tfBtn.Size = UDim2.new(0.2, 0, 1, 0)
            tfBtn.Position = UDim2.new((i - 1) * 0.2, 0, 0, 0)
            tfBtn.BackgroundTransparency = (i == 1) and 0 or 1
            tfBtn.BackgroundColor3 = Color3.fromRGB(175, 82, 222)
            tfBtn.Text = tf
            tfBtn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 165, 180)
            tfBtn.Font = Enum.Font.GothamBold
            tfBtn.TextSize = 11.5
            tfBtn.BorderSizePixel = 0
            tfBtn.ZIndex = 20
            Instance.new("UICorner", tfBtn).CornerRadius = UDim.new(0, 8)

            if i == 1 then activeTfBtn = tfBtn end

            tfBtn.MouseButton1Click:Connect(function()
                playTone(2.2)
                if activeTfBtn then
                    activeTfBtn.BackgroundTransparency = 1
                    activeTfBtn.TextColor3 = Color3.fromRGB(160, 165, 180)
                end
                activeTfBtn = tfBtn
                tfBtn.BackgroundTransparency = 0
                tfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                renderChart(tf)
            end)
        end

        task.defer(function() renderChart("1D") end)

        -- Market Stats 2x2 Grid (Video 07:15)
        local statsGrid = Instance.new("Frame", vScroll)
        statsGrid.Size = UDim2.new(1, -36, 0, 110)
        statsGrid.Position = UDim2.new(0, 18, 0, 422)
        statsGrid.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
        statsGrid.BorderSizePixel = 0
        statsGrid.ZIndex = 18
        Instance.new("UICorner", statsGrid).CornerRadius = UDim.new(0, 18)
        local sStroke = Instance.new("UIStroke", statsGrid)
        sStroke.Color = Color3.fromRGB(255, 255, 255)
        sStroke.Transparency = 0.94

        local function makeStatCell(x: number, y: number, label: string, val: string)
            local cell = Instance.new("Frame", statsGrid)
            cell.Size = UDim2.new(0.5, 0, 0.5, 0)
            cell.Position = UDim2.new(x * 0.5, 0, y * 0.5, 0)
            cell.BackgroundTransparency = 1
            cell.ZIndex = 19

            local l = Instance.new("TextLabel", cell)
            l.Size = UDim2.new(1, -20, 0, 14)
            l.Position = UDim2.new(0, 14, 0, 10)
            l.Text = label
            l.TextColor3 = Color3.fromRGB(142, 142, 147)
            l.Font = Enum.Font.Gotham
            l.TextSize = 11
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.BackgroundTransparency = 1
            l.ZIndex = 20

            local v = Instance.new("TextLabel", cell)
            v.Size = UDim2.new(1, -20, 0, 18)
            v.Position = UDim2.new(0, 14, 0, 26)
            v.Text = val
            v.TextColor3 = Color3.fromRGB(255, 255, 255)
            v.Font = Enum.Font.GothamBold
            v.TextSize = 13.5
            v.TextXAlignment = Enum.TextXAlignment.Left
            v.BackgroundTransparency = 1
            v.ZIndex = 20
        end

        makeStatCell(0, 0, "Market Cap", "$1.84 Billion")
        makeStatCell(1, 0, "24h Volume", "$42.6 Million")
        makeStatCell(0, 1, "All-Time High", "$240.10")
        makeStatCell(1, 1, "Circulating Supply", "14.3M AUR")

        -- Buy & Sell Action Buttons
        local buyBtn = Instance.new("TextButton", vScroll)
        buyBtn.Size = UDim2.new(0.46, 0, 0, 44)
        buyBtn.Position = UDim2.new(0, 18, 0, 544)
        buyBtn.BackgroundColor3 = Color3.fromRGB(52, 199, 89)
        buyBtn.Text = "Buy AUR"
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.Font = Enum.Font.GothamBold
        buyBtn.TextSize = 14
        buyBtn.BorderSizePixel = 0
        buyBtn.ZIndex = 19
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 12)

        local sellBtn = Instance.new("TextButton", vScroll)
        sellBtn.Size = UDim2.new(0.46, 0, 0, 44)
        sellBtn.Position = UDim2.new(0.51, 0, 0, 544)
        sellBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 58)
        sellBtn.Text = "Sell / Swap"
        sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        sellBtn.Font = Enum.Font.GothamBold
        sellBtn.TextSize = 14
        sellBtn.BorderSizePixel = 0
        sellBtn.ZIndex = 19
        Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 12)

        buyBtn.MouseButton1Click:Connect(function()
            playTone(2.4)
            showBanner("VaultX", "Market Order: +10.0 AUR executed at $128.50", "rbxassetid://75815873536189", "03:53")
        end)

        sellBtn.MouseButton1Click:Connect(function()
            playTone(2.0)
            showBanner("VaultX", "Swap Order: 5.0 AUR swapped to USDT", "rbxassetid://75815873536189", "03:53")
        end)
    end

    -- =========================================================================
    -- 3. MUSIC APP (Library, Track Selection, Sticky Miniplayer, Widget Sync)
    -- Video Ground Truth (04:45 - 05:25): Search, tracklist, live Springboard sync
    -- =========================================================================
    local musicApp = createBaseApp(appContainer, "Music", Color3.fromRGB(12, 14, 22))
    do
        local tracks = {
            {title = "City After Dark", artist = "Neon Wave", duration = "03:42", art = "rbxassetid://134300653681700", bgGrad = Color3.fromRGB(255, 45, 85)},
            {title = "Pacific Drive", artist = "Synthwave Los Santos", duration = "04:15", art = "rbxassetid://103043499972901", bgGrad = Color3.fromRGB(88, 86, 214)},
            {title = "Neon Rain", artist = "Cyber Dreams", duration = "02:58", art = "rbxassetid://13854583196", bgGrad = Color3.fromRGB(0, 122, 255)},
            {title = "Never Gonna Give You Up", artist = "Rick Astley", duration = "03:32", art = "rbxassetid://70546187772415", bgGrad = Color3.fromRGB(255, 149, 0)},
            {title = "Midnight City", artist = "M83", duration = "04:03", art = "rbxassetid://139358287735244", bgGrad = Color3.fromRGB(175, 82, 222)},
        }

        local currentTrackIndex = 1
        local isPlaying = false

        local mHeader = Instance.new("Frame", musicApp)
        mHeader.Size = UDim2.new(1, 0, 0, 75)
        mHeader.Position = UDim2.new(0, 0, 0, 36)
        mHeader.BackgroundTransparency = 1
        mHeader.ZIndex = 17

        local mTitle = Instance.new("TextLabel", mHeader)
        mTitle.Size = UDim2.new(1, -40, 0, 32)
        mTitle.Position = UDim2.new(0, 20, 0, 24)
        mTitle.Text = "Music"
        mTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        mTitle.Font = Enum.Font.GothamBold
        mTitle.TextSize = 28
        mTitle.TextXAlignment = Enum.TextXAlignment.Left
        mTitle.BackgroundTransparency = 1
        mTitle.ZIndex = 18

        -- Search Bar (Video 04:48)
        local searchBar = Instance.new("Frame", musicApp)
        searchBar.Size = UDim2.new(1, -36, 0, 38)
        searchBar.Position = UDim2.new(0, 18, 0, 102)
        searchBar.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
        searchBar.BorderSizePixel = 0
        searchBar.ZIndex = 18
        Instance.new("UICorner", searchBar).CornerRadius = UDim.new(0, 12)

        local sIcn = Instance.new("TextLabel", searchBar)
        sIcn.Size = UDim2.new(0, 32, 1, 0)
        sIcn.Position = UDim2.new(0, 6, 0, 0)
        sIcn.Text = "🔍"
        sIcn.TextSize = 13
        sIcn.BackgroundTransparency = 1
        sIcn.ZIndex = 19

        local sBox = Instance.new("TextBox", searchBar)
        sBox.Size = UDim2.new(1, -44, 1, 0)
        sBox.Position = UDim2.new(0, 38, 0, 0)
        sBox.BackgroundTransparency = 1
        sBox.Text = ""
        sBox.PlaceholderText = "Search artists, songs, albums..."
        sBox.PlaceholderColor3 = Color3.fromRGB(140, 145, 160)
        sBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        sBox.Font = Enum.Font.GothamMedium
        sBox.TextSize = 12.5
        sBox.TextXAlignment = Enum.TextXAlignment.Left
        sBox.ZIndex = 19

        -- Tracklist Scroll
        local tScroll = Instance.new("ScrollingFrame", musicApp)
        tScroll.Size = UDim2.new(1, -36, 1, -220)
        tScroll.Position = UDim2.new(0, 18, 0, 148)
        tScroll.BackgroundTransparency = 1
        tScroll.ScrollBarThickness = 0
        tScroll.ZIndex = 18
        local tlLayout = Instance.new("UIListLayout", tScroll)
        tlLayout.Padding = UDim.new(0, 8)

        -- Miniplayer Bar forward declaration
        local miniPlayer = Instance.new("Frame", musicApp)
        miniPlayer.Size = UDim2.new(1, -24, 0, 64)
        miniPlayer.Position = UDim2.new(0, 12, 1, -84)
        miniPlayer.BackgroundColor3 = Color3.fromRGB(26, 28, 40)
        miniPlayer.BorderSizePixel = 0
        miniPlayer.ZIndex = 25
        Instance.new("UICorner", miniPlayer).CornerRadius = UDim.new(0, 16)
        local mpStroke = Instance.new("UIStroke", miniPlayer)
        mpStroke.Color = Color3.fromRGB(255, 255, 255)
        mpStroke.Transparency = 0.9

        local mpArt = Instance.new("ImageLabel", miniPlayer)
        mpArt.Size = UDim2.new(0, 46, 0, 46)
        mpArt.Position = UDim2.new(0, 9, 0, 9)
        mpArt.BackgroundColor3 = Color3.fromRGB(175, 82, 222)
        mpArt.Image = tracks[1].art
        mpArt.ScaleType = Enum.ScaleType.Fit
        mpArt.ZIndex = 26
        Instance.new("UICorner", mpArt).CornerRadius = UDim.new(0, 10)

        local mpTitle = Instance.new("TextLabel", miniPlayer)
        mpTitle.Size = UDim2.new(0.5, 0, 0, 18)
        mpTitle.Position = UDim2.new(0, 64, 0, 14)
        mpTitle.Text = tracks[1].title
        mpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        mpTitle.Font = Enum.Font.GothamBold
        mpTitle.TextSize = 13.5
        mpTitle.TextXAlignment = Enum.TextXAlignment.Left
        mpTitle.TextTruncate = Enum.TextTruncate.AtEnd
        mpTitle.BackgroundTransparency = 1
        mpTitle.ZIndex = 26

        local mpArtist = Instance.new("TextLabel", miniPlayer)
        mpArtist.Size = UDim2.new(0.5, 0, 0, 14)
        mpArtist.Position = UDim2.new(0, 64, 0, 34)
        mpArtist.Text = tracks[1].artist
        mpArtist.TextColor3 = Color3.fromRGB(142, 142, 147)
        mpArtist.Font = Enum.Font.Gotham
        mpArtist.TextSize = 11.5
        mpArtist.TextXAlignment = Enum.TextXAlignment.Left
        mpArtist.TextTruncate = Enum.TextTruncate.AtEnd
        mpArtist.BackgroundTransparency = 1
        mpArtist.ZIndex = 26

        local mpPlayBtn = Instance.new("TextButton", miniPlayer)
        mpPlayBtn.Size = UDim2.new(0, 36, 0, 36)
        mpPlayBtn.Position = UDim2.new(1, -84, 0, 14)
        mpPlayBtn.BackgroundTransparency = 1
        mpPlayBtn.Text = "▶"
        mpPlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mpPlayBtn.Font = Enum.Font.GothamBold
        mpPlayBtn.TextSize = 20
        mpPlayBtn.ZIndex = 26

        local mpNextBtn = Instance.new("TextButton", miniPlayer)
        mpNextBtn.Size = UDim2.new(0, 36, 0, 36)
        mpNextBtn.Position = UDim2.new(1, -44, 0, 14)
        mpNextBtn.BackgroundTransparency = 1
        mpNextBtn.Text = "⏭"
        mpNextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mpNextBtn.Font = Enum.Font.GothamBold
        mpNextBtn.TextSize = 18
        mpNextBtn.ZIndex = 26

        -- Scrubber line under miniplayer
        local mpScrub = Instance.new("Frame", miniPlayer)
        mpScrub.Size = UDim2.new(1, -16, 0, 3)
        mpScrub.Position = UDim2.new(0, 8, 1, -5)
        mpScrub.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
        mpScrub.BorderSizePixel = 0
        mpScrub.ZIndex = 26
        Instance.new("UICorner", mpScrub).CornerRadius = UDim.new(1, 0)

        local mpFill = Instance.new("Frame", mpScrub)
        mpFill.Size = UDim2.new(0.42, 0, 1, 0)
        mpFill.BackgroundColor3 = Color3.fromRGB(255, 45, 85)
        mpFill.BorderSizePixel = 0
        mpFill.ZIndex = 27
        Instance.new("UICorner", mpFill).CornerRadius = UDim.new(1, 0)

        local function playTrack(index: number)
            currentTrackIndex = index
            local track = tracks[currentTrackIndex]
            isPlaying = true
            mpTitle.Text = track.title
            mpArtist.Text = track.artist
            mpArt.Image = track.art
            mpArt.BackgroundColor3 = track.bgGrad
            mpPlayBtn.Text = "⏸"

            -- Sync with Springboard 4x2 Music Widget! (Ground Truth 04:52)
            updateMusicWidget({
                title = track.title,
                artist = track.artist,
                albumArt = track.art,
                isPlaying = true,
                progress = 0.42,
            })
        end

        mpPlayBtn.MouseButton1Click:Connect(function()
            playTone(2.0)
            isPlaying = not isPlaying
            mpPlayBtn.Text = isPlaying and "⏸" or "▶"
            local track = tracks[currentTrackIndex]
            updateMusicWidget({
                title = track.title,
                artist = track.artist,
                albumArt = track.art,
                isPlaying = isPlaying,
                progress = 0.42,
            })
        end)

        mpNextBtn.MouseButton1Click:Connect(function()
            playTone(2.2)
            local nextIdx = (currentTrackIndex % #tracks) + 1
            playTrack(nextIdx)
        end)

        -- Build Track List Rows
        for idx, track in ipairs(tracks) do
            local row = Instance.new("TextButton", tScroll)
            row.Size = UDim2.new(1, 0, 0, 56)
            row.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
            row.Text = ""
            row.BorderSizePixel = 0
            row.ZIndex = 19
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

            local art = Instance.new("ImageLabel", row)
            art.Size = UDim2.new(0, 42, 0, 42)
            art.Position = UDim2.new(0, 8, 0, 7)
            art.BackgroundColor3 = track.bgGrad
            art.Image = track.art
            art.ScaleType = Enum.ScaleType.Fit
            art.ZIndex = 20
            Instance.new("UICorner", art).CornerRadius = UDim.new(0, 8)

            local titleLbl = Instance.new("TextLabel", row)
            titleLbl.Size = UDim2.new(0.6, 0, 0, 18)
            titleLbl.Position = UDim2.new(0, 58, 0, 9)
            titleLbl.Text = track.title
            titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLbl.Font = Enum.Font.GothamMedium
            titleLbl.TextSize = 13.5
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.BackgroundTransparency = 1
            titleLbl.ZIndex = 20

            local artistLbl = Instance.new("TextLabel", row)
            artistLbl.Size = UDim2.new(0.6, 0, 0, 14)
            artistLbl.Position = UDim2.new(0, 58, 0, 29)
            artistLbl.Text = track.artist
            artistLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            artistLbl.Font = Enum.Font.Gotham
            artistLbl.TextSize = 11.5
            artistLbl.TextXAlignment = Enum.TextXAlignment.Left
            artistLbl.BackgroundTransparency = 1
            artistLbl.ZIndex = 20

            local durLbl = Instance.new("TextLabel", row)
            durLbl.Size = UDim2.new(0.2, 0, 1, 0)
            durLbl.Position = UDim2.new(0.8, -12, 0, 0)
            durLbl.Text = track.duration
            durLbl.TextColor3 = Color3.fromRGB(142, 142, 147)
            durLbl.Font = Enum.Font.Gotham
            durLbl.TextSize = 12
            durLbl.TextXAlignment = Enum.TextXAlignment.Right
            durLbl.BackgroundTransparency = 1
            durLbl.ZIndex = 20

            row.MouseButton1Click:Connect(function()
                playTone(2.0)
                playTrack(idx)
            end)
        end
    end

    -- =========================================================================
    -- 4. GARAGE APP (Luxury Fleet, Valet Delivery & Lock/Unlock)
    -- =========================================================================
    local garageApp = createBaseApp(appContainer, "Garage", Color3.fromRGB(14, 16, 24))
    do
        local gHeader = Instance.new("Frame", garageApp)
        gHeader.Size = UDim2.new(1, 0, 0, 75)
        gHeader.Position = UDim2.new(0, 0, 0, 36)
        gHeader.BackgroundTransparency = 1
        gHeader.ZIndex = 17

        local gTitle = Instance.new("TextLabel", gHeader)
        gTitle.Size = UDim2.new(1, -40, 0, 32)
        gTitle.Position = UDim2.new(0, 20, 0, 28)
        gTitle.Text = "My Garage"
        gTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        gTitle.Font = Enum.Font.GothamBold
        gTitle.TextSize = 28
        gTitle.TextXAlignment = Enum.TextXAlignment.Left
        gTitle.BackgroundTransparency = 1
        gTitle.ZIndex = 18

        local gScroll = Instance.new("ScrollingFrame", garageApp)
        gScroll.Size = UDim2.new(1, -36, 1, -120)
        gScroll.Position = UDim2.new(0, 18, 0, 115)
        gScroll.BackgroundTransparency = 1
        gScroll.ScrollBarThickness = 0
        gScroll.ZIndex = 17
        local gl = Instance.new("UIListLayout", gScroll)
        gl.Padding = UDim.new(0, 14)

        local vehicles = {
            {name = "Benefactor Schafter V12", plate = "28XYZ901", class = "Sedan / Sports", engine = "Max", turbo = "Yes"},
            {name = "Pfister Comet S2", plate = "77LUX888", class = "Sports", engine = "Level 4", turbo = "Yes"},
            {name = "Pegassi Ignus", plate = "FAST99", class = "Supercar", engine = "Max", turbo = "AWD"},
            {name = "Grotti Itali RSX", plate = "ROSSO1", class = "Sports", engine = "Max", turbo = "Yes"},
        }

        for _, veh in ipairs(vehicles) do
            local card = Instance.new("Frame", gScroll)
            card.Size = UDim2.new(1, 0, 0, 120)
            card.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
            card.BorderSizePixel = 0
            card.ZIndex = 18
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
            local cs = Instance.new("UIStroke", card)
            cs.Color = Color3.fromRGB(255, 255, 255)
            cs.Transparency = 0.92

            local vName = Instance.new("TextLabel", card)
            vName.Size = UDim2.new(0.65, 0, 0, 20)
            vName.Position = UDim2.new(0, 16, 0, 12)
            vName.Text = veh.name
            vName.TextColor3 = Color3.fromRGB(255, 255, 255)
            vName.Font = Enum.Font.GothamBold
            vName.TextSize = 15
            vName.TextXAlignment = Enum.TextXAlignment.Left
            vName.BackgroundTransparency = 1
            vName.ZIndex = 19

            local vPlate = Instance.new("TextLabel", card)
            vPlate.Size = UDim2.new(0.3, 0, 0, 20)
            vPlate.Position = UDim2.new(0.68, 0, 0, 12)
            vPlate.Text = veh.plate
            vPlate.TextColor3 = Color3.fromRGB(255, 214, 10)
            vPlate.Font = Enum.Font.GothamMedium
            vPlate.TextSize = 13
            vPlate.TextXAlignment = Enum.TextXAlignment.Right
            vPlate.BackgroundTransparency = 1
            vPlate.ZIndex = 19

            local vStats = Instance.new("TextLabel", card)
            vStats.Size = UDim2.new(1, -32, 0, 16)
            vStats.Position = UDim2.new(0, 16, 0, 36)
            vStats.Text = veh.class .. "  •  Engine: " .. veh.engine .. "  •  Turbo: " .. veh.turbo
            vStats.TextColor3 = Color3.fromRGB(142, 142, 147)
            vStats.Font = Enum.Font.Gotham
            vStats.TextSize = 12
            vStats.TextXAlignment = Enum.TextXAlignment.Left
            vStats.BackgroundTransparency = 1
            vStats.ZIndex = 19

            local spawnBtn = Instance.new("TextButton", card)
            spawnBtn.Size = UDim2.new(0.46, 0, 0, 36)
            spawnBtn.Position = UDim2.new(0, 16, 0, 68)
            spawnBtn.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
            spawnBtn.Text = "🚗 Deliver Valet"
            spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            spawnBtn.Font = Enum.Font.GothamMedium
            spawnBtn.TextSize = 13
            spawnBtn.BorderSizePixel = 0
            spawnBtn.ZIndex = 20
            Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 10)

            spawnBtn.MouseButton1Click:Connect(function()
                playTone(2.4)
                showBanner("Valet", veh.name .. " marked on GPS & en route!", "rbxassetid://134300653681700", "03:54")
            end)

            local isLocked = true
            local lockBtn = Instance.new("TextButton", card)
            lockBtn.Size = UDim2.new(0.46, 0, 0, 36)
            lockBtn.Position = UDim2.new(0.51, 0, 0, 68)
            lockBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 56)
            lockBtn.Text = "🔒 Locked"
            lockBtn.TextColor3 = Color3.fromRGB(220, 225, 240)
            lockBtn.Font = Enum.Font.GothamMedium
            lockBtn.TextSize = 13
            lockBtn.BorderSizePixel = 0
            lockBtn.ZIndex = 20
            Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 10)

            lockBtn.MouseButton1Click:Connect(function()
                playTone(1.6)
                isLocked = not isLocked
                lockBtn.Text = isLocked and "🔒 Locked" or "🔓 Unlocked"
                lockBtn.TextColor3 = isLocked and Color3.fromRGB(220, 225, 240) or Color3.fromRGB(52, 199, 89)
                showBanner("Security", veh.name .. (isLocked and " Locked" or " Unlocked"), "", "03:54")
            end)
        end
    end

    -- =========================================================================
    -- 5. CYBER SNAKE GAME
    -- =========================================================================
    local snakeApp = createBaseApp(appContainer, "Snake", Color3.fromRGB(12, 14, 20))
    do
        local sHeader = Instance.new("Frame", snakeApp)
        sHeader.Size = UDim2.new(1, 0, 0, 64)
        sHeader.Position = UDim2.new(0, 0, 0, 36)
        sHeader.BackgroundTransparency = 1
        sHeader.ZIndex = 17

        local sTitle = Instance.new("TextLabel", sHeader)
        sTitle.Size = UDim2.new(0.5, 0, 1, 0)
        sTitle.Position = UDim2.new(0, 20, 0, 0)
        sTitle.Text = "Snake 🐍"
        sTitle.TextColor3 = Color3.fromRGB(88, 185, 87)
        sTitle.Font = Enum.Font.GothamBold
        sTitle.TextSize = 22
        sTitle.TextXAlignment = Enum.TextXAlignment.Left
        sTitle.BackgroundTransparency = 1
        sTitle.ZIndex = 18

        local scoreLabel = Instance.new("TextLabel", sHeader)
        scoreLabel.Size = UDim2.new(0.4, -20, 1, 0)
        scoreLabel.Position = UDim2.new(0.6, 0, 0, 0)
        scoreLabel.Text = "Score: 0"
        scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        scoreLabel.Font = Enum.Font.GothamBold
        scoreLabel.TextSize = 16
        scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
        scoreLabel.BackgroundTransparency = 1
        scoreLabel.ZIndex = 18

        local gridWidth = 12
        local gridHeight = 12
        local boardFrame = Instance.new("Frame", snakeApp)
        boardFrame.AnchorPoint = Vector2.new(0.5, 0)
        boardFrame.Position = UDim2.new(0.5, 0, 0, 105)
        boardFrame.Size = UDim2.new(0, 252, 0, 252)
        boardFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        boardFrame.BorderSizePixel = 0
        boardFrame.ClipsDescendants = true
        boardFrame.ZIndex = 18
        Instance.new("UICorner", boardFrame).CornerRadius = UDim.new(0, 12)
        local bs = Instance.new("UIStroke", boardFrame)
        bs.Color = Color3.fromRGB(40, 48, 68)

        local cellSize = 252 / gridWidth

        local overlay = Instance.new("Frame", boardFrame)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.4
        overlay.ZIndex = 25

        local oTitle = Instance.new("TextLabel", overlay)
        oTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        oTitle.Position = UDim2.new(0.5, 0, 0.4, 0)
        oTitle.Size = UDim2.new(1, 0, 0, 32)
        oTitle.Text = "Ready to Play?"
        oTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        oTitle.Font = Enum.Font.GothamBold
        oTitle.TextSize = 22
        oTitle.BackgroundTransparency = 1
        oTitle.ZIndex = 26

        local startBtn = Instance.new("TextButton", overlay)
        startBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        startBtn.Position = UDim2.new(0.5, 0, 0.65, 0)
        startBtn.Size = UDim2.new(0, 140, 0, 38)
        startBtn.BackgroundColor3 = Color3.fromRGB(88, 185, 87)
        startBtn.Text = "Start Game"
        startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        startBtn.Font = Enum.Font.GothamBold
        startBtn.TextSize = 15
        startBtn.BorderSizePixel = 0
        startBtn.ZIndex = 26
        Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 10)

        local dpad = Instance.new("Frame", snakeApp)
        dpad.AnchorPoint = Vector2.new(0.5, 0)
        dpad.Position = UDim2.new(0.5, 0, 0, 375)
        dpad.Size = UDim2.new(0, 160, 0, 140)
        dpad.BackgroundTransparency = 1
        dpad.ZIndex = 18

        local function makeDpadBtn(parent: Instance, label: string, pos: UDim2, dir: string, turnCb: (string) -> ())
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(0, 44, 0, 44)
            b.Position = pos
            b.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
            b.Text = label
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 20
            b.BorderSizePixel = 0
            b.ZIndex = 19
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            b.MouseButton1Click:Connect(function() turnCb(dir) end)
            return b
        end

        local snakeBody = {{x = 6, y = 6}, {x = 5, y = 6}, {x = 4, y = 6}}
        local direction = "right"
        local pendingDir = "right"
        local fruit = {x = 8, y = 8}
        local score = 0
        local isPlayingGame = false
        local gameLoopConn: RBXScriptConnection? = nil
        local segmentFrames = {}

        local fruitFrame = Instance.new("Frame", boardFrame)
        fruitFrame.Size = UDim2.new(0, cellSize - 2, 0, cellSize - 2)
        fruitFrame.BackgroundColor3 = Color3.fromRGB(255, 98, 86)
        fruitFrame.BorderSizePixel = 0
        fruitFrame.Visible = false
        fruitFrame.ZIndex = 20
        Instance.new("UICorner", fruitFrame).CornerRadius = UDim.new(1, 0)

        local function renderGrid()
            for _, sf in ipairs(segmentFrames) do sf:Destroy() end
            segmentFrames = {}
            fruitFrame.Position = UDim2.new(0, (fruit.x - 1) * cellSize + 1, 0, (fruit.y - 1) * cellSize + 1)
            fruitFrame.Visible = isPlayingGame

            for idx, seg in ipairs(snakeBody) do
                local sf = Instance.new("Frame", boardFrame)
                sf.Size = UDim2.new(0, cellSize - 2, 0, cellSize - 2)
                sf.Position = UDim2.new(0, (seg.x - 1) * cellSize + 1, 0, (seg.y - 1) * cellSize + 1)
                sf.BackgroundColor3 = (idx == 1) and Color3.fromRGB(145, 230, 120) or Color3.fromRGB(88, 185, 87)
                sf.BorderSizePixel = 0
                sf.ZIndex = 21
                Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 4)
                table.insert(segmentFrames, sf)
            end
        end

        local function turn(newDir: string)
            local opposites = {up = "down", down = "up", left = "right", right = "left"}
            if opposites[newDir] ~= direction then pendingDir = newDir end
        end

        makeDpadBtn(dpad, "▲", UDim2.new(0.5, -22, 0, 0), "up", turn)
        makeDpadBtn(dpad, "▼", UDim2.new(0.5, -22, 0, 96), "down", turn)
        makeDpadBtn(dpad, "◀", UDim2.new(0, 8, 0, 48), "left", turn)
        makeDpadBtn(dpad, "▶", UDim2.new(1, -52, 0, 48), "right", turn)

        local function spawnFruit()
            local occupied = {}
            for _, seg in ipairs(snakeBody) do occupied[seg.x .. "_" .. seg.y] = true end
            local available = {}
            for gx = 1, gridWidth do
                for gy = 1, gridHeight do
                    if not occupied[gx .. "_" .. gy] then table.insert(available, {x = gx, y = gy}) end
                end
            end
            if #available > 0 then fruit = available[math.random(1, #available)] end
        end

        local function gameOver()
            isPlayingGame = false
            if gameLoopConn then gameLoopConn:Disconnect(); gameLoopConn = nil end
            playTone(1.2)
            oTitle.Text = "Game Over! (" .. tostring(score) .. ")"
            startBtn.Text = "Play Again"
            overlay.Visible = true
        end

        local function tickGame()
            direction = pendingDir
            local head = snakeBody[1]
            local nextX = head.x + (direction == "right" and 1 or direction == "left" and -1 or 0)
            local nextY = head.y + (direction == "down" and 1 or direction == "up" and -1 or 0)

            if nextX < 1 or nextX > gridWidth or nextY < 1 or nextY > gridHeight then
                gameOver()
                return
            end
            for i = 1, #snakeBody - 1 do
                if snakeBody[i].x == nextX and snakeBody[i].y == nextY then
                    gameOver()
                    return
                end
            end

            local newHead = {x = nextX, y = nextY}
            table.insert(snakeBody, 1, newHead)
            if nextX == fruit.x and nextY == fruit.y then
                playTone(2.8)
                score += 1
                scoreLabel.Text = "Score: " .. tostring(score)
                spawnFruit()
            else
                table.remove(snakeBody)
            end
            renderGrid()
        end

        startBtn.MouseButton1Click:Connect(function()
            playTone(2.0)
            overlay.Visible = false
            snakeBody = {{x = 6, y = 6}, {x = 5, y = 6}, {x = 4, y = 6}}
            direction = "right"
            pendingDir = "right"
            score = 0
            scoreLabel.Text = "Score: 0"
            spawnFruit()
            isPlayingGame = true
            renderGrid()

            if gameLoopConn then gameLoopConn:Disconnect() end
            local timer = 0
            local tickRate = 0.18
            gameLoopConn = RunService.RenderStepped:Connect(function(dt)
                if not isPlayingGame then return end
                timer += dt
                if timer >= tickRate then
                    timer -= tickRate
                    tickGame()
                end
            end)
        end)
    end
end

return AppSuite_Finance_Gaming
