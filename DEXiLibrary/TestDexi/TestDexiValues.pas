namespace DexiLibrary.Tests;

interface

uses
  DexiUtils,
  DexiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiValuesTest = public class(DexiLibraryTest)
  private
    method CheckValueType(aValue: DexiValue; aType: DexiValueType);
    method CheckIs(aValue: DexiValue; aInteger,  aFloat,  aSingle, aInterval,  aSet,  aDistribution, aDefined: Boolean);
    method CheckHas(aValue: DexiValue; aIntSingle,  aIntInterval,  aIntSet,  aFltSingle: Boolean);
    method CheckLowHigh(aValue: DexiValue; aLowInt, aHighInt: Integer; aLowFloat,  aHighFloat: Float);
    method CheckAs(aValue: DexiValue; aStr: String; aInt: Integer; aFlt: Float; aIntInt: IntInterval; aFltInt: FltInterval; aIntSet: IntSet; aDistr: Distribution);
    method CheckMembers(aValue: DexiValue; aIn, aOut: IntArray);
    method CheckMembers(aValue: DexiValue; aIn, aOut: FltArray);
  protected
  public
    method TestCreateValue;
    method TestCopyValue;
    method TestIntSingle;
    method TestIntInterval;
    method TestIntSet;
    method TestDistribution;
    method TestFltSingle;
    method TestFltInterval;
    method TestUndefined;
    method TestCompareIntSingle;
    method TestCompareIntInterval;
    method TestCompareIntSet;
    method TestCompareDistribution;
    method TestCompareFltSingle;
    method TestCompareFltInterval;
    method TestCanAssignLosslessly;
    method TestSimplify;
    method TestCompact;
    method TestFromToString;
    method TestBoundIntSingle;
    method TestBoundIntInterval;
    method TestBoundIntSet;
    method TestBoundDistribution;
    method TestBoundFltSingle;
    method TestBoundFltInterval;
    method TestCrossAssign;
  end;

implementation

method DexiValuesTest.CheckValueType(aValue: DexiValue; aType: DexiValueType);
begin
  Assert.IsTrue(aValue.ValueType = aType);
end;

method DexiValuesTest.CheckIs(aValue: DexiValue; aInteger,  aFloat,  aSingle, aInterval,  aSet,  aDistribution, aDefined: Boolean);
begin
  Assert.AreEqual(aValue.IsInteger, aInteger);
  Assert.AreEqual(aValue.IsFloat, aFloat);
  Assert.AreEqual(aValue.IsSingle, aSingle);
  Assert.AreEqual(aValue.IsInterval, aInterval);
  Assert.AreEqual(aValue.IsSet, aSet);
  Assert.AreEqual(aValue.IsDistribution, aDistribution);
  Assert.AreEqual(aValue.IsDefined, aDefined);
end;

method DexiValuesTest.CheckHas(aValue: DexiValue; aIntSingle,  aIntInterval,  aIntSet,  aFltSingle: Boolean);
begin
  Assert.AreEqual(aValue.HasIntSingle, aIntSingle);
  Assert.AreEqual(aValue.HasIntInterval, aIntInterval);
  Assert.AreEqual(aValue.HasIntSet, aIntSet);
  Assert.AreEqual(aValue.HasFltSingle, aFltSingle);
end;

method DexiValuesTest.CheckLowHigh(aValue: DexiValue; aLowInt, aHighInt: Integer; aLowFloat,  aHighFloat: Float);
begin
  Assert.AreEqual(aValue.LowInt, aLowInt);
  Assert.AreEqual(aValue.HighInt, aHighInt);
  Assert.IsTrue(Utils.FloatEq(aValue.LowFloat, aLowFloat));
  Assert.IsTrue(Utils.FloatEq(aValue.HighFloat, aHighFloat));
end;

method DexiValuesTest.CheckAs(aValue: DexiValue; aStr: String; aInt: Integer; aFlt: Float; aIntInt: IntInterval; aFltInt: FltInterval; aIntSet: IntSet; aDistr: Distribution);
begin
  Assert.AreEqual(aValue.AsString, aStr);
  Assert.AreEqual(aValue.AsInteger, aInt);
  Assert.IsTrue(Utils.FloatEq(aValue.AsFloat, aFlt));
  Assert.IsTrue(Values.IntIntEq(aValue.AsIntInterval, aIntInt));
  Assert.IsTrue(Values.FltIntEq(aValue.AsFltInterval, aFltInt));
  Assert.IsTrue(Values.IntSetEq(aValue.AsIntSet, aIntSet));
  Assert.IsTrue(Values.DistrEq(aValue.AsDistribution, aDistr));
end;

method DexiValuesTest.CheckMembers(aValue: DexiValue; aIn, aOut: IntArray);
begin
  for i in aIn do
    Assert.IsTrue(aValue.Member(i));
  for i in aOut do
    Assert.IsFalse(aValue.Member(i));
end;

method DexiValuesTest.CheckMembers(aValue: DexiValue; aIn, aOut: FltArray);
begin
  for f in aIn do
    Assert.IsTrue(aValue.Member(f));
  for f in aOut do
    Assert.IsFalse(aValue.Member(f));
end;

method DexiValuesTest.TestCreateValue;

  method CheckType(aType: DexiValueType);
  begin
    var lVal := DexiValue.CreateValue(aType);
    CheckValueType(lVal, aType);
  end;

begin
  var lNone := DexiValue.CreateValue(DexiValueType.None);
  Assert.AreEqual(lNone, nil);
  CheckType(DexiValueType.Undefined);
  CheckType(DexiValueType.IntSingle);
  CheckType(DexiValueType.IntInterval);
  CheckType(DexiValueType.IntSet);
  CheckType(DexiValueType.Distribution);
  CheckType(DexiValueType.FltSingle);
  CheckType(DexiValueType.FltInterval);
end;

method DexiValuesTest.TestCopyValue;

  method CheckCopy(aValue: not nullable DexiValue);
  begin
    var lValue := DexiValue.CopyValue(aValue);
    Assert.IsNotNil(lValue);
    Assert.AreNotEqual(aValue, lValue);
    Assert.AreEqual(aValue.ValueType, lValue.ValueType);
    Assert.AreEqual(aValue.ToString, lValue.ToString);
    if aValue is not DexiUndefinedValue then
      Assert.IsTrue(aValue.EqualTo(lValue));
  end;

begin
  var lNil := DexiValue.CopyValue(nil);
  Assert.AreEqual(lNil, nil);

  CheckCopy(new DexiUndefinedValue);
  CheckCopy(new DexiIntSingle(2));
  CheckCopy(new DexiIntInterval(1, 2));
  CheckCopy(new DexiIntSet([]));
  CheckCopy(new DexiIntSet([1, 2, 3]));
  CheckCopy(new DexiDistribution(1, [0.3, 0.7]));
  CheckCopy(new DexiFltSingle(2.0));
  CheckCopy(new DexiFltInterval(1.1, 2.2));
end;

method DexiValuesTest.TestIntSingle;
  var V: DexiIntSingle;

  method CheckValue(aValue: Integer);
  begin
    Assert.AreEqual(V.Value, aValue);
  end;

