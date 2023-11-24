#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

output_dir="${dir}/pack"

archive="${1:-v8_${RUNNER_OS}_amd64}.tar.xz"

mkdir "$output_dir" || true

cp -r "${dir}/v8/include" \
  "${dir}/v8/out/release/obj/libv8_monolith.a" \
  "${dir}/gn-args_${RUNNER_OS}.txt" \
  "$output_dir"

tar -Jcf "${dir}/${archive}" -C "$output_dir" .

ls -lh "${dir}/${archive}"
