if [ -z $CLAUDE_CODE_INIT ]; then
    export CLAUDE_CODE_USE_VERTEX=1
    export CLOUD_ML_REGION=global
    export ANTHROPIC_VERTEX_PROJECT_ID=itpc-gcp-hcm-pe-eng-claude
    export CLAUDE_CODE_BASE="${HOME}/dev/claude-code-base"

    function cc-run() {
        cd "${CLAUDE_CODE_BASE}"
        claude $@
    }

    function cc-mount() {
        local src="$1"

        if [ -z "$src" ]; then
            src="$PWD"
        fi

        local src_basename=$(basename "$src")
        local dst="${CLAUDE_CODE_BASE}/${src_basename}" 

        if [ -e "$dst" ]; then
            echo "${dst} exists already"
            return 1
        fi

        mkdir "$dst"
        sudo mount --rbind "$src" "$dst"
    }

    function cc-mount-list() {
        for x in $(ls -a1 "${CLAUDE_CODE_BASE}"); do
            local target="${CLAUDE_CODE_BASE}/${x}"
            if $(mountpoint -q "$target"); then
                echo "$x"
            fi
        done
    }

    function cc-umount() {
        local target_name="$1"
        if [ -z "$target_name" ]; then
            target_name=$(basename "$PWD")
        fi

        local target="${CLAUDE_CODE_BASE}/${target_name}"
        if ! $(mountpoint -q "$target"); then
            echo "$target is not a mount point"
            return 1
        fi

        sudo umount "$target"
        rmdir "$target"

        echo "$target unmounted"
    }

    function cc-umount-all() {
        for m in $(cc-mount-list); do
            cc-umount "$target"
            if [ -d "$target" ]; then
                rmdir "$target"
            elif [ -f "$target" ]; then
                rm "$target"
            fi
        done
    }

    export -f cc-run
    export -f cc-mount
    export -f cc-mount-list
    export -f cc-umount
    export -f cc-umount-all

    export CLAUDE_CODE_INIT=1
fi