begin
  V := new DexiIntSingle;
  var W := DexiValue.CreateValue(V.ValueType) as DexiIntSingle;

  V.Value := 1;
  Assert.AreEqual(V.ValueType, DexiValueType.IntSingle);
  Assert.AreEqual(W.ValueType, DexiValueType.IntSingle);

  CheckIs(V, true, false, true, false, false, false, true);
  CheckHas(V, true, true, true, true);
  Assert.AreEqual(V.ValueSize, 1);
  CheckLowHigh(V, 1, 1, 1, 1);
  CheckAs(V, '1', 1, 1, Values.IntInt(1), Values.FltInt(1), Values.IntSet([1]), Values.Distr(1, [1.0]));
  CheckMembers(V, [1], [0, 2, -1]);
  CheckMembers(V, [1.0], [0.0, 2, -1]);

  // normalize
  V.Normalize;
  CheckValue(1);

  // assigning
  V.AsInteger := 2;
  CheckValue(2);
  V.AsFloat := 3.3;
  CheckValue(3);
  V.AsIntInterval := Values.IntInt(3, 5);
  CheckValue(4);
  V.AsFltInterval := Values.FltInt(0.9, 2.9);
  CheckValue(2);
  V.AsIntSet := Values.IntSet(Values.Normed([3, 5, 1, 11]));
  CheckValue(4);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.6, 0]);
  CheckValue(2);
  V.AsDistribution := Values.Distr(1, [0.5, 0.0, 0.6]);
  CheckValue(2);

  // Equal & assignValue
  W.Value := V.Value;
  Assert.IsTrue(V.EqualTo(W));
  W.Value := -1;
  Assert.IsFalse(V.EqualTo(W));
  W.AssignValue(V);
  Assert.IsTrue(V.EqualTo(W));
end;

method DexiValuesTest.TestIntInterval;
var V: DexiIntInterval;

  method CheckValue(aLow, aHigh: Integer);
  begin
    var lIntInt := Values.IntInt(aLow, aHigh);
    Assert.IsTrue(Values.IntIntEq(V.Value, lIntInt));
  end;

begin
  V := new DexiIntInterval;
  var W := DexiValue.CreateValue(V.ValueType) as DexiIntInterval;

  V.Value := Values.IntInt(1);
  Assert.IsTrue(V.ValueType = DexiValueType.IntInterval);
  Assert.IsTrue(W.ValueType = DexiValueType.IntInterval);

  CheckIs(V, true, false, false, true, false, false, true);
  CheckHas(V, true, true, true, true);
  Assert.AreEqual(V.ValueSize, 1);
  CheckLowHigh(V, 1, 1, 1, 1);
  CheckAs(V, '1', 1, 1, Values.IntInt(1), Values.FltInt(1), Values.IntSet([1]), Values.Distr(1, [1.0]));
  CheckMembers(V, [1], [0, 2, -1]);
  CheckMembers(V, [1.0], [0.0, 2, -1]);

  V.Value := Values.IntInt(1, 2);
  CheckIs(V, true, false, false, true, false, false, true);
  CheckHas(V, false, true, true, false);
  CheckLowHigh(V, 1, 2, 1, 2);
  Assert.AreEqual(V.ValueSize, 2);
  CheckAs(V, '1:2', 1, 1.5, Values.IntInt(1, 2), Values.FltInt(1, 2), Values.IntSet([1, 2]), Values.Distr(1, [1.0, 1.0]));
  CheckMembers(V, [1, 2], [0, 3, -1]);
  CheckMembers(V, [1.0, 2.0], [0.0, 0.9, 2.1, -1]);

  // normalize
  V.Value := Values.IntInt(1, 2);
  V.Normalize;
  CheckValue(1, 2);
  V.Value := Values.IntInt(1, 1);
  V.Normalize;
  CheckValue(1, 1);
  V.Value := Values.IntInt(2, 1);
  V.Normalize;
  CheckValue(1, 2);

  // assigning
  V.AsInteger := 2;
  CheckValue(2, 2);
  V.AsFloat := 3.3;
  CheckValue(3, 3);
  V.AsIntInterval := Values.IntInt(3, 5);
  CheckValue(3, 5);
  V.AsFltInterval := Values.FltInt(0.9, 2.9);
  CheckValue(1, 3);
  V.AsIntSet := Values.IntSet([3, 5, 1, 11]);
  CheckValue(1, 11);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.6, 0]);
  CheckValue(1, 3);
  V.AsDistribution := Values.Distr(1, [0.5, 0.0, 0.6]);
  CheckValue(1, 3);

  // Equal & assignValue
  W.Value := V.Value;
  Assert.IsTrue(V.EqualTo(W));
  W.AsInteger := -1;
  Assert.IsFalse(V.EqualTo(W));
  W.AssignValue(V);
  Assert.IsTrue(V.EqualTo(W));
end;

method DexiValuesTest.TestIntSet;
var V: DexiIntSet;

  method CheckValue(aSet: IntSet);
  begin
    var lIntSet := Values.IntSet(aSet);
    Assert.IsTrue(Values.IntSetEq(V.Value, lIntSet));
  end;

begin
  V := new DexiIntSet;
  var W := DexiValue.CreateValue(V.ValueType) as DexiIntSet;

  V.Value := Values.IntSet([1]);
  Assert.IsTrue(V.ValueType = DexiValueType.IntSet);
  Assert.IsTrue(W.ValueType = DexiValueType.IntSet);

  CheckIs(V, true, false, false, false, true, false, true);
  CheckHas(V, true, true, true, true);
  CheckLowHigh(V, 1, 1, 1, 1);
  Assert.AreEqual(V.ValueSize, 1);
  CheckAs(V, '1', 1, 1, Values.IntInt(1), Values.FltInt(1), Values.IntSet([1]), Values. Distr(1, [1.0]));
  CheckMembers(V, [1], [0, 2, -1]);
  CheckMembers(V, [1.0], [0.0, 2, -1]);

  V.Value := Values.IntSet([1, 2]);
  CheckIs(V, true, false, false, false, true, false, true);
  CheckHas(V, false, true, true, false);
  Assert.AreEqual(V.ValueSize, 2);
  CheckLowHigh(V, 1, 2, 1, 2);
  CheckAs(V, '1;2', 2, 1.5, Values.IntInt(1, 2), Values.FltInt(1, 2), Values.IntSet([1, 2]), Values.Distr(1, [1.0, 1.0]));
  CheckMembers(V, [1, 2], [0, 3, -1]);
  CheckMembers(V, [1.0, 2.0], [0.0, 0.9, 2.1, -1]);

  // normalize
  V.Value := Values.IntSet([]);
  V.Normalize;
  CheckValue([]);
  V.Value := Values.IntSet([1, 2]);
  V.Normalize;
  CheckValue([1, 2]);
  V.Value := Values.IntSet([1, 5, 3, 2, 11, 2, 3]);
  V.Normalize;
  CheckValue([1, 2, 3, 5, 11]);

  // assigning
  V.AsInteger := 2;
  CheckValue([2]);
  V.AsFloat := 3.3;
  CheckValue([3]);
  V.AsIntInterval := Values.IntInt(3, 5);
  CheckValue([3, 4, 5]);
  Assert.IsTrue(V.HasIntInterval);
  V.AsFltInterval := Values.FltInt(0.9, 2.9);
  CheckValue([1, 2, 3]);
  V.AsIntSet := Values.IntSet([3, 5, 1, 11]);
  CheckValue([1, 3, 5, 11]);
  Assert.IsFalse(V.HasIntInterval);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.6, 0]);
  CheckValue([1, 3]);
  V.AsDistribution := Values.Distr(1, [0.5, 0.0, 0.6]);
  CheckValue([1, 3]);

  // Equal & assignValue
  W.Value := V.Value;
  Assert.IsTrue(V.EqualTo(W));
  W.AsInteger := -1;
  Assert.IsFalse(V.EqualTo(W));
  W.AssignValue(V);
  Assert.IsTrue(V.EqualTo(W));
