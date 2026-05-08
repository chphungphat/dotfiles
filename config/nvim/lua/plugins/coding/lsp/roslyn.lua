return {
  "seblyng/roslyn.nvim",
  ft = { "cs", "razor" },
  config = function()
    -- Find the highest mise-installed dotnet >= 9 and force DOTNET_ROOT to it.
    local candidates =
      vim.fn.glob(vim.fn.expand("~/.local/share/mise/installs/dotnet") .. "/*/dotnet", false, true)
    local best_path, best_major = nil, 0
    for _, bin in ipairs(candidates) do
      local dir = vim.fn.fnamemodify(bin, ":h")
      local major = tonumber(vim.fn.fnamemodify(dir, ":t"):match("^(%d+)%."))
      if major and major >= 9 and major > best_major then
        best_path, best_major = dir, major
      end
    end

    if best_path then
      vim.env.DOTNET_ROOT = best_path
      -- Prepend the .NET 10 bin dir so BuildHost's `dotnet` CLI matches DOTNET_ROOT.
      -- Without this, mise's .NET 8 `dotnet` conflicts with DOTNET_ROOT=10 and
      -- HasUsableMSBuild() returns false, failing all csproj loads.
      vim.env.PATH = best_path .. ":" .. vim.env.PATH
    end

    -- Expose the roslyn server directory to nvim child processes only (not shell PATH).
    vim.env.PATH = vim.fn.expand("~/.local/share/roslyn") .. ":" .. vim.env.PATH

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if pcall(require, "blink.cmp") then
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    end

    require("roslyn").setup({
      broad_search = false,
      lock_target = true,
      extensions = {
        razor = {
          enabled = true,
          config = function()
            local razor_ext = vim.fn.expand("~/.local/share/roslyn/.razorExtension")
            if vim.fn.isdirectory(razor_ext) == 0 then
              return { path = nil }
            end
            return {
              path = vim.fs.joinpath(razor_ext, "Microsoft.VisualStudioCode.RazorExtension.dll"),
              args = {
                "--razorSourceGenerator="
                  .. vim.fs.joinpath(razor_ext, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
                "--razorDesignTimePath=" .. vim.fs.joinpath(
                  razor_ext,
                  "Targets",
                  "Microsoft.NET.Sdk.Razor.DesignTime.targets"
                ),
              },
            }
          end,
        },
      },
      config = {
        capabilities = capabilities,
        settings = {
          ["csharp|background_analysis"] = {
            dotnet_analyzer_diagnostics_scope = "openFiles",
            dotnet_compiler_diagnostics_scope = "openFiles",
          },
          ["csharp|inlay_hints"] = {
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = false,
            dotnet_enable_inlay_hints_for_indexer_parameters = false,
            dotnet_enable_inlay_hints_for_object_creation_parameters = false,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          },
          ["csharp|completion"] = {
            dotnet_provide_regex_completions = true,
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = false,
            dotnet_enable_tests_code_lens = false,
          },
        },
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          vim.keymap.set("n", "<leader>co", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.organizeImports" }, diagnostics = {} },
            })
          end, vim.tbl_extend("force", opts, { desc = "Organize Imports (C#)" }))
        end,
      },
    })
  end,
}
