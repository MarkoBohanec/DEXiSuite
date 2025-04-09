// WinTreeDraw.pas is part of
//
// DEXiWin, DEXi Decision Modeling Software
//
// Copyright (C) 2023-2025 Department of Knowledge Technologies, Jožef Stefan Institute
//
// DEXiWin is free software, distributed under terms of the GNU General Public License
// as published by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// ----------
// WinTreeDraw.pas implements classes that facilitate drawing trees of attributes in a Windows
// environment based on tree placement provided by the DEXiLibrary tree-drawing algorithms.
// ----------

namespace DexiUtils;

interface

 uses
  System.Drawing,
  System.Drawing.Drawing2D,
  System.Drawing.Imaging,
  System.Windows.Forms,
  RemObjects.Elements.RTL;

type
  ShapeType = public enum (Rectangle, RoundRect, Ellipse);
  AnchorUnit = public enum (Pixel, Percent);

type
  Anchor = public class
  public
    constructor (aX: Integer; aUnitX: AnchorUnit; aY: Integer; aUnitY: AnchorUnit);
    constructor (aAnchor: Anchor);
    class method AnchorPos(X0, X1, A: Integer; UnitA: AnchorUnit; aReverse: Boolean): Integer;
    property X: Integer;
    property Y: Integer;
    property UnitX: AnchorUnit;
    property UnitY: AnchorUnit;
  end;

type
  IShape = public interface
    property Shape: ShapeType read;
    property RoundEdge: Anchor read;
    property LinePen: PenData read;
    property NodePen: PenData read;
    property NodeBrush: BrushData read;
  end;

type
  TreeNodeFormat = public class (IShape)
  private
    fFormatClass: String;
    fParent: TreeNodeFormat;
    fChildren: List<TreeNodeFormat>;
    fMinWidth: Integer;
    fMaxWidth: Integer;
    fMinHeight: Integer;
    fMaxHeight: Integer;
    fUpAnchor: Anchor;
    fDownAnchor: Anchor;
    fFont: Font;
    fFontBrush: BrushData;
    fLinePen: PenData;
    fNodePen: PenData;
    fNodeBrush: BrushData;
    fNodeAlign: HorizontalAlignment;
    fShape: ShapeType;
    fRoundEdge: Anchor;
    fTextBorder: ImgBorder;
    fTextWrap: Boolean;
    fTextClip: Boolean;
    fTextTrim: Integer;
    fTextXAlign: HorizontalAlignment;
    fTextYAlign: HorizontalAlignment;
    fLineSpacing: Float;
  protected
    method SetParent(aParent: TreeNodeFormat); virtual;
    method GetChildCount: Integer; virtual;
    method GetChild(aIdx: Integer): TreeNodeFormat; virtual;
    method SetMinWidth(aMinWidth: Integer); virtual;
    method SetMaxWidth(aMaxWidth: Integer); virtual;
    method SetMinHeight(aMinHeight: Integer); virtual;
    method SetMaxHeight(aMaxHeight: Integer); virtual;
    method SetUpAnchor(aUpAnchor: Anchor); virtual;
    method SetDownAnchor(aDownAnchor: Anchor); virtual;
    method GetFont: Font; virtual;
    method SetFont(aFont: Font); virtual;
    method GetFontBrush: BrushData; virtual;
    method SetFontBrush(aFontBrush: BrushData); virtual;
    method GetLinePen: PenData; virtual;
    method SetLinePen(aLinePen: PenData); virtual;
    method GetNodePen: PenData; virtual;
    method SetNodePen(aNodePen: PenData); virtual;
    method GetNodeBrush: BrushData; virtual;
    method SetNodeBrush(aNodeBrush: BrushData); virtual;
    method SetNodeAlign(aNodeAlign: HorizontalAlignment); virtual;
    method SetShape(aShape: ShapeType); virtual;
    method SetRoundEdge(aRoundEdge: Anchor); virtual;
    method SetTextBorder(aTextBorder: ImgBorder); virtual;
    method SetTextBorderTop(aPix: Integer); virtual;
    method SetTextBorderBottom(aPix: Integer); virtual;
    method SetTextBorderLeft(aPix: Integer); virtual;
    method SetTextBorderRight(aPix: Integer); virtual;
    method SetTextWrap(aTextWrap: Boolean); virtual;
    method SetTextClip(aTextClip: Boolean); virtual;
    method SetTextTrim(aTextTrim: Integer); virtual;
    method SetTextXAlign(aTextXAlign: HorizontalAlignment); virtual;
    method SetTextYAlign(aTextYAlign: HorizontalAlignment); virtual;
    method SetLineSpacing(aLineSpacing: Float); virtual;
  public
    constructor (aClass: String := ''; aParent: TreeNodeFormat := nil);
    method Assign(aNodeFormat: TreeNodeFormat); virtual;
    method AddChild(aNodeFormat: TreeNodeFormat);
    method AddChild(aClass: String): TreeNodeFormat;
    method DeleteChild(aNodeFormat: TreeNodeFormat);
    method Find(aClass: String): TreeNodeFormat;
    method Find(aFormat: TreeNodeFormat): TreeNodeFormat;
    method ParentPath: List<TreeNodeFormat>;
    method PropagateToChildren;
    property FormatClass: String read fFormatClass write fFormatClass;
    property Parent: TreeNodeFormat read fParent write SetParent;
    property ChildCount: Integer read GetChildCount;
    property Child[aIdx: Integer]: TreeNodeFormat read GetChild;
    property MinWidth: Integer read fMinWidth write SetMinWidth;
    property MaxWidth: Integer read fMaxWidth write SetMaxWidth;
    property MinHeight: Integer read fMinHeight write SetMinHeight;
    property MaxHeight: Integer read fMaxHeight write SetMaxHeight;
    property UpAnchor: Anchor read fUpAnchor write SetUpAnchor;
    property DownAnchor: Anchor read fDownAnchor write SetDownAnchor;
    property Font: Font read GetFont write SetFont;
    property FontBrush: BrushData read GetFontBrush write SetFontBrush;
    property LinePen: PenData read GetLinePen write SetLinePen;
    property NodePen: PenData read GetNodePen write SetNodePen;
    property NodeBrush: BrushData read GetNodeBrush write SetNodeBrush;
    property NodeAlign: HorizontalAlignment read fNodeAlign write SetNodeAlign;
    property Shape: ShapeType read fShape write SetShape;
    property RoundEdge: Anchor read fRoundEdge write SetRoundEdge;
    property TextBorder: ImgBorder read fTextBorder write SetTextBorder;
    property TextBorderTop: Integer write SetTextBorderTop;
    property TextBorderBottom: Integer write SetTextBorderBottom;
    property TextBorderLeft: Integer write SetTextBorderLeft;
    property TextBorderRight: Integer write SetTextBorderRight;
    property TextWrap: Boolean read fTextWrap write SetTextWrap;
    property TextClip: Boolean read fTextClip write SetTextClip;
    property TextTrim: Integer read fTextTrim write SetTextTrim;
    property TextXAlign: HorizontalAlignment read fTextXAlign write SetTextXAlign;
    property TextYAlign: HorizontalAlignment read fTextYAlign write SetTextYAlign;
    property LineSpacing: Float read fLineSpacing write SetLineSpacing;
    class property DefaultFormat: TreeNodeFormat :=
      new TreeNodeFormat('default',
        Font := SystemFonts.DefaultFont,
        FontBrush := new BrushData(Color.Black),
        LinePen := new PenData(Color.Black),
        NodePen := new PenData(Color.Black),
        NodeBrush := new BrushData(Color.White));
  end;

