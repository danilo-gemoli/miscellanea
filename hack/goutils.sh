function gover_switcher() {
    GO_VERSION="$1"
    PRINT_ENV="$2"

    if [ -z "$GO_VERSION" ]; then
        return 1
    fi

    GO_INSTALLATION_DIR="$HOME/sdk/$GO_VERSION"

    if [ ! -z "$CURRENT_GO_VERSION" ]; then
        CURRENT_GO_INSTALLATION_DIR="$HOME/sdk/$CURRENT_GO_VERSION"
        pathreplace "$CURRENT_GO_INSTALLATION_DIR/bin" "$GO_INSTALLATION_DIR/bin"
    else
        GO_INSTALLATION_DIR="$HOME/sdk/$GO_VERSION"
        pathmunge "$GO_INSTALLATION_DIR/bin"
    fi
    
    if [[ "$PRINT_ENV" == "env" ]]; then
        printf "export PATH=\"$PATH\"\nexport CURRENT_GO_VERSION=\"$GO_VERSION\""
    else
        export PATH
        export CURRENT_GO_VERSION=$GO_VERSION
    fi
}
