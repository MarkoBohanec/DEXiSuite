// DexiAlternatives.pas is part of
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
// DexiAlternatives.pas implements types for storing data about and handling of DEXi
// decision alternatives. A decision alternative is defined as a named object consisting
// of a vector of DexiValues assigned to individual attributes in DexiModel.
//
// Alternatives are normally represented as part of a DexiModel. However, for various
// data-transfer and analysis purposes it is also essential to allow alternatives to
// exist outside of a DexiModel. Thus, it is important to support the notion of alternatives
// in a general way through interfaces. Three interfaces are defined here:
//
// - IDexiAlternative: a single alternative that can be named and copied, and its
//   DexiValues corresponding to indivudual attributes can be read or written.
// - IDexiAlternatives: an indexed collection of IDexiAlternative.
// - IDexiEditAlternatives: methods for editing a collection of alternatives.
//
// Additionally, DexiAlternatives.pas contains two implementations of IDexiAlternative and
// IDexiAlternatives, respectively: DexiAlternative and DexiAlternatives. These classes are
// aimed at storing and manipulating alternative data outside of DexiModel. Alternatives stored
// in DexiModel are accessible through interfaces implemented in the DexiModel class itself.
//
// Finally, the class DexiAlternativesTable extends DexiAlternatives so that alternatives are
// represented in a tabular form. Most importantly, DexiAlternativesTable provides a number
// of methods for reading and writing alternative data in the tab-delinited or
// comma-separated-values (CSV) formats.
//
// DexiOffAlternativesTable extends DexiAlternativesTable by the ability to output offset values
// of ofsetted alternatives contained in Model.OffAlternatives, if they exists. This class is
// output-only as it cannot read input offset values.
// ----------

namespace DexiLibrary;

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  IDexiAlternative = public interface
    property Name: String;
    property Description: String;
    property Value[aAtt: DexiAttribute]: DexiValue; default;
    property Attributes: ImmutableList<DexiAttribute> read;
    method &Copy: DexiAlternative;
    method ModifyFrom(aAlt: DexiAlternative);
  end;

type
  IDexiAlternatives = public interface
    property AltCount: Integer read;
    property AltValue[aIdx: Integer; aAtt: DexiAttribute]: DexiValue;
    property Alternative[aIdx: Integer]: IDexiAlternative; default;
  end;

type
  IDexiEditAlternatives = public interface
    method AddAlternative(aName: String := ''; aDescription: String := ''): Integer;
    method AddAlternative(aAlt: IDexiAlternative): Integer;
    method InsertAlternative(aIdx: Integer; aName: String := ''; aDescription: String := ''): Integer;
    method InsertAlternative(aIdx: Integer; aAlt: IDexiAlternative): Integer;
    method RemoveAlternative(aIdx: Integer): IDexiAlternative;
    method DeleteAlternative(aIdx: Integer);
    method DuplicateAlternative(aIdx: Integer): IDexiAlternative;
    method CopyAlternative(aFrom, aTo: Integer);
    method ExchangeAlternatives(aIdx1, aIdx2: Integer);
    method MoveAlternative(aFrom, aTo: Integer);
    method MoveAlternativePrev(aIdx: Integer);
    method MoveAlternativeNext(aIdx: Integer);
  end;

type
  DexiAlternativeList = public class(DexiList<DexiAlternative>);
  DexiAlternative = public class (DexiObject, IDexiAlternative)
  private
    fValues := new Dictionary<DexiAttribute, DexiValue>;
  protected
    method GetValue(aAtt: DexiAttribute): DexiValue;
    method SetValue(aAtt: DexiAttribute; aValue: DexiValue);
  public
    class method ToDexiAlternative(aAlt: IDexiAlternative): DexiAlternative;
    constructor (aName: String := ''; aDescription: String := '');
    method &Copy: DexiAlternative;
    method ModifyFrom(aAlt: DexiAlternative);
    method ExcludeAttribute(aAtt: DexiAttribute);
    method UseAttributes(aAtts: DexiAttributeList);
    property Value[aAtt: DexiAttribute]: DexiValue read GetValue write SetValue; default;
    property Attributes: ImmutableList<DexiAttribute> read fValues.Keys;
  end;

