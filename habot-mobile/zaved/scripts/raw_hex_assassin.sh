#!/usr/bin/env bash
# ==============================================================================
# scripts/raw_hex_assassin.sh
# TTMCS-002-A01: The Raw Hex Assassin (Poka-Yoke Linter)
# Fails compilation & CI/CD pull requests if raw hex color declarations
# (e.g. Color(0x...), Colors.red) are used in UI components.
# ==============================================================================

set -e

echo "⚔️ [The Raw Hex Assassin] Scanning for unauthorized color styling..."

EXCLUDE_ARGS="--exclude=semantic_colors.dart --exclude=semantic_status_colors.dart --exclude=app_design_tokens.dart --exclude=app_theme.dart --exclude=theme_config.dart --exclude-dir=test"

# 1. Check for raw Color(0x...) or Color(0X...)
HEX_MATCHES=$(grep -rnE $EXCLUDE_ARGS --include="*.dart" "Color\(0[xX][0-9a-fA-F]{6,8}\)" lib/ui/ || true)

# 2. Check for Colors.<palette> directly in UI code
MATERIAL_COLOR_MATCHES=$(grep -rnE $EXCLUDE_ARGS --include="*.dart" "Colors\.(red|green|blue|yellow|orange|purple|pink|teal|amber|grey|cyan)" lib/ui/ || true)

if [ -n "$HEX_MATCHES" ] || [ -n "$MATERIAL_COLOR_MATCHES" ]; then
  echo ""
  echo "🚨 BUILD REJECTED: Raw color styling detected!"
  echo "--------------------------------------------------"
  if [ -n "$HEX_MATCHES" ]; then
    echo "Direct Hex Instantiations Found:"
    echo "$HEX_MATCHES"
  fi
  if [ -n "$MATERIAL_COLOR_MATCHES" ]; then
    echo "Raw Colors.<name> Invocations Found:"
    echo "$MATERIAL_COLOR_MATCHES"
  fi
  echo "--------------------------------------------------"
  echo "👉 REQUIRED FIX: Use dynamic semantic tokens via:"
  echo "   Theme.of(context).extension<SemanticColors>()!.success"
  echo "   Theme.of(context).extension<SemanticColors>()!.error"
  exit 1
else
  echo "✅ [The Raw Hex Assassin] Passed: All UI styling strictly utilizes semantic design tokens."
  exit 0
fi
