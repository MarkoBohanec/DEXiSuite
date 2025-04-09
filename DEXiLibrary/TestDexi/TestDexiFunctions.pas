namespace DexiLibrary.Tests;

{$HIDE W28} // obsolete methods

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiFunctionsTest = public class(DexiLibraryTest)
  protected
    method Make3x3to3(aOut: DexiOrder; aInp: array of DexiOrder): DexiAttribute;
    method Function3x3to3(aAtt: DexiAttribute; aVals: array of String; aUseConsist: Boolean := false): DexiTabularFunction;
    method ValueList(aFnc: DexiTabularFunction): List<String>;
    method CheckFunction(aFnc: DexiTabularFunction; aVals: array of String);
    method Make1x1Discr(aOut, aInp: DexiOrder): DexiAttribute;
    method ValueList(aFnc: DexiDiscretizeFunction): List<String>;
    method CheckFunction(aFnc: DexiDiscretizeFunction; aVals: array of String);
    method CheckBounds(aFnc: DexiDiscretizeFunction; aVals: array of Float);
    class const oA = DexiOrder.Ascending;
    class const oD = DexiOrder.Descending;
    class const o0 = DexiOrder.None;
    class const L = PrefCompare.Lower;
    class const G = PrefCompare.Greater;
    class const Q = PrefCompare.Equal;
    class const X = PrefCompare.No;
	public
    method TestDexiRule;
    method TestTabularCreate;
    method TestTabularAssign;
    method TestTabularWeights;
    method TestTabularProperties;
    method TestTabularProjection;
    method TestTabularCompareRules;
    method TestTabularCompareRuleValues;
    method TestTabularConsistency;
    method TestTabularInsertArgValue;
    method TestTabularDeleteArgValue;
    method TestTabularExchangeArgs;
    method TestTabularReverseAttr;
    method TestTabularInsertFncValue;
    method TestTabularDeleteFncValue;
    method TestTabularRulesOld;
    method TestTabularRules;
    method TestTabularClassProbabilities;
    method TestTabularClassProbWhere;
    method TestTabularImpurity;
    method TestDexiBound;
    method TestDexiValueCell;
    method TestDiscretizeCreate;
    method TestDiscretizeAssign;
    method TestDiscretizeMeasures;
    method TestDiscretizeConsistAsc;
    method TestDiscretizeConsistDesc;
    method TestDiscretizeAddDelete;
    method TestDiscretizeChangeBound;
    method TestDiscretizeEvaluate;
    method TestSelect;
    method TestSelectFrom;
    method TestValuesEqual;
    method TestMarginals;
    method TestMarginalsNorm;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiFunctionsTest.Make3x3to3(aOut: DexiOrder; aInp: array of DexiOrder): DexiAttribute;
begin
  result := new DexiAttribute('Y');
  result.Scale := new DexiDiscreteScale(['a', 'b', 'c'], &Order := aOut);
  for i := low(aInp) to high(aInp) do
    begin
      var A := new DexiAttribute('X' + Utils.IntToStr(i + 1));
      A.Scale := new DexiDiscreteScale(['a', 'b', 'c'], &Order := aInp[i]);
      result.AddInput(A);
    end;
end;

method DexiFunctionsTest.Function3x3to3(aAtt: DexiAttribute; aVals: array of String; aUseConsist: Boolean := false): DexiTabularFunction;
begin
  result := new DexiTabularFunction(aAtt);
  result.ClearValues;
  result.UseConsist := aUseConsist;
  for each lVal in aVals index x do
    if lVal <> '' then
      begin
        result.RuleValue[x] :=
          if String.IsNullOrEmpty(lVal) then nil
          else if lVal = '*' then new DexiIntSet(aAtt.FullSet)
          else DexiValue.FromString(lVal);
        result.RuleEntered[x] := true;
      end;
end;

method DexiFunctionsTest.ValueList(aFnc: DexiTabularFunction): List<String>;
begin
  result := new List<String>;
  for x := 0 to aFnc.Count - 1 do
    result.Add(DexiValue.ToString(aFnc.RuleValue[x]));
end;

method DexiFunctionsTest.CheckFunction(aFnc: DexiTabularFunction; aVals: array of String);
begin
  var lList := ValueList(aFnc);
  Assert.AreEqual(aFnc.Count, length(aVals));
  for each lVal in aVals index x do
    begin
      var lValue := aFnc.RuleValue[x];
      var lValStr := lList[x];
      if lVal = nil then
        Assert.IsNil(lValue)
      else if lVal = '' then
        Assert.IsTrue(not lValue.IsDefined)
      else if lVal = '*' then
        Assert.IsTrue(Values.IntSetEq(lValue.AsIntSet, aFnc.Attribute.FullSet))
      else
        Assert.AreEqual(lValStr, lVal);
    end;
end;

method DexiFunctionsTest.Make1x1Discr(aOut, aInp: DexiOrder): DexiAttribute;
begin
  result := new DexiAttribute('Y');
  result.Scale := new DexiDiscreteScale(['a', 'b', 'c'], &Order := aOut);
  var lInp := new DexiAttribute('X');
  lInp.Scale := new DexiContinuousScale(&Order := aInp);
  result.AddInput(lInp);
end;

method DexiFunctionsTest.ValueList(aFnc: DexiDiscretizeFunction): List<String>;
begin
  result := new List<String>;
  for x := 0 to aFnc.Count - 1 do
    result.Add(DexiValue.ToString(aFnc.IntervalValue[x]));
end;

method DexiFunctionsTest.CheckFunction(aFnc: DexiDiscretizeFunction; aVals: array of String);
begin
  var lList := ValueList(aFnc);
  Assert.AreEqual(aFnc.IntervalCount, length(aVals));
  for each lVal in aVals index x do
    begin
      var lValue := aFnc.IntervalValue[x];
      var lValStr := lList[x];
      if lVal = nil then
        Assert.IsNil(lValue)
      else if lVal = '' then
        Assert.IsTrue(not lValue.IsDefined)
      else if lVal = '*' then
        Assert.IsTrue(Values.IntSetEq(lValue.AsIntSet, aFnc.Attribute.FullSet))
      else
        Assert.AreEqual(lValStr, lVal);
    end;
end;

method DexiFunctionsTest.CheckBounds(aFnc: DexiDiscretizeFunction; aVals: array of Float);
begin
  Assert.AreEqual(aFnc.BoundCount - 2, length(aVals));
  for x := low(aVals) to high(aVals) do
    Assert.IsTrue(Utils.FloatEq(aFnc.IntervalHighBound[x].Bound, aVals[x]));
end;

method DexiFunctionsTest.TestDexiRule;
begin
  var lRule := new DexiRule([0, 1, 2], 1, 3);
  Assert.IsNotNil(lRule);
  var lArgs1 := lRule.Args;
  var lArgs2 := lRule.Args;
  Assert.IsTrue(lArgs1 <> lArgs2);
  Assert.IsTrue(Utils.IntArrayEq(lArgs1, lArgs2));
  Assert.IsTrue(Utils.IntArrayEq(lArgs1, [0, 1, 2]));
  Assert.AreEqual(lRule.ArgCount, 3);
  Assert.AreEqual(lRule.LowInt, 1);
  Assert.AreEqual(lRule.HighInt, 3);
  Assert.IsTrue(lRule.Value is DexiIntInterval);
  Assert.IsTrue(lRule.IsDefined);
  Assert.AreEqual(lRule.Text, '012');
end;

