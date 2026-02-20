# swift-claude-skills

Claude Code skills and hooks for Swift/iOS/Mac Catalyst projects.

## Skills

| Skill | Description |
|-------|-------------|
| `swift-review` | Code review for Swift 6 concurrency, value types, protocol design, memory, iOS best practices |
| `swift-tdd` | Test-driven development with Swift Testing and XCTest. Red-green-refactor workflow, 80%+ coverage |
| `swift-test-coverage` | Coverage analysis via xcodebuild + xcrun xccov. Finds gaps, generates stubs |
| `xcode-build-resolver` | Fix build errors with minimal diffs. Concurrency, type, linker, Metal, signing |
| `update-codemaps` | Token-lean architecture docs (~1000 tokens/file) for AI context consumption |
| `strategic-compact` | Suggest `/compact` at logical workflow breakpoints instead of arbitrary auto-compaction |

## Hooks

| Hook | Description |
|------|-------------|
| `swift-parse-check` | Runs `swiftc -parse` after every Edit/Write on `.swift` files. Catches syntax errors immediately |

## Install

Add skills to your project via `--add-dir`:

```bash
claude --add-dir /path/to/swift-claude-skills
```

Or copy individual skills into your project's `.claude/skills/` directory.

For hooks, see [hooks/INSTALL.md](hooks/INSTALL.md).

## Design Principles

- **Token-lean** — skills describe *what to check*, not *how to write Swift*. Claude already knows the language.
- **Tables over code blocks** — patterns, errors, and fixes as one-liner references, not tutorials.
- **Workflow-first** — each skill defines a clear sequence of steps, not a knowledge dump.
