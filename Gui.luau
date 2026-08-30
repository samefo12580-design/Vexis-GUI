--[[
    Library.lua - UI Framework ฉบับสมบูรณ์ สำหรับ Roblox
    ===============================================================
    วิธีใช้เบื้องต้น:
        local Library = loadstring(game:HttpGet("URL_ของไฟล์นี้"))()
        local Window = Library:CreateWindow({
            Title = "ชื่อหน้าต่าง",
            ToggleKey = Enum.KeyCode.RightShift, -- กดเพื่อซ่อน/แสดงหน้าต่าง (ไม่ใส่ก็ได้)
            ConfigName = "MyConfig",             -- ใช้สำหรับ Save/Load Config (ไม่ใส่ก็ได้)
            Theme = "violet",                    -- "blue" (ค่าเริ่มต้น) / "violet" / "emerald" / "sunset" / "amber"
        })
        local Tab = Window:CreateTab("ชื่อแท็บ")

    ระบบธีม (สลับได้ตอนรันจริง ไม่ต้องแก้โค้ด):
        Library.Themes                        -- ตาราง preset สีทั้งหมด (blue/violet/emerald/sunset/amber)
        Window:SetTheme("emerald")             -- สลับธีมแบบ live ทั้งหน้าต่าง มีอนิเมชันเปลี่ยนสี
        Tab:CreateThemePicker("เลือกธีม")       -- Dropdown สำเร็จรูปให้ผู้เล่นสลับธีมเองในเกม

    ฟังก์ชันที่มีให้ทั้งหมดใน Tab:
        Tab:CreateLabel(text)
        Tab:CreateSection(text)                                    -- เส้นคั่นหัวข้อย่อย
        Tab:CreateParagraph(title, content)                        -- กล่องข้อความยาว
        Tab:CreateButton(text, callback)
        Tab:CreateToggle(text, default, callback)
        Tab:CreateSlider(text, min, max, default, callback)
        Tab:CreateDropdown(text, options, default, callback)       -- เลือกได้ 1 ค่า
        Tab:CreateMultiDropdown(text, options, defaults, callback) -- เลือกได้หลายค่า
        Tab:CreateInput(text, placeholder, callback)                -- กล่องพิมพ์ข้อความ
        Tab:CreateKeybind(text, defaultKey, callback)               -- ปุ่มลัดคีย์บอร์ด
        Tab:CreateColorPicker(text, defaultColor, callback)         -- เลือกสี

    ฟังก์ชันของ Library / Window:
        Library:Notify(title, text, duration)   -- แจ้งเตือนมุมจอ
        Window:SaveConfig()
        Window:LoadConfig()
        Window:SetTheme(themeKey)
        Window:Destroy()

    หมายเหตุ: Elements ทุกตัวที่คืนค่ากลับมา (Toggle/Slider/Dropdown/Input/Keybind/ColorPicker)
    จะมี :Set(value) และ :Get() ให้ใช้ควบคุม/อ่านค่าจากภายนอกได้ และมี Flag เก็บลง Config อัตโนมัติ
    ถ้าใส่พารามิเตอร์ตัวสุดท้ายเป็น Flag (string) เช่น Tab:CreateToggle("...", false, cb, "MyFlag")
]]

local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// ธีมสีทั้งหมดที่มีให้ (สลับได้ตอนรันจริง ไม่ต้องแก้โค้ด)
local ThemePresets = {
    blue = {
        DisplayName = "Default Blue",
        Background = Color3.fromRGB(24, 24, 28),  Header = Color3.fromRGB(30, 30, 36),
        Sidebar    = Color3.fromRGB(20, 20, 24),  Card   = Color3.fromRGB(34, 34, 40),
        CardHover  = Color3.fromRGB(42, 42, 50),  Accent = Color3.fromRGB(90, 120, 255),
        Accent2    = Color3.fromRGB(138, 90, 255),
        Text       = Color3.fromRGB(235, 235, 240), SubText = Color3.fromRGB(150, 150, 160),
        Stroke     = Color3.fromRGB(50, 50, 58),
        Success    = Color3.fromRGB(90, 200, 130), Error = Color3.fromRGB(220, 90, 90),
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

-- Theme คือตารางสีที่ "กำลังใช้งานอยู่จริง" ทุกส่วนของโค้ดอ้างอิงตัวนี้
-- เวลาสลับธีม เราจะแก้ค่าข้างในตารางนี้ตรงๆ (ของเดิมทุกจุดจะเห็นค่าใหม่ทันที)
local Theme = {}
for k, v in pairs(ThemePresets.blue) do Theme[k] = v end

--// ตัวช่วยสร้าง Instance
local function create(class, props, children)
    local inst = Instance.new(class)
    for prop, value in pairs(props or {}) do
        inst[prop] = value
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

local function corner(radius) return create("UICorner", {CornerRadius = UDim.new(0, radius or 8)}) end
local function stroke(color, thickness) return create("UIStroke", {Color = color or Theme.Stroke, Thickness = thickness or 1}) end
local function tween(obj, props, time) TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), props):Play() end

