// MultiLin.pas is part of
//
// DEXiLibrary, DEXi Decision Modeling Software Library
//
// Copyright (C) 2023-2025 Marko Bohanec
//
// DEXiLibrary is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// MultiLinear.pas implements multi-linear interpolation, i.e.,
// a generalization of linear interpolation to multiple dimensions.
//
// Problem:
// Given the value of some function y = f(x1, x2, ..., xn)
//   in the 2^n points lying at the corners of a n-dimensional hyper-cube,
// calculate the value of f in any interior point of the hyper-cube,
//   carying out the linear interpolation in each dimension.
//
// For further information, please see:
// Rick Wagner: Multi-Linear Interpolation. Beach Cities Robotics.
//   https://rjwagner49.com/Mathematics/Interpolation.pdf
// ----------

namespace DexiUtils;

interface

uses
  RemObjects.Elements.RTL;

type
  Grid = public array of FltArray;

type
  MultiLinear = public static class
  private
    method LowGridIndex(x: Float; aGrid: FltArray): Integer;
  public
    method MultilinearInterpolation(aArgs: FltArray; aValues: FltArray; aGrid: Grid): Float;
    method MultilinearDerivative(aArgs: FltArray; aValues: FltArray; aGrid: Grid; aArg: Integer): Float;
    method MultilinearDerivatives(aArgs: FltArray; aValues: FltArray; aGrid: Grid): FltArray;
  end;

implementation

method MultiLinear.LowGridIndex(x: Float; aGrid: FltArray): Integer;
begin
  result := 0;
  for i := 1 to high(aGrid) - 1 do
    if x >= aGrid[i] then
      result := i
    else
      break;
end;

method MultiLinear.MultilinearInterpolation(aArgs: FltArray; aValues: FltArray; aGrid: Grid): Float;
begin
  var lRank := length(aArgs);
  var lWeights := Utils.NewFltArray(lRank);
  var lZero := Utils.NewIntArray(lRank);
  var lDim := Utils.NewIntArray(lRank);
  var lLow := Utils.NewIntArray(lRank);
  var lHigh := Utils.NewIntArray(lRank);
  for i := low(lWeights) to high(lWeights) do
    begin
      var gx := LowGridIndex(aArgs[i], aGrid[i]);
      lLow[i] := gx;
      lHigh[i] := gx + 1;
      lWeights[i] := (aArgs[i] - aGrid[i][gx]) / (aGrid[i][gx+1] - aGrid[i][gx]);
      lDim[i] := high(aGrid[i])
    end;
  var wSum := 0.0;
  var ipVal := 0.0;
  var space := new Vectors(lZero, lDim);
  var points := new Vectors(lLow, lHigh);
  repeat
    var cw := 1.0;
    for g := 0 to lRank - 1 do
      if points.Vector[g] = lLow[g] then
        cw := cw * (1 - lWeights[g])
      else
        cw := cw * lWeights[g];
    wSum := wSum + cw;
    ipVal := ipVal + cw * aValues[space.IndexOf(points.Vector)];
  until not points.Next;
  result := ipVal / wSum;
end;

method MultiLinear.MultilinearDerivative(aArgs: FltArray; aValues: FltArray; aGrid: Grid; aArg: Integer): Float;
begin
  var e := Utils.FloatEpsilon;
  var lArgs := Utils.CopyFltArray(aArgs);
  lArgs[aArg] := aArgs[aArg] - e;
  var l := MultilinearInterpolation(lArgs, aValues, aGrid);
  lArgs[aArg] := aArgs[aArg] + e;
  var h := MultilinearInterpolation(lArgs, aValues, aGrid);
  result := (h - l) / (2 * e);
end;

method MultiLinear.MultilinearDerivatives(aArgs: FltArray; aValues: FltArray; aGrid: Grid): FltArray;
begin
  var e := Utils.FloatEpsilon;
  result := Utils.NewFltArray(length(aArgs));
  var lArgs := Utils.CopyFltArray(aArgs);
  for i := low(aArgs) to high(aArgs) do
    begin
      lArgs[i] := aArgs[i] - e;
      var l := MultilinearInterpolation(lArgs, aValues, aGrid);
      lArgs[i] := aArgs[i] + e;
      var h := MultilinearInterpolation(lArgs, aValues, aGrid);
      result[i] := (h - l) / (2 * e);
    end;
end;

end.
