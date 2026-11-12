local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolPriceTag = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolPriceTag)

local v = {}

local function add(label)
	if v[label] or not label:IsA("TextLabel") then
		return
	end

	v[label] = PoolPriceTag.Bind(label)
end

local function remove(p)
	local v2 = v[p]

	if v2 then
		v[p] = nil
		v2()
	end
end

CollectionService:GetInstanceAddedSignal(PoolPriceTag.Tag):Connect(add)
CollectionService:GetInstanceRemovedSignal(PoolPriceTag.Tag):Connect(remove)

for _, label in CollectionService:GetTagged(PoolPriceTag.Tag) do
	if v[label] or not label:IsA("TextLabel") then
		continue
	end

	v[label] = PoolPriceTag.Bind(label)
end