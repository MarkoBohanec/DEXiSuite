namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiQQ2Test = public class(DexiLibraryTest)
  private
    const NaN = Consts.NaN;
  protected
    method WritePathGraph(aGraph: PathGraph; aMatrix: PathGraphMatrix := nil);
    method WritePathGraph(aGraph: PathGraph; aMatrix: IntMatrix);
    method CheckValues(aQQ2: DexiQQ2Model);
    method CheckGaps(aQQ2: DexiQQ2Model);
    method CheckFunctionValues(aQQ2: DexiQQ2Model);
  public
    method TestPathGraph;
    method TestWorkApp;
    method TestWorkAppPartitioned;
    method TestEvaluateCar;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiQQ2Test.WritePathGraph(aGraph: PathGraph; aMatrix: PathGraphMatrix := nil);
begin
  writeLn(PathGraph.PathGraphToString(aGraph, aMatrix));
  readLn;
end;

method DexiQQ2Test.CheckValues(aQQ2: DexiQQ2Model);
begin
  Assert.AreEqual(aQQ2.Funct.Count, aQQ2.Graph.Count);
  for i := 0 to aQQ2.Funct.Count - 1 do
    for c := 0 to aQQ2.ClassCount - 1 do
      begin
        var lVal := aQQ2.QP[c][i];
        Assert.IsTrue(Consts.IsNaN(lVal) or (-0.5 - Utils.FloatEpsilon <= lVal <= 0.5 + Utils.FloatEpsilon));
      end;
end;

method DexiQQ2Test.CheckGaps(aQQ2: DexiQQ2Model);
begin
  var lMins := Utils.NewFltArray(aQQ2.ClassCount, Consts.MaxDouble);
  var lMaxs := Utils.NewFltArray(aQQ2.ClassCount, Consts.MinDouble);
  for i := 0 to aQQ2.Funct.Count - 1 do
    for c := 0 to aQQ2.ClassCount - 1 do
      begin
        var lVal := aQQ2.QP[c][i];
        var lGap := aQQ2.Gaps[c][i];
        Assert.IsTrue(Consts.IsNaN(lVal) = Consts.IsNaN(lGap));
        if Consts.IsNaN(lGap) then
          continue;
        lMins[c] := Math.Min(lMins[c], lVal - lGap);
        lMaxs[c] := Math.Max(lMins[c], lVal + lGap);
      end;
  for c := 0 to aQQ2.ClassCount - 1 do
    begin
      Assert.IsTrue((lMins[c] = Consts.MaxDouble) or (Utils.FloatEq(lMins[c], -0.5)));
      Assert.IsTrue((lMaxs[c] = Consts.MinDouble) or (Utils.FloatEq(lMaxs[c], +0.5)));
    end;
end;

method DexiQQ2Test.CheckFunctionValues(aQQ2: DexiQQ2Model);
begin
  var lMins := Utils.NewFltArray(aQQ2.ClassCount, Consts.MaxDouble);
  var lMaxs := Utils.NewFltArray(aQQ2.ClassCount, Consts.MinDouble);
  var lDown := Utils.NewFltArray(aQQ2.ArgCount, -0.5);
  var lUp := Utils.NewFltArray(aQQ2.ArgCount, +0.5);
  var lDown2 := Utils.NewFltArray(aQQ2.ArgCount, -0.25);
  var lUp2 := Utils.NewFltArray(aQQ2.ArgCount, +0.25);
  for r := 0 to aQQ2.Funct.Count - 1 do
    if aQQ2.Funct.RuleDefined[r] then
      begin
        var lArgVals := aQQ2.Funct.ArgValues[r];
        for c := aQQ2.Funct.RuleValLow[r] to aQQ2.Funct.RuleValHigh[r] do
          begin
            var lFValue := aQQ2.Evaluate(lArgVals, c);
            Assert.IsNotNaN(lFValue);
            Assert.IsTrue(Utils.FloatEq(lFValue, c + aQQ2.QP[c][r]));
            var lDownValue := aQQ2.Evaluate(lArgVals, lDown, c);
            Assert.IsNotNaN(lDownValue);
            Assert.IsTrue((c - 0.5) - Utils.FloatEpsilon <= lDownValue <= (c + 0.5) + Utils.FloatEpsilon);
            lMins[c] := Math.Min(lMins[c], lDownValue - c);
            var lUpValue := aQQ2.Evaluate(lArgVals, lUp, c);
            Assert.IsNotNaN(lUpValue);
            Assert.IsTrue((c - 0.5) - Utils.FloatEpsilon <= lUpValue <= (c + 0.5) + Utils.FloatEpsilon);
            lMaxs[c] := Math.Max(lMaxs[c], lUpValue - c);
            var lDownValue2 := aQQ2.Evaluate(lArgVals, lDown2, c);
            Assert.IsNotNaN(lDownValue2);
            Assert.IsTrue(Utils.FloatEq(lDownValue2, (lFValue + lDownValue)/2.0));
            var lUpValue2 := aQQ2.Evaluate(lArgVals, lUp2, c);
            Assert.IsNotNaN(lUpValue2);
            Assert.IsTrue(Utils.FloatEq(lUpValue2, (lFValue + lUpValue)/2.0));
          end;
      end;
  for i := low(lMins) to high(lMins) do
    begin
      Assert.IsTrue((lMins[i] = Consts.MaxDouble) or Utils.FloatEq(lMins[i], -0.5));
      Assert.IsTrue((lMaxs[i] = Consts.MinDouble) or Utils.FloatEq(lMaxs[i], +0.5));
    end;
