// WinUtils.pas is part of
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
// WinUtils.pas implements classess supporting GUI elements such as colors, fonts, pens and brushes.
// Two of those, 'ColorData' and 'FontData' extend the platform-independent DEXiLibrary classess
// 'ColorInfo' andf 'FontInfo', respectively, and connect them with Windows-platform colors and fonts.
// Additionally, the class 'GraphicsUtils' implements graphic utilities used in displaying charts.
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

type ColorData = public class (ColorInfo)
  public
    constructor (aColor: Color := Color.Black);
    constructor (aColor: ColorInfo);
    method NewColor: Color; virtual;
  end;

type FontData = public class (FontInfo)
  public
    class method CopyFont(aFont: Font): Font;
    constructor (aFont: Font);
    constructor (aFont: FontInfo);
    method NewFont: Font; virtual;
    method WinStyle: FontStyle;
  end;

type
  PenData = public class
  public
    constructor (aColor: Color := Color.Black; aWidth: Float := 0; aDashStyle: DashStyle := DashStyle.Solid);
    constructor (aColor: ColorInfo; aWidth: Float := 0; aDashStyle: DashStyle := DashStyle.Solid);
    constructor (aWidth: Float; aColor: Color := Color.Black; aDashStyle: DashStyle := DashStyle.Solid);
    constructor (aPenData: PenData);
    constructor (aPen: Pen);
    class method &Copy(aPenData: PenData): PenData;
    method NewPen: Pen; virtual;
    property Color: Color;
    property Width: Float;
    property DashStyle: DashStyle;
  end;

type
  BrushData = public class
  protected
    method GetHatchIndex: Integer;
  public
    constructor (aColor: Color := Color.Black; aHatchStyle: nullable HatchStyle := nil);
    constructor (aColor: ColorInfo; aHatchStyle: nullable HatchStyle := nil);
    constructor (aBrushData: BrushData);
    constructor (aBrush: Brush);
    class method &Copy(aBrushData: BrushData): BrushData;
    method NewBrush: Brush; virtual;
    property Color: Color;
    property HatchColor: Color;
    property HatchStyle: nullable HatchStyle;
    property HatchIndex: Integer read GetHatchIndex;
    property IsSolid: Boolean read HatchStyle = nil;
  end;

type
  GraphicsUtils = public static class
  public
    method CroppedRectangle(aBitmap: Bitmap): Rectangle;
    method RoundedRect(aRect: Rectangle; aEdge: Anchor): GraphicsPath;
    method CropBitmapToRect(aBitmap: Bitmap; aRect: Rectangle): Bitmap;
    method CropMetafileToRect(aMetafile: Metafile; aRect: Rectangle): Metafile;
    method SetShapePicture(aBox: PictureBox; aImage: Image);
    method MixColors(aColors: array of Color; aWeights: FltArray): Color;
  end;

implementation

{$REGION ColorData}

constructor ColorData(aColor: Color := Color.Black);
begin
  inherited constructor (aColor.ToArgb);
end;

constructor ColorData(aColor: ColorInfo);
begin
  inherited constructor (aColor);
end;

method ColorData.NewColor: Color;
begin
  result := Color.FromArgb(ARGB);
end;

{$ENDREGION}

{$REGION FontData}

class method FontData.CopyFont(aFont: Font): Font;
begin
  result := new Font(aFont, aFont.Style);
end;

constructor FontData(aFont: Font);
begin
  inherited constructor (aFont.Name, aFont.Size);
  Bold := (aFont.Style and FontStyle.Bold) <> 0;
  Italic := (aFont.Style and FontStyle.Italic) <> 0;
  Underline := (aFont.Style and FontStyle.Underline) <> 0;
end;

constructor FontData(aFont: FontInfo);
begin
  inherited constructor (aFont);
end;

method FontData.NewFont: Font;
begin
  var lName := Name;
  if lName = nil then
    lName := SystemFonts.DefaultFont.Name;
  var lSize := Size;
  if lSize <= 0 then
    lSize := SystemFonts.DefaultFont.Size;
  result := new Font(lName, lSize, WinStyle);
end;

method FontData.WinStyle: FontStyle;
begin
  result := 0;
  if Bold then result := result or FontStyle.Bold;
  if Italic then result := result or FontStyle.Italic;
  if Underline then result := result or FontStyle.Underline;
