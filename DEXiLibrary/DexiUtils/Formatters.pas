// Formatters.pas is part of
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
// Formatters.pas implements functionality for formatting and positioning reports, defined in Reports.pas.
// While Reports.pas already implements a basic HTML writer (RptHtmlWriter), which defers the task
// of positioning report elements to the browser, Formatters.pas implements the functionality necessary
// to explicitly position report elements for other outputs.
//
// The basic idea is to represent report elements in terms of possibly nested "boxes" (class FmtBox).
// Each box has physical dimensions and other properties that facilitate placing, moving, stretching, ...,
// the box in the context of a document, document page or surrounding boxes. The formatting is carried out
// by an instance of the class RptFormatter.
//
// Formatters.pas also implements RptTextFormatter, a formatter capable of formatting a report to a
// text file. Other formatters are deferred to higher platform-dependent software components.
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

uses
  RemObjects.Elements.RTL;

type
  FmtLength = public Integer;
  FmtDistance = public Double;

type
  FmtHorizontalVertical<T> = public class
  protected
    method GetValue(aDirection: RptDirection): T;
    method SetValue(aDirection: RptDirection; aValue: T);
    property Value[aDirection: RptDirection]: T read GetValue write SetValue;
  public
    constructor (aHorizontal, aVertical: T);
    method ToString: String; override;
    property Horizontal: T;
    property Vertical: T;
 end;

type
  FmtLengths = public class (FmtHorizontalVertical<FmtLength>)
  public
    constructor (aHorizontal, aVertical: FmtLength);
    constructor (aLengths: FmtLengths);
    constructor (aHorizontal, aVertical: FmtDistance; aMultiply: Float := 1.0);
    constructor (aDistances: FmtDistances; aMultiply: Float := 1.0);
    property Length[aDirection: RptDirection]: FmtLength read GetValue write SetValue; default;
    class method AddLengths(aLength1, aLength2: FmtLengths): FmtLengths;
    method Clear;
    method &Copy: not nullable FmtLengths;
    method AssignDistances(aHorizontal, aVertical: FmtDistance; aMultiply: Float := 1.0);
    method AssignDistances(aDistances: FmtDistances; aMultiply: Float := 1.0);
  end;

type
  FmtDistances = public class (FmtHorizontalVertical<FmtDistance>)
  public
    property Distance[aDirection: RptDirection]: FmtDistance read GetValue write SetValue; default;
    class method AddDistances(aDistance1, aDistance2: FmtDistances): FmtDistances;
    class method Inches(aDist: FmtDistance): RptDimension;
    method Clear;
    method &Copy: not nullable FmtDistances;
  end;

type
  FmtRectangle = public class
  public
    Left, Top, Width, Height: FmtLength;
    constructor (aLeft: FmtLength := 0; aTop: FmtLength := 0; aWidth: FmtLength := 0; aHeight: FmtLength := 0);
    method &Copy: not nullable FmtRectangle;
    method ToString: String; override;
    property Right: FmtLength read Left + Width - 1;
    property Bottom: FmtLength read Top + Height - 1;
  end;

type
  FmtBox = public class (RptAligned)
  private
    fElement: RptElement;
    fOffset: not nullable FmtLengths;
    fExtLengths: not nullable FmtLengths;
    fIntLengths: not nullable FmtLengths;
    fBoxList: List<FmtBox>;
    fPrimaryDirection: RptDirection;
    fPageBreak: Integer;
  protected
    method GetLeft: FmtLength;
    method SetLeft(aValue: FmtLength);
    method GetTop: FmtLength;
    method SetTop(aValue: FmtLength);
    method GetWidth: FmtLength;
    method SetWidth(aValue: FmtLength);
    method GetHeight: FmtLength;
    method SetHeight(aValue: FmtLength);
    method GetRight: FmtLength;
    method SetRightFixLeft(aValue: FmtLength);
    method SetRightFixWidth(aValue: FmtLength);
    method GetBottom: FmtLength;
    method SetBottomFixTop(aValue: FmtLength);
    method SetBottomFixHeight(aValue: FmtLength);
    method GetExtent: FmtLengths;
    method SetExtent(const aExtent: FmtLengths);
    method GetRectangle: FmtRectangle;
    method SetRectangle(aRectangle: FmtRectangle);
    method GetIntOff(aDirection: RptDirection): FmtLength;
    method GetIntOffset: FmtLengths;
    method GetIntLeft: FmtLength;
    method GetIntTop: FmtLength;
    method GetIntWidth: FmtLength;
    method SetIntWidth(aValue: FmtLength);
    method GetIntHeight: FmtLength;
    method SetIntHeight(aValue: FmtLength);
    method GetIntRight: FmtLength;
    method GetIntBottom: FmtLength;
    method GetIntRectangle: FmtRectangle;
    method GetExtIntOffset: FmtLengths;
    method GetExtIntLeft: FmtLength;
    method GetExtIntTop: FmtLength;
    method GetExtIntRight: FmtLength;
    method GetExtIntBottom: FmtLength;
    method GetExtIntWidth: FmtLength;
    method GetExtIntHeight: FmtLength;
    method GetExtIntRectangle: FmtRectangle;
    method IntToExt;
    method OtherDirection(aDirection: RptDirection): RptDirection;
    method GetCount: Integer; virtual;
    method GetIsGroup: Boolean;
    method GetBox(aIdx: Integer): FmtBox; virtual;
    method SetBox(aIdx: Integer; aBox: FmtBox); virtual;
    method GetBoxCount: Integer; virtual;
  public
    constructor (aElement: RptElement := nil);
    method &Add(aBox: FmtBox); virtual;
    method Insert(aIdx: Integer; aBox: FmtBox); virtual;
    method Pull(aIdx: Integer): FmtBox;
    property Element: RptElement read fElement write fElement;
    property Offset: not nullable FmtLengths read fOffset write fOffset;
    property ExtLengths: not nullable FmtLengths read fExtLengths write fExtLengths;
    property IntLengths: not nullable FmtLengths read fIntLengths write fIntLengths;
    property PageBreak: Integer read fPageBreak write fPageBreak;
    property Left: FmtLength read GetLeft write SetLeft;
    property Top: FmtLength read GetTop write SetTop;
    property Width: FmtLength read GetWidth write SetWidth;
    property Height: FmtLength read GetHeight write SetHeight;
    property Right: FmtLength read GetRight write SetRightFixLeft;
    property Bottom: FmtLength read GetBottom write SetBottomFixTop;
    property Extent: FmtLengths read GetExtent write SetExtent;
    property Rectangle: FmtRectangle read GetRectangle write SetRectangle;
    property IntOffset: FmtLengths read GetIntOffset;
    property IntLeft: FmtLength read GetIntLeft;
    property IntTop: FmtLength read GetIntTop;
    property IntWidth: FmtLength read GetIntWidth write SetIntWidth;
    property IntHeight: FmtLength read GetIntHeight write SetIntHeight;
    property IntRight: FmtLength read GetIntRight;
    property IntBottom: FmtLength read GetIntBottom;
    property IntRectangle: FmtRectangle read GetIntRectangle;
    property ExtIntOffset: FmtLengths read GetExtIntOffset;
    property ExtIntLeft: FmtLength read GetExtIntLeft;
    property ExtIntTop: FmtLength read GetExtIntTop;
    property ExtIntRight: FmtLength read GetExtIntRight;
    property ExtIntBottom: FmtLength read GetExtIntBottom;
    property ExtIntWidth: FmtLength read GetExtIntWidth;
    property ExtIntHeight: FmtLength read GetExtIntHeight;
    property ExtIntRectangle: FmtRectangle read GetExtIntRectangle;
    property BoxCount: Integer read GetBoxCount;
    property IsGroup: Boolean read GetIsGroup;
    property Count: Integer read GetCount;
    property Boxes: List<FmtBox> read fBoxList write fBoxList;
    property Box[aIdx: Integer]: FmtBox read GetBox write SetBox; default;
    property PrimaryDirection: RptDirection read fPrimaryDirection write fPrimaryDirection;
    property SecondaryDirection: RptDirection read OtherDirection(fPrimaryDirection);
  end;

