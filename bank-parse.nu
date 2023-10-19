#!/bin/env nu

# Parse chase bank CSV files
# expected input is: `open <filename>.csv --raw`
export def "from chase-bank" [] {
  from csv |
    update "Transaction Date" { || into datetime } | 
    flatten | 
    rename -b { || str trim | str downcase } | 
    select year month day description category type amount | 
    insert account "chase"
}

# Parse ally bank CSV files
# expected input is: `open <filename>.csv --raw`
export def "from ally-bank" [] {
  from csv | 
    update Date { || into datetime } | 
    flatten | 
    rename -b { || str trim | str downcase  } | 
    select year month day description type amount | 
    insert Category "" | 
    insert account "ally"
}

# Parse wells fargo bank CSV files
# expected input is: `open <filename>.csv --raw`
export def "from wells-fargo-bank" [] {
  from csv --noheaders | 
    rename date amount _ _ description | 
    reject _ | 
    update date { || into datetime } | 
    flatten | 
    insert category "" | 
    insert type "" | 
    insert account "wells fargo" 
}
