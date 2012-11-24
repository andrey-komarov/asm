#!/bin/bash

while true
do
    python gen.py > count.in
    ./a.out > x
    ./count > y
    diff x y || break
    cat count.in
done