type
  DexiAlternatives = public class (IDexiAlternatives, IDexiEditAlternatives)
  private
    fAlternatives := new DexiAlternativeList;
  protected
    method GetAltCount: Integer;
    method GetAltValue(aIdx: Integer; aAtt: DexiAttribute): DexiValue;
    method SetAltValue(aIdx: Integer; aAtt: DexiAttribute; aValue: DexiValue); virtual;
    method GetAlternative(aIdx: Integer): IDexiAlternative;
    method SetAlternative(aIdx: Integer; aAlt: IDexiAlternative);
  public
    constructor; empty;
    class method EqualAlternativesOn(aAttributes: DexiAttributeList; aAlt1, aAlt2: IDexiAlternative): Boolean;
    method Clear; virtual;
    method AddAlternative(aName: String := ''; aDescription: String := ''): Integer;
    method AddAlternative(aAlt: IDexiAlternative): Integer;
    method InsertAlternative(aIdx: Integer; aName: String := ''; aDescription: String := ''): Integer;
    method InsertAlternative(aIdx: Integer; aAlt: IDexiAlternative): Integer;
    method RemoveAlternative(aIdx: Integer): IDexiAlternative;
    method DeleteAlternative(aIdx: Integer);
    method DuplicateAlternative(aIdx: Integer): IDexiAlternative;
    method CopyAlternative(aFrom, aTo: Integer);
    method ExchangeAlternatives(aIdx1, aIdx2: Integer);
    method MoveAlternative(aFrom, aTo: Integer);
    method MoveAlternativePrev(aIdx: Integer);
    method MoveAlternativeNext(aIdx: Integer);
    method ExcludeAttribute(aAtt: DexiAttribute);
    method UseAttributes(aAtts: DexiAttributeList);
    method Assign(aAlts: IDexiAlternatives; aAppend: Boolean := false);
    property AltCount: Integer read GetAltCount;
    property AltValue[aIdx: Integer; aAtt: DexiAttribute]: DexiValue read GetAltValue write SetAltValue;
    property Alternative[aIdx: Integer]: IDexiAlternative read GetAlternative write SetAlternative; default;
  end;