method DexiFunctionsTest.TestTabularCreate;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');

  // No attribute
  var lFunct := new DexiTabularFunction;
  Assert.IsNotNil(lFunct);
  Assert.AreEqual(lFunct.Count, 0);
  Assert.AreEqual(lFunct.EntCount, 0);
  Assert.AreEqual(lFunct.DefCount, 0);
  Assert.AreEqual(lFunct.EntDefCount, 0);
  Assert.AreEqual(lFunct.ClassCount[0], 0);
  Assert.AreEqual(lFunct.FunctString, 'Rules: 0/0 (0,00%), determined: 0,00% []');
  Assert.AreEqual(lFunct.FunctClassDistr, '');
  Assert.AreEqual(lFunct.FunctStatus, '');

  // Car, full scales
  Assert.IsTrue(DexiTabularFunction.CanCreateOn(lCar));
  lFunct := new DexiTabularFunction(lCar);
  Assert.IsNotNil(lFunct);
  Assert.AreEqual(lFunct.Count, 12);
  Assert.AreEqual(lFunct.EntCount, 0);
  Assert.AreEqual(lFunct.DefCount, 12);
  Assert.AreEqual(lFunct.EntDefCount, 0);
  Assert.AreEqual(lFunct.ClassCount[0], 12);
  Assert.AreEqual(lFunct.FunctString, 'Rules: 0/12 (0,00%), determined: 0,00% [unacc:12,acc:12,good:12,exc:12]');
  Assert.AreEqual(lFunct.FunctClassDistr, 'unacc:12,acc:12,good:12,exc:12');
  Assert.AreEqual(lFunct.FunctStatus, 'Ow');

  Assert.AreEqual(lFunct.IndexOfRule([0, 0]), 0);
  Assert.AreEqual(lFunct.IndexOfRule([-1, 1]), -1);
  Assert.AreEqual(lFunct.IndexOfRule([1, 6]), -1);
  Assert.AreEqual(lFunct.IndexOfRule([1, 1]), 5);
  Assert.AreEqual(lFunct.IndexOfRule(lCar.Domain), lFunct.Count - 1);

  // Car, input scale count = 1;
  lCar.Inputs[0].Scale := new DexiDiscreteScale(['one']);
  Assert.IsTrue(DexiTabularFunction.CanCreateOn(lCar));
  lFunct := new DexiTabularFunction(lCar);
  Assert.IsNotNil(lFunct);
  Assert.AreEqual(lFunct.Count, 4);
  Assert.AreEqual(lFunct.EntCount, 0);
  Assert.AreEqual(lFunct.DefCount, 4);
  Assert.AreEqual(lFunct.EntDefCount, 0);
  Assert.AreEqual(lFunct.ClassCount[0], 4);
  Assert.AreEqual(lFunct.FunctString, 'Rules: 0/4 (0,00%), determined: 0,00% [unacc:4,acc:4,good:4,exc:4]');
  Assert.AreEqual(lFunct.FunctClassDistr, 'unacc:4,acc:4,good:4,exc:4');
  Assert.AreEqual(lFunct.FunctStatus, 'Ow');

  // Car, partial scales
  lCar.Inputs[0].Scale := nil;
  Assert.IsFalse(DexiTabularFunction.CanCreateOn(lCar));
  lFunct := new DexiTabularFunction(lCar);
  Assert.IsNotNil(lFunct);
  Assert.AreEqual(lFunct.Count, 4);
  Assert.AreEqual(lFunct.EntCount, 0);
  Assert.AreEqual(lFunct.DefCount, 4);
  Assert.AreEqual(lFunct.EntDefCount, 0);
  Assert.AreEqual(lFunct.ClassCount[0], 4);
  Assert.AreEqual(lFunct.FunctString, 'Rules: 0/4 (0,00%), determined: 0,00% [unacc:4,acc:4,good:4,exc:4]');
  Assert.AreEqual(lFunct.FunctClassDistr, 'unacc:4,acc:4,good:4,exc:4');
  Assert.AreEqual(lFunct.FunctStatus, 'Ow');

  // No input scales
  lCar.Inputs[1].Scale := nil;
  Assert.IsFalse(DexiTabularFunction.CanCreateOn(lCar));
  lFunct := new DexiTabularFunction(lCar);
  Assert.AreEqual(lFunct.Count, 1);
  Assert.AreEqual(lFunct.EntCount, 0);
  Assert.AreEqual(lFunct.DefCount, 1);
  Assert.AreEqual(lFunct.EntDefCount, 0);
  Assert.AreEqual(lFunct.ClassCount[0], 1);
  Assert.AreEqual(lFunct.FunctString, 'Rules: 0/1 (0,00%), determined: 0,00% [unacc:1,acc:1,good:1,exc:1]');
  Assert.AreEqual(lFunct.FunctClassDistr, 'unacc:1,acc:1,good:1,exc:1');
  Assert.AreEqual(lFunct.FunctStatus, 'Ow');

  // No output scale
  lCar.Scale := nil;
  Assert.IsFalse(DexiTabularFunction.CanCreateOn(lCar));

  Assert.IsFalse(DexiTabularFunction.CanCreateOn(nil));
end;

method DexiFunctionsTest.TestTabularAssign;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lPrice := Model.AttributeByName('PRICE');
  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  var lComfort := Model.AttributeByName('COMFORT');
  var fCar := lCar.Funct as DexiTabularFunction;
  var fPrice := lPrice.Funct as DexiTabularFunction;
  var fTechChar := lTechChar.Funct as DexiTabularFunction;
  var fComfort := lComfort.Funct as DexiTabularFunction;

  Assert.IsTrue(fCar.CanAssignFunction(fCar));
  Assert.IsFalse(fCar.CanAssignFunction(fPrice));
  Assert.IsFalse(fCar.CanAssignFunction(fTechChar));
  Assert.IsFalse(fCar.CanAssignFunction(fComfort));

  Assert.IsFalse(fPrice.CanAssignFunction(fCar));
  Assert.IsTrue(fPrice.CanAssignFunction(fPrice));
  Assert.IsFalse(fPrice.CanAssignFunction(fTechChar));
  Assert.IsFalse(fPrice.CanAssignFunction(fComfort));

  Assert.IsFalse(fTechChar.CanAssignFunction(fCar));
  Assert.IsFalse(fTechChar.CanAssignFunction(fPrice));
  Assert.IsTrue(fTechChar.CanAssignFunction(fTechChar));
  Assert.IsFalse(fTechChar.CanAssignFunction(fComfort));

  Assert.IsFalse(fComfort.CanAssignFunction(fCar));
  Assert.IsFalse(fComfort.CanAssignFunction(fPrice));
  Assert.IsFalse(fComfort.CanAssignFunction(fTechChar));
  Assert.IsTrue(fComfort.CanAssignFunction(fComfort));

  // Assign
  var lCarString := fCar.AsRuleString;

  var lNewCar := new DexiTabularFunction(lCar);
  var lNewCarString := lNewCar.AsRuleString;

  Assert.AreNotEqual(lCarString, lNewCarString);

  lNewCar.AssignFunction(fCar);
  lNewCarString := lNewCar.AsRuleString;
  Assert.AreEqual(lCarString, lNewCarString);

  // Assign Car through SetAsRuleString
  lNewCar := new DexiTabularFunction(lCar);
  lNewCarString := lNewCar.AsRuleString;
  Assert.AreNotEqual(lCarString, lNewCarString);

  lNewCar.SetAsRuleString(lCarString, true);
  lNewCarString := lNewCar.AsRuleString;
  Assert.AreEqual(lCarString, lNewCarString);

  // Assign Price through SetAsRuleString
  var lPriceString := fPrice.AsRuleString;
  var lNewPrice := new DexiTabularFunction(lPrice);
  var lNewPriceString := lNewPrice.AsRuleString;
  Assert.AreNotEqual(lPriceString, lNewPriceString);
  lNewPrice.SetAsRuleString(lPriceString, true);
  lNewPriceString := lNewPrice.AsRuleString;
  Assert.AreEqual(lPriceString, lNewPriceString);

  // Assign Price to TechChar
  lPriceString := fPrice.AsRuleString;
  var lTechCharString := fTechChar.AsRuleString;
  Assert.AreNotEqual(lPriceString, lTechCharString);

  fTechChar.AssignFunction(fPrice);
  lTechCharString := fTechChar.AsRuleString;
  Assert.AreEqual(lPriceString, lTechCharString);

  // Assign Car using Save/Load_StringList
  lNewCar := new DexiTabularFunction(lCar);
  lNewCarString := lNewCar.AsRuleString;
  Assert.AreNotEqual(lCarString, lNewCarString);

  var lCarList := fCar.SaveToStringList(Model.Settings);
  var lLoaded: Integer;
  var lChanged: Integer;
  lNewCar.LoadFromStringList(lCarList, Model.Settings, out lLoaded, out lChanged);
  lNewCarString := lNewCar.AsRuleString;
  Assert.AreEqual(lCarString, lNewCarString);
  Assert.AreEqual(lLoaded, 12);
  Assert.AreEqual(lChanged, 12);

  // Assign Price using Save/Load_StringList
  lNewPrice := new DexiTabularFunction(lPrice);
  lNewPriceString := lNewPrice.AsRuleString;
  Assert.AreNotEqual(lPriceString, lNewPriceString);
  Assert.AreEqual(lNewPrice.EntCount, 0);

  var lPriceList := fPrice.SaveToStringList(Model.Settings);
  lNewPrice.LoadFromStringList(lPriceList, Model.Settings, out lLoaded, out lChanged);
  lNewPriceString := lNewPrice.AsRuleString;
  Assert.AreEqual(lPriceString, lNewPriceString);
  Assert.AreEqual(lNewPrice.EntCount, 8);
  lNewPrice.SetAllEntered;
  Assert.AreEqual(lNewPrice.EntCount, 9);
