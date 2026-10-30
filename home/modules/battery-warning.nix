{ pkgs, ... }:

let
  batteryWarning = pkgs.writeShellApplication {
    name = "battery-warning";
    runtimeInputs = with pkgs; [
      coreutils
      gnused
      libnotify
      upower
    ];
    text = ''
      battery_device=""
      while IFS= read -r device; do
        case "$device" in
          *battery*)
            battery_device="$device"
            break
            ;;
        esac
      done < <(upower --enumerate)

      # Desktops and sessions without a battery need no warning.
      [ -n "$battery_device" ] || exit 0

      battery_info="$(upower --show-info "$battery_device")"
      state="$(sed -n 's/^[[:space:]]*state:[[:space:]]*//p' <<< "$battery_info")"
      capacity="$(sed -n 's/^[[:space:]]*percentage:[[:space:]]*\([0-9]*\)%.*/\1/p' <<< "$battery_info")"
      [ -n "$capacity" ] || exit 0

      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/battery-warning"
      state_file="$state_dir/last-level"
      mkdir -p "$state_dir"
      last_level="$(cat "$state_file" 2>/dev/null || printf '100')"

      if [ "$state" != "discharging" ]; then
        printf '100\n' > "$state_file"
      elif [ "$capacity" -le 5 ] && [ "$last_level" -gt 5 ]; then
        notify-send --urgency=critical --expire-time=0 \
          --hint=string:x-canonical-private-synchronous:battery-warning \
          "バッテリー残量がほとんどありません" \
          "残り ''${capacity}% です。すぐに充電してください。"
        printf '5\n' > "$state_file"
      elif [ "$capacity" -le 15 ] && [ "$last_level" -gt 15 ]; then
        notify-send --urgency=normal --expire-time=10000 \
          --hint=string:x-canonical-private-synchronous:battery-warning \
          "バッテリー残量が少なくなっています" \
          "残り ''${capacity}% です。充電器を接続してください。"
        printf '15\n' > "$state_file"
      fi
    '';
  };
in
{
  systemd.user.services.battery-warning = {
    Unit = {
      Description = "Notify when battery charge is low";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${batteryWarning}/bin/battery-warning";
    };
  };

  systemd.user.timers.battery-warning = {
    Unit.Description = "Check battery charge periodically";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      AccuracySec = "15s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
