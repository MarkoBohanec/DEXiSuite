// WinFormatter.pas is part of
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
// WinFormatter.pas implements 'RptImageFormatter' as an extension of DEXiLibrary's
// 'RptFormatter' able to format DEXi reports for a rich graphic-based display with fine
// pixel and font granulation.
// ----------

namespace DexiUtils;

interface

uses
  System.Drawing,
  System.Drawing.Imaging,
  System.Drawing.Drawing2D,
  System.Drawing.Printing,
  System.Windows.Forms,
  RemObjects.Elements.RTL;

type
  RptImagePage = public class
  private
    fBytes: array of Byte := nil;
    fMetafile: Boolean;
  public
    class method NewMetafile(aRect: Rectangle; aStream: MemoryStream := nil): Metafile;
    method HasImage: Boolean;
    method HasMetafile: Boolean;
    method HasBitmap: Boolean;
    method SetImage(aImage: Image);
    method SetImage(aBytes: array of Byte; aMetafile: Boolean);
    method GetImage: Image;
    method GetImageAsMetafile: Metafile;
    method GetImageAsBitmap: Bitmap;
    method GetBytes: array of Byte;
  end;

type
  RptFontMaker = public method (aTag: Integer; aBaseFont: Font): Font;
  RptBrushMaker = public method (aTag: Integer): Brush;

type
  RptFontBundle = class (IDisposable)
  private
    fDisposed := false;
    fFontDictionary: Dictionary<Integer, Font>;
    fFontMaker: RptFontMaker;
  protected
    method GetFont(aTag: Integer): Font;
  public
    constructor (aBaseFont: not nullable Font; aFontMaker: RptFontMaker := nil);
    property FontMaker: RptFontMaker read fFontMaker write fFontMaker;
    property BaseFont: Font read fFontDictionary[0];
    property Font[aTag: Integer]: Font read GetFont;
    method Dispose; virtual;
    method Dispose(aDisposing: Boolean); virtual;
  end;

type WinImage = public class (IRptImage)
  private
    fImage: Image;
  protected
    method GetImageType: String;
    method GetImageString: String;
  public
    constructor (aImage: Image);
    method AutoScaleToWidth(aWidth: FmtLength): Float;
    property Image: Image read fImage write fImage;
    property Width: FmtLength read fImage.Width;
    property Height: FmtLength read fImage.Height;
    property ImageType: String read GetImageType;
    property ImageString: String read GetImageString;
  end;

type
  RptImageFormatter = public class (RptFormatter)
  private
    fUseMetafile := true;
    fPageDimensions: RptDimensions;
    fBorders: RptBorders;
    fDeviceDpi: FmtLengths;
    fDefaultFont: Font;
    fFontMaker: RptFontMaker;
    fBrushMaker: RptBrushMaker;
    fFontStack: Stack<RptFontBundle>;
    fLineHeightStack: Stack<FmtLength>;
    fLiners: Stack<FmtRectangle>;
    fPrevTree: FmtBox;
    fImagePages: List<RptImagePage>;

    // Context
    ffCurrentGraphics: Graphics;
    ffCurrentImage: Image;
    ffCurrentBitmap: Bitmap;
    ffCurrentMetafile: Metafile;
    ffCurrentImageStream: MemoryStream;

  protected
    class const NormalTextFormatFlags: TextFormatFlags =
      TextFormatFlags.NoPrefix or TextFormatFlags.NoPadding or TextFormatFlags.PreserveGraphicsTranslateTransform;
    class method GetDpi: FmtLengths;
    class method WinRect(aRect: FmtRectangle): Rectangle;
    class method NumberedFileName(aFileName: String): String;

    method DimensionToLength(aDimension: RptDimension; aDir: RptDirection): FmtLength; override;

    // Context
    method ClearContext; override;
    method UpdateContext; override;
    method BeginFormatSettings(aSettings: RptFormatSettings); virtual;
    method EndFormatSettings; virtual;
    method BeginBox(aBox: FmtBox); override;
    method EndBox(aBox: FmtBox); override;

    // Measure
    method InitLineHeight(aLine: RptLine): FmtLength;
    method MeasureString(aText: String; aFont: Font): FmtLengths; virtual;
    method MeasureText(aText: String): FmtLengths; override;
    method MeasureImage(aRptImage: RptImage): FmtLengths;
    method MeasureTree(aBox: FmtBox); virtual;
    method MeasureComposite(aStr: CompositeString): FmtLengths;
    method MeasureBox(aBox: FmtBox); override;

    // Format
    method PushFormat(aBaseFont: Font); virtual;
    method PopFormat; virtual;
    method PrepareImage;
    method CaptureImagePage: RptImagePage;
    method BeginFormat; override;
    method EndFormat; override;

    // Paginate Boxes
    method GetFreeWidth: FmtLength; override;
    method GetFreeHeight: FmtLength; override;
    method BeginPaginate; override;
    method EndPaginate; override;

    // Render
    method RenderTree(aBox: FmtBox);
    method RenderText(aText: String; aRect: FmtRectangle);
    method RenderText(aText: String; aRect: FmtRectangle; aFont: Font; aBrush: Brush);
    method RenderImage(aImage: WinImage; aRect: FmtRectangle);
    method RenderLines(aBegin, aEnd: FmtRectangle; aLines: Integer);
    method RenderComposite(aBox: FmtBox);
    method RenderRectangles(aBox: FmtBox);
    method RenderBox(aBox: FmtBox); virtual;

    // Accessors
    method GetCurrentLineHeight: FmtLength;
    method SetCurrentLineHeight(aLength: FmtLength);
    method CurrentFont: Font;
    method CurrentFont(aTag: Integer): Font;
    property CurrentLineHeight: FmtLength read GetCurrentLineHeight write SetCurrentLineHeight;

  public
    constructor (
      aReport: not nullable RptReport;
      aPageOffset: FmtLengths;
      aPageLengths: FmtLengths;
      aDeviceDpi: FmtLengths := nil;
      aFont: Font := nil);
    constructor (
      aReport: not nullable RptReport;
      aPageDimensions: RptDimensions;
      aBorders: RptBorders := nil;
      aDeviceDpi: FmtLengths := nil;
      aFont: Font := nil);
    method Render; virtual;
    method HasImage(aIdx: Integer): Boolean;
    method GetImage(aIdx: Integer): Image;
    method GetImageAsBitmap(aIdx: Integer): Bitmap;
    method GetImageAsMetafile(aIdx: Integer): Metafile;
    method SaveToHtml(aFileName: String; aHtmlParams: RptHtmlParameters);
    method SaveToText(aFileName: String; aPageDimensions: FmtLengths);
    method SaveToMetafiles(aFileName: String);
    method SaveToBitmaps(aFileName: String);
    method Print(aDocument: RptPrintDocument; aStartPage: Integer; aTwoPages: Boolean := false);
    property UseMetafile: Boolean read fUseMetafile write fUseMetafile;
    property LinerWidth: FmtLength := 1;
    property LinerGap: FmtLength := 1;
    property DefaultFont: Font read fDefaultFont write fDefaultFont;
    property DrawInnerRectangles: nullable Color := nil; // Color.Red;
    property DrawOuterRectangles: nullable Color := nil; // Color.Green;
    property FontMaker: RptFontMaker read fFontMaker write fFontMaker;
    property BrushMaker: RptBrushMaker read fBrushMaker write fBrushMaker;
    property ImagePages: ImmutableList<RptImagePage> read fImagePages;
    property ImagePage[aIdx: Integer]: RptImagePage read if aIdx < ImagePageCount then fImagePages[aIdx] else nil; default;
    property ImagePageCount: Integer read if fImagePages = nil then 0 else fImagePages.Count;
  end;

