#!/bin/sh

pwd="$(pwd)"

PATH="${pwd}/depot_tools:$PATH"
export PATH

gn_args="$(cat "${pwd}/args.gn")"

cd "${pwd}/v8" || exit 1

processor="$(grep -c processor /proc/cpuinfo)"

gn gen "${pwd}/v8/out/x64.release" --args="$gn_args"
gn args "${pwd}/v8/out/x64.release" --list > "${pwd}/gn_args.txt"

ninja -C "${pwd}/v8/out/x64.release" -j "$processor" v8_monolith
