// DexiReports.pas is part of
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
// DexiReports.pas implements specific DEXi reports. In addition to the DexiReportFormat class, which
// defines parameters that control the formatting of reports, the report-related classes are:
// - DexiReport: basic abstract class that provides some common properties and methods,
//   but no specific report contents.
// - DexiModelReport: report for presenting top-level DexiModel information.
// - DexiStatisticsReport: report for presenting model statistic.
// - DexiAttributeReport: general report type for presenting a sequence of attributes
//   with associated information.
// - DexiSingleFunctionReport: specialization of 'DexiAttributeReport' for presenting a single
//   aggregation function.
// - DexiTreeReport: general report type for presenting information in the form of an indented tree.
// - DexiTreeAttributeReport: specialization of 'DexiTreeReport' for presenting attribute information.
// - DexiTreeAlternativesReport: specialization of 'DexiTreeReport' for presenting alternatives.
// - DexiTreeQQEvaluationReport: specialization of 'DexiTreeReport' for presenting Qualitative-Quantitative evaluations.
// - DexiTreeEvaluationReport: specialization of 'DexiTreeReport' for presenting evaluation results.
// - DexiFunctionsReport: report for presenting function summaries in a tabular form.
// - DexiWeightsReport: report for presenting a table of weights (local, global + normalized).
// - DexiSelectiveExplanationReport: report for presenting results of selective explanation.
// - DexiAlternativeComparisonReport: report for comparing two or more alternatives.
// - DexiPlusMinusReport: report for presenting results of plus-minus analysis.
// - DexiTargetReport: report for presenting results of target analysis (option generator).
// - DexiChartReport: report displaying some chart.
// - DexiReportGroup: report consisting of a sequence of other report types.
// ----------

namespace DexiLibrary;

interface

uses
  DexiUtils,
  RemObjects.Elements.RTL;

type
  DexiReportFormat = public class
  private
    fSoftware: String;
    fFileName: String;
    fFormatHead: RptFormatSettings;
    fFormatSection: RptFormatSettings;
    fFormatTableHead: RptFormatSettings;
    fFormatAttLink: RptFormatSettings;
    fFormatAttBasic: RptFormatSettings;
    fFormatAttAggregate: RptFormatSettings;
    fFontName: String;
    fFontSize: Float;
  public
    constructor (aModel: DexiModel := nil);
    constructor (aFormat: DexiReportFormat; aModel: DexiModel := nil);
    property Software: String read fSoftware write fSoftware;
    property FileName: String read fFileName write fFileName;
    property FormatHead: RptFormatSettings read fFormatHead write fFormatHead;
    property FormatSection: RptFormatSettings read fFormatSection write fFormatSection;
    property FormatTableHead: RptFormatSettings read fFormatTableHead write fFormatTableHead;
    property FormatAttLink: RptFormatSettings read fFormatAttLink write fFormatAttLink;
    property FormatAttBasic: RptFormatSettings read fFormatAttBasic write fFormatAttBasic;
    property FormatAttAggregate: RptFormatSettings read fFormatAttAggregate write fFormatAttAggregate;
    property FontName: String read fFontName write fFontName;
    property FontSize: Float read fFontSize write fFontSize;
  end;

type
  DexiRptFunctionRepresentation = public enum (Elementary, Complex, DecisionTree);

type
  DexiReportParameters = public class (DexiSelection)
  private
    fModel: weak DexiModel;
    fRoot: weak DexiAttribute;
    fAlternative: Integer;
    fFunct: DexiFunction;
    fColumns: IntArray;
    fWeiDecimals: Integer;
    fMemDecimals: Integer;
    fDefDetDecimals: Integer;
    fFltDecimals: Integer;
    fAttName: Boolean;
    fAttDescription: Boolean;
    fAttScale: Boolean;
    fAttFunction: Boolean;
    fFncShowWeights: Boolean;
    fFncShowNumbers: Boolean;
    fFncShowNumericValues: Boolean;
    fFncShowMarginals: Boolean;
    fFncEnteredOnly: Boolean;
    fFncStatus: Boolean;
    fRepresentation: DexiRptFunctionRepresentation;
    fWeightsLocal: Boolean;
    fWeightsGlobal: Boolean;
    fWeightsLocalNormalized: Boolean;
    fWeightsGlobalNormalized: Boolean;
    fMaxColumns: Integer;
    fEvalTrim: Integer;
    fUseNormalizedWeights: Boolean;
    fDeepCompare: Boolean;
    fMinusSteps: Integer;
    fPlusSteps: Integer;
    fImprove: Boolean;
    fUnidirectional: Boolean;
    fMaxSteps: Integer;
    fMaxGenerate: Integer;
    fMaxShow: Integer;
    fMakeTitle: Boolean;
  protected
    method GetSelectedColumns: IntArray;
  public
    constructor (aModel: DexiModel; aRoot: DexiAttribute := nil; aAlternative: Integer := -1; aColumns: IntArray := nil);
    constructor (aParameters: DexiReportParameters);
    method UpdateFromSettings(aSettings: DexiSettings := nil);
    method CollectUndoableObjects(aList: List<IUndoable>); override;
    method AddAlternative(aAlt: Integer); override;
    method DeleteAlternative(aAlt: Integer); override;
    method MoveAlternative(aFrom, aTo: Integer); override;
    method MoveAlternativePrev(aAlt: Integer); override;
    method MoveAlternativeNext(aAlt: Integer); override;
    method ExchangeAlternatives(aIdx1, aIdx2: Integer); override;
    property Model: DexiModel read fModel write fModel;
    property Root: DexiAttribute read fRoot write fRoot;
    property Funct: DexiFunction read fFunct write fFunct;
    property Alternative: Integer read fAlternative write fAlternative;
    property SelectedColumns: IntArray read GetSelectedColumns;
    property Columns: IntArray read fColumns write fColumns;
    property WeiDecimals: Integer read fWeiDecimals write fWeiDecimals;
    property MemDecimals: Integer read fMemDecimals write fMemDecimals;
    property DefDetDecimals: Integer read fDefDetDecimals write fDefDetDecimals;
    property FltDecimals: Integer read fFltDecimals write fFltDecimals;
    property AttName: Boolean read fAttName write fAttName;
    property AttDescription: Boolean read fAttDescription write fAttDescription;
    property AttScale: Boolean read fAttScale write fAttScale;
    property AttFunction: Boolean read fAttFunction write fAttFunction;
    property FncShowWeights: Boolean read fFncShowWeights write fFncShowWeights;
    property FncShowNumbers: Boolean read fFncShowNumbers write fFncShowNumbers;
    property FncShowNumericValues: Boolean read fFncShowNumericValues write fFncShowNumericValues;
    property FncShowMarginals: Boolean read fFncShowMarginals write fFncShowMarginals;
    property FncEnteredOnly: Boolean read fFncEnteredOnly write fFncEnteredOnly;
    property FncStatus: Boolean read fFncStatus write fFncStatus;
    property Representation: DexiRptFunctionRepresentation read fRepresentation write fRepresentation;
    property WeightsLocal: Boolean read fWeightsLocal write fWeightsLocal;
    property WeightsGlobal: Boolean read fWeightsGlobal write fWeightsGlobal;
    property WeightsLocalNormalized: Boolean read fWeightsLocalNormalized write fWeightsLocalNormalized;
    property WeightsGlobalNormalized: Boolean read fWeightsGlobalNormalized write fWeightsGlobalNormalized;
    property MaxColumns: Integer read fMaxColumns write fMaxColumns;
    property EvalTrim: Integer read fEvalTrim write fEvalTrim;
    property UseNormalizedWeights: Boolean read fUseNormalizedWeights write fUseNormalizedWeights;
    property MinusSteps: Integer read fMinusSteps write fMinusSteps;
    property DeepCompare: Boolean read fDeepCompare write fDeepCompare;
    property PlusSteps: Integer read fPlusSteps write fPlusSteps;
    property Improve: Boolean read fImprove write fImprove;
    property Unidirectional: Boolean read fUnidirectional write fUnidirectional;
    property MaxSteps: Integer read fMaxSteps write fMaxSteps;
    property MaxGenerate: Integer read fMaxGenerate write fMaxGenerate;
    property MaxShow: Integer read fMaxShow write fMaxShow;
    property MakeTitle: Boolean read fMakeTitle write fMakeTitle;
  end;

type
  DexiReport = public abstract class (IUndoable)
  private
    fReport: RptReport;
    fSelected: Boolean;
    fParameters: DexiReportParameters;
    fFormat: DexiReportFormat;
    fTreeParents: Dictionary<DexiAttribute, RptTreeParent>;
  protected
    method GetReportType: String; virtual; abstract;
    method GetNeedsRoot: Boolean; virtual;
    method SetFormat(aFormat: DexiReportFormat); virtual;
    method SetParameters(aParameters: DexiReportParameters); virtual;
    method GetChartParameters: DexiChartParameters; virtual;
    method SetChartParameters(aParameters: DexiChartParameters); virtual;
    method SetSelected(aSelected: Boolean); virtual;
    method AdaptSelectedAttributes(aAttList: DexiAttributeList): Boolean; virtual;
    method SetTitle(aTitle: String); virtual;
    method TruePos(aBools: array of Boolean): Integer;
    method BeginReport(aClear: Boolean := true);
    method ClearParents;
    method PrepareColumns(aColumns: IntArray; aAltOnly: Boolean): IntArray;
    method PrepareColumns(aColumns: IntArray; aExcludeAlt: Integer): IntArray;
    method Rooted(aRoot: DexiAttribute): ImmutableList<DexiAttribute>;
    method ReportHeader: RptVerticalGroup;
    method NewReport: RptReport; virtual;
    method AttFormat(aAtt: DexiAttribute): RptFormatSettings;
    method WrTreeAttribute(aCell: RptCell; aAtt: DexiAttribute; aIncludeIndent: Boolean := true; aUseParents: Boolean := true);
    method WrName(aSection: RptSection; aObj: DexiObject; aObjectIntro: String := nil; aFormat: RptFormatSettings := nil);
    method WrDescription(aSection: RptSection; aObj: DexiObject);
    method WrNameAndDescription(
      aSection: RptSection; aObj: DexiObject; aObjectIntro: String := nil; aFormat: RptFormatSettings := nil);
    method WrScale(aSection: RptSection; aAtt: DexiAttribute);
    method WrFunction(aSection: RptSection; aAtt: DexiAttribute; aFunct: DexiFunction := nil);
    method WrTabularFunction(aSection: RptSection; aAtt: DexiAttribute; aFunct: DexiFunction := nil);
    method WrFunctionStatus(aSection: RptSection; aAtt: DexiAttribute);
    method WrFunctionMarginals(aSection: RptSection; aAtt: DexiAttribute);
    method WrDiscretizeFunction(aSection: RptSection; aAtt: DexiAttribute; aFunct: DexiFunction := nil);
    fScaleStrings := new DexiScaleStrings;
  public
    class const ColDescr = -1;
    class const ColScale = -2;
    class const ColFunct = -3;
    class const ColBreak = low(Integer);
    class method NewReport(aType: String; aParameters: DexiReportParameters; aChartParameters: DexiChartParameters; aFormat: DexiReportFormat): DexiReport;
    class method BreakColumns(aColumns: IntArray; aMaxColumns: Integer): List<IntArray>;
    constructor (aParameters: DexiReportParameters; aFormat: DexiReportFormat := nil);
    constructor (aTitle: String; aParameters: DexiReportParameters; aFormat: DexiReportFormat := nil);
    property Selected: Boolean read fSelected write SetSelected;
    property Report: RptReport read fReport;
    property ReportType: String read GetReportType;
    property NeedsRoot: Boolean read GetNeedsRoot;
    property Parameters: DexiReportParameters read fParameters write SetParameters;
    property Format: DexiReportFormat read fFormat write SetFormat;
    property ChartParameters: DexiChartParameters read GetChartParameters write SetChartParameters;
    property Title: String read fReport:Title write SetTitle;
    property Model: DexiModel read fParameters:Model;
    property Software: String read fFormat:Software;
    property FileName: String read fFormat:FileName;
    property FormatHead: RptFormatSettings read fFormat.FormatHead;
    property FormatSection: RptFormatSettings read fFormat.FormatSection;
    property FormatTableHead: RptFormatSettings read fFormat.FormatTableHead;
    method &Copy: DexiReport; virtual;
    method AdaptToAttributes(aAttList: DexiAttributeList): Boolean; virtual;
    method SettingsChanged; virtual;
    method MakeReport(aClear: Boolean := true); virtual; abstract;

    // IUndoable
    method CollectUndoableObjects(aList: List<IUndoable>); virtual;
    method EqualStateAs(aObj: IUndoable): Boolean; virtual;
    method GetUndoState: IUndoable; virtual;
    method SetUndoState(aState: IUndoable); virtual;
  end;

type
  DexiModelReport = public class (DexiReport)
  protected
    method GetReportType: String; override;
  public
    method MakeReport(aClear: Boolean := true); override;
  end;

type
  DexiStatisticsReport = public class (DexiReport)
  protected
    method GetReportType: String; override;
  public
    method MakeReport(aClear: Boolean := true); override;
  end;

type
  DexiAttributeReport = public class (DexiReport)
  private
  protected
    method GetReportType: String; override;
    method MakeTitle: String;
    method TabAtt(aSection: RptSection; aAtt: DexiAttribute);
  public
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters:Root write Parameters.Root;
  end;