type
  RptPrintDocument = public class (PrintDocument)
  private
    fFormatter: not nullable RptImageFormatter;
    fPrintPage: Integer;
    fFirst: Integer;
    fLast: Integer;
  public
    constructor (aFormatter: not nullable RptImageFormatter);
    method Clear;
    property Formatter: RptImageFormatter read fFormatter;
    property First: Integer read fFirst write fFirst;
    property Last: Integer read fLast write fLast;
    method OnBeginPrint(e: PrintEventArgs); override;
    method OnPrintPage(e: PrintPageEventArgs); override;
  end;

implementation

{$REGION RptImagePage}

class method RptImagePage.NewMetafile(aRect: Rectangle; aStream: MemoryStream := nil): Metafile;
begin
  var lStream :=
    if aStream = nil then new MemoryStream
    else aStream;
  using lGraphics := Graphics.FromHwndInternal(IntPtr.Zero) do
    begin
      var lContextHandle := lGraphics.GetHdc();
      var lMfRectangleF := new RectangleF(0, 0, aRect.Width, aRect.Height);
      result := new Metafile(lStream, lContextHandle, lMfRectangleF, MetafileFrameUnit.Pixel, EmfType.EmfPlusOnly);
      lGraphics.ReleaseHdc;
      var metafileHeader := result.GetMetafileHeader;
      lGraphics.ScaleTransform(
        metafileHeader.DpiX / lGraphics.DpiX,
        metafileHeader.DpiY / lGraphics.DpiY);
      lGraphics.PageUnit := GraphicsUnit.Pixel;
      lGraphics.SetClip(lMfRectangleF);
    end;
  if aStream = nil then
    lStream.Dispose;
end;

method RptImagePage.HasImage: Boolean;
begin
  result := fBytes <> nil;
end;

method RptImagePage.HasMetafile: Boolean;
begin
  result := HasImage and fMetafile;
end;

method RptImagePage.HasBitmap: Boolean;
begin
  result := HasImage and not fMetafile;
end;

method RptImagePage.SetImage(aImage: Image);
begin
  using lStream := new MemoryStream do
    if aImage is Bitmap then
      begin
        aImage.Save(lStream, ImageFormat.Png);
        fBytes := lStream.ToArray;
        fMetafile := false;
      end
    else
      begin
        var lMfRectangle := new Rectangle(0, 0, aImage.Width, aImage.Height);
        using lMetafile := NewMetafile(lMfRectangle, lStream) do
        using lGraphics := Graphics.FromImage(lMetafile) do
          lGraphics.DrawImage(aImage, 0, 0);
        fBytes := lStream.ToArray;
        fMetafile := true;
      end;
end;

method RptImagePage.SetImage(aBytes: array of Byte; aMetafile: Boolean);
begin
  fBytes := aBytes;
  fMetafile := aMetafile;
