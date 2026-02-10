# Hook Installation

## swift-parse-check

Runs `swift -parse` after every Edit/Write on `.swift` files. Catches syntax errors immediately so Claude doesn't continue building on broken code.

### Setup

1. Copy the hook script into your project:

```bash
mkdir -p .claude/hooks
cp hooks/swift-parse-check.sh .claude/hooks/
chmod +x .claude/hooks/swift-parse-check.sh
```

2. Add to your project's `.claude/settings.json` (merge with existing settings):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/swift-parse-check.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### What it does

- After every Edit or Write of a `.swift` file, runs `swift -parse` (syntax check only, no compilation)
- If syntax is valid: exits silently, no impact on workflow
- If syntax error: exits with code 2, which feeds the error back to Claude as a blocking message. Claude sees the parse error and fixes it immediately.
- Non-Swift files are ignored
- Takes ~50-100ms per check

### Requirements

- `swift` CLI (comes with Xcode)
- `jq` for parsing hook input (`brew install jq` if not installed)
