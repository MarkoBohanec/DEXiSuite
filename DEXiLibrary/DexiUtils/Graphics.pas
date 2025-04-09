// Graphics.pas is part of
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
// Graphics.pas implements basic graphics classes for DEXi.
//
// The rationale for implementing Graphics.pas in DexiUtils is as follows:
//
// 1. Graphic elements, such as colors, points, shapes and fonts, have nothing to do with
//    the concept of DEXi models and should, in principle, not be considered in DEXiLibrary.
// 2. However, DEXi software needs to store, in .dxi files, information about colors used to
//    display good and bad DEXi values and information about fonts displayed in reports.
//    Thus, some basic treatment of graphics is necessary in DEXiLibrary.
// 3. The implementation of graphics differs considerably between platforms, such as .NET and Java.
//    DEXiLibrary, as a cross-platform software, should avoid platform-dependent solutions.
// 4. Consequenly, Graphics.pas implements classes that just store platform-independent information
//    about graphic elements (particularly rectangles, colors, fonts and chart points), to be
//    written to and read from .dxi files. Any rendering and further processing of this data
//    is deferred to higher platform-dependent software components.
//
// In addition, Graphics.pas implements the classes:
// - ScaleMaker: Given the low and high bound of a chart scale, suggest suitable tick intervals
// - Map3to2D: Mapping of a three-dimensional point to a two-dimensional surface
// ----------

namespace DexiUtils;

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

interface

 uses
  RemObjects.Elements.RTL;

type
  ColorValue = UInt32;

type
  ImgBorder = public class
  private
    fLeft: Integer;
    fRight: Integer;
    fTop: Integer;
    fBottom: Integer;
  protected
    method SetAsString(aString: String); virtual;
  public
    constructor (aLeft: Integer := 0; aRight: Integer := 0; aTop: Integer := 0; aBottom: Integer := 0);
    constructor (aBorder: ImgBorder);
    method EqualTo(aBorder: ImgBorder): Boolean;
    method ToString: String; override;
    method RelativeString(aBorder: ImgBorder): String;
    method SetFromRelativeString(aString: String; aBorder: ImgBorder);
    property Left: Integer read fLeft write fLeft;
    property Right: Integer read fRight write fRight;
    property Top: Integer read fTop write fTop;
    property Bottom: Integer read fBottom write fBottom;
    property AsString: String read ToString write SetAsString;
  end;

type
  ImgRectangle = public class
  private
    fLeft, fTop, fWidth, fHeight: Integer;
  protected
    method GetRight: Integer;
    method SetRight(aRight: Integer);
    method GetBottom: Integer;
    method SetBottom(aBottom: Integer);
    method SetAsString(aStr: String);
  public
    constructor (aLeft: Integer := 0; aTop: Integer := 0; aWidth: Integer := 0; aHeight: Integer := 0);
    constructor (aImgRect: ImgRectangle);
    constructor (aFmtRect: FmtRectangle);
    method Clear;
    method &Copy: not nullable ImgRectangle;
    method Assign(aRect: ImgRectangle);
    method Assign(aRect: FmtRectangle);
    method ToFmtRectangle: not nullable FmtRectangle;
    method ToString: String; override;
    property Left: Integer read fLeft write fLeft;
    property X: Integer read fLeft write fLeft;
    property Top: Integer read fTop write fTop;
    property Y: Integer read fTop write fTop;
    property Width: Integer read fWidth write fWidth;
    property Height: Integer read fHeight write fHeight;
    property Right: Integer read GetRight write SetRight;
    property Bottom: Integer read GetBottom write SetBottom;
    property AsString: String read toString write SetAsString;
  end;