end;

method DexiFunctionsTest.TestTabularWeights;

  method UpdateWeights(aFnc: DexiTabularFunction);
  begin
    aFnc.ActualWeights := nil;
    Assert.AreEqual(length(aFnc.ActualWeights), 0);
    aFnc.AffectsWeights;
    aFnc.UseWeights := true;
    aFnc.UpdateFunction;
    Assert.AreNotEqual(length(aFnc.ActualWeights), 0);
  end;

begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lPrice := Model.AttributeByName('PRICE');
  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  var lComfort := Model.AttributeByName('COMFORT');
  var fCar := lCar.Funct as DexiTabularFunction;
  var fPrice := lPrice.Funct as DexiTabularFunction;
  var fTechChar := lTechChar.Funct as DexiTabularFunction;
  var fComfort := lComfort.Funct as DexiTabularFunction;

  UpdateWeights(fCar);
  UpdateWeights(fPrice);
  UpdateWeights(fTechChar);
  UpdateWeights(fComfort);

  Assert.IsTrue(Utils.FltArrayEq(fCar.RequiredWeights, [50.0, 50.0]));
  Assert.IsTrue(Utils.FltArrayEq(fPrice.RequiredWeights, [50.0, 50.0]));
  Assert.IsTrue(Utils.FltArrayEq(fTechChar.RequiredWeights, [50.0, 50.0]));
  Assert.IsTrue(Utils.FltArrayEq(fComfort.RequiredWeights, [100/3.0, 100/3.0, 100/3.0]));

  Assert.IsTrue(Utils.FltArrayEq(fCar.ActualWeights, [60.0, 40.0]));
  Assert.IsTrue(Utils.FltArrayEq(fPrice.ActualWeights, [50.0, 50.0]));
  Assert.IsTrue(Utils.FltArrayEq(fTechChar.ActualWeights, [50.0, 50.0]));
  Assert.IsTrue(Utils.FltArrayEq(fComfort.ActualWeights, [39.0995260663507, 21.8009478672986, 39.0995260663507]));
end;

method DexiFunctionsTest.TestTabularProperties;

  method CheckProperties(aFnc: DexiTabularFunction; aCount, aEntCount: Integer; aIsConsistent, aIsActuallyMonotone, aIsSymmetric: Boolean);
  begin
    Assert.IsNotNil(aFnc);
    Assert.AreEqual(aFnc.Count, aCount);
    Assert.AreEqual(aFnc.EntCount, aEntCount);
    Assert.AreEqual(aFnc.IsConsistent, aIsConsistent);
    Assert.AreEqual(aFnc.IsActuallyMonotone, aIsActuallyMonotone);
    Assert.AreEqual(aFnc.IsSymmetric, aIsSymmetric);
  end;

  method CheckLinearity(aFnc: DexiTabularFunction; aLinearity, aLinDistance: Float);
  begin
    Assert.IsNotNil(aFnc);
    aFnc.UseWeights := true;
    aFnc.AffectsWeights;
    aFnc.UpdateFunction;
    var lCount := aFnc.LinCount(true, true);
    var lLinearity := Float(lCount)/aFnc.Count;
    var lLinDistance := aFnc.LinDistance(true);
    Assert.IsTrue(Math.Abs(lLinearity - aLinearity) < 0.000001);
    Assert.IsTrue(Math.Abs(lLinDistance - aLinDistance) < 0.000001);
  end;

begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lPrice := Model.AttributeByName('PRICE');
  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  var lComfort := Model.AttributeByName('COMFORT');
  var fCar := lCar.Funct as DexiTabularFunction;
  var fPrice := lPrice.Funct as DexiTabularFunction;
  var fTechChar := lTechChar.Funct as DexiTabularFunction;
  var fComfort := lComfort.Funct as DexiTabularFunction;

  CheckProperties(fCar,      12, 12, true, true, false);
  CheckProperties(fPrice,     9,  8, true, true, true);
  CheckProperties(fTechChar,  9,  9, true, true, true);
  CheckProperties(fComfort,  36, 36, true, true, false);

  // Comparison with DexFunctSum.R: LinDistance matches, Linearity does not
  CheckLinearity(fCar,      8.0/12,  0.5277778);
  CheckLinearity(fPrice,    4.0/9,   0.4197531);
  CheckLinearity(fTechChar, 6.0/9,   0.4197531);
  CheckLinearity(fComfort,  21.0/36, 0.4407407);

end;

method DexiFunctionsTest.TestTabularProjection;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lComfort := Model.AttributeByName('COMFORT');
  var fCar := lCar.Funct as DexiTabularFunction;
  var fComfort := lComfort.Funct as DexiTabularFunction;

  var lCar1 := fCar.Projection1([-1, 2]);
  Assert.IsTrue(Utils.IntArrayEq(lCar1, [2, 6, 10]));
  lCar1 := fCar.Projection1([1, -1]);
  Assert.IsTrue(Utils.IntArrayEq(lCar1, [4, 5, 6, 7]));

  var lComfort1 := fComfort.Projection1([2, 2, -1]);
  Assert.IsTrue(Utils.IntArrayEq(lComfort1, [30, 31, 32]));

  var lComfort2 := fComfort.Projection2([-1, 2, -1]);
  Assert.IsTrue(Utils.IntArrayEq(lComfort2[0], [6, 7, 8]));
  Assert.IsTrue(Utils.IntArrayEq(lComfort2[1], [18, 19, 20]));
  Assert.IsTrue(Utils.IntArrayEq(lComfort2[2], [30, 31, 32]));
end;

method DexiFunctionsTest.TestTabularCompareRules;

  method DifferInArgOnly(aFnc: DexiTabularFunction; aArg, aRule1, aRule2: Integer): Boolean;
  begin
    result := true;
    for i := 0 to aFnc.ArgCount - 1 do
      if (i <> aArg) and (aFnc.ArgVal[i, aRule1] <> aFnc.ArgVal[i, aRule2]) then
        exit false;
  end;

  method CheckCompare(aAtt: DexiAttribute; aComp: array of array of PrefCompare);
  begin
    Assert.IsTrue(DexiTabularFunction.CanCreateOn(aAtt));
    var lFnc := new DexiTabularFunction(aAtt);
    Assert.IsNotNil(lFnc);
    Assert.AreEqual(lFnc.Count, length(aComp));
    for i := 0 to lFnc.Count - 1 do
      for j := 0 to lFnc.Count - 1 do
        begin
          var lComp := lFnc.CompareRules(i, j);
          var lExp := aComp[i][j];
//        if lComp <> lExp then writeLn($"{i} {j}");
          Assert.AreEqual(lComp, lExp);
          for lArg := 0 to lFnc.ArgCount - 1 do
            begin
              lComp := lFnc.CompareArgValues(lArg, i, j);
              lExp := if DifferInArgOnly(lFnc, lArg, i, j) then aComp[i][j] else X;
//            if lComp <> lExp then writeLn($"{lArg}: {i} {j}");
              Assert.AreEqual(lComp, lExp);
            end;
        end;
   end;

