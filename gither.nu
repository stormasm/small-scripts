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

export def main [] {
  echo "Gathering projects..."
  let docker_info = docker-info
  let projects = (
    cd $env.HOME; ls **/*/.git | 
    append (ls ~/.gitclones/*/.git) | 
    insert project_dir { |it| $env.HOME | path join ($it.name | path dirname) } |
    join ($docker_info | rename -c [Source project_dir]) project_dir --left | 
    rename -b {str downcase | str trim | str replace -a ' ' '_'} 
  )
  let project_idx = (
    $projects | 
    get project_dir | 
    path basename |
    venumerate |
    input list -f |
    split row ' ' | 
    first | 
    into int
  )
  let project = ($projects | get ($project_idx - 1))  
  $project
}
