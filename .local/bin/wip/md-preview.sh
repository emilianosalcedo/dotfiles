#!/bin/sh

file="$(mktemp)" || exit
ext=".pdf"
pandoc -f markdown_strict - -o "${file}${ext}" >/dev/null 2>&1
$READER "${file}${ext}" >/dev/null 2>&1
rm "${file}" "${file}${ext}"
