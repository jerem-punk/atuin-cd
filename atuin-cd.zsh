atuin-cd() {
  local db="${ATUIN_DB:-$HOME/.local/share/atuin/history.db}"

  sqlite3 "$db" '
    SELECT DISTINCT cwd
    FROM history
    WHERE cwd IS NOT NULL
      AND cwd != ""
    ORDER BY timestamp DESC;
  '
}
