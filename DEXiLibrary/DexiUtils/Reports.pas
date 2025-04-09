// Reports.pas is part of
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
// Reports.pas implements basic functionality for handing reports in DEXi.
// Conceptually, a report is a possibly nested structure of report elements.
// Elements typically contain text, but there are also elements that contain images, formatting information, etc.
// Elements are of a particular size and can be formatted (aligned, stretched) in different ways.
// Elements can be grouped in group elements to form lines, paragraphs, sections, tables, etc.
// The whole report (class RptReport) is defined as a vertical group of elements (RptVerticalGroup).
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  RemObjects.Elements.RTL;

type
  RptDirection = public enum (Horizontal, Vertical);
  RptAlign = public enum (Fill, First, Middle, Last);
  RptUnit = public enum (Measure, Native, Line, MM, Inch, Pixel, Pt, NumChar, Em);
  RptTreePattern = public enum (None, PlusMinus, Dots, AllDots, Unicode, Lines);

type
  RptDimension = public class
  public
    class const Zero = new RptDimension(0, RptUnit.Pixel);
    constructor (aDistance: FmtDistance := 1.0; aUnit: RptUnit := RptUnit.Measure);
    method &Copy: RptDimension;
    method ToString: String; override;
    property Distance: FmtDistance;
    property &Unit: RptUnit;
  end;

type
  RptDimensions = public class
  private
    fHorizontal: RptDimension;
    fVertical: RptDimension;
  protected
    method GetDimension(aDirection: RptDirection): RptDimension;
    method SetDimension(aDirection: RptDirection; aDimension: RptDimension);
  public
    constructor (aHorizontal: RptDimension := nil; aVertical: RptDimension := nil);
    method &Copy: RptDimensions;
    method ToString: String; override;
    property Horizontal: RptDimension read fHorizontal write fHorizontal;
    property Vertical: RptDimension read fVertical write fVertical;
    property Dimension[aDirection: RptDirection]: RptDimension read GetDimension write SetDimension; default;
  end;

type
  RptBorders = public class
  private
    fLeft: RptDimension;
    fRight: RptDimension;
    fTop: RptDimension;
    fBottom: RptDimension;
  public
    constructor (aLeft: RptDimension := nil; aRight: RptDimension := nil; aTop: RptDimension := nil; aBottom: RptDimension := nil);
    method &Copy: RptBorders;
    method ToString: String; override;
    property Left: RptDimension read fLeft write fLeft;
    property Right: RptDimension read fRight write fRight;
    property Top: RptDimension read fTop write fTop;
    property Bottom: RptDimension read fBottom write fBottom;
  end;

type
  RptFormatSettings = public class
  private
    fStyle: String;
    fSizeFactor: Float;
  protected
  public
    class const BoldFormat = new RptFormatSettings(Bold := true);
    class const ItalicFormat = new RptFormatSettings(Italic := true);
    constructor (aStyle: String = nil; aSizeFactor: Float := 1.0);
    property FontName: String := nil;
    property Bold: Boolean := false;
    property Italic: Boolean := false;
    property Underlined: Boolean := false;
    property Style: String read fStyle write fStyle;
    property SizeFactor: Float read fSizeFactor write fSizeFactor;
  end;

type
  RptAligns = public class
  protected
    method GetAlignment(aDirection: RptDirection): RptAlign;
    method SetAlignment(aDirection: RptDirection; aAlign: RptAlign);
  public
    Horizontal: RptAlign;
    Vertical: RptAlign;
    constructor (aHorizontal, aVertical: RptAlign);
    method ToString: String; override;
    property Alignment[aDirection: RptDirection]: RptAlign read GetAlignment write SetAlignment; default;
    method &Copy: not nullable RptAligns;
  end;

type
  RptAligned = public class
  private
    fIntAlign: not nullable RptAligns;
    fExtAlign: not nullable RptAligns;
  public
    constructor;
    constructor (aAligned: RptAligned);
    property IntAlign: not nullable RptAligns read fIntAlign write fIntAlign;
    property ExtAlign: not nullable RptAligns read fIntAlign write fIntAlign;
    property HIntAlign: RptAlign read fIntAlign.Horizontal write fIntAlign.Horizontal;
    property VIntAlign: RptAlign read fIntAlign.Vertical write fIntAlign.Vertical;
    property HExtAlign: RptAlign read fExtAlign.Horizontal write fExtAlign.Horizontal;
    property VExtAlign: RptAlign read fExtAlign.Vertical write fExtAlign.Vertical;
  end;

type
  RptElement = public class (RptAligned)
  private
    fDimensions: RptDimensions;
  protected
    method GetText: String; virtual;
    method SetText(aText: String); virtual;
    method GetDirection: RptDirection; virtual;
    method SetDirection(aDirection: RptDirection); virtual;
    method SetHDimension(aDimension: RptDimension);
    method SetVDimension(aDimension: RptDimension);
    method GetDimension(aDirection: RptDirection): RptDimension;
    method SetDimension(aDirection: RptDirection; aDimension: RptDimension);
  public
    constructor;
    property Text: String read GetText write SetText;
    property Direction: RptDirection read GetDirection write SetDirection;
    property Dimensions: RptDimensions read fDimensions write fDimensions;
    property HDimension: RptDimension read fDimensions:Horizontal write SetHDimension;
    property VDimension: RptDimension read fDimensions:Vertical write SetVDimension;
    property Dimension[aDirection: RptDirection]: RptDimension read GetDimension write SetDimension;
    property IsNullOrEmpty: Boolean read String.IsNullOrEmpty(Text);
    property IsNull: Boolean read Text = nil;
    property IsEmpty: Boolean read Text = '';
  end;

type
  RptFill = public class (RptElement)
  private
    fDirection: RptDirection;
    fStrength: Integer;
  protected
    method GetDirection: RptDirection; override;
    method SetDirection(aDirection: RptDirection); override;
  public
    constructor (aDirection: RptDirection := RptDirection.Horizontal; aStrength: Integer := 1);
    property Strength: Integer read fStrength write fStrength;
  end;

type
  RptText = public class (RptElement)
  private
    fText: String;
  protected
    method GetText: String; override;
    method SetText(aText: String); override;
  public
    constructor (aText: String := nil);
  end;

type
  RptLines = public class (RptText)
  protected
    method GetDirection: RptDirection; override;
  end;

type
  IRptImage = public interface
    property Width: FmtLength read;
    property Height: FmtLength read;
    property ImageType: String read;
    property ImageString: String read;
  end;

type
  RptImage = public class (RptText)
  private
    fImage: IRptImage;
    fScaled: Float;
    fAutoScale: Boolean;
  protected
  public
    constructor (aImage: IRptImage; aText: String := nil);
    property Image: IRptImage read fImage write fImage;
    property Scaled: Float read fScaled write fScaled;
    property AutoScale: Boolean read fAutoScale write fAutoScale;
  end;