-- อ่านสี "เก่า" ของทุก element ในหน้าต่าง แล้วจับคู่ไปยังสี "ใหม่" ของธีมที่เลือก
-- ทำงานได้กับ element ทุกตัวโดยไม่ต้องจดทะเบียนไว้ล่วงหน้า เพราะเทียบค่าสีตรงๆ
local function repaintTheme(screenGui, oldTheme, newTheme)
    if not screenGui then return end

    -- สร้างตาราง lookup ล่วงหน้า O(1) แทนการวนลูปเทียบสีทีละคู่ทุก instance (เร็วขึ้นมาก ลดอาการกระตุก)
    local lookup = {}
    for key, oldColor in pairs(oldTheme) do
        if typeof(oldColor) == "Color3" then
            lookup[oldColor:ToHex()] = newTheme[key]
        end
    end
    local function remap(color)
        return lookup[color:ToHex()]
    end

    -- แทนที่จะ tween สีทีละร้อยชิ้นพร้อมกัน (ทำให้เฟรมสะดุด/เออ) ให้ใช้ overlay วาบสีดำจางๆ
    -- คลุมสั้นๆ แล้ว "สลับสีทันที" ตอนที่จอมืดอยู่ ดูลื่นกว่าการ tween ทีละ property มาก
    local overlay = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1, ZIndex = 200, Parent = screenGui,
    })
    tween(overlay, {BackgroundTransparency = 0.55}, 0.09)

    task.delay(0.1, function()
        for _, inst in ipairs(screenGui:GetDescendants()) do
            if inst:IsA("GuiObject") and not inst:IsA("UIStroke") then
                local ok, bg = pcall(function() return inst.BackgroundColor3 end)
                if ok then
                    local newBG = remap(bg)
                    if newBG then inst.BackgroundColor3 = newBG end
                end
            end
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                local newTC = remap(inst.TextColor3)
                if newTC then inst.TextColor3 = newTC end
                if inst:IsA("TextBox") then
                    local newPH = remap(inst.PlaceholderColor3)
                    if newPH then inst.PlaceholderColor3 = newPH end
                end
            end
            if inst:IsA("UIStroke") then
                local newSC = remap(inst.Color)
                if newSC then inst.Color = newSC end
            end
            if inst:IsA("ScrollingFrame") then
                local newSB = remap(inst.ScrollBarImageColor3)
                if newSB then inst.ScrollBarImageColor3 = newSB end
            end
        end
        tween(overlay, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.22, function() overlay:Destroy() end)
    end)
end

--// ลากหน้าต่าง
local function makeDraggable(dragHandle, targetFrame)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// ระบบไฟล์ (เผื่อ executor ไม่รองรับ ก็ปลอดภัยด้วย pcall)
local function fileFunctionsExist()
    return writefile ~= nil and readfile ~= nil and isfile ~= nil
end

--=========================================================
--  LIBRARY
--=========================================================
local Library = {}
Library.__index = Library

local NotifHolder -- เก็บ ScreenGui สำหรับ Notification (ตั้งค่าตอนสร้าง Window)

