#!/usr/bin/env bash
set -euo pipefail

# Validate GitHub Copilot agent files and path-specific instructions.
# Checks: YAML frontmatter, required fields, character limits, handoff references.

AGENTS_DIR=".github/agents"
INSTRUCTIONS_DIR=".github/instructions"
MAX_BODY_CHARS=30000
ERRORS=0
WARNINGS=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

error() { echo -e "${RED}ERROR${NC}: $1"; ((ERRORS++)); }
warn() { echo -e "${YELLOW}WARN${NC}: $1"; ((WARNINGS++)); }
ok() { echo -e "${GREEN}OK${NC}: $1"; }

# Change to repo root
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo '.')"

echo "=== Validating Agent Files ==="
echo ""

# Collect all agent names for handoff validation
declare -a AGENT_NAMES=()

# 1. Validate .agent.md files
if [ -d "$AGENTS_DIR" ]; then
  for file in "$AGENTS_DIR"/*.agent.md; do
    [ -f "$file" ] || continue
    basename=$(basename "$file")
    echo "--- $basename ---"

    # Extract agent name from filename (strip .agent.md)
    name="${basename%.agent.md}"
    AGENT_NAMES+=("$name")

    # Check frontmatter exists (starts with ---)
    first_line=$(head -1 "$file")
    if [ "$first_line" != "---" ]; then
      error "$basename: Missing YAML frontmatter (file must start with ---)"
      continue
    fi

    # Extract frontmatter (between first and second ---)
    frontmatter=$(awk '/^---$/{n++; next} n==1{print}' "$file")

    # Check required 'description' field
    if ! echo "$frontmatter" | grep -q "^description:"; then
      error "$basename: Missing required 'description' field in frontmatter"
    else
      ok "$basename: has 'description' field"
    fi

    # Extract body (everything after second ---)
    body=$(awk '/^---$/{n++; next} n>=2{print}' "$file")
    body_chars=$(echo "$body" | wc -c | tr -d ' ')

    if [ "$body_chars" -gt "$MAX_BODY_CHARS" ]; then
      error "$basename: Body is ${body_chars} chars (max ${MAX_BODY_CHARS})"
    else
      ok "$basename: body is ${body_chars}/${MAX_BODY_CHARS} chars"
    fi

    # Extract handoff agent references
    handoff_agents=$(echo "$frontmatter" | grep "agent:" | sed 's/.*agent: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' | tr -d ' ')
    if [ -n "$handoff_agents" ]; then
      while IFS= read -r agent; do
        [ -z "$agent" ] && continue
        expected_file="$AGENTS_DIR/${agent}.agent.md"
        if [ ! -f "$expected_file" ]; then
          error "$basename: Handoff references agent '${agent}' but ${expected_file} does not exist"
        else
          ok "$basename: handoff to '${agent}' resolves"
        fi
      done <<< "$handoff_agents"
    fi

    echo ""
  done
else
  error "Directory $AGENTS_DIR does not exist"
fi

# 2. Validate .instructions.md files
echo "=== Validating Instruction Files ==="
echo ""

if [ -d "$INSTRUCTIONS_DIR" ]; then
  for file in "$INSTRUCTIONS_DIR"/*.instructions.md; do
    [ -f "$file" ] || continue
    basename=$(basename "$file")
    echo "--- $basename ---"

    # Check frontmatter exists
    first_line=$(head -1 "$file")
    if [ "$first_line" != "---" ]; then
      error "$basename: Missing YAML frontmatter"
      continue
    fi

    # Extract frontmatter
    frontmatter=$(awk '/^---$/{n++; next} n==1{print}' "$file")

    # Check required 'applyTo' field
    if ! echo "$frontmatter" | grep -q "^applyTo:"; then
      error "$basename: Missing required 'applyTo' field in frontmatter"
    else
      apply_to=$(echo "$frontmatter" | grep "^applyTo:" | sed 's/applyTo: *"\{0,1\}\(.*\)"\{0,1\}/\1/')
      ok "$basename: applyTo = ${apply_to}"
    fi

    echo ""
  done
else
  warn "Directory $INSTRUCTIONS_DIR does not exist (optional)"
fi

# 3. Check for stale references to old format
echo "=== Checking for Stale References ==="
echo ""

stale_refs=$(grep -rn "\.github/copilot" --include="*.md" --include="*.yml" --include="*.yaml" . 2>/dev/null | grep -v "node_modules" | grep -v ".git/" || true)
if [ -n "$stale_refs" ]; then
  warn "Found references to old .github/copilot/ format:"
  echo "$stale_refs"
  echo ""
else
  ok "No stale references to .github/copilot/"
fi

# 4. Summary
echo "=== Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo "Agent files: ${#AGENT_NAMES[@]} (${AGENT_NAMES[*]})"

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}FAILED${NC}: $ERRORS error(s) found"
  exit 1
else
  echo -e "${GREEN}PASSED${NC}: All validations passed"
  exit 0
fi