type
  RptFormattedText = public class (RptText)
  private
    fFormat: RptFormatSettings;
  public
    constructor (aText: String := nil; aFormat: RptFormatSettings := nil);
    property Format: RptFormatSettings read fFormat write fFormat;
  end;

type
  RptBeginFormat = public class (RptElement)
  private
    fFormat: RptFormatSettings;
    fEnd: RptEndFormat;
  public
    constructor (aFormat: RptFormatSettings := nil);
    property Format: RptFormatSettings read fFormat write fFormat;
    property EndFormat: RptEndFormat read fEnd write fEnd;
  end;

type
  RptEndFormat = public class (RptElement)
  private
    fBegin: RptBeginFormat;
  public
    constructor (aBegin: not nullable RptBeginFormat);
    property BeginFormat: RptBeginFormat read fBegin;
  end;

type
  RptBeginLiner = public class (RptElement)
  private
    fLines: Integer;
    fEnd: RptEndLiner;
  public
    constructor (aLines: Integer := 1);
    property EndLiner: RptEndLiner read fEnd write fEnd;
    property Lines: Integer read fLines write fLines;
  end;

type
  RptEndLiner = public class (RptElement)
  private
    fBegin: RptBeginLiner;
  public
    constructor (aBegin: not nullable RptBeginLiner);
    property BeginLiner: RptBeginLiner read fBegin;
  end;

type
  RptComposite = public class (RptElement)
  private
    fComposite: not nullable CompositeString;
  protected
    method GetText: String; override;
  public
    constructor (aComposite: not nullable CompositeString);
    property Composite: not nullable CompositeString read fComposite write fComposite;
  end;

type
  RptTreeParent = public class (RptText);

type
  RptTree = public class (RptText)
  private
    fParent: RptTreeParent;
    fIsParent: Boolean;
  public
    class method TreePattern(aIndent: Integer; aText, aNone, aThru, aLink, aLast, aLine: String): String;
    class method AllDotsPattern(aIndent: Integer; aText: String; aDot: String := '.'; aSpace: String := ' '): String;
    class const TreeNone = '.';
    class const TreeThru = '|';
    class const TreeLink = '*';
    class const TreeLast = '+';
    class const TreeLine = '-';
    constructor (aText: String; aParent: RptTreeParent := nil; aIsParent: Boolean := true);
    property Parent: RptTreeParent read fParent write fParent;
    property IsParent: Boolean read fIsParent write fIsParent;
  end;

type
  RptMacro = public class (RptText);

type
  RptGroup = public class (RptText)
  private
    fDirection: RptDirection;
    fElements: List<RptElement>;
    fLastFormat: RptBeginFormat;
    fLastLiner: RptBeginLiner;
    fLastSectionNumber: Integer;
    fLastTableNumber: Integer;
    class var fHalfHeight: Float := 0.5;
  protected
    method GetDirection: RptDirection; override;
    method SetDirection(aDirection: RptDirection); override;
  public
    constructor (aDirection: RptDirection; aElements: sequence of RptElement := nil);
    method Clear;
    method &Add(aElement: RptElement);
    method Wr(aText: String): RptText;
    method Wr(aImage: IRptImage; aAutoScale: Boolean := false; aText: String := nil): RptImage;
    method Wr(aText: String; aFormat: RptFormatSettings): RptFormattedText;
    method Wr(aComposite: CompositeString): RptComposite;
    method WrMacro(aText: String): RptMacro;
    method Tree(aText: String; aParent: RptTreeParent := nil; aIsParent: Boolean := true): RptTree;
    method Format(aFormat: RptFormatSettings): RptBeginFormat;
    method EndFormat: RptEndFormat;
    method Liner(aLines: Integer := 1): RptBeginLiner;
    method EndLiner: RptEndLiner;
    method HFill(aStrength: Integer := 1): RptFill;
    method VFill(aStrength: Integer := 1): RptFill;
    method NewLine(aHeight: Float := 1.0): RptLine;
    method HalfLine: RptLine;
    method NewLines(aText: String := nil): RptLines;
    method NewParagraph(aText: String := nil): RptParagraph;
    method NewSection(aTitle: String; aPageBreak: Integer := RptSection.BreakNone): RptSection;
    method NewTable(aTitle: String; aPageBreak: Integer := RptSection.BreakNone): RptTable;
    class property HalfHeight: Float read fHalfHeight write fHalfHeight;
    property Title: String read Text write Text;
    property Elements: List<RptElement> read fElements;
    property Element[aIdx: Integer]: RptElement read fElements[aIdx]; default;
    property Count: Integer read if fElements = nil then 0 else fElements.Count;
  end;

type
  RptHorizontalGroup = public class (RptGroup)
  public
    constructor (aElements: sequence of RptElement := nil);
  end;

type
  RptVerticalGroup = public class (RptGroup)
  public
    constructor (aElements: sequence of RptElement := nil);
  end;

type
  RptLine = public class (RptHorizontalGroup)
  private
    fHeight: Float;
  public
    constructor (aHeight: Float := 1.0);
    property Height: Float read fHeight;
  end;

type
  RptParagraph = public class (RptVerticalGroup);

type
  RptSection = public class (RptVerticalGroup)
  private
    fNumber: Integer;
    fPageBreak: Integer;
  public
    class const BreakUncond = -2;
    class const BreakAll = -1;
    class const BreakNone = 0;
    constructor (aTitle: String := nil; aPageBreak: Integer := BreakNone; aNumber: Integer := 0);
    property Number: Integer read fNumber write fNumber;
    property PageBreak: Integer read fPageBreak write fPageBreak;
  end;

type
  RptTable = public class (RptSection)
  private
    fColumns: List<String>;
    fCellGap: String;
  protected
    method GetColCount: Integer;
    method SetColCount(aCount: Integer);
  public
    constructor (aTitle: String := nil; aColCount: Integer := 0; aPageBreak: Integer := BreakNone; aNumber: Integer := 0);
    method AddColumn(aName: String);
    method NewRow: RptRow;
    property CellGap: String read fCellGap write fCellGap;
    property Columns: List<String> read fColumns;
    property ColCount: Integer read GetColCount write SetColCount;
  end;

type
  RptCell = public class (RptGroup)
  private
    fTable: not nullable RptTable;
    fFromColumn: Integer;
    fToColumn: Integer;
  public
    constructor (aTable: not nullable RptTable; aColumn: Integer; aColSpan: Integer := 1);
    property Table: not nullable RptTable read fTable;
    property FromColumn: Integer read fFromColumn;
    property ToColumn: Integer read fToColumn;
    property ColCount: Integer read fToColumn - fFromColumn + 1;
  end;

type
  RptRow = public class (RptLine)
  private
    fTable: not nullable RptTable;
    fNextColumn: Integer;
  public
    constructor (aTable: not nullable RptTable);
    property Table: not nullable RptTable read fTable;
    method SkipColumn;
    method SkipColumns(aColumns: Integer);
    method NewCell: RptCell;
    method NewMultiCell(aColumns: Integer): RptCell;
  end;

