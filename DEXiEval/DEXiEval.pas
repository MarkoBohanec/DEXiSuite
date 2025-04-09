// DEXiEval.pas is part of
//
// DEXiEval: Command-line utility for batch DEXi evaluation
//
// Copyright (C) 2023-2025 Marko Bohanec
//
// DEXiEval is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// DEXiEval.pas implements the main entry point and functionality of the DEXiEval application.
// ----------

namespace DEXiEval;

uses
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

type
  FilePath = RemObjects.Elements.RTL.Path;
  EDexiEvalError = public class (EDexiError);

type
  OperationMode = public enum (Save, Dxi, Keep);
  FileFormat = public enum (Tab, Csv, Json);
  OffEvaluationType = public enum (None, QQ1, QQ2);

type
  GeneralSettings = public class
  public
    property Help: Boolean := false;
    property Verbose: Boolean := false;
    property License: Boolean := false;
    property Save: Boolean := false;
    property Keep: Boolean := false;
    property EvalType: EvaluationType := EvaluationType.Custom;
    property OffEvalType: OffEvaluationType := OffEvaluationType.None;
    property UndefExpand: nullable Boolean := nil;
    property EmptyExpand: nullable Boolean := nil;
  end;

type
  DEXiEval = static class
  private
    fParameters: ParameterDefinitions;
    fArguments: ProgramArguments;
    fModel: DexiModel;
    fGeneral: GeneralSettings;
    fCurrentSettings: DexiSettings;
    fFileFormat: FileFormat;
    fErrors := new List<String>;
    fOutputCount := 0;
  protected
    RunVersion := '';
    const SoftwareName = 'DEXiEval';
    const SoftwareVersion = '1.2';
    const LicenseSummary =
      SoftwareName + ' is free software that comes with ABSOLUTELY NO WARRANTY;' + Environment.LineBreak +
                     'see ' + SoftwareName + ' -license for details.';
    method AddError(aMsg: String);
    method AddJsonElement(aElement: DexiJsonAttributeElement);
    method SetExpand(aUndef, aEmpty: Boolean);
  public
    method SoftwareInfo(aCopyright: Boolean := true): String;
    class method FileFormatString(aFormat: FileFormat): String;
    method FileFormatOf(aFileName: String): FileFormat;
    method MakeExtension(aFileName: String): String;
    method ModelInfo: String;
    method SettingsInfo(aSettings: DexiSettings; aGeneralSettings: GeneralSettings := nil): String;
    method UsageString: String;
    method Usage;
    method LicenseString: String;
    method License;
    method Errors(aErrors: List<String> := nil): Boolean;
    method DefineParameters;
    method ParseArguments(args: array of String);
    method ListArguments;
    method ProcessGeneralSettings;
    method CheckParameters;
    method LoadDexiModel;
    method InitSettings;
    method SettingsToJson(aSettings: DexiSettings := nil);
    method EvaluateOffsets;
    method PrepareDexiModel;
    method LoadJson(aFileName: String);
    method LoadTabular(aFileName: String; aFormat: FileFormat);
    method LoadAlternatives;
    method SaveToFile(aFileName: String);
    method ResetSettings(aPar: String);
    method InterpretArguments;
    method Run(args: array of String; aVersion: String): Int32;
    property Help: Boolean read fGeneral.Help;
    property ShowLicense: Boolean read fGeneral.License;
    property Verbose: Boolean read fGeneral.Verbose;
    property Keep: Boolean read fGeneral.Keep;
    property Save: Boolean read fGeneral.Save;
    property ErrorStatus: Boolean read fErrors.Count > 0;
  end;

implementation

method DEXiEval.SoftwareInfo(aCopyright: Boolean := true): String;
begin
  result := $'{SoftwareName} {RunVersion} {SoftwareVersion}, powered by {DexiLibrary.LibraryString}';
  if aCopyright then
    result := result + Environment.LineBreak + 'Copyright (C) ' + DexiLibrary.Copyright;
end;

