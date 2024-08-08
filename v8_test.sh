#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "${dir}/v8" ]; then
  echo "v8 not found"
  exit 1
fi

(
  set -x
  g++ -I"${dir}/v8" -I"${dir}/v8/include" \
    "${dir}/v8/samples/hello-world.cc" -o hello_world \
    -lv8_monolith -L"${dir}/v8/out/release/obj/" \
    -pthread -std=c++20 -ldl
)

sh -c "./hello_world"
