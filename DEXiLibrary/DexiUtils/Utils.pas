// Utils.pas is part of
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
// Utils.pas implements general purpose types and classess:
// - Float type: representing floating-point numbers, offering the choice between Single and Double
// - Array types: IntArray, FltArray and BoolArray
// - Matrix types: IntMatrix and FltMatrix
// - Set classes: SetOfChar and SetOfInt, internally represented by unsorted arrays of the respective types
// - IntPair: pair of two integers
// - Utils: a static class implementing general-purpose methods operating on strings, numbers, objects, lists, etc.
// - CompositeString: a class implementing "strings" that consist of a sequence of tagged substrings.
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  RemObjects.Elements.RTL;

type
  Float = public Double;
  IntArray = public array of Integer;
  FltArray = public array of Float;
  BoolArray = public array of Boolean;
  IntMatrix = public array of IntArray;
  FltMatrix = public array of FltArray;

type
  EConvertError = class(Exception);

type
  IntDistance = public block (const ia1, ia2: IntArray): Integer;
  FltDistance = public block (const ia1, ia2: IntArray): Float;

type
  /// <summary>
  /// Represents a set of Char using an unsorted String.
  /// </summary>
  SetOfChar = public class
  private
    fChars: String;
  public
    class method EqualSets(aSet1, aSet2: SetOfInt): Boolean;
    class method CopySet(aSet: SetOfChar): SetOfChar;
    constructor;
    constructor (aSet: SetOfChar);
    constructor (aChars: sequence of Char);
    constructor (aString: String);
    method Include(aChar: Char);
    method Include(aSet: SetOfChar);
    method Include(aChars: sequence of Char);
    method Exclude(aChar: Char);
    method Exclude(aSet: SetOfChar);
    method Exclude(aChars: sequence of Char);
    method Contains(aChar: Char): Boolean;
    property Chars: String read fChars;
  end;

type
  /// <summary>
  /// Represents a set of Int using an unsorted IntArray.
  /// </summary>
  SetOfInt = public class
  protected
    fInts: IntArray;
  public
    class method EqualSets(aSet1, aSet2: SetOfInt): Boolean;
    class method CopySet(aSet: SetOfInt): SetOfInt;
    constructor;
    constructor (aFrom, aTo: Integer);
    constructor (aArr: IntArray);
    constructor (aSet: SetOfInt);
    method Clear;
    method All(aFrom, aTo: Integer);
    method Include(aInt: Integer); virtual;
    method Include(aSet: SetOfInt);
    method Include(aInts: sequence of Integer);
    method Exclude(aInt: Integer); virtual;
    method Exclude(aSet: SetOfInt);
    method Exclude(aInts: sequence of Integer);
    method IncludeIndex(aInt: Integer);
    method ExcludeIndex(aInt: Integer);
    method Exchange(aInt1, aInt2: Integer);
    method Move(aInt1, aInt2: Integer);
    method Contains(aInt: Integer): Boolean;
    method EqualsTo(aSet: SetOfInt): Boolean;
    method ToString: String; override;
    property Ints: IntArray read fInts;
    property Members: IntArray read Utils.CopyIntArray(fInts);
    property Count: Integer read length(fInts);
  end;

type
  /// <summary>
  /// A pair of two Integers, I1 and I2
  /// </summary>
  IntPair = public class
  private
    fI1, fI2: Integer;
  public
    property I1: Integer read fI1 write fI1;
    property I2: Integer read fI2 write fI2;
    constructor (aI1, aI2: Integer);
  end;

type
  ImpurityFunction = public block (aProb: FltArray): Float;

