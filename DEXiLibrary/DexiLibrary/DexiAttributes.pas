// DexiAttributes.pas is part of
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
// DexiAttributes.pas implements the class DexiAttribute. An instance of DexiAttribute is
// interpred as a variable that represents one of the properties observed and/or evaluated
// with decision alternatives. DexiAttribute has the following properties:
// - DexiAttributes are structured in a tree; each attribute may have zero or more lower-level
//   descendants, called Inputs.
// - Each attribute in DexiModel except DexiModel.Root has one Parent attribute.
// - Attributes are partitioned in the set of basic attributes (input attributes, terminal nodes)
//   and the set of aggregate attributes (internal nodes).
// - Each attribute may have assigned a scale (a descendant of DexiScale).
// - Each aggregate attribute may have assigned an aggregation function (a descendant of DexiFunction).
// - Some basic attributes may have assigned the Link property that references some other DexiAttribute.
//   These two attributes are interpreted, in a logical sense, as a single attribute member
//   of attribute hierarchy. Basic attributes whose Link <> nil are called linked attributes.
// - Each attribute has a DexiValueList called AltValues that contains values of alternatives
//   (in the same order as in DexiModel) assigned to this attribute.
//
// DexiAttribute class implements a variety of methods for finding particular attributes, carrying out
// hierarchy editing operations, manipulating alternative values and evaluationg alternatives.
// ----------

namespace DexiLibrary;

{$HIDE W28} // obsolete methods

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiAttributeType = public enum (Basic, Aggregate, Linked);
  DexiNodeStatus = public enum
    (TermUndef, TermDiscr, TermCont, TermLink, AggUndef, AggUndefOK, AggUndefIncomplete, AggDefUndet, AggDefDet);
  DexiAttributeList = public DexiList<DexiAttribute>;
  DexiAttributeStrings = public DexiStrings<DexiAttribute>;

  AttributeCondition = public method (aAtt: DexiAttribute): Boolean;

