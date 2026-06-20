-- BUILD-TIME ONLY. Run via: nvim --headless "+luafile /tmp/install-parsers.lua"
--
-- Synchronously bakes the source-of-truth treesitter parser set, then asserts
-- every one landed. A missing parser FAILS THE DOCKER BUILD (cquit 1) so the
-- image can never again silently ship zero parsers.
--
-- Why serial (max_jobs=1): install() defaults to max_jobs=100; dozens of
-- concurrent `tree-sitter build` jobs race on the shared site/parser/ output
-- dir and some .so files lose the copy/rename race ("multiple processes
-- building to the same output location"). max_jobs=1 makes that race
-- structurally impossible. force=true cleanly re-bakes after a list change.
-- :wait() blocks the headless process until the (async) install finishes —
-- without it, +qall exits before any parser is written (the original bug).

local ok_ts, ts = pcall(require, "nvim-treesitter")
if not ok_ts then
  io.stderr:write("FATAL: nvim-treesitter not on runtimepath; did +Lazy! install/restore run first?\n")
  io.stderr:flush()
  vim.cmd("cquit 1")
end

local want = require("config.parsers")

local ok_cfg, cfg = pcall(require, "nvim-treesitter.config")
if ok_cfg and cfg.get_install_dir then
  io.stdout:write("parser install dir: " .. cfg.get_install_dir("parser") .. "\n")
  io.stdout:flush()
end

-- Synchronous, serial, forced. 30-min cap is generous; the list drops the
-- expensive outliers, so real time is far lower.
ts.install(want, { max_jobs = 1, force = true }):wait(30 * 60 * 1000)

-- Hard count assertion against what actually landed on disk.
local installed = {}
for _, lang in ipairs(ts.get_installed("parsers")) do
  installed[lang] = true
end
local missing = {}
for _, lang in ipairs(want) do
  if not installed[lang] then
    missing[#missing + 1] = lang
  end
end

if #missing > 0 then
  io.stderr:write("FATAL: parsers not baked: " .. table.concat(missing, ", ") .. "\n")
  io.stderr:flush()
  vim.cmd("cquit 1") -- nonzero exit -> docker build fails
end

io.stdout:write(("OK: baked %d treesitter parsers\n"):format(#want))
io.stdout:flush()
vim.cmd("qall")
