namespace DexiLibrary.Tests;

{$HIDE W28} // obsolete methods

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiUndoRedoTest = public class(DexiLibraryTest)
  protected
    method CheckUndoState(aState: UndoState);
    method CheckComparison(aComp: UndoStateComparison; aEqual, aDifferent, aAdded, aDeleted: Integer);
  public
    method TestUndoRedoStates;
    method TestCollectUndoable;
    method TestMakeUndoState;
    method TestCompareUndoStates;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiUndoRedoTest.CheckUndoState(aState: UndoState);
begin
  Assert.IsNotNil(aState);
  for each lObj in aState.State.Keys do
    begin
      var lCont := aState[lObj];
      Assert.IsNotNil(lCont);
      Assert.AreNotEqual(lObj, lCont);
      Assert.IsTrue(lObj.EqualStateAs(lCont));
    end;
end;

method DexiUndoRedoTest.CheckComparison(aComp: UndoStateComparison; aEqual, aDifferent, aAdded, aDeleted: Integer);
begin
  Assert.AreEqual(aComp.Equal.Count, aEqual);
  Assert.AreEqual(aComp.Different.Count, aDifferent);
  Assert.AreEqual(aComp.Added.Count, aAdded);
  Assert.AreEqual(aComp.Deleted.Count, aDeleted);
end;

type
  TestUndoRedo = class (UndoRedo<String>)
  private
    fText: String;
    protected
    public
      method GetObjectState: String; override;
      method SetObjectState(aState: String); override;
      property Text: String read fText write fText;
  end;

method TestUndoRedo.GetObjectState: String;
begin
  result := fText;
end;

method TestUndoRedo.SetObjectState(aState: String);
begin
  fText := aState;
end;

method DexiUndoRedoTest.TestUndoRedoStates;
var lUndoRedo: TestUndoRedo;

  method CheckState(aUndo, aRedo: Integer; aText, aState, aPeekUndo, aPeekRedo: String);
  begin
    Assert.IsTrue(lUndoRedo.UndoCount = aUndo);
    Assert.IsTrue(lUndoRedo.RedoCount = aRedo);
    Assert.AreEqual(lUndoRedo.CanUndo, aUndo > 0);
    Assert.AreEqual(lUndoRedo.CanRedo, aRedo > 0);
    Assert.AreEqual(lUndoRedo.Text, aText);
    var lState := lUndoRedo.State;
    Assert.AreEqual(lState, aState);
    var lPeekUndo := lUndoRedo.PeekUndoState;
    Assert.AreEqual(lPeekUndo, aPeekUndo);
    var lPeekRedo := lUndoRedo.PeekRedoState;
    Assert.AreEqual(lPeekRedo, aPeekRedo);
  end;

begin
  lUndoRedo := new TestUndoRedo(Text := 'Init');
  Assert.IsTrue(lUndoRedo.Active);
  CheckState(0, 0, 'Init', nil, nil, nil,);
  lUndoRedo.SetState;
  CheckState(0, 0, 'Init', 'Init', nil, nil,);
  lUndoRedo.AddState;
  CheckState(1, 0, 'Init', 'Init', 'Init', nil);
  lUndoRedo.AddState('2nd');
  CheckState(2, 0, 'Init', '2nd', 'Init', nil);
  lUndoRedo.AddState('3rd');
  CheckState(3, 0, 'Init', '3rd', '2nd', nil);
  lUndoRedo.Text := 'New';
  lUndoRedo.AddState;
  CheckState(4, 0, 'New', 'New', '3rd', nil);
  lUndoRedo.Undo;
  CheckState(3, 1, '3rd', '3rd', '2nd', 'New');
  lUndoRedo.Undo;
  CheckState(2, 2, '2nd', '2nd', 'Init', '3rd');
  lUndoRedo.Text := 'Newest';
  lUndoRedo.AddState;
  CheckState(3, 0, 'Newest', 'Newest', '2nd', nil);
  lUndoRedo.Undo;
  CheckState(2, 1, '2nd', '2nd', 'Init', 'Newest');
  lUndoRedo.Redo;
  CheckState(3, 0, 'Newest', 'Newest', '2nd', nil);
end;

