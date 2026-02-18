---
name: swift-tdd
description: Test-Driven Development specialist for Swift/iOS. Enforces write-tests-first methodology using both XCTest and Swift Testing framework. Ensures 80%+ coverage via xcodebuild.
---

# Swift TDD

Enforce write-tests-first methodology for Swift/iOS projects.

## When to Activate

- User says "tdd", "test first", "write tests", or similar
- Writing new features, fixing bugs, or refactoring Swift code
- Adding test coverage to existing code

## TDD Cycle: Red → Green → Refactor

| Phase | Action | Rule |
|-------|--------|------|
| **RED** | Write a failing test | Test must fail for the right reason |
| **GREEN** | Write minimal implementation | Just enough to pass — no more |
| **REFACTOR** | Improve code | Keep tests green after each change |
| **VERIFY** | Check coverage | Target 80%+ line coverage |

## Framework Choice

- **Swift Testing** (`import Testing`, `@Test`, `#expect`) — preferred for new code, iOS 17+
- **XCTest** (`import XCTest`, `XCTAssert*`) — for existing suites or < iOS 17

## Build & Run Commands

```bash
# Run tests (Mac Catalyst — fastest, supports Metal)
xcodebuild test -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  -only-testing:MyAppTests 2>&1 | tail -20

# Run tests with coverage
xcodebuild test -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  -enableCodeCoverage YES \
  -resultBundlePath TestResults.xcresult 2>&1 | tail -20

# Extract coverage
xcrun xccov view --report TestResults.xcresult
```

## Test Patterns (table — no code blocks needed, Claude knows Swift)

| Pattern | When | Key Points |
|---------|------|------------|
| Protocol-based mocking | External dependencies (network, sensors, GPS) | Define protocol → production impl → test mock returning canned `Result` |
| `@MainActor` test isolation | UI-touching code | Annotate test class/suite with `@MainActor` |
| Parameterized tests | Multiple input/output pairs | Swift Testing: `@Test(arguments: [...])` |
| Async testing | Actor-isolated or async code | `async throws` test functions, `await` assertions |
| Float comparison | Geometry, angles, coordinates | `accuracy:` param (XCTest) or `abs(a - b) < epsilon` (Swift Testing) |
| UserDefaults cleanup | State-dependent tests | `removePersistentDomain(forName:)` in setUp |

## Edge Cases to Always Cover

- nil/Optional values
- Empty collections and empty Data
- Boundary values: 0, -1, Int.max, .infinity, .nan
- Actor-isolated state accessed from multiple tasks
- Memory pressure (cache eviction)

## Quality Checklist

- [ ] All public functions have tests
- [ ] Error paths tested (not just happy path)
- [ ] Edge cases covered (nil, empty, boundary)
- [ ] Tests are independent (setUp clears state)
- [ ] Test names describe behavior being verified
- [ ] Mocks used for external dependencies
- [ ] Assertions are specific (`#expect(x == 5)` not `#expect(x != nil)`)
- [ ] Coverage 80%+ (run xccov to verify)
- [ ] No `sleep()` — use async/await or expectations
- [ ] Mac Catalyst destination if Metal/GPU code involved
