// DexiJson.pas is part of
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
// DexiJson.pas implements classes that facilitate saving and loading a DexiModel to and from
// json-formatted files.

// In principle, json files are not ment to store DexiModels on a file system
// (the native .dxi XML format should be used for this purpose). Instead, their role is to exchange
// DexiModel data (full or partial) with other software tools and processes (such as Web API).
// The contents, extent and organization of an output json file can be largely controlled
// through DexiJsonSettings.
//
// The classes implemented here are:
// - JsonWriter and JsonReader: helper classess for writing and reading json values.
// - DexiJsonSettings: parameters deining the contents and organization of an output file.
// - DexiJsonWriter: to write DexiModel data on a json-formatted file.
// - DexiJsonRead: to read DexiModel data from a json-formatted file.
//
// The main output file settings are:
// - It is possible to choose whether to write the attribute structure (property 'IncludeModel'),
//   alternatives stored in the model ('IncludeAlternatives'), or both.
// - Property 'StructureFormat' determines whether attribute information is written in a single
//   json array (Flat) or is nested recursively according to the structure of attributes (Recursive).
// - Property 'ModelElements' determines what information is included with each attribute:
//     - 'Name': attribute name
//     - 'Description': attribute description
//     - 'Path': attribute name path
//     - 'Id': unique attribute ID
//     - 'Indices': sequence of attribute indices
//     - 'Type': attribute type
//     - 'Indent': indentation string (for displaying attributes in a tree)
//     - 'Level': attribute's level (Integer)
//     - 'Scale': attribute's scale
//     - 'Funct': attribute's aggregation function
// - Analogously, property 'AlternativeElements' determines information to be included with each attribute
//   when writing out data about alternatives. Additional information items for each value are:
//     - 'AsString': value formatted as a single string
//     - 'AsValue': value formatted in a "json's" way, possibly invoving a substructure of json elements
//     - 'AsOffsets': class offsets when qualitative-quantitative evaluations are available
//  - Property 'UseDexiStringValues' determines whether or not the new DEXiLibrary 2023 string format is used
//    for 'AsString' values. The new format is accurate, compact and easy to parse, but may be less readable
//    for humans. Recommended for json outputs that are expected to be re-read by software.
// ----------

namespace DexiLibrary;

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiJsonException = public class (Exception);

type
  JsonWriter = public class
  protected
    method AddValue(aObject: JsonObject; aKey, aValue: String);
    method AddValue(aObject: JsonObject; aKey: String; aValue: Boolean);
    method AddValue(aObject: JsonObject; aKey: String; aValue: Integer);
    method AddValue(aObject: JsonObject; aKey: String; aValue: Float);
  public
    constructor; empty;
  end;

type
  JsonReader = public class
  protected
    method ReadNode(aObject: JsonObject; aKey: String): JsonNode;
    method ReadString(aObject: JsonObject; aKey: String): String;
    method ReadBoolean(aObject: JsonObject; aKey: String): nullable Boolean;
    method ReadInteger(aObject: JsonObject; aKey: String): nullable Integer;
    method ReadFloat(aObject: JsonObject; aKey: String): nullable Float;
    method ReadObject(aObject: JsonObject; aKey: String): JsonObject;
    method ReadArray(aObject: JsonObject; aKey: String): JsonArray;
  end;

type
  DexiJsonStructureFormat = public enum (Flat, Recursive);
  DexiJsonAttributeElement = public flags
    (Name, Description, Path, Id, Indices, &Type, Indent, Level, Scale, Funct, AsString, AsValue, AsOffsets);
  DexiJsonAttributeType = public flags (Basic, Aggregate, Linked);
  DexiJsonInputs = public enum (None, List, IDs);
  DexiJsonDistributionFormat = public enum (Distr, Dict);
  DexiJsonDocumentElement = public enum (Model, Alternatives);

type
  DexiJsonSettings = public class (IUndoable)
  private
    fIncludeModel: nullable Boolean;
    fIncludeAlternatives: nullable Boolean;
    fStructureFormat: nullable DexiJsonStructureFormat;
    fModelElements: nullable Integer;       // DexiJsonAttributeElement flags
    fAlternativeElements: nullable Integer; // DexiJsonAttributeElement flags
    fAttributeTypes: nullable Integer;      // DexiJsonAttributeType flags
    fModelInputs: nullable DexiJsonInputs;
    fAlternativeInputs: nullable DexiJsonInputs;
    fUseDexiStringValues: nullable Boolean;
    fValueFormat: nullable ValueStringType;
    fDistributionFormat: nullable DexiJsonDistributionFormat;
    fFloatDecimals: nullable Integer;
    fMembershipDecimals: nullable Integer;
    fJsonIndent: nullable Boolean;
    fIncludeTimeInfo: nullable Boolean;
  public
    constructor; empty;
    constructor (aSettings: DexiJsonSettings);
    method Assign(aSettings: DexiJsonSettings); virtual;
    method SetDefaults; virtual;
    class method SetElements(aElements: sequence of DexiJsonAttributeElement): Integer;
    class method SetAttributeTypes(aTypes: sequence of DexiJsonAttributeType): Integer;
    method IncludesAttributeType(aType: DexiJsonAttributeType): Boolean;
    method AddType(aType: DexiJsonAttributeType);
    method IncludesElement(aState: nullable Integer; aElement: DexiJsonAttributeElement): Boolean;
    method AddElement(aState: nullable Integer; aElement: DexiJsonAttributeElement): Integer;
    property IncludeModel: nullable Boolean read fIncludeModel write fIncludeModel;
    property IncludeAlternatives: nullable Boolean read fIncludeAlternatives write fIncludeAlternatives;
    property StructureFormat: nullable DexiJsonStructureFormat read fStructureFormat write fStructureFormat;
    property ModelElements: nullable Integer read fModelElements write fModelElements;
    property AlternativeElements: nullable Integer read fAlternativeElements write fAlternativeElements;
    property AttributeTypes:  nullable Integer read fAttributeTypes write fAttributeTypes;
    property ModelInputs: nullable DexiJsonInputs read fModelInputs write fModelInputs;
    property AlternativeInputs: nullable DexiJsonInputs read fAlternativeInputs write fAlternativeInputs;
    property UseDexiStringValues: nullable Boolean read fUseDexiStringValues write fUseDexiStringValues;
    property ValueFormat: nullable ValueStringType read fValueFormat write fValueFormat;
    property DistributionFormat: nullable DexiJsonDistributionFormat read fDistributionFormat write fDistributionFormat;
    property FloatDecimals: nullable Integer read fFloatDecimals write fFloatDecimals;
    property MembershipDecimals: nullable Integer read fMembershipDecimals write fMembershipDecimals;
    property JsonIndent: nullable Boolean read fJsonIndent write fJsonIndent;
    property IncludeTimeInfo: nullable Boolean read fIncludeTimeInfo write fIncludeTimeInfo;

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>);
    method EqualStateAs(aObj: IUndoable): Boolean;
    method GetUndoState: IUndoable;
    method SetUndoState(aState: IUndoable);
  end;

