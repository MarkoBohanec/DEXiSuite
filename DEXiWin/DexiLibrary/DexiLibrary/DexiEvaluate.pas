// DexiEvaluate.pas is part of
//
// DEXiLibrary, DEXi Decision Modeling Software Library
//
// Copyright (C) 2023-2025 Marko Bohanec
//
// DEXiLibrary is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// DexiEvaluate.pas implements the main DEXi evaluation mechanism: given the values of
// basic attributes, the values of aggregate attributes are calculated in a bottom-up way
// considering the hierarchical structure of attributes and employing aggregation functions
// (DexFunction) assigned to individual aggregate attributes.
//
// Evaluation is carried out by an instance of the DexiEvaluator class. Four main types
// of aggregation are supported:
// - EvaluationType.AsSet (default DEXi aggregation mode): values are interpreted as
//   sets of qualitative categories
// - EvaluationType.AsProb: values are interpreted as probability distributions of categories
// - EvaluationType.AsFuzzy: values are interpreted as fuzzy distributions of categories
// - EvaluationType.AsFuzzyNorm: EvaluationType.AsFuzzy + fuzzy normalization of values (max = 1)
// ----------

namespace DexiLibrary;

interface

 uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  EDexiEvaluationError = public class (EDexiError);

type
  EvaluationType = public enum (Custom, AsSet, AsProb, AsFuzzy, AsFuzzyNorm);
  ArgumentsType = public enum (None, Mixed, Discrete, Continuous);
  ValueExpand = public enum (Null, All);
  OutOfBoundsMeans = public enum (Error, Narrow);

type
  EvalNormalizeMethod = public method (aValues: FltArray): FltArray;
  EvalCoNormMethod = public method (aValues: FltArray): Float;

type
  PlusMinusAlternative = public record
  private
    fAlternative: DexiAlternative;  
    fValue: Integer;
  public
    constructor (aAlternative: DexiAlternative; aValue: Integer := 0);
    property Alternative: DexiAlternative read fAlternative write fAlternative;
    property Value: Integer read fValue write fValue;
  end;

type
  DexiEvaluator = public class
  private
    fModel: weak DexiModel;
    fPruneAt: DexiAttributeList;
    fAlternative: DexiAlternative;
    fEvalType: EvaluationType;
    fUndefinedExpand: ValueExpand := ValueExpand.Null;
    fEmptyExpand: ValueExpand := ValueExpand.All;
    fOutMeans: OutOfBoundsMeans := OutOfBoundsMeans.Error;
    fNormalize: EvalNormalizeMethod;
    fNorm: EvalCoNormMethod;   // prod, min, ...
    fCoNorm: EvalCoNormMethod; // sum, max, ...
  protected
    method SetExpand(aExp: ValueExpand);
    method SetEvalType(aType: EvaluationType);
    method SetNormalize(aNormalize: EvalNormalizeMethod);
    method SetNorm(aNorm: EvalCoNormMethod);
    method SetCoNorm(aCoNorm: EvalCoNormMethod);
    method ResolveEmptyUndef(aValue: DexiValue; aAtt: DexiAttribute): DexiValue;
    method BoundedValue(aValue: DexiValue; aAtt: DexiAttribute): DexiValue;
    method CheckNil(aArgValues: DexiValueArray): Boolean;
    method CheckUndefined(aArgValues: DexiValueArray): Boolean;
    method CheckEmpty(aArgValues: DexiValueArray): Boolean;
    method CheckUndefinedArguments(aArgValues: DexiValueArray): Boolean;
    method GetAttributeValue(aAlt: IDexiAlternative; aAtt: DexiAttribute): DexiValue;
    method GetArgumentValues(aAtt: DexiAttribute): DexiValueArray;
    method GetArgumentsType(aArgValues: DexiValueArray): ArgumentsType;
    method GetEvaluationType(aAtt: DexiAttribute; aArgType: ArgumentsType): ArgumentsType;
    method DiscreteEvaluation(aAlt: IDexiAlternative; aAtt: DexiAttribute; aArgs: DexiValueArray): DexiValue;
    method ContinuousEvaluation(aAlt: IDexiAlternative; aAtt: DexiAttribute; aArgs: DexiValueArray): DexiValue;
    method EvaluateTerminal(aAlt: IDexiAlternative; aAtt: DexiAttribute): DexiValue;
    method EvaluateAggregate(aAlt: IDexiAlternative; aAtt: DexiAttribute): DexiValue;
    method EvaluateAttribute(aAlt: IDexiAlternative; aAtt: DexiAttribute);
  public
    class method NormalizeNot(aValues: FltArray): FltArray;
    class method NormalizeSet(aValues: FltArray): FltArray;
    class method NormalizeSum1(aValues: FltArray): FltArray;
    class method NormalizeMax1(aValues: FltArray): FltArray;
    class method Product(aValues: FltArray): Float;
    class method Sum(aValues: FltArray): Float;
    class method Minimum(aValues: FltArray): Float;
    class method Maximum(aValues: FltArray): Float;
    constructor (aModel: DexiModel);
    method IsTerminal(aAtt: DexiAttribute): Boolean; virtual;
    method Evaluate(aAlt: IDexiAlternative; aRoot: DexiAttribute := nil); virtual;
    method Evaluate(aAlts: IDexiAlternatives; aRoot: DexiAttribute := nil);
    method PlusMinus(aAlt: IDexiAlternative; aDiff: Integer; aAtt: DexiAttribute := nil; aInputs: DexiAttributeList := nil): DexiAlternative;
    method PlusMinus(aAlt: IDexiAlternative; aMin, aMax: Integer; aAtt: DexiAttribute := nil; aInputs: DexiAttributeList := nil): List<PlusMinusAlternative>;
    class method MinusRange(aList: List<PlusMinusAlternative>): Integer;
    class method PlusRange(aList: List<PlusMinusAlternative>): Integer;
    property Model: DexiModel read fModel;
    property PruneAt: DexiAttributeList read fPruneAt write fPruneAt;
    property UndefinedExpand: ValueExpand read fUndefinedExpand write fUndefinedExpand;
    property EmptyExpand: ValueExpand read fEmptyExpand write fEmptyExpand;
    property Expand: ValueExpand write SetExpand;
    property OutMeans: OutOfBoundsMeans read fOutMeans write fOutMeans;
    property EvalType: EvaluationType read fEvalType write SetEvalType;
    property Normalize: EvalNormalizeMethod read fNormalize write SetNormalize;
    property Norm: EvalCoNormMethod read fNorm write SetNorm;
    property CoNorm: EvalCoNormMethod read fCoNorm write SetCoNorm;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION PlusMinusAlternative}

