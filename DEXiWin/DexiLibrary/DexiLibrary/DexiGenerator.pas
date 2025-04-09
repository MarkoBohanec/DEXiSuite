// DexiGenerator.pas is part of
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
// DexiGenerator.pas implements the analysis called "option generator" or "target analysis".
// Given some DEXi alternative and some attribute 'Att' (with already assigned value 'Val'
// for this alternative), the task is to find changes of input attributes
// (possibly subject to constraints) that improve or, alternatively, degrade the 'Val'
// by some amount (typically by one qualitative level).
//
// The algorithm is of combinatorial nature and contains safeguarding mechanisms that
// terminate the execution after some number of generated solutions or elapsed time.
// ----------

namespace DexiLibrary;

interface

 uses
  RemObjects.Elements.RTL,
  DexiUtils;

type
  EDexiGeneratorError = public class(EDexiError);

type
  DexiGenDirection = public enum (Improve, Degrade);
  DexiGenCheck = public enum (Proceed, Handled, Terminate);

type
  DexiGenNode = class
  private
    fAttributes: DexiAttributeList;  // 1st attribute is normal, next are linked, if any
    fInputs: List<DexiGenNode>;      // full hierarchy
    fOutputs: List<DexiGenNode>;
    fAdmissible: IntSet;             // set of admissible values; empty means all
    fCurrentValues: IntSet;          // value (as set) of the current alternative
    fRules: array of List<IntArray>; // rules extracted from Attribute.Funct, indexed by class value
    method MakeRules;
  public
    property Attribute: DexiAttribute read if AttCount = 0 then nil else fAttributes[0];
    property Attributes: DexiAttributeList read fAttributes;
    property AttCount: Integer read if fAttributes = nil then 0 else fAttributes.Count;
    property Inputs: ImmutableList<DexiGenNode> read fInputs;
    property InpCount: Integer read if fInputs = nil then 0 else fInputs.Count;
    property Outputs: ImmutableList<DexiGenNode> read fOutputs;
    property OutCount: Integer read if fOutputs = nil then 0 else fOutputs.Count;
    property IsTerminal: Boolean read InpCount = 0;
    property IsRoot: Boolean read OutCount = 0;
    property Admissible: IntSet read fAdmissible write fAdmissible;
    property Rules: array of ImmutableList<IntArray> read fRules;
    property CurrentValues: IntSet read fCurrentValues write fCurrentValues;
    constructor (aAttribute: DexiAttribute);
    method AddLink(aAttribute: DexiAttribute);
    method AddInput(aInput: DexiGenNode);
    method AddOutput(aOutput: DexiGenNode);
    method IsAdmissible(aValue: Integer): Boolean;
    method SortRules(aWrt: IntArray);
  end;

type
  OnEmitCheckMethod = public block (aAssignment: IntArray; aFound: List<IntArray>): DexiGenCheck;
  OnEmitMethod = public block (aAssignment: IntArray; aFound: List<IntArray>);
  OnCanContinueMethod = public block (aAssignment: IntArray; aFound: List<IntArray>): Boolean;

