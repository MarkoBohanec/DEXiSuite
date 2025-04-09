// Values.pas is part of
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
// Values.pas implements low-level types and methods necessary for DEXiLibrary DexiValue classes.
// The main idea is to extend DEXi's qualitative values, which are internally represened by
// ordinal Integer values, to:
//
// - IntInterval: intervals of ordinals
// - IntOffset: values combining an ordinal value with a Float offset, e.g. 2 + 0.3
// - Float: floating-point values (to be used with continuous basic attributes)
// - FltInterval: intervals of Float
// - IntSet: sets of ordinals
// - Distribution: distributions (e.g., probabilistic or fuzzy) of ordinal values
//
// To this end, Values.pas defines the corresponding data representations together with
// a static class Values that implements low-level non-object-oriented methods
// for handling those representations.
// ----------

namespace DexiUtils;

interface

uses
  RemObjects.Elements.RTL;

type
  OffsetRounding = public enum (Down, Up);

type
  /// <summary>
  /// An Integer interval.
  /// </summary>
  IntInterval = public record
    Low, High: Integer;
  end;

  /// <summary>
  /// An Integer offset value, interpreted as Int (qualitative value) + Off (numeric value).
  /// Normally, Off is expected to be in the range between -0.5 and +0.5.
  /// </summary>
  IntOffset = public record
    Int: Integer;
    Off: Float;
  end;

  /// <summary>
  /// A Float interval.
  /// </summary>
  FltInterval = public record
    Low, High: Float;
  end;

  /// <summary>
  /// A set of Integer values. Represented by an IntArray, which is assumed to be sorted at all times.
  /// </summary>
  IntSet = public IntArray;

  /// <summary>
  /// Types of normalizations applied to value representations.
  /// Looking at values as distributions, membership values are normalized so that:
  /// - normNone and normOrd: no requirements
  /// - normSet: only 0.0 or 1.0 are allowed as membership values
  /// - normProb: the sum of membership values must be equal to 1.0
  /// - normFuzzy: the maximum of membership values must be equal to 1.0
  /// </summary>
  Normalization = public enum (normNone, normOrd, normSet, normProb, normFuzzy);

  /// <summary>
  /// Possible outcomes of preferential comparisons.
  /// 'No' indicates that compared items are incomparable.
  /// </summary>
  PrefCompare = public (No, Equal, Lower, Greater);

type
  /// <summary>
  /// A record representing a value distribution.
  /// For each Integer index x, Distribution defines its numeric membership value m(x).
  /// 'Base' indicates the index of the first element.
  /// 'Distr' contains membership values of successive elements, so that
  /// Distr[0] = m(Base), Distr[1] = m(Base + 1), etc.
  /// m(x) is assumed to be 0.0 for all x outside of the defined range of 'Distr'.
  /// </summary>
  Distribution = public record
    Base: Integer;
    Distr: FltArray;
  end;

