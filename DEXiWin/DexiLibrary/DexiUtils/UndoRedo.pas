// UndoRedo.pas is part of
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
// UndoRedo.pas implements basic Undo/Redo interfaces and functionality for undoing and redoing the
// effects of changing (e.g., editing) objects. Objects can be composed of other objects,
// possibly nested and cross-referenced.
//
// The main idea is that each object to be subject to undoing/redoing, implements the IUndoable interface,
// which consists of four methods:
//
// - CollectUndoableObjects(aList: List<IUndoable>):
//     which other objects than self should take part in undo/redo
// - EqualStateAs(aObj: IUndoable): Boolean:
//     whether or not the contents of self are equal to aObj
// - GetUndoState: IUndoable:
//     create an IUndoable object (typically a copy of self) to be stored in the undo/redo subsystem
// - SetUndoState(aState: IUndoable):
//     assign the contents of aState to self
//
// Additionally, the following types are defined in this file:
//
// - UndoStateComparison: a record representing differences between two UndoStates
// - UndoState: an undo/redo state of multiple objects;
//     for each object, it provides a link to its previous contents state
// - UndoUtils: a static class of helper methods for undo/redo
// - IUndoRedo<Tstate>: interface to a undo/redo handling system
// - UndoRedo<Tstate>: a basic abstract implementation of the undo/redo handling system
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  RemObjects.Elements.RTL;

type
  IUndoable = public interface
    method CollectUndoableObjects(aList: List<IUndoable>);
    method EqualStateAs(aObj: IUndoable): Boolean;
    method GetUndoState: IUndoable;
    method SetUndoState(aState: IUndoable);
  end;

type
  UndoStateComparison = public record
  public
    Equal: List<IUndoable>;
    Different: List<IUndoable>;
    Added: List<IUndoable>;
    Deleted: List<IUndoable>;
  end;

type
  UndoState = public class
  private
    fState: Dictionary<IUndoable, IUndoable>;
  protected
  public
    constructor (aObjects: List<IUndoable>; aCompareWith: UndoState := nil);
    property State: ImmutableDictionary<IUndoable, IUndoable> read fState;
    property StateOf[aObject: IUndoable]: IUndoable read fState[aObject]; default;
    method CompareWith(aState: UndoState): UndoStateComparison;
    method Apply;
  end;

type
  UndoUtils = public static class
  private
  public
    method UndoableList(aList: List<Object>): List<IUndoable>;
    method Include(aList: List<IUndoable>; aObject: Object);
    method Include(aList: List<IUndoable>; aObjects: sequence of Object);
    method IncludeRecursive(aList: List<IUndoable>; aObject: Object);
    method IncludeRecursive(aList: List<IUndoable>; aObjects: sequence of Object);
    method UndoStates(aList: List<IUndoable>): List<IUndoable>;
  end;

type
  IUndoRedo<Tstate> = public interface
    method GetObjectState: Tstate;
    method SetObjectState(aState: Tstate := nil);
    method Clear;
    method Undo;
    method Redo;
    method AddState(aState: Tstate := nil);
    method SetState(aState: Tstate := nil);
    property State: Tstate read;
    property UndoCount: Integer read;
    property RedoCount: Integer read;
    property CanUndo: Boolean read;
    property CanRedo: Boolean read;
    property Active: Boolean read write;
  end;

type
  UndoRedo<Tstate> = public abstract class (IUndoRedo<Tstate>)
    where Tstate is class;
    private
      fState: Tstate;
      fUndoStack := new Stack<Tstate>;
      fRedoStack := new Stack<Tstate>;
      fActive: Boolean;
    protected
      method GetActive: Boolean; virtual;
      method SetActive(aActive: Boolean); virtual;
      method GetCanUndo: Boolean;
      method GetCanRedo: Boolean;
    public
      constructor;
      method Clear; virtual;
      method Undo; virtual;
      method Redo; virtual;
      method GetObjectState: Tstate; virtual; abstract;
      method SetObjectState(aState: Tstate := nil); virtual; abstract;
      method AddState(aState: Tstate := nil); virtual;
      method SetState(aState: Tstate := nil); virtual;
      method PeekUndoState: Tstate; virtual;
      method PeekRedoState: Tstate; virtual;
      property State: Tstate read fState write SetState;
      property UndoCount: Integer read fUndoStack.Count;
      property RedoCount: Integer read fRedoStack.Count;
      property CanUndo: Boolean read GetCanUndo;
      property CanRedo: Boolean read GetCanRedo;
      property Active: Boolean read GetActive write SetActive;
  end;

implementation

{$REGION UndoState}

constructor UndoState(aObjects: List<IUndoable>; aCompareWith: UndoState := nil);
begin
  inherited constructor;
  fState := new Dictionary<IUndoable, IUndoable>;
  for each lObj in aObjects do
    begin
      var lCompState :=
        if aCompareWith = nil then nil
        else aCompareWith[lObj];
      if (lCompState = nil) or not lObj.EqualStateAs(lCompState) then
        lCompState := lObj.GetUndoState;
      fState.Add(lObj, lCompState);
    end;
