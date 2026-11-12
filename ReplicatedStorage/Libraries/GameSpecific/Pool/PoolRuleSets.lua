local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

local PoolRuleSets = {}

local Rules = PoolConstants.Rules

PoolRuleSets.Casual = {
	Name = "Casual",
	Description = "Standard 8-ball with the break quality rule relaxed.",
	BreakRequiresRails = false,
	BreakMinimumRailContacts = Rules.BreakMinimumRailContacts,
	BreakScratchGivesBallInHand = Rules.BreakScratchGivesBallInHand,
	EightOnBreakRespots = Rules.EightOnBreakRespots,
	TableOpenAfterBreak = Rules.TableOpenAfterBreak,
	RequireContact = true,
	RequireRailAfterContact = true,
	RequireOwnGroupFirst = true,
	ScratchIsFoul = true,
	TimeoutIsFoul = true,
	FoulGivesBallInHand = true,
	AssignGroupOnFirstPotted = true,
	TurnSeconds = Rules.DefaultTurnTime
}

PoolRuleSets.Tournament = {
	Name = "Tournament",
	Description = "Full rules. A break must pot or drive four balls to a rail.",
	BreakRequiresRails = true,
	BreakMinimumRailContacts = Rules.BreakMinimumRailContacts,
	BreakScratchGivesBallInHand = Rules.BreakScratchGivesBallInHand,
	EightOnBreakRespots = Rules.EightOnBreakRespots,
	TableOpenAfterBreak = Rules.TableOpenAfterBreak,
	RequireContact = true,
	RequireRailAfterContact = true,
	RequireOwnGroupFirst = true,
	ScratchIsFoul = true,
	TimeoutIsFoul = true,
	FoulGivesBallInHand = true,
	AssignGroupOnFirstPotted = true,
	TurnSeconds = Rules.DefaultTurnTime
}

PoolRuleSets.Beginner = {
	Name = "Beginner",
	Description = "Fouls only for scratching or missing every ball.",
	BreakRequiresRails = false,
	BreakMinimumRailContacts = Rules.BreakMinimumRailContacts,
	BreakScratchGivesBallInHand = Rules.BreakScratchGivesBallInHand,
	EightOnBreakRespots = Rules.EightOnBreakRespots,
	TableOpenAfterBreak = Rules.TableOpenAfterBreak,
	RequireContact = true,
	RequireRailAfterContact = false,
	RequireOwnGroupFirst = false,
	ScratchIsFoul = true,
	TimeoutIsFoul = true,
	FoulGivesBallInHand = true,
	AssignGroupOnFirstPotted = true,
	TurnSeconds = Rules.DefaultTurnTime
}

PoolRuleSets.Default = PoolRuleSets.Casual

PoolRuleSets.Sets = {
	Casual = PoolRuleSets.Casual,
	Tournament = PoolRuleSets.Tournament,
	Beginner = PoolRuleSets.Beginner
}

function PoolRuleSets.Resolve(value)
	if typeof(value) == "table" then
		return value
	end

	if typeof(value) == "string" then
		return PoolRuleSets.Sets[value] or PoolRuleSets.Default
	end

	return PoolRuleSets.Default
end

function PoolRuleSets.ForVenue(_: string?)
	return PoolRuleSets.Default
end

return PoolRuleSets