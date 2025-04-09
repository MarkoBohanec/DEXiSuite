namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  ValuesTest = public class(DexiLibraryTest)
  protected
    method CheckInterval(aInt: IntInterval; xLow, xHigh: Integer);
    method CheckInterval(aInt: FltInterval; xLow, xHigh: Float);
    method CheckOffset(aOff: IntOffset; xInt: Integer; xOff: Float);
    method CheckIntSet(aSet: IntSet; xSet: IntSet);
    method CheckDistr(aDistr: Distribution; xBase: Integer; xDistr: FltArray);
  public
    method TestIntToPref;
    method TestReversePref;
    method TestPrefUpdate;
    method TestSum;
    method TestMinMaxValueInt;
    method TestMinMaxValueFlt;
    method TestNormSumMax;
    method TestIntSingle;
    method TestIntInterval;
    method TestIntIntEq;
    method TestIntIntModify;
    method TestIntIntNorm;
    method TestIntIntStr;
    method TestIntOffset;
    method TestIntOffNorm;
    method TestIntOffEq;
    method TestIntOffStr;
    method TestFltSingle;
    method TestFltInterval;
    method TestFltIntNorm;
    method TestFltIntEq;
    method TestFltIntStr;
    method TestIntSet;
    method TestIntSetEmpty;
    method TestIntSetNorm;
    method TestIntSetNormalized;
    method TestIntSetEq;
    method TestIntSetFind;
    method TestIntSetInclude;
    method TestIntSetExclude;
    method TestIntSetUnionIntersect;
    method TestIntSetLowMedHigh;
    method TestIntSetBound;
    method TestIntSetModify;
    method TestIntSetStr;
    method TestDistr;
    method TestDistrEmpty;
    method TestDistrEq;
    method TestDistrProperties;
    method TestDistrNorm;
    method TestDistrExpand;
    method TestDistrCompact;
    method TestDistrGetSet;
    method TestDistrMul;
    method TestDistrDiv;
    method TestDistrBound;
    method TestDistrModify;
    method TestDistrStr;
    method TestIsIntSingle;
    method TestIsIntInt;
    method TestIsIntSet;
    method TestIsFltSingle;
    method TestCompareIntInterval;
    method TestCompareFltInterval;
    method TestCompareIntSet;
    method TestCompareDistr;
    method TestIntoBounds;
  end;

implementation

method ValuesTest.TestIntToPref;
begin
  Assert.IsTrue(Values.IntToPrefCompare(0) = PrefCompare.Equal);
  Assert.IsTrue(Values.IntToPrefCompare(1) = PrefCompare.Greater);
  Assert.IsTrue(Values.IntToPrefCompare(-1) = PrefCompare.Lower);
  Assert.IsTrue(Values.IntToPrefCompare(10) = PrefCompare.Greater);
  Assert.IsTrue(Values.IntToPrefCompare(-10) = PrefCompare.Lower);
end;

method ValuesTest.TestReversePref;
begin
  Assert.IsTrue(Values.ReversePrefCompare(PrefCompare.No) = PrefCompare.No);
  Assert.IsTrue(Values.ReversePrefCompare(PrefCompare.Equal) = PrefCompare.Equal);
  Assert.IsTrue(Values.ReversePrefCompare(PrefCompare.Greater) = PrefCompare.Lower);
  Assert.IsTrue(Values.ReversePrefCompare(PrefCompare.Lower) = PrefCompare.Greater);
end;

method ValuesTest.TestPrefUpdate;
begin
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.No, PrefCompare.No) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.No, PrefCompare.Equal) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.No, PrefCompare.Lower) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.No, PrefCompare.Greater) = PrefCompare.No);

  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Equal, PrefCompare.No) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Equal, PrefCompare.Equal) = PrefCompare.Equal);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Equal, PrefCompare.Lower) = PrefCompare.Lower);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Equal, PrefCompare.Greater) =  PrefCompare.Greater);

  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Lower, PrefCompare.No) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Lower, PrefCompare.Equal) = PrefCompare.Lower);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Lower, PrefCompare.Lower) = PrefCompare.Lower);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Lower, PrefCompare.Greater) = PrefCompare.No);

  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Greater, PrefCompare.No) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Greater, PrefCompare.Equal) = PrefCompare.Greater);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Greater, PrefCompare.Lower) = PrefCompare.No);
  Assert.IsTrue(Values.PrefCompareUpdate(PrefCompare.Greater, PrefCompare.Greater) = PrefCompare.Greater);
end;

method ValuesTest.CheckInterval(aInt: IntInterval; xLow, xHigh: Integer);
begin
  Assert.AreEqual(aInt.Low, xLow);
  Assert.AreEqual(aInt.High, xHigh);
end;

method ValuesTest.CheckInterval(aInt: FltInterval; xLow, xHigh: Float);
begin
  Assert.IsTrue(Utils.FloatEq(aInt.Low, xLow));
  Assert.IsTrue(Utils.FloatEq(aInt.High, xHigh));
end;

method ValuesTest.CheckOffset(aOff: IntOffset; xInt: Integer; xOff: Float);
begin
  Assert.AreEqual(aOff.Int, xInt);
  Assert.IsTrue(Utils.FloatEq(aOff.Off, xOff));
end;

method ValuesTest.CheckIntSet(aSet: IntSet; xSet: IntSet);
begin
  Assert.AreEqual(length(aSet), length(xSet));
  for i := low(aSet) to high(aSet) do
    Assert.AreEqual(aSet[i], xSet[i]);
end;

method ValuesTest.CheckDistr(aDistr: Distribution; xBase: Integer; xDistr: FltArray);
begin
  Assert.AreEqual(aDistr.Base, xBase);
  Assert.IsTrue(Utils.FltArrayEq(aDistr.Distr, xDistr));
end;

method ValuesTest.TestSum;
begin
  Assert.AreEqual(Values.Sum(IntArray(nil)), 0);
  Assert.AreEqual(Values.Sum(IntArray([])), 0);
  Assert.AreEqual(Values.Sum([0]), 0);
  Assert.AreEqual(Values.Sum([1]), 1);
  Assert.AreEqual(Values.Sum([1, 2, 3]), 6);

  Assert.AreEqual(Values.Sum(FltArray(nil)), 0.0);
  Assert.AreEqual(Values.Sum(FltArray([])), 0.0);
  Assert.AreEqual(Values.Sum([0.0]), 0.0);
  Assert.AreEqual(Values.Sum([1.1]), 1.1);
  Assert.AreEqual(Values.Sum([1, 2, 3.3]), 6.3);
end;

method ValuesTest.TestMinMaxValueInt;

  method CheckMinMax(aArr: IntArray; xMin, xMax: Integer);
  begin
    var lMin := Values.MinValue(aArr);
    var lMax := Values.MaxValue(aArr);
    Assert.AreEqual(lMin, xMin);
    Assert.AreEqual(lMax, xMax);
  end;

begin
  CheckMinMax(nil, high(Integer), low(Integer));
  CheckMinMax([], high(Integer), low(Integer));
  CheckMinMax([1], 1, 1);
  CheckMinMax([1, 2, 3], 1, 3);
  CheckMinMax([1, 5, 3], 1, 5);
end;

method ValuesTest.TestMinMaxValueFlt;

  method CheckMinMax(aArr: FltArray; xMin, xMax: Float);
  begin
    var lMin := Values.MinValue(aArr);
    var lMax := Values.MaxValue(aArr);
    Assert.AreEqual(lMin, xMin);
    Assert.AreEqual(lMax, xMax);
  end;

begin
  CheckMinMax(nil, Consts.PositiveInfinity, Consts.NegativeInfinity);
  CheckMinMax([], Consts.PositiveInfinity, Consts.NegativeInfinity);
  CheckMinMax([1], 1, 1);
  CheckMinMax([1, 2, 3], 1, 3);
  CheckMinMax([1, 5, 3], 1, 5);
end;

method ValuesTest.TestNormSumMax;

  method CheckNorm(aArr: FltArray; aNorm: Float; xSum, xMax: FltArray);
  begin
    var lsum := Values.NormSum(aArr, aNorm);
    var lmax := Values.NormMax(aArr, aNorm);
    Assert.IsTrue(Utils.FltArrayEq(lsum, xSum));
    Assert.IsTrue(Utils.FltArrayEq(lmax, xMax));
  end;

