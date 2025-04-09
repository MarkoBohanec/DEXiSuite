namespace DexiLibrary.Tests;

interface

uses
  DexiUtils,
  DexiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiScalesTest = public class(DexiLibraryTest)
  private
  protected
    method CheckScaleBounds(aScl: DexiContinuousScale; aLow, aHigh: Float);
    method CheckScaleBounds(aScl: DexiDiscreteScale; aCount: Integer; aLow, aHigh: Float);
    method CheckScale(aScl: DexiDiscreteScale; aLow, aHigh: Integer; aBad, aGood: Float; aNames: String);
    method CheckValueOnScale(aValue: DexiValue; aScale: DexiScale; aStr: String);
    method CheckValueOnScale(aValue: IntOffsets; aScale: DexiScale; aStr: String);
    method CheckScaleString(aScale: DexiScale; aStr: String);
  public
    method TestContinuousScaleAscending;
    method TestContinuousScaleDescending;
    method TestContinuousScaleUnordered;
    method TestContinuousScaleChangeOrder;
    method TestDiscreteScaleAscending;
    method TestDiscreteScaleDescending;
    method TestDiscreteScaleUnordered;
    method TestDiscreteScaleOpsAscending;
    method TestDiscreteScaleOpsAscendingLow;
    method TestDiscreteScaleOpsAscendingHigh;
    method TestDiscreteScaleOpsDescending;
    method TestAssignContCont;
    method TestAssignDiscDisc;
    method TestAssignContDisc;
    method TestAssignDiscCont;
    method TestCompatibleWith;
    method TestValueInScaleBounds;
    method TestValueIntoScaleBounds;
    method TestCompositeContinuousAscending;
    method TestCompositeContinuousDescending;
    method TestCompositeContinuousUnordered;
    method TestCompositeDiscreteAscending;
    method TestCompositeDiscreteDescending;
    method TestCompositeDiscreteUnordered;
    method TestCompositeContinuousScale;
    method TestCompositeDiscreteScale;
    method TestValueParser;
 end;

implementation

method DexiScalesTest.CheckScaleBounds(aScl: DexiDiscreteScale; aCount: Integer; aLow, aHigh: Float);
begin
  Assert.IsNotNil(aScl);
  Assert.AreEqual(aScl.Count, aCount);
  Assert.IsTrue(aScl.LowInt = 0);
  Assert.IsTrue(aScl.HighInt = aCount - 1);
  case aScl.Order of
    DexiOrder.None:
      begin
        Assert.IsTrue(aScl.Bad = Consts.NegativeInfinity);
        Assert.IsTrue(aScl.Good = Consts.PositiveInfinity);
      end;
    DexiOrder.Ascending:
      begin
        Assert.IsTrue(aScl.Bad = aLow);
        Assert.IsTrue(aScl.Good = aHigh);
      end;
    DexiOrder.Descending:
      begin
        Assert.IsTrue(aScl.Bad = aHigh);
        Assert.IsTrue(aScl.Good = aLow);
      end;
  end;
  for i := -1 to aCount + 1 do
    begin
      Assert.AreEqual(aScl.InBounds(i), 0 <= i < aCount);
      Assert.IsFalse(aScl.IsGood(i) and aScl.IsBad(i));
      case aScl.Order of
        DexiOrder.None:
          begin
            Assert.IsFalse(aScl.IsBad(i));
            Assert.IsFalse(aScl.IsGood(i));
          end;
        DexiOrder.Ascending:
          if i <= aLow then
            Assert.IsTrue(aScl.IsBad(i))
          else if i >= aHigh then
            Assert.IsTrue(aScl.IsGood(i));
        DexiOrder.Descending:
            if i <= aLow then
            Assert.IsTrue(aScl.IsGood(i))
          else if i >= aHigh then
            Assert.IsTrue(aScl.IsBad(i));
      end;
    end;
end;

method DexiScalesTest.CheckScaleBounds(aScl: DexiContinuousScale; aLow, aHigh: Float);
begin
  Assert.IsNotNil(aScl);
  Assert.AreEqual(aScl.Count, -1);
  Assert.IsTrue(Utils.FloatEq(aScl.BGLow, aLow));
  Assert.IsTrue(Utils.FloatEq(aScl.BGHigh, aHigh));
  case aScl.Order of
    DexiOrder.None:
      begin
        Assert.IsTrue(aScl.Bad = Consts.NegativeInfinity);
        Assert.IsTrue(aScl.Good = Consts.PositiveInfinity);
      end;
    DexiOrder.Ascending:
      begin
        Assert.IsTrue(Utils.FloatEq(aScl.Bad, aLow));
        Assert.IsTrue(Utils.FloatEq(aScl.Good, aHigh));
      end;
    DexiOrder.Descending:
      begin
        Assert.IsTrue(Utils.FloatEq(aScl.Bad, aHigh));
        Assert.IsTrue(Utils.FloatEq(aScl.Good, aLow));
      end;
  end;
  var lLows :=
    if Consts.IsInfinity(aLow) then []
    else [aLow - 0.2, aLow - 0.1, aLow, aLow + 0.1, aLow + 0.2];
  var lHighs :=
    if Consts.IsInfinity(aHigh) then []
    else [aHigh - 0.2, aHigh - 0.1, aHigh, aHigh + 0.1, aHigh + 0.2];
  var lVals := Utils.ConcatenateFltArrays(lLows, lHighs);
  for each v in lVals do
    begin
      Assert.IsFalse(aScl.IsGood(v) and aScl.IsBad(v));
      Assert.IsTrue(aScl.InBounds(v));
      case aScl.Order of
        DexiOrder.None:
          begin
            Assert.IsFalse(aScl.IsBad(v));
            Assert.IsFalse(aScl.IsGood(v));
          end;
        DexiOrder.Ascending:
          if v <= aLow then
            Assert.IsTrue(aScl.IsBad(v))
          else if v >= aHigh then
            Assert.IsTrue(aScl.IsGood(v));
        DexiOrder.Descending:
          if v <= aLow then
            Assert.IsTrue(aScl.IsGood(v))
          else if v >= aHigh then
            Assert.IsTrue(aScl.IsBad(v));
      end;
    end;
end;

method DexiScalesTest.CheckScale(aScl: DexiDiscreteScale; aLow, aHigh: Integer; aBad, aGood: Float; aNames: String);
begin
  Assert.IsNotNil(aScl);
  Assert.AreEqual(aScl.LowInt, aLow);
  Assert.AreEqual(aScl.HighInt, aHigh);
  Assert.AreEqual(aScl.Bad, aBad);
  Assert.AreEqual(aScl.Good, aGood);
  var lNames := '';
  for i := 0 to aScl.Count - 1 do
    lNames := lNames + aScl.Names[i];
  Assert.AreEqual(lNames, aNames);
end;

