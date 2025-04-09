namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

{$HIDE W28} // obsolete methods

type
  DexiDynamicTest = public class(DexiLibraryTest)
  private
  protected
    method DistrToFltArray(aDistr: Distribution; aCount: Integer): FltArray;
    method CheckTraceSequence(aTrace: DexiDynaTrace; aAtt: DexiAttribute; aValues: IntArray);
  public
    method TestDynaCreate;
    method TestDynaCarEvaluate;
    method TestDynaEvaluateLinked;
    method TestDynaEvaluate;
    method TestDynaEvaluateAcademic;
    method TestDynaEvaluateAcademicLags;
    method TestDynaEvaluateDistr;
    method TestDynaEvaluateAcademicDistr;
    method TestDynaSequence;
    method TestDynaCarEvaluateSequence;
  end;

implementation

method DexiDynamicTest.DistrToFltArray(aDistr: Distribution; aCount: Integer): FltArray;
begin
  result := Utils.NewFltArray(aCount);
  for i := low(result) to high(result) do
    result[i] := Values.GetDistribution(aDistr, i);
end;

method DexiDynamicTest.CheckTraceSequence(aTrace: DexiDynaTrace; aAtt: DexiAttribute; aValues: IntArray);
begin
  Assert.IsNotNil(aTrace);
  Assert.IsNotNil(aAtt);
  Assert.AreEqual(aTrace.AltCount, length(aValues));
  for i := 0 to aTrace.AltCount - 1 do
    begin
      var lAlt := aTrace.Alternative[i];
      var lValue := lAlt[aAtt];
      Assert.IsNotNil(lValue);
      Assert.IsTrue(lValue.HasIntSingle);
      Assert.AreEqual(lValue.AsInteger, aValues[i]);
    end;
end;


method DexiDynamicTest.TestDynaCreate;
begin
  var Model := LoadModel('Car.dxi');
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.IsNotNil(DynaEvaluator);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 0);
  Assert.AreEqual(DynaEvaluator.MaxLag, 0);

  Model := LoadModel('DynaTest.dxi');
  DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 9);
  DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.IsNotNil(DynaEvaluator);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 1);
  Assert.AreEqual(DynaEvaluator.MaxLag, 0);

  Model := LoadModel('Employee2.dxi');
  DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 7);
  DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.IsNotNil(DynaEvaluator);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 8);
  Assert.AreEqual(DynaEvaluator.MaxLag, 0);
end;

method DexiDynamicTest.TestDynaCarEvaluate;
begin
  var Model := LoadModel('Car.dxi');
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 0);
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative := Model.Alternative[lAlt];
      var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
      Assert.IsNotNil(lDynaEval);
      Assert.AreEqual(lDynaEval.AltCount, 1);
      Assert.AreEqual(lDynaEval.TraceEntry, 0);
    end;
end;

