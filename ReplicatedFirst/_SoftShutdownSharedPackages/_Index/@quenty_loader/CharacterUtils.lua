local Players = game:GetService("Players")

local CharacterUtils = {}

function CharacterUtils.getPlayerHumanoid(player)
	local character = player.Character

	if character then
		return character:FindFirstChildOfClass("Humanoid")
	end

	return nil
end

function CharacterUtils.getAlivePlayerHumanoid(p)
	local playerHumanoid = CharacterUtils.getPlayerHumanoid(p)

	if playerHumanoid and not (playerHumanoid.Health <= 0) then
		return playerHumanoid
	end

	return nil
end

function CharacterUtils.getAlivePlayerRootPart(p)
	local playerHumanoid = CharacterUtils.getPlayerHumanoid(p)

	if playerHumanoid and not (playerHumanoid.Health <= 0) then
		return playerHumanoid.RootPart
	end

	return nil
end

function CharacterUtils.getPlayerRootPart(p)
	local playerHumanoid = CharacterUtils.getPlayerHumanoid(p)

	return if playerHumanoid then playerHumanoid.RootPart else nil
end

function CharacterUtils.unequipTools(p)
	local playerHumanoid = CharacterUtils.getPlayerHumanoid(p)

	if playerHumanoid then
		playerHumanoid:UnequipTools()
	end
end

function CharacterUtils.getPlayerFromCharacter(character)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)

	while not playerFromCharacter do
		if not character.Parent then
			return nil
		end

		character = character.Parent
		playerFromCharacter = Players:GetPlayerFromCharacter(character)
	end

	return playerFromCharacter
end

return CharacterUtils