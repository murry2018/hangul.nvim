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

-- Create the command as soon as the plugin is loaded (Zero-config)
vim.api.nvim_create_user_command('HangulToggle', function()
    require('hangul').toggle()
end, {})

-- Default keymap for ease of use
vim.api.nvim_set_keymap('i', '<C-g>', '<cmd>HangulToggle<CR>', { noremap = true, silent = true })
