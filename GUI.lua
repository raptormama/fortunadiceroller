local Me = FortunaDiceRoller

-- Some window-size settings. This makes the window easy to tweak.
Me.MainWindowWidth            = 300
Me.MainWindowHeight           = 500
Me.BasicWindowHeight          = 110
Me.FortunaWindowHeight        = Me.BasicWindowHeight
Me.BasicSettingsFrameHeight   = 100
Me.FortunaSettingsFrameHeight = 150
Me.SettingsFrameHeight        = Me.BasicSettingsFrameHeight
    + Me.FortunaSettingsFrameHeight + 60
Me.HelpFrameHeight            = 130
Me.CloseButtonHeight          = 75
Me.ModeButtonHeight           = 75
Me.InputBoxWidth              = 230
Me.InputBoxRelativeWidth      = 0.70
Me.RollButtonRelativeWidth    = 0.30

-- Callback function for OnGroupSelected
function Me.SelectGroup(container, event, group)
  container:ReleaseChildren()
  if group == "Basic" then
    Me.DrawBasicRollFrame(container)
    Me.db.profile.CurrentRollMode = "Basic"
  elseif group == "Fortuna" then
    Me.DrawFortunaRollFrame(container)
    Me.db.profile.CurrentRollMode = "Fortuna"
  elseif group == "Settings" then
    Me.DrawSettingsFrame(container)
    Me.db.profile.CurrentRollMode = "Settings"
  elseif group == "Help" then
    Me.DrawHelpFrame(container)
    Me.db.profile.CurrentRollMode = "Help"
  end
end

-- Draw basic-roll GUI
function Me.DrawBasicRollFrame(container)
  BasicRollFrame = AceGUI:Create("InlineGroup")
  BasicRollFrame:SetFullWidth(true)
  BasicRollFrame:SetLayout("Flow")
  container:AddChild(BasicRollFrame)

  BasicRollInputBox = AceGUI:Create("EditBox")
  BasicRollInputBox:SetRelativeWidth(Me.InputBoxRelativeWidth)
  BasicRollInputBox:SetText(Me.db.profile.BasicRollString)
  BasicRollInputBox:DisableButton(true)
  BasicRollInputBox:SetCallback("OnTextChanged",
    function(widget, event, text)
    Me.db.profile.BasicRollString = text
  end)
  BasicRollInputBox:SetCallback("OnEnterPressed",
    function(widget, event, text)
    Me.db.profile.BasicRollString = text
  end)
  BasicRollFrame:AddChild(BasicRollInputBox)

  MainGUIFrame:SetHeight(Me.BasicWindowHeight+Me.CloseButtonHeight)

  BasicRollSubmitButton = AceGUI:Create("Button")
  BasicRollSubmitButton:SetText("Roll!")
  BasicRollSubmitButton:SetRelativeWidth(Me.RollButtonRelativeWidth)
  BasicRollSubmitButton:SetCallback("OnClick", function()
    Me.BasicDieRoll(Me.db.profile.BasicRollString)
  end)
  BasicRollFrame:AddChild(BasicRollSubmitButton)
end

