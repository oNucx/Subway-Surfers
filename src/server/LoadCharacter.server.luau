local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterInitEvent = ReplicatedStorage.Events.CharacterInitEvent
local GuiLoadedEvent = ReplicatedStorage.Events.GuiLoadedEvent
local DataLoaded = ReplicatedStorage.Events.DataLoaded

--When the player is added to the server, creates a hitbox and weld, where the hitbox is attached to the torso by the weld.
--A VectorForce which is used in PlayerInputHandler. Then starts the characterInit function explained in PlayerInputHandler
--When the leaderstats and data is gathered and loaded, enables the StartButton
Players.PlayerAdded:Connect(function(player)
	local character = player.CharacterAdded:Wait()
	local HumanoidRootPart = character.HumanoidRootPart
	local humanoid = character:WaitForChild("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0

		local hitbox = Instance.new("Part")
		hitbox.Name = "hitbox"
		hitbox.Size = HumanoidRootPart.Size
		hitbox.Anchored = false
		hitbox.CanCollide = false
		hitbox.Transparency = 1
		hitbox.CFrame = HumanoidRootPart.CFrame
		hitbox.Parent = character

		local Weld = Instance.new("WeldConstraint")
		Weld.Parent = hitbox
		Weld.Part0 = character:WaitForChild("Torso")
		Weld.Part1 = hitbox

		local VectorForce = Instance.new("VectorForce")
		VectorForce.Name = "DownwardForce"
		VectorForce.Enabled = false
		VectorForce.Attachment0 = HumanoidRootPart.RootAttachment
		VectorForce.Parent = HumanoidRootPart
		VectorForce.Force = Vector3.new(0, 0, 0)

		CharacterInitEvent:FireClient(player)

		DataLoaded.Event:Connect(function()
			GuiLoadedEvent:FireClient(player)
		end)
	end
end)
