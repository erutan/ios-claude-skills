#!/bin/bash
# PostToolUse hook: runs `swift -parse` on .swift files after Edit/Write
# Catches syntax errors immediately so Claude doesn't move on with broken code.
#
# Install: copy to .claude/hooks/ in your project, chmod +x, and add to settings.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check Swift files
if [[ "$FILE_PATH" != *.swift ]]; then
  exit 0
fi

# Only check files that exist (Write might have failed)
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Run syntax check
PARSE_OUTPUT=$(swift -parse "$FILE_PATH" 2>&1)
PARSE_EXIT=$?

if [[ $PARSE_EXIT -ne 0 ]]; then
  # Exit code 2 = blocking error, stderr is fed to Claude as the reason
  echo "Swift syntax error in $FILE_PATH:" >&2
  echo "$PARSE_OUTPUT" >&2
  exit 2
fi

exit 0
