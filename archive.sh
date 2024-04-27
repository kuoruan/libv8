#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"

archive_name="$1"
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

if [ -z "$archive_name" ]; then
  if [ -n "$RUNNER_ARCH" ]; then
    arch="$(echo $RUNNER_ARCH | tr '[:upper:]' '[:lower:]')"
  else
    case "$(uname -m)" in
      x86_64)
        arch="x64"
        ;;
      x86|i386|i686)
        arch="x86"
        ;;
      arm64|aarch64)
        arch="arm64"
        ;;
      arm*)
        arch="arm"
        ;;
    esac
  fi

  archive="v8_${os}_${arch}.tar.xz"
else
  archive="${archive_name}.tar.xz"
fi

mkdir "$output_dir" || true

cp -r "${dir}/v8/include" \
  "${dir}/v8/out/release/obj/libv8_monolith.a" \
  "${dir}/gn-args_${os}.txt" \
  "$output_dir"

tar -Jcf "${dir}/${archive}" -C "$output_dir" .

ls -lh "${dir}/${archive}"