end;

{$ENDREGION}

{$REGION PenData}

constructor PenData(aColor: Color := Color.Black; aWidth: Float := 0; aDashStyle: DashStyle := DashStyle.Solid);
begin
  inherited constructor;
  Color := aColor;
  Width := aWidth;
  DashStyle := aDashStyle;
end;

constructor PenData(aColor: ColorInfo; aWidth: Float := 0; aDashStyle: DashStyle := DashStyle.Solid);
begin
  var lColorData := new ColorData(aColor);
  constructor (lColorData.NewColor, aWidth, aDashStyle);
end;

constructor PenData(aWidth: Float; aColor: Color := Color.Black; aDashStyle: DashStyle := DashStyle.Solid);
begin
  constructor (aColor, aWidth, aDashStyle);
end;

constructor PenData(aPenData: PenData);
begin
  constructor (aPenData.Color, aPenData.Width, aPenData.DashStyle);
end;

constructor PenData(aPen: Pen);
begin
  constructor (aPen.Color, aPen.Width, aPen.DashStyle);
end;

class method PenData.Copy(aPenData: PenData): PenData;
begin
  result :=
    if aPenData = nil then nil
    else new PenData(aPenData);
end;

method PenData.NewPen: Pen;
begin
  result := new Pen(Color, Width);
  result.DashStyle := DashStyle;
end;

{$ENDREGION}

{$REGION BrushData}

constructor BrushData(aColor: Color := Color.Black; aHatchStyle: nullable HatchStyle := nil);
begin
  inherited constructor;
  Color := aColor;
  HatchColor := Color.White;
  HatchStyle := aHatchStyle;
end;

constructor BrushData(aColor: ColorInfo; aHatchStyle: nullable HatchStyle := nil);
begin
  var lColorData := new ColorData(aColor);
  constructor (lColorData.NewColor, aHatchStyle);
end;

constructor BrushData(aBrushData: BrushData);
begin
  constructor (aBrushData.Color, aBrushData.HatchStyle);
  HatchColor := aBrushData.HatchColor;
end;

constructor BrushData(aBrush: Brush);
begin
  constructor;
  if aBrush is SolidBrush then
    Color := SolidBrush(aBrush).Color
  else if aBrush is HatchBrush then
    with lHatchBrush := aBrush as HatchBrush do
      begin
        Color := lHatchBrush.BackgroundColor;
        HatchColor := lHatchBrush.ForegroundColor;
        HatchStyle := lHatchBrush.HatchStyle;
      end;
end;

method BrushData.GetHatchIndex: Integer;
begin
  result :=
    if HatchStyle = nil then -1
    else ord(Integer(HatchStyle));
end;

class method BrushData.Copy(aBrushData: BrushData): BrushData;
begin
  result :=
    if aBrushData = nil then nil
    else new BrushData(aBrushData);
end;

method BrushData.NewBrush: Brush;
begin
  result :=
    if IsSolid then new SolidBrush(Color)
    else new HatchBrush(HatchStyle, HatchColor, Color);
end;

{$ENDREGION}

{$REGION GraphicsUtils}

method GraphicsUtils.RoundedRect(aRect: Rectangle; aEdge: Anchor): GraphicsPath;
begin
  var lRadiusX :=
    if aEdge.UnitX = AnchorUnit.Pixel then aEdge.X
    else Math.Round(aRect.Width * aEdge.X / 100.0);
  var lRadiusY :=
    if aEdge.UnitY = AnchorUnit.Pixel then aEdge.Y
    else Math.Round(aRect.Height * aEdge.Y / 100.0);
  result := new GraphicsPath;
  if (lRadiusX <= 0) or (lRadiusY <= 0) then
    begin
      result.AddRectangle(aRect);
      exit;
    end;
  var lDiameterX := 2 * lRadiusX;
  var lDiameterY := 2 * lRadiusY;
  var lSize := new Size(lDiameterX, lDiameterY);
  var lArc := new Rectangle(aRect.Location, lSize);

  // top left
  result.AddArc(lArc, 180, 90);

  // top right
  lArc.X := aRect.Right - lDiameterX;
  result.AddArc(lArc, 270, 90);

  // bottom right
  lArc.Y := aRect.Bottom - lDiameterY;
  result.AddArc(lArc, 0, 90);

  // bottom left
  lArc.X := aRect.Left;
  result.AddArc(lArc, 90, 90);

  result.CloseFigure;
