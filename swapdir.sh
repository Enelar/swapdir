#!/bin/bash
function SysTest
{
  if [ -L "$1" ];
  then
    echo "sym"
  else
    if [ ! -d "$1" ];
    then
      echo "dir"
    else
      echo 'ok'
    fi
  fi
}

function TestDirectory 
{
  res=$(SysTest $1)
  if [ $res == "sym" ]
  then
    echo "Parameter '$1' is symlink"
    exit
  fi
  if [ $res == "dir" ];
  then
    echo "Parameter '$1' is not directory"
    exit
  fi
}

function MakeAbsolute
{
  if echo $1 | grep '^/' > /dev/null
  then
    #absolute=1
    echo $1
  else
    #absoute=0
    echo -n $(pwd)
    echo "/$1"
  fi  
}

TestDirectory $1
TestDirectory $2

d1=$(MakeAbsolute $1)
d2=$(MakeAbsolute $2)

TestDirectory $d1
TestDirectory $d2

declare -a on_exit_items

function MoveToTmp
{
  dir=$(mktemp -d)
  mv $1 $dir
  base=$(basename $1)
  echo "$dir/$base"
}

function Swap
{
  one=$(MoveToTmp $1)
  two=$(MoveToTmp $2)
  
  if [ $(SysTest $one) != "ok" ]
  then
    echo "Failed to move $1 directory"
    echo "Fallback"
    exit
  fi
  if [ $(SysTest $two) != "ok" ]
  then
    mv $one $1
    echo "Failed to move $2 directory"
    echo "Fallback"
    exit
  fi
  
  mv $one $2
  mv $two $1
  
  rmdir $(dirname $one)  
  rmdir $(dirname $two)  
}

Swap $d1 $d2
