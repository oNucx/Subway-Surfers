--Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--ProfileStore
local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)

local DataLoaded: BindableEvent = ReplicatedStorage.Events.DataLoaded

local function GetStoreName()
	return RunService:IsStudio() and "Test" or "Live"
end

local Template = require(ServerScriptService.Data.Template)
local DataManager = require(ServerScriptService.Data.DataManager)

--Access profile store
local PlayerStore = ProfileStore.New(GetStoreName(), Template)

--typeof(PlayerStore:StartSessionAsync() assigns the the type of the profile to be the type of the player joined
--Add leaderstats and synchronize player data
local function Initialize(player: Player, profile: typeof(PlayerStore:StartSessionAsync()))
	--For leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Parent = player
	leaderstats.Name = "leaderstats"

	local HighScore = Instance.new("IntValue")
	HighScore.Parent = leaderstats
	HighScore.Value = profile.Data.HighScore
	HighScore.Name = "HighScore"

	--Sync player data (UI updates, inventory update etc.)
	ReplicatedStorage.Events.SetHighScore:FireClient(player, profile.Data.HighScore)
	DataLoaded:Fire()
end

--Creates and stores a profile
local function PlayerAddedFunction(player: Player)
	--Start a new profile session
	local profile = PlayerStore:StartSessionAsync("Player" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	--Sanity check to ensure profile exists
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing data variables from template

		--Handles session-locking
		profile.OnSessionEnd:Connect(function()
			DataManager.Profiles[player] = nil
			player:Kick("Data error occured, Please rejoin.")
		end)

		--Save profile for later use
		if player.Parent == Players then
			DataManager.Profiles[player] = profile
			Initialize(player, profile)
		else
			profile:EndSession()
		end
	else
		--If server shuts down while player is joining
		player:Kick("Data error occured, Please rejoin.")
	end
end

--Early joiners
for _, player in Players:GetPlayers() do
	task.spawn(PlayerAddedFunction, player)
end
Players.PlayerAdded:Connect(PlayerAddedFunction)

Players.PlayerRemoving:Connect(function(player)
	local profile = DataManager.Profiles[player]
	if not profile then
		return
	end
	profile:EndSession()
	DataManager.Profiles[player] = nil
end)
