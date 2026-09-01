-- Neovim ships NO ftplugin for turtle (detect.ttl knows the filetype; no
-- ftplugin/turtle.* anywhere in its runtime), so 'commentstring' stays the
-- global "" and the builtin gcc/gc operator no-ops with "Option
-- 'commentstring' is empty". Commenting is not an LSP capability — vim._comment
-- reads these two options, nothing else. Lives in after/ so the thin image's
-- existing `COPY after` ships it; a new top-level ftplugin/ dir would need its
-- own COPY line or silently miss the image (the icons.lua lesson).
vim.bo.commentstring = "# %s"
-- ":#" alone: Turtle's one comment form is # to end of line. The global
-- default's C/mail leaders (://, :%, n:>) are gq noise here.
vim.bo.comments = ":#"
