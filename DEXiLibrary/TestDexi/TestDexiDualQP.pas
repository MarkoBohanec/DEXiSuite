namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiDualQPTest = public class(DexiLibraryTest)
  private
  protected
  public
    method TestGraphSimple;
    method TestGraphA;
    method TestGraphB;
    method TestWorkApp0;
    method TestWorkApp0double;
  end;

implementation

method DexiDualQPTest.TestGraphSimple;
var q: Integer; f: Float; x, u: FltArray; a: IntArray;
begin
  var G := new FltArray[6];
  G[0] := [1.01, -1, 0, 0, 0, 0];
  G[1] := [-1,    3,-1, 0,-1, 0];
  G[2] := [0,    -1, 2,-1, 0, 0];
  G[3] := [0,     0,-1, 2, 0,-1];
  G[4] := [0,    -1, 0, 0, 2,-1];
  G[5] := [0,     0, 0,-1,-1, 2.01];

  var g0 :=  [0.0,0,0,0,0,0];

  var CI := new FltArray[6];
  CI[0] := [ -1, 0, 0, 0, 0, 0];
  CI[1] := [  1,-1, 0,-1, 0, 0];
  CI[2] := [  0, 1,-1, 0, 0, 0];
  CI[3] := [  0, 0, 1, 0, 0,-1];
  CI[4] := [  0, 0, 0, 1,-1, 0];
  CI[5] := [  0, 0, 0, 0, 1, 1];

  var ci0 := [-1.0, -1, -1, -1, -1, -1];

  var CE := DualQP.QPMatrix(6, 1);
  CE[0] := [1];
  CE[1] := [0];
  CE[2] := [0];
  CE[3] := [0];
  CE[4] := [0];
  CE[5] := [0];

  var ce0: FltArray := [0];

  DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);
  Assert.IsTrue(Utils.FltArrayEq(x, [0, 1, 2, 3, 2.5, 4]));
  Assert.IsTrue(Utils.FloatEq(f, 4.33, 0.000001));
end;

method DexiDualQPTest.TestGraphA;
var q: Integer; f: Float; x, u: FltArray; a: IntArray;
begin
  var G := new FltArray[9];
  G[0] := [ 1, -1,  0,  0,  0,  0,  0,  0,  0];
  G[1] := [-1,  3, -1,  0,  0, -1,  0,  0,  0];
  G[2] := [ 0, -1,  2, -1,  0,  0,  0,  0,  0];
  G[3] := [ 0,  0, -1,  2, -1,  0,  0,  0,  0];
  G[4] := [ 0,  0,  0, -1,  2,  0,  0, -1,  0];
  G[5] := [ 0, -1,  0,  0,  0,  2, -1,  0,  0];
  G[6] := [ 0,  0,  0,  0,  0, -1,  2, -1,  0];
  G[7] := [ 0,  0,  0,  0, -1,  0, -1,  3, -1];
  G[8] := [ 0,  0,  0,  0,  0,  0,  0, -1,  1];

  var g0 :=  [0.0,0,0,0,0,0,0,0,0];

  var CI := new FltArray[9];
  CI[0] := [-1,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[1] := [ 1, -1,  0, -1,  0,  0, -1,  0,  0,  0];
  CI[2] := [ 0,  1, -1,  1,  0,  0,  0,  0,  0,  0];
  CI[3] := [ 0,  0,  1,  0, -1,  0,  0,  0,  0,  0];
  CI[4] := [ 0,  0,  0,  0,  1, -1,  0,  0,  0,  0];
  CI[5] := [ 0,  0,  0,  0,  0,  0,  1, -1,  0,  0];
  CI[6] := [ 0,  0,  0,  0,  0,  0,  0,  1, -1,  0];
  CI[7] := [ 0,  0,  0,  0,  0,  1,  0,  0,  1, -1];
  CI[8] := [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  1];

  var ci0 := [-1.0, -1, -1, -1, -1, -1, -1, -1, -1, -1];

  var CE := DualQP.QPMatrix(9, 1);
  CE[0] := [1];
  CE[1] := [0];
  CE[2] := [0];
  CE[3] := [0];
  CE[4] := [0];
  CE[5] := [0];
  CE[6] := [0];
  CE[7] := [0];
  CE[8] := [0];

  var ce0: FltArray := [0];

  DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);
  Assert.IsTrue(Utils.FltArrayEq(x, [0, 1, 2, 3, 4, 7.0/3, 11.0/3, 5, 6], 0.000001));
  Assert.IsTrue(Utils.FloatEq(f, 17.0/3, 0.000001));