end;

method RptImagePage.GetImage: Image;
begin
  if not HasImage then
    exit nil;
  using lStream := new MemoryStream(fBytes) do
    if fMetafile then
      result := new Metafile(lStream)
    else
      result := new Bitmap(lStream);
end;

method RptImagePage.GetImageAsMetafile: Metafile;
begin
  if not HasImage then
    exit nil;
  if fMetafile then
    result := Metafile(GetImage)
  else
    begin
      using lStream  := new MemoryStream(fBytes) do
      using lBitmap := new Bitmap(lStream) do
        begin
          var lMetafile := NewMetafile(new Rectangle(0, 0, lBitmap.Width, lBitmap.Height));
          using lGraphic := Graphics.FromImage(lMetafile) do
            lGraphic.DrawImage(lBitmap, 0, 0);
          result := lMetafile;
        end;
    end;
end;

method RptImagePage.GetImageAsBitmap: Bitmap;
begin
  if not HasImage then
    exit nil;
  if fMetafile then
    begin
      using lMetafile := Metafile(GetImage) do
        begin
          var lBitmap := new Bitmap(lMetafile.Width, lMetafile.Height);
          using lGraphic := Graphics.FromImage(lBitmap) do
            lGraphic.DrawImage(lMetafile, 0, 0);
          result := lBitmap;
        end;
    end
  else
    result := Bitmap(GetImage);
end;

method RptImagePage.GetBytes: array of Byte;
begin
  result := fBytes;
end;

{$ENDREGION}

{$REGION RptFontBundle}

constructor RptFontBundle(aBaseFont: not nullable Font; aFontMaker: RptFontMaker := nil);
begin
  inherited constructor;
  fFontDictionary := new Dictionary<Integer, Font>;
  fFontDictionary[0] := aBaseFont;
  fFontMaker := aFontMaker;
end;

method RptFontBundle.GetFont(aTag: Integer): Font;
begin
  if fFontDictionary.ContainsKey(aTag) then
    result := fFontDictionary[aTag]
  else if assigned(fFontMaker) then
    begin
      result := fFontMaker(aTag, BaseFont);
      fFontDictionary[aTag] := result;
    end
  else
    result := BaseFont;
end;

method RptFontBundle.Dispose;
begin
  Dispose(true);
  GC.SuppressFinalize(self);
end;

method RptFontBundle.Dispose(aDisposing: Boolean);
begin
  if fDisposed then
    exit;
  if aDisposing then
    begin
      for each lFont in fFontDictionary.Values do
        lFont.Dispose;
      fFontDictionary := nil;
    end;
  fDisposed := true;
end;

{$ENDREGION}

{$REGION WinImage}

constructor WinImage(aImage: Image);
begin
  inherited constructor;
  fImage := aImage;
end;

method WinImage.GetImageType: String;
begin
  var lFormat := fImage.RawFormat;
  result :=
    if (lFormat.Equals(ImageFormat.Png)) then 'png'
    else if (lFormat.Equals(ImageFormat.Gif)) then 'gif'
    else if (lFormat.Equals(ImageFormat.Bmp)) then 'bmp'
    else if (lFormat.Equals(ImageFormat.Emf)) then 'emf'
    else if (lFormat.Equals(ImageFormat.Wmf)) then 'wmf'
    else if (lFormat.Equals(ImageFormat.Jpeg)) then 'jpeg'
    else if (lFormat.Equals(ImageFormat.Icon)) then 'icon'
    else if (lFormat.Equals(ImageFormat.Tiff)) then 'tiff'
    else 'unknown';
end;

method WinImage.GetImageString: String;
begin
  result := nil;
  using lStream := new MemoryStream do
    begin
      try
        fImage.Save(lStream, ImageFormat.Png);
        var lData := lStream.ToArray;
        result := Convert.ToBase64String(lData);
      except
        result := nil;
      end;
    end;
end;

method WinImage.AutoScaleToWidth(aWidth: FmtLength): Float;
begin
  result := Float(aWidth) / Width;
end;

{$ENDREGION}

{$REGION RptFormatter}

constructor RptImageFormatter(
  aReport: not nullable RptReport;
  aPageOffset: FmtLengths;
  aPageLengths: FmtLengths;
  aDeviceDpi: FmtLengths := nil;
  aFont: Font := nil);
begin
  fDefaultFont :=
    if aFont = nil then SystemFonts.DefaultFont
    else aFont;
  fDeviceDpi :=
    if aDeviceDpi = nil then RptImageFormatter.GetDpi
    else aDeviceDpi;
  fBorders := new RptBorders(
    new RptDimension(aPageOffset.Horizontal, RptUnit.Pixel),
    RptDimension.Zero,
    new RptDimension(aPageOffset.Vertical, RptUnit.Pixel),
    RptDimension.Zero);
  fPageDimensions := new RptDimensions(
                       new RptDimension(aPageLengths.Horizontal, RptUnit.Pixel),
                       new RptDimension(aPageLengths.Vertical, RptUnit.Pixel));
  inherited constructor(aReport, aPageOffset, aPageLengths);
end;

constructor RptImageFormatter(
  aReport: not nullable RptReport;
  aPageDimensions: RptDimensions;
  aBorders: RptBorders := nil;
  aDeviceDpi: FmtLengths := nil;
  aFont: Font := nil);
