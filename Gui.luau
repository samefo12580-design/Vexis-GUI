-- ==========================================================
-- VORTEX UI FRAMEWORK (TRANSLUCENT / GLASS STYLE - FULL FEATURES)
-- Keybind: 'Right Control' (or configured key) to Hide/Show Menu
-- ==========================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ประกาศ forward-reference ไว้ก่อนบนสุด กันปัญหา error กรณีมีการเรียกใช้ WindowMT/TabMT
-- ก่อนที่โค้ดด้านล่างจะรันมาถึงจุดที่นิยามจริง (โครงสร้างเดิมพึ่ง global เฉยๆ อันนี้ทำให้ปลอดภัยขึ้น)
local WindowMT, TabMT

--// ธีมสีทั้งหมดที่มีให้ (สลับได้ตอนรันจริง ไม่ต้องแก้โค้ด)
local ThemePresets = {
    blue = {
        DisplayName = "Default Blue",
        Background = Color3.fromRGB(18, 18, 18),  Header = Color3.fromRGB(24, 24, 28),
        Sidebar    = Color3.fromRGB(14, 14, 14),  Card   = Color3.fromRGB(24, 24, 24),
        CardHover  = Color3.fromRGB(32, 32, 40),  Accent = Color3.fromRGB(255, 255, 255),
        Accent2    = Color3.fromRGB(138, 90, 255),
        Text       = Color3.fromRGB(240, 240, 240), SubText = Color3.fromRGB(130, 130, 130),
        Stroke     = Color3.fromRGB(45, 45, 45),
        Success    = Color3.fromRGB(90, 200, 130), Error = Color3.fromRGB(235, 65, 65),
    },
    violet = {
        DisplayName = "Neon Violet",
        Background = Color3.fromRGB(20, 16, 24),  Header = Color3.fromRGB(26, 20, 34),
        Sidebar    = Color3.fromRGB(16, 12, 22),  Card   = Color3.fromRGB(31, 24, 40),
        CardHover  = Color3.fromRGB(42, 32, 54),  Accent = Color3.fromRGB(160, 107, 255),
        Accent2    = Color3.fromRGB(255, 94, 196),
        Text       = Color3.fromRGB(240, 234, 255), SubText = Color3.fromRGB(163, 150, 194),
        Stroke     = Color3.fromRGB(51, 40, 69),
        Success    = Color3.fromRGB(90, 200, 130), Error = Color3.fromRGB(220, 90, 90),
    },
    emerald = {
        DisplayName = "Emerald Noir",
        Background = Color3.fromRGB(15, 22, 19),  Header = Color3.fromRGB(19, 30, 26),
        Sidebar    = Color3.fromRGB(11, 16, 14),  Card   = Color3.fromRGB(24, 36, 32),
        CardHover  = Color3.fromRGB(31, 48, 42),  Accent = Color3.fromRGB(51, 201, 143),
        Accent2    = Color3.fromRGB(212, 175, 55),
        Text       = Color3.fromRGB(234, 255, 243), SubText = Color3.fromRGB(143, 173, 163),
        Stroke     = Color3.fromRGB(40, 56, 47),
        Success    = Color3.fromRGB(90, 200, 130), Error = Color3.fromRGB(220, 90, 90),
    },
    sunset = {
        DisplayName = "Synthwave",
        Background = Color3.fromRGB(20, 10, 26),  Header = Color3.fromRGB(28, 15, 38),
        Sidebar    = Color3.fromRGB(16, 7, 26),   Card   = Color3.fromRGB(36, 17, 48),
        CardHover  = Color3.fromRGB(48, 23, 64),  Accent = Color3.fromRGB(255, 77, 148),
        Accent2    = Color3.fromRGB(255, 180, 68),
        Text       = Color3.fromRGB(253, 238, 255), SubText = Color3.fromRGB(185, 146, 201),
        Stroke     = Color3.fromRGB(58, 31, 76),
        Success    = Color3.fromRGB(90, 200, 130), Error = Color3.fromRGB(220, 90, 90),
    },
    amber = {
        DisplayName = "Amber Gold",
        Background = Color3.fromRGB(21, 18, 12),  Header = Color3.fromRGB(28, 23, 16),
        Sidebar    = Color3.fromRGB(16, 13, 8),   Card   = Color3.fromRGB(36, 29, 18),
        CardHover  = Color3.fromRGB(48, 38, 23),  Accent = Color3.fromRGB(224, 168, 61),
        Accent2    = Color3.fromRGB(138, 90, 44),
        Text       = Color3.fromRGB(251, 241, 222), SubText = Color3.fromRGB(182, 166, 137),
        Stroke     = Color3.fromRGB(58, 47, 28),
        Success    = Color3.fromRGB(90, 200, 130), Error = Color3.fromRGB(220, 90, 90),
    },
}

-- Theme คือตารางสีที่กำลังใช้งานอยู่จริง
local Theme = {}
for k, v in pairs(ThemePresets.blue) do Theme[k] = v end

local function tween(obj, properties, duration, easingStyle)
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    local info = TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out)
    local anim = TweenService:Create(obj, info, properties)
    anim:Play()
    return anim
end

-- ผูกสีของ Instance เข้ากับ "คีย์" ของ Theme ปัจจุบันทันที พร้อมจดจำคีย์นั้นไว้ใน Attribute
-- ทำให้ตอนเปลี่ยนธีม เรารู้แน่ชัด 100% ว่า property นี้ต้องเปลี่ยนเป็นสีไหนของธีมใหม่
-- (ไม่ต้องเดาจาก hex สีเดิมแบบระบบเก่า ซึ่งพลาดง่ายถ้าสีชนกันหรือ element ตั้งสีแบบ hardcode)
local function bindColor(inst, property, themeKey)
    inst[property] = Theme[themeKey]
    inst:SetAttribute("Bind_" .. property, themeKey)
end

-- ใช้ตอนที่ต้อง Tween สีเอง (เช่น Toggle switch ที่ต้องอนิเมชั่นนุ่มๆ)
-- แค่จดจำคีย์ธีมไว้ใน Attribute โดยไม่ไปยุ่งกับค่าที่ Tween กำลังเคลื่อนอยู่
local function tagBind(inst, property, themeKey)
    inst:SetAttribute("Bind_" .. property, themeKey)
end

local function makeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

-- ระบบเปลี่ยนธีมแบบ Live (รีเฟรชสี UI ทั้งหน้าจอทันทีพร้อม Overlay นุ่มนวล)
-- อ่าน Attribute "Bind_<Property>" ที่ bindColor/tagBind ฝากไว้ที่ทุก Instance
-- แล้วเซ็ตสีให้ตรงกับ Theme ปัจจุบันแบบตรงไปตรงมา ไม่ต้องเดาจาก hex สีเดิมอีกต่อไป
-- วิธีนี้แม่นยำ 100% ไม่ว่าธีมจะมีสีชนกันหรือ element จะซับซ้อนแค่ไหน
local function repaintTheme(screenGui)
    if not screenGui then return end

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.ZIndex = 200
    overlay.Parent = screenGui
    tween(overlay, {BackgroundTransparency = 0.55}, 0.09)

    task.delay(0.1, function()
        for _, inst in ipairs(screenGui:GetDescendants()) do
            for attrName, themeKey in pairs(inst:GetAttributes()) do
                local property = attrName:match("^Bind_(.+)$")
                if property and Theme[themeKey] ~= nil then
                    local ok = pcall(function()
                        inst[property] = Theme[themeKey]
                    end)
                    -- ok ไม่ถูกใช้ต่อ แต่ pcall ป้องกันไม่ให้ Instance ที่ property หลุดไปแล้วทำให้ทั้ง loop พัง
                end
            end
        end
        tween(overlay, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.22, function() overlay:Destroy() end)
    end)