type
  /// <summary>
  /// A static class that implements general-purpose methods.
  /// </summary>
  Utils = public static partial class
  private
    const FuzzFactor = 1000;
    const SInvalidBoolean = '"{0}" is not a valid Boolean value';
  public
    const SingleEpsilon = 1.0E-7 * FuzzFactor;
    const DoubleEpsilon = 1.0E-15 * FuzzFactor;
    const FloatEpsilon = DoubleEpsilon;
    const TabChar = #9;
    const DefaultTabSkip = 8;
    const DefaultSeparator = ';';
    property TabSkip: Integer := DefaultTabSkip;
    property Separator: Char := DefaultSeparator;

    // OBJECT

    method BothNil(aObj1, aObj2: Object): Boolean;
    method BothNonNil(aObj1, aObj2: Object): Boolean;

    // LISTS

    method ListCount<T>(aList: ImmutableList<T>): Integer;
    method EqualLists<T>(aList1, aList2: ImmutableList<T>): Boolean;
    method EqualLists(aList1, aList2: ImmutableList<String>): Boolean;
    method CopyList<T>(aList: ImmutableList<T>): List<T>;
    method ListContains(aList: ImmutableList<String>; aStr: String; aCaseSensitive: Boolean := true): Boolean;
    method ListOrder<T>(aSource, aReference: ImmutableList<T>): IntArray;
    method OrderList<T>(aSource: ImmutableList<T>; aOrder: IntArray; aAppendRest: Boolean := true): List<T>;

    // NUMERIC

    method Epsilon(var a: Double): Double;
    method Epsilon(var a: Single): Single;
    method FloatZero(const f: Float): Boolean;
    method FloatEq(const f1, f2: Float): Boolean;
    method FloatEq(const f1, f2, eps: Float): Boolean;
    method FloatEqWithNaN(const f1, f2: Float): Boolean;
    method FloatEqWithNaN(const f1, f2, eps: Float): Boolean;
    method Swap<T>(var a1, a2: T);
    method SwapInt(var i1, i2: Integer);
    method SwapFlt(var f1, f2: Float);
    method SwapBool(var b1, b2: Boolean);
    method SwapObj(var o1, o2: Object);
    method GCD(i1, i2: Integer): Integer;
    method RoundUp(const f: Float): Integer;
    method LinMap(x: Float; iMin, iMax: Float; oMin, oMax: Float): Float;

    // STRINGS

    method Pos0(const sub, s: String): Integer;
    method CopyString(const s: String; const pos: Integer := 0): String;
    method CopyString(const s: String; const pos, len: Integer): String;
    method CopyFromTo(const s: String; f, t: Integer): String;
    method StrEl(const s: String; i: Integer): Char;
    method ChStr(len: Integer; ch: Char := ' '): String;
    method ChString(len: Integer; const s: String := ' '): String;
    method PadTo(const s: String; len: Integer; ch: Char := ' '): String;
    method PadRight(const s: String; len: Integer): String;

    method RestOf(const s: String; pos: Integer): String;
    method LeftOf(const s, sub: String): String;
    method RightOf(const s, sub: String): String;
    method ReplaceStr(const s, f, t: String): String;
    method NextElem(var s: String): String;
    method NextElem(var s: String; const sep: String): String;
    method NextSubstr(var s: String; const sep: String := DefaultSeparator): String;
    method AppendStr(aString, aAppend, aSeparator: String): String;
    method IdString(aString: String; aRep: Char := '_'): String;
    method JsonString(aString: String): String;
    method HtmlString(aString: String): String;
    method BreakToLines(aString: String): ImmutableList<String>;
    method BreakToWords(aString: String): ImmutableList<String>;

    // FILE NAMES

    method FileExtension(aFileName: String): String;

    // ARRAYS

    method NewIntArray(const aLen: Integer; const aInit: Integer := 0): IntArray;
    method CopyIntArray(const aArr: IntArray; aPos: Integer := 0; aLen: Integer := -1): IntArray;
    method IntArrayIndex(const aArr: IntArray; aInt: Integer): Integer;
    method IntArrayContains(const aArr: IntArray; aInt: Integer): Boolean;
    method IntArrayEq(aArr1, aArr2: IntArray): Boolean;
    method ConcatenateIntArrays(const aArr1, aArr2: IntArray): IntArray;
    method IntArrayInsert(const aArr: IntArray; aIdx: Integer; aVal: Integer := 0): IntArray;
    method IntArrayDelete(const aArr: IntArray; aIdx: Integer): IntArray;
    method IntArrayMove(const aArr: IntArray; aFromIdx, aToIdx: Integer): IntArray;
    method IntArrayExchange(var aArr: IntArray; aFromIdx, aToIdx: Integer);
    method RangeArray(const aLen: Integer; aFrom: Integer; aStep: Integer := 1): IntArray;
    method IntArraySubset(const aArr: IntArray; aIndexCondition: Predicate<Integer>): IntArray;
    method IntArraySubset(const aArr: IntArray; aIndices: IntArray): IntArray;
    method IntArraySubset(const aArr: IntArray; aSelect: BoolArray): IntArray;
    method NewFltArray(const aLen: Integer; const aInit: Float := 0.0): FltArray;
    method CopyFltArray(const aArr: FltArray; aPos: Integer := 0; aLen: Integer := -1): FltArray;
    method FltArrayEq(aArr1, aArr2: FltArray): Boolean;
    method FltArrayEq(aArr1, aArr2: FltArray; const eps: Float): Boolean;
    method FltArrayEqWithNaN(aArr1, aArr2: FltArray; const eps: Float): Boolean;
    method ConcatenateFltArrays(const aArr1, aArr2: FltArray): FltArray;
    method FltArrayInsert(const aArr: FltArray; aIdx: Integer; aVal: Float := 0.0): FltArray;
    method FltArrayDelete(const aArr: FltArray; aIdx: Integer): FltArray;
    method FltArrayMove(const aArr: FltArray; aFromIdx, aToIdx: Integer): FltArray;
    method FltArrayExchange(var aArr: FltArray; aFromIdx, aToIdx: Integer);
    method IntToFltArray(aArr: IntArray): FltArray;
    method FltToIntArray(aArr: FltArray): IntArray;
    method RemoveNaN(aArr: FltArray): FltArray;
    method NewBoolArray(const aLen: Integer; const aInit: Boolean := false): BoolArray;
    method CopyBoolArray(const aArr: BoolArray; aPos: Integer := 0; aLen: Integer := -1): BoolArray;
    method NewIntMatrix(const aLen1, aLen2: Integer; const aInit: Integer := 0): IntMatrix;
    method NewFltMatrix(const aLen1, aLen2: Integer; const aInit: Float := 0.0): FltMatrix;

    // CONVERSIONS

    method IntToStr(i: Integer): String;
    method NullableIntToStr(i: nullable Integer): String;
    method StrToInt(const s: String): Integer;
    method FloatToStr(f: Float): String;
    method FltToStr(f: Float; aInvariant: Boolean := true): String;
    method FltToStr(f: Float; dec: Integer; aInvariant: Boolean := true): String;
    method FltToStrInvariant(f: Float; dec: Integer := -1): String;
    method FltToStrLocal(f: Float; dec: Integer := -1): String;
    method StrToFloat(const s: String): Float;
    method StrToFlt(const s: String; aInvariant: Boolean := true): Float;
    method BooleanToStr(b: Boolean): String;
    method StrToBoolean(const s: String): Boolean;
    method CharsToString(aChars: array of Char): String;
    method StrToLines(const s: String): List<String>;
    method ExchangeList(aList: List<String>; aIdx1, aIdx2: Integer);
    method ExchangeList<T>(aList: List<T>; aIdx1, aIdx2: Integer);
    method MoveList(aList: List<String>; aFrom, aTo: Integer);
    method MoveList<T>(aList: List<T>; aFrom, aTo: Integer);

    method IntArrayToStr(const aArray: IntArray): String;
    method StrToIntArray(const s: String): IntArray;
    method FltArrayToStr(const aArray: FltArray; aInvariant: Boolean := true): String;
    method FltArrayToStr(const aArray: FltArray; dec: Integer; aInvariant: Boolean := true): String;
    method StrToFltArray(const s: String; aInvariant: Boolean := true): FltArray;

    // COMPARISON

    method Compare(i1, i2: Integer): Integer;
    method Compare(f1, f2: Float): Integer;
    method Compare(const ia1, ia2: IntArray): Integer;
    method Compare(const fa1, fa2: FltArray): Integer;

    // DISTANCES

    method HammingDistance(const ia1, ia2: IntArray): Integer;
    method ManhattanDistance(const ia1, ia2: IntArray): Integer;
    method EuclideanDistance(const ia1, ia2: IntArray): Float;

    // CORRELATIONS

    method Correlation(ia1, ia2: IntArray): Float;
    method Correlation(fa1, fa2: FltArray): Float;

    // INDEX
    method InsertIndex(aIdx, aIns: Integer): Integer;
    method DeleteIndex(aIdx, aDel: Integer): Integer;
    method DuplicateIndex(aIdx, aDup: Integer): Integer;
    method MoveIndex(aIdx, aFrom, aTo: Integer): Integer;
    method ExchangeIndex(aIdx, aIdx1, aIdx2: Integer): Integer;
    method MergeIndex(aIdx, aFrom, aTo: Integer): Integer;
    method ReverseIndex(aIdx, aLow, aHigh: Integer): Integer;
    method ReverseFloat(aFlt, aLow, aHigh: Float): Float;

    // DATE TIME
    method ISODateTimeStr(aDateTime: DateTime): String;

    // FLAGS
    method AddFlag(aState, aFlag: Integer): Integer;
    method RemoveFlag(aState, aFlag: Integer): Integer;
    method IncludesFlag(aState, aFlag: Integer): Boolean;

    // IMPURITY FUNCTIONS
    method Gini(aProb: FltArray): Float;
    method Entropy(aProb: FltArray): Float;
  end;

type
  CompositeStringFactory = public method : CompositeString;

type
  /// <summary>
  /// An element of CompositeString. Contains an Integer-tagged string.
  /// </summary>
  CompositeElement = public class
  private
    fStr: String;
    fTag: Integer;
  public
    property Str: String read fStr write fStr;
    property Tag: Integer read fTag write fTag;
    constructor (aString: String := ''; aTag: Integer := 0);
  end;

type
  /// <summary>
  /// CompositeString is a string composed of zero or more CompositeElements.
  /// Useful, for instance, to handle "strings" that contain differently colored substrings.
  /// </summary>
  CompositeString = public class
  private
    fElements: List<CompositeElement> := new List<CompositeElement>;
    class var fEmpty := new CompositeString;
  protected
    method GetAsString: String; virtual;
    method GetCount: Integer;
    method GetElement(aIdx: Integer): CompositeElement;
    method GetStr(aIdx: Integer): String;
    method GetTag(aIdx: Integer): Integer;
  public
    constructor;
    class property &Empty: CompositeString read fEmpty;
    property Elements: ImmutableList<CompositeElement> read fElements;
    property Count: Integer read GetCount;
    property Element[aIdx: Integer]: CompositeElement read GetElement;
    property Str[aIdx: Integer]: String read GetStr;
    property Tag[aIdx: Integer]: Integer read GetTag;
    method &Copy: not nullable CompositeString;
    method Clear;
    method Append(aCStr: CompositeString);
    method Assign(aCStr: CompositeString);
    method &Add(aString: String; aTag: Integer := 0);
    method ElementAsString(aElement: CompositeElement): String; virtual;
    method ElementAsString(aIdx: Integer): String; virtual;
    property AsString: String read GetAsString;
  end;