constructor PlusMinusAlternative(aAlternative: DexiAlternative; aValue: Integer := 0);
begin
  fAlternative := aAlternative;
  fValue := aValue;
end;

{$ENDREGION}

{$REGION DexiEvaluator}

class method DexiEvaluator.NormalizeNot(aValues: FltArray): FltArray;
begin
  exit aValues;
end;

class method DexiEvaluator.NormalizeSet(aValues: FltArray): FltArray;
begin
  var lNormalized := true;
  for i := low(aValues) to high(aValues) do
    if (aValues[i] <> 0.0) or (aValues[i] <> 1.0) then
      begin
        lNormalized := false;
        break;
      end;
  if lNormalized then
    exit aValues;
  result := new Float[length(aValues)];
  for i := low(aValues) to high(aValues) do
    result[i] := if aValues[i] > 0.0 then 1.0 else 0.0;
end;

class method DexiEvaluator.NormalizeSum1(aValues: FltArray): FltArray;
begin
  var lSum := 0.0;
  for i := low(aValues) to high(aValues) do
    lSum := lSum + aValues[i];
  if (lSum = 1.0) or (lSum = 0.0) then
    exit aValues;
  result := new Float[length(aValues)];
  for i := low(aValues) to high(aValues) do
    result[i] := aValues[i] / lSum;
end;

class method DexiEvaluator.NormalizeMax1(aValues: FltArray): FltArray;
begin
  var lMax := 0.0;
  for i := low(aValues) to high(aValues) do
    if aValues[i] > lMax then
      lMax := aValues[i];
  if (lMax = 1.0) or (lMax = 0.0) then
    exit aValues;
  result := new Float[length(aValues)];
  for i := low(aValues) to high(aValues) do
    result[i] := aValues[i] / lMax;
end;

class method DexiEvaluator.Product(aValues: FltArray): Float;
begin
  result := 1.0;
  for i := low(aValues) to high(aValues) do
    result := result * aValues[i];
end;

class method DexiEvaluator.Sum(aValues: FltArray): Float;
begin
  result := 0.0;
  for i := low(aValues) to high(aValues) do
    result := result + aValues[i];
end;