type
  DexiAlternativesTable = public class (DexiAlternatives)
  private
    fModel: DexiModel;
    fAltNames: List<String>;
    fAttIDs: List<String>;
    fAttributes: DexiAttributeList;
    fInvariant: Boolean;
    fValueType: ValueStringType;
    fUseDexiStrings: Boolean;
    fAttIdentification: AttributeIdentification;
    fTranspose: Boolean;
    fLevels: Boolean;
    fAllData: Boolean;
    fAddedAlternatives: SetOfInt;
    fUseOffsets: Boolean;
  protected
    fFltDecimals: Integer;
    fMemDecimals: Integer;
    method SetSettings(aSettings: DexiSettings);
    method GetAttCount: Integer;
    method GetAttID(aAtt: Integer): String;
    method SetAttID(aAtt: Integer; aID: String);
    method GetAtt(aAtt: Integer): DexiAttribute;
    method GetAltName(aAlt: Integer): String;
    method SetAltName(aAlt: Integer; aName: String);
    method GetAltValue(aAlt, aAtt: Integer): DexiValue;
    method SetAltValue(aAlt, aAtt: Integer; aValue: DexiValue);
    method GetText(aAlt, aAtt: Integer): String; virtual;
    method SetText(aAlt, aAtt: Integer; aTxt: String);
    method GetRowCount: Integer;
    method GetColCount: Integer;
    method GetGridText(aRow, aCol: Integer): String;
    method SetGridText(aRow, aCol: Integer; aTxt: String);
    method GetUnmatchedAttributes: String;
    method GetUnmatchedAlternatives: String;
  public
    constructor (aModel: DexiModel := nil);
    method Clear; override;
    method ValueToText(aValue: DexiValue; aScale: DexiScale): String; virtual;
    method TextToValue(aText: String; aScale: DexiScale): DexiValue; virtual;
    method ModelAttributeByID(aID: String): DexiAttribute; virtual;
    method AddAttribute(aID: String := '');
    method AddAlternative(aName: String := '');
    method AddRow(aName: String := '');
    method AddColumn(aName: String := '');
    method LoadFromModel(aModel: DexiModel; aUseOffsets: Boolean := false);
    method LoadFromTabFile(aFileName: String; aModel: DexiModel);
    method LoadFromCSVFile(aFileName: String; aModel: DexiModel);
    method LoadFromCSVFile(aFileName: String; aModel: DexiModel; aDelim: Char);
    method LoadFromStringList(aList: ImmutableList<String>; aModel: DexiModel);
    method SaveToTabFile(aFileName: String);
    method SaveToCSVFile(aFileName: String);
    method SaveToCSVFile(aFileName: String; aDelim: Char);
    method SaveToStringList: List<String>;
    method SaveToModel(aSaveAll: Boolean := false);
    property Model: DexiModel read fModel write fModel;
    property Settings: DexiSettings write SetSettings;
    property Invariant: Boolean read fInvariant write fInvariant;
    property ValueType: ValueStringType read fValueType write fValueType;
    property UseDexiStrings: Boolean read fUseDexiStrings write fUseDexiStrings;
    property AttIdentification: AttributeIdentification read fAttIdentification write fAttIdentification;
    property Transpose: Boolean read fTranspose write fTranspose;
    property Levels: Boolean read fLevels write fLevels;
    property AllData: Boolean read fAllData write fAllData;
    property AttCount: Integer read GetAttCount;
    property AltValue[aAlt, aAtt: Integer]: DexiValue read GetAltValue write SetAltValue;
    property RowCount: Integer read GetRowCount;
    property ColCount: Integer read GetColCount;
    property AttID[aAtt: Integer]: String read GetAttID write SetAttID;
    property Att[aAtt: Integer]: DexiAttribute read GetAtt;
    property AltName[aAlt: Integer]: String read GetAltName write SetAltName;
    property Text[aAlt, aAtt: Integer]: String read GetText write SetText;
    property GridText[aRow, aCol: Integer]: String read GetGridText write SetGridText;
    property UnmatchedAttributes: String read GetUnmatchedAttributes;
    property UnmatchedAlternatives: String read GetUnmatchedAlternatives;
    property AddedAlternatives: SetOfInt read fAddedAlternatives;
    property UseOffsets: Boolean read fUseOffsets write fUseOffsets;
  end;

type
  DexiOffAlternativesTable = public class (DexiAlternativesTable)
  protected
    method GetText(aAlt, aAtt: Integer): String; override;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiAlternative}

class method DexiAlternative.ToDexiAlternative(aAlt: IDexiAlternative): DexiAlternative;
begin
  result :=
    if aAlt = nil then new DexiAlternative
    else if aAlt is DexiAlternative then DexiAlternative(aAlt)
    else aAlt.Copy;
end;

constructor DexiAlternative(aName: String := ''; aDescription: String := '');
begin
  inherited constructor (aName, aDescription);
end;

method DexiAlternative.GetValue(aAtt: DexiAttribute): DexiValue;
begin
  result := fValues[aAtt];
end;

method DexiAlternative.SetValue(aAtt: DexiAttribute; aValue: DexiValue);
begin
  fValues[aAtt] := aValue;
end;

method DexiAlternative.Copy: DexiAlternative;
begin
  result := new DexiAlternative(Name, Description);
  for each lAtt in fValues.Keys do
    result[lAtt] := DexiValue.CopyValue(Value[lAtt]);
end;

