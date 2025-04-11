DEXiWin
=======

DEXi Decision Modeling Software
-------------------------------

Copyright (C) 2023-2025 Department of Knowledge Technologies, Jožef Stefan Institute

**DEXiWin** is a Microsoft Windows desktop program for developing and using hierarchical qualitative multi-criteria decision models according to the method DEX ([Decision EXpert](https://en.wikipedia.org/wiki/Decision_EXpert)). See *References* below and [DEX Software](https://dex.ijs.si/) for more information.

DEXiWin implements a graphical user interface over the core DEXi modelling library DEXiLibrary. DEXiWin supports the following functionality:

1. Developing DEXi models, i.e., creating and editing DEXi models and their components:
   - Attributes: variables that represent decision subproblems and properties, observed at decision alternatives.
   - Tree of attributes: a hierarchical structure representing the decomposition of the decision problem.
   - Scales: discrete and continuous scales that define admissible values that can be assigned to attributes.
   - Aggregation functions: functions that define the aggregation of attributes from bottom to the top of the tree of attributes.
2. Evaluation and analysis of decision alternatives:
   - Creation and editing of alternatives and their values assigned to individual attributes.
   - Evaluation of alternatives: a bottom up aggregation of alternatives's values in accordance with model structure and defined aggregation functions.
   - Analysis of alternatives: what-if analysis,  selective explanation, comparison of alternatives, "plus-minus" analysis, target analysis.
3. User interface and input/output features:
   - Loading and saving DEXi models in the native XML format (.dxi files);
   - Copying, pasting, importing and exporting DEXi models and their parts in various formats: Json, tab-delimited and CSV (Comma-Separated Value).
   - Reporting: creating, combining, displaying and exporting various reports.
   - Charts: creating and displaying various customizable charts.
   - Tree graphic view: graphic display of model structure.

Motivation and Historical Remarks
---------------------------------

DEXiWin has been developed with the motivation to eventually replace [DEXi](https://kt.ijs.si/MarkoBohanec/dexi.html), a Windows program for multi-attribute decision making. DEXi has been concieved in 1999 as educational software. Since 2000, additional features were gradually added to DEXi, which eventually became a complete, stable, and de facto standard implementation of DEX methodology. After 20 years, DEXi reached the state that is difficult to maintain and improve any more. DEXi is based on an otherwise excellent, but largely outdated technology (Delphi) and has some design flaws that make it difficult to add new features. In particular, the user interface and model operations are insufficiently detached from each other in DEXi. Additionally, user-interface components that were available in 2000 do not fulfill the today's requirements any more. All this called for a thorough renovation of the software. 

DEXiWin has been redesigned and rebuilt from the scratch. It is now composed of two parts, a platform-independent software library DEXiLibrary for handling DEXi models, and DEXiWin itself, which implements a Windows-platform GUI over DEXiLibrary. The GUI is based on [Microsoft WinForms](https://en.wikipedia.org/wiki/Windows_Forms), a mature platform to write desktop applications for PCs. WinFroms, together with an excellent [ObjectListView](https://objectlistview.sourceforge.net/cs/index.html) open-source control by Phillip Piper, allowed us to design a consistent user interface that, at a first glance, looks very similar to DEXi's, but improves on many aspects that were not achievable in DEXi: consistent use of colors in displaying good and bad values, structuring evaluation results, and many more. Reports and charts were thoroughly redesigned, too.

Compatibility
-------------

DEXiWin is backward compatible with [DEXi](https://kt.ijs.si/MarkoBohanec/dexi.html). It implements all DEXi's features, except loading and saving DEXi models in obsolete data formats (.dax and pre-2000 .xml). DEXiWin can read and process .dxi files produced by DEXi. Furthermore, if no new features introduced in DEXiLibrary 2023 have been used, DEXiWin writes .dxi files that are readable by DEXi. After using new features, .dxi files may still be readable by the old DEXi, but new features might be igored. In the future, backward compatibility of DEXiWin with DEXi will be maintained, but the ability of DEXi to process the new .dxi files will likely deteriorate.

In comparison with DEXi, DEXiWin introduces several new features:

- Numerical basic attributes (i.e., input attributes at the terminal nodes of the model structure).
- Discretization functions to discretize numeric inputs to qualitative attribute values of internal nodes.
- Extending the set-based evaluation of alternatives, used in DEXi, to evaluation using probabilistic and fuzzy value distributions.
- Supporting Qualitative-Quantitative (QQ) evaluation for ranking alternatives within qualitative classes.
- Additional features for handling decision rules: considering symmetricity, marginal values, representation using decision trees, graphical interpretation using linear functions, multilinear interpolation and QQ evaluation.
- Extending "Plus-minus-1" to "Plus-Minus-*any_value*" analysis.
- Adding new report types and facilitating a flexible composition of reports.
- Many small, but important improvements in the user inteface, for instance displaying model components in user-selectable columns, tree-structured display/editing of evaluation results, consistent use of colors for displaying "good" and "bad" values, predefined value scales, etc.
- Tree graphic view, which effectively incorporates the functionality of [DEXiTree](https://kt.ijs.si/MarkoBohanec/dexitree.html) in DEXiWin.
- Most user-defined settings are now remembered in .dxi files.

Development
-----------

DEXiWin is written in [RemObjects](https://www.remobjects.com/) [Oxygene](https://www.remobjects.com/elements/oxygene/), a new-generation Object Pascal.
DEXiWin is being developed using [Microsoft Visual Studio, Community Edition](https://visualstudio.microsoft.com/vs/community/), together with [RemObjects Elements](https://www.remobjects.com/elements/). In order to use Elements for software development, a license from RemObjects is required. However, building applications from existing sources is possible by an open-source builder EBuild (https://elementscompiler.com/elements/ebuild.aspx). Please see [Build.bat](./Build.bat) that illustrates how to build binaries from DEXiWin sources.

DEXiWin uses the following external software:
- DEX-modeling library DEXiLibrary (DexiDLL.dll);
- Two external RemObjects libraries (Echoes.dll and Elements.dll);
- ObjectListView UI component (ObjectListView.dll).

Please see [ACKNOWLEDGMENTS.md](./ACKNOWLEDGMENTS.md) for the respective software licenses and other acknowledgements.

Please see [VERSIONS.md](./VERSIONS.md) for the history of DEXiWin releases.

Repository Structure
--------------------

DEXiWin source files are structured in three folders: /WinUtils, /Application and /Forms.

**/WinUtils** is a folder that contains code that adds Windows-platform functionality to some platform-independent components of DEXiLibrary. The aim is to prepare these components for use in forms and other user-interface components of DEXiWin. The source files in /WinUtils typically build upon the same DEXiLibrary namespaces that they extend: DexiUtils or DexiLibrary.

**/Application** contains the main `Program.pas` and two application-level source files: `AppData.pas` (central application data, settings and strings) and `AppUtil.pas` (common utilities). All are defined in namespace DexiWin.

**/Forms** contains all forms (`System.Windows.Forms.Form`) and user controls (`System.Windows.Forms.UserControl`) that constitute the DEXiWin GUI. All are defined in namespace DexiWin.
 
References
----------

1. [Decision EXpert](https://en.wikipedia.org/wiki/Decision_EXpert). Wikipedia.
2. [DEXi: A Program for Multi-Attribute Decision Making](http://kt.ijs.si/MarkoBohanec/dexi.html).
3. Bohanec, M.: [DEXi: Program for Multi-Attribute Decision Making, User’s Manual, Version
5.04](https://kt.ijs.si/MarkoBohanec/pub/DEXiManual504.pdf). IJS Report DP-13100, Jožef Stefan Institute, Ljubljana, 2020.
4. Trdin, N., Bohanec, M.: [Extending the multi-criteria decision making method DEX with
numeric attributes, value distributions and relational models](https://doi.org/10.1007/s10100-017-0468-9). *Central European Journal of Operations Research*, 1-24, 2018.
5. Bohanec, M.: [DEX (Decision EXpert): A qualitative hierarchical multi-criteria method](https://link.springer.com/chapter/10.1007/978-981-16-7414-3_3). *Multiple Criteria Decision Making* (ed. Kulkarni, A.J.), Studies in Systems, Decision and Control 407, Singapore: Springer, doi: 10.1007/978-981-16-7414-3_3, 39-78, 2022. 
