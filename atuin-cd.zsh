atuin-cd() {
  local db="${ATUIN_DB:-$HOME/.local/share/atuin/history.db}"

  sqlite3 "$db" "
    SELECT
      char(27) || '[34m' ||
      strftime(
        '%Y-%m-%d',
        MAX(timestamp) / 1000000000,
        'unixepoch'
      ) ||
      char(27) || '[0m ' ||
      replace(cwd, '$HOME', '~')
    FROM history
    WHERE cwd IS NOT NULL
      AND cwd != ''
    GROUP BY cwd
    ORDER BY MAX(timestamp) DESC;
  "
}
