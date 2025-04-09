// DexiValues.pas is part of
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
// DexiValues.pas implements DEXi value types represented as DexiValue class instances:
// - DexiValue: basic abstract class that defines basic DEXi value properties and methods,
//   including:
//   - "Is" properties, e.g., 'IsFloat', 'IsSingle'. These depend on the value type (static)
//   - "Has*" properties, e.g., 'HasIntSingle'. These depend on actual value contents, for instance,
//     a DexiIntInterval or DexiIntSet may contain a single Integer value.
//   - "As*" conversions, e.g., 'AsDistribution': Converting this value contents to other representations.
//   - methods for creating, comparing, compacting and bounding of values.
// - DexiUndefinedValue: special DEXi value type that indicates an undefined value. The interpretation of
//   undefined values in alternative evaluation depends on DexiSettings: an undefined value can be
//   interpreted either as nil (nullifying all calculations involving this value) or can be expanded
//   to the full set of the corresponding discrete scale.
// - DexiIntValue: basic abstract class for the following "*Int*" classes.
// - DexiIntSingle: value consisting of a single Integer.
// - DexiIntInterval: value consiting of an Integer interval, i.e., all Integer values between two Integer bounds.
// - DexiIntSet: value consisting of a set of Integer values (these need not be contiguous as with DexiIntInterval).
// - DexiDistribution: value represented by a distribution of Integer values. Conceptually, a distribution is a
//   set of Integer values, each of which has an additional Float membership factor, usually in the range [0, 1].
// - DexiFltValue: basic abstract class for the following "*Flt*" classes.
// - DexiFltSingle: value consisting of a single Float.
// - DexiFltInterval: value consiting of a Float interval, i.e., all Float values between two Float bounds.
// ----------

namespace DexiLibrary;

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiValueType = public enum (None, Undefined, IntSingle, IntInterval, IntSet, Distribution, FltSingle, FltInterval);
  DexiValueMethod = public enum (Single, Interval, &Set, Distr);

type
  DexiValueClass = public class of DexiValue;
  DexiValueArray = public array of DexiValue;
  DexiValueList = public List<DexiValue>;

type
  DexiValue = public abstract class (IUndoable)
  protected
    method GetValueType: DexiValueType; virtual;
    method GetValueSize: Integer; virtual;
    method GetIsInteger: Boolean; virtual;
    method GetIsFloat: Boolean; virtual;
    method GetIsSingle: Boolean; virtual;
    method GetIsInterval: Boolean; virtual;
    method GetIsSet: Boolean; virtual;
    method GetIsDistribution: Boolean; virtual;
    method GetIsDefined: Boolean; virtual;
    method GetHasIntSingle: Boolean; virtual;
    method GetHasIntInterval: Boolean; virtual;
    method GetHasIntSet: Boolean; virtual;
    method GetHasFltSingle: Boolean; virtual;
    method GetAsInteger: Integer; virtual; abstract;
    method SetAsInteger(aInt: Integer); virtual; abstract;
    method GetAsFloat: Float; virtual; abstract;
    method SetAsFloat(aFlt: Float); virtual; abstract;
    method GetLowInt: Integer; virtual; abstract;
    method GetHighInt: Integer; virtual; abstract;
    method GetLowFloat: Float; virtual; abstract;
    method GetHighFloat: Float; virtual; abstract;
    method GetAsIntInterval: IntInterval; virtual;
    method SetAsIntInterval(aIntInterval: IntInterval); virtual; abstract;
    method GetAsFltInterval: FltInterval; virtual;
    method SetAsFltInterval(aFltInterval: FltInterval); virtual; abstract;
    method GetAsIntSet: IntArray; virtual; abstract;
    method SetAsIntSet(aIntSet: IntArray); virtual; abstract;
    method GetAsDistribution: Distribution; virtual; abstract;
    method SetAsDistribution(aDistr: Distribution); virtual; abstract;
    method GetAsString: String; virtual;
    method SetAsString(aStr: String); virtual;
    method GetIsEmpty: Boolean; virtual;
  public
    constructor; empty;
    class method CreateValue(aValueType: DexiValueType): DexiValue;
    class method CopyValue(aValue: DexiValue): DexiValue;
    class method SimplifyValue(aValue: DexiValue): DexiValue;
    class method CompactValue(aValue: DexiValue): DexiValue;
    class method CompareValues(aValue1, aValue2: DexiValue; aMethod: DexiValueMethod): PrefCompare;
    class method ValueIsFloat(aValue: DexiValue): Boolean;
    class method ValueIsInteger(aValue: DexiValue): Boolean;
    class method ValueIsDefined(aValue: DexiValue): Boolean;
    class method ValueIsUndefined(aValue: DexiValue): Boolean;
    class method ValuesAreEqual(aVal1, aVal2: DexiValue): Boolean;
    class method IsUndefined(aStr: String): Boolean;
    class method ToString(aValue: DexiValue; aInvariant: Boolean := true; aDecimals: Integer = -1): String;
    class method FromIntString(aStr: String; aInvariant: Boolean := true): DexiValue;
    class method FromFltString(aStr: String; aInvariant: Boolean := true): DexiValue;
    class method FromString(aStr: String; aInvariant: Boolean := true): DexiValue;

    property ValueType: DexiValueType read GetValueType;
    property IsInteger: Boolean read GetIsInteger;
    property IsFloat: Boolean read GetIsFloat;
    property IsSingle: Boolean read GetIsSingle;
    property IsInterval: Boolean read GetIsInterval;
    property IsSet: Boolean read GetIsSet;
    property IsDistribution: Boolean read GetIsDistribution;
    property IsDefined: Boolean read GetIsDefined;

    property HasIntSingle: Boolean read GetHasIntSingle;
    property HasIntInterval: Boolean read GetHasIntInterval;
    property HasIntSet: Boolean read GetHasIntSet;
    property HasFltSingle: Boolean read GetHasFltSingle;

    property ValueSize: Integer read GetValueSize;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsFloat: Float read GetAsFloat write SetAsFloat;
    property LowInt: Integer read GetLowInt;
    property HighInt: Integer read GetHighInt;
    property LowFloat: Float read GetLowFloat;
    property HighFloat: Float read GetHighFloat;
    property AsIntInterval: IntInterval read GetAsIntInterval write SetAsIntInterval;
    property AsFltInterval: FltInterval read GetAsFltInterval write SetAsFltInterval;
    property AsIntSet: IntArray read GetAsIntSet write SetAsIntSet;
    property AsDistribution: Distribution read GetAsDistribution write SetAsDistribution;
    property AsString: String read GetAsString write SetAsString;

    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; virtual; abstract;
    method FromString(aStr: String; aInvariant: Boolean := true); virtual; abstract;

    property IsEmpty: Boolean read GetIsEmpty;

    method Clear; virtual; empty;
    method Member(aInt: Integer): Boolean; virtual;
    method Member(aFlt: Float): Boolean; virtual;
    method SameValue(aValue: DexiValue): Boolean; virtual;
    method EqualTo(aValue: DexiValue): Boolean; virtual;
    method CompareWith(aValue: DexiValue): PrefCompare; virtual; abstract;
    method CompareWith(aValue: DexiValue; aMethod: DexiValueMethod): PrefCompare; virtual;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; virtual;
    method AssignValue(aValue: DexiValue); virtual; abstract;
    method InBounds(aLow, aHigh: Integer): Boolean;
    method InBounds(aLow, aHigh: Float): Boolean;
    method IntoBounds(aLow, aHigh: Integer); virtual; abstract;
    method IntoBounds(aLow, aHigh: Float); virtual; abstract;
    method Normalize(aNorm: Normalization := Normalization.normNone); virtual; empty;

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>);
    method EqualStateAs(aObj: IUndoable): Boolean;
    method GetUndoState: IUndoable;
    method SetUndoState(aState: IUndoable);
  end;

