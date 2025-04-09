namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  ListsTest = public class(DexiLibraryTest)
  protected
    property L1: array of String := ['1', '2', '3', '2'];
    method CheckList(aList: List<String>; aComp: array of String);
  public
    method TestSetToOne;
    method TestSetToMany;
    method TestIncludeOne;
    method TestIncludeMany;
    method TestExcludeOne;
    method TestExcludeMany;
    method TestExcludeOneAll;
    method TestExcludeManyAll;
  end;

implementation

method ListsTest.CheckList(aList: List<String>; aComp: array of String);
begin
  Assert.AreEqual(aList.Count, length(aComp));
  for i := 0 to Utils.ListCount(aList) - 1 do
    Assert.AreEqual(aList[i], aComp[i]);
end;

method ListsTest.TestSetToOne;
begin
  var lList := new List<String>(L1);
  CheckList(lList, L1);
  lList.SetTo('new');
  CheckList(lList, ['new']);
end;

method ListsTest.TestSetToMany;
begin
  var lList := new List<String>(L1);
  CheckList(lList, L1);
  lList.SetTo(['new1', 'new2']);
  CheckList(lList, ['new1', 'new2']);
end;

method ListsTest.TestIncludeOne;
begin
  var lList := new List<String>(L1);
  lList.Include('2');
  CheckList(lList, L1);
  lList.Include('3');
  CheckList(lList, L1);
  lList.Include('4');
  CheckList(lList, ['1', '2', '3', '2', '4']);
  lList.Include('4');
  CheckList(lList, ['1', '2', '3', '2', '4']);
  lList.Include('5');
  CheckList(lList, ['1', '2', '3', '2', '4', '5']);
end;

method ListsTest.TestIncludeMany;
begin
  var lList := new List<String>(L1);
  lList.Include(['2', '3', '4', '4', '5']);
  CheckList(lList, ['1', '2', '3', '2', '4', '5']);
end;

method ListsTest.TestExcludeOne;
begin
  var lList := new List<String>(L1);
  lList.Exclude('1', false);
  CheckList(lList, ['2', '3', '2']);
  lList.Exclude('1', false);
  CheckList(lList, ['2', '3', '2']);
  lList.Exclude('2', false);
  CheckList(lList, ['3', '2']);
  lList.Exclude('2', false);
  CheckList(lList, ['3']);
  lList.Exclude('4', false);
  CheckList(lList, ['3']);
  lList.Exclude('3', false);
  CheckList(lList, []);
end;

method ListsTest.TestExcludeMany;
begin
  var lList := new List<String>(L1);
  lList.Exclude(['1', '2', '3', '4'], false);
  CheckList(lList, ['2']);
end;

method ListsTest.TestExcludeOneAll;
begin
  var lList := new List<String>(L1);
  lList.Exclude('1', true);
  CheckList(lList, ['2', '3', '2']);
  lList.Exclude('1', true);
  CheckList(lList, ['2', '3', '2']);
  lList.Exclude('2', true);
  CheckList(lList, ['3']);
  lList.Exclude('2', true);
  CheckList(lList, ['3']);
  lList.Exclude('4', true);
  CheckList(lList, ['3']);
  lList.Exclude('3', true);
  CheckList(lList, []);
end;

method ListsTest.TestExcludeManyAll;
begin
  var lList := new List<String>(L1);
  lList.Exclude(['1', '2', '3', '4'], true);
  CheckList(lList, []);
end;

end.