type
  /// <summary>
  /// Values is a static class that implements methods for handling value data representations
  /// in a low-level and non-object-oriented way. In general, it provides methods for
  /// creating, normalizing, converting, interpreting, comparing and bounding these representations,
  /// as well as carrying out typical editing operations:
  /// adding, inserting, deleting, duplicating, copying, moving and reversing individual elements.
  /// </summary>
  Values = public static partial class
  private
    const SCvtEmptySet = 'Illegal operation "{0}" on an empty set';
  public
    method IntToPrefCompare(aCompare: Integer): PrefCompare;
    method ReversePrefCompare(aCompare: PrefCompare): PrefCompare;
    method PrefCompareUpdate(aOldCompare, aNewCompare: PrefCompare): PrefCompare;
    method PrefCompareUpdate(aOldCompare: PrefCompare; aNewCompare: Integer): PrefCompare;
    method Sum(const aArr: IntArray): Integer;
    method Sum(const aArr: FltArray): Float;
    method MinValue(const aArr: FltArray): Float;
    method MaxValue(const aArr: FltArray): Float;
    method MinValue(const aArr: IntArray): Integer;
    method MaxValue(const aArr: IntArray): Integer;
    method NormSum(var aArr: FltArray; aNorm: Float := 100.0);
    method NormMax(var aArr: FltArray; aNorm: Float := 100.0);
    method NormSum(aArr: FltArray; aNorm: Float := 100.0): FltArray;
    method NormMax(aArr: FltArray; aNorm: Float := 100.0): FltArray;
    method IntSingle(aFlt: Float): Integer;
    method IntSingle(const aIntInt: IntInterval): Integer;
    method IntSingle(const aFltInt: FltInterval): Integer;
    method IntSingle(const aSet: IntSet): Integer;
    method IntSingle(const aDistr: Distribution): Integer;
    method IntoBounds(aInt: Integer; aLow, aHigh: Integer): Integer;

    method IntInt(const aLow, aHigh: Integer): IntInterval;
    method IntInt(const aLH: Integer): IntInterval;
    method IntInt(const aSet: IntSet): IntInterval;
    method IntInt(const aDistr: Distribution): IntInterval;
    method IntInt(const aFltInt: FltInterval): IntInterval;
    method IntIntEq(const aIntInt1, aIntInt2: IntInterval): Boolean;
    method IntIntInsertValue(const aIntInt: IntInterval; aVal: Integer): IntInterval;
    method IntIntDeleteValue(const aIntInt: IntInterval; aVal: Integer): IntInterval;
    method IntIntDuplicateValue(const aIntInt: IntInterval; aVal: Integer): IntInterval;
    method IntoBounds(aIntInt: IntInterval; aLow, aHigh: Integer): IntInterval;
    method IntIntToStr(const aIntInt: IntInterval): String;
    method StrToIntInt(const s: String): IntInterval;

    method IntOff(const aInt: Integer; const aOff: Float): IntOffset;
    method IntOff(const aInt: Integer): IntOffset;
    method IntOff(const aFlt: Float): IntOffset;
    method IntOff(const aFlt: Float; aRound: OffsetRounding): IntOffset;
    method IntOffEq(aOff1, aOff2: IntOffset): Boolean;
    method IntOffToStr(const aOff: IntOffset; aInvariant: Boolean := true): String;
    method StrToIntOff(const s: String; aInvariant: Boolean := true): IntOffset;

    method FltSingle(const aFltInt: FltInterval): Float;
    method FltSingle(const aOff: IntOffset): Float;
    method IntoBounds(aFlt: Float; aLow, aHigh: Float): Float;

    method FltInt(const aLow, aHigh: Float): FltInterval;
    method FltInt(const aLH: Float): FltInterval;
    method FltInt(const aIntInt: IntInterval): FltInterval;
    method FltIntEq(aFltInt1, aFltInt2: FltInterval): Boolean;
    method IntoBounds(aFltInt: FltInterval; aLow, aHigh: Float): FltInterval;
    method FltIntToStr(const aFltInt: FltInterval; aInvariant: Boolean := true; aDecimals: Integer = -1): String;
    method StrToFltInt(const s: String; aInvariant: Boolean := true): FltInterval;

    method EmptySet: IntSet;
    method IntSet(const aInt: Integer): IntSet;
    method IntSetArray(const aArray: IntArray): IntSet;
    method IntSet(const aFrom, aTo: Integer): IntSet;
    method IntSet(const aIntInt: IntInterval): IntSet;
    method IntSet(const aSet: IntSet): IntSet;
    method IntSet(const aDistr: Distribution): IntSet;
    method IntSetMembers(const aDistr: Distribution): FltArray;
    method IntSetEmpty(const aSet: IntSet): Boolean;
    method IntSetNormalized(const aSet: IntSet): Boolean;
    method IntSetEq(aSet1, aSet2: IntSet): Boolean;
    method IntSetFind(const aSet: IntSet; aMember: Integer): Integer;
    method IntSetMember(const aSet: IntSet; aMember: Integer): Boolean;
    method IntSetInclude(var aSet: IntSet; aInt: Integer);
    method IntSetInclude(var aSet: IntSet; const aIncl: IntSet);
    method IntSetExclude(var aSet: IntSet; aInt: Integer);
    method IntSetExclude(var aSet: IntSet; const aExcl: IntSet);
    method IntSetIntersection(aSet1, aSet2: IntSet): IntSet;
    method IntSetUnion(aSet1, aSet2: IntSet): IntSet;
    method IntSetLow(const aSet: IntSet): Integer;
    method IntSetMedium(const aSet: IntSet): Float;
    method IntSetHigh(const aSet: IntSet): Integer;
    method IntSetInsertValue(const aSet: IntSet; aVal: Integer): IntSet;
    method IntSetDeleteValue(const aSet: IntSet; aVal: Integer): IntSet;
    method IntSetDuplicateValue(const aSet: IntSet; aVal: Integer): IntSet;
    method IntSetMoveValue(var aSet: IntSet; aFrom, aTo: Integer);
    method IntSetExchangeValues(var aSet: IntSet; aIdx1, aIdx2: Integer);
    method IntoBounds(const aSet: IntSet; aLow, aHigh: Integer): IntSet;
    method IntSetToStr(const aSet: IntSet): String;
    method StrToIntSet(s: String): IntSet;

    method EmptyDistr: Distribution;
    method Distr(const aBase: Integer; aDistr: FltArray): Distribution;
    method Distr(const aBase, aLen: Integer): Distribution;
    method Distr(const aInt: Integer): Distribution;
    method DistrFromTo(const aFrom, aTo: Integer): Distribution;
    method Distr(const aIntInt: IntInterval): Distribution;
    method Distr(const aSet: IntSet): Distribution;
    method Distr(const aDistr: Distribution): Distribution;
    method Distr(const aBase, aLen: Integer; const aInt: Integer): Distribution;
    method Distr(const aBase, aLen: Integer; const aFrom, aTo: Integer): Distribution;
    method DistrFromIntInt(const aBase, aLen: Integer; const aIntInt: IntInterval): Distribution;
    method Distr(const aBase, aLen: Integer; const aSet: IntSet): Distribution;
    method Distr(const aBase, aLen: Integer; const aDistr: Distribution): Distribution;
    method DistrEmpty(const aDistr: Distribution): Boolean;
    method DistrEq(aDistr1, aDistr2: Distribution): Boolean;
    method DistrEq(aDistr1, aDistr2: Distribution; eps: Float): Boolean;
    method DistrCopy(const aDistr: Distribution): Distribution;
    method DistrClear(var aDistr: Distribution);
    method DistrClean(var aDistr: Distribution);
    method DistrCompact(const aDistr: Distribution): Distribution;
    method DistrLength(const aDistr: Distribution): Integer;
    method DistrCount(const aDistr: Distribution): Integer;
    method DistrLowIndex(const aDistr: Distribution): Integer;
    method DistrHighIndex(const aDistr: Distribution): Integer;
    method DistrExpand(var aDistr: Distribution; aNewIdx: Integer);
    method SetDistribution(var aDistr: Distribution; aIdx: Integer; aValue: Float; aExpand: Boolean := false);
    method GetDistribution(const aDistr: Distribution; aIdx: Integer): Float;
    method DistrMin(const aDistr: Distribution): Float;
    method DistrMax(const aDistr: Distribution): Float;
    method DistrSum(const aDistr: Distribution): Float;
    method DistrLow(const aDistr: Distribution): Integer;
    method DistrMedium(const aDistr: Distribution): Float;
    method DistrHigh(const aDistr: Distribution): Integer;
    method DistrMul(var aDistr: Distribution; aMul: Float);
    method DistrDiv(var aDistr: Distribution; aDiv: Float);
    method DistrInsertValue(const aDistr: Distribution; aVal: Integer): Distribution;
    method DistrDeleteValue(const aDistr: Distribution; aVal: Integer): Distribution;
    method DistrDuplicateValue(const aDistr: Distribution; aVal: Integer): Distribution;
    method DistrMergeValue(const aDistr: Distribution; aFrom, aTo: Integer; aNorm: Normalization := Normalization.normNone): Distribution;
    method DistrMoveValue(const aDistr: Distribution; aFrom, aTo: Integer): Distribution;
    method DistrReverse(const aDistr: Distribution; aLow, aHigh: Integer): Distribution;
    method IntoBounds(const aDistr: Distribution; aLow, aHigh: Integer): Distribution;
    method DistrToStr(const aDistr: Distribution; aInvariant: Boolean := true; aDecimals: Integer = -1): String;
    method StrToDistr(s: String; aInvariant: Boolean := true): Distribution;

    method NormIntInt(var aLow: Integer; var aHigh: Integer);
    method NormIntInt(var aIntInt: IntInterval);
    method NormIntOff(var aOff: IntOffset);
    method NormFltInt(var aFltInt: FltInterval);
    method NormIntSet(var aSet: IntSet);
    method NormDistr(var aDistr: Distribution; aNorm: Normalization := Normalization.normNone);

    method Normed(const aIntInt: IntInterval): IntInterval;
    method Normed(const aFltInt: FltInterval): FltInterval;
    method Normed(const aOff: IntOffset):  IntOffset;
    method Normed(const aSet: IntSet): IntSet;
    method Normed(const aDistr: Distribution; aNorm: Normalization := Normalization.normNone): Distribution;

    method IsIntSingle(const aIntInt: IntInterval): Boolean;
    method IsIntSingle(const aSet: IntSet): Boolean;
    method IsIntSingle(const aDistr: Distribution): Boolean;

    method IsIntInt(const aSet: IntSet): Boolean;
    method IsIntInt(const aDistr: Distribution): Boolean;

    method IsIntSet(const aDistr: Distribution): Boolean;

    method IsFltSingle(const aFltInt: FltInterval): Boolean;

    method CompareIntInterval(L1, H1, L2, H2: Integer): PrefCompare;
    method CompareIntInterval(aIntInt1, aIntInt2: IntInterval): PrefCompare;
    method CompareIntIntervalStrict(aIntInt1, aIntInt2: IntInterval): PrefCompare;

    method CompareFltInterval(L1, H1, L2, H2: Float): PrefCompare;
    method CompareFltInterval(aFltFlt1, aFltFlt2: FltInterval): PrefCompare;
    method CompareFltIntervalStrict(aFltFlt1, aFltFlt2: FltInterval): PrefCompare;

    method CompareIntSet(aSet1, aSet2: IntSet): PrefCompare;
    method CompareIntSetStrict(aSet1, aSet2: IntSet): PrefCompare;

    method CompareDistr(aDistr1, aDistr2: Distribution): PrefCompare;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method Values.IntToPrefCompare(aCompare: Integer): PrefCompare;
