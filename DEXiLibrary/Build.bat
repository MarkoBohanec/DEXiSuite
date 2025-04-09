rem Build DEXiLibrary: Debug and Release configurations
rem Required: RemObjects ebuild https://docs.elementscompiler.com/EBuild/
ebuild --rebuild --configuration:Debug DexiLibrary.sln
ebuild --configuration:Release DexiLibrary.sln