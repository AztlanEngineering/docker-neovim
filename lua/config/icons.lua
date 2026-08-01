-- lua/config/icons.lua
-- [cozette-icons] Every glyph the file sidebar can emit, restricted to CozetteVector.
--
-- WHY: foot paints the terminal in CozetteVector; any codepoint Cozette lacks is
-- served by the `Symbols Nerd Font Mono` fontconfig fallback (df nix/modules/base.nix),
-- so one missing glyph switches font mid-line and the pixel look breaks. Every
-- codepoint below was checked against the INSTALLED cozette 1.30.0 font, not against
-- upstream's charmap — upstream lists glyphs nixpkgs' build does not ship (the Material
-- Design plane alone is 132 upstream vs 73 installed).
-- Escapes, not literals, so a review diff stays greppable (same call as df's waybar config).
--
-- HOW snacks resolves a sidebar icon (snacks/util/init.lua:135-164, picker/format.lua:42-67):
--   directory -> picker.opts.icons.files.dir / .dir_open   (devicons is never asked)
--   file      -> devicons.get_icon(<ABSOLUTE PATH>, ext, { default = false })
--                with ext = path:match("%.(%w+)$")
--                no hit -> picker.opts.icons.files.file
-- Two consequences shape this file:
--   1. devicons is queried with the FULL PATH, so its filename-keyed entries can never
--      match in the explorer; only EXTENSION keys reach it. Dotfiles still land, because
--      that regex yields ext="gitignore" for .gitignore. Bare names (Dockerfile, Makefile,
--      LICENSE, justfile) are unreachable by design and always show icons.files.file.
--   2. default=false bypasses devicons' own default_icon: the generic file glyph in the
--      sidebar is snacks' icons.files.file, not devicons'.
local M = {}

-- Named once so the swap table reads as intent rather than as hex.
-- Family in the comment: Cozette carries Seti-UI+Custom (57 glyphs), Devicons (70),
-- FontAwesome (170), Octicons (40), Font Logos (23), Material Design (73), Codicons (1).
local g = {
  folder = "\u{e5ff}", -- nf-custom-folder          Seti/Custom
  folder_open = "\u{e5fe}", -- nf-custom-folder_open     Seti/Custom
  -- Solid folders vs an OUTLINE document: at Cozette's real 13px cell that
  -- fill-vs-outline contrast is the only folder/file cue that survives (the
  -- outline-folder pair F114/F115 collapses into "small box" next to it).
  -- f0f6 is also devicons' own default_icon, so "unknown file" is one glyph
  -- editor-wide (sidebar fallback == lualine's unknown filetype).
  file = "\u{f0f6}", -- nf-fa-file_text_o         FontAwesome
  shell = "\u{e795}", -- nf-dev-terminal           Devicons
  config = "\u{e615}", -- nf-seti-config (gear)     Seti
  rust = "\u{e7a8}", -- nf-dev-rust               Devicons
  css = "\u{e749}", -- nf-dev-css3               Devicons
  image = "\u{e60d}", -- nf-seti-image             Seti
  code = "\u{e796}", -- nf-dev-code (</>)         Devicons
  make = "\u{e779}", -- nf-dev-makefile           Devicons
  python = "\u{e606}", -- nf-seti-python            Seti
  audio = "\u{f001}", -- nf-fa-music               FontAwesome
  film = "\u{f008}", -- nf-fa-film                FontAwesome
  lock = "\u{f023}", -- nf-fa-lock                FontAwesome
  typography = "\u{f031}", -- nf-fa-font                FontAwesome
  book = "\u{f02d}", -- nf-fa-book                FontAwesome
  list = "\u{f03a}", -- nf-fa-list_ul             FontAwesome
  key = "\u{f084}", -- nf-fa-key                 FontAwesome
  db = "\u{f1c0}", -- nf-fa-database            FontAwesome
  pdf = "\u{f1c1}", -- nf-fa-file_pdf_o          FontAwesome
  sheet = "\u{f1c3}", -- nf-fa-file_excel_o        FontAwesome
  git = "\u{f1d3}", -- nf-fa-git                 FontAwesome
  chip = "\u{f2db}", -- nf-fa-microchip           FontAwesome
  docker = "\u{f308}", -- nf-linux-docker           Font Logos
  archive = "\u{f410}", -- nf-oct-file_zip           Octicons
  graph = "\u{f816}", -- nf-mdi-sitemap            FontAwesome ext
  parens = "\u{f0172}", -- nf-md-code_parentheses    Material Design
}

-- devicons overrides. { key, glyph, donor }.
--   key   = EXTENSION as snacks derives it (see HOW above); the flat lookup table also
--           holds lowercased FILENAME keys, so "dockerfile"/"justfile" fix lualine too.
--   donor = entry whose color + DevIcon* highlight group is cloned. Defaults to the key.
--           Cloning instead of hardcoding hex keeps [nvim-theme]'s lossless contract:
--           no new colour is introduced, so tools/nvim-theme-check still diffs clean.
local swaps = {
  -- shell rc + scripts collapse onto the one terminal glyph (sh/zsh/fish already use it)
  { "bash", g.shell, "sh" },
  { "bashrc", g.shell, ".bashrc" },
  { "zshrc", g.shell, ".zshrc" },
  { "profile", g.shell, "sh" },
  -- everything that is "a settings file" gets the Seti gear (conf/ini/cfg already do)
  { "toml", g.config },
  { "yaml", g.config },
  { "yml", g.config },
  { "tf", g.config },
  { "hcl", g.config, "tf" },
  { "service", g.config, "conf" },
  { "rules", g.config, "conf" },
  { "plist", g.config, "conf" },
  { "editorconfig", g.config, ".editorconfig" },
  { ".editorconfig", g.config },
  -- plain prose files share the generic-file glyph; Cozette has nothing more specific
  { "txt", g.file },
  { "org", g.file },
  { "norg", g.file },
  { "log", g.list },
  -- language logos Cozette does carry
  { "rs", g.rust },
  { "css", g.css },
  { "xml", g.code },
  { "cmake", g.make },
  { "justfile", g.make, "makefile" },
  { "el", g.parens },
  { "scm", g.parens },
  { "ipynb", g.python },
  -- media
  { "svg", g.image },
  { "svgz", g.image },
  { "mp4", g.film },
  { "mkv", g.film },
  { "webm", g.film },
  { "tidal", g.audio, "mp3" }, -- [tidal-rig] .tidal is a livecoding score, not code
  -- data
  { "csv", g.sheet },
  { "tsv", g.sheet, "csv" },
  { "pdf", g.pdf },
  { "sparql", g.db, "sql" },
  { "rq", g.db, "sql" },
  { "graphql", g.graph },
  { "ttl", g.graph, "graphql" }, -- turtle/n-triples/json-ld: RDF is a node graph
  { "nt", g.graph, "graphql" },
  { "jsonld", g.graph, "graphql" },
  -- archives + locks
  { "tar", g.archive, "zip" },
  { "lock", g.lock },
  { "lockb", g.lock, "lock" },
  { "bun.lockb", g.lock, "lock" },
  -- crypto material
  { "asc", g.key },
  { "pem", g.key, "asc" },
  { "key", g.key, "asc" },
  { "crt", g.key, "asc" },
  { "gpg", g.key, "asc" },
  -- build output / binaries
  { "bin", g.chip },
  { "so", g.chip },
  { "o", g.chip },
  { "a", g.chip },
  { "wasm", g.chip },
  { "hex", g.chip },
  -- git metadata: reachable because snacks' regex reads .gitignore as ext "gitignore"
  { "gitignore", g.git, ".gitignore" },
  { "gitattributes", g.git, ".gitattributes" },
  { "gitmodules", g.git, ".gitmodules" },
  { "gitconfig", g.git, ".gitignore" },
  -- containers + docs (filename keys: lualine/statusline only, never the explorer)
  { "dockerfile", g.docker },
  { "containerfile", g.docker, "dockerfile" },
  { "tex", g.typography },
  { "bib", g.book },
  { "readme.md", "\u{f48a}", "md" },
}

--- Override table for `require("nvim-web-devicons").setup{ override = ... }`.
--- Must be built after the plugin is on the rtp: get_icons() is populated by the
--- module-level refresh_icons(), i.e. at require time, before setup() runs.
function M.devicons()
  local base = require("nvim-web-devicons").get_icons()
  local override = {}
  for _, s in ipairs(swaps) do
    local key, glyph, donor = s[1], s[2], s[3] or s[1]
    local from = base[donor] or base[key] or {}
    override[key] = { icon = glyph, color = from.color, cterm_color = from.cterm_color, name = from.name }
  end
  return override
end

-- snacks picker/explorer's OWN vocabulary — the half devicons never supplies.
-- Deep-merged over snacks.picker.config.defaults, so unlisted keys keep upstream:
-- tree guides (│ ├╴ └╴), git modified ○ / staged ● / untracked ?, Error/Warn/Info
-- and the ui selected/unselected marks are already Cozette and stay put.
M.snacks = {
  files = {
    dir = g.folder .. " ",
    dir_open = g.folder_open .. " ",
    file = g.file .. " ", -- also every bare-name file, see HOW note 1
  },
  git = {
    added = "\u{f067}", -- nf-fa-plus
    deleted = "\u{f068}", -- nf-fa-minus
    renamed = "\u{f553}", -- nf-fa-long_arrow_alt_right
    ignored = "\u{f056}", -- nf-fa-minus_circle
    unmerged = "\u{f06a}", -- nf-fa-exclamation_circle
    commit = "\u{f111} ", -- nf-fa-circle
  },
  diagnostics = { Hint = "\u{f835} " }, -- nf-fae-lightbulb_o
  ui = { live = "\u{f0e7} " }, -- nf-fa-bolt
  undo = { saved = "\u{f00c} " }, -- nf-fa-check
  lsp = {
    unavailable = "\u{f00d}", -- nf-fa-times
    enabled = "\u{f111} ",
    disabled = "\u{f056} ",
    attached = "\u{f1eb} ", -- nf-fa-wifi
  },
  keymaps = { nowait = "\u{f0e7} " },
}

return M