end;

method DexiValuesTest.TestDistribution;
var V: DexiDistribution;

  method CheckValue(aBase: Integer; aDistr: FltArray);
  begin
    var lDistr := Values.Distr(aBase, aDistr);
    Assert.IsTrue(Values.DistrEq(V.Value, lDistr));
  end;

begin
  V := new DexiDistribution;
  var W := DexiValue.CreateValue(V.ValueType) as DexiDistribution;

  V.Value := Values.Distr(0, [0.0, 1]);
  Assert.IsTrue(V.ValueType = DexiValueType.Distribution);
  Assert.IsTrue(W.ValueType = DexiValueType.Distribution);

  CheckIs(V, true, false, false, false, false, true, true);
  Assert.AreEqual(V.ValueSize, 2);
  CheckHas(V, true, true, true, true);
  CheckLowHigh(V, 1, 1, 1, 1);
  CheckAs(V, '1:1', 1, 1, Values.IntInt(1), Values.FltInt(1), Values.IntSet([1]), Values.Distr(1, [1.0]));
  CheckMembers(V, [1], [0, 2, -1]);
  CheckMembers(V, [1.0], [0.0, 2, -1]);

  V.Value := Values.Distr(0, [0.0, 1, 1]);
  CheckIs(V, true, false, false, false, false, true, true);
  CheckHas(V, false, true, true, false);
  Assert.AreEqual(V.ValueSize, 3);
  CheckLowHigh(V, 1, 2, 1, 2);
  CheckAs(V, '1:1;2:1', 2, 1.5, Values.IntInt(1, 2), Values.FltInt(1, 2), Values.IntSet([1, 2]), Values.Distr(1, [1.0, 1.0]));
  CheckMembers(V, [1, 2], [0, 3, -1]);
  CheckMembers(V, [1.0, 2.0], [0.0, 0.9, 2.1, -1]);

  V.Value := Values.Distr(0, [0.0, 1, 0, 1]);
  Assert.AreEqual(V.ValueSize, 4);

  // assigning
  V.AsInteger := 2;
  CheckValue(2, [1]);
  V.AsFloat := 3.3;
  CheckValue(3, [1]);
  V.AsIntInterval := Values.IntInt(3, 5);
  CheckValue(3, [1, 1, 1]);
  Assert.IsTrue(V.HasIntInterval);
  V.AsFltInterval := Values.FltInt(0.9, 2.9);
  CheckValue(1, [1, 1, 1]);
  V.AsIntSet := Values.IntSet([3, 5, 1, 11]);
  CheckValue(1, [1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1]);
  Assert.IsFalse(V.HasIntInterval);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.6, 0]);
  CheckValue(0, [0, 0.5, 0, 0.6, 0]);
  V.AsDistribution := Values.Distr(0, [0.5, 0.0, 0.6]);
  CheckValue(0, [0.5, 0, 0.6]);

  // normalization
  V.Value := Values.EmptyDistr;
  V.Normalize;
  CheckValue(0, []);

  V.Value := Values.Distr(0, [0.0, 0.1, 0.2, 0.5]);
  V.Normalize(Normalization.normNone);
  CheckValue(0, [0.0, 0.1, 0.2, 0.5]);
  V.Normalize(Normalization.normOrd);
  CheckValue(0, [0.0, 0.1, 0.2, 0.5]);

  V.Value := Values.Distr(0, [0.0, 0.1, 0.2, 0.5]);
  V.Normalize(Normalization.normSet);
  CheckValue(0, [0.0, 1.0, 1.0, 1.0]);

  V.Value := Values.Distr(0, [0.0, 0.1, 0.2, 0.5]);
  V.Normalize(Normalization.normProb);
  CheckValue(0, [0.0, 0.1/0.8, 0.2/0.8, 0.5/0.8]);

  V.Value := Values.Distr(0, [0.0, 0.1, 0.2, 0.5]);
  V.Normalize(Normalization.normFuzzy);
  CheckValue(0, [0.0, 0.2, 0.4, 1.0]);

  // Equal & assignValue
  W.Value := V.Value;
  Assert.IsTrue(V.EqualTo(W));
  W.AsInteger := 17;
  Assert.IsFalse(V.EqualTo(W));
  W.AssignValue(V);
  Assert.IsTrue(V.EqualTo(W));
end;

method DexiValuesTest.TestFltSingle;
var V: DexiFltSingle;

  method CheckValue(aValue: Float);
  begin
    Assert.IsTrue(Utils.FloatEq(V.Value, aValue));
  end;

begin
  V := new DexiFltSingle;
  var W := DexiValue.CreateValue(V.ValueType) as DexiFltSingle;

  V.Value := 1.0;
  Assert.IsTrue(V.ValueType = DexiValueType.FltSingle);
  Assert.IsTrue(W.ValueType = DexiValueType.FltSingle);

  CheckIs(V, false, true, true, false, false, false, true);
  Assert.AreEqual(V.ValueSize, 1);
  CheckHas(V, true, true, true, true);
  CheckLowHigh(V, 1, 1, 1, 1);
  CheckAs(V, '1', 1, 1, Values.IntInt(1), Values.FltInt(1), Values.IntSet([1]), Values.Distr(1, [1.0]));
  CheckMembers(V, [1], [0, 2, -1]);
  CheckMembers(V, [1.0], [0.0, 2, -1]);

  V.Value := 1.1;
  CheckIs(V, false, true, true, false, false, false, true);
  CheckHas(V, false, false, false, true);
  Assert.AreEqual(V.ValueSize, 1);
  CheckLowHigh(V, 1, 1, 1.1, 1.1);
  CheckAs(V, '1.1', 1, 1.1, Values.IntInt(1), Values.FltInt(1.1), Values.IntSet([1]), Values.Distr(1, [1.0]));
  CheckMembers(V, [], [1, 0, 2, -1]);
  CheckMembers(V, [1.1], [1.2, 2.1, -1]);

  // assigning
  V.AsInteger := 2;
  CheckValue(2.0);
  V.AsFloat := 3.3;
  CheckValue(3.3);
  V.AsIntInterval := Values.IntInt(3, 5);
  CheckValue(4.0);
  V.AsFltInterval := Values.FltInt(0.9, 2.9);
  CheckValue(1.9);
  V.AsIntSet := Values.IntSet([3, 5, 1, 11]);
  CheckValue(6.0);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.5, 0]);
  CheckValue(2.0);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.6, 0]);
  CheckValue(2.3);
  V.AsDistribution := Values.Distr(0, [0.5, 0.0, 0.5]);
  CheckValue(1.0);
  V.AsDistribution := Values.Distr(0, [0.5, 0.0, 0.6]);
  CheckValue(1.2);
  V.AsDistribution := Values.Distr(1, [0.5, 0.5]);
  CheckValue(1.5);

  // Equal & assignValue
  W.Value := V.Value;
  Assert.IsTrue(V.EqualTo(W));
  W.Value := -1.0;
  Assert.IsFalse(V.EqualTo(W));
  W.AssignValue(V);
  Assert.IsTrue(V.EqualTo(W));
