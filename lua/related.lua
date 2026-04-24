local M = {}

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function get_related_files(current_file)
  local related = {}
  local ext = "." .. vim.fn.fnamemodify(current_file, ":e")
  local base = vim.fn.fnamemodify(current_file, ":r")
  
  if not ext or not base then return related end

  if ext == ".cc" or ext == ".h" then
    local prefix = base
    prefix = base:gsub("_test$", ""):gsub("_main$", "")

    local potentials = {
      prefix .. ".cc",
      prefix .. ".h",
      prefix .. "_test.cc",
      prefix .. "_main.cc"
    }
    for _, p in ipairs(potentials) do
      if p ~= current_file then
        table.insert(related, p)
      end
    end
  elseif ext == ".py" then
    local prefix = base
    prefix = base:gsub("_test$", ""):gsub("_main$", "")

    local potentials = {
      prefix .. ".py",
      prefix .. "_test.py",
      prefix .. "_main.py"
    }
    for _, p in ipairs(potentials) do
      if p ~= current_file then
        table.insert(related, p)
      end
    end
  end

  -- Add BUILD file
  local dir = vim.fs.dirname(current_file)
  local build_file = vim.fs.joinpath(dir, "BUILD")
  if file_exists(build_file) then
    table.insert(related, build_file)
  end

  return related
end

local function jump_to_filename_in_build(build_path, target_filename)
  local pattern = [[\v['"]] .. target_filename .. [=[['"]]=]
  vim.fn.search(pattern)
end

function M.find(create_mode, target_type)
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then return end

  local related = get_related_files(current_file)
  local existing = {}
  
  for _, p in ipairs(related) do
    local matches_target = true
    if target_type then
      if target_type == 'test' then
        matches_target = p:match("_test%.cc$") or p:match("_test%.py$")
      elseif target_type == 'source' then
        matches_target = (p:match("%.cc$") and not p:match("_test%.cc$") and not p:match("_main%.cc$")) or
                         (p:match("%.py$") and not p:match("_test%.py$") and not p:match("_main%.py$")) or
                         p:match("%.h$")
      elseif target_type == 'main' then
        matches_target = p:match("_main%.cc$") or p:match("_main%.py$")
      elseif target_type == 'build' then
        matches_target = p:match("BUILD$")
      end
    end

    if matches_target and (create_mode or file_exists(p)) then
      table.insert(existing, p)
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
