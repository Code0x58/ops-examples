set -e

function indent_in {
    sed "s/^/  /"
}

function run {
    # run container command [args...] [< input] [> output]
    # prints and execs a command in a container, optionally with redirection
    local service="$1"
    shift
    local extra=()
    local INPUT_FILE=/dev/stdin
    local OUTPUT_FILE=/dev/stdout
    # pop off redirections from the arguments
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
    # print the command line with a pretend shell prompt
    echo "$@" "${extra[@]}" | awk "NR==1{print \"  $service\$ \" \$0; next} {print \"  > \" \$0}"
    # if output file is stdout, then indent
    if [ "$OUTPUT_FILE" = /dev/stdout ]; then
        docker-compose exec -T "$service" "$@" < "$INPUT_FILE" | indent_in
    else
        docker-compose exec -T "$service" "$@" < "$INPUT_FILE" > "$OUTPUT_FILE"
    fi
}