type
  WinTreeDrawingAlgorithm = public class (TreeDrawingAlgorithmQP)
  private
    fGraphics: Graphics;
    fBorder: ImgBorder;
    fBackgroundColor: Color;
    fDrawSelected: Boolean;
    fHS: Integer;
    fVS: Integer;
  protected
    method GetXMirror: Boolean; override;
    method GetWinRoot: WinTreeDrawNode;
    method GetBoxWidth: Integer;
    method GetBoxHeight: Integer;
    method DrawText(aNode: WinTreeDrawNode); virtual;
    method DrawLine(aNode: WinTreeDrawNode); virtual;
    method DrawSelection(aNode: WinTreeDrawNode); virtual;
    method DrawNode(aNode: WinTreeDrawNode); virtual;
   public
    constructor (aGraphics: Graphics);
    property Graphics: Graphics read fGraphics write fGraphics;
    method Place; override;
    method Place(aGraphics: Graphics); virtual;
    method Draw(aGraphics: Graphics := nil); virtual;
    method PosPoint(X, Y: Integer): Point;
    method MakeBitmap(aPlace: Boolean := true): Bitmap;
    method MakeMetafile(aPlace: Boolean := true): Metafile;
    method MakeMetafileData: array of Byte;
    method HitTest(X, Y: Integer): TreeDrawNode;
    method DrawShape(aGraphics: Graphics;  aRect: Rectangle; aShape: IShape);
    method ShapePicture(aShape: IShape; aRect: Rectangle): Bitmap;
    property WinRoot: WinTreeDrawNode read GetWinRoot;
    property Border: ImgBorder read fBorder write fBorder;
    property BackgroundColor: Color read fBackgroundColor write fBackgroundColor;
    property HS: Integer read fHS;
    property VS: Integer read fVS;
    property BoxWidth: Integer read GetBoxWidth;
    property BoxHeight: Integer read GetBoxHeight;
    property DrawSelected: Boolean read fDrawSelected write fDrawSelected;
  end;

type
  WinTreeDrawNode = public class (TreeDrawNode, IShape)
  private
    fText: String;
    fLines: List<String>;
    fTextWidth: Integer;
    fTextHeight: Integer;
    fLineHeight: Integer;
    fNodeFormat: TreeNodeFormat;
  protected
    method GetWinDrawingAlgorithm: WinTreeDrawingAlgorithm;
    method GetNodeClass: String; virtual;
    method SetNodeClass(aClass: String); virtual;
    method GetNodeFormat: TreeNodeFormat; virtual;
    method SetNodeFormat(aFormat: TreeNodeFormat); virtual;
    method GetText: String; override;
    method GetIsSelected: Boolean; virtual;
    method GetWidth: Float; override;
    method GetHeight: Float; override;
    method GetLeftWidth: Float; override;
    method GetRightWidth: Float; override;
    method GetTopHeight: Float; override;
    method GetBottomHeight: Float; override;
    method GetMinWidth: Float; virtual;
    method GetMaxWidth: Float; virtual;
    method GetMinHeight: Float; virtual;
    method GetMaxHeight: Float; virtual;
    method GetUpAnchor: Anchor; virtual;
    method GetDownAnchor: Anchor; virtual;
    method GetFont: Font; virtual;
    method GetFontBrush: BrushData; virtual;
    method GetLinePen: PenData; virtual;
    method GetNodePen: PenData; virtual;
    method GetNodeBrush: BrushData; virtual;
    method GetNodeAlign: HorizontalAlignment; virtual;
    method GetShape: ShapeType; virtual;
    method GetRoundEdge: Anchor; virtual;
    method GetTextBorder: ImgBorder; virtual;
    method GetTextWrap: Boolean; virtual;
    method GetTextClip: Boolean; virtual;
    method GetTextTrim: Integer; virtual;
    method GetTextXAlign: HorizontalAlignment; virtual;
    method GetTextYAlign: HorizontalAlignment; virtual;
    method GetLineSpacing: Float; virtual;
    method GetLineCount: Integer; virtual;
    method GetLine(aIdx: Integer): String; virtual;
    method TextFormat; virtual;
   public
    constructor (aText: String);
    method Clear;
    method NodeRect(out PX0, PY0, PX1, PY1: Integer);
    method NodeRect: Rectangle;
    method NodePoint(out PX, PY: Integer);
    method NodePoint: Point;
    method AnchorPoint(A: Anchor; out AX, AY: Integer);
    method AnchorPoint(A: Anchor): Point;
    method UpPoint(out AX, AY: Integer);
    method UpPoint: Point;
    method DownPoint(out AX, AY: Integer);
    method DownPoint: Point;
    method MeasureWidth(aText: String): Integer;
    method MeasureHeight(aText: String): Integer;
    property DrawingAlgorithm: WinTreeDrawingAlgorithm read GetWinDrawingAlgorithm;
    property NodeClass: String read GetNodeClass write SetNodeClass;
    property NodeFormat: TreeNodeFormat read GetNodeFormat write SetNodeFormat;
    property IsSelected: Boolean read GetIsSelected;
    property WinItem[aIdx: Integer]: WinTreeDrawNode read GetItem(aIdx) as WinTreeDrawNode;
    property MinWidth: Float read GetMinWidth;
    property MaxWidth: Float read GetMaxWidth;
    property MinHeight: Float read GetMinHeight;
    property MaxHeight: Float read GetMaxHeight;
    property UpAnchor: Anchor read GetUpAnchor;
    property DownAnchor: Anchor read GetDownAnchor;
    property Font: Font read GetFont;
    property FontBrush: BrushData read GetFontBrush;
    property LinePen: PenData read GetLinePen;
    property NodePen: PenData read GetNodePen;
    property NodeBrush: BrushData read GetNodeBrush;
    property NodeAlign: HorizontalAlignment read GetNodeAlign;
    property Shape: ShapeType read GetShape;
    property RoundEdge: Anchor read GetRoundEdge;
    property TextBorder: ImgBorder read GetTextBorder;
    property TextWrap: Boolean read GetTextWrap;
    property TextClip: Boolean read GetTextClip;
    property TextTrim: Integer read GetTextTrim;
    property TextXAlign: HorizontalAlignment read GetTextXAlign;
    property TextYAlign: HorizontalAlignment read GetTextYAlign;
    property TextWidth: Integer read fTextWidth;
    property TextHeight: Integer read fTextHeight;
    property LineHeight: Integer read fLineHeight;
    property LineSpacing: Float read GetLineSpacing;
    property LineCount: Integer read GetLineCount;
    property Line[aIdx: Integer]: String read GetLine;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION Anchor}

