// DexiQQ.pas is part of
//
// DEXiLibrary, DEXi Decision Modeling Software Library
//
// Copyright (C) 2024 Marko Bohanec
//
// DEXiLibrary is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// DexiQQ.pas implements Qualitative-Quantitative Evaluation using offsets.
// The method has been proposed in:
//   Bohanec, M., Urh, B., Rajkoviè, V.:
//   Evaluating options by combined qualitative and quantitative methods.
//   Acta Psychologica 80, 67-89, North-Holland, 1992.
// Main idea:
//   Evaluation value is represented by an offset of the form off = ord(class) + offset,
//   where offset is in [-0.5, +0.5].
//   Ord(class) always corresponds to the class that would have been determined by "normal" evaluation.
//   Offset then represents preferential evaluation *within* ord(class), where
//     -0.5 represents a bad value within ord(class), and
//     +0.5 represents a good value within ord(class).
// Method sketch for each tabular function F:
//   Calculate weights
//   For each class construct a hyperplane:
//   - slanted according to weights,
//   - staying within [ord(class) - 0.5, ord(class) + 0.5] margins.
// This set of functions is used to evaluate arguments, which can be represented in terms of offsets.
// ----------

namespace DexiLibrary;

interface

 uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  ClassOffsets = FltArray;
  ClassOffsetsArray = array of ClassOffsets;
  IntOffsets = array of IntOffset;

type
  Offsets = public static class
  public
    method NewClassOffsets(aLength: Integer): ClassOffsets;
    method NewClassOffsets(aAtt: DexiAttribute): ClassOffsets;
    method Count(aOffs: ClassOffsets): Integer;
    method Defined(aOffs: ClassOffsets; aIdx: Integer): Boolean;
    method IntOffAt(aOffs: ClassOffsets; aIdx: Integer): nullable IntOffset;
    method FirstIndex(aOffs: ClassOffsets): Integer;
    method SingleFloat(aFlts: FltArray): Float;
    method SingleOffset(aOffs: ClassOffsets): Float;
    method SingleValue(aOffs: ClassOffsets): Float;
    method ValueAt(aOffs: ClassOffsets; aIdx: Integer): Float;
    method ValuesOf(aOffs: ClassOffsets): FltArray;
    method ValuesOf(aInts: IntArray; aOffs: ClassOffsets): FltArray;
    method ValuesOf(aOffs: IntOffsets): FltArray;
    method ClassToIntOffsets(aOffs: ClassOffsets): IntOffsets;
    method IntOffsets(aInts: IntArray; aFlts: FltArray := nil): IntOffsets;
    method FltToOffsets(aFlts: FltArray): ClassOffsets;
    method IntToClassOffsets(aOffs: IntOffsets; aLength: Integer): ClassOffsets;
    method IntOffsetsToStr(aOffs: IntOffsets; aInvariant: Boolean := true): String;
  end;

type
  DexiMultilinearModel = public class
  private
  private
    fFunct: DexiTabularFunction;
    fValues: FltArray;
    fGrid: Grid;
  private
    method Setup;
  public
    constructor (aFunct: DexiTabularFunction);
    property Funct: DexiTabularFunction read fFunct;
    property ArgCount: Integer read if fFunct = nil then 0 else fFunct.ArgCount;
    property Values: FltArray;
    property ValueGrid: Grid read fGrid;
    method Evaluate(aArgs: IntArray): Float;
    method Evaluate(aArgs: FltArray): Float;
  end;

type
  DexiQModel = public abstract class
  private
    fFunct: DexiTabularFunction;
  public
    constructor (aFunct: DexiTabularFunction);
    property Funct: DexiTabularFunction read fFunct;
    property ArgCount: Integer read if fFunct = nil then 0 else fFunct.ArgCount;
    property ClassCount: Integer read if fFunct = nil then 0 else fFunct.OutValCount;
    method Evaluate(aArgs: IntArray; aClass: Integer): Float; virtual; abstract;
    method Evaluate(aArgs: FltArray; aClass: Integer): Float; virtual; abstract;
    method Evaluate(aArgs: IntArray): FltArray; virtual; abstract;
    method Evaluate(aArgs: FltArray): FltArray; virtual; abstract;
  end;

