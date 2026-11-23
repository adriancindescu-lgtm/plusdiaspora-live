#!/bin/sh
set -eu
ZIP=/home/plusdiaspora/deploy-packages/NEXTSTEP_publicare_verificata_20261123.zip
DEST=/home/plusdiaspora/public_html
BACKUPS=/home/plusdiaspora/nextstep-backups
EXPECTED=02d53d2ba2963e854d52f85306e10d0340657893cb57ec5fec0427f67abd88f3
printf '%s  %s\n' "$EXPECTED" "$ZIP" | sha256sum -c -
unzip -tq "$ZIP"
STAGE=$(mktemp -d /tmp/plusdiaspora-nextstep.XXXXXX)
trap 'rm -rf "$STAGE"' EXIT HUP INT TERM
unzip -oq "$ZIP" -d "$STAGE"
for file in nextstep.html NEXTSTEP_Ghid_Bavaria_31_pagini.pdf coperta.png; do
  test -s "$STAGE/$file"
done
MATERIALS=materiale/webinar-22-noiembrie-2026
test "$(find "$STAGE/$MATERIALS" -type f -name '*.pdf' | wc -l | tr -d ' ')" = 11
test -s "$STAGE/$MATERIALS/NEXTSTEP_22nov_Toate_materialele.pdf"
mkdir -p "$BACKUPS"
BACKUP=$(mktemp -d "$BACKUPS/nextstep-20261123.XXXXXX")
for file in nextstep.html NEXTSTEP_Ghid_Bavaria_31_pagini.pdf coperta.png "$MATERIALS"; do
  if test -e "$DEST/$file"; then
    mkdir -p "$BACKUP/$(dirname "$file")"
    cp -pR "$DEST/$file" "$BACKUP/$file"
  else
    printf '%s\n' "$file" >> "$BACKUP/previously-absent.txt"
  fi
done
mkdir -p "$DEST/$MATERIALS"
for file in "$STAGE/$MATERIALS/"*.pdf; do
  install -m 0644 "$file" "$DEST/$MATERIALS/$(basename "$file").new"
  mv -f "$DEST/$MATERIALS/$(basename "$file").new" "$DEST/$MATERIALS/$(basename "$file")"
done
for file in NEXTSTEP_Ghid_Bavaria_31_pagini.pdf coperta.png nextstep.html; do
  install -m 0644 "$STAGE/$file" "$DEST/$file.new"
  mv -f "$DEST/$file.new" "$DEST/$file"
done
for file in nextstep.html NEXTSTEP_Ghid_Bavaria_31_pagini.pdf coperta.png; do
  cmp "$STAGE/$file" "$DEST/$file"
done
for file in "$STAGE/$MATERIALS/"*.pdf; do
  cmp "$file" "$DEST/$MATERIALS/$(basename "$file")"
done
printf 'NEXT STEP deployment verified. Backup: %s\n' "$BACKUP"
