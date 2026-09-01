if [ -z $BASH_INIT_BASH ]; then
    export EDITOR="vim"
    export BASH_INIT_BASH=1

    # Switch Directory
    function sd() {
        selected="$(find $PWD -maxdepth 5 -type d | fzf --exact --exit-0)"
        [ $? -eq 0 ] && cd "$selected"
    }

    export -f sd
fi
