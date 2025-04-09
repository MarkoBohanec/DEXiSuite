// DexiDecisionTrees.pas is part of
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
// DexiDecisionTrees.pas implements am ID3-inspired machine-learning algorithm for
// representing decision rules of a DexiTabularFunction with a decision tree.
// ----------

namespace DexiLibrary;

interface

 uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  SplitMeasure = public enum (InfGain, GiniGain);

type
  DecisionTreeNode = public class
  private
    fSplitOn: DexiAttribute;
    fAttIndex: Integer;
    fAttValues: IntArray;
    fClassValue: DexiValue;
    fRules: IntArray;
    fGains: FltArray;
    fSubtrees: List<DecisionTreeNode>;
  public
    constructor (aRules: IntArray);
    class method EqualSubtrees(aNode1, aNode2: DecisionTreeNode): Boolean;
    method AddSubtree(aNode: DecisionTreeNode);
    method BestGain: Integer;
    method MergeSubtrees;
    property SplitOn: DexiAttribute read fSplitOn write fSplitOn;
    property AttIndex: Integer read fAttIndex write fAttIndex;
    property AttValues: IntArray read fAttValues write fAttValues;
    property ClassValue: DexiValue read fClassValue write fClassValue;
    property Rules: IntArray read fRules;
    property Gains: FltArray read fGains write fGains;
    property Count: Integer read if fSubtrees = nil then 0 else fSubtrees.Count;
    property Subtree[aIdx: Integer]: DecisionTreeNode read fSubtrees[aIdx];
  end;

type
  DecisionTree = public class
  private
    fMeasure: SplitMeasure;
    fRoot: DecisionTreeNode;
    fFunct: DexiTabularFunction;
  protected
    method Impurity(aProb: FltArray): Float;
    method CalculateGains(aRules: IntArray; aAtts: SetOfInt): FltArray;
    method BestAttribute(aNode: DecisionTreeNode; aAtts: SetOfInt): Integer;
    method MergeSubtrees;
    method MakeValueTree(aNode: DecisionTreeNode; aAtts: SetOfInt);
  public
    constructor (aMeasure: SplitMeasure := SplitMeasure.InfGain);
    constructor (aFunct: DexiTabularFunction; aMeasure: SplitMeasure := SplitMeasure.InfGain);
    method MakeTree;
    method Evaluate(aArgs: IntArray): DexiValue;
    method CheckTree: Boolean;
    property Measure: SplitMeasure read fMeasure write fMeasure;
    property Root: DecisionTreeNode read fRoot;
    property Funct: DexiTabularFunction read fFunct write fFunct;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DecisionTreeNode}

constructor DecisionTreeNode(aRules: IntArray);
begin
  fRules := aRules;
  fSubtrees := new List<DecisionTreeNode>;
  fClassValue := nil;
end;

class method DecisionTreeNode.EqualSubtrees(aNode1, aNode2: DecisionTreeNode): Boolean;
begin
  result := true;
  if aNode1 = aNode2 then
    exit;
  if aNode1.Count <> aNode2.Count then
    exit false;
  if aNode1.SplitOn <> aNode2.SplitOn then
    exit false;
  if not DexiValue.ValuesAreEqual(aNode1.ClassValue, aNode2.ClassValue) then
    exit false;
  for i := 0 to aNode1.Count - 1 do
    if not EqualSubtrees(aNode1.Subtree[i], aNode2.Subtree[i]) then
      exit false;
end;

method DecisionTreeNode.AddSubtree(aNode: DecisionTreeNode);
begin
  fSubtrees.Add(aNode);
end;

method DecisionTreeNode.BestGain: Integer;
begin
  if length(fGains) = 0 then
    exit -1;
  result := 0;
  for i := 1 to high(fGains) do
    if fGains[i] > fGains[result] then
      result := i;
end;

method DecisionTreeNode.MergeSubtrees;
begin
  var x1 := 0;
  while x1 < Count - 1 do
    begin
      var x2 := x1 + 1;
      while x2 < Count  do
        begin
          if EqualSubtrees(Subtree[x1], Subtree[x2]) then
            begin
              Subtree[x1].AttValues := Utils.ConcatenateIntArrays(Subtree[x1].AttValues, Subtree[x2].AttValues);
              fSubtrees.RemoveAt(x2);
            end
          else
            inc(x2);
        end;
      inc(x1);
    end;
end;


{$ENDREGION}

{$REGION DecisionTree}

