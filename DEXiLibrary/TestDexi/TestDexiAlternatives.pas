namespace DexiLibrary.Tests;

//TODO further LoadSave table tests

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiAlternativesTest = public class(DexiLibraryTest)
  private
  protected
  public
    method TestAlternative;
    method TestAlternativeExclude;
    method TestAlternativeUse;
    method TestAlternatives;
    method TestAltTableCar;
    method TestAltTableCarTab2Tab;
    method TestAltTableCarTab2Model2Tab;
    method TestDeepCompareWorkApp;
  end;

implementation

method DexiAlternativesTest.TestAlternative;
begin
  var A := new DexiAttribute('A');

  var A1:= new DexiAlternative('A1');

  var vA := A1[A];
  Assert.IsNil(vA);

  A1[A] := new DexiIntSingle(1);
  vA := A1[A];
  Assert.IsNotNil(vA);
  Assert.AreEqual(vA.AsInteger, 1);

  var A2 := A1.Copy;
  vA := A2[A];
  Assert.IsNotNil(vA);
  Assert.AreEqual(vA.AsInteger, 1);

  A1[A] := new DexiIntSingle(2);
  vA := A1[A];
  Assert.AreEqual(vA.AsInteger, 2);

  A1[A] := nil;
  vA := A1[A];
  Assert.IsNil(vA);

  A1[A] := new DexiIntSingle(3);
  vA := A1[A];
  Assert.AreEqual(vA.AsInteger, 3);

  A1.ExcludeAttribute(A);
  vA := A1[A];
  Assert.IsNil(vA);
end;

method DexiAlternativesTest.TestAlternativeExclude;
begin
  var A := new DexiAttribute('A');
  var B := new DexiAttribute('B');

  var A1:= new DexiAlternative('A1');
  A1[A] := new DexiIntSingle(1);
  A1[B] := new DexiIntSingle(2);

  var vA := A1[A];
  var vB := A1[B];
  Assert.AreEqual(vA.AsInteger, 1);
  Assert.AreEqual(vB.AsInteger, 2);

  A1.ExcludeAttribute(A);
  vA := A1[A];
  vB := A1[B];
  Assert.AreEqual(vA, nil);
  Assert.AreEqual(vB.AsInteger, 2);

  A1.ExcludeAttribute(B);
  vA := A1[A];
  vB := A1[B];
  Assert.AreEqual(vA, nil);
  Assert.AreEqual(vB, nil);

  A1[A] := new DexiIntSingle(1);
  A1[B] := new DexiIntSingle(2);
  vA := A1[A];
  vB := A1[B];
  Assert.AreEqual(vA.AsInteger, 1);
  Assert.AreEqual(vB.AsInteger, 2);
end;

method DexiAlternativesTest.TestAlternativeUse;
begin
  var A := new DexiAttribute('A');
  var B := new DexiAttribute('B');
  var C := new DexiAttribute('C');

  var A1:= new DexiAlternative('A1');
  A1[A] := new DexiIntSingle(1);
  A1[B] := new DexiIntSingle(2);
  A1[C] := new DexiIntSingle(3);

  var vA := A1[A];
  var vB := A1[B];
  var vC := A1[C];
  Assert.AreEqual(vA.AsInteger, 1);
  Assert.AreEqual(vB.AsInteger, 2);
  Assert.AreEqual(vC.AsInteger, 3);

  var lUseList := new DexiAttributeList;
  lUseList.Add([A, C]);
  A1.UseAttributes(lUseList);

  vA := A1[A];
  vB := A1[B];
  vC := A1[C];
  Assert.AreEqual(vA.AsInteger, 1);
  Assert.AreEqual(vB, nil);
  Assert.AreEqual(vC.AsInteger, 3);
end;