constructor Anchor(aX: Integer; aUnitX: AnchorUnit; aY: Integer; aUnitY: AnchorUnit);
begin
  inherited constructor;
  X := aX;
  Y := aY;
  UnitX := aUnitX;
  UnitY := aUnitY;
end;

constructor Anchor(aAnchor: Anchor);
begin
  constructor (aAnchor.X, aAnchor.UnitX, aAnchor.Y, aAnchor.UnitY);
end;

class method Anchor.AnchorPos(X0, X1, A: Integer; UnitA: AnchorUnit; aReverse: Boolean): Integer;
begin
  result :=
    if aReverse then
      if UnitA = AnchorUnit.Pixel then X1 - A
      else X0 + Math.Round((X1 - X0) * (100 - A) / 100.0)
    else
      if UnitA= AnchorUnit.Pixel then X0 + A
      else X0 + Math.Round((X1 - X0) * A / 100.0)
end;

{$ENDREGION}

{$REGION GraphicsUtils}

{$ENDREGION}

{$REGION TreeNodeFormat}

constructor TreeNodeFormat(aClass: String := ''; aParent: TreeNodeFormat := nil);
begin
  inherited constructor;
  fChildren := new List<TreeNodeFormat>;
  fFormatClass := aClass;
  fFont := nil;
  fFontBrush := nil;
  fLinePen := nil;
  fNodePen := nil;
  fNodeBrush :=  nil;
  fParent := nil;
  if aParent <> nil then
    SetParent(aParent)
  else
    begin
      fMinWidth := 50;
      fMaxWidth := 150;
      fMinHeight := 10;
      fMaxHeight := 30;
      fUpAnchor := new Anchor(50, AnchorUnit.Percent, 0, AnchorUnit.Percent);
      fDownAnchor := new Anchor(50, AnchorUnit.Percent, 100, AnchorUnit.Percent);
      fNodeAlign := HorizontalAlignment.Center;
      fShape := ShapeType.Rectangle;
      fRoundEdge := new Anchor(10, AnchorUnit.Pixel, 10, AnchorUnit.Pixel);
      fTextBorder := new ImgBorder(5, 5, 5, 5);
      fTextWrap := true;
      fTextClip := false;
      fTextTrim := -1;
      fTextXAlign := HorizontalAlignment.Center;
      FTextYAlign := HorizontalAlignment.Center;
      fLineSpacing := 1;
    end;
end;

method TreeNodeFormat.Assign(aNodeFormat: TreeNodeFormat);
begin
  fMinWidth := aNodeFormat.MinWidth;
  fMaxWidth := aNodeFormat.MaxWidth;
  fMinHeight := aNodeFormat.MinHeight;
  fMaxHeight := aNodeFormat.MaxHeight;
  fUpAnchor := aNodeFormat.UpAnchor;
  fDownAnchor := aNodeFormat.DownAnchor;
  fFont := aNodeFormat.Font;
  fFontBrush := BrushData.Copy(aNodeFormat.FontBrush);
  fLinePen := PenData.Copy(aNodeFormat.LinePen);
  fNodePen := PenData.Copy(aNodeFormat.NodePen);
  fNodeBrush := BrushData.Copy(aNodeFormat.NodeBrush);
  fNodeAlign := aNodeFormat.NodeAlign;
  fShape := aNodeFormat.Shape;
  fRoundEdge := aNodeFormat.RoundEdge;
  fTextBorder := new ImgBorder(aNodeFormat.TextBorder);
  fTextWrap := aNodeFormat.TextWrap;
  fTextClip := aNodeFormat.TextClip;
  fTextTrim := aNodeFormat.TextTrim;
  fTextXAlign := aNodeFormat.TextXAlign;
  fTextYAlign := aNodeFormat.TextYAlign;
  fLineSpacing := aNodeFormat.LineSpacing;
end;

method TreeNodeFormat.SetParent(aParent: TreeNodeFormat);
begin
  if fParent <> nil then
    fParent.DeleteChild(self);
  fParent := aParent;
  if fParent <> nil then
    begin
      Assign(fParent);
      fParent.AddChild(self);
    end;
end;