type
  DexiAttribute = public class (DexiObject)
  private
    fInputs: DexiAttributeList;
    fParent: DexiAttribute;
    fLink: DexiAttribute;
    fScale: DexiScale;
    fFunction: DexiFunction;
    fAltValues: DexiValueList;
    fID: String;
  protected
    method GetInpCount: Integer;
    method GetInputs(aIdx: Integer): DexiAttribute;
    method SetInputs(aIdx: Integer; aAtt: DexiAttribute);
    method GetLevel: Integer;
    method GetIsBasic: Boolean;
    method GetIsBasicNonLinked: Boolean;
    method GetIsAggregate: Boolean;
    method GetIsLinked: Boolean;
    method GetIsRoot: Boolean;
    method GetIsContinuous: Boolean;
    method GetIsDiscrete: Boolean;
    method GetSpaceSize: Int64;
    method GetRight: DexiAttribute;
    method GetNodeStatus: DexiNodeStatus;
    method InclInputs(aList: DexiAttributeList; aCond: AttributeCondition := nil);
    method TryParentPath(aSep: String := nil): String;
    method GetAltCount: Integer;
    method GetAltValue(aIdx: Integer): DexiValue;
    method SetAltValue(aIdx: Integer; aValue: DexiValue);
    method GetAltText(aIdx: Integer): String;
    method SetAltText(aIdx: Integer; aString: String);
    method GetOptText(aIdx: Integer): String;
    method SetOptText(aIdx: Integer; aString: String);
  public
    class const TreeLineNone = '.';
    class const TreeLineThru = '|';
    class const TreeLineLink = '*';
    class const TreeLineLast = '+';
    class const TreeLineLine = '-';
    class method AttributeIsBasic(aAtt: DexiAttribute): Boolean;
    class method AttributeIsBasicNonLinked(aAtt: DexiAttribute): Boolean;
    class method AttributeIsAggregate(aAtt: DexiAttribute): Boolean;
    class method AttributeIsRoot(aAtt: DexiAttribute): Boolean;
    class method AttributeIsDiscretization(aAtt: DexiAttribute): Boolean;
    class method AttributeAtLevel(aAtt: DexiAttribute; aLevel: Integer; aIncludeLinked: Boolean := false): Boolean;
    class method AttributeAtLevelIntersection(aAtt: DexiAttribute; aLevel: Integer; aIncludeLinked: Boolean := false): Boolean;
    class method PruneList(aAttribute: DexiAttribute; aLevel: Integer): DexiAttributeList;
    class method ReplaceAttribute(aOld, aNew: DexiAttribute);

    constructor (aName: String := ''; aDesc: String := '');
    method Clear;
    method InpIndex(aAtt: DexiAttribute): Integer;
    method ParentIndex: Integer;
    method IndexOfValue(aName: String): Integer;
    method Domain: IntArray;
    method Dimension: IntArray;
    method Affects(aAtt: DexiAttribute): Boolean;
    method Depends(aAtt: DexiAttribute): Boolean;
    method AffectsFunction: Boolean;
    method AllInputs: ImmutableList<DexiAttribute>;
    method UnorderedInputs: ImmutableList<DexiAttribute>;
    method CollectInputs(aList: DexiAttributeList; aCond: AttributeCondition := nil);
    method CollectBasic(aList: DexiAttributeList);
    method CollectBasicNonLinked(aList: DexiAttributeList);
    method CollectBasicForEvaluation(aList: DexiAttributeList);
    method CollectAggregate(aList: DexiAttributeList);
    method CollectLevel(aList: DexiAttributeList; aLevel: Integer; aIncludeLinked: Boolean := false);
    method CollectLevelIntersection(aList: DexiAttributeList; aLevel: Integer; aIncludeLinked: Boolean := false);
    method CollectInputs(aCond: AttributeCondition := nil): DexiAttributeList;
    method CollectInputs(aIncludeSelf: Boolean; aCond: AttributeCondition := nil): DexiAttributeList;
    method CollectBasic: DexiAttributeList;
    method CollectBasicNonLinked: DexiAttributeList;
    method CollectBasicForEvaluation: DexiAttributeList;
    method CollectAggregate: DexiAttributeList;
    method CollectLevel(aLevel: Integer; aIncludeLinked: Boolean := false): DexiAttributeList;
    method CollectLevelIntersection(aLevel: Integer; aIncludeLinked: Boolean := false): DexiAttributeList;
    method TreeIndent: String;
    method ParentPath(aSep: String := nil): String;
    method SecureParentPath(aSeparators: sequence of String := nil): String;
    method ParentIndices: IntArray;
    method AddInput(aAtt: DexiAttribute);
    method InsertInput(aIdx: Integer; aAtt: DexiAttribute);
    method DeleteInputs;
    method DeleteInput(aIdx: Integer);
    method DeleteInput(aAtt: DexiAttribute);
    method RemoveInput(aIdx: Integer): DexiAttribute;
    method RemoveInput(aAtt: DexiAttribute): DexiAttribute;
    method MoveInputPrev(aIdx: Integer);
    method MoveInputPrev(aAtt: DexiAttribute);
    method MoveInputNext(aIdx: Integer);
    method MoveInputNext(aAtt: DexiAttribute);
    method CanSetScale(aScale: DexiScale): Boolean;
    method CleanAltValues(aCount: Integer);
    method AddAltValue(aValue: DexiValue): Integer;
    method InsertAltValue(aIdx: Integer; aValue: DexiValue): Integer;
    method RemoveAltValue(aIdx: Integer): DexiValue;
    method DeleteAltValue(aIdx: Integer);
    method MoveAltValue(aFrom, aTo: Integer);
    method MoveAltValuePrev(aIdx: Integer);
    method MoveAltValueNext(aIdx: Integer);
    method ExchangeAltValues(aIdx1, aIdx2: Integer);
    method InsertScaleValue(aIdx: Integer);
    method DeleteScaleValue(aIdx: Integer);
    method DuplicateScaleValue(aIdx: Integer);
    method MoveScaleValue(aFrom, aTo: Integer);
    method ReverseAltValues;
    method FullValue: DexiValue;
    method FullSet: IntSet;
    method IsFullSet(aSet: IntSet): Boolean;
    method NumValues(aNum: Float; aIncLow: Boolean := true; aIncHgh: Boolean := true): IntSet;
    method EvalAlternative(aIdx: Integer); deprecated;
    method EvalSubtree(aIdx: Integer); deprecated;
    method Evaluation; deprecated;
    property InpCount: Integer read GetInpCount;
    property Inputs[aIdx: Integer]: DexiAttribute read GetInputs write SetInputs;
    property Parent: DexiAttribute read fParent write fParent;
    property Link: DexiAttribute read fLink write fLink;
    property ID: String read fID write fID;
    property Level: Integer read GetLevel;
    property Right: DexiAttribute read GetRight;
    property IsBasic: Boolean read GetIsBasic;
    property IsBasicNonLinked: Boolean read GetIsBasicNonLinked;
    property IsAggregate: Boolean read GetIsAggregate;
    property IsLinked: Boolean read GetIsLinked;
    property IsRoot: Boolean read GetIsRoot;
    property IsContinuous: Boolean read GetIsContinuous;
    property IsDiscrete: Boolean read GetIsDiscrete;
    property SpaceSize: Int64 read GetSpaceSize;
    property Funct: DexiFunction read fFunction write fFunction;
    property Scale: DexiScale read fScale write fScale;
    property AltCount: Integer read GetAltCount;
    property AltValues: DexiValueList read fAltValues;
    property AltValue[aIdx: Integer]: DexiValue read GetAltValue write SetAltValue;
    property AltText[aIdx: Integer]: String read GetAltText write SetAltText;
    property OptText[aIdx: Integer]: String read GetOptText write SetOptText; // for compatibility with pre-DexiLibrary models
    property NodeStatus: DexiNodeStatus read GetNodeStatus;

    // IUndoable

    method CollectUndoableObjects(aList: List<IUndoable>); override;
    method EqualStateAs(aObj: IUndoable): Boolean; override;
    method GetUndoState: IUndoable; override;
    method SetUndoState(aState: IUndoable); override;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiAttribute}

