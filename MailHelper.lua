MailHelper = CreateFrame("Frame", nil, UIParent);
MailHelper_Config = MailHelper_Config or {};
MailHelper_DefaultConfig = {
  SendNames = {},
  isVisiblePanel = true,
}

MailHelper.api = getfenv();

local registerEvents = {
  "ADDON_LOADED",
  -- "PLAYER_LOGIN",
  -- "PLAYER_ENTERING_WORLD",
  "VARIABLES_LOADED",
  -- "MAIL_SHOW",
};

for _, event in registerEvents do
  MailHelper:RegisterEvent(event);
end

MailHelper:SetScript("OnEvent", function()
  if (event == "VARIABLES_LOADED") then
    MailHelper_Init();
  elseif (event == "ADDON_LOADED") then
    MailHelper_Skinning();
  end
end);


-- [ HookScript ]
-- Securely post-hooks a script handler.
-- 'f'          [frame]             the frame which needs a hook
-- 'script'     [string]            the handler to hook
-- 'func'       [function]          the function that should be added
function MailHelper_HookScript(f, script, func)
  local prev = f:GetScript(script);
  f:SetScript(script, function(a1,a2,a3,a4,a5,a6,a7,a8,a9)
    if (prev) then
      prev(a1,a2,a3,a4,a5,a6,a7,a8,a9);
    end

    func(a1,a2,a3,a4,a5,a6,a7,a8,a9);
  end)
end

function MailHelper_StringTrim(s)
  -- Регулярное выражение: ищет от первого непробельного символа до последнего
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end

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

function MailHelper_Init()
  MailHelper_InitVariables();
  MailHelper_RefreshPanel();
end

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

function MailHelper_SwitchShowMailHelperPanel()
  MailHelper_Config.isVisiblePanel = not MailHelper_Config.isVisiblePanel;
  MailHelper_RefreshPanel();
end

MailHelper.DraggingID = nil;
MailHelper.DraggingFrame = nil;

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
  MailHelper_RefreshList(); -- Финальное выравнивание
end

function MailHelper_CheckDragPosition(self)
  if (not MailHelper.isDragging) then
    MailHelper_StopDragging(self);
    return;
  end

  local scale = self:GetEffectiveScale();
  local cursorX, cursorY = GetCursorPosition();
  cursorY = cursorY / scale; -- Координата мыши в игровом пространстве

  -- Получаем верхнюю границу списка (первой строки)
  local listTop = MailHelperPanel_ScrollFrame_ScrollContent:GetTop(); 
  if (not listTop) then
    return;
  end

  local rowHeight = 22; -- Должно совпадать с высотой строки
  -- Вычисляем текущую позицию курсора относительно верха списка
  local relativeY = listTop - cursorY;
  -- Определяем, над каким индексом сейчас находится мышь
  local targetID = math.floor(relativeY / rowHeight) + 1;
  local maxItems = table.getn(MailHelper_Config.SendNames);

  -- Ограничиваем targetID рамками списка
  if (targetID < 1) then
    targetID = 1;
  elseif (targetID > maxItems) then
    targetID = maxItems;
  end

  -- Если курсор перешел на новую позицию в пределах таблицы
  -- AndrgitMacro_Print(targetID, MailHelper.DraggingID);
  if (targetID ~= MailHelper.DraggingID) then
    -- Меняем местами данные в таблице
    local temp = MailHelper_Config.SendNames[MailHelper.DraggingID];
    MailHelper_Config.SendNames[MailHelper.DraggingID] = MailHelper_Config.SendNames[targetID];
    MailHelper_Config.SendNames[targetID] = temp;
    
    -- local oldDragginRow = getglobal("MailHelper_ListRow"..MailHelper.DraggingID);
    -- local newDragginRow = getglobal("MailHelper_ListRow"..targetID);
    -- oldDragginRow:SetAlpha(1.0);
    -- newDragginRow:SetAlpha(0.5);

    -- Обновляем ID перетаскиваемого объекта, чтобы он не прыгал
    MailHelper.DraggingID = targetID;

    self:SetID(targetID); 
    -- Перерисовываем список (все строки, КРОМЕ той, что тащим)
    MailHelper_RefreshList(targetID); 
  end
end

function MyRemoveFromList(id)
  if MailHelper_Config.SendNames and MailHelper_Config.SendNames[id] then
    table.remove(MailHelper_Config.SendNames, id);
    MailHelper_RefreshList();
  end
end

