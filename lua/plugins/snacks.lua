return {
   "folke/snacks.nvim",
   priority = 1000,
   lazy = false,
   ---@type snacks.Config
   opts = {
      styles = {
         snacks_image = {
            relative = "cursor",
            border = "rounded",
            focusable = false,
            backdrop = false,
            row = 1,
            col = 1,
            -- width/height are automatically set by the image size unless specified below
         },
      },
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      picker = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
      image = {
         formats = {
            "png",
            "jpg",
            "jpeg",
            "gif",
            "bmp",
            "webp",
            "tiff",
            "heic",
            "avif",
            "mp4",
            "mov",
            "avi",
            "mkv",
            "webm",
            "pdf",
         },
         enabled = true,
         math = {
            enabled = true, -- enable math expression rendering
            -- in the templates below, `${header}` comes from any section in your document,
            -- between a start/end header comment. Comment syntax is language-specific.
            -- * start comment: `// snacks: header start`
            -- * end comment:   `// snacks: header end`
            typst = {
               tpl = [[
                    #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
                    #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
                    #set text(size: 12pt, fill: rgb("${color}"))
                    ${header}
                    ${content}]],
            },
            latex = {
               font_size = "normalsize",
               packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools", "xcolor" },
               color = "FFFFFF", -- HEX color without `#` (e.g., white)
               tpl = [[
                     \documentclass[preview,border=2pt,varwidth,12pt]{standalone}
                     \usepackage{${packages}}
                     \usepackage{xcolor}
                     \begin{document}
                     ${header}
                     { \${font_size} \selectfont
                       \color[HTML]{c4a7e7}
                     ${content}}
                     \end{document}]],
            },
         },
      },
   },
}
