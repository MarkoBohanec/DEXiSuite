rem Build DEXiEval: Debug and Release configurations
rem Required: RemObjects ebuild https://docs.elementscompiler.com/EBuild/
ebuild --rebuild --configuration:Debug DexiEval.sln
ebuild --configuration:Release DexiEval.sln