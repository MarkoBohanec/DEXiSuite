// Vectors.pas is part of
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
// Vectors.pas defines the type Vector and implements the class Vectors.
// The main function of a Vectors instance is to iterate over all possible vectors
// in the space bounded by two given vectors, Low and High, of the same length.
// ----------

namespace DexiUtils;

interface

uses
  RemObjects.Elements.RTL;

type
  Vector = public IntArray;
  Vectors = public class
  private
    fLow: Vector;
    fHigh: Vector;
    fBase: Vector;
    fVector: Vector;
  protected
    method DefineBase;
    method GetDim: Integer;
    method GetLowVector: Vector;
    method GetHighVector: Vector;
    method GetLowBound(dIdx: Integer): Integer;
    method GetHighBound(dIdx: Integer): Integer;
    method GetDimSize(dIdx: Integer): Integer;
    method GetDimSizeVector: Vector;
    method GetBaseVector: Vector;
    method GetBase(dIdx: Integer): Integer;
    method GetVector: Vector;
    method GetVectorCopy: Vector;
    method SetVector(aVec: Vector);
    method GetVecIndex(dIdx: Integer): Integer;
    method GetIndex: Integer;
    method SetIndex(aIdx: Integer);
    method GetCount: Integer;
    method ComparableVectors(aVec1, aVec2: Vector; out aCompare: Integer): Boolean;
  public
    class method ValidBounds(aLow, aHigh: Vector): Boolean;
    class method Comparable(aVec1, aVec2: Vector): Boolean;
    class method Comparable(aVec1, aVec2: Vector; out aCompare: Integer): Boolean;
    class method Compare(aVec1, aVec2: Vector): PrefCompare;
    constructor (aLow, aHigh: Vector);
    method ValidBound(dIdx: Integer): Boolean;
    method ValidDimIndex(dIdx: Integer): Boolean;
    method ValidIndex(aIdx: Integer): Boolean;
    method ValidVector(aVec: Vector): Boolean;
    method SetBounds(aLow, aHigh: Vector);
    method AssignBounds(var aLow, aHigh: Vector);
    method First;
    method Last;
    method Next: Boolean;
    method Prior: Boolean;
    method IndexOf(aVec: Vector): Integer;
    method VectorOf(aIdx: Integer): Vector;
    method CompareVectors(aVec1, aVec2: Vector): PrefCompare;
    property Dim: Integer read GetDim;
    property LowVector: Vector read GetLowVector;
    property HighVector: Vector read GetHighVector;
    property LowBound[dIdx: Integer]: Integer read GetLowBound;
    property HighBound[dIdx: Integer]: Integer read GetHighBound;
    property DimSize[dIdx: Integer]: Integer read GetDimSize;
    property DimSizeVector: Vector read GetDimSizeVector;
    property BaseVector: Vector read GetBaseVector;
    property Base[dIdx: Integer]: Integer read GetBase;
    property Vector: Vector read GetVector write SetVector;  // GetVector returns reference instead of copy for efficiency. Should not be modified externally!
    property VectorCopy: Vector read GetVectorCopy;
    property VecIndex[dIdx: Integer]: Integer read GetVecIndex;
    property &Index: Integer read GetIndex write SetIndex;
    property Count: Integer read GetCount;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION Vectors}

class method Vectors.ValidBounds(aLow, aHigh: Vector): Boolean;
begin
  result := assigned(aLow) and assigned(aHigh) and (length(aLow) = length(aHigh));
end;

class method Vectors.Comparable(aVec1, aVec2: Vector): Boolean;
begin
  var c: Integer;
  result := Comparable(aVec1, aVec2, out c);
end;

