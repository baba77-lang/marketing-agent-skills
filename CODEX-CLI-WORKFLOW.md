# Codex CLI Workflow

## 決策
所有 coding 任務改用 **Codex CLI** 作為預設與標準流程。

## 標準指令
```bash
codex exec -C /path/to/project --full-auto "任務描述"
```

## 較安全模式
```bash
codex exec \
  -C /path/to/project \
  -s workspace-write \
  -a on-request \
  "任務描述"
```

## Hook 替代方案
Codex CLI 目前沒有像 Claude Code 那種獨立 hooks 設定檔流程。
可採用 wrapper + callback：

```bash
~/workspace/claw/agents/dev-agent/dispatch-codex-cli.sh \
  -p "任務描述" \
  -n "task-name" \
  -w /path/to/project \
  --notify-cmd 'openclaw system event --text "Done: task-name" --mode now'
```

## 結果檔
- `codex-cli-results/latest.json`
- `codex-cli-results/<task>.log`
- `codex-cli-results/<task>-last-message.txt`

## 原則
1. 先寫清楚 prompt
2. 用 Codex 執行
3. 跑 build/test 驗證
4. 檢查 diff
5. 再 commit / push
