rem Make DEXiWin portable .zip installation package (to be unpacked at the target machine)
rem Required: Info zip http://infozip.sourceforge.net/ (or equivalent command-line zip archive maker)
setlocal
set Version=_1.2.0.2
set Binary=Release
if "%1"="D" set Binary=Debug
set AppSource=D:\DEXiWin\Bin\%Binary
erase DEXiWinZip\* /s/f/q/y
md DEXiWinZip
xcopy %AppSource%\* .\DEXiWinZip\* /s
erase DEXiWinZip\*.xml /s/q
iff exist DEXiExamples.zip then
  md DEXiWinZip\Examples
  unzip -d .\DEXiWinZip\Examples DEXiExamples.zip 
endiff
erase DEXiWin%Version%.zip/s/q
zip -mrpo9 DEXiWin%Version%.zip DEXiWinZip\*
copy DEXiWin%Version%.zip ..\Installers\*
erase DEXiWin%Version%.zip /f/q/y
rd DEXiWinZip
