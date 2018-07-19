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
    # print out each part, with quoting as necissary
    (
        for arg in "$@"; do
            # if the arg needs escaping
            if echo -n "$arg" | grep --silent --extended-regexp '\s|\$|`|!|&|\||<|>|'"'"; then
                if ! echo -n "$arg" | grep --silent "'"; then
                    # can use hard quoting
                    arg="'$arg'"
                else
                    # need to escape in quoting
                    # if it starts with <>&| then escape it too
                    arg="\"$(echo "$arg" | sed --regexp-extended 's#[$`"\\]#\\&#g')\""
                fi
            fi
            echo -n "$arg "
        done
        echo "${extra[@]}"
    ) | awk "NR==1{print \"  $service\$ \" \$0; next} {print \"  > \" \$0}"
    # if output file is stdout, then indent
    if [ "$OUTPUT_FILE" = /dev/stdout ]; then
        docker-compose exec -T "$service" "$@" < "$INPUT_FILE" | indent_in
    else
        docker-compose exec -T "$service" "$@" < "$INPUT_FILE" > "$OUTPUT_FILE"
    fi
}