begin
  CheckNorm(nil, 100.0, nil, nil);
  CheckNorm([], 100.0, [], []);
  CheckNorm([1], 100.0, [100.0], [100.0]);
  CheckNorm([1, 1], 0.0, [0.0, 0.0], [0.0, 0.0]);
  CheckNorm([0, 0], 100.0, [0.0, 0.0], [0.0, 0.0]);
  CheckNorm([1, 1], 100.0, [50.0, 50.0], [100.0, 100.0]);
  CheckNorm([1, 3], 100.0, [25.0, 75.0], [100.0/3.0, 100.0]);
  CheckNorm([1, 3], 10.0, [2.5, 7.5], [10.0/3.0, 10.0]);
  CheckNorm([1, 3], 1.0, [0.25, 0.75], [1.0/3.0, 1.0]);

  CheckNorm([-5, 0], 100.0, [100.0, 0.0], [-5.0, 0.0]);
  CheckNorm([-5, -10], 100.0, [100.0/3, 2 * 100.0/3], [100.0, 200.0]);
end;

method ValuesTest.TestIntSingle;
begin
  Assert.AreEqual(Values.IntSingle(Values.IntInt(1, 1)), 1);
  Assert.AreEqual(Values.IntSingle(Values.IntInt(-1, 1)), 0);
  Assert.AreEqual(Values.IntSingle(Values.IntInt(0, 2)), 1);

  Assert.AreEqual(Values.IntSingle([1, 1]), 1);
  Assert.AreEqual(Values.IntSingle([-1, 1]), 0);
  Assert.AreEqual(Values.IntSingle([0, 2]), 1);

  Assert.AreEqual(Values.IntSingle(Values.Distr(1)), 1);
  Assert.AreEqual(Values.IntSingle(Values.DistrFromTo(0, 2)), 3); // FromTo is not normalized

  Assert.AreEqual(Values.IntSingle(Values.FltInt(1, 1)), 1);
  Assert.AreEqual(Values.IntSingle(Values.FltInt(-1, 1)), 0);
  Assert.AreEqual(Values.IntSingle(Values.FltInt(0, 2)), 1);
  Assert.AreEqual(Values.IntSingle(Values.FltInt(0, 1)), 1);
  Assert.AreEqual(Values.IntSingle(Values.FltInt(0, 0.999)), 0);
end;

method ValuesTest.TestIntInterval;
begin
  CheckInterval(Values.IntInt(1, 1), 1, 1);
  CheckInterval(Values.IntInt(1, 2), 1, 2);

  CheckInterval(Values.IntInt(5), 5, 5);

  CheckInterval(Values.IntInt([]), high(Integer), low(Integer));
  CheckInterval(Values.IntInt([1]), 1, 1);
  CheckInterval(Values.IntInt([1, 1, 1]), 1, 1);
  CheckInterval(Values.IntInt([1, 2, 1]), 1, 2);
  CheckInterval(Values.IntInt([5, 1, 2]), 1, 5);

  CheckInterval(Values.IntInt(Values.Distr(1)), 1, 1);
  CheckInterval(Values.IntInt(Values.DistrFromTo(0, 2)), 0, 2);
end;

method ValuesTest.TestIntIntEq;
begin
  Assert.IsTrue(Values.IntIntEq(Values.IntInt(1, 1), Values.IntInt(1, 1)));
  Assert.IsTrue(Values.IntIntEq(Values.IntInt(1, 2), Values.IntInt(1, 2)));
  Assert.IsFalse(Values.IntIntEq(Values.IntInt(1, 2), Values.IntInt(1, 1)));
  Assert.IsTrue(Values.IntIntEq(Values.IntInt(1, 5), Values.IntInt(5, 1)));
  Assert.IsTrue(Values.IntIntEq(Values.IntInt(low(Integer), high(Integer)), Values.IntInt(high(Integer), low(Integer))));
end;

method ValuesTest.TestIntIntModify;
begin
  var lInt := Values.IntInt(1, 3);
  CheckInterval(Values.IntIntInsertValue(lInt, 0), 2, 4);
  CheckInterval(Values.IntIntInsertValue(lInt, 1), 2, 4);
  CheckInterval(Values.IntIntInsertValue(lInt, 2), 1, 4);
  CheckInterval(Values.IntIntInsertValue(lInt, 3), 1, 4);
  CheckInterval(Values.IntIntInsertValue(lInt, 4), 1, 3);

  CheckInterval(Values.IntIntDeleteValue(lInt, 0), 0, 2);
  CheckInterval(Values.IntIntDeleteValue(lInt, 1), 0, 2);
  CheckInterval(Values.IntIntDeleteValue(lInt, 2), 1, 2);
  CheckInterval(Values.IntIntDeleteValue(lInt, 3), 1, 2);
  CheckInterval(Values.IntIntDeleteValue(lInt, 4), 1, 3);

  CheckInterval(Values.IntIntDuplicateValue(lInt, 0), 2, 4);
  CheckInterval(Values.IntIntDuplicateValue(lInt, 1), 1, 4);
  CheckInterval(Values.IntIntDuplicateValue(lInt, 2), 1, 4);
  CheckInterval(Values.IntIntDuplicateValue(lInt, 3), 1, 4);
  CheckInterval(Values.IntIntDuplicateValue(lInt, 4), 1, 3);
end;

method ValuesTest.TestIntIntNorm;
begin
  var lInt := Values.IntInt(1, 1);
  Values.NormIntInt(var lInt);
  CheckInterval(lInt, 1, 1);

  lInt := Values.IntInt(1, 3);
  Values.NormIntInt(var lInt);
  CheckInterval(lInt, 1, 3);

  lInt := Values.IntInt(3, 1);
  Values.NormIntInt(var lInt);
  CheckInterval(lInt, 1, 3);

  lInt := Values.IntInt(1, 1);
  Values.NormIntInt(var lInt.Low, var lInt.High);
  CheckInterval(lInt, 1, 1);

  lInt := Values.IntInt(1, 3);
  Values.NormIntInt(var lInt.Low, var lInt.High);
  CheckInterval(lInt, 1, 3);

  lInt := Values.IntInt(3, 1);
  Values.NormIntInt(var lInt.Low, var lInt.High);
  CheckInterval(lInt, 1, 3);

end;

method ValuesTest.TestIntIntStr;

  method CheckStr(aIntInt: IntInterval; x: String);
  begin
    var s := Values.IntIntToStr(aIntInt);
    Assert.AreEqual(s, x);
    var lIntInt := Values.StrToIntInt(s);
    Assert.IsTrue(Values.IntIntEq(lIntInt, aIntInt));
  end;

begin
  CheckStr(Values.IntInt(1, 1), '1');
  CheckStr(Values.IntInt(0, 0), '0');
  CheckStr(Values.IntInt(1, 3), '1:3');
  CheckStr(Values.IntInt(-1, 1), '-1:1');
end;


method ValuesTest.TestIntOffset;
begin
  CheckOffset(Values.IntOff(1), 1, 0.0);

  CheckOffset(Values.IntOff(1, 0.1), 1, 0.1);
  CheckOffset(Values.IntOff(1, -0.1), 1, -0.1);

  CheckOffset(Values.IntOff(1.0), 1, 0.0);
  CheckOffset(Values.IntOff(1.1), 1, 0.1);
  CheckOffset(Values.IntOff(0.9), 1, -0.1);
  CheckOffset(Values.IntOff(1.5), 1, 0.5);
  CheckOffset(Values.IntOff(0.5), 0, 0.5);
  CheckOffset(Values.IntOff(0.51), 1, -0.49);

  CheckOffset(Values.IntOff(1.1, OffsetRounding.Down), 1, 0.1);
  CheckOffset(Values.IntOff(1.1, OffsetRounding.Up), 1, 0.1);
  CheckOffset(Values.IntOff(0.9, OffsetRounding.Down), 1, -0.1);
  CheckOffset(Values.IntOff(0.9, OffsetRounding.Up), 1, -0.1);

  CheckOffset(Values.IntOff(1.5, OffsetRounding.Down), 1, 0.5);
  CheckOffset(Values.IntOff(1.5, OffsetRounding.Up), 2, -0.5);
end;

method ValuesTest.TestIntOffNorm;

  method CheckNorm(aOff: IntOffset; xInt: Integer; xOff: Float);
  begin
    var lOff := Values.Normed(aOff);
    CheckOffset(lOff, xInt, xOff);
  end;

