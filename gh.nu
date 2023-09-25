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
