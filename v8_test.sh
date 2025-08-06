#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"
target_cpu="$1"

if [ ! -d "${dir}/v8" ]; then
  echo "v8 not found"
  exit 1
fi

current_cpu="$(sh "${dir}/scripts/get_arch.sh")"

if [ -z "$target_cpu" ]; then
  target_cpu="$current_cpu"
fi

if [ "$target_cpu" != "$current_cpu" ]; then
  echo "Skipping test for architecture: $target_cpu (current: $current_cpu)"
  exit 0
fi

os="$(sh "${dir}/scripts/get_os.sh")"

# Add macOS-specific frameworks
if [ "$os" = "macOS" ]; then
  macos_frameworks="-framework Foundation"
else
  macos_frameworks=""
fi

echo "Testing V8 for architecture: $target_cpu"

(
  set -x
  clang++ -I"${dir}/v8" -I"${dir}/v8/include" \
    "${dir}/v8/samples/hello-world.cc" -o hello_world -fno-rtti \
    -lv8_monolith -ldl -L"${dir}/v8/out/release/obj/" \
    -pthread -std=c++20 -fuse-ld=lld $macos_frameworks \
    -DV8_COMPRESS_POINTERS=1 -DV8_ENABLE_SANDBOX
)

sh -c ./hello_world
