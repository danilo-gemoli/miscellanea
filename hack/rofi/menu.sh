desc=()                        cmds=()

desc+=('Enable display')       cmds+=('xrandr --output eDP-1 --auto --right-of DP-1-1-5')
desc+=('Disable display')      cmds+=('xrandr --output eDP-1 --off')
desc+=('Suspend')              cmds+=('systemctl suspend')
desc+=('Shut Down')            cmds+=('shutdown -P now')

function descriptions() {
    for d in "${desc[@]}"; do
        echo "$d"
    done
}

function run() {
    d="$1"
    for i in ${!desc[@]}; do
        if [ "$d" == "${desc[$i]}" ]; then
            ${cmds[$i]}
        fi
    done
}

selection=$(descriptions | rofi -dmenu)

if [[ ($? -eq 0 || ($? -ge 10 && $? -le 28 )) && ! -z "$selection" ]]; then
    run "$selection"
fi
