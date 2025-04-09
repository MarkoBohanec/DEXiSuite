// DexiQQ2.pas is part of
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
// DexiQQ2.pas implements Quadratic-Programming Qualitative-Quantitative Evaluation using offsets.
// The method aims at improving the disadvantages of DexiQQ that:
// - relies on weights, which are inappropriate for non-monotone or non-linear functions,
// - weights limit the flexibility of hyperplane slopes, resulting in a non-optimal discrimination
//   between rules.
// Main idea:
//   Evaluation value is represented by an offset of the form off = ord(class) + offset,
//   exactly as with DexiQQ.
// Method sketch for each tabular function F:
//   For each class solve a Quadratic Program so as to position quantitive values
//   corresponding to rules vertically in an optimal way.
// ----------

{.DEFINE QPTRACE}  // write while executing

namespace DexiLibrary;

interface

 uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  PathGraphRow = array of nullable Integer;
  PathGraphMatrix = array of PathGraphRow;

type
  PathGraph = public class
  private
    fDimensions: List<String>;
    fIndices: IntArray;
    fGraph: PathGraphMatrix;
  protected
    method GetElement(aIdx1, aIdx2: Integer): nullable Integer;
    method SetElement(aIdx1, aIdx2: Integer; aValue: nullable Integer);
    method GetUpward(aIdx1, aIdx2: Integer): Integer;
    method GetDownward(aIdx1, aIdx2: Integer): Integer;
    method MakeGraph(aFunct: DexiTabularFunction; aDistance: IntDistance); virtual;
  public
    class method NewGraphRow(const aLen: Integer; const aInit: nullable Integer := nil): PathGraphRow;
    class method NewGraph(const aLen1, aLen2: Integer; const aInit: nullable Integer := nil): PathGraphMatrix;
    class method Neighbor(aTransitiveReduction: IntMatrix; aIdx1, aIdx2: Integer): Boolean;
    class method PathGraphToString(aGraph: PathGraph; aMatrix: PathGraphMatrix := nil): String;
    class method PathMatrixToString(aGraph: PathGraph; aMatrix: IntMatrix): String;
    constructor (aCount: Integer; aIndices: IntArray := nil; aDimensions: List<String> := nil);
    constructor (aDimensions: List<String>; aIndices: IntArray := nil);
    constructor (aIndices: IntArray; aDimensions: List<String> := nil);
    constructor (aFunct: DexiTabularFunction; aIndices: IntArray := nil; aDistance: IntDistance := nil);
    method IndicesToDimensions;
    method TransitiveReduction(aUpward: Boolean): IntMatrix;
    property Dimensions: List<String> read fDimensions write fDimensions;
    property Indices: IntArray read fIndices write fIndices;
    property Graph: PathGraphMatrix read fGraph write fGraph;
    property Row[aIdx: Integer]: PathGraphRow read fGraph[aIdx] write fGraph[aIdx];
    property Element[aIdx1, aIdx2: Integer]: nullable Integer read GetElement write SetElement; default;
    property Upward[aIdx1, aIdx2: Integer]: Integer read GetUpward;
    property Downward[aIdx1, aIdx2: Integer]: Integer read GetDownward;
    property Count: Integer read length(fGraph);
  end;

type
  ExtendedPathGraph = public class (PathGraph)
  protected
  public
    class method ExtendedGraphRow(aRow: PathGraphRow; aDim: Integer; aIndices: IntArray): PathGraphRow;
    constructor (aGraph: PathGraph; aDim: Integer; aIndices: IntArray := nil);
  end;

