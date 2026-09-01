if [ -z $BASH_INIT_GOLANG ]; then
    source "$HOME/dev/hack/goutils.sh"
    eval $(goverswitch go1.25.5)
    pathmunge "$HOME/go/bin"
    export BASH_INIT_GOLANG=1
fi