end;

method DexiDualQPTest.TestGraphB;
var q: Integer; f: Float; x, u: FltArray; a: IntArray;
begin
  var G := new FltArray[15];
  G[ 0] := [  2.001, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  G[ 1] := [ -1,  2,  0,  0, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  G[ 2] := [ -1,  0,  2, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  G[ 3] := [  0,  0, -1,  3, -1,  0,  0, -1,  0,  0,  0,  0,  0,  0,  0];
  G[ 4] := [  0, -1,  0, -1,  3, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  G[ 5] := [  0,  0,  0,  0, -1,  4, -1,  0, -1,  0, -1,  0,  0,  0,  0];
  G[ 6] := [  0,  0,  0,  0,  0, -1,  2,  0,  0,  0,  0,  0, -1,  0,  0];
  G[ 7] := [  0,  0,  0, -1,  0,  0,  0,  3, -1,  0, -1,  0,  0,  0,  0];
  G[ 8] := [  0,  0,  0,  0,  0, -1,  0, -1,  3, -1,  0,  0,  0,  0,  0];
  G[ 9] := [  0,  0,  0,  0,  0,  0,  0,  0, -1,  2,  0, -1,  0,  0,  0];
  G[10] := [  0,  0,  0,  0,  0, -1,  0, -1,  0,  0,  4, -1,  0, -1,  0];
  G[11] := [  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1,  3, -1,  0,  0];
  G[12] := [  0,  0,  0,  0,  0,  0, -1,  0,  0,  0,  0, -1,  3,  0, -1];
  G[13] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1,  0,  0,  2, -1];
  G[14] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, -1, -1,  2.001];

  var g0 :=  [0.0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

  var CI := new FltArray[15];
  CI[ 0] := [ -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 1] := [  1,  0, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 2] := [  0,  1,  0, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 3] := [  0,  0,  0,  1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 4] := [  0,  0,  1,  0,  0,  1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 5] := [  0,  0,  0,  0,  0,  0,  1, -1, -1, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 6] := [  0,  0,  0,  0,  0,  0,  0,  1,  0,  0, -1,  0,  0,  0,  0,  0,  0,  0,  0,  0];
  CI[ 7] := [  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0, -1, -1,  0,  0,  0,  0,  0,  0,  0];
  CI[ 8] := [  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  1,  0, -1,  0,  0,  0,  0,  0,  0];
  CI[ 9] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1, -1,  0,  0,  0,  0,  0];
  CI[10] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  1,  0,  0, -1, -1,  0,  0,  0];
  CI[11] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  0, -1,  0,  0];
  CI[12] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,  1, -1,  0];
  CI[13] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  0,  0, -1];
  CI[14] := [  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1];

  var ci0 := [-1.0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];

  var CE := DualQP.QPMatrix(15, 1);
  CE[0]  := [1];
  CE[1]  := [0];
  CE[2]  := [0];
  CE[3]  := [0];
  CE[4]  := [0];
  CE[5]  := [0];
  CE[6]  := [0];
  CE[7]  := [0];
  CE[8]  := [0];
  CE[9]  := [0];
  CE[10] := [0];
  CE[11] := [0];
  CE[12] := [0];
  CE[13] := [0];
  CE[14] := [0];

  var ce0: FltArray := [0];

  DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);
  Assert.IsTrue(Utils.FltArrayEq(x, [0, 1.5, 1, 2, 3, 4, 6, 4, 5, 6, 5.57142857, 7, 8, 7.28571428, 9], 0.000001));
  Assert.IsTrue(Utils.FloatEq(f, 19.7190714285714, 0.000001));
end;