type
  ColorInfo = public class
  private
    fARGB: ColorValue;
    const AlphaShift = 24;
    const RedShift =   16;
    const GreenShift =  8;
    const BlueShift =   0;
  protected
    method GetAlpha: Byte;
    method GetRed: Byte;
    method GetGreen: Byte;
    method GetBlue: Byte;
    method SetByte(aByte: Byte; aShift: Byte);
    method SetAlpha(aAlpha: Byte);
    method SetRed(aRed: Byte);
    method SetGreen(aGreen: Byte);
    method SetBlue(aBlue: Byte);
    method SetAsString(aStr: String);
  public
    constructor (aColor: ColorInfo);
    constructor (aARGB: ColorValue);
    constructor (aRed, aGreen, aBlue: Byte);
    constructor (aAlpha, aRed, aGreen, aBlue: Byte);
    constructor (aAlpha: Byte; aColor: ColorInfo);
    constructor (aStr: String);
    class method &Copy(aColor: ColorInfo): ColorInfo;
    property ARGB: ColorValue read fARGB write fARGB;
    property Alpha: Byte read GetAlpha write SetAlpha;
    property Red: Byte read GetRed write SetRed;
    property Green: Byte read GetGreen write SetGreen;
    property Blue: Byte read GetBlue write SetBlue;
    property AsString: String read ToString write SetAsString;
    method EqualTo(aInfo: ColorInfo): Boolean;
    method ToString: String; override;
    method ToHexString(aWithAlpha: Boolean := false): String;
  end;

type
  FontInfo = public class
  private
    fName: String;
    fSize: Float;
    fBold: Boolean;
    fItalic: Boolean;
    fUnderline: Boolean;
  protected
    method GetStyle: String;
    method SetStyle(aStyle: String);
    method SetAsString(aString: String);
  public
    constructor (aName: String; aSize: Float; aStyle: String := '');
    constructor (aString: String);
    constructor (aFont: FontInfo);
    class method DefaultFont: FontInfo;
    class method StyleString(aBold, aItalic, aUnderline: Boolean): String;
    class method &Copy(aFont: FontInfo): FontInfo;
    property Name: String read fName write fName;
    property Size: Float read fSize write fSize;
    property Bold: Boolean read fBold write fBold;
    property Italic: Boolean read fItalic write fItalic;
    property Underline: Boolean read fUnderline write fUnderline;
    property Style: String read GetStyle write SetStyle;
    property AsString: String read ToString write SetAsString;
    method EqualTo(aInfo: FontInfo): Boolean;
    method ToString: String; override;
  end;

type
  ScaleMaker = public class
  private
    fMinPoint: Float;
    fMaxPoint: Float;
    fMaxTicks: Integer := 10;
    fTickSpacing: Float;
    fRange: Float;
    fNiceMin: Float;
    fNiceMax: Float;
    fExtra: Float := 0.1;
  protected
    method Calculate;
    method NiceNum(aRange: Float; aRound: Boolean): Float;
    method SetMinPoint(aMin: Float);
    method SetMaxPoint(aMax: Float);
    method SetMaxTicks(aTicks: Integer);
  public
    constructor (aMin: Float; aMax: Float);
    method SetMinMaxPoints(aMin: Float; aMax: Float);
    property Extra: Float read fExtra write fExtra;
    property MinPoint: Float read fMinPoint write SetMinPoint;
    property MaxPoint: Float read fMaxPoint write SetMaxPoint;
    property MaxTicks: Integer read fMaxTicks write SetMaxTicks;
    property TickSpacing: Float read fTickSpacing;
    property NiceMin: Float read fNiceMin;
    property NiceMax: Float read fNiceMax;
  end;

type
  ChartPoint = public class
  private
     fX, fY: Float;
  public
    constructor (aX, aY: Float);
    property X: Float read fX write fX;
    property Y: Float read fY write fY;
    property IntX: Integer read Math.Round(X);
    property IntY: Integer read Math.Round(Y);
  end;