type
  DexiGenerator = public class
  private
    fGoal: DexiAttribute;                               // goal definition: a single root of the hierarchy
    fPrune: DexiAttributeList;                          // list of attributes to prune at
    fConstants: DexiAttributeList;                      // list of input attributes to keep constant
    fNodes: List<DexiGenNode>;                          // list of all nodes, eventually sorted from roots towards terminal nodes
    fAttToNode: Dictionary<DexiAttribute, DexiGenNode>; // convenientg mappings
    fNodeToIndex: Dictionary<DexiGenNode, Integer>;
    fAlternative: DexiAlternative;                      // current alternative
    fMaxSteps: Integer;                                 // maximum number of value steps to take in fDirection
    fAdmissible: Dictionary<DexiAttribute, IntSet>;     // admissible values for attributes
    fDirection: DexiGenDirection;                       // solution-finding direction
    fTargets: IntSet;                                   // target values of fGoal
    fUnidirectional: Boolean := true;                   // whether or not allowing input values to change against fDirection
    fChangeUnordered: Boolean := true;                  // whether or not allowing changing unordered attributes (for which fDirection is meaningless)

    // Current finding status
    fEmitCount: Int64;                                  // number of emitted combinations
                                                        // current distances in and opposite to fDirection:
    fCurrentDistanceInDir: Integer;                     // generally to be maximized
    fCurrentDistanceOpDir: Integer;                     // generally to be minimized within equal InDirs
    fTerminated: Boolean;                               // whether or not the finding should be terminated

    fOnEmitCheck: OnEmitCheckMethod;
    fOnEmit: OnEmitMethod;
    fOnCanContinue: OnCanContinueMethod;

    method GetAttributes: DexiAttributeList;
    method GetLinked: DexiAttributeList;
    method GetTerminals: DexiAttributeList;

    // Setup
    method NewNode(aAttribute: DexiAttribute): DexiGenNode;
    method MakeHierarchy;
    method CheckHierarchy;
    method MakeSequence;
    method SetupGenerator;
    method SetupAlternative(aSort: Boolean);
    method SetupAdmissible;
    method SetupFinding;
    method SetupOne;

    // Events
    method DoCanContinue(aAssignment: IntArray; aFound: List<IntArray>): Boolean; inline;
    method CanContinue(aAssignment: IntArray; aFound: List<IntArray>): Boolean; inline;
    method Emit(aAssignment: IntArray; aFound:  List<IntArray>); inline;

    // Generate
    method NewAlternative: DexiAlternative;
    method ValidateAlternative;
    method ValidateGenerator;
    method SolutionDistance(aAssignment: IntArray; out aUp, aDown: Integer); inline;
    method TrySetValue(aAssignment: IntArray;  aNode: DexiGenNode; aIdx, aValue: Integer): Boolean; inline;
    method TrySetValue(aAssignment: IntArray; aIdx, aValue: Integer): Boolean; inline;
    method TrySetValue(aAssignment: IntArray; aNode: DexiGenNode; aValue: Integer): Boolean; inline;
    method UnSetValue(aAssignment: IntArray; aIdx: Integer); inline;
    method UnSetValue(aAssignment: IntArray; aNode: DexiGenNode); inline;
    method Find: List<IntArray>;
    method One(aSteps: Integer): DexiAlternatives;
    method AssignmentsToAlternatives(aList: List<IntArray>): DexiAlternatives;
    property Root: DexiGenNode read if NodeCount = 0 then nil else fNodes[0];
  public
    class method ValidAttribute(aAttribute: DexiAttribute): Boolean;
    class method ValidateAttribute(aAttribute: DexiAttribute);
    class method IncreasingTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
    class method DecreasingTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
    class method BetterTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
    class method WorseTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
    class method AllIncreasingValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
    class method AllDecreasingValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
    class method AllBetterValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
    class method AllWorseValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
    class method ExtendEval(aAtt: DexiAttribute; aEval: IntSet; aSteps: Integer; aDirection: DexiGenDirection; aZeroStepsIsNil: Boolean := true): IntSet;
    class method ExtendEval(aAtt: DexiAttribute; aEval: IntSet; aSteps: Integer; aZeroStepsIsNil: Boolean := true): IntSet;
    class method SolutionDistanceAbsolute(aOpt, aBound: IntArray): Integer;  inline;
    class method UnorderedDistance(aValues: IntSet; aValue: Integer): Integer; inline;
    constructor (aGoal: DexiAttribute; aPrune: DexiAttributeList := nil);
    method IsPruned(aAttribute: DexiAttribute): Boolean; virtual;
    method ClearAlternative;
    method SetAlternative(aAlternative: DexiAlternative);
    method ClearAdmissible;
    method SetAdmissible(aValues: DexiAlternative);
    method SetAdmissible(aAttribute: DexiAttribute; aValues: IntSet);
    method AdmissibleToString: String;
    method StructureToString: String;
    method SequenceToString: String;
    method EvaluateAlternative(aAlternative: DexiAlternative);
    method FindTargets(aTargets: IntSet; aDirection: DexiGenDirection): DexiAlternatives; virtual;
    method Improve(aLevels: Integer := 0): DexiAlternatives;
    method Degrade(aLevels: Integer := 0): DexiAlternatives;
    method FindOne(aTargets: IntSet; aDirection: DexiGenDirection; aSteps: Integer := 1): DexiAlternatives; virtual;
    method ImproveOne(aLevels: Integer := 0; aSteps: Integer := 1): DexiAlternatives;
    method DegradeOne(aLevels: Integer := 0; aSteps: Integer := 1): DexiAlternatives;
    method DoEmit(aAssignment: IntArray; aFound:  List<IntArray>); //inline;
    property Goal: DexiAttribute read fGoal;
    property NodeCount: Integer read if fNodes = nil then 0 else fNodes.Count;
    property Attributes: DexiAttributeList read GetAttributes;
    property Linked: DexiAttributeList read GetLinked;
    property Terminals: DexiAttributeList read GetTerminals;
    property Constants: DexiAttributeList read fConstants write fConstants;
    property MaxSteps: Integer read fMaxSteps write fMaxSteps;
    property Alternative: DexiAlternative read fAlternative write SetAlternative;
    property Admissible: Dictionary<DexiAttribute, IntSet> read fAdmissible;
    property Unidirectional: Boolean read fUnidirectional write fUnidirectional;
    property ChangeUnordered: Boolean read fChangeUnordered write fChangeUnordered;
    property Direction: DexiGenDirection read fDirection;
    property EmitCount: Int64 read fEmitCount;
    property CurrentDistanceInDir: Integer read fCurrentDistanceInDir write fCurrentDistanceInDir;
    property CurrentDistanceOpDir: Integer read fCurrentDistanceOpDir write fCurrentDistanceOpDir;
    property Terminated: Boolean read fTerminated;
    property OnEmitCheck: OnEmitCheckMethod read fOnEmitCheck write fOnEmitCheck;
    property OnEmit: OnEmitMethod read fOnEmit write fOnEmit;
    property OnCanContinue: OnCanContinueMethod read fOnCanContinue write fOnCanContinue;
  end;

type
  DexiGeneratorChecker = public class
  private
    fGenerator: DexiCheckedGenerator;
    fTimer: Timer;
    fMaxEmit: Boolean;
    fMaxSolutions: Boolean;
    fMaxTime: Boolean;
    fTime: Float;
  public
    constructor(aGenerator: DexiCheckedGenerator);
    property ElapsedMilliSeconds: Float read if fTimer = nil then 0 else fTimer.ElapsedMilliSeconds;
    property MaxEmit: Boolean read fMaxEmit;
    property MaxSolutions: Boolean read fMaxSolutions;
    property MaxTime: Boolean read fMaxTime;
    property Time: Float read fTime write fTime;
    method Start;
    method Stop;
    method EmitCheck(aAssignment: IntArray; aFound: List<IntArray>): DexiGenCheck;
  end;

type
  DexiCheckedGenerator = public class (DexiGenerator)
  private
    fMaxSolutions: Integer := -1;
    fMaxEmit: Integer := -1;
    fMaxTime: Integer := -1;
    fChecker: DexiGeneratorChecker;
  public
    constructor (aGoal: DexiAttribute; aPrune: DexiAttributeList := nil);
    method FindTargets(aTargets: IntSet; aDirection: DexiGenDirection): DexiAlternatives; override;
    method FindOne(aTargets: IntSet; aDirection: DexiGenDirection; aSteps: Integer := 1): DexiAlternatives; override;
    property Checker: DexiGeneratorChecker read fChecker write fChecker;
    property MaxEmit: Integer read fMaxEmit write fMaxEmit;
    property MaxSolutions: Integer read fMaxSolutions write fMaxSolutions;
    property MaxTime: Integer read fMaxTime write fMaxTime;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiGenNode}

constructor DexiGenNode(aAttribute: DexiAttribute);
require
  aAttribute <> nil;
begin
  fAttributes := new DexiAttributeList;
  fAttributes.Add(aAttribute);
  MakeRules;
end;

method DexiGenNode.MakeRules;
begin
  fRules := nil;
  var lFunct := DexiTabularFunction(Attribute:Funct);
  if lFunct = nil then
    exit;
  fRules := new List<IntArray>[Attribute.Scale.Count];
  for c := 0 to Attribute.Scale.Count - 1 do
    fRules[c] := new List<IntArray>;
  for r := 0 to lFunct.Count - 1 do
    if lFunct.RuleDefined[r] then
      begin
        var lArgs := lFunct.ArgValues[r];
        var lClasses := lFunct.RuleValue[r].AsIntSet;
        for x := low(lClasses) to high(lClasses) do
          fRules[lClasses[x]].Add(lArgs);
      end;
