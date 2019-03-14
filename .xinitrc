xrdb .Xresources

./.screenlayout/display-top.sh

dbus-update-activation-environment --systemd DISPLAY
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

#xrandr --setprovideroutputsource modesetting NVIDIA-0
#xrandr --auto
xrandr --dpi 96

exec i3