function Library:Notify(title, text, duration)
    duration = duration or 3
    if not NotifHolder then return end

    local Card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0,
        Parent = NotifHolder,
        ClipsDescendants = true,
    }, {corner(8), stroke()})

    create("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
        Parent = Card,
    })

    local Layout = create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
    Layout.Parent = Card

    create("TextLabel", {
        Text = title or "แจ้งเตือน",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card,
    })

    create("TextLabel", {
        Text = text or "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Theme.SubText,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Card,
    })

    Card.BackgroundTransparency = 1
    for _, d in ipairs(Card:GetDescendants()) do
        if d:IsA("TextLabel") then d.TextTransparency = 1 end
    end
    tween(Card, {BackgroundTransparency = 0}, 0.2)
    for _, d in ipairs(Card:GetDescendants()) do
        if d:IsA("TextLabel") then tween(d, {TextTransparency = 0}, 0.2) end
    end

    task.delay(duration, function()
        tween(Card, {BackgroundTransparency = 1}, 0.3)
        for _, d in ipairs(Card:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, {TextTransparency = 1}, 0.3) end
        end
        task.wait(0.3)
        Card:Destroy()
    end)
end

-- เปิดให้เรียกดู/อ้างอิงจากภายนอกได้ เช่น for key,preset in pairs(Library.Themes) do ... end
Library.Themes = ThemePresets

local TooltipHolder, TooltipFrame, TooltipLabel

-- ผูก Tooltip ให้ GuiObject ใดๆ (ปุ่ม/การ์ด) โฮเวอร์แล้วมีคำอธิบายลอยตามเมาส์
-- ใช้ได้กับค่าที่ element คืนกลับมา ผ่าน .Instance เช่น:
--   local t = Tab:CreateToggle(...); Library:AddTooltip(t.Instance, "คำอธิบาย")
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

