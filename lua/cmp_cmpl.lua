local source = {}

-- TODO: not working, it was but failed.....
local create_job = function(self)
  local id = vim.fn.jobstart({ "cmpl-n" }, {
    on_stdout = function(_, data)
      -- print(data)
      for _, line in ipairs(data) do
        -- print(line)
        if line == "" and self.callback ~= nil then
          local complete_items = {}
          -- for _, item in ipairs(self.output_buffer) do
          --   local index = item:find("\t")
          --   if index ~= nil then
          --     local label = item:sub(0, index - 1)
          --     local detail = item:sub(index + 1, item:len())
          --     local kind = 12
          --     if string.find(detail, "^Executable") then
          --       kind = 3
          --     elseif string.find(label, "^-") then
          --       kind = 14
          --     end
          --     table.insert(complete_items, {
          --       label = label,
          --       kind = kind,
          --       detail = detail,
          --     })
          --   end
          -- end
          print("Print sprzed else")
          self.callback(complete_items)
          self.callback = nil
          self.output_buffer = {}
        else
          print("Print z else")
          -- print(line)
          table.insert(self.output_buffer, line)

          for _, item in ipairs(self.output_buffer) do
            local jitems = vim.fn.json_decode(item)
            if jitems ~= nil then
              for index, data in ipairs(jitems) do
                print(data)
                for key, value in pairs(data) do
                  print('\t', key, value)
                end
                -- for jitem in jitems do
                --   print("jitem")
                --   print(jitem)
                --   -- local index = item:find("\t")
                --   -- if index ~= nil then
                --   --   local label = item:sub(0, index - 1)
                --   --   local detail = item:sub(index + 1, item:len())
                --   --   local kind = 12
                --   --   if string.find(detail, "^Executable") then
                --   --     kind = 3
                --   --   elseif string.find(label, "^-") then
                --   --     kind = 14
                --   --   end
                --   --   table.insert(complete_items, {
                --   --     label = label,
                --   --     kind = kind,
                --   --     detail = detail,
                --   --   })
                --   -- end
                -- end
              end
            end
          end
        end
      end
    end,
  })
  local job_pid = vim.fn.jobpid(id)

  print("started job " .. id .. " on pid " .. job_pid)
  return id
end

source.new = function()
  local self = setmetatable({}, {
    __index = source,
  })
  self.output_buffer = {}
  self.cmpl_job = create_job(self)
  return self
end

source.reset = function(self)
  vim.fn.jobstop(self.cmpl_job)
  self.output_buffer = {}
  self.cmpl_job = create_job(self)
end

-- source.is_available = function()
--   return vim.bo.filetype == "cmpl"
-- end

source.get_debug_name = function()
  return "cmpl"
end

source.get_keyword_pattern = function(_)
  return [[.]]
end

source.build_input = function(word)
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

  local input = {
    Cword = word,
    Sources = sources,
    Comment = 'Complete current word Cword',
    Delay = '0ms',
  }
  local jinput = vim.fn.json_encode(input)
  print(jinput)
  return jinput .. "\n"
end


source.complete = function(self, params, callback)
  -- local word = string.sub(params.context.cursor_before_line, params.offset)
  local word = params.context.cursor_before_line
  if string.sub(word, -1) ~= "." then
    for k in string.gmatch(word, "%.?([%w_-]+)$") do
      word = k
    end
    -- print(word)

    self.output_buffer = {}
    vim.fn.chansend(self.cmpl_job, self.build_input(word))
    self.callback = callback
  end
end

return source
