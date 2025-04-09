namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiAttributesTest = public class(DexiLibraryTest)
  private
  protected
    method TestTree(aWithLinks: Boolean := false): DexiAttribute;
    method CheckAttribute(aAtt: DexiAttribute; aName: String; aInpCount: Integer; aParent: DexiAttribute; aType: String; aLink: DexiAttribute := nil);
    method CheckLayout(aAtt: DexiAttribute; aLevel: Integer; aTree, aPath: String; aRight: DexiAttribute);
    method CheckCollect(aList: DexiAttributeList; aNames: array of String);
    method CheckInputs(aAtt: DexiAttribute; aInputs: array of String);
    method Contains1(aAtt: DexiAttribute): Boolean;
  public
    method TestGetInfoOnTree;
    method TestGetInfoOnTreeLinked;
    method TestGetInfoOnCar;
    method TestDepends;
    method TestDomain;
    method TestAttributePath;
    method TestOperations;
    method TestCollectBasicForEvaluation;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiAttributesTest.TestTree(aWithLinks: Boolean := false): DexiAttribute;
// R
//    A
//      A1
//          B11
//          B12
//      B
//      A2
//          B21
//          B22
//          B23
begin
  var R := new DexiAttribute('R');
  var A := new DexiAttribute('A');
  var A1 := new DexiAttribute('A1');
  var B11 := new DexiAttribute('B11');
  var B12 := new DexiAttribute('B12');
  var B := new DexiAttribute('B');
  var A2 := new DexiAttribute('A2');
  var B21 := new DexiAttribute('B21');
  var B22 := new DexiAttribute('B22');
  var B23 := new DexiAttribute('B23');
  R.AddInput(A);
  A.AddInput(A1);
  A.AddInput(B);
  A.AddInput(A2);
  A1.AddInput(B11);
  A1.AddInput(B12);
  A2.AddInput(B21);
  A2.AddInput(B22);
  A2.AddInput(B23);
  if aWithLinks then
    begin
      B11.Link := A2;
      B.Link := B12;
    end;
  result := R;
end;

method DexiAttributesTest.CheckAttribute(aAtt: DexiAttribute; aName: String; aInpCount: Integer; aParent: DexiAttribute; aType: String; aLink: DexiAttribute := nil);
begin
  Assert.IsNotNil(aAtt);
  Assert.AreEqual(aAtt.Name, aName);
  Assert.AreEqual(aAtt.InpCount, aInpCount);
  Assert.AreEqual(aAtt.Parent, aParent);
  Assert.AreEqual(aAtt.Link, aLink);
  var lType := '';
  if aAtt.IsRoot then lType := 'R';
  if aAtt.IsAggregate then lType := lType + 'A';
  if aAtt.IsBasic then lType := lType + 'B';
  if aAtt.Link <> nil then lType := lType + 'L';
  Assert.AreEqual(aType, lType);

  Assert.AreEqual(DexiAttribute.AttributeIsAggregate(aAtt), aAtt.IsAggregate);
  Assert.AreEqual(DexiAttribute.AttributeIsBasic(aAtt), aAtt.IsBasic);
  Assert.AreEqual(DexiAttribute.AttributeIsBasicNonLinked(aAtt), aAtt.IsBasicNonLinked);
  Assert.AreEqual(DexiAttribute.AttributeIsRoot(aAtt), aAtt.IsRoot);
  Assert.AreEqual(aAtt.IsBasicNonLinked, aAtt.IsBasic and (aAtt.Link = nil));
end;

method DexiAttributesTest.CheckLayout(aAtt: DexiAttribute; aLevel: Integer; aTree, aPath: String; aRight: DexiAttribute);
begin
  Assert.IsNotNil(aAtt);
  Assert.AreEqual(aAtt.Level, aLevel);
//  writeln($"{aAtt.Name}: '{aAtt.TreeIndent}' '{aAtt.SecureParentPath}' {aAtt.Right:Name}");
  Assert.AreEqual(aAtt.TreeIndent, aTree);
  Assert.AreEqual(aAtt.SecureParentPath, aPath);
  Assert.AreEqual(aAtt.Right, aRight);
end;

