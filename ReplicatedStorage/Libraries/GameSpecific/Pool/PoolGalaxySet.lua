local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolGalaxySet = {}
PoolGalaxySet.StoreName = "PoolGalaxyStock_V1"
PoolGalaxySet.SoldAttributePrefix = "PoolGalaxySold_"
PoolGalaxySet.Category = "cueSticks"
PoolGalaxySet.Tiers = {
	{
		Id = "SpookyT2",
		Item = "Spooky_T2",
		ProductId = 3724182280,
		LegacyProductIds = { 3715202881 },
		Stock = 7500,
		Tag = nil,
		Accent = Color3.fromRGB(120, 220, 80)
	},
	{
		Id = "SpookyT3",
		Item = "Spooky_T3",
		ProductId = 3724182416,
		LegacyProductIds = { 3715202896 },
		Stock = 5000,
		Tag = "Best Value!",
		Accent = Color3.fromRGB(255, 140, 40)
	},
	{
		Id = "SpookyT4",
		Item = "Spooky_T4",
		ProductId = 3724182458,
		LegacyProductIds = { 3715202948 },
		Stock = 2500,
		Tag = "Best Cue!",
		Accent = Color3.fromRGB(170, 90, 255)
	},
	{
		Id = "SpookyT5",
		Item = "Spooky_T5",
		ProductId = 3724182527,
		LegacyProductIds = { 3715202961 },
		Stock = 500,
		Tag = "Ultimate!",
		Accent = Color3.fromRGB(255, 205, 80)
	}
}

PoolGalaxySet.RetiredTiers = {
	{
		Id = "AstraT2",
		Item = "Astra_T2",
		ProductId = 3715202881,
		Stock = 7500,
		Tag = nil,
		Accent = Color3.fromRGB(167, 130, 255)
	},
	{
		Id = "AstraT3",
		Item = "Astra_T3",
		ProductId = 3715202896,
		Stock = 5000,
		Tag = "Best Value!",
		Accent = Color3.fromRGB(226, 120, 245)
	},
	{
		Id = "AstraT4",
		Item = "Astra_T4",
		ProductId = 3715202948,
		Stock = 2500,
		Tag = "Best Cue!",
		Accent = Color3.fromRGB(255, 122, 196)
	},
	{
		Id = "AstraT5",
		Item = "Astra_T5",
		ProductId = 3715202961,
		Stock = 500,
		Tag = "Ultimate!",
		Accent = Color3.fromRGB(255, 196, 90)
	},
	{
		Id = "Tier1",
		Item = "GalaxyCue1",
		ProductId = 3713353601,
		Stock = 1000,
		Tag = nil,
		Accent = Color3.fromRGB(122, 162, 255)
	},
	{
		Id = "Tier2",
		Item = "GalaxyCue2",
		ProductId = 3713353615,
		Stock = 500,
		Tag = "Best Value!",
		Accent = Color3.fromRGB(167, 130, 255)
	},
	{
		Id = "Tier3",
		Item = "GalaxyCue3",
		ProductId = 3713353622,
		Stock = 100,
		Tag = "Rarest Finish!",
		Accent = Color3.fromRGB(226, 120, 245)
	},
	{
		Id = "Tier4",
		Item = "GalaxyCue4",
		ProductId = 3713353632,
		Stock = 40,
		Tag = "Best Cue!",
		Accent = Color3.fromRGB(255, 122, 196)
	},
	{
		Id = "Tier5",
		Item = "GalaxyCue5",
		ProductId = 3714521109,
		Stock = 20,
		Tag = "Ultimate!",
		Accent = Color3.fromRGB(255, 196, 90)
	}
}

local function eachTier() -- 1 equivalent call inferred from this helper
	local clone = table.clone(PoolGalaxySet.Tiers)

	for _, retiredTier in PoolGalaxySet.RetiredTiers do
		table.insert(clone, retiredTier)
	end

	return clone
end

PoolGalaxySet.GradientTop = Color3.fromRGB(255, 140, 30)
PoolGalaxySet.GradientBottom = Color3.fromRGB(140, 60, 230)

function PoolGalaxySet.GetTier(p: string)
	local clone = eachTier() -- inferred equivalent call

	for _, v in clone do
		if v.Id == p then
			return v
		end
	end

	return nil
end

function PoolGalaxySet.GetTierByProduct(p: number)
	for _, tier in PoolGalaxySet.Tiers do
		if tier.ProductId == p or tier.LegacyProductIds ~= nil and table.find(tier.LegacyProductIds, p) ~= nil then
			return tier
		end
	end

	for _, retiredTier in PoolGalaxySet.RetiredTiers do
		if retiredTier.ProductId == p then
			return retiredTier
		end
	end

	return nil
end

function PoolGalaxySet.SoldAttribute(p: string)
	return PoolGalaxySet.SoldAttributePrefix .. p
end

function PoolGalaxySet.GetSold(p: string)
	local attribute = ReplicatedStorage:GetAttribute(PoolGalaxySet.SoldAttribute(p))

	return if typeof(attribute) == "number" then attribute else nil
end

function PoolGalaxySet.GetRemaining(p: string)
	local tier = PoolGalaxySet.GetTier(p)
	local sold = PoolGalaxySet.GetSold(p)

	if tier and sold then
		return (math.clamp(tier.Stock - sold, 0, tier.Stock))
	end

	return nil
end

function PoolGalaxySet.IsSoldOut(p: string): boolean
	return PoolGalaxySet.GetRemaining(p) == 0
end

function PoolGalaxySet.HasStock(): boolean
	for _, tier in PoolGalaxySet.Tiers do
		local remaining = PoolGalaxySet.GetRemaining(tier.Id)

		if remaining == nil or remaining > 0 then
			return true
		end
	end

	return false
end

return PoolGalaxySet