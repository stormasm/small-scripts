#!/bin/bash

my_path=$(dirname "$0")
files=$(ls $my_path)

for file in $files; do
  prod=$(cat $file | awk '/production:/{print $NF}')
  [ "$prod" = "true" ] && 
      chmod +x "$my_path/$file" && 
      cp "$my_path/$file" "$HOME/.local/bin/" &&
      echo "Copied $file to $HOME/.local/bin/"
done
