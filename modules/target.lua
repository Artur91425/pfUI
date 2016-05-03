TargetFrame:Hide()
TargetFrame:UnregisterAllEvents()

pfUI.uf.target = CreateFrame("Button",nil,UIParent)
pfUI.uf.target:Hide()
pfUI.uf.target:RegisterEvent("PLAYER_TARGET_CHANGED")
pfUI.uf.target:SetScript("OnEvent", function()
    if UnitExists("target") then
      pfUI.uf.target:Show()
    else
      pfUI.uf.target:Hide()
    end
  end)
pfUI.uf.target:SetWidth(pfUI.config.unitframes.target.width)
pfUI.uf.target:SetHeight(pfUI.config.unitframes.target.height+pfUI.config.unitframes.target.pheight)
pfUI.uf.target:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 75, 125)

pfUI.uf.target:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
pfUI.uf.target:SetScript("OnClick", function ()
    if arg1 == "RightButton" then
      ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
    end
  end)

pfUI.uf.target:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.uf.target:RegisterEvent("PLAYER_TARGET_CHANGED")
pfUI.uf.target:RegisterEvent("UNIT_HEALTH")
pfUI.uf.target:RegisterEvent("UNIT_MAXHEALTH")
pfUI.uf.target:RegisterEvent("UNIT_DISPLAYPOWER")
pfUI.uf.target:RegisterEvent("UNIT_MANA")
pfUI.uf.target:RegisterEvent("UNIT_MAXMANA")
pfUI.uf.target:RegisterEvent("UNIT_RAGE")
pfUI.uf.target:RegisterEvent("UNIT_MAXRAGE")
pfUI.uf.target:RegisterEvent("UNIT_ENERGY")
pfUI.uf.target:RegisterEvent("UNIT_MAXENERGY")

pfUI.uf.target:SetScript("OnEvent", function()
    if UnitExists("target") then pfUI.uf.target:Show() else
      pfUI.uf.target:Hide()
      return
    end

    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
      pfUI.uf.target.power.bar:SetValue(0)
      pfUI.uf.target.hp.bar:SetValue(0)
    end

    local hp, hpmax
    if MobHealth3 then
      hp, hpmax = MobHealth3:GetUnitHealth("target")
    else
      hp, hpmax = UnitHealth("target"), UnitHealthMax("target")
    end
    local power, powermax = UnitMana("target"), UnitManaMax("target")

    if hp ~= hpmax and hpmax ~= 100 then
      pfUI.uf.target.hpText:SetText( hp .. " - " .. ceil(hp / hpmax * 100) .. "%")
    else
      pfUI.uf.target.hpText:SetText( hp)
    end

    local color
    if UnitIsPlayer("target") then
      _, class = UnitClass("target")
      color = RAID_CLASS_COLORS[class]
    else
      color = UnitReactionColor[UnitReaction("target", "player")]
    end
    local r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5

    pfUI.uf.target.hp.bar:SetMinMaxValues(0, hpmax)
    pfUI.uf.target.hp.bar:SetStatusBarColor(r, g, b, hp / hpmax / 4 + .75)
    pfUI.uf.target.powerText:SetTextColor(r, g, b, 1)

    local perc = hp / hpmax
    local r1, g1, b1, r2, g2, b2
    if perc <= 0.5 then
      perc = perc * 2; r1, g1, b1 = .9, .5, .5; r2, g2, b2 = .9, .9, .5
    else
      perc = perc * 2 - 1; r1, g1, b1 = .9, .9, .5; r2, g2, b2 = .5, .9, .5
    end
    local r, g, b = r1 + (r2 - r1)*perc, g1 + (g2 - g1)*perc, b1 + (b2 - b1)*perc
    pfUI.uf.target.hpText:SetTextColor(r, g, b,1)

    local leveldiff = UnitLevel("player") - UnitLevel("target")
    local levelcolor
    if leveldiff >= 9 then
      levelcolor = "555555"
    elseif leveldiff >= 3 then
      levelcolor = "55ff55"
    elseif leveldiff >= -2 then
      levelcolor = "aaff55"
    elseif leveldiff >= -4 then
      levelcolor = "ffaa55"
    else
      levelcolor = "ff5555"
    end

    local name = string.sub(UnitName("target"),1,25)
    if strlen(UnitName("target")) > 25 then
      name = name .. "..."
    end

    local level = UnitLevel("target")
    if level == -1 then level = "??" end

    if UnitClassification("target") == "worldboss" then
      level = level .. "B"
    elseif UnitClassification("target") == "rareelite" then
      level = level .. "R+"
    elseif UnitClassification("target") == "elite" then
      level = level .. "+"
    elseif UnitClassification("target") == "rare" then
      level = level .. "R"
    end

    pfUI.uf.target.powerText:SetText( "|cff" .. levelcolor .. level .. "|r " .. name)

    PowerColor = ManaBarColor[UnitPowerType("target")];
    pfUI.uf.target.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
    pfUI.uf.target.power.bar:SetMinMaxValues(0, UnitManaMax("target"))

    pfUI.uf.target.hpReal = hp
    pfUI.uf.target.powerReal = power
  end)