type
  DexiQQ2Model = public class (DexiQModel)
  private
    fQP: FltMatrix;
    fGaps: FltMatrix;
    fGraph: PathGraph;
    fTransitive: IntMatrix;
    fUnordered: IntArray;
    fOrderedMask: IntArray;
  protected
    method UnorderedAttributes: IntArray;
    method OrderedMask(aUnordered: IntArray): IntArray;
    method TransformLevels(aLevels: FltArray; aMaxGap: Float): FltArray;
    method SolveQP(aRules: IntArray): FltArray;
    method CalculateGaps;
    method MapPartition(aClass: Integer; aArgs, aArgVals: IntArray);
    method MapPartitions(aArgs, aArgVals: IntArray);
    method MapClasses;
  public
    class const DefaultSkew = 0.01;   
    constructor (aFunct: DexiTabularFunction);
    property QP: FltMatrix read fQP;
    property Gaps: FltMatrix read fGaps;
    property Graph: PathGraph read fGraph;
    property Transitive: IntMatrix read fTransitive;
    property Unordered: IntArray read fUnordered;
    property OrderedMask: IntArray read fOrderedMask;
    property OrderedCount: Integer read ArgCount - length(fUnordered);
    property Skew := DefaultSkew;
    method FunctionValue(aRule: Integer; aOffs: FltArray; aClass: Integer): Float;
    method FunctionValue(aRule: Integer; aOffs: FltArray): FltArray;
    method Evaluate(aArgs: IntArray; aOffs: FltArray; aClass: Integer): Float; virtual;
    method Evaluate(aArgs: IntArray; aOffs: FltArray): FltArray; virtual;
    method Evaluate(aArgs: IntArray; aClass: Integer): Float; override;
    method Evaluate(aArgs: FltArray; aClass: Integer): Float; override;
    method Evaluate(aArgs: IntArray): FltArray; override;
    method Evaluate(aArgs: FltArray): FltArray; override;
    method Evaluate(aArgs: FltArray; aClass: Integer; aRound: OffsetRounding): Float; virtual;
    method Evaluate(aArgs: FltArray; aRound: OffsetRounding): FltArray; virtual;
  end;

type
  DexiQQ2Evaluator = public class (DexiQEvaluator)
  protected
    method NewFunctModel(aFunct: DexiTabularFunction): DexiQModel; override;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION PathGraph}

class method PathGraph.NewGraphRow(const aLen: Integer; const aInit: nullable Integer := nil): PathGraphRow;
begin
  result := new (nullable Integer)[aLen];
  for i := low(result) to high(result) do
    result[i] := aInit;
end;

class method PathGraph.NewGraph(const aLen1, aLen2: Integer; const aInit: nullable Integer := nil): PathGraphMatrix;
begin
  result := new PathGraphRow[aLen1];
  for i := low(result) to high(result) do
    result[i] := NewGraphRow(aLen2, aInit);
end;

class method PathGraph.Neighbor(aTransitiveReduction: IntMatrix; aIdx1, aIdx2: Integer): Boolean;
begin
  result := (aTransitiveReduction[aIdx1][aIdx2] > 0) or (aTransitiveReduction[aIdx2][aIdx1] > 0);
end;

class method PathGraph.PathGraphToString(aGraph: PathGraph; aMatrix: PathGraphMatrix := nil): String;
begin
  if aMatrix = nil then
    aMatrix := aGraph.Graph;
  var sb := new StringBuilder;
  var lMaxWidth := 0;
  var lWidths := Utils.NewIntArray(aGraph.Count, 0);
  for i := 0 to aGraph.Count - 1 do
    begin
      var lWidth := Math.Max(aGraph.Dimensions[i].Length, 3);
      for j := 0 to aGraph.Count - 1 do
        lWidth := Math.Max(lWidth, Utils.NullableIntToStr(aMatrix[i][j]).Length);
      inc(lWidth);
      lWidths[i] := lWidth;
      lMaxWidth := Math.Max(lMaxWidth, lWidth);
    end;
  inc(lMaxWidth);
  sb.Append(Utils.ChStr(lMaxWidth));
  for j := 0 to aGraph.Count - 1 do
    begin
      sb.Append(Utils.PadRight(aGraph.Dimensions[j], lWidths[j]));
    end;
  sb.AppendLine;
  for i := 0 to aGraph.Count - 1 do
    begin
      sb.Append(Utils.PadTo(aGraph.Dimensions[i], lMaxWidth));
      for j := 0 to aGraph.Count - 1 do
        sb.Append(Utils.PadRight(Utils.NullableIntToStr(aMatrix[i][j]), lWidths[j]));
      sb.AppendLine;
    end;
  result := sb.ToString;