method DexiAlternative.ModifyFrom(aAlt: DexiAlternative);
begin
  for each lAtt in aAlt.fValues.Keys do
    Value[lAtt] := DexiValue.CopyValue(aAlt.Value[lAtt]);
end;

method DexiAlternative.ExcludeAttribute(aAtt: DexiAttribute);
begin
  fValues.Remove(aAtt);
end;

method DexiAlternative.UseAttributes(aAtts: DexiAttributeList);
begin
  if aAtts = nil then
    fValues.RemoveAll
  else
    for each lAtt in fValues.Keys do
      if not aAtts.Contains(lAtt) then
        ExcludeAttribute(lAtt);
end;

{$ENDREGION}

{$REGION DexiAlternatives}

class method DexiAlternatives.EqualAlternativesOn(aAttributes: DexiAttributeList; aAlt1, aAlt2: IDexiAlternative): Boolean;
begin
  result := true;
  for i := 0 to aAttributes.Count - 1 do
    begin
      var lAtt := aAttributes[i];
      if not DexiValue.ValuesAreEqual(aAlt1[lAtt], aAlt2[lAtt]) then
        exit false;
    end;
end;

method DexiAlternatives.Clear;
begin
  fAlternatives.RemoveAll;
end;

method DexiAlternatives.GetAltCount: Integer;
begin
  result := fAlternatives.Count;
end;

method DexiAlternatives.GetAltValue(aIdx: Integer; aAtt: DexiAttribute): DexiValue;
begin
  result := fAlternatives[aIdx].Value[aAtt];
end;

method DexiAlternatives.SetAltValue(aIdx: Integer; aAtt: DexiAttribute; aValue: DexiValue);
begin
  var lAlt := fAlternatives[aIdx];
  lAlt.Value[aAtt] := DexiValue.CopyValue(aValue);
end;

method DexiAlternatives.GetAlternative(aIdx: Integer): IDexiAlternative;
begin
  result := fAlternatives[aIdx];
end;

method DexiAlternatives.SetAlternative(aIdx: Integer; aAlt: IDexiAlternative);
begin
  fAlternatives[aIdx] := DexiAlternative.ToDexiAlternative(aAlt);
end;

method DexiAlternatives.AddAlternative(aName: String := ''; aDescription: String := ''): Integer;
begin
  result := AddAlternative(new DexiAlternative(aName, aDescription));
end;

method DexiAlternatives.AddAlternative(aAlt: IDexiAlternative): Integer;
begin
  var lAlt := DexiAlternative.ToDexiAlternative(aAlt);
  fAlternatives.Add(lAlt);
  result := fAlternatives.Count - 1;
end;

method DexiAlternatives.InsertAlternative(aIdx: Integer; aName: String := ''; aDescription: String := ''): Integer;
begin
  result := InsertAlternative(aIdx, new DexiAlternative(aName, aDescription));
end;

method DexiAlternatives.InsertAlternative(aIdx: Integer; aAlt: IDexiAlternative): Integer;
begin
  var lAlt := DexiAlternative.ToDexiAlternative(aAlt);
  result := aIdx;
  if aIdx >= AltCount then
    result := AddAlternative(lAlt)
  else
    begin
      fAlternatives.Insert(aIdx, lAlt);
      result := aIdx;
    end;
end;

method DexiAlternatives.RemoveAlternative(aIdx: Integer): IDexiAlternative;
begin
  result := Alternative[aIdx];
  DeleteAlternative(aIdx);
end;

method DexiAlternatives.DeleteAlternative(aIdx: Integer);
begin
  fAlternatives.RemoveAt(aIdx);
end;

method DexiAlternatives.DuplicateAlternative(aIdx: Integer): IDexiAlternative;
begin
  result := fAlternatives[aIdx].Copy;
  InsertAlternative(aIdx + 1, result);
end;

method DexiAlternatives.CopyAlternative(aFrom, aTo: Integer);
begin
  var lAlt := fAlternatives[aFrom].Copy;
  InsertAlternative(aTo, lAlt);
