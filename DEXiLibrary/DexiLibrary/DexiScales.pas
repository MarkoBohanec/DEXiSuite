// DexiScales.pas is part of
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
// DexiScale.pas implements the DexiScale class and its descendants. A DexiScale defines the
// type of values that can be assigned to a given DexiAttribute and defines other properies,
// such as Order of the scale (DexiOrder: None, Ascending, Descending), measuring ScaleUnit and
// the value intervals or sets that are considered particularly "bad" or "good" in this scale.
//
// DexiScale is the base abstract class, implementing all the common properties and methods.
// There are two descendant classes:
// - DexiContinuousScale: allowing assigning Float values to corresponding attributes.
//   Restricted to basic attributes without siblings.
// - DexiDiscreteScale: a typical DEXi qualitative scale. It defines a discrete and finite
//   set of values, called "categories" (represented as nameable DexiObjects). It allows
//   assigning any DexiValue (see DexiValues.pas) to the corresponding attribute.
//
// Additionally, DexiScales.pas implements classes:
// - DexiScaleStrings: to make CompositeStrings that represent a given DexiScale or
//   a given DexiValue interpreted on a given DexiScale.
// - DexiValueTokenizer: to decompose given value strings in DexiValueTokens.
// - DexiValueParser: to parse given value strings and create corresponding DexiValue objects.
// ----------

namespace DexiLibrary;

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiScaleType = public enum (Discrete, Continuous);
  DexiOrder = public enum (None, Ascending, Descending);
  DexiCategoryType = public enum (Bad, Neutral, Good);
  ActualScaleOrder = public enum (None, Constant, Ascending, Descending);
  ValueStringType = public enum (Zero, One, Text);
  ValueCategoryType = public enum (None, Bad, Neutral, Good, Mixed);

type
  DexiScaleList = public class (DexiList<DexiScale>);
  DexiScale = public abstract class (DexiObject)
  private
    fOrder: DexiOrder;
    fScaleUnit: String;
    fInterval: Boolean;
    fBGLow: Float;
    fBGHigh: Float;
    fFltDecimals: Integer;
    class const DistributableLimit = 100;
    class const BGDiff = 5 * Utils.FloatEpsilon;
  protected
    method GetIsOrdered: Boolean;
    method GetIsContinuous: Boolean;
    method GetIsDistributable: Boolean;
    method GetIsDescending: Boolean;
    method GetCount: Integer; virtual; abstract;
    method GetLow: Integer; virtual; abstract;
    method GetHigh: Integer; virtual; abstract;
    method GetLowFloat: Float; virtual; abstract;
    method GetHighFloat: Float; virtual; abstract;
    method GetHasBad: Boolean;
    method GetHasGood: Boolean;
    method GetBad: Float; virtual;
    method SetBad(aBad: Float); virtual;
    method GetGood: Float; virtual;
    method SetGood(aGood: Float); virtual;
    method GetScaleString: String; virtual;
    method GetScaleText: String; virtual;
  public
    class const BadInfo = -2;
    class const BadCategory = -1;
    class const NeutralCategory = 0;
    class const GoodCategory = 1;
    class const GoodInfo = 2;
    class method NewDiscreteScale: DexiDiscreteScale;
    class method NewContinuousScale: DexiContinuousScale;
    class method ScaleIsContinuous(aScale: DexiScale): Boolean;
    class method ScaleIsDiscrete(aScale: DexiScale): Boolean;
    class method AssignmentCompatibleScales(aTo, aFrom: DexiScale): Boolean;
    class method ValueInScaleBounds(aValue: DexiValue; aScale: DexiScale): Boolean;
    class method ValueIntoScaleBounds(aValue: DexiValue; aScale: DexiScale): DexiValue;
    class method CompareValues(aValue1, aValue2: DexiValue; aScale: DexiScale; aMethod: DexiValueMethod): PrefCompare;
    constructor;
    method CompatibleWith(aScl: DexiScale): Boolean; virtual;
    method EqualTo(aScl: DexiScale): Boolean; virtual;
    method InBounds(aFlt: Float): Boolean;
    method InBounds(aInt: Integer): Boolean;
    method IntoBounds(aFlt: Float): Float;
    method IntoBounds(aInt: Integer): Integer;
    method Compare(aInt1, aInt2: Integer): PrefCompare;
    method Compare(aFlt1, aFlt2: Float): PrefCompare;
    method IsBetter(aFlt1, aFlt2: Float): Boolean;
    method IsBetter(aInt1, aInt2: Integer): Boolean;
    method IsBetterEq(aFlt1, aFlt2: Float): Boolean;
    method IsBetterEq(aInt1, aInt2: Integer): Boolean;
    method IsWorse(aFlt1, aFlt2: Float): Boolean;
    method IsWorse(aInt1, aInt2: Integer): Boolean;
    method IsWorseEq(aFlt1, aFlt2: Float): Boolean;
    method IsWorseEq(aInt1, aInt2: Integer): Boolean;
    method IsBad(aFlt: Float): Boolean;
    method IsGood(aFlt: Float): Boolean;
    method IsBad(aValue: DexiValue): Boolean;
    method IsNeutral(aValue: DexiValue): Boolean;
    method IsGood(aValue: DexiValue): Boolean;
    method ValueCategory(aValue: DexiValue): ValueCategoryType;
    method Category(aFlt: Float): Integer;
    method SetCategory(aIdx: Integer; aCategory: DexiCategoryType);
    method SetCategory(aIdx: Integer; aCtg: Integer);
    method IndicateCategory(aIdx: Integer; aCategory: DexiCategoryType);
    method IndicateCategory(aIdx: Integer; aCtg: Integer);
    method IndexOfValue(aName: String): Integer; virtual;
    method AssignScale(aScl: DexiScale); virtual;
    method CopyScale: InstanceType; virtual; abstract;
    method &Reverse; virtual;
    property &Order: DexiOrder read fOrder write fOrder;
    property IsInterval: Boolean read fInterval write fInterval;
    property IsOrdered: Boolean read GetIsOrdered;
    property IsDescending: Boolean read GetIsDescending;
    property IsContinuous: Boolean read GetIsContinuous;
    property IsDiscrete: Boolean read not IsContinuous;
    property IsDistributable: Boolean read GetIsDistributable;
    property ScaleUnit: String read fScaleUnit write fScaleUnit;
    property Count: Integer read GetCount;
    property LowInt: Integer read GetLow;
    property HighInt: Integer read GetHigh;
    property LowFloat: Float read GetLowFloat;
    property HighFloat: Float read GetHighFloat;
    property BGLow: Float read fBGLow write fBGLow;
    property BGHigh: Float read fBGHigh write fBGHigh;
    property FltDecimals: Integer read fFltDecimals write fFltDecimals;
    property HasBad: Boolean read GetHasBad;
    property HasGood: Boolean read GetHasGood;
    property Bad: Float read GetBad write SetBad;
    property Good: Float read GetGood write SetGood;
    property ScaleString: String read GetScaleString;
    property ScaleText: String read GetScaleText;

    // IUndoable
    method EqualStateAs(aObj: IUndoable): Boolean; override;
    method GetUndoState: IUndoable; override;
    method SetUndoState(aState: IUndoable); override;
  end;

type
  DexiContinuousScale = public class (DexiScale)
  protected
    method GetCount: Integer; override;
    method GetScaleString: String; override;
    method GetScaleText: String; override;
    method GetLow: Integer; override;
    method GetHigh: Integer; override;
    method GetLowFloat: Float; override;
    method GetHighFloat: Float; override;
  public
    constructor;
    method CopyScale: InstanceType; override;
  end;