end;

method DexiValuesTest.TestFltInterval;
var V: DexiFltInterval;

  method CheckValue(aLow, aHigh: Float);
  begin
    var lFltInt := Values.FltInt(aLow, aHigh);
    Assert.IsTrue(Values.FltIntEq(V.Value, lFltInt));
  end;

begin
  V := new DexiFltInterval;
  var W := DexiValue.CreateValue(V.ValueType) as DexiFltInterval;

  V.Value := Values.FltInt(1.0);
  Assert.IsTrue(V.ValueType = DexiValueType.FltInterval);
  Assert.IsTrue(W.ValueType = DexiValueType.FltInterval);

  CheckIs(V, false, true, false, true, false, false, true);
  CheckHas(V, true, true, true, true);
  Assert.AreEqual(V.ValueSize, -1);
  CheckLowHigh(V, 1, 1, 1, 1);
  CheckAs(V, '1', 1, 1, Values.IntInt(1), Values.FltInt(1), Values.IntSet([1]), Values.Distr(1, [1.0]));
  CheckMembers(V, [1], [0, 2, -1]);
  CheckMembers(V, [1.0], [0.0, 2, -1]);

  V.Value := Values.FltInt(1.0, 2.0);
  CheckIs(V, false, true, false, true, false, false, true);
  CheckHas(V, false, false, false, false);
  Assert.AreEqual(V.ValueSize, -1);
  CheckLowHigh(V, 1, 2, 1.0, 2.0);
  CheckAs(V, '1:2', 2, 1.5, Values.IntInt(1, 2), Values.FltInt(1, 2), Values.IntSet([1, 2]), Values.Distr(1, [1.0, 1.0]));
  CheckMembers(V, [1, 2], [0, 3, -1]);
  CheckMembers(V, [1.0, 1.5, 2.0], [0.9, 2.1, -1]);

  // normalize
  V.Value := Values.FltInt(1, 2);
  V.Normalize;
  CheckValue(1, 2);
  V.Value := Values.FltInt(1, 1);
  V.Normalize;
  CheckValue(1, 1);
  V.Value := Values.FltInt(2, 1);
  V.Normalize;
  CheckValue(1, 2);

  // assigning
  V.AsInteger := 2;
  CheckValue(2, 2);
  V.AsFloat := 3.3;
  CheckValue(3.3, 3.3);
  V.AsIntInterval := Values.IntInt(3, 5);
  CheckValue(3, 5);
  V.AsFltInterval := Values.FltInt(0.9, 2.9);
  CheckValue(0.9, 2.9);
  V.AsIntSet := Values.IntSet([3, 5, 1, 11]);
  CheckValue(1, 11);
  V.AsDistribution := Values.Distr(0, [0, 0.5, 0, 0.6, 0]);
  CheckValue(1, 3);
  V.AsDistribution := Values.Distr(0, [0.5, 0.0, 0.6]);
  CheckValue(0, 2);

  // Equal & assignValue
  W.Value := V.Value;
  Assert.IsTrue(V.EqualTo(W));
  W.Value := Values.FltInt(1, 17);
  Assert.IsFalse(V.EqualTo(W));
  W.AssignValue(V);
  Assert.IsTrue(V.EqualTo(W));
end;

method DexiValuesTest.TestUndefined;
  var V: DexiUndefinedValue;

  method CheckValue(aValue: DexiValue);
  begin
    Assert.IsTrue(V.SameValue(aValue));
  end;

begin
  V := new DexiUndefinedValue;
  CheckValue(V);
  CheckIs(V, false, false, false, false, false, false, false);
  CheckHas(V, false, false, false, false);

  var W := DexiValue.CreateValue(V.ValueType);
  Assert.IsNotNil(W);
  Assert.IsTrue(W is DexiUndefinedValue);
  CheckIs(W, false, false, false, false, false, false, false);
  CheckHas(W, false, false, false, false);
  CheckValue(W);

  W.AssignValue(V);
  Assert.IsTrue(V.SameValue(W));
  Assert.IsFalse(V.EqualTo(W));
end;

method DexiValuesTest.TestCompareIntSingle;
  var V: DexiIntSingle;

  method Check(aValue: DexiValue; aPref: PrefCompare);
  begin
    Assert.IsTrue(DexiValue.CompareValues(V, aValue, DexiValueMethod.Single) = aPref);
    Assert.IsTrue(V.CompareWith(aValue) = aPref);
  end;

begin
  V := new DexiIntSingle(3);

  Check(nil,                  PrefCompare.No);
  Check(new DexiIntSingle(3), PrefCompare.Equal);
  Check(new DexiIntSingle(1), PrefCompare.Greater);
  Check(new DexiIntSingle(4), PrefCompare.Lower);
  Check(new DexiIntInterval(3, 3), PrefCompare.Equal);
  Check(new DexiIntInterval(1, 2), PrefCompare.Greater);
  Check(new DexiIntInterval(3, 6), PrefCompare.Lower);
  Check(new DexiIntInterval(2, 4), PrefCompare.Equal);
end;

method DexiValuesTest.TestCompareIntInterval;
  var V: DexiIntInterval;

  method Check(aValue: DexiValue; aPref: PrefCompare);
  begin
    Assert.IsTrue(DexiValue.CompareValues(V, aValue, DexiValueMethod.Interval) = aPref);
    Assert.IsTrue(V.CompareWith(aValue) = aPref);
  end;