method DexiAttributesTest.CheckCollect(aList: DexiAttributeList; aNames: array of String);
begin
//  for i := 0 to aList.Count - 1 do
//    &write(aList.Names[i] + ' ');
//  writeLn;
  Assert.AreEqual(aList.Count, length(aNames));
  for i := 0 to aList.Count - 1 do
    Assert.AreEqual(aList.Names[i], aNames[i]);
end;

method DexiAttributesTest.CheckInputs(aAtt: DexiAttribute; aInputs: array of String);
begin
  Assert.IsNotNil(aAtt);
  Assert.AreEqual(aAtt.InpCount, length(aInputs));
  for i := 0 to aAtt.InpCount - 1 do
    Assert.AreEqual(aAtt.Inputs[i].Name, aInputs[i]);
end;

method DexiAttributesTest.Contains1(aAtt: DexiAttribute): Boolean;
begin
  result := aAtt.Name.Contains('1');
end;

method DexiAttributesTest.TestGetInfoOnTree;
begin
  var R := TestTree;
  CheckAttribute(R, 'R', 1, nil, 'RA');
  var A := R.Inputs[0];
  CheckAttribute(A, 'A', 3, R, 'A');
  var A1 := A.Inputs[0];
  CheckAttribute(A1, 'A1', 2, A, 'A');
  var A2 := A.Inputs[2];
  CheckAttribute(A2, 'A2', 3, A, 'A');
  var B := A.Inputs[1];
  CheckAttribute(B, 'B', 0, A, 'B');
  var B11 := A1.Inputs[0];
  CheckAttribute(B11, 'B11', 0, A1, 'B');
  var B12 := A1.Inputs[1];
  CheckAttribute(B12, 'B12', 0, A1, 'B');
  var B21 := A2.Inputs[0];
  CheckAttribute(B21, 'B21', 0, A2, 'B');
  var B22 := A2.Inputs[1];
  CheckAttribute(B22, 'B22', 0, A2, 'B');
  var B23 := A2.Inputs[2];
  CheckAttribute(B23, 'B23', 0, A2, 'B');

  CheckCollect(R.CollectBasic, ['B11', 'B12', 'B', 'B21', 'B22', 'B23']);
  CheckCollect(R.CollectBasicNonLinked, ['B11', 'B12', 'B', 'B21', 'B22', 'B23']);
  CheckCollect(R.CollectAggregate, ['A', 'A1', 'A2']);
  CheckCollect(R.CollectInputs(@Contains1), ['A1', 'B11', 'B12', 'B21']);
  CheckCollect(R.CollectInputs((aAtt) -> aAtt.Name.Contains('A')), ['A', 'A1', 'A2']);

  CheckLayout(R, 0, '', '/R', nil);
  CheckLayout(A, 1, '', '/A', nil);
  CheckLayout(A1, 2, '*', '/A/A1', B);
  CheckLayout(A2, 2, '+', '/A/A2', nil);
  CheckLayout(B, 2, '*', '/A/B', A2);
  CheckLayout(B11, 3, '|*', '/A/A1/B11', B12);
  CheckLayout(B12, 3, '|+', '/A/A1/B12', B21);
  CheckLayout(B21, 3, '.*', '/A/A2/B21', B22);
  CheckLayout(B22, 3, '.*', '/A/A2/B22', B23);
  CheckLayout(B23, 3, '.+', '/A/A2/B23', nil);
end;

method DexiAttributesTest.TestGetInfoOnTreeLinked;
begin
  var R := TestTree(true);
  CheckAttribute(R, 'R', 1, nil, 'RA');
  var A := R.Inputs[0];
  CheckAttribute(A, 'A', 3, R, 'A');
  var A1 := A.Inputs[0];
  CheckAttribute(A1, 'A1', 2, A, 'A');
  var B12 := A1.Inputs[1];
  CheckAttribute(B12, 'B12', 0, A1, 'B');
  var A2 := A.Inputs[2];
  CheckAttribute(A2, 'A2', 3, A, 'A');
  var B22 := A2.Inputs[1];
  CheckAttribute(B22, 'B22', 0, A2, 'B');
  var B := A.Inputs[1];
  CheckAttribute(B, 'B', 0, A, 'BL', B12);
  var B11 := A1.Inputs[0];
  CheckAttribute(B11, 'B11', 0, A1, 'BL', A2);
  var B21 := A2.Inputs[0];
  CheckAttribute(B21, 'B21', 0, A2, 'B');
  var B23 := A2.Inputs[2];
  CheckAttribute(B23, 'B23', 0, A2, 'B');

  CheckCollect(R.CollectBasic, ['B11', 'B12', 'B', 'B21', 'B22', 'B23']);
  CheckCollect(R.CollectBasicNonLinked, ['B12', 'B21', 'B22', 'B23']);
  CheckCollect(R.CollectAggregate, ['A', 'A1', 'A2']);

  Assert.AreEqual(A1.SpaceSize, -1);