pfUI.uf.target:SetScript("OnUpdate", function()
    if not UnitExists("target") then return end

    local hpDisplay = pfUI.uf.target.hp.bar:GetValue()
    local hpReal = pfUI.uf.target.hpReal
    local hpDiff = abs(hpReal - hpDisplay)

    if hpDisplay < hpReal then
      pfUI.uf.target.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI.config.unitframes.animation_speed))
    elseif hpDisplay > hpReal then
      pfUI.uf.target.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI.config.unitframes.animation_speed))
    end

    local powerDisplay = pfUI.uf.target.power.bar:GetValue()
    local powerReal = pfUI.uf.target.powerReal
    local powerDiff = abs(powerReal - powerDisplay)

    if powerDisplay < powerReal then
      pfUI.uf.target.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI.config.unitframes.animation_speed))
    elseif powerDisplay > powerReal then
      pfUI.uf.target.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI.config.unitframes.animation_speed))
    end
  end)

pfUI.uf.target.hp = CreateFrame("Frame",nil, pfUI.uf.target)
pfUI.uf.target.hp:SetBackdrop(pfUI.backdrop)
pfUI.uf.target.hp:SetHeight(pfUI.config.unitframes.target.height)
pfUI.uf.target.hp:SetPoint("TOPLEFT",pfUI.uf.target,"TOPLEFT")
pfUI.uf.target.hp:SetPoint("TOPRIGHT",pfUI.uf.target,"TOPRIGHT")

pfUI.uf.target.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.target.hp)
pfUI.uf.target.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

pfUI.uf.target.hp.bar:ClearAllPoints()
pfUI.uf.target.hp.bar:SetPoint("TOPLEFT", pfUI.uf.target.hp, "TOPLEFT", 3, -3)
pfUI.uf.target.hp.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.target.hp, "BOTTOMRIGHT", -3, 3)

pfUI.uf.target.hp.bar:SetMinMaxValues(0, 100)
pfUI.uf.target.hp.bar:SetValue(100)

pfUI.uf.target.hp.bar.portrait = CreateFrame("PlayerModel",nil,pfUI.uf.target.hp.bar)
pfUI.uf.target.hp.bar.portrait:SetAllPoints(pfUI.uf.target.hp.bar)
pfUI.uf.target.hp.bar.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
pfUI.uf.target.hp.bar.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
pfUI.uf.target.hp.bar.portrait:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.uf.target.hp.bar.portrait:RegisterEvent("PLAYER_TARGET_CHANGED")

pfUI.uf.target.hp.bar.portrait:SetScript("OnEvent", function() this.update() end)
pfUI.uf.target.hp.bar.portrait:SetScript("OnShow", function() this.update() end)

pfUI.uf.target.hp.bar.portrait.update = function ()
  pfUI.uf.target.hp.bar.portrait:SetUnit("target");
  pfUI.uf.target.hp.bar.portrait:SetCamera(0)
  pfUI.uf.target.hp.bar.portrait:SetAlpha(0.10)
end

pfUI.uf.target.power = CreateFrame("Frame",nil, pfUI.uf.target)

