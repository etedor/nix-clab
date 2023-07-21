#!/usr/bin/env bash

KIND_MAP='linux,bash
          ceos,Cli
          arista_ceos,Cli'

# Determine if we need to sudo
if id -nG "$USER" | grep -qw docker; then
    DOCKER="docker"
else
    sudo -v || exit 1
    DOCKER="sudo docker"
fi

# Check if a container name is provided
if [[ -z $1 ]]; then
    printf "Error: No container specified.\n" >&2
    exit 1
fi

# Get the containerlab node 'kind'
NODE_KIND=$($DOCKER inspect -f '{{ index .Config.Labels "clab-node-kind" }}' "$1")
if [[ -z $NODE_KIND ]]; then
    printf "Error: The specified container is not managed by containerlab.\n" >&2
    exit 1
fi

for MAP in $KIND_MAP; do
    KIND=$(printf "%s" "$MAP" | cut -d',' -f1)
    COMMAND=$(printf "%s" "$MAP" | cut -d',' -f2)

    if [[ $KIND == "$NODE_KIND" ]]; then
        trap 'sudo chown -R $USER:users $PROJECT_ROOT' EXIT && $DOCKER exec -it "$1" "$COMMAND"
        exit 0
    fi
done

printf "Error: No matching kind found for the container.\n" >&2
exit 1