type
  RptReport = public class (RptVerticalGroup)
  private
    fHeader: RptGroup;
    fFooter: RptGroup;
    fDateTime: DateTime;
    fSectionBreak: Integer := RptSection.BreakNone;
    fTableBreak: Integer := RptSection.BreakNone;
    fTreePattern: RptTreePattern;
  public
    constructor;
    constructor (aReport: RptReport);
    property Header: RptGroup read fHeader write fHeader;
    property Footer: RptGroup read fFooter write fFooter;
    property DateTime: DateTime read fDateTime write fDateTime;
    property SectionBreak: Integer read fSectionBreak write fSectionBreak;
    property TableBreak: Integer read fTableBreak write fTableBreak;
    property TreePattern: RptTreePattern read fTreePattern write fTreePattern;
  end;

type
  RptMacroMapper = public method (aKey: String): String;

type
  RptWriter = public abstract class
  private
    fReport: RptReport;
    fBuild: StringBuilder;
    fActive: Boolean;
    fParents := new Dictionary<RptTreeParent, String>;
    fParentIdNumber := 0;
    fMacroMapper: RptMacroMapper := nil;
    fReportDate: DateTime;
  protected
    method AddParent(aParent: RptTreeParent): String;
    method ClearParents;
    method MapMacro(aKey: String): String; virtual;
    method DoMapMacro(aKey: String): String;
    property Parents: Dictionary<RptTreeParent, String> read fParents;
  public
    constructor (aReport: RptReport := nil);
    method WrRptElement(aRpt: RptElement); virtual; abstract;
    method AddReport(aReport: RptReport);
    method Finish; virtual;
    method Wr(aStr: String); virtual;
    method WrLn(aStr: String := nil); virtual;
    method WrBegin; virtual; empty;
    method WrEnd; virtual; empty;
    method WrRptBegin; virtual; empty;
    method WrRptEnd; virtual; empty;
    method WriteToFile(aFileName: String);
    property Report: RptReport read fReport;
    property AsString: String read fBuild.ToString;
    property MacroMapper: RptMacroMapper read fMacroMapper write fMacroMapper;
  end;

type
  RptJsonWriter = public class (RptWriter)
  private
  protected
    method WrJson(aName: String; aValue: String);
    method WrJson(aName: String; aValue: Integer);
    method WrJson(aName: String; aValue: Float);
    method WrJson(aName: String; aValue: Boolean);
    method WrAlign(aKey: String; aAlign: RptAlign);
    method WrAlignment(aRpt: RptElement);
    method WrElement(aName: String; aRpt: RptElement);
    method WrComposite(aStr: CompositeString);
    method WrFormat(aFmt: RptFormatSettings);
    method WrList(aList: List<String>);
  public
    method WrRptElement(aRpt: RptElement); override;
  end;

type
  RptTagMapper = public method (aTag: Integer): String;

type
  RptHtmlParameters = public class
  protected
  public
    constructor; empty;
    method TagMapper(aTag: Integer): String; virtual;
    method Style: String; virtual;
    method Script: String; virtual;
    method Head: String; virtual;
    method Foot: String; virtual;
    property HtmlTitle := 'HTML Title';
    property HtmlHead := 'HTML Head = Title: "{0}"; Style: "{1}"';
    property HtmlStyle := 'HTML Style';
    property HtmlScript := 'HTML Script';
    property HtmlFoot := 'HTML Foot';
    property TreeIndent := 2;
  end;

type
  RptHtmlWriter = public class (RptWriter)
  private
    fParameters: RptHtmlParameters;
    fInLiner: Boolean;
    fInTable: Boolean;
  protected
    method ElementIsAligned(aElement: RptCell; aAlign: RptAlign): Boolean;
    method WriteCell(aRpt: RptCell);
    method WriteRow(aRpt: RptRow);
    method WriteLine(aRpt: RptLine);
    method WriteLines(aRpt: RptLines);
    method WriteParagraph(aRpt: RptParagraph);
    method WriteTable(aRpt: RptTable);
    method WriteSection(aRpt: RptSection);
    method WriteGroup(aRpt: RptGroup);
    method WriteText(aText: String);
    method WriteText(aRpt: RptText);
    method WriteImage(aRpt: RptImage);
    method WriteMacro(aRpt: RptMacro);
    method BeginFormat(aFmt: RptFormatSettings);
    method EndFormat(aFmt: RptFormatSettings);
    method WriteFormattedText(aRpt: RptFormattedText);
    method WriteComposite(aRpt: RptComposite);
    method WriteFill(aRpt: RptFill);
    method WriteTreeParent(aRpt: RptTreeParent);
    method WriteTree(aRpt: RptTree);
  public
    constructor (aReport: RptReport := nil; aParameters: RptHtmlParameters := nil);
    method WrBegin; override;
    method WrEnd; override;
    method WrRptElement(aRpt: RptElement); override;
    property Parameters: RptHtmlParameters read fParameters write fParameters;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION RptDimension}

constructor RptDimension(aDistance: FmtDistance := 1.0; aUnit: RptUnit := RptUnit.Measure);
begin
  inherited constructor;
  Distance := aDistance;
  &Unit := aUnit;
end;

method RptDimension.Copy: RptDimension;
begin
  result := new RptDimension(Distance, &Unit);
end;

method RptDimension.ToString: String;
begin
  result := $"{Distance} {&Unit}";
end;

{$ENDREGION}

{$REGION RptDimensions}

constructor RptDimensions(aHorizontal: RptDimension := nil; aVertical: RptDimension := nil);
begin
  inherited constructor;
  fHorizontal := aHorizontal;
  if fHorizontal = nil then
    fHorizontal := RptDimension.Zero;
  fVertical := aVertical;
  if fVertical = nil then
    fVertical := RptDimension.Zero;
end;

method RptDimensions.GetDimension(aDirection: RptDirection): RptDimension;
begin
  result :=
    if aDirection = RptDirection.Horizontal then fHorizontal
    else fVertical;
end;

method RptDimensions.SetDimension(aDirection: RptDirection; aDimension: RptDimension);
begin
  if aDirection = RptDirection.Horizontal then
    fHorizontal := aDimension
  else
    fVertical := aDimension;
end;

method RptDimensions.Copy: RptDimensions;
begin
  result := new RptDimensions(fHorizontal, fVertical);
end;

method RptDimensions.ToString: String;
begin
  result := Horizontal.ToString + ', ' + Vertical.ToString;
end;

{$ENDREGION}

{$REGION RptBorders}

constructor RptBorders(aLeft: RptDimension := nil; aRight: RptDimension := nil; aTop: RptDimension := nil; aBottom: RptDimension := nil);
begin
  inherited constructor;
  fLeft := aLeft;
  if fLeft = nil then
    fLeft := RptDimension.Zero;
  fRight := aRight;
  if fRight = nil then
    fRight := RptDimension.Zero;
  fTop := aTop;
  if fTop = nil then
    fTop := RptDimension.Zero;
  fBottom := aBottom;
  if fBottom = nil then
    fBottom := RptDimension.Zero;
