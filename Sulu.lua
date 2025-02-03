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
local MainTab = Window:CreateTab("Main", nil)
local TeleportTab = Window:CreateTab("Teleport", nil)
local CharacterTab = Window:CreateTab("Character", nil)

--------------------------
-- Teleport Functionality
--------------------------
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

local selectedIsland = nil
local Dropdown = TeleportTab:CreateDropdown({
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
        if selectedIsland and game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:MoveTo(selectedIsland)
        else
            Rayfield:Notify({ Title = "Error", Content = "No island selected!", Duration = 3 })
        end
    end
})

-----------------------------
-- Character Modifications
-----------------------------
local walkSpeedEnabled = false
local jumpPowerEnabled = false
local gravityEnabled = false
local walkSpeed = 16
local jumpPower = 50
local gravity = 196.2

-- Function to Continuously Apply Character Changes
task.spawn(function()
    while true do
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            
            -- Apply WalkSpeed
            if walkSpeedEnabled then
                humanoid.WalkSpeed = walkSpeed
            else
                humanoid.WalkSpeed = 16 -- Reset to Default
            end

            -- Apply JumpPower
            if jumpPowerEnabled then
                humanoid.JumpPower = jumpPower
            else
                humanoid.JumpPower = 50 -- Reset to Default
            end
        end

        -- Apply Gravity
        if gravityEnabled then
            game.Workspace.Gravity = gravity
        else
            game.Workspace.Gravity = 196.2 -- Reset to Default
        end

        task.wait(0.1) -- Smooth Updates
    end
end)

-- Walk Speed Toggle & Slider
CharacterTab:CreateToggle({
    Name = "Enable Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        walkSpeedEnabled = Value
    end,
})

CharacterTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        walkSpeed = Value
    end,
})

-- Jump Power Toggle & Slider
CharacterTab:CreateToggle({
    Name = "Enable Jump Power",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        jumpPowerEnabled = Value
    end,
})

CharacterTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 5,
    Suffix = "Jump",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        jumpPower = Value
    end,
})

-- Gravity Toggle & Slider
CharacterTab:CreateToggle({
    Name = "Enable Gravity",
    CurrentValue = false,
    Flag = "GravityToggle",
    Callback = function(Value)
        gravityEnabled = Value
    end,
})

CharacterTab:CreateSlider({
    Name = "Gravity",
    Range = {50, 196.2},
    Increment = 1,
    Suffix = "Gravity",
    CurrentValue = 196.2,
    Flag = "Gravity",
    Callback = function(Value)
        gravity = Value
    end,
})

--------------------------------
-- Finalizing Sulu Hub
--------------------------------
-- When the script starts, reset to default values
walkSpeed = 16
jumpPower = 50
gravity = 196.2
game.Workspace.Gravity = gravity