type
  DexiUndefinedValue = public class (DexiValue)
  private
    method OperationError(aOp: String);
  protected
    method GetValueType: DexiValueType; override;
    method GetValueSize: Integer; override;
    method GetIsDefined: Boolean; override;
    method GetAsInteger: Integer; override;
    method SetAsInteger(aInt: Integer); override;
    method GetAsFloat: Float; override;
    method SetAsFloat(aFlt: Float); override;
    method GetLowInt: Integer; override;
    method GetHighInt: Integer; override;
    method GetLowFloat: Float; override;
    method GetHighFloat: Float; override;
    method SetAsIntInterval(aIntInterval: IntInterval); override;
    method SetAsFltInterval(aFltInterval: FltInterval); override;
    method GetAsIntSet: IntArray; override;
    method SetAsIntSet(aIntSet: IntArray); override;
    method GetAsDistribution: Distribution; override;
    method SetAsDistribution(aDistr: Distribution); override;
    method SetAsString(aStr: String); override;
    method GetIsEmpty: Boolean; override;
  public
    constructor; empty;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;

    method Member(aInt: Integer): Boolean; override;
    method Member(aFlt: Float): Boolean; override;
    method SameValue(aValue: DexiValue): Boolean; override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CompareWith(aValue: DexiValue; aMethod: DexiValueMethod): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Integer); override;
    method IntoBounds(aLow, aHigh: Float); override;
  end;

type
  DexiIntValue = public abstract class(DexiValue)
  protected
    method GetHasFltSingle: Boolean; override;
    method SetAsFloat(aFlt: Float); override;
    method GetLowFloat: Float; override;
    method GetHighFloat: Float; override;
  public
    method Member(aFlt: Float): Boolean; override;
    method Insert(aIdx: Integer); virtual; abstract;
    method Delete(aIdx: Integer); virtual; abstract;
    method Duplicate(aIdx: Integer); virtual; abstract;
    method Merge(aFrom, aTo: Integer); virtual; abstract;
    method Move(aFrom, aTo: Integer); virtual; abstract;
    method &Reverse(aLow, aHigh: Integer); virtual; abstract;
    method IntoBounds(aLow, aHigh: Float); override;
    property LowValue: Integer read GetLowInt;
    property HighValue: Integer read GetHighInt;
  end;

type
  DexiIntSingle = public class(DexiIntValue)
  protected
    fValue: Integer;
    method GetValue: Integer; virtual;
    method SetValue(aValue: Integer); virtual;
    method GetValueType: DexiValueType; override;
    method GetHasIntSingle: Boolean; override;
    method GetHasIntInterval: Boolean; override;
    method GetHasIntSet: Boolean; override;
    method GetAsInteger: Integer; override;
    method SetAsInteger(aInt: Integer); override;
    method GetAsFloat: Float; override;
    method GetLowInt: Integer; override;
    method GetHighInt: Integer; override;
    method SetAsIntInterval(aIntInt: IntInterval); override;
    method SetAsFltInterval(aFltInt: FltInterval); override;
    method GetAsIntSet: IntArray; override;
    method SetAsIntSet(aIntSet: IntArray); override;
    method GetAsDistribution: Distribution; override;
    method SetAsDistribution(aDistr: Distribution); override;
  public
    constructor (aValue: Integer := 0);
    method Clear; override;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;
    method Insert(aIdx: Integer); override;
    method Delete(aIdx: Integer); override;
    method Duplicate(aIdx: Integer); override;
    method Merge(aFrom, aTo: Integer); override;
    method Move(aFrom, aTo: Integer); override;
    method &Reverse(aLow, aHigh: Integer); override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Integer); override;
    property Value: Integer read GetValue write SetValue;
  end;

type
  DexiIntInterval = public class(DexiIntValue)
  protected
    fValue: IntInterval;
    method GetValue: IntInterval; virtual;
    method SetValue(aValue: IntInterval); virtual;
    method GetValueType: DexiValueType; override;
    method GetHasIntSingle: Boolean; override;
    method GetHasIntInterval: Boolean; override;
    method GetHasIntSet: Boolean; override;
    method GetValueSize: Integer; override;
    method GetAsInteger: Integer; override;
    method SetAsInteger(aInt: Integer); override;
    method GetAsFloat: Float; override;
    method GetLowInt: Integer; override;
    method GetHighInt: Integer; override;
    method SetAsIntInterval(aIntInt: IntInterval); override;
    method SetAsFltInterval(aFltInt: FltInterval); override;
    method GetAsIntSet: IntArray; override;
    method SetAsIntSet(aSet: IntSet); override;
    method GetAsDistribution: Distribution; override;
    method SetAsDistribution(aDistr: Distribution); override;
  public
    constructor;
    constructor (aLow, aHigh: Integer);
    constructor (aLowHigh: Integer);
    constructor (aIntInt: IntInterval);
    method Clear; override;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;
    method Normalize(aNorm: Normalization := Normalization.normNone); override;
    method Include(aInt: Integer);
    method Include(aIntInt: IntInterval);
    method Insert(aIdx: Integer); override;
    method Delete(aIdx: Integer); override;
    method Duplicate(aIdx: Integer); override;
    method Merge(aFrom, aTo: Integer); override;
    method Move(aFrom, aTo: Integer); override;
    method &Reverse(aLow, aHigh: Integer); override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Integer); override;
    property Value: IntInterval read GetValue write SetValue;
  end;

type
  DexiIntSet = public class(DexiIntValue)
  protected
    fValue: IntSet;
    method GetValue: IntSet; virtual;
    method SetValue(aValue: IntSet); virtual;
    method GetValueType: DexiValueType; override;
    method GetHasIntSingle: Boolean; override;
    method GetHasIntInterval: Boolean; override;
    method GetHasIntSet: Boolean; override;
    method GetValueSize: Integer; override;
    method GetAsInteger: Integer; override;
    method SetAsInteger(aInt: Integer); override;
    method GetAsFloat: Float; override;
    method GetLowInt: Integer; override;
    method GetHighInt: Integer; override;
    method SetAsIntInterval(aIntInt: IntInterval); override;
    method SetAsFltInterval(aFltInt: FltInterval); override;
    method GetAsIntSet: IntSet; override;
    method SetAsIntSet(aIntSet: IntSet); override;
    method GetAsDistribution: Distribution; override;
    method SetAsDistribution(aDistr: Distribution); override;
    method GetIsEmpty: Boolean; override;
    method GetElement(aIdx: Integer): Integer; virtual;
  public
    constructor (aSet: IntSet := nil);
    constructor (aLow, aHigh: Integer);
    method Clear; override;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;
    method Normalize(aNorm: Normalization := Normalization.normNone); override;
    method Include(aInt: Integer); virtual;
    method Include(aIncl: IntSet); virtual;
    method Exclude(aInt: Integer); virtual;
    method Exclude(aExcl: IntSet); virtual;
    method Member(aInt: Integer): Boolean; override;
    method Insert(aIdx: Integer); override;
    method Delete(aIdx: Integer); override;
    method Duplicate(aIdx: Integer); override;
    method Merge(aFrom, aTo: Integer); override;
    method Move(aFrom, aTo: Integer); override;
    method &Reverse(aLow, aHigh: Integer); override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Integer); override;
    property Value: IntSet read GetValue write SetValue;
    property Element[aIdx: Integer]: Integer read GetElement;
  end;

type
  DexiDistribution = public class(DexiIntValue)
  protected
    fValue: Distribution;
    method GetValue: Distribution; virtual;
    method SetValue(aValue: Distribution); virtual;
    method GetValueType: DexiValueType; override;
    method GetHasIntSingle: Boolean; override;
    method GetHasIntInterval: Boolean; override;
    method GetHasIntSet: Boolean; override;
    method GetValueSize: Integer; override;
    method GetAsInteger: Integer; override;
    method SetAsInteger(aInt: Integer); override;
    method GetAsFloat: Float; override;
    method GetLowInt: Integer; override;
    method GetHighInt: Integer; override;
    method SetAsIntInterval(aIntInt: IntInterval); override;
    method SetAsFltInterval(aFltInt: FltInterval); override;
    method GetAsIntSet: IntArray; override;
    method SetAsIntSet(aSet: IntArray); override;
    method GetAsDistribution: Distribution; override;
    method SetAsDistribution(aDistr: Distribution); override;
    method GetIsEmpty: Boolean; override;
    method GetBase: Integer;
    method SetBase(aBase: Integer);
    method GetDistr: FltArray;
    method GetLowIndex: Integer;
    method GetHighIndex: Integer;
    method GetElement(aIdx: Integer): Float;
    method SetElement(aIdx: Integer; aFlt: Float);
    method GetMin: Float; virtual;
    method GetMax: Float; virtual;
    method GetSum: Float; virtual;
  public
    constructor;
    constructor (aDistr: Distribution);
    constructor (aBase: Integer; aDistr: FltArray);
    method Clear; override;
    method Clean; virtual;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;
    method Normalize(aNorm: Normalization := Normalization.normNone); override;
    method SetBounds(aLow, aHigh: Integer);
    method ExtendBounds(aLow, aHigh: Integer);
    method Multiply(aMul: Float);
    method Divide(aDiv: Float);
    method Member(aInt: Integer): Boolean; override;
    method Insert(aIdx: Integer); override;
    method Delete(aIdx: Integer); override;
    method Duplicate(aIdx: Integer); override;
    method Merge(aFrom, aTo: Integer); override;
    method Merge(aFrom, aTo: Integer; aNorm: Normalization);
    method Move(aFrom, aTo: Integer); override;
    method &Reverse(aLow, aHigh: Integer); override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Integer); override;
    property Value: Distribution read GetValue write SetValue;
    property LowIndex: Integer read GetLowIndex;
    property HighIndex: Integer read GetHighIndex;
    property Base: Integer read GetBase write SetBase;
    property Distr: FltArray read GetDistr;
    property Min: Float read GetMin;
    property Max: Float read GetMax;
    property Sum: Float read GetSum;
    property Element[aIdx: Integer]: Float read GetElement write SetElement;
  end;