class method Vectors.Comparable(aVec1, aVec2: Vector; out aCompare: Integer): Boolean;
begin
  aCompare := 0;
  if aVec1 = aVec2 then
    exit true;
  if not (assigned(aVec1) and assigned(aVec2)) then
    exit false;
  var h := high(aVec1);
  var x := low(aVec1);
  result := h = high(aVec2);
  while result and (x <= h) do
    begin
      if aVec1[x] < aVec2[x] then
        begin
          result := aCompare <= 0;
          aCompare := -1;
        end
      else if aVec1[x] > aVec2[x] then
        begin
          result := aCompare >= 0;
          aCompare := 1;
        end;
      inc(x);
    end;
end;

class method Vectors.Compare(aVec1, aVec2: Vector): PrefCompare;
begin
  var c: Integer;
  result :=
    if Comparable(aVec1, aVec2, out c) then Values.IntToPrefCompare(c)
    else PrefCompare.No;
end;

method Vectors.CompareVectors(aVec1, aVec2: Vector): PrefCompare;
begin
  var c: Integer;
  result :=
    if ComparableVectors(aVec1, aVec2, out c) then Values.IntToPrefCompare(c)
    else PrefCompare.No;
end;

method Vectors.ComparableVectors(aVec1, aVec2: Vector; out aCompare: Integer): Boolean;
begin
  aCompare := 0;
  if aVec1 = aVec2 then
    exit true;
  if not (assigned(aVec1) and assigned(aVec2)) then
    exit false;
  var h := high(aVec1);
  var x := low(aVec1);
  result := h = high(aVec2);
  while result and (x <= h) do
    begin
      if ValidBound(x) then
        if aVec1[x] < aVec2[x] then
          begin
            result := aCompare <= 0;
            aCompare := -1;
          end
        else if aVec1[x] > aVec2[x] then
          begin
            result := aCompare >= 0;
            aCompare := 1;
          end;
      inc(x);
    end;
end;

constructor Vectors(aLow, aHigh: Vector);
begin
  SetBounds(aLow, aHigh);
end;

method Vectors.ValidBound(dIdx: Integer): Boolean;
begin
  result := ValidDimIndex(dIdx) and (fLow[dIdx] <= fHigh[dIdx]);
end;

method Vectors.ValidDimIndex(dIdx: Integer): Boolean;
begin
  result := 0 <= dIdx < GetDim;
end;

method Vectors.ValidIndex(aIdx: Integer): Boolean;
begin
  result := 0 <= aIdx < GetCount;
end;

method Vectors.ValidVector(aVec: Vector): Boolean;
begin
  var cLow, cHigh: Integer;
  result :=
    if not assigned(aVec) or (length(aVec) <> GetDim) then false
    else if not(ComparableVectors(fLow, aVec, out cLow) and ComparableVectors(fHigh, aVec, out cHigh)) then false
    else (cLow <= 0) and (cHigh >= 0);
end;

method Vectors.SetBounds(aLow, aHigh: Vector);
begin
  if not ValidBounds(aLow, aHigh) then
    raise new ArgumentException($'Vectors.SetBounds: Inappropriate bounds: {aLow}:{aHigh}');
  fLow := Utils.CopyIntArray(aLow);
  fHigh := Utils.CopyIntArray(aHigh);
  DefineBase;
  First;
end;

method Vectors.AssignBounds(var aLow, aHigh: Vector);
begin
  if not ValidBounds(aLow, aHigh) then
    raise new ArgumentException($'Vectors.AssignBounds: Inappropriate bounds: {aLow}:{aHigh}');
  fLow := aLow;
  fHigh := aHigh;
  aLow := nil;
  aHigh := nil;
  DefineBase;
  First;
end;

method Vectors.DefineBase;
begin
  fBase := Utils.NewIntArray(GetDim);
  var b := 1;
  for x := high(fBase) downto low(fBase) do
    if ValidBound(x) then
      begin
        fBase[x] := b;
        b := b * GetDimSize(x);
      end;
end;

method Vectors.GetDim: Integer;
begin
  result := length(fLow);
end;

method Vectors.GetLowVector: Vector;
begin
  result := Utils.CopyIntArray(fLow);