class method DexiAttribute.AttributeIsBasic(aAtt: DexiAttribute): Boolean;
begin
  result :=
    if aAtt = nil then false
    else aAtt.IsBasic;
end;

class method DexiAttribute.AttributeIsBasicNonLinked(aAtt: DexiAttribute): Boolean;
begin
  result :=
    if aAtt = nil then false
    else aAtt.IsBasicNonLinked;
end;

class method DexiAttribute.AttributeIsAggregate(aAtt: DexiAttribute): Boolean;
begin
  result :=
    if aAtt = nil then false
    else aAtt.IsAggregate;
end;

class method DexiAttribute.AttributeIsRoot(aAtt: DexiAttribute): Boolean;
begin
  result :=
    if aAtt = nil then false
    else aAtt.IsRoot;
end;

class method DexiAttribute.AttributeIsDiscretization(aAtt: DexiAttribute): Boolean;
begin
  result :=
    if aAtt = nil then false
    else (aAtt.InpCount = 1) and DexiScale.ScaleIsContinuous(aAtt.Inputs[0]:Scale);
end;

class method DexiAttribute.AttributeAtLevel(aAtt: DexiAttribute; aLevel: Integer; aIncludeLinked: Boolean := false): Boolean;
begin
  result :=
    if aAtt = nil then false
    else if aAtt.Level = aLevel then aIncludeLinked or not aAtt.IsLinked
    else false;
end;

class method DexiAttribute.AttributeAtLevelIntersection(aAtt: DexiAttribute; aLevel: Integer; aIncludeLinked: Boolean := false): Boolean;
begin
  result :=
    if aAtt = nil then false
    else if aAtt.IsLinked and not aIncludeLinked then false
    else if aAtt.Level = aLevel then true
    else if aAtt.IsBasic and (aAtt.Level < aLevel) then true
    else false;
end;

class method DexiAttribute.PruneList(aAttribute: DexiAttribute; aLevel: Integer): DexiAttributeList;
var lList := new DexiAttributeList;

  method AddAttribute(aAtt: DexiAttribute; aAttLevel: Integer);
  begin
    if aAttLevel = aLevel then
      lList.Add(aAtt)
    else if aAttLevel < aLevel then
      for i := 0 to aAtt.InpCount - 1 do
        AddAttribute(aAtt.Inputs[i], aAttLevel + 1);
  end;

begin
  AddAttribute(aAttribute, 0);
  result := lList;
end;

constructor DexiAttribute(aName: String := ''; aDesc: String := '');
begin
  inherited constructor;
  fInputs := nil;
  fParent := nil;
  fScale := nil;
  fLink := nil;
  Name := aName;
  Description := aDesc;
  fFunction := nil;
  fAltValues := new DexiValueList;
end;

method DexiAttribute.Clear;
begin
  fFunction := nil;
  fScale := nil;
  fInputs := nil;
end;

method DexiAttribute.GetInpCount: Integer;
begin
  result :=
    if fInputs = nil then 0
    else fInputs.Count;
end;

method DexiAttribute.GetInputs(aIdx: Integer): DexiAttribute;
begin
  result := fInputs[aIdx];
end;

method DexiAttribute.SetInputs(aIdx: Integer; aAtt: DexiAttribute);
begin
  fInputs[aIdx] := aAtt;
end;

method DexiAttribute.GetLevel: Integer;
begin
  result := 0;
  var lAtt := Parent;
  while lAtt <> nil do
    begin
      inc(result);
      lAtt := lAtt.Parent;
    end;
end;

method DexiAttribute.GetIsBasic: Boolean;
begin
  result := InpCount = 0;
end;

method DexiAttribute.GetIsBasicNonLinked: Boolean;
begin
  result := IsBasic and not IsLinked;
end;

method DexiAttribute.GetIsAggregate: Boolean;
begin
  result := not IsBasic;
end;

method DexiAttribute.GetIsLinked: Boolean;
begin
  result := Link <> nil;
end;

method DexiAttribute.GetIsRoot: Boolean;
begin
  result := Parent = nil;
end;

method DexiAttribute.GetIsContinuous: Boolean;
begin
  result := DexiScale.ScaleIsContinuous(Scale);
end;

method DexiAttribute.GetIsDiscrete: Boolean;
begin
  result := DexiScale.ScaleIsDiscrete(Scale);
end;

method DexiAttribute.GetSpaceSize: Int64;
begin
  result := 1;
  for i := 0 to InpCount - 1 do
    begin
      var lAtt := Inputs[i];
      if lAtt:Scale = nil then
        exit -1
      else if lAtt.Scale.IsDistributable then
        try
          result := result * lAtt.Scale.Count;
        except
          result := high(Int64);
        end
      else
        exit -1;
    end;
