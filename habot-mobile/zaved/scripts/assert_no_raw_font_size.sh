#!/usr/bin/env bash
# ==============================================================================
# scripts/assert_no_raw_font_size.sh
# BPTR-0334-A15: Hardcoded Font-Size Blocker (Poka-Yoke)
# Fails compilation & PR checks if raw `fontSize:` is declared inside UI components
# ==============================================================================

set -e

echo "🔍 [Typography Gate] Scanning for unauthorized custom font sizes..."

# Scan lib directory excluding theme token definitions and test files
VIOLATIONS=$(grep -rnE --include="*.dart" \
  --exclude="strict_m3_text_theme.dart" \
  --exclude="app_design_tokens.dart" \
  --exclude="fluid_text_scaler.dart" \
  --exclude-dir="test" \
  "TextStyle\([^)]*fontSize:" lib/ || true)

if [ -n "$VIOLATIONS" ]; then
  echo ""
  echo "❌ POKA-YOKE VIOLATION: Hardcoded 'fontSize' detected in TextStyle!"
  echo "------------------------------------------------------------------"
  echo "$VIOLATIONS"
  echo "------------------------------------------------------------------"
  echo "👉 ENFORCEMENT: Custom font size inputs are banned."
  echo "👉 REQUIRED FIX: Use Theme.of(context).textTheme.<token>."
  exit 1
else
  echo "✅ [Typography Gate] Passed: All typography strictly conforms to MD3 tokens."
  exit 0
fi
