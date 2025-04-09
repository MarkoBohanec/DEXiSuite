namespace DexiLibrary.Tests;

{$HIDE W28} // obsolete methods

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiModelsTest = public class(DexiLibraryTest)
   protected
    method TestLoadSave(aFileName: String);
  public
    method TestSettings;
    method TestLoadSaveCar;
    method TestLoadSaveLinked;
    method TestModelStatistics;
    method TestModelStatisticsLinked;
    method TestScaleStrings;
    method TestByName;
    method TestFindAlternative;
    method TestJoinAttributes;
    method TestEditAlternatives;
    method TestLoadSaveAdvanced;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiModelsTest.TestSettings;
begin
  var lSettings := new DexiSettings;
  Assert.IsTrue(lSettings.EvalType = EvaluationType.AsSet);
  Assert.IsTrue(lSettings.ExpandEmpty);
  Assert.IsTrue(lSettings.CheckBounds);
  Assert.IsTrue(lSettings.HasFullReports);
  Assert.IsTrue(lSettings.HasFullWeights);
  Assert.IsTrue(lSettings.SelectedReport[1]);
  Assert.IsTrue(lSettings.SelectedWeight[1]);

  lSettings.SelectedReport[1] := false;
  lSettings.SelectedWeight[1] := false;
  Assert.IsFalse(lSettings.HasFullReports);
  Assert.IsFalse(lSettings.HasFullWeights);
  Assert.IsFalse(lSettings.SelectedReport[1]);
  Assert.IsFalse(lSettings.SelectedWeight[1]);
end;

method DexiModelsTest.TestLoadSave(aFileName: String);
begin
  var Model := LoadModel(aFileName);
  Assert.IsNotNil(Model);
  var oFileName := (TestOutput + aFileName).Replace('.','_') + '.dxi';
  Model.SaveToFile(oFileName);
end;

method DexiModelsTest.TestLoadSaveCar;
begin
  TestLoadSave('Car.dxi');
end;

method DexiModelsTest.TestLoadSaveLinked;
begin
  TestLoadSave('Model_B.dxi');
end;

method DexiModelsTest.TestModelStatistics;
begin
  var Model := LoadModel('Car.dxi');
  var Stat := Model.Statistics;
  Assert.AreEqual(Stat.Attributes, 10);
  Assert.AreEqual(Stat.BasicAttributes, 6);
  Assert.AreEqual(Stat.AggregateAttributes, 4);
  Assert.AreEqual(Stat.LinkedAttributes, 0);
  Assert.AreEqual(Stat.Scales, 10);
  Assert.AreEqual(Stat.DiscrScales, 10);
  Assert.AreEqual(Stat.ContScales, 0);
  Assert.AreEqual(Stat.Functions, 4);
  Assert.AreEqual(Stat.TabularFunctions, 4);
  Assert.AreEqual(Stat.Alternatives, 2);
  Assert.IsFalse(Model.UsesDexiLibraryFeatures);
end;

method DexiModelsTest.TestModelStatisticsLinked;
begin
  var Model := LoadModel('Model_B.dxi');
  var Stat := Model.Statistics;
  Assert.AreEqual(Stat.Attributes, 21);
  Assert.AreEqual(Stat.BasicAttributes, 14);
  Assert.AreEqual(Stat.AggregateAttributes, 4);
  Assert.AreEqual(Stat.LinkedAttributes, 3);
  Assert.AreEqual(Stat.Scales, 21);
  Assert.AreEqual(Stat.DiscrScales, 21);
  Assert.AreEqual(Stat.ContScales, 0);
  Assert.AreEqual(Stat.Functions, 4);
  Assert.AreEqual(Stat.TabularFunctions, 4);
  Assert.AreEqual(Stat.Alternatives, 0);
  Assert.IsFalse(Model.UsesDexiLibraryFeatures);
end;

method DexiModelsTest.TestScaleStrings;
begin
  var Model := LoadModel('Car.dxi');
  Assert.IsNil(Model.DefaultScale);
  var lScaleStrings := Model.GetScaleStrings(Model.Root);
  var lDiffScales := Model.GetDifferentScales;
  Assert.IsNotNil(lScaleStrings);
  Assert.IsNotNil(lDiffScales);
  Assert.AreEqual(lScaleStrings.Count, 8);
  Assert.AreEqual(lDiffScales.Count, 7);

  lScaleStrings := Model.GetScaleStrings(Model.First, Model.First.Scale); // CAR
  Assert.IsNotNil(lScaleStrings);
  Assert.AreEqual(lScaleStrings.Count, 3);
end;

method DexiModelsTest.TestByName;
var Model: DexiModel;

  method Check(aName: String);
  begin
    var lAtt := Model.AttributeByName(aName);
    Assert.IsNotNil(lAtt);
    Assert.AreEqual(lAtt.Name, aName);
    var lInput := Model.InputAttributeByName(aName);
    Assert.AreEqual(lAtt, lInput);
    var lLink := Model.LinkAttributeByName(aName);
    Assert.IsNotNil(lLink);
    Assert.AreEqual(lAtt, lLink);

    lAtt := Model.AttributeByName(aName, 1);
    Assert.IsNil(lAtt);
  end;

