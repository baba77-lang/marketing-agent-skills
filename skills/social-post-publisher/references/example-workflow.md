# 完整範例：每日運勢社群發文

## 步驟 1：抓取內容

```javascript
// 抓取運勢內容
web_fetch({
  url: "https://divination.anything-ai.xyz/blog/2026-03-02-daily-fortune-zh-TW",
  extractMode: "markdown"
})
```

## 步驟 2：生成圖片

```bash
# 使用 Gemini (nano-banana-pro)
GEMINI_API_KEY="<key>" uv run ~/.nvm/.../nano-banana-pro/scripts/generate_image.py \
  --prompt "Mystical Chinese divination oracle card. Mountain transforming into phoenix flames, symbolizing rebirth. Dark indigo to golden gradient. I-Ching hexagram patterns. Chinese calligraphy 先破後立." \
  --filename "2026-03-02-daily-fortune.png" \
  --resolution 1K

# 複製到 uploads
cp 2026-03-02-daily-fortune.png /tmp/openclaw/uploads/
```

## 步驟 3：發布到 X.com

### 3.1 打開發文視窗
```javascript
browser({
  action: "open",
  profile: "chrome",
  targetUrl: "https://x.com/compose/post"
})
// 等待載入
exec({ command: "sleep 2" })
```

### 3.2 輸入文案
```javascript
browser({
  action: "snapshot",
  profile: "chrome",
  targetId: "<id>",
  compact: true
})
// 找到 textbox "Post text" 的 ref

browser({
  action: "act",
  profile: "chrome",
  targetId: "<id>",
  request: {
    kind: "type",
    ref: "<textbox_ref>",
    text: "🔮 3/2 每日運勢｜山地剝 → 火地晉\n\n今天的宇宙訊息：\n「先破後立，浴火重生」🔥\n\n有些事正在瓦解？別慌。\n這是在幫你清理跑道。\n\n✨ 蛇、馬：大吉！衝就對了\n🪙 猴、雞：貴人相助\n🏔️ 牛龍羊狗：順風順水\n⚠️ 虎、兔：低調為上\n\n#每日運勢 #梅花易數 #先破後立"
  }
})
```

### 3.3 上傳圖片
```javascript
browser({
  action: "upload",
  profile: "chrome",
  targetId: "<id>",
  selector: "[data-testid='fileInput']",
  paths: ["/tmp/openclaw/uploads/2026-03-02-daily-fortune.png"]
})
// 等待圖片載入
exec({ command: "sleep 2" })
```

### 3.4 發文
```javascript
browser({
  action: "act",
  profile: "chrome",
  targetId: "<id>",
  request: {
    kind: "evaluate",
    fn: "document.querySelector('[data-testid=\"tweetButton\"]').click()"
  }
})
```

### 3.5 獲取貼文 ID
```javascript
// 打開 profile 頁面
browser({
  action: "open",
  profile: "chrome",
  targetUrl: "https://x.com/<username>"
})
// snapshot 找到最新貼文的 link，URL 格式：
// /status/<tweet_id>
```

## 步驟 4：發布 X CTA 回覆

```javascript
// 使用 intent URL 自動帶入回覆文案
const ctaText = "👇 你是什麼生肖？\n\n今天有什麼正在「剝落」的事物嗎？\n留言說說，一起見證你的重生時刻 🚀"
const encodedCta = encodeURIComponent(ctaText)

browser({
  action: "open",
  profile: "chrome",
  targetUrl: `https://x.com/intent/post?in_reply_to=<tweet_id>&text=${encodedCta}`
})

// 等待載入後 snapshot
browser({ action: "snapshot", ... })

// 點擊 Reply 按鈕
browser({
  action: "act",
  request: { kind: "click", ref: "<reply_button_ref>" }
})
```

## 步驟 5：發布到 Threads

### 5.1 打開 Threads profile
```javascript
browser({
  action: "open",
  profile: "chrome",
  targetUrl: "https://www.threads.com/@<username>"
})
```

### 5.2 打開發文對話框
```javascript
browser({ action: "snapshot", ... })
// 找到 "有什麼新鮮事？" 按鈕
browser({
  action: "act",
  request: { kind: "click", ref: "<compose_button_ref>" }
})
```

### 5.3 輸入文案
```javascript
browser({ action: "snapshot", ... })
// 找到 textbox
browser({
  action: "act",
  request: {
    kind: "type",
    ref: "<textbox_ref>",
    text: "🔮 2026.3.2 梅花易數｜每日運勢\n\n卦象：山地剝 → 火地晉\n\n山正在崩解\n但那是為了讓鳳凰升起 🔥\n\n—\n\n【生肖速查】\n\n🔥 蛇、馬 → 大吉！加倍回報\n🪙 猴、雞 → 吉，有貴人\n🏔️ 牛龍羊狗 → 吉，順利\n💧 鼠、豬 → 小心，多專注\n🌳 虎、兔 → 注意，低調\n\n—\n\n今天的關鍵字：先破後立\n\n正在瓦解的，是為了讓更好的升起。\n\n#每日運勢 #梅花易數 #先破後立"
  }
})
```

### 5.4 上傳圖片（關鍵步驟）
```javascript
// 先點擊「附加影音內容」按鈕
browser({ action: "snapshot", ... })
browser({
  action: "act",
  request: { kind: "click", ref: "<attach_media_ref>" }
})

// 然後 upload
browser({
  action: "upload",
  selector: "input[type='file']",
  paths: ["/tmp/openclaw/uploads/2026-03-02-daily-fortune.png"]
})

// 等待圖片載入
exec({ command: "sleep 3" })
```

### 5.5 發文
```javascript
browser({ action: "snapshot", ... })
// 找到「發佈」按鈕
browser({
  action: "act",
  request: { kind: "click", ref: "<post_button_ref>" }
})
```

## 步驟 6：發布 Threads CTA 回覆

```javascript
// 回到 profile 頁面
browser({ action: "snapshot", ... })

// 找到剛發的貼文的「回覆」按鈕
browser({
  action: "act",
  request: { kind: "click", ref: "<reply_button_ref>" }
})

// 輸入 CTA
browser({ action: "snapshot", ... })
browser({
  action: "act",
  request: {
    kind: "type",
    ref: "<textbox_ref>",
    text: "💬 你是什麼生肖？\n今天有什麼感覺正在「剝落」嗎？\n\n留言分享，我們一起見證改變 ✨"
  }
})

// 發佈
browser({
  action: "act",
  request: { kind: "click", ref: "<post_button_ref>" }
})
```

## 步驟 7：記錄結果

```javascript
Write({
  path: "memory/YYYY-MM-DD-campaign.md",
  content: `# ${date} 社群行銷活動

## 發佈紀錄
- X: https://x.com/<user>/status/<id>
- Threads: https://www.threads.com/@<user>/post/<id>

## 素材
- 圖片：${imagePath}
- 主題：${topic}

## 備註
- ${notes}
`
})
```

## 常見問題排解

### Q: 圖片上傳後沒顯示？
A: 再次執行 upload，並等待 3 秒讓圖片載入。

### Q: Tab not found 錯誤？
A: 執行 `browser tabs` 獲取所有 tab 列表，然後用 `browser focus` 切換到正確的 tab。

### Q: Threads 發文按鈕找不到？
A: 重新執行 snapshot，Threads 的 DOM 結構會動態變化，需要使用最新的 ref。

### Q: X.com 發文按鈕點不了？
A: 用 evaluate 方式點擊：
```javascript
evaluate: document.querySelector('[data-testid="tweetButton"]').click()
```
