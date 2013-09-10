#!/bin/bash
dir=$(mktemp -d)
mv $1 $dir
mv $2 $1
base=$(basename $1)
mv $dir/$base $2
rmdir $dir
