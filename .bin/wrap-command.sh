#!/usr/bin/env bash
# Workarounds for hardcoded containerlab paths and
# permission conflicts with containerlab and direnv

CONTAINERLAB="%%CONTAINERLAB_PATH%%/bin/containerlab"

_wrapped() {
    sudo unshare -m /bin/sh -c "
            mount --bind $PROJECT_ROOT/.etc/hosts /etc/hosts &&
            trap 'sudo chown -R $USER:users $PROJECT_ROOT' EXIT &&
            $CONTAINERLAB $*"
}

# Check for an exact match in the arguments array
has_arg() {
    printf "%s" "$1" | grep -qw -- "$2"
}

COMMAND=$1
case $COMMAND in
"completion" | "help" | "generate" | "version")
    $CONTAINERLAB "$@"
    ;;
"deploy" | "dep")
    shift
    ARGS="$*"
    if ! has_arg "$ARGS" "--export-template"; then
        ARGS+=" --export-template $PROJECT_ROOT/.templates/export/auto.tmpl"
    fi
    # shellcheck disable=SC2086
    _wrapped deploy $ARGS
    ;;
"graph")
    shift
    ARGS="$*"
    if ! has_arg "$ARGS" "--static-dir"; then
        ARGS+=" --static-dir $PROJECT_ROOT/.templates/graph/nextui/static"
    fi
    if ! has_arg "$ARGS" "--template"; then
        ARGS+=" --template $PROJECT_ROOT/.templates/graph/nextui/nextui.html"
    fi
    # shellcheck disable=SC2086
    $CONTAINERLAB graph $ARGS
    ;;
*)
    _wrapped "$@"
    ;;
esac