end;

method DexiAttribute.GetRight: DexiAttribute;
var
  lResult: DexiAttribute;
  lLev: Integer;

  method Traverse(aAtt: DexiAttribute; aLev: Integer);
  begin
    if lResult <> nil then
      exit;
    if aAtt = Self then
      lLev := aLev
    else if aLev = lLev then
      lResult := aAtt;
    if lResult <> nil then
      exit;
    for i := 0 to aAtt.InpCount - 1 do
      Traverse(aAtt.Inputs[i], aLev + 1);
  end;

begin
  lResult := nil;
  var lRoot := Self;
  while lRoot.Parent <> nil do
    lRoot := lRoot.Parent;
  lLev := -1;
  Traverse(lRoot, 0);
  result := lResult;
end;

method DexiAttribute.GetNodeStatus: DexiNodeStatus;
begin
  result :=
    if IsLinked then DexiNodeStatus.TermLink
    else if IsBasic then
      if Scale = nil then DexiNodeStatus.TermUndef
      else if Scale.IsContinuous then DexiNodeStatus.TermCont
      else DexiNodeStatus.TermDiscr
    else if Funct = nil then
      if Scale = nil then DexiNodeStatus.AggUndef
      else if DexiFunction.CanCreateAnyFunctionOn(self) then DexiNodeStatus.AggUndefOK
      else DexiNodeStatus.AggUndefIncomplete
    else if Funct.Determined < 1.0 then DexiNodeStatus.AggDefUndet
    else DexiNodeStatus.AggDefDet;
end;

method DexiAttribute.InclInputs(aList: DexiAttributeList; aCond: AttributeCondition := nil);
begin
  if aList.Contains(Self) then
    exit;
  if not assigned(aCond) or aCond(Self) then
    aList.Add(Self);
  for i := 0 to InpCount - 1 do
    Inputs[i].InclInputs(aList, aCond);
end;

method DexiAttribute.InpIndex(aAtt: DexiAttribute): Integer;
begin
  result :=
    if fInputs = nil then -1
    else fInputs.IndexOf(aAtt);
end;

method DexiAttribute.ParentIndex: Integer;
begin
  result :=
    if Parent = nil then -1
    else Parent.InpIndex(self);
end;

method DexiAttribute.IndexOfValue(aName: String): Integer;
begin
  result :=
    if Scale = nil then -1
    else Scale.IndexOfValue(aName);
end;

method DexiAttribute.Domain: IntArray;
begin
  result := Utils.NewIntArray(InpCount);
  for i := 0 to InpCount - 1 do
    begin
      var lScl := Inputs[i]:Scale;
      result[i] :=
        if (lScl = nil) or (lScl.Count <= 1) then 0
        else lScl.Count - 1;
    end;
end;

method DexiAttribute.Dimension: IntArray;
begin
  result := Utils.NewIntArray(InpCount);
  for i := 0 to InpCount - 1 do
    begin
      var lScl := Inputs[i]:Scale;
      result[i] :=
        if lScl = nil then 0
        else lScl.Count;
    end;
end;

method DexiAttribute.Affects(aAtt: DexiAttribute): Boolean;
begin
  result := false;
  var lAtt := Parent;
  while (lAtt <> nil) and not result do
    begin
      result := lAtt = aAtt;
      lAtt := lAtt.Parent;
    end;
end;

method DexiAttribute.Depends(aAtt: DexiAttribute): Boolean;
begin
  result := aAtt.Affects(Self);
end;

method DexiAttribute.AffectsFunction: Boolean;
begin
  result := (Funct <> nil) or ((Parent <> nil) and (Parent.Funct <> nil));
end;

method  DexiAttribute.AllInputs: ImmutableList<DexiAttribute>;
begin
  exit fInputs;
end;

method  DexiAttribute.UnorderedInputs: ImmutableList<DexiAttribute>;
begin
  var lList := new List<DexiAttribute>;
  for each lAtt in fInputs do
    if (lAtt:Scale <> nil) and (lAtt.Scale.Order = DexiOrder.None) then
      lList.Add(lAtt);
  result := lList;
end;

method DexiAttribute.CollectInputs(aList: DexiAttributeList; aCond: AttributeCondition := nil);
begin
  for i := 0 to InpCount - 1 do
    Inputs[i].InclInputs(aList, aCond);
end;

method DexiAttribute.CollectBasic(aList: DexiAttributeList);
begin
  CollectInputs(aList, @AttributeIsBasic);
end;

method DexiAttribute.CollectBasicNonLinked(aList: DexiAttributeList);
begin
  CollectInputs(aList, @AttributeIsBasicNonLinked);
end;

method DexiAttribute.CollectBasicForEvaluation(aList: DexiAttributeList);
begin
  var lList := new DexiAttributeList;
  CollectBasic(lList);
  for i := 0 to lList.Count - 1 do
    if not lList[i].IsLinked then
      aList.Include(lList[i])
    else
      begin
        var lAtt := lList[i].Link;
        if lAtt.IsBasic then
          aList.Include(lAtt)
        else
          lAtt.CollectBasicForEvaluation(aList);
      end;