type
  DexiJsonWriter = public class (JsonWriter)
  private
    fSettings: DexiJsonSettings;
    fDocumentElement: DexiJsonDocumentElement;
    fElements: nullable Integer;
    fInputs: DexiJsonInputs;
    fScaleStrings: DexiScaleStrings;
  protected
    method SetSettings(aSettings: DexiJsonSettings);
    method SetDocumentElement(aDocumentElement: DexiJsonDocumentElement);
    method ElementIncluded(aDocumentElement: DexiJsonAttributeElement): Boolean;
    method AttTypeIncluded(aAtt: DexiAttribute): Boolean;
    method AddArray(aObject: JsonObject; aKey: String; aArray: IntArray);
    method AddArray(aObject: JsonObject; aKey: String; aArray: FltArray);
    method AddNameDescription(aObject: JsonObject; aDexiObject: DexiObject; aForce: Boolean);
    method AddNameDescription(aObject: JsonObject; aAlternative: IDexiAlternative; aForce: Boolean);
    method AddHeaderTo(aObject: JsonObject); virtual;
    method AddFunct(aObject: JsonObject; aFunct: DexiTabularFunction);
    method AddFunct(aObject: JsonObject; aFunct: DexiDiscretizeFunction);
    method AddAltValueAsInt(aObject: JsonObject; aScale: DexiDiscreteScale; aValue: Integer);
    method AddAltValueAsIntSet(aObject: JsonObject; aScale: DexiDiscreteScale; aValue: IntArray);
    method AddAltValueAsDistribution(aObject: JsonObject; aScale: DexiDiscreteScale; aValue: Distribution);
    method AddAltValue(aObject: JsonObject; aAtt: DexiAttribute; aValue: DexiValue; aOffsets: ClassOffsets := nil);
    method DexiJsonScale(aScale: DexiScale): JsonObject;
    method DexiJsonFunct(aFunct: DexiFunction): JsonObject;
    method DexiJsonAttribute(aAtt: DexiAttribute; aAlt: IDexiAlternative; aOffAlt: DexiOffAlternative := nil): JsonObject;
    method DexiJsonData(aModel: DexiModel; aAlt: IDexiAlternative; aOffAlt: DexiOffAlternative := nil): JsonArray;
  public
    constructor (aSettings: DexiJsonSettings := nil);
    method DexiJsonModel(aModel: DexiModel): JsonObject;
    method DexiJsonAlternatives(aModel: DexiModel; aAlternatives: IDexiAlternatives; aOffAlternatives: DexiOffAlternatives := nil): JsonArray;
    method DexiJsonDocument(aObject: JsonObject; aWithHeader: Boolean := true): JsonObject;
    method SaveModelToString(aModel: DexiModel): String;
    method SaveModelToFile(aModel: DexiModel; aFileName: String);
    property Settings: DexiJsonSettings read fSettings write SetSettings;
  end;

type
  DexiJsonReaderResponse = public class
  private
    // per Json document
    fSuccess: Boolean;
    fAlternatives: DexiAlternatives;
    fWarnings: List<String>;
    fErrors: List<String>;
    // per alternative
    fAltName: String;
    fUnresolvedAttributes: DexiAttributeList;
    fDuplicateAttributes: DexiAttributeList;
  public
    property Success: Boolean read fSuccess write fSuccess;
    property Alternatives: DexiAlternatives read fAlternatives;
    property Warnings: ImmutableList<String> read fWarnings;
    property Errors: ImmutableList<String> read fErrors;
    constructor;
    method AddError(aMessage: String);
    method AddWarning(aMessage: String);
    method ResolveAttribute(aAtt: DexiAttribute);
    method OpenAlternative(aAltName: String; aModel: DexiModel); virtual;
    method CloseAlternative; virtual;
    method AddAlternative(aAlt: DexiAlternative);
  end;

type
  DexiJsonReader = public class  (JsonReader)
  private
    fModel: weak DexiModel;
    fSettings := new DexiJsonSettings;
    fResponse: DexiJsonReaderResponse;
  protected
    method ReadSingle(aNode: JsonNode; aAtt: DexiAttribute): DexiValue;
    method ReadSet(aNode: JsonNode; aAtt: DexiAttribute): DexiValue;
    method ReadDistr(aNode: JsonNode; aAtt: DexiAttribute): DexiValue;
    method GetAttribute(aValObj: JsonObject): DexiAttribute;
    method LoadSettings(aObject: JsonObject);
    method LoadAttribute(aValObj: JsonObject; aAlt: DexiAlternative);
    method LoadValue(aValObj: JsonObject; aAtt: DexiAttribute; aAlt: DexiAlternative);
    method LoadAlternative(aAltObj: JsonObject);
    method LoadAlternatives(aArray: JsonArray);
  public
    method LoadAlternativesFromString(aString: String; aModel: DexiModel): DexiJsonReaderResponse;
    method LoadAlternativesFromFile(aFileName: String; aModel: DexiModel): DexiJsonReaderResponse;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION JsonWriter}

method JsonWriter.AddValue(aObject: JsonObject; aKey, aValue: String);
begin
  aObject.Add(aKey, new JsonStringValue(aValue));
end;

method JsonWriter.AddValue(aObject: JsonObject; aKey: String; aValue: Boolean);
begin
  aObject.Add(aKey, new JsonBooleanValue(aValue));
end;

method JsonWriter.AddValue(aObject: JsonObject; aKey: String; aValue: Integer);
begin
  aObject.Add(aKey, new JsonIntegerValue(aValue));
end;

method JsonWriter.AddValue(aObject: JsonObject; aKey: String; aValue: Float);
begin
  if Consts.IsInfinity(aValue) or Consts.IsNaN(aValue) then
    aObject.Add(aKey, new JsonStringValue(Utils.FltToStr(aValue, true)))
  else
    aObject.Add(aKey, new JsonFloatValue(aValue));
end;

{$ENDREGION}

{$REGION JsonReader}

method JsonReader.ReadNode(aObject: JsonObject; aKey: String): JsonNode;
begin
  result := aObject[aKey];
end;

method JsonReader.ReadString(aObject: JsonObject; aKey: String): String;
begin
  var lNode := ReadNode(aObject, aKey);
  if lNode = nil then
    result := nil
  else
    try
      result := lNode.StringValue;
    except
      raise new DexiJsonException(String.Format(DexiString.JStringExpected, aKey));
    end;
end;