function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Window"
    local toggleKey = config.ToggleKey
    local configName = config.ConfigName or "LibraryConfig"
    local themeKey = config.Theme or "blue"

    if ThemePresets[themeKey] then
        for k, v in pairs(ThemePresets[themeKey]) do Theme[k] = v end
    end

    local old = PlayerGui:FindFirstChild("CustomLibraryUI")
    if old then old:Destroy() end

    local ScreenGui = create("ScreenGui", {
        Name = "CustomLibraryUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = PlayerGui,
    })

    -- ที่เก็บ Notification (มุมขวาบน)
    NotifHolder = create("Frame", {
        Name = "Notifications",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 260, 1, -32),
        BackgroundTransparency = 1,
        Parent = ScreenGui,
    })
    create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top}).Parent = NotifHolder

    -- Tooltip ลอยตามเมาส์ (ใช้ร่วมกับ Library:AddTooltip)
    TooltipFrame = create("Frame", {
        Name = "Tooltip", BackgroundColor3 = Theme.Card, Visible = false,
        Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 100, Parent = ScreenGui,
    }, {corner(5), stroke()})
    create("UIPadding", {
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = TooltipFrame,
    })
    TooltipLabel = create("TextLabel", {
        Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.XY,
        ZIndex = 100, Parent = TooltipFrame,
    })

    local Main = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Parent = ScreenGui,
    }, {corner(10), stroke(Theme.Stroke, 1)})

    local Header = create("Frame", {
        Name = "Header", Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.Header, Parent = Main,
    }, {corner(10)})

    create("Frame", {
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Header, BorderSizePixel = 0, Parent = Header,
    })

    create("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = Theme.Text, BackgroundTransparency = 1,
        Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Header,
    })

    local MinimizeBtn = create("TextButton", {
        Text = "–", Font = Enum.Font.GothamBold, TextSize = 18,
        TextColor3 = Theme.SubText, BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(1, -76, 0, 3),
        Parent = Header,
    })

    local CloseBtn = create("TextButton", {
        Text = "✕", Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = Theme.SubText, BackgroundTransparency = 1,
        Size = UDim2.new(0, 36, 0, 36), Position = UDim2.new(1, -40, 0, 3),
        Parent = Header,
    })
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    makeDraggable(Header, Main)

    local Sidebar = create("Frame", {
        Name = "Sidebar", Size = UDim2.new(0, 140, 1, -42), Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.Sidebar, Parent = Main,
    })

    -- ช่องค้นหาแท็บ
    local SearchBox = create("TextBox", {
        Text = "", PlaceholderText = "🔍 ค้นหา...", Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, ClearTextOnFocus = false,
        BackgroundColor3 = Theme.Card, Size = UDim2.new(1, -12, 0, 26), Position = UDim2.new(0, 6, 0, 6),
        Parent = Sidebar,
    }, {corner(6)})
    create("UIPadding", {PaddingLeft = UDim.new(0, 8)}).Parent = SearchBox

    local TabListHolder = create("Frame", {
        Name = "TabList", Size = UDim2.new(1, -12, 1, -44), Position = UDim2.new(0, 6, 0, 38),
        BackgroundTransparency = 1, Parent = Sidebar,
    })
    create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}).Parent = TabListHolder

    local Content = create("Frame", {
        Name = "Content", Size = UDim2.new(1, -140, 1, -42), Position = UDim2.new(0, 140, 0, 42),
        BackgroundTransparency = 1, Parent = Main,
    })

    -- หน้าจอ Loading (ถ้าตั้งค่า LoadingTitle มา)
    if config.LoadingTitle then
        local LoadingScreen = create("Frame", {
            Name = "Loading", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Background,
            ZIndex = 50, Parent = ScreenGui,
        })
        local LT = create("TextLabel", {
            Text = config.LoadingTitle, Font = Enum.Font.GothamBold, TextSize = 22,
            TextColor3 = Theme.Text, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0.45, -30),
            ZIndex = 51, Parent = LoadingScreen,
        })
        create("TextLabel", {
            Text = config.LoadingSubtitle or "กำลังโหลด...", Font = Enum.Font.Gotham, TextSize = 13,
            TextColor3 = Theme.SubText, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.45, 4),
            ZIndex = 51, Parent = LoadingScreen,
        })
        local BarBG = create("Frame", {
            Size = UDim2.new(0, 220, 0, 4), Position = UDim2.new(0.5, -110, 0.45, 34),
            BackgroundColor3 = Theme.Sidebar, ZIndex = 51, Parent = LoadingScreen,
        }, {corner(2)})
        local BarFill = create("Frame", {
            Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent, ZIndex = 51, Parent = BarBG,
        }, {corner(2)})

        Main.Visible = false
        tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.9)
        task.delay(1, function()
            tween(LoadingScreen, {BackgroundTransparency = 1}, 0.35)
            tween(LT, {TextTransparency = 1}, 0.35)
            Main.Visible = true
            task.wait(0.35)
            LoadingScreen:Destroy()
        end)
    end

    local Window = setmetatable({}, {__index = WindowMT})
    Window.ScreenGui = ScreenGui
    Window.Main = Main
    Window.Sidebar = Sidebar
    Window.TabListHolder = TabListHolder
    Window.Content = Content
    Window.Tabs = {}
    Window.ActiveTab = nil
    Window.Flags = {}       -- เก็บ element ทั้งหมดที่มี Flag ไว้ save/load
    Window.ConfigName = configName
    Window.Minimized = false
    Window.CurrentTheme = themeKey
    Window.ToggleKey = toggleKey

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, t in ipairs(Window.Tabs) do
            if query == "" then
                t.Button.Visible = true
            else
                t.Button.Visible = t.Name:lower():find(query, 1, true) ~= nil
            end
        end
    end)

    local originalSize = Main.Size
    MinimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            tween(Main, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 42)}, 0.2)
        else
            tween(Main, {Size = originalSize}, 0.2)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if Window.ToggleKey and input.KeyCode == Window.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- Auto-load config ทันทีที่เปิดหน้าต่าง (ถ้ามีไฟล์อยู่แล้ว) และ auto-save ทุกครั้งที่ค่าถูกเปลี่ยน
    -- ผู้ใช้ไม่ต้องกดปุ่ม Save/Load เอง ทำงานอัตโนมัติตลอด
    Window.AutoSaveEnabled = true
    task.defer(function()
        if fileFunctionsExist() and isfile(Window.ConfigName .. ".json") then
            Window:LoadConfig(true) -- true = โหลดแบบเงียบ ไม่ต้อง Notify
        end
    end)

    return Window
end

--=========================================================
--  WINDOW METHODS
--=========================================================
WindowMT = {}
WindowMT.__index = WindowMT

