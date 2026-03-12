#!/bin/bash
# Codex CLI 任務派發腳本 - completion callback 版
# 用法:
#   dispatch-codex-cli.sh -p "任務描述" -n "任務名稱" -w "/path/to/project"
#
# 說明:
# - 使用 codex exec 非互動模式
# - 執行完成後寫入 latest.json
# - 可選：執行 notify command 作為 hook 替代

set -euo pipefail

PROMPT=""
TASK_NAME="task-$(date +%s)"
WORKDIR="$(pwd)"
MODEL=""
SANDBOX_MODE="workspace-write"
APPROVAL_MODE="on-request"
DANGEROUS="false"
SEARCH="false"
NOTIFY_CMD=""
RESULTS_DIR="$HOME/workspace/claw/agents/dev-agent/codex-cli-results"
LAST_MESSAGE_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--prompt) PROMPT="$2"; shift 2 ;;
    -n|--name) TASK_NAME="$2"; shift 2 ;;
    -w|--workdir) WORKDIR="$2"; shift 2 ;;
    -m|--model) MODEL="$2"; shift 2 ;;
    -s|--sandbox) SANDBOX_MODE="$2"; shift 2 ;;
    -a|--approval) APPROVAL_MODE="$2"; shift 2 ;;
    --dangerous) DANGEROUS="true"; shift ;;
    --search) SEARCH="true"; shift ;;
    --notify-cmd) NOTIFY_CMD="$2"; shift 2 ;;
    --results-dir) RESULTS_DIR="$2"; shift 2 ;;
    *) echo "未知參數: $1"; exit 1 ;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "錯誤: 必須提供 -p/--prompt 參數"
  exit 1
fi

mkdir -p "$WORKDIR" "$RESULTS_DIR"
LAST_MESSAGE_FILE="$RESULTS_DIR/${TASK_NAME}-last-message.txt"
META_FILE="$RESULTS_DIR/${TASK_NAME}-meta.json"
LOG_FILE="$RESULTS_DIR/${TASK_NAME}.log"
LATEST_FILE="$RESULTS_DIR/latest.json"

python3 - <<PY > "$META_FILE"
import json, os, datetime
print(json.dumps({
  "task_name": os.environ["TASK_NAME"],
  "prompt": os.environ["PROMPT"],
  "workdir": os.environ["WORKDIR"],
  "model": os.environ.get("MODEL") or None,
  "sandbox": os.environ["SANDBOX_MODE"],
  "approval": os.environ["APPROVAL_MODE"],
  "dangerous": os.environ["DANGEROUS"] == "true",
  "search": os.environ["SEARCH"] == "true",
  "started_at": datetime.datetime.utcnow().isoformat() + "Z"
}, ensure_ascii=False, indent=2))
PY

export TASK_NAME PROMPT WORKDIR MODEL SANDBOX_MODE APPROVAL_MODE DANGEROUS SEARCH

echo "📋 任務: $TASK_NAME"
echo "📁 目錄: $WORKDIR"
echo "🚀 啟動 Codex CLI..."

CMD=(codex exec -C "$WORKDIR")

if [[ -n "$MODEL" ]]; then
  CMD+=(-m "$MODEL")
fi

if [[ "$DANGEROUS" == "true" ]]; then
  CMD+=(--dangerously-bypass-approvals-and-sandbox)
else
  CMD+=(-s "$SANDBOX_MODE" -a "$APPROVAL_MODE")
fi

if [[ "$SEARCH" == "true" ]]; then
  CMD+=(--search)
fi

CMD+=(--output-last-message "$LAST_MESSAGE_FILE" "$PROMPT")

(
  set +e
  cd "$WORKDIR"
  "${CMD[@]}" > "$LOG_FILE" 2>&1
  EXIT_CODE=$?

  python3 - <<PY > "$LATEST_FILE"
import json, os, pathlib, datetime
last_message_path = pathlib.Path(os.environ["LAST_MESSAGE_FILE"])
log_path = pathlib.Path(os.environ["LOG_FILE"])
meta_path = pathlib.Path(os.environ["META_FILE"])

def read_text(path):
    try:
        return path.read_text(encoding="utf-8")
    except Exception:
        return ""

print(json.dumps({
  "task_name": os.environ["TASK_NAME"],
  "workdir": os.environ["WORKDIR"],
  "finished_at": datetime.datetime.utcnow().isoformat() + "Z",
  "status": "done" if int(os.environ["EXIT_CODE"]) == 0 else "failed",
  "exit_code": int(os.environ["EXIT_CODE"]),
  "meta": json.loads(read_text(meta_path) or "{}"),
  "last_message": read_text(last_message_path),
  "log_path": str(log_path),
  "last_message_path": str(last_message_path)
}, ensure_ascii=False, indent=2))
PY

  if [[ -n "$NOTIFY_CMD" ]]; then
    bash -lc "$NOTIFY_CMD" || true
  fi

  exit "$EXIT_CODE"
) &
PID=$!

echo "✅ Codex CLI 已在背景啟動 (PID: $PID)"
echo "📄 Log: $LOG_FILE"
echo "📝 Last message: $LAST_MESSAGE_FILE"
echo "📦 Latest result: $LATEST_FILE"
echo ""
echo "Hook 替代方案：Codex 執行完成後，可用 --notify-cmd 觸發 callback"
echo "例如："
echo "  --notify-cmd 'openclaw system event --text \"Done: $TASK_NAME\" --mode now'"
