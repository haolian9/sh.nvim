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
--* =expr
--* ui_attach(cmdline)
--* stdout, stderr

local Ephemeral = require("infra.Ephemeral")
local handyclosekeys = require("infra.handyclosekeys")
local highlighter = require("infra.highlighter")
local popupgeo = require("infra.popupgeo")
local prefer = require("infra.prefer")

local api = vim.api

local facts = {}
do
  local ns = api.nvim_create_namespace("sh.floatwin")
  local hi = highlighter(ns)
  if vim.go.background == "light" then
    hi("normalfloat", { fg = 7 })
    hi("winseparator", { fg = 0 })
  else
    hi("normalfloat", { fg = 15 })
    hi("winseparator", { fg = 7 })
  end
  facts.floatwin_ns = ns
end

local bufnr = Ephemeral({ buftype = "prompt" })

handyclosekeys(bufnr)

do
  ---@param ... string
  local function buffer_append_lines(...) api.nvim_buf_set_lines(bufnr, -2, -1, false, { ... }) end

  local bo = prefer.buf(bufnr)

  local function unmodified()
    vim.schedule(function() bo.modified = false end)
  end

  -- todo: put it in a standalone process?
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

  -- todo: "\x1b[31m>\x1b[39m "
  vim.fn.prompt_setprompt(bufnr, "> ")
  unmodified()

  vim.fn.prompt_setcallback(bufnr, function(cmd)
    if cmd == "" then
      -- user just pressed the <cr>
    else
      assert(coroutine.resume(interpreter))
      local _, ok, err = assert(coroutine.resume(interpreter, cmd))
      if not ok then buffer_append_lines(err) end
    end
    unmodified()
  end)
end

do
  local width, height, col, row = popupgeo.editor_central(0.8, 0.8)
  local winid = api.nvim_open_win(bufnr, true, { relative = "editor", border = "single", style = "minimal", row = row, col = col, width = width, height = height })
  api.nvim_win_set_hl_ns(winid, facts.floatwin_ns)
end

vim.cmd.startinsert()
