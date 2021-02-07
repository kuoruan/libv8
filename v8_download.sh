#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

PATH="${dir}/depot_tools:$PATH"
export PATH

version="$(cat "${dir}/VERSION")"

branch="${1:-"$version"}"

test -n "$branch"

(
	set -x
	gclient sync --no-history --reset -r "$branch"
)
