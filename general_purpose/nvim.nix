{ config, pkgs, dotfiles, ... }:

{
  programs.neovim = {
    enable        = true;
    vimAlias      = true;
    viAlias       = true;
    vimdiffAlias  = true;

    plugins = with pkgs.vimPlugins; [
      # utilities
      telescope-nvim vim-easy-align vim-multiple-cursors vim-commentary vim-css-color vim-devicons which-key-nvim vim-eunuch vim-cursorword
      # visual 
      nerdtree
      lualine-nvim lualine-lsp-progress
      # better diagnostics
      ale popup-nvim
      # buffer stuff
      bufferline-nvim
      # auto complete
      nvim-cmp cmp-buffer cmp-path cmp_luasnip lspkind-nvim nvim-lspconfig lsp_signature-nvim
      # syntax highlighting
      vim-polyglot
      # design stuff
      tokyonight-nvim indent-blankline-nvim
      # tree sitter
      # for now (sadge)
      (nvim-treesitter.withPlugins (_: with plugins; pkgs.tree-sitter.allGrammars)) nvim-ts-rainbow
    ];

    extraPackages = with pkgs; [
      ripgrep fd
    ];

    extraConfig = ''

      lua << EOF 
      -- colored indent guides
      vim.opt.termguicolors = true
      vim.cmd [[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]]
      vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]]
      vim.opt.list = true
      vim.opt.listchars:append("space:⋅")
      vim.opt.listchars:append("eol:↴")
      require("indent_blankline").setup {
          space_char_blankline = " ",
          char_highlight_list = {
              "IndentBlanklineIndent1",
              "IndentBlanklineIndent2",
              "IndentBlanklineIndent3",
              "IndentBlanklineIndent4",
              "IndentBlanklineIndent5",
              "IndentBlanklineIndent6",
          },
      }
      EOF

      lua << EOF 
      -- initialize lsp signature 
      require('lsp_signature').setup({
        bind = true,
        doc_lines = 20,
        floating_window = true,
        floating_window_above_cur_line = true,
        fix_pos = false,
        hint_enable = true,
        hint_scheme = "String",
        max_height = 18,
        max_width = 86,
        handler_opts = { border = "rounded" },
        always_trigger = false,
        auto_close_after = nil,
        zindex = 200,
        padding = "",
        extra_trigger_chars = {"(", ",", "{"},
        transparency = nil,
        timer_interval = 100
      })
      EOF

      lua << EOF 
      -- initialize completion 
      local lspkind = require("lspkind")
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      local cmp = require("cmp")
      cmp.setup {
          mapping = {
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<CR>'] = cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }),
            ["<Tab>"] = function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end,
            ["<S-Tab>"] = function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,
          },
          sources = {
              { name = 'nvim_lsp' },
              { name = 'path' },
              { name = 'luasnip' },
              { name = 'buffer' },
          },
          snippet = {
              expand = function(args) 
                  require("luasnip").lsp_expand(args.body)
              end,
          },
          formatting = {
            format = lspkind.cmp_format {
              with_text = true,
              menu = {
                buffer   = "[BUF]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[API]",
                path     = "[PATH]",
                luasnip  = "[SNIP]",
              },
            },
          },
          experimental = {
            native_menu = false,
            ghost_text = true,
          },
      }
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { jame = 'buffer' }
        }
      })
      EOF

      lua << EOF 
      -- initialize lualine 
      local config = {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = {'', ''},
          section_separators = {'', ''},
          disabled_filetypes = {}
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'filename'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {'encoding', 'fileformat', 'filetype'},
          lualine_z = {{'branch'}, {'progress'}},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = { },
        extensions = {}
      }
      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end
      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end
      ins_left {
        'lsp_progress',
        display_components = { 'lsp_client_name', { 'title', 'percentage', 'message' }},
        -- With spinner
        -- display_components = { 'lsp_client_name', 'spinner', { 'title', 'percentage', 'message' }},
        separators = {
          component = ' ',
          progress = ' | ',
          message = { pre = '(', post = ')'},
          percentage = { pre = "", post = '%% ' },
          title = { pre = "", post = ': ' },
          lsp_client_name = { pre = '[', post = ']' },
          spinner = { pre = "", post = "" },
        },
        timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
        message = { commenced = 'In Progress', completed = 'Completed' },
      }
      require('lualine').setup(config)
      EOF

      lua << EOF 
      -- initialize lsp
      local lcfg = require('lspconfig')
      lcfg.zls.setup{}
      lcfg.ccls.setup{}
      lcfg.gopls.setup{}
      lcfg.rust_analyzer.setup{}
      lcfg.cmake.setup{}
      lcfg.dockerls.setup{}
      lcfg.html.setup{}
      lcfg.rnix.setup{}
      EOF

      lua << EOF 
      -- initialize tree-sitter
      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
        },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        },
        indent = {
          enable = true,
        },
      }
      EOF

      lua << EOF 
      -- initialize buffer line
      require('bufferline').setup {
        options = {
          mode = "buffers",
          numbers = "none", 
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = "bdelete! %d",
          indicator_icon = '▎',
          buffer_close_icon = '',
          modified_icon = '●',
          close_icon = '',
          left_trunc_marker = '',
          right_trunc_marker = '',
          name_formatter = function(buf)
            if buf.name:match('%.md') then
              return vim.fn.fnamemodify(buf.name, ':t:r')
            end
          end,
          max_name_length = 18,
          max_prefix_length = 15, 
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(count, level, diagnostics_dict, context)
            return "("..count..")"
          end,
          offsets = {text_align = "center"},
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = false,
          show_buffer_default_icon = true,
          show_close_icon = false,
          show_tab_indicators = true,
          separator_style = "slant",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
        }
      }
      EOF
      

      vim.g.mapleader = "\<SPACE>"
      vim.g.ale_floating_preview = 1
      vim.g.ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
      vim.g.cursorword_min_width = 3
      vim.g.cursorword_max_width = 50
      vim.g.multi_cursor_use_default_mapping = 1
      vim.g.tokyonight_style = 'storm'

      vim.api.nvim_set_keymap('n', '<Leader>', ':NERDTreeFocus<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('t', '<Control>', ':NERDTreeToggle<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('f', '<Control>', ':NERDTreeFind<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('<', "", '<gv', { vnoremap = true })
      vim.api.nvim_set_keymap('>', "", '>gv', { vnoremap = true })
      vim.api.nvim_set_keymap('y', "", 'myy`y', { vnoremap = true })
      vim.api.nvim_set_keymap('Y', "", 'myY`y', { vnoremap = true })
      vim.api.nvim_set_keymap('k', '<Control>', '<cmd>vim.lsp.buf.signature_help()<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('g', '<Leader>', ':ALEGoToDefinition<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('fr', '<Leader>', ':ALEFindReferences<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('ss', '<Leader>', ':ALESymbolSearch', { nnoremap = true })
      vim.api.nvim_set_keymap('r', '<Leader>', ':ALERename', { nnoremap = true })
      vim.api.nvim_set_keymap('k', '<Leader>', ':nohlsearch<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('ff', '<Leader>', '<cmd>Telescope find_files<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('tt', '<Leader>', '<cmd>Telescope<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('w!', '<Leader>', ':SudoWrite<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('e!', '<Leader>', ':SudoEdit<cr>', { nnoremap = true })
      vim.api.nvim_set_keymap('[b', "", ':BufferLineCycleNext<cr>', { nnoremap = true, silent = true })
      vim.api.nvim_set_keymap('b]', "", ':BufferLineCyclePrev<cr>', { nnoremap = true, silent = true })
      vim.api.nvim_set_keymap('bh', '<Leader>', ':BufferLineMoveNext<cr>', { nnoremap = true, silent = true })
      vim.api.nvim_set_keymap('bl', '<Leader>', ':BufferLineMovePrev<cr>', { nnoremap = true, silent = true })
      vim.api.nvim_set_keymap('bd', "", ':BufferLineSortByDirectory<cr>', { nnoremap = true, silent = true })
      vim.api.nvim_set_keymap('ga', "", ':EasyAlign<cr>', { vnoremap = true })
      vim.api.nvim_set_keymap('x', "", '"_x', { noremap = true })

      vim.cmd("set clipboard+=unnamedplus")
      vim.cmd("syntax on")
      vim.cmd("set hidden")
      vim.cmd("set nobackup")
      vim.cmd("set signcolumn=yes:2")
      vim.cmd("set nowritebackup")
      vim.cmd("set cmdheight=2")
      vim.cmd("set updatetime=300")
      vim.cmd("set shortmess+=c")
      vim.cmd("set backspace=2")
      vim.cmd("set visualbell")
      vim.cmd("set t_vb=")
      vim.cmd("set title")
      vim.cmd("set relativenumber")
      vim.cmd("set number")
      vim.cmd("set ruler")
      vim.cmd("set tabstop=2")
      vim.cmd("shiftwidth=2")
      vim.cmd("smarttab")
      vim.cmd("expandtab")
      vim.cmd("set noexpandtab")
      vim.cmd("set cursorline")
      vim.cmd("set encoding=UTF-8")
      vim.cmd("set smartcase")
      vim.cmd("set smartindent")
      vim.cmd("set ignorecase")
      vim.cmd("set cursorline")
      vim.cmd("set updatetime=300")
      vim.cmd("set redrawtime=10000")
      vim.cmd("colorscheme tokyonight")
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
  # home.file = {
  #   ".config/nvim/lua" = {
  #     source = "${dotfiles}/nvim/lua";
  #   };
  # };
}