type
  DexiSingleFunctionReport = public class (DexiAttributeReport)
  protected
    method GetReportType: String; override;
  end;

type
  DexiTreeReport = public class (DexiReport)
  private
  protected
    fIncludeTreeIndent := true;
    method GetReportType: String; override;
    method AttributeRestricted(aAtt: DexiAttribute): Boolean; virtual;
    method MakeTitle(aColumns: IntArray): String; virtual;
    method TabColumns(aTable: RptTable; aColumns: IntArray);
    method TabHead(aTable: RptTable; aColumns: IntArray);
    method TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute); virtual;
    method AttributeList(aRoot: DexiAttribute): ImmutableList<DexiAttribute>; virtual;
  public
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters:Root write Parameters.Root;
    property Columns: IntArray read Parameters:Columns write Parameters.Columns;
  end;

type
  DexiTreeAttributeReport = public class (DexiTreeReport)
  protected
    method GetReportType: String; override;
  end;

type
  DexiTreeAlternativesReport = public class (DexiTreeReport)
  protected
    method GetReportType: String; override;
    method AttributeRestricted(aAtt: DexiAttribute): Boolean; override;
    method AttributeList(aRoot: DexiAttribute): ImmutableList<DexiAttribute>; override;
  public
    method MakeReport(aClear: Boolean := true); override;
  end;

type
  DexiTreeEvaluationReport = public class (DexiTreeReport)
  protected
    method GetReportType: String; override;
  end;

type
  DexiTreeQQEvaluationReport = public class (DexiTreeReport)
  private
    fAlternatives: List<DexiOffAlternative>;
  protected
    method GetReportType: String; override;
    method AttributeRestricted(aAtt: DexiAttribute): Boolean; override;
    method MakeTitle(aColumns: IntArray): String; override;
    method TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute); override;
  public
    method MakeReport(aClear: Boolean := true); override;
    property Alternatives: ImmutableList<DexiOffAlternative> read fAlternatives;
  end;

type
  DexiFunctionsReport = public class (DexiReport)
  protected
    method GetReportType: String; override;
    method TabColumns(aTable: RptTable);
    method TabHead(aTable: RptTable);
    method TabAtt(aTable: RptTable; aAtt: DexiAttribute);
  public
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters:Root write Parameters.Root;
  end;

type
  DexiWeightsReport = public class (DexiReport)
  protected
    method GetReportType: String; override;
    method TabColumns(aTable: RptTable);
    method TabHead(aTable: RptTable);
    method TabAtt(aTable: RptTable; aAtt: DexiAttribute; aWA, aWN: Float);
    method CalcWeights(aAtt: DexiAttribute);
  public
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters:Root write Parameters.Root;
  end;

type
  DexiSelectiveExplanationReport = public class (DexiReport)
  protected
    method GetReportType: String; override;
    method TabColumns(aTable: RptTable);
    method TabHead(aTable: RptTable; aAlt: Integer);
    method TabAtt(aTable: RptTable; aAtt: DexiAttribute; aAlt: Integer);
    method CollectAttributes(aAtt: DexiAttribute; aAlt: Integer; aList: DexiAttributeList; aGood: Boolean);
    method Selective(aSection: RptSection; aAlt: Integer; aGood: Boolean; aHead: String);
  public
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters.Root write Parameters.Root;
  end;

type
  DexiAlternativeComparisonReport = public class (DexiReport)
  private
    fDeepComparisons: List<Dictionary<DexiAttribute, DeepComparison>>;
  protected
    method GetReportType: String; override;
    method TabColumns(aTable: RptTable; aColumns: IntArray);
    method TabHead(aTable: RptTable; aColumns: IntArray);
    method TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute);
    method CompareString(aCompare: DeepComparison): String;
    method MakeComparisons(aColumns: IntArray);
  public
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters.Root write Parameters.Root;
    property Alternative: Integer read Parameters.Alternative write Parameters.Alternative;
  end;

type
  DexiPlusMinusReport = public class (DexiReport)
  protected
    method GetReportType: String; override;
    method GetNeedsRoot: Boolean; override;
    method TabColumns(aTable: RptTable; aRange: IntArray);
    method TabHead(aTable: RptTable; aRange: IntArray);
    method TabRoot(aTable: RptTable; aRange: IntArray);
    method TabAtt(aTable: RptTable; aRange: IntArray; aColumns: List<IDexiAlternative>; aAtt: DexiAttribute);
  public
    class method ValidAttribute(aAtt: DexiAttribute): Boolean;
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters.Root write Parameters.Root;
    property Alternative: Integer read Parameters.Alternative write Parameters.Alternative;
  end;

type
  DexiTargetReport = public class (DexiReport)
  private
    fEmitCount: Int64;
    fPruned: DexiAttributeList;
    fConstants: DexiAttributeList;
    fGenerated: DexiAlternatives;
  protected
    method GetReportType: String; override;
    method GetNeedsRoot: Boolean; override;
    method OnEmitCheck(aAssignment: IntArray; aFound: List<IntArray>): DexiGenCheck;
    method PrepareAttributeLists;
    method Generate: DexiAlternatives;
    method TabColumns(aTable: RptTable; aColumns: IntArray);
    method TabHead(aTable: RptTable; aColumns: IntArray);
    method TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute);
  public
    class method ValidAttribute(aAtt: DexiAttribute): Boolean;
    method MakeReport(aClear: Boolean := true); override;
    property Root: DexiAttribute read Parameters:Root write Parameters.Root;
  end;

type
  ChartImageMaker = public method (Model: DexiModel; aParameters: DexiChartParameters; aWidth, aHeight: Integer): IRptImage;

type
  DexiChartReport = public class (DexiReport)
  private
    fChartParameters: DexiChartParameters;
    fWidth: Integer;
    fHeight: Integer;
    fAutoScale: Boolean;
    fMakeImage: ChartImageMaker;
  protected
    method GetChartParameters: DexiChartParameters; override;
    method SetChartParameters(aParameters: DexiChartParameters); override;
    method GetReportType: String; override;
    method AdaptSelectedAttributes(aAttList: DexiAttributeList): Boolean; override;
  public
    method MakeReport(aClear: Boolean := true); override;
    method &Copy: DexiReport; override;
    property Width: Integer read fWidth write fWidth;
    property Height: Integer read fHeight write fHeight;
    property MakeImage: ChartImageMaker read fMakeImage write fMakeImage;
    property AutoScale: Boolean read fAutoScale write fAutoScale;
  end;

type
  DexiReportGroup = public class (DexiReport)
  private
    fReports: List<DexiReport>;
  protected
    method GetReportType: String; override;
    method SetFormat(aFormat: DexiReportFormat); override;
    method GetRptCount: Integer;
    method GetReport(aIdx: Integer): DexiReport;
  public
    property RptCount: Integer read GetRptCount;
    property Report[aIdx: Integer]: DexiReport read GetReport; default;
    property Reports: ImmutableList<DexiReport> read fReports;
    method ReportIndex(aRpt: DexiReport): Integer;
    method AddReport(aRpt: DexiReport);
    method InsertReport(aIdx: Integer; aRpt: DexiReport);
    method RemoveReport(aRpt: DexiReport);
    method RemoveReport(aIdx: Integer): DexiReport;
    method MoveReport(aFrom, aTo: Integer);
    method MoveReport(aRpt: DexiReport; aTo: Integer);
    method MoveReportPrev(aRpt: DexiReport);
    method MoveReportPrev(aIdx: Integer);
    method MoveReportNext(aRpt: DexiReport);
    method MoveReportNext(aIdx: Integer);
    method AddAlternative(aAlt: Integer);
    method DeleteAlternative(aAlt: Integer);
    method MoveAlternative(aFrom, aTo: Integer);
    method MoveAlternativePrev(aAlt: Integer);
    method MoveAlternativeNext(aAlt: Integer);
    method ExchangeAlternatives(aIdx1, aIdx2: Integer);
    method UpdateAttributeSelection;
    method SettingsChanged; override;
    method MakeReport(aClear: Boolean := true); override;

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

{$REGION DexiReportFormat}

constructor DexiReportFormat(aModel: DexiModel := nil);
begin
  inherited constructor;
  fSoftware := DexiString.DexSoftware;
  fFileName := if aModel = nil then '' else aModel.FileName;
  fFormatHead := new RptFormatSettings(Bold := true, SizeFactor := 1.2);
  fFormatSection := new RptFormatSettings(Bold := true, SizeFactor := 1.1);
  fFormatTableHead := new RptFormatSettings(Bold := true);
  fFormatAttLink := new RptFormatSettings(Bold := true, Italic := true);
  fFormatAttBasic := new RptFormatSettings;
  fFormatAttAggregate := new RptFormatSettings(Bold := true);
  fFontName := nil;
  fFontSize := 0.0;
end;

constructor DexiReportFormat(aFormat: DexiReportFormat; aModel: DexiModel := nil);
begin
  constructor (aModel);
  if aFormat = nil then
    exit;
  fSoftware := aFormat.Software;
  fFileName := aFormat.FileName;
  fFormatHead := aFormat.FormatHead;
  fFormatSection := aFormat.FormatSection;
  fFormatTableHead := aFormat.FormatTableHead;
  fFormatAttLink := aFormat.FormatAttLink;
  fFormatAttBasic := aFormat.FormatAttBasic;
  fFormatAttAggregate := aFormat.FormatAttAggregate;
  fFontName := aFormat.FontName;
  fFontSize := aFormat.FontSize;
end;

{$ENDREGION}

{$REGION DexiReportParameters}

constructor DexiReportParameters(aModel: DexiModel; aRoot: DexiAttribute := nil; aAlternative: Integer := -1; aColumns: IntArray := nil);
require
  aModel <> nil;
begin
  inherited constructor;
  fModel := aModel;
  fRoot := aRoot;
  fFunct := nil;
  fAlternative := aAlternative;
  fColumns := aColumns;
  UpdateFromSettings(fModel:Settings);
  fSelectedAttributes := nil;
  fSelectedAlternatives := nil;
  fAttName := true;
  fAttDescription := true;
  fAttScale := true;
  fAttFunction := true;
  fDeepCompare := true;
  fMinusSteps := 1;
  fPlusSteps := 1;
  fImprove := true;
  fUnidirectional := true;
  fMaxSteps := 1;
  fMaxGenerate := 500;
  fMaxShow := 10;
  fMakeTitle := true;
end;

constructor DexiReportParameters(aParameters: DexiReportParameters);
require
  aParameters <> nil;
begin
  inherited constructor;
  fModel := aParameters.Model;
  fRoot := aParameters.Root;
  fFunct := aParameters.Funct;
  fAlternative := aParameters.Alternative;
  fSelectedAttributes :=
    if aParameters.SelectedAttributes = nil then nil
    else new List<DexiAttribute>(aParameters.SelectedAttributes);
  fSelectedAlternatives :=
    if aParameters.SelectedAlternatives = nil then nil
    else new SetOfInt(aParameters.SelectedAlternatives);
  fColumns := Utils.CopyIntArray(aParameters.Columns);
  fWeiDecimals := aParameters.WeiDecimals;
  fMemDecimals := aParameters.MemDecimals;
  fDefDetDecimals := aParameters.DefDetDecimals;
  fFltDecimals := aParameters.FltDecimals;
  fAttName := aParameters.AttName;
  fAttDescription := aParameters.AttDescription;
  fAttScale := aParameters.AttScale;
  fAttFunction := aParameters.AttFunction;
  fFncShowWeights := aParameters.FncShowWeights;
  fFncShowNumbers := aParameters.FncShowNumbers;
  fFncShowNumericValues := aParameters.FncShowNumericValues;
  fFncShowMarginals := aParameters.FncShowMarginals;
  fFncEnteredOnly := aParameters.FncEnteredOnly;
  fFncStatus := aParameters.FncStatus;
  fRepresentation := aParameters.Representation;
  fWeightsLocal:= aParameters.WeightsLocal;
  fWeightsGlobal:= aParameters.WeightsGlobal;
  fWeightsLocalNormalized:= aParameters.WeightsLocalNormalized;
  fWeightsGlobalNormalized:= aParameters.WeightsGlobalNormalized;
  fMaxColumns := aParameters.MaxColumns;
  fEvalTrim := aParameters.EvalTrim;
  fUseNormalizedWeights := aParameters.UseNormalizedWeights;
  fDeepCompare := aParameters.DeepCompare;
  fMinusSteps := aParameters.MinusSteps;
  fPlusSteps := aParameters.PlusSteps;
  fImprove := aParameters.Improve;
  fUnidirectional := aParameters.Unidirectional;
  fMaxSteps := aParameters.MaxSteps;
  fMaxGenerate := aParameters.MaxGenerate;
  fMaxShow := aParameters.MaxShow;
  fMakeTitle := aParameters.MakeTitle;
end;