begin
  result :=
    if aCompare < 0 then PrefCompare.Lower
    else if aCompare > 0 then PrefCompare.Greater
    else PrefCompare.Equal;
end;

method Values.ReversePrefCompare(aCompare: PrefCompare): PrefCompare;
begin
  result :=
    case aCompare of
      PrefCompare.Lower: PrefCompare.Greater;
      PrefCompare.Greater: PrefCompare.Lower;
      else aCompare;
    end;
end;

method Values.PrefCompareUpdate(aOldCompare, aNewCompare: PrefCompare): PrefCompare;
begin
  if aNewCompare = PrefCompare.No then
    exit PrefCompare.No;
  result := aOldCompare;
  case aOldCompare of
    PrefCompare.Equal:
      exit aNewCompare;
    PrefCompare.Lower:
      if aNewCompare = PrefCompare.Greater then
        exit PrefCompare.No;
    PrefCompare.Greater:
      if aNewCompare = PrefCompare.Lower then
        exit PrefCompare.No;
  end;
end;

method Values.PrefCompareUpdate(aOldCompare: PrefCompare; aNewCompare: Integer): PrefCompare;
begin
  result := PrefCompareUpdate(aOldCompare, IntToPrefCompare(aNewCompare));
end;

method Values.Sum(const aArr: IntArray): Integer;
begin
  result := 0;
  for i := low(aArr) to high(aArr) do
    result := result + aArr[i];
end;

method Values.Sum(const aArr: FltArray): Float;
begin
  result := 0.0;
  for i := low(aArr) to high(aArr) do
    result := result + aArr[i];
end;

method Values.MinValue(const aArr: IntArray): Integer;
begin
  result := high(Integer);
  for i := low(aArr) to high(aArr) do
    result := Math.Min(result, aArr[i]);
end;

method Values.MaxValue(const aArr: IntArray): Integer;
begin
  result := low(Integer);
  for i := low(aArr) to high(aArr) do
    result := Math.Max(result, aArr[i]);
end;

method Values.MinValue(const aArr: FltArray): Float;
begin
  result := Consts.PositiveInfinity;
  for i := low(aArr) to high(aArr) do
    result := Math.Min(result, aArr[i]);
end;

method Values.MaxValue(const aArr: FltArray): Float;
begin
  result := Consts.NegativeInfinity;
  for i := low(aArr) to high(aArr) do
    result := Math.Max(result, aArr[i]);
end;

method Values.NormSum(var aArr: FltArray; aNorm: Float=100.0);
begin
  var lSum := Sum(aArr);
  if not Utils.FloatEq(lSum, 0) then
    for i := low(aArr) to high(aArr) do
      aArr[i] := aArr[i] * aNorm / lSum;
end;

method Values.NormMax(var aArr: FltArray; aNorm: Float=100.0);
begin
  var lMax := MaxValue(aArr);
  if not Utils.FloatEq(lMax, 0) then
    for i := low(aArr) to high(aArr) do
      aArr[i] := aArr[i] * aNorm / lMax;
end;

method Values.NormSum(aArr: FltArray; aNorm: Float := 100.0): FltArray;
begin
  result := Utils.CopyFltArray(aArr);
  NormSum(var result, aNorm);
end;

method Values.NormMax(aArr: FltArray; aNorm: Float := 100.0): FltArray;
begin
  result := Utils.CopyFltArray(aArr);
  NormMax(var result, aNorm);
end;

{ IntSingle }

method Values.IntSingle(aFlt: Float): Integer;
begin
  result := Math.Round(aFlt);
end;

method Values.IntSingle(const aIntInt: IntInterval): Integer;
begin
  result := (aIntInt.Low + aIntInt.High) div 2;
end;

method Values.IntSingle(const aFltInt: FltInterval): Integer;
begin
  result := IntSingle((aFltInt.Low + aFltInt.High) / 2.0);
end;

method Values.IntSingle(const aSet: IntSet): Integer;
begin
  result := Math.Round(IntSetMedium(aSet));
end;

method Values.IntSingle(const aDistr: Distribution): Integer;
begin
  result := Math.Round(DistrMedium(aDistr));
end;

method Values.IntoBounds(aInt: Integer; aLow, aHigh: Integer): Integer;
begin
  var lInt := IntInt(aLow, aHigh);
  NormIntInt(var lInt);
  result :=
    if aInt < lInt.Low then lInt.Low
    else if aInt > lInt.High then lInt.High
    else aInt;
end;

{ IntInterval }

method Values.IntInt(const aLow, aHigh: Integer): IntInterval;
begin
  result.Low := aLow;
  result.High := aHigh;
end;

method Values.IntInt(const aLH: Integer): IntInterval;
begin
  result := IntInt(aLH, aLH);
end;

method Values.IntInt(const aSet: IntSet): IntInterval;
begin
  result := IntInt(MinValue(aSet), MaxValue(aSet));
end;

method Values.IntInt(const aDistr: Distribution): IntInterval;
begin
  result := IntInt(DistrLow(aDistr), DistrHigh(aDistr));
end;

method Values.IntInt(const aFltInt: FltInterval): IntInterval;
begin
  result.Low := Math.Round(aFltInt.Low);
  result.High := Math.Round(aFltInt.High);
end;

method Values.IntIntEq(const aIntInt1, aIntInt2: IntInterval): Boolean;
begin
  result :=
    ((aIntInt1.Low = aIntInt2.Low) and (aIntInt1.High = aIntInt2.High)) or
    ((aIntInt1.Low = aIntInt2.High) and (aIntInt1.High = aIntInt2.Low));
end;

method Values.IntIntInsertValue(const aIntInt: IntInterval; aVal: Integer): IntInterval;
begin
  var L := aIntInt.Low;
  if L >= aVal then inc(L);
  var H := aIntInt.High;
  if H >= aVal then inc(H);
  result := IntInt(L, H);
end;

method Values.IntIntDeleteValue(const aIntInt: IntInterval; aVal: Integer): IntInterval;
begin
  var L:=aIntInt.Low;
  if L >= aVal then dec(L);
  var H := aIntInt.High;
  if H >= aVal then dec(H);
  result := IntInt(L, H);
end;

method Values.IntIntDuplicateValue(const aIntInt: IntInterval; aVal: Integer): IntInterval;
begin
  result := IntIntInsertValue(aIntInt, aVal + 1);
  if result.Low = aVal + 1 then
    result.Low := aVal;
  if result.High = aVal then
    result.High := aVal + 1;
end;

method Values.IntoBounds(aIntInt: IntInterval; aLow, aHigh: Integer): IntInterval;
begin
  var lInt := IntInt(aLow, aHigh);
  NormIntInt(var lInt);
  var lLow := IntoBounds(aIntInt.Low, aLow, aHigh);
  var lHigh := IntoBounds(aIntInt.High, aLow, aHigh);
  result := IntInt(lLow, lHigh);
