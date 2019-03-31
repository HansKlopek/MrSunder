MrSunderBars = {};
function MrSunder_CreateBars()
  for i=1,5 do
    MrSunder["Timestamp" .. i] = 0;
    local f = CreateFrame("Frame", "SunderBar" .. i, MrSunderGui.body);
    f = getglobal("SunderBar" .. i);
    f:SetWidth(200);
    f:SetHeight(22);
    f:SetPoint("TOPLEFT", 0, - (MrSunderOffsetY * (i - 1)));
    local labelBg = f:CreateTexture(nil, "ARTWORK");
    labelBg:SetPoint("TOPLEFT", 0, 0);
    labelBg:SetHeight(22);
    labelBg:SetWidth(200);
    labelBg:SetTexture(0, 0, 0, 0.3);

    local l = f:CreateFontString("SunderBarLabel" .. i, "OVERLAY", "GameFontHighlight");
    l = getglobal("SunderBarLabel" .. i);
  	l:SetPoint("TOPLEFT", 25, -5);
  	l:SetTextColor(1, 1, 1);
    l:SetText("MRSUNDER_DEFAULT_BAR_TEXT" .. i);
    l:SetFont(MrSunderFontLight, 10);
    local l = f:CreateFontString("SunderBarTimer" .. i, "OVERLAY", "GameFontHighlight");
    l = getglobal("SunderBarTimer" .. i);
  	l:SetPoint("TOPLEFT", 7, -5);
  	l:SetTextColor(1, 1, 1);
    l:SetText("MRSUNDER_DEFAULT_BAR_TEXT" .. i);
    l:SetFont(MrSunderFontBold, 10);
    f:Hide();
    f.Index = i;

    --debugging

    f:SetScript("OnUpdate", function(self)
      local timestamp = MrSunder_GetTimeLeft(f.Index);
      l:SetText(30 - floor(timestamp + .5));
      if(timestamp >= 30) then
        f:Hide();
          MrSunder["Timestamp" .. f.Index] = 0;
      end
    	-- f:SetValue(timestamp)
    end)
  end
end

function MrSunder_Populate(name, time)
  if(MrSunderBars[1] == nil) then
    MrSunder_CreateBars();
  end
  if(not MrSunder_PlayerInstanced) then
    return;
  end
  for i=1,5 do
    if(MrSunderBars[i] == name) then
      MrSunder["Timestamp" .. i] = time;
      getglobal("SunderBarLabel" .. i):SetText(name);
      getglobal("SunderBar" .. i):Show();
      return;
    end
  end
  for i=1,5 do
    local bar = getglobal("SunderBar" .. i);
    if(not bar:IsVisible()) then
      MrSunderBars[i] = name;
      MrSunder["Timestamp" .. i] = time;
      getglobal("SunderBarLabel" .. i):SetText(name);
      getglobal("SunderBar" .. i):Show();
      return;
    end
  end
end

function MrSunder_RemoveBar(name)
  for i=1,5 do
    if(MrSunderBars[i] == name) then
      getglobal("SunderBar" .. i):Hide();
    end
  end
end

function MrSunder_GetTimeLeft(index)
    return GetTime() - MrSunder["Timestamp" .. index];
end
