----------------------------------------------------------------
-- PLAYER LIST PANEL WITH SEARCH & REMOVABLE ENTRIES (X BUTTON)
----------------------------------------------------------------
-- Generic reusable component: shows Roblox players in a searchable
-- scrolling list. Clicking the "X" on an entry removes it from a
-- local "selectedPlayers" set (e.g. for a moderation tool, friends
-- list, party/group picker, etc.)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local COLOR_ON = Color3.fromRGB(138, 43, 226)
local COLOR_OFF = Color3.fromRGB(40, 30, 55)

local selectedPlayers = {} -- [UserId] = true/false

local listFrame = Instance.new("Frame")
listFrame.Name = "PlayerListPanel"
listFrame.Size = UDim2.new(0, 220, 0, 360)
listFrame.Position = UDim2.new(1, 15, 0, 0)
listFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
listFrame.BorderSizePixel = 0
listFrame.Visible = false
listFrame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") -- adjust parent as needed

Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", listFrame)
stroke.Thickness = 1.5
stroke.Color = COLOR_ON

-- Search Bar
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(25, 18, 35)
searchBox.PlaceholderText = "Search players..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 12
searchBox.Parent = listFrame
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

local listScroll = Instance.new("ScrollingFrame")
listScroll.Size = UDim2.new(1, -20, 1, -60)
listScroll.Position = UDim2.new(0, 10, 0, 50)
listScroll.BackgroundTransparency = 1
listScroll.ScrollBarThickness = 4
listScroll.ScrollBarImageColor3 = COLOR_ON
listScroll.Parent = listFrame

local listLayout = Instance.new("UIListLayout", listScroll)
listLayout.Padding = UDim.new(0, 5)

local function refreshListUI()
    local searchText = string.lower(searchBox.Text)

    for _, child in ipairs(listScroll:GetChildren()) do
        if child:IsA("Frame") and child.Name == "Entry" then
            child:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local nameMatch = string.find(string.lower(player.Name), searchText, 1, true)
        local displayMatch = string.find(string.lower(player.DisplayName), searchText, 1, true)

        if searchText ~= "" and not nameMatch and not displayMatch then continue end

        -- Entry container
        local entry = Instance.new("Frame")
        entry.Name = "Entry"
        entry.Size = UDim2.new(1, -10, 0, 40)
        entry.BackgroundColor3 = selectedPlayers[player.UserId] and COLOR_ON or COLOR_OFF
        entry.Parent = listScroll
        Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 4)

        -- Label
        local label = Instance.new("TextButton")
        label.Size = UDim2.new(1, -36, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name .. "\n(@" .. player.DisplayName .. ")"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.TextWrapped = true
        label.Parent = entry

        label.MouseButton1Click:Connect(function()
            selectedPlayers[player.UserId] = not selectedPlayers[player.UserId]
            entry.BackgroundColor3 = selectedPlayers[player.UserId] and COLOR_ON or COLOR_OFF
        end)

        -- X (remove) button
        local removeBtn = Instance.new("TextButton")
        removeBtn.Size = UDim2.new(0, 28, 0, 28)
        removeBtn.Position = UDim2.new(1, -32, 0.5, -14)
        removeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)
        removeBtn.Text = "X"
        removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeBtn.Font = Enum.Font.GothamBold
        removeBtn.TextSize = 14
        removeBtn.Parent = entry
        Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)

        removeBtn.MouseButton1Click:Connect(function()
            -- Remove this player from the selected set and drop the entry from the list
            selectedPlayers[player.UserId] = nil
            entry:Destroy()
        end)
    end

    listScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(refreshListUI)
Players.PlayerAdded:Connect(refreshListUI)
Players.PlayerRemoving:Connect(refreshListUI)

local function togglePanel(btn)
    listFrame.Visible = not listFrame.Visible
    if btn then
        btn.Text = listFrame.Visible and "PLAYER LIST: ON" or "PLAYER LIST: OFF"
    end
    if listFrame.Visible then refreshListUI() end
end

return {
    frame = listFrame,
    refresh = refreshListUI,
    toggle = togglePanel,
    selected = selectedPlayers,
}