type
  Map3to2D = public class
  private
    fDefHorizontal: Float := 225.0;
    fDefVertical: Float := 15.0;
    a, b, p1, p2, p3, p4, p5: Float;
  protected
    class const pi180 = Consts.PI / 180.0;
    method SetHorizontalRotation(aDegrees: Float); virtual;
    method SetVerticalRotation(aDegrees: Float); virtual;
  public
    constructor;
    constructor (aDefHorizontal: Float; aDefVertical: Float);
    property HorizontalRotation: Float read a write SetHorizontalRotation;
    property VerticalRotation: Float read a write SetVerticalRotation;
    method SetRotation(aHorizontal, aVertical: Float); virtual;
    method ResetRotation; virtual;
    method ProjX(x, y, z: Float): Float;
    method ProjY(x, y, z: Float): Float;
    method Proj(x, y, z: Float): ChartPoint;
  end;

implementation

{$REGION ImgBorder}

constructor ImgBorder(aLeft: Integer := 0; aRight: Integer := 0; aTop: Integer := 0; aBottom: Integer := 0);
begin
  inherited constructor;
  fLeft := aLeft;
  fRight := aRight;
  fTop := aTop;
  fBottom := aBottom;
end;

constructor ImgBorder(aBorder: ImgBorder);
begin
  constructor (aBorder.Left, aBorder.Right, aBorder.Top, aBorder.Bottom);
end;

method ImgBorder.SetAsString(aString: String);
begin
  var lElements := aString.Split(';');
  if length(lElements) <> 4 then
    raise new ArgumentException($'ImgBorder string format error: "{aString}"');
  fLeft := Utils.StrToInt(lElements[0]);
  fRight := Utils.StrToInt(lElements[1]);
  fTop := Utils.StrToInt(lElements[2]);
  fBottom := Utils.StrToInt(lElements[3]);
end;

method ImgBorder.ToString: String;
begin
  result := $"{fLeft};{fRight};{fTop};{fBottom}";
end;

method ImgBorder.EqualTo(aBorder: ImgBorder): Boolean;
begin
  result := (fLeft = aBorder.Left) and (fRight = aBorder.Right) and (fTop = aBorder.Top) and (fBottom = aBorder.Bottom);
end;

method ImgBorder.RelativeString(aBorder: ImgBorder): String;
var lString: String;

  method AddDim(aDim, aDef: Integer);
  begin
    if aDim <> aDef then
      lString := lString + Utils.IntToStr(aDim);
    lString := lString + ';';
  end;

begin
  if EqualTo(aBorder) then
    exit nil;
  lString := '';
  AddDim(fLeft, aBorder.Left);
  AddDim(fRight, aBorder.Right);
  AddDim(fTop, aBorder.Top);
  AddDim(fBottom, aBorder.Bottom);
  while lString.EndsWith(';') do
    lString := lString.Substring(0, lString.Length - 1);
  exit lString;
end;

method ImgBorder.SetFromRelativeString(aString: String; aBorder: ImgBorder);
var
  lIdx: Integer;
  lElements: ImmutableList<String>;

  method SetDim(var aDim: Integer; aDef: Integer);
  begin
    aDim :=
      if lIdx >= length(lElements) then aDef
      else if String.IsNullOrEmpty(lElements[lIdx]) then aDef
      else Utils.StrToInt(lElements[lIdx]);
    inc(lIdx);
  end;

begin
  if aString = nil then
    aString := '';
  lElements := aString.Split(';');
  lIdx := 0;
  SetDim(var fLeft, aBorder.Left);
  SetDim(var fRight, aBorder.Right);
  SetDim(var fTop, aBorder.Top);
  SetDim(var fBottom, aBorder.Bottom);
end;

{$ENDREGION}

{$REGION ImgRectangle}

constructor ImgRectangle(aLeft: Integer := 0; aTop: Integer := 0; aWidth: Integer := 0; aHeight: Integer := 0);
begin
  inherited constructor;
  fLeft := aLeft;
  fTop := aTop;
  fWidth := aWidth;
  fHeight := aHeight;
end;

constructor ImgRectangle(aImgRect: ImgRectangle);
begin
  inherited constructor;
  Assign(aImgRect);
