#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "${dir}/v8" ]; then
	echo "v8 not found"
	exit 1
fi

PATH="${dir}/depot_tools:$PATH"
export PATH

os=""

cores="2"
cc_wrapper=""

case "$(uname -s)" in
	Linux)
		cores="$(grep -c processor /proc/cpuinfo)"
		os="Linux"
		;;
	Darwin)
		cores="$(sysctl -n hw.logicalcpu)"
		os="macOS"
		;;
	*)
		echo "Unknown OS type"
		exit 1
esac

if command -v ccache >/dev/null 2>&1 ; then
  cc_wrapper="ccache"
fi

gn_args="$(grep -v "^#" "${dir}/args/${os}.gn" | grep -v "^$")
cc_wrapper=\"$cc_wrapper\""

cd "${dir}/v8"

gn gen "./out/release" --args="$gn_args"

echo "==================== Build args start ===================="
gn args "./out/release" --list | tee "${dir}/gn-args_${os}.txt"
echo "==================== Build args end ===================="

(
	set -x
	ninja -C "./out/release" -j "$cores" v8_monolith
)

ls -lh ./out/release/obj/libv8_*.a

cd -