begin
  var lAtt := Make3x3to3(o0, [oA, oA]);
  CheckCompare(lAtt, [
    {0} [Q, L, L, L, L, L, L, L, L],
    {1} [G, Q, L, X, L, L, X, L, L],
    {2} [G, G, Q, X, X, L, X, X, L],
    {3} [G, X, X, Q, L, L, L, L, L],
    {4} [G, G, X, G, Q, L, X, L, L],
    {5} [G, G, G, G, G, Q, X, X, L],
    {6} [G, X, X, G, X, X, Q, L, L],
    {7} [G, G, X, G, G, X, G, Q, L],
    {8} [G, G, G, G, G, G, G, G, Q],
    ]);

  lAtt := Make3x3to3(o0, [oD, oD]);
  CheckCompare(lAtt, [
    {0} [Q, G, G, G, G, G, G, G, G],
    {1} [L, Q, G, X, G, G, X, G, G],
    {2} [L, L, Q, X, X, G, X, X, G],
    {3} [L, X, X, Q, G, G, G, G, G],
    {4} [L, L, X, L, Q, G, X, G, G],
    {5} [L, L, L, L, L, Q, X, X, G],
    {6} [L, X, X, L, X, X, Q, G, G],
    {7} [L, L, X, L, L, X, L, Q, G],
    {8} [L, L, L, L, L, L, L, L, Q],
    ]);

  lAtt := Make3x3to3(o0, [oA, oD]);
  CheckCompare(lAtt, [
    {0} [Q, G, G, L, X, X, L, X, X],
    {1} [L, Q, G, L, L, X, L, L, X],
    {2} [L, L, Q, L, L, L, L, L, L],
    {3} [G, G, G, Q, G, G, L, X, X],
    {4} [X, G, G, L, Q, G, L, L, X],
    {5} [X, X, G, L, L, Q, L, L, L],
    {6} [G, G, G, G, G, G, Q, G, G],
    {7} [X, G, G, X, G, G, L, Q, G],
    {8} [X, X, G, X, X, G, L, L, Q],
    ]);

  lAtt := Make3x3to3(o0, [oA, o0]);
  CheckCompare(lAtt, [
    {0} [Q, X, X, L, X, X, L, X, X],
    {1} [X, Q, X, X, L, X, X, L, X],
    {2} [X, X, Q, X, X, L, X, X, L],
    {3} [G, X, X, Q, X, X, L, X, X],
    {4} [X, G, X, X, Q, X, X, L, X],
    {5} [X, X, G, X, X, Q, X, X, L],
    {6} [G, X, X, G, X, X, Q, X, X],
    {7} [X, G, X, X, G, X, X, Q, X],
    {8} [X, X, G, X, X, G, X, X, Q],
    ]);

  lAtt := Make3x3to3(o0, [o0, oD]);
  CheckCompare(lAtt, [
    {0} [Q, G, G, X, X, X, X, X, X],
    {1} [L, Q, G, X, X, X, X, X, X],
    {2} [L, L, Q, X, X, X, X, X, X],
    {3} [X, X, X, Q, G, G, X, X, X],
    {4} [X, X, X, L, Q, G, X, X, X],
    {5} [X, X, X, L, L, Q, X, X, X],
    {6} [X, X, X, X, X, X, Q, G, G],
    {7} [X, X, X, X, X, X, L, Q, G],
    {8} [X, X, X, X, X, X, L, L, Q],
    ]);

  lAtt := Make3x3to3(o0, [o0, o0]);
  CheckCompare(lAtt, [
    {0} [Q, X, X, X, X, X, X, X, X],
    {1} [X, Q, X, X, X, X, X, X, X],
    {2} [X, X, Q, X, X, X, X, X, X],
    {3} [X, X, X, Q, X, X, X, X, X],
    {4} [X, X, X, X, Q, X, X, X, X],
    {5} [X, X, X, X, X, Q, X, X, X],
    {6} [X, X, X, X, X, X, Q, X, X],
    {7} [X, X, X, X, X, X, X, Q, X],
    {8} [X, X, X, X, X, X, X, X, Q],
    ]);
end;

method DexiFunctionsTest.TestTabularCompareRuleValues;

  method CheckCompare(aFnc: DexiTabularFunction; aComp: array of array of PrefCompare);
  begin
    Assert.AreEqual(aFnc.Count, length(aComp));
    for i := 0 to aFnc.Count - 1 do
      for j := 0 to aFnc.Count - 1 do
        begin
          var lComp := aFnc.CompareRuleValues(i, j);
          var lExp := aComp[i][j];
//        if lComp <> lExp then writeLn($"{i} {j}");
          Assert.AreEqual(lComp, lExp);
        end;
//    readLn;
  end;

begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '1', '1', 'undef', '*', 'undef', '1', '0', '2']);
  CheckCompare(lFnc, [
    {0} [Q, L, L, X, L, X, L, Q, L],
    {1} [G, Q, Q, X, X, X, Q, G, L],
    {2} [G, Q, Q, X, X, X, Q, G, L],
    {3} [X, X, X, X, X, X, X, X, X],
    {4} [G, X, X, X, Q, X, X, G, L],
    {5} [X, X, X, X, X, X, X, X, X],
    {6} [G, Q, Q, X, X, X, Q, G, L],
    {7} [Q, L, L, X, L, X, L, Q, L],
    {8} [G, G, G, X, G, X, G, G, Q],
    ]);

  lAtt.Scale.Order := DexiOrder.Descending;
  CheckCompare(lFnc, [
    {0} [Q, G, G, X, G, X, G, Q, G],
    {1} [L, Q, Q, X, X, X, Q, L, G],
    {2} [L, Q, Q, X, X, X, Q, L, G],
    {3} [X, X, X, X, X, X, X, X, X],
    {4} [L, X, X, X, Q, X, X, L, G],
    {5} [X, X, X, X, X, X, X, X, X],
    {6} [L, Q, Q, X, X, X, Q, L, G],
    {7} [Q, G, G, X, G, X, G, Q, G],
    {8} [L, L, L, X, L, X, L, L, Q],
    ]);

  lAtt.Scale.Order := DexiOrder.None;
  CheckCompare(lFnc, [
    {0} [Q, X, X, X, X, X, X, Q, X],
    {1} [X, Q, Q, X, X, X, Q, X, X],
    {2} [X, Q, Q, X, X, X, Q, X, X],
    {3} [X, X, X, X, X, X, X, X, X],
    {4} [X, X, X, X, Q, X, X, X, X],
    {5} [X, X, X, X, X, X, X, X, X],
    {6} [X, Q, Q, X, X, X, Q, X, X],
    {7} [Q, X, X, X, X, X, X, Q, X],
    {8} [X, X, X, X, X, X, X, X, Q],
    ]);
end;

method DexiFunctionsTest.TestTabularConsistency;

  method CheckRuleConsistency(aFnc: DexiTabularFunction; aCons: array of array of Boolean);
  begin
    Assert.AreEqual(aFnc.Count, length(aCons));
    for i := 0 to aFnc.Count - 1 do
      for j := 0 to aFnc.Count - 1 do
        begin
          var lComp := aFnc.RuleIsConsistentWith(i, j);
          var lExp := aCons[i][j];
//        if lComp <> lExp then writeLn($"{i} {j}");
          Assert.AreEqual(lComp, lExp);
        end;
//    readLn;
  end;

  method CheckRuleInconsistency(aFnc: DexiTabularFunction; aCons: IntMatrix);
  begin
    Assert.AreEqual(aFnc.Count, length(aCons));
    for i := 0 to aFnc.Count - 1 do
      begin
        var lInconsist := aFnc.RuleInconsistentWith(i);
        var lExp := aCons[i];
//        if not Utils.IntArrayEq(lInconsist, lExp) then
//          writeLn($"{i}");
        Assert.IsTrue(Utils.IntArrayEq(lInconsist, lExp));
        Assert.AreEqual(aFnc.RuleIsConsistent(i), length(aCons[i]) = 0);
      end;
//    readLn;
  end;

begin
  const T = true;
  const F = false;
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '1', '1', 'undef', '*', 'undef', '1', '0', '2']);
  Assert.IsFalse(lFnc.IsConsistent);
  Assert.IsFalse(lFnc.IsActuallyMonotone);
  Assert.IsFalse(lFnc.IsSymmetric);
  Assert.AreEqual(lFnc.CountInconsistentRules, 4);
  CheckRuleConsistency(lFnc, [
    {0} [T, T, T, T, T, T, T, T, T],
    {1} [T, T, T, T, F, T, T, F, T],
    {2} [T, T, T, T, T, T, T, T, T],
    {3} [T, T, T, T, T, T, T, T, T],
    {4} [T, F, T, T, T, T, T, F, T],
    {5} [T, T, T, T, T, T, T, T, T],
    {6} [T, T, T, T, T, T, T, F, T],
    {7} [T, F, T, T, F, T, F, T, T],
    {8} [T, T, T, T, T, T, T, T, T],
    ]);

  CheckRuleInconsistency(lFnc, [
    {0} [],
    {1} [4, 7],
    {2} [],
    {3} [],
    {4} [1, 7],
    {5} [],
    {6} [7],
    {7} [1, 4, 6],
    {8} [],
    ]);
end;

