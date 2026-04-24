if vim.g.loaded_related_nvim ~= nil then
	return
end
vim.g.loaded_related_nvim = true

local function map(lhs, create, type, desc)
	vim.keymap.set("n", lhs, function()
		require("related").find(create, type)
	end, { desc = desc, silent = true })
end

map("<Leader>r", false, nil, "Find related files")
map("<Leader>R", true, nil, "Create/Navigate related files")
map("<Leader>rt", false, "test", "Find related test")
map("<Leader>rT", true, "test", "Create related test")
map("<Leader>rr", false, "source", "Find related source")
map("<Leader>rR", true, "source", "Create related source")
map("<Leader>rm", false, "main", "Find related main")
map("<Leader>rM", true, "main", "Create related main")
map("<Leader>rb", false, "build", "Find related BUILD")
map("<Leader>rB", true, "build", "Create related BUILD")
