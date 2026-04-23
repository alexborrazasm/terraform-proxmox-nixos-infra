{ 
  config,
  pkgs,
  lib, 
  ... 
}: {
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    configure = {
      ############################
      # Plugins
      ############################
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          nvim-osc52
        ];
        opt = [ ];
      };

      ############################
      # Lua config
      ############################
      customLuaRC = ''
        --------------------
        -- Core
        --------------------
        vim.o.number = true
        vim.o.relativenumber = true
        vim.o.mouse = "a"
        vim.o.expandtab = true
        vim.o.shiftwidth = 2
        vim.o.tabstop = 2
        vim.o.termguicolors = true
        vim.g.mapleader = " "

        --------------------
        -- Clipboard
        --------------------
        vim.o.clipboard = "unnamedplus"

        -- OSC52 (SSH / TTY)
        local has_osc52, osc52 = pcall(require, 'osc52')
        if has_osc52 then
          osc52.setup {}

          vim.keymap.set("v", "<Space>y", function()
            osc52.copy_visual()
          end, { noremap = true, silent = true })

          vim.keymap.set("n", "<Space>y", function()
            osc52.copy_operator()
          end, { noremap = true, silent = true })

          vim.keymap.set("n", "gy", function()
            osc52.copy_line()
          end, { noremap = true, silent = true })
        end

        --------------------
        -- Keymaps
        --------------------
        vim.keymap.set("n", "<leader>w", ":w<CR>")
        vim.keymap.set("n", "<leader>q", ":q<CR>")
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xclip
  ];

}