type
  FmtState = public enum (Idle, Making, Formatting, Paginating, Rendering);
  FmtFillStyle = public enum (LeftToRight, RightToLeft, Alternate);
  FmtNotify = public method (aState: FmtState; aBox: FmtBox; aProcessedBoxes, aAllBoxes, aPage: Integer);

type
  RptFormatter = public class
  private
    fReport: not nullable RptReport;
    fBoxes: FmtBox;
    fPageOffset: not nullable FmtLengths;
    fPageLengths: not nullable FmtLengths;
    fTreeIndent: Integer;
    fMacroMapper: RptMacroMapper := nil;
    fBoxCount: Integer;
    fFirstPageNumber: Integer;
    fOnNotify: FmtNotify;
    fPages: List<FmtBox>;
    fAborted: Boolean;
    fState: FmtState;
    fFillStyle: FmtFillStyle;

    // Formatting context
    ffPageNumber: Integer;
    ffCurrentPage: FmtBox;
    ffCurrentHeader: RptGroup;
    ffCurrentFooter: RptGroup;
    ffCurrentHeaderBox: FmtBox;
    ffCurrentFooterBox: FmtBox;
    ffCurrentSection: RptSection;
    ffCurrentTable: RptSection;
    ffBoxStack: Stack<FmtBox>;
    ffPageFreeHeight: FmtLength;
    ffProcessedBoxes: Integer;
    ffPageBoxesCount: Integer;
    ffFillingLeftToRight: Boolean;
  protected
    method GetPageCount: Integer; virtual;
    method DimensionToLength(aDimension: RptDimension; aDir: RptDirection): FmtLength; virtual;
    method DimensionsToLengths(aDimensions: RptDimensions): FmtLengths;
    method TreePatternText(aText: String): String; virtual;
    method DisplayedText(aBox: FmtBox): String; virtual;
    method MapMacro(aKey: String): String; virtual;
    method DoMapMacro(aKey: String): String;
    method FillIndex(aIdx, aCount: Integer): Integer;
    method SetPageNumber(aNumber: Integer);

    // Context
    method ClearContext; virtual;
    method UpdateContext; virtual;
    method BeginBox(aBox: FmtBox); virtual;
    method EndBox(aBox: FmtBox); virtual;
    method SectionContext: List<RptSection>;
    method SectionNumber(aDelimiter: String := '.'): String; virtual;

    // Measure
    method MeasureText(aText: String): FmtLengths; virtual;
    method MeasureText(aBox: FmtBox): FmtLengths; virtual;
    method MeasureBox(aBox: FmtBox); virtual;
    method MeasureInt(aBox: FmtBox); virtual;
    method MeasureExt(aBox: FmtBox); virtual;
    method MeasureIntToExt(aBox: FmtBox); virtual;
    method MeasureIntPlaced(aBox: FmtBox);

    // Make Boxes: Convert report to a hierarchy of unpositioned boxes

    method MakeLinesBox(aRpt: RptLines; aBox: FmtBox); virtual;
    method MakeParagraphBox(aRpt: RptParagraph; aBox: FmtBox);
    method MakeBox(aRpt: RptElement): FmtBox; virtual;

    // Format Boxes: Measure and format boxes recursively from bottom to the top

    method UnplaceBox(aBox: FmtBox); virtual;
    method PreFormatBox(aBox: FmtBox; aWidth: FmtLength := -1);
    method UnFormatParagraph(aBox: FmtBox; aWidth: FmtLength := -1): List<FmtBox>;
    method PostFormatParagraph(aBox: FmtBox; aWidth: FmtLength := -1);
    method PostFormatTable(aBox: FmtBox; aWidth: FmtLength := -1);
    method PostFormatBox(aBox: FmtBox; aWidth: FmtLength := -1);
    method FillBox(aBox: FmtBox);
    method JustifyBox(aBox: FmtBox);
    method PlaceBox(aBox: FmtBox);
    method BeginFormat; virtual;
    method EndFormat; virtual; empty;
    method FormatBox(aBox: FmtBox; aWidth: FmtLength := -1);

    // Paginate Boxes

    method GetFreeWidth: FmtLength; virtual;
    method GetFreeHeight: FmtLength; virtual;
    method PlaceTo(aBox: FmtBox; aAbsOffset: FmtLengths);
    method BeginPaginate; virtual;
    method EndPaginate; virtual;
    method BeginPage; virtual;
    method NewPage; virtual;
    method FormatPage(aPage: FmtBox); virtual;
    method EndPage; virtual;
    method IsFree(aHeight: FmtLength): Boolean; virtual;
    method CanBreak(aBox: FmtBox): Boolean; virtual;
    method CanPaginate(aBox: FmtBox): Boolean; virtual;
    method PaginateBox(aBox: FmtBox); virtual;

  public
    constructor (aReport: not nullable RptReport; aPageOffset: FmtLengths := nil; aPageLengths: FmtLengths := nil);
    method MakeBoxes; virtual;
    method FormatBoxes; virtual;
    method PaginateBoxes; virtual;
    method Format; virtual;
    method Abort;
    method ListBox(aBox: FmtBox; aLevel: Integer := 0): List<String>;
    method ListBoxes(aBoxes: sequence of FmtBox; aLevel: Integer := 0): List<String>;
    method ListBoxes(aFileName: String);
    method ListBoxes(aFileName: String; aBoxes: sequence of FmtBox);
    property Report: RptReport read fReport;
    property ReportDate: DateTime read fReport.DateTime;
    property TreeIndent: Integer read fTreeIndent write fTreeIndent;
    property MacroMapper: RptMacroMapper read fMacroMapper write fMacroMapper;
    property FillStyle: FmtFillStyle read fFillStyle write FillStyle;
    property State: FmtState read fState write fState;
    property PageLengths: not nullable FmtLengths read fPageLengths;

    property Aborted: Boolean read fAborted write fAborted;
    property OnNotify: FmtNotify read fOnNotify write fOnNotify;
    property Boxes: FmtBox read fBoxes;
    property Pages: ImmutableList<FmtBox> read fPages;
    property Page[aIdx: Integer]: FmtBox read fPages[aIdx];
    property PageCount: Integer read GetPageCount;
    property FirstPageNumber: Integer read fFirstPageNumber write fFirstPageNumber;
    property LogFileNamePrefix: String := nil;
  end;

type
  RptTextPage = public class (List<String>)
  private
  protected
    method AssureLine(aIdx: Integer);
    method AssureLines(aRect: FmtRectangle);
    method AssureLineLength(aIdx: Integer; aLength: FmtLength);
    method AssureRect(aRect: FmtRectangle);
  public
    constructor; empty;
    method &Write(aText: String);
    method &WriteLn(aText: String);
    method &Write(aRect: FmtRectangle; aText: String);
    method WriteLiner(aRect: FmtRectangle; aCh: Char);
    method TrimPage;
  end;

type
  RptTextFormatter = public class(RptFormatter)
  private
    fTextPages: List<RptTextPage>;
    fCurrentTextPage: RptTextPage;
    fLiners: Stack<FmtRectangle>;

    // Context
  protected
    method ClearContext; override;
    method BeginBox(aBox: FmtBox); override;
    method EndBox(aBox: FmtBox); override;
    method MeasureBox(aBox: FmtBox); override;
    method LineChar(aLines: Integer): Char; virtual;
  public
    constructor (aReport: not nullable RptReport; aPageOffset: FmtLengths := nil; aPageLengths: FmtLengths := nil);
    property TextPages: ImmutableList<RptTextPage> read fTextPages;
    property TextPage[aIdx: Integer]: RptTextPage read fTextPages[aIdx]; default;
    property TextPageCount: Integer read fTextPages.Count;
    // Some Unicode alternatives for LineChar#:
    //   #$2017:  double low line
    //   #$2015:  horizontal bar
    //   #$2550:  double horizontal bar
    //   #$203E:  overline
    property LineChar1 := '_';
    property LineChar2 := '=';
    property LinerBelow := false;
    method RenderLines(aBegin, aEnd: FmtRectangle; aLines: Integer);
    method RenderBox(aBox: FmtBox); virtual;
    method Render; virtual;
    method WriteToFile(aFileName: String; aFrom: Integer := 0; aTo: Integer := -1);
  end;

implementation

