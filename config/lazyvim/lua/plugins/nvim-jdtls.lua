return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    opts.settings.java = vim.tbl_deep_extend("force", opts.settings.java or {}, {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-17",
            path = "/usr/lib/jvm/java-17-openjdk-amd64/",
          },
        },
      },
    })

    return opts
  end,
}