method JsonReader.ReadBoolean(aObject: JsonObject; aKey: String): nullable Boolean;
begin
  var lNode := ReadNode(aObject, aKey);
  if lNode = nil then
    result := nil
  else
    try
      result := lNode.BooleanValue;
    except
      raise new DexiJsonException(String.Format(DexiString.JBooleanExpected, aKey));
    end;
end;

method JsonReader.ReadInteger(aObject: JsonObject; aKey: String): nullable Integer;
begin
  var lNode := ReadNode(aObject, aKey);
  if lNode = nil then
    result := nil
  else
    try
      result := lNode.IntegerValue;
    except
      raise new DexiJsonException(String.Format(DexiString.JIntegerExpected, aKey));
    end;
end;

method JsonReader.ReadFloat(aObject: JsonObject; aKey: String): nullable Float;
begin
  var lNode := ReadNode(aObject, aKey);
  if lNode = nil then
    result := nil
  else
    try
      result := lNode.FloatValue;
    except
      raise new DexiJsonException(String.Format(DexiString.JFloatExpected, aKey));
    end;
end;

method JsonReader.ReadObject(aObject: JsonObject; aKey: String): JsonObject;
begin
  var lNode := ReadNode(aObject, aKey);
  if lNode = nil then
    result := nil
  else if lNode is JsonObject then
    result := JsonObject(lNode)
  else
    raise new DexiJsonException(String.Format(DexiString.JObjectExpected, aKey));
end;

method JsonReader.ReadArray(aObject: JsonObject; aKey: String): JsonArray;
begin
  var lNode := ReadNode(aObject, aKey);
  if lNode = nil then
    result := nil
  else if lNode is JsonArray then
    result := JsonArray(lNode)
  else
    raise new DexiJsonException(String.Format(DexiString.JArrayExpected, aKey));
end;

{$ENDREGION}

{$REGION DexiJsonSettings}

constructor DexiJsonSettings(aSettings: DexiJsonSettings);
begin
  inherited constructor;
  Assign(aSettings);
end;

method DexiJsonSettings.Assign(aSettings: DexiJsonSettings);
begin
  if aSettings = nil then
    begin
      Assign(new DexiJsonSettings);
      exit;
    end;
  IncludeModel := aSettings.IncludeModel;
  IncludeAlternatives := aSettings.IncludeAlternatives;
  StructureFormat := aSettings.StructureFormat;
  ModelElements := aSettings.ModelElements;
  AlternativeElements := aSettings.AlternativeElements;
  ModelInputs := aSettings.ModelInputs;
  AlternativeInputs := aSettings.AlternativeInputs;
  AttributeTypes := aSettings.AttributeTypes;
  UseDexiStringValues := aSettings.UseDexiStringValues;
  ValueFormat := aSettings.ValueFormat;
  DistributionFormat := aSettings.DistributionFormat;
  FloatDecimals := aSettings.FloatDecimals;
  MembershipDecimals := aSettings.MembershipDecimals;
  JsonIndent := aSettings.JsonIndent;
  IncludeTimeInfo := aSettings.IncludeTimeInfo;
end;

method DexiJsonSettings.SetDefaults;
begin
  if IncludeModel = nil then
    IncludeModel := true;
  if IncludeAlternatives = nil then
    IncludeAlternatives := true;
  if (StructureFormat = nil) or ((AttributeTypes <> nil) and (AttributeTypes <> 0)) then
     StructureFormat := DexiJsonStructureFormat.Flat;
  if ModelElements = nil then
    ModelElements := SetElements([
      DexiJsonAttributeElement.Name,
      DexiJsonAttributeElement.Description,
      DexiJsonAttributeElement.Id,
      DexiJsonAttributeElement.Path,
      DexiJsonAttributeElement.Type,
      DexiJsonAttributeElement.Scale,
      DexiJsonAttributeElement.Funct
    ]);
  if AlternativeElements = nil then
    AlternativeElements := SetElements([
      DexiJsonAttributeElement.Name,
      DexiJsonAttributeElement.Id,
      DexiJsonAttributeElement.Path,
      DexiJsonAttributeElement.AsString,
      DexiJsonAttributeElement.AsValue,
      DexiJsonAttributeElement.AsOffsets
    ]);
  if ModelInputs = nil then
    ModelInputs := DexiJsonInputs.List;
  if AlternativeInputs = nil then
    AlternativeInputs := DexiJsonInputs.IDs;
  if UseDexiStringValues = nil then
    UseDexiStringValues := true;
  if ValueFormat = nil then
    ValueFormat := ValueStringType.Text;
  if DistributionFormat = nil then
    DistributionFormat := DexiJsonDistributionFormat.Dict;
  if FloatDecimals = nil then
    FloatDecimals := -1;
  if MembershipDecimals = nil then
    MembershipDecimals := -1;
  if JsonIndent = nil then
    JsonIndent := true;
  if IncludeTimeInfo = nil then
    IncludeTimeInfo := true;
end;

class method DexiJsonSettings.SetElements(aElements: sequence of DexiJsonAttributeElement): Integer;
begin
  result := 0;
  for each lElement in aElements do
    result := Utils.AddFlag(result, Integer(lElement));
end;

method DexiJsonSettings.IncludesAttributeType(aType: DexiJsonAttributeType): Boolean;
begin
  result := (fAttributeTypes <> nil) and Utils.IncludesFlag(fAttributeTypes, Integer(aType));
end;

method DexiJsonSettings.AddType(aType: DexiJsonAttributeType);
begin
  if fAttributeTypes = nil then
    fAttributeTypes := 0;
  fAttributeTypes := Utils.AddFlag(fAttributeTypes, Integer(aType));
end;

class method DexiJsonSettings.SetAttributeTypes(aTypes: sequence of DexiJsonAttributeType): Integer;
begin
  result := 0;
  for each lType in aTypes do
    result := Utils.AddFlag(result, Integer(lType));
end;

method DexiJsonSettings.IncludesElement(aState: nullable Integer; aElement: DexiJsonAttributeElement): Boolean;
begin
  result := (aState <> nil) and Utils.IncludesFlag(aState, Integer(aElement));
end;

method DexiJsonSettings.AddElement(aState: nullable Integer; aElement: DexiJsonAttributeElement): Integer;
begin
  var lState :=
    if aState = nil then 0
    else aState;
  result := Utils.AddFlag(lState, Integer(aElement));
end;

method DexiJsonSettings.CollectUndoableObjects(aList: List<IUndoable>);
begin
  // none
end;

