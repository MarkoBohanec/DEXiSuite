rem Make DEXiWin MSI installation package
rem Required: WiX Toolset https://wixtoolset.org/
setlocal
set Version=_1.2.0.2
set WixPath=C:\Program Files (x86)\WiX Toolset v3.11\bin\
erase DEXiWin.msi /q
"%WixPath%\candle.exe" DexiWin.wxs
if ERRORLEVEL 1 exit /b
"%WixPath%\light.exe" -ext WixUIExtension DEXiWin.wixobj
if ERRORLEVEL 1 exit /b
erase *.wixobj *.wixpdb /q
copy DEXiWin.msi ..\Installers\DEXiWin%Version%.msi
erase DEXiWin.msi /q
endlocal