end;

class method PathGraph.PathMatrixToString(aGraph: PathGraph; aMatrix: IntMatrix): String;
begin
  var sb := new StringBuilder;
  var lMaxWidth := 0;
  var lWidths := Utils.NewIntArray(aGraph.Count, 0);
  for i := 0 to aGraph.Count - 1 do
    begin
      var lWidth := Math.Max(aGraph.Dimensions[i].Length, 3);
      for j := 0 to aGraph.Count - 1 do
        lWidth := Math.Max(lWidth, Utils.IntToStr(aMatrix[i][j]).Length);
      inc(lWidth);
      lWidths[i] := lWidth;
      lMaxWidth := Math.Max(lMaxWidth, lWidth);
    end;
  inc(lMaxWidth);
  sb.Append(Utils.ChStr(lMaxWidth));
  for j := 0 to aGraph.Count - 1 do
    begin
      sb.Append(Utils.PadRight(aGraph.Dimensions[j], lWidths[j]));
    end;
  sb.AppendLine;
  for i := 0 to aGraph.Count - 1 do
    begin
      sb.Append(Utils.PadTo(aGraph.Dimensions[i], lMaxWidth));
      for j := 0 to aGraph.Count - 1 do
        sb.Append(Utils.PadRight(Utils.IntToStr(aMatrix[i][j]), lWidths[j]));
      sb.AppendLine;
    end;
  result := sb.ToString;
end;

constructor PathGraph(aCount: Integer; aIndices: IntArray := nil; aDimensions: List<String> := nil);
require
  aCount >= 0;
begin
  fGraph := NewGraph(aCount, aCount);
  fIndices :=
    if aIndices = nil then Utils.RangeArray(aCount, 0)
    else Utils.CopyIntArray(aIndices);
  if aDimensions = nil then
    IndicesToDimensions
  else
    fDimensions := aDimensions;
end;

constructor PathGraph(aDimensions: List<String>; aIndices: IntArray := nil);
begin
  constructor (aDimensions.Count, aIndices, aDimensions);
end;

constructor PathGraph(aIndices: IntArray; aDimensions: List<String> := nil);
begin
  constructor (length(aIndices), aIndices, aDimensions);
end;

constructor PathGraph(aFunct: DexiTabularFunction; aIndices: IntArray := nil; aDistance: IntDistance := nil);
require
  aFunct <> nil;
begin
  if aIndices = nil then
    aIndices := Utils.RangeArray(aFunct.Count, 0);
  var aDimensions := new List<String> withCapacity(length(aIndices));
  for i := low(aIndices) to high(aIndices) do
    aDimensions.Add($"{i}: {Utils.IntArrayToStr(aFunct.ArgValues[aIndices[i]])}");
  constructor (aIndices, aDimensions);
  MakeGraph(aFunct, aDistance);
end;

method PathGraph.GetElement(aIdx1, aIdx2: Integer): nullable Integer;
begin
  result := fGraph[aIdx1][aIdx2];
end;

method PathGraph.SetElement(aIdx1, aIdx2: Integer; aValue: nullable Integer);
begin
  fGraph[aIdx1][aIdx2] := aValue;
end;

method PathGraph.GetUpward(aIdx1, aIdx2: Integer): Integer;
begin
  var lElement := Element[aIdx1, aIdx2];
  result :=
    if (lElement = nil) or (lElement <= 0) then 0
    else lElement;
end;

method PathGraph.GetDownward(aIdx1, aIdx2: Integer): Integer;
begin
  var lElement := Element[aIdx1, aIdx2];
  result :=
    if (lElement = nil) or (lElement >= 0) then 0
    else -lElement;
