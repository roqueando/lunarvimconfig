-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = true
vim.opt.cursorline = false
vim.o.mouse = "c"

lvim.leader = ";"
-- add your own keymapping
lvim.keys.normal_mode[";w"] = ":w<cr>"
lvim.keys.insert_mode["jk"] = "<esc>"
lvim.keys.normal_mode["ga"] = "<cmd>Lspsaga code_action<CR>"
lvim.keys.normal_mode["H"] = ":lua require('dap.ui.widgets').hover()<CR>"

lvim.colorscheme = "darkplus"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "right"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.transparent_window = false

lvim.builtin.treesitter.auto_install = true
-- Plugins
lvim.plugins = {
  -- Colorschemes
  { "ellisonleao/gruvbox.nvim" },
  { "lunarvim/darkplus.nvim" },
  -- Language Depencies
  -- GO
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
  {
    "leoluz/nvim-dap-go",
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            -- Must be "go" or it will be ignored by the plugin
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
      })
    end
  },
  -- Rust
  {
    'simrat39/rust-tools.nvim',
    config = function()
      -- local lsp_installer_servers = require("nvim-lsp-installer.servers")
      require("rust-tools").setup({
        tools = {
          executor = require("rust-tools.executors").termopen,
          autoSetHints = true,
          hover_actions = {
            border = {
              { "╭", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╮", "FloatBorder" },
              { "│", "FloatBorder" },
              { "╯", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╰", "FloatBorder" },
              { "│", "FloatBorder" },
            },
          },
          runnables = {
            use_telescope = true
          }
        },
        server = {
          on_init = require('lvim.lsp').common_on_init,
          on_attach = function(client, bufnr)
            require("lvim.lsp").common_on_attach(client, bufnr)
            local rt = require("rust-tools")
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            vim.keymap.set("n", "<leader>lA", rt.code_action_group.code_action_group, { buffer = bufnr })
          end
        }
      })
    end,
    ft = { "rust", "rs" }
  },
  -- Utils
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        symbol_in_winbar = {
          enable = false
        }
      })
    end
  }
}

-- general
lvim.log.level = "warn"
lvim.builtin.illuminate.active = false
lvim.format_on_save = {
  enabled = true,
  -- pattern = "*.lua",
  timeout = 1000,
}
lvim.builtin.dap.active = true
lvim.builtin.lualine.sections.lualine_a = { "mode" }
lvim.builtin.terminal.active = true
lvim.builtin.terminal.open_mapping = "<C-t>"
lvim.builtin.alpha.active = true

-- Icons
lvim.icons.kind = {
  Text = " ",
  Method = " ",
  Function = " ",
  Constructor = " ",
  Field = " ",
  Variable = " ",
  Class = " ",
  Interface = " ",
  Module = " ",
  Property = " ",
  Unit = " ",
  Value = " ",
  Enum = " ",
  Keyword = " ",
  Snippet = " ",
  Color = " ",
  File = " ",
  Reference = " ",
  Folder = " ",
  EnumMember = " ",
  Constant = " ",
  Struct = " ",
  Event = " ",
  Operator = " ",
  TypeParameter = " ",
  Misc = " ",
  Array = "",
  Boolean = "蘒",
  Key = "",
  Namespace = "",
  Null = "ﳠ",
  Number = "",
  Object = "",
  Package = "",
  String = "",
}

-- DAP configs
local opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}
local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

-- GO
local mappings = {
  G = {
    name = "Go",
    g = { "<cmd>GoTest<CR>", "Test All" },
    t = { "<cmd>GoTestFunc<cr>", "Test Function" },
    T = { "<cmd>GoTestFile<cr>", "Test File" },
  },
}

which_key.register(mappings, opts)
vim.api.nvim_create_autocmd('FileType', {
  pattern = "dap-float",
  callback = function()
    vim.keymap.set("n", 'q', "<cmd>close!<CR>", { silent = true, buffer = true })
  end
})

-- End of DAP configs
--
-- LSP configs
local lsp_manager = require "lvim.lsp.manager"
local dap = require('dap')

-- GO
--
lsp_manager.setup("gopls", {
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
  on_init = require("lvim.lsp").common_on_init,
  capabilities = require("lvim.lsp").common_capabilities(),
  settings = {
    gopls = {
      usePlaceholders = true,
      gofumpt = true,
      codelenses = {
        generate = false,
        gc_details = true,
        test = true,
        tidy = true,
      },
    },
  },
})

lsp_manager.setup("rust-analyzer", {
  on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    local _, _ = pcall(vim.lsp.codelens.refresh)
  end,
  on_init = require("lvim.lsp").common_on_init,
  capabilities = require("lvim.lsp").common_capabilities(),
  settings = {
    ["rust-analyzer"] = {
      commands = {
        runSingle = true
      },
      lens = {
        enable = true
      },
    }
  }
})

local gopher_status_ok, gopher = pcall(require, "gopher")
if not gopher_status_ok then
  return
end

gopher.setup {
  commands = {
    go = "go",
    gomodifytags = "gomodifytags",
    gotests = "gotests",
    impl = "impl",
    iferr = "iferr",
  },
}

-- Elixir
dap.adapters.mix_task = {
  type = 'executable',
  command = 'elixir-ls', -- debugger.bat for windows
  args = {}
}

dap.configurations.elixir = {
  {
    type = "mix_task",
    name = "mix test",
    task = 'test',
    taskArgs = { "--trace" },
    request = "launch",
    startApps = true, -- for Phoenix projects
    projectDir = "${workspaceFolder}",
    requireFiles = {
      "test/**/test_helper.exs",
      "test/**/*_test.exs"
    }
  },
}