begin
  CheckNorm(Values.IntOff(1), 1, 0.0);
  CheckNorm(Values.IntOff(2), 2, 0.0);

  CheckNorm(Values.IntOff(1, 0.1), 1, 0.1);
  CheckNorm(Values.IntOff(1, -0.1), 1, -0.1);

  CheckNorm(Values.IntOff(0, 0.1), 0, 0.1);
  CheckNorm(Values.IntOff(0, -0.1), 0, -0.1);
  CheckNorm(Values.IntOff(0, -0.5), 0, -0.5);
  CheckNorm(Values.IntOff(0, +0.5), 0, +0.5);
  CheckNorm(Values.IntOff(0, -0.6), -1, +0.4);
  CheckNorm(Values.IntOff(0, +0.6), 1, -0.4);
  CheckNorm(Values.IntOff(0, -3.6), -4, +0.4);
  CheckNorm(Values.IntOff(0, +3.6), 4, -0.4);

  CheckNorm(Values.IntOff(2, 0.1), 2, 0.1);
  CheckNorm(Values.IntOff(2, -0.1), 2, -0.1);
  CheckNorm(Values.IntOff(2, -0.5), 2, -0.5);
  CheckNorm(Values.IntOff(2, +0.5), 2, +0.5);
  CheckNorm(Values.IntOff(2, -0.6), 1, +0.4);
  CheckNorm(Values.IntOff(2, +0.6), 3, -0.4);
  CheckNorm(Values.IntOff(2, -3.6), -2, +0.4);
  CheckNorm(Values.IntOff(2, +3.6), 6, -0.4);
  CheckNorm(Values.IntOff(-2, -3.6), -6, +0.4);
  CheckNorm(Values.IntOff(-2, +3.6), 2, -0.4);
end;


method ValuesTest.TestIntOffEq;
begin
  Assert.IsTrue(Values.IntOffEq(Values.IntOff(1), Values.IntOff(1, 0.0)));
  Assert.IsTrue(Values.IntOffEq(Values.IntOff(1, 0.1), Values.IntOff(1, 0.1)));
  Assert.IsFalse(Values.IntOffEq(Values.IntOff(1, 0.1), Values.IntOff(2, 0.1)));
  Assert.IsFalse(Values.IntOffEq(Values.IntOff(1, 0.1), Values.IntOff(1, 0.2)));
end;

method ValuesTest.TestIntOffStr;
var lInvariant: Boolean;

  method CheckStr(aIntOff: IntOffset; x: String);
  begin
    var s := Values.IntOffToStr(aIntOff, lInvariant);
    Assert.AreEqual(s, x);
    var lIntOff := Values.StrToIntOff(s, lInvariant);
    Assert.IsTrue(Values.IntOffEq(lIntOff, aIntOff));
  end;

begin
  lInvariant := true;
  CheckStr(Values.IntOff(1, 0), '1');
  CheckStr(Values.IntOff(1, 0.1), '1+0.1');
  CheckStr(Values.IntOff(1, -0.1), '1-0.1');

  lInvariant := false;
  CheckStr(Values.IntOff(1, 0), '1');
  CheckStr(Values.IntOff(1, 0.1), '1+0,1');
  CheckStr(Values.IntOff(1, -0.1), '1-0,1');
end;

method ValuesTest.TestFltSingle;
begin
  Assert.IsTrue(Utils.FloatEq(Values.FltSingle(Values.FltInt(2, 2)), 2.0));
  Assert.IsTrue(Utils.FloatEq(Values.FltSingle(Values.FltInt(2, 4)), 3.0));
  Assert.IsTrue(Utils.FloatEq(Values.FltSingle(Values.FltInt(2, 3)), 2.5));

  Assert.IsTrue(Utils.FloatEq(Values.FltSingle(Values.IntOff(2, 0.0)), 2.0));
  Assert.IsTrue(Utils.FloatEq(Values.FltSingle(Values.IntOff(2, 0.1)), 2.1));
  Assert.IsTrue(Utils.FloatEq(Values.FltSingle(Values.IntOff(2, -0.1)), 1.9));
end;

method ValuesTest.TestFltInterval;
begin
  CheckInterval(Values.FltInt(1, 1), 1, 1);
  CheckInterval(Values.FltInt(1, 2), 1, 2);

  CheckInterval(Values.FltInt(5), 5, 5);

  CheckInterval(Values.FltInt(Values.IntInt(1, 1)), 1, 1);
  CheckInterval(Values.FltInt(Values.IntInt(1, 2)), 1, 2);

  CheckInterval(Values.FltInt(Values.IntInt(5)), 5, 5);
end;

method ValuesTest.TestFltIntNorm;
begin
  var lFlt := Values.FltInt(1, 1);
  Values.NormFltInt(var lFlt);
  CheckInterval(lFlt, 1, 1);

  lFlt := Values.FltInt(1, 3);
  Values.NormFltInt(var lFlt);
  CheckInterval(lFlt, 1, 3);

  lFlt := Values.FltInt(3, 1);
  Values.NormFltInt(var lFlt);
  CheckInterval(lFlt, 1, 3);
end;

method ValuesTest.TestFltIntEq;
begin
  Assert.IsTrue(Values.FltIntEq(Values.FltInt(1, 1), Values.FltInt(1, 1)));
  Assert.IsTrue(Values.FltIntEq(Values.FltInt(1, 2), Values.FltInt(1, 2)));
  Assert.IsFalse(Values.FltIntEq(Values.FltInt(1, 2), Values.FltInt(1, 1)));
  Assert.IsTrue(Values.FltIntEq(Values.FltInt(1, 5), Values.FltInt(5, 1)));
  Assert.IsTrue(Values.FltIntEq(Values.FltInt(Consts.NegativeInfinity, Consts.PositiveInfinity), Values.FltInt(Consts.NegativeInfinity, Consts.PositiveInfinity)));
end;

method ValuesTest.TestFltIntStr;
var lInvariant: Boolean;

  method CheckStr(aFltInt: FltInterval; x: String);
  begin
    var s := Values.FltIntToStr(aFltInt, lInvariant);
    Assert.AreEqual(s, x);
    var lFltInt := Values.StrToFltInt(s, lInvariant);
    Assert.IsTrue(Values.FltIntEq(lFltInt, aFltInt));
  end;

begin
  lInvariant := true;
  CheckStr(Values.FltInt(1, 1), '1');
  CheckStr(Values.FltInt(0, 0), '0');
  CheckStr(Values.FltInt(1, 3), '1:3');
  CheckStr(Values.FltInt(-1, 1), '-1:1');
  CheckStr(Values.FltInt(1.1, 1.2), '1.1:1.2');
  CheckStr(Values.FltInt(0.1, 0.1), '0.1');

  lInvariant := false;
  CheckStr(Values.FltInt(1, 1), '1');
  CheckStr(Values.FltInt(0, 0), '0');
  CheckStr(Values.FltInt(1, 3), '1:3');
  CheckStr(Values.FltInt(-1, 1), '-1:1');
  CheckStr(Values.FltInt(1.1, 1.2), '1,1:1,2');
  CheckStr(Values.FltInt(0.1, 0.1), '0,1');
end;

method ValuesTest.TestIntSet;
begin
  CheckIntSet(nil, nil);
  CheckIntSet(nil, []);
  CheckIntSet(nil, []);
  CheckIntSet([], []);
  CheckIntSet([1], [1]);

  CheckIntSet(Values.IntSet(1), [1]);

  CheckIntSet(Values.IntSetArray([1]), [1]);
  CheckIntSet(Values.IntSetArray([1, 3]), [1, 3]);
  CheckIntSet(Values.IntSet([1, 3]), [1, 3]);

  CheckIntSet(Values.IntSet(1, 3), [1, 2, 3]);

  CheckIntSet(Values.IntSet(Values.IntInt(1, 3)), [1, 2, 3]);

  CheckIntSet(Values.IntSet(Values.Distr(1)), [1]);
  CheckIntSet(Values.IntSet(Values.DistrFromTo(0, 2)), [0, 1, 2]);
  CheckIntSet(Values.IntSet(Values.Distr(0, [1, 0, 0.5])), [0, 2]);
end;

method ValuesTest.TestIntSetEmpty;
begin
  Assert.IsTrue(Values.IntSetEmpty(nil));
  Assert.IsTrue(Values.IntSetEmpty([]));
  Assert.IsFalse(Values.IntSetEmpty([1]));
end;

method ValuesTest.TestIntSetNormalized;
begin
  Assert.IsTrue(Values.IntSetNormalized(nil));
  Assert.IsTrue(Values.IntSetNormalized([]));
  Assert.IsTrue(Values.IntSetNormalized([1]));
  Assert.IsTrue(Values.IntSetNormalized([1, 2]));
  Assert.IsTrue(Values.IntSetNormalized([1, 2, 5]));
  Assert.IsFalse(Values.IntSetNormalized([1, 1]));
  Assert.IsFalse(Values.IntSetNormalized([1, 5, 2]));
end;

method ValuesTest.TestIntSetNorm;

  method CheckNorm(aSet, xSet: IntSet);
  begin
    var lSet := Values.Normed(aSet);
    CheckIntSet(lSet, xSet);
  end;

begin
  CheckNorm(nil, nil);
  CheckNorm([], []);
  CheckNorm([1], [1]);
  CheckNorm([1, 2], [1, 2]);
  CheckNorm([2, 1], [1, 2]);
  CheckNorm([2, 1, 1, 3, 5, 1, 5, 2], [1, 2, 3, 5]);
