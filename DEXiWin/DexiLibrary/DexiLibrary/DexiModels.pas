// DexiModels.pas is part of
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
// DexiModels.pas implements the class DexiModel: the main top-level component of a DEXi model
// that contains all other components. This file specifically defines types:
//
// - DexiModelStatistics: a record capturing basic statistics of a given DexiModel
// - DexiSettings: a class representing the main user-defined parameters/preferences
// - DexiModelAlternative: a class implementing decision alternatives that are stored within a DexiModel
// - DexiModel: the DEXi model class itself
// ----------

namespace DexiLibrary;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$HIDE W28} // obsolete methods

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiModelStatistics = public record
  public
    Attributes: Integer;
    BasicAttributes: Integer;
    AggregateAttributes: Integer;
    LinkedAttributes: Integer;
    Scales: Integer;
    DiscrScales: Integer;
    ContScales: Integer;
    UndefScales: Integer;
    Functions: Integer;
    TabularFunctions: Integer;
    DiscretizeFunctions: Integer;
    UndefFunctions: Integer;
    Alternatives: Integer;
    Depth: Integer;
    Width: Float;
    MinWidth: Integer;
    MaxWidth: Integer;
    Rules: Float;
    MinRules: Integer;
    MaxRules: Integer;
    constructor;
    method Clear;
  end;

type
  AttributeIdentification = public enum (Name, Id, Path);

type
  DexiSettings = public class (IUndoable)
  private
    fLinking: Boolean;
    fUndoing: Boolean;
    fRptHtml: Boolean;
    fDefBrowser: Boolean;
    fSelectedReports: IntSet;
    fSelectedWeights: IntSet;
    fPagebreak: Boolean;
    fBadColor: ColorInfo;
    fNeutralColor: ColorInfo;
    fGoodColor: ColorInfo;
    fWeiDecimals: Integer;
    fMaxColumns: Integer;
    fEvalTrim: Integer;
    fFncShowWeights: Boolean;
    fFncShowNumbers: Boolean;
    fFncComplex: Boolean; // deprecated; still maintained, but replaced by fRepresentation
    fFncEnteredOnly: Boolean;
    fFontSize: Integer;
    fFontName: String;
    fValueType: ValueStringType;
    fAltDataAll: Boolean;
    fAltTranspose: Boolean;
    fAltLevels: Boolean;
    fFncDataType: ValueStringType;
    fFncDataAll: Boolean;
    fFncStatus: Boolean;
    fModelProtect: Boolean;
    fEvalType: EvaluationType;
    fExpandUndef: Boolean;
    fExpandEmpty: Boolean;
    fCheckBounds: Boolean;
    fWarnings: Boolean;

    // added in DexiLibrary 2023
    fRepresentation: DexiRptFunctionRepresentation;
    fMemDecimals: Integer;
    fDefDetDecimals: Integer;
    fFltDecimals: Integer;
    fUseReportHeader: Boolean;
    fTreePattern: RptTreePattern;
    fSectionBreak: Integer;
    fTableBreak: Integer;
    fCsvInvariant: Boolean;
    fReportFontInfo: FontInfo;
    fBadStyle: String;
    fNeutralStyle: String;
    fGoodStyle: String;
    fFncNormalizedWeights: Boolean;
    fFncShowNumericValues: Boolean;
    fFncShowMarginals: Boolean;
    fCanMoveTabs: Boolean;
    fAttId: AttributeIdentification;
    fUseDexiStringValues: Boolean;
    fJsonSettings: DexiJsonSettings;
  protected
    method GetMaxColumns: Integer;
    method GetSelectedReport(aIdx: Integer): Boolean;
    method GetSelectedWeight(aIdx: Integer): Boolean;
  public
    class const MaxReports = 10;
    class const MaxWeights = 4;
    class const DefMaxColumns = 5;
    constructor;
    constructor (aSettings: DexiSettings);
    method Clear;
    method Assign(aSettings: DexiSettings);
    method HasFullReports: Boolean;
    method HasFullWeights: Boolean;
    method SelectReport(aIdx: Integer; aSel: Boolean);
    method SelectWeight(aIdx: Integer; aSel: Boolean);
    class method ValTypeString(aType: ValueStringType): String;
    class method ValStringType(aString: String): ValueStringType;
    class method JsonInputString(aInputs: DexiJsonInputs): String;
    property Linking: Boolean read fLinking write fLinking;
    property Undoing: Boolean read fUndoing write fUndoing;
    property RptHtml: Boolean read fRptHtml write fRptHtml;
    property DefBrowser: Boolean read fDefBrowser write fDefBrowser;
    property SelectedReports: IntSet read fSelectedReports write fSelectedReports;
    property SelectedWeights: IntSet read fSelectedWeights write fSelectedWeights;
    property SelectedReport[aIdx: Integer]: Boolean read GetSelectedReport write SelectReport;
    property SelectedWeight[aIdx: Integer]: Boolean read GetSelectedWeight write SelectWeight;
    property WeightsLocal: Boolean read GetSelectedWeight(0) write begin SelectedWeight[0] := value; end;
    property WeightsGlobal: Boolean read GetSelectedWeight(1) write begin SelectedWeight[1] := value; end;
    property WeightsLocalNormalized: Boolean read GetSelectedWeight(2) write begin SelectedWeight[2] := value; end;
    property WeightsGlobalNormalized: Boolean read GetSelectedWeight(3) write begin SelectedWeight[3] := value; end;
    property Pagebreak: Boolean read fPagebreak write fPagebreak;
    property BadColor: ColorInfo read fBadColor write fBadColor;
    property NeutralColor: ColorInfo read fNeutralColor write fNeutralColor;
    property GoodColor: ColorInfo read fGoodColor write fGoodColor;
    property WeiDecimals: Integer read fWeiDecimals write fWeiDecimals;
    property MaxColumns: Integer read GetMaxColumns write fMaxColumns;
    property EvalTrim: Integer read fEvalTrim write fEvalTrim;
    property FncShowWeights: Boolean read fFncShowWeights write fFncShowWeights;
    property FncShowNumbers: Boolean read fFncShowNumbers write fFncShowNumbers;
    property FncComplex: Boolean read fFncComplex write fFncComplex;
    property FncEnteredOnly: Boolean read fFncEnteredOnly write fFncEnteredOnly;
    property FontSize: Integer read fFontSize write fFontSize; deprecated;
    property FontName: String read fFontName write fFontName; deprecated;
    property ValueType: ValueStringType read fValueType write fValueType;
    property AltDataAll: Boolean read fAltDataAll write fAltDataAll;
    property AltTranspose: Boolean read fAltTranspose write fAltTranspose;
    property AltLevels: Boolean read fAltLevels write fAltLevels;
    property FncDataType: ValueStringType read fFncDataType write fFncDataType;
    property FncDataAll: Boolean read fFncDataAll write fFncDataAll;
    property FncStatus: Boolean read fFncStatus write fFncStatus;
    property ModelProtect: Boolean read fModelProtect write fModelProtect;
    property EvalType: EvaluationType read fEvalType write fEvalType;
    property ExpandUndef: Boolean read fExpandUndef write fExpandUndef;
    property ExpandEmpty: Boolean read fExpandEmpty write fExpandEmpty;
    property CheckBounds: Boolean read fCheckBounds write fCheckBounds;
    property Warnings: Boolean read fWarnings write fWarnings;

    // added in DexiLibrary 2023
    property Representation: DexiRptFunctionRepresentation read fRepresentation write fRepresentation;
    property MemDecimals: Integer read fMemDecimals write fMemDecimals;
    property DefDetDecimals: Integer read fDefDetDecimals write fDefDetDecimals;
    property FltDecimals: Integer read fFltDecimals write fFltDecimals;
    property UseReportHeader: Boolean read fUseReportHeader write fUseReportHeader;
    property TreePattern: RptTreePattern read fTreePattern write fTreePattern;
    property SectionBreak: Integer read fSectionBreak write fSectionBreak;
    property TableBreak: Integer read fTableBreak write fTableBreak;
    property CsvInvariant: Boolean read fCsvInvariant write fCsvInvariant;
    property ReportFontInfo: FontInfo read fReportFontInfo write fReportFontInfo;
    property BadStyle: String read fBadStyle write fBadStyle;
    property NeutralStyle: String read fNeutralStyle write fNeutralStyle;
    property GoodStyle: String read fGoodStyle write fGoodStyle;
    property FncNormalizedWeights: Boolean read fFncNormalizedWeights write fFncNormalizedWeights;
    property FncShowNumericValues: Boolean read fFncShowNumericValues write fFncShowNumericValues;
    property FncShowMarginals: Boolean read fFncShowMarginals write fFncShowMarginals;
    property CanMoveTabs: Boolean read fCanMoveTabs write fCanMoveTabs;
    property AttId: AttributeIdentification read fAttId write fAttId;
    property UseDexiStringValues: Boolean read fUseDexiStringValues write fUseDexiStringValues;
    property JsonSettings: DexiJsonSettings read fJsonSettings write fJsonSettings;

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>);
    method EqualStateAs(aObj: IUndoable): Boolean;
    method GetUndoState: IUndoable;
    method SetUndoState(aState: IUndoable);
  end;

type
  DexiModelAlternative = public class (DexiObject, IDexiAlternative)
  private
    fModel: weak DexiModel;
    fIndex: Integer;
  protected
    method GetName: String; override;
    method SetName(aName: String); override;
    method GetDescription: String; override;
    method SetDescription(aDescription: String); override;
    method GetValue(aAtt: DexiAttribute): DexiValue;
    method SetValue(aAtt: DexiAttribute; aValue: DexiValue);
  public
    constructor(aModel: DexiModel; aIdx: Integer);
    property Value[aAtt: DexiAttribute]: DexiValue read GetValue write SetValue;
    property Attributes: ImmutableList<DexiAttribute> read fModel:Root.CollectInputs(false);
    method &Copy: DexiAlternative;
    method ModifyFrom(aAlt: DexiAlternative);
  end;

type
  DexiXmlHandler = public abstract class
  public
    method ReadXml(aXml: XmlElement); virtual; abstract;
    method WriteXml(aXml: XmlElement); virtual; abstract;
  end;

type
  DeepComparison = public class
  private
    fHere: PrefCompare;
    fBelow: PrefCompare;
  public
    constructor (aHere: PrefCompare := PrefCompare.No; aBelow: PrefCompare := PrefCompare.No);
    property Here: PrefCompare read fHere write fHere;
    property Below: PrefCompare read fBelow write fBelow;
  end;

type
  /// <summary>
  /// A class for storing and manipulating DEXi models. This is the top-level class that generally contains:
  /// - a hierarchy of attributes (DexiAttribute)
  /// - data about considered decision alternatives (DexiModelAlternative)
  /// - a list of user-defined reports (list of DexiReportGroup)
  /// - user-defined preferences affecting various aspects of model operations (DexiSettings)
  /// - user-defined parameters for drawing charts (DexiChartParameters)
  /// DexiModel methods perform a wide range of model operations, including:
  /// - loading and saving models and their components in various formats (native XML, tabular, CSV, ...)
  /// - model editing operations
  /// - evaluation of alternatives
  /// - creating and handling reports
  /// </summary>
  DexiModel = public class (DexiObject, IDexiAlternatives, IDexiEditAlternatives)
  private
    fRoot: DexiAttribute;
    fInputAttributeOrder: IntArray;
    fReports: List<DexiReportGroup>;
    fModified: Boolean;
    fNeedsEvaluation: Boolean;
    fDefaultScale: DexiScale;
    fAltNames: DexiObjectList;
    fAltExclude: IntSet;
    fOffAlternatives: DexiOffAlternatives;
    fChartParameters: DexiChartParameters;
    fSettings: DexiSettings;
    fEvaluator: DexiEvaluator;
    fForceLibraryFormat: Boolean := false;
    fCreated: String;
    fFileName: String;
    fXmlHandler: DexiXmlHandler;
    fOperation: String;

    // temporary for saving
    fDefaultFormat: DexiReportFormat;
    fDefaultParameters: DexiReportParameters;
    fDefaultChartParameters: DexiChartParameters;
  protected
    method GetFirst: DexiAttribute;
    method GetModelName: String;
    method GetDefaultScale: DexiScale;
    method GetSelected(aIdx: Integer): Boolean;
    method SetSelected(aIdx: Integer; aSel: Boolean);
    method GetLinking: Boolean;
    method GetUndoing: Boolean;
    method GetAltValue(aIdx: Integer; aAtt: DexiAttribute): DexiValue;
    method SetAltValue(aIdx: Integer; aAtt: DexiAttribute; aValue: DexiValue);
    method GetAlternative(aIdx: Integer): IDexiAlternative;
    method SetAlternative(aIdx: Integer; aAlt: IDexiAlternative);
    method LoadScale(aItem: XmlElement; aAtt: DexiAttribute);
    method LoadFunct(aItem: XmlElement; aAtt: DexiAttribute);
    method LoadTabular(aItem: XmlElement; aAtt: DexiAttribute);
    method LoadDiscretize(aItem: XmlElement; aAtt: DexiAttribute);
    method LoadAttribute(aItem: XmlElement; var aAtt: DexiAttribute);
    method LoadDescription(aItem: XmlElement): String;
    method LoadNameDescr(aObj: DexiObject; aItem: XmlElement);
    method LoadRoot(aItem: XmlElement);
    method LoadJsonSettings(aItem: XmlElement);
    method LoadSettings(aItem: XmlElement);
    method LoadSelectedAttributes(aItem: XmlElement): List<DexiAttribute>;
    method LoadReportFormat(aItem: XmlElement): DexiReportFormat;
    method LoadReportParameters(aItem: XmlElement): DexiReportParameters;
    method LoadReport(aItem: XmlElement): DexiReport;
    method LoadReportGroup(aItem: XmlElement): DexiReportGroup;
    method LoadReports(aItem: XmlElement);
    method LoadChartParameters(aItem: XmlElement): DexiChartParameters;
    method SaveDescription(aItem: XmlElement; aDesc: String);
    method SaveNameDescr(aObj: DexiObject; aItem: XmlElement);
    method SaveFunctOld(aFunct: DexiTabularFunction; aItem: XmlElement);
    method SaveFunct(aFunct: DexiTabularFunction; aItem: XmlElement);
    method SaveFunct(aFunct: DexiDiscretizeFunction; aItem: XmlElement);
    method SaveFunct(aAtt: DexiAttribute; aItem: XmlElement);
    method SaveScale(aAtt: DexiAttribute; aItem: XmlElement);
    method SaveAttribute(aAtt: DexiAttribute; aItem: XmlElement);
    method SaveJsonSettings(JsonItem: XmlElement; aJson: DexiJsonSettings);
    method SaveSettings(XmlItem: XmlElement);
    method SaveSelectedAttributes(XmlItem: XmlElement; aAtts: ImmutableList<DexiAttribute>);
    method SaveReportFormat(XmlItem: XmlElement; aFmt: DexiReportFormat);
    method SaveReportParameters(XmlItem: XmlElement; aPar: DexiReportParameters);
    method SaveReport(XmlItem: XmlElement; aRpt: DexiReport);
    method SaveReportGroup(XmlItem: XmlElement; aRptGrp: DexiReportGroup);
    method SaveReports(XmlItem: XmlElement);
    method SaveChartParameters(XmlItem: XmlElement; aParameters: DexiChartParameters);
    method SetupEvaluator(aType: EvaluationType);
    method ReportFormat: DexiReportFormat;
    method MigrateReports;
  public
    class method NewModel(aName: String := nil): DexiModel;
    constructor;
    method Clear;
    method Modify;
    method Statistics: DexiModelStatistics;
    method GetScaleStrings(aAtt: DexiAttribute; aCompScale: DexiScale := nil): DexiStrings<DexiScale>; deprecated;
    method GetDifferentScales: DexiStrings<DexiScale>; deprecated;
    method GetScalesFor(aAtt: DexiAttribute): DexiScaleList;
    method AttributeByName(aName: String; aIdx: Integer := 0): DexiAttribute;
    method AttributeByID(aID: String): DexiAttribute;
    method AttributesByID(aIDs: sequence of String): DexiAttributeList;
    method AttributeByPath(aPath: String): DexiAttribute;
    method AttributesByPath(aPaths: sequence of String): DexiAttributeList;
    method AttributeByIndices(aIndices: IntArray): DexiAttribute;
    method LinkAttributeByName(aName: String; aLast: Boolean := true): DexiAttribute;
    method InputAttributeByName(aName: String): DexiAttribute;
    method CanJoinAttributes(aSrc, aDest: DexiAttribute): Boolean;
    method JoinAttributes(aSrc, aDest: DexiAttribute): DexiAttribute;
    method CanMoveSubtree(aSrc, aDest: DexiAttribute): Boolean;
    method MoveSubtreeDeletes(aSrc, aDest: DexiAttribute): DexiObjectStrings;
    method MoveSubtree(aSrc, aDest: DexiAttribute): DexiAttribute;
    method CleanupAlternatives;
    method FindAlternative (aName: String; aCaseSensitive: Boolean := false; aIdx: Integer := 0): Integer;
    method AddAlternative(aName: String := ''; aDescription: String := ''): Integer;
    method AddAlternative(aAlt: IDexiAlternative): Integer;
    method AddAlternatives(aAlts: IDexiAlternatives; aOverload: Boolean; aPatch: Boolean := false): SetOfInt;
    method InsertAlternative(aIdx: Integer; aName: String := ''; aDescription: String := ''): Integer;
    method InsertAlternative(aIdx: Integer; aAlt: IDexiAlternative): Integer;
    method RemoveAlternative(aIdx: Integer): IDexiAlternative;
    method DeleteAlternative(aIdx: Integer);
    method DuplicateAlternative(aIdx: Integer): IDexiAlternative;
    method CopyAlternative(aFrom, aTo: Integer);
    method MoveAlternative(aFrom, aTo: Integer);
    method MoveAlternativePrev(aIdx: Integer);
    method MoveAlternativeNext(aIdx: Integer);
    method ExchangeAlternatives(aIdx1, aIdx2: Integer);
    method LinkAttributes;
    method SetInputAttributeOrder(aOrder: IntArray);
    method SetInputAttributeOrder(aOrder: DexiAttributeList);
    method OrderedInputAttributes: DexiAttributeList;
    method Evaluation; deprecated; // legacy Dexi evaluation
    method Evaluate(aType: EvaluationType := EvaluationType.Custom);
    method Evaluate(aAlt: Integer; aType: EvaluationType := EvaluationType.Custom; aLink: Boolean := true);
    method EvaluateNoLinking(aAlt: Integer; aType: EvaluationType := EvaluationType.Custom);
    method PlusMinus(aIdx: Integer; aDiff: Integer; aAtt: DexiAttribute := nil): DexiAlternative;
    method PlusMinus(aIdx: Integer; aMin, aMax: Integer; aAtt: DexiAttribute := nil): List<PlusMinusAlternative>;
    method EvaluateWithOffsets(aQQ2: Boolean := true): DexiOffAlternatives;
    method EvaluateWithOffsets(aAlt: Integer; aQQ2: Boolean := true): DexiOffAlternative;
    method EvaluateWithOffsets(aAlt: IDexiAlternative; aQQ2: Boolean := true): DexiOffAlternative;
    method EvaluateWithOffsets(aAlts: IDexiAlternatives; aQQ2: Boolean := true): DexiOffAlternatives;
    method EvaluateWithOffsets(aAlts: IntArray; aQQ2: Boolean := true): DexiOffAlternatives;
    method EvaluateWithOffsets(aAlt: DexiOffAlternative; aQQ2: Boolean := true);
    method EvaluateWithOffsets(aAlts: DexiOffAlternatives; aQQ2: Boolean := true);
    method DexiLibraryFeatures: List<String>;
    method UsesDexiLibraryFeatures: Boolean;
    method LoadFromFile(aFileName: String);
    method LoadAllFromStringList(aList: List<String>);
    method LoadFromStringList(aList: List<String>): DexiAttribute;
    method SaveToFile(aFileName: String);
    method SaveSubtreeToString(aAtt: DexiAttribute): String;
    method SaveToStringList(aAtt: DexiAttribute; var aList: List<String>);
    method SaveAllToStringList(var aList: List<String>);
    method SaveTreeToTabFile(aFileName: String);
    method SaveToGMLFile(aFileName: String);
    method SaveToJsonString(aSettings: DexiJsonSettings := nil): String;
    method SaveToJsonFile(aFileName: String; aSettings: DexiJsonSettings := nil);
    method CloneSubtree(aAtt: DexiAttribute): DexiAttribute;
    property XmlHandler: DexiXmlHandler read fXmlHandler write fXmlHandler;

    // Model editing methods
    method CanMovePrev(aAtt: DexiAttribute): Boolean;
    method MovePrev(aAtt: DexiAttribute);
    method CanMoveNext(aAtt: DexiAttribute): Boolean;
    method MoveNext(aAtt: DexiAttribute);
    method CanAddInputTo(aAtt: DexiAttribute): Boolean;
    method AddInputToDeletes(aAtt: DexiAttribute): DexiObjectStrings;
    method AddInputTo(aAtt: DexiAttribute): DexiAttribute;
    method CanAddSibling(aAtt: DexiAttribute): Boolean;
    method AddSiblingDeletes(aAtt: DexiAttribute): DexiObjectStrings;
    method AddSibling(aAtt: DexiAttribute): DexiAttribute;
    method CanDeleteBasic(aAtt: DexiAttribute): Boolean;
    method DeleteBasicDeletes(aAtt: DexiAttribute): DexiObjectStrings;
    method DeleteBasic(aAtt: DexiAttribute): DexiAttribute;
    method CanDeleteSubtree(aAtt: DexiAttribute): Boolean;
    method DeleteSubtree(aAtt: DexiAttribute): DexiAttribute;
    method CanCutSubtree(aAtt: DexiAttribute): Boolean;
    method CutSubtree(aAtt: DexiAttribute): DexiAttribute;
    method CanDuplicateSubtree(aAtt: DexiAttribute): Boolean;
    method DuplicateSubtree(aAtt: DexiAttribute): DexiAttribute;
    method DeleteScaleDeletes(aAtt: DexiAttribute): DexiObjectStrings;
    method ReverseScaleAffects(aAtt: DexiAttribute): DexiObjectStrings;
    method EditScaleAffects(aAtt: DexiAttribute): DexiObjectStrings;
    method CanAddValue(aAtt: DexiAttribute; aScl: DexiDiscreteScale; aFnc: DexiTabularFunction): Boolean;
    method CanDeleteValue(aScl: DexiDiscreteScale): Boolean;

    // Reports
    method NewModelReport: DexiModelReport;
    method NewStatisticsReport: DexiStatisticsReport;
    method NewAttributeTreeReport: DexiTreeReport;
    method NewAttributeDescriptionReport: DexiTreeAttributeReport;
    method NewAttributeScaleReport: DexiTreeAttributeReport;
    method NewAttributeFunctionSummaryReport: DexiTreeAttributeReport;
    method NewAttributeFunctionReport: DexiFunctionsReport;
    method NewWeightsReport: DexiWeightsReport;
    method NewAttributeReport: DexiAttributeReport;
    method NewAlternativesReport: DexiTreeAlternativesReport;
    method NewEvaluationReport: DexiTreeEvaluationReport;
    method NewFunctionReport(aAtt: DexiAttribute; aFunct: DexiFunction := nil): DexiSingleFunctionReport;
    method NewComparisonReport(aAlt: Integer): DexiAlternativeComparisonReport;
    method NewSelectiveExplanationReport: DexiSelectiveExplanationReport;
    method NewPlusMinusReport(aAtt: DexiAttribute; aAlt: Integer): DexiPlusMinusReport;
    method NewTargetReport(aAtt: DexiAttribute; aAlt: Integer): DexiTargetReport;
    method NewEvaluateQQReport: DexiTreeQQEvaluationReport;
    method CreateStandardReports;
    method ReportIsPrimary(aRpt: DexiReport): Boolean;

    /// <summary>
    /// Represents the root of the attribute hierarchy.
    /// In a logical sense, 'Root' is considered an internal and always-present attribute, which is
    /// not created by the user nor is exposed to the user in any way. 'Root' is needed to
    /// represent models that, from the user's perspective', consist of multiple separate hierarchies;
    /// these are represented as 'Root' children.
    /// </summary>
    /// <value>DexiAttribute</value>
    property Root: DexiAttribute read fRoot;
    property InputAttributeOrder: IntArray read fInputAttributeOrder write SetInputAttributeOrder;
    property Reports: List<DexiReportGroup> read fReports write fReports;
    property Evaluator: DexiEvaluator read fEvaluator;

    /// <summary>
    /// The first child of 'Root'.
    /// In a logical sense, this is the root of the first user-defined attribute hierarchy.
    /// </summary>
    /// <value>DexiAttribute</value>
    property First: DexiAttribute read GetFirst;

    property Modified: Boolean read fModified write fModified;
    property Linking: Boolean read GetLinking;
    property Undoing: Boolean read GetUndoing;
    property NeedsEvaluation: Boolean read fNeedsEvaluation write fNeedsEvaluation;
    property ModelName: String read GetModelName;
    property DefaultScale: DexiScale read GetDefaultScale write fDefaultScale;
    property Operation: String read fOperation write fOperation;

    /// <summary>
    /// Parameters determining how to compose and draw the current DEXi chart.
    /// </summary>
    /// <value>DexiChartParameters</value>
    property ChartParameters: DexiChartParameters read fChartParameters write fChartParameters;

    /// <summary>
    /// User settings (preferences) that affect the operation of DexiModel.
    /// </summary>
    /// <value>DexiSettings</value>
    property Settings: DexiSettings read fSettings write fSettings;

    /// <summary>
    /// The names of alternatives currently stored in this DexiModel.
    /// </summary>
    /// <value>DexiObjectList</value>
    property AltNames: DexiObjectList read fAltNames;

    property AltCount: Integer read fAltNames.Count;

    /// <summary>
    /// The value of the aIdx'th alternative assigned to DexiAttribute aAtt.
    /// </summary>
    /// <param name="aIdx">Index of alternative.</param>
    /// <param name="aAtt">An attribute from this DexiModel.</param>
    /// <value>DexiValue</value>
    property AltValue[aIdx: Integer; aAtt: DexiAttribute]: DexiValue read GetAltValue write SetAltValue;

    /// <summary>
    /// The aIdx'th decision alternative stored in this DexiModel.
    /// </summary>
    /// <param name="aIdx">Integer index</param>
    /// <value>IDexiAlternative</value>
    property Alternative[aIdx: Integer]: IDexiAlternative read GetAlternative write SetAlternative;

    property AltExclude: IntSet read fAltExclude write fAltExclude;

    /// <summary>
    /// Supplementary QQ-evaluation of alternatives. DexiModel provides only a placeholder for this data.
    /// Evaluation and assignment of OffAlternatives must be handled explicitly outside of DexiModel.
    /// </summary>
    /// <value></value>
    property OffAlternatives: DexiOffAlternatives read fOffAlternatives write fOffAlternatives;

    property Selected[aIdx: Integer]: Boolean read GetSelected write SetSelected;
    property RptCount: Integer read if fReports = nil then 0 else fReports.Count;

    method DeepCompare(aAlt1, aAlt2: IDexiAlternative; aRoot: DexiAttribute := nil): Dictionary<DexiAttribute, DeepComparison>;

    /// <summary>
    /// Whether or not to force the new DEXiLibrary .dxi file format.
    /// By default, the old DEXi .dxi format is preserved unles new DEXiLibrary features are used.
    /// </summary>
    /// <value></value>
    property ForceLibraryFormat: Boolean read fForceLibraryFormat write fForceLibraryFormat;

    /// <summary>
    /// Creation Date/Time of this DexiModel.
    /// </summary>
    /// <value>String</value>
    property Created: String read fCreated write fCreated;

    /// <summary>
    /// Name of the file from which this DexiModel has been loaded (to facilitate saving operations).
    /// </summary>
    /// <value>String</value>
    property FileName: String read fFileName write fFileName;

    method CheckModelStructure: DexiObjectStrings;
    method MakeUniqueAttributeIDs(aCaseSensitive: Boolean := false);
    method MakeUniqueAlternativeNames(aCaseSensitive: Boolean := false);

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>); override;
    method EqualStateAs(aObj: IUndoable): Boolean; override;
    method GetUndoState: IUndoable; override;
    method SetUndoState(aState: IUndoable); override;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiModelStatistics}

