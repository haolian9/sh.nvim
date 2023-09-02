--design choices
--* state: variables
--* overwrite builtin vim.{fn,api}
--* interpreters: vimscript, lua, shell
--* no ui_attach(cmdline|messages)
--* return-code: boolean
--* no distiguishing between stdout and stderr
--
--todo: support colored prompt? "\x1b[31m>\x1b[39m "?
--todo: :clear
--todo: history
--

local Augroup = require("infra.Augroup")
local Ephemeral = require("infra.Ephemeral")
local ex = require("infra.ex")
local bufmap = require("infra.keymap.buffer")
local prefer = require("infra.prefer")
local rifts = require("infra.rifts")

local Interpreter = require("sh.Interpreter")

local api = vim.api

local new_buf
do
  ---@param bufnr integer
  ---@param lines string[]
  local function append_lines(bufnr, lines)
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

  function new_buf()
    local bufnr = Ephemeral({ buftype = "prompt", bufhidden = "hide", handyclose = true, name = "sh://" })

    do
      local bm = bufmap.wraps(bufnr)
      --make <c-w> normal
      bm.i("<c-w>", "<s-c-w>")
      --completion
      prefer.bo(bufnr, "omnifunc", "v:lua.vim.lua_omnifunc")
      bm.i("<c-n>", "<C-x><C-o>")
      bm.i(".", [[.<c-x><c-o>]])
    end

    local function stay_clean() prefer.bo(bufnr, "modified", false) end

    local aug = Augroup.buf(bufnr, true)
    aug:repeats("bufhidden", { buffer = bufnr, callback = stay_clean })

    vim.fn.prompt_setcallback(bufnr, function(line)
      --just <cr>
      if line == "" then return stay_clean() end

      assert(coroutine.resume(interpreter))
      local _, ok, results = assert(coroutine.resume(interpreter, line))
      append_lines(bufnr, results)
      change_prompt(bufnr, ok)
      vim.schedule(stay_clean)
    end)

    change_prompt(bufnr, true)
    stay_clean()

    return bufnr
  end
end

local bufnr

return function()
  if bufnr == nil then bufnr = new_buf() end
  assert(api.nvim_buf_is_valid(bufnr))

  local winid = rifts.open.fragment(bufnr, true, { relative = "editor", border = "single" }, { width = 0.8, height = 0.3, vertical = "bot" })
  prefer.wo(winid, "wrap", true)

  ex("startinsert")
end
