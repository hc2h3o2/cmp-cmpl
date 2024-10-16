local fif = {}
local registered = false
local config = require("cmp-fif.config")

local create_job = function(self)
	-- print('fif#create_job')
	local command = self.config.fif_command
	-- print(table.concat(command, " "))
	-- for _, value in pairs(config) do
	--   print(value)
	--   for k, v in pairs(value) do
	--     print(k)
	--     print(v)
	--   end
	-- end
	local id = vim.fn.jobstart(command, {
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				local complete_items = {}
				if line ~= "" then
					local jitems = vim.fn.json_decode(line)
					if jitems ~= nil then
						for _, jitem in ipairs(jitems) do
							-- print(jitem)
							-- for key, value in pairs(jitem) do
							-- 	print("\t", key, value)
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
							-- print("\tkind: ", kind)
						end
					end
				else
					-- print("\tempty line")
				end
				-- print(vim.inspect(complete_items))
				-- print("\t", #complete_items)
				self.callback(complete_items)
			end
		end,
	})
	local job_pid = vim.fn.jobpid(id)

	vim.notify(table.concat(config.fif_command, " ") .. ":" .. id .. ":/tmp/fifn-" .. job_pid .. ".log'")
	return id
end

fif.setup = function(opts)
	if registered then
		return
	end
	registered = true

	local has_cmp, cmp = pcall(require, "cmp")

	if not has_cmp then
		return
	end

	local source = {}

	source.contains = function(table, element)
		for key, _ in pairs(table) do
			if key == element then
				return true
			end
		end
		return false
	end

	-- print('fif#setup')
	if source.contains(opts, "fif_command") then
		-- print('fif# passed opts contains fif_command')
		config.fif_command = opts.fif_command
	end

	source.new = function()
		local self = setmetatable({}, {
			__index = source,
		})
		self.config = config
		self.fif_job = create_job(self)
		return self
	end

	source.reset = function(_)
		local self = setmetatable({}, {
			__index = source,
		})
		vim.fn.jobstop(self.fif_job)
		self.config = config
		self.fif_job = create_job(self)
	end

	-- source.is_available = function()
	--   return vim.bo.filetype == "fif"
	-- end
	--
	-- TODO: VIM ignoruje ó przy uzupełnianiu (pewno keyword)

	source.get_debug_name = function()
		return "fif"
	end

	source.get_keyword_pattern = function(_)
		return [[.]]
	end

	source.default_limit = function()
		return 100
	end

	source.default_sources = function()
		local sources = {}
		local tags = table.concat(vim.opt.tags:get(), ",")
		local dicts = table.concat(vim.opt.dictionary:get(), ",")
		if dicts ~= "" then
			table.insert(sources, {
				limit = 50,
				type = "dict",
				icon = "◫",
				files = dicts,
			})
		end
		if tags ~= "" then
			table.insert(sources, {
				limit = 50,
				type = "tags",
				icon = "⌘",
				files = tags,
			})
		end
		return sources
	end

	source.build_input = function(word)
		local get_sources = vim.g.fif_get_sources or source.default_sources
		local get_limit = vim.g.fif_get_limit or source.default_limit
		local sources = get_sources()
		local limit = get_limit()
		-- for key, value in pairs(sources) do
		-- 	print(key)
		-- 	print(value)
		-- 	for k, v in pairs(value) do
		-- 		print(k)
		-- 		print(v)
		-- 	end
		-- end

		local input = {
			Limit = limit,
			Cword = word,
			Sources = sources,
			Comment = "Complete current word Cword",
			Delay = "0ms",
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

	cmp.register_source("fif", source.new())
end

return fif