{$REGION FmtHorizontalVertical<T>}

constructor FmtHorizontalVertical<T>(aHorizontal, aVertical: T);
begin
  Horizontal := aHorizontal;
  Vertical := aVertical;
end;

method FmtHorizontalVertical<T>.GetValue(aDirection: RptDirection): T;
begin
  result :=
    if aDirection = RptDirection.Horizontal then Horizontal
    else Vertical;
end;

method FmtHorizontalVertical<T>.SetValue(aDirection: RptDirection; aValue: T);
begin
  if aDirection = RptDirection.Horizontal then Horizontal := aValue
  else Vertical := aValue;
end;

method FmtHorizontalVertical<T>.ToString: String;
begin
  result := $"{Horizontal}, {Vertical}";
end;

{$ENDREGION}

{$REGION FmtLengths}

class method FmtLengths.AddLengths(aLength1, aLength2: FmtLengths): FmtLengths;
begin
  result := new FmtLengths(aLength1.Horizontal + aLength2.Horizontal, aLength1.Vertical + aLength2.Vertical);
end;

constructor FmtLengths(aHorizontal, aVertical: FmtLength);
begin
  inherited constructor(aHorizontal, aVertical);
end;

constructor FmtLengths(aLengths: FmtLengths);
begin
  inherited constructor(aLengths.Horizontal, aLengths.Vertical);
end;

constructor FmtLengths(aHorizontal, aVertical: FmtDistance; aMultiply: Float := 1.0);
begin
  inherited constructor(0, 0);
  AssignDistances(aHorizontal, aVertical, aMultiply);
end;

constructor FmtLengths(aDistances: FmtDistances; aMultiply: Float := 1.0);
begin
  inherited constructor(0, 0);
  AssignDistances(aDistances, aMultiply);
end;

method FmtLengths.Copy: not nullable FmtLengths;
begin
  result := new FmtLengths(Horizontal, Vertical);
end;

method FmtLengths.Clear;
begin
  Horizontal := 0;
  Vertical := 0;
end;

method FmtLengths.AssignDistances(aHorizontal, aVertical: FmtDistance; aMultiply: Float := 1.0);
begin
  Horizontal := Math.Round(aMultiply * aHorizontal);
  Vertical := Math.Round(aMultiply * aVertical);
end;

method FmtLengths.AssignDistances(aDistances: FmtDistances; aMultiply: Float := 1.0);
begin
  AssignDistances(aDistances.Horizontal, aDistances.Vertical, aMultiply);
end;

{$ENDREGION}

{$REGION FmtDistances}

class method FmtDistances.AddDistances(aDistance1, aDistance2: FmtDistances): FmtDistances;
begin
  result := new FmtDistances(aDistance1.Horizontal + aDistance2.Horizontal, aDistance1.Vertical + aDistance2.Vertical);
end;

class method FmtDistances.Inches(aDist: FmtDistance): RptDimension;
begin
  result := new RptDimension(aDist, RptUnit.Inch);
end;

method FmtDistances.Copy: not nullable FmtDistances;
begin
  result := new FmtDistances(Horizontal, Vertical);
end;

method FmtDistances.Clear;
begin
  Horizontal := 0.0;
  Vertical := 0.0;
end;

{$ENDREGION}

{$REGION FmtRectangle}

constructor FmtRectangle(aLeft: FmtLength := 0; aTop: FmtLength := 0; aWidth: FmtLength := 0; aHeight: FmtLength := 0);
begin
  Left := aLeft;
  Top := aTop;
  Width := aWidth;
  Height := aHeight;
end;

method FmtRectangle.Copy: not nullable FmtRectangle;
begin
  result := new FmtRectangle(Left, Top, Width, Height);
end;

method FmtRectangle.ToString: String;
begin
  result := $"{Left}, {Top}, {Width}, {Height}";
end;

{$ENDREGION}

{$REGION FmtBox}

constructor FmtBox(aElement: RptElement := nil);
begin
  inherited constructor;
  fElement := aElement;
  if fElement <> nil then
    begin
      IntAlign := fElement.IntAlign.Copy;
      ExtAlign := fElement.ExtAlign.Copy;
    end;
  fOffset := new FmtLengths(0, 0);
  fIntLengths := new FmtLengths(0, 0);
  fExtLengths := new FmtLengths(0, 0);
  fPrimaryDirection :=
    if aElement = nil then RptDirection.Horizontal
    else aElement.Direction;
  fPageBreak :=
    if aElement is RptSection then RptSection(aElement).PageBreak
    else if aElement is RptTable then RptTable(aElement).PageBreak
    else RptSection.BreakNone;
  fBoxList := nil;
end;

method FmtBox.GetLeft: FmtLength;
begin
  result := fOffset.Horizontal;
end;

method FmtBox.SetLeft(aValue: FmtLength);
begin
  fOffset.Horizontal := aValue;
end;

method FmtBox.GetTop: FmtLength;
begin
  result := fOffset.Vertical;
end;

method FmtBox.SetTop(aValue: FmtLength);
begin
  fOffset.Vertical := aValue;
end;

method FmtBox.GetWidth: FmtLength;
begin
  result := fExtLengths.Horizontal;
end;

method FmtBox.SetWidth(aValue: FmtLength);
begin
  fExtLengths.Horizontal := aValue;
end;

method FmtBox.GetHeight: FmtLength;
begin
  result := fExtLengths.Vertical;
end;

method FmtBox.SetHeight(aValue: FmtLength);
begin
  fExtLengths.Vertical := aValue;
end;

method FmtBox.GetRight: FmtLength;
begin
  result := Left + Width - 1;
end;

method FmtBox.SetRightFixLeft(aValue: FmtLength);
begin
  Width := aValue - Left + 1;
end;

method FmtBox.SetRightFixWidth(aValue: FmtLength);
begin
  Left := aValue - Width + 1;
end;

method FmtBox.GetBottom: FmtLength;
begin
  result := Top + Height - 1;
end;

method FmtBox.SetBottomFixTop(aValue: FmtLength);
begin
  Height := aValue - Top + 1;
end;

method FmtBox.SetBottomFixHeight(aValue: FmtLength);
begin
  Top := aValue - Height + 1;
end;

method FmtBox.GetExtent: FmtLengths;
begin
  result := new FmtLengths(Right, Bottom);
end;

method FmtBox.SetExtent(const aExtent: FmtLengths);
begin
  Right := aExtent.Horizontal;
  Bottom := aExtent.Vertical;
end;

method FmtBox.GetRectangle: FmtRectangle;
begin
  result := new FmtRectangle(Left, Top, Width, Height);
end;

method FmtBox.SetRectangle(aRectangle: FmtRectangle);
begin
  Top := aRectangle.Top;
  Left := aRectangle.Left;
  Width := aRectangle.Width;
  Height := aRectangle.Height;
end;

method FmtBox.GetIntOff(aDirection: RptDirection): FmtLength;
begin
  result := 0;
  case IntAlign[aDirection] of
    RptAlign.Middle: result := (ExtLengths[aDirection] - IntLengths[aDirection]) div 2;
    RptAlign.Last:   result := ExtLengths[aDirection] - IntLengths[aDirection];
  end;
end;

method FmtBox.GetIntOffset: FmtLengths;
begin
  result := new FmtLengths(IntLeft, IntTop);
end;

method FmtBox.GetIntLeft: FmtLength;
begin
  result := GetIntOff(RptDirection.Horizontal);
end;

method FmtBox.GetIntTop: FmtLength;
begin
  result := GetIntOff(RptDirection.Vertical);
end;

method FmtBox.GetIntWidth: FmtLength;
begin
  result := IntLengths.Horizontal;
end;

method FmtBox.SetIntWidth(aValue: FmtLength);
begin
  IntLengths.Horizontal := aValue;
end;

method FmtBox.GetIntHeight: FmtLength;
begin
  result := IntLengths.Vertical;
end;

method FmtBox.SetIntHeight(aValue: FmtLength);
begin
  IntLengths.Vertical := aValue;
end;

method FmtBox.GetIntRight: FmtLength;
begin
  result := IntLeft + IntWidth - 1;
end;

method FmtBox.GetIntBottom: FmtLength;
begin
  result := IntTop + IntHeight - 1;