method TreeNodeFormat.AddChild(aNodeFormat: TreeNodeFormat);
begin
  if aNodeFormat <> nil then
    if not fChildren.Contains(aNodeFormat) then
      begin
        fChildren.Add(aNodeFormat);
        aNodeFormat.Parent := self;
      end;
end;

method TreeNodeFormat.AddChild(aClass: String): TreeNodeFormat;
require
  not String.IsNullOrEmpty(aClass);
begin
  result := new TreeNodeFormat(aClass);
  AddChild(result);
end;

method TreeNodeFormat.DeleteChild(aNodeFormat: TreeNodeFormat);
begin
  fChildren.Remove(aNodeFormat);
end;

method TreeNodeFormat.Find(aClass: String): TreeNodeFormat;
begin
  if FormatClass = aClass then
    exit self;
  result := nil;
  var i := 0;
  while (result = nil) and (i < ChildCount) do
    begin
      result := Child[i].Find(aClass);
      inc(i);
    end;
end;

method TreeNodeFormat.Find(aFormat: TreeNodeFormat): TreeNodeFormat;
begin
  if self = aFormat then
    exit self;
  result := nil;
  var i := 0;
  while (result = nil) and (i < ChildCount) do
    begin
      result := Child[i].Find(aFormat);
      inc(i);
    end;
end;

method TreeNodeFormat.ParentPath: List<TreeNodeFormat>;
begin
  result := new List<TreeNodeFormat>;
  result.Add(self);
  var lFmt := self.fParent;
  while lFmt <> nil do
    begin
      result.Insert(0, lFmt);
      lFmt := lFmt.fParent;
    end;
end;

method TreeNodeFormat.PropagateToChildren;
begin
  for i := 0 to ChildCount - 1 do
    begin
      Child[i].Assign(self);
      Child[i].PropagateToChildren;
    end;
end;


method TreeNodeFormat.GetChildCount: Integer;
begin
  result := fChildren.Count;
end;

method TreeNodeFormat.GetChild(aIdx: Integer): TreeNodeFormat;
begin
  result := fChildren[aIdx];
end;

method TreeNodeFormat.SetMinWidth(aMinWidth: Integer);
begin
  fMinWidth := aMinWidth;
  for i := 0 to ChildCount - 1 do
   Child[i].SetMinWidth(aMinWidth);
end;

method TreeNodeFormat.SetMaxWidth(aMaxWidth: Integer);
begin
  fMaxWidth := aMaxWidth;
  for i := 0 to ChildCount - 1 do
   Child[i].SetMaxWidth(aMaxWidth);
end;

method TreeNodeFormat.SetMinHeight(aMinHeight: Integer);
begin
  fMinHeight := aMinHeight;
  for i := 0 to ChildCount - 1 do
   Child[i].SetMinHeight(aMinHeight);
end;

method TreeNodeFormat.SetMaxHeight(aMaxHeight: Integer);
begin
  fMaxHeight := aMaxHeight;
  for i := 0 to ChildCount - 1 do
   Child[i].SetMaxHeight(aMaxHeight);
end;

method TreeNodeFormat.SetUpAnchor(aUpAnchor: Anchor);
begin
  fUpAnchor := new Anchor(aUpAnchor);
  for i := 0 to ChildCount - 1 do
    Child[i].SetUpAnchor(aUpAnchor);
end;

method TreeNodeFormat.SetDownAnchor(aDownAnchor: Anchor);
begin
  fDownAnchor := new Anchor(aDownAnchor);
  for i := 0 to ChildCount - 1 do
    Child[i].SetDownAnchor(aDownAnchor);
end;

method TreeNodeFormat.GetFont: Font;
begin
  result :=
    if fFont = nil then TreeNodeFormat.DefaultFormat:Font
    else fFont;
end;

method TreeNodeFormat.SetFont(aFont: Font);
begin
  fFont := aFont;
  for i := 0 to ChildCount - 1 do
    Child[i].SetFont(aFont);
end;

method TreeNodeFormat.GetFontBrush: BrushData;
begin
  result :=
    if fFontBrush = nil then TreeNodeFormat.DefaultFormat:FontBrush
    else fFontBrush;
end;

method TreeNodeFormat.SetFontBrush(aFontBrush: BrushData);
begin
  fFontBrush := aFontBrush;
  for i := 0 to ChildCount - 1 do
    Child[i].SetFontBrush(aFontBrush);
end;

method TreeNodeFormat.GetLinePen: PenData;
begin
  result :=
    if fLinePen = nil then TreeNodeFormat.DefaultFormat:LinePen
    else fLinePen;
end;

method TreeNodeFormat.SetLinePen(aLinePen: PenData);
begin
  fLinePen := aLinePen;
  for i := 0 to ChildCount - 1 do
    Child[i].SetLinePen(aLinePen);
end;

method TreeNodeFormat.GetNodePen: PenData;
begin
  result :=
    if fNodePen = nil then TreeNodeFormat.DefaultFormat:NodePen
    else fNodePen;
end;

method TreeNodeFormat.SetNodePen(aNodePen: PenData);
begin
  fNodePen := aNodePen;
  for i := 0 to ChildCount - 1 do
    Child[i].SetNodePen(aNodePen);
end;

method TreeNodeFormat.GetNodeBrush: BrushData;
begin
  result :=
    if fNodeBrush = nil then TreeNodeFormat.DefaultFormat:NodeBrush
    else fNodeBrush;
end;

method TreeNodeFormat.SetNodeBrush(aNodeBrush: BrushData);
begin
  fNodeBrush := aNodeBrush;
  for i := 0 to ChildCount - 1 do
    Child[i].SetNodeBrush(aNodeBrush);
end;

method TreeNodeFormat.SetNodeAlign(aNodeAlign: HorizontalAlignment);
begin
  fNodeAlign := aNodeAlign;
  for i := 0 to ChildCount - 1 do
    Child[i].SetNodeAlign(aNodeAlign);
end;

method TreeNodeFormat.SetShape(aShape: ShapeType);
begin
  fShape := aShape;
  for i := 0 to ChildCount - 1 do
    Child[i].SetShape(aShape);
end;

