#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "${dir}/v8" ]; then
  echo "v8 not found"
  exit 1
fi

os="$(sh "${dir}/scripts/get_os.sh")"
target_cpu="$(sh "${dir}/scripts/get_arch.sh")"

# Set compiler based on architecture and OS
case "$target_cpu" in
  x64)
    cc_flags="-m64"
    ;;
  x86)
    cc_flags="-m32"
    ;;
  arm64)
    cc_flags=""
    ;;
  arm)
    cc_flags=""
    ;;
  *)
    cc_flags=""
    ;;
esac

# Add macOS-specific frameworks
if [ "$os" = "macOS" ]; then
  macos_frameworks="-framework CoreFoundation"
else
  macos_frameworks=""
fi

echo "Testing V8 for architecture: $target_cpu"

(
  set -x
  g++ -I"${dir}/v8" -I"${dir}/v8/include" \
    "${dir}/v8/samples/hello-world.cc" -o hello_world \
    -lv8_monolith -L"${dir}/v8/out/release/obj/" \
    -pthread -std=c++20 -ldl $cc_flags $macos_frameworks
)

sh -c ./hello_world
