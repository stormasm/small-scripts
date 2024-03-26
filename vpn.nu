#!/home/marchall/.cargo/bin/nu
# TODO: 
#   - Pull username, password from pass
#   - Input into openvpn
#   - Print background process id
#   - Parse filenames to only show region or look inside file for region name

export def choose [] {
  let options = (ls ~/.ovpns | 
    each { 
      |in| $in.name | 
        path basename | 
        parse "rkr_{country}-{state_province}.{url}_{tcp_udp}.ovpn" 
    } | 
    flatten | 
    rename -c {country: 'Alpha-2 code'} | 
    update 'Alpha-2 code' { str upcase } | 
    join (open countries_codes_and_coordinates.csv) 'Alpha-2 code' | 
   insert fmt { |row| $"($row.Country) - ($row.state_province | str upcase)" }
  )
  $options | input list -fd fmt
}

# Get record of VPN credentials
def vpn-creds [] {
  pass show vpn/surfshark-vpn-creds |  
    lines |
    each { parse  '{field}: {value}' } | 
    flatten | 
    transpose --header-row  |
    into record
}

export def connect [] {
  let creds = (vpn-creds)
  $"($creds.username)\n($creds.password)\n" | save -f /tmp/creds.txt
  let choice = (ls ~/.ovpns/ | input list -f)
  pueue add sudo openvpn --config ($choice.name) --auth-user-pass /tmp/creds.txt
  rm /tmp/creds.txt
}