end

local function fileFunctionsExist()
    return writefile ~= nil and readfile ~= nil and isfile ~= nil
end

local Library = {}
Library.__index = Library
Library.Themes = ThemePresets

local NotifHolder
local TooltipHolder, TooltipFrame, TooltipLabel

function Library:Notify(title, text, duration)
    duration = duration or 3
    if not NotifHolder then return end

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 0)
    Card.AutomaticSize = Enum.AutomaticSize.Y
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.35
    Card.ClipsDescendants = true
    Card.Parent = NotifHolder
    
    local Corner = Instance.new("UICorner", Card) Corner.CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local Padding = Instance.new("UIPadding", Card)
    Padding.PaddingTop = UDim.new(0, 10) Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 12) Padding.PaddingRight = UDim.new(0, 12)

    local Layout = Instance.new("UIListLayout", Card)
    Layout.Padding = UDim.new(0, 2) Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = title or "แจ้งเตือน"
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, 0, 0, 18)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local DescLbl = Instance.new("TextLabel", Card)
    DescLbl.Text = text or ""
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextSize = 11
    bindColor(DescLbl, "TextColor3", "SubText")
    DescLbl.BackgroundTransparency = 1
    DescLbl.Size = UDim2.new(1, 0, 0, 0)
    DescLbl.AutomaticSize = Enum.AutomaticSize.Y
    DescLbl.TextWrapped = true
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left

    task.delay(duration, function()
        tween(Card, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        Card:Destroy()
    end)
end

function Library:AddTooltip(guiObject, text)
    if not guiObject or not TooltipFrame then return end
    guiObject.MouseEnter:Connect(function()
        TooltipLabel.Text = text
        TooltipFrame.Visible = true
    end)
    guiObject.MouseLeave:Connect(function()
        TooltipFrame.Visible = false
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TooltipFrame.Position = UDim2.new(0, input.Position.X + 16, 0, input.Position.Y + 16)
        end
    end)
end

function Library:GetCharacterCFrame()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.CFrame or nil
end

function Library:GetCharacterCFrameString()
    local cf = self:GetCharacterCFrame()
    if not cf then return nil end
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return string.format(
        "CFrame.new(%.3f, %.3f, %.3f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f)",
        x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22
    )
end

function Library:CopyCharacterCFrame()
    local cfStr = self:GetCharacterCFrameString()
    if not cfStr then
        self:Notify("CFrame", "ไม่พบตัวละคร (Character) ในตอนนี้", 3)
        return false, nil
    end
    local copied = setclipboard and pcall(function() setclipboard(cfStr) end)
    if copied then
        self:Notify("CFrame", "คัดลอกลงคลิปบอร์ดแล้ว", 2)
    else
        self:Notify("CFrame", "Executor นี้ไม่รองรับ setclipboard: " .. cfStr, 5)
    end
    return copied or false, cfStr
end

function Library:CreateWindow(config)
    if CoreGui:FindFirstChild("VortexKarpiUI") then
        CoreGui:FindFirstChild("VortexKarpiUI"):Destroy()
    end

    config = config or {}
    local titleText = config.Title or config[1] or "Karpiware 6.1.0"
    local subtitleText = config.Subtitle or "Build - Paid (Stable) | Universal"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local configName = config.ConfigName or "KarpiwareConfig"
    local themeKey = config.Theme or "blue"

    -- ID ไอคอนโลโก้ที่จะไปโชว์มุมซ้ายบนของ TopBar ข้างชื่อ Hub
    -- เปลี่ยนได้ทุกครั้งที่เรียกใช้งานผ่าน config.Icon = "rbxassetid://ตัวเลข"
    local iconId = config.Icon or "rbxassetid://75491720746957"

    if ThemePresets[themeKey] then
        for k, v in pairs(ThemePresets[themeKey]) do Theme[k] = v end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VortexKarpiUI"
    ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
    ScreenGui.ResetOnSpawn = false

    -- ที่เก็บ Notification
    NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "Notifications"
    NotifHolder.AnchorPoint = Vector2.new(1, 0)
    NotifHolder.Position = UDim2.new(1, -16, 0, 16)
    NotifHolder.Size = UDim2.new(0, 260, 1, -32)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui
    local NotifLayout = Instance.new("UIListLayout", NotifHolder)
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Tooltip ลอยตามเมาส์
    TooltipFrame = Instance.new("Frame")
    TooltipFrame.Name = "Tooltip"
    bindColor(TooltipFrame, "BackgroundColor3", "Card")
    TooltipFrame.BackgroundTransparency = 0.2
    TooltipFrame.Visible = false
    TooltipFrame.Size = UDim2.new(0, 0, 0, 0)
    TooltipFrame.AutomaticSize = Enum.AutomaticSize.XY
    TooltipFrame.ZIndex = 100
    TooltipFrame.Parent = ScreenGui
    Instance.new("UICorner", TooltipFrame).CornerRadius = UDim.new(0, 5)
    local TooltipStroke = Instance.new("UIStroke", TooltipFrame) bindColor(TooltipStroke, "Color", "Stroke") TooltipStroke.Transparency = 0.4
    
    local TooltipPadding = Instance.new("UIPadding", TooltipFrame)
    TooltipPadding.PaddingTop = UDim.new(0, 6) TooltipPadding.PaddingBottom = UDim.new(0, 6)
    TooltipPadding.PaddingLeft = UDim.new(0, 8) TooltipPadding.PaddingRight = UDim.new(0, 8)

    TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Text = ""
    TooltipLabel.Font = Enum.Font.Gotham
    TooltipLabel.TextSize = 11
    bindColor(TooltipLabel, "TextColor3", "Text")
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.Size = UDim2.new(0, 0, 0, 0)
    TooltipLabel.AutomaticSize = Enum.AutomaticSize.XY
    TooltipLabel.ZIndex = 100
    TooltipLabel.Parent = TooltipFrame

    -- ขนาดหน้าต่างแบบ Responsive: ใช้ Scale (%) ของจอเป็นหลัก แล้ว "เพดานบน-ล่าง" ด้วย UISizeConstraint
    -- เพื่อไม่ให้เล็กเกินจนใช้งานไม่ได้ (มือถือ) และไม่ให้ใหญ่เกินไปจนดูแปลกบนจอใหญ่ (เดสก์ท็อป/มอนิเตอร์)
    -- วิธีนี้ทำงานถูกต้องในทุกกรณีโดยไม่ต้องเดาว่าเป็นอุปกรณ์ประเภทไหน (มือถือ, แท็บเล็ต, PC resize หน้าต่างเล็ก, ฯลฯ)
    local MainFrame = Instance.new("CanvasGroup")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0.92, 0, 0.85, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    bindColor(MainFrame, "BackgroundColor3", "Background")
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainSizeConstraint = Instance.new("UISizeConstraint")
    MainSizeConstraint.MinSize = Vector2.new(300, 380) -- เล็กสุดที่ยังกดใช้งานได้สะดวกบนมือถือจอเล็ก
    MainSizeConstraint.MaxSize = Vector2.new(680, 460) -- ใหญ่สุดเท่าดีไซน์เดิม กันขยายเกินบนมอนิเตอร์ใหญ่
    MainSizeConstraint.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    bindColor(UIStroke, "Color", "Stroke")
    UIStroke.Transparency = 0.3
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- ================= FULL-WIDTH TOPBAR =================
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundTransparency = 1
    TopBar.ZIndex = 10
    TopBar.Parent = MainFrame

    local BrandFrame = Instance.new("Frame")
    BrandFrame.Name = "BrandFrame"
    BrandFrame.Size = UDim2.new(1, -92, 1, 0) -- กว้างเท่าที่เหลือจริงหลังหักพื้นที่ปุ่มปิด/ย่อ (60px + ระยะขอบ) กันชนกันตอนหน้าต่างแคบ
    BrandFrame.Position = UDim2.new(0, 16, 0, 0)
    BrandFrame.BackgroundTransparency = 1
    BrandFrame.ZIndex = 11
    BrandFrame.Parent = TopBar

    -- ================= BRAND ICON (โลโก้ Hub) =================
    -- จุดสำหรับใส่ไอคอน: เปลี่ยนรูปได้ผ่าน config.Icon ตอนเรียก CreateWindow
    local BrandIcon = Instance.new("ImageLabel")
    BrandIcon.Name = "BrandIcon"
    BrandIcon.Size = UDim2.new(0, 30, 0, 30)
    BrandIcon.Position = UDim2.new(0, 0, 0.5, -15)
    BrandIcon.BackgroundTransparency = 1
    BrandIcon.Image = iconId
    BrandIcon.ScaleType = Enum.ScaleType.Fit
    BrandIcon.ZIndex = 12
    BrandIcon.Parent = BrandFrame

    local BrandIconCorner = Instance.new("UICorner")
    BrandIconCorner.CornerRadius = UDim.new(0, 6)
    BrandIconCorner.Parent = BrandIcon

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -38, 0, 18)
    TitleLabel.Position = UDim2.new(0, 38, 0, 7)
    TitleLabel.Text = titleText
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    bindColor(TitleLabel, "TextColor3", "Text")
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.ZIndex = 12
    TitleLabel.Parent = BrandFrame

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "SubtitleLabel"
    SubtitleLabel.Size = UDim2.new(1, -38, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 38, 0, 25)
    SubtitleLabel.Text = subtitleText
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextSize = 10
    bindColor(SubtitleLabel, "TextColor3", "SubText")
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.ZIndex = 12
    SubtitleLabel.Parent = BrandFrame

    local WindowControls = Instance.new("Frame")
    WindowControls.Name = "WindowControls"
    WindowControls.Size = UDim2.new(0, 60, 1, 0)
    WindowControls.Position = UDim2.new(1, -68, 0, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.ZIndex = 11
    WindowControls.Parent = TopBar

    local ControlList = Instance.new("UIListLayout")
    ControlList.FillDirection = Enum.FillDirection.Horizontal
    ControlList.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlList.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlList.Padding = UDim.new(0, 6)
    ControlList.Parent = WindowControls

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    bindColor(MinimizeBtn, "BackgroundColor3", "Card")
    MinimizeBtn.BackgroundTransparency = 0.3
    MinimizeBtn.Text = "-"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 14
    bindColor(MinimizeBtn, "TextColor3", "SubText")
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.ZIndex = 12
    MinimizeBtn.Parent = WindowControls
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    bindColor(CloseBtn, "BackgroundColor3", "Card")
    CloseBtn.BackgroundTransparency = 0.3
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    bindColor(CloseBtn, "TextColor3", "SubText")
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 12
    CloseBtn.Parent = WindowControls
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    makeDraggable(TopBar, MainFrame)

    local TopDivider = Instance.new("Frame")
    TopDivider.Size = UDim2.new(1, 0, 0, 1)
    TopDivider.Position = UDim2.new(0, 0, 0, 48)
    bindColor(TopDivider, "BackgroundColor3", "Stroke")
    TopDivider.BackgroundTransparency = 0.3
    TopDivider.BorderSizePixel = 0
    TopDivider.Parent = MainFrame

    -- ================= LEFT SIDEBAR =================
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0.3, 0, 1, -49) -- ใช้ % ของความกว้าง MainFrame แทนพิกเซลตายตัว กันทับ Content ตอนหน้าต่างแคบ
    Sidebar.Position = UDim2.new(0, 0, 0, 49)
    bindColor(Sidebar, "BackgroundColor3", "Sidebar")
    Sidebar.BackgroundTransparency = 0.25
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    bindColor(SidebarDivider, "BackgroundColor3", "Stroke")
    SidebarDivider.BackgroundTransparency = 0.3
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -24, 1, -85)
    TabContainer.Position = UDim2.new(0, 12, 0, 12)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabContainer

    -- ================= USER PROFILE BOX =================
    local UserProfileFrame = Instance.new("Frame")
    UserProfileFrame.Name = "UserProfile"
    UserProfileFrame.Size = UDim2.new(1, -24, 0, 52)
    UserProfileFrame.Position = UDim2.new(0, 12, 1, -62)
    bindColor(UserProfileFrame, "BackgroundColor3", "Card")
    UserProfileFrame.BackgroundTransparency = 0.35
    UserProfileFrame.BorderSizePixel = 0
    UserProfileFrame.Parent = Sidebar

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = UserProfileFrame

    local ProfileStroke = Instance.new("UIStroke")
    bindColor(ProfileStroke, "Color", "Stroke")
    ProfileStroke.Transparency = 0.4
    ProfileStroke.Thickness = 1
    ProfileStroke.Parent = UserProfileFrame

    local AvatarBgCircle = Instance.new("Frame")
    AvatarBgCircle.Size = UDim2.new(0, 36, 0, 36)
    AvatarBgCircle.Position = UDim2.new(0, 8, 0.5, -18)
    AvatarBgCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AvatarBgCircle.BackgroundTransparency = 0.88
    AvatarBgCircle.BorderSizePixel = 0
    AvatarBgCircle.Parent = UserProfileFrame
    Instance.new("UICorner", AvatarBgCircle).CornerRadius = UDim.new(1, 0)

    local AvatarBgStroke = Instance.new("UIStroke")
    AvatarBgStroke.Color = Color3.fromRGB(255, 255, 255)
    AvatarBgStroke.Transparency = 0.7
    AvatarBgStroke.Thickness = 1
    AvatarBgStroke.Parent = AvatarBgCircle

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 32, 0, 32)
    AvatarImage.Position = UDim2.new(0.5, -16, 0.5, -16)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Parent = AvatarBgCircle
    Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

    pcall(function()
        local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        AvatarImage.Image = content
    end)

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(1, -54, 0, 14)
    UsernameLabel.Position = UDim2.new(0, 50, 0, 9)
    UsernameLabel.Text = LocalPlayer.DisplayName
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextSize = 11
    bindColor(UsernameLabel, "TextColor3", "Text")
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Parent = UserProfileFrame

    local UptimeLabel = Instance.new("TextLabel")
    UptimeLabel.Size = UDim2.new(1, -54, 0, 14)
    UptimeLabel.Position = UDim2.new(0, 50, 0, 26)
    UptimeLabel.Text = "Uptime: 00:00:00"
    UptimeLabel.Font = Enum.Font.Gotham
    UptimeLabel.TextSize = 9
    bindColor(UptimeLabel, "TextColor3", "SubText")
    UptimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    UptimeLabel.BackgroundTransparency = 1
    UptimeLabel.Parent = UserProfileFrame

    task.spawn(function()
        local startTime = tick()
        while task.wait(1) do
            if not UptimeLabel or not UptimeLabel.Parent then break end
            local elapsed = math.floor(tick() - startTime)
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = elapsed % 60
            UptimeLabel.Text = string.format("Uptime: %02d:%02d:%02d", hours, minutes, seconds)
        end
    end)

    -- ================= RIGHT CONTENT AREA =================
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(0.7, -16, 1, -59) -- ให้สัมพันธ์กับ Sidebar 30% ที่เหลืออีก 70% หัก padding เล็กน้อย
    ContentContainer.Position = UDim2.new(0.3, 8, 0, 54)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- Exit Confirmation Modal
    local ModalOverlay = Instance.new("Frame")
    ModalOverlay.Name = "ModalOverlay"
    ModalOverlay.Size = UDim2.new(1, 0, 1, 0)
    ModalOverlay.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    ModalOverlay.BackgroundTransparency = 0.5
    ModalOverlay.Visible = false
    ModalOverlay.ZIndex = 100
    ModalOverlay.Parent = MainFrame

    local ModalCard = Instance.new("Frame")
    ModalCard.Size = UDim2.new(0, 260, 0, 130)
    ModalCard.Position = UDim2.new(0.5, -130, 0.5, -65)
    bindColor(ModalCard, "BackgroundColor3", "Background")
    ModalCard.BackgroundTransparency = 0.1
    ModalCard.ZIndex = 101
    ModalCard.Parent = ModalOverlay
    Instance.new("UICorner", ModalCard).CornerRadius = UDim.new(0, 8)
    local ModalStroke = Instance.new("UIStroke") bindColor(ModalStroke, "Color", "Stroke") ModalStroke.Transparency = 0.3 ModalStroke.Parent = ModalCard

    local ModalTitle = Instance.new("TextLabel")
    ModalTitle.Size = UDim2.new(1, -20, 0, 24)
    ModalTitle.Position = UDim2.new(0, 10, 0, 14)
    ModalTitle.Text = "Exit Confirmation"
    ModalTitle.Font = Enum.Font.GothamBold
    ModalTitle.TextSize = 13
    bindColor(ModalTitle, "TextColor3", "Text")
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.ZIndex = 102
    ModalTitle.Parent = ModalCard

    local ModalDesc = Instance.new("TextLabel")
    ModalDesc.Size = UDim2.new(1, -24, 0, 30)
    ModalDesc.Position = UDim2.new(0, 12, 0, 38)
    ModalDesc.Text = "Are you sure you want to close the menu?"
    ModalDesc.Font = Enum.Font.Gotham
    ModalDesc.TextSize = 11
    bindColor(ModalDesc, "TextColor3", "SubText")
    ModalDesc.BackgroundTransparency = 1
    ModalDesc.ZIndex = 102
    ModalDesc.Parent = ModalCard

    local ModalBtnContainer = Instance.new("Frame")
    ModalBtnContainer.Size = UDim2.new(1, -20, 0, 30)
    ModalBtnContainer.Position = UDim2.new(0, 10, 1, -40)
    ModalBtnContainer.BackgroundTransparency = 1
    ModalBtnContainer.ZIndex = 102
    ModalBtnContainer.Parent = ModalCard

    local ConfirmExitBtn = Instance.new("TextButton")
    ConfirmExitBtn.Size = UDim2.new(0.48, 0, 1, 0)
    bindColor(ConfirmExitBtn, "BackgroundColor3", "Error")
    ConfirmExitBtn.BackgroundTransparency = 0.1
    ConfirmExitBtn.Text = "Close"
    ConfirmExitBtn.Font = Enum.Font.GothamBold
    ConfirmExitBtn.TextSize = 11
    ConfirmExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ConfirmExitBtn.ZIndex = 103
    ConfirmExitBtn.Parent = ModalBtnContainer
    Instance.new("UICorner", ConfirmExitBtn).CornerRadius = UDim.new(0, 6)

    local CancelExitBtn = Instance.new("TextButton")
    CancelExitBtn.Size = UDim2.new(0.48, 0, 1, 0)
    CancelExitBtn.Position = UDim2.new(0.52, 0, 0, 0)
    bindColor(CancelExitBtn, "BackgroundColor3", "Card")
    CancelExitBtn.BackgroundTransparency = 0.3
    CancelExitBtn.Text = "Cancel"
    CancelExitBtn.Font = Enum.Font.GothamMedium
    CancelExitBtn.TextSize = 11
    bindColor(CancelExitBtn, "TextColor3", "Text")
    CancelExitBtn.ZIndex = 103
    CancelExitBtn.Parent = ModalBtnContainer
    Instance.new("UICorner", CancelExitBtn).CornerRadius = UDim.new(0, 6)

    local isMinimized = false
    local originalSize = MainFrame.Size
    local originalPosition = MainFrame.Position -- ตำแหน่งกลางจอตอนสร้าง ใช้ดึงหน้าต่างกลับมาตอนกด + (กัน โป่งออกนอกจอถ้าลากไปติดขอบไว้ก่อนย่อ)
    local function setMinimized(state)
        isMinimized = state
        if isMinimized then
            Sidebar.Visible = false
            ContentContainer.Visible = false
            TopDivider.Visible = false
            MinimizeBtn.Text = "+"
            -- ปลดล็อกเพดานความสูงขั้นต่ำชั่วคราว ไม่งั้น UISizeConstraint จะดันความสูงกลับไม่ให้ต่ำกว่า 380px
            -- ทำให้ย่อได้แค่ความกว้าง (310 > 300 ผ่าน) แต่ย่อความสูงไม่ได้ (48 < 380 ติด constraint)
            MainSizeConstraint.MinSize = Vector2.new(0, 0)
            -- ปุ่ม "-": คงตำแหน่งเดิมไว้ตามที่ลากไปวาง ไม่ขยับ (ตามที่ขอ)
            tween(MainFrame, {Size = UDim2.new(0, 310, 0, 48)})
        else
            MinimizeBtn.Text = "-"
            -- คืนเพดานขั้นต่ำกลับก่อนขยาย ป้องกันหน้าต่างเล็กเกินไปตอนใช้งานปกติ
            MainSizeConstraint.MinSize = Vector2.new(300, 380)
            -- ปุ่ม "+": ดึงหน้าต่างกลับมากลางจอเสมอ พร้อมขยายขนาด กันโป่งออกนอกจอเวลาที่ก่อนหน้านี้ถูกลากไปติดขอบจอไว้
            local anim = tween(MainFrame, {Size = originalSize, Position = originalPosition})
            anim.Completed:Connect(function()
                if not isMinimized then
                    Sidebar.Visible = true
                    ContentContainer.Visible = true
                    TopDivider.Visible = true
                end
            end)
        end
    end

    MinimizeBtn.MouseButton1Click:Connect(function() setMinimized(not isMinimized) end)
    CloseBtn.MouseButton1Click:Connect(function()
        if isMinimized then setMinimized(false) end
        ModalOverlay.Visible = true
    end)
    CancelExitBtn.MouseButton1Click:Connect(function() ModalOverlay.Visible = false end)
    ConfirmExitBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and toggleKey and input.KeyCode == toggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Window = setmetatable({}, {__index = WindowMT})
    Window.ScreenGui = ScreenGui
    Window.Main = MainFrame
    Window.Sidebar = Sidebar
    Window.TabListHolder = TabContainer
    Window.Content = ContentContainer
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Flags = {}
    Window.ConfigName = configName
    Window.Minimized = false
    Window.CurrentTheme = themeKey
    Window.ToggleKey = toggleKey
    Window.BrandIcon = BrandIcon

    Window.AutoSaveEnabled = true
    task.defer(function()
        if fileFunctionsExist() and isfile(Window.ConfigName .. ".json") then
            Window:LoadConfig(true)
        end
    end)

    return Window
