--- STEAMODDED HEADER
--- STEAMODDED SECONMDARY FILE

----------------------------------------------
------------MOD DEBUG-------------------------

Utils = {}

-- Credit to Henrik Ilgen (https://stackoverflow.com/a/6081639)
function Utils.serialize_table(val, name, skipnewlines, depth)
	skipnewlines = skipnewlines or false
	depth = depth or 0

	local tmp = string.rep(" ", depth)

	if name then tmp = tmp .. name .. " = " end

	if type(val) == "table" then
			tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

			for k, v in pairs(val) do
					tmp =  tmp .. Utils.serialize_table(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
			end

			tmp = tmp .. string.rep(" ", depth) .. "}"
	elseif type(val) == "number" then
			tmp = tmp .. tostring(val)
	elseif type(val) == "string" then
			tmp = tmp .. string.format("%q", val)
	elseif type(val) == "boolean" then
			tmp = tmp .. (val and "true" or "false")
	else
			tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
	end

	return tmp
end

-- Credit to Steamo (https://github.com/Steamopollys/Steamodded/blob/main/core/core.lua)
function Utils.wrapText(text, maxChars)
	local wrappedText = ""
	local currentLineLength = 0

	for word in text:gmatch("%S+") do
		if currentLineLength + #word <= maxChars then
			wrappedText = wrappedText .. word .. ' '
			currentLineLength = currentLineLength + #word + 1
		else
			wrappedText = wrappedText .. '\n' .. word .. ' '
			currentLineLength = #word + 1
		end
	end

	return wrappedText
end

return Utils

----------------------------------------------
------------MOD DEBUG END---------------------