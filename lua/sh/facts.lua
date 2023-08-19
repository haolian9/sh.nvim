local M = {}

local fs = require("infra.fs")
local highlighter = require("infra.highlighter")

local api = vim.api

do
  local ns = api.nvim_create_namespace("sh.floatwin")
  local hi = highlighter(ns)
  if vim.go.background == "light" then
    hi("normalfloat", { fg = 7 })
    hi("winseparator", { fg = 0 })
    hi("endofbuffer", { fg = 15 })
  else
    hi("normalfloat", { fg = 15 })
    hi("winseparator", { fg = 7 })
    hi("endofbuffer", { fg = 0 })
  end
  M.floatwin_ns = ns
end

M.excmd_fpath = fs.joinpath(fs.resolve_plugin_root("sh", "facts.lua"), "excmds")

return M