end;

method DexiGenNode.SortRules(aWrt: IntArray);
begin
  for each lList in fRules do
    lList.Sort(
      method(a1, a2: IntArray): Integer;
      begin
        var d1 := DexiGenerator.SolutionDistanceAbsolute(aWrt, a1);
        var d2 := DexiGenerator.SolutionDistanceAbsolute(aWrt, a2);
        result := d1 - d2;
        // the following code assures the same sort order in .NET and java
        if result = 0 then
          for i := low(a1) to high(a1) do
            begin
              result := Utils.Compare(a1[i], a2[i]);
              if result <> 0 then
                exit;
            end;
      end
    );
end;

method DexiGenNode.AddLink(aAttribute: DexiAttribute);
require
  assigned(aAttribute);
  assigned(aAttribute.Link);
begin
  fAttributes.Include(aAttribute);
end;

method DexiGenNode.AddInput(aInput: DexiGenNode);
require
  assigned(aInput:Attribute);
  aInput.Attribute.Link = nil;
begin
  if fInputs = nil then
    fInputs := new List<DexiGenNode>;
  if not fInputs.Contains(aInput) then
    fInputs.Add(aInput);
end;

method DexiGenNode.AddOutput(aOutput: DexiGenNode);
begin
  if aOutput = nil then
    exit;
  if fOutputs = nil then
    fOutputs := new List<DexiGenNode>;
  fOutputs.Add(aOutput);
end;

method DexiGenNode.IsAdmissible(aValue: Integer): Boolean;
begin
  result := 0 <= aValue < Attribute.Scale.Count;
  if result and (fAdmissible <> nil) then
    result := Values.IntSetMember(fAdmissible, aValue);
end;

{$ENDREGION}

{$REGION DexiGenerator}

class method DexiGenerator.ValidAttribute(aAttribute: DexiAttribute): Boolean;
begin
  result :=
    assigned(aAttribute) and not assigned(aAttribute.Link) and
    assigned(aAttribute.Scale) and not aAttribute.Scale.IsContinuous and
    assigned(aAttribute.Funct) and (aAttribute.Funct is DexiTabularFunction);
end;

class method DexiGenerator.ValidateAttribute(aAttribute: DexiAttribute);
begin
    if not assigned(aAttribute) then
      raise new EDexiGeneratorError(DexiString.SDexiGenNilAttribute);
    if assigned(aAttribute.Link) then
      raise new EDexiGeneratorError(String.Format(DexiString.SDexiGenLinkedAttribute, [aAttribute.Name]));
    if not assigned(aAttribute.Scale) or aAttribute.Scale.IsContinuous then
      raise new EDexiGeneratorError(String.Format(DexiString.SDexiGenScale, [aAttribute.Name]));
    if aAttribute.IsAggregate then
      if aAttribute:Funct is not DexiTabularFunction then
        raise new EDexiGeneratorError(String.Format(DexiString.SDexiGenFunct, [aAttribute.Name]));
end;

class method DexiGenerator.IncreasingTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
begin
  ValidateAttribute(aAttribute);
  if length(aValues) = 0 then
    exit aAttribute.FullSet;
  var lLow := Values.MaxValue(aValues) + 1;
  if lLow >= aAttribute.Scale.Count then
    exit nil;
  var lHigh :=
    if aLevels <= 0 then aAttribute.Scale.Count - 1
    else Math.Min(lLow + aLevels, aAttribute.Scale.Count - 1);
  result := Values.IntSet(lLow, lHigh);
end;

class method DexiGenerator.DecreasingTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
begin
  ValidateAttribute(aAttribute);
  if length(aValues) = 0 then
    exit aAttribute.FullSet;
  var lHigh := Values.MinValue(aValues) - 1;
  if lHigh < 0 then
    exit nil;
  var lLow :=
    if aLevels <= 0 then 0
    else Math.Max(lHigh - aLevels, 0);
  result := Values.IntSet(lLow, lHigh);
end;

class method DexiGenerator.BetterTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
begin
  result :=
    if aAttribute.Scale.Order = DexiOrder.Ascending then IncreasingTargets(aAttribute, aValues, aLevels)
    else if aAttribute.Scale.Order = DexiOrder.Descending then DecreasingTargets(aAttribute, aValues, aLevels)
    else nil;
end;

class method DexiGenerator.WorseTargets(aAttribute: DexiAttribute; aValues: IntSet; aLevels: Integer := 0): IntSet;
begin
  result :=
    if aAttribute.Scale.Order = DexiOrder.Ascending then DecreasingTargets(aAttribute, aValues, aLevels)
    else if aAttribute.Scale.Order = DexiOrder.Descending then IncreasingTargets(aAttribute, aValues, aLevels)
    else nil;
end;

class method DexiGenerator.AllIncreasingValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
begin
  ValidateAttribute(aAttribute);
  if length(aValues) = 0 then
    exit aAttribute.FullSet;
  var lLow := Values.MinValue(aValues);
  result := Values.IntSet(lLow, aAttribute.Scale.Count - 1);
end;

class method DexiGenerator.AllDecreasingValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
begin
  ValidateAttribute(aAttribute);
  if length(aValues) = 0 then
    exit aAttribute.FullSet;
  var lHigh := Values.MaxValue(aValues);
  result := Values.IntSet(0, lHigh);
end;

class method DexiGenerator.AllBetterValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
begin
  result :=
    if aAttribute.Scale.Order = DexiOrder.Ascending then AllIncreasingValues(aAttribute, aValues)
    else if aAttribute.Scale.Order = DexiOrder.Descending then AllDecreasingValues(aAttribute, aValues)
    else nil;
end;

class method DexiGenerator.AllWorseValues(aAttribute: DexiAttribute; aValues: IntSet): IntSet;
begin
  result :=
    if aAttribute.Scale.Order = DexiOrder.Ascending then AllDecreasingValues(aAttribute, aValues)
    else if aAttribute.Scale.Order = DexiOrder.Descending then AllIncreasingValues(aAttribute, aValues)
    else nil;
end;