function WindowMT:CreateTab(name, icon)
    local self = self

    local TabButton = create("TextButton", {
        Text = "", Font = Enum.Font.Gotham, TextSize = 14,
        TextColor3 = Theme.SubText, BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32),
        AutoButtonColor = false, Parent = self.TabListHolder,
    }, {corner(6)})

    local hasIcon = icon ~= nil and icon ~= ""
    local IconImg
    if hasIcon then
        IconImg = create("ImageLabel", {
            Image = icon, BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 10, 0.5, -8),
            ImageColor3 = Theme.SubText, Parent = TabButton,
        })
    end

    create("TextLabel", {
        Text = name, Font = Enum.Font.Gotham, TextSize = 14,
        TextColor3 = Theme.SubText, BackgroundTransparency = 1,
        Size = UDim2.new(1, hasIcon and -34 or -12, 1, 0),
        Position = UDim2.new(0, hasIcon and 34 or 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Name = "Label", Parent = TabButton,
    })

    local Page = create("ScrollingFrame", {
        Name = name, Size = UDim2.new(1, -20, 1, -16), Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = self.Content,
    })
    create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}).Parent = Page

    local Tab = setmetatable({}, {__index = TabMT})
    Tab.Page = Page
    Tab.Button = TabButton
    Tab.Name = name
    Tab.Window = self

    local function selectTab()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            tween(t.Button, {TextColor3 = Theme.SubText, BackgroundTransparency = 1}, 0.15)
            t.Button.Label.TextColor3 = Theme.SubText
        end
        Page.Visible = true
        tween(TabButton, {BackgroundTransparency = 0}, 0.15)
        TabButton.Label.TextColor3 = Theme.Text
        if IconImg then IconImg.ImageColor3 = Theme.Accent end
        self.ActiveTab = Tab
    end

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

-- เรียกใช้ภายในทุกครั้งที่ค่า element เปลี่ยน เพื่อบันทึกอัตโนมัติแบบเงียบๆ (มี debounce กันเขียนไฟล์ถี่เกินไป)
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

-- สลับธีมแบบ Live: ให้ key ตรงกับ Library.Themes เช่น "violet", "emerald", "sunset", "amber", "blue"
function WindowMT:SetTheme(themeKey)
    local preset = ThemePresets[themeKey]
    if not preset then
        warn("[Library] ไม่พบธีมชื่อ: " .. tostring(themeKey))
        return
    end

    -- เก็บสีชุดเก่าไว้ก่อน เพื่อใช้จับคู่ (remap) เป็นสีชุดใหม่
    local oldTheme = {}
    for k, v in pairs(Theme) do oldTheme[k] = v end

    for k, v in pairs(preset) do Theme[k] = v end
    self.CurrentTheme = themeKey

    repaintTheme(self.ScreenGui, oldTheme, Theme)
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
    return create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = Theme.SubText, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Page,
    })
end

-- จัดกลุ่ม element หลายตัวไว้ในกล่องเดียวกัน พร้อมหัวข้อ ใช้เมธอดเดียวกับ Tab ได้ทุกตัว
-- ตัวอย่าง: local Box = Tab:CreateGroupbox("ตั้งค่า Farm"); Box:CreateToggle(...)
function TabMT:CreateGroupbox(title)
    local Box = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card, Parent = self.Page,
    }, {corner(8), stroke()})
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Box,
    })
    create("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}).Parent = Box
    create("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Accent,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Box,
    })

    local Groupbox = setmetatable({}, {__index = TabMT})
    Groupbox.Page = Box
    Groupbox.Window = self.Window
    return Groupbox
end

function TabMT:CreateSection(text)
    local Holder = create("Frame", {
        Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = self.Page,
    })
    create("TextLabel", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = Theme.Accent, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = Holder,
    })
    return Holder
end

