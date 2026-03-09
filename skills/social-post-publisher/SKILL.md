---
name: social-post-publisher
description: 透過 Chrome 瀏覽器自動發布社群貼文到 X.com 和 Threads。使用時機：(1) 需要同時發布到多個社群平台 (2) 發布含圖片的貼文 (3) 需要 CTA 回覆互動 (4) 每日運勢、行銷內容、品牌宣傳等社群行銷任務。需要 browser profile="chrome" 連接。
---

# Social Post Publisher

透過 Chrome 瀏覽器發布社群貼文到 X.com 和 Threads。

## 前置需求

- Browser Relay 已連接 (`browser profile="chrome"`)
- 已登入 X.com 和 Threads 帳號
- 圖片檔案在 `/tmp/openclaw/uploads/` 目錄

## 快速流程

### 1. 準備素材
```
1. 抓取/生成內容（如：web_fetch 運勢頁面）
2. 生成圖片（nano-banana-pro 或 openai-image-gen）
3. 複製圖片到 uploads：cp <image> /tmp/openclaw/uploads/
4. 準備文案（主貼文 + CTA 回覆）
```

### 2. 發布到 X.com
```
1. browser open → https://x.com/compose/post
2. snapshot → 找到 textbox "Post text"
3. type 文案
4. upload 圖片：selector="[data-testid='fileInput']"
5. 等待圖片載入 (sleep 2)
6. evaluate: document.querySelector('[data-testid="tweetButton"]').click()
7. 記錄貼文 ID（從 profile 頁面抓取）
```

### 3. 發布 X CTA 回覆
```
browser open → https://x.com/intent/post?in_reply_to=<tweet_id>&text=<encoded_cta>
snapshot → click "Reply" 按鈕
```

### 4. 發布到 Threads
```
1. browser open → https://www.threads.com/@<username>
2. snapshot → click "有什麼新鮮事？" 按鈕
3. type 文案到 textbox
4. click "附加影音內容" 按鈕
5. upload 圖片：selector="input[type='file']"
6. 等待圖片載入 (sleep 3)
7. snapshot → click "發佈" 按鈕
```

### 5. 發布 Threads CTA 回覆
```
1. snapshot → 找到貼文的 "回覆" 按鈕並點擊
2. type CTA 文案
3. click "發佈" 按鈕
```

## 關鍵技巧

### 圖片上傳
```javascript
// X.com - 必須用 data-testid
selector: "[data-testid='fileInput']"

// Threads - 先點附加影音，再 upload
click "附加影音內容" → upload selector="input[type='file']"
```

### 發文按鈕
```javascript
// X.com - 用 evaluate 點擊
evaluate: document.querySelector('[data-testid="tweetButton"]').click()

// Threads - 用 snapshot 找 ref 再 click
snapshot → click ref="發佈"
```

### Tab 不穩定處理
```
如果 tab not found：
1. browser tabs 列出所有 tabs
2. browser focus targetId=<id>
3. 或 browser open 重新開啟頁面
```

## 文案模板

### X.com（簡潔版）
```
🔮 [日期] [主題]

[核心訊息 1-2 句]

[生肖/星座速查 - 條列式]

#標籤1 #標籤2 #標籤3
```

### Threads（故事版）
```
🔮 [日期] [主題]

[背景說明]

—

【詳細內容】
[條列式資訊]

—

[結語/關鍵字]

#標籤1 #標籤2 #標籤3
```

### CTA 回覆
```
💬 [提問 - 問生肖/經歷]
[引導留言的句子]
[正向結語] ✨
```

## 發文時間建議

| 時段 | 適合內容 |
|------|----------|
| 07-09 | 早安問候、每日運勢 |
| 12-14 | 午間輕鬆內容 |
| 19-21 | 晚間互動、回顧 |
| 週末 | 長文、深度內容 |

## 錯誤處理

| 問題 | 解法 |
|------|------|
| tab not found | `browser tabs` → `browser focus` |
| 圖片沒顯示 | 重新 upload，等待 3 秒 |
| 按鈕找不到 | 重新 snapshot，用新的 ref |
| 發文失敗 | 檢查是否超過字數限制 |

## 完整範例

見 [references/example-workflow.md](references/example-workflow.md)
