--- STEAMODDED HEADER
--- STEAMODDED SECONDARY FILE

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

local usernameFilePath = "Mods/Multiplayer/Saved/username.txt"
function Utils.save_username(text)
	love.filesystem.write(usernameFilePath, text)
end

function Utils.get_username()
	local fileContent = love.filesystem.read(usernameFilePath)
	if not fileContent then return end
	Lobby.username = fileContent
end

function Utils.string_split(inputstr, sep)
	if sep == nil then
					sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
					table.insert(t, str)
	end
	return t
end

function Utils.copy_to_clipboard(text)
	local pathSeparator = package.config:sub(1,1)
	local isWindows = pathSeparator == '\\'

	if isWindows then
			local clipCommand = 'clip'
			local process = io.popen(clipCommand, 'w')
			process:write(text)
			process:close()
	else
			local safeText = text:gsub("'", "'\\''")
			os.execute('echo "' .. safeText .. '" | pbcopy')
	end
end

function Utils.get_from_clipboard()
	local pathSeparator = package.config:sub(1,1)
	local isWindows = pathSeparator == '\\'

	local clipboardContents = nil
	if isWindows then
			local process = io.popen('powershell Get-Clipboard', 'r')
			if process then
					clipboardContents = process:read('*a')
					process:close()
			end
	else
			local process = io.popen('pbpaste', 'r')
			if process then
					clipboardContents = process:read('*a')
					process:close()
			end
	end

	return clipboardContents
end


function Utils.overlay_message(message)
	G.SETTINGS.paused = true

	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.R,
					config = {
							padding = 0.5,
							align = "cm",
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								scale = 0.6,
								shadow = true,
								text = message,
								colour = G.C.UI.TEXT_LIGHT
							}
						}
					}
				}
			}
		})
	})
end

return Utils

----------------------------------------------
------------MOD DEBUG END---------------------