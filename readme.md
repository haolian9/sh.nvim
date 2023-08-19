a shell around nvim kernel

## status
* far from usable

## design/limits
* shell like experience
* lua REPL with state
* EX cmd whitelist, BUT no state
* able to overwrite specific EX cmds
* sh/cli cmd whitelist, BUT no state
* take over builtin cmdline ui
* make use of lsp if possible
* make use of treesitter if possible

## todo
* avoid 'prompt buffer'
    * ~~weird <c-w>~~ fixable
    * broken completion
    * ~~nonsense setprompt(bo.modified = false)~~ fixable
    * impossible multiple lines
* use inline extmark to simulate transient prompt