constructor DecisionTree(aMeasure: SplitMeasure := SplitMeasure.InfGain);
begin
  fMeasure := aMeasure;
  fFunct := nil;
  fRoot := nil;
end;

constructor DecisionTree(aFunct: DexiTabularFunction; aMeasure: SplitMeasure := SplitMeasure.InfGain);
begin
  constructor (aMeasure);
  fFunct := aFunct;
  MakeTree;
end;

method DecisionTree.Impurity(aProb: FltArray): Float;
begin
  result :=
    if fMeasure = SplitMeasure.InfGain then Utils.Entropy(aProb)
    else Utils.Gini(aProb);
end;

method DecisionTree.CalculateGains(aRules: IntArray; aAtts: SetOfInt): FltArray;
begin
  result := Utils.NewFltArray(fFunct.ArgCount);
  var n := length(aRules);
  if n = 0 then
    exit;
  var P0 := fFunct.ClassProb(aRules);
  var E0 := Impurity(P0);
  for a := 0 to fFunct.ArgCount - 1 do
    if aAtts.Contains(a) then
      begin
        var lAtt := fFunct.ArgAttribute[a];
        var lGain := E0;
        for v := 0 to lAtt.Scale.Count - 1 do
          begin
            var lPart := fFunct.SelectRulesFrom(aRules, a, v);
            var Pp := fFunct.ClassProb(lPart);
            var Ep := Impurity(Pp);
            lGain := lGain - (length(lPart) / Float(n)) * Ep;
          end;
        result[a] := lGain;
      end;
end;

method DecisionTree.BestAttribute(aNode: DecisionTreeNode; aAtts: SetOfInt): Integer;
require
  aAtts.Count >= 1;
begin
  aNode.Gains := CalculateGains(aNode.Rules, aAtts);
  result := aNode.BestGain;
end;

method DecisionTree.MergeSubtrees;

  method Merge(aNode: DecisionTreeNode);
  begin
    for i := 0 to aNode.Count - 1 do
      Merge(aNode.Subtree[i]);
    aNode.MergeSubtrees;
  end;

begin
  Merge(Root);
end;

method DecisionTree.MakeValueTree(aNode: DecisionTreeNode; aAtts: SetOfInt);
begin
  if fFunct.ValuesEqual(aNode.Rules) then
    begin
      aNode.ClassValue :=
        if length(aNode.Rules) = 0 then new DexiUndefinedValue
        else fFunct.RuleValue[aNode.Rules[0]];
      exit;
    end;
  var lAtt := BestAttribute(aNode, aAtts);
  var lAtts := SetOfInt.CopySet(aAtts);
  lAtts.Exclude(lAtt);
  aNode.SplitOn := fFunct.Attribute.Inputs[lAtt];
  aNode.AttIndex := lAtt;
  for v := 0 to aNode.SplitOn.Scale.Count - 1 do
    begin
      var lRules := fFunct.SelectRulesFrom(aNode.Rules, lAtt, v);
      var lNode := new DecisionTreeNode(lRules);
      lNode.AttValues := [v];
      aNode.AddSubtree(lNode);
      MakeValueTree(lNode, lAtts);
    end;
end;

method DecisionTree.MakeTree;
begin
  fRoot := nil;
  if fFunct = nil then
    exit;
  fRoot := new DecisionTreeNode(fFunct.SelectRules);
  MakeValueTree(fRoot, new SetOfInt(0, fFunct.ArgCount - 1));
  MergeSubtrees;
end;

method DecisionTree.Evaluate(aArgs: IntArray): DexiValue;

  method EvaluateNode(aNode: DecisionTreeNode): DexiValue;
  begin
    result := nil;
    if aNode = nil then
      exit;
    if aNode.Count = 0 then
      result := aNode.ClassValue
    else
      begin
        var v := aArgs[aNode.AttIndex];
        for i := 0 to aNode.Count - 1 do
          if Utils.IntArrayContains(aNode.Subtree[i].AttValues, v) then
            exit EvaluateNode(aNode.Subtree[i]);
        end;
  end;

begin
  result := EvaluateNode(Root);
end;

method DecisionTree.CheckTree: Boolean;
begin
  result := false;
  for r := 0 to Funct.Count - 1 do
    begin
      var lArgs := Funct.ArgValues[r];
      var lDT := Evaluate(lArgs);
      var lRule := Funct.RuleValue[r];
      if not DexiValue.ValuesAreEqual(lDT, lRule) then
        exit;
    end;
  result := true;
end;

{$ENDREGION}

end.
