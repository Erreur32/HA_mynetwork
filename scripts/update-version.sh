#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# Bump add-on version across the repo (run from anywhere).
# Usage:   ./scripts/update-version.sh <new_version> [--tag-push]
# Example: ./scripts/update-version.sh 0.1.24
#          ./scripts/update-version.sh 0.1.24 --tag-push
#
# Updated files (add-on version):
#   1. mynetwork/config.yaml   — version field
#   2. README.md               — badge, release link, current version text
#   3. mynetwork/README.md     — add-on badge + Versions table
#   4. mynetwork/DOCS.md       — version line
#   5. mynetwork/DOCS_FR.md    — version line
#
# Updated files (upstream MynetworK version — scraped from GitHub):
#   6. README.md               — upstream badge + Versions table (MynetworK row)
#   7. mynetwork/README.md     — upstream badge + Versions table
#   8. mynetwork/Dockerfile    — BUILD_FROM image tag
#
# Commit message file (local only, in .gitignore):
#   9. COMMIT-MESSAGE.txt      — used by: git commit -F COMMIT-MESSAGE.txt
#
# Options:
#   --tag-push   After bump, commit using COMMIT-MESSAGE.txt, create tag, push branch & tag.
#
# After running (without --tag-push):
#   1. Edit COMMIT-MESSAGE.txt with the actual changes for this version.
#   2. Add a new entry in CHANGELOG.md for this version.
#   3. git add -A && git commit -F COMMIT-MESSAGE.txt && git push
#   4. git tag v<NEW> && git push origin v<NEW>
# ──────────────────────────────────────────────────────────────────────────────

set -e

# ── ANSI colors (disable if not a TTY) ───────────────────────────────────────
if [ -t 1 ]; then
  R="\033[0m"
  B="\033[1m"
  G="\033[32m"
  Y="\033[33m"
  C="\033[36m"
  M="\033[35m"
  RED="\033[31m"
else
  R="" B="" G="" Y="" C="" M="" RED=""
fi

# ── Resolve repo root (script lives in scripts/) ────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# ── Target files ─────────────────────────────────────────────────────────────
CONFIG="$REPO_ROOT/mynetwork/config.yaml"
ROOT_README="$REPO_ROOT/README.md"
ADDON_README="$REPO_ROOT/mynetwork/README.md"
DOCS_EN="$REPO_ROOT/mynetwork/DOCS.md"
DOCS_FR="$REPO_ROOT/mynetwork/DOCS_FR.md"
DOCKERFILE="$REPO_ROOT/mynetwork/Dockerfile"
COMMIT_MSG_FILE="$REPO_ROOT/COMMIT-MESSAGE.txt"

# ── Upstream MynetworK URLs ───────────────────────────────────────────────────
UPSTREAM_CHANGELOG_URL="https://raw.githubusercontent.com/Erreur32/MynetworK/refs/heads/main/CHANGELOG.md"

# ── Read current version from config.yaml ────────────────────────────────────
if [ ! -f "$CONFIG" ]; then
  echo -e "${RED}Error:${R} mynetwork/config.yaml not found at $CONFIG"
  exit 1
fi

CURRENT=$(grep -E '^version:' "$CONFIG" | sed -n 's/.*"\([^"]*\)".*/\1/p')
if [ -z "$CURRENT" ]; then
  echo -e "${RED}Error:${R} could not read current version from mynetwork/config.yaml"
  exit 1
fi

# ── Fetch upstream MynetworK version from GitHub CHANGELOG ───────────────────
UPSTREAM_VERSION=""
if command -v curl >/dev/null 2>&1; then
  UPSTREAM_VERSION=$(curl -sfL --max-time 10 "$UPSTREAM_CHANGELOG_URL" \
    | grep -m1 '^## \[' \
    | sed 's/## \[\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)\].*/\1/' \
    2>/dev/null) || true
fi

# ── Parse arguments: new version + optional --tag-push ───────────────────────
NEW=""
TAG_PUSH=""
for arg in "$@"; do
  if [ "$arg" = "--tag-push" ]; then
    TAG_PUSH="1"
  elif [ -z "$NEW" ]; then
    NEW="$arg"
  fi
done