method DexiJsonSettings.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiJsonSettings then
    exit false;
  var lSettings := DexiJsonSettings(aObj);
  result :=
    (fIncludeModel = lSettings.fIncludeModel) and
    (fIncludeAlternatives = lSettings.fIncludeAlternatives) and
    (fStructureFormat = lSettings.fStructureFormat) and
    (fModelElements = lSettings.fModelElements) and
    (fAlternativeElements = lSettings.fAlternativeElements) and
    (fAttributeTypes = lSettings.fAttributeTypes) and
    (fModelInputs = lSettings.fModelInputs) and
    (fAlternativeInputs = lSettings.fAlternativeInputs) and
    (fUseDexiStringValues = lSettings.fUseDexiStringValues) and
    (fValueFormat = lSettings.fValueFormat) and
    (fDistributionFormat = lSettings.fDistributionFormat) and
    (fFloatDecimals = lSettings.fFloatDecimals) and
    (fMembershipDecimals = lSettings.fMembershipDecimals) and
    (fJsonIndent = lSettings.fJsonIndent) and
    (fIncludeTimeInfo = lSettings.fIncludeTimeInfo);
end;

method DexiJsonSettings.GetUndoState: IUndoable;
begin
  result := new DexiJsonSettings(self);
end;

method DexiJsonSettings.SetUndoState(aState: IUndoable);
begin
  var lSettings := aState as DexiJsonSettings;
  Assign(lSettings);
end;

{$ENDREGION}

{$REGION DexiJsonWriter}

constructor DexiJsonWriter(aSettings: DexiJsonSettings := nil);
begin
  inherited constructor;
  SetSettings(aSettings);
end;

method DexiJsonWriter.AddArray(aObject: JsonObject; aKey: String; aArray: IntArray);
begin
  if aArray = nil then
    exit;
  if Settings.UseDexiStringValues then
    AddValue(aObject, aKey, Utils.IntArrayToStr(aArray))
  else
    begin
      var lArray := new JsonArray;
      for i := low(aArray) to high(aArray) do
        lArray.Add(new JsonIntegerValue(aArray[i]));
      aObject.Add(aKey, lArray);
    end;
end;

method DexiJsonWriter.AddArray(aObject: JsonObject; aKey: String; aArray: FltArray);
begin
  if aArray = nil then
    exit;
  if Settings.UseDexiStringValues then
    AddValue(aObject, aKey, Utils.FltArrayToStr(aArray))
  else
    begin
      var lArray := new JsonArray;
      for i := low(aArray) to high(aArray) do
        lArray.Add(new JsonFloatValue(aArray[i]));
      aObject.Add(aKey, lArray);
    end;
end;

method DexiJsonWriter.AddNameDescription(aObject: JsonObject; aDexiObject: DexiObject; aForce: Boolean);
begin
  if aForce or ElementIncluded(DexiJsonAttributeElement.Name) then
    if not String.IsNullOrEmpty(aDexiObject.Name) then
      AddValue(aObject, 'name', aDexiObject.Name);
  if aForce or ElementIncluded(DexiJsonAttributeElement.Description) then
    if not String.IsNullOrEmpty(aDexiObject.Description) then
      AddValue(aObject, 'description', aDexiObject.Description);
end;

method DexiJsonWriter.AddNameDescription(aObject: JsonObject; aAlternative: IDexiAlternative; aForce: Boolean);
begin
  if aForce or ElementIncluded(DexiJsonAttributeElement.Name) then
    if not String.IsNullOrEmpty(aAlternative.Name) then
      AddValue(aObject, 'name', aAlternative.Name);
  if aForce or ElementIncluded(DexiJsonAttributeElement.Description) then
    if not String.IsNullOrEmpty(aAlternative.Description) then
      AddValue(aObject, 'description', aAlternative.Description);
end;

method DexiJsonWriter.SetSettings(aSettings: DexiJsonSettings);
begin
  fSettings :=
    if aSettings = nil then new DexiJsonSettings
    else new DexiJsonSettings(aSettings);
  fSettings.SetDefaults;
  fScaleStrings := new DexiScaleStrings(true, fSettings.ValueFormat, fSettings.MembershipDecimals);
  fScaleStrings.Simple := true;
end;

method DexiJsonWriter.SetDocumentElement(aDocumentElement: DexiJsonDocumentElement);
begin
  fDocumentElement := aDocumentElement;
  fElements :=
    if fDocumentElement = DexiJsonDocumentElement.Model then Settings.ModelElements
    else Settings.AlternativeElements;
  fInputs :=
    if fDocumentElement = DexiJsonDocumentElement.Model then Settings.ModelInputs
    else Settings.AlternativeInputs;
  if Settings.StructureFormat = DexiJsonStructureFormat.Recursive then
    fInputs := DexiJsonInputs.List
  else
     if fDocumentElement = DexiJsonDocumentElement.Alternatives then
       if fInputs = DexiJsonInputs.List then
         fInputs := DexiJsonInputs.IDs;
end;

method DexiJsonWriter.ElementIncluded(aDocumentElement: DexiJsonAttributeElement): Boolean;
begin
  result := (fElements = nil) or Utils.IncludesFlag(fElements, Integer(aDocumentElement));
end;

method DexiJsonWriter.AttTypeIncluded(aAtt: DexiAttribute): Boolean;
begin
  with lTypes := Settings.AttributeTypes do
    result :=
      (lTypes = nil) or
      ((aAtt.IsBasic) and Utils.IncludesFlag(lTypes, Integer(DexiJsonAttributeType.Basic))) or
      ((aAtt.IsAggregate) and Utils.IncludesFlag(lTypes, Integer(DexiJsonAttributeType.Aggregate))) or
      ((aAtt.IsLinked) and Utils.IncludesFlag(lTypes, Integer(DexiJsonAttributeType.Linked)));
end;

method DexiJsonWriter.AddHeaderTo(aObject: JsonObject);
begin
  AddValue(aObject, 'software', DexiString.DexSoftware);
  AddValue(aObject, 'library', DexiLibrary.LibraryString);
  if Settings.IncludeTimeInfo then
    AddValue(aObject, 'time',  Utils.ISODateTimeStr(DateTime.UtcNow));
  AddValue(aObject, 'structureFormat',
    case Settings.StructureFormat of
      DexiJsonStructureFormat.Flat: 'flat';
      DexiJsonStructureFormat.Recursive: 'recursive';
      else nil;
    end
    );
  AddValue(aObject, 'valueFormat',
    case Settings.ValueFormat of
      ValueStringType.Zero: 'zero';
      ValueStringType.One: 'one';
      ValueStringType.Text: 'text';
      else nil;
    end
    );
  AddValue(aObject, 'valueStrings', Settings.UseDexiStringValues);
  AddValue(aObject, 'distrFormat',
    case Settings.DistributionFormat of
      DexiJsonDistributionFormat.Dict: 'dict';
      DexiJsonDistributionFormat.Distr: 'distr';
      else nil;
    end
    );
end;

