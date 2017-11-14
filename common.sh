set -e

function indent_out {
    "$@" | sed "s/^/  /"
}

function docker_exec {
    # work around for https://github.com/docker/compose/issues/3352
    local service=$1
    shift
    local flags="-i"
    if tty -s; then
        flags="${flags}t"
    fi
    docker exec $flags $(docker-compose ps -q "$service") "$@"
}

function run {
    local service="$1"
    shift
    local extra=()
    while [ $# -gt 2 ]; do
        case "${@: -2:1}" in
        \<)
            local INPUT_FILE="${@: -1}"
            extra=("${@:${#}-1:2}" "${extra[@]}")
            set -- "${@:1:${#}-2}"
            ;;
        \>)
            local OUTPUT_FILE="${@: -1}"
            extra=("${@:${#}-1:2}" "${extra[@]}")
            set -- "${@:1:${#}-2}"
            ;;
        *)
            break
        esac
    done
    echo "$@" "${extra[@]}" | awk "NR==1{print \"  $service\$ \" \$0; next} {print \"  > \" \$0}"
    if [ -n "$INPUT_FILE" ]; then
        if [ -n "$OUTPUT_FILE" ]; then
            docker_exec "$service" "$@" < "$INPUT_FILE" > "$OUTPUT_FILE"
        else
            indent_out docker_exec "$service" "$@" < "$INPUT_FILE"
        fi
    else
        if [ -n "$OUTPUT_FILE" ]; then
            docker_exec "$service" "$@" > "$OUTPUT_FILE"
        else
            indent_out docker_exec "$service" "$@"
        fi
    fi
}