end;

method RptBorders.Copy: RptBorders;
begin
  result := new RptBorders(fLeft, fRight, fTop, fBottom);
end;

method RptBorders.ToString: String;
begin
  result := fLeft.ToString + ', ' + fRight.ToString + ', ' + fTop.ToString+ ', ' + fTop.ToString;
end;

{$ENDREGION}

{$REGION RptFormatSettings}

constructor RptFormatSettings(aStyle: String = nil; aSizeFactor: Float := 1.0);
begin
  fStyle := aStyle;
  fSizeFactor := aSizeFactor;
end;

{$ENDREGION}

{$REGION RptAligns}

constructor RptAligns(aHorizontal, aVertical: RptAlign);
begin
  Horizontal := aHorizontal;
  Vertical := aVertical;
end;

method RptAligns.ToString: String;
begin
  result := Horizontal.ToString + ', ' + Vertical.ToString;
end;


method RptAligns.GetAlignment(aDirection: RptDirection): RptAlign;
begin
  result :=
    if aDirection = RptDirection.Horizontal then Horizontal
    else Vertical;
end;

method RptAligns.SetAlignment(aDirection: RptDirection; aAlign: RptAlign);
begin
  if aDirection = RptDirection.Horizontal then Horizontal := aAlign
  else Vertical := aAlign;
end;

method RptAligns.Copy: not nullable RptAligns;
begin
  result := new RptAligns(Horizontal, Vertical);
end;

{$ENDREGION}

{$REGION RptAligned}

constructor RptAligned;
begin
  inherited constructor;
  fIntAlign := new RptAligns(RptAlign.First, RptAlign.First);
  fExtAlign := new RptAligns(RptAlign.First, RptAlign.First);
end;

constructor RptAligned(aAligned: RptAligned);
begin
  inherited constructor;
  fIntAlign := aAligned.IntAlign.Copy;
  fExtAlign := aAligned.ExtAlign.Copy;
end;

{$ENDREGION}

{$REGION RptElement}

constructor RptElement;
begin
  inherited constructor;
end;

method RptElement.GetText: String;
begin
  result := nil;
end;

method RptElement.SetText(aText: String);
begin
  raise new Exception('SetText not available for this class');
end;

method RptElement.GetDirection: RptDirection;
begin
  result := RptDirection.Horizontal;
end;

method RptElement.SetDirection(aDirection: RptDirection);
begin
  raise new Exception('SetDirection not available for this class');
end;

method RptElement.SetHDimension(aDimension: RptDimension);
begin
  if fDimensions = nil then
    begin
      if aDimension = nil then
        exit;
      fDimensions := new RptDimensions;
    end;
  fDimensions.Horizontal := aDimension;
end;

method RptElement.SetVDimension(aDimension: RptDimension);
begin
  if fDimensions = nil then
    begin
      if aDimension = nil then
        exit;
      fDimensions := new RptDimensions;
    end;
  fDimensions.Vertical := aDimension;
end;

method RptElement.GetDimension(aDirection: RptDirection): RptDimension;
begin
  result := if aDirection = RptDirection.Horizontal then HDimension else VDimension;
end;

method RptElement.SetDimension(aDirection: RptDirection; aDimension: RptDimension);
begin
  if aDirection = RptDirection.Horizontal then
    SetHDimension(aDimension)
  else
    SetVDimension(aDimension);
end;

{$ENDREGION}

{$REGION RptFill}

constructor RptFill(aDirection: RptDirection := RptDirection.Horizontal; aStrength: Integer := 1);
require
  aStrength >= 0;
begin
  inherited constructor;
  fDirection := aDirection;
  fStrength := aStrength;
  ExtAlign.Alignment[fDirection] := RptAlign.Fill;
  IntAlign.Alignment[fDirection] := RptAlign.Fill;
end;

method RptFill.GetDirection: RptDirection;
begin
  result := fDirection;
end;

method RptFill.SetDirection(aDirection: RptDirection);
begin
  fDirection := aDirection
end;

{$ENDREGION}

{$REGION RptText}

constructor RptText(aText: String := nil);
begin
  inherited constructor;
  Text := aText;
end;

method RptText.GetText: String;
begin
  result := fText;
end;

method RptText.SetText(aText: String);
begin
  fText := aText;
end;

{$ENDREGION}

{$REGION RptLines}

method RptLines.GetDirection: RptDirection;
begin
  result := RptDirection.Vertical;
end;

{$ENDREGION}

{$REGION RptImage}

constructor RptImage(aImage: IRptImage; aText: String := nil);
begin
  inherited constructor(aText);
  fImage := aImage;
  fScaled := 1.0;
end;

{$ENDREGION}

{$REGION RptFormattedText}

constructor RptFormattedText(aText: String := nil; aFormat: RptFormatSettings := nil);
begin
  inherited constructor(aText);
  fFormat := if aFormat = nil then new RptFormatSettings else aFormat;
end;

{$ENDREGION}

{$REGION RptBeginFormat}

constructor RptBeginFormat(aFormat: RptFormatSettings := nil);
begin
  inherited constructor;
  fFormat := if aFormat = nil then new RptFormatSettings else aFormat;
  fEnd := nil;
end;

{$ENDREGION}

{$REGION RptEndFormat}

constructor RptEndFormat(aBegin: not nullable RptBeginFormat);
begin
  inherited constructor;
  fBegin := aBegin;
  fBegin.EndFormat := self;
end;

{$ENDREGION}

{$REGION RptBeginLiner}

constructor RptBeginLiner(aLines: Integer := 1);
begin
  inherited constructor;
  fLines := aLines;
  VIntAlign := RptAlign.Last;
  fEnd := nil;
end;

{$ENDREGION}

{$REGION RptEndLiner}

constructor RptEndLiner(aBegin: not nullable RptBeginLiner);
begin
  inherited constructor;
  VIntAlign := RptAlign.Last;
  fBegin := aBegin;
  fBegin.EndLiner := self;
end;

{$ENDREGION}

{$REGION RptComposite}

constructor RptComposite(aComposite: not nullable CompositeString);
begin
  inherited constructor;
  fComposite := aComposite;
end;

method RptComposite.GetText: String;
begin
  result := fComposite.AsString;
end;

{$ENDREGION}

{$REGION RptTree}

constructor RptTree(aText: String; aParent: RptTreeParent := nil; aIsParent: Boolean := true);
begin
  inherited constructor(aText);
  fParent := aParent;
  fIsParent := aIsParent;
end;

