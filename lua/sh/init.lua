--design choices
--* state: variables
--* overwrite builtin vim.{fn,api}
--* interpreters: vimscript, lua, shell
--* no ui_attach(cmdline|messages)
--* return-code: boolean
--* no distiguishing between stdout and stderr
--
--todo: support colored prompt? "\x1b[31m>\x1b[39m "?
--todo: clear
--todo: <c-w>?
--

local bufrename = require("infra.bufrename")
local Ephemeral = require("infra.Ephemeral")
local handyclosekeys = require("infra.handyclosekeys")
local popupgeo = require("infra.popupgeo")
local prefer = require("infra.prefer")

local facts = require("sh.facts")
local Interpreter = require("sh.Interpreter")

local api = vim.api

local get_bufnr
do
  ---@param bufnr integer
  local function stay_clean(bufnr, scheduled)
    if scheduled then
      vim.schedule(function() prefer.bo(bufnr, "modified", false) end)
    else
      prefer.bo(bufnr, "modified", false)
    end
  end

  ---@param bufnr integer
  ---@param lines string|string[]
  local function extends(bufnr, lines)
    assert(lines ~= nil and type(lines) == "table")
    if #lines == 0 then return end
    api.nvim_buf_set_lines(bufnr, -2, -1, false, lines)
  end

  local change_prompt
  do
    local last
    ---@param ok boolean
    function change_prompt(bufnr, ok)
      local this = ok and "> " or "!> "
      if last == this then return end
      vim.fn.prompt_setprompt(bufnr, this)
      last = this
    end
  end

  local interpreter = Interpreter()

  local bufnr

  function get_bufnr()
    if bufnr ~= nil then return bufnr end

    bufnr = Ephemeral({ buftype = "prompt", bufhidden = "hide" })
    bufrename(bufnr, "sh://")
    handyclosekeys(bufnr)
    change_prompt(bufnr, true)

    api.nvim_create_autocmd("bufhidden", { buffer = bufnr, callback = function() stay_clean(bufnr) end })

    vim.fn.prompt_setcallback(bufnr, function(line)
      --just <cr>
      if line == "" then return stay_clean(bufnr, true) end

      assert(coroutine.resume(interpreter))
      local _, ok, results = assert(coroutine.resume(interpreter, line))
      extends(bufnr, results)
      change_prompt(bufnr, ok)
      stay_clean(bufnr, true)
    end)

    stay_clean(bufnr)

    return bufnr
  end
end

return function()
  local bufnr = get_bufnr()
  assert(api.nvim_buf_is_valid(bufnr))

  do
    local width, height, row, col = popupgeo.editor_central(0.8, 0.8)
    local winid = api.nvim_open_win(bufnr, true, { relative = "editor", border = "single", row = row, col = col, width = width, height = height })
    api.nvim_win_set_hl_ns(winid, facts.floatwin_ns)
  end

  vim.cmd.startinsert()
end
