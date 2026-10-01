#!/usr/bin/env bash

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Parsing&AIConnector - Sync from Deploy & Docs${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

REPO_OWNER="AIJobResearcher"
REPO_NAME="docs"
BRANCH="${BRANCH:-main}"
ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.zip"

TMP_DIR=$(mktemp -d)

cleanup() {
    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

# Copy directory contents into destination, overwriting same-named files.
# Files missing in the destination are added; destination-only files are kept.
copy_dir() {
    local src="$1"
    local dst="$2"
    mkdir -p "$dst"
    # --checksum: replace by content, not by size+mtime quick check.
    if rsync -a --checksum "$src/" "$dst/" 2>/dev/null; then
        return 0
    fi
    cp -rf "$src"/. "$dst"/ 2>/dev/null
}

echo -e "${BLUE}📡 Downloading repository archive...${NC}"
echo "  Source: $ARCHIVE_URL"
echo ""

echo -n "  Downloading... "
if curl -sSL --fail "$ARCHIVE_URL" -o "$TMP_DIR/repo.zip" 2>/dev/null; then
    echo -e "${GREEN}done${NC}"
else
    echo -e "${RED}failed${NC}"
    echo "  ❌ Failed to download $ARCHIVE_URL"
    exit 1
fi

echo -n "  Extracting... "
if unzip -q "$TMP_DIR/repo.zip" -d "$TMP_DIR" 2>/dev/null; then
    echo -e "${GREEN}done${NC}"
else
    echo -e "${RED}failed${NC}"
    exit 1
fi

SRC_ROOT="$TMP_DIR/${REPO_NAME}-${BRANCH}"

echo ""

# ============================================
# docs/
# ============================================

echo -n "  docs/... "
if [ -d "$SRC_ROOT/docs" ] && copy_dir "$SRC_ROOT/docs" "./docs"; then
    echo -e "${GREEN}done${NC}"
else
    echo -e "${RED}failed${NC}"
    echo "  ❌ docs/ not found in $SRC_ROOT"
    exit 1
fi

# ============================================
# .ai-agent/standards/ (only the four that apply here)
# ============================================

STANDARDS=(
    "md-files-standards.md"
    "python-standards.md"
    "testing-standards.md"
    "token-economy-rules.md"
)

mkdir -p .ai-agent/standards

for file in "${STANDARDS[@]}"; do
    echo -n "  .ai-agent/standards/$file... "
    if [ -f "$SRC_ROOT/.ai-agent/standards/$file" ]; then
        cp -f "$SRC_ROOT/.ai-agent/standards/$file" ".ai-agent/standards/$file"
        echo -e "${GREEN}done${NC}"
    else
        echo -e "${RED}failed${NC}"
        echo "  ❌ .ai-agent/standards/$file not found in the docs repo"
        exit 1
    fi
done

# ============================================
# .ai-agent/prompts/
# ============================================

echo -n "  .ai-agent/prompts/... "
if [ -d "$SRC_ROOT/.ai-agent/prompts" ] && copy_dir "$SRC_ROOT/.ai-agent/prompts" ".ai-agent/prompts"; then
    echo -e "${GREEN}done${NC}"
else
    echo -e "${RED}failed${NC}"
    echo "  ❌ .ai-agent/prompts/ not found in the docs repo"
    exit 1
fi

# ============================================
# Working directories (absent in the docs repo)
# ============================================

mkdir -p .ai-agent/agent.data/artifacts .ai-agent/user.data/temp
echo -e "  ${GREEN}ensured .ai-agent/agent.data/artifacts/ and .ai-agent/user.data/temp/${NC}"

echo ""
echo -e "${GREEN}✅ Sync completed${NC}"
echo ""
