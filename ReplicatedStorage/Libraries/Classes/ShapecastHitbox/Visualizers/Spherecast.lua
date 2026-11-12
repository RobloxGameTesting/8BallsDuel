--!native
require(script.Parent.Parent.Types)
local Settings = require(script.Parent.Parent.Settings)

local Spherecast = {}
Spherecast.__index = Spherecast
Spherecast.__type = `ShapecastHitbox_{script.Name}`
Spherecast._AdornmentInUse = {}
Spherecast._AdornmentInReserve = {}

function Spherecast:_CreateAdornment()
	local shapecastHitboxDebugger = Instance.new("SphereHandleAdornment")
	shapecastHitboxDebugger.Name = "_ShapecastHitboxDebugger"
	shapecastHitboxDebugger.Color3 = Settings.Debug_Instance_Color
	shapecastHitboxDebugger.Transparency = Settings.Debug_Instance_Transparency
	shapecastHitboxDebugger.Radius = 1
	shapecastHitboxDebugger.CFrame = Settings.Debug_Instance_Derender_Location

	shapecastHitboxDebugger.Adornee = workspace.Terrain
	shapecastHitboxDebugger.Parent = workspace.Terrain

	return { Adornment = shapecastHitboxDebugger, LastUse = 0 }
end

function Spherecast.GetAdornment(_)
	if #Spherecast._AdornmentInReserve <= 0 then
		local adornment = Spherecast:_CreateAdornment()
		table.insert(Spherecast._AdornmentInReserve, adornment)
	end

	local adornment = table.remove(Spherecast._AdornmentInReserve, 1)

	if adornment then
		adornment.Adornment.Visible = true
		adornment.LastUse = os.clock()
		table.insert(Spherecast._AdornmentInUse, adornment)
	end

	return adornment
end

function Spherecast.ToRender(_, p, p2, cframe: CFrame, _: number, raycastResult: RaycastResult)
	p.Adornment.Radius = p2.CastData.Radius
	p.Adornment.CFrame = cframe
	p.Adornment.Color3 = raycastResult and Settings.Debug_Instance_Hit_Color or Settings.Debug_Instance_Color
	p.Adornment.ZIndex = raycastResult and 999 or -1
end

function Spherecast.ReturnAdornment(_, p)
	p.Adornment.Radius = 0
	p.Adornment.Visible = false
	p.Adornment.CFrame = Settings.Debug_Instance_Derender_Location
	table.insert(Spherecast._AdornmentInReserve, p)
end

function Spherecast.Clear(_)
	for i = #Spherecast._AdornmentInReserve, 1, -1 do
		if Spherecast._AdornmentInReserve[i].Adornment then
			Spherecast._AdornmentInReserve[i].Adornment:Destroy()
		end

		table.remove(Spherecast._AdornmentInReserve, i)
	end
end

return Spherecast