method DexiAlternativesTest.TestAlternatives;
begin
  var Alts := new DexiAlternatives;

  Assert.IsNotNil(Alts);
  Assert.AreEqual(Alts.AltCount, 0);

  Alts.AddAlternative('A1');
  Alts.InsertAlternative(1, 'A2');
  Alts.InsertAlternative(0, 'A0');
  Assert.AreEqual(Alts.AltCount, 3);
  Assert.AreEqual(Alts[0].Name, 'A0');
  Assert.AreEqual(Alts[1].Name, 'A1');
  Assert.AreEqual(Alts[2].Name, 'A2');

  var A := new DexiAttribute('A');
  var B := new DexiAttribute('B');

  Alts[0][A] := new DexiIntSingle(1);
  Alts.AltValue[1, A] := new DexiIntSingle(2);
  Alts.AltValue[1, B] := new DexiIntSingle(3);

  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B], nil);
  Assert.AreEqual(Alts[1][A].AsInteger, 2);
  Assert.AreEqual(Alts[1][B].AsInteger, 3);
  Assert.AreEqual(Alts[2][A], nil);
  Assert.AreEqual(Alts.AltValue[2, B], nil);

  Alts.ExcludeAttribute(B);
  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B], nil);
  Assert.AreEqual(Alts[1][A].AsInteger, 2);
  Assert.AreEqual(Alts[1][B], nil);
  Assert.AreEqual(Alts[2][A], nil);
  Assert.AreEqual(Alts.AltValue[2, B], nil);

  Alts.MoveAlternativeNext(0);
  Assert.AreEqual(Alts.AltCount, 3);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[1].Name, 'A0');
  Assert.AreEqual(Alts[2].Name, 'A2');

  Alts.MoveAlternativePrev(2);
  Assert.AreEqual(Alts.AltCount, 3);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[1].Name, 'A2');
  Assert.AreEqual(Alts[2].Name, 'A0');

  var lRem := Alts.RemoveAlternative(0);
  Assert.AreEqual(Alts.AltCount, 2);
  Assert.IsNotNil(lRem);
  Assert.AreEqual(lRem[A].AsInteger, 2);
  Assert.AreEqual(lRem[B], nil);
  Assert.AreEqual(Alts[0].Name, 'A2');
  Assert.AreEqual(Alts[1].Name, 'A0');

  Alts.DeleteAlternative(1);
  Assert.AreEqual(Alts.AltCount, 1);
  Assert.AreEqual(Alts[0].Name, 'A2');

  Alts.DeleteAlternative(0);
  Assert.AreEqual(Alts.AltCount, 0);

  Alts.AddAlternative('A1');
  Alts[0][A] := new DexiIntSingle(1);
  Alts.AltValue[0, B] := new DexiIntSingle(2);
  Assert.AreEqual(Alts.AltCount, 1);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B].AsInteger, 2);

  Alts.DuplicateAlternative(0);
  Assert.AreEqual(Alts.AltCount, 2);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[1].Name, 'A1');
  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B].AsInteger, 2);
  Assert.AreEqual(Alts[1][A].AsInteger, 1);
  Assert.AreEqual(Alts[1][B].AsInteger, 2);

  Alts[1].Name := 'A2';
  Alts.AltValue[1, B] := new DexiIntSingle(3);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[1].Name, 'A2');
  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B].AsInteger, 2);
  Assert.AreEqual(Alts[1][A].AsInteger, 1);
  Assert.AreEqual(Alts[1][B].AsInteger, 3);

  Alts.CopyAlternative(0, 2);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[1].Name, 'A2');
  Assert.AreEqual(Alts[2].Name, 'A1');
  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B].AsInteger, 2);
  Assert.AreEqual(Alts[1][A].AsInteger, 1);
  Assert.AreEqual(Alts[1][B].AsInteger, 3);
  Assert.AreEqual(Alts[2][A].AsInteger, 1);
  Assert.AreEqual(Alts[2][B].AsInteger, 2);

  Alts.ExchangeAlternatives(1, 2);
  Assert.AreEqual(Alts[0].Name, 'A1');
  Assert.AreEqual(Alts[1].Name, 'A1');
  Assert.AreEqual(Alts[2].Name, 'A2');
  Assert.AreEqual(Alts[0][A].AsInteger, 1);
  Assert.AreEqual(Alts[0][B].AsInteger, 2);
  Assert.AreEqual(Alts[1][A].AsInteger, 1);
  Assert.AreEqual(Alts[1][B].AsInteger, 2);
  Assert.AreEqual(Alts[2][A].AsInteger, 1);
  Assert.AreEqual(Alts[2][B].AsInteger, 3);

  var Alts2 := new DexiAlternatives;
  Alts2.Assign(Alts);
  Assert.AreEqual(Alts.AltCount, Alts2.AltCount);
  Assert.AreEqual(Alts2[0].Name, 'A1');
  Assert.AreEqual(Alts2[1].Name, 'A1');
  Assert.AreEqual(Alts2[2].Name, 'A2');
  Assert.AreEqual(Alts2[0][A].AsInteger, 1);
  Assert.AreEqual(Alts2[0][B].AsInteger, 2);
  Assert.AreEqual(Alts2[1][A].AsInteger, 1);
  Assert.AreEqual(Alts2[1][B].AsInteger, 2);
  Assert.AreEqual(Alts2[2][A].AsInteger, 1);
  Assert.AreEqual(Alts2[2][B].AsInteger, 3);
