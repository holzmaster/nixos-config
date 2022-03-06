{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # utilities
      telescope-nvim vim-easy-align vim-multiple-cursors vim-commentary vim-css-color vim-devicons

      # status bar
      vim-airline vim-airline-clock 

      # auto complete
      nvim-cmp cmp-buffer cmp-path cmp-nvim-lsp cmp_luasnip lspkind-nvim nvim-lspconfig
      vim-lightline-coc telescope-coc-nvim 

      # syntax highlighting
      zig-vim rust-vim vim-nix swift-vim

      # design stuff
      tokyonight-nvim
      indent-blankline-nvim
    ];

    extraConfig = ''
      lua require('indent')
      lua require('completion')
      lua require('zls')

      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      vnoremap x "_x
      nnoremap x "_x
      set clipboard+=unnamedplus
      syntax on
      set hidden
      set nobackup
      set nowritebackup
      set cmdheight=2
      set updatetime=300
      set shortmess+=c
      set backspace=2
      set visualbell
      set t_vb=
      set relativenumber
      set number
      set ignorecase
      set ruler
      set tabstop=2 smarttab
      set cursorline
      set encoding=UTF-8
      set smartcase
      set smartindent
      set ignorecase
      set cursorline

      colorscheme tokyonight
      set termguicolors
    '';
  };

  home.file = {
    ".config/nvim/lua" = {
      source = let
        repo = pkgs.fetchFromGitHub {
          owner  =  "s0la1337";
          repo   =  "dotfiles";
          rev    =  "a10da19584a867b8fb8e64f772302c8910fe33a7";
          sha256 =  "11pf2dz5a2p4rc8sacbgvmmakghjh35lbkzj42g703fjryg96hwv";
        };
      in "${repo}/nvim/lua";
    };
  };
}