end;

method DexiAlternatives.MoveAlternative(aFrom, aTo: Integer);
begin
  if aFrom = aTo then
    exit;
  fAlternatives.Move(aFrom, aTo);
end;

method DexiAlternatives.MoveAlternativePrev(aIdx: Integer);
begin
  ExchangeAlternatives(aIdx - 1, aIdx);
end;

method DexiAlternatives.MoveAlternativeNext(aIdx: Integer);
begin
  ExchangeAlternatives(aIdx, aIdx + 1);
end;

method DexiAlternatives.ExchangeAlternatives(aIdx1, aIdx2: Integer);
begin
  fAlternatives.Exchange(aIdx1, aIdx2);
end;

method DexiAlternatives.ExcludeAttribute(aAtt: DexiAttribute);
begin
  for i := 0 to AltCount - 1 do
    fAlternatives[i].ExcludeAttribute(aAtt);
end;

method DexiAlternatives.UseAttributes(aAtts: DexiAttributeList);
begin
  for i := 0 to AltCount - 1 do
    fAlternatives[i].UseAttributes(aAtts);
end;

method DexiAlternatives.Assign(aAlts: IDexiAlternatives; aAppend: Boolean := false);
begin
  if not aAppend then
    Clear;
  if aAlts = nil then
    exit;
  for i := 0 to aAlts.AltCount - 1 do
    AddAlternative(aAlts.Alternative[i].Copy);
end;

{$ENDREGION}

{$REGION DexiAlternativesTable}

constructor DexiAlternativesTable(aModel: DexiModel := nil);
begin
  inherited constructor;
  fModel := aModel;
  if fModel <> nil then
    fModel.MakeUniqueAttributeIDs;
  fAltNames := new List<String>;
  fAttIDs := new List<String>;
  fAttributes := new DexiAttributeList;
  SetSettings(fModel:Settings);
  fUseOffsets := false;
end;

method DexiAlternativesTable.SetSettings(aSettings: DexiSettings);
begin
  if aSettings = nil then
    begin
      fValueType := ValueStringType.One;
      fTranspose := false;
      fLevels := true;
      fAllData := true;
      fInvariant := true;
      fUseDexiStrings := false;
      fAttIdentification := AttributeIdentification.Name;
      fFltDecimals := -1;
      fMemDecimals := -1;
    end
  else
    begin
      fValueType := aSettings.ValueType;
      fTranspose := aSettings.AltTranspose;
      fLevels := aSettings.AltLevels;
      fAllData := aSettings.AltDataAll;
      fInvariant := aSettings.CsvInvariant;
      fUseDexiStrings := aSettings.UseDexiStringValues;
      fAttIdentification := aSettings.AttId;
      fFltDecimals := aSettings.FltDecimals;
      fMemDecimals := aSettings.MemDecimals;
    end;
end;

method DexiAlternativesTable.Clear;
begin
  inherited Clear;
  fAttIDs.RemoveAll;
  fAttributes.RemoveAll;
end;

method DexiAlternativesTable.GetAttCount: Integer;
begin
  result := fAttIDs.Count;
end;

method DexiAlternativesTable.GetAttID(aAtt: Integer): String;
begin
  result := fAttIDs[aAtt];
end;

method DexiAlternativesTable.SetAttID(aAtt: Integer; aID: String);
begin
  fAttIDs[aAtt] := aID;
end;

method DexiAlternativesTable.GetAtt(aAtt: Integer): DexiAttribute;
begin
  result :=
    if 0 <= aAtt < fAttributes.Count then fAttributes[aAtt]
    else nil;
end;

method DexiAlternativesTable.GetAltName(aAlt: Integer): String;
begin
  result := fAltNames[aAlt];
end;

method DexiAlternativesTable.SetAltName(aAlt: Integer; aName: String);
begin
  fAltNames[aAlt] := aName;
end;

