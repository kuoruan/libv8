#!/bin/sh

set -e

dir="$(pwd)"

PATH="${dir}/depot_tools:$PATH"
export PATH

version="$(cat "${dir}/VERSION")"

branch="${1:-"$version"}"

test -n "$branch" || exit 1

(
    set -x
    gclient sync --no-history --reset -r "$branch"
)