constructor DexiModelStatistics;
begin
  Clear;
end;

method DexiModelStatistics.Clear;
begin
  Attributes := 0;
  BasicAttributes := 0;
  AggregateAttributes := 0;
  LinkedAttributes := 0;
  Scales := 0;
  DiscrScales := 0;
  ContScales := 0;
  UndefScales := 0;
  Functions := 0;
  TabularFunctions := 0;
  DiscretizeFunctions := 0;
  UndefFunctions := 0;
  Alternatives := 0;
  Depth := 0;
  Width := 0.0;
  MinWidth := high(Integer);
  MaxWidth := low(Integer);
  Rules := 0.0;
  MinRules := high(Integer);
  MaxRules := low(Integer);
end;

{$ENDREGION}

{$REGION DexiSettings}

constructor DexiSettings;
begin
  inherited constructor;
  Clear;
end;

constructor DexiSettings(aSettings: DexiSettings);
begin
  inherited constructor;
  Assign(aSettings);
 end;

method DexiSettings.Clear;
begin
  fLinking := false;
  fUndoing := true;
  fRptHtml := false;
  fDefBrowser := false;
  fSelectedReports := Values.IntSet(0, MaxReports - 1);
  fSelectedWeights := Values.IntSet(0, MaxWeights - 1);
  fPagebreak := false;
  fBadColor := new ColorInfo('FF0000');
  fNeutralColor := new ColorInfo('000000');
  fGoodColor := new ColorInfo('008000');
  fMaxColumns := 0;
  fEvalTrim := 0;
  fWeiDecimals := 0;
  fFncShowWeights := true;
  fFncShowNumbers := true;
  fFncComplex := true;
  fFncEnteredOnly := false;
  fFontSize := 10;
  fFontName := 'Arial';
  fValueType := ValueStringType.One;
  fAltDataAll := true;
  fAltTranspose := false;
  fAltLevels := true;
  fFncDataType := ValueStringType.One;
  fFncDataAll := true;
  fFncStatus := false;
  fModelProtect := false;
  fEvalType := EvaluationType.AsSet;
  fExpandUndef := true;
  fExpandEmpty := true;
  fCheckBounds := true;
  fWarnings := true;
  fRepresentation := DexiRptFunctionRepresentation.Complex;
  fMemDecimals := 2;
  fDefDetDecimals := 2;
  fFltDecimals := 4;
  fUseReportHeader := false;
  fTreePattern := RptTreePattern.Lines;
  fSectionBreak := RptSection.BreakAll;
  fTableBreak := RptSection.BreakAll;
  fCsvInvariant := true;
  fReportFontInfo := FontInfo.DefaultFont;
  fBadStyle := 'B';
  fNeutralStyle := '';
  fGoodStyle := 'BI';
  fFncNormalizedWeights := true;
  fFncShowNumericValues := false;
  fFncShowMarginals := false;
  fCanMoveTabs := true;
  fAttId := AttributeIdentification.Name;
  fUseDexiStringValues := false;
  fJsonSettings := nil;
end;

method DexiSettings.Assign(aSettings: DexiSettings);
begin
  fLinking := aSettings.Linking;
  fUndoing := aSettings.Undoing;
  fRptHtml := aSettings.RptHtml;
  fDefBrowser := aSettings.DefBrowser;
  fSelectedReports := Utils.CopyIntArray(aSettings.SelectedReports);
  fSelectedWeights := Utils.CopyIntArray(aSettings.SelectedWeights);
  fPagebreak := aSettings.Pagebreak;
  fBadColor := aSettings.BadColor;
  fNeutralColor := aSettings.NeutralColor;
  fGoodColor := aSettings.GoodColor;
  fWeiDecimals := aSettings.WeiDecimals;
  fMaxColumns := aSettings.fMaxColumns;
  fEvalTrim := aSettings.EvalTrim;
  fFncShowWeights := aSettings.FncShowWeights;
  fFncShowNumbers := aSettings.FncShowNumbers;
  fFncComplex := aSettings.FncComplex;
  fFncEnteredOnly := aSettings.FncEnteredOnly;
  fFontSize := aSettings.FontSize;
  fFontName := aSettings.FontName;
  fValueType := aSettings.ValueType;
  fAltDataAll := aSettings.AltDataAll;
  fAltTranspose := aSettings.AltTranspose;
  fAltLevels := aSettings.AltLevels;
  fFncDataType := aSettings.FncDataType;
  fFncDataAll := aSettings.FncDataAll;
  fFncStatus := aSettings.FncStatus;
  fModelProtect := aSettings.ModelProtect;
  fEvalType := aSettings.EvalType;
  fExpandUndef := aSettings.ExpandUndef;
  fExpandEmpty := aSettings.ExpandEmpty;
  fCheckBounds := aSettings.CheckBounds;
  fWarnings := aSettings.Warnings;
  fRepresentation := aSettings.Representation;
  fMemDecimals := aSettings.MemDecimals;
  fDefDetDecimals := aSettings.DefDetDecimals;
  fFltDecimals := aSettings.FltDecimals;
  fUseReportHeader := aSettings.UseReportHeader;
  fTreePattern := aSettings.TreePattern;
  fSectionBreak := aSettings.SectionBreak;
  fTableBreak := aSettings.TableBreak;
  fCsvInvariant := aSettings.CsvInvariant;
  fReportFontInfo := new FontInfo(aSettings.ReportFontInfo);
  fBadStyle := aSettings.BadStyle;
  fNeutralStyle := aSettings.NeutralStyle;
  fGoodStyle := aSettings.GoodStyle;
  fFncNormalizedWeights := aSettings.FncNormalizedWeights;
  fFncShowNumericValues := aSettings.FncShowNumericValues;
  fFncShowMarginals := aSettings.FncShowmarginals;
  fCanMoveTabs := aSettings.CanMoveTabs;
  fAttId := aSettings.AttId;
  fUseDexiStringValues := aSettings.UseDexiStringValues;
  fJsonSettings :=
    if aSettings.JsonSettings = nil then nil
    else new DexiJsonSettings(aSettings.JsonSettings);
end;

class method DexiSettings.ValTypeString(aType: ValueStringType): String;
begin
  result :=
    case aType of
      ValueStringType.Zero: 'Zero';
      ValueStringType.Text: 'Text';
      else 'One';
    end;
end;

class method  DexiSettings.ValStringType(aString: String): ValueStringType;
begin
  result :=
    if aString = 'Zero' then ValueStringType.Zero
    else if aString = 'Text' then ValueStringType.Text
    else ValueStringType.One
end;

class method DexiSettings.JsonInputString(aInputs: DexiJsonInputs): String;
begin
  result :=
    case aInputs of
      DexiJsonInputs.IDs: 'IDs';
      DexiJsonInputs.List: 'List';
      DexiJsonInputs.None: 'None';
      else nil;
    end;
end;

method DexiSettings.CollectUndoableObjects(aList: List<IUndoable>);
begin
  UndoUtils.Include(aList, JsonSettings);
end;

method DexiSettings.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiSettings then
    exit false;
  var lSettings := DexiSettings(aObj);
  result :=
    (fLinking = lSettings.Linking) and
    (fUndoing = lSettings.Undoing) and
    (fRptHtml = lSettings.RptHtml) and
    (fDefBrowser = lSettings.DefBrowser) and
    Utils.IntArrayEq(fSelectedReports, lSettings.fSelectedReports) and
    Utils.IntArrayEq(fSelectedWeights, lSettings.fSelectedWeights) and
    (fPagebreak = lSettings.Pagebreak) and
    (fBadColor = lSettings.BadColor) and
    (fNeutralColor = lSettings.NeutralColor) and
    (fGoodColor = lSettings.GoodColor) and
    (fWeiDecimals = lSettings.WeiDecimals) and
    (fMaxColumns = lSettings.fMaxColumns) and
    (fEvalTrim = lSettings.EvalTrim) and
    (fFncShowWeights = lSettings.FncShowWeights) and
    (fFncShowNumbers = lSettings.FncShowNumbers) and
    (fFncComplex = lSettings.FncComplex) and
    (fFncEnteredOnly = lSettings.FncEnteredOnly) and
    (fFontSize = lSettings.FontSize) and
    (fFontName = lSettings.FontName) and
    (fValueType = lSettings.ValueType) and
    (fAltDataAll = lSettings.AltDataAll) and
    (fAltTranspose = lSettings.AltTranspose) and
    (fAltLevels = lSettings.AltLevels) and
    (fFncDataType = lSettings.FncDataType) and
    (fFncDataAll = lSettings.FncDataAll) and
    (fFncStatus = lSettings.FncStatus) and
    (fModelProtect = lSettings.ModelProtect) and
    (fEvalType = lSettings.EvalType) and
    (fExpandUndef = lSettings.ExpandUndef) and
    (fExpandEmpty = lSettings.ExpandEmpty) and
    (fCheckBounds = lSettings.CheckBounds) and
    (fWarnings = lSettings.Warnings) and
    (fRepresentation = lSettings.Representation) and
    (fMemDecimals = lSettings.MemDecimals) and
    (fDefDetDecimals = lSettings.DefDetDecimals) and
    (fFltDecimals = lSettings.FltDecimals) and
    (fUseReportHeader = lSettings.UseReportHeader) and
    (fTreePattern = lSettings.TreePattern) and
    (fSectionBreak = lSettings.SectionBreak) and
    (fTableBreak = lSettings.TableBreak) and
    (fCsvInvariant = lSettings.CsvInvariant) and
    (fReportFontInfo.AsString = lSettings.ReportFontInfo.AsString) and
    (fBadStyle = lSettings.BadStyle) and
    (fNeutralStyle = lSettings.NeutralStyle) and
    (fGoodStyle = lSettings.GoodStyle) and
    (fFncNormalizedWeights = lSettings.FncNormalizedWeights) and
    (fFncShowNumericValues = lSettings.FncShowNumericValues) and
    (fFncShowMarginals = lSettings.FncShowMarginals) and
    (fCanMoveTabs = lSettings.CanMoveTabs) and
    (fAttId = lSettings.AttId) and
    (fUseDexiStringValues = lSettings.UseDexiStringValues);
end;

method DexiSettings.GetUndoState: IUndoable;
begin
  result := new DexiSettings(self);
end;

method DexiSettings.SetUndoState(aState: IUndoable);
begin
  var lSettings := aState as DexiSettings;
  Assign(lSettings);
end;

method DexiSettings.GetMaxColumns: Integer;
begin
  result :=
    if fMaxColumns <= 0 then DefMaxColumns
    else fMaxColumns;
end;

method DexiSettings.HasFullReports: Boolean;
begin
  result := Values.IntSetEq(fSelectedReports, Values.IntSet(0, DexiSettings.MaxReports - 1));
end;

method DexiSettings.HasFullWeights: Boolean;
begin
  result := Values.IntSetEq(fSelectedWeights, Values.IntSet(0, DexiSettings.MaxWeights - 1));
end;

method DexiSettings.GetSelectedReport(aIdx: Integer): Boolean;
begin
  result := Values.IntSetMember(fSelectedReports, aIdx);
end;

method DexiSettings.GetSelectedWeight(aIdx: Integer): Boolean;
begin
  result := Values.IntSetMember(fSelectedWeights, aIdx);
end;

method DexiSettings.SelectReport(aIdx: Integer; aSel: Boolean);
begin
  if aSel then
    Values.IntSetInclude(var fSelectedReports, aIdx)
  else
    Values.IntSetExclude(var fSelectedReports, aIdx)
end;

method DexiSettings.SelectWeight(aIdx: Integer; aSel: Boolean);
begin
  if aSel then
    Values.IntSetInclude(var fSelectedWeights, aIdx)
  else
    Values.IntSetExclude(var fSelectedWeights, aIdx)
end;

{$ENDREGION}

{$REGION DexiModelAlternative}

constructor DexiModelAlternative(aModel: DexiModel; aIdx: Integer);
begin
  fModel := aModel;
  fIndex := aIdx;
end;

method DexiModelAlternative.GetName: String;
begin
  result := fModel.AltNames[fIndex].Name;
end;

method DexiModelAlternative.SetName(aName: String);
begin
  fModel.AltNames[fIndex].Name := aName;
end;

method DexiModelAlternative.GetDescription: String;
begin
  result := fModel.AltNames[fIndex].Description;
end;

method DexiModelAlternative.SetDescription(aDescription: String);
begin
  fModel.AltNames[fIndex].Description := aDescription;
end;

method DexiModelAlternative.GetValue(aAtt: DexiAttribute): DexiValue;
begin
  result := aAtt.AltValue[fIndex];
end;

method DexiModelAlternative.SetValue(aAtt: DexiAttribute; aValue: DexiValue);
begin
  aAtt.AltValue[fIndex] := aValue;
end;

method DexiModelAlternative.Copy: DexiAlternative;

  method GetAltVal(aAlt: IDexiAlternative; aAtt: DexiAttribute);
  begin
    var lVal := GetValue(aAtt);
    aAlt.Value[aAtt] := lVal;
    for i := 0 to aAtt.InpCount - 1 do
      GetAltVal(aAlt, aAtt.Inputs[i]);
  end;

begin
  result := new DexiAlternative(Name, Description);
  for i := 0 to fModel.Root.InpCount - 1 do
    GetAltVal(result, fModel.Root.Inputs[i]);
end;

method DexiModelAlternative.ModifyFrom(aAlt: DexiAlternative);

  method ModifyValue(aAtt: DexiAttribute);
  begin
    var lVal := aAlt.Value[aAtt];
    if lVal <> nil then
      Value[aAtt] := DexiValue.CopyValue(lVal);
    for i := 0 to aAtt.InpCount - 1 do
      ModifyValue(aAtt.Inputs[i]);
  end;

begin
  for i := 0 to fModel.Root.InpCount - 1 do
    ModifyValue(fModel.Root.Inputs[i]);
end;

{$ENDREGION}

{$REGION DeepComparison}

constructor DeepComparison(aHere: PrefCompare := PrefCompare.No; aBelow: PrefCompare := PrefCompare.No);
begin
  fHere := aHere;
  fBelow := aBelow;
end;

{$ENDREGION}

{$REGION DexiModel}

/// <summary>
/// Creates a new DexiModel.
/// </summary>
/// <param name="aName">Name of the new model (optional)</param>
/// <returns></returns>
class method DexiModel.NewModel(aName: String := nil): DexiModel;
begin
  result := new DexiModel;
  if aName <> nil then
    result.Name := aName;
  var lAtt := new DexiAttribute;
  if aName <> nil then
    lAtt.Name := aName;
  result.Root.AddInput(lAtt);
  result.CreateStandardReports;
end;

/// <summary>
/// Creates a new DexiModel.
/// </summary>
constructor DexiModel;
begin
  inherited constructor;
  fReports := nil;
  fSettings := new DexiSettings;
  fAltNames := new DexiObjectList;
  fEvaluator := new DexiEvaluator(self);
  fCreated := Utils.ISODateTimeStr(DateTime.UtcNow);
  Clear;
end;

/// <summary>
/// Empties the contents of this DexiModel.
/// </summary>
method DexiModel.Clear;
begin
  fRoot := new DexiAttribute;
  fRoot.Name := DexiString.MStrRootName;
  fAltExclude := [];
  fChartParameters := new DexiChartParameters;
  fModified := true;
  fNeedsEvaluation := true;
  fFileName := '';
end;

/// <summary>
/// Makes an indication that this DexiModel has been modified and that alternatives need to be re-evaluated.
/// </summary>
method DexiModel.Modify;
begin
  fModified := true;
  fNeedsEvaluation := true;
//  LinkAttributes;
end;

/// <summary>
/// Calculates the basic statistics of this DexiModel.
/// </summary>
/// <returns>DexModelStatistics</returns>
method DexiModel.Statistics: DexiModelStatistics;
var
  lResult: DexiModelStatistics;
  lDepth: Integer;
  lWidth, lRules: Float;

  method CountAttributes(aAtt: DexiAttribute; aLev: Integer);
  begin
    if aLev > lDepth then
      lDepth := aLev;
    inc(lResult.Attributes);
    if aAtt.IsBasic then
      if aAtt.Link <> nil then inc(lResult.LinkedAttributes)
      else inc(lResult.BasicAttributes)
    else
      begin
        inc(lResult.AggregateAttributes);
        lResult.MinWidth := Math.Min(lResult.MinWidth, aAtt.InpCount);
        lResult.MaxWidth := Math.Max(lResult.MaxWidth, aAtt.InpCount);
        lWidth := lWidth + aAtt.InpCount;
      end;
    if aAtt.Scale = nil then
      inc(lResult.UndefScales)
    else
      begin
        inc(lResult.Scales);
        if aAtt.Scale.IsDiscrete then
          inc(lResult.DiscrScales)
        else if aAtt.Scale.IsContinuous then
          inc(lResult.ContScales);
      end;
    if aAtt.Funct = nil then
      begin
        if aAtt.IsAggregate then
          inc(lResult.UndefFunctions);
      end
    else
      begin
        inc(lResult.Functions);
        if aAtt.Funct is DexiTabularFunction then
          begin
            inc(lResult.TabularFunctions);
            var lCount := aAtt.Funct.Count;
            lResult.MinRules := Math.Min(lResult.MinRules, lCount);
            lResult.MaxRules := Math.Max(lResult.MaxRules, lCount);
            lRules := lRules + lCount;
          end
        else if aAtt.Funct is DexiDiscretizeFunction then
          inc(lResult.DiscretizeFunctions);
      end;
    for i := 0 to aAtt.InpCount - 1 do
      CountAttributes(aAtt.Inputs[i], aLev + 1);
  end;

begin
  lResult := new DexiModelStatistics;
  lDepth := 0;
  lWidth := 0.0;
  lResult.Alternatives := if fAltNames = nil then 0 else fAltNames.Count;
  for i := 0 to Root.InpCount - 1 do
    CountAttributes(Root.Inputs[i], 0);
  lResult.Depth := lDepth;
  if lResult.AggregateAttributes > 0 then
    lResult.Width := lWidth / lResult.AggregateAttributes;
  if lResult.TabularFunctions > 0 then
    lResult.Rules := lRules / lResult.TabularFunctions;
  result := lResult;
end;

/// <summary>
/// Returns the first exposed root attribute of this DexiModel.
/// This is the first child of 'Root'.
/// </summary>
/// <returns>DexiAttribute</returns>
method DexiModel.GetFirst: DexiAttribute;
begin
  result :=
    if (fRoot <> nil) and (fRoot.InpCount > 0) then fRoot.Inputs[0]
    else nil;
end;

/// <summary>
/// Get model name. If empty or nil, return the name of 'First'.
/// </summary>
/// <returns>String</returns>
method DexiModel.GetModelName: String;
begin
  var lFirst := GetFirst;
  result :=
    if not String.IsNullOrEmpty(Name) then Name
    else if lFirst <> nil then lFirst.Name
    else '';
end;

method DexiModel.GetDefaultScale: DexiScale;
begin
  result := fDefaultScale;
end;

method DexiModel.GetSelected(aIdx: Integer): Boolean;
begin
  result := not Values.IntSetMember(fAltExclude, aIdx);
end;

method DexiModel.SetSelected(aIdx: Integer; aSel: Boolean);
begin
  if aSel then
    Values.IntSetExclude(var fAltExclude, aIdx)
  else
    Values.IntSetInclude(var fAltExclude, aIdx);
end;

method DexiModel.GetLinking: Boolean;
begin
  result := fSettings.Linking;
end;

method DexiModel.GetUndoing: Boolean;
begin
  result := fSettings.Undoing;
end;

method DexiModel.GetAltValue(aIdx: Integer; aAtt: DexiAttribute): DexiValue;
begin
  result := aAtt.AltValue[aIdx];
end;

method DexiModel.SetAltValue(aIdx: Integer; aAtt: DexiAttribute; aValue: DexiValue);
begin
  aAtt.AltValue[aIdx] := DexiValue.CopyValue(aValue);
end;

method DexiModel.GetAlternative(aIdx: Integer): IDexiAlternative;
begin
  result := new DexiModelAlternative(self, aIdx);
