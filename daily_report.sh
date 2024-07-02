#!/bin/bash
if [ $1 ]
then
  shift_day=0
  vdate=$1
  echo $vdate , $shift_day
  udate=$(date -d "${vdate}" +"%s")

else
  shift_day=1
  vdate=$(date +"%Y%m%d")
  echo $vdate , $shift_day
  udate=$(date -d "${vdate}" +"%s")
  udate=$((udate-shift_day*86400))
  vdate=$(date -d "@${udate}" +"%Y%m%d")

fi
echo $udate
from=$((udate+28800))
to=$((from+86399))

GF_SCRIPT="/home/uta_iot/github_repo/grafana-generate-pdf-nodejs/grafana_A3.js"
echo $from , $to
GF_TIME="&from=${from}000&to=${to}000"
echo $GF_TIME

GF_USER="admin"
GF_PASSWORD="admin"

# 生產數量
OUTPUT_PDF="/home/uta_iot/grafana_output/生產統計表/${vdate}.pdf"
GF_DASH_URL="https://192.168.2.3:3000/d/7zc-JJkRz/mei-ri-chan-chu-tong-ji-3?orgId=2"
node $GF_SCRIPT "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF

# machine
GF_SCRIPT="/home/uta_iot/github_repo/grafana-generate-pdf-nodejs/grafana_machines.js"
OUTPUT_PDF="/home/uta_iot/grafana_output/機台稼動明細/${vdate}/"

node $GF_SCRIPT "$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF
