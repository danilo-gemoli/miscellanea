pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

pathreplace() {
    old="$1"
    new="$2"
    PATH=$(printf "$PATH" | tr ':' '\n' | sed -E "s|^$old$|$new|g" | tr '\n' ':' | sed -E 's|\:$||g')
}

pathremove() {
    for x in $@; do
        PATH=$(printf $PATH | tr ':' '\n' | grep -vE "^$x$" | tr '\n' ':' | sed -E 's|\:$||g')
    done
}
