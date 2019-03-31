--bars
MrSunderOffsetX = 200;
MrSunderOffsetY = 22;
MrSunderBarYPadding = 22;
MrSunderBarXPadding = 0;
--MrSunderBarCount = 5; //not using this atm.
--vars
MrSunderLastFail = 0;
MrSunderLastCast = 0;
MrSunderLastCastTarget = "";
MrSunderSpellID = 0;
MrSunder = {};
MrSunder.Events = {
  "CHAT_MSG_SPELL_SELF_DAMAGE",
  "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
  "CHAT_MSG_COMBAT_HOSTILE_DEATH",
  "CHAT_MSG_ADDON";
};
-- GUI
GuiTitle = "SUNDERS";
MrSunderGui = {};
local guiIsInit = false;
local isMovable = true;
local images = "Interface\\AddOns\\MrSunder\\Images\\";
local fonts = "Interface\\AddOns\\MrSunder\\Fonts\\";
MrSunderFontRegular = fonts .. "RobotoCondensed-Regular.ttf";
MrSunderFontBold = fonts .. "RobotoCondensed-Bold.ttf";
MrSunderFontLight = fonts .. "RobotoCondensed-Light.ttf";


function MrSunder_OnLoad()
  MrSunder_ToggleEvents(true);
  local _, englishClass = UnitClass("player");
end

function MrSunder_CreateGui()
  if (guiIsInit) then
		return; 
  end
  MrSunderGui.frame = MrSunderFrame;
  MrSunderGui.frame:SetMovable(true);
  MrSunderGui.frame:EnableMouse(true);
  MrSunderGui.body = MrSunderBodyFrame;
  -- Header
  local labelBg = MrSunderGui.frame:CreateTexture(nil, "ARTWORK");
  labelBg:SetPoint("TOPLEFT", 0, 0);
	labelBg:SetHeight(22);
	labelBg:SetWidth(200);
	labelBg:SetTexture(0, 0, 0, 0.3);
  local label = MrSunderGui.frame:CreateFontString('title', "OVERLAY", "GameFontNormal");
	label:SetPoint("TOPLEFT", 7, -6);
	label:SetTextColor(1, 1, 1);
	label:SetText(GuiTitle);
  label:SetFont(MrSunderFontBold, 10);
  label:SetShadowOffset(0, -1);
  label:SetShadowColor(0,0,0);
  -- Action buttons
  local lockBtn = CreateFrame("Button", "lockerBtn", MrSunderGui.frame, "UIPanelButtonTemplate");
	lockBtn:SetPoint("TOPRIGHT", -25, -3);
  lockBtn:SetHeight(16);
	lockBtn:SetWidth(16);
  lockBtn:SetAlpha(0.3);
  local lockTex = lockBtn:CreateTexture("lockerBtnTexture");
  lockTex:SetTexture(images .. "unlocked");
  lockTex:SetHeight(13);
	lockTex:SetWidth(13);
  lockTex:SetPoint("CENTER", lockBtn, "CENTER", 0, 0);
  lockBtn:SetNormalTexture(lockTex);
	lockBtn:SetPushedTexture(nil);
	lockBtn:SetHighlightTexture(nil);
  lockBtn:SetScript("OnClick", function()
    isMovable = not isMovable;
    if (isMovable == false) then
      lockBtn:SetAlpha(0.7);
      lockTex:SetTexture(images .. "locked");
    else
      lockBtn:SetAlpha(0.3);
      lockTex:SetTexture(images .. "unlocked");
    end
  end)
  local closeBtn = CreateFrame("Button", "closeBtn", MrSunderGui.frame, "UIPanelButtonTemplate");
	closeBtn:SetPoint("TOPRIGHT", -7, -3);
  closeBtn:SetHeight(16);
	closeBtn:SetWidth(16);
  closeBtn:SetAlpha(0.3);
  local closeTex = closeBtn:CreateTexture("closeBtnTexture");
  closeTex:SetTexture(images .. "close");
  closeTex:SetHeight(13);
	closeTex:SetWidth(13);
  closeTex:SetPoint("CENTER", closeBtn, "CENTER", 0, 0);
  closeBtn:SetNormalTexture(closeTex);
	closeBtn:SetPushedTexture(nil);
	closeBtn:SetHighlightTexture(nil);
  closeBtn:SetScript("OnClick", function()
    MrSunderGui_Hide();
  end)
  -- Body
  MrSunderGui.body:SetPoint("TOPLEFT", 0, -22);
  guiIsInit = true;