begin
  V := new DexiIntInterval(3);

  Check(nil,                  PrefCompare.No);
  Check(new DexiIntSingle(3), PrefCompare.Equal);
  Check(new DexiIntSingle(1), PrefCompare.Greater);
  Check(new DexiIntSingle(4), PrefCompare.Lower);
  Check(new DexiIntInterval(3, 3), PrefCompare.Equal);
  Check(new DexiIntInterval(1, 2), PrefCompare.Greater);
  Check(new DexiIntInterval(1, 3), PrefCompare.Greater);
  Check(new DexiIntInterval(4, 6), PrefCompare.Lower);
  Check(new DexiIntInterval(2, 4), PrefCompare.No);
  Check(new DexiIntInterval(3, 4), PrefCompare.Lower);

  V := new DexiIntInterval(3, 5);

  Check(new DexiIntSingle(1), PrefCompare.Greater);
  Check(new DexiIntSingle(3), PrefCompare.Greater);
  Check(new DexiIntSingle(5), PrefCompare.Lower);
  Check(new DexiIntSingle(6), PrefCompare.Lower);
  Check(new DexiIntSingle(4), PrefCompare.No);
  Check(new DexiIntInterval(3, 3), PrefCompare.Greater);
  Check(new DexiIntInterval(1, 2), PrefCompare.Greater);
  Check(new DexiIntInterval(1, 3), PrefCompare.Greater);
  Check(new DexiIntInterval(4, 6), PrefCompare.Lower);
  Check(new DexiIntInterval(2, 4), PrefCompare.Greater);
  Check(new DexiIntInterval(5),    PrefCompare.Lower);
  Check(new DexiIntInterval(5, 6), PrefCompare.Lower);
  Check(new DexiIntInterval(4),    PrefCompare.No);
end;

method DexiValuesTest.TestCompareIntSet;
  var V: DexiIntSet;

  method Check(aValue: DexiValue; aPref: PrefCompare);
  begin
    Assert.IsTrue(DexiValue.CompareValues(V, aValue, DexiValueMethod.Set) = aPref);
    Assert.IsTrue(V.CompareWith(aValue) = aPref);
  end;

begin
  V := new DexiIntSet([1, 2, 3]);

  Check(nil,                  PrefCompare.No);
  Check(new DexiIntSingle(0), PrefCompare.Greater);
  Check(new DexiIntSingle(1), PrefCompare.Greater);
  Check(new DexiIntSingle(2), PrefCompare.No);
  Check(new DexiIntSingle(3), PrefCompare.Lower);
  Check(new DexiIntSingle(4), PrefCompare.Lower);

  Check(new DexiIntSet([]),           PrefCompare.No);
  Check(new DexiIntSet([0]),          PrefCompare.Greater);
  Check(new DexiIntSet([1]),          PrefCompare.Greater);
  Check(new DexiIntSet([0, 1]),       PrefCompare.Greater);
  Check(new DexiIntSet([0, 1, 2]),    PrefCompare.Greater);
  Check(new DexiIntSet([1, 2]),       PrefCompare.Greater);
  Check(new DexiIntSet([1, 2, 3]),    PrefCompare.Equal);
  Check(new DexiIntSet([2, 3]),       PrefCompare.Lower);
  Check(new DexiIntSet([2, 3, 5]),    PrefCompare.Lower);
  Check(new DexiIntSet([1, 2, 3, 5]), PrefCompare.Lower);
  Check(new DexiIntSet([3]),          PrefCompare.Lower);
  Check(new DexiIntSet([3, 5]),       PrefCompare.Lower);
  Check(new DexiIntSet([1, 3]),       PrefCompare.No);
  Check(new DexiIntSet([0, 3]),       PrefCompare.Greater);
  Check(new DexiIntSet([1, 3, 4]),    PrefCompare.Lower);
  Check(new DexiIntSet([0, 1, 3]),    PrefCompare.Greater);
  Check(new DexiIntSet([0, 4]),       PrefCompare.No);
  Check(new DexiIntSet([2]),          PrefCompare.No);
end;

method DexiValuesTest.TestCompareDistribution;
  var V: DexiDistribution;

  method Check(aValue: DexiValue; aPref: PrefCompare);
  begin
    if aValue is DexiIntSet then
      aValue := new DexiDistribution(Values.Normed(aValue.AsDistribution, Normalization.normProb));
    var lPref := DexiValue.CompareValues(V, aValue, DexiValueMethod.Distr);
    Assert.IsTrue(lPref = aPref);
    lPref := V.CompareWith(aValue);
    Assert.IsTrue(lPref = aPref);
  end;

begin
  V := new DexiDistribution(Values.Distr([1, 2, 3]));
  V.Normalize(Normalization.normProb);

  Check(nil,                  PrefCompare.No);
  Check(new DexiIntSingle(0), PrefCompare.Greater);
  Check(new DexiIntSingle(1), PrefCompare.Greater);
  Check(new DexiIntSingle(2), PrefCompare.No);
  Check(new DexiIntSingle(3), PrefCompare.Lower);
  Check(new DexiIntSingle(4), PrefCompare.Lower);

  Check(new DexiIntSet([0]),          PrefCompare.Greater);
  Check(new DexiIntSet([1]),          PrefCompare.Greater);
  Check(new DexiIntSet([0, 1]),       PrefCompare.Greater);
  Check(new DexiIntSet([0, 1, 2]),    PrefCompare.Greater);
  Check(new DexiIntSet([1, 2]),       PrefCompare.Greater);
  Check(new DexiIntSet([1, 2, 3]),    PrefCompare.Equal);
  Check(new DexiIntSet([2, 3]),       PrefCompare.Lower);
  Check(new DexiIntSet([2, 3, 5]),    PrefCompare.Lower);
  Check(new DexiIntSet([1, 2, 3, 5]), PrefCompare.Lower);
  Check(new DexiIntSet([3]),          PrefCompare.Lower);
  Check(new DexiIntSet([3, 5]),       PrefCompare.Lower);
  Check(new DexiIntSet([1, 3]),       PrefCompare.No);
  Check(new DexiIntSet([0, 3]),       PrefCompare.No);
  Check(new DexiIntSet([1, 3, 4]),    PrefCompare.Lower);
  Check(new DexiIntSet([0, 1, 3]),    PrefCompare.Greater);
  Check(new DexiIntSet([0, 4]),       PrefCompare.No);
  Check(new DexiIntSet([2]),          PrefCompare.No);

  V := new DexiDistribution(0, [0.1, 0.2, 0.3]);
  Check(new DexiDistribution(0, [0.1, 0.2, 0.3]), PrefCompare.Equal);
  Check(new DexiDistribution(0, [0.1, 0.2, 0.4]), PrefCompare.Greater);
  Check(new DexiDistribution(0, [0.1, 0.3, 0.3]), PrefCompare.Greater);
  Check(new DexiDistribution(0, [0.2, 0.3, 0.3]), PrefCompare.Greater);
  Check(new DexiDistribution(0, [0.0, 0.2, 0.3]), PrefCompare.Lower);
  Check(new DexiDistribution(0, [0.1, 0.1, 0.3]), PrefCompare.Lower);
  Check(new DexiDistribution(0, [0.1, 0.2, 0.2]), PrefCompare.Lower);
  Check(new DexiDistribution(1, [0.1, 0.2, 0.2]), PrefCompare.Lower);
end;

method DexiValuesTest.TestCompareFltSingle;
  var V: DexiFltSingle;

  method Check(aValue: DexiValue; aPref: PrefCompare);
  begin
    Assert.IsTrue(DexiValue.CompareValues(V, aValue, DexiValueMethod.Single) = aPref);
    Assert.IsTrue(V.CompareWith(aValue) = aPref);
  end;

