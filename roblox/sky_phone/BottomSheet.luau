--!strict
-- src/sky_phone/BottomSheet.luau
-- Pure Luau Component: Standard iOS Sliding Bottom Sheet Modal
-- Used across Photos Share Sheet, EasyShare (AirDrop), Banking Send Money, Clock Alarm Editor
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local BottomSheet = {}

export type SheetOptions = {
    height: number?,
    title: string?,
    showHandle: boolean?,
    onClose: (() -> ())?,
}

export type SheetInstance = {
    modalOverlay: Frame,
    sheetFrame: Frame,
    contentFrame: Frame,
    close: () -> (),
}

function BottomSheet.create(parent: Frame, options: SheetOptions?): SheetInstance
    local opts = options or {}
    local sheetHeight = opts.height or 380
    local showHandle = if opts.showHandle ~= nil then opts.showHandle else true

    -- 1. Dimmed Backdrop Overlay
    local modalOverlay = Instance.new("TextButton")
    modalOverlay.Name = "ModalOverlay"
    modalOverlay.Size = UDim2.new(1, 0, 1, 0)
    modalOverlay.Position = UDim2.new(0, 0, 0, 0)
    modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    modalOverlay.BackgroundTransparency = 1
    modalOverlay.Text = ""
    modalOverlay.AutoButtonColor = false
    modalOverlay.ZIndex = 80
    modalOverlay.BorderSizePixel = 0
    modalOverlay.Parent = parent

    -- 2. Sheet Frame (starts offscreen below parent)
    local sheetFrame = Instance.new("Frame")
    sheetFrame.Name = "SheetFrame"
    sheetFrame.Size = UDim2.new(1, 0, 0, sheetHeight)
    sheetFrame.Position = UDim2.new(0, 0, 1, 0)
    sheetFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    sheetFrame.BorderSizePixel = 0
    sheetFrame.ZIndex = 82
    sheetFrame.ClipsDescendants = true
    sheetFrame.Parent = modalOverlay

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 28)
    corner.Parent = sheetFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.88
    stroke.Thickness = 1
    stroke.Parent = sheetFrame

    -- 3. Drag Handle
    if showHandle then
        local handle = Instance.new("Frame")
        handle.Name = "DragHandle"
        handle.Size = UDim2.new(0, 38, 0, 5)
        handle.Position = UDim2.new(0.5, -19, 0, 10)
        handle.BackgroundColor3 = Color3.fromRGB(90, 92, 100)
        handle.BorderSizePixel = 0
        handle.ZIndex = 83
        Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)
        handle.Parent = sheetFrame
    end

    -- 4. Content Container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, if showHandle then -22 else 0)
    contentFrame.Position = UDim2.new(0, 0, 0, if showHandle then 22 else 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 83
    contentFrame.Parent = sheetFrame

    -- Animate In
    local tweenInfoIn = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(modalOverlay, tweenInfoIn, { BackgroundTransparency = 0.52 }):Play()
    TweenService:Create(sheetFrame, tweenInfoIn, { Position = UDim2.new(0, 0, 1, -sheetHeight) }):Play()

    local isClosing = false
    local function close()
        if isClosing then return end
        isClosing = true
        local tweenInfoOut = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local t1 = TweenService:Create(modalOverlay, tweenInfoOut, { BackgroundTransparency = 1 })
        local t2 = TweenService:Create(sheetFrame, tweenInfoOut, { Position = UDim2.new(0, 0, 1, 0) })
        t1:Play()
        t2:Play()
        task.delay(0.23, function()
            if opts.onClose then opts.onClose() end
            modalOverlay:Destroy()
        end)
    end

    modalOverlay.MouseButton1Click:Connect(function()
        close()
    end)

    return {
        modalOverlay = modalOverlay,
        sheetFrame = sheetFrame,
        contentFrame = contentFrame,
        close = close,
    }
end

return BottomSheet
