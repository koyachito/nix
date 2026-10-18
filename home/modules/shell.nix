{ ... }:
{
  programs.bash.enable = true;
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.git.enable = true;
  programs.git.settings.user.name = "koyachito";
  programs.git.settings.user.email = "account@koyachito.com";
	
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
  };
}