method DexiAlternativesTable.GetAltValue(aAlt, aAtt: Integer): DexiValue;
begin
  result := AltValue[aAlt, GetAtt(aAtt)];
end;

method DexiAlternativesTable.SetAltValue(aAlt, aAtt: Integer; aValue: DexiValue);
begin
  AltValue[aAlt, GetAtt(aAtt)] := aValue;
end;

method DexiAlternativesTable.GetText(aAlt, aAtt: Integer): String;
begin
  result := ValueToText(AltValue[aAlt, aAtt], GetAtt(aAtt):Scale);
end;

method DexiAlternativesTable.SetText(aAlt, aAtt: Integer; aTxt: String);
begin
  var lAtt := GetAtt(aAtt);
  if lAtt = nil then
    exit;
  AltValue[aAlt, lAtt] := TextToValue(aTxt, lAtt:Scale);
end;

method DexiAlternativesTable.GetRowCount: Integer;
begin
  result :=
    if fTranspose then AltCount
    else AttCount;
end;

method DexiAlternativesTable.GetColCount: Integer;
begin
  result :=
    if fTranspose then AttCount
    else AltCount;
end;

method DexiAlternativesTable.GetGridText(aRow, aCol: Integer): String;
begin
  if fTranspose then
    Utils.SwapInt(var aRow, var aCol);
  if aRow < 0 then
    if aCol < 0 then
      result := ''
    else
      result := AltName[aCol]
  else
    if aCol < 0 then
      begin
        result := AttID[aRow];
        if fLevels and (fAttributes[aRow] <> nil) then
          result := Utils.ChString(fAttributes[aRow].Level - 1, DexiString.SLevelText) + result;
      end
    else
      result := GetText(aCol, aRow);
end;

method DexiAlternativesTable.SetGridText(aRow, aCol: Integer; aTxt: String);
begin
  if fTranspose then
    Utils.SwapInt(var aRow, var aCol);
  if aRow < 0 then
    if aCol < 0 then {nothing}
    else
      AltName[aCol] := aTxt
  else
    if aCol < 0 then
      begin
        var t := aTxt;
        if fLevels then
          while Utils.Pos0(DexiString.SLevelText, t) = 0 do
            t := t.SubString(length(DexiString.SLevelText));
        AttID[aRow] := t;
        var lAtt := ModelAttributeByID(t);
        fAttributes[aRow] := lAtt;
      end
    else
      SetText(aCol, aRow, aTxt);
end;

method DexiAlternativesTable.GetUnmatchedAttributes: String;
begin
  result := '';
  for i := 0 to AttCount - 1 do
    if fAttributes[i] = nil then
      begin
        if result <> '' then
          result := result + ';';
        result := result + '"' + fAttIDs[i] + '"';
      end;
end;

method DexiAlternativesTable.GetUnmatchedAlternatives: String;
begin
  result := '';
  if fModel = nil then
    exit;
  for i := 0 to AltCount - 1 do
    begin
      var x := fModel.AltNames.IndexOf(fAltNames[i]);
      if x < 0 then
        begin
          if result <> '' then
            result := result + ';';
          result := result + '"' + fAltNames[i] + '"';
        end;
    end;
end;

method DexiAlternativesTable.ValueToText(aValue: DexiValue; aScale: DexiScale): String;
begin
  if fUseDexiStrings then
    result := DexiValue.ToString(aValue, true, fFltDecimals)
  else
    begin
      var vs := new DexiScaleStrings(fInvariant, fValueType, fMemDecimals);
      result := vs.ValueOnScaleString(aValue, aScale);
    end;
end;

method DexiAlternativesTable.TextToValue(aText: String; aScale: DexiScale): DexiValue;
begin
  if fUseDexiStrings then
    result := DexiValue.FromString(aText, true)
  else
    begin
      var vs := new DexiScaleStrings(fInvariant, fValueType);
      result := vs.ParseScaleValue(aText, aScale);
    end;
end;