type
  DexiQQ1Model = public class (DexiQModel)
  private
    fWeightFactors: FltArray;
    fClassK: FltArray;
    fClassN: FltArray;
  protected
    method MapClasses;
  public
    constructor (aFunct: DexiTabularFunction);
    property WeightFactors: FltArray read fWeightFactors;
    property ClassK: FltArray read fClassK;
    property ClassN: FltArray read fClassN;
    method Regression(aArgs: IntArray): Float;
    method Regression(aArgs: FltArray): Float;
    method Evaluate(aArgs: IntArray; aClass: Integer): Float; override;
    method Evaluate(aArgs: FltArray; aClass: Integer): Float; override;
    method Evaluate(aArgs: IntArray): FltArray; override;
    method Evaluate(aArgs: FltArray): FltArray; override;
  end;

type
  DexiOffAlternatives = public List<DexiOffAlternative>;
  DexiOffAlternative = public class (DexiObject)
  private
    fValues := new Dictionary<DexiAttribute, ClassOffsets>;
  protected
    method GetValue(aAtt: DexiAttribute): ClassOffsets;
    method SetValue(aAtt: DexiAttribute; aValue: ClassOffsets);
    method SetAsInt(aAtt: DexiAttribute; aInt: Integer);
    method GetAsFloat(aAtt: DexiAttribute): Float;
    method SetAsFloat(aAtt: DexiAttribute; aFloat: Float);
    method SetAsIntOff(aAtt: DexiAttribute; aOff: IntOffset);
    method GetAsIntOffsets(aAtt: DexiAttribute): IntOffsets;
    method SetAsIntOffsets(aAtt: DexiAttribute; aOffs: IntOffsets);
    method SetAsDexiValue(aAtt: DexiAttribute; aValue: DexiValue);
    method GetAsString(aAtt: DexiAttribute): String;
  public
    constructor (aName: String := ''; aDescription: String := '');
    constructor (aAlt: IDexiAlternative);
    method &Copy: DexiOffAlternative;
    method ExcludeAttribute(aAtt: DexiAttribute);
    method UseAttributes(aAtts: DexiAttributeList);
    property Attributes: ImmutableList<DexiAttribute> read fValues.Keys;
    property Rounding: OffsetRounding := OffsetRounding.Down;
    property Value[aAtt: DexiAttribute]: ClassOffsets read GetValue write SetValue; default;
    property AsInt[aAtt: DexiAttribute]: Integer write SetAsInt;
    property AsFloat[aAtt: DexiAttribute]: Float read GetAsFloat write SetAsFloat;
    property AsIntOff[aAtt: DexiAttribute]: IntOffset write SetAsIntOff;
    property AsIntOffsets[aAtt: DexiAttribute]: IntOffsets read GetAsIntOffsets write SetAsIntOffsets;
    property AsDexiValue[aAtt: DexiAttribute]: DexiValue write SetAsDexiValue;
    property AsString[aAtt: DexiAttribute]: String read GetAsString;
  end;

type
  DexiQEvaluator = public abstract class (DexiEvaluator)
  private
    fFunctModels := new Dictionary<DexiTabularFunction, DexiQModel>;
  protected
    method NewFunctModel(aFunct: DexiTabularFunction): DexiQModel; virtual; abstract;
    method GetArgumentOffsets(aAlt: DexiOffAlternative; aAtt: DexiAttribute): ClassOffsetsArray;
    method MakeInpList(aOffs: ClassOffsetsArray): List<IntArray>;
    method InpOffsets(aArgs: ClassOffsetsArray; aInps: IntArray): ClassOffsets;
    method InpValues(aArgs: ClassOffsetsArray; aInps: IntArray): FltArray;
    method FunctModelEvaluation(aQModel: DexiQModel; aArgs: ClassOffsetsArray; aList: List<IntArray>): ClassOffsets;
    method EvaluateAggregate(aAlt: DexiOffAlternative; aAtt: DexiAttribute): ClassOffsets;
    method EvaluateAttribute(aAlt: DexiOffAlternative; aAtt: DexiAttribute);
  public
    constructor (aModel: DexiModel);
    method IsTerminal(aAtt: DexiAttribute): Boolean; override;
    method FunctModel(aFunct: DexiTabularFunction): DexiQModel;
    method Evaluate(aAlt: DexiOffAlternative; aRoot: DexiAttribute := nil); virtual;
    method Evaluate(aAlts: sequence of DexiOffAlternative; aRoot: DexiAttribute := nil);
  end;

