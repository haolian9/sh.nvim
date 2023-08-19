local logging = require("infra.logging")
local strlib = require"infra.strlib"

local api = vim.api
local log = logging.newlogger("sh", "debug")

local ns = api.nvim_create_namespace("sh")

-- :w<cr>
--* cmdline_show, { { 0, "" } },   0, ":", "", 0, 1
--* cmdline_show, { { 0, "w" } },  1, ":", "", 0, 1
--* cmdline_hide, 1
-- :h <c-n>
--* cmdline_show, { { 0, "" } },   0, ":", "", 0, 1
--* cmdline_show, { { 0, "h" } },  1, ":", "", 0, 1
--* cmdline_show, { { 0, "h " } }, 2, ":", "", 0, 1
--* cmdline_pos,  2,     1
--* cmdline_hide, 1

local handlers = {}
do
  ---@alias Content {[1]: any, [2]: string}[] @(unknown, text)
  ---@alias MsgKind ""|"confirm"|"confirm_sub"|"emsg"|"echo"|"echomsg"|"echoerr"|"lua_error"|"rpc_error"|"return_prompt"|"quickfix"|"search_count"|"wmsg"

  --Triggered when the cmdline is displayed or changed.
  ---@param content Content
  ---@param pos integer @1-based
  ---@param char0 string @`:`, `/` ...
  function handlers.cmdline_show(content, pos, char0) end
  function handlers.cmdline_pos(pos) end
  function handlers.cmdline_hide(pos) end
  ---@param kind MsgKind
  ---@param content Content
  ---@param clear boolean
  function handlers.msg_show(kind, content, clear) end
  function handlers.msg_clear() end
  ---@param content Content
  function handlers.msg_showmode(content) end
  ---@param content Content
  function handlers.msg_showcmd(content) end
  function handlers.msg_ruler(content) end
  ---@param ents {[1]: MsgKind, [2]: Content}[]
  function handlers.msg_history_show(ents) end
  function handlers.msg_history_clear() end
end

vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
  --
  log.debug("%s, %s", event, { ... })
  -- assert(not strlib.startswith(event, 'cmdline_'))
  -- local h = handlers[event]
  -- if h ~= nil then h(...) end
end)

