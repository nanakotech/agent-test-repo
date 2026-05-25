#!/bin/bash

set +e

ERROR_FILE=".openclaw/last_test_error.txt"

if [ ! -f "$ERROR_FILE" ]; then
  echo "⚠️ No error file found"
  exit 1
fi

ERROR=$(cat "$ERROR_FILE")

echo "🤖 Requesting repaired file from model..."

FIXED_CODE=$(ollama run qwen2.5:14b <<EOF
You are a senior Python engineer.

Fix the failing test.

CRITICAL RULES:
- Return ONLY valid Python code
- Do NOT use markdown
- Do NOT explain anything
- Do NOT output backticks
- Keep changes minimal
- Preserve existing functionality

TEST FAILURE:
$ERROR

CURRENT main.py:
$(cat main.py)

Return the FULL corrected main.py file only.
EOF
)

echo "📦 Proposed repaired file:"
echo "----------------------"
echo "$FIXED_CODE"
echo "----------------------"

cp main.py main.py.bak

CLEAN_CODE=$(echo "$FIXED_CODE" \
  | sed '/^```python/d' \
  | sed '/^```/d')

echo "$CLEAN_CODE" > main.py

python3 -m py_compile main.py

if [ $? -ne 0 ]; then
  echo "❌ Syntax invalid — reverting"
  mv main.py.bak main.py
  exit 1
fi

echo "✅ Repaired file written successfully"