method DexiScalesTest.TestContinuousScaleAscending;
begin
  var S := new DexiContinuousScale;
  S.ScaleUnit := 'm';
  Assert.IsTrue(S.ScaleUnit = 'm');
  Assert.IsTrue(S.Order = DexiOrder.Ascending);
  Assert.IsTrue(S.IsInterval);
  Assert.IsTrue(S.IsOrdered);
  Assert.IsFalse(S.IsDescending);
  Assert.IsTrue(S.IsContinuous);
  Assert.IsFalse(S.IsDiscrete);
  Assert.IsTrue(S.Count = -1);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = low(Integer));
  Assert.IsTrue(S.HighInt = high(Integer));
  Assert.IsTrue(S.LowFloat = Consts.NegativeInfinity);
  Assert.IsTrue(S.HighFloat = Consts.PositiveInfinity);
  CheckScaleBounds(S, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsTrue(S.InBounds(-1));
  Assert.IsTrue(S.IntoBounds(-1) = -1);
  Assert.IsTrue(S.Compare(1, 1) = PrefCompare.Equal);
  Assert.IsTrue(S.Compare(1.0, 1.0 + Utils.FloatEpsilon/3) = PrefCompare.Lower);
  Assert.IsTrue(S.Compare(0 ,1) = PrefCompare.Lower);
  Assert.IsTrue(S.Compare(1, 0) = PrefCompare.Greater);
  Assert.IsTrue(S.IsBetter(1, 0));
  Assert.IsTrue(S.IsBetterEq(1, 0));
  Assert.IsFalse(S.IsBetter(0, 0));
  Assert.IsTrue(S.IsBetterEq(0, 0));
  Assert.IsFalse(S.IsWorse(1, 0));
  Assert.IsFalse(S.IsWorseEq(1, 0));
  Assert.IsFalse(S.IsWorse(0, 0));
  Assert.IsTrue(S.IsWorseEq(0, 0));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));

  S.Bad := -1;
  S.Good := 1;
  Assert.AreEqual(S.BGLow, -1.0);
  Assert.AreEqual(S.BGHigh, 1.0);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.AreEqual(S.Bad, -1.0);
  Assert.AreEqual(S.Good, 1.0);
  Assert.IsTrue(S.LowInt = low(Integer));
  Assert.IsTrue(S.HighInt = high(Integer));
  Assert.IsTrue(S.LowFloat = Consts.NegativeInfinity);
  Assert.IsTrue(S.HighFloat = Consts.PositiveInfinity);
  CheckScaleBounds(S, -1, 1);
  Assert.IsTrue(S.IsBad(-1.1));
  Assert.IsTrue(S.IsBad(-1));
  Assert.IsFalse(S.IsGood(-1.1));
  Assert.IsFalse(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsTrue(S.IsGood(1));
  Assert.IsTrue(S.IsGood(1.1));
  Assert.IsFalse(S.IsBad(1));
  Assert.IsFalse(S.IsBad(1.1));
end;

method DexiScalesTest.TestContinuousScaleDescending;
begin
  var S := new DexiContinuousScale;
  S.Order := DexiOrder.Descending;
  S.ScaleUnit := 'm';
  Assert.IsTrue(S.ScaleUnit = 'm');
  Assert.IsTrue(S.Order = DexiOrder.Descending);
  Assert.IsTrue(S.IsInterval);
  Assert.IsTrue(S.IsOrdered);
  Assert.IsTrue(S.IsDescending);
  Assert.IsTrue(S.IsContinuous);
  Assert.IsFalse(S.IsDiscrete);
  Assert.IsTrue(S.Count = -1);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = low(Integer));
  Assert.IsTrue(S.HighInt = high(Integer));
  Assert.IsTrue(S.LowFloat = Consts.NegativeInfinity);
  Assert.IsTrue(S.HighFloat = Consts.PositiveInfinity);
  CheckScaleBounds(S, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsTrue(S.InBounds(-1));
  Assert.IsTrue(S.IntoBounds(-1) = -1);
  Assert.IsTrue(S.Compare(1, 1) = PrefCompare.Equal);
  Assert.IsTrue(S.Compare(1.0, 1.0 + Utils.FloatEpsilon/3) = PrefCompare.Greater);
  Assert.IsTrue(S.Compare(0 ,1) = PrefCompare.Greater);
  Assert.IsTrue(S.Compare(1, 0) = PrefCompare.Lower);
  Assert.IsFalse(S.IsBetter(1, 0));
  Assert.IsFalse(S.IsBetterEq(1, 0));
  Assert.IsFalse(S.IsBetter(0, 0));
  Assert.IsTrue(S.IsBetterEq(0, 0));
  Assert.IsTrue(S.IsWorse(1, 0));
  Assert.IsTrue(S.IsWorseEq(1, 0));
  Assert.IsFalse(S.IsWorse(0, 0));
  Assert.IsTrue(S.IsWorseEq(0, 0));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));

  S.Bad := 1;
  S.Good := -1;
  Assert.AreEqual(S.BGLow, -1.0);
  Assert.AreEqual(S.BGHigh, 1.0);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.AreEqual(S.Bad, 1.0);
  Assert.AreEqual(S.Good, -1.0);
  Assert.IsTrue(S.LowInt = low(Integer));
  Assert.IsTrue(S.HighInt = high(Integer));
  Assert.IsTrue(S.LowFloat = Consts.NegativeInfinity);
  Assert.IsTrue(S.HighFloat = Consts.PositiveInfinity);
  CheckScaleBounds(S, -1, 1);
  Assert.IsFalse(S.IsBad(-1.1));
  Assert.IsFalse(S.IsBad(-1));
  Assert.IsTrue(S.IsGood(-1.1));
  Assert.IsTrue(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsFalse(S.IsGood(1));
  Assert.IsFalse(S.IsGood(1.1));
  Assert.IsTrue(S.IsBad(1));
  Assert.IsTrue(S.IsBad(1.1));
end;

method DexiScalesTest.TestContinuousScaleUnordered;
begin
  var S := new DexiContinuousScale;
  S.Order := DexiOrder.None;
  S.ScaleUnit := 'm';
  Assert.IsTrue(S.ScaleUnit = 'm');
  Assert.IsTrue(S.Order = DexiOrder.None);
  Assert.IsTrue(S.IsInterval);
  Assert.IsFalse(S.IsOrdered);
  Assert.IsFalse(S.IsDescending);
  Assert.IsTrue(S.IsContinuous);
  Assert.IsFalse(S.IsDiscrete);
  Assert.IsTrue(S.Count = -1);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = low(Integer));
  Assert.IsTrue(S.HighInt = high(Integer));
  Assert.IsTrue(S.LowFloat = Consts.NegativeInfinity);
  Assert.IsTrue(S.HighFloat = Consts.PositiveInfinity);
  CheckScaleBounds(S, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsTrue(S.InBounds(-1));
  Assert.IsTrue(S.IntoBounds(-1) = -1);
  Assert.IsTrue(S.Compare(1, 1) = PrefCompare.No);
  Assert.IsTrue(S.Compare(1.0, 1.0 + Utils.FloatEpsilon/3) = PrefCompare.No);
  Assert.IsTrue(S.Compare(0 ,1) = PrefCompare.No);
  Assert.IsTrue(S.Compare(1, 0) = PrefCompare.No);
  Assert.IsFalse(S.IsBetter(1, 0));
  Assert.IsFalse(S.IsBetterEq(1, 0));
  Assert.IsFalse(S.IsBetter(0, 0));
  Assert.IsFalse(S.IsBetterEq(0, 0));
  Assert.IsFalse(S.IsWorse(1, 0));
  Assert.IsFalse(S.IsWorseEq(1, 0));
  Assert.IsFalse(S.IsWorse(0, 0));
  Assert.IsFalse(S.IsWorseEq(0, 0));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));

  S.Bad := -1;
  S.Good := 1;
  Assert.AreEqual(S.BGLow, Consts.NegativeInfinity);
  Assert.AreEqual(S.BGHigh, Consts.PositiveInfinity);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.AreEqual(S.Bad, Consts.NegativeInfinity);
  Assert.AreEqual(S.Good, Consts.PositiveInfinity);
  Assert.IsTrue(S.LowInt = low(Integer));
  Assert.IsTrue(S.HighInt = high(Integer));
  Assert.IsTrue(S.LowFloat = Consts.NegativeInfinity);
  Assert.IsTrue(S.HighFloat = Consts.PositiveInfinity);
  CheckScaleBounds(S, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsFalse(S.IsBad(-1.1));
  Assert.IsFalse(S.IsBad(-1));
  Assert.IsFalse(S.IsGood(-1.1));
  Assert.IsFalse(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsFalse(S.IsGood(1));
  Assert.IsFalse(S.IsGood(1.1));
  Assert.IsFalse(S.IsBad(1));
  Assert.IsFalse(S.IsBad(1.1));
end;

method DexiScalesTest.TestContinuousScaleChangeOrder;
begin
  var S := new DexiContinuousScale;

  Assert.IsTrue(S.Order = DexiOrder.Ascending);
  S.Bad := -1;
  S.Good := 2;
  Assert.IsTrue(S.Bad = -1);
  Assert.IsTrue(S.Good = 2);

  S.Order := DexiOrder.Descending;
  Assert.IsTrue(S.Order = DexiOrder.Descending);
  Assert.IsTrue(S.Bad = 2);
  Assert.IsTrue(S.Good = -1);

  S.Reverse;
  Assert.IsTrue(S.Order = DexiOrder.Ascending);
  S.Bad := -1;
  S.Good := 2;
  Assert.IsTrue(S.Bad = -1);
  Assert.IsTrue(S.Good = 2);

  S.Reverse;
  Assert.IsTrue(S.Order = DexiOrder.Descending);
  Assert.IsTrue(S.Bad = 2);
  Assert.IsTrue(S.Good = -1);

  S.Order := DexiOrder.None;
  Assert.IsTrue(S.Order = DexiOrder.None);
  Assert.IsTrue(S.Bad = Consts.NegativeInfinity);
  Assert.IsTrue(S.Good = Consts.PositiveInfinity);
end;

method DexiScalesTest.TestDiscreteScaleAscending;
begin
  var S := new DexiDiscreteScale;
  S.ScaleUnit := 'm';
  Assert.IsTrue(S.ScaleUnit = 'm');
  Assert.IsTrue(S.Order = DexiOrder.Ascending);
  Assert.IsTrue(S.IsInterval);
  Assert.IsTrue(S.IsOrdered);
  Assert.IsFalse(S.IsDescending);
  Assert.IsFalse(S.IsContinuous);
  Assert.IsTrue(S.IsDiscrete);
  Assert.IsTrue(S.Count = 0);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = -1);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat, -0.5));
  CheckScaleBounds(S, 0, Consts.NegativeInfinity, Consts.PositiveInfinity);

  S.AddValue('a');
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  CheckScaleBounds(S, 1, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 0);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat, 0.5));

  S.AddValue('b');
  CheckScaleBounds(S, 2, 0.5, 0.5);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 1);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 1.5));

  S.AddValue('c');
  CheckScaleBounds(S, 3, 0, 2);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 2.5));

  Assert.IsFalse(S.InBounds(-1));
  Assert.IsTrue(S.InBounds(0));
  Assert.IsTrue(S.InBounds(2));
  Assert.IsTrue(S.InBounds(2.1));
  Assert.IsFalse(S.InBounds(2.6));
  Assert.IsFalse(S.InBounds(3));
  Assert.IsTrue(S.IntoBounds(-1) = 0);
  Assert.IsTrue(S.IntoBounds(0) = 0);
  Assert.IsTrue(S.IntoBounds(2) = 2);
  Assert.IsTrue(S.IntoBounds(2.1) = 2.1);
  Assert.IsTrue(S.IntoBounds(3) = 2);
  Assert.IsTrue(Utils.FloatEq(S.IntoBounds(3.0), 2.5 - Utils.FloatEpsilon/2));
  Assert.IsTrue(S.Compare(1, 1) = PrefCompare.Equal);
  Assert.IsTrue(S.Compare(1.0, 1.0 + Utils.FloatEpsilon/3) = PrefCompare.Lower);
  Assert.IsTrue(S.Compare(0 ,1) = PrefCompare.Lower);
  Assert.IsTrue(S.Compare(1, 0) = PrefCompare.Greater);
  Assert.IsTrue(S.IsBetter(1, 0));
  Assert.IsTrue(S.IsBetterEq(1, 0));
  Assert.IsFalse(S.IsBetter(0, 0));
  Assert.IsTrue(S.IsBetterEq(0, 0));
  Assert.IsFalse(S.IsWorse(1, 0));
  Assert.IsFalse(S.IsWorseEq(1, 0));
  Assert.IsFalse(S.IsWorse(0, 0));
  Assert.IsTrue(S.IsWorseEq(0, 0));
  Assert.IsTrue(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));

  S.Bad := -1;
  S.Good := 2;
  Assert.AreEqual(S.BGLow, -1.0);
  Assert.AreEqual(S.BGHigh, 2.0);
  Assert.IsFalse(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.AreEqual(S.Bad, -1.0);
  Assert.AreEqual(S.Good, 2.0);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 2.5));
  CheckScaleBounds(S, 3, -1, 2);
  Assert.IsTrue(S.IsBad(-1.1));
  Assert.IsTrue(S.IsBad(-1));
  Assert.IsFalse(S.IsBad(-0.9));
  Assert.IsFalse(S.IsGood(-1.1));
  Assert.IsFalse(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsFalse(S.IsGood(1));
  Assert.IsTrue(S.IsGood(2));
  Assert.IsTrue(S.IsGood(2.1));
  Assert.IsFalse(S.IsBad(2));
  Assert.IsFalse(S.IsBad(2.1));

  S.Bad := 0;
  S.Good := 1;
  Assert.AreEqual(S.BGLow, 0.0);
  Assert.AreEqual(S.BGHigh, 1.0);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.AreEqual(S.Bad, 0.0);
  Assert.AreEqual(S.Good, 1.0);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  CheckScaleBounds(S, 3, 0, 1);
  Assert.IsTrue(S.IsBad(-1.1));
  Assert.IsTrue(S.IsBad(-1));
  Assert.IsTrue(S.IsBad(-0.9));
  Assert.IsFalse(S.IsGood(-1.1));
  Assert.IsFalse(S.IsGood(-1));
  Assert.IsTrue(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsTrue(S.IsGood(1));
  Assert.IsTrue(S.IsGood(2));
  Assert.IsTrue(S.IsGood(2.1));
  Assert.IsFalse(S.IsBad(2));
  Assert.IsFalse(S.IsBad(2.1));
end;

method DexiScalesTest.TestDiscreteScaleDescending;
begin
  var S := new DexiDiscreteScale;
  S.Order := DexiOrder.Descending;
  S.ScaleUnit := 'm';
  Assert.IsTrue(S.ScaleUnit = 'm');
  Assert.IsTrue(S.Order = DexiOrder.Descending);
  Assert.IsTrue(S.IsInterval);
  Assert.IsTrue(S.IsOrdered);
  Assert.IsTrue(S.IsDescending);
  Assert.IsFalse(S.IsContinuous);
  Assert.IsTrue(S.IsDiscrete);
  Assert.IsTrue(S.Count = 0);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = -1);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat, -0.5));
  CheckScaleBounds(S, 0, Consts.NegativeInfinity, Consts.PositiveInfinity);

  S.AddValue('a');
  CheckScaleBounds(S, 1, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 0);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat, 0.5));

  S.AddValue('b');
  CheckScaleBounds(S, 2, 0.5, 0.5);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 1);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 1.5));

  S.AddValue('c');
  CheckScaleBounds(S, 3, 0, 2);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 2.5));

  Assert.IsFalse(S.InBounds(-1));
  Assert.IsTrue(S.InBounds(0));
  Assert.IsTrue(S.InBounds(2));
  Assert.IsTrue(S.InBounds(2.1));
  Assert.IsFalse(S.InBounds(2.6));
  Assert.IsFalse(S.InBounds(3));
  Assert.IsTrue(S.IntoBounds(-1) = 0);
  Assert.IsTrue(S.IntoBounds(0) = 0);
  Assert.IsTrue(S.IntoBounds(2) = 2);
  Assert.IsTrue(S.IntoBounds(2.1) = 2.1);
  Assert.IsTrue(S.IntoBounds(3) = 2);
  Assert.IsTrue(Utils.FloatEq(S.IntoBounds(3.0), 2.5 - Utils.FloatEpsilon/2));
  Assert.IsTrue(S.Compare(1, 1) = PrefCompare.Equal);
  Assert.IsTrue(S.Compare(1.0, 1.0 + Utils.FloatEpsilon/3) = PrefCompare.Greater);
  Assert.IsTrue(S.Compare(0 ,1) = PrefCompare.Greater);
  Assert.IsTrue(S.Compare(1, 0) = PrefCompare.Lower);
  Assert.IsFalse(S.IsBetter(1, 0));
  Assert.IsFalse(S.IsBetterEq(1, 0));
  Assert.IsFalse(S.IsBetter(0, 0));
  Assert.IsTrue(S.IsBetterEq(0, 0));
  Assert.IsTrue(S.IsWorse(1, 0));
  Assert.IsTrue(S.IsWorseEq(1, 0));
  Assert.IsFalse(S.IsWorse(0, 0));
  Assert.IsTrue(S.IsWorseEq(0, 0));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsTrue(S.IsGood(0));

  S.Bad := 2;
  S.Good := -1;
  Assert.AreEqual(S.BGLow, -1.0);
  Assert.AreEqual(S.BGHigh, 2.0);
  Assert.IsFalse(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.AreEqual(S.Bad, 2.0);
  Assert.AreEqual(S.Good, -1.0);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 2.5));
  CheckScaleBounds(S, 3, -1, 2);
  Assert.IsFalse(S.IsBad(-1.1));
  Assert.IsFalse(S.IsBad(-1));
  Assert.IsFalse(S.IsBad(-0.9));
  Assert.IsTrue(S.IsGood(-1.1));
  Assert.IsTrue(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsFalse(S.IsGood(1));
  Assert.IsFalse(S.IsGood(2));
  Assert.IsFalse(S.IsGood(2.1));
  Assert.IsTrue(S.IsBad(2));
  Assert.IsTrue(S.IsBad(2.1));

  S.Bad := 1;
  S.Good := 0;
  Assert.AreEqual(S.BGLow, 0.0);
  Assert.AreEqual(S.BGHigh, 1.0);
  Assert.IsTrue(S.HasBad);
  Assert.IsTrue(S.HasGood);
  Assert.AreEqual(S.Bad, 1.0);
  Assert.AreEqual(S.Good, 0.0);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  CheckScaleBounds(S, 3, 0, 1);
  Assert.IsFalse(S.IsBad(-1.1));
  Assert.IsFalse(S.IsBad(-1));
  Assert.IsFalse(S.IsBad(-0.9));
  Assert.IsTrue(S.IsGood(-1.1));
  Assert.IsTrue(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsTrue(S.IsGood(0));
  Assert.IsFalse(S.IsGood(1));
  Assert.IsFalse(S.IsGood(2));
  Assert.IsFalse(S.IsGood(2.1));
  Assert.IsTrue(S.IsBad(2));
  Assert.IsTrue(S.IsBad(2.1));
end;

method DexiScalesTest.TestDiscreteScaleUnordered;
begin
  var S := new DexiDiscreteScale;
  S.Order := DexiOrder.None;
  S.ScaleUnit := 'm';
  Assert.IsTrue(S.ScaleUnit = 'm');
  Assert.IsTrue(S.Order = DexiOrder.None);
  Assert.IsTrue(S.IsInterval);
  Assert.IsFalse(S.IsOrdered);
  Assert.IsFalse(S.IsDescending);
  Assert.IsFalse(S.IsContinuous);
  Assert.IsTrue(S.IsDiscrete);
  Assert.IsTrue(S.Count = 0);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = -1);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat, -0.5));
  CheckScaleBounds(S, 0, Consts.NegativeInfinity, Consts.PositiveInfinity);

  S.AddValue('a');
  CheckScaleBounds(S, 1, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 0);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat, 0.5));

  S.AddValue('b');
  CheckScaleBounds(S, 2, -0.5, 1.5);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 1);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 1.5));

  S.AddValue('c');
  CheckScaleBounds(S, 3, -0.5, 2.5);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 2.5));

  Assert.IsFalse(S.InBounds(-1));
  Assert.IsTrue(S.InBounds(0));
  Assert.IsTrue(S.InBounds(2));
  Assert.IsTrue(S.InBounds(2.1));
  Assert.IsFalse(S.InBounds(2.6));
  Assert.IsFalse(S.InBounds(3));
  Assert.IsTrue(S.IntoBounds(-1) = 0);
  Assert.IsTrue(S.IntoBounds(0) = 0);
  Assert.IsTrue(S.IntoBounds(2) = 2);
  Assert.IsTrue(S.IntoBounds(2.1) = 2.1);
  Assert.IsTrue(S.IntoBounds(3) = 2);
  Assert.IsTrue(Utils.FloatEq(S.IntoBounds(3.0), 2.5 - Utils.FloatEpsilon/2));
  Assert.IsTrue(S.Compare(1, 1) = PrefCompare.No);
  Assert.IsTrue(S.Compare(1.0, 1.0 + Utils.FloatEpsilon/3) = PrefCompare.No);
  Assert.IsTrue(S.Compare(0 ,1) = PrefCompare.No);
  Assert.IsTrue(S.Compare(1, 0) = PrefCompare.No);
  Assert.IsFalse(S.IsBetter(1, 0));
  Assert.IsFalse(S.IsBetterEq(1, 0));
  Assert.IsFalse(S.IsBetter(0, 0));
  Assert.IsFalse(S.IsBetterEq(0, 0));
  Assert.IsFalse(S.IsWorse(1, 0));
  Assert.IsFalse(S.IsWorseEq(1, 0));
  Assert.IsFalse(S.IsWorse(0, 0));
  Assert.IsFalse(S.IsWorseEq(0, 0));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));

  S.Bad := 2;
  S.Good := -1;
  Assert.AreEqual(S.BGLow, Consts.NegativeInfinity);
  Assert.AreEqual(S.BGHigh, Consts.PositiveInfinity);
  Assert.IsFalse(S.HasBad);
  Assert.IsFalse(S.HasGood);
  Assert.AreEqual(S.Bad, Consts.NegativeInfinity);
  Assert.AreEqual(S.Good, Consts.PositiveInfinity);
  Assert.IsTrue(S.LowInt = 0);
  Assert.IsTrue(S.HighInt = 2);
  Assert.IsTrue(Utils.FloatEq(S.LowFloat, -0.5));
  Assert.IsTrue(Utils.FloatEq(S.HighFloat + Utils.FloatEpsilon/2, 2.5));
  CheckScaleBounds(S, 3, Consts.NegativeInfinity, Consts.PositiveInfinity);
  Assert.IsFalse(S.IsBad(-1.1));
  Assert.IsFalse(S.IsBad(-1));
  Assert.IsFalse(S.IsBad(-0.9));
  Assert.IsFalse(S.IsGood(-1.1));
  Assert.IsFalse(S.IsGood(-1));
  Assert.IsFalse(S.IsBad(0));
  Assert.IsFalse(S.IsGood(0));
  Assert.IsFalse(S.IsGood(1));
  Assert.IsFalse(S.IsGood(2));
  Assert.IsFalse(S.IsGood(2.1));
  Assert.IsFalse(S.IsBad(2));
  Assert.IsFalse(S.IsBad(2.1));

  S.Bad := 1;
  S.Good := 0;
  Assert.AreEqual(S.BGLow, Consts.NegativeInfinity);
  Assert.AreEqual(S.BGHigh, Consts.PositiveInfinity);
