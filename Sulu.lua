-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "Sulu Hub",
   LoadingTitle = "Sulu Hub",
   LoadingSubtitle = "by Cero",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Create Tabs
local FishingTab = Window:CreateTab("Fishing", nil) 
local TeleportTab = Window:CreateTab("Teleport", nil)
local CharacterTab = Window:CreateTab("Character", nil)

--// Services & Variables
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local GuiService = game:GetService('GuiService')

local lp = Players.LocalPlayer
local flags = {autoshake = false, autocast = false, autoreel = false, infoxygen = false, noafk = false, perfectcast = false, alwayscatch = false}
local walkSpeedEnabled = false
local jumpPowerEnabled = false
local gravityEnabled = false
local walkSpeed = 16
local jumpPower = 50
local gravity = 196.2
local deathcon = nil
local selectedZone = nil

--// Helper Functions
getchar = function()
    return lp.Character or lp.CharacterAdded:Wait()
end

gethrp = function()
    return getchar():WaitForChild('HumanoidRootPart')
end

gethum = function()
    return getchar():WaitForChild('Humanoid')
end

FindRod = function()
    local char = getchar()
    if char then
        local tool = char:FindFirstChildOfClass('Tool')
        if tool and tool:FindFirstChild('values') then
            return tool
        end
    end
    return nil
end

FindChildOfType = function(parent, name, class)
    if parent then
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA(class) and child.Name == name then
                return child
            end
        end
    end
    return nil
end

--// Fishing Automation
task.spawn(function()
    while true do
        if flags['autoshake'] then
            local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
            if shakeUI then
                local safeZone = shakeUI:FindFirstChild('safezone')
                if safeZone then
                    local button = safeZone:FindFirstChild('button')
                    if button then
                        GuiService.SelectedObject = button
                        if GuiService.SelectedObject == button then
                            game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    end
                end
            end
        end

        if flags['autocast'] then
            local rod = FindRod()
            if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("lure") then
                if rod.values.lure.Value <= 0.001 then
                    task.wait(0.5)
                    rod.events.cast:FireServer(100, 1)
                end
            end
        end

        if flags['autoreel'] then
            local rod = FindRod()
            if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("lure") then
                if rod.values.lure.Value == 100 then
                    task.wait(0.5)
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end
        end

        task.wait(0.1)
    end
end)

-- UI for Fishing
FishingTab:CreateToggle({
    Name = "Auto Shake",
    CurrentValue = false,
    Flag = "AutoShakeToggle",
    Callback = function(Value)
        flags['autoshake'] = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Flag = "AutoCastToggle",
    Callback = function(Value)
        flags['autocast'] = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Auto Reel",
    CurrentValue = false,
    Flag = "AutoReelToggle",
    Callback = function(Value)
        flags['autoreel'] = Value
    end,
})

-- Add Auto Equip Rod toggle under Fishing Config
FishingTab:CreateToggle({
    Name = "Auto Equip Rod",
    CurrentValue = false,
    Flag = "AutoEquipRodToggle",
    Callback = function(Value)
        -- Equip the rod if the toggle is on
        if Value then
            local rod = FindRod()
            if rod then
                rod.Parent = getchar()  -- Equip the rod to the character
            end
        else
            -- Optional: You can unequip the rod if needed
            local rod = FindRod()
            if rod then
                rod.Parent = nil  -- Unequip the rod
            end
        end
    end,
})

-- Add label "Fishing Config"
FishingTab:CreateLabel("Fishing Config")

-- Add the AutoFarm section
FishingTab:CreateLabel("AutoFarm")

-- Dropdown for fishing zones (update it dynamically)
local ZoneDropdown
ZoneDropdown = FishingTab:CreateDropdown({
   Name = "Select Zone",
   Options = {},  -- Empty initially
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "ZoneDropdown",
   Callback = function(Options)
      selectedZone = Options[1]
      print("Selected Zone: " .. selectedZone)  -- Debugging line
   end,
})

-- Fetch all unique fishing zones
local function updateZonesDropdown()
    local zones = {}
    local fishingZonesFolder = workspace:FindFirstChild("zones") and workspace.zones:FindFirstChild("fishing")
    
    if fishingZonesFolder then
        for _, zone in pairs(fishingZonesFolder:GetChildren()) do
            if zone:IsA('Model') and not table.find(zones, zone.Name) then
                table.insert(zones, zone.Name)
            end
        end
    end
    
    if #zones > 0 then
        -- Set dropdown options correctly
        ZoneDropdown:SetOptions(zones)
    else
        print("No fishing zones found!") -- Debugging message
    end
