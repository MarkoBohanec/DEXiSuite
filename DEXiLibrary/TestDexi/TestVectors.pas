namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  VectorsTest = public class(DexiLibraryTest)
  protected
  public
	  method TestComparable;
	  method TestValid;
	  method TestDimensions;
	  method TestIndexes;
  end;

implementation

method VectorsTest.TestComparable;

  method CheckComparable(v1, v2: Vector; xb: Boolean; xc: Integer);
  begin
    var c: Integer;
    var b := Vectors.Comparable(v1, v2, out c);
    Assert.AreEqual(b, xb);
    Assert.AreEqual(c, xc);
  end;

begin
  CheckComparable(nil, nil, true, 0);
  CheckComparable([], nil, false, 0);
  CheckComparable(nil, [], false, 0);
  CheckComparable([], [], true, 0);

  var vec: Vector := [1, 2, 3];
  CheckComparable(vec, vec, true, 0);
  CheckComparable(vec, [1, 2, 3], true, 0);
  CheckComparable([1, 2, 3], [1, 2, 3], true, 0);

  CheckComparable([1, 2, 3, 4], [1, 2, 3], false, 0);

  CheckComparable([1, 2, 3], [1, 2, 4], true, -1);
  CheckComparable([1, 2, 4], [1, 2, 3], true, 1);
  CheckComparable([1, 1, 1], [5, 5, 5], true, -1);

  CheckComparable([1, 1, 2], [1, 2, 1], false, 1);
  CheckComparable([1, 2, 1], [1, 1, 2], false, -1);
end;

method VectorsTest.TestValid;

  method CheckValid(v1, v2: Vector; xValidBounds: Boolean; xValidBound: array of Boolean);
  begin
    Assert.AreEqual(Vectors.ValidBounds(v1, v2), xValidBounds);
    if not xValidBounds then
      exit;
    var lVectors := new Vectors(v1, v2);
    for i := low(xValidBound) to high(xValidBound) do
      Assert.AreEqual(lVectors.ValidBound(i), xValidBound[i]);
    Assert.IsTrue(Utils.IntArrayEq(lVectors.LowVector, v1));
    Assert.IsTrue(Utils.IntArrayEq(lVectors.HighVector, v2));
  end;

begin
  CheckValid(nil, nil, false, []);
  CheckValid([], [], true, []);
  CheckValid([], [1], false, []);
  CheckValid([1], [1], true, [true]);
  CheckValid([1, 1, 1], [2, 2, 2], true, [true, true, true]);
  CheckValid([1, 1, 1], [2, 1, 2], true, [true, true, true]);
  CheckValid([1, 2, 1], [2, 1, 2], true, [true, false, true]);
  CheckValid([1, 1, 2], [2, 2, 1], true, [true, true, false]);
end;

method VectorsTest.TestDimensions;

  method CheckDimensions(v1, v2: Vector; xcount: Integer; xbase: Vector);
  begin
    Assert.IsTrue(Vectors.ValidBounds(v1, v2));
    var lVectors := new Vectors(v1, v2);
    Assert.AreEqual(lVectors.Dim, length(v1));
    for i := low(v1) to high(v2) do
      Assert.IsTrue(lVectors.ValidDimIndex(i));
    Assert.IsFalse(lVectors.ValidDimIndex(-1));
    Assert.IsFalse(lVectors.ValidDimIndex(high(v2) + 1));
    Assert.AreEqual(lVectors.Count, xcount);
    for i := 0 to xcount - 1 do
      Assert.IsTrue(lVectors.ValidIndex(i));
    Assert.IsTrue(Utils.IntArrayEq(lVectors.BaseVector, xbase));
    Assert.IsFalse(lVectors.ValidIndex(-1));
    Assert.IsFalse(lVectors.ValidIndex(xcount));
    for i := low(v1) to high(v2) do
      begin
        Assert.AreEqual(lVectors.LowBound[i], v1[i]);
        Assert.AreEqual(lVectors.HighBound[i], v2[i]);
      end;
  end;

begin
  CheckDimensions([], [], 0, []);
  CheckDimensions([1], [1], 1, [1]);
  CheckDimensions([1], [3], 3, [1]);
  CheckDimensions([1, 1], [3, 3], 9, [3, 1]);
  CheckDimensions([1, 1, 1], [3, 3, 2], 18, [6, 2, 1]);
  CheckDimensions([1, 5, 1], [3, 1, 3], 9,  [3, 0, 1]);
  CheckDimensions([1, 1, 5], [3, 2, 1], 6, [2, 1, 0]);
  CheckDimensions([5, 1, 1], [1, 5, 4], 20, [0, 4, 1]);
end;

method VectorsTest.TestIndexes;

  method CheckIndexes(v1, v2: Vector; xcount: Integer);
  begin
    Assert.IsTrue(Vectors.ValidBounds(v1, v2));
    var lVectors := new Vectors(v1, v2);
    Assert.AreEqual(lVectors.Count, xcount);
    lVectors.First;
    for i := 0 to xcount - 1 do
      begin
        Assert.AreEqual(lVectors.Index, i);
        var lVec := lVectors.Vector;
        Assert.AreEqual(lVectors.IndexOf(lVec), i);
        var lVecOf := lVectors.VectorOf(i);
        Assert.IsTrue(lVectors.CompareVectors(lVec, lVecOf) = PrefCompare.Equal);
        Assert.IsTrue(lVectors.Next = (i < xcount - 1));
      end;
    lVectors.Last;
    for i := xcount - 1 downto 0 do
      begin
        Assert.AreEqual(lVectors.Index, i);
        var lVec := lVectors.Vector;
        Assert.AreEqual(lVectors.IndexOf(lVec), i);
        var lVecOf := lVectors.VectorOf(i);
        Assert.IsTrue(lVectors.CompareVectors(lVec, lVecOf) = PrefCompare.Equal);
        Assert.IsTrue(lVectors.Prior = (i > 0));
      end;
  end;

begin
  CheckIndexes([], [], 0);
  CheckIndexes([1], [1], 1);
  CheckIndexes([1], [3], 3);
  CheckIndexes([1, 1], [3, 3], 9);
  CheckIndexes([1, 1, 1], [3, 3, 2], 18);
  CheckIndexes([1, 5, 1], [3, 1, 3], 9);
  CheckIndexes([1, 1, 5], [3, 2, 1], 6);
  CheckIndexes([5, 1, 1], [1, 5, 4], 20);
end;

end.