begin
  Model := LoadModel('Car.dxi');
  Assert.AreEqual(Model.ModelName, 'CAR');
  var lAtts := Model.Root.CollectInputs;
  for each lAtt in lAtts do
    Check(lAtt.Name);
end;

method DexiModelsTest.TestFindAlternative;
begin
  var Model := LoadModel('Car.dxi');
  Assert.AreEqual(Model.FindAlternative('Car1'), 0);
  Assert.AreEqual(Model.FindAlternative('Car2'), 1);
  Assert.AreEqual(Model.FindAlternative('Car3'), -1);

  Assert.AreEqual(Model.FindAlternative('Car1', true), 0);
  Assert.AreEqual(Model.FindAlternative('Car1', false), 0);
  Assert.AreEqual(Model.FindAlternative('Car2', true), 1);
  Assert.AreEqual(Model.FindAlternative('Car2', false), 1);

  Assert.AreEqual(Model.FindAlternative('car2', true), -1);
  Assert.AreEqual(Model.FindAlternative('car2', false), 1);
  Assert.AreEqual(Model.FindAlternative('car3', true), -1);
  Assert.AreEqual(Model.FindAlternative('car3', true), -1);

  Assert.AreEqual(Model.FindAlternative('Car1', false, 1), -1);
end;


method DexiModelsTest.TestJoinAttributes;
begin
  var Model := LoadModel('JoinTest.dxi');
  var A1 := Model.AttributeByName('X1/2');
  var D1 := Model.AttributeByName('X12/2');
  var A2 := Model.AttributeByName('X2/3');
  var D2 := Model.AttributeByName('X22/2');
  var P := Model.AttributeByName('JoinTest');
  Assert.IsNotNil(A1);
  Assert.IsNotNil(D1);
  Assert.IsNotNil(A2);
  Assert.IsNotNil(D2);
  Assert.IsNotNil(P);

  var CanJoin1 := Model.CanJoinAttributes(D1, A1);
  Assert.IsFalse(CanJoin1);

  A1.Funct := nil;
  CanJoin1 := Model.CanJoinAttributes(D1, A1);
  Assert.IsTrue(CanJoin1);

  var CanJoin2 := Model.CanJoinAttributes(D2, A2);
  Assert.IsFalse(CanJoin2);

  A2.Funct := nil;
  CanJoin2 := Model.CanJoinAttributes(D2, A2);
  Assert.IsFalse(CanJoin2);

  A2.Scale := nil; // this invalidates A2.Parent's function, but is not of JoinAttributes concern
  CanJoin2 := Model.CanJoinAttributes(D2, A2);
  Assert.IsTrue(CanJoin2);

  // Join 1
  var Join1 := Model.JoinAttributes(D1, A1);
  Assert.AreEqual(Join1, D1);
  Assert.AreEqual(Join1.InpCount, 2);
  Assert.IsNotNil(Join1.Parent);
  Assert.AreEqual(Join1.Parent, P);
  Assert.IsNotNil(Join1.Scale);
  Assert.AreEqual(Join1.Scale.Count, 2);
  Assert.IsNotNil(Join1.Funct);
  Assert.AreEqual(Join1.Funct.Count, 9);
  Assert.AreEqual(Join1.ParentIndex, 0);
  Assert.IsNil(A1.Parent);
  Assert.IsNil(A1.Scale);
  Assert.IsNil(A1.Funct);
  Assert.AreEqual(A1.InpCount, 0);

  // Join 2
  var Join2 := Model.JoinAttributes(D2, A2);
  Assert.AreEqual(Join2, D2);
  Assert.AreEqual(Join2.InpCount, 2);
  Assert.IsNotNil(Join2.Parent);
  Assert.AreEqual(Join2.Parent, P);
  Assert.IsNotNil(Join2.Scale);
  Assert.AreEqual(Join2.Scale.Count, 2);
  Assert.IsNotNil(Join2.Funct);
  Assert.AreEqual(Join2.Funct.Count, 9);
  Assert.AreEqual(Join2.ParentIndex, 1);
  Assert.IsNil(A2.Parent);
  Assert.IsNil(A2.Scale);
  Assert.IsNil(A2.Funct);
  Assert.AreEqual(A2.InpCount, 0);
end;

method DexiModelsTest.TestEditAlternatives;
var Model: DexiModel;

  method CheckSelection(aSel: array of Boolean);
  begin
    for each lSel in aSel index x do
      Assert.AreEqual(lSel, Model.Selected[x]);
  end;

  method CheckNames(aNames: array of String);
  begin
    for each lName in aNames index x do
      Assert.AreEqual(Model.AltNames[x].Name, lName);
  end;