class method DexiEvaluator.Minimum(aValues: FltArray): Float;
begin
  result := Consts.PositiveInfinity; //TODO {$IFDEF JAVA} Float.POSITIVE_INFINITY {$ELSE} Float.PositiveInfinity {$ENDIF};
  for i := low(aValues) to high(aValues) do
    if aValues[i] < result then
      result := aValues[i];
end;

class method DexiEvaluator.Maximum(aValues: FltArray): Float;
begin
  result := Consts.NegativeInfinity; //TODO {$IFDEF JAVA} Float.NEGATIVE_INFINITY {$ELSE} Float.NegativeInfinity {$ENDIF};
  for i := low(aValues) to high(aValues) do
    if aValues[i] > result then
      result := aValues[i];
end;

constructor DexiEvaluator(aModel: DexiModel);
begin
  fModel := aModel;
  EvalType := EvaluationType.AsSet;
end;

method DexiEvaluator.SetExpand(aExp: ValueExpand);
begin
  fUndefinedExpand := aExp;
  fEmptyExpand := aExp;
end;

method DexiEvaluator.SetEvalType(aType: EvaluationType);
begin
  fEvalType := aType;
  case aType of
    EvaluationType.Custom:
      begin
        fNormalize := @NormalizeNot;
        fNorm :=      @Minimum;
        fCoNorm :=    @Maximum;
      end;
    EvaluationType.AsSet:
      begin
        fNormalize := @NormalizeSet;
        fNorm :=      @Minimum;
        fCoNorm :=    @Maximum;
      end;
    EvaluationType.AsProb:
      begin
        fNormalize := @NormalizeSum1;
        fNorm :=      @Product;
        fCoNorm :=    @Sum;
      end;
    EvaluationType.AsFuzzy:
      begin
        fNormalize := @NormalizeNot;
        fNorm :=      @Minimum;
        fCoNorm :=    @Maximum;
      end;
    EvaluationType.AsFuzzyNorm:
      begin
        fNormalize := @NormalizeMax1;
        fNorm :=      @Minimum;
        fCoNorm :=    @Maximum;
      end;
  end;
end;

method DexiEvaluator.SetNormalize(aNormalize: EvalNormalizeMethod);
begin
  if not assigned(aNormalize) then
    raise new EDexiEvaluationError('NULL Normalizator');
  fNormalize := aNormalize;
  fEvalType := EvaluationType.Custom;
end;

method DexiEvaluator.SetNorm(aNorm: EvalCoNormMethod);
begin
  if not assigned(aNorm) then
    raise new EDexiEvaluationError('NULL Norm');
  fNorm := aNorm;
  fEvalType := EvaluationType.Custom;
end;

method DexiEvaluator.SetCoNorm(aCoNorm: EvalCoNormMethod);
begin
  if not assigned(aCoNorm) then
    raise new EDexiEvaluationError('NULL CoNorm');
  fCoNorm := aCoNorm;
  fEvalType := EvaluationType.Custom;
end;

method DexiEvaluator.IsTerminal(aAtt: DexiAttribute): Boolean;
begin
  result :=
    aAtt.IsBasicNonLinked or
    ((fPruneAt <> nil) and fPruneAt.Contains(aAtt));
end;

method DexiEvaluator.ResolveEmptyUndef(aValue: DexiValue; aAtt: DexiAttribute): DexiValue;
begin
  result := aValue;
  if result = nil then
    begin
      if fUndefinedExpand = ValueExpand.All then
        result := aAtt.FullValue;
    end
  else if not result.IsDefined or result.IsEmpty then
    begin
      if fEmptyExpand = ValueExpand.All then
        result := aAtt.FullValue;
    end;
end;

method DexiEvaluator.BoundedValue(aValue: DexiValue; aAtt: DexiAttribute): DexiValue;
begin
  result := aValue;
  if (aValue = nil) or not aValue.IsDefined or (aAtt:Scale = nil) then
    exit;
  if DexiScale.ValueInScaleBounds(aValue, aAtt.Scale) then
    exit;
  if fOutMeans = OutOfBoundsMeans.Error then
    raise new EDexiEvaluationError(String.Format(DexiString.SValueOutOfAttBounds, [aValue.ToString, aAtt.Name]));
  result := DexiScale.ValueIntoScaleBounds(aValue, aAtt.Scale);
end;

method DexiEvaluator.CheckNil(aArgValues: DexiValueArray): Boolean;
begin
  result := false;
  for i := low(aArgValues) to high(aArgValues) do
    if aArgValues[i] = nil then
      exit true;
