#!/bin/bash
set -euo pipefail

log()  { echo -e "\033[1;32m[$(date '+%H:%M:%S')] $*\033[0m"; }
info() { echo -e "\033[1;34m  >> $*\033[0m"; }
sep()  { echo -e "\033[0;90m  $(printf '─%.0s' {1..60})\033[0m"; }

JAR="app/target/pdfbox-app-3.0.7.jar"
MAIN="org.apache.pdfbox.tools.PDFBox"
PDF="test.pdf"
BASE="test"
TMP="workload-tmp"
AOT="tree.aot"
SINGLE_AOT="single.aot"

CP="app/target/pdfbox-app-3.0.7.jar:../pdfbox-deps/pdfbox-jbig2/target/classes/:../pdfbox-deps/apache-commons-io/target/classes/"

if [ ! -f "$AOT" ]; then
  echo "tree.aot not found — run orchestrate-combine-*.sh first" >&2
  exit 1
fi

if [ ! -f "$SINGLE_AOT" ]; then
  echo "single.aot not found" >&2
  exit 1
fi

log "Java version:"
java -version
echo

mkdir -p "$TMP"

# ---------------------------------------------------------------------------
# Timing helpers
# ---------------------------------------------------------------------------
ms() { echo $(( $(date +%s%N) / 1000000 )); }

timed_no_aot() {
  local label="$1"; shift
  local start; start=$(ms)
  "$@" 2>/dev/null
  printf "  \033[1;33m%-30s\033[0m \033[0;90mno AOT  \033[0m \033[1;37m%dms\033[0m\n" \
    "$label" "$(( $(ms) - start ))"
}

timed_aot() {
  local label="$1"; shift
  local start; start=$(ms)
  "$@" 2>/dev/null
  printf "  \033[1;33m%-30s\033[0m \033[1;36mAOT tree  \033[0m \033[1;37m%dms\033[0m\n" \
    "$label" "$(( $(ms) - start ))"
}

timed_single_aot() {
  local label="$1"; shift
  local start; start=$(ms)
  "$@" 2>/dev/null
  printf "  \033[1;33m%-30s\033[0m \033[1;35mAOT single\033[0m \033[1;37m%dms\033[0m\n" \
    "$label" "$(( $(ms) - start ))"
}

run_op() {
  # $1 = label, rest = java args (without -XX:AOTCache)
  local label="$1"; shift
  timed_no_aot     "$label" java -cp "$CP" "$MAIN" "$@"
  timed_aot        "$label" java -XX:AOTCache="$AOT" -cp "$CP" "$MAIN" "$@"
  timed_single_aot "$label" java -XX:AOTCache="$SINGLE_AOT" -cp "$CP" "$MAIN" "$@"
}

# ---------------------------------------------------------------------------
# Workload
# ---------------------------------------------------------------------------
log "PDFBox workload — comparing no-AOT vs single.aot vs tree.aot"
sep

run_op "export:text" \
  export:text --input "$PDF" --output "$TMP/$BASE-text.txt"

run_op "export:images" \
  export:images --input "$PDF"

run_op "render" \
  render --input "$PDF"

run_op "fromtext" \
  fromtext --input "$TMP/$BASE-text.txt" \
           --output "$TMP/$BASE-from-text.pdf" \
           -standardFont Times-Roman

run_op "split" \
  split --input "$PDF" -split 3 -outputPrefix "$TMP/split-$BASE"

run_op "merge" \
  merge --input "$TMP/split-$BASE-1.pdf" \
        --output "$TMP/merged-$BASE.pdf"

run_op "decode" \
  decode "$PDF" "$TMP/$BASE-decoded.pdf"

run_op "overlay" \
  overlay -default "$PDF" --input "$PDF" --output "$TMP/$BASE-overlay.pdf"

echo
log "Done."