implementation

{$REGION SetOfChar}

class method SetOfChar.EqualSets(aSet1, aSet2: SetOfInt): Boolean;
begin
  result :=
    if aSet1 = aSet2 then true
    else if Utils.BothNonNil(aSet1, aSet2) then aSet1.EqualsTo(aSet2)
    else false;
end;

class method SetOfChar.CopySet(aSet: SetOfChar): SetOfChar;
begin
  result :=
    if aSet = nil then nil
    else new SetOfChar(aSet);
end;

constructor SetOfChar;
begin
  fChars := '';
end;

constructor SetOfChar(aSet: SetOfChar);
begin
  fChars := aSet.fChars;
end;

constructor SetOfChar(aChars: sequence of Char);
begin
  constructor;
  for each lChar in aChars do
    Include(lChar);
end;

constructor SetOfChar(aString: String);
begin
  fChars := aString;
end;

method SetOfChar.Include(aChar: Char);
begin
  if not Contains(aChar) then
    fChars := fChars + aChar;
end;

method SetOfChar.Include(aSet: SetOfChar);
begin
  Include(aSet.fChars.ToCharArray);
end;

method SetOfChar.Include(aChars: sequence of Char);
begin
  for each lChar in aChars do
    Include(lChar);
end;

method SetOfChar.Exclude(aChar: Char);
begin
  var x := fChars.IndexOf(aChar);
  if x >= 0 then
    fChars := fChars.SubString(0,x) + fChars.SubString(x+1);
end;

method SetOfChar.Exclude(aSet: SetOfChar);
begin
  Exclude(aSet.fChars.ToCharArray);
end;

method SetOfChar.Exclude(aChars: sequence of Char);
begin
  for each lChar in aChars do
    Exclude(lChar);
end;

method SetOfChar.Contains(aChar: Char): Boolean;
begin
  result := fChars.IndexOf(aChar) >= 0;
end;

{$ENDREGION}

{$REGION SetOfInt}

class method SetOfInt.EqualSets(aSet1, aSet2: SetOfInt): Boolean;
begin
  result :=
    if aSet1 = aSet2 then true
    else if Utils.BothNonNil(aSet1, aSet2) then aSet1.EqualsTo(aSet2)
    else false;
end;

class method SetOfInt.CopySet(aSet: SetOfInt): SetOfInt;
begin
  result :=
    if aSet = nil then nil
    else new SetOfInt(aSet);
end;

constructor SetOfInt;
begin
  fInts := new Integer[0];
end;

constructor SetOfInt(aFrom, aTo: Integer);
begin
  All(aFrom, aTo);
end;

constructor SetOfInt(aArr: IntArray);
begin
  fInts := Utils.CopyIntArray(aArr);
  if fInts = nil then
    fInts := new Integer[0];
end;

constructor SetOfInt(aSet: SetOfInt);
begin
  fInts := Utils.CopyIntArray(aSet:fInts);
end;

method SetOfInt.Clear;
begin
  fInts := new Integer[0];
end;

method SetOfInt.Include(aInt: Integer);
begin
  if not Contains(aInt) then
    begin
      var lInts := Utils.CopyIntArray(fInts, 0, length(fInts) + 1);
      lInts[high(lInts)] := aInt;
      fInts := lInts;
    end;
end;

method SetOfInt.All(aFrom, aTo: Integer);
begin
  fInts := new Integer[Math.Max(aTo - aFrom + 1, 0)];
  for i := low(fInts) to high(fInts) do
    begin
      fInts[i] := aFrom;
      inc(aFrom);
    end;
end;

method SetOfInt.Include(aSet: SetOfInt);
begin
  Include(aSet.fInts);
end;

method SetOfInt.Include(aInts: sequence of Integer);
begin
  for each lInt in aInts do
    Include(lInt);
end;

method SetOfInt.Exclude(aInt: Integer);
begin
  var x := Utils.IntArrayIndex(fInts, aInt);
  if x >= 0 then
    fInts := Utils.IntArrayDelete(fInts, x);
end;

method SetOfInt.Exclude(aSet: SetOfInt);
begin
  Exclude(aSet.fInts);
end;

method SetOfInt.Exclude(aInts: sequence of Integer);
begin
  for each lInt in aInts do
    Exclude(lInt);
end;

method SetOfInt.IncludeIndex(aInt: Integer);
begin
  for i := low(fInts) to high(fInts) do
    fInts[i] := Utils.InsertIndex(fInts[i], aInt);
  Include(aInt);
end;

method SetOfInt.ExcludeIndex(aInt: Integer);
begin
  Exclude(aInt);
  for i := low(fInts) to high(fInts) do
    fInts[i] := Utils.DeleteIndex(fInts[i], aInt);
end;

method SetOfInt.Exchange(aInt1, aInt2: Integer);
begin
  for i := low(fInts) to high(fInts) do
    if fInts[i] = aInt1 then
      fInts[i] := aInt2
    else if fInts[i] = aInt2 then
      fInts[i] := aInt1;
end;

method SetOfInt.Move(aInt1, aInt2: Integer);
begin
  for i := low(fInts) to high(fInts) do
    fInts[i] := Utils.MoveIndex(fInts[i], aInt1, aInt2);
end;

method SetOfInt.Contains(aInt: Integer): Boolean;
begin
  result := Utils.IntArrayIndex(fInts, aInt) >= 0;
end;

method SetOfInt.EqualsTo(aSet: SetOfInt): Boolean;
begin
  result := true;
  for x in fInts do
    if not aSet.Contains(x) then
      exit false;
  for x in aSet.fInts do
    if not Contains(x) then
      exit false;
end;

method SetOfInt.ToString: String;
begin
  result := Utils.IntArrayToStr(fInts);
end;

{$ENDREGION}

{$REGION IntPair}

constructor IntPair(aI1, aI2: Integer);
begin
  fI1 := aI1;
  fI2 := aI2;
end;

{$ENDREGION}

{$REGION Utils}

{$REGION OBJECT}

method Utils.BothNil(aObj1, aObj2: Object): Boolean;
begin
  result := (aObj1 = nil) and (aObj2 = nil);
end;

method Utils.BothNonNil(aObj1, aObj2: Object): Boolean;
begin
  result := (aObj1 <> nil) and (aObj2 <> nil);
end;

method Utils.ListCount<T>(aList: ImmutableList<T>): Integer;
begin
  result :=
    if aList = nil then 0
    else aList.Count;
end;

method Utils.EqualLists<T>(aList1, aList2: ImmutableList<T>): Boolean;
begin
  if aList1 = aList2 then
    exit true;
  if BothNil(aList1, aList2) then
    exit true;
  if not BothNonNil(aList1, aList2) then
    exit false;
  if aList1.Count <> aList2.Count then
    exit false;
  for i := 0 to aList1.Count - 1 do
    if Object(aList1[i]) <> Object(aList2[i]) then
      exit false;
  result := true;