method DexiFunctionsTest.TestTabularInsertArgValue;
begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '', '', '0', '1:2', '2', '1', '1', '']);
  Assert.AreEqual(lFnc.Count, 9);
  Assert.AreEqual(lFnc.EntCount, 6);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  lFnc.InsertArgValue(0, 0);
  CheckFunction(lFnc, ['0:2', '0:2', '0:2', '0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  lFnc.InsertArgValue(1, 1);
  CheckFunction(lFnc, ['0:2', '0:2', '0:2', '0:2', '0', '0:2', '0:2', '0:2', '0', '0:2', '1:2', '2', '1', '0:2', '1', '0:2']);
end;

method DexiFunctionsTest.TestTabularDeleteArgValue;
begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '', '', '0', '1:2', '2', '1', '1', '']);
  Assert.AreEqual(lFnc.Count, 9);
  Assert.AreEqual(lFnc.EntCount, 6);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  lFnc.DeleteArgValue(0, 0);
  CheckFunction(lFnc, ['0', '1:2', '2', '1', '1', '0:2']);

  lFnc.DeleteArgValue(1, 1);
  CheckFunction(lFnc, ['0', '2', '1', '0:2']);
end;

method DexiFunctionsTest.TestTabularExchangeArgs;
begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '', '', '0', '1:2', '2', '1', '1', '']);
  Assert.AreEqual(lFnc.Count, 9);
  Assert.AreEqual(lFnc.EntCount, 6);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  lFnc.ExchangeArgs(0, 1);
  CheckFunction(lFnc, ['0', '0', '1', '0:2', '1:2', '1', '0:2', '2', '0:2']);

  lFnc.ExchangeArgs(0, 1);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);
end;

method DexiFunctionsTest.TestTabularReverseAttr;
begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '', '', '0', '1:2', '2', '1', '1', '']);
  Assert.AreEqual(lFnc.Count, 9);
  Assert.AreEqual(lFnc.EntCount, 6);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  lFnc.ReverseAttr(0);
  CheckFunction(lFnc, ['1', '1', '0:2', '0', '1:2', '2', '0', '0:2', '0:2']);

  lFnc.ReverseAttr(0);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  lFnc.ReverseAttr(1);
  CheckFunction(lFnc, ['0:2', '0:2', '0', '2', '1:2', '0', '0:2', '1', '1']);

  lFnc.ReverseAttr(1);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);
end;

method DexiFunctionsTest.TestTabularInsertFncValue;
begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '', '0:2', '0', '1:2', '2', '1', '1', '']);
  Assert.AreEqual(lFnc.Count, 9);
  Assert.AreEqual(lFnc.EntCount, 7);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  DexiDiscreteScale(lAtt.Scale).InsertValue(0, 'L');
  lFnc.InsertFunctionValue(0);
  CheckFunction(lFnc, ['1', '0:3', '1:3', '1', '2:3', '3', '2', '2', '0:3']);

  DexiDiscreteScale(lAtt.Scale).InsertValue(2, 'M');
  lFnc.InsertFunctionValue(2);
  CheckFunction(lFnc, ['1', '0:4', '1:4', '1', '3:4', '4', '3', '3', '0:4']);
end;

method DexiFunctionsTest.TestTabularDeleteFncValue;
begin
  var lAtt := Make3x3to3(oA, [oA, oA]);
  var lFnc := Function3x3to3(lAtt, ['0', '', '0:2', '0', '1:2', '2', '1', '1', '']);
  Assert.AreEqual(lFnc.Count, 9);
  Assert.AreEqual(lFnc.EntCount, 7);
  CheckFunction(lFnc, ['0', '0:2', '0:2', '0', '1:2', '2', '1', '1', '0:2']);

  DexiDiscreteScale(lAtt.Scale).DeleteValue(0);
  lFnc.DeleteFunctionValue(0);
  CheckFunction(lFnc, ['0:1', '0:1', '0:1', '0:1', '0:1', '1', '0', '0', '0:1']);

  DexiDiscreteScale(lAtt.Scale).DeleteValue(1);
  lFnc.DeleteFunctionValue(1);
  CheckFunction(lFnc, ['0', '0', '0', '0', '0', '0', '0', '0', '0']);

  lAtt := Make3x3to3(oA, [oA, oA]);
  lFnc := Function3x3to3(lAtt, ['0', '', '0:2', '0', '1:2', '2', '1', '1', '']);
  DexiDiscreteScale(lAtt.Scale).DeleteValue(1);
  lFnc.DeleteFunctionValue(1);
  CheckFunction(lFnc, ['0', '0:1', '0:1', '0', '1', '1', '0:1', '0:1', '0:1']);

  lAtt := Make3x3to3(oA, [oA, oA]);
  lFnc := Function3x3to3(lAtt, ['0', '', '0:2', '0', '1:2', '2', '1', '1', '']);
  DexiDiscreteScale(lAtt.Scale).DeleteValue(2);
  lFnc.DeleteFunctionValue(2);
  CheckFunction(lFnc, ['0', '0:1', '0:1', '0', '1', '0:1', '1', '1', '0:1']);
end;

method DexiFunctionsTest.TestTabularRulesOld;
var Model: DexiModel;

  method CheckRules(aFnc: DexiTabularFunction; aClass: Integer; aExp: array of String);
  begin
    var lRules := new List<String>;
    aFnc.ComplexRules(aClass, lRules, Model.Settings);
//  writeln(String.Join("', '", lRules));
     Assert.AreEqual(lRules.Count, length(aExp));
    for i := 0 to lRules.Count - 1 do
      Assert.AreEqual(lRules[i], aExp[i]);
  end;

begin
  Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lPrice := Model.AttributeByName('PRICE');
  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  var lComfort := Model.AttributeByName('COMFORT');
  var fCar := lCar.Funct as DexiTabularFunction;
  var fPrice := lPrice.Funct as DexiTabularFunction;
  var fTechChar := lTechChar.Funct as DexiTabularFunction;
  var fComfort := lComfort.Funct as DexiTabularFunction;

  CheckRules(fCar, 0, ['0020', '0003']);
  CheckRules(fCar, 1, ['1111']);
  CheckRules(fCar, 2, ['1212', '2121']);
  CheckRules(fCar, 3, ['1323', '2223']);

  CheckRules(fPrice, 0, ['0020', '0002']);
  CheckRules(fPrice, 1, ['1111']);
  CheckRules(fPrice, 2, ['1222', '2122']);

  CheckRules(fTechChar, 0, ['0020', '0002']);
  CheckRules(fTechChar, 1, ['1111']);
  CheckRules(fTechChar, 2, ['1212', '2121']);
  CheckRules(fTechChar, 3, ['2222']);

  CheckRules(fComfort, 0, ['000230', '000202', '000032']);
  CheckRules(fComfort, 1, ['111211', '111131', '111112']);
  CheckRules(fComfort, 2, ['122232', '212232', '221232']);
end;

method DexiFunctionsTest.TestTabularRules;
var Model: DexiModel;

  method CheckRules(aFnc: DexiTabularFunction; aClass: Integer; aExp: array of String);
  begin
    var lRules := aFnc.ComplexRules(aClass, true);
    var lList := new List<String>;
    for i := 0 to lRules.Count - 1 do
      lList.Add(lRules[i].AsString.Replace(';','').Replace(':', ''));
     Assert.AreEqual(lRules.Count, length(aExp));
    for i := 0 to lRules.Count - 1 do
      Assert.AreEqual(lList[i], aExp[i]);
  end;

begin
  Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lPrice := Model.AttributeByName('PRICE');
  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  var lComfort := Model.AttributeByName('COMFORT');
  var fCar := lCar.Funct as DexiTabularFunction;
  var fPrice := lPrice.Funct as DexiTabularFunction;
  var fTechChar := lTechChar.Funct as DexiTabularFunction;
  var fComfort := lComfort.Funct as DexiTabularFunction;

  CheckRules(fCar, 0, ['0003', '0020']);
  CheckRules(fCar, 1, ['1111']);
  CheckRules(fCar, 2, ['1212', '2121']);
  CheckRules(fCar, 3, ['2223', '1323']);

  CheckRules(fPrice, 0, ['0002', '0020']);
  CheckRules(fPrice, 1, ['1111']);
  CheckRules(fPrice, 2, ['2122', '1222']);

  CheckRules(fTechChar, 0, ['0002', '0020']);
  CheckRules(fTechChar, 1, ['1111']);
  CheckRules(fTechChar, 2, ['1212', '2121']);
  CheckRules(fTechChar, 3, ['2222']);

  CheckRules(fComfort, 0, ['000032', '000202', '000230']);
  CheckRules(fComfort, 1, ['111112', '111131', '111211']);
  CheckRules(fComfort, 2, ['221232', '212232', '122232']);
end;

method DexiFunctionsTest.TestTabularClassProbabilities;

  method CheckProb(aProb, aExp: FltArray);
  begin
    Assert.IsTrue(Utils.FltArrayEq(aProb, aExp));
  end;

begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var fCar := lCar.Funct as DexiTabularFunction;

  CheckProb(fCar.ClassProb(true), Values.NormSum([6, 1, 2, 3], 1.0));
  CheckProb(fCar.ClassProb(false), Values.NormSum([6, 1, 2, 3], 1.0));
  // undefine rule 5 (acc)
  fCar.UndefineValue(5);
  CheckProb(fCar.ClassProb(true), Values.NormSum([6, 0, 2, 3], 1.0));
  CheckProb(fCar.ClassProb(false), Values.NormSum([6, 0, 2, 3], 1.0));
  // delete rule 11 (exc)
  fCar.RuleEntered[11] := false;
  CheckProb(fCar.ClassProb(true), Values.NormSum([6, 0, 2, 3], 1.0));
  CheckProb(fCar.ClassProb(false), Values.NormSum([6, 0, 2, 2], 1.0));
  // change rule 0 to unacc:acc
  fCar.RuleValLow[0] := 0;
  fCar.RuleValHigh[0] := 1;
  CheckProb(fCar.ClassProb(true), Values.NormSum([5.5, 0.5, 2, 3], 1.0));
  CheckProb(fCar.ClassProb(false), Values.NormSum([5.5, 0.5, 2, 2], 1.0));
  // change rule 11 (not entered) to *
  fCar.RuleValLow[11] := 0;
  fCar.RuleValHigh[11] := fCar.OutValCount - 1;
  CheckProb(fCar.ClassProb(true), Values.NormSum([5.75, 0.75, 2.25, 2.25], 1.0));
  CheckProb(fCar.ClassProb(false), Values.NormSum([5.5, 0.5, 2, 2], 1.0));
end;

method DexiFunctionsTest.TestTabularClassProbWhere;

  method CheckProb(aProb, aExp: FltArray);
  begin
    Assert.IsTrue(Utils.FltArrayEq(aProb, aExp));
  end;

begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var fCar := lCar.Funct as DexiTabularFunction;

  // PRICE=high
  CheckProb(fCar.ClassProbWhere(true, 0, 0), Values.NormSum([4, 0, 0, 0], 1.0));
  CheckProb(fCar.ClassProbWhere(false, 0, 0), Values.NormSum([4, 0, 0, 0], 1.0));

  // PRICE=medium
  CheckProb(fCar.ClassProbWhere(true, 0, 1), Values.NormSum([1, 1, 1, 1], 1.0));
  CheckProb(fCar.ClassProbWhere(false, 0, 1), Values.NormSum([1, 1, 1, 1], 1.0));

  // TECH.CHAR.=good
  CheckProb(fCar.ClassProbWhere(true, 1, 2), Values.NormSum([1, 0, 1, 1], 1.0));
  CheckProb(fCar.ClassProbWhere(false, 1, 2), Values.NormSum([1, 0, 1, 1], 1.0));
end;

method DexiFunctionsTest.TestTabularImpurity;
begin
  var Model := LoadModel('Car.dxi');
  var lComfort := Model.AttributeByName('COMFORT');
  var fComfort := lComfort.Funct as DexiTabularFunction;

  // expected weights have been calculated by DEXfunctions (R implementation)

  var lGiniGain := fComfort.GiniGain(true);
  var lGiniWeights := Values.NormSum(lGiniGain, 100.0);
  Assert.IsTrue(Utils.FltArrayEq(lGiniWeights, [37.15847, 25.68306, 37.15847], 0.00001));

  var lInfGain := fComfort.InformationGain(true);
  var lInfWeights := Values.NormSum(lInfGain, 100.0);
  Assert.IsTrue(Utils.FltArrayEq(lInfWeights, [36.63539, 26.72923, 36.63539], 0.00001));

  var lGainRatio := fComfort.GainRatio(true);
  var lRatioWeights := Values.NormSum(lGainRatio, 100.0);
  Assert.IsTrue(Utils.FltArrayEq(lRatioWeights, [38.78682, 22.42636, 38.78682], 0.00001));

  var lChiSquare := fComfort.ChiSquare(true);
  var lChiWeights := Values.NormSum(lChiSquare, 100.0);
  Assert.IsTrue(Utils.FltArrayEq(lChiWeights, [36.91950, 26.16099, 36.91950], 0.00001));
end;

method DexiFunctionsTest.TestDexiBound;
begin
  var lBound := new DexiBound(1.0, DexiBoundAssociation.Down);
  Assert.AreEqual(lBound.Bound, 1.0);
  Assert.AreEqual(lBound.Association, DexiBoundAssociation.Down);
  var lCopy := lBound.Copy;
  Assert.AreEqual(lCopy.Bound, 1.0);
  Assert.AreEqual(lCopy.Association, DexiBoundAssociation.Down);
end;

method DexiFunctionsTest.TestDexiValueCell;
begin
  var lCell := new DexiValueCell(5, true);
  Assert.IsNotNil(lCell);
  Assert.IsNotNil(lCell.Value);
  Assert.IsTrue(lCell.IsDefined);
  Assert.IsTrue(lCell.Value.IsInteger);
  Assert.IsTrue(lCell.Value.IsSingle);
  Assert.AreEqual(lCell.Value.AsInteger, 5);
  Assert.AreEqual(lCell.Entered, true);

  var lCell2 := lCell.Copy;
  Assert.IsNotNil(lCell2);
  Assert.IsNotNil(lCell2.Value);
  Assert.IsTrue(lCell2.IsDefined);
  Assert.IsTrue(lCell2.Value.IsInteger);
  Assert.IsTrue(lCell2.Value.IsSingle);
  Assert.AreEqual(lCell2.Value.AsInteger, 5);
  Assert.AreEqual(lCell2.Entered, true);

  lCell.Value := nil;
  Assert.IsFalse(lCell.IsDefined);
  Assert.IsTrue(lCell2.IsDefined);
end;

method DexiFunctionsTest.TestDiscretizeCreate;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  Assert.IsNotNil(lAtt);
  Assert.AreEqual(lAtt.InpCount, 1);

  Assert.IsFalse(DexiTabularFunction.CanCreateOn(lAtt));
  Assert.IsTrue(DexiDiscretizeFunction.CanCreateOn(lAtt));

  var lFnc := new DexiDiscretizeFunction(lAtt);
  Assert.IsNotNil(lFnc);
  Assert.AreEqual(lFnc.IntervalCount, 1);
  Assert.AreEqual(lFnc.BoundCount, 2);

  Assert.IsTrue(Consts.IsNegativeInfinity(lFnc.IntervalLowBound[0].Bound));
  Assert.AreEqual(lFnc.IntervalLowBound[0].Association, DexiBoundAssociation.Up);
  Assert.IsTrue(Consts.IsPositiveInfinity(lFnc.IntervalHighBound[0].Bound));
  Assert.AreEqual(lFnc.IntervalHighBound[0].Association, DexiBoundAssociation.Down);

  Assert.IsTrue(Values.IntSetEq(lFnc.IntervalValue[0].AsIntSet, lAtt.FullSet));
  Assert.AreEqual(lFnc.IntervalValLow[0], 0);
  Assert.AreEqual(lFnc.IntervalValHigh[0], lAtt.Scale.Count - 1);
  Assert.IsTrue(lFnc.IntervalDefined[0]);
end;

method DexiFunctionsTest.TestDiscretizeAssign;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  Assert.IsTrue(lFnc.CanAddBound(1.0));
  lFnc.AddBound(1.0);
  lFnc.SetIntervalVal(0, 0);
  lFnc.SetIntervalVal(1, 1);
  Assert.AreEqual(lFnc.IntervalCount, 2);
  Assert.AreEqual(lFnc.BoundCount, 3);

  var lFnc2 := new DexiDiscretizeFunction(lAtt);
  Assert.AreEqual(lFnc2.IntervalCount, 1);
  Assert.AreEqual(lFnc2.BoundCount, 2);

  Assert.IsTrue(lFnc2.CanAssignFunction(lFnc));
  Assert.IsTrue(lFnc.CanAssignFunction(lFnc2));

  lFnc2.AssignFunction(lFnc);
  Assert.AreEqual(lFnc2.IntervalCount, 2);
  Assert.AreEqual(lFnc2.BoundCount, 3);
  Assert.AreEqual(lFnc.IntervalLowBound[1].Bound, 1.0);
  Assert.AreEqual(lFnc2.IntervalLowBound[1].Bound, 1.0);
end;