end;

constructor ImgRectangle(aFmtRect: FmtRectangle);
begin
  inherited constructor;
  Assign(aFmtRect);
end;

method ImgRectangle.GetRight: Integer;
begin
  result := fLeft + fWidth - 1;
end;

method ImgRectangle.SetRight(aRight: Integer);
begin
  fWidth := aRight - fLeft + 1;
end;

method ImgRectangle.GetBottom: Integer;
begin
  result := fTop + fHeight - 1;
end;

method ImgRectangle.SetBottom(aBottom: Integer);
begin
  fHeight := aBottom - fTop + 1;
end;

method ImgRectangle.ToString: String;
begin
  result := $"{fLeft}, {fTop}, {fWidth}, {fHeight}";
end;

method ImgRectangle.SetAsString(aStr: String);

  method SetField(var aField: Integer; aElements: ImmutableList<String>; aIdx: Integer);
  begin
    if 0 <= aIdx < aElements.Count then
      begin
        var lStr := aElements[aIdx].Trim;
        if not String.IsNullOrEmpty(lStr) then
          aField := Utils.StrToInt(lStr);
      end;
  end;

begin
  var lElements := aStr.Split(',');
  SetField(var fLeft, lElements, 0);
  SetField(var fTop, lElements, 1);
  SetField(var fWidth, lElements, 2);
  SetField(var fHeight, lElements, 3);
end;

method ImgRectangle.Clear;
begin
  fLeft := 0;
  fTop := 0;
  fWidth := 0;
  fHeight := 0;
end;

method ImgRectangle.Copy: not nullable ImgRectangle;
begin
  result := new ImgRectangle(self);
end;

method ImgRectangle.Assign(aRect: ImgRectangle);
begin
  fLeft := aRect.Left;
  fTop := aRect.Top;
  fWidth := aRect.Width;
  fHeight := aRect.Height;
end;

method ImgRectangle.Assign(aRect: FmtRectangle);
begin
  fLeft := aRect.Left;
  fTop := aRect.Top;
  fWidth := aRect.Width;
  fHeight := aRect.Height;
end;

method ImgRectangle.ToFmtRectangle: not nullable FmtRectangle;
begin
  result := new FmtRectangle(Left, Top, Width, Height);
end;

{$ENDREGION}

{$REGION ColorInfo}

constructor ColorInfo(aColor: ColorInfo);
begin
  inherited constructor;
  fARGB := aColor.fARGB;
end;

constructor ColorInfo(aARGB: ColorValue);
begin
  inherited constructor;
  fARGB := aARGB;
end;

constructor ColorInfo(aRed, aGreen, aBlue: Byte);
begin
  constructor (255, aRed, aGreen, aBlue);
end;

constructor ColorInfo(aAlpha, aRed, aGreen, aBlue: Byte);
begin
  inherited constructor;
  Alpha := aAlpha;
  Red := aRed;
  Green := aGreen;
  Blue := aBlue;
end;

constructor ColorInfo(aAlpha: Byte; aColor: ColorInfo);
begin
  constructor (aColor);
  Alpha := aAlpha;
end;

constructor ColorInfo(aStr: String);
begin
  inherited constructor;
  AsString := aStr;
end;

class method ColorInfo.Copy(aColor: ColorInfo): ColorInfo;
begin
  result :=
    if aColor = nil then nil
    else new ColorInfo(aColor);
end;

method ColorInfo.GetAlpha: Byte;
begin
  result := (fARGB shr AlphaShift) and $FF;
end;

method ColorInfo.GetRed: Byte;
begin
  result := (fARGB shr RedShift) and $FF;
end;

method ColorInfo.GetGreen: Byte;
begin
  result := (fARGB shr GreenShift) and $FF;
end;

method ColorInfo.GetBlue: Byte;
begin
  result := (fARGB shr BlueShift) and $FF;
end;