end

--=========================================================
--  WINDOW METHODS
--=========================================================
WindowMT = {}
WindowMT.__index = WindowMT

-- เปลี่ยนไอคอนโลโก้บน TopBar ทีหลังได้ ไม่ต้องสร้างหน้าต่างใหม่
function WindowMT:SetIcon(iconId)
    if self.BrandIcon then
        self.BrandIcon.Image = iconId
    end
end

function WindowMT:CreateTab(name, icon)
    local self = self

    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 34)
    bindColor(TabButton, "BackgroundColor3", "Card")
    TabButton.BackgroundTransparency = 1
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabListHolder
    Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

    -- ไอคอนของแต่ละแท็บ: ใส่ผ่านพารามิเตอร์ตัวที่ 2 เช่น Window:CreateTab("Main", "rbxassetid://75491720746957")
    local hasIcon = icon ~= nil and icon ~= ""
    local IconImg
    if hasIcon then
        IconImg = Instance.new("ImageLabel", TabButton)
        IconImg.Image = icon
        IconImg.BackgroundTransparency = 1
        IconImg.Size = UDim2.new(0, 16, 0, 16)
        IconImg.Position = UDim2.new(0, 10, 0.5, -8)
        IconImg.ScaleType = Enum.ScaleType.Fit
        bindColor(IconImg, "ImageColor3", "SubText")
    end

    local Label = Instance.new("TextLabel", TabButton)
    Label.Name = "Label"
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    bindColor(Label, "TextColor3", "SubText")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, hasIcon and -34 or -12, 1, 0)
    Label.Position = UDim2.new(0, hasIcon and 34 or 12, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 2
    bindColor(Page, "ScrollBarImageColor3", "Stroke")
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = self.Content

    local CardSection = Instance.new("Frame")
    CardSection.Size = UDim2.new(1, -8, 0, 0)
    bindColor(CardSection, "BackgroundColor3", "Card")
    CardSection.BackgroundTransparency = 0.35
    CardSection.Parent = Page
    
    local CardCorner = Instance.new("UICorner", CardSection)
    CardCorner.CornerRadius = UDim.new(0, 8)

    local CardStroke = Instance.new("UIStroke", CardSection)
    bindColor(CardStroke, "Color", "Stroke")
    CardStroke.Transparency = 0.4
    CardStroke.Thickness = 1

    local CardLayout = Instance.new("UIListLayout", CardSection)
    CardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CardLayout.Padding = UDim.new(0, 12)

    local CardPadding = Instance.new("UIPadding", CardSection)
    CardPadding.PaddingTop = UDim.new(0, 14)
    CardPadding.PaddingBottom = UDim.new(0, 14)
    CardPadding.PaddingLeft = UDim.new(0, 14)
    CardPadding.PaddingRight = UDim.new(0, 14)

    CardLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        CardSection.Size = UDim2.new(1, -8, 0, CardLayout.AbsoluteContentSize.Y + 28)
        Page.CanvasSize = UDim2.new(0, 0, 0, CardSection.Size.Y.Offset + 10)
    end)

    local Tab = setmetatable({}, {__index = TabMT})
    Tab.Page = CardSection
    Tab.MainPage = Page
    Tab.Button = TabButton
    Tab.Name = name
    Tab.Window = self

    local function selectTab()
        for _, t in pairs(self.Tabs) do
            t.MainPage.Visible = false
            tween(t.Button, {BackgroundTransparency = 1}, 0.15)
            bindColor(t.Button.Label, "TextColor3", "SubText")
            if t.IconImg then bindColor(t.IconImg, "ImageColor3", "SubText") end
        end
        Page.Visible = true
        tween(TabButton, {BackgroundTransparency = 0.3}, 0.15)
        bindColor(Label, "TextColor3", "Text")
        if IconImg then bindColor(IconImg, "ImageColor3", "Accent") end
        self.ActiveTab = Tab
    end

    Tab.IconImg = IconImg
    TabButton.MouseButton1Click:Connect(selectTab)
    table.insert(self.Tabs, Tab)
    if #self.Tabs == 1 then selectTab() end

    return Tab
