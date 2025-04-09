rem Build DEXiWin: Debug and Release configurations
rem Required: RemObjects ebuild https://docs.elementscompiler.com/EBuild/
ebuild --rebuild --configuration:Debug DexiWin.sln
ebuild --configuration:Release DexiWin.sln