begin
  V := new DexiFltSingle(3);

  Check(nil,                  PrefCompare.No);
  Check(new DexiFltSingle(3), PrefCompare.Equal);
  Check(new DexiFltSingle(1), PrefCompare.Greater);
  Check(new DexiFltSingle(4), PrefCompare.Lower);
  Check(new DexiFltInterval(3, 3), PrefCompare.Equal);
  Check(new DexiFltInterval(1, 2), PrefCompare.Greater);
  Check(new DexiFltInterval(3, 6), PrefCompare.Lower);
  Check(new DexiFltInterval(2, 4), PrefCompare.Equal);
end;

method DexiValuesTest.TestCompareFltInterval;
  var V: DexiFltInterval;

  method Check(aValue: DexiValue; aPref: PrefCompare);
  begin
    Assert.IsTrue(DexiValue.CompareValues(V, aValue, DexiValueMethod.Interval) = aPref);
    Assert.IsTrue(V.CompareWith(aValue) = aPref);
  end;

begin
  V := new DexiFltInterval(3);

  Check(nil,                  PrefCompare.No);
  Check(new DexiFltSingle(3), PrefCompare.Equal);
  Check(new DexiFltSingle(1), PrefCompare.Greater);
  Check(new DexiFltSingle(4), PrefCompare.Lower);
  Check(new DexiFltInterval(3, 3), PrefCompare.Equal);
  Check(new DexiFltInterval(1, 2), PrefCompare.Greater);
  Check(new DexiFltInterval(1, 3), PrefCompare.Greater);
  Check(new DexiFltInterval(4, 6), PrefCompare.Lower);
  Check(new DexiFltInterval(2, 4), PrefCompare.No);
  Check(new DexiFltInterval(3, 4), PrefCompare.Lower);

  V := new DexiFltInterval(3, 5);

  Check(new DexiFltSingle(1), PrefCompare.Greater);
  Check(new DexiFltSingle(3), PrefCompare.Greater);
  Check(new DexiFltSingle(5), PrefCompare.Lower);
  Check(new DexiFltSingle(6), PrefCompare.Lower);
  Check(new DexiFltSingle(4), PrefCompare.No);
  Check(new DexiFltInterval(3, 3), PrefCompare.Greater);
  Check(new DexiFltInterval(1, 2), PrefCompare.Greater);
  Check(new DexiFltInterval(1, 3), PrefCompare.Greater);
  Check(new DexiFltInterval(4, 6), PrefCompare.Lower);
  Check(new DexiFltInterval(2, 4), PrefCompare.Greater);
  Check(new DexiFltInterval(5),    PrefCompare.Lower);
  Check(new DexiFltInterval(5, 6), PrefCompare.Lower);
  Check(new DexiFltInterval(4),    PrefCompare.No);
end;

method DexiValuesTest.TestCanAssignLosslessly;
  var V: DexiValue;

  method Check(aValue: DexiValue; aCan: Boolean);
  begin
    var lCan := V.CanAssignLosslessly(aValue);
    Assert.AreEqual(lCan, aCan);
  end;

begin
  V := new DexiIntSingle;

  Check(new DexiUndefinedValue, false);
  Check(new DexiIntSingle(1), true);
  Check(new DexiIntInterval(1), true);
  Check(new DexiIntInterval(1, 2), false);
  Check(new DexiIntSet([]), false);
  Check(new DexiIntSet([1]), true);
  Check(new DexiIntSet([1, 2]), false);
  Check(new DexiDistribution(0, []), false);
  Check(new DexiDistribution(1, [0.5]), true);
  Check(new DexiDistribution(1, [1.0]), true);
  Check(new DexiDistribution(1, [1.0, 1.0]), false);
  Check(new DexiFltSingle(1), true);
  Check(new DexiFltSingle(1.1), false);
  Check(new DexiFltInterval(1), true);
  Check(new DexiFltInterval(1.1), false);
  Check(new DexiFltInterval(1, 1.1), false);

  V := new DexiIntInterval;

  Check(new DexiUndefinedValue, false);
  Check(new DexiIntSingle(1), true);
  Check(new DexiIntInterval(1), true);
  Check(new DexiIntInterval(1, 2), true);
  Check(new DexiIntSet([]), false);
  Check(new DexiIntSet([1]), true);
  Check(new DexiIntSet([1, 2]), true);
  Check(new DexiIntSet([1, 3]), false);
  Check(new DexiDistribution(0, []), false);
  Check(new DexiDistribution(1, [0.5]), false);
  Check(new DexiDistribution(1, [1.0]), true);
  Check(new DexiDistribution(1, [1.0, 1.0]), true);
  Check(new DexiDistribution(1, [1.0, 0.0, 1.0]), false);
  Check(new DexiFltSingle(1), true);
  Check(new DexiFltSingle(1.1), false);
  Check(new DexiFltInterval(1), true);
  Check(new DexiFltInterval(1.1), false);
  Check(new DexiFltInterval(1, 1.1), false);

  V := new DexiIntSet;

  Check(new DexiUndefinedValue, false);
  Check(new DexiIntSingle(1), true);
  Check(new DexiIntInterval(1), true);
  Check(new DexiIntInterval(1, 2), true);
  Check(new DexiIntSet([]), true);
  Check(new DexiIntSet([1]), true);
  Check(new DexiIntSet([1, 2]), true);
  Check(new DexiIntSet([1, 3]), true);
  Check(new DexiDistribution(0, []), true);
  Check(new DexiDistribution(1, [0.5]), false);
  Check(new DexiDistribution(1, [1.0]), true);
  Check(new DexiDistribution(1, [1.0, 1.0]), true);
  Check(new DexiDistribution(1, [1.0, 0.0, 1.0]), true);
  Check(new DexiDistribution(1, [1.0, 0.5, 1.0]), false);
  Check(new DexiFltSingle(1), true);
  Check(new DexiFltSingle(1.1), false);
  Check(new DexiFltInterval(1), true);
  Check(new DexiFltInterval(1.1), false);
  Check(new DexiFltInterval(1, 1.1), false);

  V := new DexiDistribution;

  Check(new DexiUndefinedValue, false);
  Check(new DexiIntSingle(1), true);
  Check(new DexiIntInterval(1), true);
  Check(new DexiIntInterval(1, 2), true);
  Check(new DexiIntSet([]), true);
  Check(new DexiIntSet([1]), true);
  Check(new DexiIntSet([1, 2]), true);
  Check(new DexiIntSet([1, 3]), true);
  Check(new DexiDistribution(0, []), true);
  Check(new DexiDistribution(1, [0.5]), true);
  Check(new DexiDistribution(1, [1.0]), true);
  Check(new DexiDistribution(1, [1.0, 1.0]), true);
  Check(new DexiDistribution(1, [1.0, 0.0, 1.0]), true);
  Check(new DexiDistribution(1, [1.0, 0.5, 1.0]), true);
  Check(new DexiFltSingle(1), true);
  Check(new DexiFltSingle(1.1), false);
  Check(new DexiFltInterval(1), true);
  Check(new DexiFltInterval(1.1), false);
  Check(new DexiFltInterval(1, 1.1), false);

  V := new DexiFltSingle;

  Check(new DexiUndefinedValue, false);
  Check(new DexiIntSingle(1), true);
  Check(new DexiIntInterval(1), true);
  Check(new DexiIntInterval(1, 2), false);
  Check(new DexiIntSet([]), false);
  Check(new DexiIntSet([1]), true);
  Check(new DexiIntSet([1, 2]), false);
  Check(new DexiIntSet([1, 3]), false);
  Check(new DexiDistribution(0, []), false);
  Check(new DexiDistribution(1, [0.5]), true);
  Check(new DexiDistribution(1, [1.0]), true);
  Check(new DexiDistribution(1, [1.0, 1.0]), false);
  Check(new DexiFltSingle(1), true);
  Check(new DexiFltSingle(1.1), true);
  Check(new DexiFltInterval(1), true);
  Check(new DexiFltInterval(1.1), true);
  Check(new DexiFltInterval(1, 1.1), false);

  V := new DexiFltInterval;

  Check(new DexiUndefinedValue, false);
  Check(new DexiIntSingle(1), true);
  Check(new DexiIntInterval(1), true);
  Check(new DexiIntInterval(1, 2), true);
  Check(new DexiIntSet([]), false);
  Check(new DexiIntSet([1]), true);
  Check(new DexiIntSet([1, 2]), true);
  Check(new DexiIntSet([1, 3]), false);
  Check(new DexiDistribution(0, []), false);
  Check(new DexiDistribution(1, [0.5]), false);
  Check(new DexiDistribution(1, [1.0]), true);
  Check(new DexiDistribution(1, [1.0, 1.0]), true);
  Check(new DexiFltSingle(1), true);
  Check(new DexiFltSingle(1.1), true);
  Check(new DexiFltInterval(1), true);
  Check(new DexiFltInterval(1.1), true);
  Check(new DexiFltInterval(1, 1.1), true);
