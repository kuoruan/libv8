#!/bin/sh

set -e

dir="$(cd "$(dirname "$0")" && pwd)"
arch="$1"

current_arch="$(sh "${dir}/scripts/get_arch.sh")"

if [ -z "$arch" ]; then
  arch="$current_arch"
fi

if [ "$arch" == "$current_arch" ]; then
  echo "Ignoring installation for current architecture: $arch"
  exit 0
fi

deps=""

case "$arch" in
  x86)
    deps="libc6-dev-i386"
    ;;
  x64)
    ;;
  arm)
    deps="crossbuild-essential-armhf"
    ;;
  arm64)
    deps="crossbuild-essential-arm64"
    ;;
  *)
    ;;
esac

if [ -z "$deps" ]; then
  echo "Nothing to install for architecture: $arch"
  exit 0
fi

(
  set -x

  sudo apt-get update
  sudo apt-get install -yq $deps
)

echo "Cross-compilation tools installed for architecture: $arch"
