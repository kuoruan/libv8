#!/bin/sh

set -e

dir="$(pwd)"

(
    set -x
    g++ -I"${dir}/v8" -I"${dir}/v8/include" \
        hello-world.cc -o hello_world \
        -lv8_monolith -L"${dir}/out.gn/release/obj" \
        -pthread -std=c++14 -DV8_COMPRESS_POINTERS
)

sh -c "./hello_word"