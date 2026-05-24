#!/bin/bash

set +e

REPO="$(pwd)"

echo "🧪 Running tests..."

OUTPUT=$(PYTHONPATH=. pytest 2>&1)
EXIT_CODE=$?

echo "$OUTPUT"

mkdir -p .openclaw

# ALWAYS write error file (even if empty context)
if [ $EXIT_CODE -ne 0 ]; then
  echo "❌ Tests failed — saving error log"
  echo "$OUTPUT" > .openclaw/last_test_error.txt
else
  echo "✅ Tests passed"
  echo "" > .openclaw/last_test_error.txt
fi

exit $EXIT_CODE