-- Drasw settings GUI
function Me.DrawSettingsFrame(container)
  BasicSettingsHeader = AceGUI:Create("Heading")
  BasicSettingsHeader:SetText("Basic d20 Settings")
  BasicSettingsHeader:SetFullWidth(true)
  container:AddChild(BasicSettingsHeader)

  BasicSettingsFrame = AceGUI:Create("InlineGroup")
  BasicSettingsFrame:SetFullWidth(true)
  BasicSettingsFrame:SetHeight(Me.BasicSettingsFrameHeight)
  BasicSettingsFrame:SetLayout("List")
  container:AddChild(BasicSettingsFrame)

  BasicSettingsNoSettingsYet = AceGUI:Create("Label")
  BasicSettingsNoSettingsYet:SetText("No d20-specific options yet.")
  BasicSettingsNoSettingsYet:SetFullWidth(true)
  BasicSettingsFrame:AddChild(BasicSettingsNoSettingsYet)

  FortunaSettingsHeader = AceGUI:Create("Heading")
  FortunaSettingsHeader:SetText("Fortuna System Settings")
  FortunaSettingsHeader:SetFullWidth(true)
  container:AddChild(FortunaSettingsHeader)

  FortunaSettingsFrame = AceGUI:Create("InlineGroup")
  FortunaSettingsFrame:SetFullWidth(true)
  FortunaSettingsFrame:SetHeight(Me.FortunaSettingsFrameHeight)
  FortunaSettingsFrame:SetLayout("List")
  container:AddChild(FortunaSettingsFrame)

  FortunaSettingsNoSettingsYet = AceGUI:Create("Label")
  FortunaSettingsNoSettingsYet:SetText("No Fortuna-specific options yet.")
  FortunaSettingsNoSettingsYet:SetFullWidth(true)
  FortunaSettingsFrame:AddChild(FortunaSettingsNoSettingsYet)

  OutputOptions = {
    ["CONSOLE"] = 'Console',
    ["PARTY"] = 'Party',
    ["RAID"] = 'Raid',
    ["SAY"] = 'Say',
  }

  GeneralSettingsHeader = AceGUI:Create("Heading")
  GeneralSettingsHeader:SetText("All-Mode/Generic Settings")
  GeneralSettingsHeader:SetFullWidth(true)
  container:AddChild(GeneralSettingsHeader)

  GeneralSettingsFrame = AceGUI:Create("InlineGroup")
  GeneralSettingsFrame:SetFullWidth(true)
  GeneralSettingsFrame:SetHeight(Me.BasicSettingsFrameHeight)
  GeneralSettingsFrame:SetLayout("List")
  container:AddChild(GeneralSettingsFrame)

  OutputTo = AceGUI:Create("Dropdown")
  OutputTo:SetList(OutputOptions)
  if CrossRP ~= nil then
    for i=1,9 do
      OutputTo:AddItem("RP" .. tostring(i), 'RP' .. tostring(i))
    end
  end
  OutputTo:SetValue(Me.db.profile.OutputTo)
  OutputTo:SetMultiselect(false)
  OutputTo:SetLabel("Output To:")
  OutputTo:SetCallback("OnValueChanged", function(self, event, value)
    Me.db.profile.OutputTo = value
  end)
  GeneralSettingsFrame:AddChild(OutputTo)

  VerboseToggle = AceGUI:Create("CheckBox")
  VerboseToggle:SetType("checkbox")
  VerboseToggle:SetValue(Me.db.profile.VerboseMode)
  VerboseToggle:SetTriState(false)
  VerboseToggle:SetLabel("Verbose output")
  VerboseToggle:SetCallback("OnValueChanged", function(self, event, value)
    Me.db.profile.VerboseMode = value
  end)

  GeneralSettingsFrame:AddChild(VerboseToggle)

  MainGUIFrame:SetHeight(Me.SettingsFrameHeight+Me.CloseButtonHeight)
end

function Me.DrawHelpFrame(container)
  HelpFrame = AceGUI:Create("InlineGroup")
  HelpFrame:SetFullWidth(true)
  HelpFrame:SetFullHeight(true)
  HelpFrame:SetLayout("List")
  container:AddChild(HelpFrame)

  D20HelpText = AceGUI:Create("Label")
  D20HelpText:SetText("d20: Standard dice roller.")
  HelpFrame:AddChild(D20HelpText)

  ExpNoteText = AceGUI:Create("Label")
  ExpNoteText:SetText("Implosions/explosions are automatic.")
  HelpFrame:AddChild(ExpNoteText)

  AspectHelpText = AceGUI:Create("Label")
  AspectHelpText:SetText("Aspects: Roll more than 1 d20 (3d20 for 2).")
  HelpFrame:AddChild(AspectHelpText)

  DiffHelpText = AceGUI:Create("Label")
  DiffHelpText:SetText("Roll format for difficulties: XdYvA;")
  HelpFrame:AddChild(DiffHelpText)

  DiffHelpText2 = AceGUI:Create("Label")
  DiffHelpText2:SetText("  or, with modifier: XdY+ZvA.")
  HelpFrame:AddChild(DiffHelpText2)

  MainGUIFrame:SetHeight(Me.HelpFrameHeight+Me.CloseButtonHeight)
