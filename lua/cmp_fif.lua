local source = {}

local create_job = function(self)
  local id = vim.fn.jobstart({ "fif-n" }, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          local complete_items = {}
          local jitems = vim.fn.json_decode(line)
          if jitems ~= nil then
            for _, jitem in ipairs(jitems) do
              -- print(jitem)
              -- for key, value in pairs(jitem) do
              --   print('\t', key, value)
              -- end

              -- info
              -- word
              -- menu
              -- abbr
              -- icon
              -- kind
              -- print("jitem")
              -- print(jitem)

              local kind = 12
              if jitem.kind == "dict" then
                kind = 1
              elseif jitem.kind == "tag" then
                kind = 14
              end
              table.insert(complete_items, {
                label = jitem.word,
                kind = kind,
                detail = jitem.menu,
              })
            end
          end
          self.callback(complete_items)
        end
      end
    end,
  })
  local job_pid = vim.fn.jobpid(id)

  print("cmp-fif: started job " .. id .. " on pid " .. job_pid)
  return id
end

source.new = function()
  local self = setmetatable({}, {
    __index = source,
  })
  -- self.output_buffer = {}
  self.fif_job = create_job(self)
  return self
end

source.reset = function(self)
  vim.fn.jobstop(self.fif_job)
  -- self.output_buffer = {}
  self.fif_job = create_job(self)
end

-- source.is_available = function()
--   return vim.bo.filetype == "fif"
-- end

source.get_debug_name = function()
  return "fif"
end

source.get_keyword_pattern = function(_)
  return [[.]]
end

source.default_sources = function()
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

source.build_input = function(word)
  local get_sources = vim.g.fif_get_sources or source.default_sources
  local sources = get_sources()

  local input = {
    Cword = word,
    Sources = sources,
    Comment = 'Complete current word Cword',
    Delay = '0ms',
  }
  local jinput = vim.fn.json_encode(input)
  -- print(jinput)
  return jinput .. "\n"
end


source.complete = function(self, params, callback)
  local word = params.context.cursor_before_line
  if string.sub(word, -1) ~= "." then
    for k in string.gmatch(word, "%.?([%w_-]+)$") do
      word = k
    end

    vim.fn.chansend(self.fif_job, self.build_input(word))
    self.callback = callback
  end
end

return source
