-- We set the url and port for the server
MPAPI.SERVER_CONFIG.url = "localhost"
MPAPI.SERVER_CONFIG.port = 6858
-- And then initialize the connection to it
MPAPI.initialize()

SWAP = {
	ACTIONS = {},
	FUNCS = {},
}

-- We want this function to run when the other player buys a joker
SWAP.FUNCS.ON_RECEIVE_SWAP_JOKER = function(self, action, parameters, from)
	if G.jokers then -- If the joker card area exists
		local random_joker = G.jokers.cards[math.random(#G.jokers.cards)] -- Get a random joker from the card area
		SMODS.add_card({ -- Create the joker that was sent over from the sending player
			set = "Joker",
			area = G.jokers,
			key = parameters.joker,
		})
		if random_joker then -- If the random joker is no nil
			random_joker:remove() -- Then remove it
			return { -- And send it as a response to the original sender
				joker = random_joker.config.center.key,
			}
		else
			return { -- Otherwise, send a message telling the sender they get no joker
				joker = "nope",
			}
		end
	end
	return true -- This is just an "ack" telling the other player we got the message but don't have a response for them
end

-- We want this function to run when we get a response to the joker swap request
SWAP.FUNCS.CALLBACK_SWAP_JOKER = function(self, msg)
	if G.jokers then -- If the joker card area exists
		local card = SMODS.find_card(self.sent_params.joker)[1] -- Get the joker that we sent
		if card then -- If it still exits
			card:remove() -- Then delete it
		end
		if msg.joker and msg.joker ~= "nope" then -- If they responded with a joker
			SMODS.add_card({ -- Create the joker that the receiving player responsded with
				set = "Joker",
				area = G.jokers,
				key = msg.joker,
			})
		end
	end
end

-- We create an action type, this defines the behaviour when someone sends this action
-- This must have a key and parameters, but has many other things we can define about it for more advanced functionality
SWAP.ACTIONS.SWAP_JOKER_ACTION_TYPE = MPAPI.NetworkActionType({
	key = "swap_joker",
	parameters = {
		{
			key = "joker",
			type = "string",
			required = true,
		},
	},
	callback_parameters = { -- The callback parameters is what we expect to receive if the receiving player responds
		{
			key = "joker",
			type = "string",
		},
	},
	on_receive = SWAP.FUNCS.ON_RECEIVE_SWAP_JOKER,
})

-- Overrides buy_from_shop so that we can run some additional code when this function is called
local buy_from_shop_ref = G.FUNCS.buy_from_shop
function G.FUNCS.buy_from_shop(e)
	buy_from_shop_ref(e)

	local card = e.config.ref_table -- Gets the bought card

	if card.ability.set == "Joker" then -- If the bought card is a joker
		-- We create an action using the action type we created
		local action = MPAPI.NetworkAction(SWAP.ACTIONS.SWAP_JOKER_ACTION_TYPE)
		-- We set the joker parameter to the joker we bought, parameters must match the parameters set in the action type
		local parameters = {
			joker = card.config.center.key,
		}
		-- We set the callback function that will run if we get a response from the receiving player
		-- It is good practice to use a named function created elsewhere, but we could also create a function in-place like this:
		--[[
		action:callback(function(self, msg) 
			MPAPI.send_debug_message("The callback has been run")
		end)
		]]
		action:callback(SWAP.FUNCS.CALLBACK_SWAP_JOKER)
		local random_player
		repeat
			-- We get a random player that isnt ourselves by getting random indexes from `players_by_index` until one doesn't match our code
			random_player = MPAPI.LOBBY_PLAYERS.BY_INDEX[math.random(#MPAPI.LOBBY_PLAYERS.BY_INDEX)]
		until random_player.code ~= MPAPI.get_code()
		-- Then we send the action to the random player using their code and the parameters we created
		action:send(random_player.code, parameters)
	end
end