pfUI.uf.target.power:SetBackdrop(pfUI.backdrop)
pfUI.uf.target.power:SetPoint("TOPLEFT",pfUI.uf.target.hp,"BOTTOMLEFT",0,3)
pfUI.uf.target.power:SetPoint("BOTTOMRIGHT",pfUI.uf.target,"BOTTOMRIGHT",0,0)

pfUI.uf.target.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.target.power)
pfUI.uf.target.power.bar:ClearAllPoints()
pfUI.uf.target.power.bar:SetPoint("TOPLEFT", pfUI.uf.target.power, "TOPLEFT", 3, -3)
pfUI.uf.target.power.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.target.power, "BOTTOMRIGHT", -3, 3)
pfUI.uf.target.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

pfUI.uf.target.power.bar:SetBackdropColor(0,0,0,1)
pfUI.uf.target.power.bar:SetStatusBarColor(0,0,0)
pfUI.uf.target.power.bar:SetMinMaxValues(0, 100)
pfUI.uf.target.power.bar:SetValue(100)

pfUI.uf.target.hpText = pfUI.uf.target:CreateFontString("Status", "HIGH", "GameFontNormal")
pfUI.uf.target.hpText:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
pfUI.uf.target.hpText:ClearAllPoints()
pfUI.uf.target.hpText:SetParent(pfUI.uf.target.hp.bar)
pfUI.uf.target.hpText:SetPoint("RIGHT",pfUI.uf.target.hp.bar, "RIGHT", -10, 0)
pfUI.uf.target.hpText:SetJustifyH("RIGHT")
pfUI.uf.target.hpText:SetFontObject(GameFontWhite)
pfUI.uf.target.hpText:SetText("5000")

pfUI.uf.target.powerText = pfUI.uf.target:CreateFontString("Status", "HIGH", "GameFontNormal")
pfUI.uf.target.powerText:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
pfUI.uf.target.powerText:ClearAllPoints()
pfUI.uf.target.powerText:SetParent(pfUI.uf.target.hp.bar)
pfUI.uf.target.powerText:SetPoint("LEFT",pfUI.uf.target.hp.bar, "LEFT", 10, 0)
pfUI.uf.target.powerText:SetJustifyH("LEFT")
pfUI.uf.target.powerText:SetFontObject(GameFontWhite)
pfUI.uf.target.powerText:SetText("5000")

pfUI.uf.target.combopoints = CreateFrame("Frame")

pfUI.uf.target.combopoints:RegisterEvent("UNIT_COMBO_POINTS")
pfUI.uf.target.combopoints:RegisterEvent("PLAYER_COMBO_POINTS")
pfUI.uf.target.combopoints:RegisterEvent("UNIT_DISPLAYPOWER")
pfUI.uf.target.combopoints:RegisterEvent("PLAYER_TARGET_CHANGED")
pfUI.uf.target.combopoints:RegisterEvent('UNIT_ENERGY');
pfUI.uf.target.combopoints:RegisterEvent("PLAYER_ENTERING_WORLD")

pfUI.uf.target.combopoint1 = CreateFrame("Frame")
pfUI.uf.target.combopoint2 = CreateFrame("Frame")
pfUI.uf.target.combopoint3 = CreateFrame("Frame")
pfUI.uf.target.combopoint4 = CreateFrame("Frame")
pfUI.uf.target.combopoint5 = CreateFrame("Frame")

pfUI.uf.target.combopoints:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
      for point=1, 5 do
        pfUI.uf.target["combopoint" .. point]:SetFrameStrata("HIGH")
        pfUI.uf.target["combopoint" .. point]:SetWidth(12)
        pfUI.uf.target["combopoint" .. point]:SetHeight(12)
        pfUI.uf.target["combopoint" .. point]:SetBackdrop({
            bgFile = "Interface\\AddOns\\pfUI\\img\\bar", tile = true, tileSize = 8,
            edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
            insets = {left = 0, right = 0, top = 0, bottom = 0},
          })
        pfUI.uf.target["combopoint" .. point]:SetPoint("TOPLEFT", pfUI.uf.target, "TOPRIGHT", 3, -(point - 1) * 13)

        if point < 3 then
          pfUI.uf.target["combopoint" .. point]:SetBackdropColor(1, .3, .3, .75)
        elseif point < 4 then
          pfUI.uf.target["combopoint" .. point]:SetBackdropColor(1, 1, .3, .75)
        else
          pfUI.uf.target["combopoint" .. point]:SetBackdropColor(.3, 1, .3, .75)
        end
        pfUI.uf.target["combopoint" .. point]:Hide()
      end
    else
      local combopoints = GetComboPoints("target")
      for point=1, 5 do
        pfUI.uf.target["combopoint" .. point]:Hide()
      end
      for point=1, combopoints do
        pfUI.uf.target["combopoint" .. point]:Show()
      end
    end
  end)

