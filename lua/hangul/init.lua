-- Copyright (C) 2026 J. Lee <2clean8@naver.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local M = {}
local automata = require('hangul.automata')
local current_layout = nil
local is_enabled = false
local ignore_next_move = false

-- Get current status for statusline
function M.get_status()
    if is_enabled then
        return "한"
    else
        return ""
    end
end

function M.toggle()
    -- Ensure layout is loaded if setup() wasn't called manually
    if not current_layout then
        M.setup({})
    end
    
    is_enabled = not is_enabled
    if is_enabled then
        print("Hangul Input Enabled")
        automata.reset()
    else
        print("Hangul Input Disabled")
    end
    
    vim.api.nvim_exec_autocmds("User", { pattern = "HangulStatusUpdated" })
    vim.cmd('redrawstatus')
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

    -- Auto-reset logic
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
end

return M
