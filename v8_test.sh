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
    -pthread -std=c++20 -ldl $macos_frameworks
)

sh -c ./hello_world