pfUI.uf.target.buff = CreateFrame("Frame", nil)
pfUI.uf.target.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
pfUI.uf.target.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
pfUI.uf.target.buff:RegisterEvent("PLAYER_TARGET_CHANGED")
pfUI.uf.target.buff:RegisterEvent("UNIT_AURA")
pfUI.uf.target.buff:SetScript("OnEvent", function()
    pfUI.uf.target.buff.refreshBuffs()
  end)

pfUI.uf.target.buff.buffs = {}
for i=1, 16 do
  local id = i
  local row = 0
  if i <= 8 then row = 0 else row = 1 end

  pfUI.uf.target.buff.buffs[i] = CreateFrame("Button", "pfUITargetBuff" .. i, pfUI.uf.target)
  pfUI.uf.target.buff.buffs[i].stacks = pfUI.uf.target.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.target.buff.buffs[i])
  pfUI.uf.target.buff.buffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
  pfUI.uf.target.buff.buffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.target.buff.buffs[i], 2, -2)
  pfUI.uf.target.buff.buffs[i].stacks:SetJustifyH("LEFT")
  pfUI.uf.target.buff.buffs[i].stacks:SetShadowColor(0, 0, 0)
  pfUI.uf.target.buff.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
  pfUI.uf.target.buff.buffs[i].stacks:SetTextColor(1,1,.5)

  pfUI.uf.target.buff.buffs[i]:RegisterForClicks("RightButtonUp")
  pfUI.uf.target.buff.buffs[i]:ClearAllPoints()
  pfUI.uf.target.buff.buffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.target, "TOPLEFT", (i-8*row)*1 + (i-8*row)*pfUI.config.unitframes.buff_size - pfUI.config.unitframes.buff_size -1 , 1*row + pfUI.config.unitframes.buff_size*row +1)
  pfUI.uf.target.buff.buffs[i]:SetWidth(pfUI.config.unitframes.buff_size)
  pfUI.uf.target.buff.buffs[i]:SetHeight(pfUI.config.unitframes.buff_size)
  pfUI.uf.target.buff.buffs[i]:SetNormalTexture(nil)
  pfUI.uf.target.buff.buffs[i]:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
      GameTooltip:SetUnitBuff("target", id)
    end)

  pfUI.uf.target.buff.buffs[i]:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
end

pfUI.uf.target.buff.refreshBuffs = function ()
  for i=1, 16 do
    local texture, stacks = UnitBuff("target",i)
    pfUI.uf.target.buff.buffs[i]:SetBackdrop(
      { bgFile = texture, tile = false, tileSize = pfUI.config.unitframes.buff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })

    if texture then
      pfUI.uf.target.buff.buffs[i]:Show()
      if stacks > 1 then
        pfUI.uf.target.buff.buffs[i].stacks:SetText(stacks)
      else
        pfUI.uf.target.buff.buffs[i].stacks:SetText("")
      end
    else
      pfUI.uf.target.buff.buffs[i]:Hide()
    end
  end
end

pfUI.uf.target.debuff = CreateFrame("Frame", nil)
pfUI.uf.target.debuff:RegisterEvent("PLAYER_AURAS_CHANGED")
pfUI.uf.target.debuff:RegisterEvent("PLAYER_TARGET_CHANGED")
pfUI.uf.target.debuff:RegisterEvent("UNIT_AURA")
pfUI.uf.target.debuff:SetScript("OnEvent", function()
    pfUI.uf.target.debuff.refreshBuffs()
  end)

