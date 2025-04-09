// DexiClasses.pas is part of
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
// DexiClasses.pas implements basic interfaces and classes for elements used as part of DEXi models:
// - DexiLibrary: a static class providing basic information about this software library
// - INameable: interface for objects that can be named (property Name) and described (Description)
// - DexiObject: basic class for all elements of DEXi models
// - DexiEntry<TDexiClass> and DexiStrings<TDexiClass>: remnants implementing the old Delphi TStringList
// - DexiList<TDexiClass>: extension of List<TDexiClass>;
//     facilitates list-editing operations and retrieval of object names and descriptions
// ----------

namespace DexiLibrary;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  EDexiError = public class(Exception);
  EIndexError = public class(Exception);

{ DexiLibrary }

type
  DexiLibrary = public static class
  public
    const LibraryName = "DEXi Library";
    const Author = "Marko Bohanec";
    const Copyright = "2023-2025 Marko Bohanec";
    method MajorVersion: Integer;
    method MinorVersion: Integer;
    method VersionString: String;
    method LibraryString: String;
  end;

{ DexiObject }

type
  INamed = public soft interface
    property Name: String read;
    property Description: String read;
  end;

type
  INameable = public soft interface (INamed)
    property Name: String read write;
    property Description: String read write;
  end;

type
  DexiObjectClass = public class of DexiObject;

{$IFDEF DEBUG}
type
  DexiObjectInfo = public class
  private
    fNumber: Integer;
    fObjectType: String;
  public
    constructor (aObject: DexiObject);
    property Number: Integer read fNumber;
    property ObjectType: String read fObjectType;
  end;
{$ENDIF}

type
  DexiObject = public class (INameable, IUndoable)
  private
    fName: String;
    fDescription: String;
    {$IFDEF DEBUG}
    fNumber: Integer;
    {$ENDIF}
    class var fCreatedObjects: Int64 := 0;
    class var fFinalizedObjects: Int64 := 0;
    {$IFDEF DEBUG}
    class var fLivingObjects := new Dictionary<Integer, DexiObjectInfo>;
    {$ENDIF}
  protected
    method GetObjectString: String;
    method GetName: String; virtual;
    method SetName(aName: String); virtual;
    method GetDescription: String; virtual;
    method SetDescription(aDescription: String); virtual;
  public
    constructor (aName: String := ''; aDescription: String := '');
    constructor (aObject: DexiObject);
    finalizer;
    method AssignObject(aObj: DexiObject);

    property ObjectString: String read GetObjectString;
    property Name: String read GetName write SetName;
    property Description: String read GetDescription write SetDescription;
    {$IFDEF DEBUG}
    property Number: Integer read fNumber;
    {$ENDIF}
    class property CreatedObjects: Int64 read fCreatedObjects;
    class property FinalizedObjects: Int64 read fFinalizedObjects;
    class property ActiveObjects: Int64 read fCreatedObjects - fFinalizedObjects;
    {$IFDEF DEBUG}
    class property LivingObjects: Dictionary<Integer, DexiObjectInfo> read fLivingObjects;
    {$ENDIF}

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>); virtual;
    method EqualStateAs(aObj: IUndoable): Boolean; virtual;
    method GetUndoState: IUndoable; virtual;
    method SetUndoState(aState: IUndoable); virtual;
  end;

{ DexiEntry }

type
  DexiEntry<TDexiClass> = public class where TDexiClass is DexiObject;
  private
    fStr: String;
    fObj: TDexiClass;
  public
    constructor (aStr: String; aObj: TDexiClass);
    constructor (aObj: TDexiClass);
    property Str: String read fStr write fStr;
    property Obj: TDexiClass read fObj write fObj;
  end;

{ DexiStrings }

type
  DexiStrings<TDexiClass> = public class(List<DexiEntry<TDexiClass>>) where TDexiClass is DexiObject;
  public
    constructor; empty;
    method &Add(aStr: String; aObj: TDexiClass);
    method &Add(aObj: TDexiClass);
    method IndexOf(aStr: String): Integer;
    method IndexOfObject(aObj: TDexiClass): Integer;
    method ToList: DexiList<TDexiClass>;
    method ToStrings: List<String>;
  end;