method DexiAlternativesTable.ModelAttributeByID(aID: String): DexiAttribute;
begin
  result := nil;
  if (fModel <> nil) and not String.IsNullOrEmpty(aID) then
    begin
      result := fModel.AttributeByID(aID);
      if result = nil then
        result := fModel.InputAttributeByName(aID);
      if result = nil then
        begin
          result := fModel.AttributeByPath(aId);
          if (result <> nil) and not result.IsBasic then
            result := nil;
        end;
    end;
end;

method DexiAlternativesTable.AddAttribute(aID: String := '');
begin
  fAttIDs.Add(aID);
  var lAtt := ModelAttributeByID(aID);
  fAttributes.Add(lAtt);
end;

method DexiAlternativesTable.AddAlternative(aName: String := '');
begin
  fAltNames.Add(aName);
  inherited AddAlternative(aName);
end;

method DexiAlternativesTable.AddRow(aName: String := '');
begin
  if fTranspose then
    AddAlternative(aName)
  else
    AddAttribute(aName);
end;

method DexiAlternativesTable.AddColumn(aName: String := '');
begin
  if fTranspose then
    AddAttribute(aName)
  else
    AddAlternative(aName);
end;

method DexiAlternativesTable.LoadFromModel(aModel: DexiModel; aUseOffsets: Boolean := false);
begin
  Clear;
  fModel := aModel;
  if fModel:Root = nil then
    exit;
  fModel.MakeUniqueAttributeIDs;
  if fAllData then
    fModel.Root.CollectInputs(fAttributes)
  else
    fModel.Root.CollectBasicNonLinked(fAttributes);
  for i := 0 to fAttributes.Count - 1 do
    begin
      var lAtt := fAttributes[i];
      var lId :=
        case fAttIdentification of
          AttributeIdentification.Name: lAtt.Name;
          AttributeIdentification.Id:   lAtt.ID;
          AttributeIdentification.Path: lAtt.SecureParentPath;
          else 'unknownId';
         end;
      fAttIDs.Add(lId);
    end;
  for i := 0 to fModel.AltCount - 1 do
    if fModel.Selected[i] then
      AddAlternative(fModel.AltNames[i].Name);
  for i := 0 to AttCount - 1 do
    begin
      var o := 0;
      for j := 0 to fModel.AltCount - 1 do
        if fModel.Selected[j] then
          begin
            AltValue[o, i] := fAttributes[i].AltValue[j];
            inc(o);
          end;
    end;
end;

method DexiAlternativesTable.LoadFromTabFile(aFileName: String; aModel: DexiModel);
begin
  var lList := File.ReadLines(aFileName);
  LoadFromStringList(lList, aModel);
end;

method DexiAlternativesTable.LoadFromCSVFile(aFileName: String; aModel: DexiModel);
begin
  var lLocale := if fInvariant then Locale.Invariant else Locale.Current;
  var lDelim := if lLocale.NumberFormat.DecimalSeparator = ',' then ';' else ',';
  LoadFromCSVFile(aFileName, aModel, lDelim);
end;

method DexiAlternativesTable.LoadFromCSVFile(aFileName: String; aModel: DexiModel; aDelim: Char);
begin
  using sb := new StringBuilder do
    begin
      var lRead := File.ReadLines(aFileName);
      var lList := new List<String>;
      for i := 0 to lRead.Count - 1 do
        begin
          sb.Clear;
          var t := lRead[i];
          var q := false;
          for j := 0 to length(t) - 1 do
            if t[j] = '"' then
              q := not q
            else if (t[j] = aDelim) and not q then
              sb.Append(Utils.TabChar)
            else
              sb.Append(t[j]);
          lList.Add(sb.ToString);
        end;
      LoadFromStringList(lList, aModel);
    end;
end;

