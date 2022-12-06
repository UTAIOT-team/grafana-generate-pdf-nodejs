@echo off

set vdate=%~1
set /a shift=0
if not defined vdate (set vdate=%date:~0,4%%date:~5,2%%date:~8,2%& set /a shift=1)
set yy=%vdate:~0,4%& set mm=%vdate:~4,2%& set /a dd=%vdate:~6,2% - %shift%
echo %vdate%, %shift%
echo %yy%/%mm%/%dd%

setlocal
call :GetUnixTime UNIX_TIME
set from=%UNIX_TIME%
set /a to=%from% + 86400
rem echo %UNIX_TIME% seconds have elapsed since 1970-01-01 00:00:00
echo From:%from%000, To:%to%000
set GF_TIME=^&from=%from%000^&to=%to%000
rem set GF_TIME=""
echo "%GF_TIME%"
rem set GF_DASH_URL="https://192.168.2.3:3000/d/vEfuJfmgk/sheng-chan-su-du?orgId=2"
rem set GF_DASH_URL="https://192.168.2.3:3000/d/vasKTID7k/ai4?orgId=2"
set GF_DASH_URL=https://192.168.2.3:3000/d/xZyQRvRgz/mei-ri-chan-chu-tong-ji-biao-ge?orgId=2
set GF_USER=admin
set GF_PASSWORD=admin
set OUTPUT_PDF=./output/%yy%%mm%%dd%_daily_quantity_form.pdf

echo "%GF_DASH_URL%%GF_TIME%" %GF_USER%:%GF_PASSWORD% %OUTPUT_PDF%
node grafana_pdf.js "%GF_DASH_URL%%GF_TIME%" %GF_USER%:%GF_PASSWORD% %OUTPUT_PDF%
set GF_DASH_URL=https://192.168.2.3:3000/d/vx36urZRk/mei-ri-chan-chu-tong-ji-tu-biao?orgId=2
set OUTPUT_PDF=./output/%yy%%mm%%dd%_history_quantity_line.pdf
echo "%GF_DASH_URL%" %GF_USER%:%GF_PASSWORD% %OUTPUT_PDF%
node grafana_pdf.js "%GF_DASH_URL%" %GF_USER%:%GF_PASSWORD% %OUTPUT_PDF%
goto :EOF


:GetUnixTime
setlocal enableextensions
for /f %%x in ('wmic path win32_utctime get /format:list ^| findstr "="') do (set %%x )
set /a z=(14-100%mm%%%100)/12, y=10000%yy%%%10000-z
set /a ut=y*365+y/4-y/100+y/400+(153*(100%mm%%%100+12*z-3)+2)/5+%dd%-719469
rem set /a ut=ut*86400+100%Hour%%%100*3600+100%Minute%%%100*60+100%Second%%%100
set /a ut=ut*86400
endlocal & set "%1=%ut%" & goto :EOF