end;

method Values.IntIntToStr(const aIntInt: IntInterval): String;
begin
  if IsIntSingle(aIntInt) then
    result := Utils.IntToStr(aIntInt.Low)
  else
    result := Utils.IntToStr(aIntInt.Low) + ':' + Utils.IntToStr(aIntInt.High);
end;

method Values.StrToIntInt(const s: String): IntInterval;
begin
  result.Low := Utils.StrToInt(Utils.LeftOf(s, ':'));
  result.High := Utils.StrToInt(Utils.RightOf(s, ':'));
end;

{ IntOffset }

method Values.IntOff(const aInt: Integer; const aOff: Float): IntOffset;
begin
  result.Int := aInt;
  result.Off := aOff;
end;

method Values.IntOff(const aInt: Integer): IntOffset;
begin
  result := IntOff(aInt, 0.0);
end;

method Values.IntOff(const aFlt: Float): IntOffset;
begin
  result := IntOff(0, aFlt);
  NormIntOff(var result);
end;

method Values.IntOff(const aFlt: Float; aRound: OffsetRounding): IntOffset;
begin
  var lInt := Math.Round(aFlt);
  var lLow := Math.Round(aFlt - Utils.FloatEpsilon);
  var lHigh := Math.Round(aFlt + Utils.FloatEpsilon);
  if lLow <> lHigh then
    if aRound = OffsetRounding.Down then
      lInt := lLow
    else
      lInt := lHigh;
  result := IntOff(lInt, aFlt - lInt);
end;

method Values.IntOffEq(aOff1, aOff2: IntOffset): Boolean;
begin
  NormIntOff(var aOff1);
  NormIntOff(var aOff2);
  result := (aOff1.Int = aOff2.Int) and Utils.FloatEq(aOff1.Off, aOff2.Off);
end;

method Values.IntOffToStr(const aOff: IntOffset; aInvariant: Boolean := true): String;
begin
  result := Utils.IntToStr(aOff.Int);
  if not Utils.FloatEq(aOff.Off, 0.0) then
    if aOff.Off > 0.0 then
      result := result+ '+' + Utils.FltToStr(aOff.Off, aInvariant)
    else
      result := result + Utils.FltToStr(aOff.Off, aInvariant);
end;

method Values.StrToIntOff(const s: String; aInvariant: Boolean := true): IntOffset;
begin
  var lpos := length(s);
  for i := length(s) - 1 downto 0 do
    if s[i] in ['+', '-'] then
      begin
        lpos := i;
        break;
      end;
  var si := s.Substring(0, lpos).Trim;
  var sf := Utils.RestOf(s, lpos).Trim;
  if si='' then
    begin
      si := sf;
      sf := '';
    end;
  if si = '' then
    result.Int := 0
  else
    result.Int := Utils.StrToInt(si);
  if sf = '' then
    result.Off := 0.0
  else
    result.Off := Utils.StrToFlt(sf, aInvariant);
end;

{ FltSingle }

method Values.FltSingle(const aFltInt: FltInterval): Float;
begin
  result := (aFltInt.Low+aFltInt.High) / 2;
end;

method Values.FltSingle(const aOff: IntOffset): Float;
begin
  result := aOff.Int + aOff.Off;
end;

{ FltInterval }

method Values.FltInt(const aLow, aHigh: Float): FltInterval;
begin
  result.Low := aLow;
  result.High := aHigh;
end;

method Values.FltInt(const aLH: Float): FltInterval;
begin
  result := FltInt(aLH, aLH);
end;

method Values.FltInt(const aIntInt: IntInterval): FltInterval;
begin
  result.Low := aIntInt.Low;
  result.High := aIntInt.High;
end;

method Values.FltIntEq(aFltInt1, aFltInt2: FltInterval): Boolean;
begin
  result :=
    (Utils.FloatEq(aFltInt1.Low, aFltInt2.Low) and Utils.FloatEq(aFltInt1.High, aFltInt2.High)) or
    (Utils.FloatEq(aFltInt1.Low, aFltInt2.High) and Utils.FloatEq(aFltInt1.High, aFltInt2.Low));
end;

method Values.IntoBounds(aFltInt: FltInterval; aLow, aHigh: Float): FltInterval;
begin
  var lInt := FltInt(aLow, aHigh);
  NormFltInt(var lInt);
  var lLow := IntoBounds(aFltInt.Low, aLow, aHigh);
  var lHigh := IntoBounds(aFltInt.High, aLow, aHigh);
  result := FltInt(lLow, lHigh);
end;