end;

method Vectors.GetHighVector: Vector;
begin
  result := Utils.CopyIntArray(fHigh);
end;

method Vectors.GetLowBound(dIdx: Integer): Integer;
begin
  result := fLow[dIdx];
end;

method Vectors.GetHighBound(dIdx: Integer): Integer;
begin
  result := fHigh[dIdx];
end;

method Vectors.GetDimSize(dIdx: Integer): Integer;
begin
  result := fHigh[dIdx] - fLow[dIdx] + 1;
end;

method Vectors.GetDimSizeVector: Vector;
begin
  result := Utils.NewIntArray(Dim);
  for i := 0 to Dim - 1 do
    result[i] := DimSize[i];
end;

method Vectors.GetBaseVector: Vector;
begin
  result := Utils.CopyIntArray(fBase);
end;

method Vectors.GetBase(dIdx: Integer): Integer;
begin
  result := fBase[dIdx];
end;

method Vectors.GetVector: Vector;
begin
  result := fVector; // Returning reference instead of copy for efficiency. Do not modify the array externally!
end;

method Vectors.GetVectorCopy: Vector;
begin
  result := Utils.CopyIntArray(fVector);
end;

method Vectors.SetVector(aVec: Vector);
begin
  if not ValidVector(aVec) then
    raise new ArgumentException($'Vectors.SetVector: Inappropriate vector {Utils.IntArrayToStr(aVec)}');
  fVector := Utils.CopyIntArray(aVec);
end;

method Vectors.GetVecIndex(dIdx: Integer): Integer;
begin
  result := fVector[dIdx];
end;

method Vectors.GetIndex: Integer;
begin
  result := IndexOf(fVector);
end;

method Vectors.SetIndex(aIdx: Integer);
begin
  fVector := VectorOf(aIdx);
end;

method Vectors.GetCount: Integer;
begin
  result := 0;
  for x := low(fBase) to high(fBase) do
    if ValidBound(x) then
      exit fBase[x] * GetDimSize(x);
end;

method Vectors.First;
begin
  fVector := Utils.CopyIntArray(fLow);
end;

method Vectors.Last;
begin
  fVector := Utils.CopyIntArray(fHigh);
end;

method Vectors.Next: Boolean;
begin
  var c := true;
  var x := GetDim - 1;
  while (x >= 0) and c do
    begin
      if ValidBound(x) then
        begin
          inc(fVector[x]);
          if fVector[x] > fHigh[x] then
            fVector[x] := fLow[x]
          else
            c := false;
        end;
      dec(x);
    end;
  result := not c;
end;

method Vectors.Prior: Boolean;
begin
  var c := true;
  var x := GetDim - 1;
  while (x >= 0) and c do
    begin
      if ValidBound(x) then
        begin
          dec(fVector[x]);
          if fVector[x] < fLow[x] then
            fVector[x] := fHigh[x]
          else
            c := false;
        end;
      dec(x);
    end;
  result := not c;
end;

method Vectors.IndexOf(aVec: Vector): Integer;
begin
  if not ValidVector(aVec) then
    raise new ArgumentException($'Vectors.IndexOf: Inappropriate vector {Utils.IntArrayToStr(aVec)}');
  result := 0;
  for x := GetDim - 1 downto 0 do
    if ValidBound(x) then
      result := result + fBase[x] * (aVec[x] - fLow[x]);
end;

method Vectors.VectorOf(aIdx: Integer): Vector;
begin
  if not ValidIndex(aIdx) then
    raise new ArgumentException($'Vectors.VectorOf: Inappropriate index {aIdx}');
  result := Utils.NewIntArray(GetDim);
  for x := 0 to GetDim-1 do
    if ValidBound(x) then
      begin
        result[x] := aIdx div fBase[x] + fLow[x];
        aIdx := aIdx mod fBase[x];
      end;
end;

{$ENDREGION}

end.
