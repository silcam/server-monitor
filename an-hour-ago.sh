#!/bin/bash

hour=$(date +"%H")
min_sec=$(date +":%M:%S")

if [ $hour -gt 0 ]; then
  hour=$(( 10#$hour - 1 ))
fi

if [ $hour -lt 10 ]; then
  hour="0$hour"
fi

echo $hour$min_sec
