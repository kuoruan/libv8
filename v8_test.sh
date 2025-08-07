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

build_dir="${dir}/v8/out.gen/${os}.${target_cpu}.release"

if [ ! -d "$build_dir" ]; then
  echo "Build directory not found: $build_dir"
  exit 1
fi

# Add frameworks and linker settings
if [ "$os" = "macOS" ]; then
  macos_frameworks="-framework Foundation"
  linker_flags=""  # macOS uses system default linker (ld64)
else
  macos_frameworks=""
  linker_flags="-fuse-ld=lld"  # Use LLD on Linux and other platforms
fi

echo "Testing V8 for architecture: $target_cpu"

(
  set -x
  clang++ \
    -std=c++20 \
    -fno-rtti \
    -pthread \
    $linker_flags \
    -DV8_COMPRESS_POINTERS=1 \
    -DV8_ENABLE_SANDBOX \
    -I"${dir}/v8" \
    -I"${dir}/v8/include" \
    "${dir}/v8/samples/hello-world.cc" \
    -o hello_world \
    -L"${build_dir}/obj/" \
    -lv8_monolith \
    -lv8_libbase \
    -lv8_libplatform \
    -ldl \
    $macos_frameworks
)

bin_path="${dir}/hello_world"

if [ -x "$bin_path" ]; then
  echo "Compilation successful, running test..."
  "$bin_path"
else
  echo "Compilation failed"
  exit 1
fi
