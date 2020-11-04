local Me = FortunaDiceRoller

BasicVerboseRollString = {}
BasicConciseRollString = {}
FortunaVerboseRollString = {}
FortunaConciseRollString = {}

local FirstLightGuilds = {
  ["First Light"] = true;
  ["First Líght"] = true;
}

function Me.BasicDieRoll(RollString)
  local count, sides, modtype, mod = RollString:match("^%s*(%d*)[dD](%d+)([+-]?)(%d*)%s*$")

  if not count then
    Me.Print(Me, "d20 roll string format: XdY+Z")
  end

  count   = count   == "" and 1 or tonumber(count)
  sides   = sides   == "" and 20 or tonumber(sides)
  modtype = modtype == "" and "+" or modtype
  mod     = mod     == "" and 0 or tonumber(mod)

  if modtype == "-" then
    mod = -mod
  end

  local TotalDieRoll = 0

  for i=1,count do
    ThisRoll = math.random(sides)
    TotalDieRoll = TotalDieRoll + ThisRoll

    ThisRollVerboseOutputString = "Roll " .. i .. ": Rolled a d" .. tostring(sides) .. " for " .. tostring(ThisRoll) .. ". "
    table.insert(BasicVerboseRollString, ThisRollVerboseOutputString)
  end

  TotalDieRoll = TotalDieRoll + mod

  ThisRollConciseOutputString = "Rolled " .. RollString .. " for "
  .. TotalDieRoll
  table.insert(BasicConciseRollString, ThisRollConciseOutputString)

  ThisRollOutputString = " Added modifier " .. mod .. ". Total: " .. TotalDieRoll
  table.insert(BasicVerboseRollString, ThisRollOutputString)

  Me.db.profile.LastRollResult = TotalDieRoll
  Me.db.profile.LastRollMode = "Basic"

  if Me.db.profile.OutputTo ~= "CONSOLE" and Me.db.profile.OutputTo ~= "SAY" then
    BasicRollVerboseLabel = " <FortunaDiceRoller (d20)>"
    BasicRollConciseLabel = " <FDR (d20)>"

    table.insert(BasicVerboseRollString, BasicRollVerboseLabel)
    table.insert(BasicConciseRollString, BasicRollConciseLabel)
  end

  local FinalBasicVerboseRollString = table.concat(BasicVerboseRollString)
  local FinalBasicConciseRollString = table.concat(BasicConciseRollString)

  if Me.db.profile.VerboseMode then
    Me.SendOutput(FinalBasicVerboseRollString)
  else
    Me.SendOutput(FinalBasicConciseRollString)
  end

  -- clear tables for next use
  for k in pairs (BasicVerboseRollString) do
    BasicVerboseRollString [k] = nil
  end
  for k in pairs (BasicConciseRollString) do
    BasicConciseRollString [k] = nil
  end
end

