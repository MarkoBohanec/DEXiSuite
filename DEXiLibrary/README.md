DEXiLibrary
===========

DEXi Decision Modeling Software Library
---------------------------------------

Copyright (C) 2023-2025 Marko Bohanec

**DEXiLibrary** is a core software library for developing and using hierarchical qualitative multi-criteria decision models  according to the method DEX (Decision EXpert). See [Wikipedia](https://en.wikipedia.org/wiki/Decision_EXpert), [DEX Method Documentation](https://dex.ijs.si/documentation/DEX_Method/DEX_Method.html), [DEX Software](https://dex.ijs.si/), and other *References* below, for more information about DEX.

The functionality of DEXiLibrary is deliberately restricted to the level that can be easily ported to different platforms. Thus, DEXiLibrary *does not* contain any user interface elements that would, for instance, require system-dependent graphics or depend on any platform-specific GUI framework. Nevertheless, DEXiLibrary provides all the functionality necessary to handle DEXi models and is meant to be included (through code inclusion or dynamic-linking) in applications implementing DEXi user interfaces.

DEXi Models
-----------
Specifically, DEXiLibrary addresses DEX models that are developed by the software [DEXi](https://kt.ijs.si/MarkoBohanec/dexi.html) or [DEXiWin](https://dex.ijs.si/dexisuite/dexiwin.html) (hereafter referred to as *DEXi models*). In general, a DEXi model consists of a hierarchy of qualitative (symbolic linguistic, discrete) variables, called *attributes*. Each attribute represents some observable property (such as Price or Performance) of decision alternatives under study. An attribute can take values from a set of words (such as "low; medium; high" or "unacc; acc; good; exc"), which is usually small (up to five elements) and preferentially ordered from "bad" to "good" values.

The *hierarchy of attributes* represents a decomposition of a decision problem into sub-problems, so that higher-level attributes depend on the lower-level ones. Consequently, the terminal nodes represent inputs, and non-terminal attributes represent the outputs of the model. Among these, the most important are one or more root attributes, which represent the final evaluation(s) of the alternatives.

The *evaluation* of decision alternatives (i.e., hierarchical aggregation of values from model inputs to outputs) is governed by decision rules, defined for each non-terminal attribute by the creator of the model (usually referred to as a "decision maker").

Compatibility
-------------

DEXiLibrary has been developed from the scratch, based on old DEXi Delphi Object Pascal code of the same author, but heavily restructured, renewed and extended. DEXiLibrary is fully backward compatible with DEXi, that is, it can read DEXi models stored in the native `.dxi` format and, unless new features have been used, produces `.dxi` files that are readable by DEXi. DEXiLibrary introduces some new features, including:

- numerical basic attributes (i.e., input attributes at the terminal nodes of the model structure);
- discretization functions to discretize numeric inputs to qualitative attribute values of internal nodes;
- extending the set-based evaluation of alternatives to evaluation using probabilistic and fuzzy value distributions;
- extending some alternative analysis methods;
- adding report types and facilitating a flexible composition of reports.

Had these new features been used, the `.dxi` file can still be read by the current version of [DEXi](https://kt.ijs.si/MarkoBohanec/dexi.html) (v5.06), but most of the new features would be ignored. A new generation of DEXi software, called [DEXi Suite](https://dex.ijs.si/dexisuite/dexisuite.html) is based on this DEXiLibrary and fully supports the new features.

Development
-----------

DEXiLibrary is written in [RemObjects](https://www.remobjects.com/) [Oxygene](https://www.remobjects.com/elements/oxygene/), a new-generation Object Pascal. In addition to being a very powerful, flexible and readable programming language, Oxygene was chosen for its ability to create class libraries from *the same code* for all of today's major platforms. In particular, DEXiLibrary targets the Java and .NET platforms, and makes the respective class libraries, dexijar.jar and DexiDLL.dll. These can be dynamically linked to other software, providing DEX-modelling functionality.

DEXiLibrary is being developed using [Microsoft Visual Studio, Community Edition](https://visualstudio.microsoft.com/vs/community/), together with [RemObjects Elements](https://www.remobjects.com/elements/). In order to use Elements for software development, a license from RemObjects is required. However, building applications from existing sources is possible by an open-source builder [EBuild](https://elementscompiler.com/elements/ebuild.aspx). Please see [Build.bat](./Build.bat) that illustrates how to build binaries from DEXiLibrary sources.

DEXiLibrary uses six external RemObjects libraries, redistributed in this repository with permission: cooper.jar, elements.jar, remobjects.elements.eunit.jar, Echoes.dll, Elements.dll, and RemObjects.Elements.EUnit.dll. Please see [ACKNOWLEDGMENTS.md](./ACKNOWLEDGMENTS.md) for the respective software licenses.

Repository Structure
--------------------

DEXiLibrary source files are structured in two folders, /DexiUtils and /DexiLibrary.

**/DexiUtils** is a folder that contains general-purpose code (under the namespace `DexiUtils`), which is used by /DexiLibrary, but has generally no connection with DEX models. The code could have been used equally well in other projects. The code includes classes for handling strings, arrays, vectors, values, reports, and algorthms for tree drawing, report formatting, solving quadratic optimization problems, platform-independent handling of graphic components and supporting undo/redo functionality.

**/DexiLibrary** defines namespace `DexiLibrary` that provides DEX-specific classes and algorithms. First, there are building blocks that constitute a DEX *model*: *attributes* (performance variables), *scales* of attributes, and aggregation *functions*. Second, there are decision *alternatives* as the main data items being evaluated and analysed by the software. Third, there are algorithms for the *evaluation*, *analysis* and *generation* of alternatives. Finally, there are additional elements addressing *reports*, *importing/exporting* DEXi models and supporting *graphics*.

The next two folders, **/DexiJar** and **/DexiDLL**, contain software projects aimed at producing the two DEXi class libraries for the two platforms, Java and .NET. After compilation, the libraries are located in the corresponding `bin` (sub)folders: `dexijar.jar` for Java and `DEXiDLL.dll` for .NET.

The folder **/TestDexi** contains unit tests. The same code is compiled into platform-specific binaries located in **/TestDexiJava** and **/TestDexiNet**. Folder **/TestData** contains DEXi models and other data used by the unit tests, and folder **/TestOutputs** contains data, written by tests, that is interesting for human inspection or has to be kept between test runs.

References
----------

1. [Decision EXpert](https://en.wikipedia.org/wiki/Decision_EXpert). Wikipedia.
2. [Method DEX](https://dex.ijs.si/documentation/DEX_Method/DEX_Method.html).
3. [DEXi: A Program for Multi-Attribute Decision Making](https://kt.ijs.si/MarkoBohanec/dexi.html).
4. Bohanec, M.: [DEXi: Program for Multi-Attribute Decision Making, User’s Manual, Version
5.04](https://kt.ijs.si/MarkoBohanec/pub/DEXiManual504.pdf). IJS Report DP-13100, Jožef Stefan Institute, Ljubljana, 2020.
5. Bohanec, M.: [ DEXiWin: DEX Decision Modeling Software, User’s Manual, Version 1.2](https://kt.ijs.si/MarkoBohanec/pub/2024_DP14747_DEXiWin.pdf). IJS Report DP-14747, Jožef Stefan Institute, Ljubljana, 2024.
6. Trdin, N., Bohanec, M.: [Extending the multi-criteria decision making method DEX with
numeric attributes, value distributions and relational models](https://doi.org/10.1007/s10100-017-0468-9). *Central European Journal of Operations Research*, 1-24, 2018.
7. Bohanec, M.: [DEX (Decision EXpert): A qualitative hierarchical multi-criteria method](https://link.springer.com/chapter/10.1007/978-981-16-7414-3_3). *Multiple Criteria Decision Making* (ed. Kulkarni, A.J.), Studies in Systems, Decision and Control 407, Singapore: Springer, doi: 10.1007/978-981-16-7414-3_3, 39-78, 2022. 
