local PseudoLocalize = {}

function PseudoLocalize.pseudoLocalize(value: string)
	local PSEUDO_CHARACTER_MAP = PseudoLocalize.PSEUDO_CHARACTER_MAP
	local v = ""
	local v2 = false

	for k, v3 in utf8.graphemes(value) do
		local v4 = string.sub(value, k, v3)

		if v4 == "{" or v4 == "[" or v4 == "<" then
			v ..= v4
			v2 = true
		elseif v4 == "}" or v4 == "]" or v4 == ">" then
			v ..= v4
			v2 = false
		elseif v2 or not PSEUDO_CHARACTER_MAP[v4] then
			v ..= v4
		else
			v ..= PSEUDO_CHARACTER_MAP[v4]
		end
	end

	return v
end

function PseudoLocalize.getDefaultPseudoLocaleId(): string
	return "qlp-pls"
end

function PseudoLocalize.addToLocalizationTable(object, value: string?, value2: string?)
	local entries = object:GetEntries()
	local v = value or "qlp-pls"
	local v2 = value2 or "en"

	for _, entry in entries do
		if entry.Values[v] then
			continue
		end

		local value3 = entry.Values[v2]

		if type(value3) == "string" then
			entry.Values[v] = PseudoLocalize.pseudoLocalize(value3)
		else
			warn(string.format(
				"[PseudoLocalize.addToLocalizationTable] - No entry in key %q for locale %q",
				entry.Key,
				v2
			))
		end
	end

	object:SetEntries(entries)
end

PseudoLocalize.PSEUDO_CHARACTER_MAP = {
	a = "á",
	b = "β",
	c = "ç",
	d = "δ",
	e = "è",
	f = "ƒ",
	g = "ϱ",
	h = "λ",
	i = "ï",
	j = "J",
	k = "ƙ",
	l = "ℓ",
	m = "₥",
	n = "ñ",
	o = "ô",
	p = "ƥ",
	q = "9",
	r = "ř",
	s = "ƨ",
	t = "ƭ",
	u = "ú",
	v = "Ʋ",
	w = "ω",
	x = "ж",
	y = "¥",
	z = "ƺ",
	A = "Â",
	B = "ß",
	C = "Ç",
	D = "Ð",
	E = "É",
	F = "F",
	G = "G",
	H = "H",
	I = "Ì",
	J = "J",
	K = "K",
	L = "£",
	M = "M",
	N = "N",
	O = "Ó",
	P = "Þ",
	Q = "Q",
	R = "R",
	S = "§",
	T = "T",
	U = "Û",
	V = "V",
	W = "W",
	X = "X",
	Y = "Ý",
	Z = "Z"
}

return PseudoLocalize