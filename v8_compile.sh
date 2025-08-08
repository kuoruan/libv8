#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"
target_cpu="$1"

v8_dir="${dir}/v8"

if [ ! -d "$v8_dir" ]; then
  echo "v8 not found at $v8_dir"
  exit 1
fi

depot_tools_dir="${dir}/depot_tools"

if [ ! -d "$depot_tools_dir" ]; then
  echo "Error: depot_tools directory not found at ${depot_tools_dir}"
  exit 1
fi

export DEPOT_TOOLS_DIR="$depot_tools_dir"

PATH="${DEPOT_TOOLS_DIR}:$PATH"
export PATH

os="$(sh "${dir}/scripts/get_os.sh")"

cores="2"

if [ "$os" = "Linux" ]; then
  cores="$(grep -c processor /proc/cpuinfo)"
elif [ "$os" = "macOS" ]; then
  cores="$(sysctl -n hw.logicalcpu)"
fi

if [ -z "$target_cpu" ]; then
  target_cpu="$(sh "${dir}/scripts/get_arch.sh")"
fi

echo "Building V8 for $os $target_cpu"

if [ "$os" = "Linux" ]; then
  # https://chromium.googlesource.com/chromium/src/+/master/docs/linux/chromium_arm.md
  python3 "${v8_dir}/build/linux/sysroot_scripts/install-sysroot.py" --arch="$target_cpu"
fi

cc_wrapper=""
if command -v ccache >/dev/null 2>&1 ; then
  cc_wrapper="ccache"
fi

# Ignore comments and empty lines, replace spaces around '=' with no space
gn_args="$(grep -v '^#\|^$' "${dir}/args/${os}.gn" | sed 's/[[:space:]]*=[[:space:]]*/=/g' | tr -d '\r' | tr '\n' ' ')"
gn_args="${gn_args}cc_wrapper=\"$cc_wrapper\""
gn_args="${gn_args} target_cpu=\"$target_cpu\""
gn_args="${gn_args} v8_target_cpu=\"$target_cpu\""

cd "${dir}/v8"

build_dir="./out.gn/${os}.${target_cpu}.release"

if [ -d "$build_dir" ] && [ "$CI" = "true" ]; then
  echo "CI environment detected - cleaning previous build directory"
  rm -rf "$build_dir"
fi

gn gen "$build_dir" --args="$gn_args"

echo "==================== Build args start ===================="
gn args "$build_dir" --list | tee "${dir}/args_${os}.txt"
echo "==================== Build args end ===================="

(
  set -x
  ninja -C "$build_dir" -j "$cores" v8_monolith
)

ls -lh ${build_dir}/obj/libv8_*.a

cd -
