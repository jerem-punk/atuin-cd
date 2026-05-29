atuin-cd() {
  local db="${ATUIN_DB:-$HOME/.local/share/atuin/history.db}"

  sqlite3 -separator ' ' "$db" '
    SELECT
      strftime(
        "%Y-%m-%d",
        MAX(timestamp) / 1000000000,
        "unixepoch"
      ) || " " || cwd
    FROM history
    WHERE cwd IS NOT NULL
      AND cwd != ""
    GROUP BY cwd
    ORDER BY MAX(timestamp) DESC;
  '
}