end;

method DexiScalesTest.TestDiscreteScaleOpsAscending;
begin
  var S := new DexiDiscreteScale;
  S.AddValue('a');
  CheckScale(S, 0, 0, Consts.NegativeInfinity, Consts.PositiveInfinity, 'a');
  S.AddValue('b');
  CheckScale(S, 0, 1, 0.5, 0.5, 'ab');
  S.AddValue('c');
  CheckScale(S, 0, 2, 0, 2, 'abc');
  S.AddValue('d');
  CheckScale(S, 0, 3, 0, 3, 'abcd');
  S.AddValue('e');
  CheckScale(S, 0, 4, 0, 4, 'abcde');
  S.AddValue('f');
  CheckScale(S, 0, 5, 0, 5, 'abcdef');
  S.InsertValue(0, 'i');
  CheckScale(S, 0, 6, 1, 6, 'iabcdef');
  S.InsertValue(6, 'j');
  CheckScale(S, 0, 7, 1, 7, 'iabcdejf');
  S.DeleteValue(1);
  CheckScale(S, 0, 6, 1, 6, 'ibcdejf');
  S.DeleteValue(4);
  CheckScale(S, 0, 5, 1, 5, 'ibcdjf');
  S.DeleteValue(4);
  CheckScale(S, 0, 4, 1, 4, 'ibcdf');
  S.DeleteValue(4);
  CheckScale(S, 0, 3, 1, 3, 'ibcd');
  S.MovePrev(2);
  CheckScale(S, 0, 3, 1, 3, 'icbd');
  S.MovePrev(1);
  CheckScale(S, 0, 3, 1, 3, 'cibd');

  S.Reverse;
  CheckScale(S, 0, 3, 2, 0, 'dbic');
  while S.Count > 0 do
    S.DeleteValue(S.HighInt);
  CheckScale(S, 0, -1, Consts.PositiveInfinity, Consts.NegativeInfinity, '');
