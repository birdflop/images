#!/bin/bash
set -e

cd /home/container || exit 1

echo "Java version:"
java -version

exec /start.sh
