#!/bin/bash
set -euo pipefail

log()  { echo -e "\033[1;32m[$(date '+%H:%M:%S')] $*\033[0m"; }
info() { echo -e "\033[1;34m  >> $*\033[0m"; }
sep()  { echo -e "\033[0;90m  $(printf '─%.0s' {1..50})\033[0m"; }

JAR="app/target/pdfbox-app-3.0.7.jar"
MAIN="org.apache.pdfbox.tools.PDFBox"
PDF="test.pdf"

timed() {
  local label="$1"; shift
  info "$label"
  local start=$(($(date +%s%N) / 1000000))
  "$@" 2>/dev/null
  local elapsed=$(( $(date +%s%N) / 1000000 - start ))
  printf "  \033[1;33m%-20s\033[0m \033[1;37m%dms\033[0m\n" "$label" "$elapsed"
}

if [ ! -f tree.aot ]; then
  echo "tree.aot not found (run orchestrate-combine-*.sh first)" >&2
  exit 1
fi

log "Java version:"
java -version
echo

log "PDFBox workload (export:text -i test.pdf)"
sep
timed "no CDS"         java -Xshare:off -cp "$JAR" "$MAIN" export:text -i "$PDF"
timed "CDS (default)"  java -cp "$JAR" "$MAIN" export:text -i "$PDF"
timed "AOT cache (tree)" java -XX:AOTCache=tree.aot -cp "$JAR" "$MAIN" export:text -i "$PDF"

