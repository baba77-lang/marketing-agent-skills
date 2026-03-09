---
name: agent-browser
description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task.
allowed-tools: Bash(npx agent-browser:*), Bash(agent-browser:*)
---

# Browser Automation with agent-browser

## Core Workflow

Every browser automation follows this pattern:

1. **Navigate**: `agent-browser open <url>`
2. **Snapshot**: `agent-browser snapshot -i` (get element refs like `@e1`, `@e2`)
3. **Interact**: Use refs to click, fill, select
4. **Re-snapshot**: After navigation or DOM changes, get fresh refs

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # Check result
```

## Connecting to Chrome (CDP) — 已登入帳號操作

agent-browser 可以透過 CDP（Chrome DevTools Protocol）連接到已運行的 Chrome 實例，**繼承所有登入 session**。這是操作需要登入的網站（X.com、Threads 等）的最佳方式。

### 發現 Chrome CDP Port

```bash
# 找到 Chrome 的 remote-debugging-port
ps aux | grep "[c]hrome" | grep "remote-debugging" | grep -oP 'remote-debugging-port=\K\d+'

# 驗證 CDP 可用
curl -s http://127.0.0.1:9222/json/version

# 列出所有已開啟的 tabs
curl -s http://127.0.0.1:9222/json/list | python3 -c "
import json,sys
tabs=json.load(sys.stdin)
for t in tabs[:10]:
    print(f'{t[\"id\"][:20]}  {t[\"url\"][:80]}')
"
```

### 連接方式

```bash
# 方法 1：透過 browser-level WebSocket（推薦）
# 先取得 browser WebSocket URL
WS_URL=$(curl -s http://127.0.0.1:9222/json/version | python3 -c "import json,sys; print(json.load(sys.stdin)['webSocketDebuggerUrl'])")

# 用 browser-level WS 開啟頁面（會在 Chrome 中開新 tab）
agent-browser --cdp "$WS_URL" open https://www.threads.com/@username

# 後續指令不需要再帶 --cdp（daemon 會保持連線）
agent-browser snapshot -i
agent-browser fill @e5 "Hello World"
agent-browser click @e10

# 方法 2：直接用 port（可能不穩定）
agent-browser --cdp 9222 snapshot -i
```

### 與 OpenClaw Browser Relay 的差異

| 特性 | agent-browser --cdp | OpenClaw browser tool |
|------|--------------------|-----------------------|
| 連接方式 | 直接 CDP WebSocket | 透過 OpenClaw Relay proxy |
| 登入 session | ✅ 繼承 Chrome 所有 cookies | ✅ 透過 Chrome Extension |
| 操作方式 | CLI 指令 (`click @e1`) | JSON tool call (`ref: "e1"`) |
| 適合場景 | 腳本化、自動化、批次操作 | 對話式、單步操作 |
| 多 tab 支援 | 可透過 `open` 切換 | 需 `targetId` 管理 |
| 穩定性 | 直連較穩定 | 依賴 Extension 連線 |

### 實戰範例：在 Threads 發文

```bash
# 1. 連接到 Chrome-AI
WS_URL=$(curl -s http://127.0.0.1:9222/json/version | python3 -c "import json,sys; print(json.load(sys.stdin)['webSocketDebuggerUrl'])")
agent-browser --cdp "$WS_URL" open https://www.threads.com/@baba7778899

# 2. 查看頁面元素
agent-browser snapshot -i

# 3. 點擊「建立」按鈕
agent-browser click @e4
agent-browser wait 2000

# 4. 填入文案
agent-browser snapshot -i  # 取得新 ref
agent-browser fill @e13 '你的貼文內容...'

# 5. 發佈
agent-browser click @e21  # 點「發佈」按鈕
agent-browser wait 3000
```

### 實戰範例：在 X.com 發文

```bash
# 1. 開啟 X compose（已登入）
agent-browser open https://x.com/compose/post
agent-browser wait 3000
agent-browser snapshot -i

# 2. 填入文案
agent-browser fill @e5 '你的推文...'

# 3. 上傳圖片（X.com 用 data-testid selector）
agent-browser upload "[data-testid='fileInput'] >> nth=0" /path/to/image.png
agent-browser wait 3000

# 4. 發佈（X.com 按鈕需用 eval 點擊）
agent-browser eval "document.querySelector('[data-testid=\"tweetButton\"]').click()"
agent-browser wait 3000
```

## Command Chaining

Commands can be chained with `&&` in a single shell invocation.

```bash
agent-browser open https://example.com && agent-browser wait --load networkidle && agent-browser snapshot -i
```

## Essential Commands

```bash
# Navigation
agent-browser open <url>              # Navigate
agent-browser close                   # Close browser

# Snapshot
agent-browser snapshot -i             # Interactive elements with refs
agent-browser snapshot -i -C          # Include cursor-interactive elements

# Interaction (use @refs from snapshot)
agent-browser click @e1               # Click element
agent-browser fill @e2 "text"         # Clear and type text
agent-browser select @e1 "option"     # Select dropdown option
agent-browser press Enter             # Press key
agent-browser keyboard type "text"    # Type with real keystrokes
agent-browser scroll down 500         # Scroll page

# Get information
agent-browser get text @e1            # Get element text
agent-browser get url                 # Get current URL
agent-browser get title               # Get page title

# Wait
agent-browser wait @e1                # Wait for element
agent-browser wait --load networkidle # Wait for network idle
agent-browser wait 2000               # Wait milliseconds

# Capture
agent-browser screenshot              # Screenshot to temp dir
agent-browser screenshot --full       # Full page screenshot
agent-browser pdf output.pdf          # Save as PDF

# Upload
agent-browser upload @e1 /path/to/file.png     # Upload via ref
agent-browser upload "selector" /path/file.png  # Upload via CSS selector

# JavaScript
agent-browser eval "document.title"   # Run JS and return result
```

## Session Persistence

```bash
# Named sessions persist browser state across commands
agent-browser --session-name myapp open https://example.com
agent-browser --session-name myapp snapshot -i
agent-browser --session-name myapp click @e1

# Session with profile (persistent cookies/storage)
agent-browser --profile /path/to/profile open https://example.com
```

## Data Extraction

```bash
agent-browser open https://example.com/news
agent-browser snapshot -i
agent-browser get text @e5           # Get specific element text
agent-browser get text body > page.txt  # Get all page text

# JSON output for parsing
agent-browser snapshot -i --json
```

## Visual Browser (Debugging)

```bash
agent-browser --headed open https://example.com
agent-browser highlight @e1          # Highlight element
```

## Troubleshooting

### "No page found" error
CDP 連線後但頁面還沒載入完成。加 wait：
```bash
agent-browser --cdp "$WS_URL" open https://example.com && agent-browser wait 3000 && agent-browser snapshot -i
```

### Selector matched multiple elements
用 `>> nth=0` 指定第幾個：
```bash
agent-browser upload "[data-testid='fileInput'] >> nth=0" /path/to/file.png
```

### CDP "Unauthorized" on OpenClaw relay port
OpenClaw relay (port 18792) 有認證，不能直接用 agent-browser 連。用 Chrome 自身的 CDP port (如 9222)。

### Image upload on social platforms
X.com 用 `[data-testid='fileInput']`，Threads 先點「附加影音內容」再 upload `input[type='file']`。
如果 upload 不穩定，可用剪貼板方式：
```bash
osascript -e 'set the clipboard to (read (POSIX file "/tmp/image.png") as JPEG picture)'
agent-browser click @textbox_ref
agent-browser press Meta+v
agent-browser wait 3000
```
