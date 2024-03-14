#!/bin/env nu
# zelp.nu
# Zellij git hELPer - the successor to gelp

const IGNORE_DIRS = [".cache", ".cargo", ".local"]

export def main [] {
  let project_name = "spanish-chat-tech"
  let project_dir = "~/documents/spanish-chat-tech"

  let layout_dir = [$env.XDG_CONFIG_HOME, "zellij", "layouts"] | path join
  let possible_custom_layout_path = ([$project_dir, "zlayout.kdl"] | path join)
  let layout_path = if ($possible_custom_layout_path | path exists) { 
    $possible_custom_layout_path 
  } else {
    [$layout_dir, "default_layout.kdl"] | path join
  }

  let layout_config = (parse-layout-config $layout_path)
  let session_name = ($layout_config | get -i name | default $project_name)
  print $"Session name: ($session_name)"

  if (session-exists $session_name) {
    if (input "Session exists, force restart? (y/n)") == 'y' {
      zellij kill-sessions $session_name --force
    } else {
      zellij attach $session_name
      return
    }
  }

  if ($layout_config | get -i auth-needed | default false | into bool) and not (authenticate-keyring -v) {
    print "Failed to authenticate keyring..."
    return
  }

  $layout_config
}

export def list-projects [] {
  let ignore_dirs_arg = $"-E '{($IGNORE_DIRS | str join ',')}'" | str expand | str join ' '
  let fd_args = $'-Hau "^.git$" $"($env.HOME)" ($ignore_dirs_arg) --prune'
  let full_paths = (nu -c $"fd ($fd_args)" | lines)
  $full_paths
}

export def list-sessions [] {
  zellij ls --short | lines
}

export def session-exists [
  session_name: string
] -> bool {
  $session_name in (list-sessions)

}

# Requires 'dummy' entry in password store
def authenticate-keyring [
  --verbose (-v)
] -> bool {
  if $verbose { print -n "Keyring authentication needed..." }
  if (pass show dummy | complete | get exit_code) == 0 {
    if $verbose { print "success" }
    true
  } else {
    if $verbose { print }
    false
  }
}

export def parse-layout-config [
  config_path: path
] {
  open $config_path --raw | 
    lines | 
    filter { str starts-with '//' } | 
    each { str replace '//' '' | str trim } | 
    parse '{key} = {value}' | 
    transpose --header-row | 
    into record
}