method ColorInfo.SetByte(aByte: Byte; aShift: Byte);
begin
  var lMask := not ($FF shl aShift);
  var lByte := aByte shl aShift;
  fARGB := (fARGB and lMask) or lByte;
end;

method ColorInfo.SetAlpha(aAlpha: Byte);
begin
  SetByte(aAlpha, AlphaShift);
end;

method ColorInfo.SetRed(aRed: Byte);
begin
  SetByte(aRed, RedShift);
end;

method ColorInfo.SetGreen(aGreen: Byte);
begin
  SetByte(aGreen, GreenShift);
end;

method ColorInfo.SetBlue(aBlue: Byte);
begin
  SetByte(aBlue, BlueShift);
end;

method ColorInfo.SetAsString(aStr: String);
begin
  fARGB := Convert.HexStringToUInt32(aStr);
  if aStr.Length <= 6 then
    Alpha := 255;
end;

method ColorInfo.EqualTo(aInfo: ColorInfo): Boolean;
begin
  if aInfo = nil then
    exit false;
  result := fARGB = aInfo.ARGB;
end;

method ColorInfo.ToString: String;
begin
  result :=
    if Alpha = 255 then Convert.ToHexString(fARGB and $00FFFFFF, 6)
    else Convert.ToHexString(fARGB, 8);
end;

method ColorInfo.ToHexString(aWithAlpha: Boolean := false): String;
begin
  result :=
    if aWithAlpha then Convert.ToHexString(fARGB, 8)
    else Convert.ToHexString(fARGB and $00FFFFFF, 6);
end;

{$ENDREGION}

{$REGION FontInfo}

constructor FontInfo(aName: String; aSize: Float; aStyle: String := '');
begin
  inherited constructor;
  fName := aName;
  fSize := aSize;
  SetStyle(aStyle);
end;

constructor FontInfo(aString: String);
begin
  inherited constructor;
  AsString := aString;
end;

constructor FontInfo(aFont: FontInfo);
begin
  constructor (aFont.Name, aFont.Size, aFont.Style);
end;

class method FontInfo.DefaultFont: FontInfo;
begin
  result := new FontInfo(nil, 0.0);
end;

class method FontInfo.StyleString(aBold, aItalic, aUnderline: Boolean): String;
begin
  result := '';
  if aBold then
    result := result + 'B';
  if aItalic then
    result := result + 'I';
  if aUnderline then
    result := result + 'U';
end;

class method FontInfo.Copy(aFont: FontInfo): FontInfo;
begin
  result :=
    if aFont = nil then nil
    else new FontInfo(aFont);
end;

method FontInfo.GetStyle: String;
begin
  result := StyleString(fBold, fItalic, fUnderline);
end;

method FontInfo.SetStyle(aStyle: String);
begin
  aStyle := aStyle.ToUpper;
  fBold := false;
  fItalic := false;
  fUnderline := false;
  for each lCh in aStyle do
    if lCh = 'B' then fBold := true
    else if lCh = 'I' then fItalic := true
    else if lCh = 'U' then fUnderline := true;
end;

method FontInfo.SetAsString(aString: String);
begin
  var lFont := aString.Split(';');
  fName :=
    if length(lFont) >= 1 then lFont[0]
    else '';
  fSize :=
    if length(lFont) >= 2 then Utils.StrToFlt(lFont[1])
    else 0.0;
  SetStyle(if length(lFont) >= 3 then lFont[2] else '');
end;

method FontInfo.ToString: String;
begin
  result := fName +';' + Utils.FltToStr(fSize) + ';' + GetStyle;
end;

method FontInfo.EqualTo(aInfo: FontInfo): Boolean;
begin
  result := AsString = aInfo.AsString;
end;

{$ENDREGION}

{$REGION ScaleMaker}

constructor ScaleMaker(aMin: Float; aMax: Float);
begin
  SetMinMaxPoints(aMin, aMax);
end;