end;

method PathGraph.MakeGraph(aFunct: DexiTabularFunction; aDistance: IntDistance);
begin
  if aDistance = nil then
    aDistance := @Utils.HammingDistance;
  for i := low(fIndices) to high(fIndices) do
  for j := low(fIndices) to high(fIndices) do
    if i = j then
      Element[i, j] := 0
    else
      begin
        var fCompare := aFunct.CompareRules(i, j);
        if fCompare = PrefCompare.No then
          Element[i, j] := nil
        else
          begin
            var lDistance := aDistance(aFunct.ArgValues[i], aFunct.ArgValues[j]);
            if fCompare = PrefCompare.Greater then
              lDistance := - lDistance;
            Element[i, j] := lDistance;
          end;
      end;
end;

method PathGraph.IndicesToDimensions;
begin
  fDimensions := new List<String> withCapacity(length(fIndices));
  for i := low(fIndices) to high(fIndices) do
    fDimensions.Add(Utils.IntToStr(fIndices[i]));
end;

// Reduce connections, preserving only non-transitive connections (a.k.a. Hsu algorithm)
method PathGraph.TransitiveReduction(aUpward: Boolean): IntMatrix;
begin
  result := Utils.NewIntMatrix(Count, Count, 0);
  for i := 0 to Count - 1 do
    for j := 0 to Count - 1 do
      result[i][j] := 
        if aUpward then Upward[i, j]
        else Downward[i, j];
  for j := 0 to Count - 1 do
    for i := 0 to Count - 1 do
      if result[i][j] > 0 then
        for k := 0 to Count - 1 do
          if result[j][k] > 0 then
            result[i][k] := 0;
end;

{$ENDREGION}

{$REGION ExtendedPathGraph}

class method ExtendedPathGraph.ExtendedGraphRow(aRow: PathGraphRow; aDim: Integer; aIndices: IntArray): PathGraphRow;
begin
  result := NewGraphRow(length(aIndices) + 2);
  result[0] := -aDim;
  for i := low(aIndices) to high(aIndices) do
    result[i + 1] := aRow[aIndices[i]];
  result[high(result)] := aDim;
end;

constructor ExtendedPathGraph(aGraph: PathGraph; aDim: Integer; aIndices: IntArray := nil);
begin
  if aIndices = nil then
    aIndices := Utils.RangeArray(aGraph.Count, 0);
  var lNewLength := length(aIndices) + 2;
  inherited constructor (lNewLength);
  var lDimensions := new List<String>;
  lDimensions.Add('L');
  for i := low(aIndices) to high(aIndices) do
    lDimensions.Add(aGraph.Dimensions[aIndices[i]]);
  lDimensions.Add('U');
  Dimensions := lDimensions;
  var lIndices := Utils.ConcatenateIntArrays([-1], aIndices);
  lIndices := Utils.ConcatenateIntArrays(lIndices, [-1]);
  Indices := lIndices;
  Row[0] := NewGraphRow(Count, aDim);
  Element[0, 0] := 0;
  for i := low(aIndices) to high(aIndices) do
    Row[i + 1] := ExtendedGraphRow(aGraph.Row[aIndices[i]], aDim, aIndices);
  Row[Count - 1] := NewGraphRow(Count, -aDim);
  Element[Count - 1, Count - 1] := 0;
end;

{$ENDREGION}

{$REGION DexiQQ2Model}

constructor DexiQQ2Model(aFunct: DexiTabularFunction);
begin
  inherited constructor(aFunct);
  if ArgCount < 1 then
    raise new EDexiEvaluationError(DexiString.SDexiQQArgs);
  if ClassCount <= 1 then
    raise new EDexiEvaluationError(DexiString.SDexiQQOutValues);
  fQP := Utils.NewFltMatrix(ClassCount, aFunct.Count, Consts.NaN);
  fGaps := Utils.NewFltMatrix(ClassCount, aFunct.Count, Consts.NaN);
  fGraph := new PathGraph(aFunct);
  fTransitive := fGraph.TransitiveReduction(true);
  fUnordered := UnorderedAttributes;
  fOrderedMask := OrderedMask(fUnordered);
  MapClasses;
  CalculateGaps;
