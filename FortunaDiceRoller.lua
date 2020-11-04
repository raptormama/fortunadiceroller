-- Curseforge icon made by Freepik from www.flaticon.com

local AddonName, Me = ...

Me.CrossRPRelayEnabled = CrossRP.active

function Me.IsCrossRPReady()
  local CrossRPLoaded = LoadAddOn("CrossRP")
  if CrossRPLoaded == true and CrossRP ~= nil then
    return true
  else
    return false
  end
end
