#!/bin/sh

set -eu

extract() {
    set -x
    local name="${1:-}"
    local url="${2:-}"

    curl "$url" -so "$name.pdf"
    pdftoppm "$name.pdf" "$name.tmp" -png -r 150 -f 1 -singlefile
    mkdir -p plans
    convert "$name.tmp.png" "PNG8:plans/$name.png"

    set +x

    local hash="$(sha256sum $name.pdf | cut -d' ' -f1)"
    echo
    echo "Please append this checksum to the \`$name\` entry in \`urls.txt\`:"
    echo "$hash"

    rm "$name.pdf" "$name.tmp.png" 2> /dev/null
}

extract_all() {
    for line in `cat urls.txt`; do
        test -n "$line" || continue

        name="$(echo $line | cut -d, -f1)"
        url="$(echo $line | cut -d, -f2)"

        echo
        echo "Extracting $name..."
        extract "$name" "$url"
    done
}

if [ "$#" -eq 2 ]; then
    extract "$@"
elif [ "$#" -eq 1 ]; then
    extract "$1" "$(grep -F $1, urls.txt | cut -d, -f2)"
else
    read -p 'Extract all plans? [Y/n] ' ans
    test "$ans" = 'n' || extract_all
fi
