<!-- cSpell:ignore nvim -->

# `cmp-fif`

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
