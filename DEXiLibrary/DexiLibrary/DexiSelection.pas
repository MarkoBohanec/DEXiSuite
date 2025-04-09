// DexiSelection.pas is part of
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
// DexiSelection.pas implements the class DexiSelection, aimed at selecting (choosing) particular
// DexiAttributes and DexiAlternatives. This functionality is needed in GUI elements.
// Since DEXiLibrary 2023, selections made by the user are stored in .dxi files.
//
// Important: Existing instances of DexiSelection must be explicitly updated after the following
// operations upon the main DexiModel: adding, deleting, moving and exchanging an alternative.
// ----------

namespace DexiLibrary;

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiSelection = public class (IUndoable)
  protected
    fSelectedAttributes: List<DexiAttribute>;
    fSelectedAlternatives: SetOfInt;
    method GetSelectedAlternatives: SetOfInt;
    method GetAttCount: Integer;
    method GetAltCount: Integer;
  public
    constructor;
    constructor (aSelection: DexiSelection);
    method AssignSelection(aSelection: DexiSelection);
    method IsExplicitlySelected(aAtt: DexiAttribute): Boolean; virtual;
    method IsSelected(aAtt: DexiAttribute): Boolean; virtual;
    method SelectAttribute(aAtt: DexiAttribute); virtual;
    method SelectAttributes(aAttributes: sequence of DexiAttribute); virtual;
    method SelectAllAttributes; virtual;
    method SelectAllAttributesExplicitly(aAttributes: sequence of DexiAttribute); virtual;
    method UnSelectAttribute(aAtt: DexiAttribute); virtual;
    method UnSelectAttributes(aAttributes: sequence of DexiAttribute); virtual;
    method UnSelectAllAttributes; virtual;
    method AllAlternativesSelected: Boolean;
    method IsSelected(aAlt: Integer): Boolean; virtual;
    method SelectAlternative(aAlt: Integer); virtual;
    method SelectAllAlternatives; virtual;
    method SelectAllAlternativesExplicitly(aAltCount: Integer); virtual;
    method UnSelectAlternative(aAlt: Integer); virtual;
    method UnSelectAlternative(aAlt: Integer; aAltCount: Integer);
    method UnSelectAllAlternatives; virtual;
    method AddAlternative(aAlt: Integer); virtual;
    method DeleteAlternative(aAlt: Integer); virtual;
    method MoveAlternative(aFrom, aTo: Integer); virtual;
    method MoveAlternativePrev(aAlt: Integer); virtual;
    method MoveAlternativeNext(aAlt: Integer); virtual;
    method ExchangeAlternatives(aIdx1, aIdx2: Integer); virtual;
    property SelectedAttributes: List<DexiAttribute> read fSelectedAttributes write fSelectedAttributes;
    property SelectedAlternatives: SetOfInt read GetSelectedAlternatives write fSelectedAlternatives;
    property AttCount: Integer read GetAttCount;
    property AltCount: Integer read GetAltCount;

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>); virtual;
    method GetUndoState: IUndoable; virtual;
    method SetUndoState(aState: IUndoable); virtual;
    method EqualStateAs(aObj: IUndoable): Boolean; virtual;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiSelection}

constructor DexiSelection;
begin
  inherited constructor;
  fSelectedAttributes := nil;
  fSelectedAlternatives := nil;
end;

constructor DexiSelection(aSelection: DexiSelection);
begin
  constructor;
  AssignSelection(aSelection);
end;

method DexiSelection.AssignSelection(aSelection: DexiSelection);
begin
  fSelectedAttributes := Utils.CopyList(aSelection.fSelectedAttributes);
  fSelectedAlternatives := SetOfInt.CopySet(aSelection.fSelectedAlternatives);
end;

method DexiSelection.CollectUndoableObjects(aList: List<IUndoable>);
begin
  UndoUtils.Include(aList, fSelectedAttributes);
end;

method DexiSelection.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiSelection then
    exit false;
  var lSel := DexiSelection(aObj);
  if lSel = self then
    exit true;
  result :=
    Utils.EqualLists(lSel.fSelectedAttributes, fSelectedAttributes) and
    SetOfInt.EqualSets(lSel.fSelectedAlternatives, fSelectedAlternatives);
end;

method DexiSelection.GetUndoState: IUndoable;
begin
  result := new DexiSelection(self);
end;

method DexiSelection.SetUndoState(aState: IUndoable);
begin
  var lSelection := aState as DexiSelection;
  AssignSelection(lSelection);
