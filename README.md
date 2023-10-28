<!-- cSpell:ignore nvim -->

# `cmp-cmpl`

Completion source for cmpl.com/hrsh7th/nvim-cmp).

## Usage

```lua
require("packer").use({ "akemrir/cmp-cmpl" })

cmp.setup({
  sources = cmp.config.sources({
    { name = 'cmpl' }
  })
})
```