end;

method ValuesTest.TestIntSetEq;
begin
  Assert.IsTrue(Values.IntSetEq(nil, nil));
  Assert.IsTrue(Values.IntSetEq(nil, []));
  Assert.IsTrue(Values.IntSetEq([], nil));
  Assert.IsTrue(Values.IntSetEq([], []));
  Assert.IsTrue(Values.IntSetEq([1], [1]));
  Assert.IsTrue(Values.IntSetEq([1, 3], [1, 3]));

  Assert.IsFalse(Values.IntSetEq([], [1]));
  Assert.IsFalse(Values.IntSetEq([1, 3], [1, 4]));
  Assert.IsFalse(Values.IntSetEq([1, 3], [4, 1]));
  Assert.IsFalse(Values.IntSetEq([1, 2, 3], [3, 2, 1]));
  Assert.IsFalse(Values.IntSetEq([1, 2, 3, 1, 2, 3], [3, 2, 1]));
end;

method ValuesTest.TestIntSetFind;

  method CheckFind(aArr: IntArray; aFind, xIdx: Integer);
  begin
    var lSet := IntSet(aArr);
    Assert.IsTrue(Values.IntSetNormalized(lSet));
    var lIdx := Values.IntSetFind(lSet, aFind);
    Assert.AreEqual(lIdx, xIdx);
    Assert.AreEqual(Values.IntSetMember(lSet, aFind), xIdx >= 0);
  end;

begin
  CheckFind(nil, 1, -1);
  CheckFind([], 1, -1);
  CheckFind([1], 1, 0);
  CheckFind([1], 0, -1);
  CheckFind([1], 2, -1);

  CheckFind([1, 2], 1, 0);
  CheckFind([1, 2], 2, 1);
  CheckFind([1, 2], 0, -1);
  CheckFind([1, 2], 5, -1);

  CheckFind([1, 2, 5], 1, 0);
  CheckFind([1, 2, 5], 2, 1);
  CheckFind([1, 2, 5], 5, 2);
  CheckFind([1, 2, 5], 0, -1);
  CheckFind([1, 2, 5], 3, -1);
  CheckFind([1, 2, 5], 4, -1);
  CheckFind([1, 2, 5], 6, -1);
end;

method ValuesTest.TestIntSetInclude;
begin
  var lSet := Values.IntSet(nil);
  Values.IntSetInclude(var lSet, 2);
  CheckIntSet(lSet, [2]);
  Values.IntSetInclude(var lSet, 1);
  CheckIntSet(lSet, [1, 2]);
  Values.IntSetInclude(var lSet, [-1, -2, 5]);
  CheckIntSet(lSet, [-2, -1, 1, 2, 5]);
end;

method ValuesTest.TestIntSetExclude;
begin
  var lSet := Values.IntSet([1, 2, 5]);
  Values.IntSetExclude(var lSet, 7);
  CheckIntSet(lSet, [1, 2, 5]);
  Values.IntSetExclude(var lSet, 2);
  CheckIntSet(lSet, [1, 5]);
  Values.IntSetExclude(var lSet, 2);
  CheckIntSet(lSet, [1, 5]);
  Values.IntSetExclude(var lSet, 1);
  CheckIntSet(lSet, [5]);
  Values.IntSetExclude(var lSet, 1);
  CheckIntSet(lSet, [5]);
  Values.IntSetExclude(var lSet, 5);
  CheckIntSet(lSet, []);
  Values.IntSetExclude(var lSet, 5);
  CheckIntSet(lSet, []);

  lSet := Values.IntSet([1, 2, 5]);
  Values.IntSetExclude(var lSet, [1, 5, 7]);
  CheckIntSet(lSet, [2]);
  Values.IntSetExclude(var lSet, [3, 4]);
  CheckIntSet(lSet, [2]);
  Values.IntSetExclude(var lSet, [2, 5]);
  CheckIntSet(lSet, []);
end;

method ValuesTest.TestIntSetUnionIntersect;

  method CheckOp(aSet1, aSet2, aUnion, aIntersect: IntSet);
  begin
    var lUnion := Values.IntSetUnion(aSet1, aSet2);
    var lIntersect := Values.IntSetIntersection(aSet1, aSet2);
    CheckIntSet(lUnion, aUnion);
    CheckIntSet(lIntersect, aIntersect);
  end;

begin
  CheckOp (nil, nil, [], []);
  CheckOp ([], nil, [], []);
  CheckOp (nil, [], [], []);
  CheckOp (nil, nil, [], []);

  CheckOp([1], nil, [1], []);
  CheckOp(nil, [1], [1], []);
  CheckOp([1], [2], [1, 2], []);
  CheckOp([2], [1], [1, 2], []);
  CheckOp([2, 1], [2], [1, 2], [2]);
  CheckOp([2, 1], [2, 3], [1, 2, 3], [2]);
  CheckOp([5, 4, 3], [1, 2, 3, 4], [1, 2, 3, 4, 5], [3, 4]);
  CheckOp([5, 3], [1, 2, 3, 4], [1, 2, 3, 4, 5], [3]);
end;

method ValuesTest.TestIntSetLowMedHigh;

  method CheckLMH(aArr: IntArray; xL, xH: Integer; xM: Float);
  begin
    var lSet := IntSet(aArr);
    Assert.AreEqual(Values.IntSetLow(lSet), xL);
    Assert.AreEqual(Values.IntSetMedium(lSet), xM);
    Assert.AreEqual(Values.IntSetHigh(lSet), xH);
  end;

begin
  CheckLMH([1], 1, 1, 1.0);
  CheckLMH([1, 2], 1, 2, 1.5);
  CheckLMH([1, 3], 1, 3, 2.0);
  CheckLMH([1, 2, 3], 1, 3, 2.0);
  CheckLMH([1, 2, 3, 4], 1, 4, 2.5);
  CheckLMH([1, 2, 5, 10], 1, 10, 3.5);
end;

method ValuesTest.TestIntSetBound;
begin
  CheckIntSet(Values.IntoBounds(nil, 0, 11), []);

  var lSet := [1, 2, 5, 10];
  CheckIntSet(Values.IntoBounds(lSet, 0, 11), lSet);
  CheckIntSet(Values.IntoBounds(lSet, 1, 9), [1, 2, 5]);
  CheckIntSet(Values.IntoBounds(lSet, 2, 6), [2, 5]);
  CheckIntSet(Values.IntoBounds(lSet, 3, 5), [5]);
  CheckIntSet(Values.IntoBounds(lSet, 6, 7), []);
end;

method ValuesTest.TestIntSetModify;
begin
  CheckIntSet(Values.IntSetInsertValue(nil, 0), []);
  CheckIntSet(Values.IntSetDeleteValue(nil, 0), []);
  CheckIntSet(Values.IntSetDuplicateValue(nil, 0), []);

  var lSet := [1, 2, 5, 10];
  CheckIntSet(Values.IntSetInsertValue(lSet, 0), [2, 3, 6, 11]);
  CheckIntSet(Values.IntSetInsertValue(lSet, 2), [1, 3, 6, 11]);
  CheckIntSet(Values.IntSetInsertValue(lSet, 3), [1, 2, 6, 11]);
  CheckIntSet(Values.IntSetInsertValue(lSet, 10), [1, 2, 5, 11]);
  CheckIntSet(Values.IntSetInsertValue(lSet, 11), lSet);

  CheckIntSet(Values.IntSetDeleteValue(lSet, 0), [0, 1, 4, 9]);
  CheckIntSet(Values.IntSetDeleteValue(lSet, 1), [1, 4, 9]);
  CheckIntSet(Values.IntSetDeleteValue(lSet, 2), [1, 4, 9]);
  CheckIntSet(Values.IntSetDeleteValue(lSet, 3), [1, 2, 4, 9]);
  CheckIntSet(Values.IntSetDeleteValue(lSet, 10), [1, 2, 5]);
  CheckIntSet(Values.IntSetDeleteValue(lSet, 11), lSet);

  CheckIntSet(Values.IntSetDuplicateValue(lSet, 0), [2, 3, 6, 11]);
  CheckIntSet(Values.IntSetDuplicateValue(lSet, 1), [1, 2, 3, 6, 11]);
  CheckIntSet(Values.IntSetDuplicateValue(lSet, 2), [1, 2, 3, 6, 11]);
  CheckIntSet(Values.IntSetDuplicateValue(lSet, 3), [1, 2, 6, 11]);
  CheckIntSet(Values.IntSetDuplicateValue(lSet, 10), [1, 2, 5, 10, 11]);
  CheckIntSet(Values.IntSetDuplicateValue(lSet, 11), lSet);

  lSet := [1, 2, 5, 10];
  Values.IntSetExchangeValues(var lSet, 4, 6);
  CheckIntSet(lSet, [1, 2, 5, 10]);

  Values.IntSetExchangeValues(var lSet, 5, 6);
  CheckIntSet(lSet, [1, 2, 6, 10]);

  lSet := [1, 2, 5, 10];
  Values.IntSetExchangeValues(var lSet, 2, 5);
  CheckIntSet(lSet, [1, 2, 5, 10]);