type
  DexiQQEvaluator = public class (DexiQEvaluator)
  protected
    method NewFunctModel(aFunct: DexiTabularFunction): DexiQModel; override;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION Offsets}

method Offsets.NewClassOffsets(aLength: Integer): ClassOffsets;
begin
  result := Utils.NewFltArray(aLength, Consts.NaN);
end;

method Offsets.NewClassOffsets(aAtt: DexiAttribute): ClassOffsets;
begin
  result :=
    if (aAtt:Scale = nil) or (aAtt.Scale.Count < 0) then nil
    else NewClassOffsets(aAtt.Scale.Count);
end;

method Offsets.Count(aOffs: ClassOffsets): Integer;
begin
  result := 0;
  for i := low(aOffs) to high(aOffs) do
    if Defined(aOffs, i) then
      inc(result);
end;

method Offsets.Defined(aOffs: ClassOffsets; aIdx: Integer): Boolean;
begin
  result := (low(aOffs) <= aIdx <= high(aOffs)) and not Consts.IsNaN(aOffs[aIdx]);
end;

method Offsets.IntOffAt(aOffs: ClassOffsets; aIdx: Integer): nullable IntOffset;
begin
  result :=
    if Defined(aOffs, aIdx) then Values.IntOff(aIdx, aOffs[aIdx])
    else nil;
end;

method Offsets.FirstIndex(aOffs: ClassOffsets): Integer;
begin
  result := -1;
  for i := low(aOffs) to high(aOffs) do
    if Defined(aOffs, i) then
      exit i;
end;

method Offsets.SingleFloat(aFlts: FltArray): Float;
begin
  result :=
    if Count(aFlts) = 1 then aFlts[FirstIndex(aFlts)]
    else Consts.NaN;
end;

method Offsets.SingleOffset(aOffs: ClassOffsets): Float;
begin
  result := SingleFloat(aOffs);
end;

method Offsets.SingleValue(aOffs: ClassOffsets): Float;
begin
  result :=
    if Count(aOffs) = 1 then ValueAt(aOffs, FirstIndex(aOffs))
    else Consts.NaN;
end;

method Offsets.ValueAt(aOffs: ClassOffsets; aIdx: Integer): Float;
begin
  var lOffset := IntOffAt(aOffs, aIdx);
  result :=
    if lOffset = nil then Consts.NaN
    else Values.FltSingle(lOffset);
end;

method Offsets.ValuesOf(aOffs: ClassOffsets): FltArray;
begin
  result := Utils.NewFltArray(length(aOffs));
  for i := low(aOffs) to high(aOffs) do
    result[i] := ValueAt(aOffs, i);
end;

method Offsets.ValuesOf(aInts: IntArray; aOffs: ClassOffsets): FltArray;
require
  length(aInts) = length(aOffs)
begin
  result := Utils.NewFltArray(length(aInts));
  for i := low(aInts) to high(aInts) do
    result[i] := aInts[i] + aOffs[i];
end;

method Offsets.ValuesOf(aOffs: IntOffsets): FltArray;
begin
  result := Utils.NewFltArray(length(aOffs));
  for i := low(aOffs) to high(aOffs) do
    result[i] := Values.FltSingle(aOffs[i]);
end;

method Offsets.ClassToIntOffsets(aOffs: ClassOffsets): IntOffsets;
begin
  var lCount := Count(aOffs);
  result := new IntOffset[lCount];
  var x := 0;
  for i := low(aOffs) to high(aOffs) do
    if Defined(aOffs, i) then
      begin
        result[x] := IntOffAt(aOffs, i);
        inc(x);
      end;
end;

method Offsets.IntOffsets(aInts: IntArray; aFlts: FltArray := nil): IntOffsets;
begin
  result := new IntOffset[length(aInts)];
  for i := low(aInts) to high(aInts) do
    begin
      result[i].Int := aInts[i];
      result[i].Off :=
        if low(aFlts) <= i <= high(aFlts) then aFlts[i]
        else 0.0;
    end;
end;

