rem Make DEXiEval portable .zip installation packages (to be unpacked at the target machine and run outright)
rem Required: Info zip http://infozip.sourceforge.net/ (or equivalent command-line zip archive maker)
rem Required: tar utility at c:\Windows\System32\tar
setlocal
set Version=_1.2
set Binary=Release
if "%1"="D" set Binary=Debug
set ZipName=DEXiEval%Version%.zip
set TarName=DEXiEval%Version%.tgz
unp %ZipName
erase %ZipName /s/f/q/y
zip -j %ZipName ..\*.md

rem Java
set Platform=DEXiEvalJava
set PlatformID=Java
set AppSource=D:\DEXiEval\%Platform\Bin\%Binary
erase %PlatformID\* /s/f/q/y
md %PlatformID\
cd %PlatformID\
xcopy %AppSource%\*.jar . /s
erase rt.jar /s/q
erase *.jmod /s/q
ren dexievaljava.jar dexieval.jar
cd ..
zip -mrpo9 %ZipName %PlatformID\*
rd %PlatformID

rem Windows
set Platform=DEXiEvalNet
set PlatformID=Windows
set AppSource=D:\DEXiEval\%Platform\Bin\%Binary
erase %PlatformID\* /s/f/q/y
md %PlatformID\
cd %PlatformID\
xcopy %AppSource%\*.exe . /s
xcopy %AppSource%\*.dll . /s
ren DEXiEvalNet.exe DEXiEval.exe
cd ..
zip -mrpo9 %ZipName %PlatformID\*
rd %PlatformID

rem Windows
set Platform=DEXiEvalNetCore
set PlatformID=NetCore
set AppSource=D:\DEXiEval\%Platform\Bin\%Binary
erase %PlatformID\* /s/f/q/y
md %PlatformID\
cd %PlatformID\
xcopy %AppSource%\*.dll . /s
xcopy %AppSource%\DEXiEvalNetCore.runtimeconfig.json *
ren DEXiEvalNetCore.dll DEXiEval.dll
ren DEXiEvalNetCore.runtimeconfig.json DEXiEval.runtimeconfig.json
cd ..
zip -mrpo9 %ZipName %PlatformID\*
rd %PlatformID

rem Tar
md Tar
cd Tar
unzip ..\%ZipName
C:\Windows\System32\tar -czvf ..\%TarName% *
cd ..
erase Tar\* /s/f/q/y
rd Tar\*
rd Tar

move %TarName ..\Installers\*
move %ZipName ..\Installers\*