method DexiAlternativesTable.LoadFromStringList(aList: ImmutableList<String>; aModel: DexiModel);
begin
 Clear;
  if aModel = nil then
    exit;
  if (aList = nil) or (aList.Count = 0) then
    exit;
  fModel := aModel;
  fModel.MakeUniqueAttributeIDs;
  var lNum := -1;
  for i := 0 to aList.Count - 1 do
    begin
      var lLine := aList[i];
      if String.IsNullOrWhiteSpace(lLine) then
        continue;
      inc(lNum);
      if lNum > 0 then
        AddRow;
      var c := -1;
      while not String.IsNullOrEmpty(lLine) do
        begin
          var t := Utils.NextSubstr(var lLine, Utils.TabChar);
          if c >= ColCount then
            AddColumn;
          SetGridText(lNum - 1, c, t);
          inc(c);
        end;
    end;
end;

method DexiAlternativesTable.SaveToTabFile(aFileName: String);
begin
  var lList := SaveToStringList;
  File.WriteLines(aFileName, lList);
end;

method DexiAlternativesTable.SaveToCSVFile(aFileName: String);
begin
  var lLocale := if fInvariant then Locale.Invariant else Locale.Current;
  var lDelim := if lLocale.NumberFormat.DecimalSeparator = ',' then ';' else ',';
  SaveToCSVFile(aFileName, lDelim);
end;

method DexiAlternativesTable.SaveToCSVFile(aFileName: String; aDelim: Char);
begin
  using sb := new StringBuilder do
    begin
      var lList := new List<String>;
      for r := -1 to RowCount - 1 do
        begin
          sb.Clear;
          for c := -1 to ColCount - 1 do
            begin
              sb.Append('"' + GridText[r, c] + '"');
              if c < ColCount - 1 then
                sb.Append(aDelim);
            end;
          lList.Add(sb.ToString);
        end;
      File.WriteLines(aFileName, lList);
    end;
end;

method DexiAlternativesTable.SaveToStringList: List<String>;
begin
  result := new List<String>;
  var sb := new StringBuilder;
  for r := -1 to RowCount - 1 do
    begin
      sb.Clear;
      for c := -1 to ColCount - 1 do
        begin
          sb.Append(GridText[r, c]);
          if c < ColCount - 1 then
            sb.Append(Utils.TabChar);
        end;
      result.Add(sb.toString);
    end;
end;

method DexiAlternativesTable.SaveToModel(aSaveAll: Boolean := false);
begin
  if fModel = nil then
    exit;
  fAddedAlternatives := new SetOfInt;
  for xAlt := 0 to AltCount - 1 do
    begin
      var lAlt := fModel.AltNames.IndexOf(fAltNames[xAlt]);
      if (lAlt < 0) or aSaveAll then
        begin
          lAlt := fModel.AddAlternative(fAltNames[xAlt]);
          lAlt := fModel.AltCount - 1;
          fAddedAlternatives.Include(lAlt);
        end;
      for xAtt := 0 to AttCount - 1 do
        begin
          var lAtt := fAttributes[xAtt];
          if lAtt <> nil then
            if lAtt.IsBasic and (lAtt.Link = nil) then
              lAtt.AltValue[lAlt] := AltValue[xAlt, xAtt];
        end;
    end;
  fModel.Evaluate;
end;

{$ENDREGION}

{$REGION DexiOffAlternativesTable}

method DexiOffAlternativesTable.GetText(aAlt, aAtt: Integer): String;
begin
  if (Model.OffAlternatives = nil) or not (0 <= aAlt < Model.OffAlternatives.Count) then
    result := inherited GetText(aAlt, aAtt)
  else
    begin
      var lAtt := GetAtt(aAtt);
      var lOffsets := Model.OffAlternatives[aAlt]:AsIntOffsets[lAtt];
      if lOffsets = nil then
        result := inherited GetText(aAlt, aAtt)
      else
        begin
          var vs := new DexiScaleStrings(Invariant, ValueType, fFltDecimals);
          vs.Simple := true;
          result := vs.ValueOnScaleString(lOffsets, lAtt:Scale);
        end;
    end;
end;

{$ENDREGION}

end.