method TreeNodeFormat.SetRoundEdge(aRoundEdge: Anchor);
begin
  fRoundEdge := new Anchor(aRoundEdge);
  for i := 0 to ChildCount - 1 do
    Child[i].SetRoundEdge(aRoundEdge);
end;

method TreeNodeFormat.SetTextBorder(aTextBorder: ImgBorder);
begin
  fTextBorder := new ImgBorder(aTextBorder);
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextBorder(aTextBorder);
 end;

method TreeNodeFormat.SetTextBorderTop(aPix: Integer);
begin
  fTextBorder.Top := aPix;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextBorderTop(aPix);
end;

method TreeNodeFormat.SetTextBorderBottom(aPix: Integer);
begin
  fTextBorder.Bottom := aPix;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextBorderBottom(aPix);
end;

method TreeNodeFormat.SetTextBorderLeft(aPix: Integer);
begin
  fTextBorder.Left := aPix;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextBorderLeft(aPix);
end;

method TreeNodeFormat.SetTextBorderRight(aPix: Integer);
begin
  fTextBorder.Right := aPix;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextBorderRight(aPix);
end;

method TreeNodeFormat.SetTextWrap(aTextWrap: Boolean);
begin
  fTextWrap := aTextWrap;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextWrap(aTextWrap);
end;

method TreeNodeFormat.SetTextClip(aTextClip: Boolean);
begin
  fTextClip := aTextClip;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextClip(aTextClip);
end;

method TreeNodeFormat.SetTextTrim(aTextTrim: Integer);
begin
  fTextTrim := aTextTrim;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextTrim(aTextTrim);
end;

method TreeNodeFormat.SetTextXAlign(aTextXAlign: HorizontalAlignment);
begin
  fTextXAlign := aTextXAlign;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextXAlign(aTextXAlign);
end;

method TreeNodeFormat.SetTextYAlign(aTextYAlign: HorizontalAlignment);
begin
  fTextYAlign := aTextYAlign;
  for i := 0 to ChildCount - 1 do
    Child[i].SetTextYAlign(aTextYAlign);
end;

method TreeNodeFormat.SetLineSpacing(aLineSpacing: Float);
begin
  fLineSpacing := aLineSpacing;
  for i := 0 to ChildCount - 1 do
    Child[i].SetLineSpacing(aLineSpacing);
end;

{$ENDREGION}

{$REGION WinTreeDrawingAlgorithm}

constructor WinTreeDrawingAlgorithm(aGraphics: Graphics);
begin
  inherited constructor;
  fGraphics := aGraphics;
  fBorder := new ImgBorder(0, 0, 0, 0);
  fBackgroundColor := Color.White;
  fDrawSelected := true;
end;

method WinTreeDrawingAlgorithm.GetXMirror: Boolean;
begin
  result := inherited GetXMirror;
  if (Orientation = TreeOrientation.LeftRight) or (Orientation = TreeOrientation.RightLeft) then
    result := not result;
end;

method WinTreeDrawingAlgorithm.GetWinRoot: WinTreeDrawNode;
begin
  result := Root as WinTreeDrawNode;
end;

method WinTreeDrawingAlgorithm.GetBoxWidth: Integer;
begin
  result := fHS + fBorder.Left + fBorder.Right;
end;

method WinTreeDrawingAlgorithm.GetBoxHeight: Integer;
begin
  result := fVS + fBorder.Top + fBorder.Bottom;
end;

method WinTreeDrawingAlgorithm.Place;

  method ResetNodes(aNode: WinTreeDrawNode);
  begin
    if aNode = nil then
      exit;
    aNode.Clear;
    for i := 0 to aNode.Count - 1 do
      ResetNodes(aNode.WinItem[i]);
  end;

begin
  ResetNodes(WinRoot);
  inherited Place;
  fHS := XS;
  fVS := YS;
  if (Orientation = TreeOrientation.LeftRight) or (Orientation = TreeOrientation.RightLeft) then
    Utils.SwapInt(var fHS, var fVS);
end;

method WinTreeDrawingAlgorithm.Place(aGraphics: Graphics);
begin
  if aGraphics <> nil then
    fGraphics := aGraphics;
  Place;
end;

method WinTreeDrawingAlgorithm.DrawText(aNode: WinTreeDrawNode);
begin
  var lFont := aNode.Font;
  var lRect := aNode.NodeRect;
  lRect.X := lRect.X + aNode.TextBorder.Left;
  lRect.Y := lRect.Y + aNode.TextBorder.Top;
  lRect.Width := lRect.Width - aNode.TextBorder.Left - aNode.TextBorder.Right;
  lRect.Height := lRect.Height - aNode.TextBorder.Top - aNode.TextBorder.Bottom;
  var Y0 :=
    if aNode.TextYAlign = HorizontalAlignment.Left then lRect.Y
    else if aNode.TextYAlign = HorizontalAlignment.Right then lRect.Bottom - aNode.TextHeight
    else Math.Round(lRect.Y + (lRect.Height - aNode.TextHeight) / 2.0);
  using lBrush := aNode.FontBrush.NewBrush do
  using fmt := StringFormat.GenericTypographic do
    begin
      fmt.LineAlignment := StringAlignment.Center;
      for lLine := 0 to aNode.LineCount - 1 do
        begin
          var Y := Y0 + Math.Round(lLine * aNode.LineHeight * aNode.LineSpacing);
          var W := aNode.MeasureWidth(aNode.Line[lLine]);
          var X :=
            if aNode.TextXAlign = HorizontalAlignment.Left then lRect.X
            else if aNode.TextXAlign = HorizontalAlignment.Right then lRect.Right - W
            else Math.Round(lRect.X + (lRect.Width - W) / 2.0);
          var rf := new RectangleF(X, Y, W, aNode.LineHeight * aNode.LineSpacing);
          fGraphics.DrawString(aNode.Line[lLine], lFont, lBrush, rf, fmt);
       end;
     end;
end;

