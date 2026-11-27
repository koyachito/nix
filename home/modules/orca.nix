# Orca (stablyai/orca, MIT) — flatpak 配布が無いため公式 AppImage を appimageTools でラップ。
# テレメトリはラッパーで ORCA_TELEMETRY_DISABLED=1 を焼き込み恒久無効
# (設定画面のトグルより優先され、プロファイルを作り直しても効く)。
# なおテレメトリ以外の通信 (orca.dev への更新チェック・お知らせ、Google favicon 取得、
# gh ログイン中は更新確認に PAT 添付) は残る。監査メモ: ~/orca-audit-2026-11-27.md
# 更新手順: version と sha256 を書き換える
#   (ハッシュは nix-prefetch-url https://github.com/stablyai/orca/releases/download/v<新version>/orca-linux.AppImage)
# アプリ内自動アップデートは Nix ストアが読み取り専用のため機能しない (更新は nix 管理に一本化)。
{ pkgs, ... }:
let
  pname = "orca";
  version = "1.4.278";
  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    sha256 = "039qbn4iw2rx6i81v0yll9s6bjdk9l9kc6vb55a8wfb8jyxjab9y";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
  orca = pkgs.appimageTools.wrapType2 {
    inherit pname version src;
    extraInstallCommands = ''
      # 環境変数を焼き込んだラッパーで実体を包む
      mv $out/bin/orca $out/bin/.orca-unwrapped
      {
        echo '#!${pkgs.runtimeShell}'
        echo 'export ORCA_TELEMETRY_DISABLED=1'
        echo "exec $out/bin/.orca-unwrapped \"\$@\""
      } > $out/bin/orca
      chmod +x $out/bin/orca

      install -Dm444 ${appimageContents}/orca-ide.desktop \
        $out/share/applications/orca.desktop
      substituteInPlace $out/share/applications/orca.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=orca'
      install -Dm444 \
        ${appimageContents}/usr/share/icons/hicolor/512x512/apps/orca-ide.png \
        $out/share/icons/hicolor/512x512/apps/orca-ide.png
    '';
  };
in
{
  home.packages = [ orca ];
}