end;

method DexiModel.SetAlternative(aIdx: Integer; aAlt: IDexiAlternative);

  method SetAltVal(aAtt: DexiAttribute);
  begin
    aAtt.AltValue[aIdx] := aAlt.Value[aAtt];
    for i := 0 to aAtt.InpCount - 1 do
      SetAltVal(aAtt.Inputs[i]);
  end;

begin
  AltNames[aIdx].Name := aAlt.Name;
  AltNames[aIdx].Description := aAlt.Description;
  for i := 0 to Root.InpCount - 1 do
    SetAltVal(Root.Inputs[i]);
end;

/// <summary>
/// Returns the list of scales from this DexiModel that are compatible with aCompScale.
/// </summary>
/// <param name="aAtt">A DexiAttribute whose scale is included in the list. May be nil.</param>
/// <param name="aCompScale">A DexiScale against which the compatibility is checked.
/// When nil, all attribute scales are included.</param>
/// <returns>DexiStrings<DexiScale></returns>
method DexiModel.GetScaleStrings(aAtt: DexiAttribute; aCompScale: DexiScale := nil): DexiStrings<DexiScale>;
var lResult: DexiStrings<DexiScale>;

  method AddScale(aAtt: DexiAttribute);
  begin
    if aAtt.Scale <> nil then
      if (aCompScale = nil) or aCompScale.CompatibleWith(aAtt.Scale) then
        begin
          var s := aAtt.Scale.ScaleString;
          if lResult.IndexOf(s) < 0 then
            lResult.Add(s, aAtt.Scale);
        end;
    for i := 0 to aAtt.InpCount - 1 do
      AddScale(aAtt.Inputs[i]);
  end;

begin
  lResult := new DexiStrings<DexiScale>;
  if aCompScale = nil then
    lResult.Add(DexiString.SDexiNullScale, nil);
  if aAtt <> nil then
    AddScale(aAtt);
  for i := 0 to Root.InpCount - 1 do
    AddScale(Root.Inputs[i]);
  result := lResult;
end;

/// <summary>
/// Returns the list of substantially different scales from this DexiModel.
/// Among mutually compatible scales, only the first one is included.
/// </summary>
/// <returns>DexiStrings<DexiScale></returns>
method DexiModel.GetDifferentScales: DexiStrings<DexiScale>;
var lResult: DexiStrings<DexiScale>;

  method AddScale(aAtt: DexiAttribute);
  begin
    if aAtt.Scale <> nil then
      begin
        var Eq := false;
        for i := 0 to lResult.Count - 1 do
          if aAtt.Scale.EqualTo(lResult[i].Obj) then
            begin
              Eq := true;
              break;
            end;
        if not Eq then
          lResult.Add(aAtt.Name, aAtt.Scale);
      end;
    for i := 0 to aAtt.InpCount - 1 do
      AddScale(aAtt.Inputs[i]);
  end;

begin
  lResult := new DexiStrings<DexiScale>;
  for i := 0 to Root.InpCount - 1 do
    AddScale(Root.Inputs[i]);
  result := lResult;
end;

/// <summary>
/// Returns scales compatible with aAtt.Scale. Such scales can be assigned to aAtt without
/// changing any DexiFunctions in the context of aAtt.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiScaleList</returns>
method DexiModel.GetScalesFor(aAtt: DexiAttribute): DexiScaleList;
var lResult: DexiScaleList;

  method TryAddScale(aScl: DexiScale);
  begin
    if aScl = nil then
      exit;
    if not aAtt.CanSetScale(aScl) then
      exit;
    for each lScl in lResult do
      if lScl.EqualTo(aScl) then
        exit;
    lResult.Add(aScl);
  end;

begin
  lResult := new DexiScaleList;
  TryAddScale(aAtt.Scale);
  if DefaultScale <> aAtt.Scale then
    TryAddScale(DefaultScale);
  var lAtts := Root.CollectInputs;
  for each lAtt in lAtts do
    TryAddScale(lAtt.Scale);
  result := lResult;
end;

/// <summary>
/// Find a DexiAttribute named 'aName' in this DexiModel.
/// The index 'aIdx' can be specified to resolve cases of mutiple attributes with the same name.
/// </summary>
/// <param name="aName">String, attribute Name</param>
/// <param name="aIdx">Find the aIdx'th occurence of 'aName' (optional, default = 0)</param>
/// <returns>DexiAttribute or nil if not found.</returns>
method DexiModel.AttributeByName(aName: String; aIdx: Integer := 0): DexiAttribute;
var lResult: DexiAttribute;

  method Find(aAtt: DexiAttribute);
  begin
    if lResult <> nil then
      exit;
    if aAtt.Name = aName then
      begin
        if aIdx <= 0 then
          begin
            lResult := aAtt;
            exit;
          end
        else
          dec(aIdx);
      end;
    for i := 0 to aAtt.InpCount - 1 do
      Find(aAtt.Inputs[i]);
  end;

begin
  lResult := nil;
  for i := 0 to Root.InpCount - 1 do
    Find(Root.Inputs[i]);
  result := lResult;
end;

/// <summary>
/// Find the DexiAttribute by an ID.
/// IDs are unique, but need to be created explicitly beforehand by calling 'DexiModel.MakeUniqueAttributeIDs'
/// </summary>
/// <param name="aID">String, an attribute ID.</param>
/// <returns>DexiAttribute or nil if not found.</returns>
method DexiModel.AttributeByID(aID: String): DexiAttribute;
var lResult: DexiAttribute;

  method Find(aAtt: DexiAttribute);
  begin
    if lResult <> nil then
      exit;
    if aAtt.ID = aID then
      begin
        lResult := aAtt;
        exit;
      end;
    for i := 0 to aAtt.InpCount - 1 do
      Find(aAtt.Inputs[i]);
  end;

begin
  lResult := nil;
  Find(Root);
  result := lResult;
end;

/// <summary>
/// 
/// </summary>
/// <param name="aIDs">Sequence of attribute IDs</param>
/// <returns>A list of attributes in the order of IDs.</returns>
method DexiModel.AttributesByID(aIDs: sequence of String): DexiAttributeList;
begin
  result := new DexiAttributeList;
  for each lID in aIDs do
    result.Add(AttributeByID(lID));
end;

/// <summary>
/// 
/// </summary>
/// <param name="aIDs">Sequence of attribute paths</param>
/// <returns>A list of attributes in the order of paths.</returns>
method DexiModel.AttributesByPath(aPaths: sequence of String): DexiAttributeList;
begin
  result := new DexiAttributeList;
  for each lpath in aPaths do
    result.Add(AttributeByPath(lPath));
end;

/// <summary>
/// Find the DexiAttribute by path.
/// Path is a string consisting of a sequence of attribute names starting from the 'Root'.
/// Names are separated by a character that appears as the first character of 'aPath'.
/// For example: "/MyRoot/FirstRootChild/ThirdChild" may find the attribute named "ThirdChild",
/// positioned below the attribute named "FirstRootChild", which is in turn a child of
/// the user-defined root attribute named "MyRoot".
/// The string "%MyRoot%FirstRootChild%ThirdChild" defines the same path, but with a different separator, "%".
/// </summary>
/// <param name="aPath">String defining the name path of an attribute.</param>
/// <returns>DexiAttribute or nil if not found.</returns>
method DexiModel.AttributeByPath(aPath: String): DexiAttribute;
begin
  result := nil;
  if String.IsNullOrEmpty(aPath) then
    exit;
  var sep := aPath[0];
  var path := aPath.Split(sep);
  var att := Root;
  for p := 1 to path.Count - 1 do
    begin
      var x := -1;
      for i := 0 to att.InpCount - 1 do
        if att.Inputs[i].Name = path[p] then
          begin
            x := i;
            break;
          end;
      if x < 0 then
        exit;
      att := att.Inputs[x];
    end;
  result := att;
end;

/// <summary>
/// Find an attribute given successive indices of attributes starting from the user-defined root.
/// Indices are zero-based.
/// Example: AttributeByIndices([0, 1, 0]) will try fo find the first user-defined root attribute,
/// proceed to its second child attribute and return the first child of the latter.
/// </summary>
/// <param name="aIndices">IntArray, a sequence of zero-based indices.</param>
/// <returns>DexiAttribute or nil if not found.</returns>
method DexiModel.AttributeByIndices(aIndices: IntArray): DexiAttribute;
begin
  result := nil;
  var lAtt := Root;
  for each lIdx in aIndices do
    begin
      if 0 <= lIdx < lAtt.InpCount then
        lAtt := lAtt.Inputs[lIdx]
      else
        exit;
    end;
  result := lAtt;
end;

/// <summary>
/// Find an possible link candidate for an attribute named 'aName'.
/// In the case of multiple candidates, aggregate attributes take precedence over basic attributes.
/// </summary>
/// <param name="aName">Attribute name.</param>
/// <param name="aLast">In the case of multiple basic candidates, 'aLast' determines whether to take the first or last one.</param>
/// <returns>DexiAttribute or nil if not found.</returns>
method DexiModel.LinkAttributeByName(aName: String; aLast: Boolean := true): DexiAttribute;
var
  lAgg, lBas: DexiAttribute;
  lAggCount: Integer;

  method Find(aAtt: DexiAttribute);
  begin
    if (aAtt.Name = aName) and (aAtt.Link = nil) then
      if aAtt.IsBasic then
        begin
          if (lBas = nil) or aLast then
            lBas := aAtt;
        end
      else
        begin
          lAgg := aAtt;
          inc(lAggCount);
        end;
    for i := 0 to aAtt.InpCount - 1 do
      Find(aAtt.Inputs[i]);
  end;

begin
  lAgg := nil;
  lBas := nil;
  lAggCount := 0;
  for i := 0 to Root.InpCount - 1 do
    Find(Root.Inputs[i]);
  result :=
    if (lAgg <> nil) and (lAggCount = 1) then lAgg
    else lBas;
end;

method DexiModel.InputAttributeByName(aName: String): DexiAttribute;
var lAgg, lBas: DexiAttribute;

  method Find(aAtt: DexiAttribute);
  begin
    if aAtt.Name = aName then
      if aAtt.IsBasic and (aAtt.Link = nil) then
        lBas := aAtt
      else
        lAgg := aAtt;
    for i := 0 to aAtt.InpCount - 1 do
      Find(aAtt.Inputs[i]);
  end;

begin
  lAgg := nil;
  lBas := nil;
  for i := 0 to Root.InpCount - 1 do
    Find(Root.Inputs[i]);
  result := if lBas <> nil then lBas else lAgg;
end;

/// <summary>
/// Is it possible to join two attributes 'aSrc' and 'aDest'?
/// Joining means overlying the two without causing inconsistencies in the related components (scales and functions).
/// 'aSrc' must be the only child of 'aDest', their scales must be compatible and 'aDest.Funct' must be nil.
/// </summary>
/// <param name="aSrc">Source DexiAttribute.</param>
/// <param name="aDest">Destination DexiAttribute.</param>
/// <returns>Boolean</returns>
method DexiModel.CanJoinAttributes(aSrc, aDest: DexiAttribute): Boolean;
begin
  result :=
    (aDest <> nil) and (aSrc <> nil) and (aDest <> aSrc) and (aSrc.Parent = aDest) and (aDest <> Root) and
    (aDest.InpCount = 1) and (aDest.Funct = nil) and
    DexiScale.AssignmentCompatibleScales(aDest.Scale, aSrc.Scale);
end;

