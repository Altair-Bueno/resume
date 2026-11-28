#!/bin/sh
# Usage: reading-order.sh PDF MARKERS
# Fails unless every line of MARKERS appears, in order, as a line of the
# PDF's extracted text. Catches layouts that make extractors detach text
# from the entry it belongs to.
set -eu

pdftotext "$1" - | awk -v markers="$2" '
  BEGIN {
    i = n = 0
    while ((getline line < markers) > 0) if (line != "") expected[n++] = line
  }
  i < n && $0 == expected[i] { i++ }
  END {
    if (i < n) {
      printf "reading order broken: expected \"%s\" after \"%s\"\n",
        expected[i], (i > 0 ? expected[i - 1] : "start of document") > "/dev/stderr"
      exit 1
    }
  }
'