end;

method ValuesTest.TestIntSetStr;

  method CheckStr(aIntSet: IntSet; x: String);
  begin
    var s := Values.IntSetToStr(aIntSet);
    Assert.AreEqual(s, x);
    var lIntSet := Values.StrToIntSet(s);
    Assert.IsTrue(Values.IntSetEq(lIntSet, aIntSet));
  end;

begin
  CheckStr(nil, '');
  CheckStr([], '');
  CheckStr([1], '1');
  CheckStr([1, 2], '1;2');
  CheckStr([1, 2, 5], '1;2;5');
  CheckStr(Values.IntSetArray([1, -2, 5]), '-2;1;5');
end;

method ValuesTest.TestDistr;
begin
  CheckDistr(Values.Distr(1, [0.5, 0.7]), 1, [0.5, 0.7]);

  CheckDistr(Values.Distr(0, 0), 0, []);
  CheckDistr(Values.Distr(0, 1), 0, [0.0]);
  CheckDistr(Values.Distr(1, 1), 1, [0.0]);

  CheckDistr(Values.Distr(0), 0, [1.0]);
  CheckDistr(Values.Distr(1), 1, [1.0]);
  CheckDistr(Values.Distr(2), 2, [1.0]);

  CheckDistr(Values.DistrFromTo(1, 1), 1, [1.0]);
  CheckDistr(Values.DistrFromTo(1, 2), 1, [1.0, 1.0]);
  CheckDistr(Values.DistrFromTo(3, 6), 3, [1.0, 1.0, 1.0, 1.0]);

  CheckDistr(Values.Distr(Values.IntInt(3, 6)), 3, [1.0, 1.0, 1.0, 1.0]);

  CheckDistr(Values.Distr(nil), 0, []);
  CheckDistr(Values.Distr([0]), 0, [1.0]);
  CheckDistr(Values.Distr([1]), 1, [1.0]);
  CheckDistr(Values.Distr([1, 3, 5]), 1, [1.0, 0.0, 1.0, 0.0, 1.0]);

  CheckDistr(Values.Distr(Values.Distr(0, 0)), 0, []);
  CheckDistr(Values.Distr(Values.Distr(0, 1)), 0, [0.0]);
  CheckDistr(Values.Distr(Values.Distr(1, 1)), 1, [0.0]);
  CheckDistr(Values.Distr(Values.DistrFromTo(3, 6)), 3, [1.0, 1.0, 1.0, 1.0]);
  CheckDistr(Values.Distr(Values.Distr(nil)), 0, []);
  CheckDistr(Values.Distr(Values.Distr([0])), 0, [1.0]);
  CheckDistr(Values.Distr(Values.Distr([1])), 1, [1.0]);
  CheckDistr(Values.Distr(Values.Distr([1, 5, 3])), 1, [1.0, 0.0, 1.0, 0.0, 1.0]);
  CheckDistr(Values.Distr(Values.Distr([1, 5, 3])), 1, [1.0, 0.0, 1.0, 0.0, 1.0]);

  CheckDistr(Values.Distr(0, 0, 5), 0, []);
  CheckDistr(Values.Distr(0, 3, 1), 0, [0.0, 1.0, 0.0]);
  CheckDistr(Values.Distr(0, 3, 5), 0, [0.0, 0.0, 0.0]);

  CheckDistr(Values.Distr(0, 0, 5, 7), 0, []);
  CheckDistr(Values.Distr(0, 3, 0, 1), 0, [1.0, 1.0, 0.0]);
  CheckDistr(Values.Distr(0, 3, 1, 2), 0, [0.0, 1.0, 1.0]);
  CheckDistr(Values.Distr(0, 3, 5, 7), 0, [0.0, 0.0, 0.0]);

  CheckDistr(Values.DistrFromIntInt(0, 3, Values.IntInt(0, 1)), 0, [1.0, 1.0, 0.0]);
  CheckDistr(Values.DistrFromIntInt(0, 3, Values.IntInt(5, 7)), 0, [0.0, 0.0, 0.0]);

  CheckDistr(Values.Distr(0, 3, [1, 3]), 0, [0.0, 1.0, 0.0]);
  CheckDistr(Values.Distr(1, 3, [1, 3]), 1, [1.0, 0.0, 1.0]);

  CheckDistr(Values.Distr(0, 3, Values.Distr(1)), 0, [0.0, 1.0, 0.0]);
  CheckDistr(Values.Distr(0, 4, Values.Distr(1)), 0, [0.0, 1.0, 0.0, 0.0]);
end;

method ValuesTest.TestDistrEmpty;
begin
  Assert.IsTrue(Values.DistrEmpty(Values.Distr(0, 0)));
  Assert.IsTrue(Values.DistrEmpty(Values.Distr(0, [])));
  Assert.IsFalse(Values.DistrEmpty(Values.Distr(0, [1])));
end;

method ValuesTest.TestDistrEq;
begin
  Assert.IsTrue(Values.DistrEq(Values.Distr(0, 0), Values.Distr(0, [])));
  Assert.IsTrue(Values.DistrEq(Values.Distr(0, [1]), Values.Distr(0, [1])));

  Assert.IsFalse(Values.DistrEq(Values.Distr(0, [1]), Values.Distr(0, [2])));
  Assert.IsFalse(Values.DistrEq(Values.Distr(0, [1]), Values.Distr(1, [1])));

  Assert.IsTrue(Values.DistrEq(Values.Distr(0, [0.0, 1.0, 1.0]), Values.Distr(1, [1.0, 1.0])));
  Assert.IsTrue(Values.DistrEq(Values.Distr(0, [0.0, 1.0, 1.0, 0.1]), Values.Distr(1, [1.0, 1.0, 0.1])));
  Assert.IsFalse(Values.DistrEq(Values.Distr(0, [0.0, 1.0, 1.0, 0.1]), Values.Distr(1, [1.0, 1.0, 0.2])));
end;

method ValuesTest.TestDistrProperties;

  method CheckProperties(aDistr: Distribution; xLength, xCount, xLowIdx, xHighIdx, xLow, xHigh: Integer; xMin, xMax, xMedium, xSum: Float);
  begin
    Assert.AreEqual(Values.DistrLength(aDistr), xLength);
    Assert.AreEqual(Values.DistrCount(aDistr), xCount);
    Assert.AreEqual(Values.DistrLowIndex(aDistr), xLowIdx);
    Assert.AreEqual(Values.DistrHighIndex(aDistr), xHighIdx);
    Assert.AreEqual(Values.DistrLow(aDistr), xLow);
    Assert.AreEqual(Values.DistrHigh(aDistr), xHigh);
    Assert.IsTrue(Utils.FloatEq(Values.DistrMin(aDistr), xMin));
    Assert.IsTrue(Utils.FloatEq(Values.DistrMax(aDistr), xMax));
    Assert.IsTrue(Utils.FloatEq(Values.DistrMedium(aDistr), xMedium));
    Assert.IsTrue(Utils.FloatEq(Values.DistrSum(aDistr), xSum));
  end;

begin
  CheckProperties(Values.Distr(0, []),              0, 0, 0, -1, 0, -1, 0.0, 0.0, 0.0, 0.0);
  CheckProperties(Values.Distr(0, [0.0]),           1, 0, 0,  0, 1, -1, 0.0, 0.0, 0.0, 0.0);
  CheckProperties(Values.Distr(0, [1.0]),           1, 1, 0,  0, 0,  0, 1.0, 1.0, 0.0, 1.0);
  CheckProperties(Values.Distr(1, [1.0, 1.0]),      2, 2, 1,  2, 1,  2, 1.0, 1.0, 3.0, 2.0);
  CheckProperties(Values.Distr(1, [1.0, 0.0, 1.0]), 3, 2, 1,  3, 1,  3, 0.0, 1.0, 4.0, 2.0);
  CheckProperties(Values.Distr(1, [0.0, 1.0, 0.0]), 3, 1, 1,  3, 2,  2, 0.0, 1.0, 2.0, 1.0);
  CheckProperties(Values.Distr(1, [0.5, 0.5]),      2, 2, 1,  2, 1,  2, 0.5, 0.5, 1.5, 1.0);
  CheckProperties(Values.Distr(2, [0.5, 0.5]),      2, 2, 2,  3, 2,  3, 0.5, 0.5, 2.5, 1.0);
end;