if [ -z "$NEW" ]; then
  SUGGESTED=$(echo "$CURRENT" | awk -F. '{$NF=$NF+1; print $0}' OFS=.)
  echo ""
  echo -e "  ${B}Add-on version:${R}     ${C}${CURRENT}${R}"
  if [ -n "$UPSTREAM_VERSION" ]; then
    echo -e "  ${B}MynetworK upstream:${R} ${C}${UPSTREAM_VERSION}${R}  ${Y}(from GitHub CHANGELOG)${R}"
  else
    echo -e "  ${B}MynetworK upstream:${R} ${RED}(could not fetch — no internet or curl missing)${R}"
  fi
  echo ""
  echo "  Usage: $0 <new_version> [--tag-push]"
  echo ""
  echo "  Examples:"
  echo -e "    ${C}$0 ${SUGGESTED}${R}              # bump version only"
  echo -e "    ${C}$0 ${SUGGESTED} --tag-push${R}   # bump + commit + tag + push"
  echo ""
  exit 0
fi

# ── Sanity check ──────────────────────────────────────────────────────────────
if [ "$NEW" = "$CURRENT" ]; then
  if [ -n "$TAG_PUSH" ]; then
    echo ""
    echo -e "${M}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
    echo -e "${M}${B}  Tag and push v$NEW (version already set)${R}"
    echo -e "${M}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
    echo ""
    # Skip version bump, jump to tag+push below
  else
    echo -e "${Y}Warning:${R} new version ($NEW) is the same as current ($CURRENT). Nothing to do."
    exit 0
  fi
fi

# ── Helper: sed in-place (portable macOS / Linux) ───────────────────────────
sedi() {
  local file="$1"; shift
  sed -i.bak "$@" "$file" && rm -f "${file}.bak"
}

# ── Generic semver pattern for sed ───────────────────────────────────────────
SEMVER_PATTERN='[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*'

# Escape dots for sed regex
CURRENT_ESC=$(echo "$CURRENT" | sed 's/\./\\./g')

# ═══════════════════════════════════════════════════════════════════════════════
#  VERSION UPDATES — skip if NEW == CURRENT (--tag-push on already-bumped repo)
# ═══════════════════════════════════════════════════════════════════════════════

if [ "$NEW" != "$CURRENT" ]; then

echo ""
echo -e "${M}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo -e "${M}${B}  Bump add-on version: $CURRENT → $NEW${R}"
if [ -n "$UPSTREAM_VERSION" ]; then
  echo -e "${M}${B}  MynetworK upstream:  v$UPSTREAM_VERSION${R}"
fi
echo -e "${M}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""
echo -e "  ${B}── Add-on version ──${R}"

# ── 1. mynetwork/config.yaml ─────────────────────────────────────────────────
if [ -f "$CONFIG" ]; then
  sedi "$CONFIG" "s/version: \"$CURRENT_ESC\"/version: \"$NEW\"/"
  echo -e "  ${G}✓${R} mynetwork/config.yaml   ${C}(version: \"$NEW\")${R}"
else
  echo -e "  ${RED}✗${R} mynetwork/config.yaml   ${RED}(file not found)${R}"
fi

# ── 2. README.md (root) ───────────────────────────────────────────────────────
if [ -f "$ROOT_README" ]; then
  sedi "$ROOT_README" "s/version-v$CURRENT_ESC/version-v$NEW/g"
  sedi "$ROOT_README" "s|releases/tag/v$CURRENT_ESC|releases/tag/v$NEW|g"
  sedi "$ROOT_README" "s/\`$CURRENT_ESC\`/\`$NEW\`/g"
  echo -e "  ${G}✓${R} README.md               ${C}(badge + release link + version text)${R}"
else
  echo -e "  ${RED}✗${R} README.md               ${RED}(file not found)${R}"
fi

# ── 3. mynetwork/README.md ────────────────────────────────────────────────────
if [ -f "$ADDON_README" ]; then
  sedi "$ADDON_README" "s/version-${SEMVER_PATTERN}-blue/version-$NEW-blue/g"
  sedi "$ADDON_README" "s/| \*\*HA_mynetwork\*\* (add-on) | \`${SEMVER_PATTERN}\`/| **HA_mynetwork** (add-on) | \`$NEW\`/g"
  echo -e "  ${G}✓${R} mynetwork/README.md     ${C}(add-on badge + Versions table)${R}"
else
  echo -e "  ${RED}✗${R} mynetwork/README.md     ${RED}(file not found)${R}"
fi

# ── 4. mynetwork/DOCS.md ──────────────────────────────────────────────────────
if [ -f "$DOCS_EN" ]; then
  sedi "$DOCS_EN" "s/\*\*Version:\*\* \`${SEMVER_PATTERN}\`/**Version:** \`$NEW\`/g"
  echo -e "  ${G}✓${R} mynetwork/DOCS.md       ${C}(version line)${R}"
else
  echo -e "  ${RED}✗${R} mynetwork/DOCS.md       ${RED}(file not found)${R}"
fi

