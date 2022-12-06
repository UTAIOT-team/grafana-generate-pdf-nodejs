#!/bin/bash
machine=('mx5' 'mx13' 'mx14' 'me8' 'me9' 'me10' 'me11' 'mj4' 'ai1' 'ai2' 'ai4' 'aj2' 'ae1' 'ae2' 'ae5' 'ae6' 'ae7' 'ae8' 'ae9' 'ae10')

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
fi
echo $udate
from=$udate
to=$((from+86400))

echo $from , $to
GF_TIME="&from=${from}000&to=${to}000"
echo $GF_TIME

GF_DASH_URL="https://192.168.2.3:3000/d/nLFCnaWgk/report_single?orgId=2&var-machine=aj2"
GF_USER="admin"
GF_PASSWORD="admin"
OUTPUT_PDF="./output/output_${vdate}.pdf"

echo "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF
node grafana_pdf.js "$GF_DASH_URL$GF_TIME" $GF_USER:$GF_PASSWORD $OUTPUT_PDF
for str in ${machine[@]}; do
  echo $str
done
