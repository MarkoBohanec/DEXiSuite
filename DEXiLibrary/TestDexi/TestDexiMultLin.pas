namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiMLTest = public class(DexiLibraryTest)
  private
  protected
  public
    method TestCar;
    method TestComfort;
  end;

implementation

{$HIDE H11}

method DexiMLTest.TestCar;
begin
  var lGrid := new FltArray[2];
  lGrid[0] := [1, 2, 3];
  lGrid[1] := [1, 2, 3, 4];
  var lValues := [1.0, 1, 1, 1, 1, 2, 3, 4, 1, 3, 4, 4];
  // Test in points
  var aArgs := Utils.NewFltArray(2);
  var idx := 0;
  for i := 1 to 3 do
    for j := 1 to 4 do
      begin
        aArgs[0] := i;
        aArgs[1] := j;
        var z := MultiLinear.MultilinearInterpolation(aArgs, lValues, lGrid);
        Assert.IsTrue(Math.Abs(lValues[idx] - z) < 0.0001);
        var deriv := MultiLinear.MultilinearDerivatives(aArgs, lValues, lGrid);
        inc(idx);
      end;
  var x := 1.0;
  repeat
    var y := 1.0;
    repeat
      aArgs[0] := x;
      aArgs[1] := y;
      var z := MultiLinear.MultilinearInterpolation(aArgs, lValues, lGrid);
      y := y + 0.25;
    until y > 4.1;
    x := x + 0.25;
  until x > 3.1;
end;

method DexiMLTest.TestComfort;
begin
  var lGrid := new FltArray[3];
  lGrid[0] := [1, 2, 3];
  lGrid[1] := [1, 2, 3, 4];
  lGrid[2] := [1, 2, 3];
  var lValues := [1.0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2.5,1,2,3,1,2,3,1,1,1,1,2,3,1,3,3,1,3,3];
  // Test in points
  var aArgs := Utils.NewFltArray(3);
  var idx := 0;
  for i := 1 to 3 do
    for j := 1 to 4 do
      for k := 1 to 3 do
        begin
          aArgs[0] := i;
          aArgs[1] := j;
          aArgs[2] := k;
          var z := MultiLinear.MultilinearInterpolation(aArgs, lValues, lGrid);
          Assert.IsTrue(Math.Abs(lValues[idx] - z) < 0.0001);
          var deriv := MultiLinear.MultilinearDerivatives(aArgs, lValues, lGrid);
          inc(idx);
        end;
  var x := 1.0;
  repeat
    var y := 1.0;
    repeat
      var t := 1.0;
      repeat
        aArgs[0] := x;
        aArgs[1] := y;
        aArgs[2] := t;
        var z := MultiLinear.MultilinearInterpolation(aArgs, lValues, lGrid);
        t := t + 0.5;
      until t > 3.1;
      y := y + 0.5;
    until y > 4.1;
    x := x + 0.5;
  until x > 3.1;
end;

end.