method Offsets.FltToOffsets(aFlts: FltArray): ClassOffsets;
begin
  result := Offsets.NewClassOffsets(length(aFlts));
  for i := low(aFlts) to high(aFlts) do
    if Defined(aFlts, i) then
      result[i] := aFlts[i] - i;
end;

method Offsets.IntToClassOffsets(aOffs: IntOffsets; aLength: Integer): ClassOffsets;
begin
  result := NewClassOffsets(aLength);
  for each lOff in aOffs do
    result[lOff.Int] := lOff.Off;
end;

method Offsets.IntOffsetsToStr(aOffs: IntOffsets; aInvariant: Boolean := true): String;
begin
  var sb := new StringBuilder;
  for i := low(aOffs) to high(aOffs) do
    begin
      sb.Append(Values.IntOffToStr(aOffs[i]));
      if i < high(aOffs) then
        sb.Append(Utils.Separator);
    end;
  result := sb.ToString;
end;

{$ENDREGION}

{$REGION DexiMultilinearModel}

constructor DexiMultilinearModel(aFunct: DexiTabularFunction);
require
  aFunct <> nil;
begin
  fFunct := aFunct;
  if not aFunct.CanUseMultilinear then
    raise new EDexiEvaluationError(DexiString.SDexiMultilinFunct);
  Setup;
end;

method DexiMultilinearModel.Setup;
begin
  var lDim := fFunct.Attribute.Dimension;
  fGrid := new FltArray[ArgCount];
  for i := 0 to ArgCount - 1 do
    fGrid[i] := Utils.IntToFltArray(Utils.RangeArray(lDim[i], 0));
  fValues := Utils.NewFltArray(fFunct.Count);
  for r := 0 to fFunct.Count - 1 do
    begin
      if not fFunct.RuleDefined[r] or (fFunct.RuleValLow[r] <> fFunct.RuleValLow[r]) then
        raise new EDexiEvaluationError(DexiString.SDexiMultilinFunct)
      else
        fValues[r] := fFunct.RuleValLow[r];
    end;
end;

method DexiMultilinearModel.Evaluate(aArgs: IntArray): Float;
begin
  result := Evaluate(Utils.IntToFltArray(aArgs));
end;

method DexiMultilinearModel.Evaluate(aArgs: FltArray): Float;
begin
  result := MultiLinear.MultilinearInterpolation(aArgs, fValues, fGrid);
end;

{$ENDREGION}

{$REGION DexiQModel}

constructor DexiQModel(aFunct: DexiTabularFunction);
require
  aFunct <> nil;
begin
  fFunct := aFunct;
end;

{$ENDREGION}

{$REGION DexiQQ1Model}

constructor DexiQQ1Model(aFunct: DexiTabularFunction);
begin
  inherited constructor(aFunct);
  if ArgCount < 1 then
    raise new EDexiEvaluationError(DexiString.SDexiQQArgs);
  if ClassCount <= 1 then
    raise new EDexiEvaluationError(DexiString.SDexiQQOutValues);
  Funct.CalcActualWeights(true);
  fWeightFactors := Utils.CopyFltArray(Funct.WeightFactors);
  fClassK := Utils.NewFltArray(ClassCount);
  fClassN := Utils.NewFltArray(ClassCount);
  MapClasses;
end;

method  DexiQQ1Model.MapClasses;
begin
  var lMin :=  Utils.NewFltArray(ClassCount, Consts.MaxDouble);
  var lMax :=  Utils.NewFltArray(ClassCount, Consts.MinDouble);
  for r := 0 to Funct.Count - 1 do
    begin
      var lValue := Funct.RuleValue[r];
      if DexiValue.ValueIsDefined(lValue) and lValue.HasIntInterval then
        for c := 0 to ClassCount - 1 do
          if lValue.Member(c) then
            begin
              var lArgs := Utils.IntToFltArray(Funct.ArgValues[r]);
              var lMinusArgs := Utils.NewFltArray(ArgCount);
              var lPlusArgs := Utils.NewFltArray(ArgCount);
              for a := 0 to ArgCount - 1 do
                begin
                  lMinusArgs[a] := lArgs[a] - Math.Sign(fWeightFactors[a]) * 0.5;
                  lPlusArgs[a] := lArgs[a] + Math.Sign(fWeightFactors[a]) * 0.5;
                end;
              var lMinusVal := Regression(lMinusArgs);
              var lPlusVal := Regression(lPlusArgs);
              lMin[c] := Math.Min(lMin[c], lMinusVal);
              lMax[c] := Math.Max(lMax[c], lPlusVal);
            end;
    end;
  for c := 0 to ClassCount - 1 do
    begin
      fClassK[c] := if Utils.FloatEq(lMax[c], lMin[c]) then 0.0 else 1.0 / (lMax[c] - lMin[c]);
      fClassN[c] := c + 0.5 - fClassK[c] * lMax[c];
    end;
