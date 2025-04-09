namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

{$HIDE W28} // obsolete methods

type
  DexiQQTest = public class(DexiLibraryTest)
  private
  protected
    method WriteAlternative(aAlt: DexiOffAlternative);
  public
    method TestOffsets;
    method TestWorkApp;
    method TestEvaluateWorkApp;
    method TestEvaluateCar;
  end;

implementation

method DexiQQTest.WriteAlternative(aAlt: DexiOffAlternative);
begin
  writeLn;
  writeLn($"{aAlt.Name} {aAlt.Description}");
  for each lAtt in aAlt.Attributes do
    writeLn($"{Utils.PadTo(lAtt.Name, 20)} {Utils.FltArrayToStr(aAlt[lAtt])}");
end;

method DexiQQTest.TestOffsets;
begin
  var lOffs := Offsets.NewClassOffsets(3);

  // [NaN, NaN, NaN]
  Assert.AreEqual(length(lOffs), 3);
  for i := low(lOffs) to high(lOffs) do
    begin
      Assert.IsTrue(Consts.IsNaN(lOffs[i]));
      Assert.IsFalse(Offsets.Defined(lOffs, i));
      Assert.IsNil(Offsets.IntOffAt(lOffs, i));
      Assert.IsNaN(Offsets.ValueAt(lOffs, i));
    end;
  Assert.AreEqual(Offsets.Count(lOffs), 0);
  Assert.AreEqual(Offsets.FirstIndex(lOffs), -1);
  Assert.IsNaN(Offsets.SingleValue(lOffs));
  var lValuesOf := Offsets.ValuesOf(lOffs);
  Assert.AreEqual(length(lValuesOf), 3);
  var lIntOffs := Offsets.ClassToIntOffsets(lOffs);
  Assert.AreEqual(length(lIntOffs), 0);
  lValuesOf := Offsets.ValuesOf(lIntOffs);
  Assert.AreEqual(length(lValuesOf), 0);
  var lStr := Offsets.IntOffsetsToStr(lIntOffs);
  Assert.AreEqual(lStr, '');

  // [NaN, 0.1, NaN]
  lOffs[1] := 0.1;
  Assert.AreEqual(Offsets.Count(lOffs), 1);
  Assert.AreEqual(Offsets.FirstIndex(lOffs), 1);
  Assert.AreEqual(Offsets.SingleValue(lOffs), 1.1);
  lValuesOf := Offsets.ValuesOf(lOffs);
  Assert.AreEqual(length(lValuesOf), 3);
  Assert.IsTrue(Consts.IsNaN(lValuesOf[0]));
  Assert.IsTrue(Consts.IsNaN(lValuesOf[2]));
  Assert.AreEqual(lValuesOf[1], 1.1);
  lIntOffs := Offsets.ClassToIntOffsets(lOffs);
  Assert.AreEqual(length(lIntOffs), 1);
  Assert.AreEqual(lIntOffs[0].Int, 1);
  Assert.AreEqual(lIntOffs[0].Off, 0.1);
  lValuesOf := Offsets.ValuesOf(lIntOffs);
  Assert.AreEqual(length(lValuesOf), 1);
  Assert.AreEqual(lValuesOf[0], 1.1);
  lStr := Offsets.IntOffsetsToStr(lIntOffs);
  Assert.AreEqual(lStr, '1+0.1');
end;