end;

method DexiQQ2Model.UnorderedAttributes: IntArray;
begin
  var lAtt := Funct.Attribute;
  var lUnordered := lAtt.UnorderedInputs;
  result := Utils.NewIntArray(lUnordered.Count);
  for i := 0 to lUnordered.Count - 1 do
    result[i] := lAtt.InpIndex(lUnordered[i]);
end;

method DexiQQ2Model.OrderedMask(aUnordered: IntArray): IntArray;
begin
  result := Utils.NewIntArray(ArgCount, 1);
  for i := low(aUnordered) to high(aUnordered) do
    result[aUnordered[i]] := 0;
end;

{$IFDEF QPTRACE}
method FltArrayString(aArr: FltArray; aLen: Integer := 5; aDec: Integer := 2): String;
begin
  var sb := new StringBuilder;
  for i := low(aArr) to high(aArr) do
    begin
      if i > 0 then
        sb.Append(' ');
      sb.Append(Utils.PadRight(Utils.FltToStr(aArr[i], aDec), aLen));
    end;
  result := sb.ToString;
end;
{$ENDIF}

method DexiQQ2Model.TransformLevels(aLevels: FltArray; aMaxGap: Float): FltArray;
begin
  var lMinVal := aMaxGap / 2.0;
  var lMaxVal := Values.MaxValue(aLevels) - aMaxGap;
  result := Utils.NewFltArray(length(aLevels) - 2);
  for i := low(result) to high(result) do
    result[i] := (aLevels[i + 1] - lMinVal) / lMaxVal - 0.5;
end;

method DexiQQ2Model.SolveQP(aRules: IntArray): FltArray;
begin
  var lExtended := new ExtendedPathGraph(fGraph, OrderedCount, aRules);
  var lTransitive := lExtended.TransitiveReduction(true);
  var lMax := Consts.MinDouble;
  var lConn := 0;
  for i := low(lTransitive) to high(lTransitive) do
    for j := low(lTransitive) to high(lTransitive) do
      begin
        lMax := Math.Max(lMax, lTransitive[i][j]);
        if lTransitive[i][j] > 0 then
          inc(lConn);
      end;
  {$IFDEF QPTRACE}
  writeLn("Extended");
  writeLn(PathGraph.PathGraphToString(lExtended));
  writeLn("Transitive");
  writeLn(PathGraph.PathMatrixToString(lExtended, lTransitive));
  writeLn($"Max : {lMax}");
  writeLn($"Conn: {lConn}");
  writeln;
  {$ENDIF}

  var n := lExtended.Count;

  var G := Utils.NewFltMatrix(n, n, 0.0);
  var CI := Utils.NewFltMatrix(n, lConn, 0.0);
  var g0 := Utils.NewFltArray(n, 0.0);
  var ci0 := Utils.NewFltArray(lConn, 0.0);
  var CE := Utils.NewFltMatrix(n, 1, 0.0);
  CE[0] := [1.0];
  var ce0 := [0.0];

  for i := 0 to n - 1 do
    begin
      var nc := 0;
      for j := 0 to n - 1 do
        if (lTransitive[i][j] > 0) or  (lTransitive[j][i] > 0) then
          inc(nc);
      G[i][i] := nc;
    end;
  G[0][0] := G[0][0] + Skew;
  G[n - 1][n - 1] := G[n - 1][n - 1] + Skew;
  var p := 0;
  for i := 0 to n - 1 do
    for j := 0 to n - 1 do
      if lTransitive[i][j] > 0 then
        begin
          G[i][j] := -1;
          G[j][i] := -1;
          CI[i][p] := -1;
          CI[j][p] := +1;
          ci0[p] := -lTransitive[i][j]; // alernative: -1.0
          inc(p);
        end;

  {$IFDEF QPTRACE}
  writeLn("G");
  for i := 0 to high(G) do
    writeLn($"G[{i}]:   {FltArrayString(G[i])}");
  writeLn;
  writeLn($"g0:     {FltArrayString(g0)}");
  writeLn;
  writeLn("CI");
  for i := 0 to high(CI) do
    writeLn($"CI[{i}]:  {FltArrayString(CI[i])}");
  writeLn;
  writeLn($"ci0:    {FltArrayString(ci0)}");
  writeLn;
  for i := 0 to high(CE) do
    writeLn($"CE[{i}]:  {FltArrayString(CE[i])}");
  writeLn;
  writeLn($"ce0:    {FltArrayString(ce0)}");
  writeLn;
  {$ENDIF}

  var f: Float;
  var x, u: FltArray;
  var a: IntArray;
  var q: Integer;
  DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);

  var lTransform := TransformLevels(x, lMax);

  {$IFDEF QPTRACE}
  writeLn($'Solution:  {FltArrayString(x)}');
  writeLn($'Value:     {f}');
  writeLn($'Transform: {FltArrayString(lTransform)}');
  readLn;
  {$ENDIF}

  result := lTransform;