end;

method DexiEvaluator.CheckUndefined(aArgValues: DexiValueArray): Boolean;
begin
  result := false;
  for i := low(aArgValues) to high(aArgValues) do
    if (aArgValues[i] = nil) or not aArgValues[i].IsDefined  then
      exit true;
end;

method DexiEvaluator.CheckEmpty(aArgValues: DexiValueArray): Boolean;
begin
  result := false;
  for i := low(aArgValues) to high(aArgValues) do
    if (aArgValues[i] = nil) or aArgValues[i].IsEmpty  then
      exit true;
end;

method DexiEvaluator.CheckUndefinedArguments(aArgValues: DexiValueArray): Boolean;
begin
  result := true;
  for i := low(aArgValues) to high(aArgValues) do
    if (aArgValues[i] = nil) or not aArgValues[i].IsDefined or aArgValues[i].IsEmpty then
      exit false;
end;

method DexiEvaluator.GetAttributeValue(aAlt: IDexiAlternative; aAtt: DexiAttribute): DexiValue;
begin
  result := nil;
  if (aAlt <> nil) and (aAtt <> nil) then
    result := aAlt[aAtt];
end;

method DexiEvaluator.GetArgumentValues(aAtt: DexiAttribute): DexiValueArray;
begin
  result := new DexiValue[aAtt.InpCount];
  for i := 0 to aAtt.InpCount - 1 do
    result[i] := fAlternative[aAtt.Inputs[i]];
end;

method DexiEvaluator.GetArgumentsType(aArgValues: DexiValueArray): ArgumentsType;
begin
  var lInt := 0;
  var lFlt := 0;
  for i := low(aArgValues) to high(aArgValues) do
    if aArgValues[i].IsFloat then inc(lFlt)
    else if aArgValues[i].IsInteger then inc(lInt);
  result :=
    if lInt = 0 then
      if lFlt = 0 then ArgumentsType.None
      else ArgumentsType.Continuous
    else
      if lFlt = 0 then ArgumentsType.Discrete
      else ArgumentsType.Mixed;
end;

method DexiEvaluator.GetEvaluationType(aAtt: DexiAttribute; aArgType: ArgumentsType): ArgumentsType;
begin
  if (aArgType = ArgumentsType.Discrete) and (aAtt.Funct is DexiTabularFunction) then
    result := ArgumentsType.Discrete
  else if (aArgType = ArgumentsType.Continuous) {and function is of the appropriate type} then //TODO
    result := ArgumentsType.Continuous
  else
    raise new EDexiEvaluationError(String.Format(DexiString.SDexiEvaluationArguments, [aAtt.Name, fAlternative.Name]));
end;

method DexiEvaluator.EvaluateTerminal(aAlt: IDexiAlternative; aAtt: DexiAttribute): DexiValue;
begin
  result := GetAttributeValue(aAlt, aAtt);
  if (aAtt:Scale <> nil) and aAtt.Scale.IsDistributable and (result <> nil) and result.IsFloat and result.HasFltSingle then
    begin
      var lSet := aAtt.NumValues(result.AsFloat);
      result := new DexiIntSet(lSet);
    end;
end;

method DexiEvaluator.DiscreteEvaluation(aAlt: IDexiAlternative; aAtt: DexiAttribute; aArgs: DexiValueArray): DexiValue;
require
  aAlt <> nil;
  aAtt <> nil;
  length(aArgs) = aAtt.InpCount;
