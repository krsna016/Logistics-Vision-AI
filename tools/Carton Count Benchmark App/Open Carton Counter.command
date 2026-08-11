#!/bin/zsh
set -u

APP_DIR="${0:A:h}"
PYTHON_BIN="/opt/homebrew/bin/python3.12"
APP_URL="http://127.0.0.1:8011"
LOG_FILE="$APP_DIR/carton-counter.log"

cd "$APP_DIR" || exit 1

if curl -fsS "$APP_URL/api/health" >/dev/null 2>&1; then
  open "$APP_URL"
  exit 0
fi

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "Python 3.12 was not found."
  echo "Expected location: $PYTHON_BIN"
  echo "Install it using: brew install python@3.12"
  read "?Press Enter to close."
  exit 1
fi

if [[ ! -x "$APP_DIR/.venv/bin/python" ]]; then
  echo "Preparing the app for its first launch…"
  "$PYTHON_BIN" -m venv "$APP_DIR/.venv" || exit 1
  "$APP_DIR/.venv/bin/python" -m pip install -r "$APP_DIR/requirements.txt" || {
    echo "Dependency installation failed."
    read "?Press Enter to close."
    exit 1
  }
fi

export YOLO_CONFIG_DIR="$APP_DIR/.runtime/yolo"
export MPLCONFIGDIR="$APP_DIR/.runtime/matplotlib"
export XDG_CACHE_HOME="$APP_DIR/.runtime/cache"
mkdir -p "$YOLO_CONFIG_DIR" "$MPLCONFIGDIR" "$XDG_CACHE_HOME"

echo "Starting Carton Inspection Lab…"
"$APP_DIR/.venv/bin/python" -m uvicorn app:app --host 127.0.0.1 --port 8011 >"$LOG_FILE" 2>&1 &
SERVER_PID=$!

for attempt in {1..90}; do
  if curl -fsS "$APP_URL/api/health" >/dev/null 2>&1; then
    echo "Ready. Opening $APP_URL"
    open "$APP_URL"
    echo ""
    echo "Keep this window open while using the app."
    echo "Press Control+C here when you want to stop it."
    wait "$SERVER_PID"
    exit $?
  fi
  if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    echo "The app could not start. Details:"
    tail -30 "$LOG_FILE"
    read "?Press Enter to close."
    exit 1
  fi
  sleep 0.5
done

echo "The app took too long to start. Details:"
tail -30 "$LOG_FILE"
kill "$SERVER_PID" >/dev/null 2>&1
read "?Press Enter to close."
exit 1
