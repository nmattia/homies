-- A custom picker. This is different from vim.ui.select in that keys are
-- not necessarily numbers.
-- (should probably be an FZF dialog but no time to figure that out just now)
-- Usage: mk_picker{a = { hint = "Some hint", action = function () vim.cmd(":...") end } }

local M = {}

-- Build the prompt
local mk_prompt = function (options)
    local prompt = "Pick"
    for k,v in pairs(options) do
        prompt = prompt.."\n"..k..": "..v.hint
    end
    prompt = prompt.."\n> "
    return prompt
end

-- Prepare the handle function
local mk_handle = function (options)
    return function (v)
        -- No values were picked, just returned
        if(v == nil) then
            return
        end

        local option = options[v]

        if(option == nil) then
            print("\nNo action for value '"..v.."'")
            return
        end

        option.action()
    end
end

M['mk_picker'] = function (options)
    return function () vim.ui.input({ prompt = mk_prompt(options)}, mk_handle(options)) end
end

return M
