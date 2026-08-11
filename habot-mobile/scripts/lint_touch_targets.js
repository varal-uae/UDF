// ============================================================================
// lint_touch_targets.js — CI/CD Touch Target Linter
// File: scripts/lint_touch_targets.js
// Version: v1 | Created: 2026-08-10
// Step: TTMAC-010-A10 | Ritwik Sharma — Frontend Integration Specialist
// Team: UDF — UX Design & Frontend Engineering | Habot Connect DMCC
//
// PURPOSE:
//   Automated CI/CD compilation linter that scans all Dart/Flutter source
//   files and rejects any interactive element definition with a touch target
//   below the 44dp floor boundary.
//
// POKA-YOKE:
//   CI/CD pipeline runs this script on every PR. Any violation blocks merge.
//   Engineers cannot ship non-compliant touch targets without explicit review.
//
// STANDARDS:
//   Floor:   44dp (WCAG 2.5.5 AAA minimum)
//   Optimal: 48dp (MD3 + HABOT TTMAC-010 standard)
//   Spacing: 8dp between adjacent interactive elements
//
// USAGE:
//   node scripts/lint_touch_targets.js              # scan lib/ directory
//   node scripts/lint_touch_targets.js --dir src/   # custom directory
//   node scripts/lint_touch_targets.js --strict     # treat warnings as errors
//
// CI/CD INTEGRATION (add to your pipeline config):
//   - run: node scripts/lint_touch_targets.js
//     name: Touch Target Compliance Check (TTMAC-010)
//
// EXIT CODES:
//   0 = All checks pass (≥ 95% conformance)
//   1 = Violations found (< 44dp targets detected)
//   2 = Below floor conformance (< 80% compliant)
// ============================================================================

const fs   = require('fs');
const path = require('path');

// ── CONFIGURATION ─────────────────────────────────────────────────────────────

const CONFIG = {
  // Directory to scan (override with --dir flag)
  scanDir: process.argv.includes('--dir')
    ? process.argv[process.argv.indexOf('--dir') + 1]
    : 'lib',

  // Treat warnings as errors (override with --strict flag)
  strict: process.argv.includes('--strict'),

  // File extensions to scan
  extensions: ['.dart'],

  // Minimum touch target — FLOOR boundary (WCAG 2.5.5)
  floorDp: 44,

  // Optimal touch target — HABOT/MD3 standard
  optimalDp: 48,

  // Conformance rate thresholds
  floorConformance:   0.80, // 80% — must meet to pass
  optimalConformance: 0.95, // 95% — optimal target

  // Files/directories to exclude from scanning
  exclude: ['build/', '.dart_tool/', 'test/', '.g.dart'],
};

// ── VIOLATION PATTERNS ────────────────────────────────────────────────────────
// These patterns detect hardcoded size values below the floor on interactive
// elements. Each pattern has a description and severity.

