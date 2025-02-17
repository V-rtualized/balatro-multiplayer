SMODS.Mods.Multiplayer.credits_tab = function()
	return {
		n = G.UIT.ROOT,
		config = {
			r = 0.1,
			minw = 5,
			align = "cm",
			padding = 0.2,
			colour = G.C.BLACK,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm",
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = localize("join_discord"),
							shadow = true,
							scale = 0.6,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = {
					padding = 0.2,
					align = "cm",
				},
				nodes = {
					UIBox_button({
						minw = 6,
						button = "multiplayer_discord",
						colour = G.C.BLUE,
						label = {
							localize("discord_name"),
						},
					}),
				},
			},
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm",
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = localize("consider_supporting"),
							shadow = true,
							scale = 0.4,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = {
					padding = 0.2,
					align = "cm",
				},
				nodes = {
					UIBox_button({
						minw = 6,
						button = "multiplayer_kofi",
						colour = G.C.GREEN,
						label = {
							localize("kofi_name"),
						},
					}),
				},
			},
		},
	}
end

function G.FUNCS.multiplayer_discord(e)
	love.system.openURL("https://discord.gg/gEemz4ptuF")
end

function G.FUNCS.multiplayer_kofi(e)
	love.system.openURL("https://ko-fi.com/virtualized")
end