method ScaleMaker.Calculate;
begin
  var lMinPoint := fMinPoint;
  var lMaxPoint := fMaxPoint;
  if lMinPoint = lMaxPoint then
    begin
      var lDiff := fExtra * lMinPoint;
      lMinPoint := lMinPoint - lDiff;
      lMaxPoint := lMaxPoint + lDiff;
    end;
  if lMinPoint = lMaxPoint {= 0.0} then
    begin
      lMinPoint := -1.0;
      lMaxPoint := +1.0;
    end;
  fRange := NiceNum(lMaxPoint - lMinPoint, false);
  fTickSpacing := NiceNum(fRange / (fMaxTicks - 1), true);
  fNiceMin := Math.Floor(lMinPoint / fTickSpacing) * fTickSpacing;
  fNiceMax := Math.Ceiling(lMaxPoint / fTickSpacing) * fTickSpacing;
end;

method ScaleMaker.NiceNum(aRange: Float; aRound: Boolean): Float;
begin
  var lExponent := Math.Floor(Math.log10(aRange));
  var lFraction := aRange / Math.Pow(10, lExponent);
  var lNiceFraction :=
    if aRound then
      if lFraction < 1.5 then 1
      else if lFraction < 3 then 2
      else if lFraction < 7 then 5
      else 10
    else
      if lFraction <= 1 then 1
      else if lFraction <= 2 then 2
      else if lFraction <= 5 then 5
      else 10;
  result := lNiceFraction * Math.Pow(10, lExponent);
end;

method ScaleMaker.SetMinMaxPoints(aMin: Float; aMax: Float);
begin
  fMinPoint := aMin;
  fMaxPoint := aMax;
  Calculate;
end;

method ScaleMaker.SetMinPoint(aMin: Float);
begin
  SetMinMaxPoints(aMin, fMaxPoint);
end;

method ScaleMaker.SetMaxPoint(aMax: Float);
begin
  SetMinMaxPoints(fMinPoint, aMax);
end;

method ScaleMaker.SetMaxTicks(aTicks: Integer);
begin
  fMaxTicks := aTicks;
  Calculate;
end;

{$ENDREGION}

{$REGION ChartPoint}

constructor ChartPoint(aX, aY: Float);
begin
  inherited constructor;
  fX := aX;
  fY := aY;
end;

{$ENDREGION}

{$REGION Map3to2D}

constructor Map3to2D;
begin
  inherited constructor;
  ResetRotation;
end;

constructor Map3to2D(aDefHorizontal: Float; aDefVertical: Float);
begin
  inherited constructor;
  fDefHorizontal := aDefHorizontal;
  fDefVertical := aDefVertical;
  ResetRotation;
end;

method Map3to2D.SetHorizontalRotation(aDegrees: Float);
begin
  SetRotation(aDegrees, VerticalRotation);
end;

method Map3to2D.SetVerticalRotation(aDegrees: Float);
begin
  SetRotation(HorizontalRotation, aDegrees);
end;

method Map3to2D.SetRotation(aHorizontal, aVertical: Float);
begin
  a := aHorizontal;
  b := aVertical;
  p1 := Math.Cos(a * pi180);
  p2 := Math.Sin(a * pi180);
  p3 := Math.Cos(b * pi180);
  p4 := p1 * Math.Sin(b * pi180);
  p5 := p2 * Math.Sin(b * pi180);
end;

method Map3to2D.ResetRotation;
begin
  SetRotation(fDefHorizontal, fDefVertical);
end;

method Map3to2D.ProjX(x, y, z: Float): Float;
begin
  result := y * p1 - x * p2;
end;

method Map3to2D.ProjY(x, y, z: Float): Float;
begin
  result := -x * p4 - y * p5 + z * p3;
end;

method Map3to2D.Proj(x, y, z: Float): ChartPoint;
begin
  result := new ChartPoint(ProjX(x, y, z), ProjY(x, y, z));
end;

{$ENDREGION}

end.
