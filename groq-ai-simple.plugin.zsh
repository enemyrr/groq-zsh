#!/bin/zsh
# groq-ai.plugin.zsh - Type `# question` and press Enter

(( ${+GROQ_API_KEY} )) || {
  print -P "%F{yellow}groq-ai:%f Set GROQ_API_KEY in ~/.zshrc"
  return 1
}

typeset -g GROQ_MODEL="${GROQ_MODEL:-llama-3.3-70b-versatile}"
typeset -g GROQ_SYSTEM_PROMPT="You are a terminal command assistant. Respond ONLY with the exact command(s). No explanation, no markdown, no code blocks."

_groq_query() {
  local query=$1
  query=${query//\\/\\\\}
  query=${query//\"/\\\"}
  query=${query//$'\n'/\\n}
  query=${query//$'\t'/\\t}

  curl -sS --max-time 15 "https://api.groq.com/openai/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -d '{
      "model": "'"$GROQ_MODEL"'",
      "messages": [
        {"role": "system", "content": "'"$GROQ_SYSTEM_PROMPT"'"},
        {"role": "user", "content": "'"$query"'"}
      ],
      "temperature": 0.1,
      "max_tokens": 256
    }' 2>/dev/null | jq -r '.choices[0].message.content // empty' 2>/dev/null
}

_groq_accept_line() {
  if [[ $BUFFER == \#[!\#]* ]]; then
    local query=${BUFFER#\#}
    query=${query# }
    [[ -n $query ]] && {
      local result=$(_groq_query "$query")
      [[ -n $result ]] && { BUFFER=$result; CURSOR=$#BUFFER; zle redisplay; return; }
    }
  fi
  zle .accept-line
}

zle -N accept-line _groq_accept_line