end;

method DexiQQ1Model.Regression(aArgs: IntArray): Float;
require
  length(aArgs) = ArgCount;
begin
  result := fWeightFactors[ArgCount];
  for i := 0 to ArgCount - 1 do
    result := result + aArgs[i] * fWeightFactors[i];
end;

method DexiQQ1Model.Regression(aArgs: FltArray): Float;
begin
  result := fWeightFactors[ArgCount];
  for i := 0 to ArgCount - 1 do
    result := result + aArgs[i] * fWeightFactors[i];
end;

method DexiQQ1Model.Evaluate(aArgs: IntArray; aClass: Integer): Float;
require
  0 <= aClass < ClassCount;
begin
  var lRegression := Regression(aArgs);
  result := fClassK[aClass] * lRegression + fClassN[aClass];
end;

method DexiQQ1Model.Evaluate(aArgs: FltArray; aClass: Integer): Float;
require
  0 <= aClass < ClassCount;
begin
  var lRegression := Regression(aArgs);
  result := fClassK[aClass] * lRegression + fClassN[aClass];
end;

method DexiQQ1Model.Evaluate(aArgs: IntArray): FltArray;
begin
  result := Offsets.NewClassOffsets(ClassCount);
  var lValue := Funct.Evaluate(aArgs);
  for c := 0 to ClassCount - 1 do
    if lValue.Member(c) then
      result[c] := Evaluate(aArgs, c);
end;

method DexiQQ1Model.Evaluate(aArgs: FltArray): FltArray;
begin
  result := Offsets.NewClassOffsets(ClassCount);
  var lValue := Funct.Evaluate(aArgs);
  for c := 0 to ClassCount - 1 do
    if lValue.Member(c) then
      result[c] := Evaluate(aArgs, c);
end;

{$ENDREGION}

{$REGION DexiOffAlternative}

constructor DexiOffAlternative(aName: String := ''; aDescription: String := '');
begin
  inherited constructor (aName, aDescription);
end;

constructor DexiOffAlternative(aAlt: IDexiAlternative);
begin
  constructor (aAlt.Name, aAlt.Description);
  fValues.RemoveAll;
  for each lAtt in aAlt.Attributes do
    if (lAtt:Scale <> nil) and (lAtt.Scale.Count > 0) and (lAtt.Scale is DexiDiscreteScale) then
      begin
        var lValue := aAlt[lAtt];
        AsDexiValue[lAtt] := lValue;
      end;
end;

method DexiOffAlternative.GetValue(aAtt: DexiAttribute): ClassOffsets;
begin
  result := fValues[aAtt];
end;

method DexiOffAlternative.SetValue(aAtt: DexiAttribute; aValue: ClassOffsets);
begin
  fValues[aAtt] := aValue;
end;

method DexiOffAlternative.SetAsInt(aAtt: DexiAttribute; aInt: Integer);
begin
  var lOffs := Offsets.NewClassOffsets(aAtt);
  lOffs[aInt] := 0.0;
  Value[aAtt] := lOffs;
end;

method DexiOffAlternative.GetAsFloat(aAtt: DexiAttribute): Float;
begin
  var lOffs := Value[aAtt];
  result := Offsets.SingleValue(lOffs);
end;

method DexiOffAlternative.SetAsFloat(aAtt: DexiAttribute; aFloat: Float);
begin
  var lOffs := Offsets.NewClassOffsets(aAtt);
  var lOff := Values.IntOff(aFloat, Rounding);
  lOffs[lOff.Int] := lOff.Off;
  Value[aAtt] := lOffs;
end;

method DexiOffAlternative.SetAsIntOff(aAtt: DexiAttribute; aOff: IntOffset);
begin
  var lOffs := Offsets.NewClassOffsets(aAtt);
  lOffs[aOff.Int] := aOff.Off;
  Value[aAtt] := lOffs;
