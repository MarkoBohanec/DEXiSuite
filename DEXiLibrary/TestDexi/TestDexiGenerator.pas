namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiGeneratorTest = public class(DexiLibraryTest)
  private
  protected
    method AltToStr(aGenerator: DexiGenerator; aAlt: IDexiAlternative): String;
  public
    method TestCarGenerate;
    method TestLinkedGenerate;
    method TestCarOne;
    method TestCarGenerateSequence;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiGeneratorTest.AltToStr(aGenerator: DexiGenerator; aAlt: IDexiAlternative): String;
begin
  var sb := new StringBuilder;
  for each lAtt in aGenerator.Attributes index x do
    begin
      if x > 0 then sb.Append(';');
      sb.Append(Utils.IntArrayToStr(aAlt[lAtt].AsIntSet));
    end;
  exit sb.ToString;
end;

method DexiGeneratorTest.TestCarGenerate;
begin
  var lOut := new List<String>;
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount,1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  var lCar := Model.Root.Inputs[0];
  var Generator := new DexiGenerator(lCar);
  lOut.Add(Generator.StructureToString);
  lOut.Add(Generator.SequenceToString);
  Model.Evaluate;
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative := Model.Alternative[lAlt].Copy;
      Generator.SetAlternative(lAlternative);
      for u := 0 to 1 do
       for lSteps := 0 to 2 do
        begin
          Generator.Unidirectional := u > 0;
          Generator.MaxSteps := lSteps;
          lOut.Add('');
          lOut.Add($'Alternative {lAlt + 1}, Unidirectional {Utils.BooleanToStr(Generator.Unidirectional)}, MaxSteps {lSteps}');
          var lImprove := Generator.Improve(0);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add('');
          lOut.Add($'Improved {Generator.CurrentDistanceInDir}, {Generator.CurrentDistanceOpDir}');
          if lImprove <> nil then
            for x := 0 to lImprove.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lImprove[x])}');
          var lDegrade := Generator.Degrade(0);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add($'Degraded  {Generator.CurrentDistanceInDir}, {Generator.CurrentDistanceOpDir}');
          if lDegrade <> nil then
            for x := 0 to lDegrade.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lDegrade[x])}');
        end;
    end;
  File.WriteLines(TestOutput + '_TestCarGenerate.txt', lOut);
  CheckFilesEqual(TestOutput + '_TestCarGenerate.txt', TestOutput + '!TestCarGenerate.txt');
end;

method DexiGeneratorTest.TestLinkedGenerate;
begin
  var lOut := new List<String>;
  var Model := LoadModel('LinkedBoundsTest3.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  var lRoot := Model.Root.Inputs[0];
  var Generator := new DexiGenerator(lRoot);
  lOut.Add(Generator.StructureToString);
  lOut.Add(Generator.SequenceToString);
  Model.Evaluate;
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative := Model.Alternative[lAlt].Copy;
      Generator.SetAlternative(lAlternative);
      for u := 0 to 1 do
        begin
          Generator.Unidirectional := u > 0;
          lOut.Add('');
          lOut.Add($'Alternative {lAlt + 1}, Unidirectional {Utils.BooleanToStr(Generator.Unidirectional)}');
          var lImprove := Generator.Improve(0);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add('');
          lOut.Add($'Improved {Generator.CurrentDistanceInDir}, {Generator.CurrentDistanceOpDir}');
          if lImprove <> nil then
            for x := 0 to lImprove.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lImprove[x])}');
          var lDegrade := Generator.Degrade(0);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add($'Degraded  {Generator.CurrentDistanceInDir}, {Generator.CurrentDistanceOpDir}');
          if lDegrade <> nil then
            for x := 0 to lDegrade.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lDegrade[x])}');
        end;
    end;
  File.WriteLines(TestOutput + '_TestLinkedGenerate.txt', lOut);
  CheckFilesEqual(TestOutput + '_TestLinkedGenerate.txt', TestOutput + '!TestLinkedGenerate.txt');
end;

method DexiGeneratorTest.TestCarOne;
begin
  var lOut := new List<String>;
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount,1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  var lCar := Model.First;
  var Generator := new DexiGenerator(lCar);
  Model.Evaluate;
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative := Model.Alternative[lAlt].Copy;
      Generator.SetAlternative(lAlternative);
      for lSteps := 1 to 2 do
        begin
          lOut.Add('');
          lOut.Add($'Alternative {lAlt + 1}, Steps {lSteps}');
          var lImprove := Generator.ImproveOne(0, lSteps);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add('');
          lOut.Add($'Improved');
          if lImprove <> nil then
            for x := 0 to lImprove.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lImprove[x])}');
          var lDegrade := Generator.DegradeOne(0, lSteps);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add($'Degraded');
          if lDegrade <> nil then
            for x := 0 to lDegrade.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lDegrade[x])}');
        end;
    end;
  File.WriteLines(TestOutput + '_TestCarOne.txt', lOut);
  CheckFilesEqual(TestOutput + '_TestCarOne.txt', TestOutput + '!TestCarOne.txt');
end;

method DexiGeneratorTest.TestCarGenerateSequence;
begin
  // this test is essentially the same as TestCarGenerateSequence
  // it was needed while trying to assure that the same generator outputs are produced by .NET and java
  // additionally, it demonstrates the use of Generator.OnEmit
  exit;
  {$HIDE H14}
  var lOut := new List<String>;
  {$SHOW H14}
  var Model := LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount,1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  var lCar := Model.Root.Inputs[0];
  var Generator := new DexiGenerator(lCar);
  lOut.Add(Generator.StructureToString);
  lOut.Add(Generator.SequenceToString);
  Generator.OnEmit :=
    method (aAssignment: IntArray; aFound:  List<IntArray>)
    begin
      lOut.Add($"*{aFound.Count}: {Utils.IntArrayToStr(aAssignment)}");
      Generator.DoEmit(aAssignment, aFound);
    end;
  Model.Evaluate;
  for lAlt := 0 to Model.AltCount - 1 do
    begin
      var lAlternative := Model.Alternative[lAlt].Copy;
      Generator.SetAlternative(lAlternative);
      for u := 0 to 1 do
       for lSteps := 0 to 2 do
        begin
          Generator.Unidirectional := u > 0;
          Generator.MaxSteps := lSteps;
          lOut.Add('');
          lOut.Add($'Alternative {lAlt + 1}, Unidirectional {Utils.BooleanToStr(Generator.Unidirectional)}, MaxSteps {lSteps}');
          var lImprove := Generator.Improve(0);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add('');
          lOut.Add($'Improved {Generator.CurrentDistanceInDir}, {Generator.CurrentDistanceOpDir}');
          if lImprove <> nil then
            for x := 0 to lImprove.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lImprove[x])}');
          var lDegrade := Generator.Degrade(0);
          lOut.Add('');
          lOut.Add('-> ' + AltToStr(Generator, lAlternative));
          lOut.Add($'Degraded  {Generator.CurrentDistanceInDir}, {Generator.CurrentDistanceOpDir}');
          if lDegrade <> nil then
            for x := 0 to lDegrade.AltCount - 1 do
              lOut.Add($'{x + 1}. {AltToStr(Generator, lDegrade[x])}');
        end;
    end;
  {$IFDEF JAVA}
    File.WriteLines(TestOutput + 'SequenceJava.txt', lOut);
  {$ELSE}
    File.WriteLines(TestOutput + 'SequenceNET.txt', lOut);
  {$ENDIF}
end;

end.
