#!/bin/bash
for i in $(seq 1 10);
do 
  curl -s -H "version:v1.2.0" echo.autumn.com |grep "Hostname";
  # curl -s -H echo.autumn.com |grep "Hostname"
done