#!/bin/sh

archive_name="v8_${RUNNER_OS}_$(echo $RUNNER_ARCH | tr '[:upper:]' '[:lower:]')"

echo "Using Archive Name: $archive_name"

echo "ARCHIVE_NAME=$archive_name" >> "$GITHUB_ENV"
