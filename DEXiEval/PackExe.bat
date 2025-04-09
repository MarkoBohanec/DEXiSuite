setlocal
set AppDir=D:\DEXiEval\DEXiEvalNet\
set AppName=DEXiEvalNet
pushd %AppDir%\Bin\Packed
copy ..\Release\*.exe
copy ..\Release\*.dll
libz inject-dll --assembly %AppName%.exe --include *.dll --move
popd
