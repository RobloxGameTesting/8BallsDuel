local MobileControlImages = require(script.Parent:WaitForChild("MobileControlImages"))
return {
	mouselock = {
		name = "mouselock",
		image = MobileControlImages.MobileMouselock,
		imageDown = MobileControlImages.MobileMouselockDown
	},
	sprint = {
		name = "Sprint",
		image = MobileControlImages.MobileSprint,
		imageDown = MobileControlImages.MobileSprintDown,
		text = "Sprint"
	},
	shoot = {
		name = "Shoot",
		image = MobileControlImages.MobileShoot,
		imageDown = MobileControlImages.MobileShootDown
	},
	reload = {
		name = "Reload",
		image = MobileControlImages.MobileReload,
		imageDown = MobileControlImages.MobileReloadDown
	},
	dash = {
		name = "Dash",
		image = MobileControlImages.MobileDash,
		imageDown = MobileControlImages.MobileDashDown
	},
	crouch = {
		name = "Crouch",
		image = MobileControlImages.MobileDash,
		imageDown = MobileControlImages.MobileDashDown
	}
}