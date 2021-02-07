#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

(
	set -x
	g++ -I"${dir}/v8/include" \
		hello-world.cc -o hello_world \
		-lv8_monolith -L"$dir" -L"${dir}/v8/out/release/obj" \
		-pthread -std=c++14 -DV8_COMPRESS_POINTERS
)

sh -c "./hello_world"
