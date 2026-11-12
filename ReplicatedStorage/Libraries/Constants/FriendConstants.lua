local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Helpers.NumberHelper)

return {
	INVITE_BOOST = 1,
	INVITE_BOOST_LIMIT = 125,
	INVITE_REWARD = { writeLib = "Currency1", value = 100 },
	HEADER = "FREE ______ REWARD",
	DESCRIPTION = "Invite a friend and get a ________ when they join after you invite them!",
	PROMPT_MESSAGE = function(p)
		return "Receive an OP Flaming Trail when you invite " .. p.DisplayName .. " and they join! Would you like to invite them?"
	end,
	INVITE_MESSAGE_ID = "897d0a23-cc3f-1a4d-9d32-659224c9e4d6"
}