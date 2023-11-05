<!-- cSpell:ignore nvim -->

# `cmp-fif` Find in files

Completion source for github.com/hrsh7th/nvim-cmp

## Usage

```lua
require("packer").use({ "hc2h3o2/cmp-fif" })

cmp.setup({
  sources = cmp.config.sources({
    { name = 'fif' }
  })
})
```

## Sample sources function override

```
function fif_get_sources()
  local sources = {}
  local tags = table.concat(vim.opt.tags:get(), ',')
  local dicts = table.concat(vim.opt.dictionary:get(), ',')
  if dicts ~= "" then
    table.insert(sources, {
      limit = 50,
      type = 'dict',
      icon = '◫',
      files = dicts,
    })
  end
  if tags ~= "" then
    table.insert(sources, {
      limit = 50,
      type = 'tags',
      icon = '⌘',
      files = tags
    })
  end
  return sources
end

vim.g.fif_get_sources = fif_get_sources
vim.g.fif_command = {"fif-n", "--complete"}
```
