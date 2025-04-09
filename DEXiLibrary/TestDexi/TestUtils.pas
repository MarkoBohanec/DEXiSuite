namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  UtilsTest = public class(DexiLibraryTest)
  protected
    method CheckIntSet(aSet: SetOfInt; aArr: IntArray);
    method CheckIntArray(aArr1, aArr2: IntArray);
    method CheckFltArray(aArr1, aArr2: FltArray);
  public
    method TestSetOfCharCreate;
    method TestSetOfCharInclude;
    method TestSetOfCharExclude;
    method TestSetOfCharContains;

    method TestSetOfIntCreate;
    method TestSetOfIntInclude;
    method TestSetOfIntExclude;
    method TestSetOfIntContains;

    method TestIntPair;

    method TestUtilsFloatEq;
    method TestUtilsSwap;
    method TestUtilsGCD;

    method TestPos0;
    method TestCopyString;
    method TestStrEl;
    method TestChStr;
    method TestIdString;
    method TestRestOf;
    method TestLeftOf;
    method TestRightOf;
    method TestReplaceStr;
    method TestNextElem;

    method TestListContains;
    method TestListOrder;
    method TestOrderList;

    method TestBreakToLines;
    method TestBreakToWords;

    method TestNewIntArray;
    method TestCopyIntArray;
    method TestIntArrayIndex;
    method TestIntArrayEq;
    method TestConcatenateIntArrays;
    method TestIntArrayInsert;
    method TestIntArrayDelete;
    method TestIntArrayMove;
    method TestIntArrayExchange;
    method TestIntArraySubset;
    method TestNewFltArray;
    method TestCopyFltArray;
    method TestFltArrayEq;
    method TestConcatenateFltArrays;
    method TestFltArrayInsert;
    method TestFltArrayDelete;
    method TestFltArrayMove;

    method TestConversions;

    method TestCompareInt;
    method TestCompareFlt;
    method TestCompareIntArray;
    method TestCompareFltArray;

    method TestDistances;
    method TestCorrelations;

    method TestImpurity;

    method TestFlags;

    method TestIndex;

    method TestCompositeString;
  end;

implementation

method UtilsTest.CheckIntSet(aSet: SetOfInt; aArr: IntArray);
begin
  Assert.IsNotNil(aSet);
  var lArr := aSet.Ints;
  CheckIntArray(lArr, aArr);
  var lSet := new SetOfInt(aArr);
  Assert.IsTrue(aSet <> lSet);
  Assert.IsTrue(aSet.EqualsTo(lSet));
  Assert.IsTrue(aSet.Ints <> aSet.Members);
  Assert.IsTrue(Utils.IntArrayEq(aSet.Ints, aSet.Members));
end;

method UtilsTest.CheckIntArray(aArr1, aArr2: IntArray);
begin
  Assert.IsTrue(aArr1 <> aArr2);
  Assert.AreEqual(length(aArr1), length(aArr2));
  for i := low(aArr1) to high(aArr1) do
    Assert.AreEqual(aArr1[i], aArr2[i]);
end;

method UtilsTest.CheckFltArray(aArr1, aArr2: FltArray);
begin
  Assert.AreEqual(length(aArr1), length(aArr2));
  for i := low(aArr1) to high(aArr1) do
    Assert.IsTrue(Utils.FloatEq(aArr1[i], aArr2[i]));
end;

method UtilsTest.TestSetOfCharCreate;
begin
  var lSet := new SetOfChar;
  Assert.IsNotNil(lSet);
  Assert.AreEqual(lSet.Chars, '');

  lSet := new SetOfChar('AB');
  Assert.IsNotNil(lSet);
  Assert.AreEqual(lSet.Chars, 'AB');

  var lSet2 := new SetOfChar(lSet);
  Assert.IsNotNil(lSet2);
  Assert.AreEqual(lSet2.Chars, 'AB');

  lSet := new SetOfChar(['A', 'B']);
  Assert.IsNotNil(lSet);
  Assert.AreEqual(lSet.Chars, 'AB');
end;

method UtilsTest.TestSetOfCharInclude;
begin
  var lSet := new SetOfChar;
  Assert.IsNotNil(lSet);
  Assert.AreEqual(lSet.Chars, '');

  lSet.Include('A');
  Assert.AreEqual(lSet.Chars, 'A');

  lSet.Include('A');
  Assert.AreEqual(lSet.Chars, 'A');

  lSet.Include('B');
  Assert.AreEqual(lSet.Chars, 'AB');

  lSet.Include('A');
  Assert.AreEqual(lSet.Chars, 'AB');

  lSet.Include('B');
  Assert.AreEqual(lSet.Chars, 'AB');

  lSet.Include(lSet);
  Assert.AreEqual(lSet.Chars, 'AB');

  lSet.Include(['C', 'A', 'D']);
  Assert.AreEqual(lSet.Chars, 'ABCD');
end;

method UtilsTest.TestSetOfCharExclude;
begin
  var lSet := new SetOfChar;
  Assert.IsNotNil(lSet);
  Assert.AreEqual(lSet.Chars, '');

  lSet.Exclude('A');
  Assert.AreEqual(lSet.Chars, '');

  lSet := new SetOfChar('ABCD');
  lSet.Exclude('A');
  Assert.AreEqual(lSet.Chars, 'BCD');

  lSet.Exclude('A');
  Assert.AreEqual(lSet.Chars, 'BCD');

  lSet.Exclude('X');
  Assert.AreEqual(lSet.Chars, 'BCD');

  lSet.Exclude(['X', 'B', 'D']);
  Assert.AreEqual(lSet.Chars, 'C');

  lSet.Exclude(lSet);
  Assert.AreEqual(lSet.Chars, '');
end;

method UtilsTest.TestSetOfCharContains;
begin
  var lSet := new SetOfChar;
  Assert.IsNotNil(lSet);
  Assert.AreEqual(lSet.Chars, '');

  Assert.IsFalse(lSet.Contains('X'));

  lSet := new SetOfChar('ABCD');

  Assert.IsFalse(lSet.Contains('X'));
  Assert.IsTrue(lSet.Contains('A'));
  Assert.IsTrue(lSet.Contains('D'));
end;

method UtilsTest.TestSetOfIntCreate;
begin
  var lSet := new SetOfInt;
  CheckIntSet(lSet, []);

  lSet := new SetOfInt(3,5);
  CheckIntSet(lSet, [3, 4, 5]);

  lSet := new SetOfInt([3, 5]);
  CheckIntSet(lSet, [3, 5]);

  var lSet2 := new SetOfInt(lSet);
  CheckIntSet(lSet2, [3, 5]);
  Assert.IsTrue(lSet.Ints <> lSet2.Ints);
end;

method UtilsTest.TestSetOfIntInclude;
begin
  var lSet := new SetOfInt;
  CheckIntSet(lSet, []);

  lSet.Include(1);
  CheckIntSet(lSet, [1]);

  lSet.Include(1);
  CheckIntSet(lSet, [1]);

  lSet.Include(2);
  CheckIntSet(lSet, [1, 2]);

  lSet.Include(1);
  CheckIntSet(lSet, [1, 2]);

  lSet.Include([1, 3, 4, 2]);
  CheckIntSet(lSet, [1, 2, 3, 4]);

  lSet.Include(lSet);
  CheckIntSet(lSet, [1, 2, 3, 4]);
end;

method UtilsTest.TestSetOfIntExclude;
begin
  var lSet := new SetOfInt;
  CheckIntSet(lSet, []);

  lSet.Exclude([1]);
  CheckIntSet(lSet, []);

  lSet := new SetOfInt([1, 2, 3, 4]);
  lSet.Exclude(1);
  CheckIntSet(lSet, [2, 3, 4]);

  lSet.Exclude(1);
  CheckIntSet(lSet, [2, 3, 4]);

  lSet.Exclude(5);
  CheckIntSet(lSet, [2, 3, 4]);

  lSet.Exclude(4);
  CheckIntSet(lSet, [2, 3]);

  lSet := new SetOfInt([1, 2, 3, 4]);
  lSet.Exclude([1, 3]);
  CheckIntSet(lSet, [2, 4]);

  lSet.Exclude(lSet);
  CheckIntSet(lSet, []);
