-- NixOS対応: Mason がダウンロードするバイナリは NixOS では動かない (動的リンクの問題)。
-- LSP・フォーマッタは home/modules/apps.nix で nix パッケージとして入れ、
-- Mason には何もインストールさせない。
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- mason = false で「nixで入れたPATH上のバイナリを使う」指定になる
        lua_ls = { mason = false },
        nixd = { mason = false },
        clangd = { mason = false },
        gopls = { mason = false },
        pyright = { mason = false },
        ruff = { mason = false },
      },
    },
  },
}
