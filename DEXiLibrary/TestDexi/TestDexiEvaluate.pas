namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

{$HIDE W28} // obsolete methods

type
  DexiEvaluateTest = public class(DexiLibraryTest)
  private
  protected
    method ValEqDistr(aVal: Integer; aValue: DexiValue): Boolean;
  public
    method TestCarEvaluation;
    method TestCarEvaluate;
    method TestCarEvaluateWithEvaluator;
    method TestEvaluateOneLevel;
    method TestCarPlusMinus;
    method TestEvaluateOneLevelWithDiscretization;
  end;

implementation

method DexiEvaluateTest.ValEqDistr(aVal: Integer; aValue: DexiValue): Boolean;
begin
  result := aValue.HasIntSingle and (aValue.AsInteger = aVal);
end;

method DexiEvaluateTest.TestCarEvaluation;
begin
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount,  1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  Assert.AreEqual(Model.Root.Inputs[0].Name, 'CAR');
  var aCar := Model.Root.Inputs[0];
  Assert.AreEqual(aCar.AltCount,  2);
  Assert.AreEqual(aCar.OptText[0], '3');
  Assert.AreEqual(aCar.OptText[1], '2');
  aCar.OptText[0] := 'X';
  aCar.OptText[1] := 'Y';
  Assert.AreEqual(aCar.OptText[0], '');
  Assert.AreEqual(aCar.OptText[1], '');
  Model.Evaluation;
  Assert.AreEqual(aCar.OptText[0], '3');
  Assert.AreEqual(aCar.OptText[1], '2');
end;

method DexiEvaluateTest.TestCarEvaluate;
begin
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount,  1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  Assert.AreEqual(Model.Root.Inputs[0].Name, 'CAR');
  var aCar := Model.Root.Inputs[0];
  Assert.AreEqual(aCar.AltCount,  2);
  Assert.AreEqual(aCar.OptText[0], '3');
  Assert.AreEqual(aCar.OptText[1], '2');
  aCar.OptText[0] := 'X';
  aCar.OptText[1] := 'Y';
  Assert.AreEqual(aCar.OptText[0], '');
  Assert.AreEqual(aCar.OptText[1], '');
  Model.Evaluate;
  Assert.AreEqual(aCar.OptText[0], '3');
  Assert.AreEqual(aCar.OptText[1], '2');
end;

method DexiEvaluateTest.TestCarEvaluateWithEvaluator;
begin
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 2);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  Assert.AreEqual(Model.Root.Inputs[0].Name,'CAR');
  var lInputs := new DexiAttributeList;
  var lOutputs := new DexiAttributeList;
  Model.Root.CollectBasicNonLinked(lInputs);
  Model.Root.CollectAggregate(lOutputs);
  var lInpVal1 := new Integer[lInputs.Count];
  var lInpVal2 := new Integer[lInputs.Count];
  for each lInp in lInputs index x do
    begin
      lInpVal1[x] := lInp.AltValue[0].AsInteger;
      lInpVal2[x] := lInp.AltValue[1].AsInteger;
    end;
  var lOutVal1 := new Integer[lOutputs.Count];
  var lOutVal2 := new Integer[lOutputs.Count];
  var lOutVals1 := new IntSet[lOutputs.Count];
  var lOutVals2 := new IntSet[lOutputs.Count];
  for each lOut in lOutputs index x do
    begin
      lOutVal1[x] := lOut.AltValue[0].AsInteger;
      lOutVal2[x] := lOut.AltValue[1].AsInteger;
      lOutVals1[x] := lOut.AltValue[0].AsIntSet;
      lOutVals2[x] := lOut.AltValues[1].AsIntSet;
      lOut.AltValue[0] := nil;
      lOut.AltValue[1] := nil;
    end;

  var Evaluator := new DexiEvaluator(Model);

  for each lType in [EvaluationType.Custom, EvaluationType.AsSet, EvaluationType.AsProb, EvaluationType.AsFuzzy, EvaluationType.AsFuzzyNorm] do
    begin
      Evaluator.EvalType := lType;
      Evaluator.Evaluate(Model);
      for each lInp in lInputs index x do
        Assert.IsTrue(ValEqDistr(lInpVal1[x], lInp.AltValue[0]));
      for each lOut in lOutputs index x do
        Assert.IsTrue(ValEqDistr(lOutVal1[x], lOut.AltValue[0]));
      for each lInp in lInputs index x do
        Assert.IsTrue(ValEqDistr(lInpVal2[x], lInp.AltValue[1]));
      for each lOut in lOutputs index x do
        Assert.IsTrue(ValEqDistr(lOutVal2[x], lOut.AltValue[1]));
    end;
end;