end;

method UndoState.CompareWith(aState: UndoState): UndoStateComparison;
begin
  result.Equal := new List<IUndoable>;
  result.Different := new List<IUndoable>;
  result.Added := new List<IUndoable>;
  result.Deleted := new List<IUndoable>;
  for each lObj in fState.Keys do
    begin
      var lCont := fState[lObj];
      var lComp := if aState = nil then nil else aState[lObj];
      if lComp = nil then
        result.Added.Add(lObj)
      else if lCont = lComp then
        result.Equal.Add(lObj)
      else if lObj.EqualStateAs(lComp) then
        result.Equal.Add(lObj)
      else
        result.Different.Add(lObj);
    end;
  if aState <> nil then
    for each lObj in aState.State.Keys do
      if not fState.ContainsKey(lObj) then
        result.Deleted.Add(lObj);
end;

method UndoState.Apply;
begin
  for each lObj in fState.Keys do
    begin
      var lCont := fState[lObj];
      lObj.SetUndoState(lCont);
    end;
end;

{$ENDREGION}

{$REGION UndoUtils}

method UndoUtils.UndoableList(aList: List<Object>): List<IUndoable>;
begin
  result := new List<IUndoable>;
  for each lObj in aList do
    if lObj is IUndoable then
      result.Add(IUndoable(lObj));
end;

method UndoUtils.Include(aList: List<IUndoable>; aObject: Object);
begin
  if (aObject <> nil) and (aObject is IUndoable) then
    begin
      var lUndoable := IUndoable(aObject);
      if aList.IndexOf(lUndoable) < 0 then
        aList.Add(lUndoable);
    end;
end;

method UndoUtils.Include(aList: List<IUndoable>; aObjects: sequence of Object);
begin
  for each lObj in aObjects do
    Include(aList, lObj);
end;

method UndoUtils.IncludeRecursive(aList: List<IUndoable>; aObject: Object);
begin
  if (aObject <> nil) and (aObject is IUndoable) then
    begin
      var lUndoable := IUndoable(aObject);
      if aList.IndexOf(lUndoable) < 0 then
        begin
          aList.Add(lUndoable);
          lUndoable.CollectUndoableObjects(aList);
        end;
    end;
end;

method UndoUtils.IncludeRecursive(aList: List<IUndoable>; aObjects: sequence of Object);
begin
  for each lObj in aObjects do
    IncludeRecursive(aList, lObj);
end;

method UndoUtils.UndoStates(aList: List<IUndoable>): List<IUndoable>;
begin
  result := new List<IUndoable>;
  for each lUndo in aList do
    result.Add(lUndo.GetUndoState);
end;

{$ENDREGION}

{$REGION UndoRedo<Tstate>}

constructor UndoRedo<Tstate>;
begin
  fActive := true;
end;

method UndoRedo<Tstate>.GetActive: Boolean;
begin
  result := fActive;
end;

method UndoRedo<Tstate>.SetActive(aActive: Boolean);
begin
  if aActive = fActive then
    exit;
  fActive := aActive;
  Clear;
end;

method UndoRedo<Tstate>.GetCanUndo: Boolean;
begin
  result := fActive and (UndoCount > 0);
end;

method UndoRedo<Tstate>.GetCanRedo: Boolean;
begin
  result := fActive and (RedoCount > 0);
end;

method UndoRedo<Tstate>.Clear;
begin
  fUndoStack.Clear;
  fRedoStack.Clear;
end;

method UndoRedo<Tstate>.Undo;
begin
  if not CanUndo then
    exit;
  if fState <> nil then
    fRedoStack.Push(fState);
  var lState := fUndoStack.Pop;
  fState := lState;
  SetObjectState(lState);
end;

method UndoRedo<Tstate>.Redo;
begin
  if not CanRedo then
    exit;
  if fState <> nil then
    fUndoStack.Push(fState);
  var lState := fRedoStack.Pop;
  fState := lState;
  SetObjectState(lState);
end;

method UndoRedo<Tstate>.AddState(aState: Tstate := nil);
begin
  if not fActive then
    exit;
  if fState <> nil then
    fUndoStack.Push(fState);
  SetState(aState);
end;

method UndoRedo<Tstate>.SetState(aState: Tstate := nil);
begin
  if not fActive then
    exit;
  if aState = nil then
    aState := GetObjectState;
  fState := aState;
  fRedoStack.Clear;
end;

method UndoRedo<Tstate>.PeekUndoState: Tstate;
begin
  result :=
    if UndoCount = 0 then nil
    else fUndoStack.Peek;
end;

method UndoRedo<Tstate>.PeekRedoState: Tstate;
begin
  result :=
    if RedoCount = 0 then nil
    else fRedoStack.Peek;
end;

{$ENDREGION}

end.
