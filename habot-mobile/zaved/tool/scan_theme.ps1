$hexRegex = [regex]'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)'
$matRegex = [regex]'\bColors\.[a-zA-Z0-9_]+'
$files = Get-ChildItem -Path 'lib/ui' -Filter '*.dart' -Recurse
$totalViolations = 0

foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    $fileViolations = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $trimmed = $line.Trim()
        if ($trimmed.StartsWith('//') -or $trimmed.StartsWith('*') -or $trimmed.StartsWith('/*')) {
            continue
        }
        if ($hexRegex.IsMatch($line) -or $matRegex.IsMatch($line)) {
            $fileViolations += "Line $($i+1): $trimmed"
        }
    }
    if ($fileViolations.Count -gt 0) {
        $totalViolations += $fileViolations.Count
        Write-Output "=== $($file.Name) ($($fileViolations.Count)) ==="
        foreach ($v in $fileViolations) {
            Write-Output "  $v"
        }
    }
}
Write-Output "TOTAL REMAINING VIOLATIONS: $totalViolations"