method DexiEvaluateTest.TestEvaluateOneLevel;
var
  Evaluator: DexiEvaluator;
  lOut, lInp1, lInp2: DexiAttribute;

  method TestNullInput;
  begin
    Evaluator.Expand := ValueExpand.Null;
    var Alternative := new DexiAlternative;
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNil(lOutValue);

    Evaluator.Expand := ValueExpand.All;
    Alternative := new DexiAlternative;
    Evaluator.Evaluate(Alternative);
    lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOut.IsFullSet(lOutValue.AsIntSet));
  end;

  method TestFullInput;
  begin
    Evaluator.Expand := ValueExpand.Null;
    var Alternative := new DexiAlternative;
    Alternative[lInp1] := lInp1.FullValue;
    Alternative[lInp2] := lInp2.FullValue;
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOut.IsFullSet(lOutValue.AsIntSet));

    Evaluator.Expand := ValueExpand.All;
    Alternative := new DexiAlternative;
    Alternative[lInp1] := lInp1.FullValue;
    Alternative[lInp2] := lInp2.FullValue;
    Evaluator.Evaluate(Alternative);
    lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOut.IsFullSet(lOutValue.AsIntSet));
  end;

  method TestUndefInput;
  begin
    Evaluator.Expand := ValueExpand.Null;
    var Alternative := new DexiAlternative;
    Alternative[lInp1] := new DexiUndefinedValue;
    Alternative[lInp2] := lInp2.FullValue;
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(not lOutValue.IsDefined);

    Evaluator.Expand := ValueExpand.All;
    Alternative := new DexiAlternative;
    Alternative[lInp1] := new DexiUndefinedValue;
    Alternative[lInp2] := lInp2.FullValue;
    Evaluator.Evaluate(Alternative);
    lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOut.IsFullSet(lOutValue.AsIntSet));
  end;

  method TestEmptyInput;
  begin
    Evaluator.Expand := ValueExpand.Null;
    var Alternative := new DexiAlternative;
    Alternative[lInp1] := new DexiIntSet;
    Alternative[lInp2] := lInp2.FullValue;
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOutValue is DexiIntSet);
    Assert.IsTrue(lOutValue.IsEmpty);

    Evaluator.Expand := ValueExpand.All;
    Alternative := new DexiAlternative;
    Alternative[lInp1] := new DexiIntSet;
    Alternative[lInp2] := lInp2.FullValue;
    Evaluator.Evaluate(Alternative);
    lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOut.IsFullSet(lOutValue.AsIntSet));
  end;

  method TestDistr(aD1, aD2: FltArray; aType: EvaluationType; aResult: FltArray);
  begin
    Evaluator.Expand := ValueExpand.Null;
    Evaluator.EvalType := aType;
    var Alternative := new DexiAlternative;
    Alternative[lInp1] := new DexiDistribution(Values.Distr(0, aD1));
    Alternative[lInp2] := new DexiDistribution(Values.Distr(0, aD2));
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    var lOutDistr := lOutValue.AsDistribution;
    var lResult := Utils.NewFltArray(length(aResult), 0.0);
    for i := low(aResult) to high(aResult) do
      lResult[i] := Values.GetDistribution(lOutDistr, i);
    Assert.IsTrue(Utils.FltArrayEq(lResult, aResult));
  end;

begin
  var Model := LoadModel('OneLevel.dxi');
  Evaluator := new DexiEvaluator(Model);
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  lOut := Model.Root.Inputs[0];
  Assert.IsNotNil(lOut);
  Assert.AreEqual(lOut.Name, 'OneLevel');
  Assert.AreEqual(lOut.InpCount, 2);
  lInp1 := lOut.Inputs[0];
  lInp2 := lOut.Inputs[1];
  Assert.IsNotNil(lInp1);
  Assert.IsNotNil(lInp2);

  TestNullInput;
  TestFullInput;
  TestUndefInput;
  TestEmptyInput;

  TestDistr([0.2, 0.5], [0.4, 0.8, 0.0], EvaluationType.AsSet, [1.0, 1.0, 1.0]);
  TestDistr([0.2, 0.5], [0.4, 0.8, 0.0], EvaluationType.AsProb, [(2*4)/(7.0*12), (2*8 + 5*4)/(7.0*12), (5*8)/(7.0*12)]);
  TestDistr([0.2, 0.5], [0.4, 0.8, 0.0], EvaluationType.AsFuzzy, [0.2, 0.4, 0.5]);
  TestDistr([0.2, 0.5], [0.4, 0.8, 0.0], EvaluationType.AsFuzzyNorm, [0.4, 0.5, 1.0]);
end;

method DexiEvaluateTest.TestCarPlusMinus;

  method AltVector(aAtt: DexiAttribute; aAlt: IDexiAlternative): IntArray;
  begin
    var lInputs := aAtt.CollectBasicNonLinked;
    result := Utils.NewIntArray(lInputs.Count);
    for i := 0 to lInputs.Count - 1 do
      begin
        var lValue := aAlt[lInputs[i]];
        result[i] :=
          if lValue = nil then -1
          else lValue.AsInteger;
      end;
  end;

