local AddonName, Me = ...

local LibRealmInfo  = LibStub("LibRealmInfo")

-- First Light consists of two sister guilds, one on Horde and the other
-- on Alliance. These are the two. The realm is checked as part of the
-- sister function that calls on this table.
Me.FirstLightGuilds = {
  ["First Light"] = true;
  ["First Líght"] = true;
}

-- Determine if the player is in a First Light guild on Moon Guard.
-- This will cause the concise mode to display a little bit of extra
-- information when in Fortuna mode (so GMs can call for rerolls if needed)
function Me.IsPlayerInFL()
  local GuildName = GetGuildInfo("player")
  local id, name, nameForAPI, rules, locale, battlegroup, region, timezone, connectedRealmIDs, englishName, englishNameForAPI = LibRealmInfo:GetRealmInfoByUnit("player")
  if Me.FirstLightGuilds[GuildName] == true then
    if englishName == "Moon Guard" then
      return true
    end
  else
    return false
  end
end
