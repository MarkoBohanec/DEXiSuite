// Parameters.pas is part of
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
// Parameters.pas implements parsing and interpreting command-line parameters.
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
  ParameterType = public enum (NoArg, StringArg, NumArg);
  ArgumentType = public enum (NoArg, &Optional, Required);

type
  ParameterDefinition = public class
  private
    fType: ParameterType;
    fArgType: ArgumentType;
    fId: String;
    fPositional := true;
    fRangeChecking := false;
    fDefInt := 0;
    fMinInt := low(Integer);
    fMaxInt := high(Integer);
  public
    constructor (aId: String;
      aParType: ParameterType := ParameterType.NoArg;
      aArgType: ArgumentType := ArgumentType.NoArg);
    method SetRange(aDefault, aMin, aMax: Integer);
    property Id: String read fId;
    property &Type: ParameterType read fType;
    property &ArgType: ArgumentType read fArgType;
    property Positional: Boolean read fPositional write fPositional;
    property RangeChecking: Boolean read fRangeChecking write fRangeChecking;
    property DefInt: Integer read fDefInt;
    property MinInt: Integer read fMinInt;
    property MaxInt: Integer read fMaxInt;
  end;

type
  MatchResponse = public class
  public
    constructor (aArgument: ProgramArgument; aError: String := nil);
    property Argument: ProgramArgument;
    property Error: String;
  end;

type
  ParameterDefinitions = public class
  private
    fParameters: Dictionary<String, ParameterDefinition>;
    fFileParameter: ParameterDefinition;
  public
    constructor;
    method AddParameter(aParameter: ParameterDefinition): ParameterDefinition;
    method AddParameters(aParameters: sequence of ParameterDefinition);
    method AddNoArgParameters(aIds: sequence of String; aPositional: Boolean := false);
    method Match(aStr: String): MatchResponse;
    public property Parameters: ImmutableDictionary<String, ParameterDefinition> read fParameters;
  end;

type
  ProgramArgument = public class
  private
    fParameter: ParameterDefinition;
    fStringValue: String;
    fIntegerValue: nullable Integer;
  public
    constructor (aParameter: ParameterDefinition);
    constructor (aParameter: ParameterDefinition; aStr: String);
    constructor (aParameter: ParameterDefinition; aInt: Integer);
    property Parameter: ParameterDefinition read fParameter;
    property Id: String read fParameter:Id;
    property StringValue: String read fStringValue;
    property IntegerValue: nullable Integer read fIntegerValue;
  end;

type
  ProgramArguments = public class
  private
    fArguments: List<ProgramArgument>;
    fFiles: List<String>;
    fPositionalArguments: List<ProgramArgument>;
    fGeneralArguments: List<ProgramArgument>;
    fErrors: List<String>;
  public
    constructor; empty;
    method Parse(args: array of String; pars: ParameterDefinitions): List<String>;
    property Arguments: ImmutableList<ProgramArgument> read fArguments;
    property Files: ImmutableList<String> read fFiles;
    property PositionalArguments: ImmutableList<ProgramArgument> read fPositionalArguments;
    property GeneralArguments: ImmutableList<ProgramArgument> read fGeneralArguments;
  end;

implementation

{$REGION ParameterDefinition}

constructor ParameterDefinition(aId: String;
  aParType: ParameterType := ParameterType.NoArg;
  aArgType: ArgumentType := ArgumentType.NoArg);
begin
  fId := aId:ToLower;
  fType := aParType;
  fArgType := aArgType;
  if fType = ParameterType.NoArg then
    fArgType := ArgumentType.NoArg;
end;

method ParameterDefinition.SetRange(aDefault, aMin, aMax: Integer);
begin
  fDefInt := aDefault;
  fMinInt := aMin;
  fMaxInt := aMax;
end;

{$ENDREGION}

{$REGION MatchResponse}

constructor MatchResponse(aArgument: ProgramArgument; aError: String := nil);
begin
  Argument := aArgument;
  Error := aError;
end;

{$ENDREGION}

{$REGION ParameterDefinitions}

constructor ParameterDefinitions;
begin
  fParameters := new Dictionary<String, ParameterDefinition>;
  fFileParameter := new ParameterDefinition(nil);
end;