begin
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  Assert.AreEqual(Model.Root.Inputs[0].Name,'CAR');
  var lFirst := Model.First;
  Assert.IsNotNil(lFirst);
  Assert.AreEqual(lFirst.Name,'CAR');
  Assert.AreEqual(Model.AltCount, 2);

  var Evaluator := new DexiEvaluator(Model);

  var lAlt := Model.Alternative[0];

  var lMinus1 := Evaluator.PlusMinus(lAlt, -1, lFirst);
  var lResult := AltVector(lFirst, lMinus1);
  Assert.IsTrue(Utils.IntArrayEq(lResult, [0, 3, 3, 3, 3, 3]));

  var lPlus1 := Evaluator.PlusMinus(lAlt, +1);
  lResult := AltVector(lFirst, lPlus1);
  Assert.IsTrue(Utils.IntArrayEq(lResult, [3, -1, -1, 3, -1, -1]));

  lAlt := Model.Alternative[1];

  lMinus1 := Evaluator.PlusMinus(lAlt, -1, lFirst);
  lResult := AltVector(lFirst, lMinus1);
  Assert.IsTrue(Utils.IntArrayEq(lResult, [0, 0, 2, 2, 2, 0]));

  lPlus1 := Evaluator.PlusMinus(lAlt, +1);
  lResult := AltVector(lFirst, lPlus1);
  Assert.IsTrue(Utils.IntArrayEq(lResult, [3, 3, -1, 2, -1, 3]));
end;

method DexiEvaluateTest.TestEvaluateOneLevelWithDiscretization;
var
  Model: DexiModel;
  Evaluator: DexiEvaluator;
  lOut, lInp1, lInp2, lN1, lN2: DexiAttribute;
  AltCount: Integer := 0;

  method TestNullInput;
  begin
    Evaluator.Expand := ValueExpand.Null;
    var Alternative := new DexiAlternative('Null/Null');
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNil(lOutValue);
    Model.AddAlternative(Alternative);

    Evaluator.Expand := ValueExpand.All;
    Alternative := new DexiAlternative('Null/All');
    Evaluator.Evaluate(Alternative);
    lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOut.IsFullSet(lOutValue.AsIntSet));
    Model.AddAlternative(Alternative);
  end;

  method TestInput(aN1, aN2: Float; aResult: Integer);
  begin
    Evaluator.Expand := ValueExpand.Null;
    inc(AltCount);
    var Alternative := new DexiAlternative($"Test{AltCount}");
    Alternative[lN1] := new DexiFltSingle(aN1);
    Alternative[lN2] := new DexiFltSingle(aN2);
    Evaluator.Evaluate(Alternative);
    var lOutValue := Alternative[lOut];
    Assert.IsNotNil(lOutValue);
    Assert.IsTrue(lOutValue.HasIntSingle);
    var lResult := lOutValue.AsInteger;
    Assert.AreEqual(lResult, aResult);
    Model.AddAlternative(Alternative);
  end;

begin
  Model := LoadModel('OneLevel.dxi');
  Evaluator := new DexiEvaluator(Model);
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  lOut := Model.Root.Inputs[0];
  Assert.IsNotNil(lOut);
  Assert.AreEqual(lOut.Name, 'OneLevel');
  Assert.AreEqual(lOut.InpCount, 2);
  lInp1 := lOut.Inputs[0];
  lInp2 := lOut.Inputs[1];
  Assert.IsNotNil(lInp1);
  Assert.IsNotNil(lInp2);
  lN1 := new DexiAttribute('N1');
  lN1.Scale := new DexiContinuousScale;
  lInp1.AddInput(lN1);
  lN2 := new DexiAttribute('N2');
  lN2.Scale := new DexiContinuousScale;
  lInp2.AddInput(lN2);

  var lFnc1 := new DexiDiscretizeFunction(lInp1);
  lFnc1.AddBound(0.0, DexiBoundAssociation.Down);
  lFnc1.SetIntervalVal(0, 0);
  lFnc1.SetIntervalVal(1, 1);

  var lFnc2 := new DexiDiscretizeFunction(lInp2);
  lFnc2.AddBound(1.0, DexiBoundAssociation.Down);
  lFnc2.AddBound(-1.0, DexiBoundAssociation.Up);
  lFnc2.SetIntervalVal(0, 0);
  lFnc2.SetIntervalVal(1, 1);
  lFnc2.SetIntervalVal(2, 2);

  lInp1.Funct := lFnc1;
  lInp2.Funct := lFnc2;

  Assert.IsTrue(Model.UsesDexiLibraryFeatures);

  TestNullInput;

  TestInput(-2.0, -2.0, 0);
  TestInput(-2.0, 0.0, 1);
  TestInput(-2.0, 2.0, 2);
  TestInput(2.0, -2.0, 1);
  TestInput(2.0, 0.0, 2);
  TestInput(2.0, 2.0, 2);
  TestInput(0.0, 0.0, 1);

// For preparing another test case
  Model.ForceLibraryFormat := false;
  Model.SaveToFile(TestOutput + 'OneLevelContinuousOld.dxi');
  Model.ForceLibraryFormat := true;
  Model.SaveToFile(TestOutput + 'OneLevelContinuousNew.dxi')
end;

end.