begin
  result := nil;
  var lFunct := aAtt.Funct;
  if (aAtt.Scale = nil) or (lFunct = nil) or (length(aArgs) = 0) then
    exit;
  var lSets := new IntSet[length(aArgs)];
  var lMems := new FltArray[length(aArgs)];
  var lResult := Utils.NewFltArray(aAtt.Scale.Count);
  for i := 0 to aAtt.InpCount - 1 do
    begin
      if (aAtt.Inputs[i].Scale = nil) or (aAtt.Inputs[i].Scale.Count <= 0) then
        begin
          lSets[i] := [0];
          lMems[i] := [1.0];
        end
      else
        begin
          var lDistr := aArgs[i].AsDistribution;
          lSets[i] := Values.IntSet(lDistr);
          lMems[i] := Values.IntSetMembers(lDistr);
        end;
      lMems[i] := fNormalize(lMems[i]);
    end;
  var lLow := Utils.NewIntArray(length(aArgs), 0);
  var lHigh := Utils.NewIntArray(length(aArgs), 0);
  for i := 0 to aAtt.InpCount - 1 do
    lHigh[i] := high(lSets[i]);
  var lVectors := new Vectors(lLow, lHigh);
  var lArgVals := Utils.NewIntArray(length(aArgs), 0);
  var lArgMems := Utils.NewFltArray(length(aArgs), 0.0);
  lVectors.First;
  var lUndefined := false;
  repeat
    var lVector := lVectors.Vector;
    for j := 0 to aAtt.InpCount - 1 do
      begin
        lArgVals[j] := lSets[j][lVector[j]];
        lArgMems[j] := lMems[j][lVector[j]];
      end;
    var lRuleMemb := fNorm(lArgMems);
    if lRuleMemb <= 0.0 then
      continue;
    var lOutValue := lFunct.Evaluate(lArgVals);
    if (lOutValue = nil) or not lOutValue.IsDefined or lOutValue.IsEmpty then
      lUndefined := true
    else
      begin
        var lOutDistr := lOutValue.AsDistribution;
        for c := Values.DistrLowIndex(lOutDistr) to Values.DistrHighIndex(lOutDistr) do
          begin
            var d := Values.GetDistribution(lOutDistr, c);
            if d > 0.0 then
              lResult[c] := fCoNorm([lResult[c], fNorm([lRuleMemb, d])]);
          end;
      end;
  until lUndefined or not lVectors.Next;
  if not lUndefined then
    begin
      lResult := fNormalize(lResult);
      result := new DexiDistribution(Values.Distr(0, lResult));
      result := DexiValue.SimplifyValue(result);
    end;
end;

method DexiEvaluator.ContinuousEvaluation(aAlt: IDexiAlternative; aAtt: DexiAttribute; aArgs: DexiValueArray): DexiValue;
require
  aAlt <> nil;
  aAtt <> nil;
  length(aArgs) = aAtt.InpCount;
begin
  result := nil;
  var lFunct := aAtt.Funct;
  if (aAtt.Scale = nil) or (lFunct = nil) or (length(aArgs) = 0) or aAtt.Scale.IsContinuous then
    exit;
  var lArgs := Utils.NewFltArray(length(aArgs));
  for a := low(aArgs) to high(aArgs) do
    if not DexiValue.ValueIsDefined(aArgs[a]) or not aArgs[a].HasFltSingle then
      exit nil
    else
      lArgs[a] := aArgs[a].AsFloat;
  result := lFunct.Evaluate(lArgs);
end;

method DexiEvaluator.EvaluateAggregate(aAlt: IDexiAlternative; aAtt: DexiAttribute): DexiValue;
begin
  result := nil;
  if (aAlt <> nil) and (aAtt:Scale <> nil) and (aAtt:Funct <> nil) then
    begin
      var lArgValues := GetArgumentValues(aAtt);
      if CheckNil(lArgValues) then
        exit nil
      else if CheckUndefined(lArgValues) then
        exit new DexiUndefinedValue
      else if CheckEmpty(lArgValues) then
        exit new DexiIntSet
      else
        begin
          var lArgType := GetArgumentsType(lArgValues);
          var lEvalType := GetEvaluationType(aAtt, lArgType);
          case lEvalType of
            ArgumentsType.Discrete:
              result := DiscreteEvaluation(aAlt, aAtt, lArgValues);
            ArgumentsType.Continuous:
              result := ContinuousEvaluation(aAlt, aAtt, lArgValues);
            else
              raise new EDexiEvaluationError($'Unsupported evaluation type: "{lEvalType.ToString}"');
          end;
        end;
    end;
end;

method DexiEvaluator.EvaluateAttribute(aAlt: IDexiAlternative; aAtt: DexiAttribute);
begin
  var lValue: DexiValue := nil;
  if aAtt.Link <> nil then
    begin
      EvaluateAttribute(aAlt, aAtt.Link);
      lValue := fAlternative[aAtt.Link];
    end
  else if IsTerminal(aAtt) then
    lValue := EvaluateTerminal(aAlt, aAtt)
  else
    begin
      for i := 0 to aAtt.InpCount - 1 do
        EvaluateAttribute(aAlt, aAtt.Inputs[i]);
      lValue := EvaluateAggregate(aAlt, aAtt);
    end;
  lValue := ResolveEmptyUndef(lValue, aAtt);
  lValue := BoundedValue(lValue, aAtt);
  fAlternative[aAtt] := lValue;
end;

