#!/bin/zsh
# groq-ai.plugin.zsh - Type `# question` and press Enter

(( ${+GROQ_API_KEY} )) || {
  print -P "%F{yellow}groq-ai:%f Set GROQ_API_KEY in ~/.zshrc"
  return 1
}

typeset -g GROQ_MODEL="${GROQ_MODEL:-llama-3.3-70b-versatile}"
typeset -g GROQ_SYSTEM_PROMPT="You are a terminal command assistant. Respond ONLY with the exact command(s). No explanation, no markdown, no code blocks."
typeset -g GROQ_ENABLE_HISTORY="${GROQ_ENABLE_HISTORY:-false}"
typeset -gi GROQ_MAX_EXCHANGES="${GROQ_MAX_EXCHANGES:-5}"
typeset -ga GROQ_CONVERSATION_HISTORY=()

_groq_add_to_history() {
  local role=$1
  local content=$2

  # Add message to history
  GROQ_CONVERSATION_HISTORY+=("$role:$content")

  # Keep only last N exchanges (2 messages per exchange)
  local max_messages=$((GROQ_MAX_EXCHANGES * 2))
  if (( ${#GROQ_CONVERSATION_HISTORY[@]} > max_messages )); then
    GROQ_CONVERSATION_HISTORY=("${GROQ_CONVERSATION_HISTORY[@]: -$max_messages}")
  fi
}

_groq_clear_history() {
  GROQ_CONVERSATION_HISTORY=()
}

_groq_build_messages() {
  local current_query=$1
  local messages='[{"role": "system", "content": "'"$GROQ_SYSTEM_PROMPT"'"},'

  # Add history messages (only if enabled and history exists)
  if [[ $GROQ_ENABLE_HISTORY == true && ${#GROQ_CONVERSATION_HISTORY[@]} -gt 0 ]]; then
    for msg in "${GROQ_CONVERSATION_HISTORY[@]}"; do
      local role="${msg%%:*}"
      local content="${msg#*:}"
      # Escape content for JSON
      content=${content//\\/\\\\}
      content=${content//\"/\\\"}
      content=${content//$'\n'/\\n}
      content=${content//$'\t'/\\t}
      messages+='{"role": "'"$role"'", "content": "'"$content"'"},'
    done
  fi

  # Add current query
  messages+='{"role": "user", "content": "'"$current_query"'"}]'
  echo "$messages"
}

_groq_query() {
  local query=$1
  # Escape query for JSON
  query=${query//\\/\\\\}
  query=${query//\"/\\\"}
  query=${query//$'\n'/\\n}
  query=${query//$'\t'/\\t}

  local messages=$(_groq_build_messages "$query")

  curl -sS --max-time 15 "https://api.groq.com/openai/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -d '{
      "model": "'"$GROQ_MODEL"'",
      "messages": '"$messages"',
      "temperature": 0.1,
      "max_tokens": 256
    }' 2>/dev/null | jq -r '.choices[0].message.content // empty' 2>/dev/null
}

_groq_accept_line() {
  if [[ $BUFFER == \#[!\#]* ]]; then
    # Check for ## clear command (only if history enabled)
    if [[ $GROQ_ENABLE_HISTORY == true && $BUFFER == \#\#* ]]; then
      local cmd=${BUFFER#\#\#}
      cmd=${cmd# }
      if [[ $cmd == clear || $cmd == reset || -z $cmd ]]; then
        _groq_clear_history
        print -P "%F{green}groq-ai:%f Conversation history cleared"
        BUFFER=""
        zle redisplay
        return
      fi
    fi

    # Process # query
    local query=${BUFFER#\#}
    query=${query# }
    [[ -n $query ]] && {
      local result=$(_groq_query "$query")
      [[ -n $result ]] && {
        # Add to history (only if enabled)
        if [[ $GROQ_ENABLE_HISTORY == true ]]; then
          _groq_add_to_history "user" "$query"
          _groq_add_to_history "assistant" "$result"
        fi

        # Update buffer
        BUFFER=$result
        CURSOR=$#BUFFER
        zle redisplay
        return
      }
    }
  fi
  zle .accept-line
}

zle -N accept-line _groq_accept_line