class method DEXiEVal.FileFormatString(aFormat: FileFormat): String;
begin
  result :=
    case aFormat of
      FileFormat.Csv: 'csv';
      FileFormat.Tab: 'tab';
      FileFormat.Json: 'json';
    end;
end;

method DEXiEVal.FileFormatOf(aFileName: String): FileFormat;
begin
  var lExt := Utils.FileExtension(aFileName).ToLower;
  result :=
   if lExt = '.json' then FileFormat.Json
   else if lExt = '.csv' then FileFormat.Csv
   else if lExt = '.tab' then FileFormat.Tab
   else fFileFormat;
end;

method DEXiEVal.MakeExtension(aFileName: String): String;
begin
  result := aFileName;
  var lExt := Utils.FileExtension(aFileName);
  if String.IsNullOrEmpty(lExt) then
    begin
      lExt :=
        case FileFormatOf(aFileName) of
          FileFormat.Json: '.json';
          FileFormat.Tab: '.tab';
          FileFormat.Csv: '.csv';
          else '';
        end;
      result := result + lExt;
     end;
end;

method DEXiEval.ModelInfo: String;
begin
  with lStat := fModel.Statistics do
    result := String.Format('Attributes {0} ({2} basic, {3} aggregate, {4} linked), Alternatives {1}',
      lStat.Attributes, lStat.Alternatives, lStat.BasicAttributes, lStat.AggregateAttributes, lStat.LinkedAttributes);
end;

method DEXiEval.SettingsInfo(aSettings: DexiSettings; aGeneralSettings: GeneralSettings := nil): String;
begin
  var lEval :=
    case aSettings.EvalType of
      EvaluationType.AsSet: 'set';
      EvaluationType.AsProb: 'prob';
      EvaluationType.AsFuzzy: 'fuzzy';
      EvaluationType.AsFuzzyNorm: 'fuzzynorm';
      else '';
    end;
  if not String.IsNullOrEmpty(lEval) then
    lEval := '-' + lEval + ' ';
  var lQEval :=
    if aGeneralSettings = nil then ''
    else
      case aGeneralSettings.OffEvalType of
        OffEvaluationType.QQ2: 'qq2';
        OffEvaluationType.QQ1: 'qq1';
        else '';
      end;
  if not String.IsNullOrEmpty(lQEval) then
    lQEval := '-' + lQEval + ' ';
  var lExpand :=
    if aSettings.ExpandUndef then
      if aSettings.ExpandEmpty then 'expand'
      else 'undefined'
    else
      if aSettings.ExpandEmpty then 'empty'
      else 'noexpand';
  var lStrType :=
    if aSettings.UseDexiStringValues then 'strings'
    else
      case aSettings.ValueType of
        ValueStringType.Zero: 'base0';
        ValueStringType.One: 'base1';
        ValueStringType.Text: 'text';
        else 'unknown';
      end;
  var lData :=
    if aSettings.AltDataAll then 'all'
    else 'basic';
  var lTranspose :=
    if aSettings.AltTranspose then 'transpose'
    else 'normal';
  var lIndent :=
    if aSettings.AltLevels then 'indent'
    else 'noindent';
  var lCsv :=
    if aSettings.CsvInvariant then 'invariant'
    else 'local';
  var lAttId :=
    case aSettings.AttId of
      AttributeIdentification.Name: 'name';
      AttributeIdentification.Id: 'id';
      AttributeIdentification.Path: 'path';
      else 'unknown';
    end;
  var lStruct :=
    if aSettings:JsonSettings:StructureFormat = nil then 'flat'
    else if DexiJsonStructureFormat(aSettings.JsonSettings.StructureFormat) = DexiJsonStructureFormat.Flat then 'flat'
    else 'recursive';
  var lJsonFormat :=
    if aSettings:JsonSettings:JsonIndent then 'ji'
    else 'compact';
  var lFltDec := 'd' + Utils.IntToStr(aSettings.FltDecimals);
  var lMemDec := 'm' + Utils.IntToStr(aSettings.MemDecimals);
  result :=
    $"{lEval}{lQEval}-{lExpand} -{lStrType} -{lData} -{lTranspose} -{lIndent} -{lCsv} -{lAttId} -{lStruct} -{lJsonFormat} -{lFltDec} -{lMemDec}";