method ValuesTest.TestDistrNorm;

  method CheckNorm(aDistr: Distribution; aNorm: Normalization; xBase: Integer; xDistr: FltArray);
  begin
    var lDistr := Values.Normed(aDistr, Normalization.normNone);
    CheckDistr(lDistr, aDistr.Base, aDistr.Distr);

    lDistr := Values.Normed(aDistr, aNorm);
    CheckDistr(lDistr, xBase, xDistr);
  end;

begin
  CheckNorm(Values.Distr(0, 0), Normalization.normProb, 0, []);
  CheckNorm(Values.Distr(0, []), Normalization.normFuzzy, 0, []);
  CheckNorm(Values.Distr(1, []), Normalization.normOrd, 1, []);

  CheckNorm(Values.Distr(1, [1.0, 1.0]), Normalization.normSet,   1, [1.0, 1.0]);
  CheckNorm(Values.Distr(1, [1.0, 1.0]), Normalization.normProb,  1, [1.0/2, 1.0/2]);
  CheckNorm(Values.Distr(1, [1.0, 1.0]), Normalization.normFuzzy, 1, [1.0, 1.0]);

  CheckNorm(Values.Distr(1, [0.1, 0.0, 0.4]), Normalization.normSet,   1, [1.0, 0.0, 1.0]);
  CheckNorm(Values.Distr(1, [0.1, 0.0, 0.4]), Normalization.normProb,  1, [0.2, 0.0, 0.8]);
  CheckNorm(Values.Distr(1, [0.1, 0.0, 0.4]), Normalization.normFuzzy, 1, [1.0/4, 0.0, 1.0]);
end;

method ValuesTest.TestDistrExpand;
begin
  var lDistr := Values.Distr(2, [1.0, 1.0]);
  CheckDistr(lDistr, 2, [1.0, 1.0]);

  Values.DistrExpand(var lDistr, 2);
  CheckDistr(lDistr, 2, [1.0, 1.0]);

  Values.DistrExpand(var lDistr, 3);
  CheckDistr(lDistr, 2, [1.0, 1.0]);

  Values.DistrExpand(var lDistr, 4);
  CheckDistr(lDistr, 2, [1.0, 1.0, 0.0]);

  Values.DistrExpand(var lDistr, 7);
  CheckDistr(lDistr, 2, [1.0, 1.0, 0.0, 0.0, 0.0, 0.0]);

  Values.DistrExpand(var lDistr, 0);
  CheckDistr(lDistr, 0, [0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0]);
end;

method ValuesTest.TestDistrCompact;

  method CheckCompact(aDistr: Distribution; xBase: Integer; xDistr: FltArray);
  begin
    var lDistr := Values.DistrCompact(aDistr);
    CheckDistr(lDistr, xBase, xDistr);
  end;

begin
  CheckCompact(Values.Distr(0, 0), 0, []);
  CheckCompact(Values.Distr(0, []), 0, []);

  CheckCompact(Values.Distr(1, [1.0, 1.0]), 1, [1.0, 1.0]);
  CheckCompact(Values.Distr(1, [0.1, 0.2, 0.3]), 1, [0.1, 0.2, 0.3]);
  CheckCompact(Values.Distr(1, [0.1, 0.0, 0.3]), 1, [0.1, 0.0, 0.3]);
  CheckCompact(Values.Distr(1, [0.1, 0.2, 0.0]), 1, [0.1, 0.2]);
  CheckCompact(Values.Distr(1, [0.0, 0.2, 0.3]), 2, [0.2, 0.3]);
  CheckCompact(Values.Distr(1, [0.0, 0.0, 0.3]), 3, [0.3]);
  CheckCompact(Values.Distr(1, [0.0, 0.0, 0.0]), 0, []);
end;

method ValuesTest.TestDistrGetSet;

  method CheckGet(aDistr: Distribution; aFrom, aTo: Integer; aGet: FltArray);
  begin
    for i := aFrom to aTo do
      Assert.AreEqual(Values.GetDistribution(aDistr, i), aGet[i - aFrom]);
  end;

begin
  var lDistr := Values.Distr(1, [0.1, 0.2]);
  CheckGet(lDistr, 0, 5, [0.0, 0.1, 0.2, 0.0, 0.0, 0.0]);

  Values.SetDistribution(var lDistr, 1, 1.0);
  CheckGet(lDistr, 0, 5, [0.0, 1.0, 0.2, 0.0, 0.0, 0.0]);

  Values.SetDistribution(var lDistr, 2, 2.0);
  CheckGet(lDistr, 0, 5, [0.0, 1.0, 2.0, 0.0, 0.0, 0.0]);

  Values.SetDistribution(var lDistr, 3, 3.0);
  CheckGet(lDistr, 0, 5, [0.0, 1.0, 2.0, 0.0, 0.0, 0.0]);

  Values.SetDistribution(var lDistr, 3, 3.0, true);
  CheckGet(lDistr, 0, 5, [0.0, 1.0, 2.0, 3.0, 0.0, 0.0]);
end;

method ValuesTest.TestDistrMul;
begin
  var lDistr := Values.Distr(1, [0.5, 1.0]);
  Values.DistrMul(var lDistr, 2.0);
  CheckDistr(lDistr, 1, [1.0, 2.0]);
end;

method ValuesTest.TestDistrDiv;
begin
  var lDistr := Values.Distr(1, [1.0, 2.0]);
  Values.DistrDiv(var lDistr, 2.0);
  CheckDistr(lDistr, 1, [0.5, 1.0]);

  Values.DistrDiv(var lDistr, 1.0);
  CheckDistr(lDistr, 1, [0.5, 1.0]);

  Values.DistrDiv(var lDistr, 0.0);
  CheckDistr(lDistr, 1, [0.5, 1.0]);
end;

method ValuesTest.TestDistrBound;
begin
  var lDistr := Values.Distr(1, [1.0, 2.0, 3.0, 4.0, 5.0]);
  var lBound := Values.IntoBounds(lDistr, 2, 3);
  CheckDistr(lBound, 1, [0.0, 2.0, 3.0, 0.0, 0.0]);

  lBound := Values.IntoBounds(lDistr, 0, 4);
  CheckDistr(lBound, 1, [1.0, 2.0, 3.0, 4.0, 0.0]);

  lBound := Values.IntoBounds(lDistr, 5, 8);
  CheckDistr(lBound, 1, [0.0, 0.0, 0.0, 0.0, 5.0]);
end;

method ValuesTest.TestDistrModify;
begin
  var lNull := Values.Distr(0, []);
  var lDistr := Values.Distr(1, [1.0, 2.0, 3.0, 4.0, 5.0]);

  CheckDistr(Values.DistrInsertValue(lNull, 0), 0, [0.0]);
  CheckDistr(Values.DistrInsertValue(lDistr, 2), 1, [1.0, 0.0, 2.0, 3.0, 4.0, 5.0]);
  CheckDistr(Values.DistrInsertValue(lDistr, 7), 1, [1.0, 2.0, 3.0, 4.0, 5.0, 0.0, 0.0]);
  CheckDistr(Values.DistrInsertValue(lDistr, 0), 0, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]);

  CheckDistr(Values.DistrDeleteValue(lNull, 0), 0, []);
  CheckDistr(Values.DistrDeleteValue(lDistr, 2), 1, [1.0, 3.0, 4.0, 5.0, 0.0]);
  CheckDistr(Values.DistrDeleteValue(lDistr, 7), 1, [1.0, 2.0, 3.0, 4.0, 5.0]);
  CheckDistr(Values.DistrDeleteValue(lDistr, 0), 1, [2.0, 3.0, 4.0, 5.0, 0.0]);

  CheckDistr(Values.DistrDuplicateValue(lNull, 0), 1, [0.0]);
  CheckDistr(Values.DistrDuplicateValue(lDistr, 2), 1, [1.0, 2.0, 2.0, 3.0, 4.0, 5.0]);
  CheckDistr(Values.DistrDuplicateValue(lDistr, 7), 1, [1.0, 2.0, 3.0, 4.0, 5.0, 0.0, 0.0, 0.0]);
  CheckDistr(Values.DistrDuplicateValue(lDistr, 0), 1, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]);

  CheckDistr(Values.DistrMergeValue(lNull, 0, 0), 0, []);
  CheckDistr(Values.DistrMergeValue(lNull, 0, 1), 0, []);
  CheckDistr(Values.DistrMergeValue(lDistr, 2, 2), lDistr.Base, lDistr.Distr);
  CheckDistr(Values.DistrMergeValue(lDistr, 2, 3), 1, [1.0, 5.0, 4.0, 5.0, 0.0]);
  CheckDistr(Values.DistrCompact(Values.DistrMergeValue(lDistr, 2, 3)), 1, [1.0, 5.0, 4.0, 5.0]);
  CheckDistr(Values.DistrMergeValue(lDistr, 2, 3, Normalization.normFuzzy), 1, [1.0, 3.0, 4.0, 5.0, 0.0]);
  CheckDistr(Values.DistrMergeValue(lDistr, 2, 3, Normalization.normProb), 1, [1.0, 5.0, 4.0, 5.0, 0.0]);

  CheckDistr(Values.DistrMoveValue(lNull, 0, 0), 0, []);
  CheckDistr(Values.DistrMoveValue(lNull, 0, 1), 0, []);
  CheckDistr(Values.DistrMoveValue(lDistr, 2, 2), lDistr.Base, lDistr.Distr);
  CheckDistr(Values.DistrMoveValue(lDistr, 2, 3), 1, [1.0, 3.0, 2.0, 4.0, 5.0]);
  CheckDistr(Values.DistrMoveValue(lDistr, 3, 2), 1, [1.0, 3.0, 2.0, 4.0, 5.0]);
  CheckDistr(Values.DistrMoveValue(lDistr, 1, 5), 1, [2.0, 3.0, 4.0, 5.0, 1.0]);
  CheckDistr(Values.DistrMoveValue(lDistr, 1, 6), 1, [2.0, 3.0, 4.0, 5.0, 0.0, 1.0]);
  CheckDistr(Values.DistrMoveValue(lDistr, 6, 2), 1, [1.0, 0.0, 2.0, 3.0, 4.0, 5.0]);

  CheckDistr(Values.DistrReverse(lNull, 0, 0), 0, []);
  CheckDistr(Values.DistrReverse(lNull, 0, 1), 0, []);
  CheckDistr(Values.DistrReverse(lDistr, 1, 2), -2, [5.0, 4.0, 3.0, 2.0, 1.0]);
  CheckDistr(Values.DistrReverse(lDistr, 1, 5), 1, [5.0, 4.0, 3.0, 2.0, 1.0]);
  CheckDistr(Values.DistrReverse(lDistr, 1, 6), 2, [5.0, 4.0, 3.0, 2.0, 1.0]);
  CheckDistr(Values.DistrReverse(lDistr, 0, 5), 0, [5.0, 4.0, 3.0, 2.0, 1.0]);
