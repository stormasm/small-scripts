#!/bin/envnu
# gelp.nu - yet another git helper
# Dependencies: fd-find
use utils.nu [venumerate, not-implemented]

# Parse git remote url
def parse-remote-url [
  repo_path: path # FS repo path
] {
  let git_remote = git -C $repo_path remote get-url origin
  do -i { $git_remote | url parse | url join } | default (    
    $git_remote | 
      parse '{version_control}@{host}:{username}/{repo}.git' | 
      get 0 | 
      insert "scheme" "https" | 
      insert "path" $"($in.username)/($in.repo)" | 
      select host path scheme |
      url join
    )
}
  
# Get information on running docker containers
export def docker-info [
  --verbose (-v)
] {
  let info = (docker ps | 
    from ssv | 
    insert _ { 
      docker inspect -f '{{ json .Mounts }}' (
        $in | get "CONTAINER ID"
      ) | 
      from json | 
      get 0 
    } |
    flatten |
    rename -b { str snake-case })
  if $verbose { $info } else { $info | select names image status }
}

# Pull projects from filesystem and update database for faster project search
def update-project-cache [] {
  fd -Hap -g "**/.git" $"($env.HOME)" -E ".cache" -E ".local" -E ".cargo" | 
    lines | 
    each { update-uses ($in | path dirname) --no-uses }
}

# Select project to open
export def-env select-project [] -> record {
  let docker_info = docker-info -v
  let projects = get-project-history | 
    reject id | 
    default 0 uses | 
    sort-by score -r |
    join ($docker_info | rename -c {"source": "project_dir"}) project_dir --left |
    rename -b { str downcase | str trim | str replace -a ' ' '_' } 

  let project_idx = (
    $projects | 
    each { |row|
      if not ($in | get -i image | is-empty) { 
        $"($row.project_dir | path basename) \((ansi g)container: (ansi reset)($row.image)\)" 
      } else { 
        $"($row.project_dir | path basename)" 
      }
    } |
    venumerate |
    input list -f |
    split row ' ' | 
    first | 
    if ($in | is-empty) { return } else { into int }  
  )
  let project = ($projects | get ($project_idx - 1))  
  $project
}

# Run action on project
def-env run-action [
  project: record # Project to run action on 
] {
  let action = (["edit", "git", "cd", "open remote"] | input list -f $"Action for ($project.project_dir | path basename):")
  update-uses $project.project_dir
  if ($action == "edit") {
    cd $project.project_dir; run-external ($env.EDITOR) ($project.project_dir)
  } else if ($action == "git") { 
    cd $project.project_dir; gitui -d $project.project_dir
  } else if ($action == "cd") {
    cd $project.project_dir
  } else if ($action == "open remote") {
    xdg-open (parse-remote-url $project.project_dir)
  }
  
}

### Database

# Update number of uses of a project
def update-uses [
  project_dir: path # Project path
  --no-uses # Default for projects stored but not yet used
] {
  create-env
  let use_date = (if $no_uses { 
    [0, ("01-01-1970" | into datetime | format date "%Y-%m-%dT%H:%M:%S")] 
  } else { 
    [1, (date now | format date "%Y-%m-%dT%H:%M:%S")] 
  })
  open $env.gelp_db_dir | query db $"
    INSERT INTO projects 
      \(project_dir, last_used, uses\)
      VALUES \(
        '($project_dir)', 
        '($use_date.1)', 
        ($use_date.0)
      \)
      ON CONFLICT \(project_dir\) DO UPDATE SET
        uses = uses + excluded.uses,
        last_used = CASE WHEN excluded.uses = 0 
          THEN last_used 
          ELSE '($use_date.1)' 
        END;
  "
}

# Get project history
export def get-project-history [
  --non-weighted # Don't use weighting function
] {
  create-env
  let project_history = (open $env.gelp_db_dir | 
    query db $"SELECT * FROM projects;" |
    update last_used { || into datetime })

  # TODO: better weighting
  let weighting_function = if $non_weighted {
    $in.item.uses 
  } else { # Weight using exponential decay of last use and number of uses
    {(($in.index / ($project_history | length)) | math exp) * $in.item.uses}  
  }
  $project_history | 
    enumerate | 
    insert score $weighting_function | 
    flatten
}

# Create SQLite database
export def create-db [
  db_path: path # Database path
] {
  mkdir ($db_path | path dirname)
  touch $db_path
  open $db_path | query db "
    CREATE TABLE IF NOT EXISTS projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      project_dir TEXT NOT NULL UNIQUE,
      uses INTEGER,
      last_used TEXT NOT NULL
    );
  "
}

# Get last-used project
def get-last-used [] {
  get-project-history | sort-by last_used | last
}

# Clear project use history
export def clear-history [] {
  create-env
  if (input "Are you sure? ") == "y" {
    let num_entries = (open $env.gelp_db_dir | query db $"
      SELECT * FROM projects;
      DELETE FROM projects;
    " | length)
    open $env.gelp_db_dir | query db $"DELETE FROM projects;"
    print $"($num_entries) row(s) deleted"
  } else {
    print "Cancelling..."
  }
}

# Add some environment variables if not already present
def-env create-env [] {
  $env.gelp_dir = ($env | get -i gelp_dir | default ($env.HOME | path join ".local/share/gelp"))
  $env.gelp_db_dir = ($env.gelp_dir | path join "history.db")
 }

# TODO: Not done
export def add-sync-info [] {
  let projects = $in
  $projects | 
    merge ($projects | each { |project| do { git -C $project.project_dir rev-parse --abbrev-ref HEAD } | complete }) | 
    update stdout { |row| if ($row.exit_code == 0) and (($row.stdout | str trim) != "HEAD") { $row.stdout | str trim } else { null } } | 
    rename -c { stdout: curr_branch } | 
    reject exit_code stderr |
    insert synced { |row| 
      if $row.curr_branch != null { 
        git -C $row.project_dir diff --numstat $row.curr_branch $"remotes/origin/($row.curr_branch)" | is-empty 
      } else {
        false
      }
    }
}

# gelp.nu - yet another git helper
export def-env main [
  --last (-l) # Bypass selector, use last project
  --update-cache (-u) # Update cached projects
] { 
  if $update_cache { update-project-cache }
  let project = if $last { get-last-used } else { (select-project) } 
  if ($project | is-empty) { return }
  run-action $project
}
