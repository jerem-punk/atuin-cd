fzf_preview_layout() {
  if (( COLUMNS > 100 )); then
    echo "right,70%"
  elif (( LINES > 30 )); then
    echo "up,50%"
  else
    echo "hidden"
  fi
}

atuin-cd() {
  local db="${ATUIN_DB:-$HOME/.local/share/atuin/history.db}"

  local selected_dir

  selected_dir="$(
    sqlite3 "$db" "
      SELECT
        char(27) || '[34m' ||
        strftime('%Y-%m-%d', MAX(timestamp) / 1000000000, 'unixepoch') ||
        char(27) || '[0m'
        || char(9) ||
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
      --with-nth=1,2 \
      --nth=2 \
      --accept-nth=3 \
      --preview 'eza -lah --icons --color=always {3}' \
      --preview-window "$(fzf_preview_layout)"
  )"

  [[ -n "$selected_dir" ]] && cd "$selected_dir"
}

atuin-cd-widget() {
  atuin-cd
  zle reset-prompt
}

zle -N atuin-cd-widget
bindkey '^[d' atuin-cd-widget