end;

method DexiQQ2Test.WritePathGraph(aGraph: PathGraph; aMatrix: IntMatrix);
begin
  writeLn(PathGraph.PathMatrixToString(aGraph, aMatrix));
  readLn;
end;

method Utils.GraphRowEq(aArr1, aArr2: PathGraphRow): Boolean;
begin
  result := false;
  if length(aArr1) <> length(aArr2) then
    exit;
  for i := low(aArr1) to high(aArr1) do
    if aArr1[i] <> aArr2[i] then
      exit;
  result := true;
end;

method DexiQQ2Test.TestPathGraph;
begin
  var Model := LoadModel('WorkApp.dxi');
  var lWorkApp := Model.AttributeByName('WORK_APP');
  var fWorkApp := lWorkApp.Funct as DexiTabularFunction;
  var lGraph := new PathGraph(fWorkApp);
  Assert.AreEqual(lGraph.Count, fWorkApp.Count);
  var lExpect := new PathGraph(lGraph.Count);
  lExpect.row[ 0] := PathGraphRow([ 0,  1,  1,  1,  2,  2,  1,  2,  2,  1,  2,  2]);
  lExpect.row[ 1] := PathGraphRow([-1,  0,  1,nil,  1,  2,nil,  1,  2,nil,  1,  2]);
  lExpect.row[ 2] := PathGraphRow([-1, -1,  0,nil,nil,  1,nil,nil,  1,nil,nil,  1]);
  lExpect.row[ 3] := PathGraphRow([-1,nil,nil,  0,  1,  1,  1,  2,  2,  1,  2,  2]);
  lExpect.row[ 4] := PathGraphRow([-2, -1,nil, -1,  0,  1,nil,  1,  2,nil,  1,  2]);
  lExpect.row[ 5] := PathGraphRow([-2, -2, -1, -1, -1,  0,nil,nil,  1,nil,nil,  1]);
  lExpect.row[ 6] := PathGraphRow([-1,nil,nil, -1,nil,nil,  0,  1,  1,  1,  2,  2]);
  lExpect.row[ 7] := PathGraphRow([-2, -1,nil, -2, -1,nil, -1,  0,  1,nil,  1,  2]);
  lExpect.row[ 8] := PathGraphRow([-2, -2, -1, -2, -2, -1, -1, -1,  0,nil,nil,  1]);
  lExpect.row[ 9] := PathGraphRow([-1,nil,nil, -1,nil,nil, -1,nil,nil,  0,  1,  1]);
  lExpect.row[10] := PathGraphRow([-2, -1,nil, -2, -1,nil, -2, -1,nil, -1,  0,  1]);
  lExpect.row[11] := PathGraphRow([-2, -2, -1, -2, -2, -1, -2, -2, -1, -1, -1,  0]);
  Assert.AreEqual(lExpect.Count, fWorkApp.Count);
  for i := 0 to lExpect.Count - 1 do
    Assert.IsTrue(GraphRowEq(lGraph.Row[i], lExpect.Row[i]));

  var lExtended := new ExtendedPathGraph(lGraph, 1);
  Assert.AreEqual(lExtended.Count, lGraph.Count + 2);

  var lUpReduction := lGraph.TransitiveReduction(true);
  var lUpTrans := Utils.NewIntMatrix(length(lUpReduction), length(lUpReduction));

  lUpTrans[ 0] := [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0];
  lUpTrans[ 1] := [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0];
  lUpTrans[ 2] := [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0];
  lUpTrans[ 3] := [0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0];
  lUpTrans[ 4] := [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0];
  lUpTrans[ 5] := [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
  lUpTrans[ 6] := [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0];
  lUpTrans[ 7] := [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0];
  lUpTrans[ 8] := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
  lUpTrans[ 9] := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0];
  lUpTrans[10] := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
  lUpTrans[11] := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  for i := 0 to lUpTrans.Count - 1 do
    Assert.IsTrue(Utils.IntArrayEq(lUpReduction[i], lUpTrans[i]));

  var lDownReduction := lGraph.TransitiveReduction(false);
  var lDownTrans := Utils.NewIntMatrix(length(lDownReduction), length(lDownReduction));

  lDownTrans[ 0] := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 1] := [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 2] := [0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 3] := [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 4] := [0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 5] := [0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 6] := [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0];
  lDownTrans[ 7] := [0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0];
  lDownTrans[ 8] := [0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0];
  lDownTrans[ 9] := [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0];
  lDownTrans[10] := [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0];
  lDownTrans[11] := [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0];
  for i := 0 to lDownTrans.Count - 1 do
    Assert.IsTrue(Utils.IntArrayEq(lDownReduction[i], lDownTrans[i]));

  for i := 0 to lGraph.Count - 1 do
    for j := 0 to lGraph.Count - 1 do
      begin
        var lNeighbor := (lUpTrans[i][j] + lDownTrans[i][j]) > 0;
        Assert.AreEqual(PathGraph.Neighbor(lUpTrans, i, j), lNeighbor);
        Assert.AreEqual(PathGraph.Neighbor(lDownTrans, i, j), lNeighbor);
      end;
