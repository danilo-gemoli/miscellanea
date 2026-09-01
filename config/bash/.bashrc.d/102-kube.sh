if [ -z $BASH_INIT_KUBE ]; then
    pathmunge "$HOME/dev/hack/farms/scripts"
    export BASH_INIT_KUBE=1
fi