@echo off
@echo killing active adb sessions
@echo.
taskkill /f /im adb.exe >nul
cls
echo =================================================================
echo " Rooting Tool for retrofitted Automotive Android 9/10 Headunit "
echo "                                                               "
echo "        Ensure your Headunit is PX6 or Snapdragon 625          "
echo "                                                               "
echo "     written by Chrisu02 @ https://github.com/Chrisu02 V2.0    "
echo "                                                               "
echo "               !!! Do use at your own risk !!!                 "
echo =================================================================
echo.

SET /p _IP= enter the IP address of the device (e.g. 192.168.0.1): 
@echo connecting to device ....
:initialconnect
set _inputname=%_ip%:5555
echo.
@echo If %_ip% cannot be connected please check IP address again
timeout 2
ping -n 1 %_ip% |find "TTL=" || goto :initialconnect
echo Answer received.
echo.
call :connecting

@echo. Disabling Verity
"%cd%\compiler\adb" disable-verity
timeout 1 >nul
@echo. Rebooting device ...
call :rebooting
call :pingloop
call :connecting

"%cd%\compiler\adb" shell setenforce 0
@echo Pushing SU file
"%cd%\compiler\adb" push su /system/bin/su
"%cd%\compiler\adb" push su /system/xbin/su
timeout 1 >nul
"%cd%\compiler\adb" shell chmod 06755 /system/bin/su
"%cd%\compiler\adb" shell chmod 06755 /system/xbin/su
timeout 1 >nul
echo.
echo Installing SU
"%cd%\compiler\adb" shell /system/bin/su --install
timeout 1 >nul
start /min %cd%\compiler\adb shell /system/bin/su --daemon&
timeout /t 3 >nul
"%cd%\compiler\adb" shell /system/bin/su --daemon&
"%cd%\compiler\adb" push rooting.rc /system/etc/init/rooting.rc
call :rebooting

taskkill /f /im adb.exe >nul
@echo rooting finished
@echo.
pause
exit
::functions

:connecting
echo. Connecting to device...
"%cd%\compiler\adb" disconnect
timeout 1 >nul
"%cd%\compiler\adb" connect "%_inputname%"
timeout 1 >nul
echo Perfoming adb root
"%cd%\compiler\adb" root
timeout 1 >nul
echo performing adb remount
"%cd%\compiler\adb" remount
echo.
timeout 1 >nul
goto :eof

:pingloop
echo. Waiting until %_ip% is reachable again...
timeout 3 >nul
ping -n 1 %_ip% |find "TTL=" || goto :pingloop
echo Answer received.
echo.
goto :eof

:rebooting
timeout 1 >nul
echo.
@echo. Android device is rebooting , please wait...
start "" /min "%CD%\compiler\adb.exe" reboot
timeout 3 >nul
goto :eof
