# hangul.nvim

Emacs Quail의 오토마타 구조를 기반으로 구현된 Neovim 전용 한글 입력 플러그인입니다.

## 설치 및 설정

### lazy.nvim
```lua
{ "murry2018/hangul.nvim" }
```

### vim-plug
```vim
Plug 'murry2018/hangul.nvim'
```

## 사용법

- **`<C-g>`**: 한글 입력 모드 토글 (Insert 모드)
- **`:HangulToggle`**: 한글 입력 모드 토글 명령어

## 커스터마이징

### 단축키 변경
원하는 키로 직접 매핑하려면 다음과 같이 설정합니다.

```lua
-- 예: <C-\>로 변경
vim.keymap.set('i', '<C-\\>', '<cmd>HangulToggle<CR>', { silent = true })
```

### 상태줄(Statusline) 표시
`require('hangul').get_status()` 함수는 현재 입력 모드("한" 또는 "")를 반환합니다.

**Neovim Statusline 설정 예시:**

```lua
_G.my_statusline = function()
    local status = require('hangul').get_status()
    local mode = vim.api.nvim_get_mode().mode
    local file_name = vim.fn.expand("%:t")
    if file_name == "" then file_name = "[No Name]" end
    local modified = vim.bo.modified and " [+]" or ""
    
    local hangul_display = status ~= "" and (" [" .. status .. "] ") or ""
    
    return " " .. mode .. " | " .. file_name .. modified .. " %=" .. hangul_display .. " %l,%c %p%% "
end
vim.opt.statusline = "%!v:lua.my_statusline()"
```

**lualine.nvim 연동:**

```lua
require('lualine').setup {
  sections = {
    lualine_x = { 
      { function() return require('hangul').get_status() end },
      'filetype' 
    }
  }
}
```

## License
이 프로젝트는 GNU General Public License v3.0 (GPLv3) 하에 배포됩니다. Emacs의 `hangul.el` 로직을 기반으로 하고 있으므로 동일한 라이선스를 따릅니다. 자세한 내용은 [LICENSE](./LICENSE) 파일을 확인하세요.
