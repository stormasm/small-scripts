#!/bin/env nu
# TODO: add restore

# Backup history with optional label
export def main [
  label?
] {
  let end = if ($label | is-empty) { "" } else { $"-($label)" } 
  let history_dir = ($nu.history-path | path dirname)
  let sqlfiles = [history.sqlite3, history.sqlite3-shm, history.sqlite3-wal]
  $sqlfiles | 
    each { |it| cp ($history_dir | path join $it) ($history_dir | path join $"($it).copy($end)") }
}