end;

method DEXiEval.UsageString: String;
begin
  result := "
Program arguments: [-p ...] DEXi-file [-p ...] inp-file [ [-p ...] out-file ...]

Files:
 DEXi-file: input file containing a DEXi model (required, default ext .dxi)
 inp-file:  input file containing alternatives (required, except with -save)
 out-file:  zero or more output files to contain evaluation results

General parameters:
 -?, -help           display this help
 -l, -log, -verbose  display detailed file-processing information
 -license            display license information
 -save, -dxi         do not load inp-file, use alternatives in DEXi-file
 -keep               keep DEXi-file alternatives, then overload with inp-file

Evaluation settings:
 -es or -set         set-based evaluation
 -ep or -prob        probabilistic evaluation
 -ef or -fuzzy       fuzzy evaluation
 -efn or -fuzzynorm  normalized fuzzy evaluation
 -e0 or -noexpand    do not modify undefined and empty values
 -eu or -undefined   expand undefined values to full sets
 -ee or -empty       expand empty values to full sets
 -ex or -expand      expand undefined and empty values to full sets
 -qq or -qq2         qualitative-quantitative evaluation using QP optimization
 -qqold or -qq1      old-style qualitative-quantitative evaluation (deprecated)
 -q0                 do not perform qualitative-quantitative evaluation

Other parameters -p are interpreted in left-to-right order.

File format parameters:
 -tab                use tab-delimited format (default for *.tab files)
 -csv                use comma-separated format (default for *.csv files)
 -json               Json format (default at start and for *.json files)
 -un or -name        refer to attributes by names (default, possibly ambiguous)
 -ui or -id          refer to attributes by Id tags (unambiguous)
 -up or -path        refer to attributes by name paths (almost safe, verbose)
 -v0 or -base0       use ""base 0"" value format
 -v1 or -base1       use ""base 1"" value format
 -vt or -text        use ""text"" value format
 -vs or -strings     use DEXi strings to represent attribute values
 -aa or -all         save all attributes
 -ab or -basic       save only basic attributes
 -dn                 use ""n"" decimal places to display floating-point numbers
 -mn                 use ""n"" decimal places to display distributions
                     the range for ""n"" is -1 (default) to 10
 -r or -reset        reset all format parameters to that defined in DEXi-file
 -x or -rx           reset an individual format parameter, where ""x"" can be:
                     u: attribute reference, v: value format, a: attribute,
                     i: indent, o: orientation, c: CSV format, j: Json format

Valid for tables (tab, csv):
 -ii or -indent:     indent attributes according to their tree structure
 -in or -noindent:   do not indent attributes
 -on or -normal:     use normal data-table orientation (attributes \ options)
 -ot or -transpose:  use transposed orientation (options \ attributes)
 
Csv only:
 -ci or -invariant   invariant (international) format
 -cl or -local       local-culture format
 
Json only:
 -jf or -flat        flat format
 -jr or -recursive   recursive (nested) format; -a* does not affect this format
 -ji                 generate an indented (user-friendly) Json file (default)
 -jc or -compact     generate a compact (computer-friendly) Json file

Json is a rich format, thus -id, -path and -name accumulate. Use -rj to reset.
In Json, -vs can be combined with one of -v0, -v1 or -vt. Use -rv to reset.
";
end;

method DEXiEVal.Usage;
begin
  writeLn(UsageString);
end;

method DEXiEval.LicenseString: String;
begin
  result := "
LICENSE

DEXiEval: Command-line utility for batch DEXi evaluation
Copyright (C) " + DexiLibrary.Copyright + "

DEXiEval is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

DEXiEval is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/gpl-3.0.en.html>.

DEXiEval uses third-party open-source software. Please see
ACKNOWLEDGMENTS.md for the list and respective licenses.

If you wish to use DEXiEval in a commercial, closed-source or non-GNU-GPL
application, please contact marko.bohanec@ijs.si.
";
end;

