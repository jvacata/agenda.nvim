A unified Neovim plugin for advanced personal productivity. Organize tasks, track projects with kanban boards, take notes, and maintain a daily journal — all inside Neovim.

!!! CURRENTLY IN DEVELOPMENT - CODE HIGHLY UNSTABLE !!!

# Installation

## Lazy.nvim

With default options:

```
    {
        "jvacata/agenda.nvim",
        config = true
    }
```

or with custom options, with defaults as following

```
    {
        "jvacata/agenda.nvim",
        opts = {
            workspace_path = '~/.local/share/agenda.nvim' -- path where all agenda data will be stored
        }
    },
```

# Usage

Run ```:Agenda``` to open main menu (not implemented yet)

```:Agenda tasks``` to open task manager


# Task manager

Keybindings:
```
<j> - Move down
<k> - Move up
<CR> - Edit task / task value
```