end;

method ValuesTest.TestDistrStr;
var lInvariant: Boolean;

  method CheckStr(aDistr: Distribution; x: String);
  begin
    var s := Values.DistrToStr(aDistr, lInvariant);
    Assert.AreEqual(s, x);
    var lDistr := Values.StrToDistr(s, lInvariant);
    Assert.IsTrue(Values.DistrEq(lDistr, aDistr));
  end;

begin
  lInvariant := true;
  CheckStr(Values.Distr(0, 0), '');
  CheckStr(Values.Distr(0, []), '');
  CheckStr(Values.Distr(0, [0.0]), '');
  CheckStr(Values.Distr(1, [0.0, 0.0]), '');
  CheckStr(Values.Distr(0, [1.0]), '0:1');
  CheckStr(Values.Distr(0, [0.1]), '0:0.1');
  CheckStr(Values.Distr(0, [0.1, 0.2]), '0:0.1;1:0.2');
  CheckStr(Values.Distr(0, [0.1, 0.0, 0.3]), '0:0.1;2:0.3');
  CheckStr(Values.Distr(5, [0.5, 0.0, 0.7]), '5:0.5;7:0.7');
end;

method ValuesTest.TestIsIntSingle;
begin
  Assert.IsTrue(Values.IsIntSingle(Values.IntInt(1, 1)));
  Assert.IsFalse(Values.IsIntSingle(Values.IntInt(1, 2)));
  Assert.IsFalse(Values.IsIntSingle(Values.IntInt(1, 0)));

  Assert.IsTrue(Values.IsIntSingle([1]));
  Assert.IsTrue(Values.IsIntSingle(Values.Normed([1, 1, 1])));
  Assert.IsFalse(Values.IsIntSingle([1, 1, 1]));
  Assert.IsFalse(Values.IsIntSingle([]));
  Assert.IsFalse(Values.IsIntSingle([1, 2, 1]));

  Assert.IsTrue(Values.IsIntSingle(Values.Distr(1, [1.0])));
  Assert.IsTrue(Values.IsIntSingle(Values.Distr(0, [0.0, 1.0])));
  Assert.IsTrue(Values.IsIntSingle(Values.Distr(0, [0.0, 1.0, 0.0])));
  Assert.IsTrue(Values.IsIntSingle(Values.Distr(1, [0.3, 0.0])));
  Assert.IsTrue(Values.IsIntSingle(Values.Distr(1, [0.3])));
  Assert.IsFalse(Values.IsIntSingle(Values.Distr(0, [1.0, 1.0, 1.0])));
  Assert.IsFalse(Values.IsIntSingle(Values.Distr(1, [0.0, 0.0])));
  Assert.IsFalse(Values.IsIntSingle(Values.Distr(0, [])));
end;

method ValuesTest.TestIsIntInt;
begin
  Assert.IsTrue(Values.IsIntInt(Values.Distr(1, [1.0])));
  Assert.IsTrue(Values.IsIntInt(Values.Distr(0, [0.0, 1.0])));
  Assert.IsTrue(Values.IsIntInt(Values.Distr(0, [0.0, 1.0, 0.0])));
  Assert.IsTrue(Values.IsIntInt(Values.Distr(0, [1.0, 1.0, 0.0])));
  Assert.IsTrue(Values.IsIntInt(Values.Distr(0, [1.0, 1.0, 1.0])));
  Assert.IsTrue(Values.IsIntInt(Values.Distr(0, [0.0, 1.0, 1.0])));
  Assert.IsFalse(Values.IsIntInt(Values.Distr(1, [0.3])));
  Assert.IsFalse(Values.IsIntInt(Values.Distr(1, [0.3, 0.0])));
  Assert.IsFalse(Values.IsIntInt(Values.Distr(0, [1.0, 0.0, 1.0])));
  Assert.IsFalse(Values.IsIntInt(Values.Distr(1, [0.0, 0.0])));
  Assert.IsFalse(Values.IsIntInt(Values.Distr(0, [])));
end;

method ValuesTest.TestIsIntSet;
begin
  Assert.IsTrue(Values.IsIntSet(Values.Distr(1, [1.0])));
  Assert.IsTrue(Values.IsIntSet(Values.Distr(1, [1.0, 1.0])));
  Assert.IsTrue(Values.IsIntSet(Values.Distr(1, [1.0, 1.0, 0.0, 1.0])));
  Assert.IsFalse(Values.IsIntSet(Values.Distr(1, [1.0, 0.5])));
  Assert.IsFalse(Values.IsIntSet(Values.Distr(1, [1.0, 0.5, 0.2])));
  Assert.IsFalse(Values.IsIntSet(Values.Distr(1, [1.0, 0.0, 0.2])));
end;


method ValuesTest.TestIsFltSingle;
begin
  Assert.IsTrue(Values.IsFltSingle(Values.FltInt(1, 1)));
  Assert.IsTrue(Values.IsFltSingle(Values.FltInt(1.1, 1.1)));
  Assert.IsFalse(Values.IsFltSingle(Values.FltInt(1.5, 2.5)));
  Assert.IsFalse(Values.IsFltSingle(Values.FltInt(1, 2)));
  Assert.IsFalse(Values.IsFltSingle(Values.FltInt(1, 0)));
end;

method ValuesTest.TestCompareIntInterval;
begin
  // CompareIntInterval
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 2), Values.IntInt(1, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 1), Values.IntInt(1, 1)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 2), Values.IntInt(3, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 2), Values.IntInt(2, 3)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 2), Values.IntInt(2, 2)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(2, 2), Values.IntInt(2, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 3), Values.IntInt(2, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 3), Values.IntInt(2, 3)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(2, 3), Values.IntInt(2, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(1, 4), Values.IntInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(3, 4), Values.IntInt(1, 2)) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(3, 4), Values.IntInt(3, 3)) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareIntInterval(Values.IntInt(2, 4), Values.IntInt(1, 3)) = PrefCompare.Greater);

  // CompareIntIntervalStrict
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 2), Values.IntInt(1, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 1), Values.IntInt(1, 1)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 2), Values.IntInt(3, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 2), Values.IntInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 2), Values.IntInt(2, 2)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(2, 2), Values.IntInt(2, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 3), Values.IntInt(2, 4)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 3), Values.IntInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(2, 3), Values.IntInt(2, 4)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(1, 4), Values.IntInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(3, 4), Values.IntInt(1, 2)) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(3, 4), Values.IntInt(3, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntIntervalStrict(Values.IntInt(2, 4), Values.IntInt(1, 3)) = PrefCompare.No);
end;

