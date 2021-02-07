#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

test -d "${dir}/v8"

PATH="${dir}/depot_tools:$PATH"
export PATH

echo "PATH: $PATH"

gn_args="$(cat "${dir}/args.gn")"

cd "${dir}/v8"

cores="2"
is_clang="false"

case "$(uname -s)" in
	Linux)
		cores="$(grep -c processor /proc/cpuinfo)"
		;;
	Darwin)
		cores="$(sysctl -n hw.logicalcpu)"
		is_clang="true"
		;;
esac

gn_args="$(eval "printf \"$gn_args\" \"$is_clang\"")"

gn gen "out/release" --args="$gn_args"
gn args "out/release" --list > "${dir}/gn_args.txt"

(
	set -x
	ninja -C "out/release" -j "$cores" v8_monolith
)

ls -lh out/release/obj/libv8_*.a

cp -f out/release/obj/libv8_monolith.a "$dir"
