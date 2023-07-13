#!/bin/sh

set -eu

for line in `cat urls.txt`; do
    test -n "$line" || continue

    name="$(echo $line | cut -d, -f1)"
    url="$(echo $line | cut -d, -f2)"
    check="$(echo $line | cut -d, -f3)"

    curr="$(curl -s $url | sha256sum | cut -d' ' -f1)"

    test "$curr" = "$check" || echo "[changed] $name"
done