method DexiReportParameters.UpdateFromSettings(aSettings: DexiSettings := nil);
begin
  if aSettings = nil then
    aSettings := fModel:Settings;
  if aSettings = nil then
    exit;
  fRepresentation := aSettings.Representation;
  fWeiDecimals := aSettings.WeiDecimals;
  fMemDecimals := aSettings.MemDecimals;
  fDefDetDecimals := aSettings.DefDetDecimals;
  fFltDecimals := aSettings.FltDecimals;
  fFncShowWeights := aSettings.FncShowWeights;
  fFncShowNumbers := aSettings.FncShowNumbers;
  fFncShowNumericValues := aSettings.FncShowNumericValues;
  fFncShowMarginals := aSettings.FncShowMarginals;
  fFncEnteredOnly := aSettings.FncEnteredOnly;
  fFncStatus := aSettings.FncStatus;
  fWeightsLocal := aSettings.WeightsLocal;
  fWeightsGlobal := aSettings.WeightsGlobal;
  fWeightsLocalNormalized := aSettings.WeightsLocalNormalized;
  fWeightsGlobalNormalized := aSettings.WeightsGlobalNormalized;
  fMaxColumns := aSettings.MaxColumns;
  fEvalTrim := aSettings.EvalTrim;
  fUseNormalizedWeights := aSettings.FncNormalizedWeights;
end;

method DexiReportParameters.CollectUndoableObjects(aList: List<IUndoable>);
begin
  inherited CollectUndoableObjects(aList);
  UndoUtils.Include(aList, fRoot);
end;

method DexiReportParameters.GetSelectedColumns: IntArray;
begin
  result :=
    if fSelectedAlternatives = nil then Utils.RangeArray(Model.AltCount, 0)
    else fSelectedAlternatives.Ints;
end;

method DexiReportParameters.AddAlternative(aAlt: Integer);
begin
  inherited AddAlternative(aAlt);
  if fAlternative >= 0 then
    fAlternative := Utils.InsertIndex(fAlternative, aAlt);
end;

method DexiReportParameters.DeleteAlternative(aAlt: Integer);
begin
  inherited DeleteAlternative(aAlt);
  if fAlternative >= 0 then
    fAlternative :=
      if fAlternative = aAlt then -1
      else Utils.DeleteIndex(fAlternative, aAlt);
end;

method DexiReportParameters.MoveAlternative(aFrom, aTo: Integer);
begin
  inherited MoveAlternative(aFrom, aTo);
  if fAlternative >= 0 then
    fAlternative := Utils.MoveIndex(fAlternative, aFrom, aTo);
end;

method DexiReportParameters.MoveAlternativePrev(aAlt: Integer);
begin
  inherited MoveAlternativePrev(aAlt);
  if fAlternative >= 0 then
    fAlternative := Utils.MoveIndex(fAlternative, aAlt, aAlt - 1);
end;

method DexiReportParameters.MoveAlternativeNext(aAlt: Integer);
begin
  inherited MoveAlternativeNext(aAlt);
  if fAlternative >= 0 then
    fAlternative := Utils.MoveIndex(fAlternative, aAlt, aAlt + 1);
end;

method DexiReportParameters.ExchangeAlternatives(aIdx1, aIdx2: Integer);
begin
  inherited ExchangeAlternatives(aIdx1, aIdx2);
  if fAlternative >= 0 then
    fAlternative := Utils.ExchangeIndex(fAlternative, aIdx1, aIdx2);
end;

{$ENDREGION}

{$REGION DexiReport}

class method DexiReport.NewReport(aType: String; aParameters: DexiReportParameters; aChartParameters: DexiChartParameters; aFormat: DexiReportFormat): DexiReport;
begin
  result :=
    case aType of
      'MODEL':        new DexiModelReport(aParameters, aFormat);
      'STATISTICS':   new DexiStatisticsReport(aParameters, aFormat);
      'ATTRIBUTE':    new DexiAttributeReport(aParameters, aFormat);
      'FUNCTION':     new DexiSingleFunctionReport(aParameters, aFormat);
      'TREE':         new DexiTreeReport(aParameters, aFormat);
      'TREEATT':      new DexiTreeAttributeReport(aParameters, aFormat);
      'ALTERNATIVES': new DexiTreeAlternativesReport(aParameters, aFormat);
      'TREEEVAL':     new DexiTreeEvaluationReport(aParameters, aFormat);
      'TREEEVALQQ':   new DexiTreeQQEvaluationReport(aParameters, aFormat);
      'FUNCTIONS':    new DexiFunctionsReport(aParameters, aFormat);
      'WEIGHTS':      new DexiWeightsReport(aParameters, aFormat);
      'SELECTIVE':    new DexiSelectiveExplanationReport(aParameters, aFormat);
      'COMPARE':      new DexiAlternativeComparisonReport(aParameters, aFormat);
      'PLUS/MINUS':   new DexiPlusMinusReport(aParameters, aFormat);
      'TARGET':       new DexiTargetReport(aParameters, aFormat);
      'CHART':        new DexiChartReport(aParameters, aFormat);
      'REPORTS':      new DexiReportGroup(aParameters, aFormat);
      else          nil;
    end;
  if result <> nil then
    result.ChartParameters := aChartParameters;
end;

method DexiReport.Copy: DexiReport;
begin
  var lParameters := new DexiReportParameters(fParameters);
  var lChartParameters :=
    if ChartParameters = nil then nil
    else new DexiChartParameters(ChartParameters);
  var lFormat := new DexiReportFormat(fFormat);
  result := NewReport(ReportType, lParameters, lChartParameters, lFormat);
  result.Title := Title;
end;

method DexiReport.AdaptSelectedAttributes(aAttList: DexiAttributeList): Boolean;
begin
  result := true;
  if Parameters:SelectedAttributes <> nil then
    begin
      var lSelected := Parameters.SelectedAttributes.ToArray;
      for each lAtt in lSelected do
        if not aAttList.Contains(lAtt) then
          Parameters.UnSelectAttribute(lAtt);
    end;
end;

method DexiReport.AdaptToAttributes(aAttList: DexiAttributeList): Boolean;
begin
  result := true;
  if Parameters:Root <> nil then
    begin
      if not aAttList.Contains(Parameters.Root) then
        if NeedsRoot then
          exit false
        else
          Parameters.Root := nil;
      end;
  result := AdaptSelectedAttributes(aAttList);
end;

method DexiReport.SettingsChanged;
begin
  fParameters.UpdateFromSettings;
end;

class method DexiReport.BreakColumns(aColumns: IntArray; aMaxColumns: Integer): List<IntArray>;

  method Slice(var aFrom: Integer; aTo, aNext: Integer; aList: List<IntArray>);
  begin
    if aFrom <= aTo then
      begin
        var lSlice := Utils.CopyIntArray(aColumns, aFrom, aTo - aFrom + 1);
        aList.Add(lSlice);
      end;
    aFrom := aNext;
  end;

begin
  result := new List<IntArray>;
  if length(aColumns) = 0 then
    exit;
  if aMaxColumns <= 0 then
    aMaxColumns := high(Integer);
  var lFrom := 0;
  var lTo := 0;
  while lFrom <= high(aColumns) do
    begin
      var lCount := lTo - lFrom + 1;
      if lTo > high(aColumns) then
        Slice(var lFrom, lTo - 1, lTo, result)
      else if aColumns[lTo] = DexiReport.ColBreak then
        Slice(var lFrom, lTo - 1, lTo + 1, result)
      else if lCount >= aMaxColumns then
        Slice(var lFrom, lTo, lTo + 1, result);
      inc(lTo);
    end;
end;

constructor DexiReport(aParameters: DexiReportParameters; aFormat: DexiReportFormat := nil);
begin
  constructor ('', aParameters, aFormat);
end;

constructor DexiReport(aTitle: String; aParameters: DexiReportParameters; aFormat: DexiReportFormat := nil);
begin
  fSelected := true;
  fFormat :=
    if aFormat = nil then new DexiReportFormat
    else aFormat;
  fReport := NewReport;
  fParameters := aParameters;
  Title := aTitle;
  SetFormat(fFormat);
  fScaleStrings.MemDecimals := fParameters.MemDecimals;
end;

method DexiReport.CollectUndoableObjects(aList: List<IUndoable>);
begin
  UndoUtils.Include(aList, fParameters);
end;

method DexiReport.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiReport then
    exit false;
  result := true;
end;

method DexiReport.GetUndoState: IUndoable;
begin
  var lRpt := NewReport(ReportType, fParameters, ChartParameters, new DexiReportFormat(fFormat));
  lRpt.Title := Title;
  result := lRpt;
end;

method DexiReport.SetUndoState(aState: IUndoable);
begin
  var lReport := aState as DexiReport;
  fParameters := lReport.Parameters;
end;

method DexiReport.GetNeedsRoot: Boolean;
begin
  result := false;
end;

method DexiReport.SetFormat(aFormat: DexiReportFormat);
begin
  fFormat :=
    if aFormat = nil then new DexiReportFormat
    else aFormat;
  Model.Modified := true;
end;

method DexiReport.SetParameters(aParameters: DexiReportParameters);
begin
  fParameters := aParameters;
  Model.Modified := true;
end;

method DexiReport.GetChartParameters: DexiChartParameters;
begin
  result := nil;
end;

method DexiReport.SetChartParameters(aParameters: DexiChartParameters);
begin
  // ignore
end;

method DexiReport.SetSelected(aSelected: Boolean);
begin
  fSelected := aSelected;
  Model.Modified := true;
end;

method DexiReport.SetTitle(aTitle: String);
begin
  fReport.Title := aTitle;
  Model.Modified := true;
end;

method DexiReport.TruePos(aBools: array of Boolean): Integer;
begin
  var lPos := -1;
  var lCount := 0;
  for x := low(aBools) to high(aBools) do
    if aBools[x] then
      begin
        inc(lCount);
        lPos := x;
      end;
  result := if lCount = 1 then lPos else -1;
end;

method DexiReport.BeginReport(aClear: Boolean := true);
begin
  if aClear then
    Report.Clear;
  Report.Header := ReportHeader;
  Report.SectionBreak := Model.Settings.SectionBreak;
  Report.TableBreak := Model.Settings.TableBreak;
  Report.TreePattern := Model.Settings.TreePattern;
  ClearParents;
end;

method DexiReport.ClearParents;
begin
  fTreeParents := new Dictionary<DexiAttribute, RptTreeParent>;
end;

method DexiReport.AttFormat(aAtt: DexiAttribute): RptFormatSettings;
begin
  result :=
    if aAtt.IsLinked then Format.FormatAttLink
    else if aAtt.IsAggregate then Format.FormatAttAggregate
    else if aAtt.IsBasic then Format.FormatAttBasic
    else nil;
end;

method DexiReport.WrTreeAttribute(aCell: RptCell; aAtt: DexiAttribute; aIncludeIndent: Boolean := true; aUseParents: Boolean := true);
begin
  if aIncludeIndent then
    if Model.Settings.TreePattern <> RptTreePattern.Lines then
      aCell.Tree(aAtt.TreeIndent)
    else
      begin
        var lRptAtt :=
          if aUseParents and aAtt.IsAggregate then new RptTreeParent
          else nil;
        var lRptParent :=
          if aUseParents and (aAtt.Parent <> nil) then fTreeParents[aAtt.Parent]
          else nil;
        aCell.Tree(aAtt.TreeIndent, lRptParent, aUseParents);
        if lRptAtt <> nil then
          begin
            aCell.Add(lRptAtt);
            fTreeParents.Add(aAtt, lRptAtt);
          end;
      end;
  aCell.Wr(aAtt.Name, AttFormat(aAtt));
end;

method DexiReport.ReportHeader: RptVerticalGroup;
begin
  if (Model = nil) or not Model.Settings.UseReportHeader then
    exit nil;
  result := new RptVerticalGroup;
  var lLine := result.NewLine;
  lLine.HIntAlign := RptAlign.Fill;
  lLine.Liner;
  if Software <> nil then
    lLine.Wr(Software, FormatHead);
  lLine.HFill;
  if FileName <> nil then
    lLine.Wr(FileName + ' ');
  lLine.WrMacro('DATE');
  lLine.HFill;
  lLine.Wr(DexiString.RPage);
  lLine.WrMacro('PAGE');
  lLine.EndLiner;
  result.HalfLine;
end;

method DexiReport.NewReport: RptReport;
begin
  result := new RptReport(fReport);
  result.Header := ReportHeader;
end;

method DexiReport.PrepareColumns(aColumns: IntArray; aAltOnly: Boolean): IntArray;
begin
  result :=
    if aColumns = nil then []
    else Utils.CopyIntArray(aColumns);
  for i := high(aColumns) downto low(aColumns) do
    begin
      var lCond :=
        if aAltOnly then 0 <= aColumns[i] < Model.AltCount
        else aColumns[i] < Model.AltCount;
      if not lCond  then
        result := Utils.IntArrayDelete(result, i);
    end;
end;

method DexiReport.PrepareColumns(aColumns: IntArray; aExcludeAlt: Integer): IntArray;
begin
  var lIdx := Utils.IntArrayIndex(aColumns, aExcludeAlt);
  result :=
    if lIdx >= 0 then Utils.IntArrayDelete(aColumns, lIdx)
    else aColumns;
end;

method DexiReport.Rooted(aRoot: DexiAttribute): ImmutableList<DexiAttribute>;
begin
  result :=
    if aRoot = nil then Model:Root:AllInputs
    else new List<DexiAttribute>(aRoot);
end;

method DexiReport.WrName(aSection: RptSection; aObj: DexiObject; aObjectIntro: String := nil; aFormat: RptFormatSettings := nil);
begin
  if String.IsNullOrEmpty(aObj:Name) then
    exit;
  var lLine := aSection.NewLine;
  if aObjectIntro <> nil then
    lLine.Wr(aObjectIntro + ': ');
  if aFormat = nil then
    aFormat := RptFormatSettings.BoldFormat;
  lLine.Wr(aObj.Name, aFormat);
  aSection.NewLine;
