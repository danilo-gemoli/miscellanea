if [ -z $BASH_SETUP_X ]; then
    xrdb "$HOME/.Xresources"
    export BASH_SETUP_X=1
fi
