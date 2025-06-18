local DataManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

DataManager.Profiles = {}

function DataManager.AddHighScore(player: Player, NewHighscore: number)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end

	profile.Data.HighScore = NewHighscore

	local leaderstats = player:FindFirstChild("leaderstats")
	leaderstats.HighScore.Value = profile.Data.HighScore

	ReplicatedStorage.Events.SetHighScore:FireClient(player, profile.Data.HighScore)
end

return DataManager
