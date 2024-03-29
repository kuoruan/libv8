#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

output_dir="${dir}/pack"

os="$RUNNER_OS"
if [ -z "$os" ]; then
  case "$(uname -s)" in
    Linux)
      os="Linux"
      ;;
    Darwin)
      os="macOS"
      ;;
    *)
      echo "Unknown OS type"
      exit 1
  esac
fi

archive="${1:-v8_${os}_amd64}.tar.xz"

mkdir "$output_dir" || true

cp -r "${dir}/v8/include" \
  "${dir}/v8/out/release/obj/libv8_monolith.a" \
  "${dir}/gn-args_${os}.txt" \
  "$output_dir"

tar -Jcf "${dir}/${archive}" -C "$output_dir" .

ls -lh "${dir}/${archive}"