end;

method UtilsTest.TestSetOfIntContains;
begin
  var lSet := new SetOfInt;
  CheckIntSet(lSet, []);

  Assert.IsFalse(lSet.Contains(1));

  lSet := new SetOfInt([1, 2, 3, 4]);

  Assert.IsFalse(lSet.Contains(0));
  Assert.IsTrue(lSet.Contains(1));
  Assert.IsTrue(lSet.Contains(4));
end;

method UtilsTest.TestIntPair;
begin
  var lPair := new IntPair(1, 2);
  Assert.AreEqual(lPair.I1, 1);
  Assert.AreEqual(lPair.I2, 2);
end;

method UtilsTest.TestUtilsFloatEq;
begin
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0));
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0, 0.5));

  Assert.IsFalse(Utils.FloatEq(1.0, 2.0));
  Assert.IsFalse(Utils.FloatEq(1.0, 2.0, 0.5));

  Assert.IsFalse(Utils.FloatEq(1.0, 1.0 + Utils.FloatEpsilon));
  Assert.IsFalse(Utils.FloatEq(1.0, 1.0 + Utils.FloatEpsilon, Utils.FloatEpsilon));

  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 + Utils.FloatEpsilon/2));
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 + Utils.FloatEpsilon/2, Utils.FloatEpsilon));

  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 + Utils.FloatEpsilon - 1.0E-15));
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 + Utils.FloatEpsilon - 1.0E-15, Utils.FloatEpsilon));

  Assert.IsFalse(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon - 1.0E-15));
  Assert.IsFalse(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon - 1.0E-15, Utils.FloatEpsilon));

  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon));
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon, Utils.FloatEpsilon));

  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon/2));
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon/2, Utils.FloatEpsilon));

  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon + 1.0E-15));
  Assert.IsTrue(Utils.FloatEq(1.0, 1.0 - Utils.FloatEpsilon + 1.0E-15, Utils.FloatEpsilon));
end;

method UtilsTest.TestUtilsSwap;
begin
  var i := 1;
  var j := 2;
  Utils.SwapInt(var i, var j);
  Assert.AreEqual(i, 2);
  Assert.AreEqual(j, 1);

  var x := 1.0;
  var y := 2.0;
  Utils.SwapFlt(var x, var y);
  Assert.AreEqual(x, 2.0);
  Assert.AreEqual(y, 1.0);
end;

method UtilsTest.TestUtilsGCD;

  method CheckGCD(i, j, expect: Integer);
  begin
    var g := Utils.GCD(i, j);
    Assert.AreEqual(g, expect);
  end;

begin
  CheckGCD(5, 5, 5);
  CheckGCD(10, 5, 5);
  CheckGCD(5, 10, 5);
  CheckGCD(12, 9, 3);
  CheckGCD(9, 12, 3);
  CheckGCD(14, 49, 7);

  CheckGCD(-14, 49, 7);
  CheckGCD(0, 5, 0);
  CheckGCD(5, 0, 0);
  CheckGCD(0, 0, 0);
end;

method UtilsTest.TestPos0;

  method CheckPos0(const sub, s: String; expect: Integer);
  begin
    var act := Utils.Pos0(sub, s);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckPos0('a', 'abc', 0);
  CheckPos0('b', 'abc', 1);
  CheckPos0('c', 'abc', 2);
  CheckPos0('d', 'abc', -1);
  CheckPos0('ab', 'abc', 0);
  CheckPos0('bc', 'abc', 1);
  CheckPos0('ac', 'abc', -1);

  CheckPos0('', 'abc', -1);
  CheckPos0(nil, 'abc', -1);
  CheckPos0('a', '', -1);
  CheckPos0('ab', '', -1);
  CheckPos0('', '', -1);
  CheckPos0('a', nil, -1);
  CheckPos0('ab', nil, -1);
  CheckPos0('', nil, -1);
  CheckPos0(nil, nil, -1);
end;

method UtilsTest.TestCopyString;

  method CheckCopyString(s: String);
  begin
    var act := Utils.CopyString(s);
    Assert.AreEqual(act, s);
  end;

  method CheckCopyString(s: String; pos: Integer; expect: String);
  begin
    var act := Utils.CopyString(s, pos);
    Assert.AreEqual(act, expect);
  end;

  method CheckCopyFromTo(s: String; f, t: Integer; expect: String);
  begin
    var act := Utils.CopyFromTo(s, f, t);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckCopyString(nil);
  CheckCopyString('');
  CheckCopyString('a');
  CheckCopyString('ab');

  CheckCopyString(nil, 0, nil);
  CheckCopyString('', 0, '');
  CheckCopyString('a', 0, 'a');
  CheckCopyString('ab', 0, 'ab');

  CheckCopyString(nil, 1, nil);
  //throws CheckCopyString('', 1, '');
  CheckCopyString('a', 1, '');
  CheckCopyString('ab', 1, 'b');

  CheckCopyString(nil, 5, nil);
  //throws CheckCopyString('', 5, '');
  //throws CheckCopyString('a', 5, '');
  //throws CheckCopyString('ab', 5, '');

  CheckCopyString(nil, -5, nil);
  //throws CheckCopyString('', -5, '');

  CheckCopyFromTo(nil, 1, 2, nil);
  CheckCopyFromTo('', 0, -1, '');
  //throws CheckCopyFromTo('', 0, 0, '');
  //throws CheckCopyFromTo('', 1, 2, '');

  CheckCopyFromTo('a', 0, 0, 'a');
  CheckCopyFromTo('ab', 0, 0, 'a');
  CheckCopyFromTo('ab', 1, 1, 'b');
  CheckCopyFromTo('abc', 0, 1, 'ab');
  CheckCopyFromTo('abc', 1, 2, 'bc');

  CheckCopyFromTo('abc', 2, 1, '');
end;