end;

method FmtBox.GetIntRectangle: FmtRectangle;
begin
  result := new FmtRectangle(IntLeft, IntTop, IntWidth, IntHeight);
end;

method FmtBox.GetExtIntOffset: FmtLengths;
begin
  result := FmtLengths.AddLengths(Offset, IntOffset);
end;

method FmtBox.GetExtIntLeft: FmtLength;
begin
  result := Left + IntLeft;
end;

method FmtBox.GetExtIntTop: FmtLength;
begin
  result := Top + IntTop;
end;

method FmtBox.GetExtIntRight: FmtLength;
begin
  result := Left + IntRight;
end;

method FmtBox.GetExtIntBottom: FmtLength;
begin
  result := Top + IntBottom;
end;

method FmtBox.GetExtIntWidth: FmtLength;
begin
  result := ExtIntRight - ExtIntLeft + 1;
end;

method FmtBox.GetExtIntHeight: FmtLength;
begin
  result := ExtIntBottom - ExtIntTop + 1;
end;

method FmtBox.GetExtIntRectangle: FmtRectangle;
begin
  result:= new FmtRectangle(ExtIntLeft, ExtIntTop, ExtIntWidth, ExtIntHeight);
end;

method FmtBox.IntToExt;
begin
  ExtLengths := IntLengths.Copy;
end;

method FmtBox.OtherDirection(aDirection: RptDirection): RptDirection;
begin
  result :=
    if aDirection = RptDirection.Horizontal then RptDirection.Vertical
    else RptDirection.Horizontal;
end;

method FmtBox.GetCount: Integer;
begin
  result :=
    if fBoxList = nil then 0
    else fBoxList.Count;
end;

method FmtBox.GetIsGroup: Boolean;
begin
  result := Count > 0;
end;

method FmtBox.GetBox(aIdx: Integer): FmtBox;
begin
  result := fBoxList[aIdx];
end;

method FmtBox.SetBox(aIdx: Integer; aBox: FmtBox);
begin
  fBoxList[aIdx] := aBox;
end;

method FmtBox.Add(aBox: FmtBox);
begin
  if fBoxList = nil then
    fBoxList := new List<FmtBox>;
  fBoxList.Add(aBox);
end;

method FmtBox.Insert(aIdx: Integer; aBox: FmtBox);
begin
  if fBoxList = nil then
    fBoxList := new List<FmtBox>;
  fBoxList.Insert(aIdx, aBox);
end;

method FmtBox.Pull(aIdx: Integer): FmtBox;
begin
  result := fBoxList[aIdx];
  fBoxList.RemoveAt(aIdx);
end;

method FmtBox.GetBoxCount: Integer;
begin
  result := 1;
  for i := 0 to Count - 1 do
    result := result + Box[i].BoxCount;
end;

{$ENDREGION}

{$REGION RptWordBreak}

type
  RptWordBreak = class (RptText)
  public
    constructor(aFill: Boolean);
  end;

constructor RptWordBreak(aFill: Boolean);
begin
  inherited constructor;
  Text := ' ';
  if aFill then
    begin
      ExtAlign.Horizontal := RptAlign.Fill;
      IntAlign.Horizontal := RptAlign.Fill;
    end;
end;

{$ENDREGION}

{$REGION RptParagraphLine}

type
  RptParagraphLine = class (RptLine);

{$ENDREGION}

{$REGION RptFormatter}

constructor RptFormatter(aReport: not nullable RptReport; aPageOffset: FmtLengths := nil; aPageLengths: FmtLengths := nil);
begin
  inherited constructor;
  fReport := aReport;
  fPageOffset :=
    if aPageOffset = nil then new FmtLengths(0, 0)
    else aPageOffset;
  fPageLengths :=
    if aPageLengths = nil then new FmtLengths(-1, -1)
    else aPageLengths;
  fTreeIndent := 2;
  fBoxCount := 0;
  fFirstPageNumber := 1;
  fPages := new List<FmtBox>;
  fState := FmtState.Idle;
  fFillStyle := FmtFillStyle.Alternate;
  fOnNotify := nil;
  ClearContext;
end;

method RptFormatter.GetPageCount: Integer;
begin
  result := if fPages = nil then 0 else fPages.Count;
end;

method RptFormatter.DimensionToLength(aDimension: RptDimension; aDir: RptDirection): FmtLength;
begin
  // Characters per Inch
  var lCpi := if aDir = RptDirection.Horizontal then 10 else 6;
  if (aDimension = nil) or (aDimension.Unit = RptUnit.Measure) then
    result := -1
  else
    begin
      var lDistance :=
        case aDimension.Unit of
          RptUnit.Native: aDimension.Distance;
          RptUnit.MM:     lCpi / 25.4 * aDimension.Distance;
          RptUnit.Inch:   lCpi * aDimension.Distance;
          RptUnit.Pt:     lCpi / 72.27 * aDimension.Distance;
          else            aDimension.Distance;
        end;
      result := Math.Max(0, Utils.RoundUp(lDistance));
    end;
end;

method RptFormatter.DimensionsToLengths(aDimensions: RptDimensions): FmtLengths;
begin
  result := new FmtLengths(
    DimensionToLength(aDimensions.Horizontal, RptDirection.Horizontal),
    DimensionToLength(aDimensions.Vertical, RptDirection.Vertical));
end;

method RptFormatter.SetPageNumber(aNumber: Integer);
begin
  ffPageNumber := aNumber + fFirstPageNumber;
end;

method RptFormatter.TreePatternText(aText: String): String;
 const
   UNone = ' ';
   UThru = #$2502;
   ULink = #$251c;
   ULast = #$2514;
   ULine = #$2500;
begin
  if aText = nil then
    exit nil;
  result :=
    case Report.TreePattern of
      RptTreePattern.None,
      RptTreePattern.Lines:     RptTree.TreePattern(TreeIndent,    aText, ' ',  ' ',  ' ',  ' ',  ' ');
      RptTreePattern.PlusMinus: RptTree.TreePattern(TreeIndent,    aText, ' ',  '|',   '+', '+',  '-');
      RptTreePattern.Dots:      RptTree.TreePattern(TreeIndent,    aText, ' ',  '.',  '.',  '.',  ' ');
      RptTreePattern.AllDots:   RptTree.AllDotsPattern(TreeIndent, aText, '.', ' ');
      RptTreePattern.Unicode:   RptTree.TreePattern(TreeIndent, aText, UNone, UThru, ULink, ULast, ULine);
    end;
end;

method RptFormatter.DisplayedText(aBox: FmtBox): String;
begin
  result := nil;
  if aBox.IsGroup then
    exit;
  result := aBox:Element:Text;
  if String.IsNullOrEmpty(result) then
    exit
  else if aBox.Element is RptImage then
    result := $'[Image: {result}]'
  else if aBox.Element is RptMacro then
    begin
      var lMap := DoMapMacro(result);
      if lMap = nil then
        lMap := '[' + result + ']';
      result := lMap;
    end
  else if aBox.Element is RptTree then
    result := TreePatternText(result);
end;

method RptFormatter.MapMacro(aKey: String): String;
begin
  aKey := aKey.Trim.ToUpper;
  result :=
    if (aKey = 'DATE') or (aKey = 'DATE_SHORT') then
      ReportDate.ToShortDateString(TimeZone.Local)
    else if aKey = 'DATE_LONG' then
      ReportDate.ToLongPrettyDateString(TimeZone.Local)
    else if (aKey = 'TIME') or (aKey = 'TIME_SHORT') then
      ReportDate.ToString('h:mm', TimeZone.Local)
    else if aKey = 'TIME_LONG' then
      ReportDate.ToString('HH:mm:ss', TimeZone.Local)
    else if (aKey = 'DATETIME') or (aKey = 'DATETIME_SHORT') then
      MapMacro('DATE_SHORT') + ' ' + MapMacro('TIME_SHORT')
    else if aKey = 'DATETIME_LONG' then
      MapMacro('DATE_LONG') + ' ' + MapMacro('TIME_LONG')
    else if aKey = 'PAGE' then
      Utils.IntToStr(ffPageNumber)
    else if aKey = 'TITLE' then
      Report.Title
    else if (aKey = 'SECTION') or (aKey = 'SECTION_TITLE') then
      if ffCurrentSection = nil then ''
      else ffCurrentSection.Title
    else if aKey = 'SECTION_NUMBER' then
      if ffCurrentSection = nil then ''
      else Utils.IntToStr(ffCurrentSection.Number)
    else if aKey = 'SECTION_NUMBERS' then SectionNumber
    else if (aKey = 'TABLE') or (aKey = 'TABLE_TITLE') then
      if ffCurrentTable = nil then ''
      else ffCurrentTable.Title
    else if aKey = 'TABLE_NUMBER' then
      if ffCurrentTable = nil then ''
      else Utils.IntToStr(ffCurrentTable.Number)
    else nil;