method DexiDynamicTest.TestDynaEvaluateLinked;
begin
  var Model := LoadModel('LinkedBoundsTest3.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 0);
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative := Model.Alternative[lAlt];
      var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
      Assert.IsNotNil(lDynaEval);
      Assert.AreEqual(lDynaEval.AltCount, 1);
      Assert.AreEqual(lDynaEval.TraceEntry, 0);
    end;
end;

method DexiDynamicTest.TestDynaEvaluate;
begin
  var Model := LoadModel('DynaTest.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 9);
  var lRoot := Model.First;
  Assert.IsNotNil(lRoot);
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 1);
  var CheckCount := [3, 2, 3, 3, 1, 3, 3, 2, 3];
  var CheckEntry := [0, 1, 0, 0, 0, 0, 0, 1, 0];
  var CheckProb: array of FltArray := [
    [1.0/3, 1.0/3, 1.0/3],
    [0.00, 1.00, 0.00],
    [1.0/3, 1.0/3, 1.0/3],
    [1.0/3, 1.0/3, 1.0/3],
    [0.00, 1.00, 0.00],
    [1.0/3, 1.0/3, 1.0/3],
    [1.0/3, 1.0/3, 1.0/3],
    [0.00, 1.00, 0.00],
    [1.0/3, 1.0/3, 1.0/3]
  ];
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative :=  Model.Alternative[lAlt];
      var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
      Assert.IsNotNil(lDynaEval);
      Assert.AreEqual(lDynaEval.AltCount, CheckCount[lAlt]);
      var lProb := DistrToFltArray(lDynaEval.ProbEvaluation[lRoot].AsDistribution, lRoot.Scale.Count);
      Assert.IsTrue(Utils.FltArrayEq(lProb, CheckProb[lAlt]));
      Assert.AreEqual(lDynaEval.TraceEntry, CheckEntry[lAlt]);
    end;
end;

method DexiDynamicTest.TestDynaEvaluateAcademic;
begin
  var Model := LoadModel('Employee2.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 7);
  var lRoot := Model.First;
  Assert.IsNotNil(lRoot);
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 8);
  var CheckCount := [1, 7, 2, 6, 5, 2, 5];
  var CheckEntry := [0, 6, 1, 5, 4, 1, 4];
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative :=  Model.Alternative[lAlt];
      var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
      Assert.IsNotNil(lDynaEval);
      Assert.AreEqual(lDynaEval.AltCount, CheckCount[lAlt]);
      Assert.AreEqual(lDynaEval.TraceEntry, CheckEntry[lAlt]);
//      var lProb := DistrToFltArray(lDynaEval.ProbEvaluation[lRoot].AsDistribution, lRoot.Scale.Count);
//      writeLn($'{lAlt + 1}. {Utils.FltArrayToStr(lProb)}');
    end;
end;

method DexiDynamicTest.TestDynaEvaluateAcademicLags;
begin
  var Model := LoadModel('Employee2Lags.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 7);
  var lRoot := Model.First;
  Assert.IsNotNil(lRoot);
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 8);
  var CheckCount := [4, 5, 4, 11, 7, 4, 7];
  var CheckEntry := [3, 4, 3, 10, 6, 3, 6];
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative :=  Model.Alternative[lAlt];
      var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
      Assert.IsNotNil(lDynaEval);
      Assert.AreEqual(lDynaEval.AltCount, CheckCount[lAlt]);
      Assert.AreEqual(lDynaEval.TraceEntry, CheckEntry[lAlt]);
//      var lProb := DistrToFltArray(lDynaEval.ProbEvaluation[lRoot].AsDistribution, lRoot.Scale.Count);
//      writeLn($'{lAlt + 1}. {Utils.FltArrayToStr(lProb)}');
    end;
end;

method DexiDynamicTest.TestDynaEvaluateDistr;
var
  Model: DexiModel;
  EvalRoot: DexiAttribute;
  DynaEvaluator: DexiDynaEvaluator;
  Attributes: DexiAttributeList;

  method CheckEval(lAlt: Integer; lInpDistr, lOutDistr: FltArray; aAltCount, aTraceCount: Integer);
  begin
    var lAlternative := Model.Alternative[lAlt].Copy;
    for each lAtt in Attributes do
      if lAtt.IsBasic then
        lAlternative[lAtt] := new DexiDistribution(0, lInpDistr);
    var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative, EvalRoot);
    Assert.IsNotNil(lDynaEval);
    Assert.AreEqual(lDynaEval.AltCount, aAltCount);
    Assert.AreEqual(lDynaEval.TraceCount, aTraceCount);
    var lProb := DistrToFltArray(lDynaEval.ProbEvaluation[EvalRoot].AsDistribution, EvalRoot.Scale.Count);
    Assert.IsTrue(Utils.FltArrayEq(lProb, lOutDistr, DynaEvaluator.Converge));
  end;

begin
  Model := LoadModel('DynaTest.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 9);
  EvalRoot := Model.First;
  Assert.IsNotNil(EvalRoot);
  Attributes := Model.Root.CollectInputs;
  Model.Evaluate;
  DynaEvaluator := new DexiDynaEvaluator(Model);
  DynaEvaluator.EvalType := EvaluationType.AsProb;
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 1);
  CheckEval(0, [0.0, 0.5, 0.5], [0.285736083984375, 0.5714111328125, 0.142852783203125], 14, 1);
  CheckEval(0, [0.5, 0.5, 0.0], [0.142852783203125, 0.5714111328125, 0.285736083984375], 14, 1);
  CheckEval(0, [0.5, 0.0, 0.5], [0.333343505859375, 0.33331298828125, 0.333343505859375], 14, 1);
  CheckEval(0, [1.0/3, 1.0/3, 1.0/3], [0.249995766228048, 0.500008467543904, 0.249995766228048], 9, 1);
end;

method DexiDynamicTest.TestDynaEvaluateAcademicDistr;
begin
  var Model := LoadModel('Employee2.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.AreEqual(Model.AltCount, 7);
  var EvalRoot := Model.First;
  Assert.IsNotNil(EvalRoot);
  var Attributes := Model.Root.CollectInputs;
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  DynaEvaluator.EvalType := EvaluationType.AsProb;
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 8);

  var lAlternative := new DexiAlternative('EmployeeTest1');
  for each lAtt in Attributes do
    if lAtt.IsBasic then
      begin
        var lDistr := Utils.NewFltArray(lAtt.Scale.Count, 0.5);
        lDistr[high(lDistr)] := 0.0;
        lAlternative[lAtt] := new DexiDistribution(0, lDistr);
      end;
  var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
  Assert.IsNotNil(lDynaEval);