const VIOLATION_PATTERNS = [
  // Hardcoded width/height below 44dp on interactive containers
  {
    name:        'HARDCODED_SIZE_BELOW_FLOOR',
    severity:    'ERROR',
    description: 'Interactive element has hardcoded size below 44dp floor',
    regex:       /(?:width|height|size)\s*[:=]\s*(\d+(?:\.\d+)?)\s*(?:,|\))/g,
    check: (match, captured) => {
      const val = parseFloat(captured);
      // Flag values between 1 and 43 (below floor, above 0 — 0 is intentional)
      return val > 0 && val < CONFIG.floorDp;
    },
    suggestion: `Use TouchTargetWrapper with minSize: ${CONFIG.optimalDp} or add ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`,
  },

  // GestureDetector without minimum size constraint
  {
    name:        'GESTURE_DETECTOR_NO_CONSTRAINT',
    severity:    'WARNING',
    description: 'GestureDetector used without TouchTargetWrapper or ConstrainedBox',
    regex:       /GestureDetector\s*\(/g,
    check: (match, captured, fileContent, matchIndex) => {
      // Check if wrapped in TouchTargetWrapper within 500 chars before
      const before = fileContent.substring(Math.max(0, matchIndex - 500), matchIndex);
      return !before.includes('TouchTargetWrapper') &&
             !before.includes('ConstrainedBox') &&
             !before.includes('SizedBox');
    },
    suggestion: 'Wrap GestureDetector with TouchTargetWrapper to guarantee 48dp touch target',
  },

  // InkWell without minimum size
  {
    name:        'INKWELL_NO_CONSTRAINT',
    severity:    'WARNING',
    description: 'InkWell used without minimum size constraint',
    regex:       /InkWell\s*\(/g,
    check: (match, captured, fileContent, matchIndex) => {
      const before = fileContent.substring(Math.max(0, matchIndex - 300), matchIndex);
      return !before.includes('TouchTargetWrapper') &&
             !before.includes('ConstrainedBox') &&
             !before.includes('minHeight: 48') &&
             !before.includes('minWidth: 48');
    },
    suggestion: 'Wrap InkWell with TouchTargetWrapper or add ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))',
  },

  // IconButton with size below floor
  {
    name:        'ICON_BUTTON_SMALL',
    severity:    'ERROR',
    description: 'IconButton with explicit size below 44dp',
    regex:       /IconButton\s*\([^)]*iconSize\s*:\s*(\d+(?:\.\d+)?)/g,
    check: (match, captured) => {
      return parseFloat(captured) < CONFIG.floorDp;
    },
    suggestion: 'Use TouchTargetWrapper.icon() which guarantees 48dp hit area regardless of visual icon size',
  },

  // SizedBox on interactive element below floor
  {
    name:        'SIZED_BOX_BELOW_FLOOR',
    severity:    'ERROR',
    description: 'SizedBox with dimensions below 44dp used on interactive element',
    regex:       /SizedBox\s*\(\s*(?:width|height)\s*:\s*(\d+(?:\.\d+)?)/g,
    check: (match, captured, fileContent, matchIndex) => {
      const val = parseFloat(captured);
      if (val <= 0 || val >= CONFIG.floorDp) return false;
      // Only flag if near an interactive widget
      const nearby = fileContent.substring(matchIndex, matchIndex + 300);
      return nearby.includes('GestureDetector') ||
             nearby.includes('InkWell') ||
             nearby.includes('onTap') ||
             nearby.includes('onPressed');
    },
    suggestion: `Replace with ConstrainedBox(constraints: BoxConstraints(minWidth: ${CONFIG.optimalDp}, minHeight: ${CONFIG.optimalDp}))`,
  },
];

// ── FILE SCANNER ──────────────────────────────────────────────────────────────

function shouldExclude(filePath) {
  return CONFIG.exclude.some(ex => filePath.includes(ex));
}

function getFiles(dir, extensions) {
  const files = [];
  if (!fs.existsSync(dir)) return files;

  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (shouldExclude(fullPath)) continue;
    if (entry.isDirectory()) {
      files.push(...getFiles(fullPath, extensions));
    } else if (extensions.some(ext => entry.name.endsWith(ext))) {
      files.push(fullPath);
    }
  }
  return files;
}

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const violations = [];

  for (const pattern of VIOLATION_PATTERNS) {
    const regex = new RegExp(pattern.regex.source, pattern.regex.flags);
    let match;
    while ((match = regex.exec(content)) !== null) {
      const captured = match[1] || '';
      const flagged  = pattern.check(match[0], captured, content, match.index);
      if (flagged) {
        // Get line number
        const lineNum = content.substring(0, match.index).split('\n').length;
        const lineContent = content.split('\n')[lineNum - 1]?.trim() || '';

        violations.push({
          file:        filePath,
          line:        lineNum,
          pattern:     pattern.name,
          severity:    pattern.severity,
          description: pattern.description,
          code:        lineContent.substring(0, 80),
          suggestion:  pattern.suggestion,
          value:       captured ? parseFloat(captured) : null,
        });
      }
    }
  }
  return violations;
}

// ── REPORTER ──────────────────────────────────────────────────────────────────