end;

method DexiAttribute.CollectAggregate(aList: DexiAttributeList);
begin
  CollectInputs(aList, @AttributeIsAggregate);
end;

method DexiAttribute.CollectLevel(aList: DexiAttributeList; aLevel: Integer; aIncludeLinked: Boolean := false);
begin
  var lList := new DexiAttributeList;
  CollectInputs(lList);
  for each lAtt in lList do
    if AttributeAtLevel(lAtt, aLevel, aIncludeLinked) then
      aList.Add(lAtt);
end;

method DexiAttribute.CollectLevelIntersection(aList: DexiAttributeList; aLevel: Integer; aIncludeLinked: Boolean := false);
begin
  var lList := new DexiAttributeList;
  CollectInputs(lList);
  for each lAtt in lList do
    if AttributeAtLevelIntersection(lAtt, aLevel, aIncludeLinked) then
      aList.Add(lAtt);
end;

method DexiAttribute.CollectInputs(aCond: AttributeCondition := nil): DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectInputs(result, aCond);
end;

method DexiAttribute.CollectInputs(aIncludeSelf: Boolean; aCond: AttributeCondition := nil): DexiAttributeList;
begin
  result := new DexiAttributeList;
  if aIncludeSelf then
    result.Add(self);
  CollectInputs(result, aCond);
end;

method DexiAttribute.CollectBasic: DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectBasic(result);
end;

method DexiAttribute.CollectBasicNonLinked: DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectBasicNonLinked(result);
end;

method DexiAttribute.CollectBasicForEvaluation: DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectBasicForEvaluation(result);
end;

method DexiAttribute.CollectAggregate: DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectAggregate(result);
end;

method DexiAttribute.CollectLevel(aLevel: Integer; aIncludeLinked: Boolean := false): DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectLevel(result, aLevel, aIncludeLinked);
end;

method DexiAttribute.CollectLevelIntersection(aLevel: Integer; aIncludeLinked: Boolean := false): DexiAttributeList;
begin
  result := new DexiAttributeList;
  CollectLevelIntersection(result, aLevel, aIncludeLinked);
end;

method DexiAttribute.CollectUndoableObjects(aList: List<IUndoable>);
begin
  inherited CollectUndoableObjects(aList);
  UndoUtils.IncludeRecursive(aList, fInputs);
  UndoUtils.Include(aList, fParent);
  UndoUtils.Include(aList, fLink);
  UndoUtils.IncludeRecursive(aList, fScale);
  UndoUtils.Include(aList, fFunction);
  UndoUtils.IncludeRecursive(aList, fAltValues);
end;

method DexiAttribute.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiAttribute then
    exit false;
  var lAtt := DexiAttribute(aObj);
  if not inherited EqualStateAs(lAtt) then
    exit false;
  result :=
    (lAtt.InpCount = InpCount) and
    (lAtt.AltCount = AltCount) and
    (lAtt.Scale = Scale) and
    (lAtt.Parent = Parent) and
    (lAtt.Funct = Funct) and
    (lAtt.fID = fID) and
    Utils.EqualLists(lAtt.fInputs, fInputs) and
    Utils.EqualLists(lAtt.fAltValues, fAltValues);
end;

method DexiAttribute.GetUndoState: IUndoable;
begin
  var lAtt := new DexiAttribute;
  lAtt.AssignObject(self);
  lAtt.fInputs := DexiList<DexiAttribute>.CopyList(fInputs);
  lAtt.fParent := fParent;
  lAtt.fLink := fLink;
  lAtt.fScale := fScale;
  lAtt.fFunction := fFunction;
  lAtt.fAltValues := Utils.CopyList(fAltValues);
  lAtt.fID := fID;
  result := lAtt;
end;

method DexiAttribute.SetUndoState(aState: IUndoable);
begin
  inherited SetUndoState(aState);
  var lAtt := aState as DexiAttribute;
  fInputs := DexiList<DexiAttribute>.CopyList(lAtt.fInputs);
  fParent := lAtt.fParent;
  fLink := lAtt.fLink;
  fScale := lAtt.fScale;
  fFunction := lAtt.fFunction;
  fAltValues := Utils.CopyList(lAtt.fAltValues);
  fID := lAtt.fID;
end;

method DexiAttribute.TreeIndent: String;
begin
  result := '';
  if Parent = nil then
    exit;
  if Parent.InpIndex(self) >= Parent.InpCount - 1 then
    result := TreeLineLast
  else result := TreeLineLink;
  var lAtt := Parent;
  while lAtt.Parent <> nil do
    begin
      if lAtt.Parent.InpIndex(lAtt) >= lAtt.Parent.InpCount - 1 then
        result := TreeLineNone + result
      else
        result := TreeLineThru + result;
      lAtt := lAtt.Parent;
    end;
  result := result.SubString(1);
