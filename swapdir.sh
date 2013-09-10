#!/bin/bash
function TestDirectory 
{
  if [ -L "$1" ];
  then
    echo "Parameter '$1' is symlink"
    exit
  fi
  if [ ! -d "$1" ];
  then
    echo "Parameter '$1' is not directory"
    exit
  fi
}

TestDirectory $1
TestDirectory $2


dir=$(mktemp -d)
mv $1 $dir
mv $2 $1
base=$(basename $1)
mv $dir/$base $2
rmdir $dir