end;

method DexiAttributesTest.TestGetInfoOnCar;
begin
  var M := DexiLibraryTest.LoadModel('Car.dxi');
  Assert.IsNotNil(M);
  var R := M.Root;
  Assert.IsNotNil(R);
  CheckAttribute(R, 'Root', 1, nil, 'RA');
  CheckCollect(R.CollectBasic, ['BUY.PRICE', 'MAINT.PRICE', '#PERS', '#DOORS', 'LUGGAGE', 'SAFETY']);
  CheckCollect(R.CollectBasicNonLinked, ['BUY.PRICE', 'MAINT.PRICE', '#PERS', '#DOORS', 'LUGGAGE', 'SAFETY']);
  CheckCollect(R.CollectAggregate, ['CAR', 'PRICE', 'TECH.CHAR.', 'COMFORT']);
  CheckCollect(R.CollectInputs((aAtt) -> aAtt.Name.Contains('A')), ['CAR', 'MAINT.PRICE', 'TECH.CHAR.', 'LUGGAGE', 'SAFETY']);

  var lAggregate := R.CollectAggregate;
  var lSizes := [12, 9, 9, 36];
  for each lAtt in lAggregate index x do
    Assert.AreEqual(lAtt.SpaceSize, lSizes[x]);
end;

method DexiAttributesTest.TestDepends;

  method CheckAtt(aAtt: DexiAttribute);
  begin
    var lInputs := aAtt.CollectInputs;
    for i := 0 to lInputs.Count - 1 do
      begin
        Assert.IsFalse(aAtt.Affects(lInputs[i]));
        Assert.IsTrue(aAtt.Depends(lInputs[i]));
        Assert.IsTrue(lInputs[i].Affects(aAtt));
        Assert.IsFalse(lInputs[i].Depends(aAtt));
        CheckAtt(lInputs[i]);
      end;
  end;

begin
  var R := TestTree;
  var lAll := R.CollectInputs;
  Assert.IsNotNil(lAll);
  Assert.AreEqual(lAll.Count, 9);
  CheckAtt(R);
end;

method DexiAttributesTest.TestDomain;
var Model: DexiModel;

  method CheckDomain(aAttName: String; aDomain: IntArray);
  begin
    var lAtt := Model.AttributeByName(aAttName);
    Assert.IsNotNil(lAtt);
    var lDomain := lAtt.Domain;
    Assert.IsTrue(Utils.IntArrayEq(lDomain, aDomain));
  end;

begin
  Model := DexiLibraryTest.LoadModel('Car.dxi');
  CheckDomain('CAR', [2, 3]);
  CheckDomain('PRICE', [2, 2]);
  CheckDomain('TECH.CHAR.', [2, 2]);
  CheckDomain('COMFORT', [2, 3, 2]);
end;

