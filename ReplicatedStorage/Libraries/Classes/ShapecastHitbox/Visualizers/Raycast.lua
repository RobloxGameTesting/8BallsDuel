--!native
require(script.Parent.Parent.Types)
local Settings = require(script.Parent.Parent.Settings)

local Raycast = {}
Raycast.__index = Raycast
Raycast.__type = `ShapecastHitbox_{script.Name}`
Raycast._AdornmentInUse = {}
Raycast._AdornmentInReserve = {}

function Raycast:_CreateAdornment()
	local shapecastHitboxDebugger = Instance.new("LineHandleAdornment")
	shapecastHitboxDebugger.Name = "_ShapecastHitboxDebugger"
	shapecastHitboxDebugger.Color3 = Settings.Debug_Instance_Color
	shapecastHitboxDebugger.Thickness = Settings.Debug_Instance_Raycast_Width
	shapecastHitboxDebugger.Transparency = Settings.Debug_Instance_Transparency

	shapecastHitboxDebugger.Length = 0
	shapecastHitboxDebugger.CFrame = Settings.Debug_Instance_Derender_Location

	shapecastHitboxDebugger.Adornee = workspace.Terrain
	shapecastHitboxDebugger.Parent = workspace.Terrain

	return { Adornment = shapecastHitboxDebugger, LastUse = 0 }
end

function Raycast.GetAdornment(_)
	if #Raycast._AdornmentInReserve <= 0 then
		local adornment = Raycast:_CreateAdornment()
		table.insert(Raycast._AdornmentInReserve, adornment)
	end

	local adornment = table.remove(Raycast._AdornmentInReserve, 1)

	if adornment then
		adornment.Adornment.Visible = true
		adornment.LastUse = os.clock()
		table.insert(Raycast._AdornmentInUse, adornment)
	end

	return adornment
end

function Raycast.ToRender(_, p, _, cframe: CFrame, length: number, raycastResult: RaycastResult)
	p.Adornment.Length = length
	p.Adornment.CFrame = cframe
	p.Adornment.Color3 = raycastResult and Settings.Debug_Instance_Hit_Color or Settings.Debug_Instance_Color
	p.Adornment.ZIndex = raycastResult and 999 or -1
end

function Raycast.ReturnAdornment(_, p)
	p.Adornment.Length = 0
	p.Adornment.Visible = false
	p.Adornment.CFrame = Settings.Debug_Instance_Derender_Location
	table.insert(Raycast._AdornmentInReserve, p)
end

function Raycast.Clear(_)
	for i = #Raycast._AdornmentInReserve, 1, -1 do
		if Raycast._AdornmentInReserve[i].Adornment then
			Raycast._AdornmentInReserve[i].Adornment:Destroy()
		end

		table.remove(Raycast._AdornmentInReserve, i)
	end
end

return Raycast