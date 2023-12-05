#!/bin/env nu
# Should be run inside duolingo-vocab-lists/english-spanish/original

export def main [] {
  ls **/* | 
    where name !~ 'combined' and type == file | 
    each {|row| 
        ($row.name | path basename | parse 'english-spanish-Part {part}-{name}.csv' | insert filename $row.name) | 
        insert words {|row| try { (open $row.filename --raw | from csv --noheaders | rename spanish english) }  catch { print $'($row.filename) failed'; [{spanish: _, english: _}] } 
      } 
    } | flatten | flatten | flatten
}
