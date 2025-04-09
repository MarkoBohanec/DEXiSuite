setlocal
set AppDir=D:\DEXiWin\
set AppName=DEXiWin
pushd %AppDir%\Bin\Packed
copy ..\Release\*.exe
copy ..\Release\*.dll
libz inject-dll --assembly %AppName%.exe --include *.dll --move
popd
