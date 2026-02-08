---
name: swift-test-coverage
description: Analyze Swift test coverage via xcodebuild and xcrun xccov. Identifies under-covered files, generates test stubs, and tracks progress toward 80%+ threshold.
---

# Swift Test Coverage

Analyze and improve test coverage for Swift/iOS projects using xcodebuild code coverage tooling.

## When to Activate

- User says "test coverage", "coverage report", "what's not covered"
- After writing new code, to verify coverage
- Before merging, to check coverage thresholds
- When identifying what tests to write next

## Coverage Workflow

### 1. Run Tests with Coverage

```bash
# Mac Catalyst (fastest, supports Metal)
xcodebuild test -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/TestResults.xcresult \
  -only-testing:MyAppTests 2>&1 | tail -20

# iOS Simulator
xcodebuild test -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/TestResults.xcresult \
  -only-testing:MyAppUnitTests 2>&1 | tail -20
```

**Important**: Delete previous xcresult before re-running or use a unique path:
```bash
rm -rf /tmp/TestResults.xcresult
```

### 2. View Coverage Summary

```bash
# Overall summary (all targets)
xcrun xccov view --report /tmp/TestResults.xcresult

# JSON format for parsing
xcrun xccov view --report --json /tmp/TestResults.xcresult

# Filter to app target only (exclude test targets, frameworks)
xcrun xccov view --report /tmp/TestResults.xcresult | grep "MyApp"
```

### 3. View File-Level Coverage

```bash
# All files with coverage percentages
xcrun xccov view --report /tmp/TestResults.xcresult --files-for-target MyApp.app

# JSON for programmatic analysis
xcrun xccov view --report --json /tmp/TestResults.xcresult --files-for-target MyApp.app
```

### 4. View Line-Level Coverage for a Specific File

```bash
# See which lines are covered/uncovered
xcrun xccov view --file /path/to/SourceFile.swift /tmp/TestResults.xcresult
```

### 5. Identify Under-Covered Files

Parse the JSON report to find files below 80%:

```bash
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

## Coverage Targets

| Category | Target | Rationale |
|----------|--------|-----------|
| Business logic (models, services, managers) | 80%+ | Core correctness |
| Utility functions | 90%+ | Pure functions, easy to test |
| View logic (computed properties, formatting) | 70%+ | Testable without UI |
| SwiftUI views | Skip | Test via UI tests or manually |
| Metal shaders | Skip | Test via integration tests on GPU output |
| App entry point / delegates | Skip | Minimal logic |

## Generating Test Stubs

For each under-covered file, generate test stubs following these patterns:

### For a Service/Manager class:
```swift
import Testing
@testable import MyApp

@Suite("ServiceName")
struct ServiceNameTests {
    // Test each public method
    @Test("methodName does expected thing")
    func methodName() async throws {
        let sut = ServiceName(dependency: MockDependency())
        let result = try await sut.methodName(input)
        #expect(result == expectedOutput)
    }

    // Test error paths
    @Test("methodName throws on invalid input")
    func methodNameError() async throws {
        let sut = ServiceName(dependency: MockDependency())
        await #expect(throws: ServiceError.invalidInput) {
            try await sut.methodName(badInput)
        }
    }
}
```

### For a Model/Value type:
```swift
@Suite("ModelName")
struct ModelNameTests {
    @Test("initializes with valid data")
    func validInit() {
        let model = ModelName(x: 1, y: 2)
        #expect(model.x == 1)
        #expect(model.y == 2)
    }

    @Test("equatable conformance")
    func equality() {
        let a = ModelName(x: 1, y: 2)
        let b = ModelName(x: 1, y: 2)
        #expect(a == b)
    }

    @Test("computed properties")
    func computedProperty() {
        let model = ModelName(x: 3, y: 4)
        #expect(abs(model.magnitude - 5.0) < 0.0001)
    }
}
```

## Coverage Report Format

```
# Test Coverage Report

## Summary
- Overall coverage: XX.X%
- Target: 80%
- Status: PASSING / NEEDS WORK

## Files Below Threshold

| File | Coverage | Gap | Priority |
|------|----------|-----|----------|
| TileLoader.swift | 45.2% | -34.8% | HIGH |
| SearchManager.swift | 62.1% | -17.9% | MEDIUM |
| Constants.swift | 78.5% | -1.5% | LOW |

## Well-Covered Files (80%+)
- MotionManager.swift: 92.3%
- TileCache.swift: 85.7%
- Geometry.swift: 97.1%

## Excluded from Coverage
- SwiftUI Views (test via UI tests)
- Metal shaders (test via integration)
- App entry point

## Recommended Next Tests
1. TileLoader.swift — mock network layer, test fetch/retry/error paths
2. SearchManager.swift — test search query formatting, result mapping
3. Constants.swift — test computed constants, boundary values
```

## Tips

- Run coverage on **Mac Catalyst** for fastest turnaround and Metal support
- Use `-only-testing:` to run specific test bundles (skip UI tests for speed)
- Coverage data is cumulative in an xcresult — delete old results before re-running
- Focus effort on business logic, not UI code — highest ROI for testing
- Watch for files with 0% coverage that should have tests (new code without TDD)
