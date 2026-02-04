MailHelper = CreateFrame("Frame", nil, UIParent);
MailHelper_Config = MailHelper_Config or {};
MailHelper_DefaultConfig = {
  SendNames = {},
  isVisiblePanel = true,
}

MailHelper.api = getfenv();
MailHelper.RowHeight = 25;

-- ID (Index) Dragging Frame
MailHelper.DraggingID = nil;
MailHelper.DraggingFrame = nil;

-- Hidden frame only for logical when we start dragging with script OnUpdate.
MailHelper.DragUpdateFrame = CreateFrame("Frame", "MailHelper_DragUpdateFrame", UIParent);
MailHelper.DragUpdateFrame:Hide();

-- List Frame Events
local registerEvents = {
  "ADDON_LOADED",
  "VARIABLES_LOADED",
};

-- Registration Frame Events
for _, event in registerEvents do
  MailHelper:RegisterEvent(event);
end

-- Frame Events Handler
MailHelper:SetScript("OnEvent", function()
  if (event == "VARIABLES_LOADED") then
    MailHelper_Init();
  elseif (event == "ADDON_LOADED") then
    MailHelper_Skinning();
  end
end);

-- Loading and set all variables for addon
function MailHelper_InitVariables()
  if (not MailHelper_Config) then
    MailHelper_Config = {};
  end

  for i, v in pairs(MailHelper_DefaultConfig) do
    if (not MailHelper_Config[i]) then
      MailHelper_Config[i] = v;
    end
  end
end

-- Initialization Addon
function MailHelper_Init()
  MailHelper_InitVariables();
  MailHelper_RefreshPanel();
end

-- Skinning intarface
function MailHelper_Skinning()
  local pfUIActive = (
    MailHelper.api.IsAddOnLoaded( "pfUI" ) and
    MailHelper.api.pfUI and
    MailHelper.api.pfUI.api
  );

  if (pfUIActive) then
    local pfUI = MailHelper.api.pfUI;
    -- background panel 
    pfUI.api.CreateBackdrop(MailHelperPanel);
    
    local br, bg, bb, ba = pfUI.api.GetStringColor(pfUI_config.appearance.border.background);
    
    -- Scroll
    if (not MailHelperPanel_ScrollFrame.backdrop) then
      pfUI.api.CreateBackdrop(MailHelperPanel_ScrollFrame);
      MailHelperPanel_ScrollFrame.backdrop:SetPoint("TOPLEFT", MailHelperPanel_ScrollFrame, "TOPLEFT", -1, 5);
      MailHelperPanel_ScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", MailHelperPanel_ScrollFrame, "BOTTOMRIGHT", 25, -5);
      MailHelperPanel_ScrollFrame.backdrop:SetBackdropColor(br, bg, bb, 1);
      pfUI.api.SkinArrowButton(MailHelperPanel_ScrollFrameScrollUpButton, "up");
      pfUI.api.SkinArrowButton(MailHelperPanel_ScrollFrameScrollDownButton, "down");
    end

    -- Add button
    pfUI.api.SkinButton(MailHelperPanel_AddButton);
    
    -- Input
    pfUI.api.StripTextures(MailHelperPanel_Input, true, "BACKGROUND");
    pfUI.api.CreateBackdrop(MailHelperPanel_Input);
    MailHelperPanel_Input:SetTextColor(.9,1,.8,1);

    -- MailHelper Button
    pfUI.api.SkinButton(MailHelper_SwitchShowButton);
  end
end

function MailHelper_RefreshPanel()
  if (MailHelper_Config.isVisiblePanel) then
    MailHelperPanel:Show();
  else
    MailHelperPanel:Hide();
  end
end

-- Handler for click on "MailHelper_SwitchShowButton"
function MailHelper_SwitchShowMailHelperPanel()
  MailHelper_Config.isVisiblePanel = not MailHelper_Config.isVisiblePanel;
  MailHelper_RefreshPanel();
