

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
local ShopTab = Window:CreateTab("Shop/Sell", nil)
local CharacterTab = Window:CreateTab("Character", nil)



--// Services & Variables

local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local RunService = cloneref(game:GetService('RunService'))
local GuiService = cloneref(game:GetService('GuiService'))

-- local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = game:GetService("Players").LocalPlayer
local PlayerGui = lp:FindFirstChild("PlayerGui")

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



--// Bypass System Anti Cheats

local function Bypass()
    print("bypassing")
    -- Remove anti-cheat detection
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" and islclosure(v) and not is_synapse_function(v) then
            local info = debug.getinfo(v)
            if info.name == "CheckBan" or info.name == "CheckExploit" then
                hookfunction(v, function() return nil end)
		print("bypassed")
            end
        end
    end
end

-- Run Bypass immediately
Bypass()



--// Fishing Automation

RunService.Heartbeat:Connect(function()
		
    if flags['autoshake'] then
        local shakeUI = lp.PlayerGui:FindFirstChild('shakeui')
        if shakeUI then
            local safeZone = shakeUI:FindFirstChild('safezone')
            if safeZone then
                local button = safeZone:FindFirstChild('button')
                
                -- Check if button is a valid GuiObject before setting it
                if button and button:IsA("GuiObject") and button.Parent then
                    -- Only set SelectedObject if it's different
                    if GuiService.SelectedObject ~= button then
                        GuiService.SelectedObject = button
                    end

                    -- Simulate pressing Enter if button is properly selected
                    if GuiService.SelectedObject == button then
                        local vim = game:GetService('VirtualInputManager')
                        vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                        vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                    end
                else
                    -- Prevent setting an invalid object
                    if GuiService.SelectedObject and not GuiService.SelectedObject.Parent then
                        GuiService.SelectedObject = nil
                    end
                end
            end
        end
    end



		
    -- Auto Equip Rod Optimization
    if flags['autoequiprod'] and not FindRod() then
        local tool = lp.Backpack:FindFirstChildWhichIsA("Tool")
        if tool then
            lp.Character.Humanoid:EquipTool(tool)
        end
    end

    -- AutoCast Optimization
    local rod = FindRod()
    if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("lure") then
        local lureValue = rod.values.lure.Value

        if flags['autocast'] and lureValue <= 0.001 then
            rod.events.cast:FireServer(math.random(30, 99), math.random(0,1))
        end

        if flags['autoreel'] and lureValue == 100 then
	    wait(0.4)
            ReplicatedStorage.events.reelfinished:FireServer(100, false)
        end
    end
end)




--// Zone Cast System




--// Zone Cast System

local selectedZone = nil
local originalPosition = nil
local dropdownOptions = {}
local zonesDropdown -- Store dropdown UI element

-- Function to get fishing zones dynamically
local function updateFishingZones()
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

-- Function to refresh dropdown only if needed
local function refreshDropdown()
    local newZones = updateFishingZones()
    local newDropdownOptions = {}

    for zoneName, _ in pairs(newZones) do
        table.insert(newDropdownOptions, zoneName)
    end

    -- Only refresh if zones actually changed
    if #newDropdownOptions ~= #dropdownOptions then
        dropdownOptions = newDropdownOptions

        -- Preserve current selection
        local currentSelection = zonesDropdown.CurrentOption[1] or nil
        zonesDropdown:Refresh(dropdownOptions)

        -- Restore selection if it's still available
        if currentSelection and table.find(dropdownOptions, currentSelection) then
            zonesDropdown:Set({currentSelection})
        end
    end

    return newZones
end

--// UI for Zone Cast
FishingTab:CreateLabel("Zone Cast") -- Added label at the top

zonesDropdown = FishingTab:CreateDropdown({
    Name = "Select Zone",
    Options = dropdownOptions,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "autoFarmZoneDropdown",
    Callback = function(Options)
        selectedZone = updateFishingZones()[Options[1]]
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
                hrp.CFrame = CFrame.new(selectedZone + Vector3.new(0, 8, 0)) -- Teleport above the zone

                -- Freeze character without anchoring
                game:GetService("Workspace").Gravity = 0
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
            game:GetService("Workspace").Gravity = 196.2
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

-- Auto-Update Dropdown Every 5 Seconds (Only Refreshes When Needed)
task.spawn(function()
    while task.wait(5) do
        refreshDropdown()
    end
end)








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





-- Test new features


ShopTab:CreateButton({
   Name = "Sell All",
   Callback = function()
         ReplicatedStorage:WaitForChild("events"):WaitForChild("selleverything"):InvokeServer()
   -- The function that takes place when the button is pressed
   end,
})



ShopTab:CreateButton({
   Name = "Sell Hand",
   Callback = function()
         workspace.world.npcs:FindFirstChild("Marc Merchant").merchant.sell:InvokeServer()
   -- The function that takes place when the button is pressed
   end,
})


