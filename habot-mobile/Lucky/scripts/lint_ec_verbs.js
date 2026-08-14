// PELCE-019-10 — English Code (EC) System Verbs CI Linter
// Restricts mobile CTA button labels to strict machine-action verbs.
//
// Audits Dart files under lib/ for unauthorized or conversational button text.
// Exit code 1 — violations found → blocks CI merge pipeline.
// Exit code 0 — clean → merge allowed.
//
// Run:
//   node scripts/lint_ec_verbs.js
//   node scripts/lint_ec_verbs.js --strict
//   node scripts/lint_ec_verbs.js --dir lib
//
// Add to GitHub Actions:
//   - name: EC Verb Compliance (PELCE-019-10)
//     run: node scripts/lint_ec_verbs.js

const fs   = require('fs');
const path = require('path');

const STRICT  = process.argv.includes('--strict');
const DIR_ARG = process.argv.includes('--dir')
  ? process.argv[process.argv.indexOf('--dir') + 1]
  : null;

const SCRIPT_DIR = __dirname;
const CATALOG    = JSON.parse(
  fs.readFileSync(path.join(SCRIPT_DIR, 'ec_verb_catalog.json'), 'utf8'),
);

const LIB_DIR = path.resolve(
  SCRIPT_DIR,
  '..',
  DIR_ARG ?? 'lib',
);

const ALLOWED_VERBS   = new Set(CATALOG.allowedVerbs.map(v => v.toLowerCase()));
const ALLOWED_PHRASES = new Set(CATALOG.allowedPhrases.map(p => p.toLowerCase()));
const BLOCKED         = CATALOG.blockedPatterns.map(p => new RegExp(p, 'i'));
const EXEMPT_FILES    = new Set(CATALOG.exemptFiles);
const MAX_WORDS       = CATALOG.rules.maxWords;
const BUTTON_CTX      = new RegExp(CATALOG.buttonContextPattern);

// ─── FILE WALKER ─────────────────────────────────────────────────────────────

function walkDir(dir) {
  if (!fs.existsSync(dir)) {
    console.error(`❌ Scan directory not found: ${dir}`);
    process.exit(2);
  }

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

// ─── LABEL EXTRACTION ─────────────────────────────────────────────────────────

const STRING_PATTERNS = [
  /Text\(\s*['"]([^'"]+)['"]/g,
  /label:\s*['"]([^'"]+)['"]/g,
  /retryLabel:\s*['"]([^'"]+)['"]/g,
  /loadingLabel:\s*['"]([^'"]+)['"]/g,
  /actionLabel:\s*['"]([^'"]+)['"]/g,
];

function extractLabels(line) {
  const labels = [];
  for (const pattern of STRING_PATTERNS) {
    pattern.lastIndex = 0;
    let match;
    while ((match = pattern.exec(line)) !== null) {
      labels.push({ text: match[1], index: match.index + 1 });
    }
  }
  return labels;
}

function normalizeLabel(text) {
  return text
    .replace(/…/g, '')
    .replace(/\.\.\./g, '')
    .trim()
    .toLowerCase();
}

function firstWord(text) {
  return text.split(/\s+/)[0]?.replace(/[^a-z'-]/gi, '').toLowerCase() ?? '';
}

function validateLabel(raw) {
  const normalized = normalizeLabel(raw);
  if (!normalized) return null;

  // Exact phrase allowlist (handles multi-word CTAs)
  if (ALLOWED_PHRASES.has(normalized)) return null;

  // Loading-state variants — "Submitting", "Retrying"
  const stem = normalized.replace(/ing$/, '');
  if (ALLOWED_VERBS.has(stem) && normalized.endsWith('ing')) return null;

  // Block conversational patterns
  for (const blocked of BLOCKED) {
    if (blocked.test(raw.trim())) {
      return {
        rule:     'EC-VERB-002',
        severity: 'error',
        message:  `Conversational or unauthorized CTA verb — "${raw}"`,
      };
    }
  }

  // First word must be an allowed machine-action verb
  const verb = firstWord(normalized);
  if (!ALLOWED_VERBS.has(verb)) {
    return {
      rule:     'EC-VERB-001',
      severity: 'error',
      message:  `Unauthorized CTA verb "${verb}" — use EC machine-action verb from ec_verb_catalog.json`,
    };
  }

  // Word count guard — primary CTAs should be concise
  const wordCount = normalized.split(/\s+/).length;
  if (wordCount > MAX_WORDS) {
    return {
      rule:     'EC-VERB-003',
      severity: 'warning',
      message:  `CTA exceeds ${MAX_WORDS} words — use single machine-action verb where possible`,
    };
  }

  return null;
}

// ─── LINT ─────────────────────────────────────────────────────────────────────

function lint() {
  const files      = walkDir(LIB_DIR);
  const violations = [];

  for (const file of files) {
    const fileName = path.basename(file);
    if (EXEMPT_FILES.has(fileName)) continue;

    const lines = fs.readFileSync(file, 'utf8').split('\n');

    lines.forEach((line, idx) => {
      if (!BUTTON_CTX.test(line)) return;

      for (const { text, index } of extractLabels(line)) {
        const violation = validateLabel(text);
        if (violation) {
          violations.push({
            file:     path.relative(process.cwd(), file),
            line:     idx + 1,
            col:      index,
            ...violation,
            source:   line.trim(),
            label:    text,
          });
        }
      }
    });
  }

  return violations;
}

// ─── REPORT ───────────────────────────────────────────────────────────────────

function report(violations) {
  if (violations.length === 0) {
    console.log('✅ PELCE-019-10 — EC verb compliance: PASS (0 violations)');
    process.exit(0);
  }

  const errors   = violations.filter(v => v.severity === 'error');
  const warnings = violations.filter(v => v.severity === 'warning');

  console.log(`\n❌ PELCE-019-10 — EC verb compliance: FAIL`);
  console.log(`   ${errors.length} error(s)   ${warnings.length} warning(s)\n`);

  for (const v of violations) {
    const icon = v.severity === 'error' ? '✖' : '⚠';
    console.log(`${icon} [${v.rule}] ${v.file}:${v.line}:${v.col}`);
    console.log(`  Label: "${v.label}"`);
    console.log(`  ${v.message}`);
    console.log(`  → ${v.source}\n`);
  }

  const shouldFail = errors.length > 0 || (STRICT && warnings.length > 0);
  process.exit(shouldFail ? 1 : 0);
}

report(lint());
