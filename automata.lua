local M = {}

-- Unicode constants
local SBase = 0xAC00
local VCount = 21
local TCount = 28

-- Jamo mapping (Compatibility Jamo U+3131 to Lead/Vowel/Tail indices)
local compat_to_lead = {
    [1]=0, [2]=1, [4]=2, [7]=3, [8]=4, [9]=5, [17]=6, [18]=7, [19]=8, [21]=9, [22]=10, [23]=11, [24]=12, [25]=13, [26]=14, [27]=15, [28]=16, [29]=17, [30]=18
}
local compat_to_vowel = {
    [31]=0, [32]=1, [33]=2, [34]=3, [35]=4, [36]=5, [37]=6, [38]=7, [39]=8, [40]=9, [41]=10, [42]=11, [43]=12, [44]=13, [45]=14, [46]=15, [47]=16, [48]=17, [49]=18, [50]=19, [51]=20
}
-- Corrected Jongseong mapping
local compat_to_tail = {
    [1]=1, [2]=2, [3]=3, [4]=4, [5]=5, [6]=6, [7]=7, [9]=8, [10]=9, [11]=10, [12]=11, [13]=12, [14]=13, [15]=14, [16]=15, [17]=16, [18]=17, [20]=18, [21]=19, [22]=20, [23]=21, [24]=22, [26]=23, [27]=24, [28]=25, [29]=26, [30]=27
}

function M.compose(cho, jung, jong)
    if not cho or not jung then return nil end
    local l = compat_to_lead[cho]
    local v = compat_to_vowel[jung]
    local t = jong and compat_to_tail[jong] or 0
    if not l or not v then return nil end
    local code = SBase + (l * VCount + v) * TCount + t
    return vim.fn.nr2char(code)
end

function M.get_jamo(index)
    return vim.fn.nr2char(0x3130 + index)
end

-- Automaton state
local state = {
    cho = nil,
    jung = nil,
    jong = nil,
}

function M.reset()
    state.cho = nil
    state.jung = nil
    state.jong = nil
end

function M.process_backspace(layout)
    if state.jong then
        -- Handle double jong split
        local split_jong = nil
        for first, second_map in pairs(layout.combinations.jong) do
            for _, result in pairs(second_map) do
                if result == state.jong then
                    split_jong = first
                    break
                end
            end
            if split_jong then break end
        end
        state.jong = split_jong
        return M.compose(state.cho, state.jung, state.jong) or M.compose(state.cho, state.jung)
    elseif state.jung then
        -- Handle double jung split
        local split_jung = nil
        for first, second_map in pairs(layout.combinations.jung) do
            for _, result in pairs(second_map) do
                if result == state.jung then
                    split_jung = first
                    break
                end
            end
            if split_jung then break end
        end
        state.jung = split_jung
        if state.cho then
            return M.compose(state.cho, state.jung) or M.get_jamo(state.cho)
        else
            return state.jung and M.get_jamo(state.jung) or ""
        end
    elseif state.cho then
        -- Handle double cho split
        local split_cho = nil
        for first, second_map in pairs(layout.combinations.cho) do
            for _, result in pairs(second_map) do
                if result == state.cho then
                    split_cho = first
                    break
                end
            end
            if split_cho then break end
        end
        state.cho = split_cho
        return state.cho and M.get_jamo(state.cho) or ""
    end
    return nil
end

function M.process_key(key_index, layout)
    local type = layout.get_jamo_type(key_index)
    local res = ""
    local backspace = false

    if type == "consonant" then
        if state.jong then
            local next_jong = layout.combinations.jong[state.jong] and layout.combinations.jong[state.jong][key_index]
            if next_jong then
                state.jong = next_jong
                res = M.compose(state.cho, state.jung, state.jong)
                backspace = true
            else
                res = M.get_jamo(key_index)
                state.cho = key_index
                state.jung = nil
                state.jong = nil
            end
        elseif state.jung then
            if compat_to_tail[key_index] then
                state.jong = key_index
                res = M.compose(state.cho, state.jung, state.jong)
                backspace = true
            else
                res = M.get_jamo(key_index)
                state.cho = key_index
                state.jung = nil
                state.jong = nil
            end
        elseif state.cho then
            local next_cho = layout.combinations.cho[state.cho] and layout.combinations.cho[state.cho][key_index]
            if next_cho then
                state.cho = next_cho
                res = M.get_jamo(state.cho)
                backspace = true
            else
                res = M.get_jamo(key_index)
                state.cho = key_index
            end
        else
            state.cho = key_index
            res = M.get_jamo(key_index)
        end
    elseif type == "vowel" then
        if state.jong then
            local prev_jong = state.jong
            local new_cho = nil
            local split_jong = nil

            for first, second_map in pairs(layout.combinations.jong) do
                for second, result in pairs(second_map) do
                    if result == prev_jong then
                        split_jong = first
                        new_cho = second
                        break
                    end
                end
                if new_cho then break end
            end

            if new_cho then
                local prev_char = M.compose(state.cho, state.jung, split_jong)
                state.cho = new_cho
                state.jung = key_index
                state.jong = nil
                res = prev_char .. M.compose(state.cho, state.jung)
                backspace = true
            else
                local prev_char = M.compose(state.cho, state.jung)
                state.cho = prev_jong
                state.jung = key_index
                state.jong = nil
                res = prev_char .. M.compose(state.cho, state.jung)
                backspace = true
            end
        elseif state.jung then
            local next_jung = layout.combinations.jung[state.jung] and layout.combinations.jung[state.jung][key_index]
            if next_jung then
                state.jung = next_jung
                if state.cho then
                    res = M.compose(state.cho, state.jung)
                else
                    res = M.get_jamo(state.jung)
                end
                backspace = true
            else
                res = M.get_jamo(key_index)
                state.cho = nil
                state.jung = key_index
                state.jong = nil
            end
        elseif state.cho then
            state.jung = key_index
            res = M.compose(state.cho, state.jung)
            backspace = true
        else
            state.jung = key_index
            res = M.get_jamo(key_index)
        end
    end

    return res, backspace
end

return M