method DEXiEVal.License;
begin
  writeLn(LicenseString);
end;

method DEXiEVal.AddJsonElement(aElement: DexiJsonAttributeElement);
begin
  fCurrentSettings.JsonSettings.AlternativeElements :=
    Utils.AddFlag(fCurrentSettings.JsonSettings.AlternativeElements, Integer(aElement));
end;

method DEXiEval.AddError(aMsg: String);
begin
  fErrors.Add(aMsg);
end;

method DEXiEVal.Errors(aErrors: List<String> := nil): Boolean;
begin
  if aErrors = nil then
    aErrors := fErrors;
  if (aErrors = nil) or (aErrors.Count = 0) then
    exit false;
  result := true;
  for each msg in aErrors do
    writeLn($'Error: {msg}');
  aErrors.RemoveAll;
  writeLn;
  writeLn($'For help, run {SoftwareName} -help or -?');
end;

method DEXiEval.DefineParameters;
begin
  fParameters := new ParameterDefinitions;
  fParameters.AddNoArgParameters([
    '?', 'help', 'l', 'log', 'verbose', 'license', 'save', 'dxi', 'keep'
  ], false);
  fParameters.AddNoArgParameters([
    'tab', 'csv', 'json',
    'un', 'name', 'ui', 'id', 'up', 'path',
    'v0', 'base0', 'v1', 'base1', 'vt', 'text', 'vs', 'strings',
    'aa', 'all', '', 'ab', 'basic',
    'reset', 'u', 'v', 'a', 'i', 'o', 'c', 'j',
    'ii', 'indent', 'in', 'noindent', 'i+', 'i-',
    'on', 'normal', 'ot', 'transpose', 'transposed',
    'ci', 'invariant', 'cl', 'local',
    'jf', 'flat', 'jr', 'recursive', 'nested', 'ji', 'jc', 'compact',
  ], true);
  fParameters.AddNoArgParameters([
    'es', 'set', 'ep', 'prob', 'ef', 'fuzzy', 'efn', 'fuzzynorm',
    'e0', 'noexpand', 'eu', 'undefined', 'ee', 'empty', 'ex', 'expand',
    'q0', 'qq', 'qq2', 'qqold', 'qq1'
  ], false);
  fParameters.AddParameter(new ParameterDefinition('r', ParameterType.StringArg, ArgumentType.Optional));
  fParameters
    .AddParameter(new ParameterDefinition('d', ParameterType.NumArg, ArgumentType.Optional))
    .SetRange(-1, -1, 10);
  fParameters
    .AddParameter(new ParameterDefinition('m', ParameterType.NumArg, ArgumentType.Optional))
    .SetRange(-1, -1, 10);
end;

method DEXiEVal.ParseArguments(args: array of String);
begin
  fArguments := new ProgramArguments;
  var lErrors := fArguments.Parse(args, fParameters);
  fErrors.Add(lErrors);
end;

method DEXiEVal.ListArguments;
begin
  writeln('Program arguments:');
  for each lArg in fArguments.Arguments do
    begin
      var lPositional := fArguments.PositionalArguments.Contains(lArg);
      var lGeneral := fArguments.GeneralArguments.Contains(lArg);
      var lStr :=
        if lArg.Id = nil then 'file'
        else lArg.Id;
      if lArg.StringValue <> nil then
        lStr := lStr + $' : {lArg.StringValue}';
      if lArg.IntegerValue <> nil then
        lStr := lStr + $' = {lArg.IntegerValue}';
      if lPositional then
        lStr := lStr + ' [positional]';
      if lGeneral then
        lStr := lStr + ' [general]';
      writeLn(lStr);
    end;
end;

method DEXiEVal.SetExpand(aUndef, aEmpty: Boolean);
begin
  fGeneral.UndefExpand := aUndef;
  fGeneral.EmptyExpand := aEmpty;
end;

