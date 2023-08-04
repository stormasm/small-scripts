#!/home/marchall/.cargo/bin/nu

def get_region [] {
  let cols = (ls ~/.ovpns | get name | split column '/')
  $cols | get ($cols | columns | last) | input list
}

get_region

