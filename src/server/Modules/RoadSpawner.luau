local RoadSpawner = {}

local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local GameParameters = require(ServerScriptService.Modules.GameParameters)

local Variables = {
	CurrentRoad = nil,
	PreviousRoad = nil,
}

--Spawns a clone of RoadTemplate to workspace
function RoadSpawner.SpawnRoad()
	local SpawnPart = workspace.SpawnPart
	local RoadTemplate = ServerStorage.MapParts.RoadTemplate:Clone()
	local LinearVelocity = RoadTemplate.PrimaryPart.LinearVelocity
	Variables.PreviousRoad = Variables.CurrentRoad
	Variables.CurrentRoad = RoadTemplate

	--If the speed is updated, it applies to all RoadTemplates in workspace, not just one
	for _, track in pairs(workspace.RoadTracks:GetChildren()) do
		track.PrimaryPart.LinearVelocity.LineVelocity = GameParameters.Speed
	end

	LinearVelocity.MaxForce = math.huge
	LinearVelocity.LineDirection = Vector3.new(-1, 0, 0)
	LinearVelocity.LineVelocity = GameParameters.Speed

	local randomNum = math.random(1, 3)
	local TableOfObstacles = ServerStorage.MapParts.Obstacles:GetChildren()

	--Randomly generates obstacle on the road gives some pre-defined positions. Each possible obstacle location has a 1/3 chance of having an obstacle
	for _, part in pairs(RoadTemplate.PossibleObstacleLocations:GetChildren()) do
		local otherRandomNum = math.random(1, 3)
		if randomNum == otherRandomNum then
			local RandomObstacleNumber = math.random(1, #ServerStorage.MapParts.Obstacles:GetChildren())
			local randomObstacle = TableOfObstacles[RandomObstacleNumber]:Clone()
			local WeldConstraint = randomObstacle.PrimaryPart.WeldConstraint
			WeldConstraint.Part0 = RoadTemplate.PrimaryPart
			WeldConstraint.Part1 = randomObstacle.PrimaryPart

			randomObstacle.Parent = RoadTemplate
			randomObstacle:PivotTo(part.CFrame)
		end
	end

	--Spawns the RoadTemplate at the SpawnPart in workspace
	RoadTemplate.Parent = workspace.RoadTracks
	RoadTemplate:PivotTo(SpawnPart.CFrame)

	--Every time the EndPart of the RoadTemplate touches the SpawnPart, it spawns a new clone of RoadTemplate due to the while-loop in GameManager.
	--The RoadTemplate's CFrame should be the same as the EndPart of the previous RoadTemplate.
	--But since there are no RoadTemplate's in workspace to begin with, we have to spawn one clone of RoadTemplate in order to start the mechanism.
	if Variables.CurrentRoad ~= nil and Variables.PreviousRoad ~= nil then
		local currentEndPartCFrame = Variables.PreviousRoad.EndPart.CFrame

		RoadTemplate:PivotTo(currentEndPartCFrame)
	else
		RoadTemplate:PivotTo(SpawnPart.CFrame)
	end
end

--Deletes a clone of RoadTemplate from memory
function RoadSpawner.DeleteRoad(road)
	local model = road.Parent
	model:Destroy()
	model = nil
end

--Sets the variables to nil
function RoadSpawner.Restart()
	Variables.CurrentRoad = nil
	Variables.PreviousRoad = nil
end

return RoadSpawner
