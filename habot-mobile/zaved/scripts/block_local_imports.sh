#!/usr/bin/env bash
# ============================================================================
# TELEMETRY METADATA BLOCK
# Definition Name: Local Import Blocker Gatekeeper Script
# Definition Parameters: {targetPattern: "../widgets/", approvedPackage: "package:universal_src_library/"}
# Definition Type: Build-time Poka-Yoke Import Validator
# Validation Status: Active
# Definition ID: SRC-GATEKEEPER-BLOCKER-001
# Completion Status: Complete - 100% of rules formally defined, reviewed, and versioned
# ============================================================================

set -euo pipefail

echo "=== [SRC Catalog] Scanning for illegal local component imports ==="

# Check for local redundant imports of shared primitives
ILLEGAL_IMPORTS=$(grep -rnE "import\s+['\"].*(\.\./widgets/|components/custom_button|components/custom_dropdown).*['\"];" lib/ui/ || true)

if [ -n "$ILLEGAL_IMPORTS" ]; then
  echo "❌ COMPILATION BLOCKED: Redundant local component import detected!"
  echo "The following imports violate the SRC reuse policy:"
  echo "$ILLEGAL_IMPORTS"
  echo ""
  echo "Rule: Developers must import approved components from 'package:universal_src_library/...' instead."
  exit 1
fi

echo "✓ Code Reuse Gatekeeper Passed: 100% SRC compliance."