end;

method DexiReport.WrDescription(aSection: RptSection; aObj: DexiObject);
begin
  if String.IsNullOrEmpty(aObj:Description) then
    exit;
  var lLines := Utils.BreakToLines(aObj.Description);
  for each lLine in lLines do
    begin
      if String.IsNullOrEmpty(lLine) then
        lLine := ' ';
      aSection.NewParagraph(lLine);
    end;
  aSection.NewLine;
end;

method DexiReport.WrNameAndDescription(
  aSection: RptSection; aObj: DexiObject; aObjectIntro: String := nil; aFormat: RptFormatSettings := nil);
begin
  WrName(aSection, aObj, aObjectIntro, aFormat);
  WrDescription(aSection, aObj);
end;

method DexiReport.WrScale(aSection: RptSection; aAtt: DexiAttribute);

  method TabColumns(aTable: RptTable);
  begin
    aTable.AddColumn('Number');
    aTable.AddColumn('Value');
    aTable.AddColumn('Description');
  end;

  method TabValues(aTable: RptTable; aScale: DexiDiscreteScale);
  begin
    for i := 0 to aScale.Count - 1 do
      begin
        var lRow := aTable.NewRow;
        var lCell := lRow.NewCell;
        lCell.Wr(Utils.IntToStr(i + 1));
        lCell.HIntAlign := RptAlign.Last;
        lCell := lRow.NewCell;
        lCell.Wr(fScaleStrings.ValueOnScaleComposite(i, aScale));
        lCell := lRow.NewCell;
        if not String.IsNullOrEmpty(aScale.Descriptions[i]) then
          lCell.Wr(aScale.Descriptions[i]);
      end;
  end;

begin
  var lSection := aSection.NewSection('Scale', Model.Settings.SectionBreak);
  var lScale := aAtt:Scale;
  if lScale = nil then
    lSection.NewLine.Wr(DexiString.RSclUndefined)
  else
    begin
      WrNameAndDescription(lSection, lScale, DexiString.RSclName);
      if lScale is DexiDiscreteScale then
        begin
          var lTable := lSection.NewTable('Discrete scale');
          TabColumns(lTable);
          TabValues(lTable, DexiDiscreteScale(lScale));
        end
      else if lScale is DexiContinuousScale then
        begin
          lSection.NewLine.Wr(fScaleStrings.ScaleComposite(lScale));
        end;
    end;
  lSection.NewLine;
end;

type
  TabNumericInfo = class
  private
    fLinear: Boolean;
    fQQ1: Boolean;
    fQQ2: Boolean;
    fQQ1Model: DexiQQ1Model;
    fQQ2Model: DexiQQ2Model;
  public
    constructor (aFunct: DexiTabularFunction);
    property Linear: Boolean read fLinear and (fQQ1Model <> nil) write fLinear;
    property QQ1: Boolean read fQQ1 and (fQQ1Model <> nil) write fQQ1;
    property QQ2: Boolean read fQQ2 and (fQQ2Model <> nil) write fQQ2;
    property QQModel: DexiQQ1Model read fQQ1Model;
    property QQ2Model: DexiQQ2Model read fQQ2Model;
  end;

constructor TabNumericInfo(aFunct: DexiTabularFunction);
begin
  fLinear := aFunct.CanUseWeights;
  fQQ1 := aFunct.CanUseWeights;
  fQQ1Model := new DexiQQ1Model(aFunct);
  fQQ2 := true;
  fQQ2Model := new DexiQQ2Model(aFunct);
end;

method DexiReport.WrTabularFunction(aSection: RptSection; aAtt: DexiAttribute; aFunct: DexiFunction := nil);
var NumInfo: TabNumericInfo;

  method MakeNumInfo(aFunct: DexiTabularFunction): TabNumericInfo;
  begin
    result :=
      if Parameters.FncShowNumericValues and (Parameters.Representation = DexiRptFunctionRepresentation.Elementary) then
        new TabNumericInfo(aFunct)
      else
        nil;
  end;

  method TabColumns(aTable: RptTable);
  begin
    if Parameters.FncShowNumbers then
      aTable.AddColumn('Number');
    for i := 0 to aAtt.InpCount - 1 do
      aTable.AddColumn($'Input {i}');
    aTable.AddColumn('Value');
  end;

  method TabHead(aTable: RptTable);
  begin
    var lHead := aTable.NewRow;
    lHead.Liner;
    if Parameters.FncShowNumbers then
      lHead.NewCell;  // Number
    for i := 0 to aAtt.InpCount - 1 do
      lHead.NewCell.Wr(aAtt.Inputs[i]:Name, FormatTableHead);
    lHead.NewCell.Wr(aAtt:Name, FormatTableHead);
    if NumInfo <> nil then
      begin
        if NumInfo.Linear then
          begin
            var lCell := lHead.NewCell;
            lCell.Wr(DexiString.RLinear, FormatTableHead);
            lCell.HIntAlign := RptAlign.Last;
          end;
        if NumInfo.QQ1 then
          begin
            var lCell := lHead.NewCell;
            lCell.Wr(DexiString.RQQ1, FormatTableHead);
            lCell.HIntAlign := RptAlign.Last;
          end;
        if NumInfo.QQ2 then
          begin
            var lCell := lHead.NewCell;
            lCell.Wr(DexiString.RQQ2, FormatTableHead);
            lCell.HIntAlign := RptAlign.Last;
          end;
      end;
    lHead.EndLiner;
  end;

  method TabWeights(aTable: RptTable; aFunct: DexiTabularFunction);
  begin
    aFunct.CalcActualWeights(false);
    var fWeights :=
      if Parameters.UseNormalizedWeights then aFunct.NormActualWeights
      else aFunct.ActualWeights;
    if length(fWeights) <> aAtt.InpCount then
      exit;
    var lWeights := aTable.NewRow;
    lWeights.Liner;
    if Parameters.FncShowNumbers then
      lWeights.NewCell;  // Number
    for i := 0 to aAtt.InpCount - 1 do
      lWeights.NewCell.Wr(Utils.FltToStr(fWeights[i], Parameters.WeiDecimals, false) + '%');
    lWeights.NewCell;
    if NumInfo <> nil then
      begin
        if NumInfo.Linear then
          lWeights.NewCell;
        if NumInfo.QQ1 then
          lWeights.NewCell;
        if NumInfo.QQ2 then
          lWeights.NewCell;
      end;
    lWeights.EndLiner;
  end;

  method WrNumeric(aFunct: DexiTabularFunction; aRule: Integer; aRow: RptRow);
  require
    NumInfo <> nil;
  begin
    var lArgs := aFunct.ArgValues[aRule];
    if NumInfo.Linear then
      if aFunct.RuleDefined[aRule] then
        begin
          var lValue := NumInfo.QQModel.Regression(lArgs);
          var lCell := aRow.NewCell;
          lCell.Wr(Utils.FltToStr(lValue, Parameters.FltDecimals, false));
          lCell.HIntAlign := RptAlign.Last;
        end
      else
        aRow.NewCell;
    if NumInfo.QQ1 then
      if aFunct.RuleDefined[aRule] then
        begin
          var lValues := NumInfo.QQModel.Evaluate(lArgs);
          lValues := Utils.RemoveNaN(lValues);
          var lCell := aRow.NewCell;
          lCell.Wr(Utils.FltArrayToStr(lValues, Parameters.FltDecimals, false));
          lCell.HIntAlign := RptAlign.Last;
        end
      else
        aRow.NewCell;
    if NumInfo.QQ2 then
      if aFunct.RuleDefined[aRule] then
        begin
          var lValues := NumInfo.QQ2Model.Evaluate(lArgs);
          lValues := Utils.RemoveNaN(lValues);
          var lCell := aRow.NewCell;
          lCell.Wr(Utils.FltArrayToStr(lValues, Parameters.FltDecimals, false));
          lCell.HIntAlign := RptAlign.Last;
        end
      else
        aRow.NewCell;
  end;

  method WrElementaryRules(aTable: RptTable; aFunct: DexiTabularFunction);
  begin
    for r := 0 to aFunct.Count - 1 do
      if not Parameters.FncEnteredOnly or aFunct.RuleEntered[r] then
        begin
          var lRow := aTable.NewRow;
          if Parameters.FncShowNumbers then
            begin
              var lCell := lRow.NewCell;
              lCell.Wr(Utils.IntToStr(r + 1), if aFunct.RuleEntered[r] then RptFormatSettings.BoldFormat else nil);
              lCell.HIntAlign := RptAlign.Last;
            end;
          for i := 0 to aAtt.InpCount - 1 do
            lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(aFunct.ArgVal[i,r], aAtt.Inputs[i]:Scale));
          lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(aFunct.RuleValue[r], aAtt:Scale));
          if NumInfo <> nil then
            WrNumeric(aFunct, r, lRow);
        end;
  end;

  method WrComplexRules(aTable: RptTable; aFunct: DexiTabularFunction);
  begin
    var lCount := 0;
    for u := 0 to aAtt.Scale.Count - 1 do
      begin
        var lRules := aFunct.ComplexRules(u, not Parameters.FncEnteredOnly);
        for r := 0 to lRules.Count - 1 do
          begin
            inc(lCount);
            var lRow := aTable.NewRow;
            if r = lRules.Count - 1 then
              lRow.Liner;
            if Parameters.FncShowNumbers then
              begin
                var lCell := lRow.NewCell;
                lCell.Wr(Utils.IntToStr(lCount), RptFormatSettings.BoldFormat);
              end;
            var lRule := lRules[r];
            for i := 0 to aAtt.InpCount - 1 do
              begin
                var lValue := new DexiIntInterval(lRule.Low[i], lRule.High[i]);
                lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(lValue, aAtt.Inputs[i]:Scale));
              end;
            lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(u, aAtt:Scale));
            if r = lRules.Count - 1 then
              lRow.EndLiner;
          end;
      end;
  end;

  method WrDecisionTree(aFunct: DexiTabularFunction);
  var lLine: RptLine;

    method NewLine;
    begin
      lLine := aSection.NewLine;
    end;

    method WrNode(aNode: DecisionTreeNode; aLev: Integer);
    begin
      if aNode = nil then
        lLine.Wr('NIL')
      else if aNode.Count = 0 then
        begin 
          lLine.Wr(aFunct:Attribute:Name);
          lLine.Wr(': ');
          lLine.Wr(fScaleStrings.ValueOnScaleComposite(aNode:ClassValue, aAtt:Scale));
          NewLine;
        end
      else
        begin
          var lSplitOn := aNode.SplitOn;
          var lIndent := if aLev = 0 then '' else Utils.ChStr(4 * aLev);
          lLine.Wr($'{lIndent}{lSplitOn:Name}:');
          NewLine;
          lIndent := lIndent + '  ';
          for s := 0 to aNode.Count - 1 do
            begin
              var lSubtree := aNode.Subtree[s];
              var lValues := new DexiIntSet(lSubtree.AttValues);
              lLine.Wr(lIndent);
              lLine.Wr(fScaleStrings.ValueOnScaleComposite(lValues, lSplitOn:Scale));
              lLine.Wr(':');
              if lSubtree.Count = 0 then
                lLine.Wr(' ')
              else
                NewLine;
              WrNode(lSubtree, aLev + 1);
            end;
        end;
    end;

  begin
    var lDT := new DecisionTree(aFunct);
    NewLine;
    WrNode(lDT.Root, 0);
  end;

begin
  if aFunct = nil then
    aFunct := aAtt:Funct;
  var lFunct := aFunct as DexiTabularFunction;
  NumInfo := MakeNumInfo(lFunct);
  if Parameters.Representation = DexiRptFunctionRepresentation.DecisionTree then
    begin
      WrDecisionTree(lFunct);
      exit;
    end;
  var lTable := aSection.NewTable('Tabular function');
  TabColumns(lTable);
  TabHead(lTable);
  if Parameters.FncShowWeights and lFunct.CanUseWeights then
    TabWeights(lTable, lFunct);
  if Parameters.Representation = DexiRptFunctionRepresentation.Elementary then
    WrElementaryRules(lTable, lFunct)
  else
    WrComplexRules(lTable, lFunct);
end;

method DexiReport.WrFunctionStatus(aSection: RptSection; aAtt: DexiAttribute);
begin
  var lFunct := aAtt.Funct as DexiTabularFunction;
  var lStatus := lFunct.FunctionStatusReport;
  if lStatus.Count = 0 then
    exit;
  var lSection := aSection.NewSection('Status', Model.Settings.SectionBreak);
  lSection.NewLine;
  for each lItem in lStatus do
    lSection.NewLine.Wr(lItem);
end;

method DexiReport.WrFunctionMarginals(aSection: RptSection; aAtt: DexiAttribute);
begin
  var lFunct := aAtt.Funct as DexiTabularFunction;
  var lMarginals := lFunct.Marginals(true);
  aSection.NewLine;
  var lSection := aSection.NewSection('Marginal values', Model.Settings.SectionBreak);
  lSection.Wr(DexiString.RNormalizedMarginalValues);
  var lTable := aSection.NewTable('Marginal values');
  lTable.AddColumn('Attribute');
  lTable.AddColumn('Marginals');
  for i := 0 to aAtt.InpCount - 1 do
    begin
      var lRow := lTable.NewRow;
      var lCell := lRow.NewCell;
      lCell.Wr(aAtt.Inputs[i]:Name);
      lCell := lRow.NewCell;
      var lMarginal := lMarginals[i];
      for j := low(lMarginal) to high(lMarginal) do
        begin
          if j> 0 then
            lCell.Wr(DexiString.SListSeparator + ' ');
          lCell.Wr(fScaleStrings.ValueOnScaleComposite(j, aAtt.Inputs[i]:Scale));
          lCell.Wr(': ');
          lCell.Wr(Utils.FltToStr(lMarginal[j], Parameters.FltDecimals, false));
        end;
    end;
