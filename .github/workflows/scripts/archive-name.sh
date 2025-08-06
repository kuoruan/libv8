#!/bin/sh

arch="$1"

if [ -z "$arch" ]; then
  arch="$RUNNER_ARCH"
fi

archive_name="v8_${RUNNER_OS}_$(echo $arch | tr '[:upper:]' '[:lower:]')"

echo "Using Archive Name: $archive_name"

echo "ARCHIVE_NAME=$archive_name" >> "$GITHUB_ENV"
