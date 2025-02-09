-- Not released 


--// Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()



--// Create Window
local Window = Rayfield:CreateWindow({
   Name = "Sulu Hub",
   LoadingTitle = "Sulu Hub",
   LoadingSubtitle = "by Cero",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})



--// Create Tabs
local FishingTab = Window:CreateTab("Fishing", nil) 
local TeleportTab = Window:CreateTab("Teleport", nil)
local CharacterTab = Window:CreateTab("Character", nil)



--// Services & Variables

local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))

local lp = Players.LocalPlayer
local flags = {autoshake = false, autocast = false, autoreel = false, nopeakssystems = false, autoequiprod = false}
local selectedIsland = nil



--// Helper Functions

local function getchar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function gethrp()
    return getchar():WaitForChild('HumanoidRootPart')
end

local function gethum()
    return getchar():WaitForChild('Humanoid')
end

local function FindRod()
    local char = getchar()
    if char then
        local tool = char:FindFirstChildOfClass('Tool')
        if tool and tool:FindFirstChild('values') then
            return tool
        end
    end
    return nil
end

local function FindChildOfType(parent, name, class)
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


RunService.Heartbeat:Connect(function()
    -- Autofarm
    if flags['autoequiprod'] then
        if not FindRod() then
            for _, tool in pairs(lp.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("values") then
                    lp.Character.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
 
    if flags['autoshake'] then
        if FindChild(lp.PlayerGui, 'shakeui') and FindChild(lp.PlayerGui['shakeui'], 'safezone') and FindChild(lp.PlayerGui['shakeui']['safezone'], 'button') then
            GuiService.SelectedObject = lp.PlayerGui['shakeui']['safezone']['button']
            if GuiService.SelectedObject == lp.PlayerGui['shakeui']['safezone']['button'] then
                game:GetService('VirtualInputManager'):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                game:GetService('VirtualInputManager'):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
    end
    if flags['autocast'] then
        local rod = FindRod()
        if rod ~= nil and rod['values']['lure'].Value <= .001 and task.wait(.5) then
            rod.events.cast:FireServer(100, 1)
        end
    end
    if flags['autoreel'] then
        if flags['autoreelmode'] == 'Limited Blatant' then
            local rod = FindRod()
            if rod ~= nil and rod['values']['lure'].Value == 100 and task.wait(math.random(10, 20)/10) then
                task.delay(math.random(10, 25)/10, function()
                    ReplicatedStorage.events.reelfinished:FireServer(100, (math.random(1,2) == 1 and true or false))
                end)
            end
        end
    end

end)



--// Zone Cast System

local selectedZone = nil
local originalPosition = nil

local function getFishingZones()
    local zones = {}
    local fishingZones = workspace:FindFirstChild("zones") and workspace.zones:FindFirstChild("fishing")
    
    if fishingZones then
        for _, zone in pairs(fishingZones:GetChildren()) do
            if zone:IsA("BasePart") then
                zones[zone.Name] = zone.Position
            end
        end
    end

    return zones
end

local zones = getFishingZones()
local zoneNames = {}
for zoneName, _ in pairs(zones) do
    table.insert(zoneNames, zoneName)
end



--// Auto Farm Events System

local selectedZone = nil
local originalPosition = nil

local selectedEventZone = nil
local originalEventPosition = nil

-- Function to get all fishing zones
local function getFishingZones()
    local zones = {}
    local fishingZones = workspace:FindFirstChild("zones") and workspace.zones:FindFirstChild("fishing")

    if fishingZones then
        for _, zone in pairs(fishingZones:GetChildren()) do
            if zone:IsA("BasePart") then
                zones[zone.Name] = zone.Position
            end
        end
    end

    return zones
end

local zones = getFishingZones()

-- Sort zones alphabetically
local zoneNames = {}
for zoneName, _ in pairs(zones) do
    table.insert(zoneNames, zoneName)
end
table.sort(zoneNames) -- Sorting alphabetically

-- Define event zones (replace with your actual event zone names)
local eventZoneNames = { "EventZone1", "EventZone2", "EventZone3", "EventZone4", "EventZone5", "Isonade" } -- Change these to your event zones
local availableEventZones = {}

-- Filter only available event zones
for _, zoneName in pairs(eventZoneNames) do
    if zones[zoneName] then
        table.insert(availableEventZones, zoneName)
    end
end



--// Refresh Zones/Events System

task.spawn(function()
    while true do
        -- Refresh zones data
        zones = getFishingZones()
        availableEvents = getAvailableEventZones()

        -- Refresh AutoFarm Zone Dropdown
        local updatedZoneNames = {}
        for zoneName, _ in pairs(zones) do
            table.insert(updatedZoneNames, zoneName)
        end
        table.sort(updatedZoneNames)

        if autoFarmZoneDropdown then
            autoFarmZoneDropdown:SetOptions(updatedZoneNames)
        end

        -- Refresh Event Zone Dropdown
        if eventDropdown then
            eventDropdown:SetOptions(availableEvents)
        end
    end
end)



--// UI for Zone Cast

FishingTab:CreateLabel("Zone Cast") -- Added label at the top

FishingTab:CreateDropdown({
    Name = "Select Zone",
    Options = zoneNames,
    CurrentOption = zoneNames[1] and {zoneNames[1]} or {},
    MultipleOptions = false,
    Flag = "autoFarmZoneDropdown",
    Callback = function(Options)
        selectedZone = zones[Options[1]]
    end,
})

FishingTab:CreateToggle({
    Name = "Zone Cast",
    CurrentValue = false,
    Flag = "ZoneCastToggle",
    Callback = function(Value)
        local character = getchar()
        local hrp = gethrp()
        local humanoid = gethum()

        if Value then
            if selectedZone then
                originalPosition = hrp.Position -- Save player's position
                hrp.CFrame = CFrame.new(selectedZone + Vector3.new(0, 8, 0)) -- Teleport slightly above the zone

                -- Freeze character without anchoring
                humanoid.PlatformStand = true 

                -- Enable auto functions
                flags['disableSwimming'] = true
                flags['autoequiprod'] = true
                flags['autocast'] = true
                flags['autoshake'] = true
                flags['autoreel'] = true
            else
                Rayfield:Notify({ Title = "Error", Content = "No zone selected!", Duration = 3 })
            end
        else
            if originalPosition then
                hrp.CFrame = CFrame.new(originalPosition) -- Teleport back
            end

            -- Unfreeze character
            humanoid.PlatformStand = false 

            -- Disable auto functions
            flags['disableSwimming'] = false
            flags['autoequiprod'] = false
            flags['autocast'] = false
            flags['autoshake'] = false
            flags['autoreel'] = false
        end
    end,
})



--// Event Cast Label / UIs

FishingTab:CreateLabel("Events Farm") -- Label for event zones

-- Available Events Label
local function getAvailableEventZones()
    local availableEvents = {}
    for _, zoneName in pairs(eventZoneNames) do
        if zones[zoneName] then
            table.insert(availableEvents, zoneName)
        end
    end
    return availableEvents
end

local function updateEventLabel()
    local availableEvents = getAvailableEventZones()
    local labelText = #availableEvents > 0 and "Available Events: " .. table.concat(availableEvents, ", ") or "No Events Available"

    if eventLabel.Set then
        eventLabel:Set(labelText) -- Some UI libraries use Set()
    elseif eventLabel.SetText then
        eventLabel:SetText(labelText) -- Some use SetText()
    elseif eventLabel.Update then
        eventLabel:Update(labelText) -- Others use Update()
    end
end

local eventLabel = FishingTab:CreateLabel("Checking for events...") -- Default text

-- Update label every few seconds
task.spawn(function()
    while true do
        updateEventLabel()
        task.wait(5) -- Update every 5 seconds
    end
end)

-- Event Zone Dropdown
FishingTab:CreateDropdown({
    Name = "Select Event Zone",
    Options = availableEventZones,
    CurrentOption = availableEventZones[1] and {availableEventZones[1]} or {},
    MultipleOptions = false,
    Flag = "eventDropdown",
    Callback = function(Options)
        selectedEventZone = zones[Options[1]]
    end,
})

-- Auto Event Zone Toggle
FishingTab:CreateToggle({
    Name = "Auto Event Zone",
    CurrentValue = false,
    Flag = "AutoEventZoneToggle",
    Callback = function(Value)
        local character = getchar()
        local hrp = gethrp()
        local humanoid = gethum()

        if Value then
            -- Wait for the event zone to be available
            while not selectedEventZone do
                task.wait(1)
                selectedEventZone = zones[Options[1]]
            end

            if selectedEventZone then
                originalEventPosition = hrp.Position -- Save player's position
                hrp.CFrame = CFrame.new(selectedEventZone + Vector3.new(0, 8, 0)) -- Teleport slightly above the event zone

                -- Freeze character without anchoring
                humanoid.PlatformStand = true 

                -- Enable auto functions
                flags['disableSwimming'] = true
                flags['autoequiprod'] = true
                flags['autocast'] = true
                flags['autoshake'] = true
                flags['autoreel'] = true
            else
                Rayfield:Notify({ Title = "Error", Content = "No event zone selected!", Duration = 3 })
            end
        else
            if originalEventPosition then
                hrp.CFrame = CFrame.new(originalEventPosition) -- Teleport back
            end

            -- Unfreeze character
            humanoid.PlatformStand = false 

            -- Disable auto functions
            flags['disableSwimming'] = false
            flags['autoequiprod'] = false
            flags['autocast'] = false
            flags['autoshake'] = false
            flags['autoreel'] = false
        end
    end,
})



--// Fishing Config Label / UIs

FishingTab:CreateLabel("Fishing Config") -- Added "Fishing Config" label
FishingTab:CreateToggle({
    Name = "Auto Equip Rod",
    CurrentValue = false,
    Flag = "AutoEquipRod",
    Callback = function(Value)
        flags['autoequiprod'] = Value
    end,
})

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



--// Teleport System

local function getIslandsFromWorld()
    local islands = {}
    local worldFolder = workspace:FindFirstChild("world")

    if worldFolder then
        local spawnsFolder = worldFolder:FindFirstChild("spawns")
        if spawnsFolder then
            for _, islandFolder in pairs(spawnsFolder:GetChildren()) do
                if islandFolder:IsA("Folder") then
                    local spawnPoint = islandFolder:FindFirstChild("spawn")
                    if spawnPoint and spawnPoint:IsA("BasePart") then
                        islands[islandFolder.Name] = spawnPoint.Position + Vector3.new(0, 8, 0)
                    end
                end
            end
        end
    end
    return islands
end

local islands = getIslandsFromWorld()
local islandNames = {}
for islandName, _ in pairs(islands) do
    table.insert(islandNames, islandName)
end

TeleportTab:CreateLabel("Teleport To Locations") -- Label for teleport UI

TeleportTab:CreateDropdown({
   Name = "Select Island",
   Options = islandNames,
   CurrentOption = islandNames[1] and {islandNames[1]} or {},
   MultipleOptions = false,
   Flag = "IslandDropdown",
   Callback = function(Options)
      selectedIsland = islands[Options[1]]
   end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Selected Island",
    Callback = function()
        if selectedIsland and lp.Character then
            lp.Character:MoveTo(selectedIsland)
        else
            Rayfield:Notify({ Title = "Error", Content = "No island selected!", Duration = 3 })
        end
    end
})



--// Teleport To Totems

-- Define teleport locations
local TpTotemLocations = {
    ["Sundial Totem"] = Vector3.new(-1149.45605, 134.531998, -1077.27502),
    ["Windset Totem"] = Vector3.new(2851.60205, 178.119995, 2703.03296),
    ["Smokescreen Totem"] = Vector3.new(2791.71191, 137.350998, -629.452026),
    ["Metor Totem"] = Vector3.new(-1946.22998, 272.911011, 232.078003),
    ["Zeus Storm Totem"] = Vector3.new(-4326.10889, -629.97699, 2686.59204),
    ["Poseidon Wrath Totem"] = Vector3.new(-3953.21289, -556.47699, 852.85199),
    ["Eclipse Totem"] = Vector3.new(5967.2832, 272.290009, 836.903015),
    ["Blizzard Totem"] = Vector3.new(20148.748, 740.133972, 5803.66113),
    ["Avalanche Totem"] = Vector3.new(19708.2539, 464.812012, 6058.12695),
    ["Tempest Totem"] = Vector3.new(36.4309998, 133.031006, 1946.11096),
    ["Aurora Totem"] = Vector3.new(-1813.20496, -139.332001, -3280.39893),
}

local selectedTotemLocation = nil

-- Extract location names (keys) into a table
local locationNames = {}
for name, _ in pairs(TpTotemLocations) do
    table.insert(locationNames, name)
end

-- UI: Teleport Section
TeleportTab:CreateLabel("Teleport To Totem") -- Label for teleport UI

-- Create Dropdown
TeleportTab:CreateDropdown({
    Name = "Select Teleport Location",
    Options = locationNames, -- Corrected way to list locations
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "TeleportTotemDropdown",
    Callback = function(Options)
        selectedTotemLocation = TpTotemLocations[Options[1]]
    end,
})

-- Create Teleport Button
TeleportTab:CreateButton({
    Name = "Teleport To Totem",
    Callback = function()
        if selectedTotemLocation then
            local hrp = gethrp()
            if hrp then
                hrp.CFrame = CFrame.new(selectedTotemLocation + Vector3.new(0, 5, 0)) -- Offset Y to prevent stuck
                Rayfield:Notify({ Title = "Teleported", Content = "You have teleported successfully!", Duration = 3 })
            else
                Rayfield:Notify({ Title = "Error", Content = "Character not found!", Duration = 3 })
            end
        else
            Rayfield:Notify({ Title = "Error", Content = "No location selected!", Duration = 3 })
        end
    end,
})



--// Disable Swimming System

-- Add toggle flag
flags['disableSwimming'] = false 
-- Create Toggle in Character Tab
CharacterTab:CreateToggle({
    Name = "Disable Swimming",
    CurrentValue = false,
    Flag = "DisableSwimmingToggle",
    Callback = function(Value)
        flags['disableSwimming'] = Value
    end,
})


-- Disable Swimming System (Make Water Act Like Ground)
task.spawn(function()
    while true do
        if flags['disableSwimming'] then
            local humanoid = gethum()
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
            end
        else
            local humanoid = gethum()
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
            end
        end
        task.wait(0.1)
    end
end)



--// Infinite Oxygen

CharacterTab:CreateToggle({
    Name = "Infinite Oxygen at Water",
    CurrentValue = false,
    Flag = "infoxygen",
    Callback = function(Value)
        flags['infoxygen'] = Value
    end,
})



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



--// Infinite Oxygen at Peaks System

CharacterTab:CreateToggle({
    Name = "Infinite Oxygen at Peaks",
    CurrentValue = false,
    Flag = "NoPeaksSystems",
    Callback = function(Value)
        flags['nopeakssystems'] = Value
    end,
})

task.spawn(function()
    while true do
        if flags['nopeakssystems'] then
            getchar():SetAttribute('WinterCloakEquipped', true)
            getchar():SetAttribute('Refill', true)
        else
            getchar():SetAttribute('WinterCloakEquipped', nil)
            getchar():SetAttribute('Refill', false)
        end
        task.wait(0.1)
    end
end)
