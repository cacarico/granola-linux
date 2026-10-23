#!/bin/sh
# Read commit subjects, one per line, on stdin and fail if any is not a
# conventional subject with a scope, names a pull request or issue number,
# or is a fixup!, squash! or amend! commit that was never folded in.
set -eu

types='build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test'
pattern="^($types)\([a-z0-9][a-z0-9._/-]*\)!?: [^ ]"
status=0

while IFS= read -r subject || [ -n "$subject" ]; do
  case $subject in
    'fixup! '* | 'squash! '* | 'amend! '*)
      echo "not folded into the commit it changes: $subject" >&2
      status=1
      continue
      ;;
  esac
  if ! printf '%s\n' "$subject" | grep -Eq "$pattern"; then
    echo "not a conventional subject with a scope: $subject" >&2
    status=1
  elif printf '%s\n' "$subject" | grep -Eq '#[0-9]'; then
    echo "names a #number: $subject" >&2
    status=1
  fi
done

exit "$status"
