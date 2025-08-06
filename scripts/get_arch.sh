#!/bin/sh

set -e

arch=""

# X86, X64, ARM, or ARM64
if [ -n "$RUNNER_ARCH" ]; then
  arch="$(echo "$RUNNER_ARCH" | tr '[:upper:]' '[:lower:]')"
else
  case "$(uname -m)" in
    x86_64|amd64)
      arch="x64"
      ;;
    x86|i386|i486|i586|i686)
      arch="x86"
      ;;
    arm64|aarch64|armv8*)
      arch="arm64"
      ;;
    arm|armv6*|armv7*)
      arch="arm"
      ;;
    *)
      ;;
  esac
fi

if [ -z "$arch" ]; then
  echo "Unknown architecture type" >&2
  exit 1
fi

echo "$arch"
