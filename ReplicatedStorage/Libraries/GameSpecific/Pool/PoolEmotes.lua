local PoolEmotes = {}
PoolEmotes.BubbleIcon = "rbxassetid://106654153207390"
PoolEmotes.Emotes = { Fire = "🔥", Smile = "😄", Angry = "😠", Sunglasses = "😎" }

PoolEmotes.PlayerChoices = { "Fire", "Smile", "Angry" }
PoolEmotes.MaxPerSecond = 8
PoolEmotes.BotStyles = {
	{ Id = "None", Weight = 77 },
	{ Id = "Spammer", Weight = 3 },
	{ Id = "Winner", Weight = 20 }
}

PoolEmotes.WinnerEmotes = { "Sunglasses", "Smile" }

PoolEmotes.WinnerPause = { Min = 0.7, Max = 1.1 }

PoolEmotes.SpammerEmotes = { "Fire", "Smile", "Angry", "Sunglasses" }
PoolEmotes.BurstEvery = { Min = 1.4, Max = 3.2 }
PoolEmotes.BurstSize = { Min = 2, Max = 6 }
PoolEmotes.BurstGap = { Min = 0.09, Max = 0.22 }

local random = Random.new()

function PoolEmotes.IsEmote(value): boolean
	return typeof(value) == "string" and PoolEmotes.Emotes[value] ~= nil
end

function PoolEmotes.IsPlayerChoice(value): boolean
	return typeof(value) == "string" and table.find(PoolEmotes.PlayerChoices, value) ~= nil
end

function PoolEmotes.Glyph(p: string)
	return PoolEmotes.Emotes[p] or ""
end

function PoolEmotes.Between(p, p2)
	return p.Min + (p2 or random):NextNumber() * (p.Max - p.Min)
end

function PoolEmotes.Pick(list, p)
	return list[(p or random):NextInteger(1, #list)]
end

function PoolEmotes.RollBotStyle(p)
	local total = 0

	for _, botStyle in PoolEmotes.BotStyles do
		total += botStyle.Weight
	end

	local v = (p or random):NextNumber() * total

	for _, botStyle in PoolEmotes.BotStyles do
		v -= botStyle.Weight

		if v <= 0 then
			return botStyle.Id
		end
	end

	return "None"
end

function PoolEmotes:StyleOf()
	if typeof(self) ~= "table" then
		return "None"
	end

	if self.EmoteStyle == nil then
		self.EmoteStyle = PoolEmotes.RollBotStyle(self.Random)
	end

	return self.EmoteStyle
end

function PoolEmotes.IsGameBallShot(p, p2): boolean
	if typeof(p2) ~= "table" or p2.Break or typeof(p2.Choice) ~= "table" then
		return false
	end

	local v = p and p.GameType == "NineBall" and 9 or 8

	return p2.Choice.Target == v
end

return PoolEmotes