local loader = require(script.Parent.loader)
return loader.load(script)("Table").readonly({
	ROUND_TO_CLOSEST = "roundToClosest",
	TRUNCATE = "truncate",
	NONE = "None"
})