begin
  fDefaultFont :=
    if aFont = nil then SystemFonts.DefaultFont
    else aFont;
  fDeviceDpi :=
    if aDeviceDpi = nil then RptImageFormatter.GetDpi
    else aDeviceDpi;
  fBorders :=
    if aBorders = nil then new RptBorders
    else aBorders;
  fPageDimensions := aPageDimensions;
  var aPageLengths := DimensionsToLengths(fPageDimensions);
  var aPageOffset := new FmtLengths(
    DimensionToLength(fBorders.Left, RptDirection.Horizontal),
    DimensionToLength(fBorders.Top, RptDirection.Vertical));
  inherited constructor(aReport, aPageOffset, aPageLengths);
end;

class method RptImageFormatter.GetDpi: FmtLengths;
begin
  using lOffscreenGraphics := Graphics.FromHwndInternal(IntPtr.Zero) do
    result := new FmtLengths(lOffscreenGraphics.DpiX, lOffscreenGraphics.DpiY);
end;

class method RptImageFormatter.WinRect(aRect: FmtRectangle): Rectangle;
begin
  result :=
   if aRect = nil then nil
    else new Rectangle(aRect.Left, aRect.Top, aRect.Width, aRect.Height);
end;

class method RptImageFormatter.NumberedFileName(aFileName: String): String;
begin
  aFileName := Path.GetFullPath(aFileName);
  var lPath := Path.GetPathWithoutExtension(aFileName);
  var lExt := Path.GetExtension(aFileName);
  result := lPath + '*' + lExt;
end;

method RptImageFormatter.GetCurrentLineHeight: FmtLength;
begin
  result := if fLineHeightStack.Count = 0 then 0 else Utils.RoundUp(fLineHeightStack.Peek);
end;

method RptImageFormatter.SetCurrentLineHeight(aLength: FmtLength);
begin
  if fLineHeightStack.Count > 0 then
    fLineHeightStack.Pop;
  fLineHeightStack.Push(aLength);
end;

method RptImageFormatter.CurrentFont: Font;
begin
  result :=
    if (fFontStack = nil) or (fFontStack.Count = 0) then fDefaultFont
    else fFontStack.Peek.BaseFont;
end;

method RptImageFormatter.CurrentFont(aTag: Integer): Font;
begin
  result :=
    if (fFontStack = nil) or (fFontStack.Count = 0) then fDefaultFont
    else fFontStack.Peek.Font[aTag];
end;

method RptImageFormatter.DimensionToLength(aDimension: RptDimension; aDir: RptDirection): FmtLength;
begin
  var lDpi := fDeviceDpi[aDir];
  if (aDimension = nil) or (aDimension.Unit = RptUnit.Measure) then
    result := -1
  else
    begin
      var lDistance :=
        case aDimension.Unit of
          RptUnit.Native:  aDimension.Distance;
          RptUnit.Line:    CurrentLineHeight * aDimension.Distance;
          RptUnit.MM:      lDpi / 25.4 * aDimension.Distance;
          RptUnit.Inch:    lDpi * aDimension.Distance;
          RptUnit.Pt:      lDpi / 72.27 * aDimension.Distance;
          RptUnit.NumChar: MeasureText('9')[aDir];
          RptUnit.Em:      MeasureText('M')[aDir];
          else             aDimension.Distance;
        end;
      result := Math.Max(0, Utils.RoundUp(lDistance));
    end;
end;

method RptImageFormatter.ClearContext;
begin
  inherited ClearContext;
  fLiners := new Stack<FmtRectangle>;
  fFontStack := new Stack<RptFontBundle>;
  fLineHeightStack := new Stack<FmtLength>;
  fPrevTree := nil;
end;

method RptImageFormatter.UpdateContext;
begin
  inherited UpdateContext;
end;

method RptImageFormatter.BeginFormatSettings(aSettings: RptFormatSettings);
begin
  var lFontStyle := FontStyle.Regular;
  if aSettings.Bold then lFontStyle := lFontStyle or FontStyle.Bold;
  if aSettings.Italic then lFontStyle := lFontStyle or FontStyle.Italic;
  if aSettings.Underlined then lFontStyle := lFontStyle or FontStyle.Underline;
  var lSize :=  aSettings.SizeFactor * fDefaultFont.Size;
  var lFontFamily :=
    if String.IsNullOrEmpty(aSettings.FontName) then fDefaultFont.FontFamily
    else new FontFamily(aSettings.FontName);
  var lFont := new Font(lFontFamily, lSize, lFontStyle);
  PushFormat(lFont);
end;

method RptImageFormatter.EndFormatSettings;
begin
  PopFormat;
end;

method RptImageFormatter.BeginBox(aBox: FmtBox);
begin
  if aBox:Element is RptLine then
    begin
      fLineHeightStack.Push(aBox.Height);
      MeasureBox(aBox);
    end;
  if aBox:Element is RptBeginFormat then
    BeginFormatSettings(RptBeginFormat(aBox.Element).Format);
  if aBox:Element is RptFormattedText then
    BeginFormatSettings(RptFormattedText(aBox.Element).Format);
  inherited BeginBox(aBox);
  if aBox:Element is RptBeginLiner then
    fLiners.Push(aBox.Rectangle);
  if aBox:Element is RptTree then
    PushFormat(new Font(FontFamily.GenericMonospace, CurrentFont.Size));