/// <summary>
/// Join the attributes 'aSrc' and 'aDest'. See 'DexiModel.CanJoinAttributes' for preconditions.
/// As a result of this operation, 'aSrc' replaces 'aDest' in the place of aDest.Parent's child.
/// All aDest's components not present in 'aSrc' are copied to 'aSrc'.
/// All components of 'aDest' (scale, function, children) are deleted, leaving 'aDest' as an "orphaned" DexiAttribute.
/// </summary>
/// <param name="aSrc">Source DexiAttribute.</param>
/// <param name="aDest">Destination DexiAttribute.</param>
/// <returns>DexiAttribute 'aSrc', or nil after an unsuccessful operation.</returns>
method DexiModel.JoinAttributes(aSrc, aDest: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if (aDest = nil) or (aSrc = nil) then
    exit;
  if aDest.InpCount <> 1 then
    exit;
  if aDest.Inputs[0] <> aSrc then
    exit;
  var lParent := aDest.Parent;
  if lParent <> nil then
    begin
      var x := lParent.InpIndex(aDest);
      if x < 0 then
        exit;
      lParent.Inputs[x] := aSrc;
      aSrc.Parent := lParent;
    end;
  result := aSrc;
  if aSrc.Name = '' then
    begin
      aSrc.Name := aDest.Name;
      aSrc.Description := aDest.Description;
    end;
  if aSrc.Scale = nil then
    aSrc.Scale := aDest.Scale;
  aDest.Parent := nil;
  aDest.Scale := nil;
  aDest.Funct := nil;
  aDest.DeleteInputs;
end;

/// <summary>
/// Is it possible to move the subtree rooted at 'aSrc' so as to become a child of 'aDest'?
/// The main condition is that moving should not introduce cycles in the hierarchy.
/// </summary>
/// <param name="aSrc">Source DexiAttribute.</param>
/// <param name="aDest">Destination DexiAttribute.</param>
/// <returns>Boolean</returns>
method DexiModel.CanMoveSubtree(aSrc, aDest: DexiAttribute): Boolean;
begin
  result := (aSrc <> nil) and (aDest <> nil) and (aSrc <> aDest) and (aSrc.Parent <> aDest) and not aDest.Affects(aSrc)
            and not aDest.IsContinuous;
end;

/// <summary>
/// Returns the list of DexiObjects that are deleted when moving subtrees with ' DexiModel.MoveSubtree'.
/// </summary>
/// <param name="aSrc">Source DexiAttribute.</param>
/// <param name="aDest">>Destination DexiAttribute.</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.MoveSubtreeDeletes(aSrc, aDest: DexiAttribute): DexiObjectStrings;
begin
  result := nil;
  var lSrcFunct := aSrc:Parent:Funct;
  var lDestFunct := aDest:Funct;
  if (lSrcFunct <> nil) or (lDestFunct <> nil) then
    begin
      result := new DexiObjectStrings;
      if lSrcFunct <> nil then
        result.Add(aSrc:Parent:Name, lSrcFunct);
      if (lDestFunct <> nil) and (lDestFunct <> lSrcFunct) then
        result.Add(aDest:Name, lDestFunct);
    end;
end;

/// <summary>
/// Move the subtree rooted at 'aSrc' so as to become a child of 'aDest'. See 'DexiModel.CanMoveSubtree' for preconditions.
/// Functions of 'aSrc' and 'aDest', if defined, are deleted in the process.
/// </summary>
/// <param name="aSrc">Source DexiAttribute.</param>
/// <param name="aDest">Destination DexiAttribute.</param>
/// <returns>DexiAttribute 'aSrc', or nil after an unsuccessful operation.</returns>
method DexiModel.MoveSubtree(aSrc, aDest: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if CanMoveSubtree(aSrc, aDest) then
    begin
      var lSrcParent := aSrc.Parent;
      if lSrcParent <> nil then
        begin
          lSrcParent.RemoveInput(aSrc);
          lSrcParent.Funct := nil;
        end;
      aDest.AddInput(aSrc);
      aDest.Funct := nil;
      result := aSrc;
    end;
end;

method DexiModel.CleanupAlternatives;

  method ClnAltVal(aAtt: DexiAttribute);
  begin
    aAtt.CleanAltValues(AltCount);
    for i := 0 to aAtt.InpCount - 1 do
      ClnAltVal(aAtt.Inputs[i]);
  end;

begin
  ClnAltVal(Root);
end;

/// <summary>
/// Returns the index of the alternative named 'aName'. For multiple alternatives with the same name,
/// The index 'aIdx' can be specified to resolve cases of mutiple alternatives with the same name.
/// </summary>
/// <param name="aName">String, alternative name.</param>
/// <param name="aCaseSensitive">Whether otr not the search is case sensitive.</param>
/// <param name="aIdx">Find the aIdx'th occurence of 'aName' (optional, default = 0)</param>
/// <returns>Integer index (-1 if not found).</returns>
method DexiModel.FindAlternative(aName: String; aCaseSensitive: Boolean := false; aIdx: Integer := 0): Integer;
begin
  result := -1;
  if String.IsNullOrEmpty(aName) then
    exit;
  var lName :=
    if aCaseSensitive then aName
    else aName.ToUpper;
  for each lAltName in AltNames index x do
    begin
      var lFound :=
        if aCaseSensitive then
         lAltName.Name = lName
        else
          lAltName.Name.Toupper = lName;
      if lFound then
        if aIdx <= 0 then
          exit x
        else
          dec(aIdx);
  end;
end;

/// <summary>
/// Add a new alternative to this DexiModel.
/// </summary>
/// <param name="aName">Name of the alternative (optional).</param>
/// <param name="aDescription">Description of the alternative (optional).</param>
/// <returns>Integer index of the added alternative.</returns>
method DexiModel.AddAlternative(aName: String := ''; aDescription: String := ''): Integer;
begin
  var lAlt := new DexiAlternative(aName, aDescription);
  result := AddAlternative(lAlt);
end;

/// <summary>
/// Add a copy of IDexiAlternative to this DexiModel.
/// </summary>
/// <param name="aAlt">IDexiAlternative</param>
/// <returns>Integer index of the added alternative.</returns>
method DexiModel.AddAlternative(aAlt: IDexiAlternative): Integer;

  method AddAltVal(aAtt: DexiAttribute);
  begin
    aAtt.AddAltValue(aAlt[aAtt]);
    for i := 0 to aAtt.InpCount - 1 do
      AddAltVal(aAtt.Inputs[i]);
  end;

begin
  if aAlt = nil then
    aAlt := new DexiAlternative;
  result := AltCount;
  fAltNames.Add(new DexiObject(aAlt.Name, aAlt.Description));
  AddAltVal(Root);
  for each lRptGroup in Reports do
    lRptGroup.AddAlternative(AltCount - 1);
  ChartParameters.AddAlternative(AltCount - 1);
end;

/// <summary>
/// Add copies of IDexiAlternatives to this DexiModel.
/// </summary>
/// <param name="aAlts">IDexiAlternatives</param>
/// <param name="aOverload">Whether or not to overload alternatives.
/// Overloading means that when some existing alternative in this DexiModel has the same name
/// as some alternative in 'aAlts', only data from the latter is copied to the former and no new alternative
/// is added to DexiModel. Otherwise, a new alternative is added to DexiModel, resulting in at least two
/// alternatives having the same name.
/// Overloading is carried out sequentially, so that multiple alternatives from 'aAlts' can be overlaid
/// on a single equally-named alternative that already exists in the model.
/// </param>
/// <returns></returns>
method DexiModel.AddAlternatives(aAlts: IDexiAlternatives; aOverload: Boolean; aPatch: Boolean := false): SetOfInt;
begin
  result := new SetOfInt;
  for lIdx := 0 to aAlts.AltCount - 1 do
    begin
      var lAlt := aAlts.Alternative[lIdx];
      var xMod := AltNames.IndexOf(lAlt.Name);
      if (xMod >= 0) and aOverload then
        begin
          if aPatch then
            Alternative[xMod].ModifyFrom(DexiAlternative.ToDexiAlternative(lAlt))
          else
            Alternative[xMod] := lAlt;
          result.Include(xMod);
        end
      else
        begin
          var xAlt := AddAlternative(lAlt);
          result.Include(xAlt);
        end;
    end;
end;

/// <summary>
/// Insert a new alternative to this DexiModel at index 'aIdx'.
/// </summary>
/// <param name="aIdx">Integer index of the inserted alternative.</param>
/// <param name="aName">Name of the alternative (optional).</param>
/// <param name="aDescription">Description of the alternative (optional).</param>
/// <returns>Acutual Integer index of the inserted alternative.</returns>
method DexiModel.InsertAlternative(aIdx: Integer; aName: String := ''; aDescription: String := ''): Integer;
begin
  var lAlt := new DexiAlternative(aName, aDescription);
  result := InsertAlternative(aIdx, lAlt);
end;

/// <summary>
/// Insert a copy of IDexiAlternative to this DexiModel at index 'aIdx'.
/// </summary>
/// <param name="aIdx">Integer index of the inserted alternative.</param>
/// <param name="aAlt">IDexiAlternative</param>
/// <returns>Integer index of the inserted alternative.</returns>
method DexiModel.InsertAlternative(aIdx: Integer; aAlt: IDexiAlternative): Integer;

  method InsAltVal(aAtt: DexiAttribute);
  begin
    aAtt.InsertAltValue(aIdx, aAlt.Value[aAtt]);
    for i := 0 to aAtt.InpCount - 1 do
      InsAltVal(aAtt.Inputs[i]);
  end;

begin
  if aAlt = nil then
    aAlt := new DexiAlternative;
  if aIdx >= AltCount then
    result := AddAlternative(aAlt)
  else
    begin
      result := aIdx;
      fAltNames.Insert(aIdx, new DexiObject(aAlt.Name, aAlt.Description));
      InsAltVal(Root);
      fAltExclude := Values.IntSetInsertValue(fAltExclude, result);
      for each lRptGroup in Reports do
        lRptGroup.AddAlternative(aIdx);
      ChartParameters.AddAlternative(aIdx);
    end;
end;

/// <summary>
/// Remove alternative at index 'aIdx' from this DexiModel.
/// </summary>
/// <param name="aIdx">Integer index.</param>
/// <returns>Reference to the removed IDexiAlternative.</returns>
method DexiModel.RemoveAlternative(aIdx: Integer): IDexiAlternative;
begin
  result := Alternative[aIdx];
  DeleteAlternative(aIdx);
end;

/// <summary>
/// Remove alternative at index 'aIdx' from this DexiModel.
/// </summary>
/// <param name="aIdx">Integer index.</param>
method DexiModel.DeleteAlternative(aIdx: Integer);

  method DelAltVal(aAtt: DexiAttribute);
  begin
    aAtt.DeleteAltValue(aIdx);
    for i := 0 to aAtt.InpCount - 1 do
      DelAltVal(aAtt.Inputs[i]);
  end;

begin
  fAltNames.RemoveAt(aIdx);
  DelAltVal(Root);
  fAltExclude := Values.IntSetDeleteValue(fAltExclude, aIdx);
  for each lRptGroup in Reports do
    lRptGroup.DeleteAlternative(aIdx);
  ChartParameters.DeleteAlternative(aIdx);
end;

/// <summary>
/// Duplicate the alternative at index 'aIdx'. The copy is inserted at index 'aIdx' + 1.
/// </summary>
/// <param name="aIdx">Integer index.</param>
/// <returns>Reference to the source IDexiAlternative.</returns>
method DexiModel.DuplicateAlternative(aIdx: Integer): IDexiAlternative;
begin
  result := GetAlternative(aIdx);
  InsertAlternative(aIdx + 1, result);
end;

/// <summary>
/// Make a copy of alternative at index 'aFrom' and insert it at index 'aTo'.
/// </summary>
/// <param name="aFrom">Source alternative index.</param>
/// <param name="aTo">Destination alternative index.</param>
method DexiModel.CopyAlternative(aFrom, aTo: Integer);
begin
  var lAlt := GetAlternative(aFrom);
  InsertAlternative(aTo, lAlt);
end;

/// <summary>
/// Move alternative from index 'aFrom' to index 'aTo'.
/// </summary>
/// <param name="aFrom">Source alternative index.</param>
/// <param name="aTo">Destination alternative index.</param>
method DexiModel.MoveAlternative(aFrom, aTo: Integer);

  method MoveAltVal(aAtt: DexiAttribute);
  begin
    aAtt.MoveAltValue(aFrom, aTo);
    for i := 0 to aAtt.InpCount - 1 do
      MoveAltVal(aAtt.Inputs[i]);
  end;

begin
  Utils.MoveList(fAltNames, aFrom, aTo);
  MoveAltVal(Root);
  Values.IntSetMoveValue(var fAltExclude, aFrom, aTo);
  for each lRptGroup in Reports do
    lRptGroup.MoveAlternative(aFrom, aTo);
  ChartParameters.MoveAlternative(aFrom, aTo);
end;

/// <summary>
/// Move alternative from index 'aIdx' to 'aIdx' - 1.
/// </summary>
/// <param name="aIdx">Integer index.</param>
method DexiModel.MoveAlternativePrev(aIdx: Integer);

  method MoveAltValPrev(aAtt: DexiAttribute);
  begin
    aAtt.MoveAltValuePrev(aIdx);
    for i := 0 to aAtt.InpCount - 1 do
      MoveAltValPrev(aAtt.Inputs[i]);
  end;

begin
  fAltNames.Exchange(aIdx - 1, aIdx);
  MoveAltValPrev(Root);
  Values.IntSetExchangeValues(var fAltExclude, aIdx - 1, aIdx);
  for each lRptGroup in Reports do
    lRptGroup.MoveAlternativePrev(aIdx);
  ChartParameters.MoveAlternativePrev(aIdx);
end;

/// <summary>
/// Move alternative from index 'aIdx' to 'aIdx' + 1.
/// </summary>
/// <param name="aIdx">Integer index.</param>
method DexiModel.MoveAlternativeNext(aIdx: Integer);

  method MoveAltValNext(aAtt: DexiAttribute);
  begin
    aAtt.MoveAltValueNext(aIdx);
    for i := 0 to aAtt.InpCount - 1 do
      MoveAltValNext(aAtt.Inputs[i]);
  end;

begin
  fAltNames.Exchange(aIdx, aIdx + 1);
  MoveAltValNext(Root);
  Values.IntSetExchangeValues(var fAltExclude, aIdx, aIdx + 1);
  for each lRptGroup in Reports do
    lRptGroup.MoveAlternativeNext(aIdx);
  ChartParameters.MoveAlternativeNext(aIdx);
end;

/// <summary>
/// Exchange alternatives at indices 'aIdx1' and 'aIdx2'.
/// </summary>
/// <param name="aIdx1">First Integer index.</param>
/// <param name="aIdx2">Second Integer index.</param>
method DexiModel.ExchangeAlternatives(aIdx1, aIdx2: Integer);

  method ExcAltVal(aAtt: DexiAttribute);
  begin
    aAtt.ExchangeAltValues(aIdx1, aIdx2);
    for i := 0 to aAtt.InpCount - 1 do
      ExcAltVal(aAtt.Inputs[i]);
  end;

begin
  fAltNames.Exchange(aIdx1, aIdx2);
  ExcAltVal(Root);
  Values.IntSetExchangeValues(var fAltExclude, aIdx1, aIdx2);
  for each lRptGroup in Reports do
    lRptGroup.ExchangeAlternatives(aIdx1, aIdx2);
  ChartParameters.ExchangeAlternatives(aIdx1, aIdx2);
end;

/// <summary>
/// Link or relink attributes in the model.
///
/// Linking is a mechanism that facilitates using full attribute hierarchies (rather than trees) in DexModels.
/// The basic structure of attributes in DEXi is tree-like: an attribute can have zero or more children.
/// An attribute can have at most one parent and no cycles are allowed. This is characteristic of trees.
///
/// A hierarchy is defined as an acyclic directed graph, in which a node is allowed to have more than one parent.
/// To represent a hierarchy in a logical sense, DEXi allows to "link" (connect, reference) pairs of attributes
/// together; they are still represented by two DexiAttribute instances, but represent, in a logical sense, a
/// single attribute in the hierarchy.
///
/// Special requirements are put forward by DEXi to link two attributes: they must have the same name,
/// their scales must be compatible and at least one of them must be basic.
///
/// When DexiModel.Linking = true, linking is invoked automatically when needed.
/// </summary>
method DexiModel.LinkAttributes;

  method LinkAttribute(aAtt: DexiAttribute);
  begin
    if not Linking then
      aAtt.Link := nil
    else if aAtt.IsBasic then
      begin
        var lLnk := LinkAttributeByName(aAtt.Name);
        if lLnk = aAtt then
          lLnk := nil
        else if lLnk <> nil then
          if aAtt.Affects(lLnk) then
            lLnk := nil
          else if aAtt.Scale = nil then
            if lLnk.Scale = nil then {ok}
            else lLnk := nil
          else if not aAtt.Scale.EqualTo(lLnk.Scale) then
            lLnk := nil;
        aAtt.Link := lLnk;
      end;
    for i := 0 to aAtt.InpCount - 1 do
      LinkAttribute(aAtt.Inputs[i]);
  end;

begin
  Root.Link := nil;
  for i := 0 to Root.InpCount - 1 do
    LinkAttribute(Root.Inputs[i]);
end;

/// <summary>
/// Set InputAttributeOrder directly as an IntArray.
/// </summary>
/// <param name="aOrder">IntArray containing attribute indices.</param>
method DexiModel.SetInputAttributeOrder(aOrder: IntArray);
begin
  fInputAttributeOrder := Utils.CopyIntArray(aOrder);
  fModified := true;
end;

/// <summary>
/// Set InputAttributeOrder indirectly by providing the desired order of attributes.
/// </summary>
/// <param name="aOrder">DexiAttributeList that provides the desired order of input attributes.</param>
method DexiModel.SetInputAttributeOrder(aOrder: DexiAttributeList);
begin
  var lInputAttributes := new DexiAttributeList;
  Root.CollectBasicNonLinked(lInputAttributes);
  fInputAttributeOrder := Utils.ListOrder(aOrder, lInputAttributes);
  fModified := true;
end;

/// <summary>
/// Returns all model's input attributes taking into account the InputAttributeOrder property.
/// </summary>
/// <returns>Input attributes of the model ordered according to InputAttributeOrder.</returns>
method DexiModel.OrderedInputAttributes: DexiAttributeList;
begin
  var lInputAttributes := new DexiAttributeList;
  Root.CollectBasicNonLinked(lInputAttributes);
  if fInputAttributeOrder = nil then
    exit lInputAttributes;
  var lOrderedAttributes := Utils.OrderList<DexiAttribute>(lInputAttributes, fInputAttributeOrder, true);
  result := new DexiAttributeList;
  result.Add(lOrderedAttributes);
end;

/// <summary>
/// Evaluates alternatives included in this DexiModel.
/// </summary>
method DexiModel.Evaluation;
begin
  LinkAttributes;
  Root.Evaluation;
  fNeedsEvaluation := false;
  fModified := true;
end;

method DexiModel.SetupEvaluator(aType: EvaluationType);
begin
  if aType = EvaluationType.Custom then
    aType := fSettings.EvalType;
  if aType = EvaluationType.Custom then
    aType := EvaluationType.AsSet;
  fEvaluator.EvalType := aType;
  fEvaluator.UndefinedExpand :=
    if fSettings.ExpandUndef then ValueExpand.All
    else ValueExpand.Null;
  fEvaluator.EmptyExpand :=
    if fSettings.ExpandEmpty then ValueExpand.All
    else ValueExpand.Null;
  fEvaluator.OutMeans :=
    if fSettings.CheckBounds then OutOfBoundsMeans.Error
    else OutOfBoundsMeans.Narrow;
end;

/// <summary>
/// Evaluates alternatives included in this DexiModel.
/// </summary>
/// <param name="aType">Type of evaluation.</param>
method DexiModel.Evaluate(aType: EvaluationType := EvaluationType.Custom);
begin
  SetupEvaluator(aType);
  LinkAttributes;
  fEvaluator.Evaluate(self);
  fNeedsEvaluation := false;
  fModified := true;
end;

/// <summary>
/// Evaluates a single alternative included in this DexiModel.
/// </summary>
/// <param name="aAlt">Integer index of the alternatrive.</param>
/// <param name="aType">Type of evaluation.</param>
/// <param name="aLink">Whether or not to attempt LinkAttributes before evaluation.</param>
method DexiModel.Evaluate(aAlt: Integer; aType: EvaluationType := EvaluationType.Custom; aLink: Boolean := true);
begin
  SetupEvaluator(aType);
  if aLink then
    LinkAttributes;
  fEvaluator.Evaluate(self.Alternative[aAlt]);
  fNeedsEvaluation := false;
  fModified := true;
end;

/// <summary>
/// Evaluates a single alternative without attribute linking
/// </summary>
/// <param name="aAlt">Integer index of the alternatrive.</param>
/// <param name="aType">Type of evaluation.</param>
method DexiModel.EvaluateNoLinking(aAlt: Integer; aType: EvaluationType := EvaluationType.Custom);
begin
  Evaluate(aAlt, aType, false);
end;

/// <summary>
/// Runs plus/minus analysis of alternative 'aIdx':
/// Observing the effects on 'aAtt' of varying the values of basic attributes by 'aDiff'.
/// </summary>
/// <param name="aIdx">Integer index of alternative.</param>
/// <param name="aDiff">Integer offset from basic attribute values.</param>
/// <param name="aAtt">The observed DexiAttribute (default is DexiModel.First).</param>
/// <returns></returns>
method DexiModel.PlusMinus(aIdx: Integer; aDiff: Integer; aAtt: DexiAttribute := nil): DexiAlternative;
begin
  result := fEvaluator.PlusMinus(Alternative[aIdx], aDiff, aAtt);
end;

/// <summary>
/// Runs full plus/minus analysis of alternative 'aIdx':
/// Observing the effects on 'aAtt' of varying the values of basic attributes in the range from 'aMin' to 'aMax'.
/// 'aMin' and 'aMax' may be -1, inicating the largest effective range in each direction.
/// </summary>
/// <param name="aIdx">Integer index of alternative.</param>
/// <param name="aMin">Range lower bound or -1.</param>
/// <param name="aMax">Range upper bound or -1.</param>
/// <param name="aAtt">The observed DexiAttribute (default is DexiModel.First).</param>
/// <returns></returns>
method DexiModel.PlusMinus(aIdx: Integer; aMin, aMax: Integer; aAtt: DexiAttribute := nil): List<PlusMinusAlternative>;
begin
  result := fEvaluator.PlusMinus(Alternative[aIdx], aMin, aMax, aAtt);
end;

method DexiModel.EvaluateWithOffsets(aQQ2: Boolean := true): DexiOffAlternatives;
begin
  result := new DexiOffAlternatives;
  for a := 0 to AltCount - 1 do
    begin
      var lAlt := new DexiOffAlternative(Alternative[a]);
      result.Add(lAlt);
    end;
  EvaluateWithOffsets(result, aQQ2);
end;

method DexiModel.EvaluateWithOffsets(aAlt: Integer; aQQ2: Boolean := true): DexiOffAlternative;
begin
  result := new DexiOffAlternative(Alternative[aAlt]);
  EvaluateWithOffsets(result, aQQ2);
end;

method DexiModel.EvaluateWithOffsets(aAlt: IDexiAlternative; aQQ2: Boolean := true): DexiOffAlternative;
begin
  result := new DexiOffAlternative(aAlt);
  EvaluateWithOffsets(result, aQQ2);
end;

method DexiModel.EvaluateWithOffsets(aAlts: IDexiAlternatives; aQQ2: Boolean := true): DexiOffAlternatives;
begin
  result := new DexiOffAlternatives;
  for a := 0 to aAlts.AltCount - 1 do
    begin
      var lAlt := new DexiOffAlternative(aAlts.Alternative[a]);
      result.Add(lAlt);
    end;
  EvaluateWithOffsets(result, aQQ2);
end;

method DexiModel.EvaluateWithOffsets(aAlts: IntArray; aQQ2: Boolean := true): DexiOffAlternatives;
begin
  result := new DexiOffAlternatives;
  for each a in aAlts do
    begin
      var lAlt := Alternative[a];
      var lAltOff := new DexiOffAlternative(lAlt);
      result.Add(lAltOff);
    end;
  EvaluateWithOffsets(result, aQQ2);
end;

method DexiModel.EvaluateWithOffsets(aAlt: DexiOffAlternative; aQQ2: Boolean := true);
begin
  var lAlts := new DexiOffAlternatives;
  lAlts.Add(aAlt);
  EvaluateWithOffsets(lAlts, aQQ2);
end;

/// <summary>
/// Evaluate a list of DexiOffAlternatives using the QP or QQ method.
/// This is the main EvaluateWithOffsets method, called by all others.
/// </summary>
/// <param name="aAlts">List of DexiOffAlternatives to be evaliated (inline).</param>
/// <param name="aQQ2">Select method: QQ2 (true) or QQ (false).</param>
method DexiModel.EvaluateWithOffsets(aAlts: DexiOffAlternatives; aQQ2: Boolean := true);
begin
  var lEvaluator :=
    if aQQ2 then new DexiQQ2Evaluator(self)
    else new DexiQQEvaluator(self);
  for each lAlt in aAlts do
    lEvaluator.Evaluate(lAlt);
end;

/// <summary>
/// Collect names of DexiObjects that use new feratures introduced in DEXiLibrary 2023.
/// </summary>
/// <returns>List<String></returns>
method DexiModel.DexiLibraryFeatures: List<String>;

  method ExtendedFunctions: List<String>;
  begin
    result := new List<String>;
    var lAtts := Root.CollectInputs;
    for each lAtt in lAtts do
      if lAtt.Funct <> nil then
        if lAtt.Funct.UsesDexiLibraryFeatures then
          result.Add(lAtt.Name);
  end;

  method FloatAltData: Boolean;
  begin
    result := false;
    var lAtts := Root.CollectInputs;
    for lAlt := 0 to AltCount - 1 do
      for each lAtt in lAtts do
        begin
          var lValue := AltValue[lAlt, lAtt];
          if DexiValue.ValueIsDefined(lValue) and lValue.IsFloat then
            exit false;
        end;
  end;

begin
  result := new List<String>;
  if (fSettings.EvalType <> EvaluationType.AsSet) or
     not fSettings.ExpandUndef or not fSettings.ExpandEmpty or not fSettings.CheckBounds
  then
    result.Add(DexiString.SDexiFeatureEval);
  var lStatistics := Statistics;
  if lStatistics.ContScales > 0 then
    result.Add(String.Format(DexiString.SDexiFeatureContScales, [lStatistics.ContScales]));
  if lStatistics.TabularFunctions <> lStatistics.Functions then
    result.Add(String.Format(DexiString.SDexiFeatureNonTabFuncts, [lStatistics.Functions - lStatistics.TabularFunctions]));
  var lExtFunct := ExtendedFunctions;
  if lExtFunct.Count > 0 then
    result.Add(String.Format(DexiString.SDexiFeatureExtFuncts, [String.Join('; ', lExtFunct)]));
  if FloatAltData then
    result.Add(DexiString.SDexiFeatureContData);
end;

/// <summary>
/// Returns true if this DexiModel uses new features introduced in DEXiLibrary 2023.
/// </summary>
/// <returns>Boolean</returns>
method DexiModel.UsesDexiLibraryFeatures: Boolean;
begin
  result := DexiLibraryFeatures.Count > 0;
end;

method DexiModel.LoadScale(aItem: XmlElement; aAtt: DexiAttribute);
begin
  var lContItem := aItem:FirstElementWithName('CONTINUOUS');
  var lScl: DexiScale :=
    if lContItem <> nil then new DexiContinuousScale
    else new DexiDiscreteScale;
  LoadNameDescr(lScl, aItem);
  aAtt.Scale := lScl;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'UNIT' then
      lScl.ScaleUnit := lItem.Value
    else if lItem.LocalName = 'ORDER' then
      lScl.Order :=
        if lItem.Value = 'NONE' then DexiOrder.None
        else if lItem.Value = 'DESC' then DexiOrder.Descending
        else DexiOrder.Ascending
    else if lItem.LocalName = 'INTERVAL' then
      lScl.IsInterval := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'FLTDEC' then
      lScl.FltDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'DEFAULT' then
      DefaultScale := lScl;
  if lContItem <> nil then
    begin
      lScl.BGLow := Consts.NegativeInfinity;
      lScl.BGHigh := Consts.PositiveInfinity;
      for lItem in lContItem.Elements do
        if lItem.LocalName = 'LOW' then
          lScl.BGLow := Utils.StrToFlt(lItem.Value)
        else if lItem.LocalName = 'HIGH' then
          lScl.BGHigh := Utils.StrToFlt(lItem.Value);
    end
  else
    with dScl := DexiDiscreteScale(lScl) do
      begin
        for lItem in aItem.Elements do
          if lItem.LocalName = 'SCALEVALUE' then
            begin
              var lValue := new DexiScaleValue;
              LoadNameDescr(lValue, lItem);
              dScl.AddValue(lValue);
            end;
        lScl.BGLow := Consts.NegativeInfinity;
        lScl.BGHigh := Consts.PositiveInfinity;
        var j := 0;
        for lItem in aItem.Elements do
          if lItem.LocalName = 'SCALEVALUE' then
            begin
              var g := lItem:FirstElementWithName('GROUP'):Value;
              if g = 'BAD' then
                begin
                  if not dScl.IsBad(j) then dScl.Bad := Float(j);
                end
              else if g = 'GOOD' then
                begin
                  if not dScl.IsGood(j) then dScl.Good := Float(j);
                end;
              var c := lItem:FirstElementWithName('COLOR'):Value;
              if not String.IsNullOrEmpty(c) then
                dScl.Colors[j] := new ColorInfo(c);
              inc(j);
            end;
        end;
end;

method DexiModel.LoadFunct(aItem: XmlElement; aAtt: DexiAttribute);
begin
  var lFunct := new DexiTabularFunction;
  LoadNameDescr(lFunct, aItem);
  lFunct.Attribute := aAtt;
  aAtt.Funct := lFunct;
  var l := '';
  var h := '';
  var e := '';
  for lItem in aItem.Elements do
    if lItem.LocalName = 'LOW' then
      l := lItem.Value
    else if lItem.LocalName = 'HIGH' then
      h := lItem.Value
    else if lItem.LocalName = 'ENTERED' then
      e := lItem.Value
    else if lItem.LocalName = 'CONSIST' then
      lFunct.UseConsist := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ROUNDING' then
      lFunct.Rounding := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'WEIGHTS' then
      begin
        lFunct.UseWeights := true;
        lFunct.RequiredWeights := Utils.StrToFltArray(lItem.Value);
      end
    else if lItem.LocalName = 'LOCWEIGHTS' then
      lFunct.ActualWeights := Utils.StrToFltArray(lItem.Value)
    else if lItem.LocalName = 'NORMLOCWEIGHTS' then
      lFunct.NormActualWeights := Utils.StrToFltArray(lItem.Value);
  if h = '' then
    h := l;
  for i := 0 to length(l) - 1 do
    begin
      if i >= lFunct.Count then
        break;
      lFunct.RuleValLow[i] := ord(l[i]) - ord('0');
      lFunct.RuleValHigh[i] :=
        if length(h) > i then ord(h[i]) - ord('0')
        else lFunct.RuleValLow[i];
      lFunct.RuleEntered[i] :=
        if length(e) > i then e[i] = '+'
        else true;
    end;
end;

method DexiModel.LoadTabular(aItem: XmlElement; aAtt: DexiAttribute);
begin
  var lFunct := new DexiTabularFunction;
  LoadNameDescr(lFunct, aItem);
  lFunct.Attribute := aAtt;
  aAtt.Funct := lFunct;
  var lPos := 0;
  var lConsist := lFunct.UseConsist;
  lFunct.UseConsist := false;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'RULE' then
      begin
        // Also there: var lArgs := lItem.Attribute['Args'];
        var lEntered := lItem.Attribute['Entered'];
        lFunct.RuleValue[lPos] := DexiValue.FromIntString(lItem.Value);
        if lEntered <> nil then
          lFunct.RuleEntered[lPos] := Utils.StrToBoolean(lEntered.Value);
        inc(lPos);
      end
    else if lItem.LocalName = 'CONSIST' then
      lConsist := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ROUNDING' then
      lFunct.Rounding := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'WEIGHTS' then
      begin
        lFunct.UseWeights := true;
        lFunct.RequiredWeights := Utils.StrToFltArray(lItem.Value);
      end
    else if lItem.LocalName = 'LOCWEIGHTS' then
      lFunct.ActualWeights := Utils.StrToFltArray(lItem.Value)
    else if lItem.LocalName = 'NORMLOCWEIGHTS' then
      lFunct.NormActualWeights := Utils.StrToFltArray(lItem.Value);
  lFunct.UseConsist := lConsist;
end;

method DexiModel.LoadDiscretize(aItem: XmlElement; aAtt: DexiAttribute);
begin
  var lFunct := new DexiDiscretizeFunction;
  LoadNameDescr(lFunct, aItem);
  lFunct.Attribute := aAtt;
  aAtt.Funct := lFunct;
  var lConsist := lFunct.UseConsist;
  lFunct.UseConsist := false;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'BOUND' then
      begin
        var lBound := Utils.StrToFlt(lItem.Value);
        var lAssociate := lItem.Attribute['Associate'];
        var lAssociation :=
            if lAssociate = nil then DexiBoundAssociation.Down
            else if lAssociate.Value = 'Up' then DexiBoundAssociation.Up
            else DexiBoundAssociation.Down;
        lFunct.AddBound(lBound, lAssociation);
      end;
  var lPos := 0;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'VALUE' then
      begin
        var lValue := DexiValue.FromString(lItem.Value);
        lFunct.SetIntervalValue(lPos, lValue);
        var lEntered := lItem.Attribute['Entered'];
        if lEntered <> nil then
          lFunct.IntervalEntered[lPos] := Utils.StrToBoolean(lEntered.Value);
        inc(lPos);
      end
    else if lItem.LocalName = 'CONSIST' then
      lConsist := Utils.StrToBoolean(lItem.Value);
  lFunct.UseConsist := lConsist;
end;

method DexiModel.LoadAttribute(aItem: XmlElement; var aAtt: DexiAttribute);
var lNewAtt: DexiAttribute;
begin
  lNewAtt := new DexiAttribute;
  LoadNameDescr(lNewAtt, aItem);
  if aAtt = nil then
    aAtt := lNewAtt
  else
    aAtt.AddInput(lNewAtt);
  for lItem in aItem.Elements do
    if lItem.LocalName = 'ATTRIBUTE' then LoadAttribute(lItem, var lNewAtt)
    else if lItem.LocalName = 'SCALE' then LoadScale(lItem, lNewAtt)
    else if lItem.LocalName = 'OPTION' then
      begin
        var lIdx := lNewAtt.AddAltValue(nil);
        lNewAtt.OptText[lIdx] := lItem.Value;
      end
    else if lItem.LocalName = 'ALTERNATIVE' then
      begin
        var lIdx := lNewAtt.AddAltValue(nil);
        lNewAtt.AltText[lIdx] := lItem.Value;
      end;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'FUNCTION' then LoadFunct(lItem, lNewAtt)
    else if lItem.LocalName = 'TABLE' then LoadTabular(lItem, lNewAtt)
    else if lItem.LocalName = 'DISCRETIZE' then LoadDiscretize(lItem, lNewAtt);
end;

method DexiModel.LoadDescription(aItem: XmlElement): String;
begin
  if aItem.Elements.Count = 0 then
    result := aItem.Value
  else
    begin
      result := '';
      for lItem in aItem.Elements do
        if lItem.LocalName = 'LINE' then
          begin
            if result <> '' then
              result := result + Environment.LineBreak;
            result := result + lItem.Value;
          end;
    end;
end;

method DexiModel.LoadNameDescr(aObj: DexiObject; aItem: XmlElement);
begin
  for lItem in aItem.Elements do
    if lItem.LocalName = 'NAME' then aObj.Name := lItem.Value
    else if lItem.LocalName = 'DESCRIPTION' then
      aObj.Description := LoadDescription(lItem)
end;

method DexiModel.LoadRoot(aItem: XmlElement);
begin
  Clear;
  var lRoot := Root;
  LoadNameDescr(self, aItem);
  for lItem in aItem.Elements do
    if lItem.LocalName = 'ATTRIBUTE' then LoadAttribute(lItem, var lRoot)
    else if lItem.LocalName = 'SETTINGS' then LoadSettings(lItem)
    else if lItem.LocalName = 'OPERATION' then
      Operation := lItem.Value
    else if lItem.LocalName = 'OPTION' then
      fAltNames.Add(new DexiObject(lItem.Value))
    else if lItem.LocalName = 'ALTERNATIVE' then
      begin
        var lObj := new DexiObject;
        LoadNameDescr(lObj, lItem);
        fAltNames.Add(lObj);
      end
    else if lItem.LocalName = 'CREATED' then
      Created := lItem.Value
    else if lItem.LocalName = 'LINKING' then
      Settings.Linking := Utils.StrToBoolean(lItem.Value)
    else if (lItem.LocalName = 'EVALCOL') or (lItem.LocalName = 'MAXCOL') then
      Settings.MaxColumns := Utils.StrToInt(lItem.Value);
  fInputAttributeOrder := nil;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'REPORTS' then LoadReports(lItem)
    else if lItem.LocalName = 'CHART' then fChartParameters := LoadChartParameters(lItem)
    else if lItem.LocalName = 'INPUTORDER' then fInputAttributeOrder := Utils.StrToIntArray(lItem.Value);
  CleanupAlternatives;
  LinkAttributes;
  Modify;
end;

method DexiModel.LoadJsonSettings(aItem: XmlElement);
begin
  Settings.JsonSettings := new DexiJsonSettings;
  with lSettings := Settings.JsonSettings do
    for lItem in aItem.Elements do
      if lItem.LocalName = 'MODEL' then
        lSettings.IncludeModel := Utils.StrToBoolean(lItem.Value)
      else if lItem.LocalName = 'ALTERNATIVES' then
        lSettings.IncludeAlternatives := Utils.StrToBoolean(lItem.Value)
      else if lItem.LocalName = 'STRUCTURE' then
        if lItem.Value = 'RECURSIVE' then lSettings.StructureFormat := DexiJsonStructureFormat.Recursive
        else lSettings.StructureFormat := DexiJsonStructureFormat.Flat
      else if lItem.LocalName = 'MODELEMENTS' then
        lSettings.ModelElements := Convert.HexStringToUInt32(lItem.Value)
      else if lItem.LocalName = 'ALTELEMENTS' then
        lSettings.AlternativeElements := Convert.HexStringToUInt32(lItem.Value)
      else if lItem.LocalName = 'ATTTYPES' then
        lSettings.AttributeTypes := Convert.HexStringToUInt32(lItem.Value)
      else if lItem.LocalName = 'MODINPUTS' then
        if lItem.Value = 'None' then lSettings.ModelInputs := DexiJsonInputs.None
        else if lItem.Value = 'List' then lSettings.ModelInputs := DexiJsonInputs.List
        else lSettings.ModelInputs := DexiJsonInputs.IDs
      else if lItem.LocalName = 'ATTINPUTS' then
        if lItem.Value = 'None' then lSettings.AlternativeInputs := DexiJsonInputs.None
        else if lItem.Value = 'List' then lSettings.AlternativeInputs := DexiJsonInputs.List
        else lSettings.AlternativeInputs := DexiJsonInputs.IDs
      else if lItem.LocalName = 'DEXISTRINGS' then
        lSettings.UseDexiStringValues := Utils.StrToBoolean(lItem.Value)
      else if lItem.LocalName = 'VALFORMAT' then
        lSettings.ValueFormat := DexiSettings.ValStringType(lItem.Value)
      else if lItem.LocalName = 'DISTRFORMAT' then
        if lItem.Value = 'DICT' then lSettings.DistributionFormat := DexiJsonDistributionFormat.Dict
        else lSettings.DistributionFormat := DexiJsonDistributionFormat.Distr
      else if lItem.LocalName = 'FLTDEC' then
        lSettings.FloatDecimals := Utils.StrToInt(lItem.Value)
      else if lItem.LocalName = 'MEMDEC' then
        lSettings.MembershipDecimals := Utils.StrToInt(lItem.Value)
      else if lItem.LocalName = 'INDENT' then
        lSettings.JsonIndent := Utils.StrToBoolean(lItem.Value)
      else if lItem.LocalName = 'TIMEINFO' then
        lSettings.IncludeTimeInfo := Utils.StrToBoolean(lItem.Value);
end;

method DexiModel.LoadSettings(aItem: XmlElement);
begin
  for lItem in aItem.Elements do
    if lItem.LocalName = 'JSON' then
      LoadJsonSettings(lItem)
    else if lItem.LocalName = 'LINKING' then
      Settings.Linking := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'UNDOING' then
      Settings.Undoing := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'REPORTS' then
      Settings.SelectedReports := Values.StrToIntSet(lItem.Value)
    else if lItem.LocalName = 'REPORTHEADER' then
      Settings.UseReportHeader := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'HTML' then
      Settings.RptHtml := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'DEFBROWSER' then
      Settings.DefBrowser := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'WEIGHTS' then
      Settings.SelectedWeights := Values.StrToIntSet(lItem.Value)
    else if lItem.LocalName = 'LOCWEIGHTS' then
      Settings.WeightsLocal := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'GLOBWEIGHTS' then
      Settings.WeightsGlobal := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'LOCNORMWEIGHTS' then
      Settings.WeightsLocalNormalized := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'GLOBNORMWEIGHTS' then
      Settings.WeightsGlobalNormalized := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'PAGEBREAK' then
      begin
        Settings.Pagebreak := Utils.StrToBoolean(lItem.Value);
        if Settings.Pagebreak then
          begin
            Settings.TableBreak := RptTable.BreakAll;
            Settings.SectionBreak := RptSection.BreakAll;
          end;
      end
    else if lItem.LocalName = 'SECTIONBREAK' then
      Settings.SectionBreak := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'TABLEBREAK' then
      Settings.TableBreak := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'REPORTFONT' then
      Settings.ReportFontInfo := new FontInfo(lItem.Value)
    else if lItem.LocalName = 'BADCOLOR' then
      Settings.BadColor := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'NEUTRALCOLOR' then
      Settings.NeutralColor := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'GOODCOLOR' then
      Settings.GoodColor := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'BADSTYLE' then
      Settings.BadStyle := lItem.Value
    else if lItem.LocalName = 'NEUTRALSTYLE' then
      Settings.NeutralStyle := lItem.Value
    else if lItem.LocalName = 'GOODSTYLE' then
      Settings.GoodStyle := lItem.Value
    else if lItem.LocalName = 'WEIGHTDEC' then
      Settings.WeiDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MEMDEC' then
      Settings.MemDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'DEFDETDEC' then
      Settings.DefDetDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'FLTDEC' then
      Settings.FltDecimals := Utils.StrToInt(lItem.Value)
    else if (lItem.LocalName = 'EVALCOL') or (lItem.LocalName = 'MAXCOL') then
      Settings.MaxColumns := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'EVALTRIM' then
      Settings.EvalTrim := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'SHOWWEIGHTS' then
      Settings.FncShowWeights := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWNUMBERS' then
      Settings.FncShowNumbers := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWNUMERICVALUES' then
      Settings.FncShowNumericValues := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWMARGINALS' then
      Settings.FncShowMarginals := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'COMPLEX' then
      begin
        Settings.FncComplex := Utils.StrToBoolean(lItem.Value);
        if Settings.FncComplex then
          Settings.Representation := DexiRptFunctionRepresentation.Complex;
      end
    else if lItem.LocalName = 'REPRESENTATION' then
      begin
        Settings.Representation :=
          if lItem.Value = 'Elementary' then DexiRptFunctionRepresentation.Elementary
          else if lItem.Value = 'DecisionTree' then DexiRptFunctionRepresentation.DecisionTree
          else DexiRptFunctionRepresentation.Complex;
        Settings.FncComplex := Settings.Representation = DexiRptFunctionRepresentation.Complex;
      end
    else if lItem.LocalName = 'ENTERED' then
      Settings.FncEnteredOnly := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'NORMALIZEDWEIGHTS' then
      Settings.FncNormalizedWeights := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'FONTSIZE' then
      Settings.FontSize := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'FONTNAME' then
      Settings.FontName := lItem.Value
    else if lItem.LocalName = 'ALTDATATYPE' then
      Settings.ValueType := DexiSettings.ValStringType(lItem.Value)
    else if (lItem.LocalName = 'OPTDATAALL') or (lItem.LocalName = 'ALTDATAALL') then
      Settings.AltDataAll := Utils.StrToBoolean(lItem.Value)
    else if (lItem.LocalName = 'OPTTRANSPOSE') or (lItem.LocalName = 'ALTTRANSPOSE') then
      Settings.AltTranspose := Utils.StrToBoolean(lItem.Value)
    else if (lItem.LocalName = 'OPTLEVELS') or (lItem.LocalName = 'ALTLEVELS') then
      Settings.AltLevels := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'CSVINVARIANT' then
      Settings.CsvInvariant := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'FNCDATATYPE' then
      Settings.FncDataType := DexiSettings.ValStringType(lItem.Value)
    else if lItem.LocalName = 'FNCDATAALL' then
      Settings.FncDataAll := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'FNCSTATUS' then
      Settings.FncStatus := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'PROTECTMODEL' then
      Settings.ModelProtect := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'EVALUATIONTYPE' then
      if lItem.Value = 'AsSet' then Settings.EvalType := EvaluationType.AsSet
      else if lItem.Value = 'AsProb' then Settings.EvalType := EvaluationType.AsProb
      else if lItem.Value = 'AsFuzzy' then Settings.EvalType := EvaluationType.AsFuzzy
      else if lItem.Value = 'AsFuzzyNorm' then Settings.EvalType := EvaluationType.AsFuzzyNorm
      else Settings.EvalType := EvaluationType.Custom
    else if lItem.LocalName = 'EXPANDUNDEF' then
      Settings.ExpandUndef := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'EXPANDEMPTY' then
      Settings.ExpandEmpty := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'CHECKBOUNDS' then
      Settings.CheckBounds := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'WARNINGS' then
      Settings.Warnings := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'CANMOVETABS' then
      Settings.CanMoveTabs := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ATTID' then
      Settings.AttId :=
        case lItem.Value of
          'Name': AttributeIdentification.Name;
          'Id': AttributeIdentification.Id;
          'Path': AttributeIdentification.Path;
          else AttributeIdentification.Name;
        end
    else if lItem.LocalName = 'DEXISTRINGS' then
      Settings.UseDexiStringValues := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'TREEPATTERN' then
      Settings.TreePattern :=
        case lItem.Value of
          'None': RptTreePattern.None;
          'PlusMinus': RptTreePattern.PlusMinus;
          'Dots': RptTreePattern.Dots;
          'AllDots': RptTreePattern.AllDots;
          'Unicode': RptTreePattern.Unicode;
          else RptTreePattern.Lines;
        end
end;

method DexiModel.LoadReportFormat(aItem: XmlElement): DexiReportFormat;
begin
  result := new DexiReportFormat(self);
  for lItem in aItem.Elements do
    if lItem.LocalName = 'SOFTWARE' then
      result.Software := lItem.Value
//    else if lItem.LocalName = 'FILENAME' then
//      result.FileName := lItem.Value
    else if lItem.LocalName = 'FONTNAME' then
      result.FontName := lItem.Value
    else if lItem.LocalName = 'FONTSIZE' then
      result.FontSize := Utils.StrToFlt(lItem.Value, true);
end;

method DexiModel.LoadSelectedAttributes(aItem: XmlElement): List<DexiAttribute>;
begin
  result := new List<DexiAttribute>;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'ATTRIBUTE' then
      begin
        var lAtt := AttributeByIndices(Utils.StrToIntArray(lItem.Value));
        if lAtt <> nil then
          result.Add(lAtt);
      end;
end;

method DexiModel.LoadReportParameters(aItem: XmlElement): DexiReportParameters;
begin
  result := new DexiReportParameters(self);
  for lItem in aItem.Elements do
    if lItem.LocalName = 'ROOT' then
      result.Root := AttributeByIndices(Utils.StrToIntArray(lItem.Value))
    else if lItem.LocalName = 'ALTERNATIVE' then
      result.Alternative := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'ATTRIBUTES' then
      result.SelectedAttributes := LoadSelectedAttributes(lItem)
    else if lItem.LocalName = 'ALTERNATIVES' then
      result.SelectedAlternatives := new SetOfInt(Utils.StrToIntArray(lItem.Value))
    else if lItem.LocalName = 'COLUMNS' then
      result.Columns := Utils.StrToIntArray(lItem.Value)
    else if lItem.LocalName = 'WEIGHTDEC' then
      result.WeiDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MEMDEC' then
      result.MemDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'DEFDETDEC' then
      result.DefDetDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'FLTDEC' then
      result.FltDecimals := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'ATTNAME' then
      result.AttName := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ATTDESCRIPTION' then
      result.AttDescription := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ATTSCALE' then
      result.AttScale := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ATTFUNCTION' then
      result.AttFunction := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWWEIGHTS' then
      result.FncShowWeights := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWNUMBERS' then
      result.FncShowNumbers := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWNUMERICVALUES' then
      result.FncShowNumericValues := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'SHOWMARGINALS' then
      result.FncShowMarginals := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'ENTEREDONLY' then
      result.FncEnteredOnly := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'FUNCTIONSTATUS' then
      result.FncStatus := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'REPRESENTATION' then
      result.Representation :=
        if lItem.Value = 'Elementary' then DexiRptFunctionRepresentation.Elementary
        else if lItem.Value = 'DecisionTree' then DexiRptFunctionRepresentation.DecisionTree
        else DexiRptFunctionRepresentation.Complex
    else if lItem.LocalName = 'LOCWEIGHTS' then
      result.WeightsLocal := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'GLOBWEIGHTS' then
      result.WeightsGlobal := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'LOCNORMWEIGHTS' then
      result.WeightsLocalNormalized := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'GLOBNORMWEIGHTS' then
      result.WeightsGlobalNormalized := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'USENORMWEIGHTS' then
      result.UseNormalizedWeights := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'DEEPCOMPARE' then
      result.DeepCompare := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'MINUSSTEPS' then
      result.MinusSteps := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'PLUSSTEPS' then
      result.PlusSteps := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'IMPROVE' then
      result.Improve := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'UNIDIRECTIONAL' then
      result.Unidirectional := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'MAXSTEPS' then
      result.MaxSteps := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MAXGENERATE' then
      result.MaxGenerate := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MAXSHOW' then
      result.MaxShow := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MAKETITLE' then
      result.MakeTitle := Utils.StrToBoolean(lItem.Value)
end;

method DexiModel.LoadReport(aItem: XmlElement): DexiReport;
begin
  var lType := 'REPORTS';
  var lSelected := true;
  var lTitle := '';
  var lChartParameters: DexiChartParameters := nil;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'TYPE' then
      lType := lItem.Value
    else if lItem.LocalName = 'TITLE' then
      lTitle := lItem.Value
    else if lItem.LocalName = 'SELECTED' then
      lSelected := Utils.StrToBoolean(lItem.Value)
    else if lItem.LocalName = 'CHART' then
      lChartParameters := LoadChartParameters(lItem);
  var lFormat := LoadReportFormat(aItem);
  var lParameters := LoadReportParameters(aItem);
  result := DexiReport.NewReport(lType, lParameters, lChartParameters, lFormat);
  if result <> nil then
    begin
      result.Title := lTitle;
      result.Selected := lSelected;
    end;
end;

method DexiModel.LoadReportGroup(aItem: XmlElement): DexiReportGroup;
begin
  result := nil;
  var lRpt := LoadReport(aItem);
  if lRpt is not DexiReportGroup then
    exit;
  result := DexiReportGroup(lRpt);
  for lItem in aItem.Elements do
    if lItem.LocalName = 'REPORT' then
      begin
        lRpt := LoadReport(lItem);
        if lRpt <> nil then
          result.AddReport(lRpt);
      end;
end;

method DexiModel.LoadReports(aItem: XmlElement);
begin
  fReports := new List<DexiReportGroup>;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'REPORTGROUP' then
      begin
        var lRptGroup := LoadReportGroup(lItem);
        if lRptGroup <> nil then
          fReports.Add(lRptGroup);
      end;
end;

method DexiModel.LoadChartParameters(aItem: XmlElement): DexiChartParameters;
begin
  result := new DexiChartParameters;
  for lItem in aItem.Elements do
    if lItem.LocalName = 'ATTRIBUTES' then
      result.SelectedAttributes := LoadSelectedAttributes(lItem)
    else if lItem.LocalName = 'ALTERNATIVES' then
      result.SelectedAlternatives := new SetOfInt(Utils.StrToIntArray(lItem.Value))
    else if lItem.LocalName = 'MULTICHARTTYPE' then
      result.MultiChartType :=
        case lItem.Value of
          'Linear': DexiMultiAttChartType.Linear;
          'RadarGrid': DexiMultiAttChartType.RadarGrid;
          else DexiMultiAttChartType.Radar;
        end
    else if lItem.LocalName = 'GRIDX' then
      result.GridX := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'BORDER' then
      result.Border.SetFromRelativeString(lItem.Value, result.Border)
    else if lItem.LocalName = 'BACKGROUNDCOLOR' then
      result.BackgroundColorInfo := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'AREACOLOR' then
      result.AreaColorInfo := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'LIGHTNEUTRALCOLOR' then
      result.LightNeutralColorInfo := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'UNDEFCOLOR' then
      result.UndefColorInfo := new ColorInfo(lItem.Value)
    else if lItem.LocalName = 'ATTFONT' then
      result.AttFontInfo := new FontInfo(lItem.Value)
    else if lItem.LocalName = 'ALTFONT' then
      result.AltFontInfo := new FontInfo(lItem.Value)
    else if lItem.LocalName = 'VALFONT' then
      result.ValFontInfo := new FontInfo(lItem.Value)
    else if lItem.LocalName = 'LINEWIDTH' then
      result.LineWidth := Utils.StrToFlt(lItem.Value)
    else if lItem.LocalName = 'TRANSPARENT' then
      result.TransparentAlpha := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'ALTGAP' then
      result.AltGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'ATTGAP' then
      result.AttGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'SCALEGAP' then
      result.ScaleGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'VALGAP' then
      result.ValGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'LINEGAP' then
      result.LineGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'TICKLENGTH' then
      result.TickLength := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'LEGENDWIDTH' then
      result.LegendWidth := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'LEGENDHEIGHT' then
      result.LegendHeight := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'LEGENDGAP' then
      result.LegendGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'MINSIDEGAP' then
      result.MinSideGap := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'BAREXTENT' then
      result.BarExtent := Utils.StrToFlt(lItem.Value)
    else if lItem.LocalName = 'SCATTERPOINT' then
      result.ScatterPointRadius := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'RADARPOINT' then
      result.RadarPointRadius := Utils.StrToInt(lItem.Value)
    else if lItem.LocalName = 'LINEARPOINT' then
      result.AbaconPointRadius := Utils.StrToInt(lItem.Value);
end;

/// <summary>
/// Load the contents of this DexiModel from a file named 'aFileName'.
/// </summary>
/// <param name="aFileName">Input file name.</param>
method DexiModel.LoadFromFile(aFileName: String);
var XmlDoc: XmlDocument;
begin
  Clear;
  var lFile := new File(aFileName);
  try
    XmlDoc := XmlDocument.FromFile(lFile);
  except
    raise new EDexiError(String.Format(DexiString.SDexiFileLoad, lFile));
  end;
  if XmlDoc.Root.LocalName <> 'DEXi' then
    raise new EDexiError(String.Format(DexiString.SDexiFileFormat, lFile));
  LoadRoot(XmlDoc.Root);
  MigrateReports;
  fFileName := aFileName;
  fModified := false;
  if fXmlHandler <> nil then
    fXmlHandler.ReadXml(XmlDoc.Root);
end;

/// <summary>
/// Load a subtree of attributes from a string list. Typically used for copy/paste of subtrees.
/// </summary>
/// <param name="aList">Input list of strings.</param>
/// <returns>Root DexiAttribute of the loaded subtree.</returns>
method DexiModel.LoadFromStringList(aList: List<String>): DexiAttribute;
var XmlDoc: XmlDocument;
begin
  result := nil;
  try
    XmlDoc := XmlDocument.FromString(String.Join(Environment.LineBreak, aList));
  except
    raise new EDexiError(DexiString.SDexiListFormat);
  end;
  if XmlDoc.Root.LocalName <> 'SUBTREE' then
    raise new EDexiError(DexiString.SDexiListFormat);
  var AttItem := XmlDoc.Root:FirstElementWithName('ATTRIBUTE');
  if AttItem <> nil then
    LoadAttribute(AttItem, var result);
end;

/// <summary>
/// Load a full DexiModel from a string list.
/// </summary>
/// <param name="aList">Input List<String>.</param>
method DexiModel.LoadAllFromStringList(aList: List<String>);
var XmlDoc: XmlDocument;
begin
  try
    XmlDoc := XmlDocument.FromString(String.Join(Environment.LineBreak, aList));
  except
    raise new EDexiError(DexiString.SDexiListFormat);
  end;
  if XmlDoc.Root.LocalName <> 'DEXi' then
    raise new EDexiError(String.Format(DexiString.SDexiFileFormat, 'SavedList'));
  LoadRoot(XmlDoc.Root);
  MigrateReports;
  fModified := false;
end;

method DexiModel.SaveDescription(aItem: XmlElement; aDesc: String);
begin
  var lItem := new XmlElement withName('DESCRIPTION');
  if Utils.Pos0(Environment.LineBreak, aDesc) >= 0 then
    begin
      var d := aDesc;
      while d <> '' do
        lItem.AddElement(new XmlElement withName('LINE') Value(Utils.NextElem(var d, Environment.LineBreak)));
    end
  else
    lItem.Value := aDesc;
  aItem.AddElement(lItem);
end;

method DexiModel.SaveNameDescr(aObj: DexiObject; aItem: XmlElement);
begin
  if not String.IsNullOrEmpty(aObj.Name) then
    aItem.AddElement(new XmlElement withName('NAME') Value(aObj.Name));
  if not String.IsNullOrEmpty(aObj.Description) then
    SaveDescription(aItem, aObj.Description);
end;

method DexiModel.SaveFunctOld(aFunct: DexiTabularFunction; aItem: XmlElement);
begin
  var FncItem := new XmlElement withName('FUNCTION');
  SaveNameDescr(aFunct, FncItem);
  var l := new Char[aFunct.Count];
  var h := new Char[aFunct.Count];
  var e := new Char[aFunct.Count];
  for i := 0 to aFunct.Count - 1 do
    begin
      l[i] := chr(aFunct.RuleValLow[i] + ord('0'));
      h[i] := chr(aFunct.RuleValHigh[i] + ord('0'));
      e[i] := if aFunct.RuleEntered[i] then '+' else '-';
    end;
  FncItem.AddElement(new XmlElement withName('LOW') Value(Utils.CharsToString(l)));
  if Utils.CharsToString(h) <> Utils.CharsToString(l) then
    FncItem.AddElement(new XmlElement withName('HIGH') Value(Utils.CharsToString(h)));
  if aFunct.Count > aFunct.EntCount then
    FncItem.AddElement(new XmlElement withName('ENTERED') Value(Utils.CharsToString(e)));
  if aFunct.UseWeights then
    begin
      FncItem.AddElement(new XmlElement withName('WEIGHTS') Value(Utils.FltArrayToStr(aFunct.RequiredWeights)));
      FncItem.AddElement(new XmlElement withName('LOCWEIGHTS') Value(Utils.FltArrayToStr(aFunct.ActualWeights, 2)));
      FncItem.AddElement(new XmlElement withName('NORMLOCWEIGHTS') Value(Utils.FltArrayToStr(aFunct.NormActualWeights, 2)));
    end;
  if not aFunct.UseConsist then
    FncItem.AddElement(new XmlElement withName('CONSIST') Value(Utils.BooleanToStr(aFunct.UseConsist)));
  if aFunct.Rounding<>0 then
    FncItem.AddElement(new XmlElement withName('ROUNDING') Value(Utils.IntToStr(aFunct.Rounding)));
  aItem.AddElement(FncItem);
end;

method DexiModel.SaveFunct(aFunct: DexiTabularFunction; aItem: XmlElement);
begin
  var FncItem := new XmlElement withName('TABLE');
  SaveNameDescr(aFunct, FncItem);
  if aFunct.UseWeights then
    begin
      FncItem.AddElement(new XmlElement withName('WEIGHTS') Value(Utils.FltArrayToStr(aFunct.RequiredWeights)));
      FncItem.AddElement(new XmlElement withName('LOCWEIGHTS') Value(Utils.FltArrayToStr(aFunct.ActualWeights, 2)));
      FncItem.AddElement(new XmlElement withName('NORMLOCWEIGHTS') Value(Utils.FltArrayToStr(aFunct.NormActualWeights, 2)));
    end;
  if not aFunct.UseConsist then
    FncItem.AddElement(new XmlElement withName('CONSIST') Value(Utils.BooleanToStr(aFunct.UseConsist)));
  if aFunct.Rounding<>0 then
    FncItem.AddElement(new XmlElement withName('ROUNDING') Value(Utils.IntToStr(aFunct.Rounding)));
  for r := 0 to aFunct.Count - 1 do
    begin
      var RuleItem := new XmlElement withName('RULE') Value(DexiValue.ToString(aFunct.RuleValue[r]));
      RuleItem.AddAttribute(new XmlAttribute('Args', nil, Utils.IntArrayToStr(aFunct.ArgValues[r])));
      if not aFunct.RuleEntered[r] then
        RuleItem.AddAttribute(new XmlAttribute('Entered', nil, Utils.BooleanToStr(aFunct.RuleEntered[r])));
      FncItem.AddElement(RuleItem);
    end;
  aItem.AddElement(FncItem);
end;

method DexiModel.SaveFunct(aFunct: DexiDiscretizeFunction; aItem: XmlElement);
begin
  var FncItem := new XmlElement withName('DISCRETIZE');
  SaveNameDescr(aFunct, FncItem);
  if not aFunct.UseConsist then
    FncItem.AddElement(new XmlElement withName('CONSIST') Value(Utils.BooleanToStr(aFunct.UseConsist)));
  for i := 0 to aFunct.IntervalCount - 1 do
    begin
      if i > 0 then
        begin
          var lBound := aFunct.IntervalLowBound[i];
          var BndItem := new XmlElement withName('BOUND') Value(Utils.FltToStr(lBound.Bound));
          BndItem.AddAttribute(new XmlAttribute('Associate', nil, if lBound.Association = DexiBoundAssociation.Down then 'Down' else 'Up'));
          FncItem.AddElement(BndItem);
        end;
      var IntItem := new XmlElement withName('VALUE') Value(DexiValue.ToString(aFunct.IntervalValue[i]));
      if not aFunct.IntervalEntered[i] then
        IntItem.AddAttribute(new XmlAttribute('Entered', nil, Utils.BooleanToStr(aFunct.IntervalEntered[i])));
      FncItem.AddElement(IntItem);
    end;
  aItem.AddElement(FncItem);
end;

method DexiModel.SaveFunct(aAtt: DexiAttribute; aItem: XmlElement);
begin
  if (aAtt = nil) or (aAtt.Funct = nil) then
    exit;
  if aAtt.Funct is DexiTabularFunction then
    if fForceLibraryFormat or aAtt.Funct.UsesDexiLibraryFeatures then
      SaveFunct(DexiTabularFunction(aAtt.Funct), aItem)
    else
      SaveFunctOld(DexiTabularFunction(aAtt.Funct), aItem)
  else if aAtt.Funct is DexiDiscretizeFunction then
    SaveFunct(DexiDiscretizeFunction(aAtt.Funct), aItem);
end;

method DexiModel.SaveScale(aAtt: DexiAttribute; aItem: XmlElement);
begin
  if (aAtt = nil) or (aAtt.Scale = nil) then
    exit;
  var SclItem := new XmlElement withName('SCALE');
  SaveNameDescr(aAtt.Scale, SclItem);
  case aAtt.Scale.Order of
    DexiOrder.None:       SclItem.AddElement(new XmlElement withName('ORDER') Value('NONE'));
    DexiOrder.Descending: SclItem.AddElement(new XmlElement withName('ORDER') Value('DESC'));
    else {nothing}
  end;
  if not String.IsNullOrEmpty(aAtt.Scale.ScaleUnit) then
    SclItem.AddElement(new XmlElement withName('UNIT') Value(aAtt.Scale.ScaleUnit));
  if aAtt.Scale = DefaultScale then
    SclItem.AddElement(new XmlElement withName('DEFAULT') Value(''));
  if not aAtt.Scale.IsInterval then
    SclItem.AddElement(new XmlElement withName('INTERVAL') Value(Utils.BooleanToStr(aAtt.Scale.IsInterval)));
  if aAtt.Scale.FltDecimals >= 0 then
    SclItem.AddElement(new XmlElement withName('FLTDEC') Value(Utils.IntToStr(aAtt.Scale.FltDecimals)));
  if aAtt.Scale is DexiDiscreteScale then
    with lScl := DexiDiscreteScale(aAtt.Scale) do
      for i := 0 to lScl.Count - 1 do
        begin
          var ValItem := new XmlElement withName('SCALEVALUE');
          SaveNameDescr(lScl.Values[i], ValItem);
          if lScl.IsBad(i) then
            ValItem.AddElement(new XmlElement withName('GROUP') Value('BAD'))
          else if lScl.IsGood(i) then
            ValItem.AddElement(new XmlElement withName('GROUP') Value('GOOD'));
          if lScl.Colors[i] <> nil then
            ValItem.AddElement(new XmlElement withName('COLOR') Value(lScl.Colors[i].AsString));
          SclItem.AddElement(ValItem);
        end;
  if aAtt.Scale is DexiContinuousScale then
    with lScl := DexiContinuousScale(aAtt.Scale) do
      begin
        var ContItem := new  XmlElement withName('CONTINUOUS');
        if lScl.BGLow <> Consts.NegativeInfinity then
          ContItem.AddElement(new XmlElement withName('LOW') Value(Utils.FltToStr(lScl.BGLow)));
        if lScl.BGHigh <> Consts.PositiveInfinity then
          ContItem.AddElement(new XmlElement withName('HIGH') Value(Utils.FltToStr(lScl.BGHigh)));
        SclItem.AddElement(ContItem);
      end;
  aItem.AddElement(SclItem);
end;

method DexiModel.SaveAttribute(aAtt: DexiAttribute; aItem: XmlElement);
begin
  if aAtt = nil then
    exit;
  var NewItem := new XmlElement withName('ATTRIBUTE');
  SaveNameDescr(aAtt, NewItem);
  if aAtt.Scale <> nil then
    SaveScale(aAtt, NewItem);
  if aAtt.Funct <> nil then
    SaveFunct(aAtt, NewItem);
  for i := 0 to aAtt.AltCount - 1 do
    begin
      var lValue := aAtt.AltValue[i];
      var lNewFormat :=
        not DexiValue.ValueIsDefined(lValue) or
        (DexiValue.ValueIsDefined(lValue) and ((lValue.IsInteger and not lValue.HasIntSet) or lValue.IsFloat));
      if fForceLibraryFormat or lNewFormat then
        NewItem.AddElement(new XmlElement withName('ALTERNATIVE') Value(aAtt.AltText[i]))
      else
        NewItem.AddElement(new XmlElement withName('OPTION') Value(aAtt.OptText[i]));
    end;
  aItem.AddElement(NewItem);
  for i := 0 to aAtt.InpCount - 1 do
    SaveAttribute(aAtt.Inputs[i], NewItem);
end;

method DexiModel.SaveJsonSettings(JsonItem: XmlElement; aJson: DexiJsonSettings);
begin
  var aDefaults := new DexiJsonSettings;
  aDefaults.SetDefaults;
  if (aJson.IncludeModel <> nil) and (aJson.IncludeModel <> aDefaults.IncludeModel) then
    JsonItem.AddElement(new XmlElement withName('MODEL') Value(Utils.BooleanToStr(aJson.IncludeModel)));
  if (aJson.IncludeAlternatives <> nil) and (aJson.IncludeAlternatives <> aDefaults.IncludeAlternatives) then
    JsonItem.AddElement(new XmlElement withName('ALTERNATIVES') Value(Utils.BooleanToStr(aJson.IncludeAlternatives)));
  if (aJson.StructureFormat <> nil) and (aJson.StructureFormat <> aDefaults.StructureFormat) then
    begin
      var lValue :=
        if aJson.StructureFormat = DexiJsonStructureFormat.Recursive then 'RECURSIVE'
        else 'FLAT';
        JsonItem.AddElement(new XmlElement withName('STRUCTURE') Value(lValue));
    end;
  if (aJson.ModelElements <> nil) and (aJson.ModelElements <> aDefaults.ModelElements) then
    JsonItem.AddElement(new XmlElement withName('MODELEMENTS') Value(Convert.ToHexString(aJson.ModelElements, 8)));
  if (aJson.AlternativeElements <> nil) and (aJson.AlternativeElements <> aDefaults.AlternativeElements) then
    JsonItem.AddElement(new XmlElement withName('ALTELEMENTS') Value(Convert.ToHexString(aJson.AlternativeElements, 8)));
  if (aJson.AttributeTypes <> nil) and (aJson.AttributeTypes <> aDefaults.AttributeTypes) then
    JsonItem.AddElement(new XmlElement withName('ATTTYPES') Value(Convert.ToHexString(aJson.AttributeTypes, 8)));
  if (aJson.ModelInputs <> nil) and (aJson.ModelInputs <> aDefaults.ModelInputs) then
    JsonItem.AddElement(new XmlElement withName('MODINPUTS') Value(DexiSettings.JsonInputString(aJson.ModelInputs)));
  if (aJson.AlternativeInputs <> nil) and (aJson.AlternativeInputs <> aDefaults.AlternativeInputs) then
    JsonItem.AddElement(new XmlElement withName('ATTINPUTS') Value(DexiSettings.JsonInputString(aJson.AlternativeInputs)));
  if (aJson.UseDexiStringValues <> nil) and (aJson.UseDexiStringValues <> aDefaults.UseDexiStringValues) then
    JsonItem.AddElement(new XmlElement withName('DEXISTRINGS') Value(Utils.BooleanToStr(aJson.UseDexiStringValues)));
  if (aJson.ValueFormat <> nil) and (aJson.ValueFormat <> aDefaults.ValueFormat) then
    JsonItem.AddElement(new XmlElement withName('VALFORMAT') Value(DexiSettings.ValTypeString(aJson.ValueFormat)));
  if (aJson.DistributionFormat <> nil) and (aJson.DistributionFormat <> aDefaults.DistributionFormat) then
    begin
      var lValue :=
        if aJson.DistributionFormat = DexiJsonDistributionFormat.Dict then 'DICT'
        else 'DISTR';
        JsonItem.AddElement(new XmlElement withName('DISTRFORMAT') Value(lValue));
    end;
  if (aJson.FloatDecimals <> nil) and (aJson.FloatDecimals <> aDefaults.FloatDecimals) then
    JsonItem.AddElement(new XmlElement withName('FLTDEC') Value(Utils.IntToStr(aJson.FloatDecimals)));
  if (aJson.MembershipDecimals <> nil) and (aJson.MembershipDecimals <> aDefaults.MembershipDecimals) then
    JsonItem.AddElement(new XmlElement withName('MEMDEC') Value(Utils.IntToStr(aJson.MembershipDecimals)));
  if (aJson.JsonIndent <> nil) and (aJson.JsonIndent <> aDefaults.JsonIndent) then
    JsonItem.AddElement(new XmlElement withName('INDENT') Value(Utils.BooleanToStr(aJson.JsonIndent)));
  if (aJson.IncludeTimeInfo <> nil) and (aJson.IncludeTimeInfo <> aDefaults.IncludeTimeInfo) then
    JsonItem.AddElement(new XmlElement withName('TIMEINFO') Value(Utils.BooleanToStr(aJson.IncludeTimeInfo)));
end;

method DexiModel.SaveSettings(XmlItem: XmlElement);
begin
  var SetItem := new XmlElement withName('SETTINGS');
  if Linking then
    SetItem.AddElement(new XmlElement withName('LINKING') Value(Utils.BooleanToStr(Linking)));
  if not Undoing then
    SetItem.AddElement(new XmlElement withName('UNDOING') Value(Utils.BooleanToStr(Undoing)));
  if Settings.RptHtml then
    SetItem.AddElement(new XmlElement withName('HTML') Value(Utils.BooleanToStr(Settings.RptHtml)));
  if Settings.DefBrowser then
    SetItem.AddElement(new XmlElement withName('DEFBROWSER') Value(Utils.BooleanToStr(Settings.DefBrowser)));
  if not Settings.HasFullReports then
    SetItem.AddElement(new XmlElement withName('REPORTS') Value(Values.IntSetToStr(Settings.SelectedReports)));
  if Settings.UseReportHeader then
    SetItem.AddElement(new XmlElement withName('REPORTHEADING') Value(Utils.BooleanToStr(Settings.UseReportHeader)));
  if not Settings.HasFullWeights then
    SetItem.AddElement(new XmlElement withName('WEIGHTS') Value(Values.IntSetToStr(Settings.SelectedWeights))); // deprecated
  if not Settings.WeightsLocal then
    SetItem.AddElement(new XmlElement withName('LOCWEIGHTS') Value(Utils.BooleanToStr(Settings.WeightsLocal)));
  if not Settings.WeightsGlobal then
    SetItem.AddElement(new XmlElement withName('GLOBWEIGHTS') Value(Utils.BooleanToStr(Settings.WeightsGlobal)));
  if not Settings.WeightsLocalNormalized then
    SetItem.AddElement(new XmlElement withName('LOCNORMWEIGHTS') Value(Utils.BooleanToStr(Settings.WeightsLocalNormalized)));
  if not Settings.WeightsGlobalNormalized then
    SetItem.AddElement(new XmlElement withName('GLOBNORMWEIGHTS') Value(Utils.BooleanToStr(Settings.WeightsGlobalNormalized)));
// deprecated
//  if Settings.Pagebreak then
//    SetItem.AddElement(new XmlElement withName('PAGEBREAK') Value(Utils.BooleanToStr(Settings.Pagebreak)));
  if not Settings.ReportFontInfo.EqualTo(FontInfo.DefaultFont) then
    SetItem.AddElement(new XmlElement withName('REPORTFONT') Value(Settings.ReportFontInfo.AsString));
  if Settings.BadColor.AsString <> 'FF0000' then
    SetItem.AddElement(new XmlElement withName('BADCOLOR') Value(Settings.BadColor.AsString));
  if Settings.NeutralColor.AsString <> '000000' then
    SetItem.AddElement(new XmlElement withName('NEUTRALCOLOR') Value(Settings.NeutralColor.AsString));
  if Settings.GoodColor.AsString <> '008000' then
    SetItem.AddElement(new XmlElement withName('GOODCOLOR') Value(Settings.GoodColor.AsString));
  if Settings.BadStyle <> 'B' then
    SetItem.AddElement(new XmlElement withName('BADSTYLE') Value(Settings.BadStyle));
  if Settings.NeutralStyle <> '' then
    SetItem.AddElement(new XmlElement withName('NEUTRALSTYLE') Value(Settings.NeutralStyle));
  if Settings.GoodStyle <> 'BI' then
    SetItem.AddElement(new XmlElement withName('GOODSTYLE') Value(Settings.GoodStyle));
  if Settings.SectionBreak <> RptSection.BreakAll then
    SetItem.AddElement(new XmlElement withName('SECTIONBREAK') Value(Utils.IntToStr(Settings.SectionBreak)));
  if Settings.TableBreak <> RptSection.BreakAll then
    SetItem.AddElement(new XmlElement withName('TABLEBREAK') Value(Utils.IntToStr(Settings.TableBreak)));
  if Settings.WeiDecimals <> 0 then
    SetItem.AddElement(new XmlElement withName('WEIGHTDEC') Value(Utils.IntToStr(Settings.WeiDecimals)));
  if Settings.MemDecimals <> 0 then
    SetItem.AddElement(new XmlElement withName('MEMDEC') Value(Utils.IntToStr(Settings.MemDecimals)));
  if Settings.DefDetDecimals <> 0 then
    SetItem.AddElement(new XmlElement withName('DEFDETDEC') Value(Utils.IntToStr(Settings.DefDetDecimals)));
  if Settings.FltDecimals <> 0 then
    SetItem.AddElement(new XmlElement withName('FLTDEC') Value(Utils.IntToStr(Settings.FltDecimals)));
  if (Settings.MaxColumns <> 0) and (Settings.MaxColumns <> DexiSettings.DefMaxColumns) then
    begin
      SetItem.AddElement(new XmlElement withName('EVALCOL') Value(Utils.IntToStr(Settings.MaxColumns))); // deprecated
      SetItem.AddElement(new XmlElement withName('MAXCOL') Value(Utils.IntToStr(Settings.MaxColumns)));
    end;
  if Settings.EvalTrim<>0 then
    SetItem.AddElement(new XmlElement withName('EVALTRIM') Value(Utils.IntToStr(Settings.EvalTrim)));
  if not Settings.FncShowWeights then
    SetItem.AddElement(new XmlElement withName('SHOWWEIGHTS') Value(Utils.BooleanToStr(Settings.FncShowWeights)));
  if not Settings.FncShowNumbers then
    SetItem.AddElement(new XmlElement withName('SHOWNUMBERS') Value(Utils.BooleanToStr(Settings.FncShowNumbers)));
  if Settings.FncShowNumericValues then
    SetItem.AddElement(new XmlElement withName('SHOWNUMERICVALUES') Value(Utils.BooleanToStr(Settings.FncShowNumericValues)));
  if Settings.FncShowMarginals then
    SetItem.AddElement(new XmlElement withName('SHOWMARGINALS') Value(Utils.BooleanToStr(Settings.FncShowMarginals)));
  if not Settings.FncComplex then
    SetItem.AddElement(new XmlElement withName('COMPLEX') Value(Utils.BooleanToStr(Settings.FncComplex))); // deprecated
  if Settings.Representation <> DexiRptFunctionRepresentation.Complex then
    begin
      var s :=
        case Settings.Representation of
          DexiRptFunctionRepresentation.Elementary: 'Elementary';
          DexiRptFunctionRepresentation.Complex: 'Complex';
          DexiRptFunctionRepresentation.DecisionTree: 'DecisionTree';
          else 'Complex';
        end;
      SetItem.AddElement(new XmlElement withName('REPRESENTATION') Value(s));
    end;
  if Settings.FncEnteredOnly then
    SetItem.AddElement(new XmlElement withName('ENTERED') Value(Utils.BooleanToStr(Settings.FncEnteredOnly)));
  if not Settings.FncNormalizedWeights then
    SetItem.AddElement(new XmlElement withName('NORMALIZEDWEIGHTS') Value(Utils.BooleanToStr(Settings.FncNormalizedWeights)));
// deprecated
//  if Settings.FontSize<>10 then
//    SetItem.AddElement(new XmlElement withName('FONTSIZE') Value(Utils.IntToStr(Settings.FontSize)));
//  if Settings.FontName <> 'Arial' then
//    SetItem.AddElement(new XmlElement withName('FONTNAME') Value(Settings.FontName));
  if Settings.ValueType <> ValueStringType.One then
    SetItem.AddElement(new XmlElement withName('ALTDATATYPE') Value(DexiSettings.ValTypeString(Settings.ValueType)));
  if not Settings.AltDataAll then
    SetItem.AddElement(new XmlElement withName('OPTDATAALL') Value(Utils.BooleanToStr(Settings.AltDataAll)));
  if Settings.AltTranspose then
    SetItem.AddElement(new XmlElement withName('OPTTRANSPOSE') Value(Utils.BooleanToStr(Settings.AltTranspose)));
  if not Settings.AltLevels then
    SetItem.AddElement(new XmlElement withName('OPTLEVELS') Value(Utils.BooleanToStr(Settings.AltLevels)));
  if not Settings.CsvInvariant then
    SetItem.AddElement(new XmlElement withName('CSVINVARIANT') Value(Utils.BooleanToStr(Settings.CsvInvariant)));
  if Settings.FncDataType <> ValueStringType.One then
    SetItem.AddElement(new XmlElement withName('FNCDATATYPE') Value(DexiSettings.ValTypeString(Settings.FncDataType)));
  if not Settings.FncDataAll then
    SetItem.AddElement(new XmlElement withName('FNCDATAALL') Value(Utils.BooleanToStr(Settings.FncDataAll)));
  if Settings.FncStatus then
    SetItem.AddElement(new XmlElement withName('FNCSTATUS') Value(Utils.BooleanToStr(Settings.FncStatus)));
  if Settings.ModelProtect then
    SetItem.AddElement(new XmlElement withName('PROTECTMODEL') Value(Utils.BooleanToStr(Settings.ModelProtect)));
  if Settings.EvalType <> EvaluationType.AsSet then
    begin
      var s :=
        case Settings.EvalType of
          EvaluationType.AsSet: 'AsSet';
          EvaluationType.AsProb: 'AsProb';
          EvaluationType.AsFuzzy: 'AsFuzzy';
          EvaluationType.AsFuzzyNorm: 'AsFuzzyNorm';
          else 'AsSet';
        end;
      SetItem.AddElement(new XmlElement withName('EVALUATIONTYPE') Value(s));
    end;
  if not Settings.ExpandUndef then
    SetItem.AddElement(new XmlElement withName('EXPANDUNDEF') Value(Utils.BooleanToStr(Settings.ExpandUndef)));
  if not Settings.ExpandEmpty then
    SetItem.AddElement(new XmlElement withName('EXPANDEMPTY') Value(Utils.BooleanToStr(Settings.ExpandEmpty)));
  if not Settings.CheckBounds then
    SetItem.AddElement(new XmlElement withName('CHECKBOUNDS') Value(Utils.BooleanToStr(Settings.CheckBounds)));
  if not Settings.Warnings then
    SetItem.AddElement(new XmlElement withName('WARNINGS') Value(Utils.BooleanToStr(Settings.Warnings)));
  if not Settings.CanMoveTabs then
    SetItem.AddElement(new XmlElement withName('CANMOVETABS' ) Value(Utils.BooleanToStr(Settings.CanMoveTabs)));
  if Settings.AttId <> AttributeIdentification.Name then
    begin
      var s :=
        case Settings.AttId of
          AttributeIdentification.Name: 'Name';
          AttributeIdentification.Id: 'Id';
          AttributeIdentification.Path: 'Path';
          else 'Name';
        end;
      SetItem.AddElement(new XmlElement withName('ATTID') Value(s));
    end;
  if Settings.UseDexiStringValues then
    SetItem.AddElement(new XmlElement withName('DEXISTRINGS' ) Value(Utils.BooleanToStr(Settings.UseDexiStringValues)));
  if Settings.TreePattern <> RptTreePattern.Lines then
    begin
      var s :=
        case Settings.TreePattern of
          RptTreePattern.None: 'None';
          RptTreePattern.PlusMinus: 'PlusMinus';
          RptTreePattern.Dots: 'Dots';
          RptTreePattern.AllDots: 'AllDots';
          RptTreePattern.Unicode: 'Unicode';
          else 'Lines';
        end;
      SetItem.AddElement(new XmlElement withName('TREEPATTERN') Value(s));
    end;
  if Settings.JsonSettings <> nil then
    begin
      var JsonItem := new XmlElement withName('JSON');
      SaveJsonSettings(JsonItem, Settings.JsonSettings);
      SetItem.AddElement(JsonItem);
    end;
  XmlItem.AddElement(SetItem);
end;

method DexiModel.SaveReportFormat(XmlItem: XmlElement; aFmt: DexiReportFormat);
begin
  if aFmt = nil then
    exit;
  var FmtItem := XmlItem;
  // Title skipped, because it is derived from DexiReport
  if aFmt.Software <> fDefaultFormat.Software then
    FmtItem.AddElement(new XmlElement withName('SOFTWARE') Value(aFmt.Software));
//  if aFmt.FileName <> fDefaultFormat.FileName then
//    FmtItem.AddElement(new XmlElement withName('FILENAME') Value(aFmt.FileName));
  if aFmt.FontName <> fDefaultFormat.FontName then
    FmtItem.AddElement(new XmlElement withName('FONTNAME') Value(aFmt.FontName));
  if aFmt.FontSize <> fDefaultFormat.FontSize then
    FmtItem.AddElement(new XmlElement withName('FONTSIZE') Value(Utils.FltToStr(aFmt.FontSize, true)));
end;

method DexiModel.SaveSelectedAttributes(XmlItem: XmlElement; aAtts: ImmutableList<DexiAttribute>);
begin
  var AttItem := new XmlElement withName('ATTRIBUTES');
  XmlItem.AddElement(AttItem);
  for each lAtt in aAtts do
    AttItem.AddElement(new XmlElement withName('ATTRIBUTE') Value(Utils.IntArrayToStr(lAtt.ParentIndices)));
end;

method DexiModel.SaveReportParameters(XmlItem: XmlElement; aPar: DexiReportParameters);
begin
  if aPar = nil then
    exit;
//  var ParItem := new XmlElement withName('PARAMETERS');
//  XmlItem.AddElement(ParItem);
  var ParItem := XmlItem;
  if aPar.Root <> nil then
    ParItem.AddElement(new XmlElement withName('ROOT') Value(Utils.IntArrayToStr(aPar.Root.ParentIndices)));
  if aPar.Alternative <> fDefaultParameters.Alternative then
    ParItem.AddElement(new XmlElement withName('ALTERNATIVE') Value(Utils.IntToStr(aPar.Alternative)));
  if aPar.SelectedAttributes <> fDefaultParameters.SelectedAttributes then
    SaveSelectedAttributes(ParItem, aPar.SelectedAttributes);
  if not Utils.IntArrayEq(aPar.SelectedAlternatives:Ints, fDefaultParameters.SelectedAlternatives:Ints) then
    ParItem.AddElement(new XmlElement withName('ALTERNATIVES') Value(Utils.IntArrayToStr(aPar.SelectedAlternatives:Ints)));
  if not Utils.IntArrayEq(aPar.Columns, fDefaultParameters.Columns) then
    ParItem.AddElement(new XmlElement withName('COLUMNS') Value(Utils.IntArrayToStr(aPar.Columns)));
  if aPar.WeiDecimals <> fDefaultParameters.WeiDecimals then
    ParItem.AddElement(new XmlElement withName('WEIGHTDEC') Value(Utils.IntToStr(aPar.WeiDecimals)));
  if aPar.MemDecimals <> fDefaultParameters.MemDecimals then
    ParItem.AddElement(new XmlElement withName('MEMDEC') Value(Utils.IntToStr(aPar.MemDecimals)));
  if aPar.DefDetDecimals <> fDefaultParameters.DefDetDecimals then
    ParItem.AddElement(new XmlElement withName('DEFDETDEC') Value(Utils.IntToStr(aPar.DefDetDecimals)));
  if aPar.FltDecimals <> fDefaultParameters.FltDecimals then
    ParItem.AddElement(new XmlElement withName('FLOATDEC') Value(Utils.IntToStr(aPar.FltDecimals)));
  if aPar.AttName <> fDefaultParameters.AttName then
    ParItem.AddElement(new XmlElement withName('ATTNAME') Value(Utils.BooleanToStr(aPar.AttName)));
  if aPar.AttDescription <> fDefaultParameters.AttDescription then
    ParItem.AddElement(new XmlElement withName('ATTDESCRIPTION') Value(Utils.BooleanToStr(aPar.AttDescription)));
  if aPar.AttScale <> fDefaultParameters.AttScale then
    ParItem.AddElement(new XmlElement withName('ATTSCALE') Value(Utils.BooleanToStr(aPar.AttScale)));
  if aPar.AttFunction <> fDefaultParameters.AttFunction then
    ParItem.AddElement(new XmlElement withName('ATTFUNCTION') Value(Utils.BooleanToStr(aPar.AttFunction)));
  if aPar.FncShowWeights <> fDefaultParameters.FncShowWeights then
    ParItem.AddElement(new XmlElement withName('SHOWWEIGHTS') Value(Utils.BooleanToStr(aPar.FncShowWeights)));
  if aPar.FncShowNumbers <> fDefaultParameters.FncShowNumbers then
    ParItem.AddElement(new XmlElement withName('SHOWNUMBERS') Value(Utils.BooleanToStr(aPar.FncShowNumbers)));
  if aPar.FncShowNumericValues <> fDefaultParameters.FncShowNumericValues then
    ParItem.AddElement(new XmlElement withName('SHOWNUMERICVALUES') Value(Utils.BooleanToStr(aPar.FncShowNumericValues)));
  if aPar.FncShowMarginals <> fDefaultParameters.FncShowMarginals then
    ParItem.AddElement(new XmlElement withName('SHOWMARGINALS') Value(Utils.BooleanToStr(aPar.FncShowMarginals)));
  if aPar.FncEnteredOnly <> fDefaultParameters.FncEnteredOnly then
    ParItem.AddElement(new XmlElement withName('ENTEREDONLY') Value(Utils.BooleanToStr(aPar.FncEnteredOnly)));
  if aPar.FncStatus <> fDefaultParameters.FncStatus then
    ParItem.AddElement(new XmlElement withName('FUNCTIONSTATUS') Value(Utils.BooleanToStr(aPar.FncStatus)));
  if aPar.Representation <> fDefaultParameters.Representation then
    begin
      var s :=
        case aPar.Representation of
          DexiRptFunctionRepresentation.Elementary: 'Elementary';
          DexiRptFunctionRepresentation.Complex: 'Complex';
          DexiRptFunctionRepresentation.DecisionTree: 'DecisionTree';
          else 'Complex';
        end;
      ParItem.AddElement(new XmlElement withName('REPRESENTATION') Value(s));
    end;
  if aPar.WeightsLocal <> fDefaultParameters.WeightsLocal then
    ParItem.AddElement(new XmlElement withName('LOCWEIGHTS') Value(Utils.BooleanToStr(aPar.WeightsLocal)));
  if aPar.WeightsGlobal <> fDefaultParameters.WeightsGlobal then
    ParItem.AddElement(new XmlElement withName('GLOBWEIGHTS') Value(Utils.BooleanToStr(aPar.WeightsGlobal)));
  if aPar.WeightsLocalNormalized <> fDefaultParameters.WeightsLocalNormalized then
    ParItem.AddElement(new XmlElement withName('LOCNORMWEIGHTS') Value(Utils.BooleanToStr(aPar.WeightsLocalNormalized)));
  if aPar.WeightsGlobalNormalized <> fDefaultParameters.WeightsGlobalNormalized then
    ParItem.AddElement(new XmlElement withName('GLOBNORMWEIGHTS') Value(Utils.BooleanToStr(aPar.WeightsGlobalNormalized)));
  if aPar.UseNormalizedWeights <> fDefaultParameters.UseNormalizedWeights then
    ParItem.AddElement(new XmlElement withName('USENORMWEIGHTS') Value(Utils.BooleanToStr(aPar.UseNormalizedWeights)));
  if aPar.DeepCompare <> fDefaultParameters.DeepCompare then
    ParItem.AddElement(new XmlElement withName('DEEPCOMPARE') Value(Utils.BooleanToStr(aPar.DeepCompare)));
  if aPar.MinusSteps <> fDefaultParameters.MinusSteps then
    ParItem.AddElement(new XmlElement withName('MINUSSTEPS') Value(Utils.IntToStr(aPar.MinusSteps)));
  if aPar.PlusSteps <> fDefaultParameters.PlusSteps then
    ParItem.AddElement(new XmlElement withName('PLUSSTEPS') Value(Utils.IntToStr(aPar.PlusSteps)));
  if aPar.Improve <> fDefaultParameters.Improve then
    ParItem.AddElement(new XmlElement withName('IMPROVE') Value(Utils.BooleanToStr(aPar.Improve)));
  if aPar.Unidirectional <> fDefaultParameters.Unidirectional then
    ParItem.AddElement(new XmlElement withName('UNIDIRECTIONAL') Value(Utils.BooleanToStr(aPar.Unidirectional)));
  if aPar.MaxSteps <> fDefaultParameters.MaxSteps then
    ParItem.AddElement(new XmlElement withName('MAXSTEPS') Value(Utils.IntToStr(aPar.MaxSteps)));
  if aPar.MaxGenerate <> fDefaultParameters.MaxGenerate then
    ParItem.AddElement(new XmlElement withName('MAXGENERATE') Value(Utils.IntToStr(aPar.MaxGenerate)));
  if aPar.MaxShow <> fDefaultParameters.MaxShow then
    ParItem.AddElement(new XmlElement withName('MAXSHOW') Value(Utils.IntToStr(aPar.MaxShow)));
  if aPar.MakeTitle <> fDefaultParameters.MakeTitle then
    ParItem.AddElement(new XmlElement withName('MAKETITLE') Value(Utils.BooleanToStr(aPar.MakeTitle)));
end;

method DexiModel.SaveReport(XmlItem: XmlElement; aRpt: DexiReport);
begin
  if aRpt is not DexiReportGroup then
    XmlItem.AddElement(new XmlElement withName('TYPE') Value(aRpt.ReportType));
  if not String.IsNullOrEmpty(aRpt.Title) then
    XmlItem.AddElement(new XmlElement withName('TITLE') Value(aRpt.Title));
  if not aRpt.Selected then
    XmlItem.AddElement(new XmlElement withName('SELECTED') Value(Utils.BooleanToStr(aRpt.Selected)));
  SaveReportFormat(XmlItem, aRpt.Format);
  SaveReportParameters(XmlItem, aRpt.Parameters);
  SaveChartParameters(XmlItem, aRpt.ChartParameters);
end;

method DexiModel.SaveReportGroup(XmlItem: XmlElement; aRptGrp: DexiReportGroup);
begin
  var GrpItem := new XmlElement withName('REPORTGROUP');
  XmlItem.AddElement(GrpItem);
  SaveReport(GrpItem, aRptGrp);
  for each lRpt in aRptGrp.Reports do
    begin
      var RptItem := new XmlElement withName('REPORT');
      GrpItem.AddElement(RptItem);
      SaveReport(RptItem, lRpt);
    end;
end;

method DexiModel.SaveReports(XmlItem: XmlElement);
begin
  if RptCount <= 0 then
    exit;
  fDefaultFormat := new DexiReportFormat(self);
  fDefaultParameters := new DexiReportParameters(self);
  var RptsItem := new XmlElement withName('REPORTS');
  XmlItem.AddElement(RptsItem);
  for each lRptGroup in fReports do
    SaveReportGroup(RptsItem, lRptGroup);
  fDefaultFormat := nil;
  fDefaultParameters := nil;
end;

method DexiModel.SaveChartParameters(XmlItem: XmlElement; aParameters: DexiChartParameters);
begin
  if aParameters = nil then
    exit;
  fDefaultChartParameters := new DexiChartParameters;
  var ChartItem := new XmlElement withName('CHART');
  XmlItem.AddElement(ChartItem);
  if aParameters.SelectedAttributes <> nil then
    SaveSelectedAttributes(ChartItem, aParameters.SelectedAttributes);
  if aParameters.SelectedAlternatives <> nil then
    ChartItem.AddElement(new XmlElement withName('ALTERNATIVES') Value(Utils.IntArrayToStr(aParameters.SelectedAlternatives:Ints)));
  if aParameters.MultiChartType <> fDefaultChartParameters.MultiChartType then
    begin
      var s :=
        case aParameters.MultiChartType of
          DexiMultiAttChartType.Linear: 'Linear';
          DexiMultiAttChartType.RadarGrid: 'RadarGrid';
          else 'Radar';
        end;
      ChartItem.AddElement(new XmlElement withName('MULTICHARTTYPE') Value(s));
    end;
  if aParameters.GridX <> fDefaultChartParameters.GridX then
    ChartItem.AddElement(new XmlElement withName('GRIDX') Value(Utils.IntToStr(aParameters.GridX)));
  if aParameters.GridY <> fDefaultChartParameters.GridY then
    ChartItem.AddElement(new XmlElement withName('GRIDY') Value(Utils.IntToStr(aParameters.GridY)));
  if not aParameters.Border.EqualTo(fDefaultChartParameters.Border) then
    ChartItem.AddElement(new XmlElement withName('BORDER') Value(aParameters.Border.RelativeString(fDefaultChartParameters.Border)));
  if aParameters.BackgroundColorInfo.AsString <> fDefaultChartParameters.BackgroundColorInfo.AsString then
    ChartItem.AddElement(new XmlElement withName('BACKGROUNDCOLOR') Value(aParameters.BackgroundColorInfo.AsString));
  if aParameters.AreaColorInfo.AsString <> fDefaultChartParameters.AreaColorInfo.AsString then
    ChartItem.AddElement(new XmlElement withName('AREACOLOR') Value(aParameters.AreaColorInfo.AsString));
  if aParameters.LightNeutralColorInfo.AsString <> '909090' then
    ChartItem.AddElement(new XmlElement withName('LIGHTNEUTRALCOLOR') Value(aParameters.LightNeutralColorInfo.AsString));
  if aParameters.UndefColorInfo.AsString <> '808080' then
    ChartItem.AddElement(new XmlElement withName('UNDEFCOLOR') Value(aParameters.UndefColorInfo.AsString));
  if aParameters.AttFontInfo.AsString <> fDefaultChartParameters.AttFontInfo.AsString then
    ChartItem.AddElement(new XmlElement withName('ATTFONT') Value(aParameters.AttFontInfo.AsString));
  if aParameters.AltFontInfo.AsString <> fDefaultChartParameters.AltFontInfo.AsString then
    ChartItem.AddElement(new XmlElement withName('ALTFONT') Value(aParameters.AltFontInfo.AsString));
  if aParameters.ValFontInfo.AsString <> fDefaultChartParameters.ValFontInfo.AsString then
    ChartItem.AddElement(new XmlElement withName('VALFONT') Value(aParameters.ValFontInfo.AsString));
  if aParameters.LineWidth <> fDefaultChartParameters.LineWidth then
    ChartItem.AddElement(new XmlElement withName('LINEWIDTH') Value(Utils.FltToStr(aParameters.LineWidth)));
  if aParameters.TransparentAlpha <> fDefaultChartParameters.TransparentAlpha then
    ChartItem.AddElement(new XmlElement withName('TRANSPARENT') Value(Utils.IntToStr(aParameters.TransparentAlpha)));
  if aParameters.AltGap <> fDefaultChartParameters.AltGap then
    ChartItem.AddElement(new XmlElement withName('ALTGAP') Value(Utils.IntToStr(aParameters.AltGap)));
  if aParameters.AttGap <> fDefaultChartParameters.AttGap then
    ChartItem.AddElement(new XmlElement withName('ATTGAP') Value(Utils.IntToStr(aParameters.AttGap)));
  if aParameters.ScaleGap <> fDefaultChartParameters.ScaleGap then
    ChartItem.AddElement(new XmlElement withName('SCALEGAP') Value(Utils.IntToStr(aParameters.ScaleGap)));
  if aParameters.ValGap <> fDefaultChartParameters.ValGap then
    ChartItem.AddElement(new XmlElement withName('VALGAP') Value(Utils.IntToStr(aParameters.ValGap)));
  if aParameters.LineGap <> fDefaultChartParameters.LineGap then
    ChartItem.AddElement(new XmlElement withName('LINEGAP') Value(Utils.IntToStr(aParameters.LineGap)));
  if aParameters.TickLength <> fDefaultChartParameters.TickLength then
    ChartItem.AddElement(new XmlElement withName('TICKLENGTH') Value(Utils.IntToStr(aParameters.TickLength)));
  if aParameters.LegendWidth <> fDefaultChartParameters.LegendWidth then
    ChartItem.AddElement(new XmlElement withName('LEGENDWIDTH') Value(Utils.IntToStr(aParameters.LegendWidth)));
  if aParameters.LegendHeight <> fDefaultChartParameters.LegendHeight then
    ChartItem.AddElement(new XmlElement withName('LEGENDHEIGHT') Value(Utils.IntToStr(aParameters.LegendHeight)));
  if aParameters.LegendGap <> fDefaultChartParameters.LegendGap then
    ChartItem.AddElement(new XmlElement withName('LEGENDGAP') Value(Utils.IntToStr(aParameters.LegendGap)));
  if aParameters.MinSideGap <> fDefaultChartParameters.MinSideGap then
    ChartItem.AddElement(new XmlElement withName('MINSIDEGAP') Value(Utils.IntToStr(aParameters.MinSideGap)));
  if aParameters.BarExtent <> fDefaultChartParameters.BarExtent then
    ChartItem.AddElement(new XmlElement withName('BAREXTENT') Value(Utils.FltToStr(aParameters.BarExtent)));
  if aParameters.ScatterPointRadius <> fDefaultChartParameters.ScatterPointRadius then
    ChartItem.AddElement(new XmlElement withName('SCATTERPOINT') Value(Utils.IntToStr(aParameters.ScatterPointRadius)));
  if aParameters.RadarPointRadius <> fDefaultChartParameters.RadarPointRadius then
    ChartItem.AddElement(new XmlElement withName('RADARPOINT') Value(Utils.IntToStr(aParameters.RadarPointRadius)));
  if aParameters.AbaconPointRadius <> fDefaultChartParameters.AbaconPointRadius then
    ChartItem.AddElement(new XmlElement withName('LINEARPOINT') Value(Utils.IntToStr(aParameters.AbaconPointRadius)));
  fDefaultChartParameters := nil;
end;

/// <summary>
/// Save this DexiModel to a .dxi file 'aFileName' (using XML format).
/// </summary>
/// <param name="aFileName">File name.</param>
method DexiModel.SaveToFile(aFileName: String);
begin
  var XmlItem := new XmlElement withName('DEXi');
  if not String.IsNullOrEmpty(DexiString.DexSoftware) then
    XmlItem.AddElement(new XmlElement withName('SOFTWARE') Value(DexiString.DexSoftware));
  XmlItem.AddElement(new XmlElement withName('LIBRARY') Value(DexiLibrary.LibraryString));
  if not String.IsNullOrEmpty(Created) then
    XmlItem.AddElement(new XmlElement withName('CREATED') Value(Created));
  XmlItem.AddElement(new XmlElement withName('SAVED') Value(Utils.ISODateTimeStr(DateTime.UtcNow)));
  if UsesDexiLibraryFeatures then
    XmlItem.AddElement(new XmlElement withName('FORMAT') Value('DexiLibrary'));
  SaveNameDescr(self, XmlItem);
  if not String.IsNullOrEmpty(Operation) then
    XmlItem.AddElement(new XmlElement withName('OPERATION') Value(Operation));
  for i := 0 to fAltNames.Count - 1 do
    if not String.IsNullOrEmpty(fAltNames[i].Description) or fForceLibraryFormat then
      begin
        var lAltElement := new XmlElement withName('ALTERNATIVE');
        SaveNameDescr(fAltNames[i], lAltElement);
        XmlItem.AddElement(lAltElement);
      end
    else
      XmlItem.AddElement(new XmlElement withName('OPTION') Value(fAltNames[i].Name));
  SaveSettings(XmlItem);
  for i := 0 to Root.InpCount - 1 do
    SaveAttribute(Root.Inputs[i], XmlItem);
  SaveReports(XmlItem);
  SaveChartParameters(XmlItem, ChartParameters);
  if fInputAttributeOrder <> nil then
    XmlItem.AddElement(new XmlElement withName('INPUTORDER') Value(Utils.IntArrayToStr(fInputAttributeOrder)));
  if fXmlHandler <> nil then
    fXmlHandler.WriteXml(XmlItem);
  var lDoc := XmlDocument.WithRootElement(XmlItem);
  lDoc.Encoding := 'UTF-8';
  var XmlFormat := new XmlFormattingOptions;
  XmlFormat.WhitespaceStyle := XmlWhitespaceStyle.PreserveWhitespaceAroundText;
  XmlFormat.NewLineForElements := true;
  XmlFormat.Indentation := ' ';
  lDoc.SaveToFile(aFileName, XmlFormat);
  fModified := false;
  fFileName := aFileName;
end;

/// <summary>
/// Save the subtree of attributes rooted at 'aAtt' to a XML-formatted string.
/// </summary>
/// <param name="aAtt">Root DexiAttribute.</param>
/// <returns>String</returns>
method DexiModel.SaveSubtreeToString(aAtt: DexiAttribute): String;
begin
  if aAtt = nil then aAtt := Root;
  var XmlItem := new XmlElement withName('SUBTREE');
  SaveAttribute(aAtt, XmlItem);
  result := XmlItem.ToString;
end;

/// <summary>
/// Save the subtree of attributes rooted at 'aAtt' to a XML-formatted string list.
/// Typically used for copy/paste operations.
/// </summary>
/// <param name="aAtt">Root DexiAttribute to be saved.</param>
/// <param name="aList">var List<String>, created externally.</param>
method DexiModel.SaveToStringList(aAtt: DexiAttribute; var aList: List<String>);
begin
  var lString := SaveSubtreeToString(aAtt);
  aList := Utils.StrToLines(lString);
end;

/// <summary>
/// Save this entire DexiModel to an externally created List<String>.
/// </summary>
/// <param name="aList">var List<String>, created externally.</param>
method DexiModel.SaveAllToStringList(var aList: List<String>);
begin
  var XmlItem := new XmlElement withName('DEXi');
  SaveNameDescr(self, XmlItem);
  for i := 0 to fAltNames.Count - 1 do
    XmlItem.AddElement(new XmlElement withName('OPTION') Value(fAltNames[i].Name));
  SaveSettings(XmlItem);
  for i := 0 to Root.InpCount - 1 do
    SaveAttribute(Root.Inputs[i], XmlItem);
  aList := Utils.StrToLines(XmlItem.ToString);
  fModified := false;
end;

/// <summary>
/// Save the tree of attributes to a tab-delimited file 'aFileName'.
/// Output includes level-indented attribute names, scales, descriptions and link information.
/// </summary>
/// <param name="aFileName">File name.</param>
method DexiModel.SaveTreeToTabFile(aFileName: String);
var aList := new List<String>;

  method TabAtt(aAtt: DexiAttribute; aLev: Integer);
  begin
    var sb := new StringBuilder;
    sb.Append(Utils.ChStr(aLev));
    sb.Append(aAtt.Name);
    sb.Append(Utils.TabChar);
    sb.Append(if aAtt.IsAggregate then '*' else if aAtt.Link <> nil then '>' else ':');
    sb.Append(Utils.TabChar);
    sb.Append(if aAtt.Scale = nil then DexiString.SDexiNullScale else aAtt.Scale.ScaleString);
    sb.Append(Utils.TabChar);
    sb.Append(aAtt.Description);
    aList.Add(sb.ToString);
    for i := 0 to aAtt.InpCount - 1 do
      TabAtt(aAtt.Inputs[i], aLev+1);
  end;

begin
  for i := 0 to Root.InpCount - 1 do
    TabAtt(Root.Inputs[i], 0);
  File.WriteLines(aFileName, aList);
end;

/// <summary>
/// Save the hierarchy of attributes to a GML-formatted file 'aFileName' for
/// further processing of graphic sofware (such as yEd Graph Editor).
/// </summary>
/// <param name="aFileName">File name.</param>
method DexiModel.SaveToGMLFile(aFileName: String);

  method WriteNodes(aAttributes: DexiAttributeList; sb: StringBuilder);
  begin
    for each lAtt in aAttributes do
      if lAtt.Link = nil then
        begin
          sb.AppendLine('node [');
          sb.AppendLine($' id "{lAtt.ID}"');
          sb.AppendLine($' label "{lAtt.Name}"');
          sb.AppendLine(']');
        end;
  end;

  method WriteEdges(aAttributes: DexiAttributeList; sb: StringBuilder);

   method WriteEdgeTo(aFrom, aTo: DexiAttribute);
    begin
      sb.AppendLine('edge [');
      sb.AppendLine($' source "{aFrom.ID}"');
      sb.AppendLine($' target "{aTo.ID}"');
      sb.AppendLine(']');
    end;

   begin
    for each lAtt in aAttributes do
      for j := 0 to lAtt.InpCount - 1 do
        if lAtt.Inputs[j].Link <> nil then
          WriteEdgeTo(lAtt, lAtt.Inputs[j].Link)
        else
          WriteEdgeTo(lAtt, lAtt.Inputs[j]);
   end;

begin
  MakeUniqueAttributeIDs;
  var lAttributes := Root.CollectInputs;
  using sb := new StringBuilder do
    begin
      sb.AppendLine('graph [');
      WriteNodes(lAttributes, sb);
      WriteEdges(lAttributes, sb);
      sb.AppendLine(']');
      File.WriteText(aFileName, sb.ToString);
    end;
end;

/// <summary>
/// Save this DexiModel to a json-formatted file.
/// </summary>
/// <param name="aFileName">File name.</param>
/// <param name="aSettings">DexiJsonSettings determining the contents and extent of generated output.</param>
method DexiModel.SaveToJsonFile(aFileName: String; aSettings: DexiJsonSettings := nil);

begin
  var lJsonWriter := new DexiJsonWriter(aSettings);
  lJsonWriter.SaveModelToFile(self, aFileName);
end;

/// <summary>
/// Save this DexiModel to a json-formatted String.
/// </summary>
/// <param name="aFileName">File name.</param>
/// <param name="aSettings">DexiJsonSettings determining the contents and extent of generated output.</param>
method DexiModel.SaveToJsonString(aSettings: DexiJsonSettings := nil): String;
begin
  var lJsonWriter := new DexiJsonWriter(aSettings);
  result := lJsonWriter.SaveModelToString(self);
end;

/// <summary>
/// Make a copy of attribute subtree rooted at 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttibute</param>
/// <returns>Cloned DexiAttribute together with clomed subtrees.</returns>
method DexiModel.CloneSubtree(aAtt: DexiAttribute): DexiAttribute;
begin
  var aList := new List<String>;
  SaveToStringList(aAtt, var aList);
  result := LoadFromStringList(aList);
end;

/// <summary>
/// Deeply compare two alternatives.
/// </summary>
/// <param name="aAlt1">First alternative.</param>
/// <param name="aAlt2">Second alternative.</param>
/// <param name="aRoot">Root attribute for comparison.</param>
/// <returns>Disctionary mapping attributes to corresponding DeepComparisons.</returns>
method DexiModel.DeepCompare(aAlt1, aAlt2: IDexiAlternative; aRoot: DexiAttribute := nil): Dictionary<DexiAttribute, DeepComparison>;
var lResult := new Dictionary<DexiAttribute, DeepComparison>;

  method CompareAlternativesAt(aAtt: DexiAttribute);
  begin
    if aAtt.Link <> nil then
      begin
        CompareAlternativesAt(aAtt.Link);
        lResult.Add(aAtt, lResult[aAtt.Link]);
        exit;
      end;
    for i := 0 to aAtt.InpCount - 1 do
      CompareAlternativesAt(aAtt.Inputs[i]);
    if aAtt:Scale <> nil then
      begin
        var lMethod :=
          if aAtt.Scale.IsDiscrete then DexiValueMethod.Distr
          else DexiValueMethod.Single;
        var lHere := DexiScale.CompareValues(aAlt1[aAtt], aAlt2[aAtt], aAtt.Scale, lMethod);
        var lBelow := PrefCompare.Equal;
        for i := 0 to aAtt.InpCount - 1 do
          lBelow := Values.PrefCompareUpdate(lBelow, lResult[aAtt.Inputs[i]].Here);
        lResult.Add(aAtt, new DeepComparison(lHere, lBelow));
      end;
  end;

begin
  if aRoot = nil then
    aRoot := Root;
  CompareAlternativesAt(aRoot);
  result := lResult;
end;


method DexiModel.CollectUndoableObjects(aList: List<IUndoable>);
begin
  inherited CollectUndoableObjects(aList);
  UndoUtils.Include(aList, self);
  UndoUtils.IncludeRecursive(aList, fRoot);
  UndoUtils.IncludeRecursive(aList, fAltNames);
  UndoUtils.IncludeRecursive(aList, fSettings);
  UndoUtils.IncludeRecursive(aList, fReports);
  UndoUtils.Include(aList, fChartParameters);
end;

method DexiModel.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiModel then
    exit false;
  if aObj = self then
    exit true;
  var lModel := DexiModel(aObj);
  if not inherited EqualStateAs(lModel) then
    exit false;
  result :=
    (lModel.fRoot = fRoot) and
    Utils.EqualLists(lModel.fAltNames, fAltNames) and
    (lModel.fSettings = fSettings) and
    Utils.EqualLists(fReports, lModel.fReports) and
    fChartParameters.EqualStateAs(lModel.fChartParameters);
end;

method DexiModel.GetUndoState: IUndoable;
begin
  var lModel := new DexiModel;
  lModel.AssignObject(self);
  lModel.fModified := fModified;
  lModel.fRoot := fRoot;
  lModel.fAltNames := DexiList<DexiObject>.CopyList(fAltNames);
  lModel.fSettings := fSettings;
  lModel.fReports := Utils.CopyList(fReports);
  lModel.fChartParameters := fChartParameters;
  result := lModel;
end;

method  DexiModel.SetUndoState(aState: IUndoable);
begin
  inherited SetUndoState(aState);
  var lModel := aState as DexiModel;
  fModified := lModel.fModified;
  fRoot := lModel.fRoot;
  fAltNames := DexiList<DexiObject>.CopyList(lModel.fAltNames);
  fSettings := lModel.fSettings;
  fReports := Utils.CopyList(lModel.fReports);
  fChartParameters := lModel.fChartParameters;
end;

/// <summary>
/// Is it possible to move attribute 'aAtt' before its previous sibling?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanMovePrev(aAtt: DexiAttribute): Boolean;
begin
  var lParent := aAtt:Parent;
  if lParent = nil then
    exit false;
  var lIdx := lParent.InpIndex(aAtt);
  result := 1 <= lIdx < lParent.InpCount;
end;

/// <summary>
/// Move attribute 'aAtt' before its previous sibling.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
method DexiModel.MovePrev(aAtt: DexiAttribute);
begin
  if CanMovePrev(aAtt) then
    begin
      var lParent := aAtt.Parent;
      var lIdx := lParent.InpIndex(aAtt);
      aAtt.Parent.MoveInputPrev(lIdx);
      if lParent.Funct <> nil then
        lParent.Funct.ExchangeArgs(lIdx - 1, lIdx);
    end;
end;

/// <summary>
/// Is it possible to move attribute 'aAtt' after its next sibling?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanMoveNext(aAtt: DexiAttribute): Boolean;
begin
  var lParent := aAtt:Parent;
  if lParent = nil then
    exit false;
  var lIdx := lParent.InpIndex(aAtt);
  result := 0 <= lIdx < lParent.InpCount - 1;
end;

/// <summary>
/// Move attribute 'aAtt' after its next sibling.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
method DexiModel.MoveNext(aAtt: DexiAttribute);
begin
  if CanMoveNext(aAtt) then
    begin
      var lParent := aAtt.Parent;
      var lIdx := lParent.InpIndex(aAtt);
      aAtt.Parent.MoveInputNext(lIdx);
      if lParent.Funct <> nil then
        lParent.Funct.ExchangeArgs(lIdx, lIdx + 1);
    end;
end;

/// <summary>
/// Is it possible to add another child to attribute 'aAtt'?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanAddInputTo(aAtt: DexiAttribute): Boolean;
begin
  result := (aAtt <> nil) and not DexiScale.ScaleIsContinuous(aAtt:Scale) and not DexiAttribute.AttributeIsDiscretization(aAtt);
end;

/// <summary>
/// Returns the list of DexiObjects that are deleted when adding a child to 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.AddInputToDeletes(aAtt: DexiAttribute): DexiObjectStrings;
begin
  result := nil;
  if CanAddInputTo(aAtt) and (aAtt.Funct <> nil) then
    begin
      result := new DexiObjectStrings;
      result.Add(aAtt:Name, aAtt.Funct);
    end;
end;

/// <summary>
/// Add a new child to attribute 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Added DexiAttribute.</returns>
method DexiModel.AddInputTo(aAtt: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if CanAddInputTo(aAtt) then
    begin
      var lAtt := new DexiAttribute(DexiString.SDexiNewAttribute);
      if  DefaultScale <> nil then
        lAtt.Scale := DefaultScale.CopyScale;
      lAtt.CleanAltValues(AltCount);
      aAtt.AddInput(lAtt);
      aAtt.Funct := nil;
      result := lAtt;
    end;
end;

/// <summary>
/// Is it possible to add a new sibling to attribute 'aAtt'?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanAddSibling(aAtt: DexiAttribute): Boolean;
begin
  result := CanAddInputTo(aAtt:Parent);
end;

/// <summary>
/// Returns the list of DexiObjects to be deleted by adding a sibling to 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.AddSiblingDeletes(aAtt: DexiAttribute): DexiObjectStrings;
begin
  result := AddInputToDeletes(aAtt:Parent);
end;

/// <summary>
/// Add a new sibling of attribute 'aAtt'. The new attribute is added as a last child of 'aAtt.Parent'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Neely added sibling DexiAttribute.</returns>
method DexiModel.AddSibling(aAtt: DexiAttribute): DexiAttribute;
begin
  result :=
    if CanAddSibling(aAtt) then AddInputTo(aAtt:Parent)
    else nil;
end;

/// <summary>
/// Is it possible to delete basic attribute 'aAtt'?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanDeleteBasic(aAtt: DexiAttribute): Boolean;
begin
  result := DexiAttribute.AttributeIsBasic(aAtt) and (aAtt.Parent <> nil) and
    ((aAtt.Parent <> Root) or (aAtt.ParentIndex >= 1));
end;

/// <summary>
/// Reurn the list of DexiObjects to be deleted while deleting basic attribute 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.DeleteBasicDeletes(aAtt: DexiAttribute): DexiObjectStrings;
begin
  result := nil;
  if CanDeleteBasic(aAtt) and (aAtt.Parent.Funct <> nil) then
    begin
      result := new DexiObjectStrings;
      result.Add(aAtt:Parent:Name, aAtt.Parent.Funct);
    end;
end;

/// <summary>
/// Delete basic attribute 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Parent DexiAttribute of 'aAtt'.</returns>
method DexiModel.DeleteBasic(aAtt: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if CanDeleteBasic(aAtt) then
    begin
      var lParent := aAtt.Parent;
      lParent.DeleteInput(aAtt);
      if lParent.Funct <> nil then
        lParent.Funct := nil;
      result := lParent;
    end;
end;

/// <summary>
/// Is it possible to delete subtree of aggregate attribute 'aAtt'?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanDeleteSubtree(aAtt: DexiAttribute): Boolean;
begin
  result := DexiAttribute.AttributeIsAggregate(aAtt);
end;

/// <summary>
/// Delete subtree of aggregate attribute 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>'aAtt' or nil if unsuccessful.</returns>
method DexiModel.DeleteSubtree(aAtt: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if CanDeleteSubtree(aAtt) then
    begin
      aAtt.DeleteInputs;
      aAtt.Funct := nil;
      result := aAtt;
    end;
end;

/// <summary>
/// Is it possible to delete'aAtt' and its subtree?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanCutSubtree(aAtt: DexiAttribute): Boolean;
begin
  result := (aAtt <> nil) and (aAtt.Parent <> nil) and (aAtt.Parent <> Root);
end;

/// <summary>
/// Delete attribute 'aAtt' and its subtree, if any.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>'Parent of aAtt' or nil if unsuccessful.</returns>
method DexiModel.CutSubtree(aAtt: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if CanCutSubtree(aAtt) then
    begin
      var lParent := aAtt.Parent;
      lParent.Funct := nil;
      lParent.DeleteInput(aAtt);
      result := lParent;
    end;
end;

/// <summary>
/// Is it possible to duplicate subtree of attributes rooted at 'aAtt'?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Boolean</returns>
method DexiModel.CanDuplicateSubtree(aAtt: DexiAttribute): Boolean;
begin
  result := aAtt <> nil;
end;

/// <summary>
/// Duplicate subtree of attributes rooted at 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>Duplicated root DexiAttribute.</returns>
method DexiModel.DuplicateSubtree(aAtt: DexiAttribute): DexiAttribute;
begin
  result := nil;
  if CanDuplicateSubtree(aAtt) then
    begin
      result := CloneSubtree(aAtt);
      Root.AddInput(result);
    end;
end;

/// <summary>
/// Returns the list of DexiObjects to be deleted by deleting the scale of 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.DeleteScaleDeletes(aAtt: DexiAttribute): DexiObjectStrings;
begin
  result := nil;
  var lFunct := aAtt:Funct;
  var lParentFunct := aAtt:Parent:Funct;
  if (lFunct <> nil) or (lParentFunct <> nil) then
    begin
      result := new DexiObjectStrings;
      if lFunct <> nil then
        result.Add(aAtt:Name, lFunct);
      if (lParentFunct <> nil) and (lParentFunct <> lFunct) then
        result.Add(aAtt:Parent:Name, lParentFunct);
    end;
end;

/// <summary>
/// Returns the list of DexiObjects to be affected by reversing the scale of 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.ReverseScaleAffects(aAtt: DexiAttribute): DexiObjectStrings;
begin
  result := DeleteScaleDeletes(aAtt);
end;

/// <summary>
/// Returns the list of DexiObjects to be affected by editing the scale of 'aAtt'.
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <returns>DexiObjectStrings</returns>
method DexiModel.EditScaleAffects(aAtt: DexiAttribute): DexiObjectStrings;
begin
  result := nil;
  var lFunct := aAtt:Funct;
  var lParentFunct := aAtt:Parent:Funct;
  if (lFunct <> nil) or (lParentFunct <> nil) then
    begin
      result := new DexiObjectStrings;
      if (lFunct <> nil) and (lFunct is DexiTabularFunction) then
        result.Add(aAtt:Name, lFunct);
      if (lParentFunct <> nil) and (lParentFunct <> lFunct) and (lParentFunct is DexiTabularFunction) then
        result.Add(aAtt:Parent:Name, lParentFunct);
      if result.Count = 0 then
        result := nil;
    end;
end;

/// <summary>
/// Is it possible to add a new category to discrete scale 'aScl' of attribute 'aAtt'?
/// </summary>
/// <param name="aAtt">DexiAttribute</param>
/// <param name="aScl">DexiDiscreteScale</param>
/// <param name="aFnc">DexiTabularFunction that might be affected by the change.</param>
/// <returns>Boolean</returns>
method DexiModel.CanAddValue(aAtt: DexiAttribute; aScl: DexiDiscreteScale; aFnc: DexiTabularFunction): Boolean;
begin
  result := false;
  if (aScl = nil) or (aScl.Count >= DexiDiscreteScale.ValuesLimit) then
    exit;
  if aFnc <> nil then
    if (aFnc.Count / aScl.Count * (aScl.Count + 1)) > DexiTabularFunction.SpaceSizeLimit then
      exit;
  result := true;
end;

/// <summary>
/// Is it possible to delete one (any) category from discrete scale 'aScl'?
/// </summary>
/// <param name="aScl">DexiDiscreteScale</param>
/// <returns>Boolean</returns>
method DexiModel.CanDeleteValue(aScl: DexiDiscreteScale): Boolean;
begin
  result := (aScl <> nil) and (aScl.Count > 2);
end;

/// <summary>
/// Check the correctness of model structure.
/// </summary>
/// <returns>DexiObjectStrings, containing found inconsistencies and errors.</returns>
method DexiModel.CheckModelStructure: DexiObjectStrings;
var
  lErrors := new DexiObjectStrings;
  lVisited  := new DexiObjectList;

  method CheckAttribute(aAtt, aParent: DexiAttribute);
  begin
    if aAtt = nil then
      begin
        lErrors.Add('Null attribute', nil);
        exit;
      end;
    if lVisited.Contains(aAtt) then
      begin
        lErrors.Add('Duplicate ' + aAtt.Name, aAtt);
        exit;
      end;
    if aAtt.Parent <> aParent then
      lErrors.Add($'Parent of {aAtt:Name} is {aAtt:Parent:Name}, not {aParent:Name}', aAtt);
    if DexiScale.ScaleIsContinuous(aAtt:Scale) and not aAtt.IsBasic then
        lErrors.Add($'Continuous scale at {aAtt:Name}', aAtt);
    lVisited.Add(aAtt);
    for i := 0 to aAtt.InpCount - 1 do
      CheckAttribute(aAtt.Inputs[i], aAtt);
  end;

begin
  CheckAttribute(Root, nil);
  if lErrors.Count = 0 then
    lErrors := nil;
  exit lErrors;
end;

/// <summary>
/// Assign unique IDs to all attributes in this DexiModel.
/// IDs are based on attribute names. All non-alphanumeric characters are replaced with '_'.
/// Extensions of the form "_#", where # is an Integer, may be appended to ensure the
/// uniqueness of IDs within this DexiModel.
/// </summary>
/// <param name="aCaseSensitive">Whether or not IDs should be case-sensitive (default false).</param>
method DexiModel.MakeUniqueAttributeIDs(aCaseSensitive: Boolean := false);

  method MakeIdKey(aStr: String): String;
  begin
    result := if aCaseSensitive then aStr else aStr:ToUpper;
  end;

begin
  var lAttIDs := new Dictionary<String, DexiAttribute>;
  var lAttributes := Root.CollectInputs;
  for each lAtt in lAttributes do
    begin
      var lAttID :=
        if String.IsNullOrEmpty(lAtt.ID) then Utils.IdString(lAtt.Name)
        else lAtt.ID;
      var lID := lAttID;
      var lIDkey := MakeIdKey(lID);
      var lIdx := 0;
      while lAttIDs.ContainsKey(lIDkey) do
        begin
          inc(lIdx);
          lID := lAttID + '_' + Utils.IntToStr(lIdx);
          lIDkey := MakeIdKey(lID);
        end;
      lAttIDs.Add(lIDkey, lAtt);
      lAtt.ID := lID;
    end;
end;

/// <summary>
/// Ensure the uniqueness of alternative names in this DexiModel.
/// Extensions of the form "_#", where # is an Integer, are appended to previously
/// non-unique names.
/// </summary>
/// <param name="aCaseSensitive">Whether or not names should be case-sensitive (default false).</param>
method DexiModel.MakeUniqueAlternativeNames(aCaseSensitive: Boolean := false);
begin
  var lAltNames := new List<String>;
  for lAlt := 0 to AltCount - 1 do
    begin
      var lNewName := AltNames[lAlt].Name;
      var lIdx := lAlt;
      while Utils.ListContains(lAltNames, lNewName, aCaseSensitive) do
        begin
          lNewName := AltNames[lAlt].Name + '_' +  Utils.IntToStr(lIdx);
          inc(lIdx);
        end;
      lAltNames.Add(lNewName);
    end;
  for lAlt := 0 to AltCount - 1 do
    if AltNames[lAlt].Name <> lAltNames[lAlt] then
      begin
        AltNames[lAlt].Name := lAltNames[lAlt];
        fModified := true;
      end;
end;

/// <summary>
/// Migrate reports from old DEXi to DEXiLibrary 2023 ones.
/// </summary>
method DexiModel.MigrateReports;
begin
  if fReports = nil then
    CreateStandardReports;
end;

method DexiModel.ReportFormat: DexiReportFormat;
begin
  result := new DexiReportFormat;
  result.FileName := FileName;
end;

method DexiModel.NewModelReport: DexiModelReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiModelReport(DexiString.RModDesc, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[0];
end;

method DexiModel.NewStatisticsReport: DexiStatisticsReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiStatisticsReport(DexiString.RModStat, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[0];
end;

method DexiModel.NewAttributeTreeReport: DexiTreeReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, nil, -1, [DexiReport.ColDescr, DexiReport.ColScale, DexiReport.ColFunct]);
  result := new DexiTreeAttributeReport(DexiString.RTree, lParameters, lFormat);
end;

method DexiModel.NewAttributeDescriptionReport: DexiTreeAttributeReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, nil, -1, [DexiReport.ColDescr]);
  result := new DexiTreeAttributeReport(DexiString.RAttDescription, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[1];
end;

method DexiModel.NewAttributeScaleReport: DexiTreeAttributeReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, nil, -1, [DexiReport.ColScale]);
  result := new DexiTreeAttributeReport(DexiString.RAttScales, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[2];
end;

method DexiModel.NewAttributeFunctionSummaryReport: DexiTreeAttributeReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, nil, -1, [DexiReport.ColFunct]);
  result := new DexiTreeAttributeReport(DexiString.RAttFncSummary, lParameters, lFormat);
end;

method DexiModel.NewAttributeFunctionReport: DexiFunctionsReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiFunctionsReport(DexiString.RAttFncInformation, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[4];
end;

method DexiModel.NewWeightsReport: DexiWeightsReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiWeightsReport(DexiString.RWeightsTree, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[6];
end;

method DexiModel.NewAttributeReport: DexiAttributeReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiAttributeReport(DexiString.RAttInformation, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[3] or Settings.SelectedReport[5];
end;

method DexiModel.NewAlternativesReport: DexiTreeAlternativesReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  lParameters.Columns := lParameters.SelectedColumns;
  result := new DexiTreeAlternativesReport(DexiString.RAlternatives, lParameters, lFormat);
end;

method DexiModel.NewEvaluationReport: DexiTreeEvaluationReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  lParameters.Columns := lParameters.SelectedColumns;
  result := new DexiTreeEvaluationReport(DexiString.REvaluationResults, lParameters, lFormat);
  result.Selected := Settings.SelectedReport[7];
end;

method DexiModel.NewFunctionReport(aAtt: DexiAttribute; aFunct: DexiFunction := nil): DexiSingleFunctionReport;
require
  aAtt <> nil;
  (aFunct <> nil) or (aAtt.Funct <> nil);
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, aAtt);
  lParameters.SelectAttribute(aAtt);
  lParameters.Funct :=
    if aFunct = nil then aAtt.Funct
    else aFunct;
  lParameters.AttName := false;
  lParameters.AttDescription := false;
  lParameters.AttScale := false;
  lParameters.AttFunction := true;
  lParameters.MakeTitle := false;
  result := new DexiSingleFunctionReport(String.Format(DexiString.RFunctionWithName, aAtt.Name), lParameters, lFormat);
end;

method DexiModel.NewComparisonReport(aAlt: Integer): DexiAlternativeComparisonReport;
require
  0 <= aAlt < AltCount;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, nil, aAlt);
  result := new DexiAlternativeComparisonReport(DexiString.RAltCompare, lParameters, lFormat);
end;

method DexiModel.NewSelectiveExplanationReport: DexiSelectiveExplanationReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiSelectiveExplanationReport(DexiString.RSelectiveExplanation, lParameters, lFormat);
end;

method DexiModel.NewPlusMinusReport(aAtt: DexiAttribute; aAlt: Integer): DexiPlusMinusReport;
require
  DexiPlusMinusReport.ValidAttribute(aAtt);
  0 <= aAlt < AltCount;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, aAtt, aAlt);
  result := new DexiPlusMinusReport(DexiString.RPlusMinus, lParameters, lFormat);
end;

method DexiModel.NewTargetReport(aAtt: DexiAttribute; aAlt: Integer): DexiTargetReport;
require
  DexiTargetReport.ValidAttribute(aAtt);
  0 <= aAlt < AltCount;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self, aAtt, aAlt);
  result := new DexiTargetReport(DexiString.RTarget, lParameters, lFormat);
end;

method DexiModel.NewEvaluateQQReport: DexiTreeQQEvaluationReport;
begin
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  result := new DexiTreeQQEvaluationReport(DexiString.RQQEvaluationResults, lParameters, lFormat);
end;

method DexiModel.CreateStandardReports;
begin
  fReports := new List<DexiReportGroup>;
  var lFormat := ReportFormat;
  var lParameters := new DexiReportParameters(self);
  var lReports := new DexiReportGroup(DexiString.RReport, lParameters, lFormat);
  lReports.AddReport(NewModelReport);
  lReports.AddReport(NewStatisticsReport);
  lReports.AddReport(NewAttributeDescriptionReport);
  lReports.AddReport(NewAttributeScaleReport);
  lReports.AddReport(NewAttributeFunctionSummaryReport);
  lReports.AddReport(NewWeightsReport);
  lReports.AddReport(NewAttributeReport);
  lReports.AddReport(NewAlternativesReport);
  lReports.AddReport(NewEvaluationReport);
  fReports.Add(lReports);
end;

method DexiModel.ReportIsPrimary(aRpt: DexiReport): Boolean;
begin
  result := (aRpt is DexiReportGroup) and (RptCount > 0) and (fReports[0] = aRpt);
end;

{$ENDREGION}

end.
