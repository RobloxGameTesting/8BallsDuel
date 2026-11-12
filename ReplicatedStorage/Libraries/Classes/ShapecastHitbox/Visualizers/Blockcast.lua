--!native
require(script.Parent.Parent.Types)
local Settings = require(script.Parent.Parent.Settings)

local Blockcast = {}
Blockcast.__index = Blockcast
Blockcast.__type = `ShapecastHitbox_{script.Name}`
Blockcast._AdornmentInUse = {}
Blockcast._AdornmentInReserve = {}

function Blockcast:_CreateAdornment()
	local shapecastHitboxDebugger = Instance.new("BoxHandleAdornment")
	shapecastHitboxDebugger.Name = "_ShapecastHitboxDebugger"
	shapecastHitboxDebugger.Color3 = Settings.Debug_Instance_Color
	shapecastHitboxDebugger.Transparency = Settings.Debug_Instance_Transparency
	shapecastHitboxDebugger.Size = Vector3.new(0, 0, 0)
	shapecastHitboxDebugger.CFrame = Settings.Debug_Instance_Derender_Location

	shapecastHitboxDebugger.Adornee = workspace.Terrain
	shapecastHitboxDebugger.Parent = workspace.Terrain

	return { Adornment = shapecastHitboxDebugger, LastUse = 0 }
end

function Blockcast.GetAdornment(_)
	if #Blockcast._AdornmentInReserve <= 0 then
		local adornment = Blockcast:_CreateAdornment()
		table.insert(Blockcast._AdornmentInReserve, adornment)
	end

	local adornment = table.remove(Blockcast._AdornmentInReserve, 1)

	if adornment then
		adornment.Adornment.Visible = true
		adornment.LastUse = os.clock()
		table.insert(Blockcast._AdornmentInUse, adornment)
	end

	return adornment
end

function Blockcast.ToRender(_, p, p2, _: CFrame, _: number, raycastResult: RaycastResult)
	p.Adornment.Size = p2.CastData.Size
	p.Adornment.CFrame = (p2.CastData._LastCFrameBlockCast or p2.Instance.WorldCFrame) * p2.CastData.CFrame
	p.Adornment.Color3 = raycastResult and Settings.Debug_Instance_Hit_Color or Settings.Debug_Instance_Color
	p.Adornment.ZIndex = raycastResult and 999 or -1
end

function Blockcast.ReturnAdornment(_, p)
	p.Adornment.Size = Vector3.new(0, 0, 0)
	p.Adornment.Visible = false
	p.Adornment.CFrame = Settings.Debug_Instance_Derender_Location
	table.insert(Blockcast._AdornmentInReserve, p)
end

function Blockcast.Clear(_)
	for i = #Blockcast._AdornmentInReserve, 1, -1 do
		if Blockcast._AdornmentInReserve[i].Adornment then
			Blockcast._AdornmentInReserve[i].Adornment:Destroy()
		end

		table.remove(Blockcast._AdornmentInReserve, i)
	end
end

return Blockcast