end;

method DexiAlternativesTest.TestAltTableCar;
begin
  var Model := DexiLibraryTest.LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Model.CleanupAlternatives;
  var Table := new DexiAlternativesTable;
  Table.LoadFromModel(Model);
  Table.SaveToTabFile(DexiLibraryTest.TestOutput + 'Car.tab');
end;

method DexiAlternativesTest.TestAltTableCarTab2Tab;
begin
  var Model := DexiLibraryTest.LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  var Table := new DexiAlternativesTable(Model);
  var lInTab := DexiLibraryTest.TestPath + 'Car.tab';
  var lOutTab := DexiLibraryTest.TestOutput + 'Car_tab.tab';
  Table.LoadFromTabFile(lInTab, Model);
  Assert.AreEqual(Table.AltCount, 2);
  Table.SaveToTabFile(lOutTab);
  DexiLibraryTest.CheckFilesEqual(lInTab, lOutTab);
end;

method DexiAlternativesTest.TestAltTableCarTab2Model2Tab;
begin
  var Model := DexiLibraryTest.LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Model.CleanupAlternatives;
  Model.Settings.AttId := AttributeIdentification.Id;
  var Table := new DexiAlternativesTable(Model);
  var lInTab := DexiLibraryTest.TestPath + 'Car.tab';
  var lOutTab := DexiLibraryTest.TestOutput + 'CarMtab.tab';
  Table.LoadFromTabFile(lInTab, Model);
  Assert.AreEqual(Table.AltCount, 2);
  Table.SaveToModel;
  Assert.AreEqual(Model.AltCount, 2);

  Model.Evaluate;
  Table.LoadFromModel(Model);
  Assert.AreEqual(Table.AltCount, 2);
  Table.SaveToTabFile(lOutTab);
  DexiLibraryTest.CheckFilesEqual(lInTab, lOutTab);

  Table := new DexiAlternativesTable(Model);
  Table.LoadFromModel(Model);
  Assert.AreEqual(Table.AltCount, 2);
  Table.SaveToTabFile(lOutTab);
  DexiLibraryTest.CheckFilesEqual(lInTab, lOutTab);
end;

method DexiAlternativesTest.TestDeepCompareWorkApp;
begin
  var Model := LoadModel('WorkApp.dxi');
  var lWorkApp := Model.AttributeByName('WORK_APP');
  var fWorkApp := lWorkApp.Funct as DexiTabularFunction;
  var Evaluator :=  new DexiEvaluator(Model);
  for r1 := 0 to fWorkApp.Count - 1 do
  for r2 := 0 to fWorkApp.Count - 1 do
    begin
      var lInps1 := fWorkApp.ArgValues[r1];
      var lInps2 := fWorkApp.ArgValues[r2];
      var lAlt1 := new DexiAlternative('Test', Utils.IntArrayToStr(lInps1));
      var lAlt2 := new DexiAlternative('Test', Utils.IntArrayToStr(lInps2));
      for i := 0 to lWorkApp.InpCount - 1 do
        begin
          lAlt1[lWorkApp.Inputs[i]] := new DexiIntSingle(lInps1[i]);
          lAlt2[lWorkApp.Inputs[i]] := new DexiIntSingle(lInps2[i]);
        end;
      Evaluator.Evaluate(lAlt1);
      Evaluator.Evaluate(lAlt2);
      var lComparison := Model.DeepCompare(lAlt1, lAlt2);
      var lCompare := lComparison[lWorkApp];
      var lExpectedHere := Values.IntToPrefCompare(Utils.Compare(fWorkApp.RuleValLow[r1], fWorkApp.RuleValLow[r2]));
      var lExpectedBelow := fWorkApp.CompareRules(r1, r2);
      Assert.AreEqual(lCompare.Here, lExpectedHere);
      Assert.AreEqual(lCompare.Below, lExpectedBelow);
    end;
end;

end.
