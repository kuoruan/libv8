#!/bin/sh

dir="$(pwd)"

test -d "${dir}/v8" || exit 1

PATH="${dir}/depot_tools:$PATH"
export PATH

gn_args="$(cat "${dir}/args.gn")"

cd "${dir}/v8" || exit 1

processor="$(grep -c processor /proc/cpuinfo)"

gn gen "out/release" --args="$gn_args"
gn args "out/release" --list > "${dir}/gn_args.txt"

ninja -C "out/release" -j "$processor" v8_monolith
