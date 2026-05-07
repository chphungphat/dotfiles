return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  lazy = false,
  config = function()
    local themes = {
      { flavor = "mocha", name = "Gruvbox", key = "1", bg = "dark" },
      { flavor = "macchiato", name = "Everforest", key = "2", bg = "dark" },
      { flavor = "frappe", name = "RosePine", key = "3", bg = "dark" },
      { flavor = "latte", name = "Lotus", key = "4", bg = "light" },
    }

    local function switch_theme(flavor, name, bg)
      vim.cmd.colorscheme("catppuccin-" .. flavor)
      vim.o.background = bg
      vim.notify("Theme: " .. name, vim.log.levels.INFO)
    end

    require("catppuccin").setup({
      flavour = "mocha",
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      no_italic = false,
      no_bold = false,
      no_underline = false,

      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },

      color_overrides = {
        ---------------------------------------------------------------
        -- Gruvbox Material Dark Medium
        -- Daily driver: warm amber/earth tones
        -- Ref: community gruvbox port, subtexts adjusted for medium
        ---------------------------------------------------------------
        mocha = {
          rosewater = "#ffc6be",
          flamingo = "#fb4934",
          pink = "#ff75a0",
          mauve = "#f2594b",
          red = "#f2594b",
          maroon = "#fe8019",
          peach = "#FFAD7D",
          yellow = "#e9b143",
          green = "#b0b846",
          teal = "#8bba7f",
          sky = "#7daea3",
          sapphire = "#689d6a",
          blue = "#80aa9e",
          lavender = "#e2cca9",
          text = "#e2cca9",
          subtext1 = "#d4be98",
          subtext0 = "#a89984",
          overlay2 = "#8C7A58",
          overlay1 = "#735F3F",
          overlay0 = "#806234",
          surface2 = "#665c54",
          surface1 = "#3c3836",
          surface0 = "#32302f",
          base = "#282828",
          mantle = "#1d2021",
          crust = "#1b1b1b",
        },

        ---------------------------------------------------------------
        -- Everforest Dark Soft
        -- Afternoon fatigue: muted green/olive nature tones
        -- Ref: community everforest port accents + soft bg values
        ---------------------------------------------------------------
        macchiato = {
          rosewater = "#fed1cb",
          flamingo = "#ff9185",
          pink = "#d699b6",
          mauve = "#cb7ec8",
          red = "#e06062",
          maroon = "#e67e80",
          peach = "#e69875",
          yellow = "#d3ad63",
          green = "#b0cc76",
          teal = "#6db57f",
          sky = "#7fbbb3",
          sapphire = "#60aaa0",
          blue = "#59a6c3",
          lavender = "#e0d3d4",
          text = "#e8e1bf",
          subtext1 = "#e0d7c3",
          subtext0 = "#d3c6aa",
          overlay2 = "#9da9a0",
          overlay1 = "#859289",
          overlay0 = "#6d6649",
          surface2 = "#4d5960",
          surface1 = "#434f55",
          surface0 = "#3a464c",
          base = "#333c43",
          mantle = "#293136",
          crust = "#232a2e",
        },

        ---------------------------------------------------------------
        -- Rose Pine (Dusty Rose/Mauve)
        -- Afternoon fatigue: warm dusty rose backgrounds
        -- Ref: b-ggs/dotfiles backgrounds + Rose Pine Moon accents
        ---------------------------------------------------------------
        frappe = {
          rosewater = "#ea9a97",
          flamingo = "#ea9a97",
          pink = "#eb6f92",
          mauve = "#c4a7e7",
          red = "#eb6f92",
          maroon = "#eb6f92",
          peach = "#f6c177",
          yellow = "#f6c177",
          green = "#9ccfd8",
          teal = "#9ccfd8",
          sky = "#9ccfd8",
          sapphire = "#3e8fb0",
          blue = "#3e8fb0",
          lavender = "#c4a7e7",
          text = "#F4CDE9",
          subtext1 = "#DEBAD4",
          subtext0 = "#C8A6BE",
          overlay2 = "#B293A8",
          overlay1 = "#9C7F92",
          overlay0 = "#866C7D",
          surface2 = "#705867",
          surface1 = "#5A4551",
          surface0 = "#44313B",
          base = "#352939",
          mantle = "#211924",
          crust = "#1a1016",
        },

        ---------------------------------------------------------------
        -- Lotus (Kanagawa Light + community warm cream)
        -- Eye relief: warm amber background, high-contrast text
        -- Ref: Kanagawa lotus accent (#c37339) used for lavender
        --      to fix cursor visibility (was purple → now amber)
        ---------------------------------------------------------------
        latte = {
          rosewater = "#c4626a",
          flamingo = "#c84053",
          pink = "#a8458c",
          mauve = "#6c2eb5",
          red = "#b83b4a",
          maroon = "#a04a6a",
          peach = "#d04a00",
          yellow = "#8a5500",
          green = "#2a6e1a",
          teal = "#107070",
          sky = "#4a78a8",
          sapphire = "#3d5a8a",
          blue = "#4e4895",
          lavender = "#b86c00", -- was #7c6aa0 (purple); amber fixes cursor color
          text = "#1a1008",     -- was #2d2018; darker for more contrast
          subtext1 = "#38220e", -- warmened from #4b3628
          subtext0 = "#4c3018", -- warmened from #5d4a3d
          overlay2 = "#5c4820", -- warmened from #6e5e52 (was gray)
          overlay1 = "#6e5a2c", -- warmened from #817268
          overlay0 = "#806c38", -- warmened from #93867e
          surface2 = "#967e46", -- warmened from #9a8e85 (was gray)
          surface1 = "#ae9858", -- warmened from #aca298
          surface0 = "#c6b06a", -- warmened from #bfb6ad (gray-beige → amber)
          base = "#e8d89a",     -- was #EBDBB2; deeper amber parchment
          mantle = "#dac880",   -- was #E5D5A0
          crust = "#ccba68",    -- was #D5C68E
        },
      },

      custom_highlights = function(colors)
        return {
          CursorLineNr = { fg = colors.yellow, bold = true },
        }
      end,

      integrations = {
        blink_cmp = true,
        gitsigns = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        treesitter = true,
        semantic_tokens = true,
        snacks = true,
        mini = { enabled = true },
        render_markdown = true,
      },
    })

    vim.cmd.colorscheme("catppuccin")

    -- User commands and keymaps for theme switching
    for _, t in ipairs(themes) do
      vim.api.nvim_create_user_command("Theme" .. t.name, function()
        switch_theme(t.flavor, t.name, t.bg)
      end, { desc = "Switch to " .. t.name .. " theme" })

      vim.keymap.set("n", "<leader>t" .. t.key, function()
        switch_theme(t.flavor, t.name, t.bg)
      end, { desc = t.name .. " theme" })
    end
  end,
}