method ParameterDefinitions.AddParameter(aParameter: ParameterDefinition): ParameterDefinition;
begin
  if aParameter <> nil then
    fParameters.Add(aParameter.Id, aParameter);
  result := aParameter;
end;

method ParameterDefinitions.AddParameters(aParameters: sequence of ParameterDefinition);
begin
  for each lParameter in aParameters do
    AddParameter(lParameter);
end;

method ParameterDefinitions.AddNoArgParameters(aIds: sequence of String; aPositional: Boolean := false);
begin
  for each lId in aIds do
    AddParameter(new ParameterDefinition(lId, Positional := aPositional));
end;

method ParameterDefinitions.Match(aStr: String): MatchResponse;
begin
  result := nil;
  if aStr.StartsWith('-') or aStr.StartsWith('/') then
    begin
      var lStart := if aStr.StartsWith('--') then 2 else 1;
      var lOpt := aStr.Substring(0, lStart);
      var lStr := aStr.Substring(lStart);
      var lLow := lStr.ToLower;
      for each lKey in fParameters.Keys do
        begin
          var lPar := fParameters[lKey];
          var lMatch :=
            if lPar.Type = ParameterType.NoArg then lPar.Id = lLow
            else lLow.StartsWith(lPar.Id);
          if not lMatch then
            continue;
          if lPar.Type = ParameterType.NoArg then
            exit new MatchResponse(new ProgramArgument(lPar));
          var lArg := lStr.Substring(lPar.Id.Length);
          if String.IsNullOrEmpty(lArg) and (lPar.ArgType = ArgumentType.Required) then
            exit new MatchResponse(nil, $"Parameter {lOpt}{lPar.Id} requires an argument");
          if lPar.Type = ParameterType.StringArg then
            exit new MatchResponse(new ProgramArgument(lPar, lArg));
          if String.IsNullOrEmpty(lArg) then
            exit new MatchResponse(new ProgramArgument(lPar, lPar.DefInt));
          // remains Par.Type = ParameterType.NumArg 
          var lValue := Convert.TryToInt32(lArg);
          if lValue = nil then
            exit new MatchResponse(nil, $"Parameter {lOpt}{lPar.Id} requires an integer argument");
          if lPar.RangeChecking and (lValue < lPar.MinInt) or (lValue > lPar.MaxInt) then
            exit new MatchResponse(nil, $"Parameter {lOpt}{lPar.Id} requires an integer argument in the range {lPar.MinInt} to {lPar.MaxInt}");
          exit new MatchResponse(new ProgramArgument(lPar, lValue));
        end;
      exit new MatchResponse(nil, $"Unknown parameter {aStr}");
    end
  else
    result := new MatchResponse(new ProgramArgument(fFileParameter, aStr));
end;

{$ENDREGION}

{$REGION ProgramArgument}

constructor ProgramArgument(aParameter: ParameterDefinition);
begin
  fParameter := aParameter;
end;

constructor ProgramArgument(aParameter: ParameterDefinition; aStr: String);
begin
  constructor (aParameter);
  fStringValue := aStr;
end;

constructor ProgramArgument(aParameter: ParameterDefinition; aInt: Integer);
begin
  constructor (aParameter);
  fIntegerValue := aInt;
end;

{$ENDREGION}

{$REGION ProgramArguments}

method ProgramArguments.Parse(args: array of String; pars: ParameterDefinitions): List<String>;
begin
  fArguments := new List<ProgramArgument>;
  fFiles := new List<String>;
  fPositionalArguments := new List<ProgramArgument>;
  fGeneralArguments := new List<ProgramArgument>;
  fErrors := new List<String>;
  for each lCmdArg in args do
    begin
      var lResponse := pars.Match(lCmdArg);
      if lResponse.Error <> nil then
        fErrors.Add(lResponse.Error)
      else
        with lProgArg := lResponse.Argument do
          begin
            fArguments.Add(lProgArg);
            if lProgArg.Id = nil then
              fFiles.Add(lProgArg.StringValue);
            if lProgArg.Parameter.Positional then
              fPositionalArguments.Add(lProgArg)
            else
              fGeneralArguments.Add(lProgArg);
          end;
    end;
  result :=
    if fErrors.Count = 0 then nil
    else fErrors;
end;

{$ENDREGION}

end.