class method RptTree.TreePattern(aIndent: Integer; aText, aNone, aThru, aLink, aLast, aLine: String): String;
begin
  result := '';
  var lAdd := '';
  for i := 0 to aText.Length - 1 do
    begin
      case aText[i] of
        RptTree.TreeNone: begin result := result + aNone; lAdd := aNone; end;
        RptTree.TreeThru: begin result := result + aThru; lAdd := aNone; end;
        RptTree.TreeLink: begin result := result + aLink; lAdd := aLine; end;
        RptTree.TreeLast: begin result := result + aLast; lAdd := aLine; end;
        RptTree.TreeLine: begin result := result + aLine; lAdd := aLine; end;
        else              begin result := result + aText[i]; lAdd := aNone; end;
      end;
      for j := 1 to aIndent - 1 do
        result := result + lAdd;
    end;
end;

class method RptTree.AllDotsPattern(aIndent: Integer; aText: String; aDot: String := '.'; aSpace: String := ' '): String;
begin
  if aText = nil then
    exit nil;
  result := '';
  var lSpace := Utils.ChString(aIndent - 1, aSpace);
  for i := 1 to aText.Length do
    result := result + aDot + lSpace;
end;

{$ENDREGION}

{$REGION RptGroup}

constructor RptGroup(aDirection: RptDirection; aElements: sequence of RptElement := nil);
begin
  inherited constructor;
  fDirection := aDirection;
  Clear;
  if aElements <> nil then
    fElements.Add(aElements);
end;

method RptGroup.Clear;
begin
  fElements := new List<RptElement>;
  fLastFormat := nil;
  fLastLiner := nil;
  fLastSectionNumber := 0;
  fLastTableNumber := 0;
end;

method RptGroup.GetDirection: RptDirection;
begin
  result := fDirection;
end;

method RptGroup.SetDirection(aDirection: RptDirection);
begin
  fDirection := aDirection
end;

method RptGroup.Add(aElement: RptElement);
begin
  fElements.Add(aElement);
end;

method RptGroup.Wr(aText: String): RptText;
begin
  result := new RptText(aText);
  &Add(result);
end;

method RptGroup.Wr(aImage: IRptImage; aAutoScale: Boolean := false; aText: String := nil): RptImage;
require
  aImage <> nil;
begin
  result := new RptImage(aImage, aText);
  result.AutoScale := aAutoScale;
  &Add(result);
end;

method RptGroup.Wr(aText: String; aFormat: RptFormatSettings): RptFormattedText;
begin
  result := new RptFormattedText(aText, aFormat);
  &Add(result);
end;

method RptGroup.Wr(aComposite: CompositeString): RptComposite;
begin
  result := new RptComposite(aComposite);
  &Add(result);
end;

method RptGroup.WrMacro(aText: String): RptMacro;
begin
  result := new RptMacro(aText);
  &Add(result);
end;

method RptGroup.Tree(aText: String; aParent: RptTreeParent := nil; aIsParent: Boolean := true): RptTree;
begin
  result := new RptTree(aText, aParent, aIsParent);
  &Add(result);
end;

method RptGroup.Format(aFormat: RptFormatSettings): RptBeginFormat;
require
  fLastFormat = nil;
begin
  result := new RptBeginFormat(aFormat);
  &Add(result);
  fLastFormat := result;
end;

method RptGroup.EndFormat: RptEndFormat;
require
  fLastFormat <> nil;
begin
  result := new RptEndFormat(fLastFormat);
  &Add(result);
  fLastFormat := nil;
end;

method RptGroup.Liner(aLines: Integer := 1): RptBeginLiner;
require
  fLastLiner = nil;
begin
  result := new RptBeginLiner(aLines);
  &Add(result);
  fLastLiner := result;
end;

method RptGroup.EndLiner: RptEndLiner;
require
  fLastLiner <> nil;
begin
  result := new RptEndLiner(fLastLiner);
  &Add(result);
  fLastLiner := nil;
end;

method RptGroup.HFill(aStrength: Integer := 1): RptFill;
begin
  result := new RptFill(RptDirection.Horizontal, aStrength);
  &Add(result);
end;

method RptGroup.VFill(aStrength: Integer := 1): RptFill;
begin
  result := new RptFill(RptDirection.Vertical, aStrength);
  &Add(result);
end;

method RptGroup.NewLine(aHeight: Float := 1.0): RptLine;
begin
  result := new RptLine(aHeight);
  &Add(result);
end;

method RptGroup.HalfLine: RptLine;
begin
  result := new RptLine(fHalfHeight);
  &Add(result);
end;

method  RptGroup.NewLines(aText: String := nil): RptLines;
begin
  result := new RptLines;
  result.Text := aText;
  &Add(result);
end;

method RptGroup.NewParagraph(aText: String := nil): RptParagraph;
begin
  result := new RptParagraph;
  result.Text := aText;
  &Add(result);
end;

method RptGroup.NewSection(aTitle: String; aPageBreak: Integer := RptSection.BreakNone): RptSection;
begin
  inc(fLastSectionNumber);
  result := new RptSection(aTitle, aPageBreak, fLastSectionNumber);
  &Add(result);
end;

method RptGroup.NewTable(aTitle: String; aPageBreak: Integer := RptSection.BreakNone): RptTable;
begin
  inc(fLastTableNumber);
  result := new RptTable(aTitle, aPageBreak, fLastTableNumber);
  &Add(result);
end;

{$ENDREGION}

{$REGION RptHorizontalGroup}

constructor RptHorizontalGroup(aElements: sequence of RptElement := nil);
begin
  inherited constructor(RptDirection.Horizontal, aElements);
end;

{$ENDREGION}

{$REGION RptVerticalGroup}

constructor RptVerticalGroup(aElements: sequence of RptElement := nil);
begin
  inherited constructor(RptDirection.Vertical, aElements);
end;

{$ENDREGION}

{$REGION RptLine}

constructor RptLine(aHeight: Float := 1.0);
begin
  inherited constructor;
  fHeight := aHeight;
end;

{$ENDREGION}

{$REGION RptSection}

constructor RptSection(aTitle: String := nil; aPageBreak: Integer := BreakNone; aNumber: Integer := 0);
begin
  inherited constructor;
  Title := aTitle;
  fPageBreak := aPageBreak;
  fNumber := aNumber;
end;

{$ENDREGION}

{$REGION RptTable}

constructor RptTable(aTitle: String := nil; aColCount: Integer := 0; aPageBreak: Integer := BreakNone; aNumber: Integer := 0);
begin
  inherited constructor(aTitle, aPageBreak, aNumber);
  CellGap := ' ';
  ColCount := aColCount;
end;

method RptTable.GetColCount: Integer;
begin
  result := if fColumns = nil then 0 else fColumns.Count;
end;

method RptTable.SetColCount(aCount: Integer);
begin
  if fColumns = nil then
    fColumns := new List<String>;
  while fColumns.Count < aCount do
    fColumns.Add(Utils.IntToStr(fColumns.Count + 1));
  while fColumns.Count > Math.Max(aCount, 0) do
    fColumns.RemoveAt(fColumns.Count - 1);
end;

