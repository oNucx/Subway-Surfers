local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdatePointsEvent = ReplicatedStorage.Events.UpdatePointsEvent
local GuiLoadedEvent = ReplicatedStorage.Events.GuiLoadedEvent
local StartGameEvent = ReplicatedStorage.Events.StartGameEvent
local EndGameEvent: RemoteEvent = ReplicatedStorage.Events.EndGameEvent

local player
local PlayerUI
local StartGame
local RestartGame
local PointsCounter

--When character is loaded, connects an event to the button which starts the game when clicked
GuiLoadedEvent.OnClientEvent:Connect(function()
	player = Players.LocalPlayer
	PlayerUI = player.PlayerGui.PlayerUI

	StartGame = PlayerUI.StartGame
	RestartGame = PlayerUI.RestartGame

	StartGame.Transparency = 0
	StartGame.Interactable = true

	StartGame.MouseButton1Click:Connect(function()
		StartGame.Visible = false
		RestartGame.Transparency = 0
		RestartGame.Interactable = true

		StartGameEvent:FireServer(player, true)
	end)

	RestartGame.MouseButton1Click:Connect(function()
		RestartGame.Visible = false
		EndGameEvent:FireServer(player, true)
	end)
end)

--Updates the clients displayed points
UpdatePointsEvent.OnClientEvent:Connect(function(points)
	PointsCounter = PlayerUI.PointsCounter
	PointsCounter.Text = points
end)

--Displays a loading screen which diseppears after 2 seconds and resets PointsCounter
EndGameEvent.OnClientEvent:Connect(function()
	local LoadingGui = player.PlayerGui.LoadingGui
	LoadingGui.Enabled = true

	task.wait(2)
	LoadingGui.Enabled = false

	RestartGame.Transparency = 0.5
	RestartGame.Interactable = false
	RestartGame.Visible = true
	StartGame.Visible = true
	PointsCounter.Text = "0"
end)