method DEXiEVal.ProcessGeneralSettings;
begin
  fGeneral := new GeneralSettings;
  for each lArg in fArguments.GeneralArguments do
    case lArg.Id of
      '?', 'help':           fGeneral.Help := true;
      'l', 'log', 'verbose': fGeneral.Verbose := true;
      'license':             fGeneral.License := true;
      'save', 'dxi':         fGeneral.Save := true;
      'keep':                fGeneral.Keep := true;
      'es', 'set':           fGeneral.EvalType := EvaluationType.AsSet;
      'ep', 'prob':          fGeneral.EvalType := EvaluationType.AsProb;
      'ef', 'fuzzy':         fGeneral.EvalType := EvaluationType.AsFuzzy;
      'efn', 'fuzzynorm':    fGeneral.EvalType := EvaluationType.AsFuzzyNorm;
      'q0':                  fGeneral.OffEvalType := OffEvaluationType.None;
      'qq', 'qq2':           fGeneral.OffEvalType := OffEvaluationType.QQ2;
      'qqold', 'qq1':        fGeneral.OffEvalType := OffEvaluationType.QQ1;
      'e0', 'noexpand':      SetExpand(false, false);
      'ex', 'expand':        SetExpand(true, true);
      'eu', 'undefined':     SetExpand(true, false);
      'ee', 'empty':         SetExpand(false, true);
      else AddError($'Unexpected general parameter: {lArg.Id}');
    end;
  if Verbose then
    begin
      writeLn(LicenseSummary);
      writeLn;
    end;
  if Verbose and Save then
    writeLn('Save mode');
  if Verbose and Keep then
    writeLn('Keep mode');
end;

method DEXiEVal.CheckParameters;
begin
  with lCount := fArguments.Files.Count do
    if lCount < 1 then
      AddError('Input file required: DEXi-file')
    else if (not Save) and (lCount < 2) then
      AddError('Input file required: data about decision alternatives');
end;

method DEXiEVal.LoadDexiModel;
begin
  var lModelName := fArguments.Files[0];
  var lModelFile := FilePath.GetFullPath(lModelName);
  var lExt := Utils.FileExtension(lModelName);
  if lExt = '' then
    lModelFile := lModelFile + '.dxi';
  if Verbose then
    writeLn($'DEXi file: {lModelFile}');
  if not File.Exists(lModelFile) then
    AddError($"DEXi file {lModelFile} not found")
  else
    begin
      fModel := new DexiModel;
      fModel.LoadFromFile(lModelFile);
      if Verbose then
        begin
          writeLn($'DEXi model loaded: {lModelFile} [created {fModel.Created}]');
          writeLn(ModelInfo);
        end;
    end;
end;

method DEXiEVal.InitSettings;
begin
  fModel.Settings.EvalType := fGeneral.EvalType;
  if assigned(fGeneral.UndefExpand) then
    fModel.Settings.ExpandUndef := fGeneral.UndefExpand;
  if assigned(fGeneral.EmptyExpand) then
    fModel.Settings.ExpandEmpty := fGeneral.EmptyExpand;
  if fModel.Settings.JsonSettings = nil then
    begin
      fModel.Settings.JsonSettings := new DexiJsonSettings;
      fModel.Settings.JsonSettings.SetDefaults;
      SettingsToJson(fModel.Settings);
    end;
  fModel.Settings.JsonSettings.IncludeModel := false;
  fModel.Settings.JsonSettings.IncludeAlternatives := true;
end;