end;

method DexiReport.WrDiscretizeFunction(aSection: RptSection; aAtt: DexiAttribute; aFunct: DexiFunction := nil);

  method TabColumns(aTable: RptTable);
  begin
    if Parameters.FncShowNumbers then
      aTable.AddColumn('Number');
    aTable.AddColumn('');
    aTable.AddColumn('From');
    aTable.AddColumn('To');
    aTable.AddColumn('');
    aTable.AddColumn('Value');
  end;

  method TabHead(aTable: RptTable; aInpAtt: DexiAttribute);
  begin
    var lHead := aTable.NewRow;
    lHead.Liner;
    if Parameters.FncShowNumbers then
      lHead.NewCell;  // Number
    lHead.NewCell;    // Low association
    lHead.NewCell.Wr(aInpAtt:Name, FormatTableHead);  // Attribute: from
    lHead.NewCell;    // Attribute: to
    lHead.NewCell;    // High association
    lHead.NewCell.Wr(aAtt:Name, FormatTableHead);     // Value
    lHead.EndLiner;
  end;

begin
  if aFunct = nil then
    aFunct := aAtt:Funct;
  var lFunct := aFunct as DexiDiscretizeFunction;
  var lInpAtt := aAtt.Inputs[0];
  var lTable := aSection.NewTable('Discretize function');
  TabColumns(lTable);
  TabHead(lTable, lInpAtt);
  for i := 0 to lFunct.IntervalCount - 1 do
    if not Parameters.FncEnteredOnly or lFunct.IntervalEntered[i] then
      begin
        var lRow := lTable.NewRow;
        if Parameters.FncShowNumbers then
          lRow.NewCell.Wr(Utils.IntToStr(i + 1)).HIntAlign := RptAlign.Last;
        var lBound := lFunct.IntervalLowBound[i];
        lRow.NewCell.Wr(if lBound.Association = DexiBoundAssociation.Up then '[' else '(');
        lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(lBound.Bound, lInpAtt:Scale));
        lBound := lFunct.IntervalHighBound[i];
        lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(lBound.Bound, lInpAtt:Scale));
        lRow.NewCell.Wr(if lBound.Association = DexiBoundAssociation.Up then ')' else ']');
        lRow.NewCell.Wr(fScaleStrings.ValueOnScaleComposite(lFunct.IntervalValue[i], aAtt:Scale));
      end;
end;

method DexiReport.WrFunction(aSection: RptSection; aAtt: DexiAttribute; aFunct: DexiFunction := nil);
begin
  var lSection := aSection.NewSection('Function', Model.Settings.SectionBreak);
  var lFunct :=
    if aFunct = nil then aAtt:Funct
    else aFunct;
  if lFunct = nil then
    lSection.NewLine.Wr(DexiString.RFncUndefined)
  else
    begin
      WrNameAndDescription(lSection, lFunct, DexiString.RFncName);
      if lFunct is DexiTabularFunction then
        begin
          WrTabularFunction(lSection, aAtt, lFunct);
          if Parameters.FncStatus then
            WrFunctionStatus(lSection, aAtt);
          if Parameters.FncShowMarginals then
            WrFunctionMarginals(lSection, aAtt);
        end
      else if lFunct is DexiDiscretizeFunction then
        WrDiscretizeFunction(lSection, aAtt, lFunct);
    end;
  aSection.NewLine;
end;

{$ENDREGION}

{$REGION DexiModelReport}

method DexiModelReport.GetReportType: String;
begin
  result := 'MODEL';
end;

method DexiModelReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  var lSection := Report.NewSection(DexiString.RModDesc, Report.SectionBreak);
  lSection.NewLine.Wr(DexiString.RModDesc, FormatSection);
  lSection.NewLine;
  WrNameAndDescription(lSection, Model, DexiString.RModName);
end;

{$ENDREGION}

{$REGION DexiStatisticsReport}

method DexiStatisticsReport.GetReportType: String;
begin
  result := 'STATISTICS';
end;

method DexiStatisticsReport.MakeReport(aClear: Boolean := true);
  const Indent = Utils.ChStr(3, DexiString.NonBreakingSpace);
  var
    Table: RptTable;
    Statistics: DexiModelStatistics;

  method TabColumns;
  begin
    Table.AddColumn('Indicator');
    Table.AddColumn('Value');
  end;

  method WriteText(aText: String; aLev: Integer): RptRow;
  begin
    result := Table.NewRow;
    var lCell := result.NewCell;
    if aLev = 0 then
      lCell.Wr(aText, RptFormatSettings.BoldFormat)
    else
      lCell.Wr(Utils.ChString(aLev, Indent) + aText);
  end;

  method WriteStat(aText: String; aValue: Integer; aLev: Integer);
  begin
    var lRow := WriteText(aText, aLev);
    var lCell := lRow.NewCell;
    lCell.Wr(Utils.IntToStr(aValue));
    lCell.HIntAlign := RptAlign.Last;
  end;

  method WriteStat(aText: String; aValue: Float; aLev: Integer);
  begin
    var lRow := WriteText(aText, aLev);
    var lCell := lRow.NewCell;
    lCell.Wr(Utils.FltToStr(aValue, Parameters.FltDecimals, false));
    lCell.HIntAlign := RptAlign.Last;
  end;

  method TabValues;
  begin
    WriteText(DexiString.RModDim, 0);
    WriteStat(DexiString.RModDepth, Statistics.Depth, 1);
    if Statistics.AggregateAttributes > 0 then
    begin
      WriteStat(DexiString.RAverageWidth, Statistics.Width, 1);
      WriteStat(DexiString.RMin, Statistics.MinWidth, 2);
      WriteStat(DexiString.RMax, Statistics.MaxWidth, 2);
    end;
    WriteStat(DexiString.RAttributes, Statistics.Attributes, 0);
    if Statistics.BasicAttributes > 0 then
      WriteStat(DexiString.RBasic, Statistics.BasicAttributes, 1);
    if Statistics.AggregateAttributes > 0 then
      WriteStat(DexiString.RAggregate, Statistics.AggregateAttributes, 1);
    if Statistics.LinkedAttributes > 0 then
      WriteStat(DexiString.RLinked, Statistics.LinkedAttributes, 1);
    WriteStat(DexiString.RScales, Statistics.Scales, 0);
    if Statistics.DiscrScales > 0 then
      WriteStat(DexiString.RDiscrete, Statistics.DiscrScales, 1);
    if Statistics.ContScales > 0 then
      WriteStat(DexiString.RContinuous, Statistics.ContScales, 1);
    if Statistics.UndefScales > 0 then
      WriteStat(DexiString.RUndefined, Statistics.UndefScales, 1);
    WriteStat(DexiString.RFunctions, Statistics.Functions, 0);
    if Statistics.TabularFunctions > 0 then
      begin
        WriteStat(DexiString.RTabular, Statistics.TabularFunctions, 1);
        WriteStat(DexiString.RAverageSize, Statistics.Rules, 2);
        WriteStat(DexiString.RMin, Statistics.MinRules, 3);
        WriteStat(DexiString.RMax, Statistics.MaxRules, 3);
      end;
    if Statistics.DiscretizeFunctions > 0 then
      WriteStat(DexiString.RDiscretize, Statistics.DiscretizeFunctions, 1);
    if Statistics.UndefFunctions > 0 then
      WriteStat(DexiString.RUndefined, Statistics.UndefFunctions, 1);
    WriteStat(DexiString.RAlternatives, Statistics.Alternatives, 0);
  end;

require
  Model <> nil;
begin
  BeginReport(aClear);
  var lSection := Report.NewSection(DexiString.RModStat, Report.SectionBreak);
  lSection.NewLine.Wr(DexiString.RModStat, FormatSection);
  lSection.NewLine;
  Table := lSection.NewTable('Statistics');
  Statistics := Model.Statistics;
  TabColumns;
  TabValues;
  lSection.NewLine;
end;

{$ENDREGION}

{$REGION DexiAttributeReport}

method DexiAttributeReport.GetReportType: String;
begin
  result := 'ATTRIBUTE';
end;

method DexiAttributeReport.MakeTitle: String;
begin
  if not Parameters.MakeTitle then
    exit nil;
  var lElement := TruePos([Parameters.AttDescription, Parameters.AttScale, Parameters.AttFunction]);
  result :=
    case lElement of
      0: DexiString.RAttDescription;
      1: DexiString.RAttScales;
      2: DexiString.RAttFncSummary;
      else DexiString.RAttInformation;
    end;
end;

method DexiAttributeReport.TabAtt(aSection: RptSection; aAtt: DexiAttribute);
begin
  if (aAtt <> nil) and Parameters.IsSelected(aAtt) then
    begin
      var lSection := aSection.NewSection($'Attribute {aAtt:Name}', Model.Settings.SectionBreak);
      if Parameters.AttName then
        WrName(lSection, aAtt, DexiString.RAttribute, nil);
      if Parameters.AttDescription then
        WrDescription(lSection, aAtt);
      if Parameters.AttScale then
        WrScale(lSection, aAtt);
      if Parameters.AttFunction and aAtt.IsAggregate then
        WrFunction(lSection, aAtt, Parameters.Funct);
    end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    TabAtt(aSection, aAtt.Inputs[lIdx]);
end;

method DexiAttributeReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  var lTitle := MakeTitle;
  var lSection := Report.NewSection(lTitle, Report.SectionBreak);
  if Parameters.MakeTitle then
    begin
      lSection.NewLine.Wr(lTitle, FormatSection);
      lSection.NewLine;
    end;
  for lAtt in Rooted(Root) do
    TabAtt(lSection, lAtt);
end;

{$ENDREGION}

{$REGION DexiSingleFunctionReport}

method DexiSingleFunctionReport.GetReportType: String;
begin
  result := 'FUNCTION';
end;

{$ENDREGION}

{$REGION DexiTreeReport}

method DexiTreeReport.GetReportType: String;
begin
  result := 'TREE';
end;

method DexiTreeReport.AttributeRestricted(aAtt: DexiAttribute): Boolean;
begin
  result := false;
end;

method DexiTreeReport.MakeTitle(aColumns: IntArray): String;
begin
  var lProp := false;
  var lAlt := false;
  for i := low(aColumns) to high(aColumns) do
    begin
      if aColumns[i] < 0 then lProp := true;
      if aColumns[i] >= 0 then lAlt := true;
    end;
  result := DexiString.RTree;
  if lAlt and not lProp then
    result :=
      if self is DexiTreeAlternativesReport then DexiString.RAlternatives
      else DexiString.REvaluationResults;
  if lProp and not lAlt and (length(aColumns) = 1) then
    if aColumns[0] = ColDescr then result := DexiString.RDescriptions
    else if aColumns[0] = ColScale then result := DexiString.RScales
    else if aColumns[0] = ColFunct then result := DexiString.RAttFncSummary;
end;

method DexiTreeReport.TabColumns(aTable: RptTable; aColumns: IntArray);
begin
  aTable.AddColumn(DexiString.RAttribute);
  for i := low(aColumns) to high(aColumns) do
    begin
      var lCol := aColumns[i];
      var lColId :=
        if lCol >= 0 then DexiString.RAlternative + ' ' + Utils.IntToStr(lCol)
        else if lCol = ColDescr then DexiString.RDescription
        else if lCol = ColScale then DexiString.RScale
        else if lCol = ColFunct then DexiString.RFunction
        else DexiString.SDexiUndefined;
      aTable.AddColumn(lColId);
    end;
end;

method DexiTreeReport.TabHead(aTable: RptTable; aColumns: IntArray);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  for i := low(aColumns) to high(aColumns) do
    begin
      var lCol := aColumns[i];
      var lColHead :=
        if lCol >= 0 then Model.Alternative[lCol].Name
        else if lCol = ColDescr then DexiString.RDescription
        else if lCol = ColScale then DexiString.RScale
        else if lCol = ColFunct then DexiString.RFunction
        else DexiString.SDexiUndefined;
      lHead.NewCell.Wr(lColHead, FormatTableHead);
    end;
  lHead.EndLiner;
end;

method DexiTreeReport.TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute);

  method AttDescription: String;
  begin
    result := if aAtt:Description = nil then '' else aAtt:Description;
  end;

  method AttFunct: String;
  begin
    result := if aAtt:Funct = nil then DexiString.SDexiNullFunct else aAtt.Funct.FunctString;
  end;

