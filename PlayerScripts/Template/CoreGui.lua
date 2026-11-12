local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInterfaceHelper = require(ReplicatedStorage.Libraries.Helpers.UserInterfaceHelper)

UserInterfaceHelper:CoreGuiEnable({ [Enum.CoreGuiType.All] = false })