end;

method RptFormatter.DoMapMacro(aKey: String): String;
begin
  result :=
    if assigned(fMacroMapper) then fMacroMapper(aKey)
    else MapMacro(aKey);
end;

// Context

method RptFormatter.ClearContext;
begin
  fAborted := false;
  ffPageNumber := 0;
  ffCurrentPage := nil;
  ffCurrentHeader := nil;
  ffCurrentFooter := nil;
  ffCurrentHeaderBox := nil;
  ffCurrentFooterBox := nil;
  ffCurrentSection := nil;
  ffCurrentTable := nil;
  ffBoxStack := new Stack<FmtBox>;
  ffPageFreeHeight := 0;
  ffProcessedBoxes := 0;
  ffFillingLeftToRight := true;
end;

method RptFormatter.UpdateContext;
begin
  ffCurrentHeader := nil;
  ffCurrentFooter := nil;
  ffCurrentSection := nil;
  ffCurrentTable := nil;
  var lStack := ffBoxStack.ToArray;
  for i := low(lStack) to high(lStack) do
    begin
      var lElement := lStack[i].Element;
      if lElement is RptReport then
        begin
          ffCurrentHeader := RptReport(lElement).Header;
          ffCurrentFooter := RptReport(lElement).Footer;
        end
      else if lElement is RptSection  then
         ffCurrentSection := RptSection(lElement)
      else if lElement is RptTable  then
         ffCurrentTable := RptTable(lElement);
    end;
end;

method RptFormatter.BeginBox(aBox: FmtBox);
begin
  ffBoxStack.Push(aBox);
  UpdateContext;
  inc(ffProcessedBoxes);
  if assigned(fOnNotify) then
    fOnNotify(fState, aBox, ffProcessedBoxes, fBoxCount, ffPageNumber);
end;

method RptFormatter.EndBox(aBox: FmtBox);
begin
  ffBoxStack.Pop;
  UpdateContext;
end;

method RptFormatter.SectionContext: List<RptSection>;
begin
  result := new  List<RptSection>;
  var lStack := ffBoxStack.ToArray;
  for i := high(lStack) downto low(lStack) do
    if lStack[i].Element is RptSection then
      result.Add(RptSection(lStack[i].Element));
end;

method  RptFormatter.SectionNumber(aDelimiter: String := '.'): String;
begin
  result := '';
  for each lSection in SectionContext do
    result := Utils.AppendStr(result, Utils.IntToStr(lSection.Number), aDelimiter);
end;

// Measure

method RptFormatter.MeasureText(aText: String): FmtLengths;
begin
  result := new FmtLengths(0, 0);
  if aText <> nil then
    begin
      result.Horizontal := aText.Length;
      result.Vertical := 1;
    end;
end;

method RptFormatter.MeasureText(aBox: FmtBox): FmtLengths;
begin
  result := MeasureText(DisplayedText(aBox));
end;

method RptFormatter.MeasureBox(aBox: FmtBox);
begin
    aBox.IntLengths := MeasureText(aBox);
    if (aBox:Element is RptLine) and (aBox.IntLengths.Vertical = 0) then
      aBox.IntLengths.Vertical := 1;
end;

method RptFormatter.MeasureInt(aBox: FmtBox);
require
  aBox <> nil;
begin
  if not aBox.IsGroup then
    MeasureBox(aBox)
  else
    begin
      aBox.IntLengths.Clear;
      for i := 0 to aBox.Count - 1 do
        begin
          aBox.IntLengths[aBox.PrimaryDirection] :=
            aBox.IntLengths[aBox.PrimaryDirection] + aBox.Box[i].ExtLengths[aBox.PrimaryDirection];
          aBox.IntLengths[aBox.SecondaryDirection] :=
            Math.Max(aBox.IntLengths[aBox.SecondaryDirection], aBox.Box[i].IntLengths[aBox.SecondaryDirection]);
        end;
    end;
end;

method RptFormatter.MeasureExt(aBox: FmtBox);
require
  aBox <> nil;
begin
  var lRpt := aBox:Element;
  aBox.Width :=
    if lRpt:HDimension = nil then -1
    else DimensionToLength(lRpt.HDimension, RptDirection.Horizontal);
  aBox.Height :=
    if lRpt:VDimension = nil then -1
    else DimensionToLength(lRpt.VDimension, RptDirection.Vertical);
end;

method RptFormatter.MeasureIntToExt(aBox: FmtBox);
require
  aBox <> nil;
begin
  var lRpt := aBox:Element;
  if aBox.Width < 0 then
    begin
      var lDistance := if lRpt:HDimension = nil then 1.0 else lRpt.HDimension.Distance;
      if (lRpt:HDimension = nil) or (lRpt.HDimension.Unit = RptUnit.Measure) then
        aBox.Width := Math.Max(0, Math.Round(lDistance * aBox.IntWidth));
    end;
  if aBox.Height < 0 then
    begin
      var lDistance := if lRpt:VDimension = nil then 1.0 else lRpt.VDimension.Distance;
      if (lRpt:VDimension = nil) or (lRpt.VDimension.Unit = RptUnit.Measure) then
        aBox.Height := Math.Max(0, Math.Round(lDistance * aBox.IntHeight));
    end;
end;

method RptFormatter.MeasureIntPlaced(aBox: FmtBox);
require
  aBox <> nil;
begin
  aBox.IntLengths.Clear;
  if not aBox.IsGroup then
    MeasureInt(aBox)
  else
    begin
      var lBox := aBox.Box[0];
      var L := lBox.Left;
      var T := lBox.Top;
      var R := lBox.Right;
      var B := lBox.Bottom;
      for i := 1 to aBox.Count - 1 do
        begin
          lBox := aBox.Box[i];
          L := Math.Min(L, lBox.Left);
          T := Math.Min(T, lBox.Top);
          R := Math.Max(R, lBox.Right);
          B := Math.Max(B, lBox.Bottom);
        end;
      aBox.IntLengths.Horizontal := R - L + 1;
      aBox.IntLengths.Vertical := B - T + 1;
    end;
end;

{$REGION Make Boxes: Convert report to a hierarchy of unpositioned boxes}

method RptFormatter.MakeLinesBox(aRpt: RptLines; aBox: FmtBox);
begin
  var lLines := Utils.BreakToLines(aRpt.Text);
  if lLines = nil then
    exit;
  for each lText in lLines do
    begin
      var lLine := new RptLine;
      lLine.Wr(lText);
      var lBox := MakeBox(lLine);
      aBox.Add(lBox);
    end;
  aBox.Element := nil;
end;

method RptFormatter.MakeParagraphBox(aRpt: RptParagraph; aBox: FmtBox);

  method AppendRpt(aRpt: RptElement);
  begin
    var lBox := MakeBox(aRpt);
    aBox.Add(lBox)
  end;

  method FormatText(aText: String);
  begin
    var lWords := Utils.BreakToWords(aText);
    if lWords = nil then
      exit;
    for i := 0 to lWords.Count - 1 do
      begin
        if i > 0 then
          begin
            var lHBreak := new RptWordBreak(aRpt.IntAlign.Horizontal = RptAlign.Fill);
            AppendRpt(lHBreak);
          end;
        var lText := new RptText(lWords[i]);
        AppendRpt(lText);
      end;
  end;