end

function WindowMT:SaveConfig(silent)
    if not fileFunctionsExist() then
        if not silent then Library:Notify("Config", "Executor นี้ไม่รองรับการบันทึกไฟล์", 3) end
        return
    end
    local data = {}
    for flag, element in pairs(self.Flags) do
        local ok, value = pcall(function() return element:Get() end)
        if ok then data[flag] = value end
    end
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then
        pcall(function() writefile(self.ConfigName .. ".json", encoded) end)
        if not silent then Library:Notify("Config", "บันทึก Config สำเร็จ", 2) end
    end
end

function WindowMT:_AutoSave()
    if not self.AutoSaveEnabled then return end
    if self._autoSavePending then return end
    self._autoSavePending = true
    task.delay(0.6, function()
        self._autoSavePending = false
        self:SaveConfig(true)
    end)
end

function WindowMT:LoadConfig(silent)
    if not fileFunctionsExist() then
        if not silent then Library:Notify("Config", "Executor นี้ไม่รองรับการโหลดไฟล์", 3) end
        return
    end
    if not isfile(self.ConfigName .. ".json") then
        if not silent then Library:Notify("Config", "ไม่พบไฟล์ Config", 2) end
        return
    end
    local ok, raw = pcall(function() return readfile(self.ConfigName .. ".json") end)
    if not ok then return end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 then return end
    for flag, value in pairs(data) do
        local element = self.Flags[flag]
        if element then pcall(function() element:Set(value) end) end
    end
    if not silent then Library:Notify("Config", "โหลด Config สำเร็จ", 2) end