type
  DexiObjectStrings = public class (DexiStrings<DexiObject>);

{ DexiList }

type
  DexiObjectList = DexiList<DexiObject>;
  DexiList<TDexiClass> = public class(List<TDexiClass>) where TDexiClass is DexiObject;
  protected
    method GetNames(aIdx: Integer): String;
    method SetNames(aIdx: Integer; aName: String);
    method GetDescriptions(aIdx: Integer): String;
    method SetDescriptions(aIdx: Integer; aDescription: String);
  public
    class method EqualLists(aList1, aList2: DexiList<TDexiClass>): Boolean;
    class method CopyList(aList: DexiList<TDexiClass>): DexiList<TDexiClass>;
    constructor; empty;
    constructor(aList: sequence of TDexiClass);
    method ValidIndex(aIdx: Integer): Boolean;
    method ValidateIndex(aIdx: Integer);
    method Exchange(aIdx1: Integer; aIdx2: Integer);
    method Exchange(aItem1, aItem2: TDexiClass);
    method Exchange(aIdx1: Integer; aItem2: TDexiClass);
    method Exchange(aItem1: TDexiClass; aIdx2: Integer);
    method Move(CurIndex: Integer; NewIndex: Integer);
    method Move(CurItem, NewItem: TDexiClass);
    method Move(CurItem: TDexiClass; NewIndex: Integer);
    method Move(CurIndex: Integer; NewItem: TDexiClass);
    method Include(aItem: TDexiClass);
    method Exclude(aItem: TDexiClass);
    method GetNameStrings(aStrings: DexiStrings<TDexiClass>; aAppend: Boolean := false);
    method GetDescriptionStrings(aStrings: DexiStrings<TDexiClass>; aAppend: Boolean := false);
    method GetObjectStrings(aStrings: DexiStrings<TDexiClass>; aAppend: Boolean := false);
    method IndexOf(aName: String): Integer;
    method ObjectByName(aName: String): TDexiClass;
    method ToStrings: DexiStrings<TDexiClass>;
    method ToString: String; override;
    property Names[aIdx: Integer]: String read GetNames write SetNames;
    property Descriptions[aIdx: Integer]: String read GetDescriptions write SetDescriptions;
  end;

implementation

{$REGION DexiLibrary}

method DexiLibrary.MajorVersion: Integer;
begin
  result := 1;
end;

method DexiLibrary.MinorVersion: Integer;
begin
  result := 2;
end;

method DexiLibrary.VersionString: String;
begin
  result := String.Format('{0}.{1:D2}', [MajorVersion, MinorVersion]);
end;

method DexiLibrary.LibraryString: String;
begin
  result := String.Format('{0} V{1}', [LibraryName, VersionString]);
end;

{$ENDREGION}

{$REGION DexiObjectInfo}

{$IFDEF DEBUG}
constructor DexiObjectInfo(aObject: DexiObject);
begin
  fNumber := aObject.Number;
  fObjectType := typeOf(aObject).Name;
end;
{$ENDIF}

{$ENDREGION}

{$REGION DexiObject}

constructor DexiObject(aName: String := ''; aDescription: String := '');
begin
  fName := aName;
  fDescription := aDescription;
  inc(fCreatedObjects);
  {$IFDEF DEBUG}
  fNumber := fCreatedObjects;
  locking fLivingObjects do
    fLivingObjects.Add(fNumber, new DexiObjectInfo(self));
  {$ENDIF}
end;

constructor DexiObject(aObject: DexiObject);
begin
  constructor(if aObject = nil then '' else aObject.Name, if aObject = nil then '' else aObject.Description);
end;

finalizer DexiObject;
begin
  {$IFDEF DEBUG}
  locking fLivingObjects do
    if fLivingObjects.ContainsKey(fNumber) then
      fLivingObjects.Remove(fNumber);
  {$ENDIF}
  inc(fFinalizedObjects);
end;

method DexiObject.GetObjectString: String;
begin
  result := String.Format('Class="{0}", Name="{1}"',[typeOf(self).Name, Name]);