begin
  FormatText(aRpt.Text);
  for i := 0 to aRpt.Count - 1 do
    begin
      if aRpt[i] is RptFormattedText then
        begin
          var lBeginRpt := new RptBeginFormat(RptFormattedText(aRpt[i]).Format);
          AppendRpt(lBeginRpt);
          FormatText(aRpt[i].Text);
          var lEndRpt := new RptEndFormat(lBeginRpt);
          AppendRpt(lEndRpt);
        end
      else if (aRpt[i] is RptText) and (aRpt[i] is not RptMacro) then
        FormatText(aRpt[i].Text)
      else
        AppendRpt(aRpt[i]);
  end;
end;

method RptFormatter.MakeBox(aRpt: RptElement): FmtBox;
begin
  result := new FmtBox(aRpt);
  if aRpt is RptLines then
    MakeLinesBox(RptLines(aRpt), result)
  else if aRpt is RptParagraph then
    MakeParagraphBox(RptParagraph(aRpt), result)
  else if aRpt is RptGroup then
    begin
      var lRptGroup := RptGroup(aRpt);
      for i := 0 to lRptGroup.Count - 1 do
        begin
          var lBox := MakeBox(lRptGroup.Element[i]);
          result.Add(lBox);
        end;
    end;
end;

method RptFormatter.MakeBoxes;
begin
  fState := FmtState.Making;
  fBoxes := MakeBox(fReport);
  fBoxCount := fBoxes.BoxCount;
end;

{$ENDREGION}

{$REGION Format Boxes: Measure and format boxes recursively from bottom to the top}

// In this stage, some boxes may be replaced or restructured

method RptFormatter.UnplaceBox(aBox: FmtBox);
begin
  for i := 0 to aBox.Count - 1 do
    aBox[i].Offset.Clear;
end;

method RptFormatter.PreFormatBox(aBox: FmtBox; aWidth: FmtLength := -1);
begin
end;

method RptFormatter.UnFormatParagraph(aBox: FmtBox; aWidth: FmtLength := -1): List<FmtBox>;
begin
  result := new List<FmtBox>;
  for i := 0 to aBox.Count - 1 do
    if aBox[i]:Element is RptParagraphLine then
      begin
        result.Add(aBox[i].Boxes);
        var lHBreak := new RptWordBreak(aBox.IntAlign.Horizontal = RptAlign.Fill);
        var lBox := MakeBox(lHBreak);
        result.Add(lBox);
      end
    else
      result.Add(aBox[i]);
end;

method RptFormatter.PostFormatParagraph(aBox: FmtBox; aWidth: FmtLength := -1);
var
  HBox: FmtBox;
  HBoxWidth: FmtLength;
  HBoxCount: FmtLength;

  method BeginHBox;
  begin
    var lParaLine := new RptParagraphLine;
    lParaLine.ExtAlign := aBox.ExtAlign;
    HBox := new FmtBox(lParaLine);
    HBox.PrimaryDirection := RptDirection.Horizontal;
    HBoxWidth := 0;
    HBoxCount := 0;
    aBox.Add(HBox);
  end;

  method EndHBox;
  begin
    if HBox.Count > 0 then
      if HBox[0]:Element is RptWordBreak then
        HBox.Boxes.RemoveAt(0);
    if HBox.Count > 0 then
      if HBox[HBox.Count - 1]:Element is RptWordBreak then
        HBox.Boxes.RemoveAt(HBox.Count - 1);
  end;

 method TestBreak(aLength: FmtLength): Boolean;
  begin
    result := (aWidth >= 0) and (HBoxCount > 0) and ((HBoxWidth + aLength) > aWidth);
  end;

begin
  ffFillingLeftToRight := true;
  var lBoxes := UnFormatParagraph(aBox, aWidth);
  if (lBoxes = nil) or (lBoxes.Count = 0) then
    exit;
  aBox.Boxes.RemoveAll;
  BeginHBox;
  for i := 0 to lBoxes.Count - 1 do
    begin
      if TestBreak(lBoxes[i].Width) then
        begin
          EndHBox;
          BeginHBox;
        end;
      HBox.Add(lBoxes[i]);
      HBoxWidth := HBoxWidth + lBoxes[i].Width;
      inc(HBoxCount);
    end;
  HBox.ExtAlign.Horizontal := RptAlign.First;
  for each lBox in HBox.Boxes do
    if lBox.ExtAlign.Horizontal = RptAlign.Fill then
      lBox.ExtAlign.Horizontal := RptAlign.First;
  EndHBox;
  for i := 0 to aBox.Count - 1 do
    FormatBox(aBox[i], aWidth);
end;

method RptFormatter.PostFormatTable(aBox: FmtBox; aWidth: FmtLength := -1);
begin
  var lTable := aBox.Element as RptTable;
  var lColWidths := Utils.NewIntArray(lTable.ColCount, 0);
  var lMultiColumns := false;

  // Pass 1: Calculate the widths of single-cell columns
  for each lBox in aBox.Boxes do
    if lBox.Element is RptRow then
      for each cBox in lBox.Boxes do
        if cBox.Element is RptCell then
          begin
            var lCell := RptCell(cBox.Element);
            if lCell.FromColumn = lCell.ToColumn then
              lColWidths[lCell.FromColumn] := Math.Max(lColWidths[lCell.FromColumn], cBox.Width)
            else
              lMultiColumns := true;
          end;

  // Pass 2: Adjust multicolumns
  if lMultiColumns then
    for each lBox in aBox.Boxes do
      if lBox.Element is RptRow then
        for each cBox in lBox.Boxes do
          if cBox.Element is RptCell then
            begin
              var lCell := RptCell(cBox.Element);
              if lCell.FromColumn < lCell.ToColumn then
                begin
                  var lPreWidth := 0;
                  for i := lCell.FromColumn to lCell.ToColumn - 1 do
                    lPreWidth := lPreWidth + lColWidths[i];
                  lColWidths[lCell.ToColumn] := Math.Max(lColWidths[lCell.ToColumn], cBox.Width - lPreWidth);
                end;
            end;

  // Calculate cumulative Width
  var lWidth := 0;
  for i := low(lColWidths) to high(lColWidths) do
    lWidth := lWidth + lColWidths[i];

  // Pass 3: Set cell widths and lefts
  for each lBox in aBox.Boxes do
    if lBox.Element is RptRow then
      begin
        var lNextLeft := 0;
        for each cBox in lBox.Boxes do
          begin
            if cBox.Element is RptCell then
              begin
                var lCell := RptCell(cBox.Element);
                cBox.Width := lColWidths[lCell.ToColumn];
              end;
            cBox.Left := lNextLeft;
            lNextLeft := lNextLeft + cBox.Width;
        end;
      end;
  aBox.Width := lWidth;
end;

method RptFormatter.PostFormatBox(aBox: FmtBox; aWidth: FmtLength := -1);
begin
  if aBox:Element is RptParagraph then
    PostFormatParagraph(aBox, aWidth)
  else if aBox:Element is RptTable then
    PostFormatTable(aBox, aWidth);
end;

method RptFormatter.FillIndex(aIdx, aCount: Integer): Integer;
begin
  var LR :=
    (FillStyle = FmtFillStyle.LeftToRight) or
    (FillStyle = FmtFillStyle.Alternate) and ffFillingLeftToRight;
  result :=
    if LR then aIdx
    else aCount - aIdx - 1;
end;

method RptFormatter.FillBox(aBox: FmtBox);
begin
  var lFillList := new List<FmtBox>;
  var lDir := aBox.PrimaryDirection;
  for i := 0 to aBox.Count - 1 do
    if aBox[i].ExtAlign[lDir] = RptAlign.Fill then
      lFillList.Add(aBox[i]);
  if lFillList.Count > 0 then
    begin
      var lGap := aBox.ExtLengths[lDir] - aBox.IntLengths[lDir];
      var lFill := lGap div lFillList.Count;
      lGap := lGap mod lFillList.Count;
      if (lFill > 0) or (lGap > 0) then
        for i := 0 to lFillList.Count - 1 do
          begin
            // reverse the insertion order for every other line
            var j := FillIndex(i, lFillList.Count);
            var lBox := lFillList[j];
            lBox.ExtLengths[lDir] := lBox.ExtLengths[lDir] + lFill;
            if lGap > 0 then
              begin
                lBox.ExtLengths[lDir] := lBox.ExtLengths[lDir] + 1;
                dec(lGap);
              end;
            lBox.ExtAlign[lDir] := RptAlign.First;
          end;
      ffFillingLeftToRight := not ffFillingLeftToRight;
    end;
  for each lBox in aBox.Boxes do
    begin
      UnplaceBox(lBox);
      FillBox(lBox);
      JustifyBox(lBox);
      PlaceBox(lBox);
      MeasureIntPlaced(lBox);
    end;
  MeasureInt(aBox);
