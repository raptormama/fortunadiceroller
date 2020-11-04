local AddonName, Me = ...

FortunaDiceRoller = LibStub("AceAddon-3.0"):NewAddon("FortunaDiceRoller", "AceConsole-3.0", "AceEvent-3.0")
Me = FortunaDiceRoller
LibRealmInfo  = LibStub("LibRealmInfo")
AceGUI = LibStub("AceGUI-3.0")
LDB = LibStub:GetLibrary("LibDataBroker-1.1")

local LDBShortLabel = "FDR"
local LDBLongLabel = "Fortuna Dice Roller"

function Me.HandleLDBButtonClick()
	if Me.db.profile.GUIShown == true then
		Me.MainFrameCloseHelper(MainGUIFrame)
	else
		Me.DrawMainGUI()
	end
end

-- Helper function for the tooltip. Grabs info about the last roll.
function Me.UpdateFDRLauncherTooltip()
	local LastRollString = Me.db.profile.LastRollString
	local LastRollResult = Me.db.profile.LastRollResult
	local LastRollMode   = Me.db.profile.LastRollMode
	local TooltipSummary = "Last roll: " .. LastRollString
			.. " for " .. LastRollResult .. "(" .. LastRollMode .. ")"
	return TooltipSummary
end

-- Use LibDataBroker to create a launcher object. We do this instead of
-- using a minimap button since those things get rather cluttered.
-- When clicked, it will show the GUI; mousing over it will display the
-- last dice roll string, the roll result, and the mode used.
-- This will work with ElvUI, ChocolateBar, TitanPanel, etc.
LDB:NewDataObject(LDBLongLabel, {
	type          = "launcher",
	icon          = "Interface\\Icons\\inv_misc_dice_01",
	label         = LDBShortLabel,
	text          = LDBShortLabel,
	tocname       = FortunaDiceRoller,
	OnClick       = function(clickedframe, button) Me.HandleLDBButtonClick() end,
	OnTooltipShow = function(tooltip)
		local LastRollString = Me.db.profile.LastRollString
		local LastRollResult = Me.db.profile.LastRollResult
		local LastRollMode   = Me.db.profile.LastRollMode
		local TooltipSummary = "Last roll: " .. LastRollString
				.. " for " .. LastRollResult .. "  (" .. LastRollMode .. ")"

		tooltip:SetText(LDBLongLabel)
		tooltip:AddLine(" ")
		tooltip:AddLine(Me.UpdateFDRLauncherTooltip())
	end,
})

-- Set initial default values for first-time users. These only are in effect
-- if the user hasn't changed any of the options. Values in the addon's
-- file in SavedVariables take priority over these.
Me.defaults = {
  profile = {
    GUIShown = false,
    DieCount = 1,
    DiceSides = 20,
    DiceModifier = 0,
    DifficultyValue = 0,
    DifficultyCheck = false,
    VerboseMode = true,
    OutputTo = "CONSOLE",
    Ixplosions = true,
    AspectCount = 0,
    BasicRollString = "1d20+0",
    FortunaRollString = "1d20+0",
    CurrentRollMode = "Basic",
    MainWindowAnchor = "CENTER",
    MainWindowX = 0,
    MainWindowY = 0,
		LastRollString = "1d20",
		LastRollResult = 0,
		LastRollMode = "Basic"
  },
}

-- We want to save the window location/visibility state when the user
-- reloads the interface or logs out.
function Me:OnEnable()
  self:RegisterEvent("PLAYER_LOGOUT")
end

function Me:PLAYER_LOGOUT()
  if MainGUIFrame:IsVisible() == true then
    local _, _, anchor, x, y = MainGUIFrame:GetPoint()
    Me.db.profile.MainWindowAnchor = tostring(anchor)
    Me.db.profile.MainWindowX = x
    Me.db.profile.MainWindowY = y
  end
end

-- This stuff runs when the addon is loaded. It registers the database
-- with AceDB so things get saved between sessions and registers that handy
-- /fdr command that brings up the window when not using the LDB launcher.
function Me:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("FortunaDiceRollerDB", Me.defaults, true)
  self:RegisterChatCommand("fdr", "ChatCommand")
  if Me.db.profile.GUIShown == true then Me.DrawMainGUI() end
end

-- Our /fdr command doesn't take arguments. It glowers at you and then...
-- ... draws the UI. So there. Oh, maybe it has a fireside chat first.
function Me:ChatCommand(input)
  if not input or input:trim() == "" then Me.DrawMainGUI() end
end
