namespace DexiLibrary.Tests;

{$HIDE W28} // obsolete methods

interface

uses
  DEXiUtils,
  DEXiLibrary,
  RemObjects.Elements.RTL,
  RemObjects.Elements.EUnit;

type
  DexiModelsJson = public class(DexiLibraryTest)
   protected
    method TestSaveLoad(aFileName: String);
  public
    method TestJsonSaveLoad;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

method DexiModelsJson.TestSaveLoad(aFileName: String);
begin
  var Model := LoadModel(aFileName + '.dxi');
  var lBasicAttributes := Model.Root.CollectBasicNonLinked;
  var lSettings := new DexiJsonSettings(IncludeTimeInfo := false);
  lSettings.ModelElements := DexiJsonSettings.SetElements([
    DexiJsonAttributeElement.Name,
    DexiJsonAttributeElement.Description,
    DexiJsonAttributeElement.Id,
    DexiJsonAttributeElement.Indices,
    DexiJsonAttributeElement.Indent,
    DexiJsonAttributeElement.Level,
    DexiJsonAttributeElement.Path,
    DexiJsonAttributeElement.Type,
    DexiJsonAttributeElement.Scale,
    DexiJsonAttributeElement.Funct
  ]);
  lSettings.AlternativeElements := DexiJsonSettings.SetElements([
    DexiJsonAttributeElement.Name,
    DexiJsonAttributeElement.Id,
    DexiJsonAttributeElement.Path,
    DexiJsonAttributeElement.Indices,
    DexiJsonAttributeElement.AsString,
    DexiJsonAttributeElement.AsValue
  ]);
  for lFormat in ['Flat', 'Recursive'] do
  for lUseDexiStrings in ['Yes', 'No'] do
  for lValueFormat in ['Base0', 'Base1', 'Text'] do
  for lDistrFormat in ['Distr', 'Dict'] do
    begin
      lSettings.StructureFormat :=
        case lFormat of
          'Flat':       DexiJsonStructureFormat.Flat;
          'Recursive':  DexiJsonStructureFormat.Recursive;
        end;
      lSettings.UseDexiStringValues := lUseDexiStrings = 'Yes';
      lSettings.ValueFormat :=
        case lFormat of
          'Base0': ValueStringType.Zero;
          'Base1': ValueStringType.One;
          'Text':  ValueStringType.Text;
        end;
      lSettings.DistributionFormat :=
        case lFormat of
          'Distr': DexiJsonDistributionFormat.Distr;
          'Dict':  DexiJsonDistributionFormat.Dict;
        end;
      var lJsonFileName := $"{TestOutput}!!-{aFileName}_Dexi{lUseDexiStrings}-{lFormat}-{lValueFormat}-{lDistrFormat}.json";
      var lJsonWriter := new DexiJsonWriter(lSettings);
      lJsonWriter.SaveModelToFile(Model, lJsonFileName);
      var lJsonReader := new DexiJsonReader;
      var lRead := lJsonReader.LoadAlternativesFromFile(lJsonFileName, Model);
      Assert.IsTrue(lRead.Success);
      Assert.AreEqual(Model.AltCount, lRead.Alternatives.AltCount);
      for lAlt := 0 to Model.AltCount - 1 do
        Assert.IsTrue(DexiAlternatives.EqualAlternativesOn(lBasicAttributes, Model.Alternative[lAlt], lRead.Alternatives[lAlt]));
      File.Delete(lJsonFileName);
    end;
end;

method DexiModelsJson.TestJsonSaveLoad;
begin
  TestSaveLoad('Car');
  TestSaveLoad('CarDistr');
  TestSaveLoad('Cont3');
end;

end.
