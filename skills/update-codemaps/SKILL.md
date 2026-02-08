---
name: update-codemaps
description: Generate or refresh codemaps for Swift/iOS projects. Scans Swift source files to produce architecture.md, backend.md, data.md, and frontend.md in the codemaps/ directory.
---

# Update Codemaps

Generate or refresh developer navigation codemaps for Swift/iOS/Mac Catalyst projects.

## When to Activate

- User says "update codemaps", "refresh codemaps", "generate codemaps"
- After significant structural changes (new modules, renamed files, architecture shifts)
- When onboarding to an unfamiliar area of the codebase

## Output Structure

Generate 4 files in `codemaps/` at the project root:

| File | Covers |
|------|--------|
| `architecture.md` | High-level module map, directory structure, key relationships, entry points |
| `backend.md` | Services, managers, networking, GPU/compute pipelines, caching, data loading |
| `data.md` | Models, enums, type definitions, protocols, phantom types, persistence schemas |
| `frontend.md` | SwiftUI views, view hierarchy, state management, design tokens, accessibility |

## Workflow

### Step 1: Scan Project Structure

Map the directory layout. Identify key directories and their roles:

```bash
# Get directory tree (exclude build artifacts, caches)
find . -name "*.swift" -not -path "*/.*" -not -path "*/DerivedData/*" \
  | sed 's|/[^/]*$||' | sort -u
```

Count scale:
```bash
# Total Swift files and lines
find . -name "*.swift" -not -path "*/.*" | wc -l
find . -name "*.swift" -not -path "*/.*" -exec cat {} + | wc -l
```

### Step 2: Analyze Types and Relationships

For each major directory, read Swift files and extract:

- **Types**: structs, classes, enums, actors, protocols
- **Conformances**: what protocols each type conforms to
- **Key properties and methods**: public API surface
- **Dependencies**: what each module imports/references from other modules
- **Patterns**: @Observable, ObservableObject, actors, singletons

Focus on **signatures and relationships**, not implementation details.

### Step 3: Generate Codemaps

Use this format for each file:

```markdown
# [Area Name]

> Freshness: YYYY-MM-DD | [brief context about project state]

## Overview

[1-3 sentence description of what this area covers]

## Module Map

[Directory tree with brief annotations]

## Key Types

[Struct/class/protocol definitions — signatures only, not full bodies]

## Data Flow

[ASCII diagram showing how data moves through this area]

## Relationships

[Which modules depend on which, protocol hierarchies]
```

### Step 4: Diff Check

If codemaps already exist, compare with previous versions:

1. Read existing codemap files
2. Generate new content
3. Estimate change percentage
4. If changes exceed ~30%, summarize what changed and ask user to confirm before overwriting
5. If minor updates, apply directly

### Step 5: Update Freshness

Every codemap file must have a freshness timestamp:
```markdown
> Freshness: 2026-02-08 | post-refactor of tile loading system
```

## Format Conventions

**Adapt detail level to project complexity:**

- **Large projects (10K+ LOC)**: Detailed module maps, type hierarchies, protocol chains, GPU pipeline docs, phantom type documentation, data flow diagrams
- **Small projects (<5K LOC)**: Essential views, state management table, key enums/models, simple hierarchy

**File references**: Use relative paths — `Services/TileLoader.swift`, not absolute paths

**Type definitions**: Show actual Swift signatures with generics and constraints:
```swift
struct TypedTexture<W: TextureWidth, H: TextureHeight, R: TextureRole> {
    let mtlTexture: MTLTexture
}
```

**Architecture diagrams**: ASCII art in code blocks:
```
SwiftUI Views
    ↓
@Observable Managers (state)
    ↓
Services / Coordinators (logic)
    ↓
GPU Pipeline / Network / Cache
```

**Tables** for structured reference data:
```markdown
| Type | Purpose | File |
|------|---------|------|
| TileCache | LRU in-memory cache | Tiles/Cache/TileCache.swift |
```

**What to include**: Purpose, structure, signatures, relationships, data flow
**What to skip**: Implementation details, full function bodies, line-by-line commentary

## Swift-Specific Analysis

When scanning Swift files, pay attention to:

- **@Observable / ObservableObject** — these are state managers, document their published properties
- **actor** declarations — these manage concurrent shared state, document their isolation
- **protocol** hierarchies — document conformance chains
- **Phantom types** — document marker protocols and what safety they provide
- **@MainActor** annotations — note isolation boundaries
- **Metal shaders** (.metal files) — document kernel names, parameter structs, texture roles
- **UIViewRepresentable** — these bridge UIKit, document what they wrap
- **Extensions** — note which file adds which protocol conformance

## Incremental Updates

For partial updates (e.g., "update the backend codemap"):

1. Read only the relevant codemap file
2. Scan only the relevant source directories
3. Update changed sections, preserve unchanged sections
4. Update the freshness timestamp