method RptTable.AddColumn(aName: String);
begin
  if fColumns = nil then
    fColumns := new List<String>;
  fColumns.Add(aName);
end;

method RptTable.NewRow: RptRow;
begin
  result := new RptRow(self);
  &Add(result);
end;


{$ENDREGION}

{$REGION RptCell}

constructor RptCell(aTable: not nullable RptTable; aColumn: Integer; aColSpan: Integer := 1);
require
  aColSpan >= 1;
begin
  inherited constructor (RptDirection.Horizontal);
  fTable := aTable;
  fFromColumn := aColumn;
  fToColumn := fFromColumn + aColSpan - 1;
end;

{$ENDREGION}

{$REGION RptRow}

constructor RptRow(aTable: not nullable RptTable);
begin
  inherited constructor;
  fTable := aTable;
  fNextColumn := 0;
end;

method RptRow.SkipColumn;
begin
  inc(fNextColumn)
end;

method RptRow.SkipColumns(aColumns: Integer);
begin
  fNextColumn := fNextColumn + aColumns;
end;

method RptRow.NewCell: RptCell;
begin
  result := NewMultiCell(1);
end;

method RptRow.NewMultiCell(aColumns: Integer): RptCell;
require
  aColumns >= 1;
begin
  if fNextColumn > 0 then
    Wr(fTable.CellGap);
  result := new RptCell(fTable, fNextColumn, aColumns);
  fNextColumn := fNextColumn + aColumns;
  if fTable.ColCount < fNextColumn then
    fTable.ColCount := fNextColumn;
  &Add(result);
end;

{$ENDREGION}

{$REGION RptReport}

constructor RptReport;
begin
  inherited constructor;
  fDateTime := DateTime.UtcNow;
  fTreePattern := RptTreePattern.Unicode;
end;

constructor RptReport(aReport: RptReport);
begin
  constructor;
  if aReport <> nil then
    begin
      fSectionBreak := aReport.SectionBreak;
      fTableBreak := aReport.TableBreak;
      fTreePattern := aReport.TreePattern;
    end;
end;

{$ENDREGION}

{$REGION RptWriter}

constructor RptWriter(aReport: RptReport := nil);
begin
  fBuild := new StringBuilder;
  fActive := false;
  fReportDate := DateTime.UtcNow;
  if aReport <> nil then
    begin
      AddReport(aReport);
      Finish;
    end;
end;

method RptWriter.AddParent(aParent: RptTreeParent): String;
begin
  if aParent = nil then
    result := nil
  else
    begin
      if not fParents.ContainsKey(aParent) then
        begin
          inc(fParentIdNumber);
          fParents.Add(aParent, 'P' + Utils.IntToStr(fParentIdNumber));
        end;
      result := fParents[aParent];
    end;
end;

method RptWriter.ClearParents;
begin
  fParentIdNumber := 0;
  fParents.RemoveAll;
end;

method RptWriter.MapMacro(aKey: String): String;
begin
  aKey := aKey.Trim.ToUpper;
  result :=
    if (aKey = 'DATE') or (aKey = 'DATE_SHORT') then
      fReportDate.ToShortDateString(TimeZone.Local)
    else if aKey = 'DATE_LONG' then
      fReportDate.ToLongPrettyDateString(TimeZone.Local)
    else if (aKey = 'TIME') or (aKey = 'TIME_SHORT') then
      fReportDate.ToString('h:mm', TimeZone.Local)
    else if aKey = 'TIME_LONG' then
      fReportDate.ToString('HH:mm:ss', TimeZone.Local)
    else if (aKey = 'DATETIME') or (aKey = 'DATETIME_SHORT') then
      MapMacro('DATE_SHORT') + ' ' + MapMacro('TIME_SHORT')
    else if aKey = 'DATETIME_LONG' then
      MapMacro('DATE_LONG') + ' ' + MapMacro('TIME_LONG')
    else nil;
end;

method RptWriter.DoMapMacro(aKey: String): String;
begin
  result :=
    if assigned(fMacroMapper) then fMacroMapper(aKey)
    else MapMacro(aKey);
end;

method RptWriter.AddReport(aReport: RptReport);
begin
  if aReport = nil then
    exit;
  fReport := aReport;
  fReportDate := fReport.DateTime;
  if not fActive then
    begin
      fActive := true;
      WrBegin;
    end;
  WrRptElement(fReport);
end;

method RptWriter.Finish;
begin
  if fActive then
    begin
      WrEnd;
      fActive := false;
    end;
end;

method RptWriter.Wr(aStr: String);
begin
  fBuild.Append(aStr);
end;

method RptWriter.WrLn(aStr: String := nil);
begin
  if aStr <> nil then
    Wr(aStr);
  fBuild.AppendLine;
end;

method RptWriter.WriteToFile(aFileName: String);
begin
  Finish;
  File.WriteText(aFileName, AsString);
end;

{$ENDREGION}

{$REGION RptJsonWriter}

method RptJsonWriter.WrJson(aName: String; aValue: String);
begin
  Wr($'"{aName}":"{Utils.JsonString(aValue)}",');
end;

method RptJsonWriter.WrJson(aName: String; aValue: Integer);
begin
  Wr($'"{aName}":{aValue},');
end;

method RptJsonWriter.WrJson(aName: String; aValue: Float);
begin
  Wr($'"{aName}":{Utils.FltToStr(aValue, true)},');
end;

method RptJsonWriter.WrJson(aName: String; aValue: Boolean);
begin
  Wr($'"{aName}":{if aValue then 'true' else 'false'},');
end;

method RptJsonWriter.WrAlign(aKey: String; aAlign: RptAlign);
begin
  if aAlign <> RptAlign.First then
    WrJson(aKey, aAlign.ToString);
end;

method RptJsonWriter.WrAlignment(aRpt: RptElement);
begin
  WrAlign('HIntAlign', aRpt.HIntAlign);
  WrAlign('VIntAlign', aRpt.VIntAlign);
  WrAlign('HExtAlign', aRpt.HExtAlign);
  WrAlign('VExtAlign', aRpt.VExtAlign);
end;

method RptJsonWriter.WrElement(aName: String; aRpt: RptElement);
begin
  if aRpt = nil then
    exit;
  Wr('"' + aName + '":');
  WrRptElement(aRpt);
  Wr(',');
end;

method RptJsonWriter.WrComposite(aStr: CompositeString);
begin
  if aStr = nil then
    exit;
  Wr('"Composite":[');
  for each lEl in aStr.Elements do
    begin
      Wr('{');
      WrJson('String', lEl.Str);
      WrJson('Tag', lEl.Tag);
      Wr('},');
    end;
  Wr('],');
end;