begin
  if Parameters.IsSelected(aAtt) and not AttributeRestricted(aAtt) then
    begin
      var lRow := aTable.NewRow;
      var lCell := lRow.NewCell;
      WrTreeAttribute(lCell, aAtt, fIncludeTreeIndent);
      for i := low(aColumns) to high(aColumns) do
        begin
          lCell := lRow.NewCell;
          var lCol := aColumns[i];
          if lCol >= 0 then lCell.Wr(fScaleStrings.ValueOnScaleComposite(Model.AltValue[lCol, aAtt], aAtt:Scale))
          else if lCol = ColDescr then lCell.Wr(AttDescription)
          else if lCol = ColScale then
            lCell.Wr(fScaleStrings.ScaleComposite(aAtt:Scale))
          else if lCol = ColFunct then
            lCell.Wr(if aAtt.IsAggregate then AttFunct else '')
          else lCell.Wr(DexiString.SDexiUndefined);
        end;
      end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    TabAtt(aTable, aColumns, aAtt.Inputs[lIdx]);
end;

method  DexiTreeReport.AttributeList(aRoot: DexiAttribute): ImmutableList<DexiAttribute>;
begin
  result := Rooted(aRoot);
end;

method DexiTreeReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  if (self is DexiTreeAlternativesReport) or (self is DexiTreeEvaluationReport) then
    Columns := Parameters.SelectedColumns;
  var lTableColumns := PrepareColumns(Columns, false);
  var lAllColumns := DexiReport.BreakColumns(lTableColumns, Parameters.MaxColumns);
  if (lAllColumns = nil) or (lAllColumns.Count = 0) then
    exit;
  for lColumns in lAllColumns do
    begin
      var lTitle := MakeTitle(lColumns);
      var lSection := Report.NewSection(lTitle, Report.SectionBreak);
      lSection.NewLine.Wr(lTitle, FormatSection);
      lSection.NewLine;
      var lTable := lSection.NewTable(lTitle);
      TabColumns(lTable, lColumns);
      TabHead(lTable, lColumns);
      for lAtt in AttributeList(Root) do
        TabAtt(lTable, lColumns, lAtt);
      lSection.NewLine;
    end;
end;

{$ENDREGION}

{$REGION DexiTreeAttributeReport}

method DexiTreeAttributeReport.GetReportType: String;
begin
  result := 'TREEATT';
end;

{$ENDREGION}

{$REGION DexiTreeAlternativesReport}

method DexiTreeAlternativesReport.GetReportType: String;
begin
  result := 'ALTERNATIVES';
end;

method DexiTreeAlternativesReport.AttributeRestricted(aAtt: DexiAttribute): Boolean;
begin
  result := not DexiAttribute.AttributeIsBasicNonLinked(aAtt);
end;

method DexiTreeAlternativesReport.AttributeList(aRoot: DexiAttribute): ImmutableList<DexiAttribute>;
begin
  var lRoots := inherited AttributeList(aRoot);
  if Model.InputAttributeOrder = nil then
    exit lRoots;
  var lRooted := new DexiAttributeList;
  for each lRoot in lRoots do
    begin
      if not AttributeRestricted(lRoot) then
        lRooted.Add(lRoot);
      lRoot.CollectInputs(lRooted, (att) -> not AttributeRestricted(att));
    end;
  var lOrdered := Model.OrderedInputAttributes;
  var lResult := new List<DexiAttribute>;
  for each lAtt in lOrdered do
    if lRooted.Contains(lAtt) then
      lResult.Add(lAtt);
  exit lResult;
end;

method DexiTreeAlternativesReport.MakeReport(aClear: Boolean := true);
begin
  fIncludeTreeIndent := false;
  inherited MakeReport(aClear);
end;

{$ENDREGION}

{$REGION DexiTreeEvaluationReport}

method DexiTreeEvaluationReport.GetReportType: String;
begin
  result := 'TREEEVAL';
end;

{$ENDREGION}

{$REGION DexiTreeQQEvaluationReport}

method DexiTreeQQEvaluationReport.GetReportType: String;
begin
  result := 'TREEEVALQQ';
end;

method DexiTreeQQEvaluationReport.AttributeRestricted(aAtt: DexiAttribute): Boolean;
begin
  result := inherited AttributeRestricted(aAtt) or (aAtt:Scale = nil) or (aAtt.Scale is not DexiDiscreteScale);
end;

method DexiTreeQQEvaluationReport.MakeTitle(aColumns: IntArray): String;
begin
  result :=
    if not Parameters.MakeTitle then nil
    else DexiString.RQQEvaluationResults;
end;

method DexiTreeQQEvaluationReport.TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute);
begin
  if Parameters.IsSelected(aAtt) and not AttributeRestricted(aAtt) then
    begin
      var lRow := aTable.NewRow;
      var lCell := lRow.NewCell;
      WrTreeAttribute(lCell, aAtt, fIncludeTreeIndent);
      for a := 0 to fAlternatives.Count - 1 do
        begin
          lCell := lRow.NewCell;
          var lCol := aColumns[a];
          if lCol >= 0 then lCell.Wr(fScaleStrings.ValueOnScaleComposite(fAlternatives[a].AsIntOffsets[aAtt], aAtt:Scale))
          else lCell.Wr(DexiString.SDexiUndefined);
        end;
    end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    TabAtt(aTable, aColumns, aAtt.Inputs[lIdx]);
end;

method DexiTreeQQEvaluationReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  Columns := Parameters.SelectedColumns;
  var lTableColumns := PrepareColumns(Columns, false);
  var lAllColumns := DexiReport.BreakColumns(lTableColumns, Parameters.MaxColumns);
  if (lAllColumns = nil) or (lAllColumns.Count = 0) then
    exit;
  for lColumns in lAllColumns do
    begin
      fAlternatives := Model.EvaluateWithOffsets(lColumns);
      var lTitle := MakeTitle(lColumns);
      var lSection := Report.NewSection(lTitle, Report.SectionBreak);
      lSection.NewLine.Wr(lTitle, FormatSection);
      lSection.NewLine;
      var lTable := lSection.NewTable(lTitle);
      TabColumns(lTable, lColumns);
      TabHead(lTable, lColumns);
      for lAtt in Rooted(Root) do
        TabAtt(lTable, lColumns, lAtt);
      lSection.NewLine;
    end;
end;

{$ENDREGION}

{$REGION DexiFunctionsReport}

method DexiFunctionsReport.GetReportType: String;
begin
  result := 'FUNCTIONS';
end;

method DexiFunctionsReport.TabColumns(aTable: RptTable);
begin
  aTable.AddColumn(DexiString.RAttribute);
  aTable.AddColumn('Items');
  aTable.AddColumn('Defined');
  aTable.AddColumn('Determined');
  if Parameters.FncStatus then
    aTable.AddColumn('Status');
  aTable.AddColumn('Values');
end;

method DexiFunctionsReport.TabHead(aTable: RptTable);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  lHead.NewCell.Wr(DexiString.RItems, FormatTableHead).HIntAlign := RptAlign.Last;
  lHead.NewCell.Wr(DexiString.RDefined, FormatTableHead).HIntAlign := RptAlign.Last;
  lHead.NewCell.Wr(DexiString.RDetermined, FormatTableHead).HIntAlign := RptAlign.Last;
  if Parameters.FncStatus then
    lHead.NewCell.Wr(DexiString.RStatus, FormatTableHead);
  lHead.NewCell.Wr(DexiString.RValues, FormatTableHead);
  lHead.EndLiner;
end;

method DexiFunctionsReport.TabAtt(aTable: RptTable; aAtt: DexiAttribute);

  method WrPercent(lRow: RptRow; aPercent: Float);
  begin
    var lCell := lRow.NewCell;
    lCell.Wr(Utils.FltToStr(100.0 * aPercent, Parameters.DefDetDecimals, false));
    lCell.HIntAlign := RptAlign.Last;
  end;

begin
  var lRow := aTable.NewRow;
  var lCell := lRow.NewCell;
  WrTreeAttribute(lCell, aAtt);
  if aAtt:Funct = nil then
    begin
      if (aAtt = Model.Root) or not aAtt.IsAggregate then
        lRow.NewCell.NewLine.Wr('')
      else
        lRow.NewMultiCell(aTable.ColCount - 1).Wr(DexiString.RFncUndefined).HIntAlign := RptAlign.Middle;
    end
  else
    begin
      var lFunct := aAtt.Funct;
      lFunct.ReviseFunction(true);
      lCell := lRow.NewCell;
      lCell.Wr(lFunct.ItemRatio);
      lCell.HIntAlign := RptAlign.Last;
      WrPercent(lRow, lFunct.Defined);
      WrPercent(lRow, lFunct.Determined);
      if Parameters.FncStatus then
        lRow.NewCell.Wr(lFunct.FunctStatus);
      lRow.NewCell.Wr(lFunct.FunctClassDistr);
    end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    TabAtt(aTable, aAtt.Inputs[lIdx]);
end;

method DexiFunctionsReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  var lTitle := DexiString.RAttFncInformation;
  var lSection := Report.NewSection(lTitle, Report.SectionBreak);
  lSection.NewLine.Wr(lTitle, FormatSection);
  lSection.NewLine;
  var lTable := lSection.NewTable(lTitle);
  TabColumns(lTable);
  TabHead(lTable);
  for lAtt in Rooted(Root) do
    TabAtt(lTable, lAtt);
  lSection.NewLine;
end;

{$ENDREGION}

{$REGION DexiWeightsReport}

method DexiWeightsReport.GetReportType: String;
begin
  result := 'WEIGHTS';
end;

method DexiWeightsReport.TabColumns(aTable: RptTable);
begin
  aTable.AddColumn(DexiString.RAttribute);
  if Parameters.WeightsLocal then
    aTable.AddColumn('Local');
  if Parameters.WeightsGlobal then
    aTable.AddColumn('Global');
  if Parameters.WeightsLocalNormalized then
    aTable.AddColumn('LocalNormalized');
  if Parameters.WeightsGlobalNormalized then
    aTable.AddColumn('GlobalNormalized');
end;

method DexiWeightsReport.TabHead(aTable: RptTable);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  if Parameters.WeightsLocal then
    lHead.NewCell.Wr(DexiString.RLocal, FormatTableHead).HIntAlign := RptAlign.Last;
  if Parameters.WeightsGlobal then
    lHead.NewCell.Wr(DexiString.RGlobal, FormatTableHead).HIntAlign := RptAlign.Last;
  if Parameters.WeightsLocalNormalized then
    lHead.NewCell.Wr(DexiString.RLocNorm, FormatTableHead).HIntAlign := RptAlign.Last;
  if Parameters.WeightsGlobalNormalized then
    lHead.NewCell.Wr(DexiString.RGlobNorm, FormatTableHead).HIntAlign := RptAlign.Last;
  lHead.EndLiner;
end;

method DexiWeightsReport.TabAtt(aTable: RptTable; aAtt: DexiAttribute; aWA, aWN: Float);

  method WrWeight(lRow: RptRow; aWeight: Float);
  begin
    var lCell := lRow.NewCell;
    lCell.Wr(Utils.FltToStr(aWeight, Parameters.WeiDecimals, false));
    lCell.HIntAlign := RptAlign.Last;
  end;

begin
  var lRow := aTable.NewRow;
  var lCell := lRow.NewCell;
  WrTreeAttribute(lCell, aAtt);
  var lWA := 1.0;
  var lWN := 1.0;
  if aAtt:Parent:Funct = nil then
    begin
      if (aAtt:Parent = Model.Root) then
        lRow.NewCell.NewLine.Wr('')
      else
        lRow.NewMultiCell(aTable.ColCount - 1).Wr(DexiString.RFncParentUndefined).HIntAlign := RptAlign.Middle;
    end
  else if aAtt.Parent.Funct is not DexiTabularFunction then
    lRow.NewCell.Wr('')
  else
    begin
      var lFunct := DexiTabularFunction(aAtt.Parent.Funct);
      var lIdx := aAtt.Parent.InpIndex(aAtt);
      lWA := lFunct.ActualWeights[lIdx] / 100.0;
      lWN := lFunct.NormActualWeights[lIdx] / 100.0;
      if Parameters.WeightsLocal then
        WrWeight(lRow, 100.0 * lWA);
      if Parameters.WeightsGlobal then
        WrWeight(lRow, 100.0 * lWA * aWA);
      if Parameters.WeightsLocalNormalized then
        WrWeight(lRow, 100.0 * lWN);
      if Parameters.WeightsGlobalNormalized then
        WrWeight(lRow, 100.0 * lWN * aWN);
    end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    TabAtt(aTable, aAtt.Inputs[lIdx], lWA * aWA, lWN * aWN);
end;

method DexiWeightsReport.CalcWeights(aAtt: DexiAttribute);
begin
  var lFunct := DexiTabularFunction(aAtt.Funct);
  if lFunct <> nil then
    lFunct.CalcActualWeights(true);
  for i :=0 to aAtt.InpCount-1 do
    CalcWeights(aAtt.Inputs[i]);
end;

method DexiWeightsReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  if not (Parameters.WeightsLocal or Parameters.WeightsGlobal or Parameters.WeightsLocalNormalized or Parameters.WeightsLocalNormalized) then
    exit;
  var lTitle := DexiString.RAverageWeights;
  var lSection := Report.NewSection(lTitle, Report.SectionBreak);
  lSection.NewLine.Wr(lTitle, FormatSection);
  lSection.NewLine;
  var lTable := lSection.NewTable(lTitle);
  TabColumns(lTable);
  TabHead(lTable);
  for lAtt in Rooted(Root) do
    begin
      CalcWeights(lAtt);
      TabAtt(lTable, lAtt, 1.0, 1.0);
    end;
  lSection.NewLine;
end;

{$ENDREGION}

