// TTMCS-013-A01 — Design Token CI Linter
// Audits all Dart files under lib/ for:
//   1. Hardcoded hex color values  (e.g. Color(0xFF1b2a4a), Color(0xFFffffff))
//   2. Raw numeric dimension values (e.g. EdgeInsets.all(16), SizedBox(height: 24))
//      that should reference HabotSpacing / HabotRadius / HabotElevation tokens
//   3. Hardcoded font size values   (e.g. fontSize: 14)
//      that should reference HabotFontSize tokens
//
// Exit code 1 — violations found → blocks CI merge pipeline.
// Exit code 0 — clean → merge allowed.
//
// Run:
//   node scripts/lint_design_tokens.js
//   node scripts/lint_design_tokens.js --strict   (warnings treated as errors)
//
// Add to GitHub Actions:
//   - name: Design Token Compliance (TTMCS-013)
//     run: node scripts/lint_design_tokens.js

const fs   = require('fs');
const path = require('path');

const STRICT = process.argv.includes('--strict');
const LIB_DIR = path.join(__dirname, '..', 'lib');

// ─── VIOLATION PATTERNS ───────────────────────────────────────────────────────

const RULES = [
  {
    id:       'TOKEN-001',
    severity: 'error',
    pattern:  /Color\(0x[0-9A-Fa-f]{8}\)/g,
    message:  'Hardcoded hex color — use HabotColorTokens or Theme.of(context).colorScheme',
    exempt:   ['design_tokens.dart', 'color_schemes.dart'],
  },
  {
    id:       'TOKEN-002',
    severity: 'error',
    pattern:  /Color\(#[0-9A-Fa-f]{3,8}\)/g,
    message:  'Hardcoded hex color string — use HabotColorTokens',
    exempt:   ['design_tokens.dart', 'color_schemes.dart'],
  },
  {
    id:       'TOKEN-003',
    severity: 'warning',
    pattern:  /fontSize:\s*\d+(\.\d+)?(?!\s*\/\/\s*token)/g,
    message:  'Raw fontSize value — use HabotFontSize token',
    exempt:   ['design_tokens.dart', 'text_theme.dart'],
  },
  {
    id:       'TOKEN-004',
    severity: 'warning',
    pattern:  /EdgeInsets\.(all|symmetric|only|fromLTRB)\([\d.,\s]+\)/g,
    message:  'Raw EdgeInsets value — use HabotSpacing token',
    exempt:   ['design_tokens.dart', 'app_theme.dart'],
  },
  {
    id:       'TOKEN-005',
    severity: 'warning',
    pattern:  /SizedBox\((width|height):\s*\d+(\.\d+)?\)/g,
    message:  'Raw SizedBox dimension — use HabotSpacing token',
    exempt:   ['design_tokens.dart'],
  },
  {
    id:       'TOKEN-006',
    severity: 'warning',
    pattern:  /BorderRadius\.circular\(\d+(\.\d+)?\)/g,
    message:  'Raw BorderRadius value — use HabotRadius token',
    exempt:   ['design_tokens.dart', 'app_theme.dart'],
  },
];

// ─── FILE WALKER ──────────────────────────────────────────────────────────────

function walkDir(dir) {
  let files = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files = files.concat(walkDir(full));
    } else if (entry.name.endsWith('.dart')) {
      files.push(full);
    }
  }
  return files;
}

// ─── LINT ─────────────────────────────────────────────────────────────────────

function lint() {
  const files     = walkDir(LIB_DIR);
  const violations = [];

  for (const file of files) {
    const fileName = path.basename(file);
    const content  = fs.readFileSync(file, 'utf8');
    const lines    = content.split('\n');

    for (const rule of RULES) {
      if (rule.exempt.includes(fileName)) continue;

      lines.forEach((line, idx) => {
        const matches = [...line.matchAll(rule.pattern)];
        for (const match of matches) {
          violations.push({
            file:     path.relative(process.cwd(), file),
            line:     idx + 1,
            col:      match.index + 1,
            rule:     rule.id,
            severity: rule.severity,
            message:  rule.message,
            source:   line.trim(),
          });
        }
      });
    }
  }

  return violations;
}

// ─── REPORT ───────────────────────────────────────────────────────────────────

function report(violations) {
  if (violations.length === 0) {
    console.log('✅ TTMCS-013 — Design token compliance: PASS (0 violations)');
    process.exit(0);
  }

  const errors   = violations.filter(v => v.severity === 'error');
  const warnings = violations.filter(v => v.severity === 'warning');

  console.log(`\n❌ TTMCS-013 — Design token compliance: FAIL`);
  console.log(`   ${errors.length} error(s)   ${warnings.length} warning(s)\n`);

  for (const v of violations) {
    const icon = v.severity === 'error' ? '✖' : '⚠';
    console.log(`${icon} [${v.rule}] ${v.file}:${v.line}:${v.col}`);
    console.log(`  ${v.message}`);
    console.log(`  → ${v.source}\n`);
  }

  const shouldFail = errors.length > 0 || (STRICT && warnings.length > 0);
  process.exit(shouldFail ? 1 : 0);
}

report(lint());