method WinTreeDrawingAlgorithm.DrawLine(aNode: WinTreeDrawNode);
begin
  if (aNode.Parent <> nil) and not aNode.Parent.IsVirtual then
    using lPen := aNode.LinePen.NewPen do
      begin
        var lParent := aNode.Parent as WinTreeDrawNode;
        var P := aNode.UpPoint;
        var PP := lParent.DownPoint;
        var YL := Math.Round(LevelY[lParent.Level + 1]);
        if aNode.Y <> YL then
          begin
            var lLevPt := PosPoint(aNode.X, YL);
            fGraphics.DrawLine(lPen, P, lLevPt);
            P := lLevPt;
          end;
        fGraphics.DrawLine(lPen, P, PP);
      end;
  for i := 0 to aNode.Count - 1 do
    DrawLine(aNode.WinItem[i]);
end;

method WinTreeDrawingAlgorithm.DrawSelection(aNode: WinTreeDrawNode);
begin
  var lPen := Pens.Blue;
  var lRect := aNode.NodeRect;
  lRect.Inflate(3, 3);
  fGraphics.DrawRectangle(lPen, lRect);
end;

method WinTreeDrawingAlgorithm.DrawShape(aGraphics: Graphics;  aRect: Rectangle; aShape: IShape);
begin
  using lBrush := aShape.NodeBrush.NewBrush do
  using lPen := aShape.NodePen.NewPen do
    case aShape.Shape of
      ShapeType.Ellipse:
        begin
          aGraphics.FillEllipse(lBrush, aRect);
          aGraphics.DrawEllipse(lPen, aRect);
        end;
      ShapeType.RoundRect:
        using lPath := GraphicsUtils.RoundedRect(aRect, aShape.RoundEdge) do
          begin
            aGraphics.FillPath(lBrush, lPath);
            aGraphics.DrawPath(lPen, lPath);
          end;
      else
        begin
          aGraphics.FillRectangle(lBrush, aRect);
          aGraphics.DrawRectangle(lPen, aRect);
        end;
  end;
end;

method WinTreeDrawingAlgorithm.ShapePicture(aShape: IShape; aRect: Rectangle): Bitmap;
begin
  var lHeight := aRect.Height;
  var lLineBottom := lHeight / 3;
  result := new Bitmap(aRect.Width, lHeight);
  using lGraphics := Graphics.FromImage(result) do
  using lPen := aShape.LinePen.NewPen do
    begin
      lGraphics.Clear(BackgroundColor);
      lGraphics.DrawLine(lPen, aRect.Width / 2, 0, aRect.Width / 2, lLineBottom);
      const lMargin = 5;
      var lRect := new Rectangle(lMargin, lLineBottom, aRect.Width - 2 * lMargin, 2 * lLineBottom - lMargin);
      DrawShape(lGraphics, lRect, aShape);
    end;
end;

method WinTreeDrawingAlgorithm.DrawNode(aNode: WinTreeDrawNode);
begin
  if not aNode.IsVirtual then
    begin
      DrawShape(fGraphics, aNode.NodeRect, aNode);
      DrawText(aNode);
      if fDrawSelected and aNode.IsSelected then
        DrawSelection(aNode);
    end;
  for i := 0 to aNode.Count - 1 do
    DrawNode(aNode.WinItem[i]);
end;

method WinTreeDrawingAlgorithm.Draw(aGraphics: Graphics := nil);
begin
  if Root = nil then
    exit;
  if aGraphics <> nil then
    fGraphics := aGraphics;
  fGraphics.Clear(fBackgroundColor);
  DrawLine(WinRoot);
  DrawNode(WinRoot);
end;

method WinTreeDrawingAlgorithm.PosPoint(X, Y: Integer): Point;
begin
  var PX := Border.Left;
  var PY := Border.Top;
  case Orientation of
    TreeOrientation.TopDown:
      begin
        PX := PX + X;
        PY := PY + Y;
      end;
    TreeOrientation.LeftRight:
      begin
        PX := PX + Y;
        PY := BoxHeight - Border.Bottom - X;
      end;
    TreeOrientation.BottomUp:
      begin
        PX := BoxWidth - Border.Right - X;
        PY := BoxHeight - Border.Bottom - Y;
      end;
    TreeOrientation.RightLeft:
      begin
        PX := BoxWidth - Border.Right - Y;
        PY := PY + X;
      end;
  end;
  result := new Point(PX, PY);
end;

method WinTreeDrawingAlgorithm.MakeBitmap(aPlace: Boolean := true): Bitmap;
begin
  if aPlace then
    using lBitmap := new Bitmap(10, 10) do
    using lGraphics := Graphics.FromImage(lBitmap) do
      begin
        Place(lGraphics);
        AssurePlacement;
      end;
   result := new Bitmap(BoxWidth, BoxHeight);
   using lGraphics := Graphics.FromImage(result) do
      Draw(lGraphics);
end;

method WinTreeDrawingAlgorithm.MakeMetafile(aPlace: Boolean := true): Metafile;
begin
  if aPlace then
    using lMetafile := RptImagePage.NewMetafile(new Rectangle(0, 0, 10, 10)) do
    using lGraphics := Graphics.FromImage(lMetafile) do
      begin
        Place(lGraphics);
        AssurePlacement;
      end;
   result := RptImagePage.NewMetafile(new Rectangle(0, 0, BoxWidth, BoxHeight));
   using lGraphics := Graphics.FromImage(result) do
      Draw(lGraphics);
end;

method WinTreeDrawingAlgorithm.MakeMetafileData: array of Byte;
begin
   using lStream := new MemoryStream do
     begin
       using lMetafile := RptImagePage.NewMetafile(new Rectangle(0, 0, BoxWidth, BoxHeight), lStream) do
       using lGraphics := Graphics.FromImage(lMetaFile) do
         Draw(lGraphics);
       result := lStream.ToArray;
     end;
end;

method WinTreeDrawingAlgorithm.HitTest(X, Y: Integer): TreeDrawNode;

  method CheckNode(aNode: WinTreeDrawNode): WinTreeDrawNode;
  begin
    if not aNode.IsVirtual then
      begin
        var lRect := aNode.NodeRect;
        if lRect.Contains(X, Y) then
          exit aNode;
      end;
    for i := 0 to aNode.Count - 1 do
      begin
        result := CheckNode(aNode.WinItem[i]);
        if result <> nil then
          exit;
      end;
  end;