end

-- Call updateZonesDropdown after a short delay to ensure workspace loads
task.wait(1)
updateZonesDropdown()

-- AutoFarm toggle functionality
FishingTab:CreateToggle({
    Name = "Enable AutoFarm Zones",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        if Value then
            -- Enable AutoFarm: Teleport, Auto Equip Rod, Auto Cast, Auto Shake, Auto Reel, Freeze Character
            local zone = selectedZone  -- Zone selected from the dropdown
            if zone then
                -- Teleport player to selected zone
                local zonePos = workspace.zones.fishing[zone].Position
                lp.Character:MoveTo(zonePos)
                
                -- Enable Auto Equip Rod, Auto Cast, Auto Shake, Auto Reel
                flags['autocast'] = true
                flags['autoshake'] = true
                flags['autoreel'] = true
                
                -- Freeze Character (Disable movement)
                gethum().PlatformStand = true
            end
        else
            -- Disable AutoFarm: Disable all auto functions, Teleport back to island, Unfreeze character
            flags['autocast'] = false
            flags['autoshake'] = false
            flags['autoreel'] = false
            -- Teleport back to the island
            lp.Character:MoveTo(workspace.zones.fishing.Island1.Position)
            
            -- Unfreeze character (Enable movement)
            gethum().PlatformStand = false
        end
    end,
})

-- Teleport Tab functionality (fetch spawns dynamically)
local teleportDropdown
teleportDropdown = TeleportTab:CreateDropdown({
    Name = "Teleport to",
    Options = {},  -- Empty initially
    CurrentOption = "Island1",
    Flag = "TeleportDropdown",
    Callback = function(Options)
        local selectedLocation = Options[1]
        local target = workspace.world.spawns:FindFirstChild(selectedLocation)
        
        if target then
            lp.Character:MoveTo(target.Position)
        end
    end,
})

-- Fetch spawn points dynamically
local function updateTeleportDropdown()
    local spawnPoints = {}
    local spawnsFolder = workspace.world:FindFirstChild("spawns")
    
    if spawnsFolder then
        for _, spawn in pairs(spawnsFolder:GetChildren()) do
            if spawn:IsA('Model') and not table.find(spawnPoints, spawn.Name) then
                table.insert(spawnPoints, spawn.Name)
            end
        end
    end
    
    if #spawnPoints > 0 then
        -- Set dropdown options correctly
        teleportDropdown:SetOptions(spawnPoints)
    else
        print("No spawn points found!") -- Debugging message
    end
end

-- Call updateTeleportDropdown after a short delay to ensure workspace loads
task.wait(1)
updateTeleportDropdown()

-- Add Infinite Oxygen at Peaks functionality in Character Tab
CharacterTab:CreateToggle({
    Name = "Infinite Oxygen at Peaks",
    CurrentValue = false,
    Flag = "InfiniteOxygenAtPeaks",
    Callback = function(Value)
        flags['infoxygen'] = Value
    end,
})

-- Infinite Oxygen at Peaks script
task.spawn(function()
    while true do
        if flags['infoxygen'] then
            if not deathcon then
                deathcon = gethum().Died:Connect(function()
                    task.delay(9, function()
                        if FindChildOfType(getchar(), 'DivingTank', 'Decal') then
                            FindChildOfType(getchar(), 'DivingTank', 'Decal'):Destroy()
                        end
                        local oxygentank = Instance.new('Decal')
                        oxygentank.Name = 'DivingTank'
                        oxygentank.Parent = workspace
                        oxygentank:SetAttribute('Tier', 1/0)
                        oxygentank.Parent = getchar()
                        deathcon = nil
                    end)
                end)
            end
            if deathcon and gethum().Health > 0 then
                if not getchar():FindFirstChild('DivingTank') then
                    local oxygentank = Instance.new('Decal')
                    oxygentank.Name = 'DivingTank'
                    oxygentank.Parent = workspace
                    oxygentank:SetAttribute('Tier', 1/0)
                    oxygentank.Parent = getchar()
                end
            end
        else
            if FindChildOfType(getchar(), 'DivingTank', 'Decal') then
                FindChildOfType(getchar(), 'DivingTank', 'Decal'):Destroy()
            end
        end
        task.wait(1)
    end
end)
