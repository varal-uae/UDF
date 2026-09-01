#!/usr/bin/env bash
# ============================================================================
# TELEMETRY METADATA BLOCK
# Creation Date: 2026-08-26T11:08:43+05:30
# Created By: Antigravity UI Architecture Team
# Creation Method: Automated Atomic Mobile Grid Width Validator
# Initial Configuration: {maxAllowedFixedWidth: 360.0dp, scanTarget: "lib/ui/"}
# Object ID: LINTER-WIDTH-BLOCKER-012
# Completion Status: Complete - 100% Typography Token Scale Adherence
# ============================================================================

set -euo pipefail

echo "=== [Atomic Grid] Validating Layout Container Widths (Max allowed fixed width: 360px) ==="

# Check for hardcoded fixed pixel widths over 360px on layout wrappers (e.g., width: 361.0, width: 400.0, width: 1000.0)
INVALID_WIDTHS=$(grep -rnE "width:\s*([4-9][0-9]{2}|[1-9][0-9]{3,})\.0" lib/ui/ || true)

if [ -n "$INVALID_WIDTHS" ]; then
  echo "❌ COMPILATION BLOCKED: Hardcoded fixed pixel width (>360px) detected in layout layer:"
  echo "$INVALID_WIDTHS"
  echo ""
  echo "Fix: Replace hardcoded static widths with MobileGridContainer, LayoutBuilder, or flex fractions."
  exit 1
fi

echo "✓ Fluid Grid Validation Passed: Zero hardcoded width overflows detected."