method UtilsTest.TestStrEl;

  method CheckStrEl(const s: String; i: Integer; expect: Char);
  begin
    var act := Utils.StrEl(s, i);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckStrEl(nil, 0, #0);
  CheckStrEl(nil, 1, #0);
  CheckStrEl(nil, -1, #0);

  CheckStrEl('', 0, #0);
  CheckStrEl('', 1, #0);
  CheckStrEl('', -1, #0);

  CheckStrEl('a', 0, 'a');
  CheckStrEl('a', 1, #0);
  CheckStrEl('a', -1, #0);

  CheckStrEl('ab', 0, 'a');
  CheckStrEl('ab', 1, 'b');
  CheckStrEl('ab', 2, #0);
  CheckStrEl('ab', -1, #0);
end;

method UtilsTest.TestChStr;

  method CheckChStr(len: Integer; ch: Char; expect: String);
  begin
    var act := Utils.ChStr(len, ch);
    Assert.AreEqual(act, expect);
  end;

  method CheckChString(len: Integer; s: String; expect: String);
  begin
    var act := Utils.ChString(len, s);
    Assert.AreEqual(act, expect);
  end;

begin
  // throws CheckChStr(-1, ' ', '');
  CheckChStr(0, ' ', '');
  CheckChStr(1, ' ', ' ');
  CheckChStr(1, 'a', 'a');
  CheckChStr(2, 'a', 'aa');
  CheckChStr(5, 'a', 'aaaaa');

  CheckChString(-1, ' ', '');
  CheckChString(0, ' ', '');
  CheckChString(1, ' ', ' ');
  CheckChString(1, 'a', 'a');
  CheckChString(2, 'a', 'aa');
  CheckChString(5, 'a', 'aaaaa');
  CheckChString(5, '', '');
  CheckChString(5, nil, '');
  CheckChString(5, 'ab', 'ababababab');
end;

method UtilsTest.TestIdString;

  method CheckStr(inp, expect: String; rep: Char := '_');
  begin
    var act := Utils.IdString(inp, rep);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckStr('Name1', 'Name1');
  CheckStr('Name 1', 'Name_1');
  CheckStr('Name#1', 'Name_1');
  CheckStr('___', '___');
  CheckStr('@#$', '___');
  CheckStr('@ # $', '_____');
  CheckStr('a # z', 'a___z');
  CheckStr('a # z', 'a***z', '*');
end;


method UtilsTest.TestRestOf;

  method CheckRestOf(const s: String; pos: Integer; expect: String);
  begin
    var act := Utils.RestOf(s, pos);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckRestOf('', 0, '');
  CheckRestOf('', 1, '');

  CheckRestOf(nil, 0, '');
  CheckRestOf(nil, 1, '');

  CheckRestOf('a', 0, 'a');
  CheckRestOf('a', 1, '');

  CheckRestOf('abc', 0, 'abc');
  CheckRestOf('abc', 1, 'bc');
  CheckRestOf('abc', 2, 'c');
  CheckRestOf('abc', 3, '');
  CheckRestOf('abc', 4, '');
  CheckRestOf('abc', -1, 'abc');
end;

method UtilsTest.TestLeftOf;

  method CheckLeftOf(const s, sub: String; expect: String);
  begin
    var act := Utils.LeftOf(s, sub);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckLeftOf('', '', '');
  CheckLeftOf('', 'a', '');

  CheckLeftOf('a', 'a', '');
  CheckLeftOf('abc', 'a', '');
  CheckLeftOf('abc', 'b', 'a');
  CheckLeftOf('abc', 'c', 'ab');
  CheckLeftOf('abc', 'd', 'abc');

  CheckLeftOf('ab==cd', '=', 'ab');
  CheckLeftOf('ab==cd', '==', 'ab');
  CheckLeftOf('ab==cd', '=c', 'ab=');
  CheckLeftOf('abc', 'a', '');
  CheckLeftOf('abc', 'b', 'a');
  CheckLeftOf('abc', 'c', 'ab');
  CheckLeftOf('abc', 'd', 'abc');
end;

method UtilsTest.TestRightOf;

  method CheckRightOf(const s, sub: String; expect: String);
  begin
    var act := Utils.RightOf(s, sub);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckRightOf('', '', '');
  CheckRightOf('', 'a', '');

  CheckRightOf('a', 'a', '');
  CheckRightOf('abc', 'a', 'bc');
  CheckRightOf('abc', 'b', 'c');
  CheckRightOf('abc', 'c', '');
  CheckRightOf('abc', 'd', 'abc');

  CheckRightOf('ab==cd', '=', '=cd');
  CheckRightOf('ab==cd', '==', 'cd');
  CheckRightOf('ab==cd', '=c', 'd');
  CheckRightOf('abc', 'a', 'bc');
  CheckRightOf('abc', 'b', 'c');
  CheckRightOf('abc', 'c', '');
  CheckRightOf('abc', 'd', 'abc');
end;

method UtilsTest.TestReplaceStr;

  method CheckReplaceStr(const s, f, t: String; expect: String);
  begin
    var act := Utils.ReplaceStr(s, f, t);
    Assert.AreEqual(act, expect);
  end;

begin
  // throws CheckReplaceStr('', '', '', '');
  CheckReplaceStr('', 'a', 'b', '');
  CheckReplaceStr('a', 'a', 'b', 'b');
  CheckReplaceStr('aa', 'a', 'b', 'bb');
  CheckReplaceStr('aca', 'a', 'b', 'bcb');
  CheckReplaceStr('caa', 'a', 'b', 'cbb');
  CheckReplaceStr('aac', 'a', 'b', 'bbc');
  CheckReplaceStr('aacaac', 'a', 'b', 'bbcbbc');
  CheckReplaceStr('aacaac', 'ca', '-', 'aa-ac');
  CheckReplaceStr('aacaac', 'aa', '-', '-c-c');
  CheckReplaceStr('aaaa', 'aa', 'b', 'bb');
  CheckReplaceStr('aaaaa', 'aa', 'b', 'bba');
end;

method UtilsTest.TestNextElem;
begin
  var s := '';
  var e := Utils.NextElem(var s);
  Assert.AreEqual(e, '');
  Assert.AreEqual(s, '');

  s := 'a';
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, 'a');
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, '');
  Assert.AreEqual(s, '');

  s := 'a bb ccc  ddd';
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, 'a');
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, 'bb');
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, 'ccc');
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, '');
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, 'ddd');
  e := Utils.NextElem(var s);
  Assert.AreEqual(e, '');
  Assert.AreEqual(s, '');

  s := 'a;bb;ccc;;ddd';
  e := Utils.NextElem(var s, ';');
  Assert.AreEqual(e, 'a');
  e := Utils.NextElem(var s, ';');
  Assert.AreEqual(e, 'bb');
  e := Utils.NextElem(var s, ';');
  Assert.AreEqual(e, 'ccc');
  e := Utils.NextElem(var s, ';');
  Assert.AreEqual(e, '');
  e := Utils.NextElem(var s, ';');
  Assert.AreEqual(e, 'ddd');
  e := Utils.NextElem(var s, ';');
  Assert.AreEqual(e, '');
  Assert.AreEqual(s, '');

  s := 'a;-bb;-ccc;-;-ddd';
  e := Utils.NextElem(var s, ';-');
  Assert.AreEqual(e, 'a');
  e := Utils.NextElem(var s, ';-');
  Assert.AreEqual(e, 'bb');
  e := Utils.NextElem(var s, ';-');
  Assert.AreEqual(e, 'ccc');
  e := Utils.NextElem(var s, ';-');
  Assert.AreEqual(e, '');
  e := Utils.NextElem(var s, ';-');
  Assert.AreEqual(e, 'ddd');
  e := Utils.NextElem(var s, ';-');
  Assert.AreEqual(e, '');
  Assert.AreEqual(s, '');
end;

method UtilsTest.TestListContains;
begin
  var list := new List<String>(['Name 1', 'Name2']);

  Assert.IsTrue(Utils.ListContains(list, 'Name 1'));
  Assert.IsTrue(Utils.ListContains(list, 'Name2'));
  Assert.IsFalse(Utils.ListContains(list, 'Name3'));
  Assert.IsFalse(Utils.ListContains(list, 'NAME 1'));
  Assert.IsFalse(Utils.ListContains(list, 'NAME2'));

  Assert.IsTrue(Utils.ListContains(list, 'Name 1', false));
  Assert.IsTrue(Utils.ListContains(list, 'Name2', false));
  Assert.IsFalse(Utils.ListContains(list, 'Name3', false));
  Assert.IsTrue(Utils.ListContains(list, 'NAME 1', false));
  Assert.IsTrue(Utils.ListContains(list, 'NAME2', false));
  Assert.IsTrue(Utils.ListContains(list, 'NaMe2', false));
end;

method UtilsTest.TestListOrder;

  method CheckOrder(aList, aRef: array of Object; aExpected: IntArray);
  begin
    var lList :=
      if aList = nil then nil 
      else new List<Object>(aList);
    var lRef :=
      if aRef = nil then nil
      else new List<Object>(aRef);
    var lOrder := Utils.ListOrder(lList, lRef);
    Assert.IsTrue(Utils.IntArrayEq(lOrder, aExpected));
  end;

begin
  var x1 := new Object;
  var x2 := new Object;
  var x3 := new Object;
  CheckOrder(nil, nil, nil);
  CheckOrder([], nil, nil);
  CheckOrder(nil, [], nil);
  CheckOrder([], [], nil);
  CheckOrder([x1], [x1], nil);
  CheckOrder([x1], [x2], [-1]);
  CheckOrder([x1, x2, x3], [x1, x2, x3], nil);
  CheckOrder([x1, x2, x3], [x3, x2, x1], [2, 1, 0]);
  CheckOrder([x1, x2, x3], [x2, x1], [1, 0, -1]);
end;

method UtilsTest.TestOrderList;

  method CheckOrder(aList: array of Object; aOrder: IntArray; aExpected: array of Object; aAppendRest: Boolean);
  begin
    var lList :=
      if aList = nil then nil 
      else new List<Object>(aList);
    var lExpected :=
      if aExpected = nil then nil
      else new List<Object>(aExpected);
    var lOrdered := Utils.OrderList(lList, aOrder, aAppendRest);
    Assert.IsTrue(Utils.EqualLists<Object>(lOrdered, lExpected));
  end;

begin
  var x1 := new Object;
  var x2 := new Object;
  var x3 := new Object;
  CheckOrder(nil, nil, nil, false);
  CheckOrder(nil, [], nil, false);
  CheckOrder([], nil, [], false);
  CheckOrder([], [], [], false);
  CheckOrder(nil, nil, nil, true);
  CheckOrder(nil, [], nil, true);
  CheckOrder([], nil, [], true);
  CheckOrder([], [], [], true);

  CheckOrder([x1], [0], [x1], false);
  CheckOrder([x1], [0], [x1], true);

  CheckOrder([x1], [-1], [], false);
  CheckOrder([x1], [-1], [x1], true);

  CheckOrder([x1], [1], [], false);
  CheckOrder([x1], [1], [x1], true);

  CheckOrder([x1, x2, x3], nil, [x1, x2, x3], false);
  CheckOrder([x1, x2, x3], nil, [x1, x2, x3], true);

  CheckOrder([x1, x2, x3], [1], [x2], false);
  CheckOrder([x1, x2, x3], [1], [x2, x1, x3], true);

  CheckOrder([x1, x2, x3], [1, 5], [x2], false);
  CheckOrder([x1, x2, x3], [1, 5], [x2, x1, x3], true);
  
  CheckOrder([x1, x2, x3], [2, 1, 0], [x3, x2, x1], false);
  CheckOrder([x1, x2, x3], [2, 1, 0], [x3, x2, x1], true);

  CheckOrder([x1, x2, x3], [2, 1], [x3, x2], false);
  CheckOrder([x1, x2, x3], [2, 1, 0], [x3, x2, x1], true);
 
  CheckOrder([x1, x2, x3], [2, 1, 1], [x3, x2, x2], false);
  CheckOrder([x1, x2, x3], [2, 1, 1], [x3, x2, x2, x1], true);
end;

method UtilsTest.TestBreakToLines;
begin
  Assert.IsNil(Utils.BreakToLines(nil));
  var s := 'a '#11'b'#12' c'#10'd'#13'e'#13#10'f'#$0085#$2028#$2020'z';
  var l := Utils.BreakToLines(s).ToList<String>;
  var c := new List<String>(['a ', 'b', ' c', 'd', 'e', 'f', '', '', 'z']);
  Assert.IsTrue(Utils.EqualLists(l, c));
end;

method UtilsTest.TestBreakToWords;
begin
  Assert.IsNil(Utils.BreakToWords(nil));
  var s := 'this is a  statement'#13#10'in'#13'three text'#10'lines';
  var l := Utils.BreakToWords(s).ToList<String>;
  var c := new List<String>(['this', 'is', 'a', '', 'statement', 'in', 'three', 'text', 'lines']);
  Assert.IsTrue(Utils.EqualLists(l, c));
end;

method UtilsTest.TestNewIntArray;
begin
  var a := Utils.NewIntArray(0);
  CheckIntArray(a, []);

  a := Utils.NewIntArray(1);
  CheckIntArray(a, [0]);

  a := Utils.NewIntArray(2, 1);
  CheckIntArray(a, [1, 1]);
end;

method UtilsTest.TestCopyIntArray;
begin
  var a := Utils.CopyIntArray(nil);
  Assert.IsNil(a);

  a := Utils.CopyIntArray([]);
  CheckIntArray(a, []);

  a := Utils.CopyIntArray([3]);
  CheckIntArray(a, [3]);

  a := Utils.CopyIntArray([3, 4]);
  CheckIntArray(a, [3, 4]);

  a := Utils.CopyIntArray([1], 0, 0);
  CheckIntArray(a, []);

  a := Utils.CopyIntArray([1], 0, 1);
  CheckIntArray(a, [1]);

  a := Utils.CopyIntArray([], 1, 2);
  CheckIntArray(a, [0, 0]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 0, 1);
  CheckIntArray(a, [1]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 0, 2);
  CheckIntArray(a, [1, 2]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 0, 3);
  CheckIntArray(a, [1, 2, 3]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 0, 4);
  CheckIntArray(a, [1, 2, 3, 4]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 1, 1);
  CheckIntArray(a, [2]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 1, 2);
  CheckIntArray(a, [2, 3]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 1, 3);
  CheckIntArray(a, [2, 3, 4]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 1, 4);
  CheckIntArray(a, [2, 3, 4, 0]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 2, 2);
  CheckIntArray(a, [3, 4]);

  a := Utils.CopyIntArray([1, 2, 3, 4], 3, 1);
  CheckIntArray(a, [4]);

end;

method UtilsTest.TestIntArrayIndex;

  method CheckIndex(const aArr: IntArray; aInt: Integer; expect: Integer);
  begin
    var act := Utils.IntArrayIndex(aArr, aInt);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckIndex(nil, 1, -1);
  CheckIndex([], 1, -1);
  CheckIndex([0], 1, -1);
  CheckIndex([1], 1, 0);
  CheckIndex([1, 2, 3, 4], 1, 0);
  CheckIndex([1, 2, 3, 4], 2, 1);
  CheckIndex([1, 2, 3, 4], 4, 3);
  CheckIndex([1, 2, 3, 4], 5, -1);
end;

method UtilsTest.TestIntArrayEq;

  method CheckArrayEq(aArr1, aArr2: IntArray; expect: Boolean);
  begin
    var act := Utils.IntArrayEq(aArr1, aArr2);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckArrayEq(nil, nil, true);
  CheckArrayEq(nil, [], true);
  CheckArrayEq([], nil, true);

  CheckArrayEq([1], nil, false);
  CheckArrayEq([1], [], false);
  CheckArrayEq([1], [2], false);
  CheckArrayEq([1], [1], true);

  CheckArrayEq([1, 2], nil, false);
  CheckArrayEq([1, 2], [], false);
  CheckArrayEq([1, 2], [2], false);
  CheckArrayEq([1, 2], [1, 2], true);
  CheckArrayEq([1, 2], [1, 2, 3], false);
end;

method UtilsTest.TestConcatenateIntArrays;

  method CheckConcatenate(aArr1, aArr2, expect: IntArray);
  begin
    var act := Utils.ConcatenateIntArrays(aArr1, aArr2);
    CheckIntArray(act, expect);
  end;

begin
  CheckConcatenate(nil, nil, []);
  CheckConcatenate(nil, [], []);
  CheckConcatenate([], nil, []);
  CheckConcatenate([], [], []);

  CheckConcatenate([1], nil, [1]);
  CheckConcatenate([1], [], [1]);
  CheckConcatenate(nil, [1], [1]);
  CheckConcatenate([], [1], [1]);

  CheckConcatenate([1], [2], [1, 2]);
  CheckConcatenate([1, 2], [3], [1, 2, 3]);
  CheckConcatenate([1], [2, 3], [1, 2, 3]);
  CheckConcatenate([1, 2], [3, 5], [1, 2, 3, 5]);
end;

method UtilsTest.TestIntArrayInsert;

  method CheckInsert(aArr: IntArray; aIdx: Integer; expect: IntArray);
  begin
    var act := Utils.IntArrayInsert(aArr, aIdx, -1);
    CheckIntArray(act, expect);
  end;

begin
  CheckInsert(nil, 0, [-1]);
  CheckInsert(nil, 1, [-1]);
  CheckInsert(nil, -1, [-1]);

  CheckInsert([], 0, [-1]);
  CheckInsert([], 1, [-1]);
  CheckInsert([], -1, [-1]);

  CheckInsert([1], 0, [-1, 1]);
  CheckInsert([1], 1, [1, -1]);
  CheckInsert([1], 2, [1, -1]);
  CheckInsert([1], -1, [-1, 1]);

  CheckInsert([1, 2], 0, [-1, 1, 2]);
  CheckInsert([1, 2], 1, [1, -1, 2]);
  CheckInsert([1, 2], 2, [1, 2, -1]);
  CheckInsert([1, 2], 3, [1, 2, -1]);
  CheckInsert([1, 2], -1, [-1, 1, 2]);
end;

method UtilsTest.TestIntArrayDelete;

  method CheckDelete(aArr: IntArray; aIdx: Integer; expect: IntArray);
  begin
    var act := Utils.IntArrayDelete(aArr, aIdx);
    CheckIntArray(act, expect);
  end;

begin
  CheckDelete(nil, 0, []);
  CheckDelete(nil, 1, []);
  CheckDelete(nil, -1, []);

  CheckDelete([], 0, []);
  CheckDelete([], 1, []);
  CheckDelete([], -1, []);

  CheckDelete([1], 0, []);
  CheckDelete([1], 1, [1]);
  CheckDelete([1], 2, [1]);
  CheckDelete([1], -1, [1]);

  CheckDelete([1, 2], 0, [2]);
  CheckDelete([1, 2], 1, [1]);
  CheckDelete([1, 2], 2, [1, 2]);
  CheckDelete([1, 2], 3, [1, 2]);
  CheckDelete([1, 2], -1, [1, 2]);

  CheckDelete([1, 2, 3], 0, [2, 3]);
  CheckDelete([1, 2, 3], 1, [1, 3]);
  CheckDelete([1, 2, 3], 2, [1, 2]);
  CheckDelete([1, 2, 3], 3, [1, 2, 3]);
  CheckDelete([1, 2, 3], -1, [1, 2, 3]);
end;

method UtilsTest.TestIntArrayMove;

  method CheckMove(aArr: IntArray; aF, aT: Integer; expect: IntArray);
  begin
    var act := Utils.IntArrayMove(aArr, aF, aT);
    CheckIntArray(act, expect);
  end;

begin
  CheckMove(nil, 0, 2, []);
  CheckMove(nil, 0, 1, []);
  CheckMove(nil, -1, 2, []);

  CheckMove([], 0, 0, []);
  CheckMove([], 1, 1, []);
  CheckMove([], -1, 2, []);

  CheckMove([1], 0, 1, [1]);
  CheckMove([1], 1, 0, [1]);

  CheckMove([1, 2, 3], 0, 0, [1, 2, 3]);
  CheckMove([1, 2, 3], 0, 1, [2, 1, 3]);
  CheckMove([1, 2, 3], 0, 2, [2, 3, 1]);
  CheckMove([1, 2, 3], 0, 3, [1, 2, 3]);

  CheckMove([1, 2, 3], 1, 0, [2, 1, 3]);
  CheckMove([1, 2, 3], 1, 1, [1, 2, 3]);
  CheckMove([1, 2, 3], 1, 2, [1, 3, 2]);
  CheckMove([1, 2, 3], 1, 3, [1, 2, 3]);

  CheckMove([1, 2, 3], 2, 0, [3, 1, 2]);
  CheckMove([1, 2, 3], 2, 1, [1, 3, 2]);
  CheckMove([1, 2, 3], 2, 2, [1, 2, 3]);
  CheckMove([1, 2, 3], 2, 3, [1, 2, 3]);
end;

method UtilsTest.TestIntArrayExchange;

  method CheckExchange(aArr: IntArray; aF, aT: Integer; expect: IntArray);
  begin
    var lArr := Utils.CopyIntArray(aArr);
    Utils.IntArrayExchange(var lArr, aF, aT);
    CheckIntArray(lArr, expect);
  end;

begin
  CheckExchange([1], 0, 0, [1]);
  CheckExchange([1, 2], 0, 1, [2, 1]);
  CheckExchange([1, 2, 3], 0, 1, [2, 1, 3]);
  CheckExchange([1, 2, 3], 1, 2, [1, 3, 2]);
  CheckExchange([1, 2, 3], 0, 2, [3, 2, 1]);
end;

method UtilsTest.TestIntArraySubset;

  method CheckSubset(aArray, aExpected: IntArray);
  begin
    if (aArray = nil) and (aExpected = nil) then
      exit;
    Assert.IsTrue(Utils.IntArrayEq(aArray, aExpected));
  end;

begin
  var lArray: IntArray := nil;
  var lPredicate := Utils.IntArraySubset(lArray, (x) -> (x mod 2 = 1));
  CheckSubset(lPredicate, nil);
  var lIndices := Utils.IntArraySubset(lArray, IntArray([]));
  CheckSubset(lIndices, nil);
  var lSelect := Utils.IntArraySubset(lArray, BoolArray([]));
  CheckSubset(lSelect, nil);

  lArray := [];
  lPredicate := Utils.IntArraySubset(lArray, (x) -> (x mod 2 = 1));
  CheckSubset(lPredicate, []);
  lIndices := Utils.IntArraySubset(lArray, IntArray([]));
  CheckSubset(lIndices, []);
  lSelect := Utils.IntArraySubset(lArray, BoolArray([]));
  CheckSubset(lSelect, []);

  lArray := [1, 2, 3, 4];
  lPredicate := Utils.IntArraySubset(lArray, (x) -> (x mod 2 = 1));
  CheckSubset(lPredicate, [2, 4]);
  lPredicate := Utils.IntArraySubset(lArray, (x) -> (x = 3));
  CheckSubset(lPredicate, [4]);
  lPredicate := Utils.IntArraySubset(lArray, (x) -> (x > 5));
  CheckSubset(lPredicate, []);

  lIndices := Utils.IntArraySubset(lArray, IntArray([]));
  CheckSubset(lIndices, []);
  lIndices := Utils.IntArraySubset(lArray, [1, 3]);
  CheckSubset(lIndices, [2, 4]);

  lSelect := Utils.IntArraySubset(lArray, BoolArray([]));
  CheckSubset(lSelect, []);
  lSelect := Utils.IntArraySubset(lArray, [false, true, true, false]);
  CheckSubset(lSelect, [2, 3]);
end;

method UtilsTest.TestNewFltArray;
begin
  var a := Utils.NewFltArray(0);
  CheckFltArray(a, []);

  a := Utils.NewFltArray(1);
  CheckFltArray(a, [0.0]);

  a := Utils.NewFltArray(2, 1);
  CheckFltArray(a, [1.0, 1.0]);
end;

method UtilsTest.TestCopyFltArray;
begin
  var a := Utils.CopyFltArray(nil);
  Assert.IsNil(a);

  a := Utils.CopyFltArray([]);
  CheckFltArray(a, []);

  a := Utils.CopyFltArray([3]);
  CheckFltArray(a, [3]);

  a := Utils.CopyFltArray([3, 4]);
  CheckFltArray(a, [3, 4]);

  a := Utils.CopyFltArray([1], 0, 0);
  CheckFltArray(a, []);

  a := Utils.CopyFltArray([1], 0, 1);
  CheckFltArray(a, [1]);

  a := Utils.CopyFltArray([], 1, 2);
  CheckFltArray(a, [0, 0]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 0, 1);
  CheckFltArray(a, [1]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 0, 2);
  CheckFltArray(a, [1, 2]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 0, 3);
  CheckFltArray(a, [1, 2, 3]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 0, 4);
  CheckFltArray(a, [1, 2, 3, 4]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 1, 1);
  CheckFltArray(a, [2]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 1, 2);
  CheckFltArray(a, [2, 3]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 1, 3);
  CheckFltArray(a, [2, 3, 4]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 1, 4);
  CheckFltArray(a, [2, 3, 4, 0]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 2, 2);
  CheckFltArray(a, [3, 4]);

  a := Utils.CopyFltArray([1, 2, 3, 4], 3, 1);
  CheckFltArray(a, [4]);

end;

method UtilsTest.TestFltArrayEq;

  method CheckArrayEq(aArr1, aArr2: FltArray; expect: Boolean);
  begin
    var act := Utils.FltArrayEq(aArr1, aArr2);
    Assert.AreEqual(act, expect);
  end;

begin
  CheckArrayEq(nil, nil, true);
  CheckArrayEq(nil, [], true);
  CheckArrayEq([], nil, true);

  CheckArrayEq([1], nil, false);
  CheckArrayEq([1], [], false);
  CheckArrayEq([1], [2], false);
  CheckArrayEq([1], [1], true);

  CheckArrayEq([1, 2], nil, false);
  CheckArrayEq([1, 2], [], false);
  CheckArrayEq([1, 2], [2], false);
  CheckArrayEq([1, 2], [1, 2], true);
  CheckArrayEq([1, 2], [1, 2, 3], false);
end;

method UtilsTest.TestConcatenateFltArrays;

  method CheckConcatenate(aArr1, aArr2, expect: FltArray);
  begin
    var act := Utils.ConcatenateFltArrays(aArr1, aArr2);
    CheckFltArray(act, expect);
  end;

begin
  CheckConcatenate(nil, nil, []);
  CheckConcatenate(nil, [], []);
  CheckConcatenate([], nil, []);
  CheckConcatenate([], [], []);

  CheckConcatenate([1], nil, [1]);
  CheckConcatenate([1], [], [1]);
  CheckConcatenate(nil, [1], [1]);
  CheckConcatenate([], [1], [1]);

  CheckConcatenate([1], [2], [1, 2]);
  CheckConcatenate([1, 2], [3], [1, 2, 3]);
  CheckConcatenate([1], [2, 3], [1, 2, 3]);
  CheckConcatenate([1, 2], [3, 5], [1, 2, 3, 5]);
end;

method UtilsTest.TestFltArrayInsert;

  method CheckInsert(aArr: FltArray; aIdx: Integer; expect: FltArray);
  begin
    var act := Utils.FltArrayInsert(aArr, aIdx, -1);
    CheckFltArray(act, expect);
  end;

begin
  CheckInsert(nil, 0, [-1]);
  CheckInsert(nil, 1, [-1]);
  CheckInsert(nil, -1, [-1]);

  CheckInsert([], 0, [-1]);
  CheckInsert([], 1, [-1]);
  CheckInsert([], -1, [-1]);

  CheckInsert([1], 0, [-1, 1]);
  CheckInsert([1], 1, [1, -1]);
  CheckInsert([1], 2, [1, -1]);
  CheckInsert([1], -1, [-1, 1]);

  CheckInsert([1, 2], 0, [-1, 1, 2]);
  CheckInsert([1, 2], 1, [1, -1, 2]);
  CheckInsert([1, 2], 2, [1, 2, -1]);
  CheckInsert([1, 2], 3, [1, 2, -1]);
  CheckInsert([1, 2], -1, [-1, 1, 2]);
end;

method UtilsTest.TestFltArrayDelete;

  method CheckDelete(aArr: FltArray; aIdx: Integer; expect: FltArray);
  begin
    var act := Utils.FltArrayDelete(aArr, aIdx);
    CheckFltArray(act, expect);
  end;

begin
  CheckDelete(nil, 0, []);
  CheckDelete(nil, 1, []);
  CheckDelete(nil, -1, []);

  CheckDelete([], 0, []);
  CheckDelete([], 1, []);
  CheckDelete([], -1, []);

  CheckDelete([1], 0, []);
  CheckDelete([1], 1, [1]);
  CheckDelete([1], 2, [1]);
  CheckDelete([1], -1, [1]);

  CheckDelete([1, 2], 0, [2]);
  CheckDelete([1, 2], 1, [1]);
  CheckDelete([1, 2], 2, [1, 2]);
  CheckDelete([1, 2], 3, [1, 2]);
  CheckDelete([1, 2], -1, [1, 2]);

  CheckDelete([1, 2, 3], 0, [2, 3]);
  CheckDelete([1, 2, 3], 1, [1, 3]);
  CheckDelete([1, 2, 3], 2, [1, 2]);
  CheckDelete([1, 2, 3], 3, [1, 2, 3]);
  CheckDelete([1, 2, 3], -1, [1, 2, 3]);
end;

method UtilsTest.TestFltArrayMove;

  method CheckMove(aArr: FltArray; aF, aT: Integer; expect: FltArray);
  begin
    var act := Utils.FltArrayMove(aArr, aF, aT);
    CheckFltArray(act, expect);
  end;

begin
  CheckMove(nil, 0, 2, []);
  CheckMove(nil, 0, 1, []);
  CheckMove(nil, -1, 2, []);

  CheckMove([], 0, 0, []);
  CheckMove([], 1, 1, []);
  CheckMove([], -1, 2, []);

  CheckMove([1], 0, 1, [1]);
  CheckMove([1], 1, 0, [1]);

  CheckMove([1, 2, 3], 0, 0, [1, 2, 3]);
  CheckMove([1, 2, 3], 0, 1, [2, 1, 3]);
  CheckMove([1, 2, 3], 0, 2, [2, 3, 1]);
  CheckMove([1, 2, 3], 0, 3, [1, 2, 3]);

  CheckMove([1, 2, 3], 1, 0, [2, 1, 3]);
  CheckMove([1, 2, 3], 1, 1, [1, 2, 3]);
  CheckMove([1, 2, 3], 1, 2, [1, 3, 2]);
  CheckMove([1, 2, 3], 1, 3, [1, 2, 3]);

  CheckMove([1, 2, 3], 2, 0, [3, 1, 2]);
  CheckMove([1, 2, 3], 2, 1, [1, 3, 2]);
  CheckMove([1, 2, 3], 2, 2, [1, 2, 3]);
  CheckMove([1, 2, 3], 2, 3, [1, 2, 3]);
end;

method UtilsTest.TestConversions;
begin
  // IntToStr
  Assert.AreEqual(Utils.IntToStr(0), '0');
  Assert.AreEqual(Utils.IntToStr(10), '10');
  Assert.AreEqual(Utils.IntToStr(-1), '-1');

  // StrToInt
  // throws Assert.AreEqual(Utils.StrToInt(''), 0);
  // throws Assert.AreEqual(Utils.StrToInt('a'), 0);
  Assert.AreEqual(Utils.StrToInt('0'), 0);
  Assert.AreEqual(Utils.StrToInt('010'), 10);
  Assert.AreEqual(Utils.StrToInt('-1'), -1);
  Assert.AreEqual(Utils.StrToInt('-0001'), -1);

  // FloatToStr
  Assert.AreEqual(Utils.FloatToStr(0.0), '0');
  Assert.AreEqual(Utils.FloatToStr(1.0), '1');
  Assert.AreEqual(Utils.FloatToStr(-1.0), '-1');
  Assert.AreEqual(Utils.FloatToStr(-1.1), '-1,1');

  // FltToStr
  Assert.AreEqual(Utils.FltToStr(0.0), '0');
  Assert.AreEqual(Utils.FltToStr(1.0), '1');
  Assert.AreEqual(Utils.FltToStr(-1.0), '-1');
  Assert.AreEqual(Utils.FltToStr(-1.1), '-1.1');
  Assert.AreEqual(Utils.FltToStr(-1.1, false), '-1,1');

  // StrToFloat
  Assert.AreEqual(Utils.StrToFloat('0'), 0.0);
  Assert.AreEqual(Utils.StrToFloat('0.0'), 0.0);
  Assert.AreEqual(Utils.StrToFloat('020'), 20.0);
  Assert.AreEqual(Utils.StrToFloat('-1'), -1.0);
  Assert.AreEqual(Utils.StrToFloat('-1,1'), -1.1);
  Assert.AreEqual(Utils.StrToFloat('-1,1E-2'), -1.1E-2);

  // StrToFlt
  Assert.AreEqual(Utils.StrToFlt('0'), 0.0);
  Assert.AreEqual(Utils.StrToFlt('0.0'), 0.0);
  Assert.AreEqual(Utils.StrToFlt('020'), 20.0);
  Assert.AreEqual(Utils.StrToFlt('-1'), -1.0);
  Assert.AreEqual(Utils.StrToFlt('-1.1'), -1.1);
  Assert.AreEqual(Utils.StrToFlt('-1.1E-2'), -1.1E-2);

  // BooleanToStr
  Assert.AreEqual(Utils.BooleanToStr(true), 'True');
  Assert.AreEqual(Utils.BooleanToStr(false), 'False');

  // StrToBoolean
  Assert.AreEqual(Utils.StrToBoolean('false'), false);
  Assert.AreEqual(Utils.StrToBoolean('true'), true);
  Assert.AreEqual(Utils.StrToBoolean('False'), false);
  Assert.AreEqual(Utils.StrToBoolean('TRuE'), true);
  Assert.AreEqual(Utils.StrToBoolean('f'), false);
  Assert.AreEqual(Utils.StrToBoolean('t'), true);
  Assert.AreEqual(Utils.StrToBoolean('0'), false);
  Assert.AreEqual(Utils.StrToBoolean('1'), true);
  Assert.AreEqual(Utils.StrToBoolean('no'), false);
  Assert.AreEqual(Utils.StrToBoolean('yes'), true);

  // CharsToString
  // throws Assert.AreEqual(Utils.CharsToString(nil), '');
  Assert.AreEqual(Utils.CharsToString([]), '');
  Assert.AreEqual(Utils.CharsToString(['a', 'b']), 'ab');

  // StrToLines
  var lines := Utils.StrToLines(nil);
  Assert.IsNotNil(lines);
  Assert.AreEqual(lines.Count, 1);
  Assert.AreEqual(lines[0], '');

  lines := Utils.StrToLines('');
  Assert.IsNotNil(lines);
  Assert.AreEqual(lines.Count, 1);
  Assert.AreEqual(lines[0], '');

  lines := Utils.StrToLines('aa');
  Assert.IsNotNil(lines);
  Assert.AreEqual(lines.Count, 1);
  Assert.AreEqual(lines[0], 'aa');

  lines := Utils.StrToLines('aa' + Environment.LineBreak + 'bb');
  Assert.IsNotNil(lines);
  Assert.AreEqual(lines.Count, 2);
  Assert.AreEqual(lines[0], 'aa');
  Assert.AreEqual(lines[1], 'bb');

  // ExchangeList
  var list := new List<String>;
  list.Add('aa');
  Utils.ExchangeList(list, 0, 0);
  Assert.AreEqual(list[0], 'aa');

  list.Add('bb');
  Utils.ExchangeList(list, 0, 1);
  Assert.AreEqual(list[0], 'bb');
  Assert.AreEqual(list[1], 'aa');

  // IntArrayToStr
  Assert.AreEqual(Utils.IntArrayToStr(nil), '');
  Assert.AreEqual(Utils.IntArrayToStr([]), '');
  Assert.AreEqual(Utils.IntArrayToStr([1]), '1');
  Assert.AreEqual(Utils.IntArrayToStr([1, 2]), '1;2');
  Assert.AreEqual(Utils.IntArrayToStr([-1, -2]), '-1;-2');

  // StrToIntArray
  CheckIntArray(Utils.StrToIntArray(nil), []);
  CheckIntArray(Utils.StrToIntArray(''), []);
  CheckIntArray(Utils.StrToIntArray('1'), [1]);
  CheckIntArray(Utils.StrToIntArray('-1'), [-1]);
  CheckIntArray(Utils.StrToIntArray('1;2'), [1, 2]);

  // FltArrayToStr
  Assert.AreEqual(Utils.FltArrayToStr(nil), '');
  Assert.AreEqual(Utils.FltArrayToStr([]), '');
  Assert.AreEqual(Utils.FltArrayToStr([1]), '1');
  Assert.AreEqual(Utils.FltArrayToStr([1, 2]), '1;2');
  Assert.AreEqual(Utils.FltArrayToStr([-1, -2]), '-1;-2');
  Assert.AreEqual(Utils.FltArrayToStr([-1.1, -2.2]), '-1.1;-2.2');

  Assert.AreEqual(Utils.FltArrayToStr([-1.1, -2.2], false), '-1,1;-2,2');

  Assert.AreEqual(Utils.FltArrayToStr(nil, 2), '');
  Assert.AreEqual(Utils.FltArrayToStr([], 2), '');
  Assert.AreEqual(Utils.FltArrayToStr([1], 2), '1.00');
  Assert.AreEqual(Utils.FltArrayToStr([1, 2], 2), '1.00;2.00');
  Assert.AreEqual(Utils.FltArrayToStr([-1, -2], 2), '-1.00;-2.00');
  Assert.AreEqual(Utils.FltArrayToStr([-1.1, -2.2], 2), '-1.10;-2.20');

  // StrToFltArray
  CheckFltArray(Utils.StrToFltArray(nil), []);
  CheckFltArray(Utils.StrToFltArray(''), []);
  CheckFltArray(Utils.StrToFltArray('1'), [1]);
  CheckFltArray(Utils.StrToFltArray('-1'), [-1]);
  CheckFltArray(Utils.StrToFltArray('1;2'), [1, 2]);
  CheckFltArray(Utils.StrToFltArray('1.1;2.2'), [1.1, 2.2]);
  CheckFltArray(Utils.StrToFltArray('1,1;2,2', false), [1.1, 2.2]);
end;

method UtilsTest.TestCompareInt;
begin
  Assert.AreEqual(Utils.Compare(0, 0), 0);
  Assert.AreEqual(Utils.Compare(1, 0), 1);
  Assert.AreEqual(Utils.Compare(0, 1), -1);
end;

method UtilsTest.TestCompareFlt;
begin
  Assert.AreEqual(Utils.Compare(0.0, 0.0), 0);
  Assert.AreEqual(Utils.Compare(1.0, 0.0), 1);
  Assert.AreEqual(Utils.Compare(0.0, 1.0), -1);
end;

method UtilsTest.TestCompareIntArray;
begin
  Assert.AreEqual(Utils.Compare(IntArray(nil), nil), 0);
  Assert.AreEqual(Utils.Compare(IntArray(nil), []), 0);
  Assert.AreEqual(Utils.Compare(IntArray([]), nil), 0);
  Assert.AreEqual(Utils.Compare(IntArray([]), []), 0);
  Assert.AreEqual(Utils.Compare(IntArray([1]), [1]), 0);
  Assert.AreEqual(Utils.Compare(IntArray([2]), [1]), 1);
  Assert.AreEqual(Utils.Compare(IntArray([1]), [2]), -1);
  Assert.AreEqual(Utils.Compare(IntArray([1, 1, 1]), [1, 1, 1]), 0);
  Assert.AreEqual(Utils.Compare(IntArray([1, 1, 2]), [1, 1, 1]), 1);
  Assert.AreEqual(Utils.Compare(IntArray([1, 1, 1]), [1, 1, 2]), -1);
  Assert.AreEqual(Utils.Compare(IntArray([1, 1, 1]), [1, 1]), 1);
  Assert.AreEqual(Utils.Compare(IntArray([1, 1, 1]), [1, 1, 1, 1]), -1);
end;

method UtilsTest.TestCompareFltArray;
begin
  Assert.AreEqual(Utils.Compare(FltArray(nil), nil), 0);
  Assert.AreEqual(Utils.Compare(FltArray(nil), []), 0);
  Assert.AreEqual(Utils.Compare(FltArray([]), nil), 0);
  Assert.AreEqual(Utils.Compare(FltArray([]), []), 0);
  Assert.AreEqual(Utils.Compare(FltArray([1]), [1]), 0);
  Assert.AreEqual(Utils.Compare(FltArray([2]), [1]), 1);
  Assert.AreEqual(Utils.Compare(FltArray([1]), [2]), -1);
  Assert.AreEqual(Utils.Compare(FltArray([1, 1, 1]), [1, 1, 1]), 0);
  Assert.AreEqual(Utils.Compare(FltArray([1, 1, 2]), [1, 1, 1]), 1);
  Assert.AreEqual(Utils.Compare(FltArray([1, 1, 1]), [1, 1, 2]), -1);
  Assert.AreEqual(Utils.Compare(FltArray([1, 1, 1]), [1, 1]), 1);
  Assert.AreEqual(Utils.Compare(FltArray([1, 1, 1]), [1, 1, 1, 1]), -1);
end;

method UtilsTest.TestDistances;

  method CheckDistances(a1, a2: IntArray; aHamming, aManhattan: Integer; aEuclidean: Float);
  begin
    var lHamming := Utils.HammingDistance(a1, a2);
    var lManhattan := Utils.ManhattanDistance(a1, a2);
    var lEuclidean := Utils.EuclideanDistance(a1, a2);
    Assert.AreEqual(lHamming, aHamming);
    Assert.AreEqual(lManhattan, aManhattan);
    Assert.AreEqual(lEuclidean, aEuclidean);
  end;

begin
  var l1 := Utils.NewIntArray(0);
  var l2 := Utils.NewIntArray(0);
  CheckDistances(l1, l2, 0, 0, 0.0);

  l1 := [1];
  l2 := [1];
  CheckDistances(l1, l2, 0, 0, 0.0);

  l1 := [1];
  l2 := [2];
  CheckDistances(l1, l2, 1, 1, 1.0);

  l1 := [1, 2];
  l2 := [1, 2];
  CheckDistances(l1, l2, 0, 0, 0.0);

  l1 := [1, 2];
  l2 := [1, 4];
  CheckDistances(l1, l2, 1, 2, Math.Sqrt(2));

  l1 := [1, 2, 1, 3];
  l2 := [1, 3, 1, 7];
  CheckDistances(l1, l2, 2, 5, 3.0);
end;

method UtilsTest.TestCorrelations;

  method CheckCorrelation(aInts1, aInts2: IntArray; aCorrelation: Float);
  begin
    var lCorrelation := Utils.Correlation(aInts1, aInts2);
    Assert.IsTrue(Utils.FloatEqWithNaN(lCorrelation, aCorrelation));
    lCorrelation := Utils.Correlation(Utils.IntToFltArray(aInts1), Utils.IntToFltArray(aInts2));
    Assert.IsTrue(Utils.FloatEqWithNaN(lCorrelation, aCorrelation));
  end;

begin
  CheckCorrelation(nil, nil, Consts.NaN);
  CheckCorrelation([], [], Consts.NaN);
  CheckCorrelation([0], [0], Consts.NaN);
  CheckCorrelation([0, 1], [0, 1], 1.0);
  CheckCorrelation([0, 1], [1, 0], -1.0);
  CheckCorrelation([1, 2, 3], [1, 2, 3], 1.0);
  CheckCorrelation([1, 2, 3], [3, 2, 1], -1.0);
  CheckCorrelation([1, 2, 3], [1, 3, 2], 0.5);
  CheckCorrelation([3, 2, 1], [1, 3, 2], -0.5);
end;


method UtilsTest.TestImpurity;

  method CheckImpurity(aProb: FltArray; aGini, aEntropy: Float);
  begin
    var lGini := Utils.Gini(aProb);
    var lEntropy := Utils.Entropy(aProb);
    Assert.IsTrue(Utils.FloatEqWithNaN(lGini, aGini));
    Assert.IsTrue(Utils.FloatEqWithNaN(lEntropy, aEntropy));
  end;

begin
  CheckImpurity([1], 0, 0);
  CheckImpurity([0], 1, 0);
  CheckImpurity([0, 1], 0, 0);
  CheckImpurity([0, 1, 0], 0, 0);
  CheckImpurity([0.5, 0.5], 0.5, 1);
  CheckImpurity([0, 0], 1, 0);
  CheckImpurity([0.25, 0.75], 0.375, 0.811278124459133);
  CheckImpurity([], 0, 0);
  CheckImpurity(nil, 0, 0);
end;

type
  UtilsTestFlags =  flags (One, Two, Three) of Integer;

method UtilsTest.TestFlags;

  method CheckInclude(aState: Integer; aOne, aTwo, aThree: Boolean);
  begin
    Assert.AreEqual(Utils.IncludesFlag(aState, Integer(UtilsTestFlags.One)), aOne);
    Assert.AreEqual(Utils.IncludesFlag(aState, Integer(UtilsTestFlags.Two)), aTwo);
    Assert.AreEqual(Utils.IncludesFlag(aState, Integer(UtilsTestFlags.Three)), aThree);
  end;

begin
  var lState := 0;
  CheckInclude(lState, false, false, false);
  lState := Utils.AddFlag(lState, Integer(UtilsTestFlags.Two));
  CheckInclude(lState, false, true,  false);
  lState := Utils.AddFlag(lState, Integer(UtilsTestFlags.Three));
  CheckInclude(lState, false, true,  true);
  lState := Utils.AddFlag(lState, Integer(UtilsTestFlags.Three));
  CheckInclude(lState, false, true,  true);
  lState := Utils.RemoveFlag(lState, Integer(UtilsTestFlags.One));
  CheckInclude(lState, false, true,  true);
  lState := Utils.RemoveFlag(lState, Integer(UtilsTestFlags.One));
  CheckInclude(lState, false, true,  true);
  lState := Utils.RemoveFlag(lState, Integer(UtilsTestFlags.Two));
  CheckInclude(lState, false, false, true);
  lState := Utils.RemoveFlag(lState, Integer(UtilsTestFlags.Two));
  CheckInclude(lState, false, false, true);
  lState := Utils.RemoveFlag(lState, Integer(UtilsTestFlags.Three));
  CheckInclude(lState, false, false, false);
  lState := Utils.RemoveFlag(lState, Integer(UtilsTestFlags.Three));
  CheckInclude(lState, false, false, false);
end;

method UtilsTest.TestIndex;
begin
  // Insert
  Assert.AreEqual(Utils.InsertIndex(2, 3), 2);
  Assert.AreEqual(Utils.InsertIndex(3, 3), 4);
  Assert.AreEqual(Utils.InsertIndex(4, 3), 5);

  // Delete
  Assert.AreEqual(Utils.DeleteIndex(2, 3), 2);
  Assert.AreEqual(Utils.DeleteIndex(3, 3), 3);
  Assert.AreEqual(Utils.DeleteIndex(4, 3), 3);

  // Duplicate
  Assert.AreEqual(Utils.DuplicateIndex(2, 3), 2);
  Assert.AreEqual(Utils.DuplicateIndex(3, 3), 3);
  Assert.AreEqual(Utils.DuplicateIndex(4, 3), 5);

  // Move
  Assert.AreEqual(Utils.MoveIndex(2, 3, 4), 2);
  Assert.AreEqual(Utils.MoveIndex(2, 4, 3), 2);
  Assert.AreEqual(Utils.MoveIndex(3, 3, 4), 4);
  Assert.AreEqual(Utils.MoveIndex(3, 4, 3), 4);
  Assert.AreEqual(Utils.MoveIndex(4, 3, 4), 3);
  Assert.AreEqual(Utils.MoveIndex(4, 4, 3), 3);
  Assert.AreEqual(Utils.MoveIndex(5, 3, 4), 5);
  Assert.AreEqual(Utils.MoveIndex(5, 4, 3), 5);

  // Merge
  Assert.AreEqual(Utils.MergeIndex(2, 3, 4), 2);
  Assert.AreEqual(Utils.MergeIndex(2, 4, 3), 2);
  Assert.AreEqual(Utils.MergeIndex(3, 3, 4), 3);
  Assert.AreEqual(Utils.MergeIndex(3, 4, 3), 3);
  Assert.AreEqual(Utils.MergeIndex(4, 3, 4), 3);
  Assert.AreEqual(Utils.MergeIndex(4, 4, 3), 3);
  Assert.AreEqual(Utils.MergeIndex(5, 3, 4), 4);
  Assert.AreEqual(Utils.MergeIndex(5, 4, 3), 4);

  // Reverse
  Assert.AreEqual(Utils.ReverseIndex(2, 2, 4), 4);
  Assert.AreEqual(Utils.ReverseIndex(3, 2, 4), 3);
  Assert.AreEqual(Utils.ReverseIndex(4, 2, 4), 2);
  Assert.AreEqual(Utils.ReverseIndex(5, 2, 4), 1);

  // ReverseFloat
  Assert.AreEqual(Utils.ReverseFloat(1, 1, 1), 1);
  Assert.AreEqual(Utils.ReverseFloat(2, 1, 1), 0);
  Assert.AreEqual(Utils.ReverseFloat(0, 1, 1), 2);

  Assert.AreEqual(Utils.ReverseFloat(1, 1, 2), 2);
  Assert.AreEqual(Utils.ReverseFloat(2, 1, 2), 1);
  Assert.AreEqual(Utils.ReverseFloat(0, 1, 2), 3);
  Assert.AreEqual(Utils.ReverseFloat(1.5, 1, 2), 1.5);
end;

type
  TestCompositeString = class(CompositeString)
  public
    method ElementAsString(aIdx: Integer): String; override;
    begin
      result := $"{Str[aIdx]}<{Tag[aIdx]}>";
    end;
  end;

method UtilsTest.TestCompositeString;
  var cStr: CompositeString;

  method Check(aStr: String);
  begin
    Assert.AreEqual(cStr.AsString, aStr);
  end;

begin
  cStr := new TestCompositeString;
  Check('');
  cStr.Add('zero');
  Check('zero<0>');
  cStr.Add('one', 1);
  Check('zero<0>one<1>');
  cStr.Add('', -1);
  Check('zero<0>one<1><-1>');
  cStr.Add(nil);
  Check('zero<0>one<1><-1><0>');
end;

end.
