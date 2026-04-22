# hangul.nvim

Emacs Quail의 오토마타 구조를 기반으로 구현된 Neovim 전용 한글 입력 플러그인입니다.

## Quickstart

### 1. 설치
Neovim의 플러그인 디렉토리(예: `~/.config/nvim/lua/` 또는 플러그인 매니저 경로)에 복제합니다.

```bash
git clone https://github.com/murry2018/hangul.nvim.git
```

### 2. 설정 (`init.lua`)
`init.lua`에 다음 내용을 추가합니다.

```lua
require('hangul').setup()
```

### 3. 기본 조작
- **`<C-g>`**: 한글 입력 모드 켜기/끄기 (Insert 모드 전용)
- **`:HangulToggle`**: 한글 입력 모드 토글 명령

## 기본 설정 및 커스터마이징

### 단축키 변경
`setup()` 호출 시 기본 단축키가 `<C-g>`로 설정되지만, 원하는 키로 덮어씌울 수 있습니다.

```lua
-- 예: <C-\>로 단축키 변경
vim.api.nvim_set_keymap('i', '<C-\\>', '<cmd>HangulToggle<CR>', { noremap = true, silent = true })
```

### 상태줄(Statusline) 표시
`require('hangul').get_status()` 함수를 사용하여 현재 입력 모드("한" 또는 "")를 표시할 수 있습니다.

**순수 Neovim Statusline 예시:**

```lua
_G.my_statusline = function()
    local status = require('hangul').get_status()
    local hangul_display = status ~= "" and (" [" .. status .. "] ") or ""
    return "%f %m %=" .. hangul_display .. " %l,%c %p%%"
end
vim.opt.statusline = "%!v:lua.my_statusline()"
```

**lualine.nvim 예시:**

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