method DexiDualQPTest.TestWorkApp0;
var q: Integer; f: Float; x, u: FltArray; a: IntArray;
begin
  var G := new FltArray[8];
  G[0] := [ 1.01, -1,  0,  0,  0,  0,  0,  0];
  G[1] := [-1,     3, -1,  0, -1,  0,  0,  0];
  G[2] := [ 0,    -1,  2, -1,  0,  0,  0,  0];
  G[3] := [ 0,     0, -1,  2,  0,  0,  0, -1];
  G[4] := [ 0,    -1,  0,  0,  2, -1,  0,  0];
  G[5] := [ 0,     0,  0,  0, -1,  2, -1,  0];
  G[6] := [ 0,     0,  0,  0,  0, -1,  2, -1];
  G[7] := [ 0,     0,  0, -1,  0,  0, -1,  2.01];

  var g0 := Utils.NewFltArray(8, 0.0);

  var CI := new FltArray[8];
  CI[0] := [-1,  0,  0,  0,  0,  0,  0,  0];
  CI[1] := [ 1, -1, -1,  0,  0,  0,  0,  0];
  CI[2] := [ 0,  1,  0, -1,  0,  0,  0,  0];
  CI[3] := [ 0,  0,  0,  1, -1,  0,  0,  0];
  CI[4] := [ 0,  0,  1,  0,  0, -1,  0,  0];
  CI[5] := [ 0,  0,  0,  0,  0,  1, -1,  0];
  CI[6] := [ 0,  0,  0,  0,  0,  0,  1, -1];
  CI[7] := [ 0,  0,  0,  0,  1,  0,  0,  1];

  var ci0 := Utils.NewFltArray(8, -1.0);

  var CE := DualQP.QPMatrix(8, 1);
  CE[0]  := [1];
  CE[1]  := [0];
  CE[2]  := [0];
  CE[3]  := [0];
  CE[4]  := [0];
  CE[5]  := [0];
  CE[6]  := [0];
  CE[7]  := [0];

  var ce0: FltArray := [0];

  DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);
  Assert.IsTrue(Utils.FltArrayEq(x, [0.0, 1, 2.3333333, 3.6666667, 2, 3, 4, 5], 0.000001));
  Assert.IsTrue(Utils.FloatEq(f, 5.29166666666667, 0.000001));
end;

method DexiDualQPTest.TestWorkApp0double;
var q: Integer; f: Float; x, u: FltArray; a: IntArray;
begin
  var G := new FltArray[8];
  G[0] := [ 1.01, -1,  0,  0,  0,  0,  0,  0];
  G[1] := [-1,     3, -1,  0, -1,  0,  0,  0];
  G[2] := [ 0,    -1,  2, -1,  0,  0,  0,  0];
  G[3] := [ 0,     0, -1,  2,  0,  0,  0, -1];
  G[4] := [ 0,    -1,  0,  0,  2, -1,  0,  0];
  G[5] := [ 0,     0,  0,  0, -1,  2, -1,  0];
  G[6] := [ 0,     0,  0,  0,  0, -1,  2, -1];
  G[7] := [ 0,     0,  0, -1,  0,  0, -1,  2.01];

  var g0 := Utils.NewFltArray(8, 0.0);

  var CI := new FltArray[8];
  CI[0] := [-1,  0,  0,  0,  0,  0,  0,  0];
  CI[1] := [ 1, -1, -1,  0,  0,  0,  0,  0];
  CI[2] := [ 0,  1,  0, -1,  0,  0,  0,  0];
  CI[3] := [ 0,  0,  0,  1, -1,  0,  0,  0];
  CI[4] := [ 0,  0,  1,  0,  0, -1,  0,  0];
  CI[5] := [ 0,  0,  0,  0,  0,  1, -1,  0];
  CI[6] := [ 0,  0,  0,  0,  0,  0,  1, -1];
  CI[7] := [ 0,  0,  0,  0,  1,  0,  0,  1];

  // difference 2 between q_L and first higher, and q_U and first lower
  var ci0 := [-2.0, -1, -1, -1, -2, -1, -1, -2];

  var CE := DualQP.QPMatrix(8, 1);
  CE[0]  := [1];
  CE[1]  := [0];
  CE[2]  := [0];
  CE[3]  := [0];
  CE[4]  := [0];
  CE[5]  := [0];
  CE[6]  := [0];
  CE[7]  := [0];

  var ce0: FltArray := [0];

  DualQP.DualOpt(G, CI, CE, g0, ci0, ce0, out f, out x, out u, out a, out q);
  Assert.IsTrue(Utils.FltArrayEq(x, [0.0, 2,  3.5,  5,  3,  4,  5, 7], 0.000001));
  Assert.IsTrue(Utils.FloatEq(f,9.995, 0.000001));
end;

end.