type
  DexiFltValue = public abstract class(DexiValue)
  protected
    method GetHasIntSingle: Boolean; override;
    method GetHasIntInterval: Boolean; override;
    method GetHasIntSet: Boolean; override;
    method GetAsInteger: Integer; override;
    method SetAsInteger(aInt: Integer); override;
    method GetLowInt: Integer; override;
    method GetHighInt: Integer; override;
    method GetAsIntSet: IntArray; override;
    method SetAsIntSet(aIntSet: IntArray); override;
    method GetAsDistribution: Distribution; override;
    method SetAsDistribution(aDistr: Distribution); override;
  public
    method Member(aInt: Integer): Boolean; override;
    method IntoBounds(aLow, aHigh: Integer); override;
    property LowValue: Float read GetLowFloat;
    property HighValue: Float read GetHighFloat;
  end;

type
  DexiFltSingle = public class(DexiFltValue)
  protected
    fValue: Float;
    method GetValue: Float; virtual;
    method SetValue(aValue: Float); virtual;
    method GetValueType: DexiValueType; override;
    method GetHasFltSingle: Boolean; override;
    method GetAsFloat: Float; override;
    method SetAsFloat(aFloat: Float); override;
    method GetLowFloat: Float; override;
    method GetHighFloat: Float; override;
    method GetAsIntInterval: IntInterval; override;
    method SetAsIntInterval(aIntInt: IntInterval); override;
    method SetAsDistribution(aDistr: Distribution); override;
    method GetAsFltInterval: FltInterval; override;
    method SetAsFltInterval(aFltInt: FltInterval); override;
  public
    constructor (aValue: Float := 0.0);
    method Clear; override;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Float); override;
    property Value: Float read GetValue write SetValue;
  end;

type
  DexiFltInterval = public class(DexiFltValue)
  protected
    fValue: FltInterval;
    method GetValue: FltInterval; virtual;
    method SetValue(aValue: FltInterval); virtual;
    method GetValueType: DexiValueType; override;
    method GetHasFltSingle: Boolean; override;
    method GetValueSize: Integer; override;
    method GetAsFloat: Float; override;
    method SetAsFloat(aFloat: Float); override;
    method GetLowFloat: Float; override;
    method GetHighFloat: Float; override;
    method GetAsIntInterval: IntInterval; override;
    method SetAsIntInterval(aIntInt: IntInterval); override;
    method GetAsFltInterval: FltInterval; override;
    method SetAsFltInterval(aFltInt: FltInterval); override;
  public
    constructor;
    constructor (aLow, aHigh: Float);
    constructor (aLowHigh: Float);
    method Clear; override;
    method ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String; override;
    method FromString(aStr: String; aInvariant: Boolean := true); override;
    method Normalize(aNorm: Normalization := Normalization.normNone); override;
    method EqualTo(aValue: DexiValue): Boolean; override;
    method CompareWith(aValue: DexiValue): PrefCompare; override;
    method CanAssignLosslessly(aValue: DexiValue): Boolean; override;
    method AssignValue(aValue: DexiValue); override;
    method IntoBounds(aLow, aHigh: Float); override;
    property Value: FltInterval read GetValue write SetValue;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiValue}

class method DexiValue.CreateValue(aValueType: DexiValueType): DexiValue;
begin
  result :=
    case aValueType of
      DexiValueType.Undefined:    new DexiUndefinedValue;
      DexiValueType.None:         nil;
      DexiValueType.IntSingle:    new DexiIntSingle;
      DexiValueType.IntInterval:  new DexiIntInterval;
      DexiValueType.IntSet:       new DexiIntSet;
      DexiValueType.Distribution: new DexiDistribution;
      DexiValueType.FltSingle:    new DexiFltSingle;
      DexiValueType.FltInterval:  new DexiFltInterval;
    end;
end;

class method DexiValue.CopyValue(aValue: DexiValue): DexiValue;
begin
  if aValue = nil then
    result := nil
  else
    begin
      var aValType := aValue.ValueType;
      result := CreateValue(aValType);
      result.AssignValue(aValue);
    end;
end;

class method DexiValue.SimplifyValue(aValue: DexiValue): DexiValue;
begin
  result := aValue;
  if aValue = nil then
    exit;
  if aValue.IsInteger then
    begin
      if aValue.HasIntSingle then
        begin
          if not (aValue is DexiIntSingle) then
            result := new DexiIntSingle(aValue.AsInteger)
        end
      else if aValue.HasIntInterval then
        begin
          if not (aValue is DexiIntInterval) then
          result := new DexiIntInterval(aValue.AsIntInterval);
        end
      else if aValue.HasIntSet then
        begin
          if not (aValue is DexiIntSet) then
            result := new DexiIntSet(aValue.AsIntSet);
        end
    end
  else if aValue.IsFloat then
    begin
      if aValue.HasFltSingle then
        begin
          if not (aValue is DexiFltSingle) then
            result := new DexiFltSingle(aValue.AsFloat);
        end;
    end;
end;

class method DexiValue.CompactValue(aValue: DexiValue): DexiValue;
begin
  result := aValue;
  if aValue = nil then
    exit;
  if aValue.HasIntSingle then
    begin
      if not (aValue is DexiIntSingle) then
        result := new DexiIntSingle(aValue.AsInteger);
    end
  else if aValue.HasIntInterval then
    begin
      if not (aValue is DexiIntInterval) then
        result := new DexiIntInterval(aValue.AsIntInterval);
    end
  else if aValue.HasIntSet then
    begin
      if not (aValue is DexiIntSet) then
        result := new DexiIntSet(aValue.AsIntSet)
    end
  else if aValue.HasFltSingle then
    begin
      if not (aValue is DexiFltSingle) then
        result := new DexiFltSingle(aValue.AsFloat);
    end;
end;

class method DexiValue.CompareValues(aValue1, aValue2: DexiValue; aMethod: DexiValueMethod): PrefCompare;
begin
  result :=
    if aValue1 = aValue2 then PrefCompare.Equal
    else if DexiValue.ValueIsDefined(aValue1) and DexiValue.ValueIsDefined(aValue2) then aValue1.CompareWith(aValue2, aMethod)
    else PrefCompare.No;
end;