method DexiUndoRedoTest.TestCollectUndoable;
begin
  var lModel := LoadModel('Car.dxi');
  var lUndoable := new List<IUndoable>;
  lModel.CollectUndoableObjects(lUndoable);
  Assert.AreEqual(lUndoable.Count, 70);
end;

method DexiUndoRedoTest.TestMakeUndoState;
begin
  var lModel := LoadModel('Car.dxi');
  var lUndoable := new List<IUndoable>;
  lModel.CollectUndoableObjects(lUndoable);
  var lUndoState := new UndoState(lUndoable);
  CheckUndoState(lUndoState);
end;

method DexiUndoRedoTest.TestCompareUndoStates;
begin
  var lModel := LoadModel('Car.dxi');
  var lOriginalString := lModel.SaveSubtreeToString(nil);
  Assert.IsTrue(lOriginalString.Contains('<NAME>PRICE</NAME>'));
  var lUndoable := new List<IUndoable>;
  lModel.CollectUndoableObjects(lUndoable);
  var lCount := lUndoable.Count;
  var lUndoState := new UndoState(lUndoable);
  CheckUndoState(lUndoState);
  var lUndoState2 := new UndoState(lUndoable, lUndoState);
  CheckUndoState(lUndoState2);
  Assert.IsTrue(Utils.EqualLists(lUndoState.State.Keys, lUndoState2.State.Keys));

  // No change
  var lCompare := lUndoState2.CompareWith(lUndoState);
  CheckComparison(lCompare, lCount, 0, 0, 0);

  // Change Name/Description of two attributes
  var lPrice := lModel.AttributeByName('PRICE');
  Assert.IsNotNil(lPrice);
  var lSafety := lModel.AttributeByName('SAFETY');
  Assert.IsNotNil(lSafety);
  lPrice.Name := 'New name';
  lSafety.Description := 'New description';
  lUndoState2 := new UndoState(lUndoable, lUndoState);
  CheckUndoState(lUndoState2);
  lCompare := lUndoState2.CompareWith(lUndoState);
  CheckComparison(lCompare, lCount - 2, 2, 0, 0);
  Assert.IsTrue(lCompare.Different.Contains(lPrice));
  Assert.IsTrue(lCompare.Different.Contains(lSafety));

  var lChangedString := lModel.SaveSubtreeToString(nil);
  Assert.AreNotEqual(lOriginalString, lChangedString);
  Assert.IsTrue(lChangedString.Contains('<NAME>New name</NAME>'));
  Assert.IsTrue(not lChangedString.Contains('<NAME>PRICE</NAME>'));


  // Change scale of Safety
  DexiDiscreteScale(lSafety.Scale).Names[0] := 'smaller';

  // Delete 1st argument of Price
  var lBuyPrice := lPrice.Inputs[0];
  lPrice.DeleteInput(0);

  lUndoable.RemoveAll;
  lModel.CollectUndoableObjects(lUndoable);
  var lUndoState3 := new UndoState(lUndoable, lUndoState);
  CheckUndoState(lUndoState3);
  lCompare := lUndoState3.CompareWith(lUndoState);
  CheckComparison(lCompare, lCount - 7, 3, 0, 4);
  Assert.IsTrue(lCompare.Different.Contains(lPrice));
  Assert.IsTrue(lCompare.Different.Contains(lSafety));

  lCompare := lUndoState3.CompareWith(lUndoState2);
  CheckComparison(lCompare, lCount - 6, 2, 0, 4);
  Assert.IsTrue(lCompare.Deleted.Contains(lBuyPrice));
  Assert.IsTrue(lCompare.Deleted.Contains(lBuyPrice.Scale));
  Assert.IsTrue(lCompare.Different.Contains(lSafety.Scale));

  // Apply
  lUndoState.Apply;

  lUndoable := new List<IUndoable>;
  lModel.CollectUndoableObjects(lUndoable);
  Assert.AreEqual(lUndoable.Count, lCount);

  var lUndoFinalState := new UndoState(lUndoable);
  CheckUndoState(lUndoFinalState);
  lCompare := lUndoFinalState.CompareWith(lUndoState);
  CheckComparison(lCompare, lCount, 0, 0, 0);

  var lFinalString := lModel.SaveSubtreeToString(nil);
  Assert.AreEqual(lOriginalString, lFinalString);

end;

end.
