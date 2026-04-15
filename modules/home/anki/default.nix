{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "anki" {
  home.packages = with pkgs; [ anki ];

  systemd.user.services.anki-sync = {
    Unit.Description = "Sync Anki database";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "anki-sync" ''
        ${lib.getExe pkgs.anki} &
        ANKI_PID=$!
        sleep 120
        kill "$ANKI_PID"
        wait "$ANKI_PID" 2>/dev/null || true
      '';
    };
  };

  systemd.user.timers.anki-sync = {
    Unit.Description = "Sync Anki database daily at 23:00";
    Timer = {
      OnCalendar = "*-*-* 23:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
  # TODO: use programs.anki.addons with buildAnkiAddon to manage these declaratively
  # Addons currently installed manually in ~/.local/share/Anki2/addons21/:
  #   - batch-editing (291119185) — glutanimate/batch-editing tag v0.4.0, sourceRoot = src/batch_editing
  #   - fsrs-helper (759844606) — open-spaced-repetition/fsrs4anki-helper, files at repo root
  #   - anki-simulator (817108664) — giovannihenriksen/Anki-Simulator, sourceRoot = src/anki_simulator
  #   - ajt-japanese — Ajatt-Tools/Japanese, needs fetchSubmodules = true
  #   - japanese-readings-and-pitch-accent — expipiplus1/anki-jrp, sourceRoot = src, needs tsc build + data files
}