end;

method DexiQQ2Model.MapPartition(aClass: Integer; aArgs, aArgVals: IntArray);
begin
  var lRules := Funct.SelectRules(true, aArgs, aArgVals, aClass);
  {$IFDEF QPTRACE}
  writeLn;
  writeLn($"Mapping partition for class {aClass}: {Utils.IntArrayToStr(aArgs)} {Utils.IntArrayToStr(aArgVals)}");
  writeLn($"Rules: {Utils.IntArrayToStr(lRules)}");
  writeLn;
  {$ENDIF}
  if length(lRules) = 0 then
    exit;
  var lQPvalues :=
    if length(lRules) = 1 then [0.0]
    else SolveQP(lRules);
  for i := low(lQPvalues) to high(lQPvalues) do
    fQP[aClass][lRules[i]] := lQPvalues[i];
end;

method DexiQQ2Model.MapPartitions(aArgs, aArgVals: IntArray);
begin
  for c := 0 to ClassCount - 1 do
    MapPartition(c, aArgs, aArgVals);
end;

method DexiQQ2Model.CalculateGaps;
require
  Funct.Count = fGraph.Count;
begin
  for r := 0 to Funct.Count - 1 do
    if Funct.RuleDefined[r] then
      for c := Funct.RuleValLow[r] to Funct.RuleValHigh[r] do
        begin
          var lQPValue := QP[c][r];
          if Consts.IsNaN(lQPValue) then
            continue;
          var lDiff := 0.5 - Math.Abs(lQPValue);
          for i := 0 to Funct.Count - 1 do
            if not Consts.IsNaN(QP[c][i]) then
              begin
                var lNeighbor := PathGraph.Neighbor(fTransitive, r, i);
                if lNeighbor then
                  lDiff := Math.Min(lDiff, OrderedCount * Math.Abs(lQPValue - QP[c][i])/2.0);
              end;
          fGaps[c][r] := lDiff;
        end;
end;

method DexiQQ2Model.MapClasses;
begin
  if length(fUnordered) = 0 then
    MapPartitions([], [])
  else
    begin
      var lLow := Utils.NewIntArray(length(fUnordered), 0);
      var lHigh := Utils.NewIntArray(length(fUnordered), 0);
      for i := low(fUnordered) to high(fUnordered) do
        lHigh[i] := Funct.Attribute.Inputs[fUnordered[i]].Scale.Count - 1;
      var lVectors := new Vectors(lLow, lHigh);
      repeat
        MapPartitions(fUnordered, lVectors.Vector);
      until not lVectors.Next;
    end;
