set -e

function indent_out {
    "$@" | sed "s/^/  /"
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
            docker-compose exec -T "$service" "$@" < "$INPUT_FILE" > "$OUTPUT_FILE"
        else
            indent_out docker-compose exec -T "$service" "$@" < "$INPUT_FILE"
        fi
    else
        if [ -n "$OUTPUT_FILE" ]; then
            docker-compose exec -T "$service" "$@" > "$OUTPUT_FILE"
        else
            indent_out docker-compose exec -T "$service" "$@"
        fi
    fi
}
