#!/bin/bash
set -euo pipefail

log() { echo -e "\033[1;32m[$(date '+%H:%M:%S')] $*\033[0m"; }

log "Java version:"
java -version

log "Creating tree.aot (base=tools/cache.aot, inputs=jbig2 cache)"
rm -f tree.aot

java -Xlog:aot=info \
  -XX:AOTMode=merge \
  -XX:AOTCache=tools/cache.aot \
  -XX:AOTMergeInputs="../pdfbox-deps/pdfbox-jbig2/cache.aot" \
  -XX:AOTCacheOutput=tree.aot \
  -cp "../pdfbox-deps/pdfbox-jbig2/target/classes/:tools/target/pdfbox-tools-3.0.7.jar" \
  -version

test -f tree.aot
log "tree.aot created."

