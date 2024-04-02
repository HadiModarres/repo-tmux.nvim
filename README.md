# repo-tmux.nvim

Work effectively with multiple git repositories in Neovim by attaching to tmux sessions.

## Problem

You find yourself jumping between many different git repositories and need persistent terminals for each repository.
You dedicate tmux sessions to each repository and launch Neovim from inside tmux sessions.

<b>The issues with this setup are</b>:

- You find yourself having too many Neovim instances open across different tmux sessions. This can cause using a lot of memory, especially
  when you use language servers.

- Jumping between tmux sessions to read code for other repositories is tiring.

## Solution

This plugin provides a way to access the tmux session for each repository from Neovim. So you only need to have one Neovim instance open.

## Requirements

tmux is required.

## Installation

- install using [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use "HadiModarres/repo-tmux.nvim"
```

- install using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "HadiModarres/repo-tmux.nvim",
}
```

## Usage

- Open Neovim in parent folder of your git repositories.

  - ParentFolder/
    - repository-1/
    - repository-2/
    - repository-3/

<br/>

```shell
cd ParentFolder && nvim .
```

- Make sure you use `set autochdir`, this causes many plugins such as lazygit.nvim to detect which git repository you're currently in.

- Open any buffer in one of the repositories and then run `RepoTmuxOpen` to attach to the tmux session for that repo. If a session does not exist it will be created.

- `RepoTmuxClose`: Close window
