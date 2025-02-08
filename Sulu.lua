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

        if flags['autocast'] then
            local rod = FindRod()
            if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("lure") then
                if rod.values.lure.Value <= 0.001 then
                    task.wait(0.3) -- Made it slightly faster
                    rod.events.cast:FireServer(100, 1)
                end
            end
        end

        if flags['autoreel'] then
            local rod = FindRod()
            if rod and rod:FindFirstChild("values") and rod.values:FindFirstChild("lure") then
                if rod.values.lure.Value == 100 then
                    task.wait(0.3) -- Faster reeling
                    ReplicatedStorage.events.reelfinished:FireServer(100, true)
                end
            end
        end

        task.wait(0.1)
    end
end)

-- UI for Fishing
FishingTab:CreateLabel("AutoFarm") -- Added label at the top

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

FishingTab:CreateToggle({
    Name = "Perfect Cast",
    CurrentValue = false,
    Flag = "PerfectCastToggle",
    Callback = function(Value)
        flags['perfectcast'] = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Always Catch",
    CurrentValue = false,
    Flag = "AlwaysCatchToggle",
    Callback = function(Value)
        flags['alwayscatch'] = Value
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
