#!/bin/env nu
# gelp.nu - yet another git helper
# TODO: Make database to store usage numbers and sort selection by number of recent uses
  
export def docker-info [] {
  docker ps | 
    from ssv | 
    insert _ { 
      docker inspect -f '{{ json .Mounts }}' (
        $in | get "CONTAINER ID"
      ) | 
      from json | 
      get 0 
    } |
    flatten
}

# Select project to open
export def-env "gelp select" [] {
  echo "Gathering projects..."
  let docker_info = docker-info
  let projects = (
    cd $env.HOME; ls documents/*/.git | 
    append (ls .gitclones/*/.git) | 
    insert project_dir { |it| $env.HOME | path join ($it.name | path dirname) } |
    join ($docker_info | rename -c [Source project_dir]) project_dir --left | 
    rename -b { str downcase | str trim | str replace -a ' ' '_' } 
  )
  let project_idx = (
    $projects | 
    each { 
      if not ($in.image | is-empty) { 
        $"($in.project_dir | path basename) \((ansi g)container: (ansi reset)($in.image)\)" 
      } else { 
        $"($in.project_dir | path basename)" 
      }
    } |
    venumerate |
    input list -f |
    split row ' ' | 
    first | 
    if ($in | is-empty) { return } else { into int }  
  )
  let project = ($projects | get ($project_idx - 1))  

  let action = (["edit", "git", "cd"] | input list)
  if ($action == "edit") {
    hx $project.project_dir
  } else if ($action == "git") { 
    gitui -d $project.project_dir
  } else if ($action == "cd") {
    cd $project.project_dir
  }
}

# gelp.nu - yet another git helper
export def-env main [] { gelp select }
