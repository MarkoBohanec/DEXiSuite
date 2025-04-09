namespace DexiLibrary.Tests;

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiLibraryTest = public class(Test)
  protected
    class const cTestPath = '../../../TestData';
    class const cTestOutput = '../../../TestOutputs';
  public
    {$IFDEF JAVA}
    class property TestPath := new java.io.File(cTestPath).getCanonicalPath() + '/'; lazy;
    class property TestOutput := new java.io.File(cTestOutput).getCanonicalPath() + '/'; lazy;
    {$ELSE}
    class property TestPath := RemObjects.Elements.RTL.Path.GetFullPath(cTestPath) + '/'; lazy;
    class property TestOutput := RemObjects.Elements.RTL.Path.GetFullPath(cTestOutput) + '/'; lazy;
    {$ENDIF}
    class method LoadModel(aFileName: String): DexiModel;
    class method CheckFilesEqual(f1, f2: File);
    class method CheckEqualAlternativesOn(aAttributes: DexiAttributeList; aAlt1, aAlt2: IDexiAlternative);
  end;

implementation

class method DexiLibraryTest.CheckFilesEqual(f1, f2: File);
begin
  var s1 := f1.ReadText.Replace(#13#10, #10);
  var s2 := f2.ReadText.Replace(#13#10, #10);
  Assert.AreEqual(s1, s2);
end;

class method DexiLibraryTest.LoadModel(aFileName: String): DexiModel;
begin
  result := nil;
  var iFileName := TestPath + aFileName;
  var Model := new DexiModel;
  Model.LoadFromFile(iFileName);
  exit Model;
end;

class method DexiLibraryTest.CheckEqualAlternativesOn(aAttributes: DexiAttributeList; aAlt1, aAlt2: IDexiAlternative);
begin
  for i := 0 to aAttributes.Count - 1 do
    begin
      var lAtt := aAttributes[i];
      Assert.IsTrue(DexiValue.ValuesAreEqual(aAlt1[lAtt], aAlt2[lAtt]));
    end;
end;

end.