begin
  result := CheckNode(WinRoot);
end;

{$ENDREGION}

{$REGION WinTreeDrawNode}

constructor WinTreeDrawNode(aText: String);
begin
  inherited constructor;
  fText := if aText = nil then '' else aText;
  fLines := nil;
  fNodeFormat := nil;
end;

method WinTreeDrawNode.Clear;
begin
  fLines := nil;
  fTextWidth := -1;
  fTextHeight := -1;
  fLineHeight := -1;
end;

method WinTreeDrawNode.NodeRect(out PX0, PY0, PX1, PY1: Integer);
begin
  var PX, PY: Integer;
  NodePoint(out PX, out PY);
  PX0 := PX - Math.Round(LeftWidth);
  PX1 := PX + Math.Round(RightWidth);
  PY0 := PY - Math.Round(TopHeight);
  PY1 := PY + Math.Round(BottomHeight);
end;

method WinTreeDrawNode.NodeRect: Rectangle;
begin
  var PX0, PY0, PX1, PY1: Integer;
  NodeRect(out PX0, out PY0, out PX1, out PY1);
  result := new Rectangle(PX0, PY0, PX1 - PX0 + 1, PY1 - PY0 + 1);
end;

method WinTreeDrawNode.NodePoint(out PX, PY: Integer);
begin
  var lPoint := NodePoint;
  PX := lPoint.X;
  PY := lPoint.Y;
end;

method WinTreeDrawNode.NodePoint: Point;
begin
  result := GetWinDrawingAlgorithm.PosPoint(X, Y);
end;

method WinTreeDrawNode.AnchorPoint(A: Anchor; out AX, AY: Integer);
begin
  var R := NodeRect;
  var lBottomRightX := R.X + R.Width - 1;
  var lBottomRightY := R.Y + R.Height - 1;
  case TreeDrawing.Orientation of
  TreeOrientation.TopDown:
    begin
      AX := Anchor.AnchorPos(R.X, lBottomRightX, A.X, A.UnitX, false);
      AY := Anchor.AnchorPos(R.Y, lBottomRightY, A.Y, A.UnitY, false);
    end;
  TreeOrientation.LeftRight:
    begin
      AX := Anchor.AnchorPos(R.X, lBottomRightX, A.Y, A.UnitY, false);
      AY := Anchor.AnchorPos(R.Y, lBottomRightY, A.X, A.UnitX, true);
    end;
  TreeOrientation.BottomUp:
    begin
      AX := Anchor.AnchorPos(R.X, lBottomRightX, A.X, A.UnitX, true);
      AY := Anchor.AnchorPos(R.Y, lBottomRightY, A.Y, A.UnitY, true);
    end;
  TreeOrientation.RightLeft:
    begin
      AX := Anchor.AnchorPos(R.X, lBottomRightX, A.Y, A.UnitY, true);
      AY := Anchor.AnchorPos(R.Y, lBottomRightY, A.X, A.UnitX, false);
    end;
  end;
end;

method WinTreeDrawNode.AnchorPoint(A: Anchor): Point;
begin
  var AX, AY: Integer;
  AnchorPoint(A, out AX, out AY);
  result := new Point(AX, AY);
end;

method WinTreeDrawNode.UpPoint(out AX, AY: Integer);
begin
  AnchorPoint(UpAnchor, out AX, out AY);
end;

method WinTreeDrawNode.UpPoint: Point;
begin
  result := AnchorPoint(UpAnchor);
end;

method WinTreeDrawNode.DownPoint(out AX, AY: Integer);
begin
  AnchorPoint(DownAnchor, out AX, out AY);
end;

method WinTreeDrawNode.DownPoint: Point;
begin
  result := AnchorPoint(DownAnchor);
end;

method WinTreeDrawNode.MeasureWidth(aText: String): Integer;
begin
  var lGraphics := GetWinDrawingAlgorithm:Graphics;
  if String.IsNullOrEmpty(aText) or (lGraphics = nil) then
    result := 0
  else
    using fmt := StringFormat.GenericTypographic do
      begin
        var lMeasure := lGraphics.MeasureString(aText, Font, new SizeF(high(Integer), high(Integer)), fmt);
        result := Utils.RoundUp(lMeasure.Width);
      end;
end;

method WinTreeDrawNode.MeasureHeight(aText: String): Integer;
begin
  var lGraphics := GetWinDrawingAlgorithm:Graphics;
  if String.IsNullOrEmpty(aText) or (lGraphics = nil) then
    result := 0
  else
    using fmt := StringFormat.GenericTypographic do
      begin
        var lMeasure := lGraphics.MeasureString(aText, Font, new SizeF(high(Integer), high(Integer)), fmt);
        result := Utils.RoundUp(lMeasure.Height);
      end;
end;

method WinTreeDrawNode.GetWinDrawingAlgorithm: WinTreeDrawingAlgorithm;
begin
  result := TreeDrawing as WinTreeDrawingAlgorithm;
end;

method WinTreeDrawNode.GetNodeClass: String;
begin
  result :=
    if fNodeFormat = nil then 'default'
    else fNodeFormat.FormatClass;
end;

method WinTreeDrawNode.SetNodeClass(aClass: String);
begin
  if String.IsNullOrEmpty(aClass) then
    begin
      fNodeFormat := nil;
      exit;
    end;
  var lOld := fNodeFormat;
  var lFmt := TreeNodeFormat.DefaultFormat.Find(aClass);
  fNodeFormat :=
    if lFmt = nil then new TreeNodeFormat(aClass, lOld)
    else lFmt;
end;

method WinTreeDrawNode.GetNodeFormat: TreeNodeFormat;
begin
  result :=
    if fNodeFormat = nil then TreeNodeFormat.DefaultFormat
    else fNodeFormat;
end;

method WinTreeDrawNode.SetNodeFormat(aFormat: TreeNodeFormat);
begin
  fNodeFormat := aFormat;
end;

method WinTreeDrawNode.GetText: String;
begin
  result :=
    if fText = nil then ''
    else if (TextTrim >= 0) and (fText.Length > TextTrim) then fText.Substring(0, TextTrim)
    else fText;
