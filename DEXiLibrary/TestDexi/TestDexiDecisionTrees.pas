namespace DexiLibrary.Tests;

{$HIDE W28} // obsolete methods

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiDecisionTreesTest = public class(DexiLibraryTest)
  protected
    method WrTree(aDT: DecisionTree);
  public
    method TestDecisionTree;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiDecisionTreesTest.WrTree(aDT: DecisionTree);
var SStrings := new DexiScaleStrings;

  method WrNode(aNode: DecisionTreeNode; aLev: Integer);
  begin
    if aNode = nil then
      writeLn('NIL')
    else if aNode.Count = 0 then
      writeLn($'{aDT:Funct:Attribute:Name} = {SStrings.ValueOnScaleString(aNode:ClassValue, aDT:Funct:Attribute:Scale)}')
    else
      begin
        var lSplitOn := aNode.SplitOn;
        var lIndent := if aLev = 0 then '' else Utils.ChStr(4 * aLev);
        writeLn($'{lIndent}{lSplitOn:Name}:');
        lIndent := lIndent + '  ';
        for s := 0 to aNode.Count - 1 do
          begin
            var lSubtree := aNode.Subtree[s];
            var lValues := new DexiIntSet(lSubtree.AttValues);
            write($'{lIndent}{SStrings.ValueOnScaleString(lValues, lSplitOn:Scale)}:');
            if lSubtree.Count = 0 then write(' ') else writeLn;
            WrNode(lSubtree, aLev + 1);
          end;
      end;
  end;

begin
  WrNode(aDT.Root, 0);
  readLn;
end;

method DexiDecisionTreesTest.TestDecisionTree;
begin
  var Model := LoadModel('Car.dxi');
  var lCar := Model.AttributeByName('CAR');
  var lCarTab := lCar:Funct as DexiTabularFunction;
  Assert.IsNotNil(lCarTab);
  
  var DT := new DecisionTree(lCarTab);
  Assert.IsTrue(DT.CheckTree);

  DT := new DecisionTree(lCarTab, SplitMeasure.GiniGain);
  Assert.IsTrue(DT.CheckTree);

  var lComfort := Model.AttributeByName('COMFORT');
  var lComfortTab := lComfort:Funct as DexiTabularFunction;
  Assert.IsNotNil(lComfortTab);

  DT := new DecisionTree(lComfortTab);
//  WrTree(DT);
  Assert.IsTrue(DT.CheckTree);

  DT := new DecisionTree(lComfortTab, SplitMeasure.GiniGain);
  Assert.IsTrue(DT.CheckTree);

end;

end.
