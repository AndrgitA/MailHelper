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


-- String Trim Function
function MailHelper_StringTrim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"));
end