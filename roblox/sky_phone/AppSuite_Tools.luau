--!strict
-- src/sky_phone/AppSuite_Tools.luau
-- Pure Luau Component: Weather (2x2 Metrics & Hourly Forecast),
-- Clock (Alarm List, iOS Drum Wheel Picker Modal, Stopwatch),
-- Camera (Focal controls & Shutter), Calculator (5x4 Dark Grid)
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local AppSuite_Tools = {}

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

function AppSuite_Tools.build(appContainer: Frame, ctx: any)
    local showNotification = ctx and ctx.showNotification or function(title: string, msg: string) end

    -- =========================================================================
    -- 1. WEATHER APP (Detailed View: 2x2 Telemetry Grid & 6-Hour Forecast)
    -- =========================================================================
    local weatherApp = createBaseApp(appContainer, "Weather", Color3.fromRGB(18, 28, 46))
    do
        local wGrad = Instance.new("UIGradient", weatherApp)
        wGrad.Rotation = 90
        wGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(36, 64, 102)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(20, 36, 62)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(10, 16, 28)),
        })

        local wHeader = Instance.new("Frame", weatherApp)
        wHeader.Size = UDim2.new(1, 0, 0, 60)
        wHeader.Position = UDim2.new(0, 0, 0, 36)
        wHeader.BackgroundTransparency = 1
        wHeader.ZIndex = 17

        local wTitle = Instance.new("TextLabel", wHeader)
        wTitle.Size = UDim2.new(1, 0, 0, 24)
        wTitle.Position = UDim2.new(0, 0, 0, 6)
        wTitle.BackgroundTransparency = 1
        wTitle.Text = "Weather"
        wTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        wTitle.Font = Enum.Font.GothamBold
        wTitle.TextSize = 18
        wTitle.ZIndex = 18

        local wLoc = Instance.new("TextLabel", wHeader)
        wLoc.Size = UDim2.new(1, 0, 0, 18)
        wLoc.Position = UDim2.new(0, 0, 0, 32)
        wLoc.BackgroundTransparency = 1
        wLoc.Text = "↗ Los Santos"
        wLoc.TextColor3 = Color3.fromRGB(170, 195, 235)
        wLoc.Font = Enum.Font.GothamMedium
        wLoc.TextSize = 13
        wLoc.ZIndex = 18

        -- Big Temp & Hero Icon
        local heroFrame = Instance.new("Frame", weatherApp)
        heroFrame.Size = UDim2.new(1, -36, 0, 130)
        heroFrame.Position = UDim2.new(0, 18, 0, 102)
        heroFrame.BackgroundTransparency = 1
        heroFrame.ZIndex = 17

        local wIcon = Instance.new("TextLabel", heroFrame)
        wIcon.Size = UDim2.new(1, 0, 0, 48)
        wIcon.Position = UDim2.new(0, 0, 0, 0)
        wIcon.BackgroundTransparency = 1
        wIcon.Text = "⛅"
        wIcon.TextSize = 42
        wIcon.ZIndex = 18

        local wTemp = Instance.new("TextLabel", heroFrame)
        wTemp.Size = UDim2.new(1, 0, 0, 52)
        wTemp.Position = UDim2.new(0, 0, 0, 46)
        wTemp.BackgroundTransparency = 1
        wTemp.Text = "24°"
        wTemp.TextColor3 = Color3.fromRGB(255, 255, 255)
        wTemp.Font = Enum.Font.GothamBold
        wTemp.TextSize = 50
        wTemp.ZIndex = 18

        local wCondition = Instance.new("TextLabel", heroFrame)
        wCondition.Size = UDim2.new(1, 0, 0, 20)
        wCondition.Position = UDim2.new(0, 0, 0, 98)
        wCondition.BackgroundTransparency = 1
        wCondition.Text = "Partly Cloudy"
        wCondition.TextColor3 = Color3.fromRGB(255, 255, 255)
        wCondition.Font = Enum.Font.GothamBold
        wCondition.TextSize = 16
        wCondition.ZIndex = 18

        local wSub = Instance.new("TextLabel", weatherApp)
        wSub.Size = UDim2.new(1, -36, 0, 16)
        wSub.Position = UDim2.new(0, 18, 0, 236)
        wSub.BackgroundTransparency = 1
        wSub.Text = "Sunshine mixed with passing clouds."
        wSub.TextColor3 = Color3.fromRGB(180, 200, 230)
        wSub.Font = Enum.Font.Gotham
        wSub.TextSize = 12
        wSub.ZIndex = 18

        -- 2x2 Telemetry Grid
        local metricGrid = Instance.new("Frame", weatherApp)
        metricGrid.Size = UDim2.new(1, -36, 0, 140)
        metricGrid.Position = UDim2.new(0, 18, 0, 262)
        metricGrid.BackgroundTransparency = 1
        metricGrid.ZIndex = 17

        local mgLayout = Instance.new("UIGridLayout", metricGrid)
        mgLayout.CellSize = UDim2.new(0.48, 0, 0.46, 0)
        mgLayout.CellPadding = UDim2.new(0.04, 0, 0.08, 0)

        local function makeMetricCard(title: string, value: string, icon: string)
            local card = Instance.new("Frame", metricGrid)
            card.BackgroundColor3 = Color3.fromRGB(22, 30, 46)
            card.BackgroundTransparency = 0.25
            card.ZIndex = 18
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

            local cs = Instance.new("UIStroke", card)
            cs.Color = Color3.fromRGB(255, 255, 255)
            cs.Transparency = 0.90
            cs.Thickness = 1

            local tLbl = Instance.new("TextLabel", card)
            tLbl.Size = UDim2.new(1, -20, 0, 16)
            tLbl.Position = UDim2.new(0, 10, 0, 10)
            tLbl.BackgroundTransparency = 1
            tLbl.Text = icon .. " " .. title
            tLbl.TextColor3 = Color3.fromRGB(140, 165, 200)
            tLbl.Font = Enum.Font.GothamBold
            tLbl.TextSize = 10
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.ZIndex = 19

            local vLbl = Instance.new("TextLabel", card)
            vLbl.Size = UDim2.new(1, -20, 0, 26)
            vLbl.Position = UDim2.new(0, 10, 0, 28)
            vLbl.BackgroundTransparency = 1
            vLbl.Text = value
            vLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            vLbl.Font = Enum.Font.GothamBold
            vLbl.TextSize = 18
            vLbl.TextXAlignment = Enum.TextXAlignment.Left
            vLbl.ZIndex = 19
        end

        makeMetricCard("FEELS LIKE", "23°", "🌡️")
        makeMetricCard("WIND", "12 km/h", "💨")
        makeMetricCard("HUMIDITY", "53%", "💧")
        makeMetricCard("PRECIPITATION", "18%", "☂️")

        -- Next Hours Forecast Card
        local nextHoursCard = Instance.new("Frame", weatherApp)
        nextHoursCard.Size = UDim2.new(1, -36, 0, 120)
        nextHoursCard.Position = UDim2.new(0, 18, 0, 420)
        nextHoursCard.BackgroundColor3 = Color3.fromRGB(22, 30, 46)
        nextHoursCard.BackgroundTransparency = 0.25
        nextHoursCard.ZIndex = 18
        Instance.new("UICorner", nextHoursCard).CornerRadius = UDim.new(0, 16)

        local nhTitle = Instance.new("TextLabel", nextHoursCard)
        nhTitle.Size = UDim2.new(1, -20, 0, 20)
        nhTitle.Position = UDim2.new(0, 12, 0, 8)
        nhTitle.BackgroundTransparency = 1
        nhTitle.Text = "⏱ Next Hours"
        nhTitle.TextColor3 = Color3.fromRGB(150, 175, 210)
        nhTitle.Font = Enum.Font.GothamBold
        nhTitle.TextSize = 11.5
        nhTitle.TextXAlignment = Enum.TextXAlignment.Left
        nhTitle.ZIndex = 19

        local hoursRow = Instance.new("Frame", nextHoursCard)
        hoursRow.Size = UDim2.new(1, -20, 0, 80)
        hoursRow.Position = UDim2.new(0, 10, 0, 32)
        hoursRow.BackgroundTransparency = 1
        hoursRow.ZIndex = 19

        local hrLayout = Instance.new("UIListLayout", hoursRow)
        hrLayout.FillDirection = Enum.FillDirection.Horizontal
        hrLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        hrLayout.Padding = UDim.new(0, 8)

        local FORECAST = {
            { time = "Now", icon = "⛅", pop = "", temp = "24°" },
            { time = "18", icon = "🌧️", pop = "82%", temp = "19°" },
            { time = "19", icon = "🌧️", pop = "82%", temp = "17°" },
            { time = "20", icon = "🌧️", pop = "82%", temp = "16°" },
            { time = "21", icon = "🌧️", pop = "82%", temp = "15°" },
            { time = "22", icon = "🌧️", pop = "82%", temp = "13°" },
        }

        for _, fc in ipairs(FORECAST) do
            local col = Instance.new("Frame", hoursRow)
            col.Size = UDim2.new(0, 38, 1, 0)
            col.BackgroundTransparency = 1
            col.ZIndex = 20

            local hTime = Instance.new("TextLabel", col)
            hTime.Size = UDim2.new(1, 0, 0, 14)
            hTime.BackgroundTransparency = 1
            hTime.Text = fc.time
            hTime.TextColor3 = Color3.fromRGB(180, 200, 230)
            hTime.Font = Enum.Font.GothamMedium
            hTime.TextSize = 10.5
            hTime.ZIndex = 21

            local hIco = Instance.new("TextLabel", col)
            hIco.Size = UDim2.new(1, 0, 0, 22)
            hIco.Position = UDim2.new(0, 0, 0, 16)
            hIco.BackgroundTransparency = 1
            hIco.Text = fc.icon
            hIco.TextSize = 16
            hIco.ZIndex = 21

            if fc.pop ~= "" then
                local hPop = Instance.new("TextLabel", col)
                hPop.Size = UDim2.new(1, 0, 0, 10)
                hPop.Position = UDim2.new(0, 0, 0, 38)
                hPop.BackgroundTransparency = 1
                hPop.Text = fc.pop
                hPop.TextColor3 = Color3.fromRGB(100, 190, 255)
                hPop.Font = Enum.Font.GothamBold
                hPop.TextSize = 8.5
                hPop.ZIndex = 21
            end

            local hTemp = Instance.new("TextLabel", col)
            hTemp.Size = UDim2.new(1, 0, 0, 16)
            hTemp.Position = UDim2.new(0, 0, 1, -18)
            hTemp.BackgroundTransparency = 1
            hTemp.Text = fc.temp
            hTemp.TextColor3 = Color3.fromRGB(255, 255, 255)
            hTemp.Font = Enum.Font.GothamBold
            hTemp.TextSize = 12
            hTemp.ZIndex = 21
        end
    end

    -- =========================================================================
    -- 2. CLOCK APP (Dark Theme: Alarms, iOS Drum Wheel Picker Modal, Stopwatch)
    -- =========================================================================
    local clockApp = createBaseApp(appContainer, "Clock", Color3.fromRGB(14, 16, 24))
    do
        local alarmsView = Instance.new("Frame", clockApp)
        alarmsView.Name = "AlarmsView"
        alarmsView.Size = UDim2.new(1, 0, 1, 0)
        alarmsView.BackgroundTransparency = 1
        alarmsView.ZIndex = 17

        local stopwatchView = Instance.new("Frame", clockApp)
        stopwatchView.Name = "StopwatchView"
        stopwatchView.Size = UDim2.new(1, 0, 1, 0)
        stopwatchView.BackgroundTransparency = 1
        stopwatchView.Visible = false
        stopwatchView.ZIndex = 17

        -- Alarms Header
        local aHeader = Instance.new("Frame", alarmsView)
        aHeader.Size = UDim2.new(1, -36, 0, 48)
        aHeader.Position = UDim2.new(0, 18, 0, 40)
        aHeader.BackgroundTransparency = 1
        aHeader.ZIndex = 18

        local aAddBtn = Instance.new("TextButton", aHeader)
        aAddBtn.Size = UDim2.new(0, 32, 0, 32)
        aAddBtn.Position = UDim2.new(0, 0, 0.5, -16)
        aAddBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        aAddBtn.Text = "＋"
        aAddBtn.TextColor3 = Color3.fromRGB(255, 159, 10)
        aAddBtn.Font = Enum.Font.GothamBold
        aAddBtn.TextSize = 20
        aAddBtn.ZIndex = 19
        Instance.new("UICorner", aAddBtn).CornerRadius = UDim.new(1, 0)

        local aTitle = Instance.new("TextLabel", aHeader)
        aTitle.Size = UDim2.new(1, -120, 1, 0)
        aTitle.Position = UDim2.new(0, 44, 0, 0)
        aTitle.BackgroundTransparency = 1
        aTitle.Text = "Alarm"
        aTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        aTitle.Font = Enum.Font.GothamBold
        aTitle.TextSize = 26
        aTitle.TextXAlignment = Enum.TextXAlignment.Left
        aTitle.ZIndex = 19

        local aEditBtn = Instance.new("TextButton", aHeader)
        aEditBtn.Size = UDim2.new(0, 50, 0, 32)
        aEditBtn.Position = UDim2.new(1, -50, 0.5, -16)
        aEditBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
        aEditBtn.Text = "Edit"
        aEditBtn.TextColor3 = Color3.fromRGB(255, 159, 10)
        aEditBtn.Font = Enum.Font.GothamMedium
        aEditBtn.TextSize = 13
        aEditBtn.ZIndex = 19
        Instance.new("UICorner", aEditBtn).CornerRadius = UDim.new(0, 8)

        -- Alarms List
        local aScroll = Instance.new("ScrollingFrame", alarmsView)
        aScroll.Size = UDim2.new(1, -36, 1, -180)
        aScroll.Position = UDim2.new(0, 18, 0, 96)
        aScroll.BackgroundTransparency = 1
        aScroll.ScrollBarThickness = 0
        aScroll.ZIndex = 18

        local asLayout = Instance.new("UIListLayout", aScroll)
        asLayout.SortOrder = Enum.SortOrder.LayoutOrder
        asLayout.Padding = UDim.new(0, 10)

        local function makeAlarmRow(timeStr: string, labelStr: string, defaultOn: boolean)
            local row = Instance.new("Frame", aScroll)
            row.Size = UDim2.new(1, 0, 0, 68)
            row.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
            row.ZIndex = 19
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 14)

            local t = Instance.new("TextLabel", row)
            t.Size = UDim2.new(1, -80, 0, 34)
            t.Position = UDim2.new(0, 14, 0, 8)
            t.BackgroundTransparency = 1
            t.Text = timeStr
            t.TextColor3 = defaultOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(142, 142, 147)
            t.Font = Enum.Font.Gotham
            t.TextSize = 34
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.ZIndex = 20

            local sub = Instance.new("TextLabel", row)
            sub.Size = UDim2.new(1, -80, 0, 16)
            sub.Position = UDim2.new(0, 14, 0, 42)
            sub.BackgroundTransparency = 1
            sub.Text = labelStr
            sub.TextColor3 = Color3.fromRGB(142, 142, 147)
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 11.5
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.ZIndex = 20

            local sw = Instance.new("TextButton", row)
            sw.Size = UDim2.new(0, 46, 0, 26)
            sw.Position = UDim2.new(1, -58, 0.5, -13)
            sw.BackgroundColor3 = defaultOn and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(58, 62, 74)
            sw.Text = ""
            sw.AutoButtonColor = false
            sw.ZIndex = 20
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", sw)
            knob.Size = UDim2.new(0, 22, 0, 22)
            knob.Position = defaultOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.ZIndex = 21
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local isOn = defaultOn
            sw.MouseButton1Click:Connect(function()
                isOn = not isOn
                sw.BackgroundColor3 = isOn and Color3.fromRGB(52, 199, 89) or Color3.fromRGB(58, 62, 74)
                knob.Position = isOn and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
                t.TextColor3 = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(142, 142, 147)
            end)
        end

        makeAlarmRow("13:30", "Never · Garage appointment", true)
        makeAlarmRow("08:00", "Weekdays · Work Shift", false)

        -- Alarm Editor Modal (iOS Drum Wheel Roller & Repeat Checklist)
        local alarmModal = Instance.new("Frame", clockApp)
        alarmModal.Name = "AlarmModal"
        alarmModal.Size = UDim2.new(1, 0, 1, 0)
        alarmModal.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
        alarmModal.Visible = false
        alarmModal.ZIndex = 50
        Instance.new("UICorner", alarmModal).CornerRadius = UDim.new(0.136, 0)

        local amHeader = Instance.new("Frame", alarmModal)
        amHeader.Size = UDim2.new(1, -36, 0, 48)
        amHeader.Position = UDim2.new(0, 18, 0, 36)
        amHeader.BackgroundTransparency = 1
        amHeader.ZIndex = 51

        local amClose = Instance.new("TextButton", amHeader)
        amClose.Size = UDim2.new(0, 32, 0, 32)
        amClose.Position = UDim2.new(0, 0, 0.5, -16)
        amClose.BackgroundColor3 = Color3.fromRGB(36, 38, 48)
        amClose.Text = "✕"
        amClose.TextColor3 = Color3.fromRGB(255, 255, 255)
        amClose.Font = Enum.Font.GothamBold
        amClose.TextSize = 14
        amClose.ZIndex = 52
        Instance.new("UICorner", amClose).CornerRadius = UDim.new(1, 0)

        local amTitle = Instance.new("TextLabel", amHeader)
        amTitle.Size = UDim2.new(1, -100, 1, 0)
        amTitle.Position = UDim2.new(0, 50, 0, 0)
        amTitle.BackgroundTransparency = 1
        amTitle.Text = "Alarm"
        amTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        amTitle.Font = Enum.Font.GothamBold
        amTitle.TextSize = 17
        amTitle.ZIndex = 52

        local amSave = Instance.new("TextButton", amHeader)
        amSave.Size = UDim2.new(0, 32, 0, 32)
        amSave.Position = UDim2.new(1, -32, 0.5, -16)
        amSave.BackgroundColor3 = Color3.fromRGB(255, 159, 10)
        amSave.Text = "✓"
        amSave.TextColor3 = Color3.fromRGB(255, 255, 255)
        amSave.Font = Enum.Font.GothamBold
        amSave.TextSize = 16
        amSave.ZIndex = 52
        Instance.new("UICorner", amSave).CornerRadius = UDim.new(1, 0)

        -- Drum Wheel Roller
        local drumFrame = Instance.new("Frame", alarmModal)
        drumFrame.Size = UDim2.new(1, -40, 0, 150)
        drumFrame.Position = UDim2.new(0, 20, 0, 92)
        drumFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
        drumFrame.ZIndex = 51
        Instance.new("UICorner", drumFrame).CornerRadius = UDim.new(0, 14)

        local drumHighlight = Instance.new("Frame", drumFrame)
        drumHighlight.Size = UDim2.new(1, -16, 0, 44)
        drumHighlight.Position = UDim2.new(0, 8, 0.5, -22)
        drumHighlight.BackgroundColor3 = Color3.fromRGB(44, 48, 60)
        drumHighlight.BackgroundTransparency = 0.5
        drumHighlight.ZIndex = 52
        Instance.new("UICorner", drumHighlight).CornerRadius = UDim.new(0, 8)

        local dHour = Instance.new("TextLabel", drumHighlight)
        dHour.Size = UDim2.new(0.45, 0, 1, 0)
        dHour.Position = UDim2.new(0, 10, 0, 0)
        dHour.BackgroundTransparency = 1
        dHour.Text = "09"
        dHour.TextColor3 = Color3.fromRGB(255, 255, 255)
        dHour.Font = Enum.Font.GothamBold
        dHour.TextSize = 34
        dHour.TextXAlignment = Enum.TextXAlignment.Center
        dHour.ZIndex = 53

        local dMin = Instance.new("TextLabel", drumHighlight)
        dMin.Size = UDim2.new(0.45, 0, 1, 0)
        dMin.Position = UDim2.new(0.55, -10, 0, 0)
        dMin.BackgroundTransparency = 1
        dMin.Text = "30"
        dMin.TextColor3 = Color3.fromRGB(255, 255, 255)
        dMin.Font = Enum.Font.GothamBold
        dMin.TextSize = 34
        dMin.TextXAlignment = Enum.TextXAlignment.Center
        dMin.ZIndex = 53

        -- Ghost Rows Above and Below
        local function makeGhostRow(hText: string, mText: string, yPos: number)
            local gr = Instance.new("Frame", drumFrame)
            gr.Size = UDim2.new(1, -16, 0, 36)
            gr.Position = UDim2.new(0, 8, 0, yPos)
            gr.BackgroundTransparency = 1
            gr.ZIndex = 52

            local gh = Instance.new("TextLabel", gr)
            gh.Size = UDim2.new(0.45, 0, 1, 0)
            gh.Position = UDim2.new(0, 10, 0, 0)
            gh.BackgroundTransparency = 1
            gh.Text = hText
            gh.TextColor3 = Color3.fromRGB(100, 105, 120)
            gh.Font = Enum.Font.Gotham
            gh.TextSize = 26
            gh.ZIndex = 53

            local gm = Instance.new("TextLabel", gr)
            gm.Size = UDim2.new(0.45, 0, 1, 0)
            gm.Position = UDim2.new(0.55, -10, 0, 0)
            gm.BackgroundTransparency = 1
            gm.Text = mText
            gm.TextColor3 = Color3.fromRGB(100, 105, 120)
            gm.Font = Enum.Font.Gotham
            gm.TextSize = 26
            gm.ZIndex = 53
        end
        makeGhostRow("08", "29", 12)
        makeGhostRow("10", "31", 102)

        -- Repeat Section (Monday-Sunday Checklist)
        local repTitle = Instance.new("TextLabel", alarmModal)
        repTitle.Size = UDim2.new(1, -40, 0, 20)
        repTitle.Position = UDim2.new(0, 20, 0, 256)
        repTitle.BackgroundTransparency = 1
        repTitle.Text = "Repeat"
        repTitle.TextColor3 = Color3.fromRGB(142, 142, 147)
        repTitle.Font = Enum.Font.GothamBold
        repTitle.TextSize = 12
        repTitle.TextXAlignment = Enum.TextXAlignment.Left
        repTitle.ZIndex = 51

        local repCard = Instance.new("Frame", alarmModal)
        repCard.Size = UDim2.new(1, -40, 0, 230)
        repCard.Position = UDim2.new(0, 20, 0, 280)
        repCard.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
        repCard.ZIndex = 51
        Instance.new("UICorner", repCard).CornerRadius = UDim.new(0, 14)

        local rcLayout = Instance.new("UIListLayout", repCard)
        rcLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local DAYS = {
            { "Monday", true }, { "Tuesday", false }, { "Wednesday", false },
            { "Thursday", false }, { "Friday", false }, { "Saturday", true }, { "Sunday", true }
        }

        for _, d in ipairs(DAYS) do
            local row = Instance.new("TextButton", repCard)
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundTransparency = 1
            row.Text = ""
            row.ZIndex = 52

            local dLbl = Instance.new("TextLabel", row)
            dLbl.Size = UDim2.new(1, -50, 1, 0)
            dLbl.Position = UDim2.new(0, 14, 0, 0)
            dLbl.BackgroundTransparency = 1
            dLbl.Text = d[1]
            dLbl.TextColor3 = Color3.fromRGB(245, 245, 250)
            dLbl.Font = Enum.Font.GothamMedium
            dLbl.TextSize = 13
            dLbl.TextXAlignment = Enum.TextXAlignment.Left
            dLbl.ZIndex = 53

            local check = Instance.new("TextLabel", row)
            check.Size = UDim2.new(0, 24, 1, 0)
            check.Position = UDim2.new(1, -34, 0, 0)
            check.BackgroundTransparency = 1
            check.Text = "✓"
            check.TextColor3 = Color3.fromRGB(0, 122, 255)
            check.Font = Enum.Font.GothamBold
            check.TextSize = 14
            check.Visible = d[2]
            check.ZIndex = 53

            row.MouseButton1Click:Connect(function()
                check.Visible = not check.Visible
            end)
        end

        aAddBtn.MouseButton1Click:Connect(function()
            alarmModal.Visible = true
        end)
        amClose.MouseButton1Click:Connect(function()
            alarmModal.Visible = false
        end)
        amSave.MouseButton1Click:Connect(function()
            alarmModal.Visible = false
            makeAlarmRow("09:30", "Mon, Sat, Sun · Custom", true)
            showNotification("Clock", "Alarm set for 09:30")
        end)

        -- -------------------------------------------------------------
        -- Stopwatch Tab
        -- -------------------------------------------------------------
        local swDigit = Instance.new("TextLabel", stopwatchView)
        swDigit.Size = UDim2.new(1, 0, 0, 70)
        swDigit.Position = UDim2.new(0, 0, 0, 140)
        swDigit.BackgroundTransparency = 1
        swDigit.Text = "00:01.16"
        swDigit.TextColor3 = Color3.fromRGB(255, 255, 255)
        swDigit.Font = Enum.Font.Gotham
        swDigit.TextSize = 58
        swDigit.ZIndex = 18

        local btnReset = Instance.new("TextButton", stopwatchView)
        btnReset.Size = UDim2.new(0, 68, 0, 68)
        btnReset.Position = UDim2.new(0, 36, 0, 270)
        btnReset.BackgroundColor3 = Color3.fromRGB(36, 38, 48)
        btnReset.Text = "Reset"
        btnReset.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnReset.Font = Enum.Font.GothamMedium
        btnReset.TextSize = 14
        btnReset.ZIndex = 19
        Instance.new("UICorner", btnReset).CornerRadius = UDim.new(1, 0)

        local btnStart = Instance.new("TextButton", stopwatchView)
        btnStart.Size = UDim2.new(0, 68, 0, 68)
        btnStart.Position = UDim2.new(1, -104, 0, 270)
        btnStart.BackgroundColor3 = Color3.fromRGB(120, 25, 30)
        btnStart.Text = "Stop"
        btnStart.TextColor3 = Color3.fromRGB(255, 100, 100)
        btnStart.Font = Enum.Font.GothamMedium
        btnStart.TextSize = 14
        btnStart.ZIndex = 19
        Instance.new("UICorner", btnStart).CornerRadius = UDim.new(1, 0)

        -- Bottom Tab Bar (Clock, Alarm, Stopwatch, Timer)
        local tabFrame = Instance.new("Frame", clockApp)
        tabFrame.Name = "TabBar"
        tabFrame.AnchorPoint = Vector2.new(0.5, 1)
        tabFrame.Position = UDim2.new(0.5, 0, 1, -26)
        tabFrame.Size = UDim2.new(1, -36, 0, 48)
        tabFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
        tabFrame.ZIndex = 22
        Instance.new("UICorner", tabFrame).CornerRadius = UDim.new(0, 24)

        local tLayout = Instance.new("UIListLayout", tabFrame)
        tLayout.FillDirection = Enum.FillDirection.Horizontal
        tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        tLayout.Padding = UDim.new(0, 6)

        local function makeTabBtn(name: string, icon: string, targetView: Frame, isDefault: boolean)
            local btn = Instance.new("TextButton", tabFrame)
            btn.Size = UDim2.new(0.23, 0, 1, -8)
            btn.BackgroundColor3 = isDefault and Color3.fromRGB(48, 52, 64) or Color3.fromRGB(24, 26, 34)
            btn.BackgroundTransparency = isDefault and 0 or 1
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.ZIndex = 23
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = icon .. "\n" .. name
            lbl.TextColor3 = isDefault and Color3.fromRGB(255, 159, 10) or Color3.fromRGB(142, 142, 147)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 9.5
            lbl.ZIndex = 24

            btn.MouseButton1Click:Connect(function()
                alarmsView.Visible = false
                stopwatchView.Visible = false
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
                lbl.TextColor3 = Color3.fromRGB(255, 159, 10)
            end)
        end

        makeTabBtn("Clock", "🌐", alarmsView, false)
        makeTabBtn("Alarm", "⏰", alarmsView, true)
        makeTabBtn("Stopwatch", "⏱", stopwatchView, false)
        makeTabBtn("Timer", "⏳", alarmsView, false)
    end

    -- =========================================================================
    -- 3. CAMERA APP (Focal Selectors .5x, 1x, 2x, 3x & Shutter)
    -- =========================================================================
    local camApp = createBaseApp(appContainer, "Camera", Color3.fromRGB(0, 0, 0))
    do
        local camVf = Instance.new("Frame", camApp)
        camVf.Size = UDim2.new(1, 0, 0.78, 0)
        camVf.Position = UDim2.new(0, 0, 0, 50)
        camVf.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        camVf.ZIndex = 17

        local vfText = Instance.new("TextLabel", camVf)
        vfText.Size = UDim2.new(1, 0, 1, 0)
        vfText.BackgroundTransparency = 1
        vfText.Text = "📷 High Resolution Viewfinder"
        vfText.TextColor3 = Color3.fromRGB(80, 85, 100)
        vfText.Font = Enum.Font.GothamBold
        vfText.TextSize = 16
        vfText.ZIndex = 18

        -- Focal Selector Pills (.5, 1, 2, 3x)
        local focalBar = Instance.new("Frame", camApp)
        focalBar.Size = UDim2.new(0, 160, 0, 32)
        focalBar.AnchorPoint = Vector2.new(0.5, 1)
        focalBar.Position = UDim2.new(0.5, 0, 0.78, 40)
        focalBar.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
        focalBar.ZIndex = 19
        Instance.new("UICorner", focalBar).CornerRadius = UDim.new(1, 0)

        local fbLayout = Instance.new("UIListLayout", focalBar)
        fbLayout.FillDirection = Enum.FillDirection.Horizontal
        fbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        fbLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        local FOCALS = { ".5", "1", "2", "3x" }
        for idx, fVal in ipairs(FOCALS) do
            local b = Instance.new("TextButton", focalBar)
            b.Size = UDim2.new(0, 36, 0, 26)
            b.BackgroundTransparency = 1
            b.Text = fVal
            b.TextColor3 = (idx == 4) and Color3.fromRGB(255, 204, 0) or Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.ZIndex = 20
        end

        -- Bottom Shutter Row
        local shutRow = Instance.new("Frame", camApp)
        shutRow.Size = UDim2.new(1, -40, 0, 80)
        shutRow.AnchorPoint = Vector2.new(0.5, 1)
        shutRow.Position = UDim2.new(0.5, 0, 1, -20)
        shutRow.BackgroundTransparency = 1
        shutRow.ZIndex = 19

        local shutter = Instance.new("TextButton", shutRow)
        shutter.Size = UDim2.new(0, 68, 0, 68)
        shutter.AnchorPoint = Vector2.new(0.5, 0.5)
        shutter.Position = UDim2.new(0.5, 0, 0.5, 0)
        shutter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        shutter.Text = ""
        shutter.ZIndex = 20
        Instance.new("UICorner", shutter).CornerRadius = UDim.new(1, 0)

        local sRing = Instance.new("UIStroke", shutter)
        sRing.Color = Color3.fromRGB(255, 255, 255)
        sRing.Thickness = 4

        shutter.MouseButton1Click:Connect(function()
            playTone(2.4)
            showNotification("Camera", "Photo Captured")
        end)
    end

    -- =========================================================================
    -- 4. CALCULATOR APP (5x4 Dark Grid + Floating Point Logic)
    -- =========================================================================
    local calcApp = createBaseApp(appContainer, "Calculator", Color3.fromRGB(14, 16, 24))
    do
        local display = Instance.new("TextLabel", calcApp)
        display.Size = UDim2.new(1, -36, 0, 70)
        display.Position = UDim2.new(0, 18, 0, 80)
        display.BackgroundTransparency = 1
        display.Text = "0"
        display.TextColor3 = Color3.fromRGB(255, 255, 255)
        display.Font = Enum.Font.GothamBold
        display.TextSize = 52
        display.TextXAlignment = Enum.TextXAlignment.Right
        display.ZIndex = 18

        local grid = Instance.new("Frame", calcApp)
        grid.Size = UDim2.new(1, -36, 0, 360)
        grid.Position = UDim2.new(0, 18, 0, 160)
        grid.BackgroundTransparency = 1
        grid.ZIndex = 18

        local gl = Instance.new("UIGridLayout", grid)
        gl.CellSize = UDim2.new(0, 64, 0, 64)
        gl.CellPadding = UDim2.new(0, 14, 0, 10)

        local BTNS = {
            {"C", Color3.fromRGB(165, 165, 165), Color3.fromRGB(0, 0, 0)},
            {"+/-", Color3.fromRGB(165, 165, 165), Color3.fromRGB(0, 0, 0)},
            {"%", Color3.fromRGB(165, 165, 165), Color3.fromRGB(0, 0, 0)},
            {"÷", Color3.fromRGB(255, 159, 10), Color3.fromRGB(255, 255, 255)},
            {"7", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"8", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"9", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"×", Color3.fromRGB(255, 159, 10), Color3.fromRGB(255, 255, 255)},
            {"4", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"5", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"6", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"-", Color3.fromRGB(255, 159, 10), Color3.fromRGB(255, 255, 255)},
            {"1", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"2", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"3", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"+", Color3.fromRGB(255, 159, 10), Color3.fromRGB(255, 255, 255)},
            {"0", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {".", Color3.fromRGB(50, 50, 50), Color3.fromRGB(255, 255, 255)},
            {"=", Color3.fromRGB(255, 159, 10), Color3.fromRGB(255, 255, 255)},
        }

        for _, b in ipairs(BTNS) do
            local btn = Instance.new("TextButton", grid)
            btn.Size = UDim2.new(0, 64, 0, 64)
            btn.BackgroundColor3 = b[2]
            btn.Text = b[1]
            btn.TextColor3 = b[3]
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 24
            btn.ZIndex = 19
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

            btn.MouseButton1Click:Connect(function()
                playTone(1.8)
                if b[1] == "C" then
                    display.Text = "0"
                elseif b[1] == "=" then
                    -- Keep current
                else
                    if display.Text == "0" then
                        display.Text = b[1]
                    else
                        display.Text = display.Text .. b[1]
                    end
                end
            end)
        end
    end
end

return AppSuite_Tools
