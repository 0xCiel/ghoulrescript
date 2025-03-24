local repo = "https://raw.githubusercontent.com/Yv50/Ui-lib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local ESP = loadstring(game:HttpGet('https://raw.githubusercontent.com/Yv50/testing-stuff/refs/heads/main/pre'))()
local Window =
    Library:CreateWindow(
    {
        Title = 'test',
        Center = true,
        AutoShow = true,
        TabPadding = 8
    }
)
local Tabs = {
    PlayerTab = Window:AddTab("Players"),
    WorldTab = Window:AddTab("World"),
    VisualTab = Window:AddTab("Visual"),
    MiscTab = Window:AddTab("Miscs"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}
local PlayersGroup = Tabs.PlayerTab:AddLeftGroupbox("< Local Player >")
local WorldGroup = Tabs.WorldTab:AddLeftGroupbox("< Main >")
local ESPGroup = Tabs.VisualTab:AddLeftGroupbox("< ESP >")
local VisualMiscGroup = Tabs.VisualTab:AddRightGroupbox("< Miscs >")
local MiscGroup = Tabs.MiscTab:AddLeftGroupbox("< Main >")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local http = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")

local MainVariables = {
    flying = false,
    flySpeed = 100,
    noclip = false,
    speedhack = false,
    speedhackWalkSpeed = 100,
    infJump = false,
    VoidMob = false,
}

--Main Functions

local function tweenToTarget(hrp, targetCFrame, speed)
    local duration = (hrp.Position - targetCFrame.Position).Magnitude / speed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    return TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
end

local function Teleport(targetCFrame, speed)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local hrp = character.HumanoidRootPart
    local startCFrame = hrp.CFrame
    local startTime = tick()
    local duration = (startCFrame.Position - targetCFrame.Position).Magnitude / speed

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed >= duration then
            hrp.CFrame = targetCFrame
            connection:Disconnect()
        else
            local alpha = elapsed / duration
            hrp.CFrame = startCFrame:Lerp(targetCFrame, alpha)
        end
    end)
end
local bodyVelocity

local function ensureBodyVelocity()
    local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and (not bodyVelocity or not bodyVelocity.Parent) then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = humanoidRootPart
    end
end

