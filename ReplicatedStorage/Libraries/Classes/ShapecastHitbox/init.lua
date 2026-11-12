--!native
require(script.Types)

return {
	new = require(script.Hitbox),
	Settings = require(script.Settings),
	CastTypes = { Raycast = "Raycast", Blockcast = "Blockcast", Spherecast = "Spherecast" }
}