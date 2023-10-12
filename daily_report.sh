#!/bin/bash
machine=('mx5' 'mx13' 'mx14' 'mx15' 'me8' 'me9' 'me10' 'me11' 'mj2' 'mj3' 'mj4' 'mj5' 'ai1' 'ai2' 'ai4' 'aj2' 'ae1' 'ae2' 'ae5' 'ae6' 'ae7' 'ae8' 'ae9' 'ae10')

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
GF_DASH_URL="https://192.168.2.3:3000/d/_Mjk-mmgk/mei-ri-chan-chu-tong-ji-biao-ge-2_you-ban-bie?orgId=2"
node $GF_SCRIPT "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF

# machine
OUTPUT_PDF="./grafana_output/機台稼動明細/${vdate}"
mkdir -p $OUTPUT_PDF

#echo "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF
#node grafana_A3.js "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF
for str in ${machine[@]}; do
  GF_DASH_URL="https://192.168.2.3:3000/d/nLFCnaWgk/report_single?orgId=2&var-machine=${str}"
  OUTPUT_PDF="/home/uta_iot/grafana_output/機台稼動明細/${vdate}/${str}.pdf"
  echo "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF
  node $GF_SCRIPT "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF

  sleep 120
done
