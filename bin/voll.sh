#!/bin/sh

USAGE=$(
    cat <<'EOF_HEREDOC'
usage: voll [-a] [-d] [-s] [-o]

Whitespace stripping is done before quote stripping.
Quote stripping will strip (at most) one pair of quotes off the value.
Arguments to options can be specified as single letters instead of words.
For example `-n k` instead of `-n keys`.

Option flags MUST come before arguments.

    Basic Action flags:
        -h:        Print help and exit.
        -i:        Identity. Literally just sends out what came in.
                   This is the default action.
        -g <key>:  Get the value associated with the given key (after any requested stripping)
                   Command exits with a non-zero return code of 3 if it isn't found.
                   This is to differentiate between a key that doesn't exists
                   versus an empty value (which is a possible return value).
        -n <what>: Normalize format.
                   Valid arguments are "all", "keys", or "values".
                   Normalizing currently just strips off surrounding whitespace.
                   Comments and blank lines are left unchanged.
                   Quote stripping arguments are currently ignored.

    Basic Formatting flags:
        -w <mode>: How (or if) to do whitespace stripping.
                   Valid arguments are "all", "left", "right", or "off" (the default).
        -q <mode>: How (or if) to do quote stripping.
                   Valid options are "auto", "single", "double", or "off" (the default).
                   Automatic quote stripping cannot be done in a streaming fashion
                   and should be avoided on files too large to fit in memory.

    Extended flags:
        All Action and Formatting flags are ignored when any extended flags are used.

        -j <mode>: JSON action.
                   Valid arguments are "write", "read", or "off" (the default).
                   "write" will convert the input voll file to JSON.
                   This mode automatically strips whitespace surrounding values prior to conversion.
                   "read" will treat input as a JSON blob and convert it as output to voll format.
                   Output keys and values are never whitespace padded.
                   Any mode other than "off" will ignore all basic action and formatting options.

EOF_HEREDOC
)

usage() {
    printf '%s' "$USAGE"
    exit "$1"
}

# Action flag options
# - i : identity
# - g : get value associated with key.
# - a : Normalize all (keys and values)
# - k : Normalize keys.
# - v : Normalize values.
action_flag='i'
get_key=

ws_flag='o'
quote_flag='o'
json_flag='o'

while getopts ":hig:n:w:q:j:" opt; do
    case "${opt}" in
    h)
        usage 0
        ;;
    i)
        action_flag='i'
        ;;
    g)
        action_flag='g'
        get_key="${OPTARG}"
        ;;
    n)
        action_flag="$(printf '%.1s' "$OPTARG")"
        ;;
    w)
        ws_flag="$(printf '%.1s' "$OPTARG")"
        ;;
    q)
        quote_flag="$(printf '%.1s' "$OPTARG")"
        ;;
    j)
        json_flag="$(printf '%.1s' "$OPTARG")"
        ;;
    *)
        usage 2
        ;;
    esac
done
shift $((OPTIND - 1))

ws_re='[ \t]*'
key_re='[a-zA-Z][a-zA-Z0-9_.]*'
safe_key_re='s/\./\\./'
main_re='^[ \t]*([a-zA-Z][a-zA-Z0-9_.]*)[ \t]*=(.*)$'
main_ltrim_value_re='^[ \t]*([a-zA-Z][a-zA-Z0-9_.]*)[ \t]*=[ \t]*(.*)$'
comment_re='^[ \t]*(#.*)$'
blank_re='^[ \t]*$'
list_key_re="s/${main_re}/\1/"
list_value_re="s/${main_re}/\2/"
ltrim_sed_re='s/^[ \t]*//'
rtrim_sed_re='s/[ \t]*$//'

_sed_cmd_str=""

filter_blank_lines() {
    sed -E "/${blank_re}/d"
}

filter_comment_lines() {
    sed -E "/${comment_re}/d"
}

is_key() {
    _key="$(cat)"
    if [ -n "${_key}" ] && [ "$(printf '%s' "${_key}" | wc -l)" -le '1' ]; then
        # `grep` returns non-zero when it finds no matches.
        # `sed` only returns non-zero on error.
        # It isn't clear that this counts as an error.
        printf '%s' "${_key}" | grep -E "^${key_re}$" >/dev/null
    else
        return 1
    fi
}

list_keys() {
    sed -E "${list_key_re}"
}

list_values() {
    sed -E "${list_value_re}"
}

ltrim_lines() {
    sed -E "${ltrim_sed_re}"
}

rtrim_lines() {
    sed -E "${rtrim_sed_re}"
}

trim_all() {
    sed -E "s/${main_ltrim_value_re}/\1=\2/; ${rtrim_sed_re}"
}

voll_to_json() {
    filter_blank_lines |
        filter_comment_lines |
        trim_all |
        jq --raw-input --compact-output 'rtrimstr("\n") | [capture( "^(?<key>[^:]*)=(?<value>.*)$" )] | .[0] | .key as $key | (.value | fromjson) as $value | {} | setpath($key / "."; $value)' |
        jq --slurp 'reduce .[] as $item ({}; . * $item)'
    # jq 'rtrimstr("\n") | [capture( "^(?<key>[^:]*)=(?<value>.*)$" )] | .[0] | .key as $key | (.value | fromjson) as $value | {} | setpath($key / "."; $value) ' --raw-input
    # jq 'rtrimstr("\n") | [capture( "^(?<key>[^:]*)=(?<value>.*)$" )] | .[0] | .key as $key | (.value | fromjson) as $value| from_entries | del([$key]) | setpath($key / "."; $value) ' --raw-input
    # jq 'rtrimstr("\n") | [capture( "^(?<key>[^:]*)=(?<value>.*)$" )] | from_entries | with_entries(.value = (.value | fromjson)) | foreach .[] as $item ({}; $item; setpath($item.key / "."; $item.value) ) ' --raw-input
}

json_to_voll() {
    cat | jq '. / "\n"' --raw-input --slurp
}

# shellcheck disable=2002
# cat "$1" | voll_filter_comment_lines | voll_filter_blank_lines | voll_list_values
# cat "$1" | voll_filter_comment_lines | voll_filter_blank_lines | voll_list_keys

case "${json_flag}" in
r)
    cat "$1" | voll_to_json
    exit
    ;;
w)
    cat "$1" | json_to_voll
    exit
    ;;
o)
    # Do nothing in "off" case.
    ;;
*)
    usage 2
    ;;
esac