end;

method DexiObject.GetName: String;
begin
  result := fName;
end;

method DexiObject.SetName(aName: String);
begin
  fName := if aName = nil then '' else aName;
end;

method DexiObject.GetDescription: String;
begin
  result := fDescription;
end;

method DexiObject.SetDescription(aDescription: String);
begin
  fDescription := if aDescription = nil then '' else aDescription;
end;

method DexiObject.AssignObject(aObj: DexiObject);
begin
  Name := aObj.Name;
  Description := aObj.Description;
end;

method DexiObject.CollectUndoableObjects(aList: List<IUndoable>);
begin
  // none
end;

method DexiObject.GetUndoState: IUndoable;
begin
  result := new DexiObject(self);
end;

method DexiObject.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiObject then
    exit false;
  var lObj := DexiObject(aObj);
  result :=
    (Name = lObj.Name) and
    (Description = lObj.Description);
end;

method DexiObject.SetUndoState(aState: IUndoable);
begin
  var lObj := aState as DexiObject;
  Name := lObj.Name;
  Description := lObj.Description;
end;

{$ENDREGION}

{$REGION DexiEntry}

constructor DexiEntry<TDexiClass>(aStr: String; aObj: TDexiClass);
begin
  fStr := aStr;
  fObj := aObj;
end;

constructor DexiEntry<TDexiClass>(aObj: TDexiClass);
begin
  constructor (aObj:Name, aObj);
end;

{$ENDREGION}

{$REGION DexiStrings}

method DexiStrings<TDexiClass>.&Add(aStr: String; aObj: TDexiClass);
begin
  &Add(new DexiEntry<TDexiClass>(aStr, aObj));
end;

method DexiStrings<TDexiClass>.&Add(aObj: TDexiClass);
begin
  &Add(aObj:Name, aObj);
end;

method DexiStrings<TDexiClass>.IndexOf(aStr: String): Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if self[i].Str = aStr then
      exit i;
end;

method DexiStrings<TDexiClass>.IndexOfObject(aObj: TDexiClass): Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if self[i].Obj = aObj then
      exit i;
end;

method DexiStrings<TDexiClass>.ToList: DexiList<TDexiClass>;
begin
  result := new DexiList<TDexiClass>;
  for i := 0 to Count - 1 do
    result.Add(self[i].Obj);
end;

method DexiStrings<TDexiClass>.ToStrings: List<String>;
begin
  result := new List<String>;
  for i := 0 to Count - 1 do
    result.Add(self[i].Str);
end;

{$ENDREGION}

{$REGION DexiList}

class method DexiList<TDexiClass>.EqualLists(aList1, aList2: DexiList<TDexiClass>): Boolean;
begin
  if aList1 = aList2 then
    exit true;
  if Utils.BothNil(aList1, aList2) then
    exit true;
  if not Utils.BothNonNil(aList1, aList2) then
    exit false;
  if aList1.Count <> aList2.Count then
    exit false;
  for i := 0 to aList1.Count - 1 do
    if Object(aList1[i]) <> Object(aList2[i]) then
      exit false;
  result := true;
end;

class method DexiList<TDexiClass>.CopyList(aList: DexiList<TDexiClass>): DexiList<TDexiClass>;
begin
  result :=
    if aList = nil then nil
    else new DexiList<TDexiClass>(aList);
end;

constructor DexiList<TDexiClass>(aList: sequence of TDexiClass);
begin
  constructor;
  &Add(aList);
end;

method DexiList<TDexiClass>.ValidIndex(aIdx: Integer): Boolean;
begin
  result :=  0 <= aIdx < Count;
end;

method DexiList<TDexiClass>.ValidateIndex(aIdx: Integer);
begin
  if not ValidIndex(aIdx) then
    raise new EIndexError(String.Format(DexiString.SDexiListIndex, [aIdx, Count-1]));
end;

method DexiList<TDexiClass>.Exchange(aIdx1: Integer; aIdx2: Integer);
begin
  var lTmp := Item[aIdx1];
  Item[aIdx1] := Item[aIdx2];
  Item[aIdx2] := lTmp;