end;

method RptFormatter.JustifyBox(aBox: FmtBox);
begin
  var lDir := aBox.SecondaryDirection;
  for i := 0 to aBox.Count - 1 do
    case aBox[i].ExtAlign[lDir] of
      RptAlign.Fill:
        begin
          aBox[i].Offset[lDir] := 0;
          aBox[i].ExtLengths[lDir] := aBox.ExtLengths[lDir];
        end;
      RptAlign.First:
        aBox[i].Offset[lDir] := 0;
      RptAlign.Middle:
        aBox[i].Offset[lDir] := (aBox.ExtLengths[lDir] - aBox[i].ExtLengths[lDir]) div 2;
      RptAlign.Last:
        aBox[i].Offset[lDir] := aBox.ExtLengths[lDir] - aBox[i].ExtLengths[lDir];
    end;
  MeasureInt(aBox);
end;

method RptFormatter.PlaceBox(aBox: FmtBox);
begin
  var lOff := aBox.IntOffset.Copy;
  var lPrimDir := aBox.PrimaryDirection;
  var lOthrDir := aBox.SecondaryDirection;
  for i := 0 to aBox.Count - 1 do
    begin
      aBox[i].Offset[lPrimDir] := lOff[lPrimDir];
      lOff[lPrimDir] := lOff[lPrimDir] + aBox[i].ExtLengths[lPrimDir];
      aBox[i].Offset[lOthrDir] := aBox[i].Offset[lOthrDir] + lOff[lOthrDir];
    end;
end;

method RptFormatter.BeginFormat;
begin
  ClearContext;
end;

method RptFormatter.FormatBox(aBox: FmtBox; aWidth: FmtLength := -1);
begin
  if aBox = nil then
    exit;
  BeginBox(aBox);
  try
    UnplaceBox(aBox);
    PreFormatBox(aBox, aWidth);
    for i := 0 to aBox.Count - 1 do
      FormatBox(aBox[i], aWidth);
    PostFormatBox(aBox, aWidth);
    MeasureExt(aBox);
    MeasureInt(aBox);
    MeasureIntToExt(aBox);
    if (aWidth >= 0) and (aBox.PrimaryDirection = RptDirection.Vertical) then
      aBox.Width := aWidth;
    FillBox(aBox);
    JustifyBox(aBox);
    PlaceBox(aBox);
  finally
    EndBox(aBox);
  end;
end;

method RptFormatter.FormatBoxes;
begin
  BeginFormat;
  try
    fState := FmtState.Formatting;
    FormatBox(fBoxes, GetFreeWidth);
    fBoxCount := fBoxes.BoxCount;
  finally
    EndFormat;
  end;
end;

{$ENDREGION}

{$REGION Paginate Boxes}

method RptFormatter.GetFreeWidth: FmtLength;
begin
  result := fPageLengths.Horizontal;
end;

method RptFormatter.GetFreeHeight: FmtLength;
begin
  result := fPageLengths.Vertical;
end;

method RptFormatter.PlaceTo(aBox: FmtBox; aAbsOffset: FmtLengths);
begin
  aBox.Offset := aAbsOffset.Copy;
  for i := 0 to aBox.Count - 1 do
    PlaceTo(aBox[i], FmtLengths.AddLengths(aAbsOffset, aBox[i].Offset));
end;

method RptFormatter.BeginPaginate;
begin
  fPages.RemoveAll;
  ClearContext;
  ffCurrentHeader := fReport.Header;
  ffCurrentFooter := fReport.Footer;
end;

method RptFormatter.EndPaginate;
begin
end;

method RptFormatter.BeginPage;
begin
  ffPageNumber := ffPageNumber + 1;
  var lPage := new FmtBox(nil, PrimaryDirection := RptDirection.Vertical);
  lPage.IntAlign.Vertical := RptAlign.Fill;
  lPage.Offset := fPageOffset.Copy;
  lPage.ExtLengths := fPageLengths.Copy;
  ffCurrentPage := lPage;
  ffPageFreeHeight := GetFreeHeight;
  ffPageBoxesCount := 0;
  if ffCurrentHeader <> nil then
    begin
      var lBox := MakeBox(ffCurrentHeader);
      FormatBox(lBox, GetFreeWidth);
      ffCurrentPage.Add(lBox);
      ffCurrentHeaderBox := lBox;
      ffPageFreeHeight := ffPageFreeHeight - lBox.Height;
    end;
  if ffCurrentFooter <> nil then
    begin
      var lBox := MakeBox(ffCurrentFooter);
      FormatBox(lBox, GetFreeWidth);
      // add later to the page
      ffCurrentFooterBox := lBox;
      ffPageFreeHeight := ffPageFreeHeight - lBox.Height;
    end;
end;

method RptFormatter.NewPage;
begin
 if ffPageBoxesCount > 0 then
   begin
     EndPage;
     BeginPage;
   end;
end;

method RptFormatter.FormatPage(aPage: FmtBox);
begin
  MeasureInt(aPage);
  MeasureIntToExt(aPage);
  FillBox(aPage);
  PlaceBox(aPage);
  PlaceTo(aPage, fPageOffset);
end;

method RptFormatter.EndPage;
begin
  if ffCurrentHeaderBox <> nil then
    {nothing};
  if ffCurrentFooterBox <> nil then
    ffCurrentPage.Add(ffCurrentFooterBox);
  FormatPage(ffCurrentPage);
  fPages.Add(ffCurrentPage);
  ffCurrentPage := nil;
  UpdateContext;
end;

method RptFormatter.IsFree(aHeight: FmtLength): Boolean;
begin
  result :=
    if fPageLengths.Vertical <= 0 then true
    else aHeight <= ffPageFreeHeight;
end;

method RptFormatter.CanBreak(aBox: FmtBox): Boolean;
begin
  result := aBox.IsGroup and (aBox.PrimaryDirection = RptDirection.Vertical);
end;

method RptFormatter.CanPaginate(aBox: FmtBox): Boolean;
begin
  if aBox.Element is RptReport then
    if aBox.Element.VExtAlign = RptAlign.Fill then
      exit false;
  if aBox.PageBreak = RptSection.BreakUncond then
    NewPage
  else if (aBox.PageBreak = RptSection.BreakAll) or not CanBreak(aBox) then
    begin
      if not IsFree(aBox.Height) then
        NewPage;
    end
  else if aBox.PageBreak = RptSection.BreakNone then {nothing}
  else
    begin
      var H := 0;
      for i := 0 to aBox.PageBreak - 1 do
        H := H + aBox[i].Height;
      if not IsFree(H) then
        NewPage;
    end;
  result := IsFree(aBox.Height);
end;

method RptFormatter.PaginateBox(aBox: FmtBox);
begin
  if Aborted then
    exit;
  BeginBox(aBox);
  try
    var lCanPaginate := CanPaginate(aBox);
    var lCanBreak := CanBreak(aBox);
    if lCanPaginate or not lCanBreak then
      begin
        ffCurrentPage.Add(aBox);
        var lCount := aBox.BoxCount;
        ffPageBoxesCount := ffPageBoxesCount + lCount - 1;
        ffProcessedBoxes := ffProcessedBoxes + lCount - 1;
        ffPageFreeHeight := ffPageFreeHeight - aBox.Height;
      end
    else
      begin
        for i := 0 to aBox.Count - 1 do
          PaginateBox(aBox[i]);
        inc(ffPageBoxesCount);
      end;
  finally
    EndBox(aBox);
  end;
end;

method RptFormatter.PaginateBoxes;
begin
  fState := FmtState.Paginating;
  BeginPaginate;
  BeginPage;
  try
    PaginateBox(fBoxes);
  finally
    EndPage;
    EndPaginate;
  end;
end;

{$ENDREGION}