end;

method DexiOffAlternative.GetAsIntOffsets(aAtt: DexiAttribute): IntOffsets;
begin
  var lOffs := Value[aAtt];
  result := Offsets.ClassToIntOffsets(lOffs);
end;

method DexiOffAlternative.SetAsIntOffsets(aAtt: DexiAttribute; aOffs: IntOffsets);
begin
  var lOffs := Offsets.NewClassOffsets(aAtt);
  lOffs := Offsets.IntToClassOffsets(aOffs, length(lOffs));
  Value[aAtt] := lOffs;
end;

method DexiOffAlternative.SetAsDexiValue(aAtt: DexiAttribute; aValue: DexiValue);
begin
  fValues.Remove(aAtt);
  if aValue = nil then
    exit;
  var lOffs := Offsets.NewClassOffsets(aAtt);
  if (lOffs = nil) or not aValue.IsDefined then
    exit;
  if aValue.IsFloat then
    if aValue.HasFltSingle then
      AsFloat[aAtt] := aValue.AsFloat
    else {nothing}
  else if aValue.HasIntSingle then
    AsInt[aAtt] := aValue.AsInteger
  else
    begin
      var lSet := aValue.AsIntSet;
      for each lEl in lSet do
        lOffs[lEl] := 0.0;
      Value[aAtt] := lOffs;
    end;
end;

method DexiOffAlternative.GetAsString(aAtt: DexiAttribute): String;
begin
  var lOffs := Value[aAtt];
  var lIntOffs := Offsets.ClassToIntOffsets(lOffs);
  result := Offsets.IntOffsetsToStr(lIntOffs);
end;

method DexiOffAlternative.Copy: DexiOffAlternative;
begin
  result := new DexiOffAlternative(Name, Description);
  for each lAtt in fValues.Keys do
    result[lAtt] := Utils.CopyFltArray(Value[lAtt]);
end;

method DexiOffAlternative.ExcludeAttribute(aAtt: DexiAttribute);
begin
  fValues.Remove(aAtt);
end;

method DexiOffAlternative.UseAttributes(aAtts: DexiAttributeList);
begin
  if aAtts = nil then
    fValues.RemoveAll
  else
    for each lAtt in fValues.Keys do
      if not aAtts.Contains(lAtt) then
        ExcludeAttribute(lAtt);
end;

{$ENDREGION}

{$REGION DexiQEvaluator}

constructor DexiQEvaluator(aModel: DexiModel);
begin
  inherited constructor (aModel);
end;

method DexiQEvaluator.IsTerminal(aAtt: DexiAttribute): Boolean;
begin
  result :=
    inherited IsTerminal(aAtt) or
    (aAtt.IsAggregate and (aAtt.InpCount = 1) and (aAtt.Inputs[0]:Scale is DexiContinuousScale));
end;


method DexiQEvaluator.FunctModel(aFunct: DexiTabularFunction): DexiQModel;
begin
  if aFunct = nil then
    result := nil
  else if fFunctModels.ContainsKey(aFunct) then
    result := fFunctModels[aFunct]
  else
    begin
      result := NewFunctModel(aFunct);
      if result <> nil then
        fFunctModels.Add(aFunct, result);
    end;
end;

method DexiQEvaluator.GetArgumentOffsets(aAlt: DexiOffAlternative; aAtt: DexiAttribute): ClassOffsetsArray;
begin
  result := new ClassOffsets[aAtt.InpCount];
  for i := 0 to aAtt.InpCount - 1 do
    result[i] := aAlt[aAtt.Inputs[i]];
end;

method DexiQEvaluator.MakeInpList(aOffs: ClassOffsetsArray): List<IntArray>;
var
  lList := new List<IntArray>;
  lLen := length(aOffs);
  lHigh := high(aOffs);
  lCurrent := Utils.NewIntArray(lLen);

  method TraverseIndex(aIdx: Integer);
  begin
    if aIdx > lHigh then
      exit;
    for i := low(aOffs[aIdx]) to high(aOffs[aIdx]) do
      begin
        lCurrent[aIdx] := i;
        var v := aOffs[aIdx][i];
        if not Consts.IsNaN(v) then
          if aIdx < lHigh then
            TraverseIndex(aIdx + 1)
          else
            lList.Add(Utils.CopyIntArray(lCurrent));
      end;
  end;

