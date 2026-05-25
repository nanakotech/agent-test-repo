#!/bin/bash

set +e

MAX_ATTEMPTS=10
ATTEMPT=0

while true; do

  ATTEMPT=$((ATTEMPT+1))

  if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
    echo "❌ Max attempts reached — stopping loop"
    exit 1
  fi

  echo "🧪 Running tests..."

  bash .openclaw/agent/test_runner.sh
  RESULT=$?

  if [ $RESULT -eq 0 ]; then
    echo "🎉 Tests passed — stopping"

    # optional safety commit
    if [ -d ".git" ]; then
      git add .
      git commit -m "autonomous repair: tests passing" >/dev/null 2>&1 || true
    fi

    break
  fi

  # SAFETY CHECK: ensure error file exists
  if [ ! -f ".openclaw/last_test_error.txt" ]; then
    echo "⚠️ No error file found — skipping repair step"
    echo "🔁 retrying..."
    continue
  fi

  echo "🤖 Running self-heal..."

  bash .openclaw/agent/self_heal.sh
  bash .openclaw/agent/apply_patch.sh

  echo "🔁 Re-testing..."

done
