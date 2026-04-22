local M = {}
local automata = require('hangul.automata')
local current_layout = nil
local is_enabled = false
local ignore_next_move = false -- Flag to distinguish plugin input from manual moves

function M.toggle()
    is_enabled = not is_enabled
    if is_enabled then
        print("Hangul Input Enabled")
        automata.reset()
    else
        print("Hangul Input Disabled")
    end
end

function M.setup(opts)
    opts = opts or {}
    local layout_name = opts.layout or "dubeolsik"
    current_layout = require('hangul.layouts.' .. layout_name)

    _G.hangul_process = function(key)
        if not is_enabled then return key end
        
        local key_index = current_layout.keys[key]
        if not key_index then
            automata.reset()
            return key
        end

        ignore_next_move = true
        local res, backspace = automata.process_key(key_index, current_layout)
        if backspace then
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true) .. res
        end
        return res
    end

    _G.hangul_backspace = function()
        if not is_enabled then
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
        end
        
        ignore_next_move = true
        local res = automata.process_backspace(current_layout)
        if res and res ~= "" then
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true) .. res
        else
            automata.reset()
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
        end
    end

    -- Map keys a-z, A-Z
    local letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i = 1, #letters do
        local char = letters:sub(i, i)
        vim.api.nvim_set_keymap('i', char, "v:lua.hangul_process('" .. char .. "')", { expr = true, noremap = true })
    end

    -- Map Backspace
    vim.api.nvim_set_keymap('i', '<BS>', "v:lua.hangul_backspace()", { expr = true, noremap = true })

    -- Auto-reset logic: If cursor moves by something other than our hangul_process, reset state.
    vim.api.nvim_create_autocmd({"CursorMovedI", "InsertLeave"}, {
        callback = function()
            if not is_enabled then return end
            
            if ignore_next_move then
                ignore_next_move = false
                return
            end
            automata.reset()
        end
    })
    
    vim.api.nvim_create_user_command('HangulToggle', M.toggle, {})
    vim.api.nvim_set_keymap('i', '<C-g>', '<cmd>HangulToggle<CR>', { noremap = true, silent = true })
end

return M
