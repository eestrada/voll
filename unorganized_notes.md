Related Links:

- Suggestions on sourcing environment variables in POSIX shell
  with characters other than ASCII letters, numbers alphanum, and underscore:
  <https://stackoverflow.com/a/58734692/1733321>
- Basic hashmap in POSIX shell using the filesystem and secure hash algorithms:
  <https://www.baeldung.com/linux/posix-shell-array#associative-arrays--hash-maps>
- grep fixed strings from input: <https://stackoverflow.com/a/3242906/1733321>
- How to use `env` to parse out a value:
  ```sh
  env -i "one.two=three.four" | tail -n 1 | grep -F "one.two=" | tail -n 1 | sed 's/[^=]*=\(.*\)/\1/'
  ```