method DEXiEVal.SettingsToJson(aSettings: DexiSettings := nil);
begin
  if aSettings = nil then
    aSettings := fCurrentSettings;
  var lElements := new List<DexiJsonAttributeElement>;
  if aSettings.AttId = AttributeIdentification.Name then
    lElements.Add(DexiJsonAttributeElement.Name)
  else if aSettings.AttId = AttributeIdentification.Id then
    lElements.Add(DexiJsonAttributeElement.Id)
  else if aSettings.AttId = AttributeIdentification.Path then
    lElements.Add(DexiJsonAttributeElement.Path);
  if aSettings.UseDexiStringValues then 
    lElements.Add(DexiJsonAttributeElement.AsString)
  else
    lElements.Add(DexiJsonAttributeElement.AsValue);
  if fGeneral.OffEvalType <> OffEvaluationType.None then
    lElements.Add(DexiJsonAttributeElement.AsOffsets);
  aSettings.JsonSettings.AlternativeElements := DexiJsonSettings.SetElements(lElements);
  aSettings.JsonSettings.UseDexiStringValues := aSettings.UseDexiStringValues;
  {$IFDEF JAVA}
  aSettings.JsonSettings.ValueFormat := Integer(aSettings.ValueType);
  {$ELSE}
  aSettings.JsonSettings.ValueFormat := aSettings.ValueType;
  {$ENDIF}
  aSettings.JsonSettings.AttributeTypes := Integer(DexiJsonAttributeType.Basic);
  if aSettings.AltDataAll then
    aSettings.JsonSettings.AttributeTypes :=
      Utils.AddFlag(aSettings.JsonSettings.AttributeTypes, Integer(DexiJsonAttributeType.Aggregate));
end;

method DEXiEVal.EvaluateOffsets;
begin
  fModel.OffAlternatives :=
    if (fModel.AltCount = 0) or (fGeneral.OffEvalType = OffEvaluationType.None) then nil
    else fModel.EvaluateWithOffsets(fGeneral.OffEvalType = OffEvaluationType.QQ2);
  var lCount := Utils.ListCount(fModel.OffAlternatives);
  if Verbose and (lCount > 0) then
    writeLn($'Evaluated {lCount} alternatives using the {if fGeneral.OffEvalType = OffEvaluationType.QQ2 then 'QQ2' else 'QQold'} method')
end;

method DEXiEVal.PrepareDexiModel;
begin
  InitSettings;
  if Verbose then
    writeLn($'Model settings: {SettingsInfo(fModel.Settings)}');
  if (fModel.AltCount > 0) and not (Keep or Save) then //xxx
    begin
      while fModel.AltCount > 0 do
        fModel.DeleteAlternative(0);
      if Verbose then
        writeLn('Existing alternatives deleted from the model');
    end;
  EvaluateOffsets;
end;

method DEXiEVal.LoadJson(aFileName: String);
begin
  var lJsonReader := new DexiJsonReader;
  var lRead := lJsonReader.LoadAlternativesFromFile(aFileName, fModel);
  if lRead.Success then
    begin
      if lRead.Warnings.Count > 0 then
        for each lWarning in lRead.Warnings do
          writeLn($'Warning: {lWarning}');
      var lAlternatives := lRead.Alternatives;
      if Verbose then
        writeLn($'Loaded {lAlternatives.AltCount} alternatives');
      fModel.AddAlternatives(lAlternatives, true);
      fModel.Evaluate;
    end
  else
    fErrors.Add(lRead.Errors);
end;

method DEXiEVal.LoadTabular(aFileName: String; aFormat: FileFormat);
begin
  var lTable := new DexiAlternativesTable(fModel);
  lTable.Settings := fCurrentSettings;
  if aFormat = FileFormat.Csv then
    lTable.LoadFromCSVFile(aFileName, fModel)
  else
    lTable.LoadFromTabFile(aFileName, fModel);
  if Verbose then
    writeLn($'Loaded {lTable.AltCount} alternatives');
  var lUnmatched := lTable.UnmatchedAttributes;
  if not String.IsNullOrEmpty(lUnmatched) then
    writeLn($'Warning: Unmatched attributes: {lUnmatched}');
  lTable.SaveToModel;
end;

method DEXiEVal.LoadAlternatives;
begin
  if Save then
    exit;
  var lDataName := fArguments.Files[1];
  var lDataFile := FilePath.GetFullPath(MakeExtension(lDataName));
  var lFileFormat := FileFormatOf(lDataFile);
  if Verbose then
    begin
      writeLn($'Loading data from {lDataFile} using -{FileFormatString(lFileFormat)} format');
      writeln($'Using settings: {SettingsInfo(fCurrentSettings)}');
    end;
  if not File.Exists(lDataFile) then
    AddError($"Data file {lDataFile} not found")
  else
    begin
      if lFileFormat = FileFormat.Json then
        LoadJson(lDataFile)
      else
        LoadTabular(lDataFile, lFileFormat);
      if Verbose then
        writeLn($'Evaluated {fModel.AltCount} alternatives');
      EvaluateOffsets;
    end;
