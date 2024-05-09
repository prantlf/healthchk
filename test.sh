#!/bin/sh

set -e

test() {
  echo "----------------------------------------"
  echo "> $1"
  echo "----------------------------------------"
}

test "no arguments"
./healthchk || true

test "unknown argument"
./healthchk -a || true

test "invalid method argument"
./healthchk -m A http://www.blankwebsite.com || true

test "invalid timeout argument"
./healthchk -t a http://www.blankwebsite.com || true

test "default options"
./healthchk http://www.blankwebsite.com

test "two URLs"
./healthchk http://www.blankwebsite.com http://www.blankwebsite.com || true

test "use HEAD"
./healthchk -m HEAD http://www.blankwebsite.com

test "with timeout"
./healthchk -t 1 https://www.unknown.co || true

test "unresolved address"
./healthchk http://www.blankwebsite.c || true

test "invalid URL"
./healthchk https://www.unknown.c || true

test "silent"
./healthchk http://www.blankwebsite.com -s

test "verbose"
./healthchk -v http://www.blankwebsite.com

echo "----------------------------------------"
echo "done"