method DexiQQTest.TestWorkApp;
var QQ1: DexiQQ1Model;

  method CheckQQ(aRegression, aQQ: FltArray);
  begin
    var lMin := Consts.MaxDouble;
    var lMax := Consts.MinDouble;
    for r := 0 to QQ1.Funct.Count - 1 do
      begin
        var lRuleVal := QQ1.Funct.RuleValLow[r];
        var lArgs := QQ1.Funct.ArgValues[r];
        var lRegression := QQ1.Regression(lArgs);
        Assert.IsTrue(Utils.FloatEq(lRegression, aRegression[r], 0.00001));
        var lEvaluate := QQ1.Evaluate(lArgs);
        var lQQValue := Offsets.SingleFloat(lEvaluate);
        Assert.IsFalse(Consts.IsNaN(lQQValue));
        Assert.IsTrue(Utils.FloatEq(lQQValue, aQQ[r], 0.00001));
        Assert.AreEqual(Values.IntOff(lQQValue).Int, lRuleVal);
        var lMinusArgs := Utils.NewFltArray(QQ1.ArgCount);
        var lPlusArgs := Utils.NewFltArray(QQ1.ArgCount);
        for a := 0 to QQ1.ArgCount - 1 do
          begin
            lMinusArgs[a] := lArgs[a] - Math.Sign(QQ1.WeightFactors[a]) * (0.5 - Utils.FloatEpsilon);
            lPlusArgs[a] := lArgs[a] + Math.Sign(QQ1.WeightFactors[a]) * (0.5 - Utils.FloatEpsilon);
          end;
        lEvaluate := QQ1.Evaluate(lMinusArgs);
        var lMinVal := Offsets.SingleFloat(lEvaluate);
        lEvaluate := QQ1.Evaluate(lPlusArgs);
        var lMaxVal := Offsets.SingleFloat(lEvaluate);
        lMin := Math.Min(lMin, lMinVal);
        lMax := Math.Max(lMax, lMaxVal);
      end;
    Assert.IsTrue(Utils.FloatEq(lMin, -0.5, 0.0000001));
    Assert.IsTrue(Utils.FloatEq(lMax, QQ1.ClassCount - 0.5, 0.0000001));
  end;

begin
  var Model := LoadModel('WorkApp.dxi');
  var lWorkApp := Model.AttributeByName('WORK_APP');
  var fWorkApp := lWorkApp.Funct as DexiTabularFunction;
  QQ1 := new DexiQQ1Model(fWorkApp);
  Assert.IsTrue(Utils.FltArrayEq(QQ1.WeightFactors, [0.433333333, 0.625, -0.525], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(QQ1.ClassK, [0.42403, 0.59406, 0.59406], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(QQ1.ClassN, [-0.05300, 0.49752, 0.98267], 0.00001));
  CheckQQ(
    [-0.525, 0.1, 0.725, -0.091666667, 0.533333333, 1.158333333, 0.341666667, 0.966666667, 1.591666667, 0.775, 1.4, 2.025],
    [-0.275618375, -0.010600707, 0.254416961, -0.091872792, 0.814356436, 1.185643564, 0.091872792, 1.071782178, 1.928217822, 0.275618375, 1.814356436, 2.185643564]);
end;

method DexiQQTest.TestEvaluateWorkApp;
begin
  var Model := LoadModel('WorkApp.dxi');
  var lWorkApp := Model.AttributeByName('WORK_APP');
  var fWorkApp := lWorkApp.Funct as DexiTabularFunction;
  var lEvaluator := new DexiQQEvaluator(Model);
  var lOffsets := 
    [-0.275618375, -0.010600707, 0.254416961, -0.091872792, 0.814356436, 1.185643564, 0.091872792, 1.071782178, 1.928217822, 0.275618375, 1.814356436, 2.185643564];
  for r := 0 to fWorkApp.Count - 1 do
    begin
      var lInps := fWorkApp.ArgValues[r];
      var lAlt := new DexiOffAlternative('Test', Utils.IntArrayToStr(lInps));
      for i := 0 to lWorkApp.InpCount - 1 do
        lAlt.AsInt[lWorkApp.Inputs[i]] := lInps[i];
      lEvaluator.Evaluate(lAlt);
      var lResult := lAlt[lWorkApp];
      var lIndex := Offsets.FirstIndex(lResult);
      Assert.AreEqual(lIndex, fWorkApp.RuleValLow[r]);
      var lSingle := Offsets.SingleValue(lResult);
      Assert.IsTrue(Utils.FloatEq(lSingle, lOffsets[r], 0.0000001));
    end;
end;

method DexiQQTest.TestEvaluateCar;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lEvaluator := new DexiQQEvaluator(Model);
  var lClasses := [3,                  2];
  var lOffsets := [0.131719440353461, -0.0743740795287187];
  for a := 0 to Model.AltCount - 1 do
    begin
      var lAlt := new DexiOffAlternative(Model.Alternative[a]);
      lEvaluator.Evaluate(lAlt);
      var lResult := lAlt[lCar];
      var lIndex := Offsets.FirstIndex(lResult);
      Assert.AreEqual(lIndex, lClasses[a]);
      var lSingle := Offsets.SingleValue(lResult);
      Assert.IsTrue(Utils.FloatEq(lSingle, lClasses[a] + lOffsets[a], 0.0000001));
    end;
end;

end.
