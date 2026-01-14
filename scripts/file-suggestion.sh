#!/bin/bash

# Read the query from stdin
query=$(cat | jq -r '.query')

# Use ripgrep to find files matching the query
# --files: List files (don't search content)
# --no-ignore-parent: Don't use .gitignore from parent directories
# --glob: Pattern matching for the query
# We search from CLAUDE_PROJECT_DIR and filter results
cd "$CLAUDE_PROJECT_DIR"

if [ -z "$query" ]; then
  # No query, list recent files
  rg --files --no-ignore-parent \
    --glob '!.git/' \
    --glob '!build/' \
    --glob '!.gradle/' \
    --glob '!node_modules/' \
    2>/dev/null | head -20
else
  # With query, search for matching files
  rg --files --no-ignore-parent \
    --glob '!.git/' \
    --glob '!build/' \
    --glob '!.gradle/' \
    --glob '!node_modules/' \
    2>/dev/null | rg "$query" | head -20
fi
