local Players = game:GetService("Players")
local Cleaner = require(script.Parent.Cleaner)

local PlayerUtil = {}
PlayerUtil.__index = PlayerUtil

function PlayerUtil.ObservePlayers(callback)
	local newPlayer = function(player: Player)
		local cleaner = Cleaner.new()

		-- thread to end the cleaner
		task.spawn(function()
			repeat
				task.wait()
			until player.Parent ~= Players
			cleaner:Destroy()
		end)

		task.spawn(callback, player, cleaner)
	end

	for _, player in Players:GetPlayers() do
		newPlayer(player)
	end
	return Players.PlayerAdded:Connect(newPlayer)
end

function PlayerUtil.ObserveCharactersForPlayer(player: Player, callback)
	local newCharacter = function(character: Model)
		local cleaner = Cleaner.new()
		task.spawn(callback, character, cleaner)

		-- thread to end the cleaner
		task.spawn(function()
			repeat
				task.wait()
			until player.Parent ~= Players or character ~= player.Character
			cleaner:Destroy()
		end)
	end

	if player.Character then
		newCharacter(player.Character)
	end

	player.CharacterAdded:Connect(newCharacter)
end

function PlayerUtil.ObserveCharacters(callback)
	PlayerUtil.ObservePlayers(function(player)
		PlayerUtil.ObserveCharactersForPlayer(player, function(...)
			callback(player, ...)
		end)
	end)
end

return PlayerUtil