end;

method DexiList<TDexiClass>.Exchange(aItem1, aItem2: TDexiClass);
begin
  Exchange(IndexOf(aItem1), IndexOf(aItem2));
end;

method DexiList<TDexiClass>.Exchange(aIdx1: Integer; aItem2: TDexiClass);
begin
  Exchange(aIdx1, IndexOf(aItem2));
end;

method DexiList<TDexiClass>.Exchange(aItem1: TDexiClass; aIdx2: Integer);
begin
  Exchange(IndexOf(aItem1), aIdx2);
end;

method DexiList<TDexiClass>.Move(CurIndex: Integer; NewIndex: Integer);
begin
  if CurIndex = NewIndex then
    exit;
  var lCurrent := Item[CurIndex];
  RemoveAt(CurIndex);
  Insert(NewIndex, lCurrent);
end;

method DexiList<TDexiClass>.Move(CurItem, NewItem: TDexiClass);
begin
  Move(IndexOf(CurItem), IndexOf(NewItem));
end;

method DexiList<TDexiClass>.Move(CurItem: TDexiClass; NewIndex: Integer);
begin
  Move(IndexOf(CurItem), NewIndex);
end;

method DexiList<TDexiClass>.Move(CurIndex: Integer; NewItem: TDexiClass);
begin
  Move(CurIndex, IndexOf(NewItem));
end;

method DexiList<TDexiClass>.Include(aItem: TDexiClass);
begin
  if not Contains(aItem) then
    &Add(aItem);
end;

method DexiList<TDexiClass>.Exclude(aItem: TDexiClass);
begin
  var lIdx := IndexOf(aItem);
  if lIdx >= 0 then
    RemoveAt(lIdx);
end;

method DexiList<TDexiClass>.GetNames(aIdx: Integer): String;
begin
  result := Item[aIdx].Name;
end;

method DexiList<TDexiClass>.SetNames(aIdx: Integer; aName: String);
begin
  Item[aIdx].Name := aName;
end;

method DexiList<TDexiClass>.GetDescriptions(aIdx: Integer): String;
begin
  result := Item[aIdx].Description;
end;

method DexiList<TDexiClass>.SetDescriptions(aIdx: Integer; aDescription: String);
begin
  Item[aIdx].Description := aDescription;
end;

method DexiList<TDexiClass>.GetNameStrings(aStrings: DexiStrings<TDexiClass>; aAppend: Boolean := false);
begin
  if not aAppend then
    aStrings.RemoveAll;
  for i := 0 to Count - 1 do
    aStrings.Add(Item[i].Name, Item[i]);
end;

method DexiList<TDexiClass>.GetDescriptionStrings(aStrings: DexiStrings<TDexiClass>; aAppend: Boolean := false);
begin
  if not aAppend then
    aStrings.RemoveAll;
  for i := 0 to Count - 1 do
    aStrings.Add(Item[i].Description, Item[i]);
end;

method DexiList<TDexiClass>.GetObjectStrings(aStrings: DexiStrings<TDexiClass>; aAppend: Boolean := false);
begin
  if not aAppend then
    aStrings.RemoveAll;
  for i := 0 to Count - 1 do
    aStrings.Add(Item[i].ObjectString, Item[i]);
end;

method DexiList<TDexiClass>.IndexOf(aName: String): Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if Item[i].Name = aName then
      exit i;
end;

method DexiList<TDexiClass>.ObjectByName(aName: String): TDexiClass;
begin
  var x := IndexOf(aName);
  result := if x < 0 then nil else Item[x];
end;

method DexiList<TDexiClass>.ToStrings: DexiStrings<TDexiClass>;
begin
  result := new DexiStrings<TDexiClass>;
  for i := 0 to Count - 1 do
    result.Add(Item[i]);
end;

method DexiList<TDexiClass>.ToString: String;
begin
  var lStrings := ToStrings;
  result := '';
  for i := 0 to lStrings.Count - 1 do
    result := Utils.AppendStr(result, lStrings[i].Str, ', ');
end;

{$ENDREGION}

end.
