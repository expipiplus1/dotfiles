#!/usr/bin/env bash

# Not sure which one of these works
gsettings set org.gnome.shell.overrides edge-tiling true
gsettings set org.gnome.mutter edge-tiling true

# Remove the wasted space in the terminal.
#
# Currently a bug for fullscreen where there is one frame of graphical
# corruption when alt-tabbing to it
gsettings set org.gnome.Terminal.Legacy.Settings headerbar false

# NixOS or Gnome-shell don't set -types properly
setxkbmap -verbose 10 fc660c -types fc660c

# Sensible Alt-Tab
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"

firefoxSetting() {
  for d in "$HOME/.mozilla/firefox"/*/; do
    u="$d/user.js"
    touch "$u"
    sed -i 's/user_pref("'"$1"'",.*);/user_pref("'"$1"'",'"$2"');/' "$u"
    grep -q "$1" "$u" || echo "user_pref(\"$1\",$2);" >> "$u"
  done
}

firefoxSetting browser.urlbar.doubleClickSelectsAll false
firefoxSetting browser.tabs.tabMinWidth 0
firefoxSetting toolkit.legacyUserProfileCustomizations.stylesheets true
firefoxSetting layers.acceleration.force-enabled true

for d in "$HOME/.mozilla/firefox"/*/; do
  mkdir -p "$d/chrome"
  cat > "$d/chrome/userChrome.css" << EOF
.tabbrowser-tab:not([pinned]) {
  min-width: 26px !important;
}

.tab-content {
  padding: 0 4px !important;
  min-width: 18px !important;
}

.tab-close-button,
.tabs-newtab-button,
#new-tab-button {
  display: none !important;
}
EOF
done
