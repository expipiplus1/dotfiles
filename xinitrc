mkdir -p .xkb/keymap
setxkbmap -print | sed -e '/xkb_symbols/s/"[[:space:]]/+local&/' \
                 > $HOME/.xkb/keymap/custom
xkbcomp -w0 -I$HOME/.xkb -R$HOME/.xkb keymap/custom $DISPLAY

# Start VirtualBox client to enable clipboard exchange with host and screen autoresize
if ! pidof VBoxClient; then
   exec VBoxClient --clipboard &
   exec VBoxClient --display &
fi

exec i3
