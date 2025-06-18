local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CharacterInitEvent = ReplicatedStorage.Events.CharacterInitEvent
local EndGameEvent = ReplicatedStorage.Events.EndGameEvent
local StartGameEvent: RemoteEvent = ReplicatedStorage.Events.StartGameEvent

local player = Players.LocalPlayer

local Platform = workspace.Platform

local LeftPlate = Platform:WaitForChild("LeftPlate")
local RightPlate = Platform:WaitForChild("RightPlate")

local connected = false

--Loads animations, adds a RunService function which check if the player is hit
CharacterInitEvent.OnClientEvent:Connect(function()
	local character = player.Character
	local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local head = character:WaitForChild("Head")

	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://129808203600336"

	local Animator = character.Humanoid.Animator
	local AnimationTrack = Animator:LoadAnimation(Animation)
	local AnimationPlaying = false

	--Constantly checks if player is hit by an obstacle. If so, the game ends
	RunService.Heartbeat:Connect(function()
		if connected then
			for _, part in pairs(workspace:GetPartsInPart(character.hitbox)) do
				if part:FindFirstAncestor(character.Name) ~= character and part.Parent ~= workspace.Platform then
					EndGameEvent:FireServer(player)
					connected = false
				end
			end
		end
	end)

	--Handles UserInputs
	UserInputService.InputBegan:Connect(function(input)
		local RaycastParams = RaycastParams.new()
		RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		RaycastParams.FilterDescendantsInstances = { Platform.SpawnLocation }
		--Uses a ray to determine which plate the character is on top off
		local ray =
			workspace:Raycast(character:WaitForChild("Right Leg").Position, Vector3.new(0, -10, 0), RaycastParams)

		local StandingOnTopOff = ray.Instance

		if input.KeyCode == Enum.KeyCode.A and StandingOnTopOff ~= LeftPlate then
			head.CFrame = head.CFrame * CFrame.new(-6.5, 0, 0)
		elseif input.KeyCode == Enum.KeyCode.D and StandingOnTopOff ~= RightPlate then
			head.CFrame = head.CFrame * CFrame.new(6.5, 0, 0)
		elseif input.KeyCode == Enum.KeyCode.S then
			if AnimationPlaying then
				return
			end

			local Downward = false

			--Runs regardless of the state of the character
			task.spawn(function()
				AnimationPlaying = true
				AnimationTrack:Play()
				AnimationTrack.Stopped:Wait()
				AnimationPlaying = false
				Downward = false
			end)

			--Constantly checks if the player pressed S while in the air
			while not Downward do
				--If they did, the humanoidRootPart will experience a downward force which makes the gameplay more enjoyable and fast paced
				if
					input.KeyCode == Enum.KeyCode.S
					and character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall
				then
					Downward = true
					print("Force activated")
					local DownwardForce = HumanoidRootPart.DownwardForce
					DownwardForce.Enabled = true
					DownwardForce.Force = HumanoidRootPart.CFrame.UpVector * 4000 * -1
					wait(0.2)
					DownwardForce.Enabled = false
					DownwardForce.Force = Vector3.new(0, 0, 0)
					print(DownwardForce.Force)
				end
				wait()
			end
		end
	end)
end)

--Starts the RunService loop
StartGameEvent.OnClientEvent:Connect(function()
	connected = true
end)