method DexiFunctionsTest.TestDiscretizeMeasures;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  lFnc.UseConsist := false;
  lFnc.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc.AddBound(-1.0, DexiBoundAssociation.Up);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 0);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 0);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.IsTrue(lFnc.IsSymmetric);
  Assert.IsTrue(lFnc.IsActuallyMonotone);
  Assert.IsFalse(lFnc.ArgAffects(0));
  Assert.AreEqual(lFnc.ArgActualOrder(0), ActualScaleOrder.Constant);
  Assert.AreEqual(lFnc.Determined, 0.0);

  Assert.IsTrue(lFnc.InInterval(0, -2.0));
  Assert.IsTrue(lFnc.InInterval(0, -1.0 - Utils.FloatEpsilon));
  Assert.IsFalse(lFnc.InInterval(0, -1.0));

  Assert.IsFalse(lFnc.InInterval(1, -1.0 - Utils.FloatEpsilon));
  Assert.IsTrue(lFnc.InInterval(1, -1.0));
  Assert.IsTrue(lFnc.InInterval(1, 1.0));
  Assert.IsFalse(lFnc.InInterval(1, 1.0 + Utils.FloatEpsilon));
  Assert.IsTrue(lFnc.InInterval(1, -1.0));
  Assert.IsTrue(lFnc.InInterval(1, -1.0 + Utils.FloatEpsilon));

  lFnc.SetIntervalVal(1, 1);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 1);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 1);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.IsTrue(lFnc.IsSymmetric);
  Assert.IsFalse(lFnc.IsActuallyMonotone);
  Assert.IsTrue(lFnc.ArgAffects(0));
  Assert.AreEqual(lFnc.ArgActualOrder(0), ActualScaleOrder.None);
  Assert.AreEqual(lFnc.Determined, 1.0/3);

  lFnc.SetIntervalVal(0, 1);
  lFnc.SetIntervalVal(2, 2);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 3);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 3);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.IsTrue(lFnc.IsSymmetric);
  Assert.IsTrue(lFnc.IsActuallyMonotone);
  Assert.IsTrue(lFnc.ArgAffects(0));
  Assert.AreEqual(lFnc.ArgActualOrder(0), ActualScaleOrder.Ascending);
  Assert.AreEqual(lFnc.Determined, 1.0);
end;

method DexiFunctionsTest.TestDiscretizeConsistAsc;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  lFnc.UseConsist := false;
  lFnc.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc.AddBound(-1.0, DexiBoundAssociation.Up);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.Determined, 0.0);

  lFnc.UseConsist := true;
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.Determined, 0.0);

  lFnc.SetIntervalVal(1, 1);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 1);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 1);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.IntervalValue[0].ToString, "0:1");
  Assert.IsFalse(lFnc.IntervalEntered[0]);
  Assert.AreEqual(lFnc.IntervalValue[1].ToString, "1");
  Assert.IsTrue(lFnc.IntervalEntered[1]);
  Assert.AreEqual(lFnc.IntervalValue[2].ToString, "1:2");
  Assert.IsFalse(lFnc.IntervalEntered[2]);
  Assert.AreEqual(lFnc.Determined, 2.0/3);

  lFnc.UseConsist := false;
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 1);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 1);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.IntervalValue[0].ToString, "0;1;2");
  Assert.IsFalse(lFnc.IntervalEntered[0]);
  Assert.AreEqual(lFnc.IntervalValue[1].ToString, "1");
  Assert.IsTrue(lFnc.IntervalEntered[1]);
  Assert.AreEqual(lFnc.IntervalValue[2].ToString, "0;1;2");
  Assert.IsFalse(lFnc.IntervalEntered[2]);
  Assert.AreEqual(lFnc.Determined, 1.0/3);
end;

method DexiFunctionsTest.TestDiscretizeConsistDesc;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Descending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  lFnc.UseConsist := false;
  lFnc.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc.AddBound(-1.0, DexiBoundAssociation.Up);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.Determined, 0.0);

  lFnc.UseConsist := true;
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.Determined, 0.0);

  lFnc.SetIntervalVal(1, 1);
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 1);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 1);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.IntervalValue[0].ToString, "1:2");
  Assert.IsFalse(lFnc.IntervalEntered[0]);
  Assert.AreEqual(lFnc.IntervalValue[1].ToString, "1");
  Assert.IsTrue(lFnc.IntervalEntered[1]);
  Assert.AreEqual(lFnc.IntervalValue[2].ToString, "0:1");
  Assert.IsFalse(lFnc.IntervalEntered[2]);
  Assert.AreEqual(lFnc.Determined, 2.0/3);

  lFnc.UseConsist := false;
  Assert.AreEqual(lFnc.IntervalCount, 3);
  Assert.AreEqual(lFnc.BoundCount, 4);
  Assert.AreEqual(lFnc.EntCount, 1);
  Assert.AreEqual(lFnc.DefCount, 3);
  Assert.AreEqual(lFnc.EntDefCount, 1);
  Assert.IsTrue(lFnc.IsConsistent);
  Assert.AreEqual(lFnc.IntervalValue[0].ToString, "0;1;2");
  Assert.IsFalse(lFnc.IntervalEntered[0]);
  Assert.AreEqual(lFnc.IntervalValue[1].ToString, "1");
  Assert.IsTrue(lFnc.IntervalEntered[1]);
  Assert.AreEqual(lFnc.IntervalValue[2].ToString, "0;1;2");
  Assert.IsFalse(lFnc.IntervalEntered[2]);
  Assert.AreEqual(lFnc.Determined, 1.0/3);
end;

method DexiFunctionsTest.TestDiscretizeAddDelete;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  lFnc.UseConsist := true;

  CheckFunction(lFnc, ['*']);
  lFnc.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc.AddBound(-1.0, DexiBoundAssociation.Up);
  CheckFunction(lFnc, ['*', '*', '*']);

  lFnc.SetIntervalVal(0, 1);
  CheckFunction(lFnc, ['1', '1:2', '1:2']);

  lFnc.SetIntervalVal(2, 2);
  CheckFunction(lFnc, ['1', '1:2', '2']);

  lFnc.SetIntervalVal(1, 1);
  CheckFunction(lFnc, ['1', '1', '2']);

  Assert.IsFalse(lFnc.CanDeleteBound(0));
  Assert.IsTrue(lFnc.CanDeleteBound(1));
  Assert.IsTrue(lFnc.CanDeleteBound(2));
  Assert.IsFalse(lFnc.CanDeleteBound(3));
  lFnc.RemoveBound(2);
  CheckFunction(lFnc, ['1', '1:2']);
end;

method DexiFunctionsTest.TestDiscretizeChangeBound;
begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  lFnc.UseConsist := true;

  CheckFunction(lFnc, ['*']);
  CheckBounds(lFnc, []);
  lFnc.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc.AddBound(-1.0, DexiBoundAssociation.Up);
  CheckFunction(lFnc, ['*', '*', '*']);
  CheckBounds(lFnc, [-1.0, 1.0 ]);

  Assert.IsFalse(lFnc.CanChangeBound(0, -2.0));
  Assert.IsTrue(lFnc.CanChangeBound(1, -2.0));
  Assert.IsTrue(lFnc.CanChangeBound(2, -2.0));
  Assert.IsFalse(lFnc.CanChangeBound(2, -1.0));
  Assert.IsFalse(lFnc.CanChangeBound(3, -2.0));

  lFnc.ChangeBound(1, -2.0);
  lFnc.ChangeBound(2, 3.0);
  CheckBounds(lFnc, [-2.0, 3.0 ]);

  lFnc.SetIntervalVal(0, 0);
  lFnc.SetIntervalVal(1, 2);
  lFnc.SetIntervalVal(2, 2);
  CheckFunction(lFnc, ['0', '2', '2']);
  CheckBounds(lFnc, [-2.0, 3.0 ]);

  lFnc.ChangeBound(2, -3.0);
  CheckBounds(lFnc, [-3.0, -2.0]);
  CheckFunction(lFnc, ['0', '0:2', '2']);
end;

method DexiFunctionsTest.TestDiscretizeEvaluate;

  method CheckFunctValue(aFnc: DexiDiscretizeFunction; aArg: Float; aResult: Integer);
  begin
    var lValue := aFnc.FunctionValue(aArg);
    Assert.IsNotNil(lValue);
    Assert.IsTrue(lValue.HasIntSingle);
    Assert.AreEqual(lValue.AsInteger, aResult);
  end;