end;

method DEXiEVal.SaveToFile(aFileName: String);
begin
  var lOutFile := FilePath.GetFullPath(MakeExtension(aFileName));
  var lFileFormat := FileFormatOf(lOutFile);
  if Verbose then
    begin
      writeLn($'Writing data to {lOutFile} using -{FileFormatString(lFileFormat)} format');
      writeln($'Using settings: {SettingsInfo(fCurrentSettings, fGeneral)}');
    end;
  if lFileFormat = FileFormat.Json then
    begin
      fModel.SaveToJsonFile(lOutFile, fCurrentSettings.JsonSettings);
      inc(fOutputCount);
    end
  else 
    begin
      var lTable := new DexiOffAlternativesTable(fModel);
      lTable.Settings := fCurrentSettings;
      lTable.LoadFromModel(fModel);
      if fFileFormat = FileFormat.Csv then
        lTable.SaveToCSVFile(lOutFile)
      else
        lTable.SaveToTabFile(lOutFile);
      inc(fOutputCount);
    end;
  if Verbose then
    writeLn('Written');
end;

method DEXiEval.ResetSettings(aPar: String);
begin
  if String.IsNullOrEmpty(aPar) then
    fCurrentSettings.Assign(fModel.Settings)
  else
    case aPar.ToLower of
      'u': fCurrentSettings.AttId := fModel.Settings.AttId;
      'v': fCurrentSettings.ValueType := fModel.Settings.ValueType;
      'a': fCurrentSettings.AltDataAll := fModel.Settings.AltDataAll;
      'i': fCurrentSettings.AltLevels := fModel.Settings.AltLevels;
      'o': fCurrentSettings.AltTranspose := fModel.Settings.AltTranspose;
      'c': fCurrentSettings.CsvInvariant := fModel.Settings.CsvInvariant;
      'j':
        begin
          fCurrentSettings.JsonSettings.StructureFormat := fModel.Settings.JsonSettings.StructureFormat;
          fCurrentSettings.JsonSettings.JsonIndent := fModel.Settings.JsonSettings.JsonIndent;
        end;
      else
        raise new EDexiEvalError($'Unexpected reset parameter "{aPar}"');
    end;
  SettingsToJson;
end;