class method DexiGenerator.ExtendEval(aAtt: DexiAttribute; aEval: IntSet; aSteps: Integer; aDirection: DexiGenDirection; aZeroStepsIsNil: Boolean := true): IntSet;
begin
  if length(aEval) = 0 then
    exit nil;
  if aSteps <= 0 then
    exit if aZeroStepsIsNil then nil else aEval;
  var lMin := Values.MinValue(aEval);
  var lMax := Values.MaxValue(aEval);
  if aAtt.Scale.Order = DexiOrder.None then
    result := Values.IntSet(Math.Max(lMin - aSteps, 0), Math.Min(lMax + aSteps, aAtt.Scale.Count - 1))
  else if (aAtt.Scale.Order = DexiOrder.Ascending) xor (aDirection = DexiGenDirection.Degrade) then
    result := Values.IntSet(lMin, Math.Min(lMax + aSteps, aAtt.Scale.Count - 1))
  else
    result := Values.IntSet(Math.Max(lMin - aSteps, 0), lMax);
end;

class method DexiGenerator.ExtendEval(aAtt: DexiAttribute; aEval: IntSet; aSteps: Integer; aZeroStepsIsNil: Boolean := true): IntSet;
begin
  if length(aEval) = 0 then
    exit nil;
  if aSteps <= 0 then
    exit if aZeroStepsIsNil then nil else aEval;
  var lMin := Values.MinValue(aEval);
  var lMax := Values.MaxValue(aEval);
  result := Values.IntSet(Math.Max(lMin - aSteps, 0), Math.Min(lMax + aSteps, aAtt.Scale.Count - 1))
end;

class method DexiGenerator.SolutionDistanceAbsolute(aOpt, aBound: IntArray): Integer;
require
  length(aOpt) = length(aBound);
begin
  result := 0;
  for i := low(aOpt) to high(aOpt) do
    result := result + Math.Abs(aOpt[i] - aBound[i]);
end;

class method DexiGenerator.UnorderedDistance(aValues: IntSet; aValue: Integer): Integer;
begin
  if length(aValues) = 0 then
    exit 0;
  result := high(Integer);
  for each lValue in aValues do
    if lValue = aValue then
      exit 0
    else
      begin
        var lDiff := Math.Abs(lValue - aValue);
        if lDiff < result then
          result := lDiff;
      end;
end;

constructor DexiGenerator(aGoal: DexiAttribute; aPrune: DexiAttributeList := nil);
begin
  ValidateAttribute(aGoal);
  fGoal := aGoal;
  fPrune := aPrune;
  fMaxSteps := 0;
  SetupGenerator;
end;

method DexiGenerator.GetAttributes: DexiAttributeList;
begin
  result := new DexiAttributeList;
  for each lNode in fNodes do
    result.Add(lNode.Attribute);
end;

method DexiGenerator.GetLinked: DexiAttributeList;
begin
  result := new DexiAttributeList;
  for each lNode in fNodes do
    for i := 1 to lNode.AttCount - 1 do
      result.Include(lNode.Attributes[i]);
end;

method DexiGenerator.GetTerminals: DexiAttributeList;
begin
  result := new DexiAttributeList;
  for each lNode in fNodes do
    if lNode.IsTerminal then
      result.Add(lNode.Attribute);
end;

method DexiGenerator.IsPruned(aAttribute: DexiAttribute): Boolean;
begin
  result := if fPrune = nil then false else fPrune.Contains(aAttribute);
end;

// Setup

method DexiGenerator.NewNode(aAttribute: DexiAttribute): DexiGenNode;
begin
  result := new DexiGenNode(aAttribute);
  fNodes.Add(result);
  fAttToNode.Add(aAttribute, result);
end;

method DexiGenerator.MakeHierarchy;
var
  lAttList := new DexiAttributeList;
  lLinkList := new DexiAttributeList;

  method CollectAttributes(aAtt: DexiAttribute);
  begin
    if aAtt = nil then
      exit;
    if (aAtt.Scale <> nil) and aAtt.Scale.IsContinuous then
      exit;
    if aAtt.Link = nil then
      lAttList.Include(aAtt)
    else
      lLinkList.Include(aAtt);
    if (aAtt.InpCount > 0) and not IsPruned(aAtt) then
      for i := 0 to aAtt.InpCount - 1 do
        CollectAttributes(aAtt.Inputs[i]);
  end;

  method MakeNodes;
  begin
    for each lAtt in lAttList do
      NewNode(lAtt);
    for each lNode in fNodes do
      lNode.AddOutput(fAttToNode[lNode.Attribute.Parent]);
  end;

  method IncludeLinks;
  begin
    for each lLink in lLinkList do
      begin
        var lAtt := lLink.Link;
        var lNode := fAttToNode[lAtt];
        if lNode = nil then
          begin
            NewNode(lAtt);
            lNode := fAttToNode[lAtt];
          end;
        lNode.AddLink(lLink);
        fAttToNode.Add(lLink, lNode);
        lNode.AddOutput(fAttToNode[lLink.Parent]);
      end;
  end;

  method Structure(aNode: DexiGenNode);
  begin
    if aNode = nil then
      exit;
    if aNode.Attribute.InpCount = 0 then
      exit;
    for each lAtt in aNode.Attributes do
      if IsPruned(lAtt) then
        exit;
    for i := 0 to aNode.Attribute.InpCount - 1 do
      begin
        var lNode := fAttToNode[aNode.Attribute.Inputs[i]];
        if lNode = nil then
          continue;
        aNode.AddInput(lNode);
        Structure(lNode);
      end;
  end;

begin
  CollectAttributes(fGoal);
  MakeNodes;
  IncludeLinks;
  Structure(Root);
end;

method DexiGenerator.CheckHierarchy;
begin
  var lNilScales := new List<DexiGenNode>;
  var lNilFuncts := new List<DexiGenNode>;
  for each lNode in fNodes do
    begin
      if (lNode.Attribute.Scale = nil) or lNode.Attribute.Scale.IsContinuous then
        lNilScales.Add(lNode);
      if (lNode.InpCount > 0) and ((lNode.Attribute.Funct = nil) or not (lNode.Attribute.Funct is DexiTabularFunction)) then
        lNilFuncts.Add(lNode);
    end;
  if lNilScales.Count > 0 then
    raise new EDexiGeneratorError(String.Format(DexiString.SDexiGenNilScales, [lNilScales.Count]));
  if lNilFuncts.Count > 0 then
    raise new EDexiGeneratorError(String.Format(DexiString.SDexiGenNilFuncts, [lNilFuncts.Count]));
