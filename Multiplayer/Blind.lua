--- STEAMODDED HEADER
--- STEAMODDED SECONDARY FILE

----------------------------------------------
------------MOD BLIND-------------------------

local bl_pvp = {
  name = 'Your Nemesis',
  defeated = false,
  order = 0,
  dollars = 5,
  mult = 0,
  vars = {},
  debuff = {},
  pos = {x=0, y=25},
  boss_colour = HEX('ac3232'),
  boss = {min = 1, max = 10}
}

local create_UIBox_your_collection_blinds_ref = create_UIBox_your_collection_blinds
function create_UIBox_your_collection_blinds(exit)
  G.P_BLINDS.bl_pvp = nil
  local res = create_UIBox_your_collection_blinds_ref(exit)
  G.P_BLINDS.bl_pvp = bl_pvp
  return res
end

local set_discover_tallies_ref = set_discover_tallies
function set_discover_tallies()
  G.P_BLINDS.bl_pvp = nil
  local res = set_discover_tallies_ref()
  G.P_BLINDS.bl_pvp = bl_pvp
  return res
end

----------------------------------------------
------------MOD BLIND END---------------------