begin
  Model := LoadModel('Car.dxi');
  Assert.AreEqual(Model.AltCount, 2);
  var lInputs := Model.Root.CollectInputs;
  CheckSelection([true, true]);

  Model.Selected[0] := false;
  CheckSelection([false, true]);

  var lAlt1 := Model.Alternative[0];
  var lAlt2 := Model.Alternative[1];
  Assert.IsTrue(lAlt1 is DexiModelAlternative);

  var lAlt1Copy := lAlt1.Copy;
  Assert.IsTrue(lAlt1Copy is DexiAlternative);

  CheckEqualAlternativesOn(lInputs, lAlt1, lAlt1Copy);
  Assert.Throws(() -> (CheckEqualAlternativesOn(lInputs, lAlt1, lAlt2)));

  // Add
  Model.AddAlternative(lAlt1);
  Model.AddAlternative(lAlt1Copy);
  Assert.AreEqual(Model.AltCount, 4);
  CheckSelection([false, true, true, true]);
  Model.Selected[2] := false;
  CheckSelection([false, true, false, true]);
  CheckEqualAlternativesOn(lInputs, lAlt1, Model.Alternative[2]);
  CheckEqualAlternativesOn(lInputs, lAlt1, Model.Alternative[3]);

  // Insert
  Model.InsertAlternative(1, lAlt1);
  Assert.AreEqual(Model.AltCount, 5);
  CheckSelection([false, true, true, false, true]);
  CheckEqualAlternativesOn(lInputs, lAlt1, Model.Alternative[1]);
  CheckEqualAlternativesOn(lInputs, lAlt1, Model.Alternative[4]);

  // Remove
  var lRemove := Model.RemoveAlternative(2);
  Assert.AreEqual(Model.AltCount, 4);
  CheckSelection([false, true, false, true]);
  CheckEqualAlternativesOn(lInputs, lAlt2, lRemove);

  // Delete
  Model.DeleteAlternative(3);
  Assert.AreEqual(Model.AltCount, 3);
  CheckSelection([false, true, false]);

  // New Setup
  Model.AltNames[0].Name := '0';
  Model.AltNames[1].Name := '1';
  Model.AltNames[2].Name := '2';
  CheckNames(['0', '1', '2']);

  // Duplicate
  Model.DuplicateAlternative(0);
  lAlt2 := Model.Alternative[1];
  Assert.AreEqual(Model.AltCount, 4);
  CheckSelection([false, true, true, false]);
  CheckNames(['0', '0', '1', '2']);
  Model.AltNames[1].Name := 'C';
  CheckNames(['0', 'C', '1', '2']);
  CheckEqualAlternativesOn(lInputs, Model.Alternative[0], Model.Alternative[1]);

  // Copy
  Model.CopyAlternative(1, 0);
  Assert.AreEqual(Model.AltCount, 5);
  CheckSelection([true, false, true, true, false]);
  CheckNames(['C', '0', 'C', '1', '2']);
  Model.AltNames[0].Name := 'D';
  CheckNames(['D', '0', 'C', '1', '2']);
  CheckEqualAlternativesOn(lInputs, Model.Alternative[2], Model.Alternative[0]);

  // MovePrev
  Model.MoveAlternativePrev(4);
  Assert.AreEqual(Model.AltCount, 5);
  CheckSelection([true, false, true, false, true]);
  CheckNames(['D', '0', 'C',  '2', '1',]);

  // MoveNext
  Model.MoveAlternativeNext(1);
  Assert.AreEqual(Model.AltCount, 5);
  CheckSelection([true, true, false, false, true]);
  CheckNames(['D', 'C',  '0', '2', '1',]);

  // Exchenge
  Model.ExchangeAlternatives(0, 3);
  Assert.AreEqual(Model.AltCount, 5);
  CheckSelection([false, true, false, true, true]);
  CheckNames(['2', 'C',  '0', 'D', '1',]);

  // Move
  Model.MoveAlternative(1, 3);
  Assert.AreEqual(Model.AltCount, 5);
  CheckSelection([false, false, true, true, true]);
  CheckNames(['2', '0', 'D', 'C', '1',]);
end;

method DexiModelsTest.TestLoadSaveAdvanced;
begin
  var Model := LoadModel('OneLevelContinuousOld.dxi');
  Model.ForceLibraryFormat := false;
  Model.SaveToFile(TestOutput + 'OldOld.dxi');
  Model.ForceLibraryFormat := true;
  Model.SaveToFile(TestOutput + 'OldNew.dxi');
  Model := LoadModel('OneLevelContinuousNew.dxi');
  Model.ForceLibraryFormat := false;
  Model.SaveToFile(TestOutput + 'NewOld.dxi');
  Model.ForceLibraryFormat := true;
  Model.SaveToFile(TestOutput + 'NewNew.dxi');
end;

end.