{$REGION DexiSelectiveExplanationReport}

method DexiSelectiveExplanationReport.GetReportType: String;
begin
  result := 'SELECTIVE';
end;

method DexiSelectiveExplanationReport.TabColumns(aTable: RptTable);
begin
  aTable.AddColumn(DexiString.RAttribute);
  aTable.AddColumn(DexiString.RAlternative);
end;

method DexiSelectiveExplanationReport.TabHead(aTable: RptTable; aAlt: Integer);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  lHead.NewCell.Wr(Model.Alternative[aAlt].Name, FormatTableHead);
  lHead.EndLiner;
end;

method DexiSelectiveExplanationReport.TabAtt(aTable: RptTable; aAtt: DexiAttribute; aAlt: Integer);
begin
  var lValue := Model.Alternative[aAlt].Value[aAtt];
  var lRow := aTable.NewRow;
  var lCell := lRow.NewCell;
  WrTreeAttribute(lCell, aAtt, true, false);
  lCell := lRow.NewCell;
  lCell.Wr(fScaleStrings.ValueOnScaleComposite(lValue, aAtt.Scale));
end;

method DexiSelectiveExplanationReport.CollectAttributes(aAtt: DexiAttribute; aAlt: Integer; aList: DexiAttributeList; aGood: Boolean);
begin
  if Parameters.IsSelected(aAtt) and (aAtt:Scale <> nil) then
    begin
      var lValue := Model.Alternative[aAlt].Value[aAtt];
      var lCond :=
        if aGood then aAtt.Scale.IsGood(lValue)
        else aAtt.Scale.IsBad(lValue);
      if lCond then
        aList.Add(aAtt);
    end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    CollectAttributes(aAtt.Inputs[lIdx], aAlt, aList, aGood);
end;

method DexiSelectiveExplanationReport.Selective(aSection: RptSection; aAlt: Integer; aGood: Boolean; aHead: String);
begin
  ClearParents;
  aSection.NewLine.Wr(aHead);
  aSection.NewLine;
  var lList := new DexiAttributeList;
  for lAtt in Rooted(Root) do
    CollectAttributes(lAtt, aAlt, lList, aGood);
  if lList.Count = 0 then
    aSection.NewLine.Wr(DexiString.RNone)
  else
    begin
      var lTable := aSection.NewTable($'Alternative {aAlt}');
      TabColumns(lTable);
      TabHead(lTable, aAlt);
      for each lAtt in lList do
        TabAtt(lTable, lAtt, aAlt);
    end;
  aSection.NewLine;
end;

method DexiSelectiveExplanationReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
begin
  BeginReport(aClear);
  var lTitle := DexiString.RSelectiveExplanation;
  var lSection := Report.NewSection(lTitle, Report.SectionBreak);
  lSection.NewLine.Wr(lTitle, FormatSection);
  lSection.NewLine;
  for lAlt := 0 to Model.AltCount - 1 do
    if Parameters.IsSelected(lAlt) then
      begin
        lSection := Report.NewSection($'Alternative {lAlt}', Report.SectionBreak);
        var lLine := lSection.NewLine;
        lLine.Wr(DexiString.RAlternative + ': ');
        lLine.Wr(Model.Alternative[lAlt].Name, RptFormatSettings.BoldFormat);
        lSection.NewLine;
        Selective(lSection, lAlt, false, DexiString.RWeakPoints);
        Selective(lSection, lAlt, true, DexiString.RStrongPoints);
      end;
end;

{$ENDREGION}

{$REGION DexiAlternativeComparisonReport}

method DexiAlternativeComparisonReport.GetReportType: String;
begin
  result := 'COMPARE';
end;

method DexiAlternativeComparisonReport.TabColumns(aTable: RptTable; aColumns: IntArray);
begin
  aTable.AddColumn(DexiString.RAttribute);
  aTable.AddColumn($'Main alternative');
  for i := low(aColumns) to high(aColumns) do
    aTable.AddColumn($'Alternative {i}');
end;

method DexiAlternativeComparisonReport.TabHead(aTable: RptTable; aColumns: IntArray);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  lHead.NewCell.Wr(Model.Alternative[Parameters.Alternative].Name, FormatTableHead);
  for i := low(aColumns) to high(aColumns) do
    lHead.NewCell.Wr(Model.Alternative[aColumns[i]].Name, FormatTableHead);
  lHead.EndLiner;
end;

method DexiAlternativeComparisonReport.CompareString(aCompare: DeepComparison): String;
begin
  result :=
    case aCompare.Here of
      PrefCompare.Equal:
        case aCompare.Below of
          PrefCompare.Greater: DexiString.SBetterEq;
          PrefCompare.Lower:   DexiString.SWorseEq;
          PrefCompare.No:   DexiString.SPrefEq + DexiString.SPrefNone;
          else DexiString.SPrefEq;
        end;
      PrefCompare.Greater: DexiString.SPrefBetter;
      PrefCompare.Lower:   DexiString.SPrefWorse;
      PrefCompare.No:      DexiString.SPrefNone;
    end;
  if not String.IsNullOrEmpty(result) then
    result := result + ' ';
end;

method DexiAlternativeComparisonReport.TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute);
begin
  if (aAtt <> nil) and Parameters.IsSelected(aAtt) then
    begin
      var lRow := aTable.NewRow;
      var lCell := lRow.NewCell;
      WrTreeAttribute(lCell, aAtt);
      lCell := lRow.NewCell;
      var lMainValue := Model.AltValue[Parameters.Alternative, aAtt];
      lCell.Wr(fScaleStrings.ValueOnScaleComposite(lMainValue, aAtt:Scale));
      for i := low(aColumns) to high(aColumns) do
        begin
          lCell := lRow.NewCell;
          if Parameters.DeepCompare then
            begin
              var lCompare := fDeepComparisons[i][aAtt];
              lCell.Wr(CompareString(lCompare));
            end;
          var lAlt := aColumns[i];
          var lValue := Model.AltValue[lAlt, aAtt];
          var lMethod :=
            if (aAtt:Scale = nil) or aAtt.Scale.IsDiscrete then DexiValueMethod.Distr
            else DexiValueMethod.Single;
          var lCompare := DexiScale.CompareValues(lMainValue, lValue, aAtt:Scale, lMethod);
          if lCompare <> PrefCompare.Equal then
            lCell.Wr(fScaleStrings.ValueOnScaleComposite(lValue, aAtt:Scale));
        end;
    end;
  for lIdx := 0 to aAtt.InpCount - 1 do
    TabAtt(aTable, aColumns, aAtt.Inputs[lIdx]);
end;

method DexiAlternativeComparisonReport.MakeComparisons(aColumns: IntArray);
begin
  fDeepComparisons := nil;
  if not Parameters.DeepCompare then
    exit;
  fDeepComparisons := new List<Dictionary<DexiAttribute, DeepComparison>>;
  for i := low(aColumns) to high(aColumns) do
    begin
      var lCompare := Model.DeepCompare(Model.Alternative[Parameters.Alternative], Model.Alternative[aColumns[i]]);
      fDeepComparisons.Add(lCompare);
    end;
end;

method DexiAlternativeComparisonReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
  0 <= Parameters.Alternative < Model.AltCount;
begin
  BeginReport(aClear);
  var lSelectedColumns := PrepareColumns(Parameters.SelectedColumns, Alternative);
  var lAllColumns := DexiReport.BreakColumns(lSelectedColumns, Parameters.MaxColumns - 1);
  if (lAllColumns = nil) or (lAllColumns.Count = 0) then
    exit;
  for lColumns in lAllColumns do
    begin
      MakeComparisons(lColumns);
      var lTitle := DexiString.RAltCompare;
      var lSection := Report.NewSection(lTitle, Report.SectionBreak);
      lSection.NewLine.Wr(lTitle, FormatSection);
      lSection.NewLine;
      var lTable := lSection.NewTable(lTitle);
      TabColumns(lTable, lColumns);
      TabHead(lTable, lColumns);
      for lAtt in Rooted(Root) do
        TabAtt(lTable, lColumns, lAtt);
      lSection.NewLine;
    end;
end;

{$ENDREGION}

{$REGION DexiPlusMinusReport}

class method DexiPlusMinusReport.ValidAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := (aAtt:Scale <> nil) and aAtt.Scale.IsDiscrete and (aAtt.Scale.Count >= 2);
end;

method DexiPlusMinusReport.GetReportType: String;
begin
  result := 'PLUS/MINUS';
end;

method DexiPlusMinusReport.GetNeedsRoot: Boolean;
begin
  result := true;
end;

method DexiPlusMinusReport.TabColumns(aTable: RptTable; aRange: IntArray);
begin
  aTable.AddColumn(DexiString.RAttribute);
  for i := low(aRange) to high(aRange) do
    aTable.AddColumn(Utils.IntToStr(aRange[i]));
end;

method DexiPlusMinusReport.TabHead(aTable: RptTable; aRange: IntArray);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  for i := low(aRange) to high(aRange) do
    if aRange[i] = 0 then
      lHead.NewCell.Wr(Model.Alternative[Alternative].Name, FormatTableHead)
    else if aRange[i] > 0 then
      lHead.NewCell.Wr('+' + Utils.IntToStr(aRange[i]), FormatTableHead)
    else lHead.NewCell.Wr(Utils.IntToStr(aRange[i]), FormatTableHead);
  lHead.EndLiner;
end;

method DexiPlusMinusReport.TabRoot(aTable: RptTable; aRange: IntArray);
begin
  var lRow := aTable.NewRow;
  lRow.Liner;
  var lCell := lRow.NewCell;
  lCell.Tree(Root.TreeIndent);
  lCell.Wr(Root.Name, AttFormat(Root));
  for i := low(aRange) to high(aRange) do
    begin
      lCell := lRow.NewCell;
      if aRange[i] = 0 then
        begin
          var lMainValue := Model.Alternative[Alternative].Value[Root];
          lCell.Wr(fScaleStrings.ValueOnScaleComposite(lMainValue, Root:Scale))
        end;
    end;
  lRow.EndLiner;
end;

method DexiPlusMinusReport.TabAtt(aTable: RptTable; aRange: IntArray; aColumns: List<IDexiAlternative>; aAtt: DexiAttribute);
begin
  var lAtt :=
    if aAtt.IsLinked then aAtt.Link
    else aAtt;
  if (lAtt <> nil) and lAtt.IsBasic and (lAtt.Scale is DexiDiscreteScale) and
    (Parameters.IsSelected(lAtt) or Parameters.IsSelected(lAtt))
  then
    begin
      var lScale := DexiDiscreteScale(lAtt.Scale);
      var lRow := aTable.NewRow;
      var lCell := lRow.NewCell;
      var lRootValue := Model.Alternative[Alternative].Value[Root];
      var lMainValue := Model.Alternative[Alternative].Value[lAtt];
      if DexiValue.ValueIsDefined(lMainValue) then
        begin
          WrTreeAttribute(lCell, lAtt);
          var lLow := lMainValue.LowInt;
          var lHigh := lMainValue.HighInt;
          for i := low(aRange) to high(aRange) do
            begin
              lCell := lRow.NewCell;
              if aRange[i] = 0 then
                lCell.Wr(fScaleStrings.ValueOnScaleComposite(lMainValue, lScale))
              else
                begin
                  var lValue := aColumns[i].Value[lAtt];
                  if lLow + aRange[i] = -1 then
                    begin
                      lCell.HIntAlign := RptAlign.Last;
                      lCell.Wr('[');
                    end
                  else if lHigh + aRange[i] = lScale.Count then
                    lCell.Wr(']')
                  else if (lValue <> nil) and not DexiValue.ValuesAreEqual(lRootValue, lValue) then
                    lCell.Wr(fScaleStrings.ValueOnScaleComposite(lValue, Root:Scale));
                end;
            end;
        end;
    end;
  for lIdx := 0 to lAtt.InpCount - 1 do
    TabAtt(aTable, aRange, aColumns, lAtt.Inputs[lIdx]);
end;

method DexiPlusMinusReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
  ValidAttribute(Parameters.Root);
  0 <= Parameters.Alternative < Model.AltCount;
begin
  BeginReport(aClear);
  var lRange := Utils.RangeArray(Parameters.MinusSteps + Parameters.PlusSteps + 1, -Parameters.MinusSteps);
  var lColumns := new List<IDexiAlternative>;
  for lDiff in lRange do
    begin
      var lAlt: IDexiAlternative :=
        if lDiff = 0 then
          Model.Alternative[Parameters.Alternative]
        else Model.PlusMinus(Parameters.Alternative, lDiff, Root);
      lColumns.Add(lAlt);
    end;
  var lTitle := DexiString.RPlusMinus;
  var lSection := Report.NewSection(lTitle, Report.SectionBreak);
  lSection.NewLine.Wr(lTitle, FormatSection);
  lSection.NewLine;
  var lTable := lSection.NewTable(lTitle);
  TabColumns(lTable, lRange);
  TabHead(lTable, lRange);
  TabRoot(lTable, lRange);
  TabAtt(lTable, lRange, lColumns, Root);
  lSection.NewLine;
end;

{$ENDREGION}

{$REGION DexiTargetReport}

class method DexiTargetReport.ValidAttribute(aAtt: DexiAttribute): Boolean;
begin
  result := (aAtt:Scale <> nil) and aAtt.Scale.IsDiscrete and (aAtt.Scale.Count >= 2);
end;