method DexiJsonWriter.AddFunct(aObject: JsonObject; aFunct: DexiTabularFunction);
begin
  var lFncObject := new JsonObject;
  aObject.Add('table', lFncObject);
   if aFunct.Attribute <> nil then
    AddArray(lFncObject, 'dimension', aFunct.Attribute.Dimension);
  if aFunct.UseWeights then
    begin
      AddValue(lFncObject, 'weights', Utils.FltArrayToStr(aFunct.RequiredWeights));
      AddValue(lFncObject, 'weightsLoc', Utils.FltArrayToStr(aFunct.ActualWeights));
      AddValue(lFncObject, 'weightsLocNorm', Utils.FltArrayToStr(aFunct.NormActualWeights, 2));
    end;
  if not aFunct.UseConsist then
    AddValue(lFncObject, 'consist', aFunct.UseConsist);
  if aFunct.Rounding <> 0 then
    AddValue(lFncObject, 'rounding', Utils.IntToStr(aFunct.Rounding));
  var lRulesObject := new JsonArray;
  lFncObject.Add('rules', lRulesObject);
  for r := 0 to aFunct.Count - 1 do
    begin
      var lRuleObject := new JsonObject;
      AddArray(lRuleObject, 'args', aFunct.ArgValues[r]);
      AddValue(lRuleObject, 'value', DexiValue.ToString(aFunct.RuleValue[r]));
      AddValue(lRuleObject, 'entered', aFunct.RuleEntered[r]);
      lRulesObject.Add(lRuleObject);
    end;
end;

method DexiJsonWriter.AddFunct(aObject: JsonObject; aFunct: DexiDiscretizeFunction);
begin
  var lFncObject := new JsonObject;
  aObject.Add('discretize', lFncObject);
  if not aFunct.UseConsist then
    AddValue(lFncObject, 'consist', aFunct.UseConsist);
  var lObject := new JsonArray;
  lFncObject.Add('bounds', lObject);
  for i := 1 to aFunct.IntervalCount - 1 do
    begin
      var lBound := aFunct.IntervalLowBound[i];
      var lBndObject := new JsonObject;
      AddValue(lBndObject, 'value', Utils.FltToStr(lBound.Bound));
      AddValue(lBndObject, 'associate',
        if lBound.Association = DexiBoundAssociation.Down then 'down' else 'up');
      lObject.Add(lBndObject);
    end;
  lObject := new JsonArray;
  lFncObject.Add('intervals', lObject);
  for i := 0 to aFunct.IntervalCount - 1 do
    begin
      var lIntObject := new JsonObject;
      AddValue(lIntObject, 'value', DexiValue.ToString(aFunct.IntervalValue[i]));
      AddValue(lIntObject, 'entered', aFunct.IntervalEntered[i]);
      lObject.Add(lIntObject);
    end;
end;

method DexiJsonWriter.AddAltValueAsInt(aObject: JsonObject; aScale: DexiDiscreteScale; aValue: Integer);
begin
  if Settings.ValueFormat = ValueStringType.Text then
    AddValue(aObject, 'value', aScale.Names[aValue])
  else
    begin
      if Settings.ValueFormat = ValueStringType.One then
        inc(aValue);
      AddValue(aObject, 'value', aValue);
    end;
end;

method DexiJsonWriter.AddAltValueAsIntSet(aObject: JsonObject; aScale: DexiDiscreteScale; aValue: IntArray);
begin
  AddValue(aObject, 'valueType', 'set');
  if Settings.ValueFormat = ValueStringType.Text then
    begin
      var lArray := new JsonArray;
      for each el in aValue do
        lArray.Add(new JsonStringValue(aScale.Names[el]));
      aObject.Add('value', lArray);
    end
  else
    begin
      if Settings.ValueFormat = ValueStringType.One then
        for i := low(aValue) to high(aValue) do
          inc(aValue[i]);
      AddArray(aObject, 'value', aValue);
    end;
end;

method DexiJsonWriter.AddAltValueAsDistribution(aObject: JsonObject; aScale: DexiDiscreteScale; aValue: Distribution);
begin
  AddValue(aObject, 'valueType', 'distribution');
  if Settings.DistributionFormat = DexiJsonDistributionFormat.Distr then
    begin
      var lMem := Utils.NewFltArray(aScale.Count);
      for lIdx := 0 to aScale.Count - 1 do
        lMem[lIdx] := Values.GetDistribution(aValue, lIdx);
      AddArray(aObject, 'value', lMem);
    end
  else
    begin
      var lValObject := new JsonObject;
      aObject.Add('value', lValObject);
      for lIdx := 0 to aScale.Count - 1 do
        begin
          var lMem := Values.GetDistribution(aValue, lIdx);
          if not Utils.FloatEq(lMem, 0.0) then
            begin
              var lKey :=
                case Settings.ValueFormat of
                  ValueStringType.Zero: Utils.IntToStr(lIdx);
                  ValueStringType.One: Utils.IntToStr(lIdx + 1);
                  ValueStringType.Text: aScale.Names[lIdx];
                end;
              AddValue(lValObject, lKey, lMem);
            end;
          end;
    end;
end;

method DexiJsonWriter.AddAltValue(aObject: JsonObject; aAtt: DexiAttribute; aValue: DexiValue; aOffsets: ClassOffsets := nil);
begin
  if aAtt:Scale = nil then
    exit;
  if ElementIncluded(DexiJsonAttributeElement.AsString) then
    if Settings.UseDexiStringValues then
      AddValue(aObject, 'string', DexiValue.ToString(aValue))
    else
      AddValue(aObject, 'string', fScaleStrings.ValueOnScaleString(aValue, aAtt.Scale));
  if ElementIncluded(DexiJsonAttributeElement.AsValue) then
    begin
      if aValue = nil then
        AddValue(aObject, 'valueType', 'null')
      else if not aValue.IsDefined then
        AddValue(aObject, 'valueType', 'undefined')
      else if aAtt.Scale is DexiContinuousScale then
        AddValue(aObject, 'value', aValue.AsFloat)
      else
        with lScale := DexiDiscreteScale(aAtt.Scale) do
          if aValue.HasIntSingle then
            AddAltValueAsInt(aObject, lScale, aValue.AsInteger)
          else if aValue.HasIntSet then
            AddAltValueAsIntSet(aObject, lScale, aValue.AsIntSet)
          else
            AddAltValueAsDistribution(aObject, lScale, aValue.AsDistribution);
    end;
  if (aOffsets <> nil) and ElementIncluded(DexiJsonAttributeElement.AsOffsets) then
    begin
      var lIntOffsets := Offsets.ClassToIntOffsets(aOffsets);
      AddValue(aObject, 'offsets', fScaleStrings.ValueOnScaleString(lIntOffsets, aAtt.Scale));
    end;
end;