method DexiEvaluator.Evaluate(aAlt: IDexiAlternative; aRoot: DexiAttribute := nil);
begin
  if aRoot = nil then
    aRoot := fModel.Root;
  fAlternative := new DexiAlternative(aAlt.Name, aAlt.Description);
  EvaluateAttribute(aAlt, aRoot);
  for each lAtt in fAlternative.Attributes do
    if not IsTerminal(lAtt) then
      aAlt[lAtt] := fAlternative[lAtt];
  fAlternative := nil;
end;

method DexiEvaluator.Evaluate(aAlts: IDexiAlternatives; aRoot: DexiAttribute := nil);
begin
  for i := 0 to aAlts.AltCount - 1 do
    Evaluate(aAlts[i], aRoot);
end;

method DexiEvaluator.PlusMinus(aAlt: IDexiAlternative; aDiff: Integer; aAtt: DexiAttribute := nil; aInputs: DexiAttributeList := nil): DexiAlternative;
begin
  result := new DexiAlternative(aAlt.Name, aAlt.Description);
  if aAtt = nil then
    aAtt := fModel.First;
  if aAtt = nil then
    exit;
  if aInputs = nil then
    aInputs := aAtt.CollectBasicForEvaluation;
  var lAlt := aAlt.Copy;
  if aDiff = 0 then
    begin
      Evaluate(lAlt, aAtt);
      result[aAtt] := lAlt[aAtt];
      for i := 0 to aInputs.Count - 1 do
        begin
          var lAtt := aInputs[i];
          result[lAtt] := lAlt[lAtt];
        end
    end
  else
    for i := 0 to aInputs.Count - 1 do
      begin
        var lAtt := aInputs[i];
        var lValue := lAlt[lAtt];
        if (lAtt:Scale <> nil) and lAtt.Scale.IsDiscrete and DexiValue.ValueIsDefined(lValue) and lValue.IsInteger then
          begin
            var lNewInt :=
              if aDiff < 0 then lValue.LowInt + aDiff
              else lValue.HighInt + aDiff;
            if lAtt.Scale.InBounds(lNewInt) then
              begin
                lAlt[lAtt] := new DexiIntSingle(lNewInt);
                Evaluate(lAlt, aAtt);
                result[lAtt] := lAlt[aAtt];
                lAlt[lAtt] := lValue;
              end
            else
              result[lAtt] := nil;
          end;
      end;
end;

method DexiEvaluator.PlusMinus(aAlt: IDexiAlternative; aMin, aMax: Integer; aAtt: DexiAttribute := nil; aInputs: DexiAttributeList := nil): List<PlusMinusAlternative>;
begin
  var lMinusList := new List<PlusMinusAlternative>;
  var lPlusList := new List<PlusMinusAlternative>;
  if aMin = -1 then aMin := low(Integer);
  if aMax = -1 then aMax := high(Integer);
  var lAlt: DexiAlternative := nil;
  var lDiff := -1;
  while lDiff >= -aMin do
    begin
      lAlt := PlusMinus(aAlt, lDiff, aAtt, aInputs);
      if (lAlt:Attributes = nil) or (lAlt.Attributes.Count = 0) then
        break;
      lMinusList.Add(new PlusMinusAlternative(lAlt, lDiff));
      dec(lDiff);
    end;
  lDiff := +1;
  while lDiff <= aMax do
    begin
      lAlt := PlusMinus(aAlt, lDiff, aAtt, aInputs);
      if (lAlt:Attributes = nil) or (lAlt.Attributes.Count = 0) then
        break;
      lPlusList.Add(new PlusMinusAlternative(lAlt, lDiff));
      inc(lDiff);
    end;
  result := new List<PlusMinusAlternative>;
  lAlt := PlusMinus(aAlt, 0, aAtt, aInputs);
  result.Add(new PlusMinusAlternative(lAlt));
  for i := lMinusList.Count - 1 downto 0 do
    result.Add(lMinusList[i]);
  for i := 0 to lPlusList.Count - 1 do
    result.Add(lPlusList[i]);
end;

class method DexiEvaluator.MinusRange(aList: List<PlusMinusAlternative>): Integer;
begin
  result := 0;
  for each lAlt in aList do
    result := Math.Min(result, lAlt.Value);
end;

class method DexiEvaluator.PlusRange(aList: List<PlusMinusAlternative>): Integer;
begin
  result := 0;
  for each lAlt in aList do
    result := Math.Max(result, lAlt.Value);
end;

{$ENDREGION}

end.