method RptJsonWriter.WrFormat(aFmt: RptFormatSettings);
begin
  if aFmt = nil then
    exit;
  Wr('"Format":{');
  if not String.IsNullOrEmpty(aFmt.FontName) then WrJson('Font', aFmt.FontName);
  if aFmt.Bold then WrJson('Bold', aFmt.Bold);
  if aFmt.Italic then WrJson('Italic', aFmt.Italic);
  if aFmt.Underlined then WrJson('Underline', aFmt.Underlined);
  if aFmt.SizeFactor <> 1.0 then WrJson('SizeFactor', aFmt.SizeFactor);
  Wr('},');
end;

method RptJsonWriter.WrList(aList: List<String>);
begin
  if aList = nil then
    exit;
  Wr('"Columns":[');
  for each lEl in aList do
    begin
      Wr('"' + Utils.JsonString(lEl) + '"');
      Wr(',');
    end;
  Wr('],');
end;

method RptJsonWriter.WrRptElement(aRpt: RptElement);
begin
  Wr('{');
  WrJson('Type', typeOf(aRpt).Name);
  if aRpt.Text <> nil then
    WrJson('Text', aRpt.Text);
  if aRpt.Direction <> RptDirection.Horizontal then
     WrJson('Direction', aRpt.Direction.ToString);
  WrAlignment(aRpt);
  if aRpt is RptFill then
    begin
      var lFill := RptFill(aRpt);
      if lFill.Strength <> 1 then
        WrJson('Strength', lFill.Strength);
    end;
  if aRpt is RptImage then
    begin
      var lImage := RptImage(aRpt).Image;
      WrJson('Type', lImage.ImageType);
      var lString := lImage.ImageString;
      if not String.IsNullOrEmpty(lString) then
        WrJson('Data', lString);
    end;
  if aRpt is RptFormattedText then
    WrFormat(RptFormattedText(aRpt).Format);
  if aRpt is RptBeginFormat then
    WrFormat(RptBeginFormat(aRpt).Format);
  if aRpt is RptBeginLiner then
    WrJson('Lines', RptBeginLiner(aRpt).Lines);
  if aRpt is RptLine then
    WrJson('Height', RptLine(aRpt).Height);
  if aRpt is RptComposite then
    WrComposite(RptComposite(aRpt).Composite);
  if aRpt is RptTreeParent then
    begin
      var lId := AddParent(RptTreeParent(aRpt));
      if lId <> nil then
        WrJson('Id', lId);
    end;
  if aRpt is RptTree then
    begin
      var lParent := RptTree(aRpt).Parent;
      var lId := AddParent(lParent);
      if lId <> nil then
        WrJson('ParentId', lId);
    end;
  if aRpt is RptSection then
    begin
      WrJson('Number', RptSection(aRpt).Number);
      WrJson('PageBreak', RptSection(aRpt).PageBreak);
    end;
  if aRpt is RptTable then
    begin
      WrJson('CellGap', RptTable(aRpt).CellGap);
      WrList(RptTable(aRpt).Columns);
    end;
  if aRpt is RptCell then
    begin
      var lCell := RptCell(aRpt);
      WrJson('From', lCell.FromColumn);
      if lCell.FromColumn <> lCell.ToColumn then
        WrJson('To', lCell.ToColumn);
    end;
  if aRpt is RptReport then
    begin
      var lRpt := RptReport(aRpt);
      WrElement('Header', lRpt.Header);
      WrElement('Footer', lRpt.Footer);
      WrJson('Date', Utils.ISODateTimeStr(lRpt.DateTime));
      WrJson('SectionBreak', lRpt.SectionBreak);
      WrJson('TableBreak', lRpt.TableBreak);
      WrJson('TreePattern', lRpt.TreePattern.ToString);
    end;
  if aRpt is RptGroup then
    begin
      var lGrp := RptGroup(aRpt);
      Wr('"Elements":[');
      for lIdx := 0 to lGrp.Elements.Count - 1 do
        begin
          WrRptElement(lGrp.Elements[lIdx]);
          Wr(',');
        end;
      Wr('],');
    end;
  Wr('}');
end;

{$ENDREGION}

{$REGION RptHtmlParameters}

method RptHtmlParameters.TagMapper(aTag: Integer): String;
begin
  result := nil;
end;

method RptHtmlParameters.Style: String;
begin
  result := HtmlStyle;
end;

method RptHtmlParameters.Script: String;
begin
  result := HtmlScript;
end;

method RptHtmlParameters.Head: String;
begin
  result := String.Format(HtmlHead, HtmlTitle, Style);
end;

method RptHtmlParameters.Foot: String;
begin
  result := HtmlFoot;
end;

{$ENDREGION}

{$REGION RptHtmlWriter}

constructor RptHtmlWriter(aReport: RptReport := nil; aParameters: RptHtmlParameters := nil);
begin
  fParameters :=
    if aParameters = nil then new RptHtmlParameters
    else aParameters;
  fInLiner := false;
  inherited constructor(aReport);
end;

method RptHtmlWriter.WrBegin;
begin
  Wr(fParameters.Head);
end;

method RptHtmlWriter.WrEnd;
begin
  if Report.TreePattern = RptTreePattern.Lines then
    Wr(fParameters.Script);
  Wr(fParameters.Foot);
end;

method RptHtmlWriter.WrRptElement(aRpt: RptElement);
begin
   if aRpt is RptRow then WriteRow(RptRow(aRpt))
   else if aRpt is RptCell then WriteCell(RptCell(aRpt))
   else if aRpt is RptLine then WriteLine(RptLine(aRpt))
   else if aRpt is RptLines then WriteLines(RptLines(aRpt))
   else if aRpt is RptParagraph then WriteParagraph(RptParagraph(aRpt))
   else if aRpt is RptTable then WriteTable(RptTable(aRpt))
   else if aRpt is RptSection then WriteSection(RptSection(aRpt))
   else if aRpt is RptGroup then WriteGroup(RptGroup(aRpt))
   else if aRpt is RptComposite then WriteComposite(RptComposite(aRpt))
   else if aRpt is RptFormattedText then WriteFormattedText(RptFormattedText(aRpt))
   else if aRpt is RptTreeParent then WriteTreeParent(RptTreeParent(aRpt))
   else if aRpt is RptTree then WriteTree(RptTree(aRpt))
   else if aRpt is RptMacro then WriteMacro(RptMacro(aRpt))
   else if aRpt is RptImage then WriteImage(RptImage(aRpt))
   else if aRpt is RptText then WriteText(RptText(aRpt))
   else if aRpt is RptBeginFormat then BeginFormat(RptBeginFormat(aRpt).Format)
   else if aRpt is RptEndFormat then EndFormat(RptEndFormat(aRpt).BeginFormat.Format)
   else if aRpt is RptBeginLiner then fInLiner := true
   else if aRpt is RptEndLiner then fInLiner :=false
   else if aRpt is RptFill then WriteFill(RptFill(aRpt));
end;

method RptHtmlWriter.WriteTable(aRpt: RptTable);
begin
  WrLn('<table border="0" cellspacing="0" cellpadding="0">');
  fInTable := true;
  try
    WriteGroup(aRpt);
  finally
    fInTable := false;
    WrLn('</table>');
  end;
