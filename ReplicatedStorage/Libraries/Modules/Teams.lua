local Teams = {
	list = {
		Neutral = {
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(33, 33, 33)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(33, 33, 33))
			}),
			colour = Color3.fromRGB(255, 255, 255),
			abbreviation = "Neutral"
		},
		Red = {
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(188, 0, 0))
			}),
			colour = Color3.fromRGB(255, 0, 0),
			abbreviation = "Red"
		},
		Blue = {
			gradient = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 115, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 84, 188))
			}),
			colour = Color3.fromRGB(0, 102, 255),
			abbreviation = "Blue"
		}
	},
	countryList = {}
}

for k, _ in Teams.list do
	if k ~= "Neutral" then
		table.insert(Teams.countryList, k)
	end
end

function Teams.GetGradient(p, p2)
	return p.list[p2].gradient
end

function Teams.GetColour(p, p2)
	return p.list[p2].colour
end

function Teams.GetAbbreviation(p, p2)
	return p.list[p2].abbreviation
end

function Teams.GetCountries(p)
	return p.countryList
end

return Teams