DEXi Suite
==========

DEXi Decision Modeling Software
-------------------------------

**DEXi Suite** is a software collection for developing and using hierarchical qualitative multi-criteria decision models according to the method DEX ([Decision EXpert](https://dex.ijs.si/documentation/DEX_Method/DEX_Method.html)).

DEXi Suite is aimed at gradually replacing [DEXi Classic](https://dex.ijs.si/dexiclassic/dexiclassic.html), DEX modeling tools developed in the period 2000-2020, including [DEXi](https://kt.ijs.si/MarkoBohanec/dexi.html), the trusted and <i>de-facto</i> DEX implementation since 2000. DEXi Suite has been rebuilt from the scratch in order to provide a more modern, flexible and extensible DEX platform, while maintaining backward compatibility with DEXi Classic.

DEXi Suite consists of three software components:

- [DexiLibrary](./DexiLibrary/README.md): A common software library for developing and using DEXi models. Available as open-source code, and Java and .NET class libraries, dexijar.jar and DexiDLL.dll.

- [DexiWin](./DexiWin/README.md): A Microsoft Windows desktop program for developing and using DEX models. Essentially, it is a graphic user interface built upon DexiLibrary that supports:

  - Creation and editing of DEXi models and their components: attributes and their structure, value scales, and decision tables;
  
  - Evaluation and analysis of decision alternatives, including what-if analysis,  selective explanation, comparison of alternatives, "plus-minus" analysis, and target analysis;
  
  - Other features: loading, saving, importing and exporting of DEXi models and their components; making and displaying reports and charts; graphic display of model structure.

  Available as open-source code, and as portable (.zip) and .msi installers for MS Windows.

- [DexiEval](./DexiEval/README.md): A command-line utility program for batch evaluation of decision alternatives using a DEXi model. Also build upon DexiLibrary. Available as open-source code, and portable binary installers (.zip, .tgz) for Windows, Java and .NET Core.

Further Information
-------------------

1. DEX method: 

   - Bohanec, M.: [DEX (Decision EXpert): A qualitative hierarchical multi-criteria method](https://link.springer.com/chapter/10.1007/978-981-16-7414-3_3). *Multiple Criteria Decision Making* (ed. Kulkarni, A.J.), Studies in Systems, Decision and Control 407, Singapore: Springer, doi: 10.1007/978-981-16-7414-3_3, 39-78, 2022. 
   - [Wikipedia](https://en.wikipedia.org/wiki/Decision_EXpert)
   - [Documentation](https://dex.ijs.si/documentation/DEX_Method/DEX_Method.html)
  
2. [DEX Software](https://dex.ijs.si/):

   - [DEXi Suite](https://dex.ijs.si/dexisuite/dexisuite.html)
   - [DEXi Classic](https://dex.ijs.si/dexiclassic/dexiclassic.html)