end;

method WinTreeDrawNode.GetIsSelected: Boolean;
begin
  result := false;
end;

method WinTreeDrawNode.GetWidth: Float;
begin
  TextFormat;
  result := TextWidth + TextBorder.Left + TextBorder.Right;
  if result < MinWidth then
    result := MinWidth
  else if result > MaxWidth then
    result := MaxWidth;
end;

method WinTreeDrawNode.GetHeight: Float;
begin
  TextFormat;
  result := TextHeight + TextBorder.Top + TextBorder.Bottom;
  if result < MinHeight then
    result := MinHeight
  else if result > MaxHeight then
    result := MaxHeight;
end;

method WinTreeDrawNode.GetLeftWidth: Float;
begin
 result :=
   if (TreeDrawing.Orientation = TreeOrientation.TopDown) or (TreeDrawing.Orientation = TreeOrientation.BottomUp) then
      Width / 2
   else if NodeAlign = HorizontalAlignment.Left then 0
   else if NodeAlign = HorizontalAlignment.Right then Width
   else Width / 2;
end;

method WinTreeDrawNode.GetRightWidth: Float;
begin
  result := Width - LeftWidth;
end;

method WinTreeDrawNode.GetTopHeight: Float;
begin
  result :=
    if (TreeDrawing.Orientation = TreeOrientation.LeftRight) or (TreeDrawing.Orientation = TreeOrientation.RightLeft) then
      Height / 2
    else if NodeAlign = HorizontalAlignment.Left then 0
    else if NodeAlign = HorizontalAlignment.Right then Height
    else Height / 2;
end;

method WinTreeDrawNode.GetBottomHeight: Float;
begin
  result := Height - TopHeight;
end;

method WinTreeDrawNode.GetMinWidth: Float;
begin
  result := NodeFormat.MinWidth;
end;

method WinTreeDrawNode.GetMaxWidth: Float;
begin
  result := NodeFormat.MaxWidth;
end;

method WinTreeDrawNode.GetMinHeight: Float;
begin
  result := NodeFormat.MinHeight;
end;

method WinTreeDrawNode.GetMaxHeight: Float;
begin
  result := NodeFormat.MaxHeight;
end;

method WinTreeDrawNode.GetUpAnchor: Anchor;
begin
  result := NodeFormat.UpAnchor;
end;

method WinTreeDrawNode.GetDownAnchor: Anchor;
begin
  result := NodeFormat.DownAnchor;
end;

method WinTreeDrawNode.GetFont: Font;
begin
  result := NodeFormat.Font;
end;

method WinTreeDrawNode.GetFontBrush: BrushData;
begin
  result := NodeFormat.FontBrush;
end;

method WinTreeDrawNode.GetLinePen: PenData;
begin
  result := NodeFormat.LinePen;
end;

method WinTreeDrawNode.GetNodePen: PenData;
begin
  result := NodeFormat.NodePen;
end;

method WinTreeDrawNode.GetNodeBrush: BrushData;
begin
  result := NodeFormat.NodeBrush;
end;

method WinTreeDrawNode.GetNodeAlign: HorizontalAlignment;
begin
  result := NodeFormat.NodeAlign;
end;

method WinTreeDrawNode.GetShape: ShapeType;
begin
  result := NodeFormat.Shape;
end;

method WinTreeDrawNode.GetRoundEdge: Anchor;
begin
  result := NodeFormat.RoundEdge;
end;

method WinTreeDrawNode.GetTextBorder: ImgBorder;
begin
  result := NodeFormat.TextBorder;
end;

method WinTreeDrawNode.GetTextWrap: Boolean;
begin
  result := NodeFormat.TextWrap;
end;

method WinTreeDrawNode.GetTextClip: Boolean;
begin
  result := NodeFormat.TextClip;
end;

method WinTreeDrawNode.GetTextTrim: Integer;
begin
  result := NodeFormat.TextTrim;
end;

method WinTreeDrawNode.GetTextXAlign: HorizontalAlignment;
begin
  result := NodeFormat.TextXAlign;
end;

method WinTreeDrawNode.GetTextYAlign: HorizontalAlignment;
begin
  result := NodeFormat.TextYAlign;
end;

method WinTreeDrawNode.GetLineSpacing: Float;
begin
  result := NodeFormat.LineSpacing;
end;

method WinTreeDrawNode.GetLineCount: Integer;
begin
  TextFormat;
  result := fLines.Count;
end;

method WinTreeDrawNode.GetLine(aIdx: Integer): String;
begin
  TextFormat;
  result := fLines[aIdx];
end;

method WinTreeDrawNode.TextFormat;
begin
  if fLines <> nil then
    exit;
  fLines := new List<String>;
  if not TextWrap then
    begin
      fLines.Add(Text);
      fTextWidth := MeasureWidth(Text);
    end
  else
    begin
      fTextWidth := 0;
      var lTxt := Text;
      while lTxt <> '' do
        begin
          var w := MeasureWidth(lTxt);
          var b := -1;
          var t := -1;
          if w > MaxWidth then
            for p := 1 to lTxt.Length - 1 do
              begin
                if lTxt[p] = ' ' then
                  b := p;
                w := MeasureWidth(lTxt.Substring(0, p));
                if w <= MaxWidth then
                  t := p
                else
                  break;
              end;
          if b > 1 then
            begin
              var lLine := lTxt.Substring(0, b);
              fLines.Add(lLine);
              lTxt := lTxt.Substring(b + 1);
              w := MeasureWidth(lLine);
            end
          else if t > 1 then
            begin
              var lLine := lTxt.Substring(0, t);
              FLines.Add(lLine);
              lTxt := lTxt.Substring(t);
              w := MeasureWidth(lLine);
            end
          else
            begin
              fLines.Add(lTxt);
              lTxt := '';
            end;
          if w > fTextWidth then
            fTextWidth := w;
        end;
    end;
  fLineHeight := MeasureHeight('Tj');
  fTextHeight := Math.Round((LineCount - 1) * fLineHeight * LineSpacing + fLineHeight + 0.5);
end;

{$ENDREGION}

end.
