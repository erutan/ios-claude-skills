---
name: swift-test-coverage
description: Analyze Swift test coverage via xcodebuild and xcrun xccov. Identifies under-covered files, generates test stubs, and tracks progress toward 80%+ threshold.
---

# Swift Test Coverage

Analyze and improve test coverage for Swift/iOS projects.

## When to Activate

- User says "test coverage", "coverage report", "what's not covered"
- After writing new code, to verify coverage
- Before merging, to check thresholds

## Workflow

### 1. Run Tests with Coverage

```bash
# Delete stale results first
rm -rf /tmp/TestResults.xcresult

# Mac Catalyst (fastest, supports Metal)
xcodebuild test -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/TestResults.xcresult \
  -only-testing:MyAppTests 2>&1 | tail -20
```

### 2. Analyze Coverage

```bash
# Summary
xcrun xccov view --report /tmp/TestResults.xcresult

# File-level for app target
xcrun xccov view --report /tmp/TestResults.xcresult --files-for-target MyApp.app

# Line-level for a specific file
xcrun xccov view --file /path/to/SourceFile.swift /tmp/TestResults.xcresult

# Find files below 80% (JSON parsing)
xcrun xccov view --report --json /tmp/TestResults.xcresult \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
for target in data.get('targets', []):
    if 'Test' in target['name']: continue
    for f in target.get('files', []):
        pct = f['lineCoverage'] * 100
        if pct < 80:
            print(f'{pct:5.1f}%  {f[\"name\"]}')
" | sort -n
```

### 3. Generate Tests for Under-Covered Files

For each file below threshold:
- Identify untested public methods and error paths
- Generate tests using project conventions (Swift Testing or XCTest)
- Mock external dependencies via protocols
- Cover: happy path → error path → edge cases → branch coverage

### 4. Verify Improvement

Re-run coverage. Repeat until threshold met.

## Coverage Targets

| Category | Target | Rationale |
|----------|--------|-----------|
| Business logic (models, services, managers) | 80%+ | Core correctness |
| Utility functions | 90%+ | Pure functions, easy to test |
| View logic (computed properties, formatting) | 70%+ | Testable without UI |
| SwiftUI views | Skip | Test via UI tests or manually |
| Metal shaders | Skip | Test via integration on GPU output |
| App entry point / delegates | Skip | Minimal logic |

## Tips

- Mac Catalyst destination for fastest turnaround + Metal support
- `-only-testing:` to skip UI tests for speed
- Delete old `.xcresult` before re-running — coverage data is cumulative
- Focus effort on business logic — highest ROI
- Watch for 0% files that should have tests (new code without TDD)
