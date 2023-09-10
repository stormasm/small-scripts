#!/home/marchall/.cargo/bin/nu
# TODO: 
#   - Pull username, password from pass
#   - Input into openvpn
#   - Print background process id
#   - Parse filenames to only show region or look inside file for region name

def main [] {
  let options = (ls ~/.ovpns | 
    each { 
      |in| $in.name | 
        path basename | 
        parse "rkr_{country}-{state_province}.{url}_{tcp_udp}.ovpn" 
    } | 
    flatten)
  let choice = ($options | select country state_province | input list)
}
