#!/bin/sh

set -e

os=""

# Linux, Windows, or macOS
if [ -n "$RUNNER_OS" ]; then
  os="$RUNNER_OS"
else
  case "$(uname -s)" in
    Linux|linux)
      os="Linux"
      ;;
    macOS|macos|Darwin|darwin)
      os="macOS"
      ;;
    *)
      ;;
  esac
fi

if [ -z "$os" ]; then
  echo "Unknown OS type" >&2
  exit 1
fi

echo "$os"