function Me.FortunaDieRoll(RollString)
  local count, sides, modtype, mod, difficulty, RollMode

  RollMode = -1

  count, sides, difficulty = RollString:match("^%s*(%d*)[dD](%d+)[vV](%d+)%s*$")
  if count then
    RollMode = 4
    modtype = "+"
    modifier = 0
  end -- out of order, added later

  count, sides, modtype, mod, difficulty =
  RollString:match("^%s*(%d*)[dD](%d+)([+-]?)(%d*)[vV](%d+)%s*$")
  if count then RollMode = 1 end

  if RollMode == -1 then
    Me.db.profile.LastRollString = RollString
    Me.db.profile.LastRollMode = "Fortuna"

    count, sides, modtype, mod =
    RollString:match("^%s*(%d*)[dD](%d+)([+-]?)(%d*)%s*$")
    if count then
      RollMode = 2
      difficulty = 0
    end
  end

  if RollMode == -1 then
    Me.Print(Me, "Fortuna roll string format w/ known difficulty: XdY+ZvD")
    Me.Print(Me, "Fortuna roll string format w/o difficulty: XdY+Z")
  end

  count      = count      == "" and 1 or tonumber(count)
  sides      = sides      == "" and 20 or tonumber(sides)
  modtype    = modtype    == "" and "+" or modtype
  mod        = mod        == "" and 0 or tonumber(mod)
  difficulty = difficulty == "" and 0 or tonumber(difficulty)

  local DiceIxploded = false

  if modtype == "-" then
    mod = -mod
  end

  -- if RollMode == 1 then Me.Print(Me, count, sides, modtype, mod, difficulty) end
  -- if RollMode == 2 then Me.Print(Me, count, sides, modtype, mod) end

  local TotalDieRoll = 0                --track total so far
  local IxplosionRoll = 0              --imploding/exploding die roll

  -- We don't let end users adjust this. It's part of the basic Fortuna rules.
  -- Every (this many) pips rolled gains an extra point of healing/damage.
  local threshold = 5

  local critFail = 1                 --default crit-fail to 1
  local critSuccess = sides          --crit success = highest roll possible
  local InImplosion = false
  local DiceModifier = mod
  local AspectCount = math.abs(count-1)

  if RollMode ~= -1 then
    Me.db.profile.LastRollString = RollString

    if AspectCount > 0 then
      ThisRollOutputString = "Invoked " .. tostring(AspectCount) .. " aspect(s). "
      table.insert(FortunaVerboseRollString, ThisRollOutputString)
      ThisConciseRollString = tostring(AspectCount) .. " Aspects. "
      table.insert(FortunaConciseRollString, ThisConciseRollString)
    end

    for i=1,count do
      ThisRoll = math.random(sides)
      TotalDieRoll = TotalDieRoll + ThisRoll

      ThisRollOutputString = "[" .. i .. "]: Rolled a d" .. tostring(sides) .. " for " .. tostring(ThisRoll) .. ". "
      table.insert(FortunaVerboseRollString, ThisRollOutputString)

      if ThisRoll == critFail or ThisRoll == critSuccess then
        if ThisRoll == critFail then InImplosion = true end
        local IxplosionMode = "explosion"
        DiceIxploded = true
        while math.abs(IxplosionRoll) == 0 or math.abs(IxplosionRoll) == critSuccess do
          IxplosionRoll = math.random(sides)
          if ThisRoll == critFail then
            IxplosionMode = "implosion"
            DiceIxploded = true
            IxplosionRoll = -IxplosionRoll
          end
          TotalDieRoll = TotalDieRoll+IxplosionRoll
          ThisRollOutputString = "Rolled an " .. IxplosionMode .. " d" ..sides .. " for " .. tostring(IxplosionRoll) .. ". "
          table.insert(FortunaVerboseRollString, ThisRollOutputString)
          if math.abs(IxplosionRoll) ~= critFail and math.abs(IxplosionRoll) ~= critSuccess then
            break
          end
        end
      end

      if DiceModifier > 0 then
        ThisVerboseRollString = modtype .. tostring(DiceModifier) .. ". "
        table.insert(FortunaVerboseRollString, ThisVerboseRollString)
        TotalDieRoll = TotalDieRoll + DiceModifier
      end
    end

    local ConciseRollIxplosionMarker
    if DiceIxploded then
      ConciseRollIxplosionMarker = " [!]"
    else
      ConciseRollIxplosionMarker = ""
    end

    if DiceModifier > 0 then
      ThisConciseRollString = "Rolled " .. count .. "d" .. sides .. "+"
          .. DiceModifier .. " for " .. TotalDieRoll
    else
      ThisConciseRollString = "Rolled " .. count .. "d" .. sides
          .. " for " .. TotalDieRoll
    end

    if difficulty == 0 then
      ThisConciseRollString = ThisConciseRollString .. ConciseRollIxplosionMarker
    end

    table.insert(FortunaConciseRollString, ThisConciseRollString)

    Me.db.profile.LastRollResult = TotalDieRoll

    ActionEffectiveness = math.floor((TotalDieRoll-difficulty)/threshold)+1

    ThisVerboseRollString = "RESULT: ".. tostring(TotalDieRoll)
    table.insert(FortunaVerboseRollString, ThisVerboseRollString)

    if difficulty > 0 then
      ThisVerboseRollString = " for " .. tostring(ActionEffectiveness) .. " points against difficulty of " .. tostring(difficulty) .. ". "
      table.insert(FortunaVerboseRollString, ThisVerboseRollString)

      ThisConciseRollString = " vs. " .. difficulty .. ". (RESULT: " .. ActionEffectiveness .. ")"
      table.insert(FortunaConciseRollString, ThisConciseRollString)

      if DiceIxploded then
        ThisConciseRollString = ConciseRollIxplosionMarker
        table.insert(FortunaConciseRollString, ThisConciseRollString)
      end

      DiceIxploded = false
    end

    -- We don't need to report ixplosions being disabled if the player is
    -- not in First Light. Other guilds likely won't use this feature.
    -- It's self-evident in verbose mode, so don't do it there.
    -- if Me.IsPlayerInFL() then
    --   if not Me.db.profile.VerboseMode and not Me.db.profile.Ixplosions then
    --     NoIxplosionsString = " (Ixplosions off)"
    --     table.insert(FortunaConciseRollString, NoIxplosionsString)
    --   end
    -- end

    if Me.db.profile.OutputTo ~= "CONSOLE" and Me.db.profile.OutputTo ~= "SAY" then
      ThisVerboseRollString = " <FortunaDiceRoller (Fortuna)>"
      table.insert(FortunaVerboseRollString, ThisVerboseRollString)
      ThisConciseRollString = " <FDR (F)>"
      table.insert(FortunaConciseRollString, ThisConciseRollString)
    end

    local FinalVerboseRollString = table.concat(FortunaVerboseRollString)
    local FinalConciseRollString = table.concat(FortunaConciseRollString)

    if not Me.db.profile.VerboseMode then
      RollOutput = FinalConciseRollString
    else
      RollOutput = FinalVerboseRollString
    end
  end

  Me.SendOutput(RollOutput)

  -- clear tables for next use
  for k in pairs (FortunaVerboseRollString) do
    FortunaVerboseRollString [k] = nil
  end
  for k in pairs (FortunaConciseRollString) do
    FortunaConciseRollString [k] = nil
  end
end

function Me.SendOutput(InputString)
  if Me.db.profile.OutputTo == "SAY" then
    SendChatMessage(InputString, Me.db.profile.OutputTo)
  elseif Me.db.profile.OutputTo == "PARTY" then
    if UnitInParty("player") then
      SendChatMessage(InputString, Me.db.profile.OutputTo)
    else
      Me.Print(Me, "Not in a party. Change output mode and reroll.")
    end
  elseif Me.db.profile.OutputTo == "RAID" then
    if UnitInRaid("player") then
      SendChatMessage(InputString, Me.db.profile.OutputTo)
    else
      Me.Print(Me, "Not in a raid. Change output mode and reroll.")
    end
  elseif Me.db.profile.OutputTo == "CONSOLE" then
    Me:Print(InputString)
  elseif string.match(Me.db.profile.OutputTo, "RP") ~= nil and CrossRP ~= nil then
    if CrossRP.active then
      SendChatMessage(InputString,Me.db.profile.OutputTo, nil);
    else
      Me.Print(Me, "CrossRP installed, but relay seems to be inactive.")
    end
  else
    Me:Print(Me, Me.db.profile.OutputTo)
    Me:Print(Me, "Can't figure out what the output mode is. Select one.")
  end
end