end;

method DexiScalesTest.TestDiscreteScaleOpsAscendingLow;
begin
  var S := new DexiDiscreteScale;
  S.AddValue('a');
  CheckScale(S, 0, 0, Consts.NegativeInfinity, Consts.PositiveInfinity, 'a');
  S.AddValue('b');
  CheckScale(S, 0, 1, 0.5, 0.5, 'ab');
  S.AddValue('c');
  CheckScale(S, 0, 2, 0, 2, 'abc');
  S.InsertValue(0, 'd');
  CheckScale(S, 0, 3, 1, 3, 'dabc');
  S.InsertValue(0, 'e');
  CheckScale(S, 0, 4, 2, 4, 'edabc');
  S.InsertValue(0, 'f');
  CheckScale(S, 0, 5, 3, 5, 'fedabc');
  S.InsertValue(0, 'i');
  CheckScale(S, 0, 6, 4, 6, 'ifedabc');
  S.MoveNext(5);
  CheckScale(S, 0, 6, 4, 6, 'ifedacb');
  S.DeleteValue(5);
  CheckScale(S, 0, 5, 4, 5, 'ifedab');
  S.DeleteValue(0);
  CheckScale(S, 0, 4, 3, 4, 'fedab');
  S.DeleteValue(0);
  CheckScale(S, 0, 3, 2, 3, 'edab');
  S.DeleteValue(0);
  CheckScale(S, 0, 2, 1, 2, 'dab');
  S.DeleteValue(0);
  CheckScale(S, 0, 1, 0, 1, 'ab');
  S.DeleteValue(0);
  CheckScale(S, 0, 0, Consts.NegativeInfinity, Consts.PositiveInfinity, 'b');
  S.DeleteValue(0);
  CheckScale(S, 0, -1, Consts.NegativeInfinity, Consts.PositiveInfinity, '');
end;