method DexiJsonWriter.DexiJsonScale(aScale: DexiScale): JsonObject;
begin
  result := new JsonObject;
  AddValue(result, 'order',
      case aScale.Order of
        DexiOrder.Descending: 'descending';
        DexiOrder.Ascending: 'ascending';
        else 'none';
      end);
  if not String.IsNullOrEmpty(aScale.ScaleUnit) then
    AddValue(result, 'unit', aScale.ScaleUnit);
  AddValue(result, 'interval', aScale.IsInterval);
  if aScale is DexiDiscreteScale then
    begin
      var lScale := DexiDiscreteScale(aScale);
      AddValue(result, 'type', 'discrete');
      var lValArray := new JsonArray;
      result.Add('values', lValArray);
      for i := 0 to lScale.Count - 1 do
        begin
          var lScaleValue := new JsonObject;
          lValArray.Add(lScaleValue);
          AddValue(lScaleValue, 'name', lScale.Names[i]);
          if not String.IsNullOrEmpty(lScale.Descriptions[i]) then
            AddValue(lScaleValue, 'description', lScale.Descriptions[i]);
          var s :=
            if lScale.IsBad(i) then 'bad'
            else if lScale.IsGood(i) then 'good'
            else 'neutral';
          AddValue(lScaleValue, 'group', s);
        end;
    end;
  if aScale is DexiContinuousScale then
    begin
      var lScale := DexiContinuousScale(aScale);
      AddValue(result, 'type', 'continuous');
      if not Consts.IsNegativeInfinity(lScale.BGLow) then
        AddValue(result, 'low', lScale.BGLow);
      if not  Consts.IsPositiveInfinity(lScale.BGHigh) then
        AddValue(result, 'high', lScale.BGHigh);
    end;
end;

method DexiJsonWriter.DexiJsonFunct(aFunct: DexiFunction): JsonObject;
begin
  result := new JsonObject;
  AddNameDescription(result, aFunct, true);
  if aFunct is DexiTabularFunction then
    AddFunct(result, DexiTabularFunction(aFunct))
  else
    AddFunct(result, DexiDiscretizeFunction(aFunct));
end;

method DexiJsonWriter.DexiJsonAttribute(aAtt: DexiAttribute; aAlt: IDexiAlternative; aOffAlt: DexiOffAlternative := nil): JsonObject;
begin
  result := new JsonObject;
  AddNameDescription(result, aAtt, false);
  if ElementIncluded(DexiJsonAttributeElement.Path) then
    AddValue(result, 'path', aAtt.SecureParentPath);
  if ElementIncluded(DexiJsonAttributeElement.Id) then
    AddValue(result, 'id', aAtt.ID);
  if ElementIncluded(DexiJsonAttributeElement.Indices) then
    AddValue(result, 'indices', Utils.IntArrayToStr(aAtt.ParentIndices));
  if ElementIncluded(DexiJsonAttributeElement.Type) then
    begin
      var lType :=
        if aAtt.IsAggregate then DexiJsonAttributeType.Aggregate
        else if aAtt.IsLinked then DexiJsonAttributeType.Linked
        else if aAtt.IsBasic then DexiJsonAttributeType.Basic
        else nil;
      AddValue(result, 'type',
        case lType of
          DexiJsonAttributeType.Basic: 'basic';
          DexiJsonAttributeType.Aggregate: 'aggregate';
          DexiJsonAttributeType.Linked: 'linked';
          else nil;
        end
      );
    end;
  if ElementIncluded(DexiJsonAttributeElement.Indent) then
    AddValue(result, 'indent', aAtt.TreeIndent);
  if ElementIncluded(DexiJsonAttributeElement.Level) then
    AddValue(result, 'level', aAtt.Level);
  if ElementIncluded(DexiJsonAttributeElement.Scale) then
    if aAtt.Scale <> nil then
      result.Add('scale', DexiJsonScale(aAtt.Scale));
  if ElementIncluded(DexiJsonAttributeElement.Funct) then
    if aAtt.Funct <> nil then
      result.Add('function', DexiJsonFunct(aAtt.Funct));
  if aAlt <> nil then
    AddAltValue(result, aAtt, aAlt.Value[aAtt], aOffAlt:Value[aAtt]);
  if aAtt.InpCount = 0 then
    exit;
  if fInputs = DexiJsonInputs.List then
    begin
      var lInputs := new JsonArray;
      for lInp := 0 to aAtt.InpCount - 1 do
        lInputs.Add(DexiJsonAttribute(aAtt.Inputs[lInp], aAlt, aOffAlt));
      result.Add('inputs', lInputs);
    end;
  if (fInputs = DexiJsonInputs.IDs) and (aAlt = nil) then
    begin
      var lInputs := new JsonArray;
      for lInp := 0 to aAtt.InpCount - 1 do
        lInputs.Add(aAtt.Inputs[lInp].ID);
      result.Add('inputs', lInputs);
    end;
end;

method DexiJsonWriter.DexiJsonData(aModel: DexiModel; aAlt: IDexiAlternative; aOffAlt: DexiOffAlternative := nil): JsonArray;
begin
  if aAlt = nil then
    SetDocumentElement(DexiJsonDocumentElement.Model)
  else
    SetDocumentElement(DexiJsonDocumentElement.Alternatives);
  result := new JsonArray;
  case Settings.StructureFormat of
    DexiJsonStructureFormat.Flat:
      begin
        var lAttributes := aModel.Root.CollectInputs;
        for each lAtt in lAttributes do
          if AttTypeIncluded(lAtt) then
            result.Add(DexiJsonAttribute(lAtt, aAlt, aOffAlt));
      end;
    DexiJsonStructureFormat.Recursive:
      begin
        for lAtt := 0 to aModel.Root.InpCount - 1 do
          result.Add(DexiJsonAttribute(aModel.Root.Inputs[lAtt], aAlt, aOffAlt));
      end;
  end;
end;

method DexiJsonWriter.DexiJsonModel(aModel: DexiModel): JsonObject;
begin
  result := new JsonObject;
  aModel.MakeUniqueAttributeIDs;
  AddNameDescription(result, aModel, true);
  if Settings.IncludeTimeInfo then
    begin
      AddValue(result, 'created',  aModel.Created);
      AddValue(result, 'modified',  aModel.Modified);
    end;
  if Settings.IncludeModel then
    result.Add('model', DexiJsonData(aModel, nil, nil));
  if Settings.IncludeAlternatives then
    result.Add('alternatives', DexiJsonAlternatives(aModel, aModel, aModel.OffAlternatives));
end;

method DexiJsonWriter.DexiJsonAlternatives(aModel: DexiModel; aAlternatives: IDexiAlternatives; aOffAlternatives: DexiOffAlternatives := nil): JsonArray;
begin
  if aOffAlternatives = nil then
    aOffAlternatives := aModel.OffAlternatives;
  result := new JsonArray;
  var lAlternatives := new JsonArray;
  for lAlt := 0 to aAlternatives.AltCount - 1 do
    if aModel.Selected[lAlt] then
      begin
        var lAltObj := new JsonObject;
        var lAlternative := aAlternatives.Alternative[lAlt];
        var lOffAlternative :=
          if aOffAlternatives = nil then nil
          else if 0 <= lAlt < aOffAlternatives.Count then aOffAlternatives[lAlt]
          else nil;
        AddNameDescription(lAltObj, lAlternative, true);
        var lAltValues := DexiJsonData(aModel, lAlternative, lOffAlternative);
        lAltObj.Add('values', lAltValues);
        lAlternatives.Add(lAltObj);
      end;
  result := lAlternatives;