class method DexiValue.ValueIsFloat(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.IsFloat;
end;

class method DexiValue.ValueIsInteger(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.IsInteger;
end;

class method DexiValue.ValueIsDefined(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.IsDefined;
end;

class method DexiValue.ValueIsUndefined(aValue: DexiValue): Boolean;
begin
  result := not ValueIsDefined(aValue);
end;

class method DexiValue.ValuesAreEqual(aVal1, aVal2: DexiValue): Boolean;
begin
  result :=
    if aVal1 = aVal2 then true
    else if aVal1 = nil then aVal2 = nil
    else if aVal1.HasIntSingle and aVal2.HasIntSingle then aVal1.AsInteger = aVal2.AsInteger
    else if aVal1.HasIntInterval and aVal2.HasIntInterval then Values.IntIntEq(aVal1.AsIntInterval, aVal2.AsIntInterval)
    else if aVal1.HasIntSet and aVal2.HasIntSet then Values.IntSetEq(aVal1.AsIntSet, aVal2.AsIntSet)
    else if aVal1.HasFltSingle and aVal2.HasFltSingle then Utils.FloatEq(aVal1.AsFloat, aVal2.AsFloat)
    else Values.DistrEq(aVal1.AsDistribution, aVal2.AsDistribution);
end;

class method DexiValue.IsUndefined(aStr: String): Boolean;
begin
  if String.IsNullOrEmpty(aStr) then
    exit false;
  aStr := aStr.ToLower;
  result := (aStr = DexiString.SDexiUndefValue) or (aStr.Contains('undef'));
end;

class method DexiValue.ToString(aValue: DexiValue; aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  if aValue = nil then
    result := ''
  else
    begin
      result := aValue.ToString(aInvariant, aDecimals);
      if aValue.IsDefined then
        if not(result.StartsWith('{') or result.StartsWith('<')) then
          if aValue.IsSet then
            result := '{' + result + '}'
          else if aValue.IsDistribution then
            result := '<' + result + '>';
    end;
end;

class method DexiValue.FromIntString(aStr: String; aInvariant: Boolean := true): DexiValue;
begin
  result := nil;
  if String.IsNullOrEmpty(aStr) then
    exit;
  if IsUndefined(aStr) then
    exit new DexiUndefinedValue;
  try
    if aStr.StartsWith('{') and aStr.EndsWith('}') then {IntSet}
      begin
        result := new DexiIntSet;
        aStr := aStr.Substring(1, aStr.Length - 2);
      end
    else if aStr.StartsWith('<') and aStr.EndsWith('>') then {Distribution}
      begin
        result := new DexiDistribution;
        aStr := aStr.Substring(1, aStr.Length - 2);
      end
    else if aStr.Contains(':') then { IntInterval }
      result := new DexiIntInterval
    else
      result := new DexiIntSingle;
    result.FromString(aStr, aInvariant);
  except
    raise new EDexiError(String.Format(DexiString.SDexiIntValueError, [aStr]));
  end;
end;

class method DexiValue.FromFltString(aStr: String; aInvariant: Boolean := true): DexiValue;
begin
  result := nil;
  if String.IsNullOrEmpty(aStr) then
    exit;
  if IsUndefined(aStr) then
    exit new DexiUndefinedValue;
  if String.IsNullOrEmpty(aStr) or (aStr = DexiString.SDexiUndefValue) then
    exit;
  try
    result :=
      if aStr.Contains(':') then new DexiFltInterval
      else new DexiFltSingle;
    result.FromString(aStr, aInvariant);
  except
    raise new EDexiError(String.Format(DexiString.SDexiFltValueError, [aStr]));
  end;
end;

class method DexiValue.FromString(aStr: String; aInvariant: Boolean := true): DexiValue;
begin
  result := nil;
  if String.IsNullOrEmpty(aStr) then
    exit;
  if IsUndefined(aStr) then
    exit new DexiUndefinedValue;
  try
    result := FromIntString(aStr, aInvariant);
  except
    try
      result := FromFltString(aStr, aInvariant);
    except
      raise new EDexiError(String.Format(DexiString.SDexiValueError, [aStr]));
    end;
  end;
end;

method DexiValue.CollectUndoableObjects(aList: List<IUndoable>);
begin
  // none
end;

method DexiValue.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiValue then
    exit false;
  var lVal := DexiValue(aObj);
  result := lVal.EqualTo(self);
end;

method DexiValue.GetUndoState: IUndoable;
begin
  var lVal := CopyValue(self);
  result := lVal;
end;

method DexiValue.SetUndoState(aState: IUndoable);
begin
  var lValue := aState as DexiValue;
  AssignValue(lValue);
end;

method DexiValue.GetValueType: DexiValueType;
begin
  result := DexiValueType.None;
end;

method DexiValue.GetValueSize: Integer;
begin
  result := 1;
end;

method DexiValue.GetIsInteger: Boolean;
begin
  result := ValueType in [DexiValueType.IntSingle .. DexiValueType.Distribution];
end;

method DexiValue.GetIsFloat: Boolean;
begin
  result := ValueType in [DexiValueType.FltSingle .. DexiValueType.FltInterval];
end;

method DexiValue.GetIsSingle: Boolean;
begin
 result := ValueType in [DexiValueType.IntSingle, DexiValueType.FltSingle];
end;

method DexiValue.GetIsInterval: Boolean;
begin
  result := ValueType in [DexiValueType.IntInterval, DexiValueType.FltInterval];
end;

method DexiValue.GetIsSet: Boolean;
begin
  result := ValueType = DexiValueType.IntSet;
end;

method DexiValue.GetIsDistribution: Boolean;
begin
  result := ValueType = DexiValueType.Distribution;
end;

method DexiValue.GetIsDefined: Boolean;
begin
  result := true;
end;

method DexiValue.GetHasIntSingle: Boolean;
begin
  result := false;
end;

method DexiValue.GetHasIntInterval: Boolean;
begin
  result := false;
end;

method DexiValue.GetHasIntSet: Boolean;
begin
  result := false;
end;

method DexiValue.GetHasFltSingle: Boolean;
begin
  result := false;
end;

method DexiValue.GetAsIntInterval: IntInterval;
begin
  result := Values.IntInt(LowInt, HighInt);
end;

method DexiValue.GetAsFltInterval: FltInterval;
begin
  result := Values.FltInt(LowFloat, HighFloat);
end;

method DexiValue.GetAsString: String;
begin
  result := ToString;
end;

method DexiValue.SetAsString(aStr: String);
begin
  FromString(aStr);
end;

method DexiValue.GetIsEmpty: Boolean;
begin
  result := LowFloat > HighFloat;
end;

method DexiValue.Member(aInt: Integer): Boolean;
begin
  result := LowInt <= aInt <= HighInt;
end;

method DexiValue.Member(aFlt: Float): Boolean;
begin
  result := LowFloat <= aFlt <= HighFloat;
end;

method DexiValue.EqualTo(aValue: DexiValue): Boolean;
begin
  result := false;
end;

method DexiValue.SameValue(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and (ValueType = aValue.ValueType) and EqualTo(aValue);
end;

method DexiValue.CompareWith(aValue: DexiValue; aMethod: DexiValueMethod): PrefCompare;
begin
  result := PrefCompare.No;
  if IsInteger then
    case aMethod of
      DexiValueMethod.Single:   result := Values.IntToPrefCompare(Utils.Compare(AsInteger, aValue.AsInteger));
      DexiValueMethod.Interval: result := Values.CompareIntInterval(AsIntInterval, aValue.AsIntInterval);
      DexiValueMethod.Set:      result := Values.CompareIntSet(AsIntSet, aValue.AsIntSet);
      DexiValueMethod.Distr:    result := Values.CompareDistr(AsDistribution, aValue.AsDistribution);
    end
  else if IsFloat then
    case aMethod of
      DexiValueMethod.Single:   result := Values.IntToPrefCompare(Utils.Compare(AsFloat, aValue.AsFloat));
      DexiValueMethod.Interval: result := Values.CompareFltInterval(AsFltInterval, aValue.AsFltInterval);
    end;
end;

method DexiValue.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := false;
end;

method DexiValue.InBounds(aLow, aHigh: Integer): Boolean;
begin
  result :=
    if IsEmpty then true
    else (aLow <= LowInt <= aHigh) and (aLow <= HighInt <= aHigh);
end;

method DexiValue.InBounds(aLow, aHigh: Float): Boolean;
begin
  result := (aLow <= LowFloat <= aHigh) and (aLow <= HighFloat <= aHigh);
end;

{$ENDREGION}

{$REGION DexiUndefinedValue}

method DexiUndefinedValue.OperationError(aOp: String);
begin
  raise new EDexiError(String.Format(DexiString.SDexiUndefValueOperation, [aOp]));
end;

method DexiUndefinedValue.GetValueType: DexiValueType;
begin
  result := DexiValueType.Undefined;
end;

method DexiUndefinedValue.GetValueSize: Integer;
begin
  result := 0;
end;

method DexiUndefinedValue.GetIsDefined: Boolean;
begin
  result := false;
end;

method DexiUndefinedValue.GetAsInteger: Integer;
begin
  OperationError('GetAsInteger');
end;

method DexiUndefinedValue.SetAsInteger(aInt: Integer);
begin
  OperationError('SetAsInteger');
end;

method DexiUndefinedValue.GetAsFloat: Float;
begin
  OperationError('GetAsFloat');
end;

method DexiUndefinedValue.SetAsFloat(aFlt: Float);
begin
  OperationError('SetAsFloat');
end;

method DexiUndefinedValue.GetLowInt: Integer;
begin
  OperationError('GetLowInt');
end;

method DexiUndefinedValue.GetHighInt: Integer;
begin
  OperationError('GetHighInt');
end;

method DexiUndefinedValue.GetLowFloat: Float;
begin
  OperationError('GetLowFloat');
end;

method DexiUndefinedValue.GetHighFloat: Float;
begin
  OperationError('GetHighFloat');
end;

method DexiUndefinedValue.SetAsIntInterval(aIntInterval: IntInterval);
begin
  OperationError('SetAsIntInterval');
end;

method DexiUndefinedValue.SetAsFltInterval(aFltInterval: FltInterval);
begin
  OperationError('SetAsFltInterval');
end;

method DexiUndefinedValue.GetAsIntSet: IntArray;
begin
  OperationError('GetAsIntSet');
end;

method DexiUndefinedValue.SetAsIntSet(aIntSet: IntArray);
begin
  OperationError('SetAsIntSet');
end;

method DexiUndefinedValue.GetAsDistribution: Distribution;
begin
  OperationError('GetAsDistribution');
end;

method DexiUndefinedValue.SetAsDistribution(aDistr: Distribution);
begin
  OperationError('SetAsDistribution');
end;

method DexiUndefinedValue.SetAsString(aStr: String);
begin
  if not String.IsNullOrEmpty(aStr) and ((aStr = DexiString.SDexiUndefValue) or aStr.ToLower.Contains('undef')) then
    exit;
  OperationError('SetAsString');
end;

method DexiUndefinedValue.GetIsEmpty: Boolean;
begin
  result := true;
end;

method DexiUndefinedValue.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := DexiString.SDexiUndefValue;
end;

method DexiUndefinedValue.FromString(aStr: String; aInvariant: Boolean := true);
begin
  AsString := aStr;
end;

method DexiUndefinedValue.Member(aInt: Integer): Boolean;
begin
  result := false;
end;

method DexiUndefinedValue.Member(aFlt: Float): Boolean;
begin
  result := false;
end;

method DexiUndefinedValue.SameValue(aValue: DexiValue): Boolean;
begin
  result := aValue is DexiUndefinedValue;
end;

method DexiUndefinedValue.EqualTo(aValue: DexiValue): Boolean;
begin
  result := false;
end;

method DexiUndefinedValue.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result := PrefCompare.No;
end;

method DexiUndefinedValue.CompareWith(aValue: DexiValue; aMethod: DexiValueMethod): PrefCompare;
begin
  result := PrefCompare.No;
end;

method DexiUndefinedValue.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := false;
end;

method DexiUndefinedValue.AssignValue(aValue: DexiValue);
begin
end;

method DexiUndefinedValue.IntoBounds(aLow, aHigh: Integer);
begin
end;

method DexiUndefinedValue.IntoBounds(aLow, aHigh: Float);
begin
end;

{$ENDREGION}

{$REGION DexiIntValue}

method DexiIntValue.GetHasFltSingle: Boolean;
begin
  result := HasIntSingle;
end;

method DexiIntValue.SetAsFloat(aFlt: Float);
begin
  AsInteger := Values.IntSingle(aFlt);
end;

method DexiIntValue.GetLowFloat: Float;
begin
  result := LowInt;
end;

method DexiIntValue.GetHighFloat: Float;
begin
  result := HighInt;
end;

method DexiIntValue.Member(aFlt: Float): Boolean;
begin
  var lInt := Values.IntSingle(aFlt);
  result :=  (lInt = aFlt) and Member(lInt);
end;

method DexiIntValue.IntoBounds(aLow, aHigh: Float);
begin
  IntoBounds(Values.IntSingle(Math.Ceiling(aLow)), Values.IntSingle(Math.Floor(aHigh)));
end;

{$ENDREGION}

{$REGION DexiIntSingle}

constructor DexiIntSingle(aValue: Integer := 0);
begin
  Value := aValue;
end;

method DexiIntSingle.Clear;
begin
  fValue := 0;
end;

method DexiIntSingle.GetValueType: DexiValueType;
begin
  result := DexiValueType.IntSingle;
end;

method DexiIntSingle.GetValue: Integer;
begin
  result := fValue;
end;

method DexiIntSingle.SetValue(aValue: Integer);
begin
  fValue := aValue;
end;

method DexiIntSingle.GetHasIntSingle: Boolean;
begin
  result := true;
end;

method DexiIntSingle.GetHasIntInterval: Boolean;
begin
  result := true;
end;

method DexiIntSingle.GetHasIntSet: Boolean;
begin
  result := true;
end;

method DexiIntSingle.GetAsInteger: Integer;
begin
  result := fValue;
end;

method DexiIntSingle.SetAsInteger(aInt: Integer);
begin
  Value := aInt;
end;

method DexiIntSingle.GetAsFloat: Float;
begin
  result := fValue;
end;

method DexiIntSingle.GetLowInt: Integer;
begin
  result := fValue;
end;

method DexiIntSingle.GetHighInt: Integer;
begin
  result := fValue;
end;

method DexiIntSingle.SetAsIntInterval(aIntInt: IntInterval);
begin
  Value := Values.IntSingle(aIntInt);
end;

method DexiIntSingle.SetAsFltInterval(aFltInt: FltInterval);
begin
  Value := Values.IntSingle(aFltInt);
end;

method DexiIntSingle.GetAsIntSet: IntArray;
begin
  result := Values.IntSet(fValue);
end;

method DexiIntSingle.SetAsIntSet(aIntSet: IntArray);
begin
  Value := Values.IntSingle(aIntSet);
end;

method DexiIntSingle.GetAsDistribution: Distribution;
begin
  result := Values.Distr(fValue);
end;

method DexiIntSingle.SetAsDistribution(aDistr: Distribution);
begin
  Value := Values.IntSingle(aDistr);
end;

method DexiIntSingle.Insert(aIdx: Integer);
begin
  Value := Utils.InsertIndex(fValue, aIdx);
end;

method DexiIntSingle.Delete(aIdx: Integer);
begin
  Value := Utils.DeleteIndex(fValue, aIdx);
end;

method DexiIntSingle.Duplicate(aIdx: Integer);
begin
  Value := Utils.DuplicateIndex(fValue, aIdx);
end;

method DexiIntSingle.Merge(aFrom, aTo: Integer);
begin
  Value := Utils.MergeIndex(fValue, aFrom, aTo);
end;

method DexiIntSingle.Move(aFrom, aTo: Integer);
begin
  Value := Utils.MoveIndex(fValue, aFrom, aTo);
end;

method DexiIntSingle.Reverse(aLow, aHigh: Integer);
begin
  Value := Utils.ReverseIndex(fValue, aLow, aHigh);
end;

method DexiIntSingle.EqualTo(aValue: DexiValue): Boolean;
begin
  result :=
    if aValue = nil then false
    else fValue = aValue.AsInteger;
end;

method DexiIntSingle.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result :=
    if aValue = nil then PrefCompare.No
    else Values.IntToPrefCompare(Utils.Compare(fValue, aValue.AsInteger));
end;

method DexiIntSingle.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.HasIntSingle;
end;

method DexiIntSingle.AssignValue(aValue: DexiValue);
begin
  if assigned(aValue) then
    Value := aValue.AsInteger
  else
    Clear;
end;

method DexiIntSingle.IntoBounds(aLow, aHigh: Integer);
begin
  Value := Values.IntoBounds(Value, aLow, aHigh);
end;

method DexiIntSingle.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := Utils.IntToStr(Value);
end;

method DexiIntSingle.FromString(aStr: String; aInvariant: Boolean := true);
begin
  Value := Utils.StrToInt(aStr);
end;

{$ENDREGION}

{$REGION DexiIntInterval}

constructor DexiIntInterval;
begin
  constructor(0, 0);
end;

constructor DexiIntInterval(aLow, aHigh: Integer);
begin
  fValue.Low := aLow;
  fValue.High:= aHigh;
end;

constructor DexiIntInterval(aLowHigh: Integer);
begin
  constructor(aLowHigh, aLowHigh);
end;

constructor DexiIntInterval(aIntInt: IntInterval);
begin
  constructor(aIntInt.Low, aIntInt.High);
end;

method DexiIntInterval.Clear;
begin
  Value := Values.IntInt(0);
end;

method DexiIntInterval.GetValue: IntInterval;
begin
  result := fValue;
end;

method DexiIntInterval.SetValue(aValue: IntInterval);
begin
  fValue := aValue;
end;

method DexiIntInterval.GetValueType: DexiValueType;
begin
  result := DexiValueType.IntInterval;
end;

method DexiIntInterval.GetHasIntSingle: Boolean;
begin
  result := fValue.Low = fValue.High;
end;

method DexiIntInterval.GetHasIntInterval: Boolean;
begin
  result := true;
end;

method DexiIntInterval.GetHasIntSet: Boolean;
begin
  result := true;
end;

method DexiIntInterval.GetValueSize: Integer;
begin
  result := fValue.High - fValue.Low + 1;
end;

method DexiIntInterval.GetAsInteger: Integer;
begin
  result := Values.IntSingle(fValue);
end;

method DexiIntInterval.SetAsInteger(aInt: Integer);
begin
  Value := Values.IntInt(aInt);
end;

method DexiIntInterval.GetAsFloat: Float;
begin
  result := Values.FltSingle(Values.FltInt(fValue));
end;

method DexiIntInterval.GetLowInt: Integer;
begin
  result := fValue.Low;
end;

method DexiIntInterval.GetHighInt: Integer;
begin
  result := fValue.High;
end;

method DexiIntInterval.SetAsIntInterval(aIntInt: IntInterval);
begin
  Value := aIntInt;
  Normalize;
end;

method DexiIntInterval.SetAsFltInterval(aFltInt: FltInterval);
begin
  Value := Values.IntInt(aFltInt);
  Normalize;
end;

method DexiIntInterval.GetAsIntSet: IntArray;
begin
  result := Values.IntSet(fValue);
end;

method DexiIntInterval.SetAsIntSet(aSet: IntSet);
begin
  Value := Values.IntInt(aSet);
end;

method DexiIntInterval.GetAsDistribution: Distribution;
begin
  result := Values.Distr(fValue);
end;

method DexiIntInterval.SetAsDistribution(aDistr: Distribution);
begin
  Value := Values.IntInt(aDistr);
end;

method DexiIntInterval.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := Values.IntIntToStr(fValue);
end;

method DexiIntInterval.FromString(aStr: String; aInvariant: Boolean := true);
begin
  Value := Values.StrToIntInt(aStr);
end;

method DexiIntInterval.Normalize(aNorm: Normalization := Normalization.normNone);
begin
  Values.NormIntInt(var fValue);
end;

method DexiIntInterval.Include(aInt: Integer);
begin
  Value := Values.IntInt(Math.Min(LowValue, aInt), Math.Max(HighValue, aInt));
end;

method DexiIntInterval.Include(aIntInt: IntInterval);
begin
  Value := Values.IntInt(Math.Min(LowValue, Math.Min(aIntInt.Low, aIntInt.High)), Math.Max(HighValue, Math.Max(aIntInt.Low, aIntInt.High)));
end;

method DexiIntInterval.Insert(aIdx: Integer);
begin
  Value := Values.IntInt(Utils.InsertIndex(fValue.Low, aIdx), Utils.InsertIndex(fValue.High, aIdx));
end;

method DexiIntInterval.Delete(aIdx: Integer);
begin
  Value := Values.IntInt(Utils.DeleteIndex(fValue.Low, aIdx), Utils.DeleteIndex(fValue.High, aIdx));
end;

method DexiIntInterval.Duplicate(aIdx: Integer);
begin
  Value := Values.IntInt(Utils.DuplicateIndex(fValue.Low, aIdx), Utils.DuplicateIndex(fValue.High, aIdx));
end;

method DexiIntInterval.Merge(aFrom, aTo: Integer);
begin
  Value := Values.IntInt(Utils.MergeIndex(fValue.Low, aFrom, aTo), Utils.MergeIndex(fValue.High, aFrom, aTo));
end;

method DexiIntInterval.Move(aFrom, aTo: Integer);
begin
  Value := Values.IntInt(Utils.MoveIndex(fValue.Low, aFrom, aTo), Utils.MoveIndex(fValue.High, aFrom, aTo));
end;

method DexiIntInterval.&Reverse(aLow, aHigh: Integer);
begin
  Value := Values.IntInt(Utils.ReverseIndex(fValue.Low, aLow, aHigh), Utils.ReverseIndex(fValue.High, aLow, aHigh));
  Normalize;
end;

method DexiIntInterval.EqualTo(aValue: DexiValue): Boolean;
begin
  result :=
    if aValue = nil then false
    else Values.IntIntEq(fValue, aValue.AsIntInterval);
end;

method DexiIntInterval.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result :=
    if aValue = nil then PrefCompare.No
    else Values.CompareIntInterval(fValue, aValue.AsIntInterval);
end;

method DexiIntInterval.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.HasIntInterval;
end;

method DexiIntInterval.AssignValue(aValue: DexiValue);
begin
  if assigned(aValue) then
    Value := aValue.AsIntInterval
  else
    Clear;
end;

method DexiIntInterval.IntoBounds(aLow, aHigh: Integer);
begin
  Value := Values.IntoBounds(fValue, aLow, aHigh);
end;

{$ENDREGION}

{$REGION DexiIntSet}

constructor DexiIntSet(aSet: IntSet := nil);
begin
  Value := aSet;
end;

constructor DexiIntSet(aLow, aHigh: Integer);
begin
  AsIntInterval := Values.IntInt(aLow, aHigh);
end;

method DexiIntSet.Clear;
begin
  fValue := nil;
end;

method DexiIntSet.GetValue: IntSet;
begin
  result := fValue;
end;

method DexiIntSet.SetValue(aValue: IntSet);
begin
  fValue := aValue;
end;

method DexiIntSet.GetValueType: DexiValueType;
begin
  result := DexiValueType.IntSet;
end;

method DexiIntSet.GetHasIntSingle: Boolean;
begin
  result := length(fValue) = 1;
end;

method DexiIntSet.GetHasIntInterval: Boolean;
begin
  result :=
    if Values.IntSetEmpty(fValue) then false
    else Values.IntSetEq(fValue, Values.IntSet(LowValue, HighValue));
end;

method DexiIntSet.GetHasIntSet: Boolean;
begin
  result := true;
end;

method DexiIntSet.GetValueSize: Integer;
begin
  result := length(fValue);
end;

method DexiIntSet.GetAsInteger: Integer;
begin
  result := Values.IntSingle(fValue);
end;

method DexiIntSet.SetAsInteger(aInt: Integer);
begin
  Value := Values.IntSet(aInt);
end;

method DexiIntSet.GetAsFloat: Float;
begin
  result := Values.IntSetMedium(fValue);
end;

method DexiIntSet.GetLowInt: Integer;
begin
  result := Values.IntSetLow(fValue);
end;

method DexiIntSet.GetHighInt: Integer;
begin
  result := Values.IntSetHigh(fValue);
end;

method DexiIntSet.SetAsIntInterval(aIntInt: IntInterval);
begin
  Value := Values.IntSet(aIntInt);
end;

method DexiIntSet.SetAsFltInterval(aFltInt: FltInterval);
begin
  Value := Values.IntSet(Values.IntInt(aFltInt));
end;

method DexiIntSet.GetAsIntSet: IntSet;
begin
  result := Values.IntSet(Value);
end;

method DexiIntSet.SetAsIntSet(aIntSet: IntSet);
begin
  Value := Values.IntSet(aIntSet);
  Normalize;
end;

method DexiIntSet.GetAsDistribution: Distribution;
begin
  result := Values.Distr(fValue);
end;

method DexiIntSet.SetAsDistribution(aDistr: Distribution);
begin
  fValue := Values.IntSet(aDistr);
end;

method DexiIntSet.GetIsEmpty: Boolean;
begin
  result := Values.IntSetEmpty(fValue);
end;

method DexiIntSet.GetElement(aIdx: Integer): Integer;
begin
  result := fValue[aIdx];
end;

method DexiIntSet.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
 result := Values.IntSetToStr(fValue);
end;

method DexiIntSet.FromString(aStr: String; aInvariant: Boolean := true);
begin
  Value := Values.StrToIntSet(aStr);
end;

method DexiIntSet.Normalize(aNorm: Normalization := Normalization.normNone);
begin
  Values.NormIntSet(var fValue);
end;

method DexiIntSet.Include(aInt: Integer);
begin
  Values.IntSetInclude(var fValue, aInt);
end;

method DexiIntSet.Include(aIncl: IntSet);
begin
  Values.IntSetInclude(var fValue, aIncl);
end;

method DexiIntSet.Exclude(aInt: Integer);
begin
  Values.IntSetExclude(var fValue, aInt);
end;

method DexiIntSet.Exclude(aExcl: IntSet);
begin
  Values.IntSetExclude(var fValue, aExcl);
end;

method DexiIntSet.Member(aInt: Integer): Boolean;
begin
  result := Values.IntSetMember(fValue, aInt);
end;

method DexiIntSet.Insert(aIdx: Integer);
begin
  for i := low(fValue) to high(fValue) do
    fValue[i] := Utils.InsertIndex(fValue[i], aIdx);
end;

method DexiIntSet.Delete(aIdx: Integer);
begin
  for i := low(fValue) to high(fValue) do
    fValue[i] := Utils.DeleteIndex(fValue[i], aIdx);
end;

method DexiIntSet.Duplicate(aIdx: Integer);
begin
  for i := low(fValue) to high(fValue) do
    fValue[i] := Utils.DuplicateIndex(fValue[i], aIdx);
end;

method DexiIntSet.Merge(aFrom, aTo: Integer);
begin
  for i := low(fValue) to high(fValue) do
    fValue[i] := Utils.MergeIndex(fValue[i], aFrom, aTo);
end;

method DexiIntSet.Move(aFrom, aTo: Integer);
begin
  for i := low(fValue) to high(fValue) do
    fValue[i] := Utils.MoveIndex(fValue[i], aFrom, aTo);
end;

method DexiIntSet.&Reverse(aLow, aHigh: Integer);
begin
  for i := low(fValue) to high(fValue) do
    fValue[i] := Utils.ReverseIndex(fValue[i], aLow, aHigh);
end;

method DexiIntSet.EqualTo(aValue: DexiValue): Boolean;
begin
  result :=
    if aValue = nil then false
    else Values.IntSetEq(fValue, aValue.AsIntSet);
end;

method DexiIntSet.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result :=
    if aValue = nil then PrefCompare.No
    else Values.CompareIntSet(fValue, aValue.AsIntSet);
end;

method DexiIntSet.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.HasIntSet;
end;

method DexiIntSet.AssignValue(aValue: DexiValue);
begin
  if assigned(aValue) then
    Value := aValue.AsIntSet
  else
    Clear;
end;

method DexiIntSet.IntoBounds(aLow, aHigh: Integer);
begin
  Value := Values.IntoBounds(fValue, aLow, aHigh);
end;

{$ENDREGION}

{$REGION DexiDistribution}

constructor DexiDistribution;
begin
  fValue := Values.EmptyDistr;
end;

constructor DexiDistribution(aDistr: Distribution);
begin
  Value := aDistr;
end;

constructor DexiDistribution(aBase: Integer; aDistr: FltArray);
begin
  constructor(Values.Distr(aBase, aDistr));
end;

method DexiDistribution.GetValue: Distribution;
begin
  result := fValue;
end;

method DexiDistribution.SetValue(aValue: Distribution);
begin
  fValue := aValue;
end;

method DexiDistribution.Clear;
begin
  Values.DistrClear(var fValue);
end;

method DexiDistribution.Clean;
begin
  Values.DistrClean(var fValue);
end;

method DexiDistribution.GetValueType: DexiValueType;
begin
  result := DexiValueType.Distribution;
end;

method DexiDistribution.GetHasIntSingle: Boolean;
begin
  result := LowValue = HighValue;
end;

method DexiDistribution.GetHasIntInterval: Boolean;
begin
  result :=
    if Values.DistrEmpty(fValue) then false
    else Values.DistrEq(fValue, Values.DistrFromTo(LowValue, HighValue));
end;

method DexiDistribution.GetHasIntSet: Boolean;
begin
  result := Values.DistrEq(fValue, Values.Distr(Values.IntSet(fValue)));
end;

method DexiDistribution.GetValueSize: Integer;
begin
  result := length(fValue.Distr);
end;

method DexiDistribution.GetAsInteger: Integer;
begin
  result := Values.IntSingle(Values.Normed(fValue, Normalization.normProb));
end;

method DexiDistribution.SetAsInteger(aInt: Integer);
begin
  Value := Values.Distr(aInt);
end;

method DexiDistribution.GetAsFloat: Float;
begin
  result := Values.DistrMedium(Values.Normed(fValue, Normalization.normProb));
end;

method DexiDistribution.GetLowInt: Integer;
begin
  result := Values.DistrLow(fValue);
end;

method DexiDistribution.GetHighInt: Integer;
begin
  result := Values.DistrHigh(fValue);
end;

method DexiDistribution.SetAsIntInterval(aIntInt: IntInterval);
begin
  Value := Values.Distr(aIntInt);
end;

method DexiDistribution.SetAsFltInterval(aFltInt: FltInterval);
begin
  Value := Values.Distr(Values.IntInt(aFltInt));
end;

method DexiDistribution.GetAsIntSet: IntArray;
begin
  result := Values.IntSet(fValue);
end;

method DexiDistribution.SetAsIntSet(aSet: IntArray);
begin
  Value := Values.Distr(aSet);
end;

method DexiDistribution.GetAsDistribution: Distribution;
begin
  result := Values.Distr(fValue);
end;

method DexiDistribution.SetAsDistribution(aDistr: Distribution);
begin
  Value := Values.Distr(aDistr);
end;

method DexiDistribution.GetIsEmpty: Boolean;
begin
  result := Values.DistrEmpty(fValue);
end;

method DexiDistribution.GetBase: Integer;
begin
  result := fValue.Base;
end;

method DexiDistribution.SetBase(aBase: Integer);
begin
  fValue.Base := aBase;
end;

method DexiDistribution.GetDistr: FltArray;
begin
  result := Utils.CopyFltArray(fValue.Distr);
end;


method DexiDistribution.GetLowIndex: Integer;
begin
  result := Values.DistrLowIndex(fValue);
end;

method DexiDistribution.GetHighIndex: Integer;
begin
  result := Values.DistrHighIndex(fValue);
end;

method DexiDistribution.GetElement(aIdx: Integer): Float;
begin
  result := Values.GetDistribution(fValue, aIdx);
end;

method DexiDistribution.SetElement(aIdx: Integer; aFlt: Float);
begin
  Values.SetDistribution(var fValue, aIdx, aFlt, true);
end;

method DexiDistribution.GetMin: Float;
begin
  result := Values.DistrMin(fValue);
end;

method DexiDistribution.GetMax: Float;
begin
  result := Values.DistrMax(fValue);
end;

method DexiDistribution.GetSum: Float;
begin
  result := Values.DistrSum(fValue);
end;

method DexiDistribution.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := Values.DistrToStr(fValue, aInvariant, aDecimals);
end;

method DexiDistribution.FromString(aStr: String; aInvariant: Boolean := true);
begin
  Value := Values.StrToDistr(aStr, aInvariant);
end;

method DexiDistribution.Normalize(aNorm: Normalization := Normalization.normNone);
begin
  Values.NormDistr(var fValue, aNorm);
end;

method DexiDistribution.SetBounds(aLow, aHigh: Integer);
begin
  Value := Values.IntoBounds(fValue, aLow, aHigh);
end;

method DexiDistribution.ExtendBounds(aLow, aHigh: Integer);
begin
  Values.DistrExpand(var fValue, aLow);
  Values.DistrExpand(var fValue, aHigh);
end;

method DexiDistribution.Multiply(aMul: Float);
begin
  Values.DistrMul(var fValue, aMul);
end;

method DexiDistribution.Divide(aDiv: Float);
begin
  Values.DistrDiv(var fValue, aDiv);
end;

method DexiDistribution.Member(aInt: Integer): Boolean;
begin
  result := Element[aInt] > 0.0;
end;

method DexiDistribution.Insert(aIdx: Integer);
begin
  Value := Values.DistrInsertValue(fValue, aIdx);
end;

method DexiDistribution.Delete(aIdx: Integer);
begin
  Value := Values.DistrDeleteValue(fValue, aIdx);
end;

method DexiDistribution.Duplicate(aIdx: Integer);
begin
  Value := Values.DistrDuplicateValue(fValue, aIdx);
end;

method DexiDistribution.Merge(aFrom, aTo: Integer);
begin
  Value := Values.DistrMergeValue(fValue, aFrom, aTo);
end;

method DexiDistribution.Merge(aFrom, aTo: Integer; aNorm: Normalization);
begin
  Value := Values.DistrMergeValue(fValue, aFrom, aTo, aNorm);
end;

method DexiDistribution.Move(aFrom, aTo: Integer);
begin
  Value := Values.DistrMoveValue(fValue, aFrom, aTo);
end;

method DexiDistribution.&Reverse(aLow, aHigh: Integer);
begin
  Value := Values.DistrReverse(fValue, aLow, aHigh);
end;

method DexiDistribution.EqualTo(aValue: DexiValue): Boolean;
begin
  result :=
    if aValue = nil then false
    else Values.DistrEq(fValue, aValue.AsDistribution);
end;

method DexiDistribution.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result :=
    if aValue = nil then PrefCompare.No
    else Values.CompareDistr(fValue, aValue.AsDistribution);
end;

method DexiDistribution.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and (aValue.IsInteger or aValue.HasIntInterval);
end;

method DexiDistribution.AssignValue(aValue: DexiValue);
begin
  if assigned(aValue) then
    Value := aValue.AsDistribution
  else
    Clear;
end;

method DexiDistribution.IntoBounds(aLow, aHigh: Integer);
begin
  Value := Values.IntoBounds(fValue, aLow, aHigh);
end;

{$ENDREGION}

{$REGION DexiFltValue}

method DexiFltValue.GetHasIntSingle: Boolean;
begin
  result := HasFltSingle and (AsFloat = Values.IntSingle(AsFloat));
end;

method DexiFltValue.GetHasIntInterval: Boolean;
begin
  result := HasIntSingle;
end;

method DexiFltValue.GetHasIntSet: Boolean;
begin
  result := HasIntSingle;
end;

method DexiFltValue.GetAsInteger: Integer;
begin
  result := Values.IntSingle(AsFloat);
end;

method DexiFltValue.SetAsInteger(aInt: Integer);
begin
  AsFloat := aInt;
end;

method DexiFltValue.GetLowInt: Integer;
begin
  result := Values.IntSingle(LowFloat);
end;

method DexiFltValue.GetHighInt: Integer;
begin
  result := Values.IntSingle(HighFloat);
end;

method DexiFltValue.GetAsIntSet: IntArray;
begin
  result := Values.IntSet(LowInt, HighInt);
end;

method DexiFltValue.SetAsIntSet(aIntSet: IntArray);
begin
  AsIntInterval := Values.IntInt(aIntSet);
end;

method DexiFltValue.GetAsDistribution: Distribution;
begin
  result := Values.Distr(AsIntInterval);
end;

method DexiFltValue.SetAsDistribution(aDistr: Distribution);
begin
  AsIntInterval := Values.IntInt(aDistr);
end;

method DexiFltValue.Member(aInt: Integer): Boolean;
begin
  result := Member(Float(aInt));
end;

method DexiFltValue.IntoBounds(aLow, aHigh: Integer);
begin
  IntoBounds(Float(aLow), Float(aHigh));
end;

{$ENDREGION}

{$REGION DexiFltSingle}

constructor DexiFltSingle(aValue: Float := 0.0);
begin
  Value := aValue;
end;

method DexiFltSingle.Clear;
begin
  fValue := 0.0;
end;

method DexiFltSingle.GetValue: Float;
begin
  result := fValue;
end;

method DexiFltSingle.SetValue(aValue: Float);
begin
  fValue := aValue;
end;

method DexiFltSingle.GetValueType: DexiValueType;
begin
  result := DexiValueType.FltSingle;
end;

method DexiFltSingle.GetHasFltSingle: Boolean;
begin
  result := true;
end;

method DexiFltSingle.GetAsFloat: Float;
begin
  result := fValue;
end;

method DexiFltSingle.SetAsFloat(aFloat: Float);
begin
  Value := aFloat;
end;

method DexiFltSingle.GetLowFloat: Float;
begin
  result := fValue;
end;

method DexiFltSingle.GetHighFloat: Float;
begin
  result := fValue;
end;

method DexiFltSingle.GetAsIntInterval: IntInterval;
begin
  result := Values.IntInt(AsInteger);
end;

method DexiFltSingle.SetAsIntInterval(aIntInt: IntInterval);
begin
  Value := Values.FltSingle(Values.FltInt(aIntInt));
end;

method DexiFltSingle.SetAsDistribution(aDistr: Distribution);
begin
  Value := Values.DistrMedium(aDistr);
end;

method DexiFltSingle.GetAsFltInterval: FltInterval;
begin
  result := Values.FltInt(fValue);
end;

method DexiFltSingle.SetAsFltInterval(aFltInt: FltInterval);
begin
  Value := Values.FltSingle(aFltInt);
end;

method DexiFltSingle.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := Utils.FltToStr(fValue, aDecimals, aInvariant);
end;

method DexiFltSingle.FromString(aStr: String; aInvariant: Boolean := true);
begin
  Value := Utils.StrToFlt(aStr, aInvariant);
end;

method DexiFltSingle.EqualTo(aValue: DexiValue): Boolean;
begin
  result :=
    if aValue = nil then false
    else Utils.FloatEq(fValue, aValue.AsFloat);
end;

method DexiFltSingle.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result :=
    if aValue = nil then PrefCompare.No
    else Values.IntToPrefCompare(Utils.Compare(fValue, aValue.AsFloat));
end;

method DexiFltSingle.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and aValue.HasFltSingle;
end;

method DexiFltSingle.AssignValue(aValue: DexiValue);
begin
  if assigned(aValue) then
    Value := aValue.AsFloat
  else
    Clear;
end;

method DexiFltSingle.IntoBounds(aLow, aHigh: Float);
begin
   Value := Values.IntoBounds(fValue, aLow, aHigh);
end;

{$ENDREGION}

{$REGION DexiFltInterval}

constructor DexiFltInterval;
begin
  constructor(0, 0);
end;

constructor DexiFltInterval(aLow, aHigh: Float);
begin
  fValue.Low := aLow;
  fValue.High:= aHigh;
end;

constructor DexiFltInterval(aLowHigh: Float);
begin
  constructor(aLowHigh, aLowHigh);
end;

method DexiFltInterval.Clear;
begin
  Value := Values.FltInt(0.0);
end;

method DexiFltInterval.GetValue: FltInterval;
begin
  result := fValue;
end;

method DexiFltInterval.SetValue(aValue: FltInterval);
begin
  fValue := aValue;
end;

method DexiFltInterval.GetValueType: DexiValueType;
begin
  result := DexiValueType.FltInterval;
end;

method DexiFltInterval.GetHasFltSingle: Boolean;
begin
  result := Values.FltIntEq(fValue, Values.FltInt(Values.FltSingle(fValue)));
end;

method DexiFltInterval.GetValueSize: Integer;
begin
  result := -1;
end;

method DexiFltInterval.GetAsFloat: Float;
begin
  result := Values.FltSingle(fValue);
end;

method DexiFltInterval.SetAsFloat(aFloat: Float);
begin
  Value := Values.FltInt(aFloat);
end;

method DexiFltInterval.GetLowFloat: Float;
begin
  result := fValue.Low;
end;

method DexiFltInterval.GetHighFloat: Float;
begin
  result := fValue.High;
end;

method DexiFltInterval.GetAsIntInterval: IntInterval;
begin
  result := Values.IntInt(fValue);
end;

method DexiFltInterval.SetAsIntInterval(aIntInt: IntInterval);
begin
  Value := Values.FltInt(aIntInt);
end;

method DexiFltInterval.GetAsFltInterval: FltInterval;
begin
  result := fValue;
end;

method DexiFltInterval.SetAsFltInterval(aFltInt: FltInterval);
begin
  Value := aFltInt;
end;

method DexiFltInterval.ToString(aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := Values.FltIntToStr(fValue, aInvariant, aDecimals);
end;

method DexiFltInterval.FromString(aStr: String; aInvariant: Boolean := true);
begin
  Value := Values.StrToFltInt(aStr, aInvariant);
end;

method DexiFltInterval.Normalize(aNorm: Normalization := Normalization.normNone);
begin
  Values.NormFltInt(var fValue);
end;

method DexiFltInterval.EqualTo(aValue: DexiValue): Boolean;
begin
  result :=
    if aValue = nil then false
    else Values.FltIntEq(fValue, aValue.AsFltInterval);
end;

method DexiFltInterval.CompareWith(aValue: DexiValue): PrefCompare;
begin
  result :=
    if aValue = nil then PrefCompare.No
    else Values.CompareFltInterval(fValue, aValue.AsFltInterval);
end;

method DexiFltInterval.CanAssignLosslessly(aValue: DexiValue): Boolean;
begin
  result := (aValue <> nil) and (aValue.IsFloat or aValue.HasIntInterval);
end;

method DexiFltInterval.AssignValue(aValue: DexiValue);
begin
  if assigned(aValue) then
    Value := aValue.AsFltInterval
  else
    Clear;
end;

method DexiFltInterval.IntoBounds(aLow, aHigh: Float);
begin
  Value := Values.IntoBounds(fValue, aLow, aHigh);
end;

{$ENDREGION}

end.