end

-- Draw Fortuna roll GUI
function Me.DrawFortunaRollFrame(container)
  FortunaRollFrame = AceGUI:Create("InlineGroup")
  FortunaRollFrame:SetFullWidth(true)
  FortunaRollFrame:SetLayout("Flow")
  container:AddChild(FortunaRollFrame)

  MainGUIFrame:SetHeight(Me.FortunaWindowHeight+Me.CloseButtonHeight)

  FortunaRollInputBox = AceGUI:Create("EditBox")
  FortunaRollInputBox:SetRelativeWidth(Me.InputBoxRelativeWidth)
  FortunaRollInputBox:SetText(Me.db.profile.FortunaRollString)
  FortunaRollInputBox:DisableButton(true)
  FortunaRollInputBox:SetCallback("OnTextChanged",
    function(widget, event, text)
    Me.db.profile.FortunaRollString = text
  end)
  FortunaRollInputBox:SetCallback("OnEnterPressed", function()
    Me.FortunaDieRoll(Me.db.profile.FortunaRollString)
  end)
  FortunaRollFrame:AddChild(FortunaRollInputBox)

  FortunaRollSubmitButton = AceGUI:Create("Button")
  FortunaRollSubmitButton:SetText("Roll!")
  FortunaRollSubmitButton:SetRelativeWidth(Me.RollButtonRelativeWidth)
  FortunaRollSubmitButton:SetCallback("OnClick", function()
    Me.FortunaDieRoll(Me.db.profile.FortunaRollString)
  end)
  FortunaRollFrame:AddChild(FortunaRollSubmitButton)
end

-- Save info about main frame when closing it
function Me.MainFrameCloseHelper(widget)
  if widget ~= nil then
    local _, _, anchor, x, y = widget:GetPoint()
    Me.db.profile.MainWindowAnchor = tostring(anchor)
    Me.db.profile.MainWindowX = x
    Me.db.profile.MainWindowY = y
    Me.db.profile.GUIShown = false
    AceGUI:Release(widget)
  end
end

-- Draw the main window, find current mode, and draw that too
function Me.DrawMainGUI()
  local anchor = Me.db.profile.MainWindowAnchor
  local x = Me.db.profile.MainWindowX
  local y = Me.db.profile.MainWindowY

  -- Reset things if something went wrong
  if Me.db.profile.MainWindowAnchor == "nil" then
    Me.db.profile.MainWindowAnchor = "CENTER"
    Me.db.profile.MainWindowX = 0
    Me.db.profile.MainWindowY = 0
  end

  MainGUIFrame = AceGUI:Create("Frame")
  MainGUIFrame:EnableResize(false)
  MainGUIFrame:ClearAllPoints()
  MainGUIFrame:SetPoint(tostring(Me.db.profile.MainWindowAnchor),x,y)
  MainGUIFrame:SetWidth(Me.MainWindowWidth)
  MainGUIFrame:SetTitle("Fortuna Dice Roller")
  MainGUIFrame:SetCallback("OnClose", function(widget)
    Me.MainFrameCloseHelper(widget)
  end)
  MainGUIFrame:SetLayout("Fill")

  tab =  AceGUI:Create("TabGroup")
  tab:SetLayout("Flow")
  tab:SetTabs({
    {text = "d20",      value = "Basic"},
    {text = "Fortuna",  value = "Fortuna"},
    {text = "Settings", value = "Settings"},
    {text = "Help",     value = "Help"},
  })
  tab:SetCallback("OnGroupSelected", Me.SelectGroup)
  tab:SelectTab(Me.db.profile.CurrentRollMode)
  MainGUIFrame:AddChild(tab)
  Me.db.profile.GUIShown = true
end
