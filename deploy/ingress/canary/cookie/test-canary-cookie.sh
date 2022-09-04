#!/bin/bash
for i in $(seq 1 10);
do 
  curl -s -b "beijing=always" echo.autumn.com |grep "Hostname";
dones