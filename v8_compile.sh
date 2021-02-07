#!/bin/sh

set -e

dir="$(pwd)"

test -d "${dir}/v8" || exit 1

PATH="${dir}/depot_tools:$PATH"
export PATH

gn_args="$(cat "${dir}/args.gn")"

cd "${dir}/v8" || exit 1

cores="2"

case "$(uname -s)" in
	Linux)
		cores="$(grep -c processor /proc/cpuinfo)"
		;;
	Darwin)
		cores="$(sysctl -n hw.logicalcpu)"
		;;
esac

gn gen "out/release" --args="$gn_args"
gn args "out/release" --list > "${dir}/gn_args.txt"

(
	set -x
	ninja -C "out/release" -j "$cores" v8_monolith
)


ls -lh out/release/obj/*.a
