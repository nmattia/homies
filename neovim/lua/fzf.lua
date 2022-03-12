-- A picker for fzf functions
-- (should probably be an FZF dialog but no time to figure that out just now)

local M = {}

-- The results, where the keys are the potential answers from 'input'
local result = {
    a = { hint = "[a]ll files", f = function () vim.cmd(":Files") end },
    g = { hint = "[g]it ls-files", f = function () vim.cmd(":GFiles") end },
    b = { hint = "[b]uffers", f = function () vim.cmd(":Buffers") end },
    c = { hint = "[c]ommits", f = function () vim.cmd(":Commits") end },
    l = { hint = "[l]ines", f = function () vim.cmd(":Lines") end },
}

-- Build the prompt
local prompt = "Pick"
for k,v in pairs(result) do
    prompt = prompt.."\n"..k..": "..v.hint
end
prompt = prompt.."\n> "

local handle = function (v)

    -- No values were picked, just returned
    if(v == nil) then
        return
    end

    local action = result[v]

    if(action == nil) then
        print("\nNo action for value '"..v.."'")
        return
    end

    action.f()
end

M['fzf'] = function () vim.ui.input({ prompt = prompt}, handle) end

return M