method ValuesTest.TestCompareFltInterval;
begin
 // CompareFltInterval
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 2), Values.FltInt(1, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 1), Values.FltInt(1, 1)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 2), Values.FltInt(3, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 2), Values.FltInt(2, 3)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 2), Values.FltInt(2, 2)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(2, 2), Values.FltInt(2, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 3), Values.FltInt(2, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 3), Values.FltInt(2, 3)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(2, 3), Values.FltInt(2, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(1, 4), Values.FltInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(3, 4), Values.FltInt(1, 2)) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(3, 4), Values.FltInt(3, 3)) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareFltInterval(Values.FltInt(2, 4), Values.FltInt(1, 3)) = PrefCompare.Greater);

  // CompareFltIntervalStrict
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 2), Values.FltInt(1, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 1), Values.FltInt(1, 1)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 2), Values.FltInt(3, 4)) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 2), Values.FltInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 2), Values.FltInt(2, 2)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(2, 2), Values.FltInt(2, 2)) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 3), Values.FltInt(2, 4)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 3), Values.FltInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(2, 3), Values.FltInt(2, 4)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(1, 4), Values.FltInt(2, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(3, 4), Values.FltInt(1, 2)) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(3, 4), Values.FltInt(3, 3)) = PrefCompare.No);
  Assert.IsTrue(Values.CompareFltIntervalStrict(Values.FltInt(2, 4), Values.FltInt(1, 3)) = PrefCompare.No);
end;

method ValuesTest.TestCompareIntSet;
begin
 // CompareIntSet
  Assert.IsTrue(Values.CompareIntSet([], []) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntSet([1], []) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSet([], [1]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSet([1], [1]) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntSet([2], [1]) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareIntSet([1], [2]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSet([1, 2], [3, 4]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSet([1, 2], [2, 3, 4]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSet([1, 4], [2, 3]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSet([1, 3, 5], [2, 4]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSet([1, 4, 5], [2, 4]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSet([1, 4, 5], [4, 5]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSet([1, 4], [1, 4, 5]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSet([4, 5], [4, 5]) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntSet([1, 4, 5], [4, 5, 6]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSet([1, 4, 5], [4, 5, 6, 8]) = PrefCompare.Lower);

  // CompareIntSetStrict
  Assert.IsTrue(Values.CompareIntSetStrict([], []) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntSetStrict([1], []) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([], [1]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1], [1]) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntSetStrict([2], [1]) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareIntSetStrict([1], [2]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 2], [3, 4]) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 2], [2, 3, 4]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 4], [2, 3]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 3, 5], [2, 4]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 4, 5], [2, 4]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 4, 5], [4, 5]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 4], [1, 4, 5]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([4, 5], [4, 5]) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 4, 5], [4, 5, 6]) = PrefCompare.No);
  Assert.IsTrue(Values.CompareIntSetStrict([1, 4, 5], [4, 5, 6, 8]) = PrefCompare.No);
end;

method ValuesTest.TestCompareDistr;
begin
  // CompareDistrP
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, []), Values.Distr(0, [])) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1.0]), Values.Distr(0, [])) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, []), Values.Distr(0, [0.0, 1.0])) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [1.0]), Values.Distr(0, [1.0])) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1]), Values.Distr(0, [0.0, 1])) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1]), Values.Distr(0, [0.0, 0, 1])) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 0, 1]), Values.Distr(0, [0.0, 1])) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1, 1]), Values.Distr(0, [0.0, 1, 0])) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0, 0.5, 0.5]), Values.Distr(0, [0.0, 1, 0])) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1, 1, 1]), Values.Distr(0, [0.0, 1, 1, 1])) = PrefCompare.Equal);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1, 1, 0, 1]), Values.Distr(0, [0.0, 1, 1, 1, 0])) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1, 0, 1, 1]), Values.Distr(0, [0.0, 1, 1, 0, 1])) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [0.0, 1, 0, 1, 1, 0]), Values.Distr(0, [0.0, 1, 1, 0, 0, 1])) = PrefCompare.No);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [1.0, 1, 1]), Values.Distr(0, [1, 0.5, 1])) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [1.0, 1, 1]), Values.Distr(0, [1, 0.5, 1, 0.1])) = PrefCompare.Lower);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [1, 0.4, 0.0, 0.5]), Values.Distr(0, [1, 0.5, 0.0, 0.4])) = PrefCompare.Greater);
  Assert.IsTrue(Values.CompareDistr(Values.Distr(0, [1, 0.4, 0.0, 0.6]), Values.Distr(0, [1, 0.5, 0.0, 0.4])) = PrefCompare.No);
end;

method ValuesTest.TestIntoBounds;
begin
  // IntSingle
  Assert.AreEqual(Values.IntoBounds(1, 1, 1), 1);
  Assert.AreEqual(Values.IntoBounds(2, 1, 1), 1);
  Assert.AreEqual(Values.IntoBounds(0, 1, 1), 1);

  Assert.AreEqual(Values.IntoBounds(0, 1, 3), 1);
  Assert.AreEqual(Values.IntoBounds(1, 1, 3), 1);
  Assert.AreEqual(Values.IntoBounds(2, 1, 3), 2);
  Assert.AreEqual(Values.IntoBounds(3, 1, 3), 3);
  Assert.AreEqual(Values.IntoBounds(4, 1, 3), 3);

  Assert.AreEqual(Values.IntoBounds(0, 3, 1), 1);
  Assert.AreEqual(Values.IntoBounds(1, 3, 1), 1);
  Assert.AreEqual(Values.IntoBounds(2, 3, 1), 2);
  Assert.AreEqual(Values.IntoBounds(3, 3, 1), 3);
  Assert.AreEqual(Values.IntoBounds(4, 3, 1), 3);

  // FltSingle
  Assert.AreEqual(Values.IntoBounds(1.0, 1, 1), 1);
  Assert.AreEqual(Values.IntoBounds(2.0, 1, 1), 1);
  Assert.AreEqual(Values.IntoBounds(0.0, 1, 1), 1);

  Assert.AreEqual(Values.IntoBounds(0.0, 1, 3), 1);
  Assert.AreEqual(Values.IntoBounds(1.0, 1, 3), 1);
  Assert.AreEqual(Values.IntoBounds(2.0, 1, 3), 2);
  Assert.AreEqual(Values.IntoBounds(3.0, 1, 3), 3);
  Assert.AreEqual(Values.IntoBounds(4.0, 1, 3), 3);


  Assert.AreEqual(Values.IntoBounds(0.0, 3, 1), 1);
  Assert.AreEqual(Values.IntoBounds(1.0, 3, 1), 1);
  Assert.AreEqual(Values.IntoBounds(2.0, 3, 1), 2);
  Assert.AreEqual(Values.IntoBounds(3.0, 3, 1), 3);
  Assert.AreEqual(Values.IntoBounds(4.0, 3, 1), 3);
  Assert.AreEqual(Values.IntoBounds(2.999, 3, 1), 2.999);
  Assert.AreEqual(Values.IntoBounds(3.001, 3, 1), 3);

  // IntInterval
  CheckInterval(Values.IntoBounds(Values.IntInt(1, 1), 1, 1), 1, 1);
  CheckInterval(Values.IntoBounds(Values.IntInt(1, 2), 1, 1), 1, 1);
  CheckInterval(Values.IntoBounds(Values.IntInt(0, 2), 1, 1), 1, 1);

  CheckInterval(Values.IntoBounds(Values.IntInt(1, 1), 1, 3), 1, 1);
  CheckInterval(Values.IntoBounds(Values.IntInt(1, 4), 1, 3), 1, 3);
  CheckInterval(Values.IntoBounds(Values.IntInt(0, 3), 1, 3), 1, 3);
  CheckInterval(Values.IntoBounds(Values.IntInt(0, 4), 1, 3), 1, 3);
  CheckInterval(Values.IntoBounds(Values.IntInt(1, 2), 0, 3), 1, 2);

  // FltInterval
  CheckInterval(Values.IntoBounds(Values.FltInt(1, 1), 1, 1), 1, 1);
  CheckInterval(Values.IntoBounds(Values.FltInt(1, 2), 1, 1), 1, 1);
  CheckInterval(Values.IntoBounds(Values.FltInt(0, 2), 1, 1), 1, 1);

  CheckInterval(Values.IntoBounds(Values.FltInt(1, 1), 1, 3), 1, 1);
  CheckInterval(Values.IntoBounds(Values.FltInt(1, 4), 1, 3), 1, 3);
  CheckInterval(Values.IntoBounds(Values.FltInt(0, 3), 1, 3), 1, 3);
  CheckInterval(Values.IntoBounds(Values.FltInt(0, 4), 1, 3), 1, 3);
  CheckInterval(Values.IntoBounds(Values.FltInt(1, 2), 0, 3), 1, 2);
end;

end.
