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
        -l:        Lint. Print lines that do not conform to syntax.
        -g <key>:  Get the value associated with the given key (after any requested stripping)
                   Command exits with a non-zero status code if it isn't found.
                   This is to differentiate between a key that doesn't exist
                   versus an empty value (which is a valid value in VOLL).
        -c <what>: Conform.
                   Valid arguments are "all", "keys", or "values".
                   Conforming currently just strips off surrounding whitespace.
                   Comments and blank lines are left unchanged.
                   Quote stripping arguments are currently ignored.
                   It is always safe to conform keys.
                   Depending on the expectations of ingestingn programs,
                   it may or may not be safe to conform values.

    Basic Formatting flags:
        -w <mode>: How (or if) to do whitespace stripping for returned values.
                   Valid arguments are "all", "left", "right", or "off" (the default).
        -q <mode>: How (or if) to do quote stripping.
                   Valid options are "auto", "single", "double", or "off" (the default).
                   Automatic quote stripping will attempt to strip off double quotes,
                   then will attempt to strip off single quotes.
                   If a value has both, in that order, it will strip off both sets.
                   For this reason, "auto" mode in this tool is not recommended.

    Extended flags:
        All Action and Formatting flags are ignored when any extended flags are used.

        -j <mode>: JSON action.
                   Valid arguments are "write", "read", or "off" (the default).
                   "write" will convert the input voll file to JSON.
                   In "literal" string mode,
                   this mode automatically strips whitespace surrounding values prior to conversion.
                   "read" will treat input as a JSON blob and convert it as output to voll format.
                   Output keys and values are never whitespace padded.
                   Any mode other than "off" will ignore all basic action and formatting options.
        -s <mode>: JSON string mode.
                   Valid arguments are "string", or "literal" (the default).
                   By default, JSON output assumes
                   that VOLL input contains valid JSON literals for values.
                   However, under certain circumstancs it may make more sense
                   to parse all values as just strings.
                   String only mode is safer
                   and cannot fail due to values
                   that do not conform to JSON literal syntax.
                   It can, however, still fail for input
                   that is not in valid VOLL format.
                   Whitespace and quote stripping options are respected in "string" mode,
                   whereas they are ignored in "literal" mode.


EOF_HEREDOC
)

usage() {
    printf '%s' "$USAGE"
    exit "$1"
}

# Action flag options
# - i : identity
# - l : lint
# - g : get value associated with key.
# - a : Conform all (keys and values)
# - k : Conform keys.
# - v : Conform values.
action_flag='i'
get_key=

ws_flag='o'
quote_flag='o'

# JSON Action flag options
# - r : Read JSON from input and output in VOLL format.
# - w : Read VOLL from input and output in JSON format.
# - o : Don't do anything related to JSON (the default).
json_flag='o'

# JSON string mode flag options
# - s : Treat VOLL input values as JSON strings.
# - l : Treat VOLL input values as JSON literals (the default).
json_value_flag='l'

while getopts ":hilg:c:w:q:j:s:" opt; do
    case "${opt}" in
    h)
        usage 0
        ;;
    i)
        action_flag='i'
        ;;
    l)
        action_flag='l'
        ;;
    g)
        action_flag='g'
        get_key="${OPTARG}"
        ;;
    c)
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
    s)
        json_value_flag="$(printf '%.1s' "$OPTARG")"
        ;;
    *)
        usage 2
        ;;
    esac
done
shift $((OPTIND - 1))

# If no input file is given, default to stdin using the `-` file.
# cat will treat this value appropriately.
in_file="${1:-'-'}"

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
    _key="$1"
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

lint_stream() {
    grep -vEHn "${blank_re}|${comment_re}|${main_re}" "$in_file"
}

get_value_by_key() {
    _key="$1"
    is_key "$_key" ||
        (printf '%s' "The given key \"${_key}\" is not valid. Keys must conform to this regex: ${key_re}" 1>&2 && exit 2)
    _safe_key="$(printf '%s' "$_key" | sed -E "s/\./\\./")"

    # Grep is used instead of sed,
    # because it will return a non-zero exit code
    # if no occurrences of the key are found
    # whereas sed will still return zero.

    set -e
    # shellcheck disable=2002
    cat "$in_file" |
        grep -E "^[ \t]*(${_safe_key})[ \t]*=" |
        tail -n 1 |
        sed -E "s/^[ \t]*(${_safe_key})[ \t]*=(.*)$/\2/"
}

voll_to_json() {
    # FIXME: invoke jq only once instead of pipelining it twice.
    # It should be possible to reduce the inputs as an array
    # instead of as a series of inputs.
    # Using the `--slurp` option on the first invocation should make this possible,
    # but the rest of the filtering will need to be refactored to accommodate this change.

    set -e
    # shellcheck disable=2002
    cat "$in_file" | filter_blank_lines |
        filter_comment_lines |
        trim_all |
        jq --raw-input --compact-output 'rtrimstr("\n") | [capture( "^(?<key>[^:]*)=(?<value>.*)$" )] | .[0] | .key as $key | (.value | fromjson) as $value | {} | setpath($key / "."; $value)' |
        jq --slurp 'reduce .[] as $item ({}; . * $item)'
}

json_to_voll() {
    # shellcheck disable=2002
    cat "$in_file" | jq '.'
}

case "${json_flag}" in
w)
    # shellcheck disable=2002
    voll_to_json
    exit
    ;;
r)
    # shellcheck disable=2002
    json_to_voll
    exit
    ;;
o)
    # Do nothing in "off" case.
    ;;
*)
    usage 2
    ;;
esac

# Action flag options
# - i : identity
# - g : get value associated with key.
# - a : conform all (keys and values)
# - k : conform keys.
# - v : conform values.
# action_flag='i'
# get_key=
case "${action_flag}" in
i)
    # Do nothing in "identity" case.
    cat "$in_file"
    exit
    ;;
l)
    lint_stream
    exit
    ;;
g)
    # shellcheck disable=2002
    get_value_by_key "$get_key"
    exit
    ;;
a)
    # conform all
    exit
    ;;
k)
    # conform keys.
    ;;
v)
    # conform values.
    ;;
*)
    usage 2
    ;;
esac