end;

method FltArrayString(aArr: FltArray; aLen: Integer := 5; aDec: Integer := 2): String;
begin
  var sb := new StringBuilder;
  for i := low(aArr) to high(aArr) do
    begin
      if i > 0 then
        sb.Append(' ');
      sb.Append(Utils.PadRight(Utils.FltToStr(aArr[i], aDec), aLen));
    end;
  result := sb.ToString;
end;

method DexiQQ2Test.TestWorkApp;
begin
  var Model := LoadModel('WorkApp.dxi');
  var lWorkApp := Model.AttributeByName('WORK_APP');
  var fWorkApp := lWorkApp.Funct as DexiTabularFunction;
  var lQP := new DexiQQ2Model(fWorkApp);

  Assert.IsTrue(Utils.IntArrayEq(lQP.Unordered, []));
  Assert.IsTrue(Utils.IntArrayEq(lQP.OrderedMask, [1, 1]));
  CheckValues(lQP);
  CheckGaps(lQP);

//  for i := 0 to high(lQP.QP) do
//    writeLn($"QP[{i}]:  {FltArrayString(lQP.QP[i], 0, 4)}");
//
//  for i := 0 to high(lQP.Gaps) do
//    writeLn($"Gaps[{i}]:{FltArrayString(lQP.Gaps[i], 7, 4)}");

  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.QP[0], [-0.3000, 0.0000, 0.3000, -0.1000, NaN, NaN, 0.1000, NaN, NaN, 0.3000, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.QP[1], [NaN, NaN, NaN, NaN, -0.1667, 0.1667, NaN, 0.1667, NaN, NaN, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.QP[2], [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, -0.1667, NaN, -0.1667, 0.1667], 0.0005));
 
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.Gaps[0], [0.2000, 0.3000, 0.2000, 0.2000, NaN, NaN, 0.2000, NaN, NaN, 0.2000, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.Gaps[1], [NaN, NaN, NaN, NaN, 0.3333, 0.3333, NaN, 0.3333, NaN, NaN, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.Gaps[2], [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.3333, NaN, 0.3333, 0.3333], 0.0005));

  CheckFunctionValues(lQP);
 
end;

method DexiQQ2Test.TestWorkAppPartitioned;
begin
  var Model := LoadModel('WorkApp.dxi');
  var lWorkApp := Model.AttributeByName('WORK_APP');
  var fWorkApp := lWorkApp.Funct as DexiTabularFunction;
  lWorkApp.Inputs[1].Scale.Order := DexiOrder.None;
  var lQP := new DexiQQ2Model(fWorkApp);

  Assert.IsTrue(Utils.IntArrayEq(lQP.Unordered, [1]));
  Assert.IsTrue(Utils.IntArrayEq(lQP.OrderedMask, [1, 0]));
  CheckValues(lQP);
  CheckGaps(lQP);

//  for i := 0 to high(lQP.QP) do
//    writeLn($"QP[{i}]:  {FltArrayString(lQP.QP[i], 0, 4)}");
// 
//  for i := 0 to high(lQP.Gaps) do
//    writeLn($"Gaps[{i}]:{FltArrayString(lQP.Gaps[i], 7, 4)}");
 
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.QP[0], [-0.3750, 0.0000, 0.0000, -0.1250, NaN, NaN, 0.1250, NaN, NaN, 0.3750, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.QP[1], [NaN, NaN, NaN, NaN, -0.2500, 0.0000, NaN, 0.2500, NaN, NaN, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.QP[2], [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, -0.2500, NaN, 0.0000, 0.2500], 0.0005));

  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.Gaps[0], [0.1250, 0.5000, 0.5000, 0.1250, NaN, NaN, 0.1250, NaN, NaN, 0.1250, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.Gaps[1], [NaN, NaN, NaN, NaN, 0.2500, 0.5000, NaN, 0.2500, NaN, NaN, NaN, NaN], 0.0005));
  Assert.IsTrue(Utils.FltArrayEqWithNaN(lQP.Gaps[2], [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 0.2500, NaN, 0.5000, 0.2500], 0.0005));

  CheckFunctionValues(lQP);

end;

method DexiQQ2Test.TestEvaluateCar;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lEvaluator := new DexiQQ2Evaluator(Model);
  var lClasses := [3,                  2];
  var lOffsets := [1.0/9, -0];
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