end;

method DexiJsonWriter.DexiJsonDocument(aObject: JsonObject; aWithHeader: Boolean := true): JsonObject;
begin
  var lObject :=
    if aObject = nil then new JsonObject
    else aObject;
  if aWithHeader then
    AddHeaderTo(aObject);
  result := lObject;
end;

method DexiJsonWriter.SaveModelToString(aModel: DexiModel): String;
begin
  var lObject := DexiJsonModel(aModel);
  var lDocument := DexiJsonDocument(lObject);
  var lFormat :=
    if Settings.JsonIndent then JsonFormat.HumanReadable
    else JsonFormat.Minimal;
  result := lDocument.ToJsonString(lFormat);
end;

method DexiJsonWriter.SaveModelToFile(aModel: DexiModel; aFileName: String);
begin
  var lString := SaveModelToString(aModel);
  File.WriteText(aFileName, lString);
end;

{$ENDREGION}

{$REGION DexiJsonReaderResponse}

constructor DexiJsonReaderResponse;
begin
  inherited constructor;
  fSuccess := true;
  fWarnings := new List<String>;
  fErrors := new List<String>;
end;

method DexiJsonReaderResponse.AddError(aMessage: String);
begin
  fErrors.Add(aMessage);
  fSuccess := false;
end;

method DexiJsonReaderResponse.AddWarning(aMessage: String);
begin
  fWarnings.Add(aMessage);
end;

method DexiJsonReaderResponse.ResolveAttribute(aAtt: DexiAttribute);
begin
  if aAtt = nil then
    exit;
  if fUnresolvedAttributes.Contains(aAtt) then
    fUnresolvedAttributes.Remove(aAtt)
  else
    fDuplicateAttributes.Include(aAtt);
end;

method DexiJsonReaderResponse.OpenAlternative(aAltName: String; aModel: DexiModel);
begin
  fAltName := aAltName;
  fUnresolvedAttributes := aModel.Root.CollectBasicNonLinked;
  fDuplicateAttributes := new DexiAttributeList;
end;

method DexiJsonReaderResponse.CloseAlternative;
begin
  if fUnresolvedAttributes.Count > 0 then
    AddWarning(String.Format(DexiString.JUnresolvedAttributes, fAltName, fUnresolvedAttributes.ToString));
  if fDuplicateAttributes.Count > 0 then
    AddWarning(String.Format(DexiString.JDuplicateAttributes, fAltName, fDuplicateAttributes.ToString));
  fAltName := nil;
end;

method DexiJsonReaderResponse.AddAlternative(aAlt: DexiAlternative);
begin
  if aAlt = nil then
    exit;
  if fAlternatives = nil then
    fAlternatives := new DexiAlternatives;
  fAlternatives.AddAlternative(aAlt);
end;

{$ENDREGION}

{$REGION DexiJsonReader}

method DexiJsonReader.ReadSingle(aNode: JsonNode; aAtt: DexiAttribute): DexiValue;
begin
  result := nil;
  if fSettings.ValueFormat = ValueStringType.Text then
    begin
      var lValName := aNode.StringValue;
      var lValIdx := aAtt.Scale.IndexOfValue(lValName);
      if lValIdx >= 0 then
        result := new DexiIntSingle(lValIdx)
      else
        fResponse.AddError(String.Format(DexiString.JUndefinedCategory, lValName, aAtt:Name));
    end
  else
    begin
      var lValIdx := aNode.IntegerValue;
      if fSettings.ValueFormat = ValueStringType.One then
        dec(lValIdx);
      result := new DexiIntSingle(lValIdx);
    end;
end;

method DexiJsonReader.ReadSet(aNode: JsonNode; aAtt: DexiAttribute): DexiValue;
begin
  result := nil;
  if aNode is JsonStringValue then
    begin
      var lValue := aNode.StringValue;
      var lSet := Utils.StrToIntArray(lValue);
      result := new DexiIntSet(lSet);
    end
  else if aNode is JsonArray then
    begin
      var lSet := Utils.NewIntArray(aNode.Count);
      for i := low(lSet) to high(lSet) do
        begin
          var lSingle := ReadSingle(aNode.Item[i], aAtt);
          if lSingle = nil then
            exit nil;
          lSet[i] := lSingle.AsInteger;
        end;
      result := new DexiIntSet(lSet);
    end
  else
   fResponse.AddError(String.Format(DexiString.JArrayExpectedSet, aAtt:Name));
end;

method DexiJsonReader.ReadDistr(aNode: JsonNode; aAtt: DexiAttribute): DexiValue;
begin
  result := nil;
  if aNode is JsonStringValue then
    begin
      var lValue := aNode.StringValue;
      var lDistr := Utils.StrToFltArray(lValue);
      result := new DexiDistribution(0, lDistr);
    end
  else if aNode is JsonArray then
    begin
      var lDistr := Utils.NewFltArray(aNode.Count);
      for i := low(lDistr) to high(lDistr) do
        begin
          var lNode := aNode.Item[i];
          lDistr[i] := lNode.FloatValue;
        end;
      result := new DexiDistribution(0, lDistr);
    end
  else if aNode is JsonObject then
    begin
      var lDict := JsonObject(aNode);
      var lDistr := Utils.NewFltArray(aAtt.Scale.Count);
      for each lKey in lDict.Keys do
        begin
          var lValIdx :=
            case fSettings.ValueFormat of
              ValueStringType.Zero: Utils.StrToInt(lKey);
              ValueStringType.One: Utils.StrToInt(lKey) - 1;
              ValueStringType.Text: aAtt.Scale.IndexOfValue(lKey);
            end;
          if 0 <= lValIdx < aAtt.Scale.Count then
            lDistr[lValIdx] := lDict.Item[lKey].FloatValue
          else
            begin
              fResponse.AddError(String.Format(DexiString.JAttValueOutOfRange, aAtt:Name, lKey));
              exit nil;
            end;
        end;
      result := new DexiDistribution(0, lDistr);
    end
  else
   fResponse.AddError(String.Format(DexiString.JDistrExpected, aAtt:Name));
end;

