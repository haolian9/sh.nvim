--design
--* state: variables
--* overwrite builtin vim.{fn,api}
--
--interpreter impl:
--* fn.luaeval
--* ii14/neorepl
--* ...?

local api = vim.api

local bufnr = api.nvim_create_buf(false, true)

---@param ... string
local function buffer_append_lines(...) api.nvim_buf_set_lines(bufnr, -2, -1, false, { ... }) end

local bo = vim.bo[bufnr]
bo.buftype = "prompt"
bo.bufhidden = "wipe"
-- todo: "\x1b[31m>\x1b[39m "
vim.fn.prompt_setprompt(bufnr, "> ")

vim.fn.prompt_setcallback(bufnr, function(cmd)
  buffer_append_lines(cmd)
  -- the schedule magic is necessary here
  vim.schedule(function() bo.modified = false end)
end)

local win_id = api.nvim_open_win(bufnr, true, {
  relative = "editor",
  row = 3,
  col = 3,
  width = math.floor(vim.o.columns * 0.8),
  height = math.floor(vim.o.lines * 0.6),
  style = "minimal",
})
vim.cmd.startinsert()