method DexiScalesTest.TestDiscreteScaleOpsAscendingHigh;
begin
  var S := new DexiDiscreteScale;
  S.AddValue('a');
  CheckScale(S, 0, 0, Consts.NegativeInfinity, Consts.PositiveInfinity, 'a');
  S.AddValue('b');
  CheckScale(S, 0, 1, 0.5, 0.5, 'ab');
  S.AddValue('c');
  CheckScale(S, 0, 2, 0, 2, 'abc');
  S.InsertValue(3, 'd');
  CheckScale(S, 0, 3, 0, 3, 'abcd');
  S.InsertValue(4, 'e');
  CheckScale(S, 0, 4, 0, 4, 'abcde');
  S.Good := 3;
  CheckScale(S, 0, 4, 0, 3, 'abcde');
  S.InsertValue(5, 'f');
  CheckScale(S, 0, 5, 0, 4, 'abcdef');
  S.InsertValue(6, 'i');
  CheckScale(S, 0, 6, 0, 5, 'abcdefi');
  S.MoveNext(0);
  CheckScale(S, 0, 6, 0, 5, 'bacdefi');
  S.DeleteValue(5);
  CheckScale(S, 0, 5, 0, 5, 'bacdei');
  S.DeleteValue(1);
  CheckScale(S, 0, 4, 0, 4, 'bcdei');
  S.DeleteValue(0);
  CheckScale(S, 0, 3, 0, 3, 'cdei');
  S.DeleteValue(3);
  CheckScale(S, 0, 2, 0, 2, 'cde');
  S.DeleteValue(0);
  CheckScale(S, 0, 1, 0, 1, 'de');
  S.DeleteValue(1);
  CheckScale(S, 0, 0, Consts.NegativeInfinity, Consts.PositiveInfinity, 'd');
  S.DeleteValue(0);
  CheckScale(S, 0, -1, Consts.NegativeInfinity, Consts.PositiveInfinity, '');
end;

method DexiScalesTest.TestDiscreteScaleOpsDescending;
begin
  var S := new DexiDiscreteScale;
  S.Reverse;
  S.AddValue('a');
  CheckScale(S, 0, 0, Consts.PositiveInfinity, Consts.NegativeInfinity, 'a');
  S.AddValue('b');
  CheckScale(S, 0, 1, 0.5, 0.5, 'ab');
  S.AddValue('c');
  CheckScale(S, 0, 2, 2, 0, 'abc');
  S.AddValue('d');
  CheckScale(S, 0, 3, 3, 0, 'abcd');
  S.AddValue('e');
  CheckScale(S, 0, 4, 4, 0, 'abcde');
  S.AddValue('f');
  CheckScale(S, 0, 5, 5, 0, 'abcdef');
  S.InsertValue(0, 'i');
  CheckScale(S, 0, 6, 6, 1, 'iabcdef');
  S.InsertValue(6, 'j');
  CheckScale(S, 0, 7, 7, 1, 'iabcdejf');
  S.DeleteValue(1);
  CheckScale(S, 0, 6, 6, 1, 'ibcdejf');
  S.DeleteValue(4);
  CheckScale(S, 0, 5, 5, 1, 'ibcdjf');
  S.DeleteValue(4);
  CheckScale(S, 0, 4, 4, 1, 'ibcdf');
  S.DeleteValue(4);
  CheckScale(S, 0, 3, 3, 1, 'ibcd');
  S.MovePrev(2);
  CheckScale(S, 0, 3, 3, 1, 'icbd');
  S.MovePrev(1);
  CheckScale(S, 0, 3, 3, 1, 'cibd');

  S.Reverse;
  CheckScale(S, 0, 3, 0, 2, 'dbic');
  while S.Count > 0 do
    S.DeleteValue(S.HighInt);
  CheckScale(S, 0, -1, Consts.NegativeInfinity, Consts.PositiveInfinity, '');
end;

method DexiScalesTest.TestAssignContCont;
begin
  var S1 := new DexiContinuousScale;
  var S2 := new DexiContinuousScale;
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsTrue(S1.EqualTo(S2));

  S1.ScaleUnit := 'unit';
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsFalse(S1.EqualTo(S2));

  S1.Bad := -1;
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsFalse(S1.EqualTo(S2));

  S2.AssignScale(S1);
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsTrue(S1.EqualTo(S2));
  Assert.IsTrue(S2.EqualTo(S1));
  Assert.AreEqual(S2.ScaleUnit, 'unit');
  Assert.AreEqual(S2.Bad, -1);
end;

method DexiScalesTest.TestAssignDiscDisc;
begin
  var S1 := new DexiDiscreteScale;
  var S2 := new DexiDiscreteScale;
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsTrue(S1.EqualTo(S2));

  S1.ScaleUnit := 'unit';
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsFalse(S1.EqualTo(S2));

  S1.Bad := -1;
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsFalse(S1.EqualTo(S2));

  S1.AddValue('a');
  S1.AddValue('b');
  S1.AddValue('c');

  S2.AssignScale(S1);
  Assert.IsTrue(S1.CompatibleWith(S2));
  Assert.IsTrue(S1.EqualTo(S2));
  Assert.IsTrue(S2.EqualTo(S1));
  Assert.AreEqual(S2.ScaleUnit, 'unit');
  Assert.AreEqual(S1.Bad, S2.Bad);
  Assert.AreEqual(S1.Count, S2.Count);
  for i := 0 to S1.Count -1 do
    Assert.AreEqual(S1.Names[i], S2.Names[i]);
end;

method DexiScalesTest.TestAssignDiscCont;
begin
  var S1 := new DexiDiscreteScale;
  var S2 := new DexiContinuousScale;
  Assert.IsFalse(S1.CompatibleWith(S2));
  Assert.IsFalse(S1.EqualTo(S2));

  S1.ScaleUnit := 'unit';
  S1.AddValue('a');

  S2.AssignScale(S1);
  Assert.IsFalse(S1.CompatibleWith(S2));
  Assert.IsFalse(S2.CompatibleWith(S1));
  Assert.IsFalse(S1.EqualTo(S2));
  Assert.IsFalse(S2.EqualTo(S1));
  Assert.AreEqual(S2.ScaleUnit, 'unit');
end;

method DexiScalesTest.TestAssignContDisc;
begin
  var S1 := new DexiContinuousScale;
  var S2 := new DexiDiscreteScale;
  Assert.IsFalse(S1.CompatibleWith(S2));
  Assert.IsFalse(S1.EqualTo(S2));

  S1.ScaleUnit := 'unit';
  S2.AddValue('a');

  S2.AssignScale(S1);
  Assert.IsFalse(S1.CompatibleWith(S2));
  Assert.IsFalse(S2.CompatibleWith(S1));
  Assert.IsFalse(S1.EqualTo(S2));
  Assert.IsFalse(S2.EqualTo(S1));
  Assert.AreEqual(S2.ScaleUnit, 'unit');
  Assert.AreEqual(S2.Count, 0);
end;

method DexiScalesTest.TestCompatibleWith;

  method DiscreteScale(aValues: Integer; aOrder: DexiOrder): DexiDiscreteScale;
  begin
    result := new DexiDiscreteScale;
    result.Order := aOrder;
    for i := 0 to aValues - 1 do
      result.AddValue(Utils.IntToStr(i + 1));
  end;

begin
  for i := 0 to 3 do
    for j := 0 to 3 do
      for each p in [DexiOrder.None, DexiOrder.Ascending, DexiOrder.Descending] do
        for each q in [DexiOrder.None, DexiOrder.Ascending, DexiOrder.Descending] do
          begin
            var S1 := DiscreteScale(i, p);
            var S2 := DiscreteScale(j, q);
            var lComp := (i = j) and (p = q);
            Assert.AreEqual(S1.CompatibleWith(S2), lComp);
            Assert.AreEqual(S2.CompatibleWith(S1), lComp);
          end;
end;

type
 TestRecord = record
  ValIntSingle: DexiIntSingle;
  ValIntInterval: DexiIntInterval;
  ValIntSet: DexiIntSet;
  ValDistribution: DexiDistribution;
  ValFltSingle: DexiFltSingle;
  ValFltInterval: DexiFltInterval;
  ContinuousScale: DexiContinuousScale;
  DiscreteScale: DexiDiscreteScale;
  method Make;
 end;

method TestRecord.Make;
begin
  ValIntSingle := new DexiIntSingle;
  ValIntInterval := new DexiIntInterval;
  ValIntSet := new DexiIntSet;
  ValDistribution := new DexiDistribution;
  ValFltSingle := new DexiFltSingle;
  ValFltInterval := new DexiFltInterval;
  ContinuousScale := new DexiContinuousScale;
  DiscreteScale := new DexiDiscreteScale;
  DiscreteScale.AddValue('a');
  DiscreteScale.AddValue('b');
end;