end;

method DexiGenerator.MakeSequence;
var lSequence := new List<DexiGenNode>;

  method AddAggregates(aNode: DexiGenNode);
  begin
    if aNode = nil then
      exit;
    if aNode.InpCount = 0 then
      exit;
    for each lParent in aNode.Outputs do
      if not lSequence.Contains(lParent) then
        exit;
    if not lSequence.Contains(aNode) then
      begin
        lSequence.Add(aNode);
        for each lChild in aNode.Inputs do
          AddAggregates(lChild);
      end;
  end;

  method AddTerminals(aNode: DexiGenNode);
  begin
    if aNode = nil then
      exit;
    if aNode.IsTerminal then
      begin
        if not lSequence.Contains(aNode) then
          lSequence.Add(aNode);
      end
    else
      for each lChild in aNode.Inputs do
        AddTerminals(lChild);
  end;

begin
  AddAggregates(Root);
  AddTerminals(Root);
  if fNodes.Count <> lSequence.Count then
    raise new EDexiGeneratorError($'DexiGenerator.MakeSequence Internal Error: Incompatible counts: nodes {fNodes.Count} vs sequence {lSequence.Count}');
  fNodes := lSequence;
  fNodeToIndex := new Dictionary<DexiGenNode, Integer>;
  for x := 0 to NodeCount - 1 do
    fNodeToIndex.Add(fNodes[x], x);
end;

method DexiGenerator.SetupGenerator;
begin
  fNodes := new List<DexiGenNode>;
  fAttToNode := new Dictionary<DexiAttribute, DexiGenNode>;
  MakeHierarchy;
  CheckHierarchy;
  MakeSequence;
end;

method DexiGenerator.SetupAlternative(aSort: Boolean);
begin
  for each lNode in fNodes do
    begin
      var lVal := fAlternative[lNode.Attribute];
      var lValSet :=
        if DexiValue.ValueIsUndefined(lVal) then Values.EmptySet
        else lVal.AsIntSet;
      lNode.CurrentValues :=
        if length(lValSet) = 0 then lNode.Attribute.FullSet
        else lValSet;
    end;
  if aSort then
    for each lNode in fNodes do
      if (lNode.InpCount > 0) and (lNode.Attribute.Funct is DexiTabularFunction) then
        begin
          var lArgs := Utils.NewIntArray(lNode.InpCount, 0);
          for i := 0 to lNode.InpCount - 1 do
            begin
              var lCurrent := lNode.Inputs[i].CurrentValues;
              lArgs[i] := (Values.MinValue(lCurrent) + Values.MaxValue(lCurrent)) div 2;
            end;
          lNode.SortRules(lArgs);
        end;
end;

method DexiGenerator.SetupAdmissible;
begin
  for each lNode in fNodes do
    if lNode.IsRoot then
      lNode.Admissible := fTargets
    else
      begin
        lNode.Admissible := nil;
        var lAtt := lNode.Attribute;
        if (fAdmissible <> nil) and fAdmissible.ContainsKey(lAtt) then
          lNode.Admissible := fAdmissible[lAtt]
        else if lNode.IsTerminal then
          begin
            var lVal := fAlternative[lAtt];
            var lCurVal :=
              if DexiValue.ValueIsUndefined(lVal) then Values.EmptySet
              else lVal.AsIntSet;
            if (fConstants <> nil) and fConstants.Contains(lAtt) then
              lNode.Admissible := lCurVal
            else if (lAtt.Scale.Order = DexiOrder.None) and not ChangeUnordered then
              lNode.Admissible := lCurVal
            else if MaxSteps > 0 then
              if Unidirectional then
                lNode.Admissible := DexiGenerator.ExtendEval(lAtt, lCurVal, MaxSteps, fDirection)
              else
                lNode.Admissible := DexiGenerator.ExtendEval(lAtt, lCurVal, MaxSteps)
            else if Unidirectional then
              if fDirection = DexiGenDirection.Improve then
                lNode.Admissible := AllBetterValues(lAtt, lCurVal)
              else
                lNode.Admissible := AllWorseValues(lAtt, lCurVal);
          end;
      end;
end;

method DexiGenerator.SetupFinding;
begin
  SetupAlternative(true);
  SetupAdmissible;
  fCurrentDistanceInDir := high(Integer);
  fCurrentDistanceOpDir := 0;
  fTerminated := false;
end;

method DexiGenerator.SetupOne;
begin
  SetupAlternative(false);
  SetupAdmissible;
end;

// Events

method DexiGenerator.DoCanContinue(aAssignment: IntArray; aFound: List<IntArray>): Boolean;
begin
  var lUp: Integer;
  var lDown: Integer;
  SolutionDistance(aAssignment, out lUp, out lDown);
  result := lUp <= CurrentDistanceInDir;
end;

method DexiGenerator.CanContinue(aAssignment: IntArray; aFound: List<IntArray>): Boolean;
begin
  result :=
    if assigned(OnCanContinue) then OnCanContinue(aAssignment, aFound)
    else DoCanContinue(aAssignment, aFound);
end;

method DexiGenerator.DoEmit(aAssignment: IntArray; aFound:  List<IntArray>);
begin
//  if (fEmitCount mod 1000000) = 0 then
//    writeln($'Emitted {fEmitCount}: {IntArrayToStr(aAssignment)}');
  var lUp: Integer;
  var lDown: Integer;
  SolutionDistance(aAssignment, out lUp, out lDown);
  if (lUp < CurrentDistanceInDir) or ((lUp = CurrentDistanceInDir) and (lDown > CurrentDistanceOpDir)) then
    begin
//      &write(' * ');
      aFound.RemoveAll;
      CurrentDistanceInDir := lUp;
      CurrentDistanceOpDir := lDown;
    end;
//  if (lUp = CurrentDistanceInDir) and (lDown = CurrentDistanceOpDir) then
//    writeLn($"{aFound.Count}: {Utils.IntArrayToStr(aAssignment)}");
//  writeLn;
  if (lUp = CurrentDistanceInDir) and (lDown = CurrentDistanceOpDir) then
    aFound.Add(Utils.CopyIntArray(aAssignment));
end;

