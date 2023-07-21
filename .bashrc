#!/bin/bash

# shellcheck disable=SC1090
source <(containerlab completion bash)
source <(sed 's/containerlab/clab/g' <(containerlab completion bash))

# Container name completion for "cli" command:
# https://github.com/docker/docker-ce/blob/master/components/cli/contrib/completion/bash/docker
__docker_q() {
    docker ${host:+--host "$host"} ${config:+--config "$config"} ${context:+--context "$context"} "$@" 2>/dev/null
}

# shellcheck disable=SC2207
_cli() {
    # Only complete if there is exactly one container specified
    if [ "${#COMP_WORDS[@]}" -ne 2 ]; then
        return
    fi

    local containers=($(__docker_q ps -a -q --no-trunc --filter "name=clab-"))
    local names=($(__docker_q inspect --format '{{.Name}}' "${containers[@]}"))
    names=("${names[@]#/}") # trim off the leading "/" from the container names

    local cur=$2
    COMPREPLY=()
    for name in "${names[@]}"; do
        if [[ $name =~ $cur ]]; then
            COMPREPLY+=($(compgen -W "${name}" -- "$cur"))
        fi
    done
}

complete -F _cli cli

cd ./topos || exit

clear
printf "                           _                   _       _     \n"
printf "                 _        (_)                 | |     | |    \n"
printf " ____ ___  ____ | |_  ____ _ ____   ____  ____| | ____| | _  \n"
printf "/ ___) _ \|  _ \|  _)/ _  | |  _ \ / _  )/ ___) |/ _  | || \ \n"
printf "( (__| |_|| | | | |_( ( | | | | | ( (/ /| |   | ( ( | | |_) )\n"
printf "\____)___/|_| |_|\___)_||_|_|_| |_|\____)_|   |_|\_||_|____/ \n"