end;

method DexiAttribute.TryParentPath(aSep: String := nil): String;
 begin
  if String.IsNullOrEmpty(aSep) then
    aSep := DexiString.SPathSeparator;
  if Name.Contains(aSep) then
    exit nil;
  result := Name;
  var lAtt := Parent;
  while (lAtt <> nil) and not lAtt.IsRoot do
    begin
      if lAtt.Name.Contains(aSep) then
        exit nil;
      result := lAtt.Name + aSep + result;
      lAtt := lAtt.fParent;
    end;
  result := aSep + result;
end;

method DexiAttribute.ParentPath(aSep: String := nil): String;
begin
  if String.IsNullOrEmpty(aSep) then
    aSep := DexiString.SPathSeparator;
  result := Name;
  var lAtt := Parent;
  while (lAtt <> nil) and not lAtt.IsRoot do
    begin
      result := lAtt.Name + aSep + result;
      lAtt := lAtt.fParent;
    end;
  result := aSep + result;
end;

method DexiAttribute.SecureParentPath(aSeparators: sequence of String := nil): String;
begin
  if aSeparators = nil then
    aSeparators := DexiString.SPathSeparators;
  result := nil;
  for each lSep in aSeparators do
    begin
      result := TryParentPath(lSep);
      if result <> nil then
        exit;
    end;
end;

method DexiAttribute.ParentIndices: IntArray;
begin
  var lList := new List<Integer>;
  var lAtt := self;
  var lParent := lAtt.Parent;
  while lParent <> nil do
    begin
      lList.Insert(0, lParent.InpIndex(lAtt));
      lAtt := lParent;
      lParent := lParent.fParent;
    end;
  {$IFDEF JAVA}
  result := Utils.NewIntArray(lList.Count);
  for i := low(result) to high(result) do
    result[i] := lList[i];
  {$ELSE}
  result := lList.ToArray;
  {$ENDIF}
end;

method DexiAttribute.AddInput(aAtt: DexiAttribute);
begin
  if aAtt = nil then
    exit;
  if fInputs = nil then
    fInputs := new DexiAttributeList;
  fInputs.Add(aAtt);
  aAtt.fParent := Self;
end;

method DexiAttribute.InsertInput(aIdx: Integer; aAtt: DexiAttribute);
begin
  if aAtt = nil then
    exit;
  if aIdx >= InpCount then
    AddInput(aAtt)
  else
    begin
      fInputs.Insert(aIdx, aAtt);
      aAtt.fParent := Self;
    end;
end;

class method DexiAttribute.ReplaceAttribute(aOld, aNew: DexiAttribute);
begin
  var lParent := aOld.Parent;
  var lIdx := lParent.InpIndex(aOld);
  lParent.Inputs[lIdx] := aNew;
  aNew.Parent := lParent;
end;

method DexiAttribute.DeleteInputs;
begin
  fInputs := nil;
end;

method DexiAttribute.DeleteInput(aIdx: Integer);
begin
  fInputs.RemoveAt(aIdx);
  if InpCount = 0 then
    fInputs := nil;
end;

method DexiAttribute.DeleteInput(aAtt: DexiAttribute);
begin
  fInputs.Exclude(aAtt);
  if InpCount = 0 then
    fInputs := nil;
end;

method DexiAttribute.RemoveInput(aIdx: Integer): DexiAttribute;
begin
  result := fInputs[aIdx];
  fInputs.RemoveAt(aIdx);
  if InpCount = 0 then
    fInputs := nil;
end;

method DexiAttribute.RemoveInput(aAtt: DexiAttribute): DexiAttribute;
begin
  var x := fInputs.IndexOf(aAtt);
  result := if x < 0 then nil else RemoveInput(x);
end;

method DexiAttribute.MoveInputPrev(aIdx: Integer);
begin
  fInputs.Exchange(aIdx - 1, aIdx);
end;

method DexiAttribute.MoveInputPrev(aAtt: DexiAttribute);
begin
  MoveInputPrev(InpIndex(aAtt));
end;

method DexiAttribute.MoveInputNext(aIdx: Integer);
begin
  fInputs.Exchange(aIdx + 1, aIdx);
end;

method DexiAttribute.MoveInputNext(aAtt: DexiAttribute);
begin
  MoveInputNext(InpIndex(aAtt));
end;

method DexiAttribute.CanSetScale(aScale: DexiScale): Boolean;
begin
  var lParentFunct := Parent:Funct;
  var lContinuous := IsBasic and (Funct = nil) and (Parent <> nil) and (Parent.InpCount = 1) and not (lParentFunct is DexiTabularFunction);
  result :=
    if (Funct = nil) and (lParentFunct = nil) then
      if (aScale = nil) or aScale.IsDiscrete then true
      else lContinuous
    else if aScale = nil then false
    else if aScale.IsDiscrete then DexiScale.AssignmentCompatibleScales(Scale, aScale)
    else if aScale.IsContinuous then lContinuous and DexiScale.AssignmentCompatibleScales(Scale, aScale)
    else false;
