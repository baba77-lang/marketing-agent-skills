# 平台規格參考

## X.com (Twitter)

### 字數限制
- 一般帳號：280 字元
- Premium：25,000 字元
- 中文字 = 1 字元

### 圖片規格
- 格式：JPG, PNG, GIF, WEBP
- 最大檔案：5MB (圖片)、15MB (GIF)
- 建議尺寸：1200x675 (16:9) 或 1080x1080 (1:1)
- 最多：4 張圖片

### 重要 DOM 選擇器
```javascript
// 發文輸入框
textbox "Post text"

// 上傳圖片
[data-testid='fileInput']

// 發文按鈕
[data-testid='tweetButton']

// 回覆按鈕
[data-testid='reply']
```

### 發文 URL
```
// 新貼文
https://x.com/compose/post

// 回覆（帶文字）
https://x.com/intent/post?in_reply_to=<tweet_id>&text=<encoded_text>

// 引用
https://x.com/intent/post?url=<tweet_url>
```

---

## Threads

### 字數限制
- 文字：500 字元
- 中文字 = 1 字元

### 圖片規格
- 格式：JPG, PNG
- 建議尺寸：1080x1080 (1:1) 或 1080x1350 (4:5)
- 最多：10 張圖片

### 重要 DOM 元素
```javascript
// 發文按鈕（在 profile 頁）
button "有什麼新鮮事？" 或 button "文字欄位空白..."

// 發文輸入框（對話框內）
textbox "文字欄位空白。請輸入內容以撰寫新貼文。"

// 附加圖片
button "附加影音內容"

// 上傳圖片
input[type='file']

// 發佈按鈕
button "發佈"

// 回覆按鈕
button "回覆"
```

### 特殊注意事項
1. **必須先點「附加影音內容」才能 upload**
2. DOM 結構經常變化，每次都要重新 snapshot
3. 對話框標題會顯示「新串文」或「回覆」

---

## 最佳發文時間

### 台灣時區 (GMT+8)

| 平台 | 最佳時段 | 次佳時段 |
|------|----------|----------|
| X.com | 12:00-14:00 | 20:00-22:00 |
| Threads | 19:00-21:00 | 07:00-09:00 |

### 星期分布

| 日期 | 建議 |
|------|------|
| 週一 | 勵志內容、週計畫 |
| 週二-四 | 知識內容、產品宣傳 |
| 週五 | 輕鬆內容、週末預告 |
| 週六日 | 生活分享、互動貼文 |

---

## 互動策略

### CTA 類型

| 類型 | 適用 | 範例 |
|------|------|------|
| 提問型 | 運勢、生活 | 「你是什麼生肖？」 |
| 選擇型 | 產品、偏好 | 「A 還是 B？」 |
| 分享型 | 經驗、故事 | 「說說你的經歷」 |
| 標記型 | 傳播、互動 | 「標記需要的朋友」 |

### 回覆時機
- 發文後 1 小時內發第一則自己的回覆（CTA）
- 增加貼文的互動數和可見度
- 引導用戶留言方向

---

## 帳號對照

| 平台 | 帳號格式 | 範例 |
|------|----------|------|
| X.com | @username | @baba77letitgo |
| Threads | @username | @baba7778899 |

### Profile URL
```
X.com: https://x.com/<username>
Threads: https://www.threads.com/@<username>
```

### 貼文 URL
```
X.com: https://x.com/<username>/status/<tweet_id>
Threads: https://www.threads.com/@<username>/post/<post_id>
```
