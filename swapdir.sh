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
  else
    #absoute=0
    echo -n $(pwd)
    echo $1
  fi  
}

TestDirectory $1
TestDirectory $2

$1 = $(MakeAbsolute $1)
$2 = $(MakeAbsolute $2)

TestDirectory $1
TestDirectory $2

declare -a on_exit_items

function on_exit()
{
    for i in "${on_exit_items[@]}"
    do
        echo "on_exit: $i"
        eval $i
    done
}

function add_on_exit()
{
    local n=${#on_exit_items[*]}
    on_exit_items[$n]="$*"
    if [[ $n -eq 0 ]]; then
        echo "Setting trap"
        trap on_exit EXIT
    fi
}

function MoveToTmp
{
  dir=$(mktemp -d)
  add_on_exit rmdir $dir
  mv $1 $dir
  base=$(basename $1)
  echo "$dir/$base"
}

function Swap
{
  $one = $(MoveToTmp $1)
  $two = $(MoveToTmp $2)
  
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
}

Swap $1 $2