method DexiScalesTest.TestValueInScaleBounds;
var R: TestRecord;
begin
  R.Make;
  R.ValIntSingle.Value := 1;
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntSingle, R.ContinuousScale));
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntSingle, R.DiscreteScale));
  R.ValIntSingle.Value := 2;
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntSingle, R.ContinuousScale));
  Assert.IsFalse(DexiScale.ValueInScaleBounds(R.ValIntSingle, R.DiscreteScale));

  R.ValIntInterval.Value := Values.IntInt(0, 1);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntInterval, R.ContinuousScale));
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntInterval, R.DiscreteScale));
  R.ValIntInterval.Value := Values.IntInt(0, 3);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntInterval, R.ContinuousScale));
  Assert.IsFalse(DexiScale.ValueInScaleBounds(R.ValIntInterval, R.DiscreteScale));

  R.ValIntSet.Value := Values.IntSet([0, 1]);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntSet, R.ContinuousScale));
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntSet, R.DiscreteScale));
  R.ValIntSet.Value := Values.IntSet([0, 3]);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValIntSet, R.ContinuousScale));
  Assert.IsFalse(DexiScale.ValueInScaleBounds(R.ValIntSet, R.DiscreteScale));

  R.ValDistribution.Value := Values.Distr(0, [0.1, 1]);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValDistribution, R.ContinuousScale));
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValDistribution, R.DiscreteScale));
  R.ValDistribution.Value := Values.Distr(0, [0.1, 1, 1]);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValDistribution, R.ContinuousScale));
  Assert.IsFalse(DexiScale.ValueInScaleBounds(R.ValDistribution, R.DiscreteScale));

  R.ValFltSingle.Value := 0.5;
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValFltSingle, R.ContinuousScale));
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValFltSingle, R.DiscreteScale));
  R.ValFltSingle.Value := 1.5;
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValFltSingle, R.ContinuousScale));
  Assert.IsFalse(DexiScale.ValueInScaleBounds(R.ValFltSingle, R.DiscreteScale));

  R.ValFltInterval.Value := Values.FltInt(0, 0.5);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValFltInterval, R.ContinuousScale));
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValFltInterval, R.DiscreteScale));
  R.ValFltInterval.Value := Values.FltInt(0, 1.5);
  Assert.IsTrue(DexiScale.ValueInScaleBounds(R.ValFltInterval, R.ContinuousScale));
  Assert.IsFalse(DexiScale.ValueInScaleBounds(R.ValFltInterval, R.DiscreteScale));
end;

method DexiScalesTest.TestValueInToScaleBounds;
var R: TestRecord;

  method Test(aIn: Boolean; aValue: DexiValue; aScale: DexiScale);
  begin
    if DexiScale.ValueInScaleBounds(aValue, aScale) then
      Assert.IsTrue(aIn)
    else
      begin
        var lValue := DexiScale.ValueIntoScaleBounds(aValue, aScale);
        Assert.IsTrue(DexiScale.ValueInScaleBounds(lValue, aScale));
        Assert.IsFalse(aIn);
      end;
  end;

begin
  R.Make;
  R.ValIntSingle.Value := 1;
  Test(true, R.ValIntSingle, R.ContinuousScale);
  R.ValIntSingle.Value := 1;
  R.ValIntSingle.Value := 1;
  Test(true, R.ValIntSingle, R.DiscreteScale);
  R.ValIntSingle.Value := 2;
  Test(true, R.ValIntSingle, R.ContinuousScale);
  R.ValIntSingle.Value := 2;
  R.ValIntSingle.Value := 2;
  Test(false, R.ValIntSingle, R.DiscreteScale);

  R.ValIntInterval.Value := Values.IntInt(0, 1);
  Test(true, R.ValIntInterval, R.ContinuousScale);
  R.ValIntInterval.Value := Values.IntInt(0, 1);
  R.ValIntInterval.Value := Values.IntInt(0, 1);
  Test(true, R.ValIntInterval, R.DiscreteScale);
  R.ValIntInterval.Value := Values.IntInt(0, 3);
  Test(true, R.ValIntInterval, R.ContinuousScale);
  R.ValIntInterval.Value := Values.IntInt(0, 3);
  R.ValIntInterval.Value := Values.IntInt(0, 3);
  Test(false, R.ValIntInterval, R.DiscreteScale);

  R.ValIntSet.Value := Values.IntSet([0, 1]);
  Test(true, R.ValIntSet, R.ContinuousScale);
  R.ValIntSet.Value := Values.IntSet([0, 1]);
  R.ValIntSet.Value := Values.IntSet([0, 1]);
  Test(true, R.ValIntSet, R.DiscreteScale);
  R.ValIntSet.Value := Values.IntSet([0, 3]);
  Test(true, R.ValIntSet, R.ContinuousScale);
  R.ValIntSet.Value := Values.IntSet([0, 3]);
  R.ValIntSet.Value := Values.IntSet([0, 3]);
  Test(false, R.ValIntSet, R.DiscreteScale);

  R.ValDistribution.Value := Values.Distr(0, FltArray([0.1, 1]));
  Test(true, R.ValDistribution, R.ContinuousScale);
  R.ValDistribution.Value := Values.Distr(0, FltArray([0.1, 1]));
  R.ValDistribution.Value := Values.Distr(0, FltArray([0.1, 1]));
  Test(true, R.ValDistribution, R.DiscreteScale);
  R.ValDistribution.Value := Values.Distr(0, FltArray([0.1, 1, 1]));
  Test(true, R.ValDistribution, R.ContinuousScale);
  R.ValDistribution.Value := Values.Distr(0, FltArray([0.1, 1, 1]));
  R.ValDistribution.Value := Values.Distr(0, FltArray([0.1, 1, 1]));
  Test(false, R.ValDistribution, R.DiscreteScale);

  R.ValFltSingle.Value := 0.5;
  Test(true, R.ValFltSingle, R.ContinuousScale);
  R.ValFltSingle.Value := 0.5;
  R.ValFltSingle.Value := 0.5;
  Test(true, R.ValFltSingle, R.DiscreteScale);
  R.ValFltSingle.Value := 1.5;
  Test(true, R.ValFltSingle, R.ContinuousScale);
  R.ValFltSingle.Value := 1.5;
  R.ValFltSingle.Value := 1.5;
  Test(false, R.ValFltSingle, R.DiscreteScale);

  R.ValFltInterval.Value := Values.FltInt(0, 0.5);
  Test(true, R.ValFltInterval, R.ContinuousScale);
  R.ValFltInterval.Value := Values.FltInt(0, 0.5);
  R.ValFltInterval.Value := Values.FltInt(0, 0.5);
  Test(true, R.ValFltInterval, R.DiscreteScale);
  R.ValFltInterval.Value := Values.FltInt(0, 1.5);
  Test(true, R.ValFltInterval, R.ContinuousScale);
  R.ValFltInterval.Value := Values.FltInt(0, 1.5);
  R.ValFltInterval.Value := Values.FltInt(0, 1.5);
  Test(false, R.ValFltInterval, R.DiscreteScale);
 end;

type
  TestScalesString = class(CompositeString)
  public
    method ElementAsString(aIdx: Integer): String; override;
    begin
      var lTag := Tag[aIdx];
      var lTagStr :=
        if lTag < 0 then 'B'
        else if lTag > 0 then 'G'
        else 'N';
      result := $"<{lTagStr}>{Str[aIdx]}";
    end;
  end;

method DexiScalesTest.CheckValueOnScale(aValue: DexiValue; aScale: DexiScale; aStr: String);
begin
  var vs := new DexiScaleStrings(StringCreate := method begin result := new TestScalesString; end);
  var lStr := vs.ValueOnScaleString(aValue, aScale);
  Assert.AreEqual(lStr, aStr);
end;

method DexiScalesTest.CheckValueOnScale(aValue: IntOffsets; aScale: DexiScale; aStr: String);
begin
  var vs := new DexiScaleStrings(StringCreate := method begin result := new TestScalesString; end);
  var lStr := vs.ValueOnScaleString(aValue, aScale);
  Assert.AreEqual(lStr, aStr);
end;

method DexiScalesTest.CheckScaleString(aScale: DexiScale; aStr: String);
begin
  var vs := new DexiScaleStrings(StringCreate := method begin result := new TestScalesString; end);
  var lStr := vs.ScaleString(aScale);
  Assert.AreEqual(lStr, aStr);
end;