begin
  TraverseIndex(0);
  result := lList;
end;

method DexiQEvaluator.InpOffsets(aArgs: ClassOffsetsArray; aInps: IntArray): ClassOffsets;
require
  length(aArgs) = length(aInps);
begin
  result := Offsets.NewClassOffsets(length(aInps));
  for i := low(aInps) to high(aInps) do
    result[i] := aArgs[i][aInps[i]];
end;

method DexiQEvaluator.InpValues(aArgs: ClassOffsetsArray; aInps: IntArray): FltArray;
begin
  var lOffs := InpOffsets(aArgs, aInps);
  result := Offsets.ValuesOf(aInps, lOffs);
end;

method DexiQEvaluator.FunctModelEvaluation(aQModel: DexiQModel; aArgs: ClassOffsetsArray; aList: List<IntArray>): ClassOffsets;
begin
  if aList.Count = 0 then
    result := nil
  else if aList.Count = 1 then
    begin
      var lVals := InpValues(aArgs, aList[0]);
      result :=  aQModel.Evaluate(lVals);
    end
  else
    begin
      var lNum := Utils.NewIntArray(aQModel.ClassCount);
      var lSum := Utils.NewFltArray(aQModel.ClassCount);
      for each lInps in aList do
        begin
          var lVals := InpValues(aArgs, lInps);
          var lEval := aQModel.Evaluate(lVals);
          for i := low(lEval) to high(lEval) do
            if not Consts.IsNaN(lEval[i]) then
              begin
                inc(lNum[i]);
                lSum[i] := lSum[i] + lEval[i];
              end;
        end;
      result := Offsets.NewClassOffsets(length(lSum));
      for i := low(lSum) to high(lSum) do
        if lNum[i] > 0 then
          result[i] := lSum[i] / lNum[i];
    end;
end;

method DexiQEvaluator.EvaluateAggregate(aAlt: DexiOffAlternative; aAtt: DexiAttribute): ClassOffsets;
begin
  result := nil;
  if (aAlt <> nil) and (aAtt:Scale <> nil) and (aAtt:Funct <> nil) and (aAtt.Funct is DexiTabularFunction) then
    begin
      var lFunct := aAtt.Funct as DexiTabularFunction;
      var lFunctModel := FunctModel(lFunct);
      if lFunctModel = nil then
        exit;
      var lArgOffsets := GetArgumentOffsets(aAlt, aAtt);
      var lInpList := MakeInpList(lArgOffsets);
      if lInpList.Count = 0 then
        exit;
      result := FunctModelEvaluation(lFunctModel, lArgOffsets, lInpList);
      for c := 1 to high(result) do
        result[c] := result[c] - c;
    end;
end;

method DexiQEvaluator.EvaluateAttribute(aAlt: DexiOffAlternative; aAtt: DexiAttribute);
begin
  var lOffs: ClassOffsets := nil;
  if aAtt.Link <> nil then
    begin
      EvaluateAttribute(aAlt, aAtt.Link);
      lOffs := Utils.CopyFltArray(aAlt[aAtt.Link]);
    end
  else if IsTerminal(aAtt) then
    lOffs := aAlt[aAtt]
  else
    begin
      for i := 0 to aAtt.InpCount - 1 do
        EvaluateAttribute(aAlt, aAtt.Inputs[i]);
      lOffs := EvaluateAggregate(aAlt, aAtt);
    end;
  aAlt[aAtt] := lOffs;
end;

method DexiQEvaluator.Evaluate(aAlt: DexiOffAlternative; aRoot: DexiAttribute := nil);
begin
  if aRoot = nil then
    aRoot := Model.Root;
  EvaluateAttribute(aAlt, aRoot);
end;

method DexiQEvaluator.Evaluate(aAlts: sequence of DexiOffAlternative; aRoot: DexiAttribute := nil);
begin
  for lAlt in aAlts do
    Evaluate(lAlt, aRoot);
end;

{$ENDREGION}

{$REGION DexiQQEvaluator}

method DexiQQEvaluator.NewFunctModel(aFunct: DexiTabularFunction): DexiQModel;
begin
  result := new DexiQQ1Model(aFunct);
end;

{$ENDREGION}

end.
