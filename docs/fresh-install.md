# NixOS フレッシュインストール手順書

対象: `github:koyachito/nix` の flake から `koyachito-laptop` を新規マシン(または再インストール)に立ち上げる。
前提: NixOS 26.05 インストーラ / UEFI + systemd-boot / LUKS フルディスク暗号化 / x86_64。

構成の方針(2026-11 時点):

- **NixOS (nixpkgs)** — カーネル・LUKS・greetd・sway/niri・fcitx5+mozc・xremap などシステム基盤
- **home-manager (nixpkgs)** — CLIツール・開発ツールチェーン・デスクトップ密結合GUI (kitty, signal, zathura 等)
- **nix-flatpak (flathub)** — 自己完結型GUI: firefox / vscodium / libreoffice / vlc
- 非OSSは claude-code のみ (`allowUnfree` はこれとファームウェアのため)

---

## 0. 旧マシンでのバックアップ(インストール前に必ず)

flake に入っていない、手動で持ち出すもの:

| 対象 | 場所 | 備考 |
|---|---|---|
| SSHキー | `~/.ssh/` | これが無いと GitHub から clone できない |
| GPGキー | `~/.gnupg/` | 使っていれば |
| Firefox プロファイル | `~/.mozilla/` または `~/.var/app/org.mozilla.firefox/` | 最低限ブックマークをエクスポート。flatpak 版は後者 |
| claude-code 認証 | `~/.claude/` | 持ち出さない場合は再ログインでも可 |
| ロック画面動画 | `~/Videos/undertale.webm` | **undertale-lock が絶対パスで参照**。無いとロック画面が壊れる |
| 作業リポジトリ | `~/42commoncore` ほか | push 漏れがないか `git status` を全リポジトリで確認 |
| その他 | `~/Pictures`, `~/Downloads`, `~/invoices` 等 | 必要に応じて |

`~/nix` 自体も未 push の変更がないか確認して push しておく:

```sh
cd ~/nix && git status && git push
```

## 1. インストーラ起動〜パーティション

1. NixOS 26.05 の ISO で起動(UEFI モードであること)。
2. パーティションを切る。想定レイアウト:
   - ESP: 512MB, FAT32, `/boot`
   - 残り: LUKS → その中に ext4(または btrfs)で `/`
3. `/mnt` にマウント(ESP は `/mnt/boot`)。

パーティションの具体的なコマンドは環境依存なので本書では固定しない。
LUKS を使う場合、後述の `nixos-generate-config` が `boot.initrd.luks.devices` を
正しい UUID 付きで生成してくれることを確認する。

## 2. flake の取得とハードウェア設定の差し替え

```sh
# インストーラ環境で
nixos-generate-config --root /mnt

git clone https://github.com/koyachito/nix /mnt/home/nix-bootstrap
cd /mnt/home/nix-bootstrap

# 生成された実機のハードウェア設定で置き換える(他マシンの流用・UUID捏造は厳禁)
cp /mnt/etc/nixos/hardware-configuration.nix hosts/laptop/hardware-configuration.nix

# flake は git 管理下のファイルしか見ないので add が必要(commit は不要)
git add hosts/laptop/hardware-configuration.nix
```

評価が通るか先に確認:

```sh
nix flake show
nix eval .#nixosConfigurations.koyachito-laptop.config.system.build.toplevel.drvPath
```

## 3. インストール

```sh
nixos-install --flake /mnt/home/nix-bootstrap#koyachito-laptop
```

- `koyachito` のパスワードは **対話的に** 設定する(`nixos-install` が root パスワードを聞く。
  ユーザーは初回起動後 `passwd koyachito` でも可)。設定ファイルに平文で書かない。
- 完了したら `reboot`。

## 4. 初回起動

1. LUKS パスフレーズ → tuigreet でセッション選択(sway / niri、`--remember-session` で以後記憶)。
2. ネットワーク: `nmtui` か nm-applet で Wi-Fi 接続。
3. flake リポジトリを本来の場所へ:

```sh
git clone git@github.com:koyachito/nix ~/nix   # SSHキー復元後
# bootstrap に置いた hardware-configuration.nix をコミットしていなければここで反映して push
```

以後の更新は:

```sh
cd ~/nix && sudo nixos-rebuild switch --flake .#koyachito-laptop
```

## 5. flatpak アプリの初回インストールを確認

nix-flatpak は rebuild(activation)後に systemd ユーザーサービスが flathub から取得する。
**rebuild 直後はまだアプリが無い**ので焦らない:

```sh
systemctl --user status flatpak-managed-install   # 進行確認
flatpak list                                      # firefox / vscodium / libreoffice / vlc が並べば完了
```

自動更新は weekly(apps.nix の `update.auto`)。手動なら `flatpak update`。

## 6. アプリごとの再セットアップ

### Firefox (flatpak)

- プロファイルは `~/.var/app/org.mozilla.firefox/` 配下。旧 `~/.mozilla` からの自動引き継ぎは無い。
  ブックマークはエクスポートした HTML/JSON をインポート。
- 拡張を入れる: **Surfingkeys** / **Multi-Account Containers**(仕事・個人の Google を同一ウィンドウで分離)/ **Bitwarden**(デスクトップアプリは入れない方針。ブラウザ拡張で運用)。
- 同期は使わない方針(Mozilla アカウント不要)。

### VSCodium (flatpak)

- 拡張は Open VSX から: `anthropic.claude-code` / `kube.42header` / `dokca.42-ft-count-line`。
  Open VSX に無い場合は GitHub から .vsix を取得して
  `flatpak run com.vscodium.codium --install-extension foo.vsix`。
- **日本語入力の確認を最初にやる**。Wayland 起動用の環境変数
  (`ELECTRON_OZONE_PLATFORM_HINT=auto`)は nix-flatpak の overrides で設定済み。
  効かない場合は `flatpak run com.vscodium.codium --enable-wayland-ime` を試す。

### Slack / Discord

アプリは廃止。ブラウザ(Firefox)で `app.slack.com` / `discord.com/app` を使う。
Discord のグローバル Push-to-Talk は使えない点だけ注意。

### CLI系の認証

```sh
gh auth login          # GitHub CLI
claude                 # claude-code 初回ログイン(~/.claude を復元したなら不要)
git config --global user.name  / user.email   # shell.nix 等で宣言していなければ
```

## 7. 動作確認チェックリスト

- [ ] fcitx5: Ctrl+Space で mozc 切替(CapsLock も xremap 経由で同じ動作)
- [ ] kitty で日本語入力(変換候補窓の位置・preedit が正常 = unstable 版が効いている)
- [ ] VSCodium で日本語入力
- [ ] 変換キー / 右Alt → Super として動作(xremap)
- [ ] スクリーンショット(grim+slurp)、録画(`rec` スクリプト)
- [ ] ロック画面(`undertale-lock`。`~/Videos/undertale.webm` が必要)
- [ ] クラムシェル: 外部モニタ接続中に蓋を閉じてもサスペンドしない
- [ ] Bluetooth(bluetui / blueman)、音量(pavucontrol)

## 8. 既知の注意点

- flake には unstable の先行取得が2点ある(fcitx5 5.1.23 / kitty 0.50.0)。
  **26.11 に上げたら外す**(flake.nix と desktop.nix のコメント参照)。
- `hosts/laptop/hardware-configuration.nix` はマシン固有。別マシンに入れるときは必ず再生成。
- signal-desktop を flatpak にしない理由: Electron + fcitx5(waylandFrontend)の
  日本語入力が壊れやすいため nixpkgs 側に残している。