end;

method RptImageFormatter.EndBox(aBox: FmtBox);
begin
  if aBox:Element is RptLine then
    fLineHeightStack.Pop;
  if aBox:Element is RptEndFormat then
    EndFormatSettings;
  if aBox:Element is RptFormattedText then
    EndFormatSettings;
  inherited EndBox(aBox);
  if aBox:Element is RptEndLiner then
    if fLiners.Count > 0 then
      fLiners.Pop;
  if aBox:Element is RptTree then
    PopFormat;
end;

method RptImageFormatter.MeasureString(aText: String; aFont: Font): FmtLengths;
begin
  aText := aText.Replace(' ', '-');
  using fmt := StringFormat.GenericTypographic do
    begin
      var lMeasure := ffCurrentGraphics.MeasureString(aText, aFont, new SizeF(high(Integer), high(Integer)), fmt);
      result := new FmtLengths(Utils.RoundUp(lMeasure.Width), Utils.RoundUp(lMeasure.Height));
    end;
end;

method RptImageFormatter.MeasureText(aText: String): FmtLengths;
begin
  if String.IsNullOrEmpty(aText) or (ffCurrentGraphics = nil) or (fFontStack.Count = 0) then
    result := new FmtLengths(0, 0)
  else
    result := MeasureString(aText, CurrentFont);
end;

method RptImageFormatter.MeasureImage(aRptImage: RptImage): FmtLengths;

  method ScaledWidth(aWidth: Integer): Integer;
  begin
    result := Integer(aWidth * aRptImage.Scaled);
  end;

begin
  var lImage := aRptImage.Image as WinImage;
  if aRptImage.AutoScale then
    aRptImage.Scaled := lImage.AutoScaleToWidth(GetFreeWidth);
  result := new FmtLengths(ScaledWidth(lImage.Width), ScaledWidth(lImage.Height));
end;

method RptImageFormatter.InitLineHeight(aLine: RptLine): FmtLength;
begin
  var lTextLengths := MeasureText('Wg');
  result := Utils.RoundUp(aLine.Height * lTextLengths.Vertical);
end;

method RptImageFormatter.MeasureTree(aBox: FmtBox);
const RefChar = 'X';
begin
  var lTree := RptTree(aBox.Element);
  if Report.TreePattern = RptTreePattern.Lines then
    begin
      aBox.IntLengths.Horizontal := TreeIndent * lTree.Text.Length * MeasureString(RefChar, CurrentFont).Horizontal;
      aBox.IntLengths.Vertical := MeasureString(RptTree.TreeThru, CurrentFont).Vertical;
    end;
end;

method RptImageFormatter.MeasureComposite(aStr: CompositeString): FmtLengths;
begin
  result := new FmtLengths(0, 0);
  for i := 0 to aStr.Count - 1 do
    begin
      var lStr := aStr.Element[i].Str;
      var lTag := aStr.Element[i].Tag;
      var lFont := fFontStack.Peek.Font[lTag];
      var lMeasure := MeasureString(lStr, lFont);
      result.Horizontal := result.Horizontal + lMeasure.Horizontal;
      result.Vertical := Math.Max(result.Vertical, lMeasure.Vertical);
    end;
end;

method RptImageFormatter.MeasureBox(aBox: FmtBox);
begin
  aBox.IntLengths := MeasureText(aBox);
  if aBox:Element is RptImage then
    aBox.IntLengths := MeasureImage(RptImage(aBox.Element));
  if aBox:Element is RptTree then
    MeasureTree(aBox);
  if aBox:Element is RptComposite then
    aBox.IntLengths := MeasureComposite(RptComposite(aBox.Element).Composite);
  if aBox:Element is RptLine then
    begin
      var lHeight := aBox.IntLengths.Vertical;
      if lHeight = 0 then
        lHeight := InitLineHeight(RptLine(aBox.Element));
      aBox.IntLengths.Vertical := lHeight;
      CurrentLineHeight := lHeight;
    end;
  if aBox:Element is RptBeginLiner then
    aBox.IntLengths.Vertical := Math.Max(0, CurrentLineHeight + RptBeginLiner(aBox.Element).Lines * (LinerGap + LinerWidth));
  if aBox:Element is RptEndLiner then
    if RptEndLiner(aBox.Element).BeginLiner <> nil then
      aBox.IntLengths.Vertical := Math.Max(0, CurrentLineHeight + RptEndLiner(aBox.Element).BeginLiner.Lines * (LinerGap + LinerWidth));
end;

method RptImageFormatter.GetFreeWidth: FmtLength;
begin
  var lHorizontalBorders :=
    DimensionToLength(fBorders.Left, RptDirection.Horizontal) + DimensionToLength(fBorders.Right, RptDirection.Horizontal);
  result := PageLengths.Horizontal - lHorizontalBorders;
end;

method RptImageFormatter.GetFreeHeight: FmtLength;
begin
  var lVerticalBorders :=
    DimensionToLength(fBorders.Top, RptDirection.Vertical) + DimensionToLength(fBorders.Bottom, RptDirection.Vertical);
  result := PageLengths.Vertical - lVerticalBorders;
