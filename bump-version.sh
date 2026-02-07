#!/usr/bin/env bash
# Bump add-on version across the repo (run from repo root before push).
# Usage: ./bump-version.sh <new_version>
# Example: ./bump-version.sh 0.0.2
# After running, add a new entry in CHANGELOG.md for this version.

set -e

# ANSI colors (disable if not a TTY)
if [ -t 1 ]; then
  R="\033[0m"
  B="\033[1m"
  G="\033[32m"
  Y="\033[33m"
  C="\033[36m"
  M="\033[35m"
else
  R="" B="" G="" Y="" C="" M=""
fi

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"

NEW="$1"
if [ -z "$NEW" ]; then
  echo "Usage: $0 <new_version>"
  echo "Example: $0 0.0.2"
  exit 1
fi

CONFIG="$REPO_ROOT/mynetwork/config.yaml"
if [ ! -f "$CONFIG" ]; then
  echo "Error: mynetwork/config.yaml not found. Run from repo root."
  exit 1
fi

CURRENT=$(grep -E '^version:' "$CONFIG" | sed -n 's/.*"\([^"]*\)".*/\1/p')
if [ -z "$CURRENT" ]; then
  echo "Error: could not read current version from mynetwork/config.yaml"
  exit 1
fi

echo ""
echo -e "${M}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo -e "${M}${B}  Bump version: $CURRENT → $NEW${R}"
echo -e "${M}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""

# Escape dots for sed (replace . with \.)
CURRENT_ESC=$(echo "$CURRENT" | sed 's/\./\\./g')
NEW_ESC=$(echo "$NEW" | sed 's/\./\\./g')

# 1. Add-on config
sed -i.bak "s/version: \"$CURRENT_ESC\"/version: \"$NEW\"/" "$CONFIG" && rm -f "${CONFIG}.bak"
echo -e "  ${G}✓${R} mynetwork/config.yaml"

# 2. Dockerfile
sed -i.bak "s/mynetwork:$CURRENT_ESC/mynetwork:$NEW/" "$REPO_ROOT/mynetwork/Dockerfile" && rm -f "$REPO_ROOT/mynetwork/Dockerfile.bak"
echo -e "  ${G}✓${R} mynetwork/Dockerfile"

# 3. Root README (badges, Current version, release links)
sed -i.bak "s/HA_mynetwork-$CURRENT_ESC/HA_mynetwork-$NEW/g; s/v$CURRENT_ESC/v$NEW/g; s/\`$CURRENT_ESC\`/\`$NEW\`/g" "$REPO_ROOT/README.md" && rm -f "$REPO_ROOT/README.md.bak"
echo -e "  ${G}✓${R} README.md"

# 4. Add-on README (badge)
sed -i.bak "s/version-$CURRENT_ESC/version-$NEW/" "$REPO_ROOT/mynetwork/README.md" && rm -f "$REPO_ROOT/mynetwork/README.md.bak"
echo -e "  ${G}✓${R} mynetwork/README.md"

# 5. DOCS
sed -i.bak "s/mynetwork:$CURRENT_ESC/mynetwork:$NEW/" "$REPO_ROOT/mynetwork/DOCS.md" && rm -f "$REPO_ROOT/mynetwork/DOCS.md.bak"
echo -e "  ${G}✓${R} mynetwork/DOCS.md"

echo ""
echo -e "${G}${B}Done.${R} Version is now ${B}$NEW${R}."
echo -e "${Y}→${R} Add a new section in CHANGELOG.md for this version."
echo ""
echo -e "${C}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo -e "${C}${B}  Commands to run (copy / paste)${R}"
echo -e "${C}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""
echo -e "  ${B}git add -A && git commit -m \"release: v$NEW\" && git push${R}"
echo ""
