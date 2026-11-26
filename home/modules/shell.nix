{ ... }:
{
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    cb = "claude --permission-mode bypassPermissions";
    # flatpak アプリの alias は apps.nix の flatpakApps から自動生成
    code = "codium"; # codium は nixpkgs 移行済み
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.git.enable = true;
  programs.git.settings.user.name = "koyachito";
  programs.git.settings.user.email = "accounts@koyachito.com";
	
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
  };
}