end

function WindowMT:SetTheme(themeKey)
    local preset = ThemePresets[themeKey]
    if not preset then return end

    for k, v in pairs(preset) do Theme[k] = v end
    self.CurrentTheme = themeKey

    repaintTheme(self.ScreenGui)
    Library:Notify("ธีม", "เปลี่ยนเป็น " .. (preset.DisplayName or themeKey), 2)
end

function WindowMT:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

--=========================================================
--  TAB METHODS
--=========================================================
TabMT = {}
TabMT.__index = TabMT

local function registerFlag(tab, flag, element)
    if flag then tab.Window.Flags[flag] = element end
end

function TabMT:CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    bindColor(Label, "TextColor3", "SubText")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = self.Page
    return Label
end

function TabMT:CreateGroupbox(title)
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1, 0, 0, 0)
    Box.AutomaticSize = Enum.AutomaticSize.Y
    bindColor(Box, "BackgroundColor3", "Sidebar")
    Box.BackgroundTransparency = 0.35
    Box.Parent = self.Page
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Box) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local Padding = Instance.new("UIPadding", Box)
    Padding.PaddingTop = UDim.new(0, 10) Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 10) Padding.PaddingRight = UDim.new(0, 10)

    local Layout = Instance.new("UIListLayout", Box)
    Layout.Padding = UDim.new(0, 8) Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local TitleLbl = Instance.new("TextLabel", Box)
    TitleLbl.Text = title
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Accent")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, 0, 0, 16)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Groupbox = setmetatable({}, {__index = TabMT})
    Groupbox.Page = Box
    Groupbox.Window = self.Window
    return Groupbox
