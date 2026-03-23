#!/bin/bash
set -euo pipefail

log() { echo -e "\033[1;32m[$(date '+%H:%M:%S')] $*\033[0m"; }

log "Java version:"
java -version

SINGLE_AOT="single.aot"
SINGLE_JAR="app/target/pdfbox-app-3.0.7.jar"

if [ ! -f "$SINGLE_AOT" ]; then
  log "Creating single.aot (export:text)"
  rm -f "$SINGLE_AOT"

  test -f "$SINGLE_JAR" || { echo "Missing $SINGLE_JAR (build app first)" >&2; exit 1; }
  test -f "test.pdf" || { echo "Missing test.pdf (expected at pdfbox/test.pdf)" >&2; exit 1; }

  java -XX:AOTCacheOutput="$SINGLE_AOT" -jar "$SINGLE_JAR" export:text -i test.pdf
fi

test -f "$SINGLE_AOT"
log "single.aot ready."

log "Creating tree.aot (base=tools/cache.aot, inputs=jbig2 cache + commons-io cache)"
rm -f tree.aot

java -Xlog:aot \
  -XX:AOTMode=merge \
  -XX:AOTCache=tools/cache.aot \
  -XX:AOTMergeInputs="../pdfbox-deps/pdfbox-jbig2/cache.aot:../pdfbox-deps/apache-commons-io/cache.aot" \
  -XX:AOTCacheOutput=tree.aot \
  -cp "tools/target/pdfbox-tools-3.0.7.jar:../pdfbox-deps/pdfbox-jbig2/target/classes/:../pdfbox-deps/apache-commons-io/target/classes/" \
  -version

test -f tree.aot
log "tree.aot created."