end;

method GraphicsUtils.SetShapePicture(aBox: PictureBox; aImage: Image);
begin
  if aBox.Image <> nil then
    aBox.Image.Dispose;
  aBox.Image := aImage;
end;

method GraphicsUtils.MixColors(aColors: array of Color; aWeights: FltArray): Color;

  method Clr(aValue, aSum: Float): Integer;
  begin
    result :=
      if aSum = 0.0 then 0
      else Math.Min(Math.Round(aValue / aSum), 255);
  end;

require
  length(aColors) = length(aWeights);
  length(aColors) > 0;
begin
  var lA := 0.0;
  var lR := 0.0;
  var lG := 0.0;
  var lB := 0.0;
  var lWsum := 0.0;
  for each lColor in aColors index x do
    begin
      var lW := aWeights[x];
      lA := lA + lW * lColor.A;
      lR := lR + lW * lColor.R;
      lG := lG + lW * lColor.G;
      lB := lB + lW * lColor.B;
      lWsum := lWsum + lW;
    end;
  result := Color.FromArgb(Clr(lA, lWsum), Clr(lR, lWsum), Clr(lG, lWsum), Clr(lB, lWsum));
end;

method GraphicsUtils.CroppedRectangle(aBitmap: Bitmap): Rectangle;

  method HasPixel(x, y: Integer): Boolean;
  const NoColor = Color.FromArgb(255, 255, 255, 255);
  begin
    result := aBitmap.GetPixel(x, y) <> NoColor;
  end;

begin
  result := new Rectangle(0, 0, aBitmap.Width, aBitmap.Height);
  var IsFirstOne := true;
  for y := 0 to aBitmap.Height - 1 do
    for x := 0 to aBitmap.Width - 1 do
      if IsFirstOne then
        begin
          if HasPixel(x, y) then
            begin
              result := new Rectangle;
              result.X := x;
              result.Y := y;
              result.Width := 1;
              result.Height := 1;
              IsFirstOne := false;
            end;
        end
      else if not result.Contains(x, y) then
        if HasPixel(x, y) then
          begin
            if x > (result.X + result.Width) then
                result.Width := x - result.X;
            if x < result.X then
              begin
                var oldRectLeft := result.Left;
                result.X := x;
                result.Width := result.Width + oldRectLeft - x;
              end;
            if y > (result.Y + result.Height) then
              result.Height := y - result.Y;
            if y < (result.Y + result.Height) then
              begin
                var oldRectTop := result.Top;
                result.Y := y;
                result.Height := result.Height + oldRectTop - y;
              end;
            end;
end;

method GraphicsUtils.CropBitmapToRect(aBitmap: Bitmap; aRect: Rectangle): Bitmap;
begin
  result := new Bitmap(aRect.Width, aRect.Height);
  using g := Graphics.FromImage(result) do
    g.DrawImage(aBitmap, -aRect.X, -aRect.Y);
end;

method GraphicsUtils.CropMetafileToRect(aMetafile: Metafile; aRect: Rectangle): Metafile;
begin
  using lStream := new MemoryStream do
  using lGraphics := Graphics.FromHwndInternal(IntPtr.Zero) do
    begin
      var lContextHandle := lGraphics.GetHdc();
      var lMfRectangleF: RectangleF := aRect;
      result := new Metafile(lStream, lContextHandle, lMfRectangleF, MetafileFrameUnit.Pixel, EmfType.EmfPlusOnly);
      lGraphics.ReleaseHdc;
      var metafileHeader := result.GetMetafileHeader;
      lGraphics.ScaleTransform(
        metafileHeader.DpiX / lGraphics.DpiX,
        metafileHeader.DpiY / lGraphics.DpiY);
      lGraphics.PageUnit := GraphicsUnit.Pixel;
      using g := Graphics.FromImage(result) do
        g.DrawImage(aMetafile, 0, 0);
    end;
end;

{$ENDREGION}

end.
