-- Path helpers for JS/TS monorepos whose projects keep their tool configs in `.configs/`
-- (oxlint.config.mts, oxfmt.config.mts) and their tools in each project's node_modules/.bin.
-- No tool looks inside `.configs/` on its own, so the editor has to find it and pass it.
local M = {}

-- The nearest folder, from `path` upward, whose `.configs/` holds `file` (e.g. "oxfmt.config.mts").
function M.dot_configs_root(path, file)
  return vim.fs.root(path, function(name, dir)
    return name == ".configs" and vim.uv.fs_stat(vim.fs.joinpath(dir, ".configs", file)) ~= nil
  end)
end

-- The git root of `path` when it also holds `.configs/<file>`: the repo-wide config, which in
-- nx-seller formats every non-code file (json, yaml, css, html, toml), inside projects too.
function M.repo_dot_configs_root(path, file)
  local root = vim.fs.root(path, ".git")
  if root and vim.uv.fs_stat(vim.fs.joinpath(root, ".configs", file)) then
    return root
  end
  return nil
end

-- The nearest `node_modules/.bin/<bin>` from `path` upward, else `<bin>` on $PATH, else nil.
function M.find_node_bin(path, bin)
  local rel = vim.fs.joinpath("node_modules", ".bin", bin)
  local root = vim.fs.root(path, function(name, dir)
    return name == "node_modules" and vim.fn.executable(vim.fs.joinpath(dir, rel)) == 1
  end)
  if root then
    return vim.fs.joinpath(root, rel)
  end
  if vim.fn.executable(bin) == 1 then
    return vim.fn.exepath(bin)
  end
  return nil
end

-- The nearest `node_modules/typescript/lib` from `path` upward (a project's own TypeScript), or nil.
function M.typescript_lib(path)
  local rel = vim.fs.joinpath("node_modules", "typescript", "lib")
  local root = vim.fs.root(path, function(name, dir)
    return name == "node_modules" and vim.uv.fs_stat(vim.fs.joinpath(dir, rel, "tsserver.js")) ~= nil
  end)
  return root and vim.fs.joinpath(root, rel) or nil
end

-- The repo root when its files should get the native TypeScript server (tsgo): the repo keeps the
-- `.configs/` layout (nx-seller, ignis) and a tsgo binary is installed. Else nil (use vtsls).
function M.prefers_native_ts(path)
  if path == "" then
    return nil
  end
  local root = M.repo_dot_configs_root(path, "oxfmt.config.mts")
  if root and M.find_node_bin(root, "tsgo") then
    return root
  end
  return nil
end

return M