# ── 5. mynetwork/DOCS_FR.md ───────────────────────────────────────────────────
if [ -f "$DOCS_FR" ]; then
  sedi "$DOCS_FR" "s/\*\*Version :\*\* \`${SEMVER_PATTERN}\`/**Version :** \`$NEW\`/g"
  echo -e "  ${G}✓${R} mynetwork/DOCS_FR.md    ${C}(version line)${R}"
else
  echo -e "  ${RED}✗${R} mynetwork/DOCS_FR.md    ${RED}(file not found)${R}"
fi

# ── Upstream MynetworK version ───────────────────────────────────────────────
echo ""
if [ -n "$UPSTREAM_VERSION" ]; then
  echo -e "  ${B}── Upstream MynetworK v${UPSTREAM_VERSION} ──${R}"

  # ── 6. README.md (root) — upstream badge + Versions table ─────────────────
  if [ -f "$ROOT_README" ]; then
    sedi "$ROOT_README" "s/MynetworK%20v${SEMVER_PATTERN}-orange/MynetworK%20v${UPSTREAM_VERSION}-orange/g"
    sedi "$ROOT_README" "s/| \*\*MynetworK\*\* (main project) | \`v${SEMVER_PATTERN}\`/| **MynetworK** (main project) | \`v${UPSTREAM_VERSION}\`/g"
    echo -e "  ${G}✓${R} README.md               ${C}(upstream badge + Versions table → v${UPSTREAM_VERSION})${R}"
  fi

  # ── 7. mynetwork/README.md — upstream badge + Versions table ──────────────
  if [ -f "$ADDON_README" ]; then
    sedi "$ADDON_README" "s/MynetworK-v${SEMVER_PATTERN}-orange/MynetworK-v${UPSTREAM_VERSION}-orange/g"
    sedi "$ADDON_README" "s/| \*\*MynetworK\*\* (main project) | \`v${SEMVER_PATTERN}\`/| **MynetworK** (main project) | \`v${UPSTREAM_VERSION}\`/g"
    echo -e "  ${G}✓${R} mynetwork/README.md     ${C}(upstream badge + Versions table → v${UPSTREAM_VERSION})${R}"
  fi

  # ── 8. mynetwork/Dockerfile — BUILD_FROM image tag ─────────────────────────
  if [ -f "$DOCKERFILE" ]; then
    sedi "$DOCKERFILE" "s|ghcr\.io/erreur32/mynetwork:${SEMVER_PATTERN}|ghcr.io/erreur32/mynetwork:${UPSTREAM_VERSION}|g"
    echo -e "  ${G}✓${R} mynetwork/Dockerfile    ${C}(BUILD_FROM → ghcr.io/erreur32/mynetwork:${UPSTREAM_VERSION})${R}"
  else
    echo -e "  ${RED}✗${R} mynetwork/Dockerfile    ${RED}(file not found)${R}"
  fi

else
  echo -e "  ${Y}⚠${R}  Could not fetch upstream MynetworK version"
  echo -e "     ${Y}(no internet or curl missing — upstream badges and Dockerfile NOT updated)${R}"
fi

# ── Fix ownership if run as root (e.g. inside container) ────────────────────
if [ "$(id -u)" = 0 ] && id debian32 >/dev/null 2>&1; then
  chown -R debian32:debian32 "$REPO_ROOT"
  echo -e "  ${G}✓${R} chown debian32:debian32 (recursive)"
fi

# ── COMMIT-MESSAGE.txt ────────────────────────────────────────────────────────
echo ""
echo -e "  ${B}── Commit message file ──${R}"
if [ -f "$COMMIT_MSG_FILE" ] && grep -q "v${NEW}\|${NEW}" "$COMMIT_MSG_FILE" 2>/dev/null; then
  echo -e "  ${G}✓${R} COMMIT-MESSAGE.txt      ${C}(already contains v${NEW} — ready to use)${R}"
else
  cat > "$COMMIT_MSG_FILE" << CMEOF
release: v${NEW} — <short summary of changes>

- <change 1>
- <change 2>
CMEOF
  echo -e "  ${G}✓${R} COMMIT-MESSAGE.txt      ${C}(generated template — edit before committing)${R}"
fi

# ── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${G}${B}Done.${R} Add-on version is now ${B}$NEW${R}."
if [ -n "$UPSTREAM_VERSION" ]; then
  echo -e "       Upstream MynetworK: ${B}v$UPSTREAM_VERSION${R}"
fi

fi  # end of "if NEW != CURRENT"

# ═══════════════════════════════════════════════════════════════════════════════
#  TAG + PUSH (--tag-push)
# ═══════════════════════════════════════════════════════════════════════════════