type
  DexiScaleValue = public class (DexiObject)
  private
    fColor: ColorInfo;
  public
    property Color: ColorInfo read fColor write fColor;
  end;

  DexiScaleValueList = public class (DexiList<DexiScaleValue>);

  DexiDiscreteScale = public class (DexiScale)
  protected
    fValues: DexiScaleValueList;
  protected
    method NewValue(aName: String := ''; aDescription: String := ''): DexiScaleValue;
    method GetCount: Integer; override;
    method GetLow: Integer; override;
    method GetHigh: Integer; override;
    method GetLowFloat: Float; override;
    method GetHighFloat: Float; override;
    method GetValues(aIdx: Integer): DexiScaleValue;
    method GetNames(aIdx: Integer): String;
    method GetDescriptions(aIdx: Integer): String;
    method GetColors(aIdx: Integer): ColorInfo;
    method GetScaleString: String; override;
    method GetScaleText: String; override;
    method ExtendCategory(aIdx: Integer);
    method ReduceCategory(aIdx: Integer);
    method GoodBad: array of Char;
  assembly
    property Values[aIdx: Integer]: DexiScaleValue read GetValues;
    method AddValue(aValue: DexiScaleValue);
    property ValueList: DexiScaleValueList read fValues;
    method ValueIndex(aValue: DexiScaleValue): Integer;
  public
    class const ValuesLimit = 35;
    constructor;
    constructor (aValues: sequence of String);
    method EqualTo(aScl: DexiScale): Boolean; override;
    method IndexOfValue(aName: String): Integer; override;
    method AssignScale(aScl: DexiScale); override;
    method CopyScale: InstanceType; override;
    method &Reverse; override;
    method DefaultCategory;
    method SetNames(aIdx: Integer; aName: String);
    method SetDescriptions(aIdx: Integer; aDescription: String);
    method SetColors(aIdx: Integer; aColor: ColorInfo);
    method NameIndex(aName: String): Integer;
    method AddValue(aName: String := ''; aDescription: String := '');
    method InsertValue(aIdx: Integer; aName: String := ''; aDescription: String := '');
    method DeleteValue(aIdx: Integer);
    method GetNameStrings(aStrings: DexiStrings<DexiScaleValue>; aAppend: Boolean := false);
    method GetDescriptionStrings(aStrings: DexiStrings<DexiScaleValue>; aAppend: Boolean := false);
    method MovePrev(aIdx: Integer);
    method MoveNext(aIdx: Integer);
    method CountBads: Integer;
    method CountGoods: Integer;
    method NameList: List<String>;
    method FullValue: DexiValue;
    property Names[aIdx: Integer]: String read GetNames write SetNames; default;
    property Descriptions[aIdx: Integer]: String read GetDescriptions write SetDescriptions;
    property Colors[aIdx: Integer]: ColorInfo read GetColors write SetColors;
  end;

{ DexiScaleStrings }

type
  DexiScaleStrings = public class
  private
    fScale: DexiScale;
    fString: CompositeString;
    fInvariant: Boolean;
    fSimple: Boolean;
    fValueType: ValueStringType;
    fMemDecimals: Integer;
    fStringCreate: CompositeStringFactory;
  protected
    method NewString: CompositeString; virtual;
    method MakeString: CompositeString;
    method AddStr(aStr: String); virtual;
    method AddStr(aStr: String; aTag: Integer); virtual;
    method AddInt(aInt: Integer); virtual;
    method AddFlt(aFlt: Float); virtual;
  public
    constructor (
      aInvariant: Boolean := true;
      aValueType: ValueStringType := ValueStringType.Text;
      aMemDecimals: Integer := -1);
    method ResetDecimals;
    method ValueOnScaleComposite(aValue: Integer; aScale: DexiScale): CompositeString;
    method ValueOnScaleComposite(aValue: Float; aScale: DexiScale): CompositeString;
    method ValueOnScaleComposite(aValue: DexiValue; aScale: DexiScale): CompositeString;
    method ValueOnScaleString(aValue: DexiValue; aScale: DexiScale): String;
    method ValueOnScaleComposite(aOffsets: IntOffsets; aScale: DexiScale): CompositeString;
    method ValueOnScaleString(aOffsets: IntOffsets; aScale: DexiScale): String;
    method ScaleComposite(aScale: DexiScale; aWithName: Boolean := false): CompositeString;
    method ScaleString(aScale: DexiScale): String;
    method ParseScaleValue(aStr: String; aScale: DexiScale): DexiValue;
    method TryParseScaleValue(aStr: String; aScale: DexiScale): DexiValueParser;
    property StringCreate: CompositeStringFactory read fStringCreate write fStringCreate;
    property Invariant: Boolean read fInvariant write fInvariant;
    property Simple: Boolean read fSimple write fSimple;
    property ValueType: ValueStringType read fValueType write fValueType;
    property MemDecimals: Integer read fMemDecimals write fMemDecimals;
    property AsCompositeString: CompositeString read fString;
    property AsString: String read fString.AsString;
  end;

{ DexiValueParser }

type
  DexiValueToken = public class
  private
  public
    constructor (aStr: String);
    property Str: String;
    property IsQuoted := false;
    property IsDelimiter := false;
  end;

