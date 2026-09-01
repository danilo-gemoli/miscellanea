if [ -z $BASH_INIT_DEVTOOLS ]; then
    export KUBE_EDITOR="vim"

    # Dev
    export dev="$HOME/dev"
    export devworkbench="${dev}/workbench"
    export src="${dev}/src"

    function normalize() { echo -n "$1" | sed -E 's/\-|_//g' | tr '[:upper:]' '[:lower:]'; }
    function ls_dir() { ls -l "${1}" | grep -E '^d' | awk '{print $9}'; }

    # Export all orgs and repos
    for host in $(ls_dir "${src}"); do
        for org in $(ls_dir "${src}/${host}"); do
            org_normalized=$(normalize "$org")
            export "org_${org_normalized}"="${src}/${host}/${org}"
            for repo in $(ls_dir "${src}/${host}/${org}"); do
                repo_normalized=$(normalize "$repo")
                export "repo_${org_normalized}_${repo_normalized}"="${src}/${host}/${org}/${repo}"
            done
        done
    done
    
    # Switch Repository
    function sr() {
        local repos=$(find $src -mindepth 1 -maxdepth 3 -type d | sed -E "s|^$src/|\$src/|")
        local dw=$(find $devworkbench -mindepth 1 -maxdepth 1 -type d | sed -E "s|^$devworkbench/|\$devworkbench/|")
        local chosen=$(printf '%s\n%s\n%s\n%s' "$repos" "$dw" "\$src" "\$devworkbench" | fzf --exact)
        if [ $? -eq 0 -a ! -z "$chosen" ]; then
            local expanded=$(printf '%s' "$chosen" | sed -E \
                "s|\\\$src|$src|
                 s|\\\$devworkbench|$devworkbench|" \
            )
            cd "$expanded"
        fi
    }
    export -f sr

    # Rust
    . "$HOME/.cargo/env"

    export PATH
    export BASH_INIT_DEVTOOLS=1
fi