method DexiGenerator.Emit(aAssignment: IntArray; aFound:  List<IntArray>);
begin
  inc(fEmitCount);
  var lCheck :=
    if assigned(OnEmitCheck) then OnEmitCheck(aAssignment, aFound)
    else DexiGenCheck.Proceed;
  case lCheck of
    DexiGenCheck.Handled: {already handled} ;
    DexiGenCheck.Terminate:
      fTerminated := true;
    DexiGenCheck.Proceed:
      if assigned(OnEmit) then
        OnEmit(aAssignment, aFound)
      else
        DoEmit(aAssignment, aFound);
  end;
end;

method DexiGenerator.SolutionDistance(aAssignment: IntArray; out aUp, aDown: Integer);
begin
  aUp := 0;
  aDown := 0;
  var lCount := 0;
  for i := NodeCount - 1 downto 0 do
    begin
      var lNode := fNodes[i];
      if not lNode.IsTerminal then
        exit;
      var x := fNodeToIndex[lNode];
      var lAssignedValue := aAssignment[x];
      if lAssignedValue < 0 then
        continue;
      inc(lCount);
      var lCurrentValues := lNode.CurrentValues;
      var lOrder := lNode.Attribute.Scale.Order;
      if lOrder = DexiOrder.None then
        begin
          var lDist := UnorderedDistance(lCurrentValues, lAssignedValue);
          aUp := aUp + lDist;
          aDown := aDown + lDist;
        end
      else
        begin
          var lMin := Values.MinValue(lCurrentValues);
          var lMax := Values.MaxValue(lCurrentValues);
          var lUp: Integer;
          var lDown: Integer;
          if (lOrder = DexiOrder.Ascending) xor (fDirection = DexiGenDirection.Degrade) then
            begin
              lUp := lAssignedValue - lMax;
              lDown := lMin - lAssignedValue;
            end
          else
            begin
              lUp := lMin - lAssignedValue;
              lDown := lAssignedValue - lMax;
            end;
          if lUp > 0 then
            aUp := aUp + lUp;
          if lDown > 0 then
            aDown := aDown + lDown;
        end;
     end;
  if lCount = 0 then
    aUp := high(Integer);
end;

method DexiGenerator.NewAlternative: DexiAlternative;
begin
  result := new DexiAlternative;
  for each lNode in fNodes do
    if lNode.IsTerminal then
      begin
        var lValue := fAlternative[lNode.Attribute];
        var lAddValue :=
          if DexiValue.ValueIsDefined(lValue) then lValue
          else new DexiIntSet(lNode.Attribute.FullSet);
        result[lNode.Attribute] := lAddValue;
      end;
end;

method DexiGenerator.ValidateAlternative;
begin
  if fAlternative = nil then
    raise new EDexiGeneratorError(DexiString.SDexiGenNoAlternative);
end;

method DexiGenerator.ValidateGenerator;
begin
  ValidateAlternative;
  if not DexiValue.ValueIsDefined(fAlternative[fGoal]) then
    raise new EDexiGeneratorError(DexiString.SDexiGenUndefGoal);
end;

method DexiGenerator.TrySetValue(aAssignment: IntArray; aNode: DexiGenNode; aIdx, aValue: Integer): Boolean;
begin
  result := false;
  if aValue >= 0 then
    if aAssignment[aIdx] < 0 then
      if aNode.IsAdmissible(aValue) then {ok}
      else
        exit
    else if aAssignment[aIdx] <> aValue then
      exit;
  aAssignment[aIdx] := aValue;
  result := true;
end;

method DexiGenerator.TrySetValue(aAssignment: IntArray; aIdx, aValue: Integer): Boolean;
begin
  result := TrySetValue(aAssignment, fNodes[aIdx], aIdx, aValue);
end;

method DexiGenerator.TrySetValue(aAssignment: IntArray; aNode: DexiGenNode; aValue: Integer): Boolean;
begin
  result := TrySetValue(aAssignment, aNode, fNodeToIndex[aNode], aValue);
end;

method DexiGenerator.UnSetValue(aAssignment: IntArray; aIdx: Integer);
begin
  aAssignment[aIdx] := -1;
end;

method DexiGenerator.UnSetValue(aAssignment: IntArray; aNode: DexiGenNode);
begin
  aAssignment[fNodeToIndex[aNode]] := -1;
end;

method DexiGenerator.Find: List<IntArray>;
var
  lFound: List<IntArray>;

  method TryNode(aIdx: Integer; aAssignment: IntArray);
  require
    aAssignment[aIdx] >= 0;
  begin
    if fTerminated then
      exit;
    if fNodes[aIdx].IsTerminal then
      begin
        Emit(aAssignment, lFound);
        exit;
      end;
    if not CanContinue(aAssignment, lFound) then
      exit;
    var lNode := fNodes[aIdx];
    var lTarget := aAssignment[aIdx];
    var lAssignment := Utils.CopyIntArray(aAssignment);
    for each lRule in lNode.Rules[lTarget] do
      begin
        var lSuccess := true;
        for i := low(lRule) to high(lRule) do
          begin
            var lInp := lNode.Inputs[i];
            var x := fNodeToIndex[lInp];
            if not TrySetValue(lAssignment, lInp, x, lRule[i]) then
              begin
                lSuccess := false;
                break;
              end;
          end;
        if lSuccess then
          TryNode(aIdx + 1, lAssignment);
        for i := low(lRule) to high(lRule) do
          begin
            var lInp := lNode.Inputs[i];
            var x := fNodeToIndex[lInp];
            lAssignment[x] := aAssignment[x];
          end;
      end;
  end;

begin
  fEmitCount := 0;
  if NodeCount <= 0 then
    exit nil;
  lFound := new List<IntArray>;
  var lAssignment := Utils.NewIntArray(NodeCount, -1);
  for each lTarget in fTargets do
    if TrySetValue(lAssignment, 0, lTarget) then
      begin
        TryNode(0, lAssignment);
        UnSetValue(lAssignment, 0);
      end;
  result := lFound;
end;

