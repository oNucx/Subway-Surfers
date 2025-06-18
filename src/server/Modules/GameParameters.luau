local GameParameters = {
	Points = 0,
	Speed = 50,
	GameStarted = false,
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdatePointsEvent = ReplicatedStorage.Events.UpdatePointsEvent

--Updates the speed of the track and points of the player
function GameParameters.Start(player)
	local TimeWhenStarted = DateTime.now()
	local timeElapsed = 0
	local endTime = 0
	GameParameters.GameStarted = true

	--The code is a little messy here, but essentially what it does is updating the points to the player. Updates the highscore as well if current points is higher than
	--points in highscore
	task.spawn(function()
		while GameParameters.GameStarted do
			endTime = DateTime.now()
			timeElapsed = endTime.UnixTimestamp - TimeWhenStarted.UnixTimestamp

			GameParameters.Points = math.floor(timeElapsed ^ 2)
			UpdatePointsEvent:FireClient(player, GameParameters.Points)
			if GameParameters.Points > player.leaderstats.HighScore.Value then
				player.leaderstats.HighScore.Value = GameParameters.Points
			end
			wait(0.2)
		end
	end)

	--Adds 1 to the speed every second making the track go faster
	while GameParameters.GameStarted do
		print("running")
		GameParameters.Speed += 1
		print(GameParameters.Speed)
		GameParameters.Points = timeElapsed * 2
		task.wait(1)
	end
end

--Stops the while-loops responsible for tracking and updating points and speed
function GameParameters.Stop()
	GameParameters.GameStarted = false
end

--Resets parameters
function GameParameters.RestartParameters()
	GameParameters.Speed = 50
	GameParameters.Points = 0
	GameParameters.GameStarted = false
end

return GameParameters