function printResults(allViolations, totalFiles) {
  const errors   = allViolations.filter(v => v.severity === 'ERROR');
  const warnings = allViolations.filter(v => v.severity === 'WARNING');

  console.log('\n' + '═'.repeat(70));
  console.log('  TTMAC-010 Touch Target Compliance Linter — HABOT Connect DMCC');
  console.log('  Step: TTMAC-010-A10 | Standard: MD3 48dp minimum | WCAG 2.5.5');
  console.log('═'.repeat(70));
  console.log(`\n  Files scanned:    ${totalFiles}`);
  console.log(`  Violations found: ${allViolations.length}`);
  console.log(`  Errors:           ${errors.length}`);
  console.log(`  Warnings:         ${warnings.length}`);
  console.log(`  Floor:            ${CONFIG.floorDp}dp (44dp — WCAG 2.5.5 AAA)`);
  console.log(`  Optimal:          ${CONFIG.optimalDp}dp (48dp — MD3/HABOT standard)`);

  if (allViolations.length === 0) {
    console.log('\n  ✅ ALL CHECKS PASS');
    console.log(`  Touch Target Conformance: 100% | Floor ✅ | Optimal ✅`);
    console.log('═'.repeat(70) + '\n');
    return;
  }

  if (errors.length > 0) {
    console.log('\n  ❌ ERRORS (blocks merge):');
    for (const v of errors) {
      console.log(`\n  [ERROR] ${v.file}:${v.line}`);
      console.log(`  Rule:   ${v.pattern}`);
      console.log(`  Issue:  ${v.description}`);
      if (v.value) console.log(`  Value:  ${v.value}dp (below ${CONFIG.floorDp}dp floor)`);
      console.log(`  Code:   ${v.code}`);
      console.log(`  Fix:    ${v.suggestion}`);
    }
  }

  if (warnings.length > 0) {
    console.log('\n  ⚠️  WARNINGS' + (CONFIG.strict ? ' (strict mode — treated as errors):' : ':'));
    for (const v of warnings) {
      console.log(`\n  [WARN]  ${v.file}:${v.line}`);
      console.log(`  Rule:   ${v.pattern}`);
      console.log(`  Issue:  ${v.description}`);
      console.log(`  Code:   ${v.code}`);
      console.log(`  Fix:    ${v.suggestion}`);
    }
  }

  // Conformance rate
  const compliant = totalFiles > 0
    ? Math.max(0, totalFiles - new Set(allViolations.map(v => v.file)).size)
    : 0;
  const rate = totalFiles > 0 ? compliant / totalFiles * 100 : 0;
  console.log(`\n  Conformance Rate: ${rate.toFixed(1)}%`);
  console.log(`  Floor (80%):      ${rate >= 80 ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`  Optimal (95%):    ${rate >= 95 ? '✅ PASS' : '🟡 BELOW OPTIMAL'}`);
  console.log('═'.repeat(70) + '\n');
}

// ── MAIN ──────────────────────────────────────────────────────────────────────

function main() {
  console.log(`\nScanning: ${path.resolve(CONFIG.scanDir)}`);
  console.log(`Strict mode: ${CONFIG.strict ? 'ON' : 'OFF'}`);

  const files      = getFiles(CONFIG.scanDir, CONFIG.extensions);
  const violations = [];

  for (const file of files) {
    const fileViolations = scanFile(file);
    violations.push(...fileViolations);
  }

  printResults(violations, files.length);

  // Exit codes
  const errors = violations.filter(v => v.severity === 'ERROR');
  const warns  = violations.filter(v => v.severity === 'WARNING');

  if (errors.length > 0 || (CONFIG.strict && warns.length > 0)) {
    process.exit(1); // Violations found — block merge
  }

  const compliantFiles = files.length - new Set(violations.map(v => v.file)).size;
  const rate = files.length > 0 ? compliantFiles / files.length : 1;
  if (rate < CONFIG.floorConformance) {
    process.exit(2); // Below floor conformance
  }

  process.exit(0); // All good
}

main();