method Values.FltIntToStr(const aFltInt: FltInterval; aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  if IsFltSingle(aFltInt) then
    result := Utils.FltToStr(aFltInt.Low, aDecimals, aInvariant)
  else
    result := Utils.FltToStr(aFltInt.Low, aInvariant) + ':' + Utils.FltToStr(aFltInt.High, aDecimals, aInvariant);
end;

method Values.StrToFltInt(const s: String; aInvariant: Boolean := true): FltInterval;
begin
  result.Low := Utils.StrToFlt(Utils.LeftOf(s, ':'), aInvariant);
  result.High := Utils.StrToFlt(Utils.RightOf(s, ':'), aInvariant);
end;

method Values.IntoBounds(aFlt: Float; aLow, aHigh: Float): Float;
begin
  var lInt := FltInt(aLow, aHigh);
  NormFltInt(var lInt);
  result :=
    if aFlt < lInt.Low then lInt.Low
    else if aFlt > lInt.High then lInt.High
    else aFlt;
end;

{ IntSet }

method Values.EmptySet: IntSet;
begin
  result := [];
end;

method Values.IntSet(const aInt: Integer): IntSet;
begin
  result := Utils.NewIntArray(1, aInt);
end;

method Values.IntSetArray(const aArray: IntArray): IntSet;
begin
  result := Normed(aArray);
end;

method Values.IntSet(const aFrom, aTo: Integer): IntSet;
begin
  result := Utils.NewIntArray(Math.Max(0, aTo - aFrom + 1));
  for i := aFrom to aTo do
    result[i - aFrom] := i;
end;

method Values.IntSet(const aIntInt: IntInterval): IntSet;
begin
  result := IntSet(aIntInt.Low, aIntInt.High);
end;

method Values.IntSet(const aSet: IntSet): IntSet;
begin
  result := Utils.CopyIntArray(aSet);
  NormIntSet(var result);
end;

method Values.IntSet(const aDistr: Distribution): IntSet;
begin
  result := Utils.NewIntArray(0);
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    begin
      var d := GetDistribution(aDistr, i);
      if d > 0.0 then
        IntSetInclude(var result, i);
    end;
end;

method Values.IntSetMembers(const aDistr: Distribution): FltArray;
begin
  var lCnt := 0;
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    begin
      var d := GetDistribution(aDistr, i);
      if d > 0.0 then
        inc(lCnt);
    end;
  result := Utils.NewFltArray(lCnt);
  var lPos := 0;
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    begin
      var d := GetDistribution(aDistr, i);
      if d > 0.0 then
        begin
          result[lPos] := d;
          inc(lPos);
        end;
    end;
end;

method Values.IntSetEmpty(const aSet: IntSet): Boolean;
begin
  result := length(aSet) = 0;
end;

method Values.IntSetNormalized(const aSet: IntSet): Boolean;
begin
  result := false;
  for i := low(aSet) + 1 to high(aSet) do
    if aSet[i - 1] >= aSet[i] then
      exit;
  result := true;
end;

method Values.IntSetEq(aSet1, aSet2: IntSet): Boolean;
begin
  result := false;
  if length(aSet1) <> length(aSet2) then
    exit;
  for i := low(aSet1) to high(aSet1) do
    if aSet1[i] <> aSet2[i] then exit;
  result := true;
end;

method Values.IntSetFind(const aSet: IntSet; aMember: Integer): Integer;
begin
  result := -1;
  var l := low(aSet);
  var h := high(aSet);
  while l <= h do
    begin
      var i := (l + h) div 2;
      if aSet[i] < aMember then
        l := i + 1
      else if aSet[i] > aMember then
        h := i - 1
      else
        exit i;
    end;
end;

method Values.IntSetMember(const aSet: IntSet; aMember: Integer): Boolean;
begin
  result := IntSetFind(aSet, aMember) >= 0;
end;

method Values.IntSetInclude(var aSet: IntSet; aInt: Integer);
begin
  if length(aSet) = 0 then
    aSet := IntSet(aInt)
  else if not IntSetMember(aSet, aInt) then
    begin
      var lSet := Utils.CopyIntArray(aSet, 0, length(aSet) + 1);
      lSet[high(lSet)] := aInt;
      aSet := Normed(lSet);
    end;
end;

method Values.IntSetInclude(var aSet: IntSet; const aIncl: IntSet);
begin
  if length(aSet) = 0 then
    aSet := IntSet(aIncl)
  else
    begin
      var lSet := Utils.CopyIntArray(aSet, 0, length(aSet) + length(aIncl));
      var h := high(aSet);
      for i := low(aIncl) to high(aIncl) do
        begin
          inc(h);
          lSet[h] := aIncl[i];
        end;
      aSet := Normed(lSet);
    end;
end;

method Values.IntSetExclude(var aSet: IntSet; aInt: Integer);
begin
  var x := IntSetFind(aSet, aInt);
  if x < 0 then
    exit;
  for i := x + 1 to high(aSet) do
    aSet[i - 1] := aSet[i];
  aSet := Utils.CopyIntArray(aSet, 0, length(aSet) - 1);
end;

method Values.IntSetExclude(var aSet: IntSet; const aExcl: IntSet);
begin
  for i := low(aExcl) to high(aExcl) do
    IntSetExclude(var aSet, aExcl[i]);
end;

method Values.IntSetIntersection(aSet1, aSet2: IntSet): IntSet;
begin
  result := EmptySet;
  if IntSetEmpty(aSet1) or IntSetEmpty(aSet2) then
    exit;
  for x1 := low(aSet1) to high(aSet1) do
    for x2 := low(aSet2) to high(aSet2) do
      if aSet1[x1] = aSet2[x2] then
        IntSetInclude(var result, aSet1[x1]);
  NormIntSet(var result);
end;

method Values.IntSetUnion(aSet1, aSet2: IntSet): IntSet;
begin
  result := Utils.ConcatenateIntArrays(aSet1, aSet2);
  NormIntSet(var result);
end;

method Values.IntSetLow(const aSet: IntSet): Integer;
begin
  if IntSetEmpty(aSet) then
    raise new EConvertError(String.Format(SCvtEmptySet, ['IntSetLow']));
  result := aSet[low(aSet)];
end;

method Values.IntSetMedium(const aSet: IntSet): Float;
begin
  if IntSetEmpty(aSet) then
    raise new EConvertError(String.Format(SCvtEmptySet, ['IntSetMedium']));
  var l := length(aSet);
  var p := l div 2;
  result := if (l mod 2) = 1 then aSet[p] else (aSet[p - 1] + aSet[p]) / 2.0;
end;

method Values.IntSetHigh(const aSet: IntSet): Integer;
begin
  if IntSetEmpty(aSet) then
    raise new EConvertError(String.Format(SCvtEmptySet, ['IntSetHigh']));
  result := aSet[high(aSet)];
end;

method Values.IntSetInsertValue(const aSet: IntSet; aVal: Integer): IntSet;
begin
  result := IntSet(aSet);
  for i := low(result) to high(result) do
    if result[i] >= aVal then
      inc(result[i]);
end;

method Values.IntSetDeleteValue(const aSet: IntSet; aVal: Integer): IntSet;
begin
  result := IntSet(aSet);
  IntSetExclude(var result, aVal);
  for i := low(result) to high(result) do
    if result[i] > aVal then
      dec(result[i]);
end;

method Values.IntSetDuplicateValue(const aSet: IntSet; aVal: Integer): IntSet;
begin
  result := IntSetInsertValue(aSet, aVal + 1);
  if IntSetMember(aSet, aVal) then
    IntSetInclude(var result, aVal + 1);
end;

method Values.IntSetMoveValue(var aSet: IntSet; aFrom, aTo: Integer);
begin
  for i := low(aSet) to high(aSet) do
    aSet[i] := Utils.MoveIndex(aSet[i], aFrom, aTo);
  NormIntSet(var aSet);
end;

method Values.IntSetExchangeValues(var aSet: IntSet; aIdx1, aIdx2: Integer);
begin
  for i := low(aSet) to high(aSet) do
    if aSet[i] = aIdx1 then
      aSet[i] := aIdx2
    else if aSet[i] = aIdx2 then
      aSet[i] := aIdx1;
  NormIntSet(var aSet);
end;

method Values.IntoBounds(const aSet: IntSet; aLow, aHigh: Integer): IntSet;
begin
  var lInt := IntInt(aLow, aHigh);
  NormIntInt(var lInt);
  result := new Integer[0];
  for i := low(aSet) to high(aSet) do
    if lInt.Low <= aSet[i] <= lInt.High then
      IntSetInclude(var result, aSet[i]);
end;

method Values.IntSetToStr(const aSet: IntSet): String;
begin
  result := Utils.IntArrayToStr(aSet);
end;

method Values.StrToIntSet(s: String): IntSet;
begin
  result := Utils.StrToIntArray(s);
  NormIntSet(var result);
end;

{ Distribution }

method Values.EmptyDistr: Distribution;
begin
  result.Base := 0;
  result.Distr := nil;
end;

method Values.Distr(const aBase: Integer; aDistr: FltArray): Distribution;
begin
  result.Base := aBase;
  result.Distr := Utils.CopyFltArray(aDistr);
end;

method Values.Distr(const aBase, aLen: Integer): Distribution;
begin
  result.Base := aBase;
  result.Distr := Utils.NewFltArray(Math.Max(0, aLen));
  DistrClear(var result);
end;

method Values.Distr(const aInt: Integer): Distribution;
begin
  result := Distr(aInt, 1, aInt);
end;

method Values.DistrFromTo(const aFrom, aTo: Integer): Distribution;
begin
  result := Distr(aFrom, aTo - aFrom + 1, aFrom, aTo);
end;

method Values.Distr(const aIntInt: IntInterval): Distribution;
begin
  result := DistrFromTo(aIntInt.Low, aIntInt.High);
end;

method Values.Distr(const aSet: IntSet): Distribution;
begin
  if length(aSet)=0 then
    result := Distr(0, 0)
  else
    begin
      var min := MinValue(aSet);
      var max := MaxValue(aSet);
      result := Distr(min, max - min + 1, aSet);
    end;
end;

method Values.Distr(const aDistr: Distribution): Distribution;
begin
  result.Base := aDistr.Base;
  result.Distr := Utils.CopyFltArray(aDistr.Distr);
end;

method Values.Distr(const aBase, aLen: Integer; const aInt: Integer): Distribution;
begin
  result := Distr(aBase, aLen);
  SetDistribution(var result, aInt, 1.0);
end;

method Values.Distr(const aBase, aLen: Integer; const aFrom, aTo: Integer): Distribution;
begin
  result := Distr(aBase, aLen);
  for i := aFrom to aTo do
    SetDistribution(var result, i, 1.0);
end;

method Values.DistrFromIntInt(const aBase, aLen: Integer; const aIntInt: IntInterval): Distribution;
begin
  result := Distr(aBase, aLen, aIntInt.Low, aIntInt.High);
end;

method Values.Distr(const aBase, aLen: Integer; const aSet: IntSet): Distribution;
begin
  result := Distr(aBase, aLen);
  for i := low(aSet) to high(aSet) do
    SetDistribution(var result, aSet[i], 1.0);
end;

method Values.Distr(const aBase, aLen: Integer; const aDistr: Distribution): Distribution;
begin
  result := Distr(aBase, aLen);
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    SetDistribution(var result, i, GetDistribution(aDistr, i));
end;

method Values.DistrEmpty(const aDistr: Distribution): Boolean;
begin
  result := length(aDistr.Distr) = 0;
  if not result then
    for i := low(aDistr.Distr) to high(aDistr.Distr) do
      if not Utils.FloatZero(aDistr.Distr[i]) then
        exit false;
  exit true;
end;

method Values.DistrEq(aDistr1, aDistr2: Distribution): Boolean;
begin
  result := false;
  for i :=
    Math.Min(DistrLowIndex(aDistr1), DistrLowIndex(aDistr2)) to
    Math.Max(DistrHighIndex(aDistr1), DistrHighIndex(aDistr2)) do
      if not Utils.FloatEq(GetDistribution(aDistr1, i), GetDistribution(aDistr2, i)) then
        exit;
  result := true;
end;

method Values.DistrEq(aDistr1, aDistr2: Distribution; eps: Float): Boolean;
begin
  result := false;
  for i :=
    Math.Min(DistrLowIndex(aDistr1), DistrLowIndex(aDistr2)) to
    Math.Max(DistrHighIndex(aDistr1), DistrHighIndex(aDistr2)) do
      if not Utils.FloatEq(GetDistribution(aDistr1, i), GetDistribution(aDistr2, i), eps) then
        exit;
  result := true;
end;

method Values.DistrCopy(const aDistr: Distribution): Distribution;
begin
  result.Base := aDistr.Base;
  result.Distr := Utils.CopyFltArray(aDistr.Distr);
end;

method Values.DistrClear(var aDistr: Distribution);
begin
  for i := low(aDistr.Distr) to high(aDistr.Distr) do
    aDistr.Distr[i] := 0.0;
end;

method Values.DistrClean(var aDistr: Distribution);
begin
  for i := low(aDistr.Distr) to high(aDistr.Distr) do
    if aDistr.Distr[i] < Utils.FloatEpsilon then
      aDistr.Distr[i] := 0.0
    else if Utils.FloatEq(aDistr.Distr[i], 1.0) then
      aDistr.Distr[i] := 1.0;
end;

method Values.DistrCompact(const aDistr: Distribution): Distribution;
begin
  if length(aDistr.Distr) = 0 then
    result := Distr(0, 0)
  else
    begin
      var lMin := DistrLow(aDistr);
      var lMax := DistrHigh(aDistr);
      result :=
        if lMin > lMax then Distr(0, 0)
        else Distr(lMin, lMax - lMin + 1, aDistr);
    end;
end;

method Values.DistrLength(const aDistr: Distribution): Integer;
begin
  result := length(aDistr.Distr);
end;

method Values.DistrCount(const aDistr: Distribution): Integer;
begin
  result := 0;
  for i := low(aDistr.Distr) to high(aDistr.Distr) do
    if not Utils.FloatEq(aDistr.Distr[i], 0.0) then
      inc(result);
end;

method Values.DistrLowIndex(const aDistr: Distribution): Integer;
begin
  result := aDistr.Base;
end;

method Values.DistrHighIndex(const aDistr: Distribution): Integer;
begin
  result := aDistr.Base + length(aDistr.Distr) - 1;
end;

method Values.DistrExpand(var aDistr: Distribution; aNewIdx: Integer);
begin
  if aNewIdx < DistrLowIndex(aDistr) then
    aDistr := Distr(aNewIdx, DistrLength(aDistr) + DistrLowIndex(aDistr) - aNewIdx, aDistr)
  else if aNewIdx > DistrHighIndex(aDistr) then
    aDistr := Distr(aDistr.Base, DistrLength(aDistr) + aNewIdx - DistrHighIndex(aDistr), aDistr);
end;

method Values.SetDistribution(var aDistr: Distribution; aIdx: Integer; aValue: Float; aExpand: Boolean := false);
begin
  if aExpand then
    DistrExpand(var aDistr, aIdx);
  if (aIdx >= DistrLowIndex(aDistr)) and (aIdx <= DistrHighIndex(aDistr)) then
    aDistr.Distr[aIdx - aDistr.Base] := aValue
end;

method Values.GetDistribution(const aDistr: Distribution; aIdx: Integer): Float;
begin
  if (aIdx < DistrLowIndex(aDistr)) or (aIdx > DistrHighIndex(aDistr)) then
    result := 0.0
  else
    result := aDistr.Distr[aIdx - aDistr.Base];
end;

method Values.DistrMin(const aDistr: Distribution): Float;
begin
  if DistrLength(aDistr) = 0 then
    result := 0.0
  else
    begin
      result := aDistr.Distr[low(aDistr.Distr)];
      for i := low(aDistr.Distr) + 1 to high(aDistr.Distr) do
        if aDistr.Distr[i] < result then
          result := aDistr.Distr[i];
    end;
end;

method Values.DistrMax(const aDistr: Distribution): Float;
begin
  if DistrLength(aDistr) = 0 then
    result := 0.0
  else
    begin
      result := aDistr.Distr[low(aDistr.Distr)];
      for i := low(aDistr.Distr) + 1 to high(aDistr.Distr) do
        if aDistr.Distr[i] > result then
          result := aDistr.Distr[i];
    end;
end;

method Values.DistrSum(const aDistr: Distribution): Float;
begin
  result := 0.0;
  for i := low(aDistr.Distr) to high(aDistr.Distr) do
    result := result + aDistr.Distr[i];
end;

method Values.DistrLow(const aDistr: Distribution): Integer;
begin
  result := DistrLowIndex(aDistr);
  var h := DistrHighIndex(aDistr);
  while (result <= h) and (GetDistribution(aDistr, result) = 0.0) do
    inc(result);
end;

method Values.DistrMedium(const aDistr: Distribution): Float;
begin
  result := 0.0;
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    result := result + i * GetDistribution(aDistr, i);
end;

method Values.DistrHigh(const aDistr: Distribution): Integer;
begin
  result := DistrHighIndex(aDistr);
  var l := DistrLowIndex(aDistr);
  while (result >= l) and (GetDistribution(aDistr, result) = 0.0) do
    dec(result);
end;

method Values.DistrMul(var aDistr: Distribution; aMul: Float);
begin
  for i := low(aDistr.Distr) to high(aDistr.Distr) do
    aDistr.Distr[i] := aMul * aDistr.Distr[i];
end;

method Values.DistrDiv(var aDistr: Distribution; aDiv: Float);
begin
  if (aDiv = 0.0) or (aDiv=1.0) then
    exit;
  for i := low(aDistr.Distr) to high(aDistr.Distr) do
    aDistr.Distr[i] := aDistr.Distr[i] / aDiv;
end;

method Values.DistrInsertValue(const aDistr: Distribution; aVal: Integer): Distribution;
begin
  if DistrLength(aDistr) = 0 then
    exit Distr(aVal, [0.0]);
  if aVal <  DistrLowIndex(aDistr) then
    begin
      result := Distr(aDistr);
      DistrExpand(var result, aVal);
      exit;
    end;
  result := Distr(aDistr.Base, Math.Max(aVal, DistrHighIndex(aDistr) + 1));
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    begin
      var v := if i >= aVal then i + 1 else i;
      SetDistribution(var result, v, GetDistribution(aDistr, i));
    end;
end;

method Values.DistrDeleteValue(const aDistr: Distribution; aVal: Integer): Distribution;
begin
  result := Distr(aDistr.Base, DistrLength(aDistr));
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    if i <> aVal then
      begin
        var v :=  if i >= aVal then i - 1 else i;
        SetDistribution(var result, v, GetDistribution(aDistr, i));
      end;
end;

method Values.DistrDuplicateValue(const aDistr: Distribution; aVal: Integer): Distribution;
begin
  result := DistrInsertValue(aDistr, aVal + 1);
  SetDistribution(var result, aVal + 1, GetDistribution(aDistr, aVal));
end;

method Values.DistrMergeValue(const aDistr: Distribution; aFrom, aTo: Integer; aNorm: Normalization := Normalization.normNone): Distribution;
begin
  if aFrom = aTo then
    exit aDistr;
  var lFrom := GetDistribution(aDistr, aFrom);
  var lTo :=  GetDistribution(aDistr, aTo);
  var x := Utils.MergeIndex(aTo, aFrom, aTo);
  result := DistrDeleteValue(aDistr, aFrom);
  var lUnion :=
    if aNorm = Normalization.normSet then
      if (aFrom = 0.0) and (aTo = 0.0) then 0.0 else 1.0
    else if aNorm = Normalization.normFuzzy then Math.Max(aFrom, aTo)
    else lFrom + lTo;
  SetDistribution(var result, x, lUnion);
end;

method Values.DistrMoveValue(const aDistr: Distribution; aFrom, aTo: Integer): Distribution;
begin
  if aFrom = aTo then
    exit aDistr;
  result := Distr(aDistr.Base, DistrLength(aDistr));
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    SetDistribution(var result, Utils.MoveIndex(i, aFrom, aTo), GetDistribution(aDistr, i), true);
end;

method Values.DistrReverse(const aDistr: Distribution; aLow, aHigh: Integer): Distribution;
begin
  result := EmptyDistr;
  if DistrEmpty(aDistr) then
    exit;
  var lLow := DistrLowIndex(aDistr);
  var lHigh := DistrHighIndex(aDistr);
  var nLow := Utils.ReverseIndex(lLow, aLow, aHigh);
  var nHigh := Utils.ReverseIndex(lHigh, aLow, aHigh);
  NormIntInt(var nLow, var nHigh);
  result := Distr(nLow, nHigh - nLow + 1);
  for i := lLow to lHigh do
    SetDistribution(var result, Utils.ReverseIndex(i, aLow, aHigh), GetDistribution(aDistr, i), true);
end;

method Values.IntoBounds(const aDistr: Distribution; aLow, aHigh: Integer): Distribution;
begin
  var lInt := IntInt(aLow, aHigh);
  NormIntInt(var lInt);
  result := Distr(aDistr);
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    if (i < lInt.Low) or (i > lInt.High) then
      SetDistribution(var result, i, 0.0);
end;

method Values.DistrToStr(const aDistr: Distribution; aInvariant: Boolean := true; aDecimals: Integer = -1): String;
begin
  result := '';
  for i := DistrLowIndex(aDistr) to DistrHighIndex(aDistr) do
    begin
      var d := GetDistribution(aDistr, i);
      if d > 0.0 then
        begin
          if result <> '' then
            result := result + Utils.DefaultSeparator;
          result := result + Utils.IntToStr(i) + ':' + Utils.FltToStr(d, aDecimals, aInvariant);
        end;
    end;
end;

method Values.StrToDistr(s: String; aInvariant: Boolean := true): Distribution;
begin
  result := Distr(0,0);
  while s <> '' do
    begin
      var sub := Utils.NextSubstr(var s);
      SetDistribution(var result, Utils.StrToInt(Utils.LeftOf(sub, ':')), Utils.StrToFlt(Utils.RightOf(sub, ':'), aInvariant), true);
    end;
  DistrClean(var result);
end;

{ Norm }

method Values.NormIntInt(var aIntInt: IntInterval);
begin
  if aIntInt.Low > aIntInt.High then
    Utils.SwapInt(var aIntInt.Low, var aIntInt.High);
end;

method Values.NormIntInt(var aLow: Integer; var aHigh: Integer);
begin
  if aLow > aHigh then
    Utils.SwapInt(var aLow, var aHigh);
end;

method Values.NormIntOff(var aOff: IntOffset);
begin
  var d := Integer(Math.Truncate(aOff.Off));
  inc(aOff.Int, d);
  aOff.Off := aOff.Off - d;
  if aOff.Off > 0.5 then
    begin
      inc(aOff.Int);
      aOff.Off := aOff.Off - 1.0;
    end
  else if aOff.Off < -0.5 then
    begin
      dec(aOff.Int);
      aOff.Off := aOff.Off + 1.0;
    end;
end;

method Values.NormFltInt(var aFltInt: FltInterval);
begin
  if aFltInt.Low > aFltInt.High then
    Utils.SwapFlt(var aFltInt.Low,var aFltInt.High);
end;

method Values.NormIntSet(var aSet: IntSet);
begin
  if IntSetNormalized(aSet) then
    exit;
  // sort
  for i := low(aSet) to high(aSet) - 1 do
    for j := i + 1 to high(aSet) do
      if aSet[j] < aSet[i] then
        Utils.SwapInt(var aSet[i], var aSet[j]);
  // remove duplicates
  var i := low(aSet);
  for j := low(aSet) + 1 to high(aSet) do
    if aSet[i] <> aSet[j] then
      begin
        inc(i);
        aSet[i] := aSet[j];
      end;
  if i <> high(aSet) then
    aSet := Utils.CopyIntArray(aSet, 0, i + 1);
end;

method Values.NormDistr(var aDistr: Distribution; aNorm: Normalization := Normalization.normNone);
begin
  DistrClean(var aDistr);
  case aNorm of
    Normalization.normNone, Normalization.normOrd: {nothing};
    Normalization.normSet:
      for i := low(aDistr.Distr) to high(aDistr.Distr) do
        if aDistr.Distr[i] > 0.0 then aDistr.Distr[i] := 1.0;
    Normalization.normProb:
      DistrDiv(var aDistr, DistrSum(aDistr));
    Normalization.normFuzzy:
      DistrDiv(var aDistr, DistrMax(aDistr));
  end;
end;

method Values.Normed(const aIntInt: IntInterval): IntInterval;
begin
  result := aIntInt;
  NormIntInt(var result);
end;

method Values.Normed(const aFltInt: FltInterval): FltInterval;
begin
  result := aFltInt;
  NormFltInt(var result);
end;

method Values.Normed(const aSet: IntSet): IntSet;
begin
  result := IntSet(aSet);
  NormIntSet(var result);
end;

method Values.Normed(const aOff: IntOffset): IntOffset;
begin
  result := aOff;
  NormIntOff(var result);
end;

method Values.Normed(const aDistr: Distribution; aNorm: Normalization := Normalization.normNone): Distribution;
begin
  result := Distr(aDistr);
  NormDistr(var result, aNorm);
end;

{ Is }

method Values.IsIntSingle(const aIntInt: IntInterval): Boolean;
begin
  result := aIntInt.Low = aIntInt.High;
end;

method Values.IsIntSingle(const aSet: IntSet): Boolean;
begin
  result := length(aSet) = 1;
end;

method Values.IsIntSingle(const aDistr: Distribution): Boolean;
begin
  result := (DistrLength(aDistr) > 0) and (DistrLow(aDistr) = DistrHigh(aDistr));
end;

method Values.IsIntInt(const aSet: IntSet): Boolean;
begin
  result := false;
  if IntSetEmpty(aSet) then
    exit;
  for i := low(aSet) + 1 to high(aSet) do
    if aSet[i-1] <> aSet[i] - 1 then
      exit;
  result := true;
end;

method Values.IsIntInt(const aDistr: Distribution): Boolean;
begin
  result := IsIntSet(aDistr) and IsIntInt(IntSet(aDistr));
end;

method Values.IsIntSet(const aDistr: Distribution): Boolean;
begin
  result := DistrEq(aDistr, Distr(IntSet(aDistr)));
end;

method Values.IsFltSingle(const aFltInt: FltInterval): Boolean;
begin
  result := Utils.FloatEq(aFltInt.Low, aFltInt.High);
end;

{ Compare }

method Values.CompareIntInterval(L1, H1, L2, H2: Integer): PrefCompare;
begin
  result :=
    if L1 = L2 then
      if H1 = H2 then PrefCompare.Equal
      else if H1 > H2 then PrefCompare.Greater
      else PrefCompare.Lower
    else if L1 > L2 then
      if H1 >= H2 then PrefCompare.Greater
      else PrefCompare.No
    else //L1 < L2
      if H1 <= H2 then PrefCompare.Lower
      else PrefCompare.No;
end;

method Values.CompareIntInterval(aIntInt1, aIntInt2: IntInterval): PrefCompare;
begin
  result := CompareIntInterval(aIntInt1.Low, aIntInt1.High, aIntInt2.Low, aIntInt2.High);
end;

method Values.CompareIntIntervalStrict(aIntInt1, aIntInt2: IntInterval): PrefCompare;
begin
  result :=
    if IntIntEq(aIntInt1, aIntInt2) then PrefCompare.Equal
    else if aIntInt1.High < aIntInt2.Low then PrefCompare.Lower
    else if aIntInt1.Low > aIntInt2.High then PrefCompare.Greater
    else PrefCompare.No;
end;

method Values.CompareFltInterval(L1, H1, L2, H2: Float): PrefCompare;
begin
  result :=
    if L1 = L2 then
      if H1 = H2 then PrefCompare.Equal
      else if H1 > H2 then PrefCompare.Greater
      else PrefCompare.Lower
    else if L1 > L2 then
      if H1 >= H2 then PrefCompare.Greater
      else PrefCompare.No
    else //L1 < L2
      if H1 <= H2 then PrefCompare.Lower
      else PrefCompare.No;
end;

method Values.CompareFltInterval(aFltFlt1, aFltFlt2: FltInterval): PrefCompare;
begin
  result := CompareFltInterval(aFltFlt1.Low, aFltFlt1.High, aFltFlt2.Low, aFltFlt2.High);
end;

method Values.CompareFltIntervalStrict(aFltFlt1, aFltFlt2: FltInterval): PrefCompare;
begin
  result :=
    if FltIntEq(aFltFlt1, aFltFlt2) then PrefCompare.Equal
    else if aFltFlt1.High < aFltFlt2.Low then PrefCompare.Lower
    else if aFltFlt1.Low > aFltFlt2.High then PrefCompare.Greater
    else PrefCompare.No;
end;

method Values.CompareIntSet(aSet1, aSet2: IntSet): PrefCompare;
begin
  var lSet := IntSetIntersection(aSet1, aSet2);
  if IntSetEmpty(lSet) then
    exit CompareIntSetStrict(aSet1, aSet2);
  var xSet1 := IntSet(aSet1);
  var xSet2 := IntSet(aSet2);
  IntSetExclude(var xSet1, lSet);
  IntSetExclude(var xSet2, lSet);
  result :=
    if IntSetEmpty(xSet1) then
      if IntSetEmpty(xSet2) then PrefCompare.Equal
      else CompareIntSetStrict(lSet, xSet2)
    else
      if IntSetEmpty(xSet2) then CompareIntSetStrict(xSet1, lSet)
      else CompareIntSetStrict(xSet1, xSet2);
end;

method Values.CompareIntSetStrict(aSet1, aSet2: IntSet): PrefCompare;
begin
  result :=
    if IntSetEmpty(aSet1) then
      if IntSetEmpty(aSet2) then PrefCompare.Equal
      else PrefCompare.No
    else
      if IntSetEmpty(aSet2) then PrefCompare.No
      else CompareIntIntervalStrict(IntInt(aSet1), IntInt(aSet2));
end;

method Values.CompareDistr(aDistr1, aDistr2: Distribution): PrefCompare;
begin
  result := PrefCompare.Equal;
  var c1 := 0.0;
  var c2 := 0.0;
  for x := Math.Min(DistrLow(aDistr1), DistrLow(aDistr2)) to Math.Max(DistrHigh(aDistr1), DistrHigh(aDistr2)) do
    begin
      c1 := c1 + GetDistribution(aDistr1, x);
      c2 := c2 + GetDistribution(aDistr2, x);
      result := PrefCompareUpdate(result, Utils.Compare(c2, c1));
      if result = PrefCompare.No then
        exit;
    end;
end;

end.
