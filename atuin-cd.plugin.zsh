fzf_preview_layout() {
  if (( COLUMNS > 100 )); then
    echo "right,60%"
  elif (( LINES > 30 )); then
    echo "up,50%"
  else
    echo "hidden"
  fi
}

fzf_preview_command() {
  cat <<'EOF'
dir={2}
atuin search --cwd "$dir" --limit 5 --format "{time} {command}"
printf '\n'
eza -lah --icons --color=always "$dir"
EOF
}

atuin-select-dir() {
  local db="${ATUIN_DB:-$HOME/.local/share/atuin/history.db}"
  sqlite3 "$db" "
    SELECT
      char(27) || '[34m' ||
      strftime('%Y-%m-%d', MAX(timestamp) / 1000000000, 'unixepoch') ||
      char(27) || '[0m'
      || ' ' ||
      replace(cwd, '$HOME', '~')
      || char(9) ||
      cwd
    FROM history
    WHERE cwd IS NOT NULL
      AND cwd != ''
    GROUP BY cwd
    ORDER BY MAX(timestamp) DESC;
  " | fzf \
    --ansi \
    --no-sort \
    --delimiter=$'\t' \
    --with-nth=1 \
    --accept-nth=2 \
    --preview "$(fzf_preview_command)" \
    --preview-window "$(fzf_preview_layout)"
}

atuin-cd-widget() {
  local selected_dir
  local was_empty=$(( ${#BUFFER} == 0 ))

  selected_dir="$(atuin-select-dir)"
  [[ -z "$selected_dir" ]] && zle redisplay && return 0

  if (( was_empty )); then
    cd -- "$selected_dir"
    zle reset-prompt
  else
    LBUFFER+="${(q)selected_dir}/"
  fi
}

zle -N atuin-cd-widget
bindkey '^[d' atuin-cd-widget