end;

method Utils.EqualLists(aList1, aList2: ImmutableList<String>): Boolean;
begin
  if aList1 = aList2 then
    exit true;
  if not BothNonNil(aList1, aList2) then
    exit false;
  if aList1.Count <> aList2.Count then
    exit false;
  for i := 0 to aList1.Count - 1 do
    if aList1[i] <> aList2[i] then
      exit false;
  result := true;
end;

method Utils.CopyList<T>(aList: ImmutableList<T>): List<T>;
begin
  result :=
    if aList = nil then nil
    else new List<T>(aList);
end;

method Utils.ListContains(aList: ImmutableList<String>; aStr: String; aCaseSensitive: Boolean := true): Boolean;
begin
  if aCaseSensitive then
    result := aList.Contains(aStr)
  else
    begin
      result := false;
      aStr := aStr.ToUpper;
      for each str in aList do
        if str.ToUpper = aStr then
          exit true;
    end;
end;

method Utils.ListOrder<T>(aSource, aReference: ImmutableList<T>): IntArray;
begin
  if EqualLists(aSource, aReference) then
    exit nil;
  result := NewIntArray(Utils.ListCount(aSource));
  for i := low(result) to high(result) do
    begin
      var lIdx := aReference.IndexOf(aSource[i]);
      result[i] := lIdx;
    end;
end;

method Utils.OrderList<T>(aSource: ImmutableList<T>; aOrder: IntArray; aAppendRest: Boolean := true): List<T>;
begin
  if aSource = nil then
    exit nil;
  if aOrder = nil then
    exit new List<T>(aSource);
  result := new List<T>;
  for i := low(aOrder) to high(aOrder) do
    begin
      var x := aOrder[i];
      if 0 <= x < aSource.Count then
        result.Add(aSource[x]);
    end;
  if aAppendRest then
    for each lSrc in aSource do
      if not result.Contains(lSrc) then
        result.Add(lSrc);
end;

{$ENDREGION}

{$REGION NUMERIC}

method Utils.Epsilon(var a: Double): Double;
begin
  result := DoubleEpsilon;
end;

method Utils.Epsilon(var a: Single): Single;
begin
  result := SingleEpsilon;
end;

method Utils.FloatZero(const f: Float): Boolean;
begin
  result := FloatEq(f, 0.0);
end;

method Utils.FloatEq(const f1, f2: Float): Boolean;
begin
  result :=
    if Consts.IsInfinity(f1) then f1 = f2
    else Math.Abs(f1 - f2) < Utils.FloatEpsilon;
end;

method Utils.FloatEq(const f1, f2, eps: Float): Boolean;
begin
  result := Math.Abs(f1 - f2) < eps;
end;

method Utils.FloatEqWithNaN(const f1, f2: Float): Boolean;
begin
  result :=
    if Consts.IsNaN(f1) and Consts.IsNaN(f2) then true
    else FloatEq(f1, f2);
end;

method Utils.FloatEqWithNaN(const f1, f2, eps: Float): Boolean;
begin
  result :=
    if Consts.IsNaN(f1) and Consts.IsNaN(f2) then true
    else FloatEq(f1, f2, eps);
end;


method Utils.Swap<T>(var a1, a2: T);
begin
  var a := a1;
  a1 := a2;
  a2 := a;
end;

method Utils.SwapInt(var i1, i2: Integer);
begin
  var i := i1;
  i1 := i2;
  i2 := i;
end;

method Utils.SwapFlt(var f1, f2: Float);
begin
  var f := f1;
  f1 := f2;
  f2 := f;
end;

method Utils.SwapBool(var b1, b2: Boolean);
begin
  var b := b1;
  b1 := b2;
  b2 := b;
end;

method Utils.SwapObj(var o1, o2: Object);
begin
  var o := o1;
  o1 := o2;
  o2 := o;
end;

method Utils.GCD(i1, i2: Integer): Integer;
begin
  if (i1 = 0) or (i2 = 0) then
    exit 0;
  i1 := Math.Abs(i1);
  i2 := Math.Abs(i2);
  while i1 <> i2 do
    if i1 > i2 then
      i1 := i1 - i2
    else
      i2 := i2 - i1;
  result := i1;
end;

method Utils.RoundUp(const f: Float): Integer;
begin
  result := Math.Round(Math.Ceiling(f));
end;

method Utils.LinMap(x: Float; iMin, iMax: Float; oMin, oMax: Float): Float;
begin
  var k := (oMax - oMin) / (iMax - iMin);
  var n := oMin - k * iMin;
  result := k * x + n;
end;

{$ENDREGION}

{$REGION STRINGS}

method Utils.Pos0(const sub, s: String): Integer;
begin
  result :=
    if String.IsNullOrEmpty(s) or String.IsNullOrEmpty(sub) then -1
    else s.IndexOf(sub);
end;

method Utils.CopyString(const s: String; const pos: Integer := 0): String;
begin
  result :=
    if s = nil then nil
    else s.SubString(pos);
end;

method Utils.CopyString(const s: String; const pos, len: Integer): String;
begin
  result :=
    if s = nil then nil
    else s.SubString(pos, len);
end;

method Utils.CopyFromTo(const s: String; f, t: Integer): String;
begin
  result := CopyString(s, f, t - f + 1);
end;

method Utils.StrEl(const s: String; i: Integer): Char;
begin
  result :=
    if 0 <= i < length(s) then s[i]
    else #0;
end;

method Utils.ChStr(len: Integer; ch: Char := ' '): String;
begin
  result := new String(ch, len);
end;

method Utils.ChString(len: Integer; const s: String := ' '): String;
begin
   var sb := new StringBuilder;
   for i := 1 to len do
     sb.Append(s);
   result := sb.ToString;
end;

method Utils.PadTo(const s: String; len: Integer; ch: Char := ' '): String;
begin
  var lLen := if String.IsNullOrEmpty(s) then 0 else s.Length;
  result :=
    if lLen < len then s + ChStr(len - lLen, ch)
    else if lLen > len then s.Substring(0, len)
    else s;
end;

method Utils.PadRight(const s: String; len: Integer): String;
begin
  result :=
    if s.Length >= len then s
    else ChStr(len - s.Length) + s;
end;

method Utils.RestOf(const s: String; pos: Integer): String;
begin
  result :=
    if String.IsNullOrEmpty(s) then ''
    else if 0 <= pos < length(s) then s.SubString(pos)
    else if pos < 0 then s
    else '';
end;

method Utils.LeftOf(const s, sub: String): String;
begin
  if String.IsNullOrEmpty(sub) then
    exit s;
  var p := s.IndexOf(sub);
  result := if p < 0 then s else s.SubString(0, p);
end;

method Utils.RightOf(const s, sub: String): String;
begin
  if String.IsNullOrEmpty(sub) then
    exit String.Empty;
  var p := s.IndexOf(sub);
  result := if p < 0 then s else s.SubString(p + length(sub));
end;

method Utils.ReplaceStr(const s, f, t: String): String;
begin
  result := s.Replace(f, t);
end;

method Utils.NextElem(var s: String): String;
begin
  if String.IsNullOrEmpty(s) then
    exit s;
  var p := s.IndexOf(' ');
  if p < 0 then
    begin
     result := s;
     s:='';
    end
  else
    begin
      result := s.SubString(0, p);
      s := RestOf(s, p + 1);
    end;
