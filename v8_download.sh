#!/bin/sh

PATH="$(pwd)/depot_tools:$PATH"
export PATH

branch="${1:-master}"

gclient sync --no-history --reset -r "$branch"
