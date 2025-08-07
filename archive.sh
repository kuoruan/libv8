#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"
arch="$1"

output_dir="${dir}/pack"

os="$(sh "${dir}/scripts/get_os.sh")"

if [ -z "$arch" ]; then
  arch="$(sh "${dir}/scripts/get_arch.sh")"
fi

build_dir="${dir}/v8/out.gen/${os}.${arch}.release"

if [ ! -d "$build_dir" ]; then
  echo "Build directory not found: $build_dir"
  exit 1
fi

archive_name="v8_${os}_${arch}"
archive="${archive_name}.tar.xz"

if [ -z "$GITHUB_ENV" ]; then
  echo "GITHUB_ENV is not set, skipping environment variable export."
else
  echo "Using Archive Name: $archive_name"
  echo "ARCHIVE_NAME=$archive_name" >> "$GITHUB_ENV"
fi

mkdir "$output_dir" || true

cp -r "${dir}/v8/include" \
  "${build_dir}/obj/libv8_monolith.a" \
  "${dir}/gn-args_${os}.txt" \
  "$output_dir"

tar -Jcf "${dir}/${archive}" -C "$output_dir" .

ls -lh "${dir}/${archive}"