end;

method DexiAttribute.GetAltCount: Integer;
begin
  result := fAltValues.Count;
end;

method DexiAttribute.CleanAltValues(aCount: Integer);
begin
  if aCount <= 0 then
    begin
      fAltValues.RemoveAll;
      exit;
    end;
  while AltCount < aCount do
    AddAltValue(nil);
  while AltCount > aCount do
    DeleteAltValue(AltCount - 1);
end;

method DexiAttribute.GetAltValue(aIdx: Integer): DexiValue;
begin
  result := fAltValues[aIdx];
end;

method DexiAttribute.SetAltValue(aIdx: Integer; aValue: DexiValue);
begin
  fAltValues[aIdx] := DexiValue.CopyValue(aValue);
end;

method DexiAttribute.GetAltText(aIdx: Integer): String;
begin
  var lValue := AltValue[aIdx];
  result := DexiValue.ToString(lValue);
end;

method DexiAttribute.SetAltText(aIdx: Integer; aString: String);
begin
  var lValue :=
    if fScale = nil then DexiValue.FromString(aString)
    else if fScale.IsContinuous then DexiValue.FromFltString(aString)
    else DexiValue.FromIntString(aString);
  AltValue[aIdx] := lValue;
end;

method DexiAttribute.GetOptText(aIdx: Integer): String;
begin
  var lValue := AltValue[aIdx];
  if (Scale = nil) or (lValue = nil) or not lValue.IsDefined then
    result := ''
  else if not Scale.IsDiscrete or not lValue.HasIntSet then
    result := nil
  else
    begin
      var lSet := lValue.AsIntSet;
      if IsFullSet(lSet) then
        result := '*'
      else
        begin
          result := '';
          for i := low(lSet) to high(lSet) do
            if Scale.InBounds(lSet[i]) then
              result := result + chr(lSet[i] + ord('0'));
        end;
    end;
end;

method DexiAttribute.SetOptText(aIdx: Integer; aString: String);
begin
  if (Scale =  nil) or not Scale.IsDiscrete or (aString = nil) then
    AltValue[aIdx] := nil
  else if (aString = '') or (aString = '*') then
    AltValue[aIdx] := new DexiIntInterval(Scale.LowInt, Scale.HighInt)
  else
    begin
      var lSet := Values.EmptySet;
      for i := 0 to aString.Length - 1 do
        begin
          var lValue := ord(aString[i]) - ord('0');
          if Scale.InBounds(lValue) then
            Values.IntSetInclude(var lSet, lValue);
        end;
      AltValue[aIdx] :=
        if length(lSet) = 1 then new DexiIntSingle(lSet[0])
        else DexiValue.SimplifyValue(new DexiIntSet(lSet));
    end;
end;

method DexiAttribute.AddAltValue(aValue: DexiValue): Integer;
begin
  fAltValues.Add(DexiValue.CopyValue(aValue));
  result := fAltValues.Count - 1;
end;

method DexiAttribute.InsertAltValue(aIdx: Integer; aValue: DexiValue): Integer;
begin
  if aIdx >= fAltValues.Count then
    result := AddAltValue(aValue)
  else
    begin
      result := aIdx;
      fAltValues.Insert(aIdx, nil);
      AltValue[result] := aValue;
    end;
end;

method DexiAttribute.RemoveAltValue(aIdx: Integer): DexiValue;
begin
  result := AltValue[aIdx];
  DeleteAltValue(aIdx);
end;

method DexiAttribute.DeleteAltValue(aIdx: Integer);
begin
  fAltValues.RemoveAt(aIdx);
end;

method DexiAttribute.MoveAltValuePrev(aIdx: Integer);
begin
  ExchangeAltValues(aIdx - 1, aIdx);
end;

method DexiAttribute.MoveAltValueNext(aIdx: Integer);
begin
  ExchangeAltValues(aIdx, aIdx + 1);
end;

method DexiAttribute.ExchangeAltValues(aIdx1, aIdx2: Integer);
begin
  Utils.ExchangeList(fAltValues, aIdx1, aIdx2);
end;

method DexiAttribute.MoveAltValue(aFrom, aTo: Integer);
begin
  Utils.MoveList(fAltValues, aFrom, aTo);
end;

method DexiAttribute.InsertScaleValue(aIdx: Integer);
begin
  if (Scale = nil) or Scale.IsContinuous then
    exit;
  for i := 0 to AltCount - 1 do
    if (fAltValues[i] <> nil) and (fAltValues[i] is DexiIntValue) then
      DexiIntValue(fAltValues[i]).Insert(aIdx);
end;

method DexiAttribute.DeleteScaleValue(aIdx: Integer);
begin
  if (Scale = nil) or Scale.IsContinuous then
    exit;
  for i := 0 to AltCount - 1 do
    if (fAltValues[i] <> nil) and (fAltValues[i] is DexiIntValue) then
      DexiIntValue(fAltValues[i]).Delete(aIdx);
