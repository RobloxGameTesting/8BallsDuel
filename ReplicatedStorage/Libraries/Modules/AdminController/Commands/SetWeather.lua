local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Libraries.Modules.AdminController.AdminTypes)
game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = RunService:IsServer()
local v = {
	Night = "{\"SunRaysEffect\":{\"Intensity\":0.009999999776482582,\"Spread\":0.10000000149011612},\"BloomEffect\":{\"Threshold\":2,\"Intensity\":1,\"Size\":24},\"Sky\":{\"StarCount\":3000,\"SkyboxUp\":\"rbxasset://sky/null_plainsky512_up.jpg\",\"MoonTextureId\":\"rbxasset://sky/moon.jpg\",\"SkyboxBk\":\"rbxasset://sky/null_plainsky512_bk.jpg\",\"CelestialBodiesShown\":true,\"SkyboxDn\":\"rbxasset://sky/null_plainsky512_dn.jpg\",\"SkyboxLf\":\"rbxasset://sky/null_plainsky512_lf.jpg\",\"SunTextureId\":\"rbxasset://sky/sun.jpg\",\"SunAngularSize\":21,\"SkyboxFt\":\"rbxasset://sky/null_plainsky512_ft.jpg\",\"SkyboxRt\":\"rbxasset://sky/null_plainsky512_rt.jpg\",\"MoonAngularSize\":11},\"Lighting\":{\"ExposureCompensation\":0,\"ColorShift_Bottom\":[\"C\",0,0,0],\"FogColor\":[\"C\",0.7411764860153198,0.7411764860153198,0.7411764860153198],\"FogEnd\":10000,\"TimeOfDay\":\"00:00:00\",\"ShadowSoftness\":0.20000000298023225,\"EnvironmentDiffuseScale\":1,\"EnvironmentSpecularScale\":1,\"GlobalShadows\":true,\"FogStart\":0,\"Ambient\":[\"C\",0.5686274766921997,0.5686274766921997,0.5686274766921997],\"OutdoorAmbient\":[\"C\",0.27450981736183169,0.27450981736183169,0.27450981736183169],\"GeographicLatitude\":0,\"Brightness\":3,\"ColorShift_Top\":[\"C\",0,0,0],\"ClockTime\":0}}",
	Sunny = "{\"SunRaysEffect\":{\"Intensity\":0.009999999776482582,\"Spread\":0.10000000149011612},\"BloomEffect\":{\"Threshold\":2,\"Intensity\":1,\"Size\":24},\"Sky\":{\"StarCount\":3000,\"SkyboxUp\":\"rbxasset://sky/null_plainsky512_up.jpg\",\"MoonTextureId\":\"rbxasset://sky/moon.jpg\",\"SkyboxBk\":\"rbxasset://sky/null_plainsky512_bk.jpg\",\"CelestialBodiesShown\":true,\"SkyboxDn\":\"rbxasset://sky/null_plainsky512_dn.jpg\",\"SkyboxLf\":\"rbxasset://sky/null_plainsky512_lf.jpg\",\"SunTextureId\":\"rbxasset://sky/sun.jpg\",\"SunAngularSize\":21,\"SkyboxFt\":\"rbxasset://sky/null_plainsky512_ft.jpg\",\"SkyboxRt\":\"rbxasset://sky/null_plainsky512_rt.jpg\",\"MoonAngularSize\":11},\"Lighting\":{\"ExposureCompensation\":0,\"ColorShift_Bottom\":[\"C\",0,0,0],\"FogColor\":[\"C\",0.7411764860153198,0.7411764860153198,0.7411764860153198],\"FogEnd\":10000,\"TimeOfDay\":\"12:00:00\",\"ShadowSoftness\":0.20000000298023225,\"EnvironmentDiffuseScale\":1,\"EnvironmentSpecularScale\":1,\"GlobalShadows\":true,\"FogStart\":0,\"Ambient\":[\"C\",0.5686274766921997,0.5686274766921997,0.5686274766921997],\"OutdoorAmbient\":[\"C\",0.27450981736183169,0.27450981736183169,0.27450981736183169],\"GeographicLatitude\":0,\"Brightness\":3,\"ColorShift_Top\":[\"C\",0,0,0],\"ClockTime\":12}}",
	Winter = "{\"SunRaysEffect\":{\"Intensity\":0.009999999776482582,\"Spread\":0.10000000149011612},\"Lighting\":{\"ExposureCompensation\":0,\"ColorShift_Bottom\":[\"C\",0,0,0],\"FogColor\":[\"C\",0.7529412508010864,0.7529412508010864,0.7529412508010864],\"FogEnd\":100000,\"TimeOfDay\":\"12:00:00\",\"ShadowSoftness\":0.20000000298023225,\"EnvironmentDiffuseScale\":1,\"EnvironmentSpecularScale\":1,\"GlobalShadows\":true,\"FogStart\":0,\"Ambient\":[\"C\",0.8901961445808411,0.8901961445808411,0.8901961445808411],\"OutdoorAmbient\":[\"C\",0.27450981736183169,0.27450981736183169,0.27450981736183169],\"GeographicLatitude\":0,\"Brightness\":3,\"ColorShift_Top\":[\"C\",0,0,0],\"ClockTime\":12},\"Sky\":{\"StarCount\":3000,\"SkyboxUp\":\"rbxassetid://2029213271\",\"MoonTextureId\":\"rbxasset://sky/moon.jpg\",\"SkyboxBk\":\"rbxassetid://2029210131\",\"CelestialBodiesShown\":true,\"SkyboxDn\":\"rbxassetid://2029210773\",\"SkyboxLf\":\"rbxassetid://2029212393\",\"SunTextureId\":\"rbxasset://sky/sun.jpg\",\"SunAngularSize\":21,\"SkyboxFt\":\"rbxassetid://2029211409\",\"SkyboxRt\":\"rbxassetid://2029212849\",\"MoonAngularSize\":11},\"BloomEffect\":{\"Threshold\":2,\"Intensity\":1,\"Size\":24},\"Atmosphere\":{\"Density\":0.30000001192092898,\"Offset\":0.25,\"Color\":[\"C\",0.7803921699523926,0.7803921699523926,0.7803921699523926],\"Glare\":0,\"Haze\":0,\"Decay\":[\"C\",0.4156862795352936,0.43921568989753725,0.4901960790157318]}}",
	Gloomy = "{\"SunRaysEffect\":{\"Intensity\":0.009999999776482582,\"Spread\":0.10000000149011612},\"Lighting\":{\"ExposureCompensation\":0,\"ColorShift_Bottom\":[\"C\",0,0,0],\"FogColor\":[\"C\",0.7529412508010864,0.7529412508010864,0.7529412508010864],\"FogEnd\":100000,\"TimeOfDay\":\"09:00:00\",\"ShadowSoftness\":0.20000000298023225,\"EnvironmentDiffuseScale\":1,\"EnvironmentSpecularScale\":1,\"GlobalShadows\":true,\"FogStart\":0,\"Ambient\":[\"C\",0.5686274766921997,0.5686274766921997,0.5686274766921997],\"OutdoorAmbient\":[\"C\",0.27450981736183169,0.27450981736183169,0.27450981736183169],\"GeographicLatitude\":0,\"Brightness\":3,\"ColorShift_Top\":[\"C\",0,0,0],\"ClockTime\":9},\"Sky\":{\"StarCount\":3000,\"SkyboxUp\":\"rbxassetid://13140378032\",\"MoonTextureId\":\"rbxassetid://1345054856\",\"SkyboxBk\":\"rbxassetid://13140379284\",\"CelestialBodiesShown\":true,\"SkyboxDn\":\"rbxassetid://13140377222\",\"SkyboxLf\":\"rbxassetid://13140387037\",\"SunTextureId\":\"rbxassetid://1345009717\",\"SunAngularSize\":11,\"SkyboxFt\":\"rbxassetid://13140381786\",\"SkyboxRt\":\"rbxassetid://13140372646\",\"MoonAngularSize\":11},\"BloomEffect\":{\"Threshold\":2,\"Intensity\":1,\"Size\":24},\"Atmosphere\":{\"Density\":0.30000001192092898,\"Offset\":0.25,\"Color\":[\"C\",0.7803921699523926,0.7803921699523926,0.7803921699523926],\"Glare\":0,\"Haze\":0,\"Decay\":[\"C\",0.4156862795352936,0.43921568989753725,0.4901960790157318]}}",
	Scary = "{\"SunRaysEffect\":{\"Intensity\":0.009999999776482582,\"Spread\":0.10000000149011612},\"Lighting\":{\"ExposureCompensation\":0,\"ColorShift_Bottom\":[\"C\",0,0,0],\"FogColor\":[\"C\",0.7529412508010864,0.7529412508010864,0.7529412508010864],\"FogEnd\":100000,\"TimeOfDay\":\"09:00:00\",\"ShadowSoftness\":0.20000000298023225,\"EnvironmentDiffuseScale\":1,\"EnvironmentSpecularScale\":1,\"GlobalShadows\":true,\"FogStart\":0,\"Ambient\":[\"C\",0.5686274766921997,0.5686274766921997,0.5686274766921997],\"OutdoorAmbient\":[\"C\",0.27450981736183169,0.27450981736183169,0.27450981736183169],\"GeographicLatitude\":0,\"Brightness\":3,\"ColorShift_Top\":[\"C\",0,0,0],\"ClockTime\":9},\"Sky\":{\"StarCount\":3000,\"SkyboxUp\":\"http://www.roblox.com/asset/?id=13720335408\",\"MoonTextureId\":\"\",\"SkyboxBk\":\"http://www.roblox.com/asset/?id=13720421689\",\"CelestialBodiesShown\":true,\"SkyboxDn\":\"http://www.roblox.com/asset/?id=13720333936\",\"SkyboxLf\":\"http://www.roblox.com/asset/?id=13720356894\",\"SunTextureId\":\"\",\"SunAngularSize\":21,\"SkyboxFt\":\"http://www.roblox.com/asset/?id=13720423714\",\"SkyboxRt\":\"http://www.roblox.com/asset/?id=13720354336\",\"MoonAngularSize\":11},\"BloomEffect\":{\"Threshold\":2,\"Intensity\":1,\"Size\":24},\"Atmosphere\":{\"Density\":0.30000001192092898,\"Offset\":0.25,\"Color\":[\"C\",0.7803921699523926,0.7803921699523926,0.7803921699523926],\"Glare\":0,\"Haze\":0,\"Decay\":[\"C\",0.4156862795352936,0.43921568989753725,0.4901960790157318]}}",
	Foggy = "{\"SunRaysEffect\":{\"Intensity\":0.009999999776482582,\"Spread\":0.10000000149011612},\"BloomEffect\":{\"Threshold\":2,\"Intensity\":1,\"Size\":24},\"Lighting\":{\"ExposureCompensation\":0,\"ColorShift_Bottom\":[\"C\",0,0,0],\"FogColor\":[\"C\",0.7411764860153198,0.7411764860153198,0.7411764860153198],\"FogEnd\":300,\"TimeOfDay\":\"09:00:00\",\"ShadowSoftness\":0.20000000298023225,\"EnvironmentDiffuseScale\":1,\"EnvironmentSpecularScale\":1,\"GlobalShadows\":true,\"FogStart\":0,\"Ambient\":[\"C\",0.5686274766921997,0.5686274766921997,0.5686274766921997],\"OutdoorAmbient\":[\"C\",0.27450981736183169,0.27450981736183169,0.27450981736183169],\"GeographicLatitude\":0,\"Brightness\":3,\"ColorShift_Top\":[\"C\",0,0,0],\"ClockTime\":9}}"
}

local SetWeather = {
	command = "Set Weather",
	commandType = "Global",
	searchTerms = { "Weather" },
	icon = "rbxassetid://139749037245348",
	layoutOrder = 120,
	maxActivationDistance = 1e999,
	cooldown = 10,
	cost = 0,
	options = {
		{ optionType = "List", extra = {} }
	},
	robuxIds = {},
	roles = { "OwnerAdmin" },
	userIds = {},
	onActivate = function(_, list)
		if not isServer then
			return ""
		end

		local item = list[1]
		local v2 = v[item]

		workspace.Regions.Map:SetAttribute("Light", v2)

		return `Admin set the lighting to {item}`
	end
}

for k, _ in v do
	table.insert(SetWeather.options[1].extra, k)
end

return SetWeather