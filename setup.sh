#!/bin/bash

my_path=$(dirname "$0")
files=$(ls $my_path)

for file in $files; do
  prod=$(cat $file | awk '/production:/{print $NF}')
  [ "$prod" = "true" ] && cp "$my_path/$file" "$HOME/.local/bin/"
done