method DexiScalesTest.TestCompositeContinuousAscending;
begin
  var S := new DexiContinuousScale;
  S.Bad := 4.0;
  S.Good := 6.0;
  var V: DexiValue := new DexiIntSingle;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntInterval;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(3,5);
  CheckValueOnScale(V, S, '<B>3<N>:<N>5');
  V := new DexiIntSet;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntSet;
  V.AsIntInterval := Values.IntInt(3,5);
  CheckValueOnScale(V, S, '<B>3<N>:<N>5');
  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([3,5,7]);
  CheckValueOnScale(V, S, '<B>3<N>;<N>5<N>;<G>7');
  V := new DexiFltSingle;
  V.AsFloat := 5.5;
  CheckValueOnScale(V, S, '<N>5.50');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,5.5);
  CheckValueOnScale(V, S, '<B>3.30<N>:<N>5.50');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,7.77);
  CheckValueOnScale(V, S, '<B>3.30<N>:<G>7.77');
  S.FltDecimals := -1;
  V := new DexiFltSingle;
  V.AsFloat := 5.5;
  CheckValueOnScale(V, S, '<N>5.5');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,5.5);
  CheckValueOnScale(V, S, '<B>3.3<N>:<N>5.5');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,7.77);
  CheckValueOnScale(V, S, '<B>3.3<N>:<G>7.77');
end;

method DexiScalesTest.TestCompositeContinuousDescending;
begin
  var S := new DexiContinuousScale;
  S.Order := DexiOrder.Descending;
  S.Good := 4.0;
  S.Bad := 6.0;
  S.FltDecimals := -1;
  var V: DexiValue := new DexiIntSingle;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntInterval;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(3,5);
  CheckValueOnScale(V, S, '<G>3<N>:<N>5');
  V := new DexiIntSet;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntSet;
  V.AsIntInterval := Values.IntInt(3,5);
  CheckValueOnScale(V, S, '<G>3<N>:<N>5');
  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([3,5,7]);
  CheckValueOnScale(V, S, '<G>3<N>;<N>5<N>;<B>7');
  V := new DexiFltSingle;
  V.AsFloat := 5.5;
  CheckValueOnScale(V, S, '<N>5.5');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,5.5);
  CheckValueOnScale(V, S, '<G>3.3<N>:<N>5.5');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,7.77);
  CheckValueOnScale(V, S, '<G>3.3<N>:<B>7.77');
end;

method DexiScalesTest.TestCompositeContinuousUnordered;
begin
  var S := new DexiContinuousScale;
  S.Order := DexiOrder.None;
  S.Good := 4.0;
  S.Bad := 6.0;
  S.FltDecimals := -1;
  var V: DexiValue := new DexiIntSingle;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntInterval;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(3,5);
  CheckValueOnScale(V, S, '<N>3<N>:<N>5');
  V := new DexiIntSet;
  V.AsInteger := 5;
  CheckValueOnScale(V, S, '<N>5');
  V := new DexiIntSet;
  V.AsIntInterval := Values.IntInt(3,5);
  CheckValueOnScale(V, S, '<N>3<N>:<N>5');
  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([3,5,7]);
  CheckValueOnScale(V, S, '<N>3<N>;<N>5<N>;<N>7');
  V := new DexiFltSingle;
  V.AsFloat := 5.5;
  CheckValueOnScale(V, S, '<N>5.5');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,5.5);
  CheckValueOnScale(V, S, '<N>3.3<N>:<N>5.5');
  V := new DexiFltInterval;
  V.AsFltInterval := Values.FltInt(3.3,7.77);
  CheckValueOnScale(V, S, '<N>3.3<N>:<N>7.77');
end;

