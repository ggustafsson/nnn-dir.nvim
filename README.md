# 📁 nnn-dir.nvim

![Screenshot](https://github.com/ggustafsson/Project-Assets/raw/master/nnn-dir.nvim/Screenshot.png)

## 🚨 Description

- `nvim` plugin that replaces builtin `netrw` with external file manager `nnn`.

- `nnn` is a real file manager that can be used outside of `nvim`. Learn once,
  use everywhere!

- Seamless `nvim` + `nnn` integration. Use commands `nvim`, `:edit`, `:split`,
  `:vsplit`, etc.

- Keeps `netrw`'s "netrw-gx" feature. Open up file/URL under cursor with `gx`
  keybinding.

- Supports `nnn`'s "cd on quit" feature. See
[nnn/wiki/Basic-use-cases#configure-cd-on-quit](https://github.com/jarun/nnn/wiki/Basic-use-cases#configure-cd-on-quit)

## 🌟 Project Goals

1. **Seamless integration** - E.g. use it with default commands.
2. **User-friendly** - E.g. move between splits with default keybindings.
3. **Minimal but feature complete** - E.g. implement "cd on quit", "gx", etc.
4. **Clean code/Stable use** - E.g. don't use `nvim` in a way it is not meant
   to be used.
5. **Low effort** - It should "just work" with low mental overhead.

These are the core goals that intertwine and leads to something unique and good
enough that the release of yet another plugin is warranted.

## 📦 Installation

Same procedure as for all other `nvim` plugins; Download and extract/git clone
`nnn-dir.nvim` at location `~/.local/share/nvim/site/pack/<X>/start/<Y>` (or
use a "package manager" if that is your thing).

Enable `nnn-dir` with the following inside of `~/.config/nvim/init.[lua|vim]`:

    [lua] require("nnn-dir").setup()
