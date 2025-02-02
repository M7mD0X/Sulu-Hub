-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "Sulu",
   LoadingTitle = "This Script Made Using AI",
   LoadingSubtitle = "by Cero",
   ConfigurationSaving = { Enabled = True },
   KeySystem = false
})

-- **Create Tabs**
local MainTab = Window:CreateTab("Main", nil)
local TeleportTab = Window:CreateTab("Teleport", nil)
local CharacterTab = Window:CreateTab("Character", nil)

-- **Get All Islands & Their Spawn Points**
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

-- **Dropdown for Selecting an Island**
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

-- **Button to Teleport**
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

-- **Character Settings Variables**
local walkSpeedEnabled = false
local jumpPowerEnabled = false
local gravityEnabled = false
local walkSpeed = 16
local jumpPower = 50
local gravity = 196.2

-- **Function to Continuously Apply Character Changes**
task.spawn(function()
    while true do
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            if walkSpeedEnabled then
                character.Humanoid.WalkSpeed = walkSpeed
            end
            if jumpPowerEnabled then
                character.Humanoid.JumpPower = jumpPower
            end
        end
        if gravityEnabled then
            game.Workspace.Gravity = gravity
        end
        task.wait(0.1) -- Smooth Updates
    end
end)

-- **Walk Speed Toggle & Slider**
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

-- **Jump Power Toggle & Slider**
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

-- **Gravity Toggle & Slider**
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
