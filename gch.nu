#!/bin/nu
# Git checkout helper

def get_branches [] {
    g branch -l | parse -r '(?x)([[:alnum:]_-]+)' | get capture0 | input list
}