method DEXiEVal.InterpretArguments;
begin
  fCurrentSettings := new DexiSettings(fModel.Settings);
  fFileFormat := FileFormat.Json;
  var lDexiFile := true;
  var lDataFile := not Save;
  for each lArg in fArguments.PositionalArguments do
    if lArg.Id = nil then // file
      if lDexiFile then // skip first file argument
        lDexiFile := false
      else if lDataFile then
        begin
          lDataFile := false;
          LoadAlternatives;
          if ErrorStatus then
            exit;
        end
      else
        begin
          SaveToFile(lArg.StringValue);
          if ErrorStatus then
            exit;
        end
    else
      case lArg.Id of
        'json': fFileFormat := FileFormat.Json;
        'tab': fFileFormat := FileFormat.Tab;
        'csv': fFileFormat := FileFormat.Csv;
        'un', 'name':
          begin
            fCurrentSettings.AttId := AttributeIdentification.Name;
            AddJsonElement(DexiJsonAttributeElement.Name);
          end;
        'ui', 'id':
          begin
            fCurrentSettings.AttId := AttributeIdentification.Id;
            AddJsonElement(DexiJsonAttributeElement.Id);
          end;
        'up', 'path':
          begin
            fCurrentSettings.AttId := AttributeIdentification.Path;
            AddJsonElement(DexiJsonAttributeElement.Path);
          end;
        'v0', 'base0':
          begin
            fCurrentSettings.ValueType := ValueStringType.Zero;
            AddJsonElement(DexiJsonAttributeElement.AsValue);
          end;
        'v1', 'base1':
          begin
            fCurrentSettings.ValueType := ValueStringType.One;
            AddJsonElement(DexiJsonAttributeElement.AsValue);
          end;
        'vt', 'text':
          begin
            fCurrentSettings.ValueType := ValueStringType.Text;
            AddJsonElement(DexiJsonAttributeElement.AsValue);
          end;
        'vs', 'strings':
          begin
            fCurrentSettings.UseDexiStringValues := true;
            AddJsonElement(DexiJsonAttributeElement.AsString);
          end;
        'aa', 'all':
          begin
            fCurrentSettings.AltDataAll := true;
            fCurrentSettings.JsonSettings.AttributeTypes :=
              Utils.AddFlag(fCurrentSettings.JsonSettings.AttributeTypes, Integer(DexiJsonAttributeType.Aggregate));
          end;
        'ab', 'basic':
          begin
            fCurrentSettings.AltDataAll := false;
            fCurrentSettings.JsonSettings.AttributeTypes :=
              Utils.RemoveFlag(fCurrentSettings.JsonSettings.AttributeTypes, Integer(DexiJsonAttributeType.Aggregate));
          end;
        'ii', 'indent', 'i+': fCurrentSettings.AltLevels := true;
        'in', 'noindent', 'i-': fCurrentSettings.AltLevels := false;
        'on', 'normal': fCurrentSettings.AltTranspose := false;
        'ot', 'transpose', 'transposed': fCurrentSettings.AltTranspose := true;
        'ci', 'invariant': fCurrentSettings.CsvInvariant := true;
        'cl', 'local': fCurrentSettings.CsvInvariant := false;
        'jf', 'flat': fCurrentSettings.JsonSettings.StructureFormat :=
          {$IFDEF JAVA}
          Integer(DexiJsonStructureFormat.Flat)          
          {$ELSE}
          DexiJsonStructureFormat.Flat
          {$ENDIF}
          ;
        'jr', 'recursive', 'nested': fCurrentSettings.JsonSettings.StructureFormat :=
          {$IFDEF JAVA}
          Integer(DexiJsonStructureFormat.Recursive)          
          {$ELSE}
          DexiJsonStructureFormat.Recursive
          {$ENDIF}
          ;
        'ji': fCurrentSettings.JsonSettings.JsonIndent := true;
        'jc', 'compact': fCurrentSettings.JsonSettings.JsonIndent := false;
        'd': fCurrentSettings.FltDecimals := lArg.IntegerValue;
        'm': fCurrentSettings.MemDecimals := lArg.IntegerValue;
        'r', 'reset': ResetSettings(lArg.StringValue);
        'u': ResetSettings('u');
        'v': ResetSettings('v');
        'a': ResetSettings('a');
        'i': ResetSettings('i');
        'o': ResetSettings('o');
        'c': ResetSettings('c');
        'j': ResetSettings('j');
        else
          begin
            AddError($'Unexpected parameter: {lArg.Id}');
            exit;
          end;
      end;
end;

method DEXiEVal.Run(args: array of String; aVersion: String): Int32;
begin
  try
    fGeneral := new GeneralSettings;
    RunVersion := aVersion;
    writeLn(SoftwareInfo);
    writeLn;
    DefineParameters;
    ParseArguments(args);
    if Errors then exit 1;
    ProcessGeneralSettings;
    {$IFDEF DEBUG}
    ListArguments;
    {$ENDIF}
    if Errors then exit 2;
    if Help then
      begin
        Usage;
        exit 0;
      end;
    if ShowLicense then
      begin
        License;
        exit 0;
      end;
    CheckParameters;
    if Errors then exit 3;
    LoadDexiModel;
    if Errors then exit 4;
    PrepareDexiModel;
    if Errors then exit 5;
    InterpretArguments;
    if Errors then exit 6;
    if fOutputCount = 0 then
      writeLn($'Warning: No output files written')
    else if Verbose then
      writeLn($'Output file(s) written: {fOutputCount}');
  except on e: Exception do
    begin
      AddError('Exception: ' + e.Message);
      Errors;
      exit 10;
    end;
  end;
end;

end.
