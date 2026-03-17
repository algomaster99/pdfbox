#!/bin/bash
set -euo pipefail

log() { echo -e "\033[1;32m[$(date '+%H:%M:%S')] $*\033[0m"; }

log "Java version:"
java -version

log "Creating tree.aot (base=jbig2 cache, inputs=tools/cache.aot)"
rm -f tree.aot

java -Xlog:aot+merge=info \
  -XX:AOTMode=merge \
  -XX:AOTCache=../pdfbox-deps/pdfbox-jbig2/cache.aot \
  -XX:AOTMergeInputs=tools/cache.aot \
  -XX:AOTCacheOutput=tree.aot \
  -cp tools/target/pdfbox-tools-3.0.7.jar:../pdfbox-deps/pdfbox-jbig2/target/classes/ \
  -version

test -f tree.aot
log "tree.aot created."

