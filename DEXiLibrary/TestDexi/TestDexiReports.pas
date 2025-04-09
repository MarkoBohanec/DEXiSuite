namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiReportsTest = public class(DexiLibraryTest)
  private
  protected
  public
    method TestBreakColumns;
  end;

implementation

method DexiReportsTest.TestBreakColumns;

  method CheckResult(aResult: List<IntArray>; aCheck: array of IntArray);
  begin
    Assert.AreEqual(aResult.Count, length(aCheck));
    for each lEl in aResult index x do
      Assert.IsTrue(Utils.IntArrayEq(lEl, aCheck[x]));
  end;

begin
  var lColumns: IntArray := nil;
  CheckResult(DexiReport.BreakColumns(lColumns, 0), []);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), []);
  lColumns := [];
  CheckResult(DexiReport.BreakColumns(lColumns, 0), []);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), []);
  lColumns := [1];
  CheckResult(DexiReport.BreakColumns(lColumns, 0), [[1]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), [[1]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 2), [[1]]);
  lColumns := [1, 2];
  CheckResult(DexiReport.BreakColumns(lColumns, 0), [[1, 2]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), [[1], [2]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 2), [[1, 2]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 3), [[1, 2]]);
  lColumns := [1, 2, 3];
  CheckResult(DexiReport.BreakColumns(lColumns, 0), [[1, 2, 3]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), [[1], [2], [3]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 2), [[1, 2], [3]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 3), [[1, 2, 3]]);
  lColumns := [1, DexiReport.ColBreak, 3, 4];
  CheckResult(DexiReport.BreakColumns(lColumns, 0), [[1],  [3, 4]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), [[1], [3], [4]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 2), [[1], [3, 4]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 3), [[1], [3, 4]]);
  lColumns := [1, 2, DexiReport.ColBreak, 3, 4];
  CheckResult(DexiReport.BreakColumns(lColumns, 0), [[1, 2],  [3, 4]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 1), [[1], [2], [3], [4]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 2), [[1, 2], [3, 4]]);
  CheckResult(DexiReport.BreakColumns(lColumns, 3), [[1, 2], [3, 4]]);
end;

end.
