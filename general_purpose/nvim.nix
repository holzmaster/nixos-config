{ config, pkgs, dotfiles, ... }:

{
  programs.neovim = {
    enable       = true;
    vimAlias     = true;
    viAlias      = true;
    vimdiffAlias = true;

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
      #(nvim-treesitter.withPlugins (_: with plugins; pkgs.tree-sitter.allGrammars)) nvim-ts-rainbow
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

      let mapleader = "\<SPACE>"

      let g:ale_floating_preview = 1
      let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']

      " min width of word
      let g:cursorword_min_width = 3

      " max width of word
      let g:cursorword_max_width = 50
      let g:multi_cursor_use_default_mapping = 1

      let g:tokyonight_style = 'storm'

      nnoremap <leader>n :NERDTreeFocus<cr>
      nnoremap <C-t> :NERDTreeToggle<cr>
      nnoremap <C-f> :NERDTreeFind<cr>

      vnoremap < <gv
      vnoremap > >gv
      vnoremap y myy`y
      vnoremap Y myY`y

      nnoremap <C-k> <cmd>lua vim.lsp.buf.signature_help()<cr>
      nnoremap <leader>g :ALEGoToDefinition<cr>
      nnoremap <leader>fr :ALEFindReferences<cr>
      nnoremap <leader>ss :ALESymbolSearch
      nnoremap <leader>r :ALERename

      nnoremap <leader>k :nohlsearch<cr>
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>tt <cmd>Telescope<cr>
      nnoremap <leader>w! :SudoWrite<cr>
      nnoremap <leader>e! :SudoEdit<cr>

      nnoremap <silent>[b :BufferLineCycleNext<CR>
      nnoremap <silent>b] :BufferLineCyclePrev<CR>
      nnoremap <silent><leader>bh :BufferLineMoveNext<CR>
      nnoremap <silent><leader>bl :BufferLineMovePrev<CR>
      nnoremap <silent>bd :BufferLineSortByDirectory<CR>

      vnoremap ga :EasyAlign<cr>

      vnoremap x "_x
      nnoremap x "_x

      set clipboard+=unnamedplus
      syntax on
      set hidden
      set nobackup
      set signcolumn=yes:2
      set nowritebackup
      set cmdheight=2
      set updatetime=300
      set shortmess+=c
      set backspace=2
      set visualbell
      set t_vb=
      set title
      set relativenumber
      set number
      set ruler
      set tabstop=2 shiftwidth=2 smarttab expandtab
      set noexpandtab
      set cursorline
      set encoding=UTF-8
      set smartcase
      set smartindent
      set ignorecase
      set cursorline
      set updatetime=300
      set redrawtime=10000

      colorscheme tokyonight
    '';
  };

  # home.file = {
  #   ".config/nvim/lua" = {
  #     source = "${dotfiles}/nvim/lua";
  #   };
  # };
}
