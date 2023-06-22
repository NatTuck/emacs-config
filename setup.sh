#!/bin/bash

BASE=$(pwd)

mkdir -p tmp
cd tmp
git clone https://github.com/casouri/tree-sitter-module.git
cd tree-sitter-module
./batch.sh
cp -r dist "$BASE/tree-sitter"

