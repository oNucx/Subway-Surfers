local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataManager = require(ServerScriptService.Data.DataManager)
local RoadSpawner = require(ServerScriptService.Modules.RoadSpawner)

local StartGameEvent: RemoteEvent = ReplicatedStorage.Events.StartGameEvent
local EndGameEvent: RemoteEvent = ReplicatedStorage.Events.EndGameEvent

local GameParameters = require(ServerScriptService.Modules.GameParameters)

local SpawnPart = workspace.SpawnPart
local DeletePart = workspace.DeletePart

local RoundStarted = false

--Starts spawning the roads
local StartRound = function()
	RoadSpawner.SpawnRoad()

	--If EndPart is inside SpawnPart, the RoadSpawner module spawns a new road. If a member of any given clone of RoadTemplate touches DeletePart, the RoadSpawner module
	--deletes the part
	while RoundStarted do
		for _, member in pairs(workspace:GetPartsInPart(SpawnPart)) do
			if member:IsA("Part") and member.Name == "EndPart" then
				print("Spawn road")
				RoadSpawner.SpawnRoad()
				task.wait(0.5)
			end
		end
		for _, member in pairs(workspace:GetPartsInPart(DeletePart)) do
			if member:IsA("Part") and member:FindFirstAncestor("RoadTemplate") then
				RoadSpawner.DeleteRoad(member)
				break
			end
		end
		wait()
	end
end

--When the StartButton is clicked, the StartRound() function is called and the game parameters gets updated (Speed of road, points). I use task.spawn since
--GameParameters.Start() includes while loops
StartGameEvent.OnServerEvent:Connect(function(player)
	RoundStarted = true
	StartGameEvent:FireClient(player)
	task.spawn(function()
		StartRound()
	end)
	GameParameters.Start(player)
end)

--Ends the generation of roads, and terminates every RoadTemplate from memory. Stores the new HighScore and resets parameters and the gui (EndGameEvent).
--RoadSpawner.Restart() is explained in the given module
EndGameEvent.OnServerEvent:Connect(function(player)
	RoundStarted = false

	for _, road in pairs(workspace.RoadTracks:GetChildren()) do
		road:Destroy()
		road = nil
	end

	local newHighScore = player.leaderstats.HighScore.Value
	DataManager.AddHighScore(player, newHighScore)

	RoadSpawner.Restart()
	GameParameters.RestartParameters()

	EndGameEvent:FireClient(player)
end)