function MyAddTextToList()
  -- Получаем текст из инпута (название EditBox из твоего XML)
  local text = MailHelperPanel_Input:GetText();
  local cleanText = MailHelper_StringTrim(text);
  -- Проверка на пустоту
  if (not cleanText or cleanText == "") then 
    -- Опционально: можно "тряхнуть" поле ввода или вывести сообщение
    UIErrorsFrame:AddMessage("Введите имя персонажа", 1.0, 0.1, 0.1, 1.0);
    return;
  end
  
  -- Инициализируем базу, если вдруг она пуста
  if (not MailHelper_Config.SendNames) then 
    MailHelper_Config.SendNames = {} 
  end

  -- Проверка на дубликаты (чтобы не добавлять одно и то же имя дважды)
  for _, name in ipairs(MailHelper_Config.SendNames) do
    if (string.lower(name) == string.lower(cleanText)) then
      UIErrorsFrame:AddMessage("Это имя уже есть в списке", 1.0, 1.0, 0.0, 1.0);
      return;
    end
  end
  
  -- Добавляем в таблицу
  table.insert(MailHelper_Config.SendNames, cleanText);
  -- Очищаем поле ввода
  MailHelperPanel_Input:SetText("");
  MailHelperPanel_Input:ClearFocus();
  
  -- ПЕРЕРИСОВЫВАЕМ список, чтобы новая строка появилась в скролле
  MailHelper_RefreshList();
end

function MailHelper_RefreshList(excludeID)
  if (not MailHelper_Config.SendNames) then
    return;
  end

  local rowHeight = 22 -- Должно совпадать с высотой в XML
  -- Сначала скрываем абсолютно все существующие строки
  local i = 1;
  local prefixRowFrame = "MailHelper_ListRow";

  while (getglobal(prefixRowFrame..i)) do
    getglobal(prefixRowFrame..i):Hide();
    i = i + 1;
  end

  -- Отрисовываем актуальный список
  for i, val in ipairs(MailHelper_Config.SendNames) do
    local row = getglobal(prefixRowFrame..i);
    if not row then
      row = CreateFrame("Button", prefixRowFrame..i, MailHelperPanel_ScrollFrame_ScrollContent, "MailHelper_ListRowTemplate");
    end
    
    row:SetID(i); -- Устанавливаем ID, чтобы OnClick знал, какой индекс удалять
    getglobal(row:GetName().."Text"):SetText(val);

    -- Не трогаем позицию строки, которую держит мышка
    if (i ~= excludeID) then
      row:ClearAllPoints();
      row:SetAlpha(1.0);
      row:SetPoint("TOPLEFT", 0, -(i-1) * rowHeight);
    else
      row:SetAlpha(0.5);
    end
    row:Show();
  end

  -- Обновляем скролл
  local count = table.getn(MailHelper_Config.SendNames);
  MailHelperPanel_ScrollFrame_ScrollContent:SetHeight(count * rowHeight);
  MailHelperPanel_ScrollFrame:UpdateScrollChildRect();
end

function MailHelper_ListRowClick()
  if (arg1 == "LeftButton" and IsShiftKeyDown()) then
    if (not MailHelper.isDragging) then
      MailHelper.isDragging = true;
      this:StartMoving();
      this:SetAlpha(0.5);
      MailHelper.DraggingID = this:GetID();

      -- Запоминаем текущий фрейм
      MailHelper.DraggingFrame = this;
      
      -- ВКЛЮЧАЕМ OnUpdate только на время перетаскивания
      MailHelper.DragUpdateFrame:Show(); 
    else 
      MailHelper.isDragging = false;
      MailHelper_StopDragging(this);
    end
  elseif (arg1 == "RightButton" and IsShiftKeyDown()) then
    -- Удаление: Правая кнопка + Alt
    MyRemoveFromList(this:GetID());
  elseif (arg1 == "LeftButton") then
    MailFrameTab2:Click();

    local txt = getglobal(this:GetName().."Text"):GetText();

    if (txt) then
      if (TurtleMail and TurtleMail.api) then
        -- Обработка из аддона TurtleMail
        TurtleMail.api.SendMailNameEditBox:_SetText(txt);
      else
        -- Обработка из нативного интерфейса
        SendMailNameEditBox:SetText(txt);
      end
      SendMailFrame_CanSend();
    end
  end
end

MailHelper.DragUpdateFrame = CreateFrame("Frame", "MailHelper_DragUpdateFrame", UIParent);
MailHelper.DragUpdateFrame:Hide(); -- По умолчанию выключен

MailHelper.DragUpdateFrame:SetScript("OnUpdate", function()
  -- Вызываем проверку только для того элемента, который сейчас тащат
  if MailHelper.DraggingID and MailHelper.DraggingFrame then
    MailHelper_CheckDragPosition(MailHelper.DraggingFrame);
  end
end);


function MailHelper_MainSlashCmd()
  MailHelper_ShowAddonHelpInfo();
end

---@return void
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