method DexiAttributesTest.TestOperations;
begin
  var R := TestTree;
  CheckAttribute(R, 'R', 1, nil, 'RA');
  var A := R.Inputs[0];
  CheckAttribute(A, 'A', 3, R, 'A');
  CheckInputs(A, ['A1', 'B', 'A2']);

  A.MoveInputNext(0);
  CheckInputs(A, ['B', 'A1', 'A2']);

  A.MoveInputPrev(2);
  CheckInputs(A, ['B', 'A2', 'A1']);

  A.AddInput(new DexiAttribute('X'));
  CheckInputs(A, ['B', 'A2', 'A1', 'X']);

  A.InsertInput(4, new DexiAttribute('Y'));
  CheckInputs(A, ['B', 'A2', 'A1', 'X', 'Y']);

  A.InsertInput(0, new DexiAttribute('O'));
  CheckInputs(A, ['O', 'B', 'A2', 'A1', 'X', 'Y']);

  var B := A.RemoveInput(1);
  CheckInputs(A, ['O', 'A2', 'A1', 'X', 'Y']);
  CheckAttribute(B, 'B', 0, A, 'B');

  A.DeleteInput(3);
  CheckInputs(A, ['O', 'A2', 'A1', 'Y']);

  var A2 := A.Inputs[1];
  CheckAttribute(A2, 'A2', 3, A, 'A');
  var A2R := A.RemoveInput(A2);
  CheckInputs(A, ['O', 'A1', 'Y']);
  Assert.AreEqual(A2, A2R);

  var O := A.Inputs[0];
  A.DeleteInput(O);
  CheckInputs(A, ['A1', 'Y']);

  A.Clear;
  CheckInputs(A, []);
end;

method DexiAttributesTest.TestAttributePath;
begin
  var Model := DexiLibraryTest.LoadModel('Car.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount,1);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  Assert.AreEqual(Model.Root.Inputs[0].Name,'CAR');

  var aAtt := Model.AttributeByPath('CAR');;
  Assert.IsNil(aAtt);

  aAtt := Model.AttributeByPath('/CAR');;
  Assert.AreEqual(aAtt.Name, 'CAR');
  Assert.AreEqual(aAtt.ParentPath, '/CAR');
  Assert.AreEqual(aAtt.SecureParentPath, '/CAR');

  aAtt := Model.AttributeByPath('#CAR');;
  Assert.AreEqual(aAtt.Name, 'CAR');
  aAtt := Model.AttributeByPath('/CAR/PRICE');;
  Assert.AreEqual(aAtt.Name, 'PRICE');
  Assert.AreEqual(aAtt.ParentPath, '/CAR/PRICE');
  Assert.AreEqual(aAtt.SecureParentPath, '/CAR/PRICE');

  aAtt := Model.AttributeByPath('/CAR/TECH.CHAR.');;
  Assert.AreEqual(aAtt.Name, 'TECH.CHAR.');

  aAtt := Model.AttributeByPath('\CAR\PRICE\MAINT.PRICE');;
  Assert.AreEqual(aAtt.Name, 'MAINT.PRICE');
  Assert.AreEqual(aAtt.ParentPath, '/CAR/PRICE/MAINT.PRICE');
  Assert.AreEqual(aAtt.SecureParentPath, '/CAR/PRICE/MAINT.PRICE');
  Assert.AreEqual(aAtt.ParentPath('-'), '-CAR-PRICE-MAINT.PRICE');
  Assert.AreEqual(aAtt.SecureParentPath(['.', '*']), '*CAR*PRICE*MAINT.PRICE');

  aAtt.Name := 'MAINT/PRICE';

  Assert.AreEqual(aAtt.ParentPath, '/CAR/PRICE/MAINT/PRICE');
  Assert.AreEqual(aAtt.ParentPath('.'), '.CAR.PRICE.MAINT/PRICE');
  Assert.AreEqual(aAtt.SecureParentPath, '|CAR|PRICE|MAINT/PRICE');

  aAtt := Model.AttributeByPath('\CAR\PRICE\MAINT.PRICE\');;
  Assert.IsNil(aAtt);
end;

method DexiAttributesTest.TestCollectBasicForEvaluation;
begin
  var Model := DexiLibraryTest.LoadModel('AgriFoodChainIntegrated.dxi');
  Assert.IsNotNil(Model);
  Assert.IsNotNil(Model.Root);
  Assert.AreEqual(Model.Root.InpCount, 6);
  Assert.IsNotNil(Model.Root.Inputs[0]);
  Assert.AreEqual(Model.Root.Inputs[0].Name, 'Production');

  var lFirst := Model.AttributeByName('Production');
  Assert.IsNotNil(lFirst);

  var lAtts := lFirst.CollectBasicForEvaluation;
  Assert.AreEqual(lAtts.Count, 3);
  for each lAtt in lAtts do
    begin
      Assert.Istrue(lAtt.IsBasic);
      Assert.IsFalse(lAtt.IsLinked);
    end;

end;

end.