end;

method Utils.NextElem(var s: String; const sep: String): String;
begin
  if String.IsNullOrEmpty(s) or String.IsNullOrEmpty(sep) then
    exit NextElem(var s);
  var p := s.IndexOf(sep);
  if p < 0 then
    begin
      result := s;
      s := '';
    end
  else
    begin
      result := s.SubString(0,p);
      s := s.SubString(p + length(sep));
    end;
end;

method Utils.NextSubstr(var s: String; const sep: String := DefaultSeparator): String;
begin
  result := NextElem(var s, sep);
end;

method Utils.AppendStr(aString, aAppend, aSeparator: String): String;
begin
  result :=
    if String.IsNullOrEmpty(aString) then aAppend
    else aString + aSeparator + aAppend;
end;

method Utils.IdString(aString: String; aRep: Char := '_'): String;
begin
  if String.IsNullOrEmpty(aString) then
    exit aString;
  var lChars := aString.ToCharArray;
  for i := low(lChars) to high(lChars) do
    if not Char.IsLetterOrDigit(lChars[i]) then
      lChars[i] := aRep;
  result := CharsToString(lChars);
end;

method Utils.JsonString(aString: String): String;
begin
  var sb := new StringBuilder;
  for i := 0 to aString.Length - 1 do
    begin
      var c := aString[i];
      case c of
        '\': sb.Append("\\");
        '"': sb.Append('\"');
        #8: sb.Append('\b');
        #9: sb.Append('\t');
        #10: sb.Append('\n');
        #12: sb.Append('\f');
        #13: sb.Append('\r');
        #32..#33,
        #35..#91,
        #93..#127: sb.Append(c);
        else sb.Append('\u' + Convert.ToHexString(Int32(c), 4));
      end;
    end;
  result := sb.ToString;
end;

