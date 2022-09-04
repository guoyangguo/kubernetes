#!/bin/bash
for i in $(seq 1 10);
do 
  curl -s echo.autumn.com |grep "Hostname";
done