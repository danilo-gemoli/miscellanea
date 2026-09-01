if [ -z $BASH_INIT_COMMON ]; then
    source "$HOME/dev/hack/shutils.sh"
    pathmunge "$HOME/dev/hack/go"
    export PATH
    export MANPAGER="vim -M +MANPAGER -c 'map q :q<CR>' -c 'map d <C-d>' -c 'map u <C-u>' -c 'set nu' -c 'set wrap' -c 'set breakindent' --not-a-term -"
    export BASH_INIT_COMMON=1
fi
