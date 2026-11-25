{ ... }:
{
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    cb = "claude --permission-mode bypassPermissions";
    code = "flatpak run com.vscodium.codium";
    codium = "flatpak run com.vscodium.codium";
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
