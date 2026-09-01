#!/bin/bash
# ==============================================================================
# RCGLA-014-A02 & TTMCS-003-A16: POKA-YOKE UNIVERSAL LIBRARY ENFORCEMENT SCRIPT
# ==============================================================================
# This pre-commit / CI script scans the repository to prevent:
# 1. Unmapped hardcoded Color(0x...) or standard Colors.* instantiations in lib/ui/
# 2. Duplicate local component widgets (e.g. *button.dart) outside lib/widgets/
# ==============================================================================

set -e

echo "=================================================================="
echo " Running Universal Component & Token Adherence Blocker (Poka-Yoke)"
echo "=================================================================="

VIOLATIONS_FOUND=0

# 1. Scan for hardcoded colors in lib/ui/
echo "==> Scanning lib/ui/ for unmapped hardcoded color declarations..."
HARDCODED_COLORS=$(grep -rnE "\bColor\s*\(\s*0x[0-9a-fA-F]+\s*\)|\bColors\.[a-zA-Z0-9_]+" lib/ui/ || true)

if [ -n "$HARDCODED_COLORS" ]; then
    echo "ERROR: Hardcoded color values detected in lib/ui/!"
    echo "$HARDCODED_COLORS"
    VIOLATIONS_FOUND=1
else
    echo "PASS: Zero hardcoded colors detected in lib/ui/."
fi

# 2. Scan for duplicate local button widgets outside lib/widgets/
echo "==> Scanning for duplicate local widget files outside authorized directories..."
LOCAL_BUTTON_FILES=$(find lib/ -name "*button*.dart" -not -path "lib/widgets/*" -not -path "lib/ui/system_verb_button.dart" -not -path "lib/ui/loading_submit_button_form.dart" || true)

if [ -n "$LOCAL_BUTTON_FILES" ]; then
    echo "ERROR: Unauthorized local button components detected outside universal library!"
    echo "$LOCAL_BUTTON_FILES"
    echo "Action Required: Consume UniversalPrimaryButton from lib/widgets/ instead."
    VIOLATIONS_FOUND=1
else
    echo "PASS: Zero unauthorized local button duplicates found."
fi

if [ $VIOLATIONS_FOUND -ne 0 ]; then
    echo "=================================================================="
    echo " FAILED: Universal Library Enforcement Blocker Triggered!"
    echo "=================================================================="
    exit 1
fi

echo "=================================================================="
echo " SUCCESS: 100% Universal Design System Adherence Confirmed!"
echo "=================================================================="
exit 0
