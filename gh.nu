#!/bin/env nu
# gh.nu

export def gitignore [
  --language (-l) ?: string # Language to bypass selection
  --no-save (-n)
] {
  let language = if not $language {
    http get (
    {
      scheme: https
      username: brunerm99
      host: api.github.com
      port: ""
      path: $"gitignore/templates"
      fragment: ""
    } | url join) | input list -f
  } else { $language }
  print $"Fetching ($language) gitignore"
  let gitignore = (http get (
    {
      scheme: https
      username: brunerm99
      host: api.github.com
      port: ""
      path: $"gitignore/templates/($language)"
      fragment: ""
    } | url join)
  )
  if not $no_save {
    $gitignore | save .gitignore-test
  }
}

# Get info on whether repos are ahead of remote
# Relies on zelp's creation of the project_cache.nuon file
# FIXME: Make tolerant of repos with no 'main' branch
export def ahead-info [] {
  open ~/.local/share/zelp/project_cache.nuon | 
    filter { |prj| $prj.full_path | path join ".git" | path exists } | 
    insert origin_diff { |prj| git -C $prj.full_path log --oneline origin/main..HEAD | lines } | 
    insert commits_ahead { |prj| $prj.origin_diff | length } 
}

# Return all repos ahead of remote
export def all-ahead [] {
  ahead-info | where commits_ahead > 0
}
