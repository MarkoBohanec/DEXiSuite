DEXiEval
========

Command-line utility for batch DEXi evaluation
----------------------------------------------

Copyright (C) 2023-2025 Marko Bohanec

**DEXiEval** is command-line utility program for batch evaluation of decision alternatives using a DEXi model. Basically, DEXiEval reads a DEXi model from a DEXi file and loads alternatives' data from another input file. It evaluates these alternatives and writes the evaluation results to output data files. In one run, DEXiEval can create several output files in different formats.

DEXiEval is a utility program for:

- [DEXi](https://kt.ijs.si/MarkoBohanec/dexi.html), a computer program for qualitative multi-attribute decision modeling;
- [DEXiWin](https://dex.ijs.si/dexisuite/dexiwin.html), DEXi Decision Modeling Software.

Please see [DEX Software](https://dex.ijs.si/) and *References* below for more information about the method DEX and programs DEXi and DEXiWin. Specifically, you may want to find descriptions of concepts that are important for understanding DEXiEval: "DEXi model", "DEXi file", "alternative", and "DEXi/DEXiWin format settings".

Please see [VERSIONS.md](./VERSIONS.md) for the history of DEXiEval releases.

Installation
------------

DEXiEval is distributed in a single archive containing three portable binaries that run in different operating systems and/or platforms: Windows, Java and .NET Core (NetCore). Unpack the archive to a folder of your choice and run DEXiEval from there.

Running the Java version requires [Java Runtime Environment (JRE)](https://www.java.com/en/download/manual.jsp) version 8 or later installed on your system.

To run the NetCore version of DEXiEval, [.NET 7.0](https://dotnet.microsoft.com/en-us/download/dotnet/7.0) (.NET Desktop Runtime or ASP.NET Core Runtime), must be installed on your system.

Usage
-----

DEXiEval is invoked from a command line using the commands:

- Windows: `DEXiEval.exe Program_arguments`
- Java: `java -jar dexieval.jar Program_arguments`
- .NET Core: `dotnet DEXiEval.dll Program_arguments`

In all environments, `Program_arguments` have the following general form:

`[-p ...] DEXi-file [-p ...] inp-file [ [-p ...] out-file ...]`

Files:
- `DEXi-file`: input file containing a DEXi model (required, default extension `.dxi`)
- `inp-file`: input file containing alternatives (required, except with `-save`)
- `out-file`:  zero or more output files to contain evaluation results

The following parameters can occur anywhere in the command line and affect the whole DEXiEval run.

General parameters:
- `-?`, `-help`: display help information
- `-l`, `-log`, `-verbose`: display detailed file-processing information
- `-license`: display license information
- `-save`, `-dxi`: do not load `inp-file`, use alternatives stored in `DEXi-file`
- `-keep`: keep `DEXi-file` alternatives, then overload with `inp-file`

Evaluation settings:
- `-es` or `-set`: set-based evaluation
- `-ep` or `-prob`: probabilistic evaluation
- `-ef` or `-fuzzy`: fuzzy evaluation
- `-efn` or `-fuzzynorm`: normalized fuzzy evaluation
- `-e0` or `-noexpand`: do not modify undefined and empty values
- `-eu` or `-undefined`: expand undefined values to full sets
- `-ee` or `-empty`: expand empty values to full sets
- `-ex` or `-expand`: expand undefined and empty values to full sets
- `-qqold` or `-qq1`: old-style qualitative-quantitative evaluation (deprecated)
- `-qq` or `-qq2`: qualitative-quantitative evaluation using QP optimization
- `-q0`: do not perform qualitative-quantitative evaluation

Other parameters `-p` are interpreted in the left-to-right order.

File format parameters:
- `-tab`: use tab-delimited format (default for `*.tab` files)
- `-csv`: use comma-separated format (default for `*.csv` files)
- `-json`: use Json format (default at the beginning and for `*.json` files)
- `-un` or `-name`: refer to attributes by names (default, but possibly ambiguous)
- `-ui` or `-id`: refer to attributes by Id tags (unambiguous)
- `-up` or `-path`: refer to attributes by name paths (almost unambiguous, but verbose)
- `-v0` or `-base0`: use "base 0" value format
- `-v1` or `-base1`: use "base 1" value format
- `-vt` or `-text`: use "text" value format
- `-vs` or `-strings`: use DEXi strings to represent attribute values
- `-aa` or `-all`: write out all attributes
- `-ab` or `-basic`: write out only basic attributes
- `-dn`: use `n` decimal places to display floating-point numbers; the range of `n` is from -1 (default) to 10
- `-mn`: use `n` decimal places to display value distributions; the range of `n` is from -1 (default) to 10
- `-r` or `-reset`: reset all format parameters to that defined in `DEXi-file`
- `-x` or `-rx`: reset an individual format parameter, where `x` can be: `u`: attribute reference, `v`: value format, `a`: attribute, `i`: indent, `o`: orientation, `c`: CSV format, `j`: Json format

Valid for tables (`-tab`, `-csv`):
- `-ii` or `-indent`: indent attributes according to their tree structure
- `-in` or `-noindent`: do not indent attributes
- `-on` or `-normal`: use normal data-table orientation (attributes \ alternatives)
- `-ot` or `-transpose`: use transposed orientation (alternatives \ attributes)
 
CSV only:
- `-ci` or `-invariant`: invariant (international) format: using "`.`" for decimal point and "`,`" to separate data fields
- `-cl` or `-local`: local-culture format: may use "`,`" for decimal comma and "`;`" for data field separation
 
Json only:
- `-jf` or `-flat`: flat format: attribute-related data is written in a single Json array
- `-jr` or `-recursive`: recursive (nested) format: attribute-related data is structured according to the DEXi-model tree structure (`-a*` is ignored with `-recursive`)
- `-ji`: generate an indented (user-readable) Json file (default)
- `-jc` or `-compact`: generate a compact (computer-friendly) Json file

Json is a rich format, thus `-id`, `-path` and `-name` accumulate. Use `-rj` to reset.
Also in Json, `-vs` can be combined with one of `-v0`, `-v1` or `-vt`. Use `-rv` to reset.


DEXiEval Operation
------------------

In addition to a DEXi model (composed of a hierarchy of attributes, scales and aggregation functions), a `DEXi-file` additionally contains:

1. data of zero or more decision alternatives stored in the DEXi/DEXiWin program itself
2. data formatting parameters, as defined:
   - in DEXi with `File/Settings.../"Import/Export"`, or
   - in DEXiWin with `File/Preferences.../"Import/Export"` and `File/Preferences.../Json`

By default, 1. is erased by DEXiEval after loading a `DEXi-file` and only
alternatives from `inp-file` are taken into account. There are two exceptions:

- When you specify `-save` or `-dxi`, then 1. is retained and `inp-file` is not loaded at all (in this case, it *must not* be specified in the command line).
- Specifying `-keep` means that 1. is retained but overloaded with data from `inp-file`. *Overloading* means that alternatives from `inp-file` are *added* to those prevously stored in `DEXi-file`, except in the case of *equal alternatives' names*. In that case, equally-named alternatives are removed from `DEXi-file` and replaced with those from `inp-file`.

The formatting data 2. provides defaults for DEXiEval. This means that when no formatting parameters are specified in the command line, DEXiEval uses the formatting settings as defined in the `DEXi-file`. Whenever a  `-reset` or `-r*` parameter is specified in the command line, DEXiEval reverts to `DEXi-file` settings.

Files containing data about alternatives come in three different basic formats: comma-separated (CSV), tab-delimited (TAB) and JavaScript Object Notation (Json). 
The default is Json, except when the format can be determined from the file's extension. Namely, for `inp-files` and `out-files` whose filename extensions are given explicitly (`.csv`, `.tab`, or `.json`), DEXiEval assumes they are of the respective format. For files with other extensions, their format can be explicitly specified beforehand using `-csv`, `-tab` or `-json`.


Examples
--------

`DEXiEval Car.dxi -save Cars`

Load `DEXi-file` `Car.dxi`, evaluate alternatives (cars) contained in it and save the evaluation results to `out-file` `Cars.json`. Cars is written in the default Json format, using format settings as specified in `Car.dxi`.


`DEXiEval -save Car.dxi Cars.tab`

As above, but write to `out-file` `Cars.tab`, implicitly assuming the TAB
format.


`DEXiEval Car.dxi -dxi -tab Cars.dat`

As above, but write to `out-file` `Cars.dat` using the TAB format.


`DEXiEval Car.dxi CarsData CarsOut`

Typical use. Load `Car.dxi` model and alternative data from `CarsData.json`, evaluate alternatives and save the results to `CarsOut.json`.


`DEXiEval Car.dxi Cars.tab Cars.csv`

Evaluate alternatives from `Cars.tab` and write the results to `Cars.csv`. An implicit conversion from TAB to CSV format takes place.


`DEXiEval Car.dxi Cars.csv -base0 -basic -csv C.dat -text -all -indent -tab C.txt`

Load alternatives from `Cars.csv`, evaluate them by the `Car.dxi` model and save the results on two output files, `C.dat` and `C.txt`, using different formats. `C.dat` is quite criptic: CSV format, containing only data of basic attributes, represented with "base_0" numerical values. The file `C.txt`, on the other hand, might be used as a report, as it is written using TABs, contains data of all attributes, which are represented by "text" values and indented for better readability.


`DEXiEval Car.dxi CarsData CarsOut` -fuzzy -noexpand

Modifying evaluation settings. Load `Car.dxi` model and alternative data from `CarsData.json`, evaluate alternatives and save the results to `CarsOut.json`. Use the "fuzzy" evaluation algorithm and do not expand empty and undefined values, if any, to full value sets before evaluation.


References
----------

1. [Decision EXpert](https://en.wikipedia.org/wiki/Decision_EXpert). Wikipedia.
2. [DEXi: A Program for Multi-Attribute Decision Making](https://kt.ijs.si/MarkoBohanec/dexi.html).
3. Bohanec, M.: [DEXi: Program for Multi-Attribute Decision Making, User’s Manual, Version
5.04](https://kt.ijs.si/MarkoBohanec/pub/DEXiManual504.pdf). IJS Report DP-13100, Jožef Stefan Institute, Ljubljana, 2020.
4. Bohanec, M.: [ DEXiWin: DEX Decision Modeling Software, User’s Manual, Version 1.2](https://kt.ijs.si/MarkoBohanec/pub/2024_DP14747_DEXiWin.pdf). IJS Report DP-14747, Jožef Stefan Institute, Ljubljana, 2024.
5. Trdin, N., Bohanec, M.: [Extending the multi-criteria decision making method DEX with
numeric attributes, value distributions and relational models](https://doi.org/10.1007/s10100-017-0468-9). *Central European Journal of Operations Research*, 1-24, 2018.
6. Bohanec, M.: [DEX (Decision EXpert): A qualitative hierarchical multi-criteria method](https://link.springer.com/chapter/10.1007/978-981-16-7414-3_3). *Multiple Criteria Decision Making* (ed. Kulkarni, A.J.), Studies in Systems, Decision and Control 407, Singapore: Springer, doi: 10.1007/978-981-16-7414-3_3, 39-78, 2022. 
