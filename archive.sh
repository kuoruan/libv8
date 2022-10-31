#!/bin/sh

set -e

output_dir="${GITHUB_WORKSPACE}/pack"

archive="v8_${RUNNER_OS}_amd64.tar.xz"

mkdir "$output_dir"

cp -r "${GITHUB_WORKSPACE}/v8/include" \
  "${GITHUB_WORKSPACE}/v8/out/release/obj/libv8_monolith.a" \
  "${GITHUB_WORKSPACE}/gn-args_${RUNNER_OS}.txt" \
  "$output_dir"

tar -Jcf "${GITHUB_WORKSPACE}/${archive}" -C "$output_dir" .

ls -lh "${GITHUB_WORKSPACE}/${archive}"

echo "archive=$archive" >> $GITHUB_OUTPUT