//  writeLn(lDynaEval.AsString(Attributes));
  Assert.AreEqual(lDynaEval.AltCount, 22);
  Assert.AreEqual(lDynaEval.TraceCount, 1);
  var lProb := DistrToFltArray(lDynaEval.ProbEvaluation[EvalRoot].AsDistribution, EvalRoot.Scale.Count);
  Assert.IsTrue(lProb[0] > 0.999);

  lAlternative := new DexiAlternative('EmployeeTest2');
  for each lAtt in Attributes do
    if lAtt.IsBasic then
      begin
        var lDistr := Utils.NewFltArray(lAtt.Scale.Count, 0.5);
        lDistr[0] := 0.0;
        lAlternative[lAtt] := new DexiDistribution(0, lDistr);
      end;
  lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative);
  Assert.IsNotNil(lDynaEval);
//  writeLn(lDynaEval.AsString(Attributes));
  Assert.AreEqual(lDynaEval.AltCount, 8);
  Assert.AreEqual(lDynaEval.TraceCount, 1);
  lProb := DistrToFltArray(lDynaEval.ProbEvaluation[EvalRoot].AsDistribution, EvalRoot.Scale.Count);
  Assert.IsTrue(lProb[4] > 0.999);
end;

method  DexiDynamicTest.TestDynaSequence;
begin
  var lSeq := new DexiValueSequence(IntArray(nil));

  Assert.AreEqual(lSeq.Value[0], nil);
  Assert.AreEqual(lSeq.Value[1], nil);

  lSeq := new DexiValueSequence([1, 2, 3]);
  for b in [BeyondSequence.Cycle, BeyondSequence.Stay, BeyondSequence.Undefined, BeyondSequence.NilValue] do
    begin
      lSeq.Beyond := b;
      for i := 0 to 5 do
        begin
          var lValue := lSeq.Value[i];
          if i < 3 then
            begin
              Assert.IsTrue(DexiValue.ValueIsDefined(lValue));
              Assert.IsTrue(DexiValue.ValueIsInteger(lValue));
              Assert.AreEqual(lValue.AsInteger, i + 1);
            end
          else
            case b of
              BeyondSequence.Stay:
                begin
                  Assert.IsTrue(DexiValue.ValueIsDefined(lValue));
                  Assert.IsTrue(DexiValue.ValueIsInteger(lValue));
                  Assert.AreEqual(lValue.AsInteger, 3);
                end;
              BeyondSequence.Cycle:
                begin
                  Assert.IsTrue(DexiValue.ValueIsDefined(lValue));
                  Assert.IsTrue(DexiValue.ValueIsInteger(lValue));
                  Assert.AreEqual(lValue.AsInteger, i - 2);
                end;
              BeyondSequence.Undefined:
                begin
                  Assert.IsNotNil(lValue);
                  Assert.IsTrue(DexiValue.ValueIsUndefined(lValue));
                end;
              BeyondSequence.NilValue:
                begin
                  Assert.IsNil(lValue);
                end;
            end;
        end;
    end;
end;

method DexiDynamicTest.TestDynaCarEvaluateSequence;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  Assert.IsNotNil(lCar);
  var lSafety := Model.AttributeByName('SAFETY');
  Assert.IsNotNil(lSafety);
  var lSequences := new DexiValueSequences;
  lSequences.AddSequence(lSafety, new DexiValueSequence([0, 1, 2]));
  Model.Evaluate;
  var DynaEvaluator := new DexiDynaEvaluator(Model);
  Assert.AreEqual(DynaEvaluator.DynaLinkCount, 0);

  var lAlt := 0;
  var lAlternative := Model.Alternative[lAlt];
  var lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative, lSequences);
  Assert.IsNotNil(lDynaEval);
  Assert.AreEqual(lDynaEval.AltCount, 4);
  Assert.AreEqual(lDynaEval.TraceEntry, 3);
  CheckTraceSequence(lDynaEval, lSafety, [0, 1, 2, 2]);
  CheckTraceSequence(lDynaEval, lCar, [0, 3, 3, 3]);

  lAlt := 1;
  lAlternative := Model.Alternative[lAlt];
  lDynaEval := DynaEvaluator.DynaEvaluate(lAlternative, lSequences);
  Assert.IsNotNil(lDynaEval);
  Assert.AreEqual(lDynaEval.AltCount, 4);
  Assert.AreEqual(lDynaEval.TraceEntry, 3);
  CheckTraceSequence(lDynaEval, lSafety, [0, 1, 2, 2]);
  CheckTraceSequence(lDynaEval, lCar, [0, 2, 3, 3]);

end;


end.