end;

method RptImageFormatter.PushFormat(aBaseFont: Font);
begin
  var lBundle := new RptFontBundle(aBaseFont, fFontMaker);
  fFontStack.Push(lBundle);
end;

method RptImageFormatter.PopFormat;
require
  fFontStack.Count > 0;
begin
  fFontStack.Peek.Dispose;
  fFontStack.Pop;
end;

method RptImageFormatter.PrepareImage;
begin
  ffCurrentImageStream := if fUseMetafile then new MemoryStream else nil;
  if fUseMetafile then
    begin
      ffCurrentImageStream := new MemoryStream;
      using lGraphics := Graphics.FromHwndInternal(IntPtr.Zero) do
        begin
          var lContextHandle := lGraphics.GetHdc();
          var lMfRectangleF := new RectangleF(0, 0, PageLengths.Horizontal, PageLengths.Vertical);
          ffCurrentMetafile := new Metafile(ffCurrentImageStream, lContextHandle, lMfRectangleF, MetafileFrameUnit.Pixel, EmfType.EmfPlusOnly);
          lGraphics.ReleaseHdc;
          var metafileHeader := ffCurrentMetafile.GetMetafileHeader;
          lGraphics.ScaleTransform(
            metafileHeader.DpiX / lGraphics.DpiX,
            metafileHeader.DpiY / lGraphics.DpiY);
          lGraphics.PageUnit := GraphicsUnit.Pixel;
          lGraphics.SetClip(lMfRectangleF);
        end;
      ffCurrentImage := ffCurrentMetafile;
    end
  else
    begin
      ffCurrentImageStream := nil;
      ffCurrentBitmap := new Bitmap(PageLengths.Horizontal, PageLengths.Vertical);
      ffCurrentImage := ffCurrentBitmap;
    end;
  ffCurrentGraphics := Graphics.FromImage(ffCurrentImage);
//  ffCurrentGraphics.SmoothingMode := SmoothingMode.HighQuality;
  ffCurrentGraphics.InterpolationMode := InterpolationMode.HighQualityBicubic;
  ffCurrentGraphics.PixelOffsetMode := PixelOffsetMode.HighQuality;
  ffCurrentGraphics.CompositingQuality := CompositingQuality.HighQuality;
  ffCurrentGraphics.Clear(Color.White);
end;

method RptImageFormatter.CaptureImagePage: RptImagePage;
begin
  ffCurrentGraphics.Dispose;
  ffCurrentGraphics := nil;
  result := new RptImagePage;
  if ffCurrentMetafile <> nil then
    result.SetImage(ffCurrentImageStream.ToArray, true)
  else
    result.SetImage(ffCurrentBitmap);
  ffCurrentMetafile := nil;
  ffCurrentBitmap := nil;
  ffCurrentImage.Dispose;
  if ffCurrentImageStream <> nil then
    begin
      ffCurrentImageStream.Dispose;
      ffCurrentImageStream := nil;
    end;
end;

method RptImageFormatter.BeginFormat;
begin
  inherited BeginFormat;
  PushFormat(new Font(fDefaultFont, FontStyle.Regular));
  fLineHeightStack.Push(InitLineHeight(new RptLine));
  PrepareImage;
end;

method RptImageFormatter.EndFormat;
begin
  inherited EndFormat;
  fLineHeightStack.Pop;
  PopFormat;
end;

method RptImageFormatter.BeginPaginate;
begin
  inherited BeginPaginate;
  PushFormat(new Font(fDefaultFont, FontStyle.Regular));
  fLineHeightStack.Push(InitLineHeight(new RptLine));
  PrepareImage;
end;

method RptImageFormatter.EndPaginate;
begin
  fLineHeightStack.Pop;
  PopFormat;
  inherited EndPaginate;
end;

method RptImageFormatter.RenderText(aText: String; aRect: FmtRectangle);
begin
// This seems right, but it does not work (sometimes strips off string tail when exported to PDF)
//  using fmt := StringFormat.GenericTypographic do
//    ffCurrentGraphics.DrawString(aText, CurrentFont, Brushes.Black, WinRect(aRect), fmt);
  var lPoint := new PointF(aRect.Left, aRect.Top + aRect.Height / 2.0);
  using fmt := StringFormat.GenericTypographic do
    ffCurrentGraphics.DrawString(aText, CurrentFont, Brushes.Black, lPoint, fmt);
end;

method RptImageFormatter.RenderText(aText: String; aRect: FmtRectangle; aFont: Font; aBrush: Brush);
begin
// This seems right, but it does not work (sometimes strips off string tail when exported to PDF)
//  using fmt := StringFormat.GenericTypographic do
//    ffCurrentGraphics.DrawString(aText, aFont, aBrush, WinRect(aRect), fmt);
  var lPoint := new PointF(aRect.Left, aRect.Top + aRect.Height / 2.0);
  using fmt := StringFormat.GenericTypographic do
    ffCurrentGraphics.DrawString(aText, aFont, aBrush, lPoint, fmt);
end;