end;

method DexiAttribute.DuplicateScaleValue(aIdx: Integer);
begin
  if (Scale = nil) or Scale.IsContinuous then
    exit;
  for i := 0 to AltCount - 1 do
    if (fAltValues[i] <> nil) and (fAltValues[i] is DexiIntValue) then
      DexiIntValue(fAltValues[i]).Duplicate(aIdx);
end;

method DexiAttribute.MoveScaleValue(aFrom, aTo: Integer);
begin
  if (Scale = nil) or Scale.IsContinuous or (aFrom = aTo) then
    exit;
  for i := 0 to AltCount - 1 do
    if (fAltValues[i] <> nil) and (fAltValues[i] is DexiIntValue) then
      DexiIntValue(fAltValues[i]).Move(aFrom, aTo);
end;

method DexiAttribute.ReverseAltValues;
begin
  if (Scale = nil) or Scale.IsContinuous or (Scale.Order = DexiOrder.None) or (Scale.Count <= 1) then
    exit;
  for i := 0 to AltCount - 1 do
    begin
      var lValue := fAltValues[i];
      if lValue is DexiIntValue then
        DexiIntValue(lValue).Reverse(0, Scale.Count - 1);
    end;
end;

method DexiAttribute.FullValue: DexiValue;
begin
  result :=
    if (Scale <> nil) and Scale.IsContinuous then nil
    else new DexiIntSet(FullSet);
end;

method DexiAttribute.FullSet: IntSet;
begin
  result :=
    if Scale = nil then Values.EmptySet
    else if Scale.IsContinuous then nil
    else Values.IntSet(Scale.LowInt, Scale.HighInt);
end;

method DexiAttribute.IsFullSet(aSet: IntSet): Boolean;
begin
  result :=
    if Scale = nil then false
    else Values.IntSetEq(aSet, FullSet);
end;

method DexiAttribute.NumValues(aNum: Float; aIncLow: Boolean := true; aIncHgh: Boolean := true): IntSet;
begin
  result := Values.EmptySet;
  if (Scale = nil) or not (Scale is DexiDiscreteScale) then
    exit;
  var lScl := DexiDiscreteScale(Scale);
  for i := Scale.LowInt to Scale.HighInt do
    begin
      var s := lScl.Names[i];
      var sl := '';
      var sh := '';
      var l := 0.0;
      var h := 0.0;
      var c := 1;
      for j := 0 to length(s) - 1 do
        if s[j] in ['0'..'9', '.', ',', '-', '+', 'E', 'e'] then
          begin
            if c = 1 then
              sl := sl + s[j]
            else
              sh := sh + s[j];
          end
        else if s[j] = '(' then aIncLow := false
        else if s[j] = '[' then aIncLow := true
        else if s[j] = ')' then aIncHgh := false
        else if s[j] = ']' then aIncHgh := true
        else
          inc(c);
      try
        if sl <> '' then
          l := Utils.StrToFlt(sl);
        if sh <> '' then
          h := Utils.StrToFlt(sh);
      except
      end;
      var IsIn :=
        if sl = '' then
          if Utils.Pos0('<=', s) = 0 then aNum <= h
          else if Utils.Pos0('>=', s) = 0 then aNum >= h
          else if Utils.Pos0('<', s) = 0 then aNum < h
          else if Utils.Pos0('>', s) = 0 then aNum > h
          else Math.Abs(aNum - h) < Utils.FloatEpsilon
        else
          if aIncLow then
            if aIncHgh then l <= aNum <= h
            else l <= aNum < h
          else
            if aIncHgh then l < aNum <= h
            else l < aNum < h;
      if IsIn then
        Values.IntSetInclude(var result, i);
    end;
end;

method DexiAttribute.EvalAlternative(aIdx: Integer);
begin
  if IsBasic then
    begin
      if Link <> nil then
        AltValue[aIdx] := Link.AltValue[aIdx];
      exit;
    end;
  var ArgVal := new List<String>;
  var r := '';
  if (Scale <> nil) and (Funct <> nil) then
    begin
      for i := 0 to InpCount - 1 do
        ArgVal.Add(Inputs[i].AltText[aIdx]);
      r := Funct.Evaluation(ArgVal);
    end;
  AltText[aIdx] := r;
end;

method DexiAttribute.EvalSubtree(aIdx: Integer);
begin
  if Link <> nil then
    Link.EvalSubtree(aIdx);
  for i := 0 to InpCount - 1 do
    Inputs[i].EvalSubtree(aIdx);
  EvalAlternative(aIdx);
end;

method DexiAttribute.Evaluation;
begin
  if Link <> nil then
    Link.Evaluation;
  for lAtt := 0 to InpCount - 1 do
    Inputs[lAtt].Evaluation;
  for lAlt := 0 to AltCount - 1 do
    EvalAlternative(lAlt);
end;

{$ENDREGION}

end.