end

function MrSunderGui_Hide()
  MrSunderGui.frame:Hide();
end

function MrSunderGui_Show()
  MrSunderGui.frame:Show();
end

function MrSunderGui_StartMoving()
  if (MrSunderGui.frame:IsMovable() and (isMovable == true)) then 
		MrSunderGui.frame:StartMoving();
	end
end

function MrSunderGui_StopMovingOrSizing()
  MrSunderGui.frame:StopMovingOrSizing()
end

function whomeframe()
  local f = CreateFrame("Frame","MrSunderFrame",UIParent)
  f:SetMovable(true);
  f:EnableMouse(true)
  f:SetFrameStrata("BACKGROUND");
  f:SetWidth(128);
  f:SetHeight(64);

  local t = f:CreateTexture(nil,"BACKGROUND")
  t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
  t:SetAllPoints(f)
  f.texture = t

  f:SetPoint("CENTER",0,0)
  f:Show()
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
end

function MrSunder_OnEvent()
  MrSunder_CreateGui();
  if(event == "CHAT_MSG_COMBAT_HOSTILE_DEATH") then
    if(strfind(arg1, "dies.")) then
      MrSunder_RemoveBar(string.gsub(arg1, " dies.", ""));
    end
    return;
  end
  if(event == "CHAT_MSG_ADDON" and arg1 == "MRSUNDER") then
    local a,b = MrSunder_StringSplit(arg2, "_");
    MrSunder_Populate(a, b);
    return;
  end
  if(strfind(arg1, "Sunder Armor")) then
    if(event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
      MrSunderLastFail = GetTime();
      return;
    end
    --create / refresh bar as a sunder stack has been applied
    local a,b = MrSunder_StringSplit(arg1, " is afflicted");
    -- DebugMessage(a);
    MrSunder_Populate(a, GetTime());
  end
  if(MrSunderLastCast - MrSunderLastFail < 0) then
    MrSunderLastFail = 0;
    MrSunderLastCast = 0;
  end
  if(MrSunderLastCast > 0) then
    --send data for successful sunder application.,
    MrSunder_SendAddonMessage(MrSunderLastCastTarget .. "_" .. MrSunderLastCast);
    MrSunderLastCast = 0;
  end
end

function MrSunder_ToggleEvents(bool)
  for k, v in pairs(MrSunder.Events) do
    if(bool) then
      this:RegisterEvent(v);
    else
      this:UnregisterEvent(v);
    end
  end
end

function MrSunder_SetSpellID()
  if(MrSunderSpellID ~= 0) then
    return
  end
  local i = 1
  while true do
   local spellName = GetSpellName(i, "spell")
    if(spellName == "Sunder Armor") then
      MrSunderSpellID = i;
      return i;
    end
    if not spellName then
      break
    end
   i = i + 1
 end
end

function MrSunder_CastSunder()
  CastSpellByName("Sunder Armor");
  MrSunder_SetSpellID();
  local start, _ = GetSpellCooldown(MrSunderSpellID, "spell");
  if(GetTime() - start == 0) then
    MrSunderLastCast = GetTime();
    MrSunderLastCastTarget = UnitName("target");
    --success, test with self_damage fail (miss, dodge)
  end
end


function MrSunder_SendAddonMessage(msg)
  if GetNumRaidMembers() == 0 then
    SendAddonMessage("MRSUNDER", msg, "PARTY");
  else
    SendAddonMessage("MRSUNDER", msg, "RAID");
  end
end

--TODO: Player blacklist, sunder use tracking, next sunder alert (if unitname = Targetunit name and t < x and targethealth > y),