method DexiTargetReport.GetReportType: String;
begin
  result := 'TARGET';
end;

method DexiTargetReport.GetNeedsRoot: Boolean;
begin
  result := true;
end;

method DexiTargetReport.OnEmitCheck(aAssignment: IntArray; aFound: List<IntArray>): DexiGenCheck;
begin
  inc(fEmitCount);
  result :=
    if fEmitCount > Parameters.MaxGenerate then DexiGenCheck.Terminate
    else DexiGenCheck.Proceed;
end;

method DexiTargetReport.PrepareAttributeLists;
begin
  fPruned := new DexiAttributeList;
  fConstants := new DexiAttributeList;
  var lInputs := Parameters.Root.CollectInputs(false);
  for each lAtt in lInputs do
    if lAtt.IsAggregate then
      begin
        if Parameters.IsSelected(lAtt) then
          fPruned.Add(lAtt);
      end
    else
      begin
        if not Parameters.IsSelected(lAtt) then
          begin
            fConstants.Add(lAtt);
            if lAtt.Link <> nil then
              fConstants.Add(lAtt.Link);
          end;
      end;
end;

method DexiTargetReport.Generate: DexiAlternatives;
begin
  PrepareAttributeLists;
  var lGenerator := new DexiGenerator(Root, fPruned);
  lGenerator.Alternative := Model.Alternative[Parameters.Alternative].Copy;
  lGenerator.Constants := fConstants;
  lGenerator.Unidirectional := Parameters.Unidirectional;
  lGenerator.MaxSteps := Parameters.MaxSteps;
  lGenerator.OnEmitCheck := @OnEmitCheck;
  fEmitCount := 0;
  fGenerated :=
    if Parameters.Improve then lGenerator.Improve
    else lGenerator.Degrade;
end;

method DexiTargetReport.TabColumns(aTable: RptTable; aColumns: IntArray);
begin
  aTable.AddColumn(DexiString.RAttribute);
  aTable.AddColumn($'Main alternative');
  for i := low(aColumns) to high(aColumns) do
    aTable.AddColumn($'Alternative {aColumns[i]}');
end;

method DexiTargetReport.TabHead(aTable: RptTable; aColumns: IntArray);
begin
  var lHead := aTable.NewRow;
  lHead.Liner;
  lHead.NewCell.Wr(DexiString.RAttribute, FormatTableHead);
  lHead.NewCell.Wr(Model.Alternative[Parameters.Alternative].Name, FormatTableHead);
  for i := low(aColumns) to high(aColumns) do
    lHead.NewCell.Wr(Utils.IntToStr(aColumns[i] + 1), FormatTableHead);
  lHead.EndLiner;
end;

method DexiTargetReport.TabAtt(aTable: RptTable; aColumns: IntArray; aAtt: DexiAttribute);
begin
  var lAtt :=
    if aAtt.IsLinked then aAtt.Link
    else aAtt;
  var lRow := aTable.NewRow;
  var lCell := lRow.NewCell;
  WrTreeAttribute(lCell, aAtt);
  lCell := lRow.NewCell;
  var lMainValue := Model.AltValue[Parameters.Alternative, lAtt];
  lCell.Wr(fScaleStrings.ValueOnScaleComposite(lMainValue, lAtt:Scale));
  for i := low(aColumns) to high(aColumns) do
    begin
      lCell := lRow.NewCell;
      var lAlt := fGenerated[aColumns[i]];
      var lValue := lAlt.Value[lAtt];
      if DexiValue.ValuesAreEqual(lMainValue, lValue) then
        begin
          if fConstants.Contains(lAtt) then
            lCell.Wr('.');
        end
      else
        lCell.Wr(fScaleStrings.ValueOnScaleComposite(lValue, lAtt:Scale));
    end;
  if not fPruned.Contains(aAtt) then
    for lIdx := 0 to aAtt.InpCount - 1 do
      TabAtt(aTable, aColumns, aAtt.Inputs[lIdx]);
end;

method DexiTargetReport.MakeReport(aClear: Boolean := true);
require
  Model <> nil;
  Root <> nil;
  0 <= Parameters.Alternative < Model.AltCount;
begin
  BeginReport(aClear);
  Generate;
  var lTitle := DexiString.RTarget;
  var lSection := Report.NewSection(lTitle, Report.SectionBreak);
  lSection.NewLine.Wr(lTitle, FormatSection);
  lSection.NewLine;
  if (fGenerated = nil) or (fGenerated.AltCount = 0) then
    lSection.NewLine.Wr(DexiString.RAltGenNoResults)
  else
    begin
      var lTableColumns := Utils.RangeArray(Math.Min(fGenerated.AltCount, Parameters.MaxShow), 0);
      var lAllColumns := DexiReport.BreakColumns(lTableColumns, Parameters.MaxColumns - 1);
      for lColumns in lAllColumns do
        begin
          var lTable := lSection.NewTable(lTitle);
          TabColumns(lTable, lColumns);
          TabHead(lTable, lColumns);
          TabAtt(lTable, lColumns, Root);
          lSection.NewLine;
        end;
    end;
end;

{$ENDREGION}

{$REGION DexiReportGroup}

method DexiReportGroup.GetReportType: String;
begin
  result := 'REPORTS';
end;

method DexiReportGroup.GetRptCount: Integer;
begin
  result :=
    if fReports = nil then 0
    else fReports.Count;
end;

method DexiReportGroup.GetReport(aIdx: Integer): DexiReport;
begin
  result := fReports[aIdx];
end;

method DexiReportGroup.SetFormat(aFormat: DexiReportFormat);
begin
  inherited SetFormat(aFormat);
  for i := 0 to RptCount - 1 do
    Report[i].Format := aFormat;
end;

method DexiReportGroup.CollectUndoableObjects(aList: List<IUndoable>);
begin
  inherited CollectUndoableObjects(aList);
  UndoUtils.IncludeRecursive(aList, fReports);
end;

method DexiReportGroup.EqualStateAs(aObj: IUndoable): Boolean;
begin
  if aObj is not DexiReportGroup then
    exit false;
  if aObj = self then
    exit true;
  var lRpt := DexiReportGroup(aObj);
  if not inherited EqualStateAs(lRpt) then
    exit false;
  result := Utils.EqualLists(lRpt.fReports, fReports);
end;

method DexiReportGroup.GetUndoState: IUndoable;
begin
  var lRptGrp := NewReport(ReportType, Parameters, ChartParameters, new DexiReportFormat(Format)) as DexiReportGroup;
  lRptGrp.Title := Title;
  lRptGrp.fReports :=
    if fReports = nil then nil
    else new List<DexiReport>(fReports);
  result := lRptGrp;
end;

method DexiReportGroup.SetUndoState(aState: IUndoable);
begin
  inherited SetUndoState(aState);
  var lRptGrp := aState as DexiReportGroup;
  fReports :=
    if lRptGrp.Reports =  nil then nil
    else new List<DexiReport>(lRptGrp.fReports);
end;

method DexiReportGroup.ReportIndex(aRpt: DexiReport): Integer;
begin
  result :=
    if fReports = nil then -1
    else fReports.IndexOf(aRpt);
end;

method DexiReportGroup.AddReport(aRpt: DexiReport);
require
  aRpt <> nil;
begin
  if fReports = nil then
    fReports := new List<DexiReport>;
  fReports.Add(aRpt);
  aRpt.Format := Format;
  Model.Modified := true;
end;

method DexiReportGroup.InsertReport(aIdx: Integer; aRpt: DexiReport);
begin
  if 0 <= aIdx < RptCount then
    begin
      fReports.Insert(aIdx, aRpt);
      aRpt.Format := Format;
      Model.Modified := true;
    end
  else
    AddReport(aRpt);
end;

method DexiReportGroup.RemoveReport(aRpt: DexiReport);
begin
  fReports.Remove(aRpt);
  Model.Modified := true;
end;

method DexiReportGroup.RemoveReport(aIdx: Integer): DexiReport;
begin
  fReports.RemoveAt(aIdx);
  Model.Modified := true;
end;

method DexiReportGroup.MoveReport(aFrom, aTo: Integer);
begin
  Utils.MoveList(fReports, aFrom, aTo);
  Model.Modified := true;
end;

method DexiReportGroup.MoveReport(aRpt: DexiReport; aTo: Integer);
begin
  var lIdx := ReportIndex(aRpt);
  MoveReport(lIdx, aTo);
end;

method DexiReportGroup.MoveReportPrev(aRpt: DexiReport);
begin
  var lIdx := ReportIndex(aRpt);
  MoveReportPrev(lIdx);
end;

method DexiReportGroup.MoveReportPrev(aIdx: Integer);
begin
  MoveReport(aIdx, aIdx - 1);
end;

method DexiReportGroup.MoveReportNext(aRpt: DexiReport);
begin
  var lIdx := ReportIndex(aRpt);
  MoveReportNext(lIdx);
end;

method DexiReportGroup.MoveReportNext(aIdx: Integer);
begin
  MoveReport(aIdx, aIdx + 1);
end;

method DexiReportGroup.AddAlternative(aAlt: Integer);
begin
  for each lRpt in fReports do
    if lRpt.Parameters <> nil then
      lRpt.Parameters.AddAlternative(aAlt);
end;

method DexiReportGroup.DeleteAlternative(aAlt: Integer);
begin
  var lToDelete := new List<DexiReport>;
  for each lRpt in fReports do
    if lRpt.Parameters <> nil then
      if lRpt.Parameters.Alternative = aAlt then
        lToDelete.Add(lRpt)
      else
        lRpt.Parameters.DeleteAlternative(aAlt);
  for each lRpt in lToDelete do
    fReports.Remove(lRpt);
end;

method DexiReportGroup.MoveAlternative(aFrom, aTo: Integer);
begin
  for each lRpt in fReports do
    if lRpt.Parameters <> nil then
      lRpt.Parameters.MoveAlternative(aFrom, aTo);
end;

method DexiReportGroup.MoveAlternativePrev(aAlt: Integer);
begin
  for each lRpt in fReports do
    if lRpt.Parameters <> nil then
      lRpt.Parameters.MoveAlternativePrev(aAlt);
end;

method DexiReportGroup.MoveAlternativeNext(aAlt: Integer);
begin
  for each lRpt in fReports do
    if lRpt.Parameters <> nil then
      lRpt.Parameters.MoveAlternativeNext(aAlt);
end;

method DexiReportGroup.ExchangeAlternatives(aIdx1, aIdx2: Integer);
begin
  for each lRpt in fReports do
    if lRpt.Parameters <> nil then
      lRpt.Parameters.ExchangeAlternatives(aIdx1, aIdx2);
end;

method DexiReportGroup.UpdateAttributeSelection;
begin
  var lInputs := Model.Root.CollectInputs(true);
  var lToDelete := new List<DexiReport>;
  for each lRpt in fReports do
    if not lRpt.AdaptToAttributes(lInputs) then
      lToDelete.Add(lRpt);
  for each lRpt in lToDelete do
    fReports.Remove(lRpt);
end;

method DexiReportGroup.SettingsChanged;
begin
  inherited SettingsChanged;
  for each lRpt in fReports do
    lRpt.SettingsChanged;
end;

method DexiReportGroup.MakeReport(aClear: Boolean := true);
begin
  UpdateAttributeSelection;
  BeginReport(aClear);
  for each lRpt in fReports do
    if lRpt.Selected then
      begin
        lRpt.MakeReport;
        for each lElement in lRpt.Report.Elements do
          Report.Add(lElement);
      end;
end;

{$ENDREGION}

{$REGION DexiChartReport}

method DexiChartReport.GetChartParameters: DexiChartParameters;
begin
  result := fChartParameters;
end;

method DexiChartReport.SetChartParameters(aParameters: DexiChartParameters);
begin
  fChartParameters :=
    if aParameters = nil then nil
    else new DexiChartParameters(aParameters);
  Model.Modified := true;
  if fChartParameters <> nil then
    Parameters.AssignSelection(fChartParameters);
end;

method DexiChartReport.GetReportType: String;
begin
  result := 'CHART';
end;

method DexiChartReport.Copy: DexiReport;
begin
  result := inherited &Copy;
  var lResult := DexiChartReport(result);
  if lResult = nil then exit;
  lResult.fWidth := fWidth;
  lResult.fheight := fHeight;
  lResult.fAutoScale := fAutoScale;
  lResult.fMakeImage := fMakeImage;
end;

method DexiChartReport.AdaptSelectedAttributes(aAttList: DexiAttributeList): Boolean;
begin
  result := true;
  if ChartParameters:SelectedAttributes = nil then
    exit false;
  var lSelected := Parameters.SelectedAttributes.ToArray;
  for each lAtt in lSelected do
    if not aAttList.Contains(lAtt) then
      exit false;
end;

method DexiChartReport.MakeReport(aClear: Boolean := true);
begin
  BeginReport(aClear);
  var lSection := Report.NewSection(DexiString.RModDesc, Report.SectionBreak);
  lSection.NewLine.Wr('Chart Report', FormatSection);
  lSection.NewLine;
  var lImage :=
    if assigned(fMakeImage) then MakeImage(Parameters.Model, ChartParameters, Width, Height)
    else nil;
  if lImage <> nil then
    lSection.NewLine.Wr(lImage, fAutoScale)
  else
    lSection.NewLine.Wr(DexiString.RImageUndefined);
  lSection.NewLine;
end;

{$ENDREGION}

end.
