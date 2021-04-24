#!/usr/bin/env bash

## run (only once) processes which spawn with the same name
function run {
   if (command -v $1 && ! pgrep $1); then
     $@&
   fi
}

# This implements the XDG autostart specification
if (command -v dex && ! xrdb -query | grep -q "^awesome\.started:\strue$"); then
	xrdb -merge <<< "awesome.started:true"
	dex -e Awesome -a
fi;

if (command -v gnome-keyring-daemon && ! pgrep gnome-keyring-d); then
    gnome-keyring-daemon --daemonize --login &
fi

if (command -v /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 && ! pgrep polkit-mate-aut) ; then
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &
fi

set colored-completion-prefix on
set colored-stats on

run fusuma -d
run picom --config /home/den/.config/awesome/picom.conf
# run picom --experimental-backends --config /home/den/.config/awesome/picom.conf
#run xfsettingsd --sm-client-disable --disable-wm-check
run clipit
run flameshot
run volumeicon
run blueman-applet
run xautolock -time 30 -locker blurlock
run nm-applet --indicator
run alttab -w 1 -d 1 -s 1 -i 64x64 -theme Numix-Circle -bg _rnd_low
run setxkbmap -model pc104 -layout "us,ru" -option "grp:win_space_toggle"

# sleep 2

# local screen_opts=$(xrandr --current --query | grep -e '^\(\(HDMI\|e\?DP\)-\?[0-9]\) \(connected\)' -o | sed -E 's/(eDP-?[0-9]) connected/--output \1 --primary --mode 1920x1080 --pos 0x840 --rotate normal/g' | sed -E 's/(HDMI-?[0-9]) connected/--output \1 --mode 2560x1440 --pos 1920x0 --rotate normal/g' | paste -s -d " " -)
# run xrandr $(echo "$screen_opts")