method RptImageFormatter.RenderTree(aBox: FmtBox);
const Exceed = 1;
begin
  var lText := RptTree(aBox:Element).Text;
  var lRect := aBox.Rectangle;
  if String.IsNullOrEmpty(lText) then
    begin
      fPrevTree := nil;
      exit;
    end;
  if Report.TreePattern <> RptTreePattern.Lines then
    RenderText(DisplayedText(aBox), lRect)
  else
    begin
      var W := lRect.Width div lText.Length;
      var W1 := W div TreeIndent;
      var X := lRect.Left;
      var CY := (lRect.Top + lRect.Bottom) div 2;
      using lPen := new Pen(Brushes.Black, 0) do
        for each lChar in lText do
          begin
            var CX := X + W1 div 2;
            var TY :=
              if fPrevTree = nil then lRect.Top - Exceed
              else fPrevTree.Bottom - Exceed;
            if lChar = RptTree.TreeLine then
              ffCurrentGraphics.DrawLine(lPen, X, CY, X + W, CY)
            else if lChar <> RptTree.TreeNone then
              begin
                ffCurrentGraphics.DrawLine(lPen, CX, TY, CX, CY);
                if (lChar = RptTree.TreeThru) or (lChar = RptTree.TreeLink) then
                  ffCurrentGraphics.DrawLine(lPen, CX, CY, CX, lRect.Bottom + Exceed);
                if (lChar = RptTree.TreeLink) or (lChar = RptTree.TreeLast) then
                  ffCurrentGraphics.DrawLine(lPen, CX, CY, X + W, CY);
              end;
            X := X + W;
          end;
    end;
end;

method RptImageFormatter.RenderImage(aImage: WinImage; aRect: FmtRectangle);
begin
  ffCurrentGraphics.DrawImage(aImage.Image, WinRect(aRect));
end;

method RptImageFormatter.RenderLines(aBegin, aEnd: FmtRectangle; aLines: Integer);
begin
  var lBottom := Math.Max(aBegin.Bottom, aEnd.Bottom);
  var lDiff := LinerWidth + LinerGap;
  using lPen := new Pen(Color.Black, LinerWidth) do
    begin
      for i := 1 to aLines do
        begin
          ffCurrentGraphics.DrawLine(lPen, aBegin.Left, lBottom, aEnd.Right, lBottom);
          lBottom := lBottom - lDiff;
        end;
    end;
end;

method RptImageFormatter.RenderComposite(aBox: FmtBox);
begin
  var lRect := aBox.Rectangle.Copy;
  var lComposite := RptComposite(aBox.Element).Composite;
  for i := 0 to lComposite.Count - 1 do
    begin
      var lStr := lComposite.Element[i].Str;
      var lTag := lComposite.Element[i].Tag;
      var lFont := fFontStack.Peek.Font[lTag];
      var lBrush :=
        if assigned(BrushMaker) then BrushMaker(lTag)
        else new SolidBrush(Color.Black);
      var lMeasure := MeasureString(lStr, lFont);
      RenderText(lStr, lRect, lFont, lBrush);
      lRect.Left := lRect.Left + lMeasure.Horizontal;
      lBrush.Dispose;
    end;
end;

method RptImageFormatter.RenderRectangles(aBox: FmtBox);

  method DrawRect(aRect: FmtRectangle; aColor: Color);
  begin
    using lPen := new Pen(aColor, 1) do
      ffCurrentGraphics.DrawRectangle(lPen, WinRect(aRect));
  end;

begin
  if DrawInnerRectangles <> nil then
    begin
      var lRect := aBox.IntRectangle.Copy;
      lRect.Left := lRect.Left + aBox.Rectangle.Left;
      lRect.Top := lRect.Top + aBox.Rectangle.Top;
      DrawRect(lRect, DrawInnerRectangles);
    end;
  if DrawOuterRectangles <> nil then
    DrawRect(aBox.Rectangle, DrawOuterRectangles);
end;

method RptImageFormatter.RenderBox(aBox: FmtBox);
begin
  BeginBox(aBox);
  try
    RenderRectangles(aBox);
    var lRpt := aBox.Element;
    var lRect := aBox.Rectangle;
    if lRpt is RptImage then
      RenderImage(RptImage(lRpt).Image as WinImage, lRect)
    else if lRpt is RptComposite then
      RenderComposite(aBox)
    else if lRpt is RptEndLiner then
      begin
        if fLiners.Count > 0 then
          RenderLines(fLiners.Peek, lRect, RptEndLiner(lRpt).BeginLiner.Lines);
      end
    else if lRpt is RptSection then
      fPrevTree := nil
    else if lRpt is not RptGroup then
      begin
        if lRpt is RptTree then
          begin
            RenderTree(aBox);
            fPrevTree :=
              if RptTree(lRpt).IsParent then aBox
              else nil;
          end
        else
          begin
            var lText := DisplayedText(aBox);
            RenderText(lText, lRect);
          end;
       end;
    for lIdx := 0 to aBox.Count - 1 do
      RenderBox(aBox[lIdx]);
  finally
    EndBox(aBox);
  end;
end;

method RptImageFormatter.Render;
begin
  ClearContext;
  State := FmtState.Rendering;
  Aborted := false;
  fImagePages := new List<RptImagePage>;
  PushFormat(new Font(fDefaultFont, FontStyle.Regular));
  fLineHeightStack.Push(InitLineHeight(new RptLine));
  try
    for pIdx := 0 to PageCount - 1 do
      begin
        if Aborted then
          break;
        SetPageNumber(pIdx);
        PrepareImage;
        fPrevTree := nil;
        for each lBox in Page[pIdx].Boxes do
          RenderBox(lBox);
        fImagePages.Add(CaptureImagePage);
      end;
  finally
    fLineHeightStack.Pop;
    PopFormat;
    State := FmtState.Idle;
  end;