method DexiScalesTest.TestCompositeDiscreteAscending;
begin
  var S := new DexiDiscreteScale(['L', 'M', 'H']);
  CheckScaleString(S, '<B>L<N>;<N>M<N>;<G>H');
  var V: DexiValue := new DexiIntSingle;
  V.AsInteger := 0;
  CheckValueOnScale(V, S, '<B>L');
  V := new DexiIntSingle;
  V.AsInteger := 1;
  CheckValueOnScale(V, S, '<N>M');
  V := new DexiIntSingle;
  V.AsInteger := 2;
  CheckValueOnScale(V, S, '<G>H');
  V := new DexiIntInterval;
  V.AsInteger := 0;
  CheckValueOnScale(V, S, '<B>L');
  V := new DexiIntInterval;
  V.AsInteger := 1;
  CheckValueOnScale(V, S, '<N>M');
  V := new DexiIntInterval;
  V.AsInteger := 2;
  CheckValueOnScale(V, S, '<G>H');

  S.IsInterval := false;
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,2);
  CheckValueOnScale(V, S, '<B>L<N>;<N>M<N>;<G>H');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(1,2);
  CheckValueOnScale(V, S, '<N>M<N>;<G>H');

  S.IsInterval := true;
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,2);
  CheckValueOnScale(V, S, '<N>*');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,1);
  CheckValueOnScale(V, S, '<N><=<N>M');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(1,2);
  CheckValueOnScale(V, S, '<N>>=<N>M');

  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([0,1,2]);
  CheckValueOnScale(V, S, '<N>*');

  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([0,2]);
  CheckValueOnScale(V, S, '<B>L<N>;<G>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0]);
  CheckValueOnScale(V, S, '<B>L');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 1.0]);
  CheckValueOnScale(V, S, '<N><=<N>M');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 0.0, 1.0]);
  CheckValueOnScale(V, S, '<B>L<N>;<G>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 0.5, 1.0]);
  CheckValueOnScale(V, S, '<B>L<N>;<N>M<N>/0.5<N>;<G>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [0.1, 1.0, 0.5]);
  CheckValueOnScale(V, S, '<B>L<N>/0.1<N>;<N>M<N>;<G>H<N>/0.5');

  var O := Offsets.IntOffsets([0, 1]);
  CheckValueOnScale(O, S, '<B>L<N>;<N>M');

  O := Offsets.IntOffsets([0, 2], [0.1, -0.2]);
  CheckValueOnScale(O, S, '<B>L<N>+<N>0.1<N>;<G>H<N>−<N>0.2');
end;

method DexiScalesTest.TestCompositeDiscreteDescending;
begin
  var S := new DexiDiscreteScale(['L', 'M', 'H']);
  S.Order := DexiOrder.Descending;
  CheckScaleString(S, '<G>L<N>;<N>M<N>;<B>H');
  var V: DexiValue := new DexiIntSingle;
  V.AsInteger := 0;
  CheckValueOnScale(V, S, '<G>L');
  V := new DexiIntSingle;
  V.AsInteger := 1;
  CheckValueOnScale(V, S, '<N>M');
  V := new DexiIntSingle;
  V.AsInteger := 2;
  CheckValueOnScale(V, S, '<B>H');
  V := new DexiIntInterval;
  V.AsInteger := 0;
  CheckValueOnScale(V, S, '<G>L');
  V := new DexiIntInterval;
  V.AsInteger := 1;
  CheckValueOnScale(V, S, '<N>M');
  V := new DexiIntInterval;
  V.AsInteger := 2;
  CheckValueOnScale(V, S, '<B>H');

  S.IsInterval := false;
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,2);
  CheckValueOnScale(V, S, '<G>L<N>;<N>M<N>;<B>H');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(1,2);
  CheckValueOnScale(V, S, '<N>M<N>;<B>H');

  S.IsInterval := true;
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,2);
  CheckValueOnScale(V, S, '<N>*');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,1);
  CheckValueOnScale(V, S, '<N>>=<N>M');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(1,2);
  CheckValueOnScale(V, S, '<N><=<N>M');

  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([0,1,2]);
  CheckValueOnScale(V, S, '<N>*');

  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([0,2]);
  CheckValueOnScale(V, S, '<G>L<N>;<B>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0]);
  CheckValueOnScale(V, S, '<G>L');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 1.0]);
  CheckValueOnScale(V, S, '<N>>=<N>M');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 0.0, 1.0]);
  CheckValueOnScale(V, S, '<G>L<N>;<B>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 0.5, 1.0]);
  CheckValueOnScale(V, S, '<G>L<N>;<N>M<N>/0.5<N>;<B>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [0.1, 1.0, 0.5]);
  CheckValueOnScale(V, S, '<G>L<N>/0.1<N>;<N>M<N>;<B>H<N>/0.5');

  var O := Offsets.IntOffsets([0, 1]);
  CheckValueOnScale(O, S, '<G>L<N>;<N>M');

  O := Offsets.IntOffsets([0, 2], [0.1, -0.2]);
  CheckValueOnScale(O, S, '<G>L<N>+<N>0.1<N>;<B>H<N>−<N>0.2');
end;

method DexiScalesTest.TestCompositeDiscreteUnordered;
begin
  var S := new DexiDiscreteScale(['L', 'M', 'H']);
  S.Order := DexiOrder.None;
  CheckScaleString(S, '<N>L<N>;<N>M<N>;<N>H');
  var V: DexiValue := new DexiIntSingle;
  V.AsInteger := 0;
  CheckValueOnScale(V, S, '<N>L');
  V := new DexiIntSingle;
  V.AsInteger := 1;
  CheckValueOnScale(V, S, '<N>M');
  V := new DexiIntSingle;
  V.AsInteger := 2;
  CheckValueOnScale(V, S, '<N>H');
  V := new DexiIntInterval;
  V.AsInteger := 0;
  CheckValueOnScale(V, S, '<N>L');
  V := new DexiIntInterval;
  V.AsInteger := 1;
  CheckValueOnScale(V, S, '<N>M');
  V := new DexiIntInterval;
  V.AsInteger := 2;
  CheckValueOnScale(V, S, '<N>H');

  S.IsInterval := false;
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,2);
  CheckValueOnScale(V, S, '<N>L<N>;<N>M<N>;<N>H');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(1,2);
  CheckValueOnScale(V, S, '<N>M<N>;<N>H');

  S.IsInterval := true;
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,2);
  CheckValueOnScale(V, S, '<N>*');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(0,1);
  CheckValueOnScale(V, S, '<N><=<N>M');
  V := new DexiIntInterval;
  V.AsIntInterval := Values.IntInt(1,2);
  CheckValueOnScale(V, S, '<N>>=<N>M');

  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([0,1,2]);
  CheckValueOnScale(V, S, '<N>*');

  V := new DexiIntSet;
  V.AsIntSet := Values.IntSet([0,2]);
  CheckValueOnScale(V, S, '<N>L<N>;<N>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0]);
  CheckValueOnScale(V, S, '<N>L');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 1.0]);
  CheckValueOnScale(V, S, '<N><=<N>M');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 0.0, 1.0]);
  CheckValueOnScale(V, S, '<N>L<N>;<N>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [1.0, 0.5, 1.0]);
  CheckValueOnScale(V, S, '<N>L<N>;<N>M<N>/0.5<N>;<N>H');

  V := new DexiDistribution;
  V.AsDistribution := Values.Distr(0, [0.1, 1.0, 0.5]);
  CheckValueOnScale(V, S, '<N>L<N>/0.1<N>;<N>M<N>;<N>H<N>/0.5');

  var O := Offsets.IntOffsets([0, 1]);
  CheckValueOnScale(O, S, '<N>L<N>;<N>M');

  O := Offsets.IntOffsets([0, 2], [0.1, -0.2]);
  CheckValueOnScale(O, S, '<N>L<N>+<N>0.1<N>;<N>H<N>−<N>0.2');
end;

method DexiScalesTest.TestCompositeContinuousScale;
begin
  var S := new DexiContinuousScale;
  CheckScaleString(S, '<B><<G>>');
  S.Bad := -10.0;
  CheckScaleString(S, '<B><<N> <B>-10<N> : <N> <G>>');
  S.Good := 10.0;
  CheckScaleString(S, '<B><<N> <B>-10<N> : <G>10<N> <G>>');
  S.Bad := Consts.NegativeInfinity;
  CheckScaleString(S, '<B><<N> <N> : <G>10<N> <G>>');
  S := new DexiContinuousScale;
  S.Reverse;
  CheckScaleString(S, '<G><<B>>');
  S.Bad := 10.0;
  CheckScaleString(S, '<G><<N> <N> : <B>10<N> <B>>');
  S.Good := -10.0;
  CheckScaleString(S, '<G><<N> <G>-10<N> : <B>10<N> <B>>');
  S.Bad := Consts.PositiveInfinity;
  CheckScaleString(S, '<G><<N> <G>-10<N> : <N> <B>>');
end;

method DexiScalesTest.TestCompositeDiscreteScale;
begin
  var S := new DexiDiscreteScale(['L', 'M', 'H']);
  CheckScaleString(S, '<B>L<N>;<N>M<N>;<G>H');
  S.Good := 1;
  CheckScaleString(S, '<B>L<N>;<G>M<N>;<G>H');
  S.Bad := 1;
  CheckScaleString(S, '<B>L<N>;<B>M<N>;<G>H');
  S.Reverse;
  CheckScaleString(S, '<G>H<N>;<B>M<N>;<B>L');

  S := new DexiDiscreteScale(['L', 'M', 'H']);
  S.Order := DexiOrder.Descending;
  CheckScaleString(S, '<G>L<N>;<N>M<N>;<B>H');
  S.Good := 1;
  CheckScaleString(S, '<G>L<N>;<G>M<N>;<B>H');
  S.Bad := 1;
  CheckScaleString(S, '<G>L<N>;<B>M<N>;<B>H');
  S.Reverse;
  CheckScaleString(S, '<B>H<N>;<B>M<N>;<G>L');

  S := new DexiDiscreteScale(['L', 'M', 'H']);
  S.Order := DexiOrder.None;
  CheckScaleString(S, '<N>L<N>;<N>M<N>;<N>H');
  S.Good := 1;
  CheckScaleString(S, '<N>L<N>;<N>M<N>;<N>H');
  S.Bad := 1;
  CheckScaleString(S, '<N>L<N>;<N>M<N>;<N>H');
  S.Reverse;
  CheckScaleString(S, '<N>H<N>;<N>M<N>;<N>L');
end;

method DexiScalesTest.TestValueParser;
var lScale := new DexiDiscreteScale(['L', 'M', 'H']);
var lScaleStrings := new DexiScaleStrings(true);

  method CheckParse(aInp, aOut: String);
  begin
    var lParser := lScaleStrings.TryParseScaleValue(aInp, lScale);
    Assert.IsTrue(String.IsNullOrEmpty(lParser.Error));
    var lValue := lParser.Value;
    var lValStr := lScaleStrings.ValueOnScaleString(lValue, lScale);
//    writeLn(lValStr);
    Assert.AreEqual(lValStr, aOut);
  end;

  method CheckParseError(aStr: String);
  begin
    var lParser := lScaleStrings.TryParseScaleValue(aStr, lScale);
    Assert.IsFalse(String.IsNullOrEmpty(lParser.Error));
//    writeLn(lParser.Error);
  end;

begin
  CheckParse(nil, '<undefined>');
  CheckParse('', '<undefined>');
  CheckParse('UNDEF', '<undefined>');
  CheckParse('UnDeFiNeD', '<undefined>');
  CheckParse('*', '*');
  CheckParse('0:2', '*');
  CheckParse('1', 'M');
  CheckParse('1:1', 'M');
  CheckParse('2:1', 'H:M');
  CheckParse('2;1', '>=M');
  CheckParse(' 2 / 0.5 ; 1 ', 'M;H/0.5');
  CheckParse('2/ 0.5 ;1/0.1', 'M/0.1;H/0.5');
  CheckParse('2;1/0.1;0', 'L;M/0.1;H');
  CheckParse('"1"', 'M');
  CheckParse('"0"', 'L');
  CheckParse(' <M ', 'L');
  CheckParse(' <=M', '<=M');
  CheckParse('>M', 'H');
  CheckParse(' > L', '>=M');
  CheckParse('>=M', '>=M');

  CheckParse('M', 'M');
  CheckParse('M:M', 'M');
  CheckParse('H:1', 'H:M');
  CheckParse('H;1', '>=M');
  CheckParse('2/0.5;M', 'M;H/0.5');
  CheckParse('H/0.5;"M"/0.1', 'M/0.1;H/0.5');
  CheckParse('2;1/0.1;"L"', 'L;M/0.1;H');

  CheckParseError('1+1');
  CheckParseError('-1');
  CheckParseError('"1''";0');
  CheckParseError('2;1/0.1;3');
  CheckParseError('2;1//0.1');
  CheckParseError('1:2/0.1');
  CheckParseError('1/0..2');
  CheckParseError('1/0.2f');
  CheckParseError('1/0.2/0.3');
  CheckParseError('V');
  CheckParseError('>=M:L');
  CheckParseError('>=M<H');

  lScaleStrings.ValueType := ValueStringType.One;
  CheckParse(nil, '<undefined>');
  CheckParse('', '<undefined>');
  CheckParse('UNDEF', '<undefined>');
  CheckParse('UnDeFiNeD', '<undefined>');
  CheckParse('2', '2');
  CheckParse('2:2', '2');
  CheckParse('3:2', '3:2');
  CheckParse('3;2', '>=2');
  CheckParse(' 3 / 0.5 ; 2 ', '2;3/0.5');
  CheckParse('3/ 0.5 ;2/0.1', '2/0.1;3/0.5');
  CheckParse('3;2/0.1;1', '1;2/0.1;3');
  CheckParse('"2"', '2');
  CheckParse('"1"', '1');
  CheckParse(' <2 ', '1');
  CheckParse(' <=2', '<=2');
  CheckParse('>2', '3');
  CheckParse(' > 1', '>=2');
  CheckParse('>=2', '>=2');

  lScale := new DexiDiscreteScale(['0', '1', '2']);
  CheckParse('1', '1');
  CheckParse('"1"', '2');
  CheckParse('1;2;3', '*');
  CheckParse('"0"; "1"; "2"', '*');

  CheckParseError('"0"; "1", "2"');
end;

end.