method Utils.HtmlString(aString: String): String;
begin
  if aString = nil then
    exit nil;
  var sb := new StringBuilder;
  for i := 0 to aString.Length - 1 do
    begin
      var c := aString[i];
      case c of
        '''': sb.Append("&apos;");
        '"': sb.Append('&quot;');
        '<': sb.Append('&lt;');
        '>': sb.Append('&gt;');
        else sb.Append(c);
      end;
    end;
  result := sb.ToString;
end;

method Utils.BreakToLines(aString: String): ImmutableList<String>;
const
  LineBreaks: array of Char = [#11, #12, #13, #$0085, #$2028, #$2020]; // VT, FF, CR, NEL, LS, PS
begin
  if aString = nil then
    exit nil;
  aString := aString.Replace(#13#10, #10);
  if aString.ContainsAny(LineBreaks) then
    for each lBrk in LineBreaks do
      aString := aString.Replace(lBrk, #10);
  result := aString.Split(#10);
end;

method Utils.BreakToWords(aString: String): ImmutableList<String>;
begin
  if aString = nil then
    exit nil;
  aString := aString.Replace(#13#10, #10);
  aString := aString.Replace(#10, ' ');
  for i := 0 to aString.Length - 1 do
    if (aString[i] <> ' ') and Char.IsWhiteSpace(aString[i]) then
      aString := aString.Replace(i, 1, ' ');
  result := aString.Split(' ');
end;

{$ENDREGION}

{$REGION FILE NAMES}

method Utils.FileExtension(aFileName: String): String;
begin
  result := Path.GetExtension(aFileName);
  if (result = '') and aFileName.EndsWith('.') then
    result := '.';
end;

{$ENDREGION}

{$REGION ARRAYS}

method Utils.NewIntArray(const aLen: Integer; const aInit: Integer := 0): IntArray;
begin
  result := new Integer[aLen];
  for i := low(result) to high(result) do
    result[i] := aInit;
end;

method Utils.CopyIntArray(const aArr: IntArray; aPos: Integer := 0; aLen: Integer := -1): IntArray;
begin
  if aArr = nil then
    exit nil;
  if aPos < 0 then
    aPos := 0;
  if aLen < 0 then
    aLen := length(aArr) - aPos;
  result := NewIntArray(aLen);
  var p := aPos;
  for i := low(result) to high(result) do
    begin
      if p > high(aArr) then
        exit;
      result[i] := aArr[p];
      inc(p);
    end;
end;

method Utils.IntArrayIndex(const aArr: IntArray; aInt: Integer): Integer;
begin
  result := -1;
  for i := low(aArr) to high(aArr) do
    if aArr[i] = aInt then
      exit i;
end;

method Utils.IntArrayContains(const aArr: IntArray; aInt: Integer): Boolean;
begin
  result := IntArrayIndex(aArr, aInt) >= 0;
end;

method Utils.IntArrayEq(aArr1, aArr2: IntArray): Boolean;
begin
  result := false;
  if length(aArr1) <> length(aArr2) then
    exit;
  for i := low(aArr1) to high(aArr1) do
    if aArr1[i] <> aArr2[i] then
      exit;
  result := true;
end;

method Utils.ConcatenateIntArrays(const aArr1, aArr2: IntArray): IntArray;
begin
  result := new Integer[length(aArr1) + length(aArr2)];
  var p := 0;
  for i := low(aArr1) to high(aArr1) do
    begin
      result[p] := aArr1[i];
      inc(p);
    end;
  for i := low(aArr2) to high(aArr2) do
    begin
      result[p] := aArr2[i];
      inc(p);
    end;
end;

method Utils.IntArrayInsert(const aArr: IntArray; aIdx: Integer; aVal: Integer := 0): IntArray;
begin
  if aIdx < low(aArr) then
    result := ConcatenateIntArrays([aVal], aArr)
  else if aIdx > high(aArr) then
    result := ConcatenateIntArrays(aArr, [aVal])
  else
    begin
      result := new Integer[length(aArr) + 1];
      for i := low(aArr) to aIdx - 1 do
        result[i] := aArr[i];
      result[aIdx] := aVal;
      for i := aIdx to high(aArr) do
        result[i + 1] := aArr[i];
    end;
end;

method Utils.IntArrayDelete(const aArr: IntArray; aIdx: Integer): IntArray;
begin
  if (length(aArr) = 0) or not (low(aArr) <= aIdx <= high(aArr)) then
    result := CopyIntArray(aArr)
  else
    begin
      result := NewIntArray(length(aArr) - 1);
      for i := low(result) to high(result) do
        result[i] :=
          if i < aIdx then aArr[i]
          else aArr[i + 1];
    end;
end;

method Utils.IntArrayMove(const aArr: IntArray; aFromIdx, aToIdx: Integer): IntArray;
begin
  result := CopyIntArray(aArr);
  if (aFromIdx = aToIdx) or not ((low(aArr) <= aFromIdx <= high(aArr)) and (low(aArr) <= aToIdx <= high(aArr))) then
    exit;
  var el := aArr[aFromIdx];
  if aFromIdx < aToIdx then
    for i := aFromIdx to aToIdx - 1 do
      result[i] := aArr[i + 1]
  else
    for i := aFromIdx downto aToIdx + 1 do
      result[i] := aArr[i - 1];
  result[aToIdx] := el;
end;

method Utils.IntArrayExchange(var aArr: IntArray; aFromIdx, aToIdx: Integer);
begin
  var t := aArr[aFromIdx];
  aArr[aFromIdx] := aArr[aToIdx];
  aArr[aToIdx] := t;
end;

method Utils.RangeArray(const aLen: Integer; aFrom: Integer; aStep: Integer := 1): IntArray;
begin
  result := new Integer[aLen];
  for i := low(result) to high(result) do
    begin
      result[i] := aFrom;
      aFrom := aFrom + aStep;
    end;
end;

method Utils.IntArraySubset(const aArr: IntArray; aIndexCondition: Predicate<Integer>): IntArray;
begin
  if aArr = nil then
    exit nil;
  var lCount := 0;
  for i := low(aArr) to high(aArr) do
    if aIndexCondition(i) then
      inc(lCount);
  result := NewIntArray(lCount);
  var x := 0;
  for i := low(aArr) to high(aArr) do
    if aIndexCondition(i) then
      begin
        result[x] := aArr[i];
        inc(x);
      end;
end;

method Utils.IntArraySubset(const aArr: IntArray; aIndices: IntArray): IntArray;
begin
  if aArr = nil then
    exit nil;
  result := NewIntArray(length(aIndices));
  for i := low(result) to high(result) do
    result[i] := aArr[aIndices[i]];
end;

method Utils.IntArraySubset(const aArr: IntArray; aSelect: BoolArray): IntArray;

  method Selected(x: Integer): Boolean;
  begin
    result :=
      if not (low(aSelect) <= x <= high(aSelect)) then false
      else aSelect[x];
  end;

begin
  if aArr = nil then
    exit nil;
  var lCount := 0;
  for i := low(aArr) to high(aArr) do
    if Selected(i) then
      inc(lCount);
  result := NewIntArray(lCount);
  var x := 0;
  for i := low(aArr) to high(aArr) do
    if Selected(i) then
      begin
        result[x] := aArr[i];
        inc(x);
      end;
end;

method Utils.NewFltArray(const aLen: Integer; const aInit: Float := 0.0): FltArray;
begin
  result := new Float[aLen];
  for i :=low(result) to high(result) do
    result[i] := aInit;
end;

method Utils.CopyFltArray(const aArr: FltArray; aPos: Integer := 0; aLen: Integer := -1): FltArray;
begin
  if aArr = nil then
    exit nil;
  if aPos < 0 then
    aPos := 0;
  if aLen < 0 then
    aLen := length(aArr) - aPos;
  result := NewFltArray(aLen);
  var p := aPos;
  for i := low(result) to high(result) do
    begin
      if p > high(aArr) then
        exit;
      result[i] := aArr[p];
      inc(p);
    end;
end;

method Utils.FltArrayEq(aArr1, aArr2: FltArray): Boolean;
begin
  result := false;
  if length(aArr1) <> length(aArr2) then
    exit;
  for i := low(aArr1) to high(aArr1) do
    if not Utils.FloatEq(aArr1[i], aArr2[i]) then
      exit;
  result := true;
end;

method Utils.FltArrayEq(aArr1, aArr2: FltArray; const eps: Float): Boolean;
begin
  result := false;
  if length(aArr1) <> length(aArr2) then
    exit;
  for i := low(aArr1) to high(aArr1) do
    if not Utils.FloatEq(aArr1[i], aArr2[i], eps) then
      exit;
  result := true;
end;

method Utils.FltArrayEqWithNaN(aArr1, aArr2: FltArray; const eps: Float): Boolean;
begin
  result := false;
  if length(aArr1) <> length(aArr2) then
    exit;
  for i := low(aArr1) to high(aArr1) do
    if not Utils.FloatEqWithNaN(aArr1[i], aArr2[i], eps) then
      exit;
  result := true;
end;

method Utils.ConcatenateFltArrays(const aArr1, aArr2: FltArray): FltArray;
begin
  result := new Float[length(aArr1) + length(aArr2)];
  var p := 0;
  for i := low(aArr1) to high(aArr1) do
    begin
      result[p] := aArr1[i];
      inc(p);
    end;
  for i := low(aArr2) to high(aArr2) do
    begin
      result[p] := aArr2[i];
      inc(p);
    end;
end;

method Utils.FltArrayInsert(const aArr: FltArray; aIdx: Integer; aVal: Float := 0.0): FltArray;
begin
  if aIdx < low(aArr) then
    result := ConcatenateFltArrays([aVal], aArr)
  else if aIdx > high(aArr) then
    result := ConcatenateFltArrays(aArr, [aVal])
  else
    begin
      result := new Float[length(aArr) + 1];
      for i := low(aArr) to aIdx - 1 do
        result[i] := aArr[i];
      result[aIdx] := aVal;
      for i := aIdx to high(aArr) do
        result[i + 1] := aArr[i];
    end;
end;

method Utils.FltArrayDelete(const aArr: FltArray; aIdx: Integer): FltArray;
begin
  if (length(aArr) = 0) or not (low(aArr) <= aIdx <= high(aArr)) then
    result := CopyFltArray(aArr)
  else
    begin
      result := NewFltArray(length(aArr) - 1);
      for i := low(result) to high(result) do
        result[i] :=
          if i < aIdx then aArr[i]
          else aArr[i + 1];
    end;
end;

method Utils.FltArrayMove(const aArr: FltArray; aFromIdx, aToIdx: Integer): FltArray;
begin
  result := CopyFltArray(aArr);
  if (aFromIdx = aToIdx) or not ((low(aArr) <= aFromIdx <= high(aArr)) and (low(aArr) <= aToIdx <= high(aArr))) then
    exit;
  var el := aArr[aFromIdx];
  if aFromIdx < aToIdx then
    for i := aFromIdx to aToIdx - 1 do
      result[i] := aArr[i + 1]
  else
    for i := aFromIdx downto aToIdx + 1 do
      result[i] := aArr[i - 1];
  result[aToIdx] := el;
end;

method Utils.FltArrayExchange(var aArr: FltArray; aFromIdx, aToIdx: Integer);
begin
  var t := aArr[aFromIdx];
  aArr[aFromIdx] := aArr[aToIdx];
  aArr[aToIdx] := t;
end;

method Utils.IntToFltArray(aArr: IntArray): FltArray;
begin
  if aArr = nil then
    exit nil;
  result := NewFltArray(length(aArr));
  for i := low(aArr) to high(aArr) do
    result[i] := aArr[i];
end;

method Utils.FltToIntArray(aArr: FltArray): IntArray;
begin
  if aArr = nil then
    exit nil;
  result := NewIntArray(length(aArr));
  for i := low(aArr) to high(aArr) do
    result[i] := Math.Round(aArr[i]);
end;

method Utils.RemoveNaN(aArr: FltArray): FltArray;
begin
  if aArr = nil then
    exit nil;
  var lLen := 0;
  for i := low(aArr) to high(aArr) do
    if not Consts.IsNaN(aArr[i]) then
      inc(lLen);
  result := new Float[lLen];
  var x := 0;
  for i := low(aArr) to high(aArr) do
    if not Consts.IsNaN(aArr[i]) then
      begin
        result[x] := aArr[i];
        inc(x);
      end;
end;

method Utils.NewBoolArray(const aLen: Integer; const aInit: Boolean := false): BoolArray;
begin
  result := new Boolean[aLen];
  for i := low(result) to high(result) do
    result[i] := aInit;
end;

method Utils.CopyBoolArray(const aArr: BoolArray; aPos: Integer := 0; aLen: Integer := -1): BoolArray;
begin
  if aArr = nil then
    exit nil;
  if aPos < 0 then
    aPos := 0;
  if aLen < 0 then
    aLen := length(aArr) - aPos;
  result := NewBoolArray(aLen);
  var p := aPos;
  for i := low(result) to high(result) do
    begin
      if p > high(aArr) then
        exit;
      result[i] := aArr[p];
      inc(p);
    end;
end;

method Utils.NewIntMatrix(const aLen1, aLen2: Integer; const aInit: Integer := 0): IntMatrix;
begin
  result := new IntArray[aLen1];
  for i := low(result) to high(result) do
    result[i] := NewIntArray(aLen2, aInit);
end;

method Utils.NewFltMatrix(const aLen1, aLen2: Integer; const aInit: Float := 0.0): FltMatrix;
begin
  result := new FltArray[aLen1];
  for i := low(result) to high(result) do
    result[i] := NewFltArray(aLen2, aInit);
end;

{$ENDREGION}

{$REGION CONVERSIONS}

method Utils.IntToStr(i: Integer): String;
begin
  result := Convert.ToString(i);
end;

method Utils.NullableIntToStr(i: nullable Integer): String;
begin
  result :=
    if i = nil then 'NIL'
    else IntToStr(i);
end;

method Utils.StrToInt(const s: String): Integer;
begin
  result := Convert.ToInt64(s);
end;

method Utils.FloatToStr(f: Float): String;
begin
  result := Convert.ToString(f, -1, Locale.Current);
end;

method Utils.FltToStr(f: Float; aInvariant: Boolean := true): String;
begin
  var lLocale := if aInvariant then Locale.Invariant else Locale.Current;
  result := Convert.ToString(f, -1, lLocale);
end;

method Utils.FltToStr(f: Float; dec: Integer; aInvariant: Boolean := true): String;
begin
  var lLocale := if aInvariant then Locale.Invariant else Locale.Current;
  result := Convert.ToString(f, dec, lLocale);
end;

method Utils.FltToStrInvariant(f: Float; dec: Integer := -1): String;
begin
  result := FltToStr(f, dec, true);
end;

method Utils.FltToStrLocal(f: Float; dec: Integer := -1): String;
begin
  result := FltToStr(f, dec, false);
end;

method Utils.StrToFloat(const s: String): Float;
begin
  result := Convert.ToDouble(s, Locale.Current);
end;

method Utils.StrToFlt(const s: String; aInvariant: Boolean := true): Float;
begin
  var lLocale := if aInvariant then Locale.Invariant else Locale.Current;
  result := Convert.ToDouble(s, lLocale);
end;

method Utils.BooleanToStr(b: Boolean): String;
begin
  result := if b then 'True' else 'False';
end;

method Utils.StrToBoolean(const s: String): Boolean;
begin
  var z := s.ToUpper;
  if (z = '0') or (z = 'F') or (z = 'FALSE') or (z = 'NO') then
    result:=false
  else if (z = '1') or (z = 'T') or (z = 'TRUE') or (z = 'YES') then
    result:=true
  else
    raise new EConvertError(String.Format(Utils.SInvalidBoolean, [s]));
end;

method Utils.CharsToString(aChars: array of Char): String;
begin
  result := new String(aChars);
end;

method Utils.StrToLines(const s: String): List<String>;
begin
  result := s.Split(#10).Select(z -> z.Trim([#13])).ToList;
end;

method Utils.ExchangeList(aList: List<String>; aIdx1, aIdx2: Integer);
begin
  var lTmp := aList[aIdx1];
  aList[aIdx1] := aList[aIdx2];
  aList[aIdx2] := lTmp;
end;

method Utils.ExchangeList<T>(aList: List<T>; aIdx1, aIdx2: Integer);
begin
  var lTmp := aList[aIdx1];
  aList[aIdx1] := aList[aIdx2];
  aList[aIdx2] := lTmp;
end;

method Utils.MoveList(aList: List<String>; aFrom, aTo: Integer);
begin
  var lTmp := aList[aFrom];
  aList.RemoveAt(aFrom);
  aList.Insert(aTo, lTmp);
end;

method Utils.MoveList<T>(aList: List<T>; aFrom, aTo: Integer);
begin
  var lTmp := aList[aFrom];
  aList.RemoveAt(aFrom);
  aList.Insert(aTo, lTmp);
end;

method Utils.IntArrayToStr(const aArray: IntArray): String;
begin
  var sb := new StringBuilder;
  for i := low(aArray) to high(aArray) do
    begin
      sb.Append(IntToStr(aArray[i]));
      if i < high(aArray) then
        sb.Append(DefaultSeparator);
    end;
  result := sb.ToString;
end;

method Utils.StrToIntArray(const s: String): IntArray;
begin
  if String.IsNullOrEmpty(s) then
    exit [];
  var str := s.Split(DefaultSeparator);
  result := NewIntArray(str.Count);
  for i := low(result) to high(result) do
    result[i] := StrToInt(str[i]);
end;

method Utils.FltArrayToStr(const aArray: FltArray; aInvariant: Boolean := true): String;
begin
  var sb := new StringBuilder;
  for i := low(aArray) to high(aArray) do
    begin
      sb.Append(FltToStr(aArray[i], aInvariant));
      if i < high(aArray) then
        sb.Append(DefaultSeparator);
    end;
  result := sb.ToString;
end;

method Utils.FltArrayToStr(const aArray: FltArray; dec: Integer; aInvariant: Boolean := true): String;
begin
  var sb := new StringBuilder;
  for i := low(aArray) to high(aArray) do
    begin
      sb.Append(FltToStr(aArray[i], dec, aInvariant));
      if i < high(aArray) then
        sb.Append(DefaultSeparator);
    end;
  result := sb.ToString;
end;

method Utils.StrToFltArray(const s: String; aInvariant: Boolean := true): FltArray;
begin
  if String.IsNullOrEmpty(s) then
    exit [];
  var str := s.Split(DefaultSeparator);
  result := NewFltArray(str.Count);
  for i := low(result) to high(result) do
    result[i] := StrToFlt(str[i], aInvariant);
end;

{$ENDREGION}

{$REGION COMPARISON}

method Utils.Compare(i1, i2: Integer): Integer;
begin
  result :=
    if i1 < i2 then -1
    else if i1 > i2 then 1
    else 0;
end;

method Utils.Compare(f1, f2: Float): Integer;
begin
  result :=
    if f1 < f2 then -1
    else if f1 > f2 then 1
    else 0;
end;

method Utils.Compare(const ia1, ia2: IntArray): Integer;
begin
  result := 0;
  for i := 0 to Math.Max(high(ia1), high(ia2)) do
    if i > high(ia1) then
      exit -1
    else if i > high(ia2) then
      exit 1
    else
      begin
        result := Compare(ia1[i], ia2[i]);
        if result <> 0 then
          exit;
      end;
end;

method Utils.Compare(const fa1, fa2: FltArray): Integer;
begin
  result := 0;
  for i := 0 to Math.Max(high(fa1), high(fa2)) do
    if i > high(fa1) then
      exit -1
    else if i > high(fa2) then
      exit 1
    else
      begin
        result := Compare(fa1[i], fa2[i]);
        if result <> 0 then
          exit;
      end;
end;

method Utils.HammingDistance(const ia1, ia2: IntArray): Integer;
begin
  result := 0;
  for i := 0 to Math.Max(high(ia1), high(ia2)) do
    if ia1[i] <> ia2[i] then
      inc(result);
end;

method Utils.ManhattanDistance(const ia1, ia2: IntArray): Integer;
begin
  result := 0;
  for i := 0 to Math.Max(high(ia1), high(ia2)) do
    result := result + Math.Abs(ia2[i] - ia1[i]);
end;

method Utils.EuclideanDistance(const ia1, ia2: IntArray): Float;
begin
  result := 0.0;
  for i := 0 to Math.Max(high(ia1), high(ia2)) do
    result := result + Math.Sqrt(ia2[i] - ia1[i]);
end;

{$ENDREGION}

{$REGION CORRELATIONS}

method Utils.Correlation(ia1, ia2: IntArray): Float;
begin
  var lAvg1 := Values.Sum(ia1) / Float(length(ia1));
  var lAvg2 := Values.Sum(ia2) / Float(length(ia2));
  var lSum := 0.0;
  var lSq1 := 0.0;
  var lSq2 := 0.0;
  for i := low(ia1) to high(ia1) do
    for j := low(ia2) to high(ia2) do
      begin
        lSum := lSum + (ia1[i] - lAvg1) * (ia2[i] - lAvg2);
        lSq1 := lSq1 + (ia1[i] - lAvg1) * (ia1[i] - lAvg1);
        lSq2 := lSq2 + (ia2[i] - lAvg2) * (ia2[i] - lAvg2);
      end;
  result := lSum / Math.Sqrt(lSq1 * lSq2);
end;

method Utils.Correlation(fa1, fa2: FltArray): Float;
begin
  var lAvg1 := Values.Sum(fa1) / Float(length(fa1));
  var lAvg2 := Values.Sum(fa2) / Float(length(fa2));
  var lSum := 0.0;
  var lSq1 := 0.0;
  var lSq2 := 0.0;
  for i := low(fa1) to high(fa1) do
    for j := low(fa2) to high(fa2) do
      begin
        lSum := lSum + (fa1[i] - lAvg1) * (fa2[i] - lAvg2);
        lSq1 := lSq1 + (fa1[i] - lAvg1) * (fa1[i] - lAvg1);
        lSq2 := lSq2 + (fa2[i] - lAvg2) * (fa2[i] - lAvg2);
      end;
  result := lSum / Math.Sqrt(lSq1 * lSq2);
end;

{$ENDREGION}

{$REGION INDEX}

method Utils.InsertIndex(aIdx, aIns: Integer): Integer;
begin
  result := if aIdx >= aIns then aIdx + 1 else aIdx;
end;

method Utils.DeleteIndex(aIdx, aDel: Integer): Integer;
begin
  result := if aIdx > aDel then aIdx - 1 else aIdx;
end;

method Utils.DuplicateIndex(aIdx, aDup: Integer): Integer;
begin
  result := if aIdx > aDup then aIdx + 1 else aIdx;
end;

method Utils.MoveIndex(aIdx, aFrom, aTo: Integer): Integer;
begin
  if aIdx = aFrom then
    exit aTo
  else
    begin
      result := aIdx;
      if (aFrom < aTo) and (aFrom <= aIdx <= aTo) then
        dec(result)
      else if (aFrom > aTo) and (aTo <= aIdx <= aFrom) then
        inc(result);
    end;
end;

method Utils.ExchangeIndex(aIdx, aIdx1, aIdx2: Integer): Integer;
begin
  result :=
    if aIdx = aIdx1 then aIdx2
    else if aIdx = aIdx2 then aIdx1
    else aIdx;
end;

method Utils.MergeIndex(aIdx, aFrom, aTo: Integer): Integer;
begin
  result :=
    if aFrom = aTo then aIdx
    else if aIdx = aFrom then
      if aFrom < aTo then aTo - 1
      else aTo
    else DeleteIndex(aIdx, aFrom);
end;

method Utils.ReverseIndex(aIdx, aLow, aHigh: Integer): Integer;
begin
  result := aLow + aHigh - aIdx;
end;

method Utils.ReverseFloat(aFlt, aLow, aHigh: Float): Float;
begin
  result := aHigh - (aFlt - aLow);
end;

{$ENDREGION}

{$REGION DATE TIME}

method Utils.ISODateTimeStr(aDateTime: DateTime): String;
begin
  result := aDateTime.ToString("yyyy-MM-dd+HH:mm:ss", TimeZone.Local).Replace("+", "T");
end;

{$ENDREGION}

{$REGION FLAGS}

method Utils.AddFlag(aState, aFlag: Integer): Integer;
begin
  result := aState or aFlag;
end;

method Utils.RemoveFlag(aState, aFlag: Integer): Integer;
begin
  result := aState and not aFlag;
end;

method Utils.IncludesFlag(aState, aFlag: Integer): Boolean;
begin
  result := (aState and aFlag) <> 0;
end;

{$ENDREGION}

{$REGION IMPURITY FUNCTIONS}

method Utils.Gini(aProb: FltArray): Float;
begin
  if length(aProb) = 0 then
    exit 0.0;
  result := 1.0;
  for i := low(aProb) to high(aProb) do
    result := result - aProb[i] * aProb[i];
end;

method Utils.Entropy(aProb: FltArray): Float;
begin
  result := 0.0;
  for i := low(aProb) to high(aProb) do
    begin
      var p := aProb[i];
      if p > 0.0 then
       result := result - p * Math.Log(p) / Math.Log(2.0);
    end;
end;

{$ENDREGION}

{$ENDREGION}

{$REGION CompositeElement}

constructor CompositeElement(aString: String := ''; aTag: Integer := 0);
begin
  Str := if aString = nil then '' else aString;
  Tag := aTag;
end;

{$ENDREGION}

{$REGION CompositeString}

constructor CompositeString;
begin
  inherited constructor;
end;

method CompositeString.GetAsString: String;
begin
  var sb := new StringBuilder;
  for i := 0 to fElements.Count - 1 do
    sb.Append(ElementAsString(i));
  result := sb.ToString;
end;

method CompositeString.GetCount: Integer;
begin
  result := fElements.Count;
end;

method CompositeString.GetElement(aIdx: Integer): CompositeElement;
begin
  result := fElements[aIdx];
end;

method CompositeString.GetStr(aIdx: Integer): String;
begin
  result := fElements[aIdx].Str;
end;

method CompositeString.GetTag(aIdx: Integer): Integer;
begin
  result := fElements[aIdx].Tag;
end;

method CompositeString.Copy: not nullable CompositeString;
begin
  result := new CompositeString;
  result.Assign(self);
end;

method CompositeString.Clear;
begin
  fElements.RemoveAll;
end;

method CompositeString.Append(aCStr: CompositeString);
begin
  if aCStr:fElements = nil then
    exit;
  for i := 0 to aCStr.fElements.Count - 1 do
    begin
      var lElement := aCStr.fElements[i];
      &Add(lElement.Str, lElement.Tag);
    end;
end;

method CompositeString.Assign(aCStr: CompositeString);
begin
  Clear;
  Append(aCStr);
end;

method CompositeString.&Add(aString: String; aTag: Integer := 0);
begin
  fElements.Add(new CompositeElement(aString, aTag));
end;

method CompositeString.ElementAsString(aElement: CompositeElement): String;
begin
  result := aElement.Str;
end;

method CompositeString.ElementAsString(aIdx: Integer): String;
begin
  result := ElementAsString(fElements[aIdx]);
end;

{$ENDREGION}

end.