method RptFormatter.Format;
begin
  MakeBoxes;
  if LogFileNamePrefix <> nil then
    ListBoxes(LogFileNamePrefix + 'MakeBoxes.txt');
  FormatBoxes;
  if LogFileNamePrefix <> nil then
    ListBoxes(LogFileNamePrefix + 'FormatBoxes.txt');
  PaginateBoxes;
  if LogFileNamePrefix <> nil then
    ListBoxes(LogFileNamePrefix + 'PaginateBoxes.txt', Pages);
  fState := FmtState.Idle;
end;

method RptFormatter.Abort;
begin
  fAborted := true;
end;

{$REGION List Boxes}

method RptFormatter.ListBox(aBox: FmtBox; aLevel: Integer := 0): List<String>;
var lList: List<String>;

  method AddBox(aBox: FmtBox; aLevel: Integer);
  begin
    BeginBox(aBox);
    try
      var lRpt := aBox.Element;
      var lRect := aBox.Rectangle;
      var lLevel := Utils.ChString(aLevel, '. ');
      var lType := if lRpt = nil then 'NIL' else typeOf(lRpt).Name;
      lList.Add($'{lLevel} [{lRect.ToString}] {lType} "{lRpt:Text}"');
      for lIdx := 0 to aBox.Count - 1 do
        AddBox(aBox[lIdx], aLevel + 1);
    finally
      EndBox(aBox);
    end;
  end;

begin
  lList := new List<String>;
  AddBox(aBox, aLevel);
  result := lList;
end;

method RptFormatter.ListBoxes(aBoxes: sequence of FmtBox; aLevel: Integer := 0): List<String>;
begin
  result := new List<String>;
  for each lBox in aBoxes do
    begin
      var lList := ListBox(lBox, aLevel);
      result.Add(lList);
    end;
end;

method RptFormatter.ListBoxes(aFileName: String);
begin
  var lList := ListBox(fBoxes);
  File.WriteLines(aFileName, lList);
end;

method RptFormatter.ListBoxes(aFileName: String; aBoxes: sequence of FmtBox);
begin
  var lList := ListBoxes(aBoxes);
  File.WriteLines(aFileName, lList);
end;

{$ENDREGION}

{$ENDREGION}

{$REGION RptTextPage}

method RptTextPage.AssureLine(aIdx: Integer);
begin
  while Count < (aIdx + 1) do
    &Add('');
end;

method RptTextPage.AssureLines(aRect: FmtRectangle);
begin
  AssureLine(aRect.Bottom);
end;

method RptTextPage.AssureLineLength(aIdx: Integer; aLength: FmtLength);
begin
  AssureLine(aIdx);
  var lLine := self[aIdx];
  if lLine.Length < aLength then
    self[aIdx] := lLine + Utils.ChStr(aLength - lLine.Length);
end;

method RptTextPage.AssureRect(aRect: FmtRectangle);
begin
  AssureLines(aRect);
  for lLine := aRect.Top to aRect.Bottom do
    AssureLineLength(lLine, aRect.Right + 1);
end;

method RptTextPage.Write(aText: String);
begin
  if String.IsNullOrEmpty(aText) then
    exit;
  if Count = 0 then
    &Add('');
  self[Count - 1] := self[Count - 1] + aText;
end;

method RptTextPage.&WriteLn(aText: String);
begin
  &write(aText);
  &Add('');
end;

method RptTextPage.WriteLiner(aRect: FmtRectangle; aCh: Char);
begin
  if (aRect.Top < 0) or (aRect.Bottom < aRect.Top) or (aRect.Left < 0) or (aRect.Right < aRect.Left) then
    exit;
  AssureRect(aRect);
  var lLineChars := self[aRect.Top].ToCharArray;
  for i := aRect.Left to aRect.Right do
    if lLineChars[i] = ' ' then
      lLineChars[i] := aCh;
  self[aRect.Top] := lLineChars.JoinedString;
end;

method RptTextPage.Write(aRect: FmtRectangle; aText: String);
begin
  if (aText = nil) or (aRect.Top < 0) or (aRect.Bottom < aRect.Top) or (aRect.Left < 0) or (aRect.Right < aRect.Left) then
    exit;
  AssureRect(aRect);
  aText := Utils.PadTo(aText, aRect.Width);
  var lLine := self[aRect.Top];
  lLine := lLine.Replace(aRect.Left, aRect.Width, aText);
  self[aRect.Top] := lLine;
end;

method RptTextPage.TrimPage;
begin
  for i := 0 to Count - 1 do
    self[i] := self[i].TrimEnd;
end;

{$ENDREGION}

{$REGION RptTextFormatter}

constructor RptTextFormatter(aReport: not nullable RptReport; aPageOffset: FmtLengths := nil; aPageLengths: FmtLengths := nil);
begin
  inherited constructor(aReport, aPageOffset, aPageLengths);
  fTextPages := new List<RptTextPage>;
end;

method RptTextFormatter.ClearContext;
begin
  inherited ClearContext;
  fLiners := new Stack<FmtRectangle>;
end;

method RptTextFormatter.BeginBox(aBox: FmtBox);
begin
  inherited BeginBox(aBox);
  if aBox:Element is RptBeginLiner then
    fLiners.Push(aBox.Rectangle)
end;

method RptTextFormatter.EndBox(aBox: FmtBox);
begin
  inherited EndBox(aBox);
  if aBox:Element is RptEndLiner then
    if fLiners.Count > 0 then
      fLiners.Pop;
end;

method RptTextFormatter.MeasureBox(aBox: FmtBox);
begin
  inherited MeasureBox(aBox);
  if (aBox:Element is RptBeginLiner) or (aBox:Element is RptEndLiner) then
    aBox.IntLengths.Vertical := if LinerBelow then 2 else 1;
end;

method RptTextFormatter.LineChar(aLines: Integer): Char;
begin
  result := if aLines > 1 then LineChar2 else LineChar1;
end;

method RptTextFormatter.RenderLines(aBegin, aEnd: FmtRectangle; aLines: Integer);
begin
  if (aBegin.Bottom <> aEnd.Bottom) or (aBegin.Left > aEnd.Right) then
    exit;
  var lLineChar := LineChar(aLines);
  var lLineRect := new FmtRectangle(aBegin.Left, aBegin.Bottom, aEnd.Left - aBegin.Left, 1);
  fCurrentTextPage.WriteLiner(lLineRect, lLineChar);
end;

method RptTextFormatter.RenderBox(aBox: FmtBox);
begin
  BeginBox(aBox);
  try
    var lRpt := aBox.Element;
    var lRect := aBox.Rectangle;
    if lRpt is RptEndLiner then
      begin
        if fLiners.Count > 0 then
          RenderLines(fLiners.Peek, lRect, RptEndLiner(lRpt).BeginLiner.Lines);
      end
    else if lRpt is not RptGroup then
      begin
        var lText := DisplayedText(aBox);
        fCurrentTextPage.Write(lRect, lText);
       end;
    for lIdx := 0 to aBox.Count - 1 do
      RenderBox(aBox[lIdx]);
  finally
    EndBox(aBox);
  end;
end;

method RptTextFormatter.Render;
begin
  ClearContext;
  State := FmtState.Rendering;
  Aborted := false;
  fTextPages.RemoveAll;
  for pIdx := 0 to PageCount - 1 do
    begin
      if Aborted then
        break;
      SetPageNumber(pIdx);
      fCurrentTextPage := new RptTextPage;
      fTextPages.Add(fCurrentTextPage);
      for each lBox in Page[pIdx].Boxes do
        RenderBox(lBox);
    end;
  State := FmtState.Idle;
end;

method RptTextFormatter.WriteToFile(aFileName: String; aFrom: Integer := 0; aTo: Integer := -1);
begin
  var lOutList := new List<String>;
  if aTo < 0 then
    aTo := PageCount - 1;
  ClearContext;
  for lPage := aFrom to aTo do
    begin
      var lCount := lOutList.Count;
      var lTextPage := TextPage[lPage];
      lTextPage.TrimPage;
      lOutList.Add(lTextPage);
      if lCount > 0 then
        lOutList[lCount] := #12 + lOutList[lCount];
    end;
  File.WriteLines(aFileName, lOutList);
end;

{$ENDREGION}

end.