local function flyLoop(delta)
    if MainVariables.flying and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        ensureBodyVelocity()
		LocalPlayer.Character:FindFirstChild("Humanoid").PlatformStand = false
        local moveDirection = Vector3.new(0, 0, 0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - workspace.CurrentCamera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + workspace.CurrentCamera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end

        bodyVelocity.Velocity = moveDirection * MainVariables.flySpeed
    end
end

local function toggleFlying(state)
    MainVariables.flying = state
    local humanoidRootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if MainVariables.flying then
        RunService:BindToRenderStep("Fly", Enum.RenderPriority.Input.Value, flyLoop)
    else
        RunService:UnbindFromRenderStep("Fly")
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
    end
end

--Misc Loop
RunService.RenderStepped:Connect(
    function(delta)
       --[[
        if MainVariables.noclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.Head.CanCollide = false
            game.Players.LocalPlayer.Character.Torso.CanCollide = false
        else
            game.Players.LocalPlayer.Character.Head.CanCollide = true
            game.Players.LocalPlayer.Character.Torso.CanCollide = true
        end
        ]]
        if MainVariables.speedhack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character:TranslateBy(
                game.Players.LocalPlayer.Character.Humanoid.MoveDirection * MainVariables.speedhackWalkSpeed * delta
            )
        end
    end
)
RunService.RenderStepped:Connect(function()
    if MainVariables.VoidMob then
        for i, v in ipairs(workspace.Entities:GetChildren()) do
            if v:IsA("Model") and not game.Players:FindFirstChild(v.Name) then
                if v.PrimaryPart then
                    if isnetworkowner(v) or isnetworkowner(v.PrimaryPart) then
                        v.PrimaryPart.CFrame = CFrame.new(0, -1000000, 0)
                    end
                end
            end
        end
    end
end)
UIS.JumpRequest:Connect(
    function()
        if MainVariables.infJump then
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
)

PlayersGroup:AddToggle(
    "Fly",
    {
        Text = "Fly",
        Default = false,
        Tooltip = "Fly",
        Callback = function(Value)
            toggleFlying(Value)
        end
    }
):AddKeyPicker(
    "FlyKeybind",
    {
        Default = "Y",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Fly Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)

PlayersGroup:AddSlider(
    "FlySpeed",
    {
        Text = "Fly Speed",
        Default = 100,
        Min = 0,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            MainVariables.flySpeed = Value
        end
    }
)

PlayersGroup:AddToggle(
    "SpeedHack",
    {
        Text = "SpeedHack",
        Default = false,
        Tooltip = "SpeedHack",
        Callback = function(Value)
            MainVariables.speedhack = Value
        end
    }
):AddKeyPicker(
    "SpeedKeyBind",
    {
        Default = "",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Speed Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)
PlayersGroup:AddSlider(
    "SpeedMultiplier",
    {
        Text = "Speed Multiplier",
        Default = 50,
        Min = 0,
        Max = 500,
        Rounding = 1,
        Callback = function(Value)
            MainVariables.speedhackWalkSpeed = Value
        end
    }
)
PlayersGroup:AddToggle(
    "InfJump",
    {
        Text = "Inf Jump",
        Default = false,
        Tooltip = "InfJump",
        Callback = function(Value)
            MainVariables.infJump = Value
        end
    }
):AddKeyPicker(
    "InfJumpKeyBind",
    {
        Default = "",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Speed Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)

--[[
PlayersGroup:AddToggle(
    "Noclip",
    {
        Text = "Noclip",
        Default = false,
        Tooltip = "Noclip",
        Callback = function(Value)
            MainVariables.noclip = Value
        end
    }
):AddKeyPicker(
    "NoclipKeybind",
    {
        Default = "N",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Noclip Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)

]]
--ESP MAIN
-- ESP MAIN
local ESPConfig = {
    PlayerESP = false,
    mobESP = false,
    ESPObjects = {},
    ActiveMobs = {},
    fontSize = 14,
    espDistance = 1000,
    MobESPColor = Color3.new(1, 1, 1)
}

local function NewText(color)
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.Color = color
    text.Size = ESPConfig.fontSize
    return text
end

local function RemoveMobESP(mob)
    if ESPConfig.ActiveMobs[mob] then
        local data = ESPConfig.ActiveMobs[mob]
        if data.espText then data.espText:Remove() end
        if data.highlight then data.highlight:Destroy() end
        ESPConfig.ActiveMobs[mob] = nil
    end
end

local function CreateMobESP(mob)
    if not (mob and mob:IsA("Model")) or ESPConfig.ActiveMobs[mob] then return end

    local humanoid = mob:FindFirstChildOfClass("Humanoid")
    local rootPart = mob:FindFirstChild("HumanoidRootPart")
    if not (humanoid and rootPart) then return end

    local espText = NewText(ESPConfig.MobESPColor)
    espText.Visible = false
    table.insert(ESPConfig.ESPObjects, espText)

    local highlight = Instance.new("Highlight")
    highlight.Parent = mob
    highlight.FillColor = ESPConfig.MobESPColor
    highlight.Enabled = false

    ESPConfig.ActiveMobs[mob] = {espText = espText, highlight = highlight}

    local updateName = "UpdateESP_" .. mob:GetDebugId()

    local function UpdateESP()
        if not mob or not mob.Parent or not humanoid or not rootPart or not ESPConfig.mobESP then
            RunService:UnbindFromRenderStep(updateName)
            RemoveMobESP(mob)
            return
        end

        local player = Players.LocalPlayer
        local char = player.Character
        if not char then return end

        local playerRoot = char:FindFirstChild("HumanoidRootPart")
        if not playerRoot then return end

        local distance = (rootPart.Position - playerRoot.Position).Magnitude
        local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

        if distance <= ESPConfig.espDistance and onScreen then
            local healthPercent = humanoid.MaxHealth > 0 and (humanoid.Health / humanoid.MaxHealth) * 100 or 0
            healthPercent = math.clamp(math.floor(healthPercent), 0, 100)

            espText.Text = string.format("[%s] [Dist: %.1f] [HP: %d%%]", mob.Name, distance, healthPercent)
            espText.Position = Vector2.new(screenPos.X, screenPos.Y - 50)
            espText.Size = ESPConfig.fontSize
            espText.Visible = true
            highlight.Enabled = true
        else
            espText.Visible = false
            highlight.Enabled = false
        end
    end

    RunService:BindToRenderStep(updateName, Enum.RenderPriority.Camera.Value + 1, UpdateESP)

    mob.AncestryChanged:Connect(function(_, parent)
        if not parent then
            RunService:UnbindFromRenderStep(updateName)
            RemoveMobESP(mob)
        end
    end)
end

local function UpdateMobs()
    for _, mob in ipairs(workspace.Entities:GetChildren()) do
        if mob:IsA("Model") and not Players:FindFirstChild(mob.Name) and not ESPConfig.ActiveMobs[mob] then
            CreateMobESP(mob)
        end
    end
end

workspace.Entities.ChildAdded:Connect(function(newMob)
    if newMob:IsA("Model") and not Players:FindFirstChild(newMob.Name) then
        CreateMobESP(newMob)
    end
end)

ESPGroup:AddToggle("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Tooltip = "ESP players with name, distance, and health",
    Callback = function(Value)
        ESPConfig.PlayerESP = Value
        if ESPConfig.PlayerESP then
            ESP:load()
        else
            ESP:unload()
        end
    end
})

ESPGroup:AddToggle("MobESP", {
    Text = "MobESP",
    Default = false,
    Tooltip = "ESP mobs with name, distance, and health",
    Callback = function(Value)
        ESPConfig.mobESP = Value
        if ESPConfig.mobESP then
            UpdateMobs()
        else
            for mob in pairs(ESPConfig.ActiveMobs) do
                RemoveMobESP(mob)
            end
            ESPConfig.ESPObjects = {}
        end
    end
}):AddColorPicker("MobColorPicker", {
    Default = ESPConfig.MobESPColor,
    Title = "Mob ESP Color",
    Transparency = 0,
    Callback = function(Value)
        ESPConfig.MobESPColor = Value
        for _, obj in pairs(ESPConfig.ActiveMobs) do
            if obj.highlight then
                obj.highlight.FillColor = Value
            end
        end
    end
})

ESPGroup:AddSlider("Distance", {
    Text = "ESP Distance",
    Default = 1000,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value)
        ESPConfig.espDistance = Value
    end
})

ESPGroup:AddSlider("TextSizeSlider", {
    Text = "Text Font Size",
    Default = 14,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        ESPConfig.fontSize = Value
    end
})
--Auto Farm
local AutoFarmSettings = {
    AutoFarmMobsDistance = 10,
    AutoFarmMobsHeight = 0,
    AutoFarmMobs = false,
    AutoFarmSelectedMobs = false,
}
WorldGroup:AddToggle(
    "Attach to nearby mobs",
    {
        Text = "Auto Farm Nearby Mobs",
        Default = false,
        Tooltip = "Auto Farm Nearest mob",
        Callback = function(Value)
            AutoFarmSettings.AutoFarmMobs = Value
            if AutoFarmSettings.AutoFarmMobs then
                task.spawn(
                    function()
                        while AutoFarmSettings.AutoFarmMobs and task.wait() do
                            local character = LocalPlayer.Character
                            if
                                not character or not character:FindFirstChild("HumanoidRootPart") or
                                    not Character.PrimaryPart
                             then
                                return
                            end
                            local hrp = character.HumanoidRootPart
                            local nearestMob = nil
                            local shortestDistance = math.huge
                            for _, mob in pairs(workspace.Entities:GetChildren()) do
                                if
                                    mob:IsA("Model") and not Players:FindFirstChild(mob.Name) 
                                 then
                                    local mobRootPart = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                                    if mobRootPart then
                                        local distance = (hrp.Position - mobRootPart.Position).Magnitude
                                        if distance < shortestDistance then
                                            shortestDistance = distance
                                            nearestMob = mobRootPart
                                        end
                                    end
                                end
                            end
                            if nearestMob then
                                repeat
									LocalPlayer.Character:FindFirstChild("Humanoid").PlatformStand = false
                                    Teleport(
                                        nearestMob.CFrame * CFrame.new(0, AutoFarmSettings.AutoFarmMobsHeight, AutoFarmSettings.AutoFarmMobsDistance),
                                        170
                                    )
                                    hrp.CFrame =
                                        CFrame.lookAt(
                                        hrp.CFrame.Position,
                                        Vector3.new(
                                            nearestMob.CFrame.Position.X,
                                            nearestMob.CFrame.Position.Y,
                                            nearestMob.CFrame.Position.Z
                                        )
                                    )
									task.wait()
                                until not AutoFarmSettings.AutoFarmMobs or not nearestMob.Parent or
                                    not nearestMob:IsDescendantOf(workspace)
                            end
                        end
                    end
                )
            end
        end
    }
):AddKeyPicker(
    "AutoFarmNearbyKeybind",
    {
        Default = "",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "AutoFarmNearby Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)




--[[
local MobsStorage = {}
local function addMob(mob)
    local mobName = mob.Name
    local isDuplicate = false

    for _, storedName in ipairs(MobsStorage) do
        if string.find(storedName, mobName) or string.find(mobName, storedName) then
            isDuplicate = true
            break
        end
    end

    if not isDuplicate then
        table.insert(MobsStorage, mobName)
        table.sort(MobsStorage)
    end
end
local function removeMob(mob)
    local mobName = mob.Name

    for i, storedName in ipairs(MobsStorage) do
        if string.find(storedName, mobName) or string.find(mobName, storedName) then
            table.remove(MobsStorage, i)
            break
        end
    end
end

for _, mob in ipairs(workspace.Entities:GetChildren()) do
    if mob:IsA("Model") and not game.Players:FindFirstChild(mob.Name) then
        addMob(mob)
    end
end

workspace.Entities.ChildAdded:Connect(function(child)
    if child:IsA("Model") and not game.Players:FindFirstChild(child.Name) then
        addMob(child)
    end
end)

workspace.Entities.ChildRemoved:Connect(function(child)
    if child:IsA("Model") and not game.Players:FindFirstChild(child.Name) then
        removeMob(child)
    end
end)
local SelectedMobs = {}
local MobsDropDown =
    WorldGroup:AddDropdown(
    "MobsDropDown",
    {
        Values = MobsStorage,
        Default = {},
        Multi = true,
        Text = "Mobs",
        Tooltip = "Select Mobs to Auto Farm",
        Callback = function(Value)
            print("[cb] Dropdown got changed. New value:", Value)
            SelectedMobs = Value
        end
    }
)
WorldGroup:AddToggle(
    "AutoFarmSelectedMobs",
    {
        Text = "AutoFarm Selected Mobs",
        Default = false,
        Tooltip = "AutoFarm Selected Mobs",
        Callback = function(Value)
            AutoFarmSettings.AutoFarmSelectedMobs = Value
            if AutoFarmSettings.AutoFarmSelectedMobs then
                task.spawn(
                    function()
                        while AutoFarmSettings.AutoFarmSelectedMobs and task.wait() do
                            local character = LocalPlayer.Character
                            if
                                not character or not character:FindFirstChild("HumanoidRootPart") or
                                    not character.PrimaryPart
                             then
                                return
                            end
                            local closestMob = nil
                            local minDistance = math.huge

                            for _, mob in ipairs(workspace.Entities:GetChildren()) do
                                if
                                    mob:IsA("Model") and not game.Players:FindFirstChild(mob.Name)
                                 then
                                    for mobName, _ in pairs(SelectedMobs) do
                                        if string.find(mob.Name, mobName) then
                                            local distance =
                                                (mob.PrimaryPart.Position -
                                                game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            if distance < minDistance then
                                                minDistance = distance
                                                closestMob = mob
                                            end
                                        end
                                    end
                                end
                            end
                            if closestMob then
                                repeat
								LocalPlayer.Character:FindFirstChild("Humanoid").PlatformStand = false
                                    Teleport(
                                        closestMob.PrimaryPart.CFrame *
                                            CFrame.new(0, AutoFarmSettings.AutoFarmMobsHeight, AutoFarmSettings.AutoFarmMobsDistance),
                                        170
                                    )
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                                        CFrame.lookAt(
                                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position,
                                        Vector3.new(
                                            closestMob.PrimaryPart.CFrame.Position.X,
                                            closestMob.PrimaryPart.CFrame.Position.Y,
                                            closestMob.PrimaryPart.CFrame.Position.Z
                                        )
                                    )
                                    task.wait()
                                until not AutoFarmSettings.AutoFarmSelectedMobs or not closestMob.Parent or
                                    not closestMob:IsDescendantOf(workspace)
                            end
                        end
                    end
                )
            end
        end
    }
):AddKeyPicker(
    "AutoFarmSelectedMobsKeybind",
    {
        Default = "",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Auto Farm Selected Mobs Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)
]]

WorldGroup:AddSlider(
    "Distance",
    {
        Text = "Distance",
        Default = 10,
        Min = 0,
        Max = 30,
        Rounding = 0,
        Callback = function(Value)
            AutoFarmSettings.AutoFarmMobsDistance = Value
        end
    }
)
WorldGroup:AddSlider(
    "Height",
    {
        Text = "Height",
        Default = 0,
        Min = -30,
        Max = 30,
        Rounding = 0,
        Callback = function(Value)
            AutoFarmSettings.AutoFarmMobsHeight = Value
        end
    }
)
WorldGroup:AddToggle(
    "Void Mob",
    {
        Text = "Void Mob",
        Default = false,
        Tooltip = "Void Mob",
        Callback = function(Value)
        end
    }
):AddKeyPicker(
    "AutoFarmNearbyKeybind",
    {
        Default = "",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "AutoFarmNearby Keybind",
        NoUI = false,
        Callback = function(Value)
        end
    }
)
WorldGroup:AddButton(
    "Go to quest marker",
    function()
        for i,v in ipairs(workspace.Dialogues:GetChildren()) do
            if v:FindFirstChild("Quest Marker") then
                Teleport(v:FindFirstChild("HumanoidRootPart").CFrame, 170)
            end
        end
    end
)
WorldGroup:AddButton(
    "Go to Loot Crate",
    function()
        Teleport(workspace.giftbox_blend.WorldPivot, 170)
    end
)

VisualMiscGroup:AddToggle(
    "StreamerMode",
    {
        Text = "Streamer Mode",
        Default = false,
        Tooltip = "Hides your UID",
        Callback = function(Value)
            game:GetService("Players").LocalPlayer.PlayerGui.ClientInfo.Section1.Visible = not Value
        end
    }
)
local originalDensity = Lighting.Atmosphere.Density

VisualMiscGroup:AddToggle(
    "NoFog",
    {
        Text = "No Fog",
        Default = false,
        Tooltip = "Disables or enables fog by adjusting Atmosphere Density.",
        Callback = function(Value)
            if Value then
                if Lighting:FindFirstChild("Atmosphere") then
                    Lighting.Atmosphere.Density = 0
                end
            else
                if Lighting:FindFirstChild("Atmosphere") then
                    Lighting.Atmosphere.Density = originalDensity
                end
            end
        end
    }
)

local function ToggleKeybindFrame(isVisible)
    Library.KeybindFrame.Visible = isVisible
end
Library:OnUnload(
    function()
        print("Unloaded!")
        Library.Unloaded = true
    end
)

local FrameTimer, FrameCounter, FPS = tick(), 0, 60

local WatermarkConnection =
game:GetService("RunService").RenderStepped:Connect(
    function()
        FrameCounter = FrameCounter + 1
        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter
            FrameTimer, FrameCounter = tick(), 0
        end
        Library:SetWatermark(
            ("XES Hub | %s fps | %s ms"):format(
                math.floor(FPS),
                math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            )
        )
    end
)

Library:OnUnload(
    function()
        WatermarkConnection:Disconnect()
        print("Unloaded!")
        Library.Unloaded = true
    end
)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton(
    "Unload",
    function()
        Library:Unload()
    end
)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "End", NoUI = true, Text = "Menu keybind"})
Library.ToggleKeybind = Options.MenuKeybind
MenuGroup:AddToggle(
    "KeybindPanel",
    {
        Text = "Keybinds Menu",
        Default = true,
        Callback = function(Value)
            ToggleKeybindFrame(Value)
        end
    }
)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("SexHub")
SaveManager:SetFolder("SexHub/specific-game")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