end;

method DexiQQ2Model.FunctionValue(aRule: Integer; aOffs: FltArray; aClass: Integer): Float;
require
  Funct <> nil;
  0 <= aRule < Funct.Count;
  0 <= aClass < ClassCount;
begin
  var lValue := QP[aClass][aRule];
  var lGap := Gaps[aClass][aRule];
  if Consts.IsNaN(lValue) or Consts.IsNaN(lGap) then
    exit Consts.NaN;
  result := aClass + lValue;
  for i := low(aOffs) to high(aOffs) do
    if fOrderedMask[i] > 0 then
      result := result + 2.0 * aOffs[i] * lGap / OrderedCount;
end;

method DexiQQ2Model.FunctionValue(aRule: Integer; aOffs: FltArray): FltArray;
begin
  result := Offsets.NewClassOffsets(ClassCount);
  for c := 0 to ClassCount - 1 do
    result[c] := FunctionValue(aRule, aOffs, c);
end;

method DexiQQ2Model.Evaluate(aArgs: IntArray; aOffs: FltArray; aClass: Integer): Float;
begin
  var lRule := Funct.IndexOfRule(aArgs);
  result :=
    if lRule < 0 then nil
    else FunctionValue(lRule, aOffs, aClass);
end;

method DexiQQ2Model.Evaluate(aArgs: IntArray; aOffs: FltArray): FltArray;
begin
  var lRule := Funct.IndexOfRule(aArgs);
  result :=
    if lRule < 0 then nil
    else FunctionValue(lRule, aOffs);
end;

method DexiQQ2Model.Evaluate(aArgs: IntArray): FltArray;
begin
  var lOffs := Utils.NewFltArray(ArgCount, 0.0);
  result := Evaluate(aArgs, lOffs);
end;

method DexiQQ2Model.Evaluate(aArgs: IntArray; aClass: Integer): Float;
begin
  var lOffs := Utils.NewFltArray(ArgCount, 0.0);
  result := Evaluate(aArgs, lOffs, aClass);
end;

method DexiQQ2Model.Evaluate(aArgs: FltArray; aClass: Integer): Float;
begin
  result := Evaluate(aArgs, aClass, OffsetRounding.Down);
end;

method DexiQQ2Model.Evaluate(aArgs: FltArray): FltArray;
begin
  result := Evaluate(aArgs, OffsetRounding.Down);
end;

method DexiQQ2Model.Evaluate(aArgs: FltArray; aClass: Integer; aRound: OffsetRounding): Float;
begin
  var lArgs := Utils.NewIntArray(length(aArgs));
  var lOffs := Utils.NewFltArray(length(aArgs));
  for i := low(aArgs) to high(aArgs) do
    begin
      var lOff := Values.IntOff(aArgs[i], aRound);
      lArgs[i] := lOff.Int;
      lOffs[i] := lOff.Off;
    end;
  result := Evaluate(lArgs, lOffs, aClass);
end;

method DexiQQ2Model.Evaluate(aArgs: FltArray; aRound: OffsetRounding): FltArray;
begin
  result := Offsets.NewClassOffsets(ClassCount);
  var lArgs := Utils.NewIntArray(length(aArgs));
  var lOffs := Utils.NewFltArray(length(aArgs));
  for i := low(aArgs) to high(aArgs) do
    begin
      var lOff := Values.IntOff(aArgs[i], aRound);
      lArgs[i] := lOff.Int;
      lOffs[i] := lOff.Off;
    end;
  for c := 0 to ClassCount - 1 do
    result[c] := Evaluate(lArgs, lOffs, c);
end;

{$ENDREGION}

{$REGION DexiQQ2Evaluator}

method DexiQQ2Evaluator.NewFunctModel(aFunct: DexiTabularFunction): DexiQModel;
begin
  result := new DexiQQ2Model(aFunct);
end;

{$ENDREGION}

end.
