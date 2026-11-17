#!/usr/bin/env bash
# Szintetikus NeoForge 1.21.1 GameTest: a hivatalos MDK-sablon (rögzített commit) + egy füstteszt.
# Elvárás: pozitív futás kilépési kódja 0, negatív (GT_FAIL=1) futásé nem 0.
set -uo pipefail
MDK_REPO=https://github.com/NeoForgeMDKs/MDK-1.21.1-ModDevGradle.git
MDK_SHA=e0000cb81c6ca4bb218046cfd8ade771a42e9c32
NEO_VERSION=21.1.264   # a GF-mod verziója (D-004), hogy az eredmény átvihető legyen
ROOT=$(pwd)
git clone -q "$MDK_REPO" work && git -C work checkout -q "$MDK_SHA" || exit 2
cd work
sed -i "s/^neo_version=.*/neo_version=$NEO_VERSION/" gradle.properties
MODID=$(grep '^mod_id=' gradle.properties | cut -d= -f2)
MAIN=$(grep -rl '@Mod(' src/main/java | head -1)
PKG=$(grep -m1 '^package' "$MAIN" | sed -E 's/package ([^;]+);/\1/')
sed -e "s/__PKG__/$PKG/" -e "s/__MODID__/$MODID/" "$ROOT/ci/SmokeGameTests.java.tmpl" > "$(dirname "$MAIN")/SmokeGameTests.java"
mkdir -p "src/main/resources/data/$MODID/structure"
python3 -I "$ROOT/ci/make_empty_nbt.py" "src/main/resources/data/$MODID/structure/empty.nbt"
java -version 2>&1 | head -1
SECONDS=0; ./gradlew runGameTestServer --no-daemon > pos.log 2>&1; POS=$?; T_POS=$SECONDS
SECONDS=0; GT_FAIL=1 ./gradlew runGameTestServer --no-daemon > neg.log 2>&1; NEG=$?; T_NEG=$SECONDS
{
  echo "## Szintetikus NeoForge GameTest"
  echo "- MDK: \`$MDK_SHA\`, NeoForge $NEO_VERSION, mod_id \`$MODID\`"
  echo "- Pozitív futás: kilépési kód **$POS**, $T_POS s (hideg Gradle-gyorsítótár)"
  echo "- Negatív futás (GT_FAIL=1): kilépési kód **$NEG**, $T_NEG s"
  echo '```'; grep -i -E "smoke|required tests|gametest" pos.log | tail -5; echo '```'
} | tee -a "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
[[ $POS -eq 0 && $NEG -ne 0 ]] && exit 0 || exit 1
