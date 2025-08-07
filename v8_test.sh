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

os="$(sh "${dir}/scripts/get_os.sh")"

build_dir="${dir}/v8/out.gen/${os}.${target_cpu}.release"

if [ ! -d "$build_dir" ]; then
  echo "Build directory not found: $build_dir"
  exit 1
fi

# https://clang.llvm.org/docs/CrossCompilation.html#general-cross-compilation-options-in-clang
if [ "$os" = "macOS" ]; then
  framework_flags="-framework Foundation"
  linker_flags=""  # macOS uses system default linker (ld64)

  case "$target_cpu" in
    x64)
      target_flags="--target=x86_64-apple-darwin"
      ;;
    arm64)
      target_flags="--target=arm64-apple-darwin"
      ;;
    *)
      target_flags=""
      ;;
  esac
else
  framework_flags=""
  linker_flags="-fuse-ld=lld"  # Use LLD on Linux and other platforms

  case "$target_cpu" in
    x64)
      target_flags="--target=x86_64-linux-gnu"
      ;;
    x86)
      target_flags="--target=i386-linux-gnu"
      ;;
    arm)
      target_flags="--target=arm-linux-gnueabihf"
      ;;
    arm64)
      target_flags="--target=aarch64-linux-gnu"
      ;;
    *)
      target_flags=""
      ;;
  esac
fi

echo "Building hello world for architecture: $target_cpu"

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
    $framework_flags \
    $target_flags
)

if [ "$target_cpu" != "$current_cpu" ]; then
  echo "Cross-compilation successful for $target_cpu"
  echo "Skipping run test for architecture: $target_cpu (current: $current_cpu)"
  exit 0
fi

bin_path="${dir}/hello_world"

if [ -x "$bin_path" ]; then
  echo "Compilation successful, running test..."
  "$bin_path"
else
  echo "Compilation failed"
  exit 1
fi
