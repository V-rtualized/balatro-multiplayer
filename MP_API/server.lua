-- Socket.lua with enhanced debugging
return [[
local CONFIG_URL, CONFIG_PORT = ...

require("love.filesystem")
local socket = require("socket")

Networking = {}
local isSocketClosed = true
local networkToUiChannel = love.thread.getChannel("networkToUi")
local uiToNetworkChannel = love.thread.getChannel("uiToNetwork")

function Networking.connect()
	Networking.Client = socket.tcp()
	Networking.Client:settimeout(10)
	Networking.Client:setoption("tcp-nodelay", true)

	local connectionResult, errorMessage = Networking.Client:connect(CONFIG_URL, CONFIG_PORT)

	if connectionResult ~= 1 then
		networkToUiChannel:push("action:error,message:Failed to connect to central server")
	else
		isSocketClosed = false
	end

	Networking.Client:settimeout(0)
end

-- Check for messages from the main thread
local mainThreadMessageQueue = function()
	local requestsPerCycle = 25
	while true do
		for _ = 1, requestsPerCycle do
			local msg = uiToNetworkChannel:pop()
			if msg then
				if msg:find("^action") ~= nil then
					Networking.Client:send(msg .. "\n")
				elseif msg == "connect" then
					Networking.connect()
				end
			else
				coroutine.yield()
			end
		end
		coroutine.yield()
	end
end
local mainThreadCoroutine = coroutine.create(mainThreadMessageQueue)

local timer = function(time)
	local init = os.time()
	local diff = os.difftime(os.time(), init)
	while diff < time do
		coroutine.yield(diff)
		diff = os.difftime(os.time(), init)
	end
end
local timerCoroutine = coroutine.create(timer)

local keepAliveInitialTimeout = 7
local keepAliveRetryTimeout = 3
local keepAliveRetryCount = 3

local isRetry = false
local retryCount = 0

local networkPacketQueue = function()
	local packetsPerCycle = 25
	while true do
		if Networking.Client then
			for _ = 1, packetsPerCycle do
				local data, error, partial = Networking.Client:receive()
				if data then
					isRetry = false
					retryCount = 0
					timerCoroutine = coroutine.create(timer)

					networkToUiChannel:push(data)
				elseif error == "closed" and not isSocketClosed then
					isSocketClosed = true
					retryCount = 0
					isRetry = false
					timerCoroutine = coroutine.create(timer)
					networkToUiChannel:push("action:disconnected")
				elseif error ~= "timeout" then
					coroutine.yield()
				else
					coroutine.yield()
				end
			end
			coroutine.yield()
		end
		coroutine.yield()
	end
end
local networkCoroutine = coroutine.create(networkPacketQueue)

while true do
	coroutine.resume(mainThreadCoroutine)
	coroutine.resume(networkCoroutine)

	if not isSocketClosed and coroutine.status(timerCoroutine) ~= "dead" then
		coroutine.resume(timerCoroutine, keepAliveInitialTimeout)
	elseif not isSocketClosed then
		isRetry = true

		if retryCount > keepAliveRetryCount then
			Networking.Client:close()
			isSocketClosed = true
			retryCount = 0
			isRetry = false
			timerCoroutine = coroutine.create(timer)
			networkToUiChannel:push("action:disconnected")
		end

		if isRetry then
			retryCount = retryCount + 1
			uiToNetworkChannel:push("action:keep_alive")
			timerCoroutine = coroutine.create(timer)
			coroutine.resume(timerCoroutine, keepAliveRetryTimeout)
		end
	end

	socket.sleep(0.2)
end
]]