end;

method DexiValuesTest.TestSimplify;

  method Check(aValue, aVal: DexiValue);
  begin
    var lVal := DexiValue.SimplifyValue(aValue);
    if aVal = nil then
        Assert.AreEqual(aValue, lVal)
    else
      begin
        Assert.IsNotNil(lVal);
        Assert.IsTrue(lVal.EqualTo(aVal));
      end;
  end;

begin
  Check(nil, nil);
  Check(new DexiIntSingle(1), nil);
  Check(new DexiIntInterval(1, 1), new DexiIntSingle(1));
  Check(new DexiIntInterval(1, 2), nil);
  Check(new DexiIntSet([1]), new DexiIntSingle(1));
  Check(new DexiIntSet([1, 2]), new DexiIntInterval(1, 2));
  Check(new DexiIntSet([1, 2, 3]), new DexiIntInterval(1, 3));
  Check(new DexiIntSet([1, 3]), nil);
  Check(new DexiDistribution(1, [1.0]), new DexiIntSingle(1));
  Check(new DexiDistribution(1, [1.0, 1.0]), new DexiIntInterval(1, 2));
  Check(new DexiDistribution(1, [1.0, 0.0, 1.0]), new DexiIntSet([1, 3]));
  Check(new DexiDistribution(1, [1.0, 0.5, 1.0]), nil);
  Check(new DexiDistribution(1, [1.0, 0.5, 0.0, 1.0]), nil);
  Check(new DexiFltSingle(1), nil);
  Check(new DexiFltInterval(1, 1), new DexiFltSingle(1));
  Check(new DexiFltInterval(1.1, 1.1), new DexiFltSingle(1.1));
  Check(new DexiFltInterval(1, 2), nil);
end;

method DexiValuesTest.TestCompact;

  method Check(aValue, aVal: DexiValue);
  begin
    var lVal := DexiValue.CompactValue(aValue);
    if aVal = nil then
        Assert.AreEqual(aValue, lVal)
    else
      begin
        Assert.IsNotNil(lVal);
        Assert.IsTrue(lVal.EqualTo(aVal));
      end;
  end;

begin
  Check(nil, nil);
  Check(new DexiIntSingle(1), nil);
  Check(new DexiIntInterval(1, 1), new DexiIntSingle(1));
  Check(new DexiIntInterval(1, 2), nil);
  Check(new DexiIntSet([1]), new DexiIntSingle(1));
  Check(new DexiIntSet([1, 2]), new DexiIntInterval(1, 2));
  Check(new DexiIntSet([1, 2, 3]), new DexiIntInterval(1, 3));
  Check(new DexiIntSet([1, 3]), nil);
  Check(new DexiDistribution(1, [1.0]), new DexiIntSingle(1));
  Check(new DexiDistribution(1, [1.0, 1.0]), new DexiIntInterval(1, 2));
  Check(new DexiDistribution(1, [1.0, 0.0, 1.0]), new DexiIntSet([1, 3]));
  Check(new DexiDistribution(1, [1.0, 0.5, 1.0]), nil);
  Check(new DexiDistribution(1, [1.0, 0.5, 0.0, 1.0]), nil);
  Check(new DexiFltSingle(1), new DexiIntSingle(1));
  Check(new DexiFltInterval(1, 1), new DexiIntSingle(1));
  Check(new DexiFltInterval(1.1, 1.1), new DexiFltSingle(1.1));
  Check(new DexiFltInterval(1, 2), nil);
end;

method DexiValuesTest.TestFromToString;

  method Check(aVal: DexiValue; aStr: String; aRead: String := nil);
  begin
    var lStr := DexiValue.ToString(aVal);
    Assert.AreEqual(lStr, aStr);
    var lVal := DexiValue.FromString(lStr);
    if lVal is not DexiUndefinedValue then
      Assert.IsTrue((aVal = lVal) or aVal.EqualTo(lVal));
    if aRead <> nil then
      begin
        lVal := DexiValue.FromString(aRead);
        Assert.IsTrue((aVal = lVal) or aVal.SameValue(lVal));
      end;
  end;

begin
  Check(nil, '');
  Check(new DexiUndefinedValue, '?');
  Check(new DexiIntSingle(1), '1');
  Check(new DexiIntInterval(1, 1), '1');
  Check(new DexiIntInterval(1, 2), '1:2');
  Check(new DexiIntSet([1]), '{1}');
  Check(new DexiIntSet([1, 2]), '{1;2}');
  Check(new DexiIntSet([1, 2, 3]), '{1;2;3}');
  Check(new DexiIntSet([1, 3]), '{1;3}');
  Check(new DexiDistribution(1, [1.0]), '<1:1>');
  Check(new DexiDistribution(1, [1.0, 1.0]), '<1:1;2:1>');
  Check(new DexiDistribution(1, [1.0, 0.0, 1.0]), '<1:1;3:1>');
  Check(new DexiDistribution(1, [1.0, 0.5, 1.0]), '<1:1;2:0.5;3:1>');
  Check(new DexiDistribution(1, [1.0, 0.5, 0.0, 1.0]), '<1:1;2:0.5;4:1>');
  Check(new DexiFltSingle(1), '1', '1.');
  Check(new DexiFltInterval(1, 1), '1', '1.:1');
  Check(new DexiFltInterval(1.1, 1.1), '1.1', '1.1:1.1');
  Check(new DexiFltInterval(1, 2), '1:2', '1.:2');
end;

