#!/usr/bin/env bash

IMG_PATH="$PROJECT_ROOT/images"

declare -A KIND_MAP
KIND_MAP["ceos"]="cEOS-lab-(.*[FM])\.tar\.tar"
KIND_MAP["ceos64"]="cEOS64-lab-(.*[FM])\.tar\.tar"

# Determine if we need to sudo
if id -nG "$USER" | grep -qw docker; then
    DOCKER="docker"
else
    sudo -v || exit 1
    DOCKER="sudo docker"
fi

getKindAndVersion() {
    local filename=$1
    for kind in "${!KIND_MAP[@]}"; do
        local pattern=${KIND_MAP[$kind]}
        if [[ $filename =~ $pattern ]]; then
            local vers=${BASH_REMATCH[1]}
            printf "%s %s\n" "$kind" "$vers"
            return 0
        fi
    done
    return 1
}

dispatch() {
    local file=$1
    local kind=$2
    local vers=$3
    case "${kind}" in
    ceos | ceos64)
        local repo_tag="${kind}:${vers}"
        if ! ${DOCKER} images --format '{{.Repository}}:{{.Tag}}' | grep -q "${repo_tag}"; then
            ${DOCKER} import "${file}" "${repo_tag}"
        fi
        ;;
    *) ;;
    esac
}

find "${IMG_PATH}" -type f -print0 | while IFS= read -r -d '' file; do
    if IFS=" " read -r -a kind_vers <<<"$(getKindAndVersion "$(basename "${file}")")"; then
        kind="${kind_vers[0]}"
        vers="${kind_vers[1]}"
        dispatch "$file" "$kind" "$vers"
    fi
done