end;

method RptImageFormatter.HasImage(aIdx: Integer): Boolean;
begin
  result := (0 <= aIdx < PageCount) and ImagePage[aIdx].HasImage;
end;

method RptImageFormatter.GetImage(aIdx: Integer): Image;
begin
  result := ImagePage[aIdx].GetImage;
end;

method RptImageFormatter.GetImageAsBitmap(aIdx: Integer): Bitmap;
begin
  result := ImagePage[aIdx].GetImageAsBitmap;
end;

method RptImageFormatter.GetImageAsMetafile(aIdx: Integer): Metafile;
begin
  result := ImagePage[aIdx].GetImageAsMetafile;
end;

method RptImageFormatter.SaveToHtml(aFileName: String; aHtmlParams: RptHtmlParameters);
require
  not String.IsNullOrEmpty(aFileName);
begin
  using lHtmlWriter := new RptHtmlWriter(Report, aHtmlParams) do
    lHtmlWriter.WriteToFile(aFileName);
end;

method RptImageFormatter.SaveToText(aFileName: String; aPageDimensions: FmtLengths);
require
  not String.IsNullOrEmpty(aFileName);
begin
  using lTextFormatter := new RptTextFormatter(Report, nil, aPageDimensions) do
    begin
      lTextFormatter.Format;
      lTextFormatter.Render;
      lTextFormatter.WriteToFile(aFileName);
    end;
end;

method RptImageFormatter.SaveToMetafiles(aFileName: String);
begin
 var lFileNames := NumberedFileName(aFileName);
  for i := 0 to ImagePageCount - 1 do
    begin
      var lPage := ImagePage[i];
      var lFileName := lFileNames.Replace('*', '_' + Utils.IntToStr(i + 1));
      if lPage.HasMetafile then
          File.WriteBytes(lFileName, lPage.GetBytes)
      else
        using lMetafile := lPage.GetImageAsMetafile do
          begin
            var lImgPage := new RptImagePage;
            lImgPage.SetImage(lMetafile);
            File.WriteBytes(lFileName, lImgPage.GetBytes);
          end;
    end;
end;

method RptImageFormatter.SaveToBitmaps(aFileName: String);
begin
 var lFileNames := NumberedFileName(aFileName);
  for i := 0 to ImagePageCount - 1 do
    begin
      var lFileName := lFileNames.Replace('*', '_' + Utils.IntToStr(i + 1));
      var lPage := ImagePage[i];
      using lBitmap := lPage.GetImageAsBitmap do
        lBitmap.Save(lFileName, ImageFormat.Png);
    end;
end;

method RptImageFormatter.Print(aDocument: RptPrintDocument; aStartPage: Integer; aTwoPages: Boolean := false);
require
  aDocument <> nil;
begin
  var ps := aDocument.PrinterSettings;
  var lFirst := ps.MinimumPage - 1;
  var lLast := ps.MaximumPage - 1;
  aDocument.Clear;
  case ps.PrintRange of
    PrintRange.AllPages: {nothing}
      ;
    PrintRange.CurrentPage:
      begin
        lFirst := aStartPage;
        lLast := aStartPage;
      end;
    PrintRange.Selection:
      begin
        lFirst := aStartPage;
        lLast := aStartPage;
        if aTwoPages then
          lLast := Math.Min(lFirst + 1, PageCount - 1);
      end;
    PrintRange.SomePages:
      begin
        lFirst := ps.FromPage - 1;
        lLast := ps.ToPage - 1;
      end;
  end;
  aDocument.First := lFirst;
  aDocument.Last := lLast;
  aDocument.Print;
end;

{$ENDREGION}

{$REGION RptPrintDocument}

constructor RptPrintDocument(aFormatter: not nullable RptImageFormatter);
begin
  inherited constructor;
  fFormatter := aFormatter;
  if not String.IsNullOrEmpty(fFormatter:Report:Text) then
    DocumentName := fFormatter.Report.Text;
  Clear;
end;

method RptPrintDocument.Clear;
begin
  fFirst := 0;
  fLast := fFormatter.ImagePageCount - 1;
end;

method RptPrintDocument.OnBeginPrint(e: PrintEventArgs);
begin
  if fFirst >= fFormatter.ImagePageCount then
    fFirst := fFormatter.ImagePageCount - 1;
  if fLast >= fFormatter.ImagePageCount then
    fLast := fFormatter.ImagePageCount - 1;
  fPrintPage := fFirst;
  inherited OnBeginPrint(e);
end;

method RptPrintDocument.OnPrintPage(e: PrintPageEventArgs);
begin
  if fPrintPage > fLast then
    begin
      e.HasMorePages := false;
      exit;
    end;
  using lImage := fFormatter.GetImage(fPrintPage) do
    e.Graphics.DrawImage(lImage, PointF.Empty);
  inc(fPrintPage);
  e.HasMorePages := fPrintPage <= fLast;
end;

{$ENDREGION}

end.