method DexiValuesTest.TestBoundIntSingle;
begin
  var V := new DexiIntSingle(1);
  Assert.IsTrue(V.InBounds(1, 1));
  Assert.IsTrue(V.InBounds(1, 2));
  Assert.IsTrue(V.InBounds(0, 1));
  Assert.IsTrue(V.InBounds(0, 2));
  V.IntoBounds(2, 3);
  CheckLowHigh(V, 2, 2, 2, 2);
  V.IntoBounds(0, 1);
  CheckLowHigh(V, 1, 1, 1, 1);
end;

method DexiValuesTest.TestBoundIntInterval;
begin
  var V := new DexiIntInterval(1, 3);
  Assert.IsFalse(V.InBounds(1, 1));
  Assert.IsFalse(V.InBounds(1, 2));
  Assert.IsTrue(V.InBounds(0, 3));
  Assert.IsTrue(V.InBounds(1, 3));
  Assert.IsTrue(V.InBounds(1, 4));
  Assert.IsTrue(V.InBounds(0, 4));
  V.IntoBounds(2, 3);
  CheckLowHigh(V, 2, 3, 2, 3);
  V.IntoBounds(0, 1);
  CheckLowHigh(V, 1, 1, 1, 1);
end;

method DexiValuesTest.TestBoundIntSet;
  var V: DexiIntSet;

  method Check(aSet: IntSet);
  begin
    Assert.IsTrue(V.EqualTo(new DexiIntSet(aSet)));
  end;

begin
  V := new DexiIntSet([1, 3]);
  Assert.IsFalse(V.InBounds(1, 1));
  Assert.IsFalse(V.InBounds(1, 2));
  Assert.IsTrue(V.InBounds(0, 3));
  Assert.IsTrue(V.InBounds(1, 3));
  Assert.IsTrue(V.InBounds(1, 4));
  Assert.IsTrue(V.InBounds(0, 4));
  V.IntoBounds(2, 3);
  Check([3]);
  V.IntoBounds(0, 1);
  Check([]);

  V := new DexiIntSet([1, 2, 3]);
  V.IntoBounds(2, 3);
  Check([2, 3]);

  V := new DexiIntSet([1, 2, 3, 4]);
  V.IntoBounds(2, 3);
  Check([2, 3]);
end;

method DexiValuesTest.TestBoundDistribution;
  var V: DexiDistribution;

  method Check(aBase: Integer; aDistr: FltArray);
  begin
    Assert.IsTrue(V.EqualTo(new DexiDistribution(aBase, aDistr)));
  end;

begin
  V := new DexiDistribution(Values.Distr([1, 3]));
  Check(1, [1.0, 0.0, 1.0]);
  Assert.IsFalse(V.InBounds(1, 1));
  Assert.IsFalse(V.InBounds(1, 2));
  Assert.IsTrue(V.InBounds(0, 3));
  Assert.IsTrue(V.InBounds(1, 3));
  Assert.IsTrue(V.InBounds(1, 4));
  Assert.IsTrue(V.InBounds(0, 4));
  V.IntoBounds(2, 3);
  Check(1, [0.0, 0.0, 1.0]);
  V.IntoBounds(0, 1);
  Check(1, [0.0, 0.0, 0.0]);

  V := new DexiDistribution(Values.Distr([1, 2, 3]));
  Check(1, [1.0, 1.0, 1.0]);
  V.IntoBounds(2, 3);
  Check(1, [0.0, 1.0, 1.0]);

  V := new DexiDistribution(Values.Distr([1, 2, 3, 4]));
  Check(1, [1.0, 1.0, 1.0, 1.0]);
  V.IntoBounds(2, 3);
  Check(1, [0.0, 1.0, 1.0, 0.0]);
end;

method DexiValuesTest.TestBoundFltSingle;
begin
  var V := new DexiFltSingle(1);
  Assert.IsTrue(V.InBounds(1, 1));
  Assert.IsTrue(V.InBounds(1, 2));
  Assert.IsTrue(V.InBounds(0, 1));
  Assert.IsTrue(V.InBounds(0, 2));
  V.IntoBounds(2, 3);
  CheckLowHigh(V, 2, 2, 2, 2);
  V.IntoBounds(0, 1);
  CheckLowHigh(V, 1, 1, 1, 1);

  V := new DexiFltSingle(1.1);
  V.IntoBounds(2, 3);
  CheckLowHigh(V, 2, 2, 2, 2);

  V := new DexiFltSingle(1.1);
  V.IntoBounds(2.1, 3.3);
  CheckLowHigh(V, 2, 2, 2.1, 2.1);
end;

method DexiValuesTest.TestBoundFltInterval;
begin
  var V := new DexiFltInterval(1, 3);
  Assert.IsFalse(V.InBounds(1, 1));
  Assert.IsFalse(V.InBounds(1, 2));
  Assert.IsTrue(V.InBounds(0, 3));
  Assert.IsTrue(V.InBounds(1, 3));
  Assert.IsTrue(V.InBounds(1, 4));
  Assert.IsTrue(V.InBounds(0, 4));
  V.IntoBounds(2, 3);
  CheckLowHigh(V, 2, 3, 2, 3);
  V.IntoBounds(0, 1);
  CheckLowHigh(V, 1, 1, 1, 1);

  V := new DexiFltInterval(1.1);
  V.IntoBounds(2, 3);
  CheckLowHigh(V, 2, 2, 2, 2);

  V := new DexiFltInterval(1.1, 2.4);
  V.IntoBounds(2.1, 3.3);
  CheckLowHigh(V, 2, 2, 2.1, 2.4);
end;

method DexiValuesTest.TestCrossAssign;
var lIn, lOut: array [DexiValueType.None .. DexiValueType.FltInterval] of DexiValue;
begin
  // DexiUndefined deliberately left out
  for lIdx: DexiValueType := DexiValueType.IntSingle to DexiValueType.FltInterval do
    begin
      lOut[lIdx] := DexiValue.CreateValue(lIdx);
      lIn[lIdx] :=
        case lIdx of
          DexiValueType.Undefined:    new DexiUndefinedValue;
          DexiValueType.IntSingle:    new DexiIntSingle(6);
          DexiValueType.IntInterval:  new DexiIntInterval(2, 9);
          DexiValueType.IntSet:       new DexiIntSet([1, 11, 15]);
          DexiValueType.Distribution: new DexiDistribution(0, [0, 0, 0.5, 0.3, 0.2, 0]);
          DexiValueType.FltSingle:    new DexiFltSingle(6.2);
          DexiValueType.FltInterval:  new DexiFltInterval(2.2, 2.4);
        end;
  end;
  for lIdx: DexiValueType := DexiValueType.IntSingle to DexiValueType.FltInterval  do
    for lOdx: DexiValueType := DexiValueType.IntSingle to DexiValueType.FltInterval  do
      begin
        lOut[lOdx].AssignValue(lIn[lIdx]);
        Assert.IsTrue(lOut[lOdx].EqualTo(lIn[lIdx]));
        Assert.IsTrue((lIdx<>lOdx) or lOut[lOdx].SameValue(lIn[lIdx]));
      end;
end;

end.
