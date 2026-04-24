local M = {}

local default_rules = {
	{
		exts = { ".cc", ".h" },
		prefix_strip = { "_test$", "_main$" },
		suffixes = {
			{ suffix = ".cc", type = "source" },
			{ suffix = ".h", type = "source" },
			{ suffix = "_test.cc", type = "test" },
			{ suffix = "_main.cc", type = "main" },
		},
	},
	{
		exts = { ".py" },
		prefix_strip = { "_test$", "_main$" },
		suffixes = {
			{ suffix = ".py", type = "source" },
			{ suffix = "_test.py", type = "test" },
			{ suffix = "_main.py", type = "main" },
		},
	},
}

local rules = {} -- Track registered rules

local function file_exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

local function get_related_files(current_file)
	local related = {}
	local ext = "." .. vim.fn.fnamemodify(current_file, ":e")
	local base = vim.fn.fnamemodify(current_file, ":r")

	if not ext or not base then
		return related
	end

	local rules_to_use = #rules > 0 and rules or default_rules

	for _, rule in ipairs(rules_to_use) do
		if vim.tbl_contains(rule.exts, ext) then
			local prefix = base
			for _, strip in ipairs(rule.prefix_strip or {}) do
				prefix = prefix:gsub(strip, "")
			end
			for _, item in ipairs(rule.suffixes) do
				local p = prefix .. item.suffix
				if p ~= current_file then
					table.insert(related, { path = p, type = item.type })
				end
			end
		end
	end

	-- Add BUILD file
	local dir = vim.fs.dirname(current_file)
	local build_file = vim.fs.joinpath(dir, "BUILD")
	if file_exists(build_file) then
		table.insert(related, { path = build_file, type = "build" })
	end

	return related
end

M.setup = function(opts)
	rules = opts.rules or {}
end

local function jump_to_filename_in_build(build_path, target_filename)
  local pattern = [[\v['"][^'"]*]] .. target_filename .. [=[['"]]=]
  vim.fn.search(pattern)
end

function M.find(create_mode, target_type)
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then return end

  local related = get_related_files(current_file)
  local existing = {}
  
  for _, item in ipairs(related) do
    local matches_target = true
    if target_type and item.type ~= target_type then
      matches_target = false
    end

    if matches_target and (create_mode or file_exists(item.path)) then
      table.insert(existing, item.path)
    end
  end

  if #existing == 0 then
    print("No related files found.")
    return
  end

  if #existing == 1 and (not create_mode or target_type) then
    vim.cmd("edit " .. vim.fn.fnameescape(existing[1]))
    if existing[1]:match("BUILD$") then
      local filename = vim.fs.basename(current_file)
      jump_to_filename_in_build(existing[1], filename)
    end
    return
  end

  -- Use native Vim menus (vim.ui.select)
  vim.ui.select(existing, {
    prompt = create_mode and "Create/Navigate Related Files:" or "Select Related File:",
    format_item = function(item)
      return vim.fs.basename(item)
    end,
  }, function(choice)
    if choice then
      vim.cmd("edit " .. vim.fn.fnameescape(choice))
      if choice:match("BUILD$") then
        local filename = vim.fs.basename(current_file)
        jump_to_filename_in_build(choice, filename)
      end
    end
  end)
end

M._get_related_files = get_related_files
return M
