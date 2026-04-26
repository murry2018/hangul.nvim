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
local saved_is_enabled = false  -- CmdlineEnter 시 저장, CmdlineLeave 시 복원
local skip_reset_count = 0      -- <BS>+char 조합 시 CmdlineChanged 2회 발화 대응

function M.get_status()
    return is_enabled and "한" or ""
end

function M.toggle()
    if not current_layout then
        M.setup({})
    end

    is_enabled = not is_enabled
    if is_enabled then
        automata.reset()
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "HangulStatusUpdated" })
    vim.cmd('redrawstatus')
end

function M.setup(opts)
    opts = opts or {}
    local layout_name = opts.layout or "dubeolsik"
    current_layout = require('hangul.layouts.' .. layout_name)

    -- Insert mode globals
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

    -- Cmdline mode globals
    _G.hangul_cmdline_process = function(key)
        if not is_enabled then return key end

        local key_index = current_layout.keys[key]
        if not key_index then
            automata.reset()
            return key
        end

        local res, backspace = automata.process_key(key_index, current_layout)
        skip_reset_count = backspace and 2 or 1
        if backspace then
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true) .. res
        end
        return res
    end

    _G.hangul_cmdline_backspace = function()
        if not is_enabled then
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
        end

        local res = automata.process_backspace(current_layout)
        if res and res ~= "" then
            skip_reset_count = 2
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true) .. res
        else
            automata.reset()
            skip_reset_count = 0
            return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
        end
    end

    _G.hangul_cmdline_cursor_reset = function(key)
        automata.reset()
        return vim.api.nvim_replace_termcodes(key, true, true, true)
    end

    -- Insert mode keymaps
    local letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i = 1, #letters do
        local char = letters:sub(i, i)
        vim.api.nvim_set_keymap('i', char, "v:lua.hangul_process('" .. char .. "')", { expr = true, noremap = true })
    end
    vim.api.nvim_set_keymap('i', '<BS>', "v:lua.hangul_backspace()", { expr = true, noremap = true })

    -- Cmdline mode keymaps
    for i = 1, #letters do
        local char = letters:sub(i, i)
        vim.api.nvim_set_keymap('c', char, "v:lua.hangul_cmdline_process('" .. char .. "')", { expr = true, noremap = true })
    end
    vim.api.nvim_set_keymap('c', '<BS>', "v:lua.hangul_cmdline_backspace()", { expr = true, noremap = true })

    -- 커서 이동 시 오토마타 리셋 (CmdlineChanged는 커서 이동만으로 발화 안 함)
    for _, key in ipairs({ "<Left>", "<Right>", "<Home>", "<End>",
                           "<C-b>", "<C-e>", "<C-a>", "<Up>", "<Down>" }) do
        vim.api.nvim_set_keymap('c', key,
            "v:lua.hangul_cmdline_cursor_reset('" .. key .. "')",
            { expr = true, noremap = true })
    end

    -- Insert mode auto-reset
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

    -- Cmdline: 진입 시 영어로 전환(현재 상태 저장), 종료 시 복원
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        callback = function()
            saved_is_enabled = is_enabled
            is_enabled = false
            skip_reset_count = 0
            automata.reset()
            vim.cmd('redrawstatus')
        end
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
        callback = function()
            is_enabled = saved_is_enabled
            skip_reset_count = 0
            automata.reset()
            vim.cmd('redrawstatus')
        end
    })

    vim.api.nvim_create_autocmd("CmdlineChanged", {
        callback = function()
            if skip_reset_count > 0 then
                skip_reset_count = skip_reset_count - 1
                return
            end
            automata.reset()
        end
    })
end

return M
