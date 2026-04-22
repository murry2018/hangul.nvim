-- Copyright (C) 2026 J. Lee <2clean8@naver.com>

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local M = {}

-- Hangul Jamo Index (U+3131: 1)
local hangul2_keymap = {
    17, 48, 26, 23, 7, 9, 30, 39, 33, 35, 31, 51, 49, 44, 32, 36, 18, 1, 4, 21, 37, 29, 24, 28, 43, 27
}

M.keys = {}
local letters = "abcdefghijklmnopqrstuvwxyz"
for i = 1, #letters do
    local char = letters:sub(i, i)
    M.keys[char] = hangul2_keymap[i]
end

-- Double consonants/vowels for Shift keys (Indivisible units in Dubeolsik)
local shift_map = {
    Q = 18, -- ㅂ -> ㅃ (19)
    W = 24, -- ㅈ -> ㅉ (25)
    E = 7,  -- ㄷ -> ㄸ (8)
    R = 1,  -- ㄱ -> ㄲ (2)
    T = 21, -- ㅅ -> ㅆ (22)
    O = 33, -- ㅐ -> ㅒ (34)
    P = 37, -- ㅔ -> ㅖ (38)
}

for key, base_index in pairs(shift_map) do
    M.keys[key] = base_index + 1
end

local upper_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
for i = 1, #upper_letters do
    local char = upper_letters:sub(i, i)
    if not M.keys[char] then
        M.keys[char] = hangul2_keymap[i]
    end
end

-- Double Jamo combinations
-- NOTE: We REMOVED self-combinations like [1]+[1]=[2] (ㄱ+ㄱ=ㄲ) 
-- to ensure they are treated as single units and only input via Shift.
M.combinations = {
    cho = {}, -- Dubeolsik doesn't combine Choseong
    jung = {
        [39] = { [31] = 40, [32] = 41, [51] = 42 }, -- ㅗ + ㅏ = ㅘ, ㅐ = ㅙ, ㅣ = ㅚ
        [44] = { [35] = 45, [36] = 46, [51] = 47 }, -- ㅜ + ㅓ = ㅝ, ㅔ = ㅞ, ㅣ = ㅟ
        [49] = { [51] = 50 },                       -- ㅡ + ㅣ = ㅢ
    },
    jong = {
        [1] = { [21] = 3 },                         -- ㄱ + ㅅ = ㄳ
        [4] = { [24] = 5, [30] = 6 },               -- ㄴ + ㅈ = ㄵ, ㅎ = ㄶ
        [9] = { [1] = 10, [17] = 11, [18] = 12, [21] = 13, [28] = 14, [29] = 15, [30] = 16 },
        -- ㄹ + ㄱ = ㄺ, ㅁ = ㄻ, ㅂ = ㄼ, ㅅ = ㄽ, ㅌ = ㄾ, ㅍ = ㄿ, ㅎ = ㅀ
        [18] = { [21] = 20 },                       -- ㅂ + ㅅ = ㅄ
    }
}

function M.get_jamo_type(index)
    if index >= 1 and index <= 30 then
        return "consonant"
    elseif index >= 31 and index <= 51 then
        return "vowel"
    end
    return nil
end

return M
