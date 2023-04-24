--design
--* state: variables
--* overwrite builtin vim.{fn,api}
--
--interpreter impl:
--* fn.luaeval
--* ii14/neorepl
--* ...?
--
--todo
--* ui_attach(cmdline)
--* stdout, stderr

local api = vim.api

local bufnr = api.nvim_create_buf(false, true)

---@param ... string
local function buffer_append_lines(...) api.nvim_buf_set_lines(bufnr, -2, -1, false, { ... }) end

local bo = vim.bo[bufnr]
bo.buftype = "prompt"
bo.bufhidden = "wipe"
-- todo: "\x1b[31m>\x1b[39m "
vim.fn.prompt_setprompt(bufnr, "> ")

do
  local interpreter = coroutine.create(function()
    while true do
      local chunk, load_err = loadstring(coroutine.yield())
      if chunk then
        coroutine.yield(pcall(chunk))
      else
        coroutine.yield(false, load_err)
      end
    end
  end)
  vim.fn.prompt_setcallback(bufnr, function(cmd)
    assert(coroutine.resume(interpreter))
    local _, ok, err = assert(coroutine.resume(interpreter, cmd))
    if not ok then buffer_append_lines(err) end
    -- the schedule magic is necessary here
    vim.schedule(function() bo.modified = false end)
  end)
end

local win_id
do
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor(vim.o.columns * 0.1)
  local row = math.floor(vim.o.lines * 0.1)
  win_id = api.nvim_open_win(bufnr, true, { relative = "editor", row = row, col = col, width = width, height = height, style = "minimal" })
end

vim.cmd.startinsert()
