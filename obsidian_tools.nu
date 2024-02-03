#!/bin/env nu

def get-checkboxes [] { 
  $in | 
    lines | 
    parse --regex '- \[(?<status>[x\ ])\] (?<item>[\w\W\s]+)' | 
    update status { |row| not ($row | get status | str trim | is-empty) }
}