method DexiGenerator.One(aSteps: Integer): DexiAlternatives;
var
  lFound : DexiAlternatives;
  lAlternative: DexiAlternative;

  method CheckAlternative: Boolean;
    begin
      EvaluateAlternative(lAlternative);
      var lEval := lAlternative[fGoal].AsIntSet;
      result := false;
      for each lVal in lEval do
        if Values.IntSetMember(fTargets, lVal) then
          begin
            result := true;
            break;
          end;
      if result then
        begin
          inc(fEmitCount);
          lFound.AddAlternative(lAlternative);
          lAlternative := NewAlternative;
        end;
    end;

  method CheckValue(aNode: DexiGenNode; aCurrentValue: DexiValue; aValue: Integer);
  begin
    if not aNode.IsAdmissible(aValue) then
      exit;
    lAlternative[aNode.Attribute] := new DexiIntSingle(aValue);
    if not CheckAlternative then
      lAlternative[aNode.Attribute] := aCurrentValue;
  end;

  method CheckNode(aNode: DexiGenNode);
  begin
    if aNode = nil then
      exit;
    if (fConstants <> nil) and fConstants.Contains(aNode.Attribute) then
      exit;
    var lCurrentValue := fAlternative[aNode.Attribute];
    var lCurrentIntSet := lCurrentValue.AsIntSet;
    var lOrder := aNode.Attribute.Scale.Order;
    var lUpBound := aNode.Attribute.Scale.Count - 1;
    var lSteps := if aSteps > 0 then aSteps else lUpBound;
    if lOrder = DexiOrder.None then
      begin
        if not ChangeUnordered then
          exit;
        var lLow := Math.Max(Values.MinValue(lCurrentIntSet) - lSteps, 0);
        var lHigh := Math.Min(Values.MaxValue(lCurrentIntSet) + lSteps, lUpBound);
        for v := lLow to lHigh do
          if not Values.IntSetMember(lCurrentIntSet, v) then
            CheckValue(aNode, lCurrentValue, v);
      end
    else if (lOrder = DexiOrder.Ascending) xor (fDirection = DexiGenDirection.Degrade) then
      begin
        var lPt := Values.MaxValue(lCurrentIntSet);
        var lLow := Math.Min(lPt + 1, lUpBound);
        var lHigh := Math.Min(lPt + lSteps, lUpBound);
        for v := lLow to lHigh do
          CheckValue(aNode, lCurrentValue, v);
      end
    else
      begin
        var lPt := Values.MinValue(lCurrentIntSet);
        var lHigh := Math.Max(lPt - 1, 0);
        var lLow := Math.Max(lPt - lSteps, 0);
        for v := lHigh downto lLow do
          CheckValue(aNode, lCurrentValue, v);
      end;
  end;

begin
  fEmitCount := 0;
  if NodeCount <= 0 then
    exit nil;
  lFound := new DexiAlternatives;
  lAlternative := NewAlternative;
  CheckAlternative;
  for each lNode in fNodes do
    if lNode.IsTerminal then
      CheckNode(lNode);
  result := lFound;
end;

method DexiGenerator.ClearAlternative;
begin
  fAlternative := nil;
end;

method DexiGenerator.SetAlternative(aAlternative: DexiAlternative);
begin
  fAlternative := aAlternative.Copy;
//  for each lNode in fNodes do
//    begin
//      var lValue := fAlternative[lNode.Attribute];
//      if DexiValue.ValueIsDefined(lValue) and not lValue.HasIntSet then
//        fAlternative[lNode.Attribute] := new DexiIntSet(lValue.AsIntSet);
//    end;
end;

method DexiGenerator.ClearAdmissible;
begin
  fAdmissible := nil;
end;

method DexiGenerator.SetAdmissible(aValues: DexiAlternative);
begin
  fAdmissible := new Dictionary<DexiAttribute, IntSet>;
  for each lNode in fNodes do
    begin
      var lValue := aValues[lNode.Attribute];
      if DexiValue.ValueIsDefined(lValue) then
        fAdmissible.Add(lNode.Attribute, lValue.AsIntSet);
    end;
end;

method DexiGenerator.SetAdmissible(aAttribute: DexiAttribute; aValues: IntSet);
begin
  if length(aValues) = 0 then
    begin
      if fAdmissible <> nil then
        if fAdmissible.ContainsKey(aAttribute) then
          fAdmissible.Remove(aAttribute);
    end
  else
    begin
      if fAdmissible = nil then
        fAdmissible := new Dictionary<DexiAttribute, IntSet>;
      if fAdmissible.ContainsKey(aAttribute) then
        fAdmissible[aAttribute] := aValues
      else
        fAdmissible.Add(aAttribute, aValues);
    end;
end;

method DexiGenerator.EvaluateAlternative(aAlternative: DexiAlternative);

  method EvaluateSet(aNode: DexiGenNode): IntSet;
  begin
    result := nil;
    var lArgs := new IntSet[aNode.InpCount];
    for i := 0 to aNode.InpCount - 1 do
      begin
        var lAtt := aNode.Inputs[i].Attribute;
        var lValue := aAlternative[lAtt];
        if not DexiValue.ValueIsDefined(lValue) then
          exit;
        lArgs[i] := lValue.AsIntSet;
      end;
    result := [];
    for c := low(aNode.Rules) to high(aNode.Rules) do
      for each lRule in aNode.Rules[c] do
        begin
          var lApplies := true;
          for a := low(lRule) to high(lRule) do
            if not lArgs[a].Contains(lRule[a]) then
              begin
                lApplies := false;
                break;
              end;
          if lApplies then
            Values.IntSetInclude(var result, c);
        end;
  end;

  method Evaluate(aNode: DexiGenNode);
  begin
    if aNode = nil then
      exit;
    var lAtt := aNode.Attribute;
    var lValue := aAlternative[lAtt];
    var lIntSet: IntSet;
    if aNode.IsTerminal then
      lIntSet :=
        if DexiValue.ValueIsDefined(lValue) then lValue.AsIntSet
        else lAtt.FullSet
    else
      begin
        for each lInp in aNode.Inputs do
          Evaluate(lInp);
        lIntSet := EvaluateSet(aNode);
      end;
    aAlternative[lAtt] := new DexiIntSet(lIntSet);
  end;

begin
  Evaluate(Root);
end;