begin
  var lAtt := Make1x1Discr(DexiOrder.Ascending, DexiOrder.Ascending);
  var lFnc := new DexiDiscretizeFunction(lAtt);
  var eps := Utils.FloatEpsilon;
  lFnc.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc.AddBound(-1.0, DexiBoundAssociation.Up);
  lFnc.SetIntervalVal(0, 0);
  lFnc.SetIntervalVal(1, 1);
  lFnc.SetIntervalVal(2, 2);
  CheckBounds(lFnc, [-1.0, 1.0 ]);
  CheckFunction(lFnc, ['0', '1', '2']);

  CheckFunctValue(lFnc, Consts.NegativeInfinity, 0);
  CheckFunctValue(lFnc, -2.0, 0);
  CheckFunctValue(lFnc, -1.0 - eps, 0);
  CheckFunctValue(lFnc, -1.0, 1);
  CheckFunctValue(lFnc, 0.0, 1);
  CheckFunctValue(lFnc, 1.0, 1);
  CheckFunctValue(lFnc, 1.0 + eps, 2);
  CheckFunctValue(lFnc, 2.0, 2);
  CheckFunctValue(lFnc, Consts.PositiveInfinity, 2);

  var lExp := lFnc.IntervalValue[1];
  var lEval := lFnc.Evaluate([-1]);
  Assert.AreEqual(lEval, lExp);
  lEval := lFnc.Evaluate([0]);
  Assert.AreEqual(lEval, lExp);

  lExp := lFnc.IntervalValue[2];
  lEval := lFnc.Evaluate([3.0]);
  Assert.AreEqual(lEval, lExp);
end;

method DexiFunctionsTest.TestSelect;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lCarTab := lCar:Funct as DexiTabularFunction;
  Assert.IsNotNil(lCarTab);

  var lSel := lCarTab.SelectRules;
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]));

  lSel := lCarTab.SelectRules((r) -> (lCarTab.RuleDefined[r]));
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]));

  lSel := lCarTab.SelectRules((r) -> (not lCarTab.RuleDefined[r]));
  Assert.IsTrue(Utils.IntArrayEq(lSel, []));

  lCarTab.RuleEntered[3] := false;

  lSel := lCarTab.SelectRules(true, 0, 0);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 1, 2, 3]));

  lSel := lCarTab.SelectRules(false, 0, 0);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 1, 2]));

  lSel := lCarTab.SelectRules(true, 1, 1);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [1, 5, 9]));

  lSel := lCarTab.SelectRules(false, 1, 1);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [1, 5, 9]));

  lSel := lCarTab.SelectRules(true, 1, [0, 3]);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 3, 4, 7, 8, 11]));

  lSel := lCarTab.SelectRules(false, 1, [0, 3]);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 4, 7, 8, 11]));

  lSel := lCarTab.SelectRules(true, [], [], 3);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [7, 10, 11]));

  lSel := lCarTab.SelectRules(true, [0], [0], 3);
  Assert.IsTrue(Utils.IntArrayEq(lSel, []));

  lSel := lCarTab.SelectRules(true, [0], [2], 3);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [10, 11]));

  lSel := lCarTab.SelectRules(true, [0], [2], -1);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [8, 9, 10, 11]));

end;

method DexiFunctionsTest.TestSelectFrom;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lCarTab := lCar:Funct as DexiTabularFunction;
  Assert.IsNotNil(lCarTab);

  lCarTab.RuleEntered[3] := false;

  var lAll := lCarTab.SelectRules;
  Assert.IsTrue(Utils.IntArrayEq(lAll, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]));

  var lSel := lCarTab.SelectRulesFrom(lAll, (r) -> (lCarTab.RuleEntered[r]));
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11]));

  lSel := lCarTab.SelectRulesFrom(lAll, 1, [0, 3]);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 3, 4, 7, 8, 11]));

  lSel := lCarTab.SelectRulesFrom(lSel, 1, [0, 3]);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [0, 3, 4, 7, 8, 11]));

  lSel := lCarTab.SelectRulesFrom(lSel, 0, 1);
  Assert.IsTrue(Utils.IntArrayEq(lSel, [4, 7]));

end;

method DexiFunctionsTest.TestValuesEqual;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lCarTab := lCar:Funct as DexiTabularFunction;
  Assert.IsNotNil(lCarTab);

  lCarTab.RuleEntered[3] := false;

  var lAll := lCarTab.SelectRules;
  Assert.IsFalse(lCarTab.ValuesEqual(lAll));

  Assert.IsTrue(lCarTab.ValuesEqual(nil));
  Assert.IsTrue(lCarTab.ValuesEqual([]));
  Assert.IsTrue(lCarTab.ValuesEqual([0]));

  Assert.IsTrue(lCarTab.ValuesEqual([0, 1]));
  Assert.IsTrue(lCarTab.ValuesEqual([0, 1, 2, 3, 4]));
  Assert.IsTrue(lCarTab.ValuesEqual([0, 1, 2, 3, 4, 8]));
  Assert.IsTrue(lCarTab.ValuesEqual([10, 11]));

  Assert.IsFalse(lCarTab.ValuesEqual([0, 1, 2, 3, 4, 9]));
  Assert.IsFalse(lCarTab.ValuesEqual([5, 10, 11]));
end;

method DexiFunctionsTest.TestMarginals;
begin
  var Model := LoadModel('Car.dxi');
  var lComfort := Model.AttributeByName('COMFORT');
  Assert.IsNotNil(lComfort:Funct);
  var lFunct := lComfort.Funct as DexiTabularFunction;
  Assert.IsNotNil(lFunct);

  var lMarginals := lFunct.Marginals;
  Assert.AreEqual(length(lMarginals), lFunct.ArgCount);

  Assert.IsTrue(Utils.FltArrayEq(lMarginals[0], [0.0, 0.666667, 0.916667], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[1], [0.0, 0.555556, 0.777778, 0.777778], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[2], [0.0, 0.666667, 0.916667], 0.00001));

  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  Assert.IsNotNil(lTechChar);
  lFunct := lTechChar.Funct as DexiTabularFunction;
  Assert.IsNotNil(lFunct);

  lMarginals := lFunct.Marginals;
  Assert.AreEqual(length(lMarginals), lFunct.ArgCount);

  Assert.IsTrue(Utils.FltArrayEq(lMarginals[0], [0.0, 1.0, 1.666667], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[1], [0.0, 1.0, 1.666667], 0.00001));

end;

method DexiFunctionsTest.TestMarginalsNorm;
begin
  var Model := LoadModel('Car.dxi');
  var lComfort := Model.AttributeByName('COMFORT');
  Assert.IsNotNil(lComfort:Funct);
  var lFunct := lComfort.Funct as DexiTabularFunction;
  Assert.IsNotNil(lFunct);

  var lMarginals := lFunct.Marginals(true);
  Assert.AreEqual(length(lMarginals), lFunct.ArgCount);

  Assert.IsTrue(Utils.FltArrayEq(lMarginals[0], [0.0, 0.333333, 0.458333], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[1], [0.0, 0.277778, 0.388889, 0.388889], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[2], [0.0, 0.3333333, 0.458333], 0.00001));

  var lTechChar := Model.AttributeByName('TECH.CHAR.');
  Assert.IsNotNil(lTechChar);
  lFunct := lTechChar.Funct as DexiTabularFunction;
  Assert.IsNotNil(lFunct);

  lMarginals := lFunct.Marginals(true);
  Assert.AreEqual(length(lMarginals), lFunct.ArgCount);

  Assert.IsTrue(Utils.FltArrayEq(lMarginals[0], [0.0, 0.3333333, 0.5555556], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[1], [0.0, 0.3333333, 0.5555556], 0.00001));

  for r := 0 to lFunct.Count - 1 do
    lFunct.RuleVal[r] := 0;

  lMarginals := lFunct.Marginals(true);
  Assert.AreEqual(length(lMarginals), lFunct.ArgCount);

  Assert.IsTrue(Utils.FltArrayEq(lMarginals[0], [0.0, 0.0, 0.0], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[1], [0.0, 0.0, 0.0], 0.00001));

  for r := 0 to lFunct.Count - 1 do
    lFunct.RuleVal[r] := lFunct.OutValCount - 1;

  lMarginals := lFunct.Marginals(true);
  Assert.AreEqual(length(lMarginals), lFunct.ArgCount);

  Assert.IsTrue(Utils.FltArrayEq(lMarginals[0], [1.0, 1.0, 1.0], 0.00001));
  Assert.IsTrue(Utils.FltArrayEq(lMarginals[1], [1.0, 1.0, 1.0], 0.00001));


end;

end.