end

function MailHelper_StopDragging(self)
  local target = self or MailHelper.DraggingFrame;

  MailHelper.isDragging = false;
  MailHelper.DragUpdateFrame:Hide();

  if (target) then
    target:StopMovingOrSizing();
    target:SetAlpha(1.0)
    target:UnlockHighlight();
    target:SetUserPlaced(false) 
    target:ClearAllPoints();
  end

  MailHelper.DraggingID = nil;
  MailHelper.DraggingFrame = nil;
  MailHelper_RefreshList();
end

function MailHelper_CheckDragPosition(self)
  if (not MailHelper.isDragging) then
    MailHelper_StopDragging(self);
    return;
  end

  local scale = self:GetEffectiveScale();
  local cursorX, cursorY = GetCursorPosition();
  cursorY = cursorY / scale; -- Cursor Position in Game

  -- Top position for scroll list. 
  local listTop = MailHelperPanel_ScrollFrame_ScrollContent:GetTop(); 
  if (not listTop) then
    return;
  end

  local rowHeight = MailHelper.RowHeight;
  
  -- current position cursor
  local relativeY = listTop - cursorY;
  -- current target index
  local targetID = math.floor(relativeY / rowHeight) + 1;
  local maxItems = table.getn(MailHelper_Config.SendNames);

  -- normalize targetID for current SendNames list
  if (targetID < 1) then
    targetID = 1;
  elseif (targetID > maxItems) then
    targetID = maxItems;
  end

  if (targetID ~= MailHelper.DraggingID) then
    -- Swap data rows
    local temp = MailHelper_Config.SendNames[MailHelper.DraggingID];
    MailHelper_Config.SendNames[MailHelper.DraggingID] = MailHelper_Config.SendNames[targetID];
    MailHelper_Config.SendNames[targetID] = temp;

    -- Update row ID
    MailHelper.DraggingID = targetID;

    self:SetID(targetID);
    -- update list without this target
    MailHelper_RefreshList(targetID); 
  end
end

-- Remore row from list
function MailHelper_RemoveFromList(id)
  if MailHelper_Config.SendNames and MailHelper_Config.SendNames[id] then
    table.remove(MailHelper_Config.SendNames, id);
    MailHelper_RefreshList();
  end
end

-- Add new line to list
function MailHelper_AddTextToList()
  local text = MailHelperPanel_Input:GetText();
  local cleanText = MailHelper_StringTrim(text);
  
  if (not cleanText or cleanText == "") then
    UIErrorsFrame:AddMessage("Введите имя персонажа", 1.0, 0.1, 0.1, 1.0);
    return;
  end
  
  if (not MailHelper_Config.SendNames) then 
    MailHelper_Config.SendNames = {} 
  end

  -- check for duplicate
  for _, name in ipairs(MailHelper_Config.SendNames) do
    if (string.lower(name) == string.lower(cleanText)) then
      UIErrorsFrame:AddMessage("Это имя уже есть в списке", 1.0, 1.0, 0.0, 1.0);
      return;
    end
  end
  
  table.insert(MailHelper_Config.SendNames, cleanText);
  -- Clean input after add
  MailHelperPanel_Input:SetText("");
  MailHelperPanel_Input:ClearFocus();
  
  MailHelper_RefreshList();
end