end

function TabMT:CreateSection(text)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 24)
    Holder.BackgroundTransparency = 1
    Holder.Parent = self.Page

    local TitleLbl = Instance.new("TextLabel", Holder)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Accent")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, 0, 0, 18)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Line = Instance.new("Frame", Holder)
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 1, -2)
    bindColor(Line, "BackgroundColor3", "Stroke")
    Line.BorderSizePixel = 0
    return Holder
end

function TabMT:CreateParagraph(title, content)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 0)
    Card.AutomaticSize = Enum.AutomaticSize.Y
    bindColor(Card, "BackgroundColor3", "Sidebar")
    Card.BackgroundTransparency = 0.35
    Card.Parent = self.Page
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local Padding = Instance.new("UIPadding", Card)
    Padding.PaddingTop = UDim.new(0, 10) Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 12) Padding.PaddingRight = UDim.new(0, 12)

    local Layout = Instance.new("UIListLayout", Card)
    Layout.Padding = UDim.new(0, 4) Layout.SortOrder = Enum.SortOrder.LayoutOrder

    local TitleLabel = Instance.new("TextLabel", Card)
    TitleLabel.Text = title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    bindColor(TitleLabel, "TextColor3", "Text")
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ContentLabel = Instance.new("TextLabel", Card)
    ContentLabel.Text = content
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextSize = 11
    bindColor(ContentLabel, "TextColor3", "SubText")
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Size = UDim2.new(1, 0, 0, 0)
    ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
    ContentLabel.TextWrapped = true
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left

    return {
        Instance = Card,
        SetTitle = function(_, newTitle) TitleLabel.Text = newTitle end,
        SetContent = function(_, newContent) ContentLabel.Text = newContent end,
    }
end

function TabMT:CreateText(text)
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 0)
    Card.AutomaticSize = Enum.AutomaticSize.Y
    bindColor(Card, "BackgroundColor3", "Sidebar")
    Card.BackgroundTransparency = 0.35
    Card.Parent = self.Page
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local Padding = Instance.new("UIPadding", Card)
    Padding.PaddingTop = UDim.new(0, 10) Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 12) Padding.PaddingRight = UDim.new(0, 12)

    local Label = Instance.new("TextLabel", Card)
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    bindColor(Label, "TextColor3", "Text")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 0)
    Label.AutomaticSize = Enum.AutomaticSize.Y
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Left

    return {
        Instance = Card,
        SetText = function(_, newText) Label.Text = newText end,
    }
end

function TabMT:CreateButton(text, callback)
    callback = callback or function() end
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    bindColor(Btn, "BackgroundColor3", "Card")
    Btn.BackgroundTransparency = 0.3
    Btn.Text = text
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    bindColor(Btn, "TextColor3", "Text")
    Btn.AutoButtonColor = false
    Btn.Parent = self.Page

    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Btn)
    bindColor(Stroke, "Color", "Stroke")
    Stroke.Transparency = 0.4

    Btn.MouseButton1Click:Connect(function()
        tween(Btn, {BackgroundColor3 = Theme.CardHover}, 0.08)
        task.delay(0.12, function() tween(Btn, {BackgroundColor3 = Theme.Card}, 0.15) end)
        callback()
    end)
    return Btn
end

