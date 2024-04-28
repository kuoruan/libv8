#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"
v8_dir="${dir}/v8"

if [ ! -d "$v8_dir" ]; then
  echo "v8 not found at $v8_dir"
  exit 1
fi

depot_tools_dir="${v8_dir}/third_party/depot_tools"

if [ ! -d "$depot_tools_dir" ]; then
  depot_tools_dir="${dir}/depot_tools"
fi

PATH="${depot_tools_dir}:$PATH"
export PATH

os="$RUNNER_OS"

if [ -z "$os" ]; then
  case "$(uname -s)" in
    Linux)
      os="Linux"
      ;;
    Darwin)
      os="macOS"
      ;;
    *)
      echo "Unknown OS type"
      exit 1
  esac
fi

cores="2"

if [ "$os" = "Linux" ]; then
  cores="$(grep -c processor /proc/cpuinfo)"
elif [ "$os" = "macOS" ]; then
  cores="$(sysctl -n hw.logicalcpu)"
fi

if [ -n "$RUNNER_ARCH" ]; then
  target_cpu="$(echo $RUNNER_ARCH | tr '[:upper:]' '[:lower:]')"
else
  case "$(uname -m)" in
    x86_64)
      target_cpu="x64"
      ;;
    x86|i386|i686)
      target_cpu="x86"
      ;;
    arm64|aarch64)
      target_cpu="arm64"
      ;;
    arm*)
      target_cpu="arm"
      ;;
  esac
fi

echo "Building V8 for $os $target_cpu"

cc_wrapper=""
if command -v ccache >/dev/null 2>&1 ; then
  cc_wrapper="ccache"
fi

gn_args="$(grep -v "^#" "${dir}/args/${os}.gn" | grep -v "^$")
cc_wrapper=\"$cc_wrapper\"
target_cpu=\"$target_cpu\"
v8_target_cpu=\"$target_cpu\""

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