-- Main update function for list items
function MailHelper_RefreshList(excludeID)
  if (not MailHelper_Config.SendNames) then
    return;
  end

  local rowHeight = MailHelper.RowHeight
  
  -- Hide all current lines
  local i = 1;
  local prefixRowFrame = "MailHelper_ListRow";
  while (getglobal(prefixRowFrame..i)) do
    getglobal(prefixRowFrame..i):Hide();
    i = i + 1;
  end

  -- Show only rows for list SendNames
  for i, val in ipairs(MailHelper_Config.SendNames) do
    local row = getglobal(prefixRowFrame..i);
    if not row then
      row = CreateFrame("Button", prefixRowFrame..i, MailHelperPanel_ScrollFrame_ScrollContent, "MailHelper_ListRowTemplate");
    end
    
    row:SetID(i);
    getglobal(row:GetName().."Text"):SetText(val);

    if (i ~= excludeID) then
      row:ClearAllPoints();
      row:SetAlpha(1.0);
      row:SetPoint("TOPLEFT", 0, -(i-1) * rowHeight);
    else
      row:SetAlpha(0.5);
    end
    row:Show();
  end

  -- Update Scrolle Container
  local count = table.getn(MailHelper_Config.SendNames);
  MailHelperPanel_ScrollFrame_ScrollContent:SetHeight(count * rowHeight);
  MailHelperPanel_ScrollFrame:UpdateScrollChildRect();
end

-- Hanlder for clicks on row
function MailHelper_ListRowClick()
  if (arg1 == "LeftButton" and IsShiftKeyDown()) then
    -- LMB + Shift (Dragging logical code)
    if (not MailHelper.isDragging) then
      MailHelper.isDragging = true;
      this:StartMoving();
      this:SetAlpha(0.5);
      MailHelper.DraggingID = this:GetID();

      MailHelper.DraggingFrame = this;
      
      MailHelper.DragUpdateFrame:Show(); 
    else 
      MailHelper.isDragging = false;
      MailHelper_StopDragging(this);
    end
  elseif (arg1 == "RightButton" and IsShiftKeyDown()) then
    -- RMB + Shift (Delete line code)
    MailHelper_RemoveFromList(this:GetID());
  elseif (arg1 == "LeftButton") then
    -- LMB (Enter text to SendMailNameEditBox)
    -- Show Tab2 for Mail
    MailFrameTab2:Click();

    local txt = getglobal(this:GetName().."Text"):GetText();

    if (txt) then
      if (TurtleMail and TurtleMail.api) then
        -- Using MailTurtle api for SetText
        TurtleMail.api.SendMailNameEditBox:_SetText(txt);
      else
        -- Native SetText
        SendMailNameEditBox:SetText(txt);
      end
      -- Give games check signal
      SendMailFrame_CanSend();
    end
  end
end

-- Hanlder for OnUpdate when we still dragging
MailHelper.DragUpdateFrame:SetScript("OnUpdate", function()
  if MailHelper.DraggingID and MailHelper.DraggingFrame then
    MailHelper_CheckDragPosition(MailHelper.DraggingFrame);
  end
end);

-- Slash Command Hanlder
function MailHelper_MainSlashCmd()
  MailHelper_ShowAddonHelpInfo();
end

-- Show info about addon
function MailHelper_ShowAddonHelpInfo()
	local infoColor = "|c0000ff00";
	local textColor = "|caaffff44";
	DEFAULT_CHAT_FRAME:AddMessage("Addon `Mail Helper`. Makes it easier to send letters to characters.", 1, .7, 0);
	DEFAULT_CHAT_FRAME:AddMessage("Interface info:", 0, 1, 0);

	DEFAULT_CHAT_FRAME:AddMessage(infoColor.."Left Click on a row "..textColor.."- paste text in send mail input.");
	DEFAULT_CHAT_FRAME:AddMessage(infoColor.."Right Click + Shift on a row "..textColor.."- delete row from storage.");
	DEFAULT_CHAT_FRAME:AddMessage(infoColor.."Left Click + Shift on a row "..textColor.."- Start/Stop signal for moving item to any position.");
	DEFAULT_CHAT_FRAME:AddMessage(infoColor.."Click on Mail Helper Button "..textColor.."- Show/Hide Mail Helper Panel");
end

-- =====================
-- Slash Command
-- =====================
SLASH_MAILHELPER1 = "/mailhelper";
SlashCmdList["MAILHELPER"] = MailHelper_MainSlashCmd;