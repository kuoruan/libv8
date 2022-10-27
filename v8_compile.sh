#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "${dir}/v8" ]; then
	echo "v8 not found"
	exit 1
fi

PATH="${dir}/depot_tools:$PATH"
export PATH

cores="2"
is_clang="false"
cc_wrapper=""

case "$(uname -s)" in
	Linux)
		cores="$(grep -c processor /proc/cpuinfo)"
		;;
	Darwin)
		cores="$(sysctl -n hw.logicalcpu)"
		is_clang="true"
		;;
esac

if command -v ccache >/dev/null 2>&1 ; then
    cc_wrapper="ccache"
fi

gn_args="$(grep -v "^#" "${dir}/args.gn" | grep -v "^$")
is_clang=$is_clang
cc_wrapper=\"$cc_wrapper\""

cd "${dir}/v8"

gn gen "out/release" --args="$gn_args"
gn args "out/release" --list > "${dir}/gn_args.txt"

(
	set -x
	ninja -C "out/release" -j "$cores" v8_monolith
)

ls -lh out/release/obj/libv8_*.a

cp -f out/release/obj/libv8_monolith.a "$dir"
