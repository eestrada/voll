#!/bin/sh

_ws_re='[ \t]*'
_key_re='[a-zA-Z][a-zA-Z0-9_.]*'
_safe_key_re='s/\./\\./'
_main_re='^[ \t]*([a-zA-Z][a-zA-Z0-9_.]*)[ \t]*=(.*)$'
_comment_re='^[ \t]*(#.*)$'
_blank_re='^[ \t]*$'
_list_key_re="s/${_main_re}/\1/"
_list_value_re="s/${_main_re}/\2/"
_ltrim_re='s/^[ \t]*//'
_rtrim_re='s/[ \t]*$//'
_rtrim_re='s/[ \t]*$//'

voll_filter_blank_lines() {
    grep -v -E "${_blank_re}"
}

voll_filter_comment_lines() {
    grep -v -E "${_comment_re}"
}

voll_is_key() {
    _key="$(cat)"
    if [ -n "${_key}" ] && [ "$(printf '%s' "${_key}" | wc -l)" -le '1' ]; then
        printf '%s' "${_key}" | grep -E "^${_key_re}$" >/dev/null
    else
        return 1
    fi
}

voll_list_keys() {
    sed -E "${_list_key_re}"
}

voll_list_values() {
    sed -E "${_list_value_re}"
}

voll_ltrim_lines() {
    sed -E "${_ltrim_re}"
}

voll_rtrim_lines() {
    sed -E "${_rtrim_re}"
}

# shellcheck disable=2002
cat "$1" | voll_filter_comment_lines | voll_filter_blank_lines | voll_list_values
cat "$1" | voll_filter_comment_lines | voll_filter_blank_lines | voll_list_keys

# printf 'en\nrico\n' | voll_is_key
echo $?