function TabMT:CreateParagraph(title, content)
    local Card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Card, Parent = self.Page,
    }, {corner(6), stroke()})
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = Card,
    })
    create("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}).Parent = Card
    create("TextLabel", {
        Text = title, Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = Theme.Text, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    create("TextLabel", {
        Text = content, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = Theme.SubText, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    return Card
end

function TabMT:CreateButton(text, callback)
    callback = callback or function() end
    local Card = create("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, Parent = self.Page}, {corner(6), stroke()})
    local Btn = create("TextButton", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = Card,
    })
    Btn.MouseEnter:Connect(function() tween(Card, {BackgroundColor3 = Theme.CardHover}, 0.15) end)
    Btn.MouseLeave:Connect(function() tween(Card, {BackgroundColor3 = Theme.Card}, 0.15) end)
    Btn.MouseButton1Click:Connect(function()
        tween(Card, {BackgroundColor3 = Theme.Accent}, 0.08)
        task.delay(0.12, function() tween(Card, {BackgroundColor3 = Theme.Card}, 0.15) end)
        callback()
    end)
    return Card
end

function TabMT:CreateToggle(text, default, callback, flag)
    local userCallback = callback or function() end
    local selfTab = self
    callback = function(...)
        userCallback(...)
        if flag and selfTab.Window then selfTab.Window:_AutoSave() end
    end
    local state = default or false

    local Card = create("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, Parent = self.Page}, {corner(6), stroke()})
    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local SwitchBG = create("Frame", {
        Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = state and Theme.Accent or Theme.Sidebar, Parent = Card,
    }, {corner(10)})
    local Knob = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = SwitchBG,
    }, {corner(8)})
    local ClickArea = create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = Card})

    local function updateVisual()
        tween(SwitchBG, {BackgroundColor3 = state and Theme.Accent or Theme.Sidebar}, 0.15)
        tween(Knob, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.15)
    end

    ClickArea.MouseButton1Click:Connect(function()
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

    local Card = create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Card, Parent = self.Page}, {corner(6), stroke()})
    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 24), Position = UDim2.new(0, 12, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local ValueLabel = create("TextLabel", {
        Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Accent,
        BackgroundTransparency = 1, Size = UDim2.new(0, 50, 0, 24), Position = UDim2.new(1, -58, 0, 4),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = Card,
    })
    local Track = create("Frame", {
        Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 34),
        BackgroundColor3 = Theme.Sidebar, Parent = Card,
    }, {corner(3)})

    local function ratioFromValue(v) return (v - min) / (max - min) end

    local Fill = create("Frame", {Size = UDim2.new(ratioFromValue(value), 0, 1, 0), BackgroundColor3 = Theme.Accent, Parent = Track}, {corner(3)})
    local Knob = create("Frame", {
        Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(ratioFromValue(value), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = Track,
    }, {corner(6)})

    local dragging = false
    local function setFromX(xPos)
        local ratio = math.clamp((xPos - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * ratio + 0.5)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        Knob.Position = UDim2.new(ratio, -6, 0.5, -6)
        ValueLabel.Text = tostring(value)
        callback(value)
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

    local Obj = {
        Set = function(_, v)
            v = math.clamp(v, min, max)
            setFromX(Track.AbsolutePosition.X + (ratioFromValue(v) * Track.AbsoluteSize.X))
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

    local Card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card,
        ClipsDescendants = true, Parent = self.Page,
    }, {corner(6), stroke()})

    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -100, 0, 36), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local SelectedLabel = create("TextLabel", {
        Text = tostring(selected), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.SubText,
        BackgroundTransparency = 1, Size = UDim2.new(0, 90, 0, 36), Position = UDim2.new(1, -98, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = Card,
    })
    local ClickArea = create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = Card})
    local OptionsHolder = create("Frame", {
        Size = UDim2.new(1, -16, 0, #options * 26), Position = UDim2.new(0, 8, 0, 40),
        BackgroundTransparency = 1, Parent = Card,
    })
    create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}).Parent = OptionsHolder

    for _, optionName in ipairs(options) do
        local OptBtn = create("TextButton", {
            Text = optionName, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.CardHover, Size = UDim2.new(1, 0, 0, 24), Parent = OptionsHolder,
        }, {corner(4)})
        OptBtn.MouseButton1Click:Connect(function()
            selected = optionName
            SelectedLabel.Text = optionName
            callback(selected)
            open = false
            tween(Card, {Size = UDim2.new(1, 0, 0, 36)}, 0.15)
        end)
    end

    ClickArea.MouseButton1Click:Connect(function()
        open = not open
        local targetHeight = open and (40 + #options * 26 + 6) or 36
        tween(Card, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.15)
    end)

    local Obj = {
        Set = function(_, value) selected = value; SelectedLabel.Text = tostring(value); callback(selected) end,
        Get = function() return selected end,
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

    local Card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card,
        ClipsDescendants = true, Parent = self.Page,
    }, {corner(6), stroke()})

    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local ClickArea = create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = Card})
    local OptionsHolder = create("Frame", {
        Size = UDim2.new(1, -16, 0, #options * 26), Position = UDim2.new(0, 8, 0, 40),
        BackgroundTransparency = 1, Parent = Card,
    })
    create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}).Parent = OptionsHolder

    local function buttonColor(optionName)
        return selected[optionName] and Theme.Accent or Theme.CardHover
    end

    for _, optionName in ipairs(options) do
        local OptBtn = create("TextButton", {
            Text = optionName, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.Text,
            BackgroundColor3 = buttonColor(optionName), Size = UDim2.new(1, 0, 0, 24), Parent = OptionsHolder,
        }, {corner(4)})
        OptBtn.MouseButton1Click:Connect(function()
            selected[optionName] = not selected[optionName]
            tween(OptBtn, {BackgroundColor3 = buttonColor(optionName)}, 0.15)
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
                if child:IsA("TextButton") then tween(child, {BackgroundColor3 = buttonColor(child.Text)}, 0.15) end
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
    local Card = create("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, Parent = self.Page}, {corner(6), stroke()})
    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local Box = create("TextBox", {
        Text = "", PlaceholderText = placeholder or "", Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText, ClearTextOnFocus = false,
        BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0.5, -12, 0, 26), Position = UDim2.new(0.5, 0, 0.5, -13),
        Parent = Card,
    }, {corner(5)})
    create("UIPadding", {PaddingLeft = UDim.new(0, 8)}).Parent = Box

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

    local Card = create("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card, Parent = self.Page}, {corner(6), stroke()})
    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local KeyBtn = create("TextButton", {
        Text = currentKey.Name, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Theme.SubText,
        BackgroundColor3 = Theme.Sidebar, Size = UDim2.new(0, 80, 0, 26), Position = UDim2.new(1, -92, 0.5, -13),
        Parent = Card,
    }, {corner(5)})

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
        Get = function() return currentKey.Name end, -- คืนเป็น string เพื่อให้บันทึกเป็น JSON ได้
        GetKeyCode = function() return currentKey end, -- ใช้ตอนต้องการ Enum.KeyCode จริงๆ
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

    local Card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Card,
        ClipsDescendants = true, Parent = self.Page,
    }, {corner(6), stroke()})

    create("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
        BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 36), Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = Card,
    })
    local Preview = create("TextButton", {
        Text = "", BackgroundColor3 = color, Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -38, 0, 5), Parent = Card,
    }, {corner(5), stroke()})

    local PickerHolder = create("Frame", {
        Size = UDim2.new(1, -16, 0, 90), Position = UDim2.new(0, 8, 0, 40),
        BackgroundTransparency = 1, Parent = Card,
    })

    local function makeChannelSlider(labelText, order, initValue, onChange)
        local Row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 0, (order - 1) * 26),
            BackgroundTransparency = 1, Parent = PickerHolder,
        })
        create("TextLabel", {
            Text = labelText, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.SubText,
            BackgroundTransparency = 1, Size = UDim2.new(0, 16, 1, 0), Parent = Row,
        })
        local Track = create("Frame", {
            Size = UDim2.new(1, -26, 0, 6), Position = UDim2.new(0, 20, 0.5, -3),
            BackgroundColor3 = Theme.Sidebar, Parent = Row,
        }, {corner(3)})
        local Fill = create("Frame", {Size = UDim2.new(initValue / 255, 0, 1, 0), BackgroundColor3 = Theme.Accent, Parent = Track}, {corner(3)})

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
        return Fill, Track
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
        GetColor3 = function() return color end, -- ใช้ตอนต้องการ Color3 จริงๆ
    }
    registerFlag(self, flag, Obj)
    return Obj
end

-- Dropdown สำเร็จรูปสำหรับสลับธีมทั้งหมดที่มีใน Library.Themes โดยไม่ต้องเขียน dropdown เอง
-- ตัวอย่าง: Tab:CreateThemePicker("ธีม")
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

-- Keybind สำเร็จรูปสำหรับผูกกับคีย์เปิด/ปิดเมนูโดยเฉพาะ (แก้ไขคีย์ ToggleKey ของหน้าต่างได้จากในเกมเลย)
-- ตัวอย่าง: SettingsTab:CreateToggleMenuKeybind("คีย์เปิด-ปิดเมนู")
function TabMT:CreateToggleMenuKeybind(text)
    text = text or "คีย์เปิด-ปิดเมนู"
    return self:CreateKeybind(text, self.Window.ToggleKey or Enum.KeyCode.RightControl, function(key)
        self.Window.ToggleKey = key
    end, "__ToggleMenuKey")
end

return Library