type
  DexiValueTokenizer = public class
  private
    class const Delimiters: array of Char = [';', ':', '/'];
    class const Quotes: array of Char = ['''', '"'];
  protected
    method Unquote(aStr: String): String;
    method GetDelimiters(aStr: String): List<Integer>;
  public
    constructor; empty;
    method Clear;
    method Tokenize(aStr: String);
    property Tokens := new List<DexiValueToken>;
    property Count: Integer read Tokens.Count;
    property IntervalOperators := false;
    property IntervalDelimiters := 0;
    property MemberDelimiters := 0;
    property ListDelimiters := 0;
  end;

type
  DexiValueParser = public class
  private
    fParseStr: String;
    fValueType: ValueStringType;
    fInvariant: Boolean;
    fScale: DexiScale;
    fValue: DexiValue;
    fError: String;
  protected
    property Tokenizer := new DexiValueTokenizer;
    method Clear;
    method ParseError(aErrorMsg: String);
    method ParseError;
    method ValidateTokens;
    method ParseAsInt(aToken: DexiValueToken): Integer;
    method ParseAsFlt(aToken: DexiValueToken): Float;
    method ParseAsSet: DexiValue;
    method ParseAsDistribution: DexiValue;
    method ParseIntValues(aStr: String): DexiValue;
  public
    constructor (aScale: DexiScale; aValueType: ValueStringType := ValueStringType.Text; aInvariant: Boolean := true);
    method Parse(aStr: String): Boolean;
    property ParseStr: String read fParseStr;
    property ValueType: ValueStringType read fValueType write fValueType;
    property Invariant: Boolean read fInvariant write fInvariant;
    property Scale: DexiScale read fScale write fScale;
    property Value: DexiValue read fValue;
    property Error: String read fError;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiScale}

class method DexiScale.NewDiscreteScale: DexiDiscreteScale;
begin
  result := new DexiDiscreteScale([DexiString.SDexiScaleValue1, DexiString.SDexiScaleValue2]);
end;

class method  DexiScale.NewContinuousScale: DexiContinuousScale;
begin
  result := new DexiContinuousScale;
end;

class method DexiScale.ScaleIsContinuous(aScale: DexiScale): Boolean;
begin
  result := (aScale <> nil) and aScale.IsContinuous;
end;

class method DexiScale.ScaleIsDiscrete(aScale: DexiScale): Boolean;
begin
  result := (aScale <> nil) and aScale.IsDiscrete;
end;

class method DexiScale.AssignmentCompatibleScales(aTo, aFrom: DexiScale): Boolean;
begin
  result := (aTo = nil) or aTo.CompatibleWith(aFrom);
end;

class method DexiScale.ValueInScaleBounds(aValue: DexiValue; aScale: DexiScale): Boolean;
begin
  result :=
    if aScale = nil then true
    else if aValue = nil then false
    else if aValue.IsEmpty then true
    else if aScale.IsContinuous then aValue.InBounds(aScale.LowFloat, aScale.HighFloat)
    else aValue.InBounds(aScale.LowInt, aScale.HighInt);
end;

class method DexiScale.ValueIntoScaleBounds(aValue: DexiValue; aScale: DexiScale): DexiValue;
begin
  result := aValue;
  if (aValue = nil) or (aScale = nil) or ValueInScaleBounds(aValue, aScale) then
    exit;
  result := DexiValue.CopyValue(aValue);
  if aScale.IsContinuous then
    result.IntoBounds(aScale.LowFloat, aScale.HighFloat)
  else
    result.IntoBounds(aScale.LowInt, aScale.HighInt);
end;

class method DexiScale.CompareValues(aValue1, aValue2: DexiValue; aScale: DexiScale; aMethod: DexiValueMethod): PrefCompare;
begin
  result := PrefCompare.No;
  if (aScale <> nil) and aScale.IsOrdered then
    begin
      result := DexiValue.CompareValues(aValue1, aValue2, aMethod);
      if aScale.IsDescending then
        result := Values.ReversePrefCompare(result);
    end;
end;

constructor DexiScale;
begin
  inherited constructor;
  fOrder := DexiOrder.Ascending;
  fScaleUnit := '';
  fBGLow := Consts.NegativeInfinity;
  fBGHigh := Consts.PositiveInfinity;
  fInterval := true;
  fFltDecimals := -1;
end;

method DexiScale.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiScale then
    exit false;
  if aObj = self then
    exit true;
  var lScl := DexiScale(aObj);
  if not inherited EqualStateAs(lScl) then
    exit false;
  result := EqualTo(lScl);
end;

method DexiScale.GetUndoState: IUndoable;
begin
  var lScl := CopyScale;
  result := lScl;
end;

method DexiScale.SetUndoState(aState: IUndoable);
begin
  inherited SetUndoState(aState);
  var lScl := aState as DexiScale;
  AssignScale(lScl);
end;

method DexiScale.CompatibleWith(aScl: DexiScale): Boolean;
begin
  result :=
    (aScl <> nil) and (&Order = aScl.Order) and (Count = aScl.Count) and
    (LowFloat = aScl.LowFloat) and (HighFloat = aScl.HighFloat);
end;

method DexiScale.EqualTo(aScl: DexiScale): Boolean;
begin
  result :=
    (Name = aScl.Name) and
    (Description = aScl.Description) and
    CompatibleWith(aScl) and
    (ScaleUnit = aScl.ScaleUnit) and
    Utils.FloatEq(BGLow, aScl.BGLow) and Utils.FloatEq(BGHigh, aScl.BGHigh);
end;

method DexiScale.GetIsOrdered: Boolean;
begin
  result := fOrder <> DexiOrder.None;
end;

method DexiScale.GetIsContinuous: Boolean;
begin
  result := Count < 0;
end;

method DexiScale.GetIsDistributable: Boolean;
begin
  result := IsDiscrete and (LowInt = 0) and (0 <= Count <= DistributableLimit);
end;

method DexiScale.GetIsDescending: Boolean;
begin
  result := fOrder = DexiOrder.Descending;
end;

method DexiScale.GetHasBad: Boolean;
begin
  result := BGLow > LowFloat;
end;

method DexiScale.GetHasGood: Boolean;
begin
  result := BGHigh < HighFloat;
end;

method DexiScale.GetBad: Float;
begin
  result :=
    case &Order of
      DexiOrder.Ascending:  BGLow;
      DexiOrder.Descending: BGHigh;
      else Consts.NegativeInfinity;
    end;
end;

method DexiScale.SetBad(aBad: Float);
begin
  if IsOrdered then
    if IsDescending then
      begin
        fBGHigh := aBad;
        if BGLow > BGHigh then
          fBGLow := aBad;
        if Utils.FloatEq(BGLow, BGHigh) then
          fBGLow := fBGLow - BGDiff;
      end
    else
      begin
        fBGLow := aBad;
        if fBGLow > fBGHigh then
          fBGHigh := aBad;
        if Utils.FloatEq(BGLow, BGHigh) then
          fBGHigh := fBGHigh + BGDiff;
      end;
end;

method DexiScale.GetGood: Float;
begin
  result :=
    case &Order of
      DexiOrder.Ascending:  BGHigh;
      DexiOrder.Descending: BGLow;
      else Consts.PositiveInfinity;
    end;
end;

method DexiScale.SetGood(aGood: Float);
begin
  if IsOrdered then
    if IsDescending then
      begin
        fBGLow := aGood;
        if fBGLow > fBGHigh then
          fBGHigh := aGood;
        if Utils.FloatEq(BGLow, BGHigh) then
          fBGHigh := fBGHigh + BGDiff;
      end
    else
      begin
        fBGHigh := aGood;
        if fBGLow > fBGHigh then
          fBGLow := aGood;
        if Utils.FloatEq(BGLow, BGHigh) then
          fBGLow := fBGLow - BGDiff;
      end;
end;

method DexiScale.GetScaleString: String;
begin
  result := Name;
  if &Order = DexiOrder.Ascending then
    result := result + '+'
  else if &Order = DexiOrder.Descending then
    result := result + '-';
  if not String.IsNullOrEmpty(ScaleUnit) then
    result := result + '[' + ScaleUnit + ']';
end;

method DexiScale.GetScaleText: String;
begin
  result := '';
end;

method DexiScale.InBounds(aFlt: Float): Boolean;
begin
  result := LowFloat <= aFlt <= HighFloat;
end;

method DexiScale.InBounds(aInt: Integer): Boolean;
begin
  result := LowInt <= aInt <= HighInt;
end;

method DexiScale.IntoBounds(aFlt: Float): Float;
begin
  result :=
    if aFlt < LowFloat then LowFloat
    else if aFlt > HighFloat then HighFloat
    else aFlt;
end;

method DexiScale.IntoBounds(aInt: Integer): Integer;
begin
  result :=
    if aInt < LowInt then LowInt
    else if aInt > HighInt then HighInt
    else aInt;
end;

method DexiScale.Compare(aInt1, aInt2: Integer): PrefCompare;
begin
  if not IsOrdered then
    exit PrefCompare.No;
  var lCompare := Utils.Compare(aInt1, aInt2);
  if IsDescending then
    lCompare := -lCompare;
  result := Values.IntToPrefCompare(lCompare);
end;

method DexiScale.Compare(aFlt1, aFlt2: Float): PrefCompare;
begin
  if not IsOrdered then
    exit PrefCompare.No;
  var lCompare := Utils.Compare(aFlt1, aFlt2);
  if IsDescending then
    lCompare := -lCompare;
  result := Values.IntToPrefCompare(lCompare);
end;

method DexiScale.IsBetter(aFlt1, aFlt2: Float): Boolean;
begin
  result :=
    case &Order of
      DexiOrder.Ascending:  aFlt1 > aFlt2;
      DexiOrder.Descending: aFlt1 < aFlt2;
      else false;
    end;
end;

method DexiScale.IsBetter(aInt1, aInt2: Integer): Boolean;
begin
  result :=
    case &Order of
      DexiOrder.Ascending:  aInt1 > aInt2;
      DexiOrder.Descending: aInt1 < aInt2;
      else false;
    end;
end;

method DexiScale.IsBetterEq(aFlt1, aFlt2: Float): Boolean;
begin
  result :=
    if &Order = DexiOrder.None then false
    else Utils.FloatEq(aFlt1, aFlt2) or IsBetter(aFlt1, aFlt2);
end;

method DexiScale.IsBetterEq(aInt1, aInt2: Integer): Boolean;
begin
  result :=
    if &Order = DexiOrder.None then false
    else (aInt1 = aInt2) or IsBetter(aInt1, aInt2);
end;

method DexiScale.IsWorse(aFlt1, aFlt2: Float): Boolean;
begin
  result :=
    case &Order of
      DexiOrder.Ascending:  aFlt1 < aFlt2;
      DexiOrder.Descending: aFlt1 > aFlt2;
      else false;
    end;
end;

method DexiScale.IsWorse(aInt1, aInt2: Integer): Boolean;
begin
  result :=
    case &Order of
      DexiOrder.Ascending:  aInt1 < aInt2;
      DexiOrder.Descending: aInt1 > aInt2;
      else false;
    end;
end;

method DexiScale.IsWorseEq(aFlt1, aFlt2: Float): Boolean;
begin
  result :=
    if &Order = DexiOrder.None then false
    else Utils.FloatEq(aFlt1, aFlt2) or IsWorse(aFlt1, aFlt2);
end;

method DexiScale.IsWorseEq(aInt1, aInt2: Integer): Boolean;
begin
  result :=
    if &Order = DexiOrder.None then false
    else (aInt1 = aInt2) or IsWorse(aInt1, aInt2);
end;

method DexiScale.IsBad(aFlt: Float): Boolean;
begin
  result := IsWorseEq(aFlt, Bad);
end;

method DexiScale.IsGood(aFlt: Float): Boolean;
begin
  result := IsBetterEq(aFlt, Good);
end;

method DexiScale.IsBad(aValue: DexiValue): Boolean;
begin
  if not DexiValue.ValueIsDefined(aValue) then
    result := false
  else if aValue.IsInteger then
    begin
      result := false;
      var lSet := aValue.AsIntSet;
      for each lEl in lSet do
        if IsBad(lEl) then
          exit true;
    end
  else
    result := IsBad(aValue.LowFloat) or IsBad(aValue.HighFloat);
end;

method DexiScale.IsNeutral(aValue: DexiValue): Boolean;
begin
  if not DexiValue.ValueIsDefined(aValue) then
    result := false
  else if aValue.IsInteger then
    begin
      result := false;
      var lSet := aValue.AsIntSet;
      for each lEl in lSet do
        if not IsBad(lEl) and not IsGood(lEl) then
          exit true;
    end
  else
    result := not IsBad(aValue.LowFloat) and not IsGood(aValue.LowFloat) and not IsBad(aValue.HighFloat) and not IsGood(aValue.HighFloat);
end;

method DexiScale.IsGood(aValue: DexiValue): Boolean;
begin
  if not DexiValue.ValueIsDefined(aValue) then
    result := false
  else if aValue.IsInteger then
    begin
      result := false;
      var lSet := aValue.AsIntSet;
      for each lEl in lSet do
        if IsGood(lEl) then
          exit true;
    end
  else
    result := IsGood(aValue.LowFloat) or IsGood(aValue.HighFloat);
end;

method DexiScale.ValueCategory(aValue: DexiValue): ValueCategoryType;
begin
  var lBad := IsBad(aValue);
  var lNeutral := IsNeutral(aValue);
  var lGood := IsGood(aValue);
  var lCount := ord(lBad) + ord(lNeutral) + ord(lGood);
  result :=
    if lCount = 0 then ValueCategoryType.None
    else if lCount > 1 then ValueCategoryType.Mixed
    else if lBad then ValueCategoryType.Bad
    else if lGood then ValueCategoryType.Good
    else ValueCategoryType.Neutral;
end;

method DexiScale.Category(aFlt: Float): Integer;
begin
  result :=
    if IsGood(aFlt) then GoodCategory
    else if IsBad(aFlt) then BadCategory
    else NeutralCategory;
end;

method DexiScale.SetCategory(aIdx: Integer; aCategory: DexiCategoryType);
begin
  case aCategory of
    DexiCategoryType.Bad:
      Bad := aIdx;
    DexiCategoryType.Neutral:
      if &Order = DexiOrder.Ascending then
        begin
          Bad := Math.Min(Bad, aIdx - 1);
          Good := Math.Max(Good, aIdx + 1);
        end
      else if &Order = DexiOrder.Descending then
        begin
          Bad := Math.Max(Bad, aIdx + 1);
          Good := Math.Min(Good, aIdx - 1);
        end;
    DexiCategoryType.Good:
      Good := aIdx;
  end;
end;

method DexiScale.SetCategory(aIdx: Integer; aCtg: Integer);
begin
  case aCtg of
    DexiScale.BadCategory:     SetCategory(aIdx, DexiCategoryType.Bad);
    DexiScale.NeutralCategory: SetCategory(aIdx, DexiCategoryType.Neutral);
    DexiScale.GoodCategory:    SetCategory(aIdx, DexiCategoryType.Good);
  end;
end;

method DexiScale.IndicateCategory(aIdx: Integer; aCategory: DexiCategoryType);
begin
  case aCategory of
    DexiCategoryType.Bad:
      if &Order = DexiOrder.Ascending then
        begin
          Bad := Math.Max(Bad, aIdx);
          Good := Math.Max(Good, aIdx + 1);
        end
      else if &Order = DexiOrder.Descending then
        begin
          Bad := Math.Min(Bad, aIdx);
          Good := Math.Min(Good, aIdx - 1);
        end;
    DexiCategoryType.Neutral:
      if &Order = DexiOrder.Ascending then
        begin
          Bad := Math.Min(Bad, aIdx - 1);
          Good := Math.Max(Good, aIdx + 1);
        end
      else if &Order = DexiOrder.Descending then
        begin
          Bad := Math.Max(Bad, aIdx + 1);
          Good := Math.Min(Good, aIdx - 1);
        end;
    DexiCategoryType.Good:
      if &Order = DexiOrder.Ascending then
        begin
          Good := Math.Min(Good, aIdx);
          Bad := Math.Min(Bad, aIdx - 1);
        end
      else if &Order = DexiOrder.Descending then
        begin
          Good := Math.Max(Good, aIdx);
          Bad := Math.Max(Bad, aIdx + 1);
        end;
  end;
end;

method DexiScale.IndicateCategory(aIdx: Integer; aCtg: Integer);
begin
  case aCtg of
    DexiScale.BadCategory:     IndicateCategory(aIdx, DexiCategoryType.Bad);
    DexiScale.NeutralCategory: IndicateCategory(aIdx, DexiCategoryType.Neutral);
    DexiScale.GoodCategory:    IndicateCategory(aIdx, DexiCategoryType.Good);
  end;
end;

method DexiScale.IndexOfValue(aName: String): Integer;
begin
  result := -1;
end;

method DexiScale.AssignScale(aScl: DexiScale);
begin
  &Order := aScl.Order;
  Name := aScl.Name;
  Description := aScl.Description;
  ScaleUnit := aScl.ScaleUnit;
  fBGLow := aScl.BGLow;
  fBGHigh := aScl.BGHigh;
  fInterval := aScl.fInterval;
  fFltDecimals := aScl.FltDecimals;
end;

method DexiScale.Reverse;
begin
  if fOrder = DexiOrder.Ascending then
    fOrder := DexiOrder.Descending
  else if fOrder = DexiOrder.Descending then
    fOrder := DexiOrder.Ascending;
end;

{$ENDREGION}

{$REGION DexiContinuousScale}

constructor DexiContinuousScale;
begin
  inherited constructor;
  FltDecimals := 2;
end;

method DexiContinuousScale.CopyScale: InstanceType;
begin
  result := new DexiContinuousScale;
  result.AssignScale(self);
end;

method DexiContinuousScale.GetCount: Integer;
begin
  result := -1;
end;

method DexiContinuousScale.GetLow: Integer;
begin
  result := low(Integer);
end;

method DexiContinuousScale.GetHigh: Integer;
begin
  result := high(Integer);
end;

method DexiContinuousScale.GetLowFloat: Float;
begin
  result := Consts.NegativeInfinity;
end;

method DexiContinuousScale.GetHighFloat: Float;
begin
  result := Consts.PositiveInfinity;
end;

method DexiContinuousScale.GetScaleString: String;
begin
  result := inherited GetScaleString;
  var lBad :=
    if Consts.IsInfinity(Bad) then ''
    else Utils.FloatToStr(Bad);
  var lGood :=
    if Consts.IsInfinity(Good) then ''
    else Utils.FloatToStr(Good);
  if (lBad <> '') or (lGood <> '') then
    result := result + $"<{lBad}:{lGood}>";
end;

method DexiContinuousScale.GetScaleText: String;
begin
  var lBad :=
    if Consts.IsInfinity(Bad) then ''
    else Utils.FloatToStr(Bad);
  var lGood :=
    if Consts.IsInfinity(Good) then ''
    else Utils.FloatToStr(Good);
  result := $"<{lBad}:{lGood}>";
end;

{$ENDREGION}

{$REGION DexiDiscreteScale}

constructor DexiDiscreteScale;
begin
  inherited constructor;
  fValues := new DexiScaleValueList;
end;

constructor DexiDiscreteScale(aValues: sequence of String);
begin
  constructor;
  for each lValue in aValues do
    AddValue(lValue);
end;

method DexiDiscreteScale.NewValue(aName: String := ''; aDescription: String := ''): DexiScaleValue;
begin
  result := new DexiScaleValue(Name := aName, Description := aDescription);
end;

method DexiDiscreteScale.GetCount: Integer;
begin
  result := fValues.Count;
end;

method DexiDiscreteScale.GetLow: Integer;
begin
  result := 0;
end;

method DexiDiscreteScale.GetHigh: Integer;
begin
  result := Count - 1;
end;

method DexiDiscreteScale.GetLowFloat: Float;
begin
  result := LowInt - 0.5 + Utils.FloatEpsilon;
end;

method DexiDiscreteScale.GetHighFloat: Float;
begin
  result := HighInt + 0.5 - Utils.FloatEpsilon;
end;

method DexiDiscreteScale.GetValues(aIdx: Integer): DexiScaleValue;
begin
  result := fValues[aIdx];
end;

method DexiDiscreteScale.GetNames(aIdx: Integer): String;
begin
  result := fValues[aIdx].Name;
end;

method DexiDiscreteScale.GetDescriptions(aIdx: Integer): String;
begin
  result := fValues[aIdx].Description;
end;

method DexiDiscreteScale.GetColors(aIdx: Integer): ColorInfo;
begin
  result := fValues[aIdx].Color;
end;

method DexiDiscreteScale.GetScaleString: String;
begin
  result := inherited GetScaleString;
  if result <> '' then
    result := result + ' ';
  for i := 0 to Count - 1 do
    begin
      if i > 0 then
        result := result + DexiString.SListSeparator;
      result := result + Names[i];
      if IsBad(i) then
        result := result + '(-)'
      else if IsGood(i) then
        result := result + '(+)';
    end;
end;

method DexiDiscreteScale.GetScaleText: String;
begin
  result := '';
  for i := 0 to Count - 1 do
    begin
      if i > 0 then
        result := result + DexiString.SListSeparator;
      result := result + Names[i];
    end;
end;

method DexiDiscreteScale.DefaultCategory;
begin
  if IsOrdered and (Count > 1) then
    begin
      BGLow := LowInt + 0.5;
      BGHigh := HighInt - 0.5;
     end
  else
    begin
      BGLow := Consts.NegativeInfinity;
      BGHigh := Consts.PositiveInfinity;
    end;
end;

method DexiDiscreteScale.ExtendCategory(aIdx: Integer);
begin
  if not IsOrdered or (Count <= 2) then
    DefaultCategory
  else if Count = 3 then
    begin
      BGLow := LowInt;
      BGHigh := HighInt;
    end
  else
    begin
      if aIdx <= BGLow then
        BGLow := BGLow + 1.0;
      if (aIdx >= HighInt) or (aIdx <= BGHigh) then
        BGHigh := BGHigh + 1.0;
    end;
end;

method DexiDiscreteScale.ReduceCategory(aIdx: Integer);
begin
  if not IsOrdered or (Count <= 1) then
    DefaultCategory
  else
    begin
      if aIdx < BGLow then
        BGLow := BGLow - 1.0;
      if (aIdx > HighInt) or (aIdx < BGHigh) then
        BGHigh := BGHigh - 1.0;
    end;
end;

method DexiDiscreteScale.CountBads: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if IsBad(i) then
      inc(result);
end;

method DexiDiscreteScale.CountGoods: Integer;
begin
  result := 0;
  for i := 0 to Count - 1 do
    if IsGood(i) then
      inc(result);
end;

method DexiDiscreteScale.SetNames(aIdx: Integer; aName: String);
begin
  fValues[aIdx].Name := aName;
end;

method DexiDiscreteScale.SetDescriptions(aIdx: Integer; aDescription: String);
begin
  fValues[aIdx].Description := aDescription;
end;

method  DexiDiscreteScale.SetColors(aIdx: Integer; aColor: ColorInfo);
begin
  fValues[aIdx].Color := aColor;
end;

method  DexiDiscreteScale.NameList: List<String>;
begin
  result := new List<String>;
  for each lValue in fValues do
    result.Add(lValue.Name);
end;

method DexiDiscreteScale.FullValue: DexiValue;
begin
  result := new DexiIntInterval(0, Count - 1);
end;

method DexiDiscreteScale.ValueIndex(aValue: DexiScaleValue): Integer;
begin
  result := fValues.IndexOf(aValue);
end;

method DexiDiscreteScale.NameIndex(aName: String): Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if Names[i] = aName then
      exit i;
end;

method DexiDiscreteScale.AddValue(aValue: DexiScaleValue);
begin
  fValues.Add(aValue);
  ExtendCategory(Count - 1);
end;

method DexiDiscreteScale.AddValue(aName: String := ''; aDescription: String := '');
begin
  AddValue(NewValue(aName, aDescription));
end;

method DexiDiscreteScale.InsertValue(aIdx: Integer; aName: String := ''; aDescription: String := '');
begin
  if aIdx >= Count then
    AddValue(aName, aDescription)
  else
    begin
      fValues.Insert(aIdx, NewValue(aName, aDescription));
      ExtendCategory(aIdx);
    end;
end;

method DexiDiscreteScale.DeleteValue(aIdx: Integer);
begin
  fValues.RemoveAt(aIdx);
  ReduceCategory(aIdx);
end;

method DexiDiscreteScale.GetNameStrings(aStrings: DexiStrings<DexiScaleValue>; aAppend: Boolean := false);
begin
  fValues.GetNameStrings(aStrings, aAppend);
end;

method DexiDiscreteScale.GetDescriptionStrings(aStrings: DexiStrings<DexiScaleValue>; aAppend: Boolean := false);
begin
  fValues.GetDescriptionStrings(aStrings, aAppend);
end;

method DexiDiscreteScale.MovePrev(aIdx: Integer);
begin
  fValues.Move(aIdx, aIdx - 1);
end;

method DexiDiscreteScale.MoveNext(aIdx: Integer);
begin
  fValues.Move(aIdx, aIdx + 1);
end;

method DexiDiscreteScale.EqualTo(aScl: DexiScale): Boolean;
begin
  result := (aScl is DexiDiscreteScale) and inherited EqualTo(aScl);
  if not result then
    exit;
  var lScl := DexiDiscreteScale(aScl);
  for i := 0 to Count - 1 do
    if (Names[i] <> lScl.Names[i]) or (Descriptions[i] <> lScl.Descriptions[i]) then
      exit false;
end;

method DexiDiscreteScale.IndexOfValue(aName: String): Integer;
begin
  result := fValues.IndexOf(aName);
end;

method DexiDiscreteScale.AssignScale(aScl: DexiScale);
begin
  inherited AssignScale(aScl);
  fValues.RemoveAll;
  if not (aScl is DexiDiscreteScale) then
    exit;
  var lScl := DexiDiscreteScale(aScl);
  for i := 0 to lScl.Count - 1 do
    fValues.Add(NewValue(lScl.Names[i], lScl.Descriptions[i]));
end;

method DexiDiscreteScale.CopyScale: InstanceType;
begin
  result := new DexiDiscreteScale;
  result.AssignScale(self);
end;

method DexiDiscreteScale.GoodBad: array of Char;
begin
  result := new Char[Count];
  for i :=  low(result) to high(result) do
    result[i]  := 'V';
  for i := 0 to Count - 1 do
    if IsGood(i) then
      result[i] := 'G'
    else if IsBad(i) then
      result[i] := 'B';
end;

method DexiDiscreteScale.Reverse;
begin
  var lGoodBad := GoodBad;
  inherited &Reverse;
  if Count <= 0then
    exit;
  for i := 0 to (Count - 1) div 2 do
    begin
      var x := Count - i - 1;
      fValues.Exchange(i, x);
    end;
  BGLow := Consts.NegativeInfinity;
  BGHigh := Consts.PositiveInfinity;
  if not IsOrdered then
    exit;
  for i := 0 to (Count - 1) div 2 do
    begin
      var x := Count - i - 1;
      var lGB := lGoodBad[i];
      lGoodBad[i] := lGoodBad[x];
      lGoodBad[x] := lGB;
    end;
  if IsDescending then
    begin
      var minB := Count;
      var maxG := -1;
      for i := 0 to Count - 1 do
        begin
          if (lGoodBad[i] = 'B') and (minB = Count) then
            minB := i;
          if lGoodBad[i] = 'G' then
            maxG := i;
        end;
      BGLow := maxG;
      BGHigh := minB;
    end
  else
    begin
      var maxB := -1;
      var minG := Count;
      for i := 0 to Count - 1 do
        begin
          if lGoodBad[i] = 'B' then
            maxB := i;
          if (lGoodBad[i] = 'G') and (minG = Count) then
            minG := i;
        end;
      BGLow := maxB;
      BGHigh := minG;
    end;
end;

{$ENDREGION}

{$REGION DexiScaleStrings}

constructor DexiScaleStrings(
  aInvariant: Boolean := true;
  aValueType: ValueStringType := ValueStringType.Text;
  aMemDecimals: Integer := -1);
begin
  fString := MakeString;
  fInvariant := aInvariant;
  fSimple := false;
  fValueType := aValueType;
  fMemDecimals := aMemDecimals;
  fStringCreate := nil;
end;

method DexiScaleStrings.ResetDecimals;
begin
  fMemDecimals := -1;
end;

method DexiScaleStrings.NewString: CompositeString;
begin
  result := new CompositeString;
end;

method DexiScaleStrings.MakeString: CompositeString;
begin
  result :=
    if assigned(fStringCreate) then fStringCreate()
    else NewString;
end;

method DexiScaleStrings.AddStr(aStr: String);
begin
  fString.Add(aStr, 0);
end;

method DexiScaleStrings.AddStr(aStr: String; aTag: Integer);
begin
  fString.Add(aStr, aTag);
end;

method DexiScaleStrings.AddInt(aInt: Integer);
begin
  var lTag :=
    if fScale.IsBad(aInt) then -1
    else if fScale.IsGood(aInt) then +1
    else 0;
  case fValueType of
    ValueStringType.Zero: AddStr(Utils.IntToStr(aInt), lTag);
    ValueStringType.One:  AddStr(Utils.IntToStr(aInt + 1), lTag);
    ValueStringType.Text:
      if fScale is DexiDiscreteScale then
        AddStr(DexiDiscreteScale(fScale).Names[aInt], lTag)
      else AddStr(Utils.IntToStr(aInt), lTag);
  end;
end;

method DexiScaleStrings.AddFlt(aFlt: Float);
begin
  var lTag :=
    if fScale.IsBad(aFlt) then -1
    else if fScale.IsGood(aFlt) then +1
    else 0;
  AddStr(Utils.FltToStr(aFlt, fScale.FltDecimals, Invariant), lTag);
end;

method DexiScaleStrings.ValueOnScaleComposite(aValue: Integer; aScale: DexiScale): CompositeString;
begin
  fScale := aScale;
  fString := MakeString;
  fString.Clear;
  if (aValue < 0) or (aScale = nil) then
    fString.Add(DexiString.SDexiUndefinedValue)
  else
    AddInt(aValue);
  result := fString;
end;

method DexiScaleStrings.ValueOnScaleComposite(aValue: Float; aScale: DexiScale): CompositeString;
begin
  fScale := aScale;
  fString := MakeString;
  if (aScale = nil) or not aScale.IsContinuous then
    fString.Add(DexiString.SDexiUndefinedValue)
  else
    AddFlt(aValue);
  result := fString;
end;

method DexiScaleStrings.ValueOnScaleComposite(aValue: DexiValue; aScale: DexiScale): CompositeString;

  method DoAddIntSet(aIntSet: IntSet);
  begin
    for i := low(aIntSet) to high(aIntSet) do
      begin
        if i > 0 then
          AddStr(DexiString.SListSeparator);
        AddInt(aIntSet[i]);
      end;
  end;

  method DoAddDistr(aDistr: Distribution);
  begin
    var lNext := false;
    for i := Values.DistrLowIndex(aDistr) to Values.DistrHighIndex(aDistr) do
      begin
        var lElement := Values.GetDistribution(aDistr, i);
        if Utils.FloatEq(lElement, 0.0) then {nothing}
        else
          begin
            if lNext then
              AddStr(DexiString.SListSeparator)
            else
              lNext := true;
            AddInt(i);
            if not Utils.FloatEq(lElement, 1.0) then
              AddStr(DexiString.SDistrSeparator + Utils.FltToStr(lElement, MemDecimals, fInvariant));
          end;
      end;
  end;

  method AddIntInt(aIntInt: IntInterval);
  begin
    if Values.IsIntSingle(aIntInt) then
      AddInt(aIntInt.Low)
    else
      begin
        if not aScale.IsInterval then
          DoAddIntSet(Values.IntSet(aIntInt))
        else
          begin
            var lBound := aIntInt.Low <= aScale.LowInt;
            var hBound := aIntInt.High >= aScale.HighInt;
            if lBound then
              if hBound then
                AddStr(DexiString.SFullInterval)
              else
                begin // LE
                  AddStr(if aScale.IsDescending then DexiString.SBetterEq else DexiString.SWorseEq);
                  AddInt(aIntInt.High);
                end
            else
              if hBound then
                begin // GE
                  AddStr(if aScale.IsDescending then DexiString.SWorseEq else DexiString.SBetterEq);
                  AddInt(aIntInt.Low);
                end
              else
                begin
                  AddInt(aIntInt.Low);
                  AddStr(DexiString.SIntervalSeparator);
                  AddInt(aIntInt.High);
                end;
          end;
      end;
  end;

  method AddIntSet(aIntSet: IntSet);
  begin
    if Values.IsIntSingle(aIntSet) then
      AddInt(Values.IntSingle(aIntSet))
    else if Values.IsIntInt(aIntSet) then
      AddIntInt(Values.IntInt(aIntSet))
    else
      DoAddIntSet(aIntSet);
  end;

  method AddDistribution(aDistr: Distribution);
  begin
    if Values.IsIntSingle(aDistr) then
      AddInt(Values.IntSingle(aDistr))
    else if Values.IsIntInt(aDistr) then
      AddIntInt(Values.IntInt(aDistr))
    else if Values.IsIntSet(aDistr) then
      AddIntSet(Values.IntSet(aDistr))
    else
      DoAddDistr(aDistr);
  end;

  method AddFltFlt(aFltInt: FltInterval);
  begin
    if Values.IsFltSingle(aFltInt) then
      AddFlt(aFltInt.Low)
    else
      begin
        if not aScale.IsInterval then
          begin
            AddFlt(aFltInt.Low);
            AddStr(DexiString.SIntervalSeparator);
            AddFlt(aFltInt.High);
          end
        else
          begin
            var lBound := aFltInt.Low <= aScale.LowFloat;
            var hBound := aFltInt.High >= aScale.HighFloat;
            if lBound then
              if hBound then
                AddStr(DexiString.SFullInterval)
              else
                begin // LE
                  AddStr(if aScale.IsDescending then DexiString.SBetterEq else DexiString.SWorseEq);
                  AddFlt(aFltInt.High);
                end
            else
              if hBound then
                begin // GE
                  AddStr(if aScale.IsDescending then DexiString.SWorseEq else DexiString.SBetterEq);
                  AddFlt(aFltInt.Low);
                end
              else
                begin
                  AddFlt(aFltInt.Low);
                  AddStr(DexiString.SIntervalSeparator);
                  AddFlt(aFltInt.High);
                end;
          end;
      end;
  end;

 begin
  fScale := aScale;
  fString := MakeString;
  if (aValue = nil) or (aScale = nil) or not aValue.IsDefined then
    fString.Add(DexiString.SDexiUndefinedValue)
  else
    case aValue.ValueType of
      DexiValueType.IntSingle:    AddInt(aValue.AsInteger);
      DexiValueType.IntInterval:  AddIntInt(aValue.AsIntInterval);
      DexiValueType.IntSet:       AddIntSet(aValue.AsIntSet);
      DexiValueType.Distribution: AddDistribution(aValue.AsDistribution);
      DexiValueType.FltSingle:    AddFlt(aValue.AsFloat);
      DexiValueType.FltInterval:  AddFltFlt(aValue.AsFltInterval);
    else
     fString.Add(DexiValue.ToString(aValue, fInvariant));
    end;
  result := fString;
end;

method DexiScaleStrings.ValueOnScaleString(aValue: DexiValue; aScale: DexiScale): String;
begin
  result := ValueOnScaleComposite(aValue, aScale).AsString;
end;

method DexiScaleStrings.ValueOnScaleComposite(aOffsets: IntOffsets; aScale: DexiScale): CompositeString;
begin
  fScale := aScale;
  fString := MakeString;
  if (aOffsets = nil) or (aScale = nil) or (aScale is not DexiDiscreteScale) then
    fString.Add(DexiString.SDexiUndefinedValue)
  else
    for each lOffset in aOffsets index x do
      begin
        if x > 0 then
          AddStr(DexiString.SListSeparator);
        AddInt(lOffset.Int);
        if not Utils.FloatZero(lOffset.Off) then
          begin
            if lOffset.Off > 0.0 then
              AddStr(if Simple then '+' else DexiString.PlusSign)
            else
              AddStr(if Simple then '-' else DexiString.MinusSign);
            AddStr(Utils.FltToStr(Math.Abs(lOffset.Off), MemDecimals, Invariant));
          end;
      end;
  result := fString;
end;

method DexiScaleStrings.ValueOnScaleString(aOffsets: IntOffsets; aScale: DexiScale): String;
begin
  result := ValueOnScaleComposite(aOffsets, aScale).AsString;
end;

method DexiScaleStrings.ScaleComposite(aScale: DexiScale; aWithName: Boolean := false): CompositeString;

  method AddDiscreteScale(aScale: DexiDiscreteScale);
  begin
    var lNext := false;
    for i := 0 to aScale.Count - 1 do
      begin
        if lNext then
          AddStr(DexiString.SListSeparator)
        else
          lNext := true;
        AddInt(i);
      end;
  end;

  method AddContinuousScale(aScale: DexiContinuousScale);
  begin
    var lLow :=
      if Consts.IsInfinity(aScale.BGLow) then ''
      else Utils.FltToStr(aScale.BGLow, fInvariant);
    var lHigh :=
      if Consts.IsInfinity(aScale.BGHigh) then ''
      else Utils.FltToStr(aScale.BGHigh, fInvariant);
    var lTag :=
      case aScale.Order of
        DexiOrder.Ascending: DexiScale.BadCategory;
        DexiOrder.Descending: DexiScale.GoodCategory;
        DexiOrder.None: DexiScale.NeutralCategory;
      end;
    AddStr('<', lTag);
    if (lLow + lHigh) <> '' then
      begin
        AddStr(' ');
        if lLow <> '' then
          AddStr(lLow, lTag);
        AddStr(' ' + DexiString.SIntervalSeparator + ' ');
        if lHigh <> '' then
          AddStr(lHigh, -lTag);
        AddStr(' ');
      end;
    AddStr('>', -2 * lTag);
    if not String.IsNullOrEmpty(aScale.ScaleUnit) then
      AddStr(' [' + aScale.ScaleUnit + ']');
  end;

begin
  fScale := aScale;
  fString := MakeString;
  if aScale = nil then
    fString.Add(DexiString.SDexiNullScale)
  else
    begin
      if aWithName and not String.IsNullOrEmpty(aScale.Name) then
        AddStr(aScale.Name + ': ');
      if aScale is DexiDiscreteScale then
        AddDiscreteScale(aScale as DexiDiscreteScale)
      else if aScale is DexiContinuousScale then
        AddContinuousScale(aScale as DexiContinuousScale)
      else
        raise new EDexiError(String.Format(DexiString.SDexiUnsupportedScale, aScale.ScaleString));
    end;
  result := fString;
end;

method DexiScaleStrings.ScaleString(aScale: DexiScale): String;
begin
  result := ScaleComposite(aScale).AsString;
end;

method DexiScaleStrings.ParseScaleValue(aStr: String; aScale: DexiScale): DexiValue;
begin
  var lParser := new DexiValueParser(aScale, ValueType, Invariant);
  if lParser.Parse(aStr) then
    result := lParser.Value
  else
    raise new EDexiError(lParser.Error);
end;

method DexiScaleStrings.TryParseScaleValue(aStr: String; aScale: DexiScale): DexiValueParser;
begin
  result := new DexiValueParser(aScale, ValueType, Invariant);
  result.Parse(aStr);
end;

{$ENDREGION}

{$REGION DexiValueToken}

constructor DexiValueToken(aStr: String);
begin
  Str := aStr;
end;

{$ENDREGION}

{$REGION DexiValueTokenizer}

method DexiValueTokenizer.Clear;
begin
  Tokens.RemoveAll;
  IntervalOperators := false;
  IntervalDelimiters := 0;
  MemberDelimiters := 0;
  ListDelimiters := 0;
end;

method DexiValueTokenizer.Unquote(aStr: String): String;
begin
  result := aStr;
  if String.IsNullOrEmpty(aStr) or not (aStr[0] in Quotes) or (aStr[0] <> aStr[aStr.Length - 1]) then
    exit;
  var sb := new StringBuilder;
  var lQuote: Char := aStr[0];
  var lPrevQuote := false;
  for i := 1 to aStr.Length - 2 do
    begin
      if aStr[i] = lQuote then
        begin
          if lPrevQuote then
            sb.Append(lQuote);
          lPrevQuote := not lPrevQuote;
        end
      else
        begin
          if lPrevQuote then
            sb.Append(lQuote);
          lPrevQuote := false;
          sb.Append(aStr[i]);
        end;
    end;
  if lPrevQuote then
    sb.Append(lQuote);
  result := sb.ToString;
end;

method DexiValueTokenizer.GetDelimiters(aStr: String): List<Integer>;
begin
  result := new List<Integer>;
  if String.IsNullOrEmpty(aStr) then
    exit;
  var lQuote: Char := ' ';
  for each lChar in aStr index x do
    begin
      if lChar in ['''', '"'] then
        if lQuote = ' ' then
          lQuote := lChar
        else if lChar = lQuote then
          lQuote := ' ';
      if (lQuote = ' ') and (lChar in Delimiters) then
        result.Add(x);
    end;
end;

method DexiValueTokenizer.Tokenize(aStr: String);
begin
  Clear;
  if String.IsNullOrEmpty(aStr) then
    exit;
  var lOpLen :=
    if aStr.StartsWith('<=') or aStr.StartsWith('>=') then 2
    else if aStr.StartsWith('<') or aStr.StartsWith('>') then 1
    else 0;
  if lOplen > 0 then
    begin
      var lOp := aStr.Substring(0, lOpLen);
      Tokens.Add(new DexiValueToken(lOp, IsDelimiter := true));
      IntervalOperators := true;
    end;
  var lLastDelim := lOpLen - 1;
  var lDelimiters := GetDelimiters(aStr);
  for each lDelim in lDelimiters do
    begin
      var lStr := Utils.CopyFromTo(aStr, lLastDelim + 1, lDelim - 1).Trim;
      var lDel := aStr[lDelim];
      lLastDelim := lDelim;
      Tokens.Add(new DexiValueToken(lStr));
      Tokens.Add(new DexiValueToken(lDel, IsDelimiter := true));
    end;
  var lStr := Utils.CopyFromTo(aStr, lLastDelim + 1, aStr.Length - 1).Trim;
  Tokens.Add(new DexiValueToken(lStr));
  for i := 0 to Tokens.Count - 1 do
    begin
      if Tokens[i].IsDelimiter then
        case Tokens[i].Str of
          '/': MemberDelimiters := MemberDelimiters + 1;
          ':': IntervalDelimiters := IntervalDelimiters + 1;
          ';': ListDelimiters := ListDelimiters + 1;
        end
      else
        begin
          var lUnquoted := Unquote(Tokens[i].Str);
          if lUnquoted <> Tokens[i].Str then
            begin
              Tokens[i].Str := lUnquoted;
              Tokens[i].IsQuoted := true;
            end;
          if String.IsNullOrEmpty(Tokens[i].Str) then
            raise new EDexiError(String.Format(DexiString.SDexiValueParseError, [aStr]));
        end;
    end;
end;

{$ENDREGION}

{$REGION DexiValueParser}

constructor DexiValueParser(aScale: DexiScale; aValueType: ValueStringType := ValueStringType.Text; aInvariant: Boolean := true);
begin
  fScale := aScale;
  fValueType := aValueType;
  fInvariant := aInvariant;
  Clear;
end;

method DexiValueParser.Clear;
begin
  fParseStr := '';
  fValue := nil;
  fError := nil;
end;

method DexiValueParser.ParseError(aErrorMsg: String);
begin
  raise new EDexiError(aErrorMsg);
end;

method DexiValueParser.ParseError;
begin
  ParseError(String.Format(DexiString.SDexiValueParseError, [ParseStr]));
end;

method DexiValueParser.ValidateTokens;
begin
  if Tokenizer.IntervalOperators then
    begin
      if Tokenizer.Count <> 2 then
        ParseError;
      if (Tokenizer.MemberDelimiters > 0) or (Tokenizer.IntervalDelimiters > 0) or (Tokenizer.ListDelimiters > 0) then
        ParseError;
    end
  else if Tokenizer.IntervalDelimiters > 1 then
    ParseError
  else if Tokenizer.IntervalDelimiters = 1 then
    begin
      if Tokenizer.Count <> 3 then
        ParseError;
      if (Tokenizer.MemberDelimiters > 0) or (Tokenizer.ListDelimiters > 0) then
        ParseError;
    end;
  if Tokenizer.MemberDelimiters > Tokenizer.ListDelimiters + 1 then
    ParseError;
end;

method DexiValueParser.ParseAsInt(aToken: DexiValueToken): Integer;
begin
  if aToken.IsDelimiter then
    ParseError;
  var lSuccess := false;
  if (ValueType <> ValueStringType.Text) and not aToken.IsQuoted then
    try
      result := Utils.StrToInt(aToken.Str);
      if ValueType = ValueStringType.One then
        dec(result);
       lSuccess := true;
    except
    end;
  if not lSuccess then
    begin
      result := Scale.IndexOfValue(aToken.Str);
      lSuccess := result >= 0;
    end;
  if not lSuccess then
    try
      result := Utils.StrToInt(aToken.Str);
      if ValueType = ValueStringType.One then
        dec(result);
      lSuccess := true;
    except
    end;
  if not lSuccess then
    ParseError(String.Format(DexiString.SDexiValueParseInt, [ParseStr, aToken.Str]));
end;

method DexiValueParser.ParseAsFlt(aToken: DexiValueToken): Float;
begin
  if aToken.IsDelimiter then
    ParseError;
  try
    result := Utils.StrToFlt(aToken.Str, Invariant);
  except
    ParseError(String.Format(DexiString.SDexiValueParseFlt, [ParseStr, aToken.Str]));
  end;
end;

method DexiValueParser.ParseAsSet: DexiValue;
begin
  var lSet := Values.EmptySet;
  for each lToken in Tokenizer.Tokens do
    if lToken.IsDelimiter then
      begin
        if lToken.Str <> ';' then
          ParseError;
      end
    else
      begin
        var lInt := ParseAsInt(lToken);
        Values.IntSetInclude(var lSet, lInt)
      end;
  result := new DexiIntSet(lSet);
end;

method DexiValueParser.ParseAsDistribution: DexiValue;
var
  TokenPos: Integer;
  CurrentToken: DexiValueToken;

  method Advance;
  begin
    inc(TokenPos);
    CurrentToken :=
      if TokenPos >= Tokenizer.Tokens.Count then nil
      else Tokenizer.Tokens[TokenPos];
  end;

begin
  var lDistr := Values.EmptyDistr;
  TokenPos := -1;
  Advance;
  while CurrentToken <> nil do
    begin
      if CurrentToken.IsDelimiter then
        ParseError;
      var lInt := ParseAsInt(CurrentToken);
      var lMem := 1.0;
      Advance;
      if (CurrentToken <> nil) and CurrentToken.IsDelimiter and (CurrentToken.Str = '/') then
        begin
          Advance;
          lMem := ParseAsFlt(CurrentToken);
          Advance;
        end;
      Values.SetDistribution(var lDistr, lInt, lMem, true);
      if (CurrentToken <> nil) and CurrentToken.IsDelimiter and (CurrentToken.Str = ';') then
        Advance;
    end;
  result := new DexiDistribution(lDistr);
end;

method DexiValueParser.ParseIntValues(aStr: String): DexiValue;
begin
  Tokenizer.Tokenize(aStr);
  ValidateTokens;
  result := nil;
  if Tokenizer.IntervalOperators then
    begin
      var lInt := ParseAsInt(Tokenizer.Tokens[1]);
      case Tokenizer.Tokens[0].Str of
        '<':  result := new DexiIntInterval(Scale.LowInt, lInt - 1);
        '<=': result := new DexiIntInterval(Scale.LowInt, lInt);
        '>':  result := new DexiIntInterval(lInt + 1, Scale.HighInt);
        '>=': result := new DexiIntInterval(lInt, Scale.HighInt);
        else
          ParseError;
      end;
    end
  else if Tokenizer.Count = 1 then
    if Tokenizer.Tokens[0].Str = '*' then
      result := new DexiIntInterval(Scale.LowInt, Scale.HighInt)
    else
      begin
        var lInt := ParseAsInt(Tokenizer.Tokens[0]);
        result := new DexiIntSingle(lInt);
      end
  else if Tokenizer.IntervalDelimiters = 1 then
    begin
      var lLow := ParseAsInt(Tokenizer.Tokens[0]);
      var lHigh := ParseAsInt(Tokenizer.Tokens[2]);
      result := new DexiIntInterval(lLow, lHigh);
    end
  else if Tokenizer.MemberDelimiters > 0 then
    result := ParseAsDistribution
  else
    result := ParseAsSet;
  if result <> nil then
    if not result.InBounds(Scale.LowInt, Scale.HighInt) then
      ParseError(String.Format(DexiString.SDexiValueParseOutOfBounds, [ParseStr]));
end;

method DexiValueParser.Parse(aStr: String): Boolean;
begin
  Clear;
  fParseStr := aStr:Trim;
  result := true;
  if String.IsNullOrEmpty(aStr) then
    exit;
  if DexiValue.IsUndefined(aStr) then
    begin
      fValue := new DexiUndefinedValue;
      exit;
    end;
  try
    if Scale = nil then
      ParseError
    else if Scale.IsContinuous then
      fValue := DexiValue.FromFltString(ParseStr, Invariant)
    else
      fValue := ParseIntValues(ParseStr);
  except on E: Exception do
    begin
      fError := E.Message;
      fValue := nil;
      result := false;
    end;
  end;
end;

{$ENDREGION}

end.
