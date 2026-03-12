---
name: codex-cli-headless
description: Use Codex CLI as the default coding agent for headless development, refactors, bug fixes, code review, build/test verification, and repeatable coding workflows. Use when: (1) building or modifying application code, (2) fixing TypeScript/build/test issues, (3) running autonomous coding tasks in a repo, (4) replacing older Claude Code headless workflows with Codex CLI, or (5) setting up a callback-based Codex dispatch flow.
---

# Codex CLI Headless + Callback Workflow

Use Codex CLI as the default coding path.

## Standard commands

### Safe default
```bash
codex exec \
  -C /path/to/project \
  -s workspace-write \
  -a on-request \
  "任務描述"
```

### Faster sandboxed flow
```bash
codex exec -C /path/to/project --full-auto "任務描述"
```

### High-permission flow
Only use when the environment is already externally sandboxed and the task genuinely needs it.

```bash
codex exec \
  -C /path/to/project \
  --dangerously-bypass-approvals-and-sandbox \
  "任務描述"
```

## Preferred workflow

1. Write a precise task prompt.
2. Run Codex with `codex exec` in the target repo.
3. Verify with build/test commands.
4. Review diff.
5. Commit only after validation passes.

## Callback / hook-like completion

Codex CLI does not currently expose the same built-in hook config pattern used by Claude Code.
Use the wrapper script instead:

```bash
~/workspace/claw/agents/dev-agent/dispatch-codex-cli.sh \
  -p "任務描述" \
  -n "task-name" \
  -w /path/to/project \
  --notify-cmd 'openclaw system event --text "Done: task-name" --mode now'
```

This provides a hook-like completion flow by:
- running Codex in headless mode
- saving the final message and logs
- writing `codex-cli-results/latest.json`
- invoking a callback command after completion

## Output locations

```bash
~/workspace/claw/agents/dev-agent/codex-cli-results/latest.json
~/workspace/claw/agents/dev-agent/codex-cli-results/<task-name>.log
~/workspace/claw/agents/dev-agent/codex-cli-results/<task-name>-last-message.txt
```

## Recommended patterns

### Feature development
```bash
codex exec -C ~/workspace/claw/my-app --full-auto "
實作功能：
1. ...
2. ...
3. 跑 build 與測試
4. 回報修改摘要
"
```

### Bug fix
```bash
codex exec -C ~/workspace/claw/my-app -s workspace-write -a on-request "
修復 bug：
- 重現問題
- 找出 root cause
- 修復
- 跑測試
"
```

### Review
```bash
codex review origin/main...HEAD
```

## Rules

- Prefer `codex exec` over direct manual patching for non-trivial coding work.
- Prefer `workspace-write` unless stronger permissions are truly needed.
- Always validate with build/tests after changes.
- Use the callback wrapper when you want zero-polling completion signaling.
- Treat older Claude Code headless docs as legacy workflow, not default workflow.