method DexiGenerator.AssignmentsToAlternatives(aList: List<IntArray>): DexiAlternatives;
begin
  result := new DexiAlternatives;
  for each lAssignment in aList index x do
    begin
      if fNodes.Count <> length(lAssignment) then
        raise new EDexiGeneratorError($'DexiGenerator.AssignmentsToAlternatives Internal Error: Incompatible counts: nodes {fNodes.Count} vs assignment {length(lAssignment)}');
      var lAlternative := new DexiAlternative($"{fAlternative.Name}<{x + 1}>", fAlternative.Description);
      for n := 0 to fNodes.Count - 1 do
        lAlternative[fNodes[n].Attribute] := new DexiIntSingle(lAssignment[n]);
      result.AddAlternative(lAlternative);
    end;
end;

method DexiGenerator.FindTargets(aTargets: IntSet; aDirection: DexiGenDirection): DexiAlternatives;
begin
  if length(aTargets) = 0 then
    exit nil;
  ValidateAlternative;
  fTargets := aTargets;
  fDirection := aDirection;
  SetupFinding;
  var lFind := Find;
  result := AssignmentsToAlternatives(lFind);
end;

method DexiGenerator.Improve(aLevels: Integer := 0): DexiAlternatives;
begin
  ValidateGenerator;
  var lTargets := BetterTargets(fGoal, fAlternative[fGoal].AsIntSet, aLevels);
  result := FindTargets(lTargets, DexiGenDirection.Improve);
end;

method DexiGenerator.Degrade(aLevels: Integer := 0): DexiAlternatives;
begin
  ValidateGenerator;
  var lTargets := WorseTargets(fGoal, fAlternative[fGoal].AsIntSet, aLevels);
  result := FindTargets(lTargets, DexiGenDirection.Degrade);
end;

method DexiGenerator.FindOne(aTargets: IntSet; aDirection: DexiGenDirection; aSteps: Integer := 1): DexiAlternatives;
begin
  if length(aTargets) = 0 then
    exit nil;
  ValidateAlternative;
  fTargets := aTargets;
  fDirection := aDirection;
  SetupOne;
  result := One(aSteps);
end;

method DexiGenerator.ImproveOne(aLevels: Integer := 0; aSteps: Integer := 1): DexiAlternatives;
begin
  ValidateGenerator;
  var lTargets := BetterTargets(fGoal, fAlternative[fGoal].AsIntSet, aLevels);
  result := FindOne(lTargets, DexiGenDirection.Improve, aSteps);
end;

method DexiGenerator.DegradeOne(aLevels: Integer := 0; aSteps: Integer := 1): DexiAlternatives;
begin
  ValidateGenerator;
  var lTargets := WorseTargets(fGoal, fAlternative[fGoal].AsIntSet, aLevels);
  result := FindOne(lTargets, DexiGenDirection.Degrade, aSteps);
end;

method DexiGenerator.AdmissibleToString: String;
begin
  var sb := new StringBuilder;
  for each lNode in fNodes do
    begin
      sb.Append(lNode.Attribute.Name);
      sb.Append(' ');
      sb.Append(Values.IntSetToStr(lNode.Admissible));
    end;
  exit sb.ToString;
end;

method DexiGenerator.StructureToString: String;
var sb := new StringBuilder;

  method ToString(aNode: DexiGenNode; aLevel: Integer);
  begin
    sb.Append(new String(' ', 2*aLevel));
    sb.Append(aNode.Attribute.Name);
    if aNode.AttCount > 1 then
      sb.Append($' <- {aNode.AttCount - 1}');
    sb.AppendLine;
    for each lNode in aNode.Inputs do
      ToString(lNode, aLevel + 1);
  end;

begin
  ToString(Root, 0);
  exit sb.ToString;
end;

method DexiGenerator.SequenceToString: String;
begin
  var sb := new StringBuilder;
  for each lNode in fNodes index x do
    begin
      if x > 0 then
        sb.Append(' -> ');
      sb.Append(lNode.Attribute.Name);
      if lNode.OutCount > 1 then
        begin
          sb.Append('[');
          for i := 0 to lNode.OutCount - 1 do
            begin
              if i > 0 then sb.Append('; ');
              sb.Append(lNode.Outputs[i].Attribute.Name);
            end;
          sb.Append(']');
          end;
    end;
  exit sb.ToString;
end;

{$ENDREGION}

{$REGION DexiGeneratorChecker}

constructor DexiGeneratorChecker(aGenerator: DexiCheckedGenerator);
begin
  fGenerator := aGenerator;
  fMaxEmit := false;
  fMaxSolutions := false;
  fMaxTime := false;
  fTime := 0;
  fTimer := new Timer(false);
end;

method DexiGeneratorChecker.Start;
begin
  fTimer.Start;
end;

method DexiGeneratorChecker.Stop;
begin
  fTime := fTime + fTimer.ElapsedMilliSeconds;
end;

method DexiGeneratorChecker.EmitCheck(aAssignment: IntArray; aFound: List<IntArray>): DexiGenCheck;
begin
  result := DexiGenCheck.Proceed;
  if (fGenerator.MaxEmit > 0) and (fGenerator.EmitCount > fGenerator.MaxEmit) then
    fMaxEmit := true
  else if (fGenerator.MaxSolutions > 0) and (aFound.Count >= fGenerator.MaxSolutions) then
    fMaxSolutions := true
  else if (fGenerator.MaxTime > 0) and (ElapsedMilliSeconds > fGenerator.MaxTime) then
    fMaxTime := true;
  if fMaxEmit or fMaxSolutions or fMaxTime then
    result := DexiGenCheck.Terminate;
end;

{$ENDREGION}

{$REGION DexiCheckedGenerator}

constructor DexiCheckedGenerator(aGoal: DexiAttribute; aPrune: DexiAttributeList := nil);
begin
  inherited constructor (aGoal, aPrune);
  fChecker := new DexiGeneratorChecker(self);
  OnEmitCheck := @fChecker.EmitCheck;
end;

method DexiCheckedGenerator.FindTargets(aTargets: IntSet; aDirection: DexiGenDirection): DexiAlternatives;
begin
  fChecker.Start;
  try
    result := inherited FindTargets(aTargets, aDirection);
  finally
    fChecker.Stop;
  end;
end;

method DexiCheckedGenerator.FindOne(aTargets: IntSet; aDirection: DexiGenDirection; aSteps: Integer := 1): DexiAlternatives;
begin
  fChecker.Start;
  try
    result := inherited FindOne(aTargets, aDirection, aSteps);
  finally
    fChecker.Stop;
  end;
end;

{$ENDREGION}

end.