do_commit_tag_push() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [ -z "$branch" ]; then
    echo -e "${RED}Error:${R} not a git repository or no branch. Cannot tag/push."
    return 1
  fi

  local tag_name="v$NEW"

  # ── Commit if there are uncommitted changes ────────────────────────────────
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo -e "  ${B}Uncommitted changes found — committing...${R}"
    git add -A

    if [ -f "$COMMIT_MSG_FILE" ] && grep -q "v${NEW}\|${NEW}" "$COMMIT_MSG_FILE" 2>/dev/null; then
      git commit -F "$COMMIT_MSG_FILE" || { echo -e "${RED}Commit failed.${R}"; return 1; }
      echo -e "  ${G}✓${R} Committed using ${C}COMMIT-MESSAGE.txt${R}"
    else
      git commit -m "release: v$NEW" || { echo -e "${RED}Commit failed.${R}"; return 1; }
      echo -e "  ${G}✓${R} Committed with generic message ${C}\"release: v$NEW\"${R}"
      echo -e "  ${Y}⚠${R} ${Y}COMMIT-MESSAGE.txt was missing or outdated — used fallback message${R}"
    fi
    echo ""
  else
    echo -e "  ${G}✓${R} Working tree clean — no commit needed."
    echo ""
  fi

  # ── Create tag ────────────────────────────────────────────────────────────
  if git rev-parse "$tag_name" >/dev/null 2>&1; then
    echo -e "  ${Y}⚠${R} Tag ${C}${tag_name}${R} already exists locally."
  else
    git tag -a "$tag_name" -m "Release $tag_name" || { echo -e "${RED}Tag creation failed.${R}"; return 1; }
    echo -e "  ${G}✓${R} Tag ${C}${tag_name}${R} created."
  fi

  # ── Push branch ───────────────────────────────────────────────────────────
  echo -e "  ${B}Pushing ${C}origin ${branch}${R} ...${R}"
  if ! git push origin "$branch"; then
    echo -e "${RED}Push branch failed.${R}"
    return 1
  fi
  echo -e "  ${G}✓${R} Branch ${C}${branch}${R} pushed."

  # ── Push tag ──────────────────────────────────────────────────────────────
  if git ls-remote origin "refs/tags/$tag_name" 2>/dev/null | grep -q .; then
    echo -e "  ${Y}○${R} Tag ${C}${tag_name}${R} already exists on remote — skip."
  else
    echo -e "  ${B}Pushing tag ${C}${tag_name}${R} ...${R}"
    if ! git push origin "$tag_name"; then
      echo -e "${RED}Push tag failed.${R}"
      return 1
    fi
    echo -e "  ${G}✓${R} Tag ${C}${tag_name}${R} pushed."
  fi

  echo ""
  echo -e "  ${G}${B}✓ Release v$NEW complete.${R}"
  return 0
}

if [ -n "$TAG_PUSH" ]; then
  echo ""
  echo -e "${C}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
  echo -e "${C}${B}  Commit, tag and push (--tag-push)${R}"
  echo -e "${C}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
  echo ""
  do_commit_tag_push || exit 1
  echo ""
  exit 0
fi

# ═══════════════════════════════════════════════════════════════════════════════
#  MANUAL COMMANDS (when --tag-push is not used)
# ═══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${Y}→${R} Edit ${B}COMMIT-MESSAGE.txt${R} with the actual changes for v${NEW}."
echo -e "${Y}→${R} Add a new section in ${B}CHANGELOG.md${R} for this version."
echo ""
echo -e "${C}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo -e "${C}${B}  Commands to run (copy / paste)${R}"
echo -e "${C}${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo ""
echo -e "  ${B}1. Commit with custom message:${R}"
echo -e "     ${G}git add -A && git commit -F COMMIT-MESSAGE.txt && git push${R}"
echo ""
echo -e "  ${B}2. Commit with generic message:${R}"
echo -e "     ${G}git add -A && git commit -m \"release: v$NEW\" && git push${R}"
echo ""
echo -e "  ${B}3. Create and push tag:${R}"
echo -e "     ${G}git tag -a v$NEW -m \"Release v$NEW\" && git push origin v$NEW${R}"
echo ""
echo -e "  ${B}All-in-one (commit + tag + push):${R}"
echo -e "     ${G}git add -A && git commit -F COMMIT-MESSAGE.txt && git tag -a v$NEW -m \"Release v$NEW\" && git push origin \$(git rev-parse --abbrev-ref HEAD) && git push origin v$NEW${R}"
echo ""
echo -e "  ${B}Or re-run with --tag-push (automatic):${R}"
echo -e "     ${C}$0 $NEW --tag-push${R}"
echo ""
