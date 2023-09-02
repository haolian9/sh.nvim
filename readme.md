a shell around nvim kernel

## status
* far from usable

## design/limits
* lua REPL with state
* make some EX cmds accessible
* make some sh/cli cmds accessible
* user defined cmds
* usable lua completion
* behave like a shell (define it)

## todo
* ~~avoid 'prompt buffer'~~
    * ~~weird `<c-w>`~~ `<s-c-w>`
    * ~~broken completion~~ `vim.lua_omnifunc`
    * ~~nonsense setprompt(bo.modified = false)~~ fixable
    * impossible multiple lines
* input history
    * normal j/k
* transient prompt based on inline extmark
* ~~take over builtin cmdline ui~~