end;

method DexiSelection.GetAttCount: Integer;
begin
  result :=
    if fSelectedAttributes = nil then -1
    else fSelectedAttributes.Count;
end;

method DexiSelection.GetAltCount: Integer;
begin
  result :=
    if fSelectedAlternatives = nil then -1
    else length(fSelectedAlternatives:Ints);
end;

method DexiSelection.GetSelectedAlternatives: SetOfInt;
begin
  result :=
    if fSelectedAlternatives = nil then nil
    else new SetOfInt(fSelectedAlternatives);
end;

method DexiSelection.IsSelected(aAtt: DexiAttribute): Boolean;
begin
  result := (fSelectedAttributes = nil) or fSelectedAttributes.Contains(aAtt);
end;

method DexiSelection.IsExplicitlySelected(aAtt: DexiAttribute): Boolean;
begin
  result := (fSelectedAttributes <> nil) and fSelectedAttributes.Contains(aAtt);
end;

method DexiSelection.SelectAttribute(aAtt: DexiAttribute);
begin
  if fSelectedAttributes = nil then
    fSelectedAttributes := new List<DexiAttribute>;
  if not fSelectedAttributes.Contains(aAtt) then
    fSelectedAttributes.Add(aAtt);
end;

method DexiSelection.SelectAttributes(aAttributes: sequence of DexiAttribute);
begin
  for each lAtt in aAttributes do
    SelectAttribute(lAtt);
end;

method DexiSelection.SelectAllAttributes;
begin
  fSelectedAttributes := nil;
end;

method DexiSelection.SelectAllAttributesExplicitly(aAttributes: sequence of DexiAttribute);
begin
  UnSelectAllAttributes;
  SelectAttributes(aAttributes);
end;

method DexiSelection.UnSelectAttribute(aAtt: DexiAttribute);
begin
  if fSelectedAttributes <> nil then
    fSelectedAttributes.Remove(aAtt);
end;

method DexiSelection.UnSelectAttributes(aAttributes: sequence of DexiAttribute);
begin
  for each lAtt in aAttributes do
    UnSelectAttribute(lAtt);
end;

method DexiSelection.UnSelectAllAttributes;
begin
  fSelectedAttributes := new List<DexiAttribute>;
end;

method DexiSelection.AllAlternativesSelected: Boolean;
begin
  result := fSelectedAlternatives = nil;
end;

method DexiSelection.IsSelected(aAlt: Integer): Boolean;
begin
  result := (fSelectedAlternatives = nil) or fSelectedAlternatives.Contains(aAlt);
end;

method DexiSelection.SelectAlternative(aAlt: Integer);
begin
  if fSelectedAlternatives = nil then
    fSelectedAlternatives := new SetOfInt(aAlt, aAlt)
  else
    fSelectedAlternatives.Include(aAlt);
end;

method DexiSelection.SelectAllAlternatives;
begin
  fSelectedAlternatives := nil;
end;

method DexiSelection.SelectAllAlternativesExplicitly(aAltCount: Integer);
begin
  fSelectedAlternatives := new SetOfInt(0, aAltCount - 1);
end;

method DexiSelection.UnSelectAlternative(aAlt: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.Exclude(aAlt);
end;

method DexiSelection.UnSelectAlternative(aAlt: Integer; aAltCount: Integer);
begin
  if fSelectedAlternatives = nil then
    SelectAllAlternativesExplicitly(aAltCount);
  UnSelectAlternative(aAlt);
end;

method DexiSelection.UnSelectAllAlternatives;
begin
  fSelectedAlternatives := new SetOfInt;
end;

method DexiSelection.AddAlternative(aAlt: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.IncludeIndex(aAlt);
end;

method DexiSelection.DeleteAlternative(aAlt: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.ExcludeIndex(aAlt);
end;

method DexiSelection.MoveAlternative(aFrom, aTo: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.Move(aFrom, aTo);
end;

method DexiSelection.MoveAlternativePrev(aAlt: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.Exchange(aAlt - 1, aAlt);
end;

method DexiSelection.MoveAlternativeNext(aAlt: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.Exchange(aAlt + 1, aAlt);
end;

method DexiSelection.ExchangeAlternatives(aIdx1, aIdx2: Integer);
begin
  if fSelectedAlternatives <> nil then
    fSelectedAlternatives.Exchange(aIdx1, aIdx2);
end;

{$ENDREGION}

end.