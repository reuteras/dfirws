#!/bin/bash

for dir in /c/git/*; do
    basename=$(basename "$dir")
    git config --global --add safe.directory "C:/git/$basename";
done