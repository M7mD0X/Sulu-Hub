-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "Fisch Hub",
   LoadingTitle = "Fisch Game Hub",
   LoadingSubtitle = "by YourName",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- **Create Main Tab (Empty for Now)**
local MainTab = Window:CreateTab("Main", nil)

-- **Create Teleport Tab**
local TeleportTab = Window:CreateTab("Teleport", nil)

-- **Function to Get All Islands and Their Spawn Points**
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

-- **Get Islands List**
local islands = getIslandsFromWorld()
local islandNames = {}
for islandName, _ in pairs(islands) do
    table.insert(islandNames, islandName)
end

local selectedIsland = nil

-- **Dropdown for Selecting an Island**
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

-- **Button to Teleport to Selected Island**
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

-- **Create Character Tab**
local CharacterTab = Window:CreateTab("Character", nil)

-- **State Variables for Toggles**
local walkSpeedEnabled = false
local jumpPowerEnabled = false
local gravityEnabled = false

-- **Walk Speed Toggle**
CharacterTab:CreateToggle({
    Name = "Enable Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        walkSpeedEnabled = Value
    end,
})

-- **Walk Speed Slider**
CharacterTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        if walkSpeedEnabled then
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = Value
            end
        end
    end,
})

-- **Jump Power Toggle**
CharacterTab:CreateToggle({
    Name = "Enable Jump Power",
    CurrentValue = false,
    Flag = "JumpPowerToggle",
    Callback = function(Value)
        jumpPowerEnabled = Value
    end,
})

-- **Jump Power Slider**
CharacterTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 5,
    Suffix = "Jump",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        if jumpPowerEnabled then
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.JumpPower = Value
            end
        end
    end,
})

-- **Gravity Toggle**
CharacterTab:CreateToggle({
    Name = "Enable Gravity",
    CurrentValue = false,
    Flag = "GravityToggle",
    Callback = function(Value)
        gravityEnabled = Value
    end,
})

-- **Gravity Slider**
CharacterTab:CreateSlider({
    Name = "Gravity",
    Range = {50, 196.2},
    Increment = 1,
    Suffix = "Gravity",
    CurrentValue = 196.2,
    Flag = "Gravity",
    Callback = function(Value)
        if gravityEnabled then
            game.Workspace.Gravity = Value
        end
    end,
})
