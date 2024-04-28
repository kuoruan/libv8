#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

PATH="${dir}/depot_tools:$PATH"
export PATH

export DEPOT_TOOLS_UPDATE=0

version="$(head -n1 "${dir}/VERSION" | cut -d'-' -f1)"

branch="${1:-"$version"}"

test -n "$branch"

(
  set -x
  gclient sync --no-history --reset -r "$branch"
)
