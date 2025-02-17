MP.mod_hash = "0000"
MP.mod_list = ""

function hash(str)
	if not str then
		return "0000"
	end

	local bit = require("bit")
	h = 5381

	for c in str:gmatch(".") do
		h = (bit.lshift(h, 5) + h) + string.byte(c)
	end
	return string.sub(tostring(h), -4)
end

function MP.generate_hash()
	local mods_to_sort = {}
	for key, mod in pairs(SMODS.Mods) do
		if not mod.disabled and key ~= "Lovely" and key ~= "Balatro" and key ~= "Steamodded" then
			table.insert(mods_to_sort, mod)
		end
	end

	table.sort(mods_to_sort, function(a, b)
		return a.id < b.id
	end)

	local mod_str = ""
	for _, mod in ipairs(mods_to_sort) do
		mod_str = mod_str .. mod.id .. "-" .. mod.version .. ";"
	end

	MP.mod_list = mod_str
	MP.mod_hash = hash(mod_str)
	MP.send_info_message("Generated Mod Hash: " .. MP.mod_hash)
end

G.E_MANAGER:add_event(Event({
	trigger = "immediate",
	blockable = false,
	blocking = false,
	func = function()
		if SMODS.booted then
			MP.generate_hash()
			return true
		end
		return false
	end,
}))
