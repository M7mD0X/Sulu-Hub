if game.PlaceId == 17625359962 then

  -- -- Boot Ui Library
  local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
  -- -- Create Window
  local Window = Rayfield:CreateWindow({
   Name = "Sulu Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Rivals",
   LoadingSubtitle = "by Cero",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "Sulu Hub", -- Create a custom folder for your hub/game
      FileName = "Sulu Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

  
  -- -- Create Tabs
  local MainTab = Window:CreateTab("Main", nil)
  local EspTab = Window:CreateTab("Esp", nil)

  -- -- Main Tab Scripts
  -- Aimbot Button
  local Button = MainTab:CreateButton({
   Name = "AimBot",
   Callback = function()
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

local aimSmoothing = 0.15 -- Lower = smoother aim
local aimbotEnabled = false

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 100, 0, 30)
ToggleButton.Position = UDim2.new(0.5, -50, 0.1, 0)
ToggleButton.Text = "Aimbot: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSans
ToggleButton.TextSize = 14

local DeleteButton = Instance.new("TextButton", ScreenGui)
DeleteButton.Size = UDim2.new(0, 30, 0, 30)
DeleteButton.Position = UDim2.new(0.5, 60, 0.1, 0)
DeleteButton.Text = "X"
DeleteButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
DeleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteButton.Font = Enum.Font.SourceSans
DeleteButton.TextSize = 14

local deleteClickCount = 0

local function isVisible(target)
    local origin = Camera.CFrame.Position
    local direction = (target.Position - origin).Unit * (target.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)

    return result == nil or result.Instance:IsDescendantOf(target.Parent)
end

local function getBestTarget()
    local bestTarget = nil
    local bestDot = -math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if Teams and player.Team == LocalPlayer.Team then
                continue
            end

            local targetPart = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart and isVisible(targetPart) then
                local direction = (targetPart.Position - Camera.CFrame.Position).Unit
                local dot = direction:Dot(Camera.CFrame.LookVector)

                if dot > bestDot then
                    bestDot = dot
                    bestTarget = targetPart
                end
            end
        end
    end
    return bestTarget
end

local function aimAt(target)
    if target then
        local newCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        local tweenInfo = TweenInfo.new(aimSmoothing, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = newCFrame})
        tween:Play()
    end
end

local function updateAimbot()
    if aimbotEnabled then
        local target = getBestTarget()
        if target then
            aimAt(target)
        end
    end
end

RunService.RenderStepped:Connect(updateAimbot)

ToggleButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        ToggleButton.Text = "Aimbot: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        ToggleButton.Text = "Aimbot: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

DeleteButton.MouseButton1Click:Connect(function()
    deleteClickCount += 1
    task.delay(0.5, function() deleteClickCount = 0 end)

    if deleteClickCount >= 2 then
        ToggleButton:Destroy()
        DeleteButton:Destroy()
    end
end)

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeDraggable(ToggleButton)
makeDraggable(DeleteButton)
   -- The function that takes place when the button is pressed
   end,
})

  -- Other in main tab

  
  -- -- Esp Tab Scripts
  -- Esp toggle
end
