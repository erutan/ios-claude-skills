---
name: update-codemaps
description: Generate or refresh codemaps for Swift/iOS projects. Scans Swift source files to produce architecture.md, backend.md, data.md, and frontend.md in the codemaps/ directory.
---

# Update Codemaps

Generate token-lean developer navigation codemaps for Swift/iOS/Mac Catalyst projects.

## When to Activate

- User says "update codemaps", "refresh codemaps", "generate codemaps"
- After significant structural changes (new modules, renamed files, architecture shifts)
- When onboarding to an unfamiliar area of the codebase

## Output Structure

Generate files in `codemaps/` at the project root. **Each file must stay under ~1000 tokens.**

| File | Covers |
|------|--------|
| `architecture.md` | Module map, directory roles, entry points, key relationships |
| `backend.md` | Services, managers, networking, GPU/compute, caching |
| `data.md` | Models, enums, protocols, persistence schemas |
| `frontend.md` | View hierarchy, state management, design tokens |

## Token Budget

**Hard limit: ~1000 tokens per codemap file.** Codemaps are loaded into AI context windows — every extra token competes with actual source code. Be ruthlessly concise.

## Workflow

### Step 1: Scan Project Structure

```bash
find . -name "*.swift" -not -path "*/.*" -not -path "*/DerivedData/*" \
  | sed 's|/[^/]*$||' | sort -u
```

### Step 2: Generate Codemaps

Use this format:

```markdown
# [Area Name]

<!-- Freshness: YYYY-MM-DD | Files scanned: N | ~Token estimate -->

## Overview
[1-2 sentences max]

## Module Map
Dir/
  SubDir/          — role annotation

## Key Types
| Type | Role | File |
|------|------|------|
| TileCache | LRU memory cache | Tiles/Cache/TileCache.swift |

## Data Flow
Views → @Observable Managers → Services → GPU/Network/Cache
```

### Step 3: Diff Check

If codemaps exist, compare with previous versions. If changes > ~30%, summarize and ask before overwriting.

### Step 4: Update Freshness

Every codemap must include a metadata comment:
```markdown
<!-- Freshness: 2026-02-18 | Files scanned: 42 | ~650 tokens -->
```

## Format Rules

**DO:**
- Arrow-chain notation for flows: `View → Manager.load() → Service.fetch() → Cache.get()`
- One-line role descriptions: `Services/TileLoader.swift (tile fetch + decode, 180 lines)`
- Tables for structured type references
- Minimal ASCII diagrams (3-5 lines max)
- Relative paths: `Services/TileLoader.swift`

**DON'T:**
- No Swift code blocks in codemaps — signatures go in tables or inline
- No full function bodies or implementation details
- No generics/constraints unless critical to understanding (e.g., phantom types)
- No prose paragraphs — bullets and tables only
- No line-by-line commentary

**Adapt to project size:**
- **Large (10K+ LOC):** All 4 files, full module maps, protocol chains
- **Small (<5K LOC):** Combine into fewer files, essential types only

## Swift-Specific Signals

When scanning, note these patterns for the relevant codemap:
- `@Observable` / `ObservableObject` → state managers, list published properties
- `actor` → concurrent shared state, note isolation
- `protocol` hierarchies → document conformance chains
- `@MainActor` → note isolation boundaries
- `UIViewRepresentable` → note what UIKit view it wraps

## Incremental Updates

For partial updates (e.g., "update the backend codemap"):
1. Read only the relevant codemap + source directories
2. Update changed sections, preserve unchanged
3. Update freshness timestamp and token estimate