method DexiJsonReader.LoadSettings(aObject: JsonObject);
begin
  fSettings.StructureFormat := DexiJsonStructureFormat.Flat;
  var lValue := ReadString(aObject, 'structureFormat');
  if lValue = 'recursive' then
    fSettings.StructureFormat := DexiJsonStructureFormat.Recursive;
  lValue := ReadString(aObject, 'valueFormat');
  case lValue of
    'zero': fSettings.ValueFormat := ValueStringType.Zero;
    'one':  fSettings.ValueFormat := ValueStringType.One;
    'text': fSettings.ValueFormat := ValueStringType.Text;
  end;
  fSettings.UseDexiStringValues := ReadBoolean(aObject, 'valueStrings');
  lValue := ReadString(aObject, 'DistrFormat');
  case lValue of
    'dict':  fSettings.DistributionFormat := DexiJsonDistributionFormat.Dict;
    'distr': fSettings.DistributionFormat := DexiJsonDistributionFormat.Distr;
  end;
  fSettings.SetDefaults;
end;

method DexiJsonReader.GetAttribute(aValObj: JsonObject): DexiAttribute;
var
  lLastId: String;
  lAnyId: String;

  method CheckId(aStr: String): Boolean;
  begin
    lLastId := aStr;
    if String.IsNullOrEmpty(aStr) then
      result := false
    else
      begin
        result := true;
        if lAnyId = nil then lAnyId := aStr;
      end;
  end;

begin
  result := nil;
  lAnyId := nil;
  if CheckId(ReadString(aValObj, 'id')) then
    result := fModel.AttributeByID(lLastId);
  if result = nil then
    if CheckId(ReadString(aValObj, 'path')) then
      result := fModel.AttributeByPath(lLastId);
  if result = nil then
    if CheckId(ReadString(aValObj, 'name')) then
      result := fModel.AttributeByName(lLastId);
  if result = nil then
    if CheckId(ReadString(aValObj, 'indices')) then
      result := fModel.AttributeByIndices(Utils.StrToIntArray(lLastId));
  if result = nil then
    fResponse.AddError(String.Format(DexiString.JUnknownAttribute, lAnyId));
  if not DexiAttribute.AttributeIsBasic(result) then
    result := nil;
  fResponse.ResolveAttribute(result);
end;

method DexiJsonReader.LoadValue(aValObj: JsonObject; aAtt: DexiAttribute; aAlt: DexiAlternative);
begin
  var lString := ReadString(aValObj, 'string');
  var lType := ReadString(aValObj, 'valueType');
  if lType = nil then lType := 'single';
  var lValue: DexiValue := nil;
  var lValNode := ReadNode(aValObj, 'value');
  if lType = 'null' then
    lValue := nil
  else if lType = 'undefined' then
    lValue := new DexiUndefinedValue
  else if (lString = nil) and (lValNode = nil) then // nothing
  else if fSettings.UseDexiStringValues then
    begin
      if lString <> nil then
        lValue := DexiValue.FromString(lString)
    end
  else if lValNode <> nil then
    begin
      if aAtt.Scale = nil then
        fResponse.AddError(String.Format(DexiString.JUndefinedScale, aAtt.Name))
      else if aAtt.Scale.IsContinuous then
        lValue := new DexiFltSingle(lValNode.FloatValue)
      else
        case lType of
          'single':       lValue := ReadSingle(lValNode, aAtt);
          'set':          lValue := ReadSet(lValNode, aAtt);
          'distribution': lValue := ReadDistr(lValNode, aAtt);
        end;
    end;
  if (lValue <> nil) and (aAtt:Scale <> nil) then
    if not DexiScale.ValueInScaleBounds(lValue, aAtt.Scale) then
      begin
        fResponse.AddError(String.Format(DexiString.JAttValueOutOfRange, aAtt.Name, lValue.ToString));
        lValue := nil;
      end;
  aAlt.Value[aAtt] := lValue;
end;

method DexiJsonReader.LoadAttribute(aValObj: JsonObject; aAlt: DexiAlternative);
begin
  var lAtt := GetAttribute(aValObj);
  if lAtt <> nil then
    LoadValue(aValObj, lAtt, aAlt);
  if fSettings.StructureFormat = DexiJsonStructureFormat.Recursive then
    begin
      var lAltValues := ReadArray(aValObj, 'inputs');
      if lAltValues <> nil then
        for each lNode in lAltValues do
          begin
            if lNode is not JsonObject then
              raise new DexiJsonException(DexiString.JObjectExpected, 'inputs');
            LoadAttribute(JsonObject(lNode), aAlt);
          end;
    end;
end;

method DexiJsonReader.LoadAlternative(aAltObj: JsonObject);
begin
  var lAltName := ReadString(aAltObj, 'name');
  var lAltDescr := ReadString(aAltObj, 'description');
  fResponse.OpenAlternative(lAltName, fModel);
  try
    var lAlt := new DexiAlternative(lAltName, lAltDescr);
    var lAltValues := ReadArray(aAltObj, 'values');
    if lAltValues <> nil then
      begin
        for each lNode in lAltValues do
          begin
            if lNode is not JsonObject then
              raise new DexiJsonException(DexiString.JObjectExpected, 'values');
            LoadAttribute(JsonObject(lNode), lAlt);
          end;
        fResponse.AddAlternative(lAlt);
      end;
  finally
    fResponse.CloseAlternative;
  end;

end;

method DexiJsonReader.LoadAlternatives(aArray: JsonArray);
begin
  if aArray = nil then
    exit;
  for each lNode in aArray.Items do
    begin
      if lNode is not JsonObject then
        raise new DexiJsonException(DexiString.JObjectExpected, 'alternatives');
      LoadAlternative(JsonObject(lNode));
    end;
end;

method DexiJsonReader.LoadAlternativesFromString(aString: String; aModel: DexiModel): DexiJsonReaderResponse;
require
  aModel <> nil;
begin
  try
    fModel := aModel;
    fResponse := new DexiJsonReaderResponse;
    result := fResponse;
    var lDocument := JsonDocument.FromString(aString);
    var lRoot := lDocument;
    if lRoot is not JsonObject then
      raise new DexiJsonException(String.Format(DexiString.JObjectExpected, "JsonDocument.Root"));
    var lAltObj := lRoot.Item['alternatives'];
    if lAltObj = nil then
      exit;
    if lAltObj is not JsonArray then
      raise new DexiJsonException(String.Format(DexiString.JArrayExpected, "alternatives"));
    LoadSettings(lRoot as JsonObject);
    LoadAlternatives(lAltObj as JsonArray);
  except on e: Exception do
    fResponse.AddError(e.Message);
  end;
end;

method DexiJsonReader.LoadAlternativesFromFile(aFileName: String; aModel: DexiModel): DexiJsonReaderResponse;
require
  aModel <> nil;
begin
  try
    var lString := File.ReadText(aFileName);
    result := LoadAlternativesFromString(lString, aModel);
  except on e: Exception do
    begin
      result := new DexiJsonReaderResponse;
      result.AddError(e.Message);
    end;
  end;
end;

{$ENDREGION}

end.
