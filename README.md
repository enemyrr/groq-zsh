# groq-zsh

Zsh plugins for AI-powered command generation using Groq API. Type `# your question` and get instant command suggestions.

## Features

- **Simple plugin**: Basic command generation
- **Advanced plugin**: Command generation with conversation history support

## Prerequisites

- `zsh` shell
- `curl` (usually pre-installed)
- `jq` (JSON processor)

### Installing jq

**macOS:**
```bash
brew install jq
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt-get install jq
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install jq
```

## Installation

### Option 1: Using Oh My Zsh

1. Clone the repository:
```bash
git clone https://github.com/enemyrr/groq-zsh.git ~/.oh-my-zsh/custom/plugins/groq-zsh
```

2. Add the plugin to your `~/.zshrc`:
```bash
plugins=(... groq-zsh)
```

3. Source your `.zshrc`:
```bash
source ~/.zshrc
```

### Option 2: Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/enemyrr/groq-zsh.git ~/groq-zsh
```

2. Add to your `~/.zshrc`:

**For the simple plugin:**
```bash
source ~/groq-zsh/groq-ai-simple.plugin.zsh
```

**For the advanced plugin (with history):**
```bash
source ~/groq-zsh/groq-ai.plugin.zsh
```

3. Source your `.zshrc`:
```bash
source ~/.zshrc
```

### Option 3: Using Antigen

Add to your `~/.zshrc`:
```bash
antigen bundle enemyrr/groq-zsh
```

### Option 4: Using Zinit

Add to your `~/.zshrc`:
```bash
zinit load enemyrr/groq-zsh
```

## Environment Variables

### Required

- **`GROQ_API_KEY`**: Your Groq API key
  - Get one at [console.groq.com](https://console.groq.com)
  - Add to `~/.zshrc`:
    ```bash
    export GROQ_API_KEY="your-api-key-here"
    ```

### Optional

- **`GROQ_MODEL`**: The Groq model to use (default: `llama-3.3-70b-versatile`)
  ```bash
  export GROQ_MODEL="llama-3.3-70b-versatile"
  ```
  Other available models: `llama-3.1-8b-instant`, `llama-3.1-70b-versatile`, `mixtral-8x7b-32768`, etc.

- **`GROQ_SYSTEM_PROMPT`**: Custom system prompt (default: "You are a terminal command assistant. Respond ONLY with the exact command(s). No explanation, no markdown, no code blocks.")
  ```bash
  export GROQ_SYSTEM_PROMPT="Your custom prompt here"
  ```

### Advanced Plugin Only

- **`GROQ_ENABLE_HISTORY`**: Enable conversation history (default: `false`)
  ```bash
  export GROQ_ENABLE_HISTORY="true"
  ```

- **`GROQ_MAX_EXCHANGES`**: Maximum number of conversation exchanges to keep in history (default: `5`)
  ```bash
  export GROQ_MAX_EXCHANGES=10
  ```

## Usage

### Simple Plugin

Type `# your question` and press Enter:

```bash
# list all files in current directory sorted by size
```

The plugin will replace your question with the generated command.

### Advanced Plugin

**Basic usage** (same as simple plugin):
```bash
# find all python files
```

**With history enabled** (`GROQ_ENABLE_HISTORY="true"`):
- The plugin maintains conversation context
- Use `## clear` or `## reset` to clear conversation history

## Example Configuration

Add this to your `~/.zshrc`:

```bash
export GROQ_API_KEY="your-api-key-here"
export GROQ_MODEL="llama-3.3-70b-versatile"
export GROQ_ENABLE_HISTORY="true"
export GROQ_MAX_EXCHANGES=5

source ~/groq-zsh/groq-ai.plugin.zsh
```

## Troubleshooting

**Plugin not working?**
- Make sure `GROQ_API_KEY` is set: `echo $GROQ_API_KEY`
- Verify `jq` is installed: `which jq`
- Check plugin is sourced: `grep groq ~/.zshrc`

**API errors?**
- Verify your API key is valid
- Check your internet connection
- Ensure you have API credits/quota

## License

MIT