pfUI.uf.target.debuff.debuffs = {}
for i=1, 16 do
  local id = i
  pfUI.uf.target.debuff.debuffs[i] = CreateFrame("Button", "pfUITargetDebuff" .. i, pfUI.uf.target)
  pfUI.uf.target.debuff.debuffs[i].stacks = pfUI.uf.target.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.target.debuff.debuffs[i])
  pfUI.uf.target.debuff.debuffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
  pfUI.uf.target.debuff.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.target.debuff.debuffs[i], 2, -2)
  pfUI.uf.target.debuff.debuffs[i].stacks:SetJustifyH("LEFT")
  pfUI.uf.target.debuff.debuffs[i].stacks:SetShadowColor(0, 0, 0)
  pfUI.uf.target.debuff.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
  pfUI.uf.target.debuff.debuffs[i].stacks:SetTextColor(1,1,.5)
  pfUI.uf.target.debuff.debuffs[i]:RegisterForClicks("RightButtonUp")
  pfUI.uf.target.debuff.debuffs[i]:ClearAllPoints()

  local row = 0;
  local top = 0;
  if i > 8 then row = 1 end
  if pfUI.uf.target.buff.buffs[1]:IsShown() then top = top + 1 end
  if pfUI.uf.target.buff.buffs[9]:IsShown() then top = top + 1 end

  pfUI.uf.target.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.target, "TOPLEFT",
    (i-8*row)*1 + (i-8*row)*pfUI.config.unitframes.debuff_size - pfUI.config.unitframes.debuff_size -1 ,
    1*row + pfUI.config.unitframes.debuff_size*row +1 + (top*(pfUI.config.unitframes.debuff_size+1))
  )

  pfUI.uf.target.debuff.debuffs[i]:SetWidth(pfUI.config.unitframes.debuff_size)
  pfUI.uf.target.debuff.debuffs[i]:SetHeight(pfUI.config.unitframes.debuff_size)
  pfUI.uf.target.debuff.debuffs[i]:SetNormalTexture(nil)
  pfUI.uf.target.debuff.debuffs[i]:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
      GameTooltip:SetUnitDebuff("target", id)
    end)
  pfUI.uf.target.debuff.debuffs[i]:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  pfUI.uf.target.debuff.debuffs[i]:SetScript("OnClick", function()
      CancelPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
    end)
end

pfUI.uf.target.debuff.refreshBuffs = function ()
  for i=1, 16 do
    local row = 0;
    local top = 0;
    if i > 8 then row = 1 end
    if pfUI.uf.target.buff.buffs[1]:IsShown() then top = top + 1 end
    if pfUI.uf.target.buff.buffs[9]:IsShown() then top = top + 1 end

    pfUI.uf.target.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.target, "TOPLEFT",
      (i-8*row)*1 + (i-8*row)*pfUI.config.unitframes.debuff_size - pfUI.config.unitframes.debuff_size -1 ,
      1*row + pfUI.config.unitframes.debuff_size*row +1 + (top*(pfUI.config.unitframes.debuff_size+1))
    )
    local texture, stacks = UnitDebuff("target",i)
    pfUI.uf.target.debuff.debuffs[i]:SetBackdrop(
      { bgFile = texture, tile = false, tileSize = pfUI.config.unitframes.debuff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })

    local _,_,dtype = UnitDebuff("target", i)
    if dtype == "Magic" then
      pfUI.uf.target.debuff.debuffs[i]:SetBackdropBorderColor(0,1,1,1)
    elseif dtype == "Poison" then
      pfUI.uf.target.debuff.debuffs[i]:SetBackdropBorderColor(0,1,0,1)
    elseif dtype == "Curse" then
      pfUI.uf.target.debuff.debuffs[i]:SetBackdropBorderColor(1,0,1,1)
    else
      pfUI.uf.target.debuff.debuffs[i]:SetBackdropBorderColor(1,0,0,1)
    end

    if texture then
      pfUI.uf.target.debuff.debuffs[i]:Show()
      if stacks > 1 then
        pfUI.uf.target.debuff.debuffs[i].stacks:SetText(stacks)
      else
        pfUI.uf.target.debuff.debuffs[i].stacks:SetText("")
      end
    else
      pfUI.uf.target.debuff.debuffs[i]:Hide()
    end
  end
end
