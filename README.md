# Marketing Agent Skills

AI agent skills for social media marketing automation.

## Skills

### agent-browser
Browser automation CLI that connects to Chrome via CDP (Chrome DevTools Protocol). Enables AI agents to automate web tasks using existing Chrome login sessions.

**Key feature**: Connect to running Chrome instance to inherit all logged-in sessions (X.com, Threads, etc.)

### social-post-publisher
Automated social media posting to X.com and Threads via browser automation.

## Usage

These skills follow the [Anthropic Agent Skills format](https://github.com/anthropics/skills). Each skill has a `SKILL.md` that describes the workflow.

### Quick Start: Post to Threads via agent-browser

```bash
# Connect to Chrome's CDP
WS_URL=$(curl -s http://127.0.0.1:9222/json/version | python3 -c "import json,sys; print(json.load(sys.stdin)['webSocketDebuggerUrl'])")
agent-browser --cdp "$WS_URL" open https://www.threads.com/@username

# Take snapshot and interact
agent-browser snapshot -i
agent-browser click @e4        # Create button
agent-browser fill @e13 'Your post content'
agent-browser click @e21       # Publish
```

## License

MIT