function TabMT:CreateToggle(text, default, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    local state = default or false

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = self.Page

    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    bindColor(Label, "TextColor3", "Text")
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("Frame", ToggleFrame)
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(1, -36, 0.5, -9)
    bindColor(Switch, "BackgroundColor3", state and "Accent" or "CardHover")
    Switch.BackgroundTransparency = state and 0 or 0.3
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Switch)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    bindColor(Knob, "BackgroundColor3", state and "Background" or "SubText")
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local ClickBtn = Instance.new("TextButton", ToggleFrame)
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""

    local function updateVisual()
        local switchKey = state and "Accent" or "CardHover"
        local knobKey = state and "Background" or "SubText"

        tween(Switch, {
            BackgroundColor3 = Theme[switchKey],
            BackgroundTransparency = state and 0 or 0.3
        }, 0.15)
        tween(Knob, {
            Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = Theme[knobKey]
        }, 0.15)

        -- อัปเดต Attribute ตามสถานะล่าสุด เพื่อให้สลับธีมทีหลังยังรีเฟรชสีถูกต้อง
        -- แม้ว่าตอนนั้น Toggle จะอยู่สถานะ ON หรือ OFF ก็ตาม
        tagBind(Switch, "BackgroundColor3", switchKey)
        tagBind(Knob, "BackgroundColor3", knobKey)
    end

    ClickBtn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        callback(state)
    end)

    local Obj = {
        Set = function(_, value) state = value; updateVisual(); callback(state) end,
        Get = function() return state end,
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateSlider(text, min, max, default, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    min, max = min or 0, max or 100
    local value = math.clamp(default or min, min, max)

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 26)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = self.Page

    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(0.4, 0, 1, 0)
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    bindColor(Label, "TextColor3", "Text")
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local ValueBox = Instance.new("Frame", SliderFrame)
    ValueBox.Size = UDim2.new(0, 42, 0, 22)
    ValueBox.Position = UDim2.new(1, -42, 0.5, -11)
    bindColor(ValueBox, "BackgroundColor3", "Card")
    ValueBox.BackgroundTransparency = 0.3
    Instance.new("UICorner", ValueBox).CornerRadius = UDim.new(0, 4)

    local ValueLabel = Instance.new("TextLabel", ValueBox)
    ValueLabel.Size = UDim2.new(1, 0, 1, 0)
    ValueLabel.Text = tostring(value)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextSize = 11
    bindColor(ValueLabel, "TextColor3", "Text")
    ValueLabel.BackgroundTransparency = 1

    local Track = Instance.new("Frame", SliderFrame)
    Track.Size = UDim2.new(0.6, -95, 0, 4)
    Track.Position = UDim2.new(0.4, 10, 0.5, -2)
    bindColor(Track, "BackgroundColor3", "Stroke")
    Track.BackgroundTransparency = 0.3
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    bindColor(Fill, "BackgroundColor3", "Accent")
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Knob = Instance.new("Frame", Fill)
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.Position = UDim2.new(1, -5, 0.5, -5)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * pos)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        callback(value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    local Obj = {
        Set = function(_, v)
            v = math.clamp(v, min, max)
            value = v
            local pos = (v - min) / (max - min)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            ValueLabel.Text = tostring(v)
            callback(v)
        end,
        Get = function() return value end,
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateDropdown(text, options, default, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    options = options or {}
    local selected = default or options[1]
    local open = false

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 36)
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.3
    Card.ClipsDescendants = true
    Card.Parent = self.Page
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, -100, 0, 36)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local SelectedLabel = Instance.new("TextLabel", Card)
    SelectedLabel.Text = tostring(selected)
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 11
    bindColor(SelectedLabel, "TextColor3", "SubText")
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Size = UDim2.new(0, 90, 0, 36)
    SelectedLabel.Position = UDim2.new(1, -98, 0, 0)
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right

    local ClickArea = Instance.new("TextButton", Card)
    ClickArea.Text = ""
    ClickArea.BackgroundTransparency = 1
    ClickArea.Size = UDim2.new(1, 0, 0, 36)

    local OptionsHolder = Instance.new("Frame", Card)
    OptionsHolder.Size = UDim2.new(1, -16, 0, #options * 26)
    OptionsHolder.Position = UDim2.new(0, 8, 0, 40)
    OptionsHolder.BackgroundTransparency = 1
    local OptLayout = Instance.new("UIListLayout", OptionsHolder)
    OptLayout.Padding = UDim.new(0, 2) OptLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- สร้างปุ่มตัวเลือกทั้งหมดจากลิสต์ options ปัจจุบัน
    -- แยกเป็นฟังก์ชันเพื่อให้ SetValues/Refresh เรียกซ้ำเพื่อ "รีเฟรช" รายการได้
    local function buildOptions()
        for _, child in ipairs(OptionsHolder:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, optionName in ipairs(options) do
            local OptBtn = Instance.new("TextButton", OptionsHolder)
            OptBtn.Text = optionName
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 11
            bindColor(OptBtn, "TextColor3", "Text")
            bindColor(OptBtn, "BackgroundColor3", "CardHover")
            OptBtn.Size = UDim2.new(1, 0, 0, 24)
            Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

            OptBtn.MouseButton1Click:Connect(function()
                selected = optionName
                SelectedLabel.Text = optionName
                callback(selected)
                open = false
                tween(Card, {Size = UDim2.new(1, 0, 0, 36)}, 0.15)
            end)
        end

        OptionsHolder.Size = UDim2.new(1, -16, 0, #options * 26)
    end

    buildOptions()

    ClickArea.MouseButton1Click:Connect(function()
        open = not open
        local targetHeight = open and (40 + #options * 26 + 6) or 36
        tween(Card, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.15)
    end)

    local function setValues(newOptions)
        options = newOptions or {}
        buildOptions()
        -- ถ้าค่าที่เลือกไว้เดิมหายไปจากลิสต์ใหม่ ให้รีเซ็ตเป็นค่าว่าง/ตัวแรก กันค่าเก่าค้าง
        local stillExists = false
        for _, v in ipairs(options) do
            if v == selected then stillExists = true break end
        end
        if not stillExists then
            selected = options[1] or ""
            SelectedLabel.Text = tostring(selected)
        end
        -- ถ้าเมนูเปิดอยู่ตอนรีเฟรช ให้ปรับความสูงให้ตรงกับจำนวนตัวเลือกใหม่ทันที
        if open then
            tween(Card, {Size = UDim2.new(1, 0, 0, 40 + #options * 26 + 6)}, 0.15)
        end
    end

    local Obj = {
        Set = function(_, value) selected = value; SelectedLabel.Text = tostring(value); callback(selected) end,
        Get = function() return selected end,
        SetValues = function(_, newOptions) setValues(newOptions) end,
        Refresh = function(_, newOptions) setValues(newOptions) end, -- alias เผื่อโค้ดเรียกชื่อนี้
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateMultiDropdown(text, options, defaults, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    options = options or {}
    local selected = {}
    for _, v in ipairs(defaults or {}) do selected[v] = true end
    local open = false

    local Card = Instance.new("Frame", self.Page)
    Card.Size = UDim2.new(1, 0, 0, 36)
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.3
    Card.ClipsDescendants = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, -40, 0, 36)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local ClickArea = Instance.new("TextButton", Card)
    ClickArea.Text = ""
    ClickArea.BackgroundTransparency = 1
    ClickArea.Size = UDim2.new(1, 0, 0, 36)

    local OptionsHolder = Instance.new("Frame", Card)
    OptionsHolder.Size = UDim2.new(1, -16, 0, #options * 26)
    OptionsHolder.Position = UDim2.new(0, 8, 0, 40)
    OptionsHolder.BackgroundTransparency = 1
    local OptLayout = Instance.new("UIListLayout", OptionsHolder)
    OptLayout.Padding = UDim.new(0, 2) OptLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function buttonColorKey(optionName)
        return selected[optionName] and "Accent" or "CardHover"
    end

    for _, optionName in ipairs(options) do
        local OptBtn = Instance.new("TextButton", OptionsHolder)
        OptBtn.Text = optionName
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 11
        bindColor(OptBtn, "TextColor3", "Text")
        bindColor(OptBtn, "BackgroundColor3", buttonColorKey(optionName))
        OptBtn.Size = UDim2.new(1, 0, 0, 24)
        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

        OptBtn.MouseButton1Click:Connect(function()
            selected[optionName] = not selected[optionName]
            local key = buttonColorKey(optionName)
            tween(OptBtn, {BackgroundColor3 = Theme[key]}, 0.15)
            tagBind(OptBtn, "BackgroundColor3", key)
            local list = {}
            for name, isSel in pairs(selected) do if isSel then table.insert(list, name) end end
            callback(list)
        end)
    end

    ClickArea.MouseButton1Click:Connect(function()
        open = not open
        local targetHeight = open and (40 + #options * 26 + 6) or 36
        tween(Card, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.15)
    end)

    local Obj = {
        Set = function(_, list)
            selected = {}
            for _, v in ipairs(list) do selected[v] = true end
            for _, child in ipairs(OptionsHolder:GetChildren()) do
                if child:IsA("TextButton") then
                    local key = buttonColorKey(child.Text)
                    tween(child, {BackgroundColor3 = Theme[key]}, 0.15)
                    tagBind(child, "BackgroundColor3", key)
                end
            end
            callback(list)
        end,
        Get = function()
            local list = {}
            for name, isSel in pairs(selected) do if isSel then table.insert(list, name) end end
            return list
        end,
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateInput(text, placeholder, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end

    local Card = Instance.new("Frame", self.Page)
    Card.Size = UDim2.new(1, 0, 0, 36)
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.3
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(0.4, 0, 1, 0)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Box = Instance.new("TextBox", Card)
    Box.Text = ""
    Box.PlaceholderText = placeholder or ""
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 11
    bindColor(Box, "TextColor3", "Text")
    bindColor(Box, "PlaceholderColor3", "SubText")
    Box.ClearTextOnFocus = false
    bindColor(Box, "BackgroundColor3", "Sidebar")
    Box.Size = UDim2.new(0.5, -12, 0, 26)
    Box.Position = UDim2.new(0.5, 0, 0.5, -13)
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 5)
    local Pad = Instance.new("UIPadding", Box) Pad.PaddingLeft = UDim.new(0, 8)

    Box.FocusLost:Connect(function(enterPressed)
        callback(Box.Text, enterPressed)
    end)

    local Obj = {
        Set = function(_, value) Box.Text = value; callback(value, false) end,
        Get = function() return Box.Text end,
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateKeybind(text, defaultKey, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    local currentKey = defaultKey or Enum.KeyCode.Unknown
    local listening = false

    local Card = Instance.new("Frame", self.Page)
    Card.Size = UDim2.new(1, 0, 0, 36)
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.3
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, -100, 1, 0)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local KeyBtn = Instance.new("TextButton", Card)
    KeyBtn.Text = currentKey.Name
    KeyBtn.Font = Enum.Font.Gotham
    KeyBtn.TextSize = 11
    bindColor(KeyBtn, "TextColor3", "SubText")
    bindColor(KeyBtn, "BackgroundColor3", "Sidebar")
    KeyBtn.Size = UDim2.new(0, 80, 0, 26)
    KeyBtn.Position = UDim2.new(1, -92, 0.5, -13)
    Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 5)

    KeyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        KeyBtn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not listening then
            if input.KeyCode == currentKey and not gameProcessed and currentKey ~= Enum.KeyCode.Unknown then
                callback(currentKey)
            end
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = input.KeyCode
            KeyBtn.Text = currentKey.Name
            listening = false
            callback(currentKey)
        end
    end)

    local Obj = {
        Set = function(_, key)
            if typeof(key) == "string" then key = Enum.KeyCode[key] end
            if not key then return end
            currentKey = key
            KeyBtn.Text = currentKey.Name
            userCallback(currentKey)
        end,
        Get = function() return currentKey.Name end,
        GetKeyCode = function() return currentKey end,
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateColorPicker(text, defaultColor, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    local color = defaultColor or Color3.fromRGB(255, 255, 255)
    local open = false

    local Card = Instance.new("Frame", self.Page)
    Card.Size = UDim2.new(1, 0, 0, 36)
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.3
    Card.ClipsDescendants = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, -60, 0, 36)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local Preview = Instance.new("TextButton", Card)
    Preview.Text = ""
    Preview.BackgroundColor3 = color
    Preview.Size = UDim2.new(0, 26, 0, 26)
    Preview.Position = UDim2.new(1, -38, 0, 5)
    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", Preview)

    local PickerHolder = Instance.new("Frame", Card)
    PickerHolder.Size = UDim2.new(1, -16, 0, 90)
    PickerHolder.Position = UDim2.new(0, 8, 0, 40)
    PickerHolder.BackgroundTransparency = 1

    local function makeChannelSlider(labelText, order, initValue, onChange)
        local Row = Instance.new("Frame", PickerHolder)
        Row.Size = UDim2.new(1, 0, 0, 22)
        Row.Position = UDim2.new(0, 0, 0, (order - 1) * 26)
        Row.BackgroundTransparency = 1

        local Lbl = Instance.new("TextLabel", Row)
        Lbl.Text = labelText
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 11
        bindColor(Lbl, "TextColor3", "SubText")
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(0, 16, 1, 0)

        local Track = Instance.new("Frame", Row)
        Track.Size = UDim2.new(1, -26, 0, 6)
        Track.Position = UDim2.new(0, 20, 0.5, -3)
        bindColor(Track, "BackgroundColor3", "Sidebar")
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", Track)
        Fill.Size = UDim2.new(initValue / 255, 0, 1, 0)
        bindColor(Fill, "BackgroundColor3", "Accent")
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function setFromX(xPos)
            local ratio = math.clamp((xPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(ratio, 0, 1, 0)
            onChange(math.floor(ratio * 255))
        end

        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                setFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        return Fill
    end

    local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
    local function updateColor()
        color = Color3.fromRGB(r, g, b)
        Preview.BackgroundColor3 = color
        callback(color)
    end
    makeChannelSlider("R", 1, r, function(v) r = v; updateColor() end)
    makeChannelSlider("G", 2, g, function(v) g = v; updateColor() end)
    makeChannelSlider("B", 3, b, function(v) b = v; updateColor() end)

    Preview.MouseButton1Click:Connect(function()
        open = not open
        tween(Card, {Size = UDim2.new(1, 0, 0, open and 136 or 36)}, 0.15)
    end)

    local Obj = {
        Set = function(_, newColor)
            if typeof(newColor) == "string" then newColor = Color3.fromHex(newColor) end
            color = newColor
            r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
            Preview.BackgroundColor3 = color
            callback(color)
        end,
        Get = function() return color:ToHex() end,
        GetColor3 = function() return color end,
    }
    registerFlag(self, flag, Obj)
    return Obj
end

function TabMT:CreateThemePicker(text)
    text = text or "ธีม"
    local keys, names = {}, {}
    for key, preset in pairs(ThemePresets) do
        table.insert(keys, key)
        names[preset.DisplayName or key] = key
    end
    table.sort(keys)

    local displayList = {}
    for _, key in ipairs(keys) do
        table.insert(displayList, ThemePresets[key].DisplayName or key)
    end

    local currentDisplay = ThemePresets[self.Window.CurrentTheme] and ThemePresets[self.Window.CurrentTheme].DisplayName or displayList[1]

    return self:CreateDropdown(text, displayList, currentDisplay, function(selectedName)
        local key = names[selectedName]
        if key then self.Window:SetTheme(key) end
    end)
end

function TabMT:CreateToggleMenuKeybind(text)
    text = text or "คีย์เปิด-ปิดเมนู"
    return self:CreateKeybind(text, self.Window.ToggleKey or Enum.KeyCode.RightControl, function(key)
        self.Window.ToggleKey = key
    end, "__ToggleMenuKey")
end

function TabMT:CreateCFrameCopier(text)
    text = text or "คัดลอกตำแหน่งที่ยืน (CFrame)"

    local Card = Instance.new("Frame", self.Page)
    Card.Size = UDim2.new(1, 0, 0, 36)
    bindColor(Card, "BackgroundColor3", "Card")
    Card.BackgroundTransparency = 0.3
    Card.ClipsDescendants = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", Card) bindColor(Stroke, "Color", "Stroke") Stroke.Transparency = 0.4

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Text = text
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 12
    bindColor(TitleLbl, "TextColor3", "Text")
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Size = UDim2.new(1, -92, 0, 36)
    TitleLbl.Position = UDim2.new(0, 12, 0, 0)
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local CopyBtn = Instance.new("TextButton", Card)
    CopyBtn.Text = "คัดลอก"
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 11
    bindColor(CopyBtn, "TextColor3", "Text")
    bindColor(CopyBtn, "BackgroundColor3", "Stroke")
    CopyBtn.Size = UDim2.new(0, 72, 0, 26)
    CopyBtn.Position = UDim2.new(1, -84, 0, 5)
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 5)

    local OutputBox = Instance.new("TextBox", Card)
    OutputBox.Text = ""
    OutputBox.Font = Enum.Font.Code
    OutputBox.TextSize = 11
    bindColor(OutputBox, "TextColor3", "SubText")
    OutputBox.ClearTextOnFocus = false
    OutputBox.TextEditable = true
    OutputBox.MultiLine = false
    bindColor(OutputBox, "BackgroundColor3", "Sidebar")
    OutputBox.Size = UDim2.new(1, -16, 0, 26)
    OutputBox.Position = UDim2.new(0, 8, 0, 40)
    OutputBox.Visible = false
    Instance.new("UICorner", OutputBox).CornerRadius = UDim.new(0, 5)
    local Pad = Instance.new("UIPadding", OutputBox) Pad.PaddingLeft = UDim.new(0, 8)

    CopyBtn.MouseButton1Click:Connect(function()
        local cfStr = Library:GetCharacterCFrameString()
        if not cfStr then
            Library:Notify("CFrame", "ไม่พบตัวละคร (Character) ในตอนนี้", 3)
            return
        end

        OutputBox.Text = cfStr
        OutputBox.Visible = true
        tween(Card, {Size = UDim2.new(1, 0, 0, 74)}, 0.15)

        local copied = Library:CopyCharacterCFrame()
        if not copied then
            OutputBox:CaptureFocus()
        end
    end)

    return {
        GetCFrameString = function() return Library:GetCharacterCFrameString() end,
    }
end

return Library