end;

method RptHtmlWriter.WriteRow(aRpt: RptRow);
begin
  Wr('<tr>');
  WriteGroup(aRpt);
  WrLn('</tr>');
end;

method RptHtmlWriter.ElementIsAligned(aElement: RptCell; aAlign: RptAlign): Boolean;

  method IsAligned(aRpt: RptElement): Boolean;
  begin
    result := aRpt.HIntAlign = aAlign;
    if not result then
      if aRpt is RptGroup then
        begin
          var lRpt := RptGroup(aRpt);
          for i := 0 to lRpt.Count - 1 do
            begin
              result := IsAligned (lRpt.Element[i]);
              if result then
                exit;
            end;
        end;
  end;

begin
  result := IsAligned(aElement);
end;

method RptHtmlWriter.WriteCell(aRpt: RptCell);
begin
  var lStyle :=
    if fInLiner then ' class="underlined"'
    else '';
  var lRight :=
    if ElementIsAligned(aRpt, RptAlign.Last) then 'text-align:right;' else '';
  if lRight <> '' then
    lStyle := lStyle + $' style="{lRight}"';
  Wr($'<td{lStyle}>');
  WriteGroup(aRpt);
  WrLn('&nbsp;</td>');
end;

method RptHtmlWriter.WriteLine(aRpt: RptLine);
begin
  if not fInTable then
    Wr('<p>');
  WriteGroup(aRpt);
  if not fInTable then
    WrLn('<p/>');
  WrLn;
end;

method RptHtmlWriter.WriteLines(aRpt: RptLines);
begin
  var lLines := Utils.BreakToLines(aRpt.Text);
  if lLines = nil then
    exit;
  Wr('<p>');
  Wr(String.Join('<br/>', lLines));
  WrLn('<p/>');
end;

method RptHtmlWriter.WriteParagraph(aRpt: RptParagraph);
begin
  WrLn;
  Wr('<p>');
  WriteText(aRpt.Text);
  WriteGroup(aRpt);
  WrLn('</p>');
end;

method RptHtmlWriter.WriteSection(aRpt: RptSection);
begin
  WrLn;
  Wr('<div class="section">');
  WriteGroup(aRpt);
  WrLn('</div>');
end;

method RptHtmlWriter.WriteGroup(aRpt: RptGroup);
begin
  for each lEl in aRpt.Elements do
    WrRptElement(lEl);
end;

method RptHtmlWriter.WriteText(aRpt: RptText);
begin
  WriteText(aRpt.Text);
end;

method RptHtmlWriter.WriteImage(aRpt: RptImage);
begin
  var lImage := aRpt.Image;
  var lText := if aRpt.Text = nil then '' else aRpt.Text;
  var lString := lImage.ImageString;
  WrLn;
  if lString = nil then
    WrLn(lText)
  else
    WrLn($'<img src="data:image/{lImage.ImageType};base64,{lString}" alt="{lText}"/>');
end;

method RptHtmlWriter.WriteText(aText: String);
begin
  Wr(Utils.HtmlString(aText));
end;

method RptHtmlWriter.WriteMacro(aRpt: RptMacro);
begin
  var lMapped := DoMapMacro(aRpt.Text);
  if lMapped = nil then
    lMapped := '[' + aRpt.Text + ']';
  WriteText(lMapped);
end;

method RptHtmlWriter.BeginFormat(aFmt: RptFormatSettings);
begin
  if aFmt = nil then
    exit;
  var lFontSize :=
    if aFmt.SizeFactor = 1.0 then ''
    else $' style="font-size: {Utils.FltToStr(100 * aFmt.SizeFactor, 2, true)}%"';
  Wr('<span' + lFontSize + '>');
  if aFmt.Bold then Wr('<b>');
  if aFmt.Italic then Wr('<i>');
  if aFmt.Underlined then Wr('<u>');
end;

method RptHtmlWriter.EndFormat(aFmt: RptFormatSettings);
begin
  if aFmt = nil then
    exit;
  if aFmt.Underlined then Wr('</u>');
  if aFmt.Italic then Wr('</i>');
  if aFmt.Bold then Wr('</b>');
  Wr('</span>');
end;

method RptHtmlWriter.WriteFormattedText(aRpt: RptFormattedText);
begin
  BeginFormat(aRpt.Format);
  WriteText(aRpt);
  EndFormat(aRpt.Format);
end;

method RptHtmlWriter.WriteComposite(aRpt: RptComposite);
begin
  for each lEl in aRpt.Composite.Elements do
    begin
      var lClass := fParameters.TagMapper(lEl.Tag);
      if lClass <> nil then
        Wr($'<span class="{lClass}">');
      WriteText(lEl.Str);
      if lClass <> nil then
        Wr($'</span>');
    end;
end;

method RptHtmlWriter.WriteTreeParent(aRpt: RptTreeParent);
begin
  Wr($'<span id="{AddParent(aRpt)}"/>');
end;

method RptHtmlWriter.WriteTree(aRpt: RptTree);
 const
   NBS = '&nbsp;';
   UNone = '&nbsp;';
   UThru = '&#x2502;';
   ULink = '&#x251c;';
   ULast = '&#x2514;';
   ULine = '&#x2500;';
begin
  if aRpt.Text = nil then
    exit;
  var lTreePattern :=
    case Report.TreePattern of
      RptTreePattern.None,
      RptTreePattern.Lines:     RptTree.TreePattern(fParameters.TreeIndent, aRpt.Text, NBS,  NBS,  NBS,  NBS,  NBS);
      RptTreePattern.PlusMinus: RptTree.TreePattern(fParameters.TreeIndent, aRpt.Text, NBS,  '|',  '+',  '+',  '-');
      RptTreePattern.Dots:      RptTree.TreePattern(fParameters.TreeIndent, aRpt.Text, NBS,  '.',  '.',  '.',  NBS);
      RptTreePattern.AllDots:   RptTree.AllDotsPattern(fParameters.TreeIndent, aRpt.Text, '.', NBS);
      RptTreePattern.Unicode:   RptTree.TreePattern(fParameters.TreeIndent, aRpt.Text, UNone, UThru, ULink, ULast, ULine);
    end;
  var lParentId :=
    if (aRpt.Parent <> nil) and (Report.TreePattern = RptTreePattern.Lines) then Parents[aRpt.Parent]
    else nil;
  var lParentAtt :=
    if lParentId <> nil then $' data-dex-parent="{lParentId}"'
    else '';
  Wr($'<span class="tree"{lParentAtt}>{lTreePattern}</span>');
end;

method RptHtmlWriter.WriteFill(aRpt: RptFill);
begin
  if aRpt.Direction = RptDirection.Horizontal then
    Wr('<span class="hfill"/>')
  else if aRpt.Direction = RptDirection.Vertical then
    Wr('<div class="vfill"/>');
end;

{$ENDREGION}

end.
