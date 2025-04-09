// WinGraphics.pas is part of
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
// WinGraphics.pas implements DEXiWin charts used to display results of alternatives' evaluation
// and tabular aggregation functions.
// ----------

namespace DexiLibrary;

interface

 uses
  System.Drawing,
  System.Drawing.Drawing2D,
  System.Drawing.Imaging,
  System.Windows.Forms,
  RemObjects.Elements.RTL,
  DexiUtils;

type
  WinChartParameters = public extension class (DexiChartParameters)
  protected
    method GetBackgroundColor: Color;
    method SetBackgroundColor(aColor: Color);
    method GetAreaColor: Color;
    method SetAreaColor(aColor: Color);
    method GetNeutralColor: Color;
    method SetNeutralColor(aColor: Color);
    method GetUndefinedColor: Color;
    method SetUndefinedColor(aColor: Color);
    method GetAttFont: Font;
    method SetAttFont(aFont: Font);
    method GetAltFont: Font;
    method SetAltFont(aFont: Font);
    method GetValFont: Font;
    method SetValFont(aFont: Font);
  public
    property BackgroundColor: Color read GetBackgroundColor write SetBackgroundColor;
    property AreaColor: Color read GetAreaColor write SetAreaColor;
    property NeutralColor: Color read GetNeutralColor write SetNeutralColor;
    property UndefinedColor: Color read GetUndefinedColor write SetUndefinedColor;
    property AttFont: Font read GetAttFont write SetAttFont;
    property AltFont: Font read GetAltFont write SetAltFont;
    property ValFont: Font read GetValFont write SetValFont;
  end;

type
  Win3DChartParameters = public extension class (DexiFunct3DChartParameters)
  protected
    method GetBackgroundColor: Color;
    method SetBackgroundColor(aColor: Color);
    method GetAreaColor: Color;
    method SetAreaColor(aColor: Color);
    method GetAttFont: Font;
    method SetAttFont(aFont: Font);
    method GetValFont: Font;
    method SetValFont(aFont: Font);
  public
    property BackgroundColor: Color read GetBackgroundColor write SetBackgroundColor;
    property AreaColor: Color read GetAreaColor write SetAreaColor;
    property AttFont: Font read GetAttFont write SetAttFont;
    property ValFont: Font read GetValFont write SetValFont;
    property LinearColor: Color read Color.Red;
    property MultilinearColor: Color read Color.Green;
    property QQColor: Color read Color.Purple;
    property QPColor: Color read Color.Blue;
  end;

type
  WinChartDrawing = public class
  private
    fBorderPenData: PenData;
    fScalePenData: PenData;
    fGridPenData: PenData;
    fGoodPenData: PenData;
    fBadPenData: PenData;
    fNeutralPenData: PenData;
    fGoodBrushData: BrushData;
    fBadBrushData: BrushData;
    fNeutralBrushData: BrushData;
    fGoodBackgroundBrushData: BrushData;
    fBadBackgroundBrushData: BrushData;
    fNeutralBackgroundBrushData: BrushData;
    fConnectionPenData: PenData;
  public
    constructor;
    constructor (aModel: DexiModel);
    property BorderPenData: PenData read fBorderPenData write fBorderPenData;
    property ScalePenData: PenData read fScalePenData write fScalePenData;
    property GridPenData: PenData read fGridPenData write fGridPenData;
    property GoodPenData: PenData read fGoodPenData write fGoodPenData;
    property BadPenData: PenData read fBadPenData write fBadPenData;
    property NeutralPenData: PenData read fNeutralPenData write fNeutralPenData;
    property GoodBrushData: BrushData read fGoodBrushData write fGoodBrushData;
    property BadBrushData: BrushData read fBadBrushData write fBadBrushData;
    property NeutralBrushData: BrushData read fNeutralBrushData write fNeutralBrushData;
    property GoodBackgroundBrushData: BrushData read fGoodBackgroundBrushData write fGoodBackgroundBrushData;
    property BadBackgroundBrushData: BrushData read fBadBackgroundBrushData write fBadBackgroundBrushData;
    property NeutralBackgroundBrushData: BrushData read fNeutralBackgroundBrushData write fNeutralBackgroundBrushData;
    property ConnectionPenData: PenData read fConnectionPenData write fConnectionPenData;
  end;

type
  WinChart = public class
  private
    fWidth: Integer;
    fHeight: Integer;
    fBorder: ImgBorder;
    fGraphics: Graphics;
  protected
    const MinChartWidth = 150;
    const MinChartHeight = 150;
    const MinChartRectWidth = 100;
    const MinChartRectHeight = 100;
    const DefaultPalette = [
      // Excel
		  Color.FromArgb(153,153,255),
			Color.FromArgb(153,51,102),
			Color.FromArgb(255,255,128),
			Color.FromArgb(128,255,255),
			Color.FromArgb(102,0,102),
			Color.FromArgb(255,128,128),
			Color.FromArgb(0,102,204),
			Color.FromArgb(204,204,255),
			Color.FromArgb(0,0,128),
			Color.FromArgb(255,0,255),
			Color.FromArgb(255,255,0),
			Color.FromArgb(0,255,255),
			Color.FromArgb(128,0,128),
			Color.FromArgb(128,0,0),
			Color.FromArgb(0,128,128),
			Color.FromArgb(0,0,255),
      // BrightPastel
			Color.FromArgb(65, 140, 240),
			Color.FromArgb(252, 180, 65),
			Color.FromArgb(224, 64, 10),
			Color.FromArgb(5, 100, 146),
			Color.FromArgb(191, 191, 191),
			Color.FromArgb(26, 59, 105),
			Color.FromArgb(255, 227, 130),
			Color.FromArgb(18, 156, 221),
			Color.FromArgb(202, 107, 75),
			Color.FromArgb(0, 92, 219),
			Color.FromArgb(243, 210, 136),
			Color.FromArgb(80, 99, 129),
			Color.FromArgb(241, 185, 168),
			Color.FromArgb(224, 131, 10),
			Color.FromArgb(120, 147, 190)
    ];
    method AllocateResources; virtual; empty;
    method DisposeResources; virtual; empty;
    method Measure; virtual; empty;
    method MeasureWidth(aText: String; aFont: Font): Integer;
    method MeasureHeight(aText: String; aFont: Font): Integer;
    method DrawText(aText: String; aFont: Font; aX, aY: Integer; aHA: HorizontalAlignment := HorizontalAlignment.Left; aVA: HorizontalAlignment := HorizontalAlignment.Left);
    method DrawText(aText: String; aAngle: Float; aFont: Font; aX, aY: Integer; aHA: HorizontalAlignment := HorizontalAlignment.Left; aVA: HorizontalAlignment := HorizontalAlignment.Left);
  public
    constructor (aWidth, aHeight: Integer);
    property Graphics: Graphics read fGraphics write fGraphics;
    method Draw(aGraphics: Graphics); virtual;
    method DrawChart; virtual; empty;
    method MakeBitmap: Bitmap;
    method MakeBitmapData: array of Byte;
    method MakeMetafile: Metafile;
    method MakeMetafileData: array of Byte;
    property Width: Integer read fWidth;
    property Height: Integer read fHeight;
    property Border: ImgBorder read fBorder write fBorder;
    property Palette: array of Color := DefaultPalette;
  end;

type
  DexiEvalChart = public class (WinChart)
  private
    fModel: DexiModel;
    fParameters: DexiChartParameters;
    fAltOrder: IntArray;
    fDrawing: WinChartDrawing;
    fAttCount: Integer;
    fAltCount: Integer;
    fChartRect: Rectangle;
    fChartArea: Rectangle;
    fGridArea: Rectangle;
    fAttFont: Font;
    fAltFont: Font;
    fValFont: Font;
    fAttTextHeight: Integer;
    fAltTextHeight: Integer;
    fValTextHeight: Integer;
  protected
    method AllocateResources; override;
    method DisposeResources; override;
    method Measure; override;
    method CalculateAttTextWidth: Integer;
    method CalculateAltTextWidth: Integer;
    method DrawAreaBackground; virtual;
  public
    constructor (aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
    method ValuePen(aScale: DexiScale; aValue: Float): Pen;
    method ValueBrushData(aScale: DexiScale; aValue: Float): BrushData;
    method ValueBrush(aScale: DexiScale; aValue: Float): Brush;
    method ValueBackgroundBrush(aScale: DexiScale; aValue: Float): Brush;
    method ValueInfo(aAlt: Integer; aAtt: DexiAttribute): AltValueInfo;
    method TransparentColor(aColor: Color): Color;
    method PointColor(aPoint: ScatterPoint): Color;
    method DrawChart; override;
    property Model: DexiModel read fModel;
    property Parameters: DexiChartParameters read fParameters;
    property AttCount: Integer read fAttCount;
    property AltCount: Integer read fAltCount;
    property AltOrder: IntArray read fAltOrder;

    property ChartRect: Rectangle read fChartRect;
    property ChartArea: Rectangle read fChartArea write fChartArea;
    property GridArea: Rectangle read fGridArea write fGridArea;
    property AttFont: Font read fAttFont;
    property AltFont: Font read fAltFont;
    property ValFont: Font read fValFont;
    property AttTextWidth: Integer := CalculateAttTextWidth; lazy;
    property AltTextWidth: Integer := CalculateAltTextWidth; lazy;
    property AttTextHeight: Integer read fAttTextHeight;
    property AltTextHeight: Integer read fAltTextHeight;
    property ValTextHeight: Integer read fValTextHeight;
    property BackgroundColor: Color read Parameters.BackgroundColor;
    property AreaColor: Color read Parameters.AreaColor;
    property LineWidth: Float read Parameters.LineWidth;
    property TransparentAlpha: Byte read Parameters.TransparentAlpha;
    property AltGap: Integer read Parameters.AltGap;
    property AttGap: Integer read Parameters.AttGap;
    property ScaleGap: Integer read Parameters.ScaleGap;
    property ValGap: Integer read Parameters.ValGap;
    property LineGap: Integer read Parameters.LineGap;
    property TickLength: Integer read Parameters.TickLength;
    property LegendWidth: Integer read Parameters.LegendWidth;
    property LegendHeight: Integer read Parameters.LegendHeight;
    property LegendGap: Integer read Parameters.LegendGap;
    property MinSideGap: Integer read Parameters.MinSideGap;
    property BarExtent: Float read Parameters.BarExtent;
    property Drawing: WinChartDrawing read fDrawing;
  end;

type
  DexiBarChart = public class (DexiEvalChart)
  private
    fAttribute: DexiAttribute;
    fBarHeight: Integer;
    fBarBarHeight: Integer;
    fValueRange: DexiAltValueRange;
  protected
    method AllocateResources; override;
    method Measure; override;
    method BarY(aIdx: Integer; aPos: HorizontalAlignment := HorizontalAlignment.Left): Integer;
    method DrawAltNames;
    method DrawAttName;
    method DrawChartArea;
    method DrawScale;
    method DrawValue(aValue: Float; aBarY: Integer);
    method DrawValue(aValue: Distribution; aBarY: Integer);
    method DrawValues;
  public
    constructor (aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
    method DrawChart; override;
  end;

type
  DexiScatterChart = public class (DexiEvalChart)
  private
    fAttributeX: DexiAttribute;
    fAttributeY: DexiAttribute;
    fValTextWidth: Integer;
    fValueRangeX: DexiAltValueRange;
    fValueRangeY: DexiAltValueRange;
    fPoints: ScatterPoints;
  protected
    method ScaleYWidth: Integer;
    method AllocateResources; override;
    method Measure; override;
    method GridX(aValue: Float): Integer;
    method GridY(aValue: Float): Integer;
    method DrawAttXName;
    method DrawAttYName;
    method DrawScaleX;
    method DrawScaleY;
    method DrawChartArea;
    method DrawAlternatives;
    method DrawPoints;
    method DrawExtent(aAlt: Integer; aValueInfoX, aValueInfoY: AltValueInfo);
  public
    constructor (aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
    method DrawChart; override;
    property PointRadius: Integer read Parameters.ScatterPointRadius;
  end;

type
  AxisPoint = public class
  private
  public
    constructor (aCoord: Point; aBrushData: BrushData; aText: String := '');
    property Coord: Point;
    property Brush: BrushData;
    property Text: String;
  end;

type
  AxisPoints = public class
  private
    fPoints: List<AxisPoint>;
  public
    constructor;
    method AddPoint(aPoint: AxisPoint);
    method AddPoint(aCoord: Point; aBrushData: BrushData; aText: String := '');
    property Count: Integer read fPoints.Count;
    property Points: ImmutableList<AxisPoint> read fPoints;
  end;

type
  DexiRadarChart = public class (DexiEvalChart)
  private
    fAltSubset: IntArray;
    fGridCenter: Point;
    fGridDiameter: Integer;
    fGridRadius: Integer;
    fValueRanges: List<DexiAltValueRange>;
    fChartPoints: List<Point>;
    fAltPoints: List<AxisPoints>;
  protected
    method Measure; override;
    method RadarPoint(aIdx: Integer; aValue: Float := 1.0): Point;
    method ValuePoint(aIdx: Integer; aValue: Float): Point;
    method AlternativeColor(aAlt: Integer): Color;
    method DrawAreaBackground; override;
    method DrawAltNames;
    method DrawRadar;
    method DrawGrid;
    method DrawAttNames;
    method PrepareValue(aValue: Float; aAtt: Integer);
    method PrepareValue(aValue: Distribution; aAtt: Integer);
    method PrepareValues(aAlt, aAtt: Integer);
    method PrepareValues(aAlt: Integer);
    method DrawValues(aAlt, aAtt: Integer);
    method DrawValues(aAlt: Integer);
    method DrawConnection(aAlt: Integer; aFrom, aTo: AxisPoints);
    method DrawConnections(aAlt: Integer);
    method DrawValues;
  public
    constructor (aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil; aAltSubset: IntArray := nil);
    method DrawChart; override;
    property AltSubset: IntArray read fAltSubset;
    property SubCount: Integer read length(fAltSubset);
    property Single: Boolean read SubCount <= 1;
    property PointRadius: Integer read Parameters.RadarPointRadius;
  end;

type
  DexiRadarGrid = public class (DexiEvalChart)
  private
    fGridWidth: Integer;
    fGridHeight: Integer;
  protected
  public
    constructor (aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
    property GridX: Integer read Parameters.GridX;
    property GridY: Integer read Parameters.GridY;
    method DrawChart; override;
  end;

type
  DexiAbaconChart = public class (DexiEvalChart)
  private
    fLineGap: Integer;
    fValueRanges: List<DexiAltValueRange>;
    fAltPoints: List<AxisPoints>;
  protected
    method AllocateResources; override;
    method Measure; override;
    method AttY(aIdx: Integer): Integer;
    method AlternativeColor(aAlt: Integer): Color;
    method DrawChartArea;
    method DrawAttNames;
    method DrawAltNames;
    method DrawGrid;
    method DrawScale(aIdx: Integer; aTicks: Boolean; aValues: Boolean);
    method DrawScales(aTicks: Boolean; aValues: Boolean);
    method PrepareValue(aValue: Float; aAtt: Integer);
    method PrepareValue(aValue: Distribution; aAtt: Integer);
    method PrepareValues(aAlt, aAtt: Integer);
    method PrepareValues(aAlt: Integer);
    method DrawValues(aAlt, aAtt: Integer);
    method DrawValues(aAlt: Integer);
    method DrawConnection(aIdx, aAlt: Integer; aFrom, aTo: AxisPoints);
    method DrawConnections(aIdx, aAlt: Integer);
    method DrawValues;
  public
    constructor (aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
    method DrawChart; override;
    property PointRadius: Integer read Parameters.AbaconPointRadius;
  end;

type
  MapRangeToRectangle = public class (Map3to2D)
  private
    fRect: Rectangle;
  protected
    // default is unit rectangle
    fLowX := 0.0;
    fHighX := 1.0;
    fLowY := 0.0;
    fHighY := 1.0;
    fLowZ := 0.0;
    fHighZ := 1.0;
    fMinX: Float;
    fMaxX: Float;
    fMinY: Float;
    fMaxY: Float;
    method SetHorizontalRotation(aDegrees: Float); override;
    method SetVerticalRotation(aDegrees: Float); override;
    method ReMap;
    method SetRectangle(aRect: Rectangle);
  public
    constructor (aRect: Rectangle);
    constructor (aRect: Rectangle; aDefHorizontal: Float; aDefVertical: Float);
    method SetRotation(aHorizontal, aVertical: Float); override;
    method ResetRotation; override;
    method RectX(x, y, z: Float): Integer;
    method RectY(x, y, z: Float): Integer;
    method RectProj(x, y, z: Float): ChartPoint;
    method SetXRange(aFrom, aTo: Float);
    method SetYRange(aFrom, aTo: Float);
    method SetZRange(aFrom, aTo: Float);
    property Rect: Rectangle read fRect write SetRectangle;
    property LowX: Float read fLowX;
    property HighX: Float read fHighX;
    property LowY: Float read fLowY;
    property HighY: Float read fHighY;
    property LowZ: Float read fLowZ;
    property HighZ: Float read fHighZ;
  end;

type
  FunctToDraw3D = public block (aArgs: FltArray): Float;

type
  DexiFunct3DChart = public class (WinChart)
  private
    fModel: DexiModel;
    fDrawing: WinChartDrawing;
    fAttribute: DexiAttribute;
    fFunct: DexiTabularFunction;
    fParameters: DexiFunct3DChartParameters;
    fMap3D: MapRangeToRectangle;
    fChartRect: Rectangle;
    fChartArea: Rectangle;
    fGridArea: Rectangle;
    fAttFont: Font;
    fValFont: Font;
    fAttTextHeight: Integer;
    fValTextHeight: Integer;
    fML: DexiMultilinearModel;
    fQQ1: DexiQQ1Model;
    fQQ2: DexiQQ2Model;
  protected
    method GetML: DexiMultilinearModel;
    method GetQQ1: DexiQQ1Model;
    method GetQQ2: DexiQQ2Model;
    method ProjX(x, y, z: Float): Integer;
    method ProjY(x, y, z: Float): Integer;
    method ProjPoint(x, y, z: Float): Point;
    method DrawLine(aPoint1, aPoint2: Point; aPen: Pen);
    method DrawLine(ax1, ay1, az1: Float; ax2, ay2, az2: Float; aPen: Pen);
    method MapAndDrawLine(ax1, ay1, az1: Float; ax2, ay2, az2: Float; aPen: Pen);
    method LinearApproximation(aArgs: FltArray): Float;
    method MultilinearInterpolation(aArgs: FltArray): Float;
    method EvaluateFunct(aFunct: FunctToDraw3D; ax1, ax2: Float): Float;
    method EvaluateModel(aModel: DexiQModel; aClass: Integer; ax1, ax2: Float): Float;
    method DrawFunct(aFunct: FunctToDraw3D; ax1f, ax1t, ax2f, ax2t: Float; aStep: Float; aPenMain, aPenSide: Pen);
    method DrawModelPoint(aModel: DexiQModel; aArgs: IntArray; aClass: Integer; aPenBorder, aPenInternal: Pen);
    method RevIndex(aIdx, aSize: Integer; aRev: Boolean): Integer;
    method RevIndex(aIdx: Integer; aDimIdx: Integer): Integer;
    method RevValue(aValue: Float; aSize: Integer; aRev: Boolean): Float;
    method RevValue(aValue: Float; aDimIdx: Integer): Float;
    method FromDexiToDrawCoordinates(aValue: Float; aSize: Integer; aRev: Boolean): Float;
    method FromDexiToDrawCoordinates(aValue: Float; aDimIdx: Integer): Float;
    method AllocateResources; override;
    method DisposeResources; override;
    method MakeMap: MapRangeToRectangle;
    method Measure; override;
    method CalculateAttValTextWidth: Integer;
    method DrawChartArea;
    method DrawAttNames;
    method DrawGrid;
    method DrawScales;
    method DrawPoints(aPoints: Boolean);
    method DrawConnection(a1f, a1t, a2f, a2t: Integer);
    method DrawConnections;
    method DrawLinearApproximation;
    method DrawMultilinearInterpolation;
    method DrawQ(aModel: DexiQModel; aPenBorder, aPenInternal: Pen);
    method DrawQQ1;
    method DrawQQ2;
    method DrawOverlays;
    method DrawFunct;
    property AttScale: DexiDiscreteScale read fAttribute.Scale as DexiDiscreteScale;
  public
    constructor (aWidth, aHeight: Integer;
      aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction; aParameters: DexiFunct3DChartParameters);
    method DrawChart; override;
    property Model: DexiModel read fModel;
    property Parameters: DexiFunct3DChartParameters read fParameters;
    property ML: DexiMultilinearModel read GetML;
    property QQ1: DexiQQ1Model read GetQQ1;
    property QQ2: DexiQQ2Model read GetQQ2;
    property ChartRect: Rectangle read fChartRect;
    property ChartArea: Rectangle read fChartArea write fChartArea;
    property GridArea: Rectangle read fGridArea write fGridArea;
    property AttFont: Font read fAttFont;
    property ValFont: Font read fValFont;
    property AttValTextWidth: Integer := CalculateAttValTextWidth; lazy;
    property AttTextHeight: Integer read fAttTextHeight;
    property ValTextHeight: Integer read fValTextHeight;
    property BackgroundColor: Color read Parameters.BackgroundColor;
    property AreaColor: Color read Parameters.AreaColor;
    property LineWidth: Float read Parameters.LineWidth;
    property AttGap: Integer read Parameters.AttGap;
    property ScaleGap: Integer read Parameters.ScaleGap;
    property ValGap: Integer read Parameters.ValGap;
    property TickLength: Integer read Parameters.TickLength;
    property PointRadius: Integer read Parameters.PointRadius;
    property PillarWidth: Integer read Parameters.PillarWidth;
    property Drawing: WinChartDrawing read fDrawing;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION WinChartParameters}

method WinChartParameters.GetBackgroundColor: Color;
begin
  var lData := new ColorData(BackgroundColorInfo);
  result := lData.NewColor;
end;

method WinChartParameters.SetBackgroundColor(aColor: Color);
begin
  BackgroundColorInfo := new ColorData(aColor);
end;

method WinChartParameters.GetAreaColor: Color;
begin
  var lData := new ColorData(AreaColorInfo);
  result := lData.NewColor;
end;

method WinChartParameters.SetAreaColor(aColor: Color);
begin
  AreaColorInfo := new ColorData(aColor);
end;

method WinChartParameters.GetNeutralColor: Color;
begin
  var lData := new ColorData(LightNeutralColorInfo);
  result := lData.NewColor;
end;

method WinChartParameters.SetNeutralColor(aColor: Color);
begin
  LightNeutralColorInfo := new ColorData(aColor);
end;

method WinChartParameters.GetUndefinedColor: Color;
begin
  var lData := new ColorData(UndefColorInfo);
  result := lData.NewColor;
end;

method WinChartParameters.SetUndefinedColor(aColor: Color);
begin
  UndefColorInfo := new ColorData(aColor);
end;

method WinChartParameters.GetAttFont: Font;
begin
  var lData := new FontData(AttFontInfo);
  result := lData.NewFont;
end;

method WinChartParameters.SetAttFont(aFont: Font);
begin
  AttFontInfo := new FontData(aFont);
end;

method WinChartParameters.GetAltFont: Font;
begin
  var lData := new FontData(AltFontInfo);
  result := lData.NewFont;
end;

method WinChartParameters.SetAltFont(aFont: Font);
begin
  AltFontInfo := new FontData(aFont);
end;

method WinChartParameters.GetValFont: Font;
begin
  var lData := new FontData(ValFontInfo);
  result := lData.NewFont;
end;

method WinChartParameters.SetValFont(aFont: Font);
begin
  ValFontInfo := new FontData(aFont);
end;

{$ENDREGION}

{$REGION Win3DChartParameters}

method Win3DChartParameters.GetBackgroundColor: Color;
begin
  var lData := new ColorData(BackgroundColorInfo);
  result := lData.NewColor;
end;

method Win3DChartParameters.SetBackgroundColor(aColor: Color);
begin
  BackgroundColorInfo := new ColorData(aColor);
end;

method Win3DChartParameters.GetAreaColor: Color;
begin
  var lData := new ColorData(AreaColorInfo);
  result := lData.NewColor;
end;

method Win3DChartParameters.SetAreaColor(aColor: Color);
begin
  AreaColorInfo := new ColorData(aColor);
end;

method Win3DChartParameters.GetAttFont: Font;
begin
  var lData := new FontData(AttFontInfo);
  result := lData.NewFont;
end;

method Win3DChartParameters.SetAttFont(aFont: Font);
begin
  AttFontInfo := new FontData(aFont);
end;

method Win3DChartParameters.GetValFont: Font;
begin
  var lData := new FontData(ValFontInfo);
  result := lData.NewFont;
end;

method Win3DChartParameters.SetValFont(aFont: Font);
begin
  ValFontInfo := new FontData(aFont);
end;

{$ENDREGION}

{$REGION WinChart}

constructor WinChartDrawing;
begin
  fBorderPenData := new PenData(Color.Black, 2);
  fScalePenData := new PenData(Color.Black);
  fGridPenData := new PenData(Color.LightGray);
  fGoodPenData := new PenData(Color.Green, 2);
  fBadPenData := new PenData(Color.Red, 2);
  fNeutralPenData := new PenData(Color.DarkGray, 2);
  fGoodBrushData := new BrushData(Color.Green);
  fBadBrushData := new BrushData(Color.Red);
  fNeutralBrushData := new BrushData(Color.DarkGray);
  fGoodBackgroundBrushData := new BrushData(Color.FromArgb(50, Color.Green));
  fBadBackgroundBrushData := new BrushData(Color.FromArgb(50, Color.Red));
  fNeutralBackgroundBrushData := new BrushData(Color.LightGray);
  fConnectionPenData := new PenData(Color.Black, 1);
end;

constructor WinChartDrawing(aModel: DexiModel);
require
  aModel <> nil;
begin
  var lSettings := aModel.Settings;
  var lParameters := aModel.ChartParameters;
  fBorderPenData := new PenData(Color.Black, 2);
  fScalePenData := new PenData(Color.Black);
  fGridPenData := new PenData(Color.LightGray);
  fGoodPenData := new PenData(lSettings.GoodColor, 2);
  fBadPenData := new PenData(lSettings.BadColor, 2);
  fNeutralPenData := new PenData(lSettings.NeutralColor, 2);
  fGoodBrushData := new BrushData(lSettings.GoodColor);
  fBadBrushData := new BrushData(lSettings.BadColor);
  fNeutralBrushData := new BrushData(lParameters.LightNeutralColorInfo);
  fGoodBackgroundBrushData := new BrushData(new ColorInfo(50, lSettings.GoodColor));
  fBadBackgroundBrushData := new BrushData(new ColorInfo(50, lSettings.BadColor));
  fNeutralBackgroundBrushData := new BrushData(new ColorInfo(50, lSettings.NeutralColor));
  fConnectionPenData := new PenData(Color.Black, 1);
end;

{$ENDREGION}

{$REGION WinChart}

constructor WinChart(aWidth, aHeight: Integer);
begin
  inherited constructor;
  fWidth := Math.Max(aWidth, MinChartWidth);
  fHeight := Math.Max(aHeight, MinChartHeight);
  fBorder := new ImgBorder(10, 10, 10, 10);
end;

method WinChart.MeasureWidth(aText: String; aFont: Font): Integer;
begin
  if String.IsNullOrEmpty(aText) or (fGraphics = nil) then
    result := 0
  else
    using fmt := StringFormat.GenericTypographic do
      begin
        var lMeasure := fGraphics.MeasureString(aText, aFont, new SizeF(high(Integer), high(Integer)), fmt);
        result := Utils.RoundUp(lMeasure.Width);
      end;
end;

method WinChart.MeasureHeight(aText: String; aFont: Font): Integer;
begin
  if String.IsNullOrEmpty(aText) or (fGraphics = nil) then
    result := 0
  else
    using fmt := StringFormat.GenericTypographic do
      begin
        var lMeasure := fGraphics.MeasureString(aText, aFont, new SizeF(high(Integer), high(Integer)), fmt);
        result := Utils.RoundUp(lMeasure.Height);
      end;
end;

method WinChart.DrawText(aText: String; aFont: Font; aX, aY: Integer; aHA: HorizontalAlignment := HorizontalAlignment.Left; aVA: HorizontalAlignment := HorizontalAlignment.Left);
begin
  var lWidth :=  MeasureWidth(aText, aFont);
  var lHeight :=  MeasureHeight(aText, aFont);
  var lRect := new Rectangle(aX, aY, lWidth, lHeight);
  if aHA = HorizontalAlignment.Center then
    lRect.X := lRect.X - lWidth div 2
  else if aHA = HorizontalAlignment.Right then
    lRect.X := lRect.X - lWidth;
  if aVA = HorizontalAlignment.Center then
    lRect.Y := lRect.Y - lHeight div 2
  else if aVA = HorizontalAlignment.Right then
    lRect.Y := lRect.Y - lHeight;
  using fmt := StringFormat.GenericTypographic do
    begin
      fmt.LineAlignment := StringAlignment.Center;
      fGraphics.DrawString(aText, aFont, Brushes.Black, lRect, fmt);
    end;
end;

method WinChart.DrawText(aText: String; aAngle: Float; aFont: Font; aX, aY: Integer; aHA: HorizontalAlignment := HorizontalAlignment.Left; aVA: HorizontalAlignment := HorizontalAlignment.Left);
begin
//  fGraphics.DrawEllipse(Pens.Blue, new Rectangle(aX - 4, aY - 4, 8, 8));
  var lWidth :=  MeasureWidth(aText, aFont);
  var lHeight :=  MeasureHeight(aText, aFont);
  var lRect := new Rectangle(aX, aY, lWidth, lHeight);
  if aHA = HorizontalAlignment.Center then
    lRect.X := lRect.X - lWidth div 2
  else if aHA = HorizontalAlignment.Right then
    lRect.X := lRect.X - lWidth;
  if aVA = HorizontalAlignment.Center then
    lRect.Y := lRect.Y - lHeight div 2
  else if aVA = HorizontalAlignment.Right then
    lRect.Y := lRect.Y - lHeight;
//  fGraphics.DrawRectangle(Pens.Black, lRect);
  fGraphics.TranslateTransform(aX, aY);
  fGraphics.RotateTransform(aAngle);
  fGraphics.TranslateTransform(-aX, -aY);
//  fGraphics.DrawRectangle(Pens.Red, lRect);
  using fmt := StringFormat.GenericTypographic do
    begin
      fmt.LineAlignment := StringAlignment.Center;
      fGraphics.DrawString(aText, aFont, Brushes.Black, lRect, fmt);
    end;
  fGraphics.ResetTransform;
end;

method WinChart.Draw(aGraphics: Graphics);
require
  aGraphics <> nil;
begin
  fGraphics := aGraphics;
  AllocateResources;
  Measure;
  DrawChart;
  DisposeResources;
end;

method WinChart.MakeBitmap: Bitmap;
begin
   result := new Bitmap(fWidth, fHeight);
   using lGraphics := Graphics.FromImage(result) do
      Draw(lGraphics);
end;

method WinChart.MakeBitmapData: array of Byte;
begin
  using lBitmap := MakeBitmap do
  using lStream := new MemoryStream do
   begin
     lBitmap.Save(lStream, ImageFormat.Png);
     result := lStream.ToArray;
   end;
end;

method WinChart.MakeMetafile: Metafile;
begin
   result := RptImagePage.NewMetafile(new Rectangle(0, 0, fWidth, fHeight));
   using lGraphics := Graphics.FromImage(result) do
      Draw(lGraphics);
end;

method WinChart.MakeMetafileData: array of Byte;
begin
   using lStream := new MemoryStream do
     begin
       using lMetafile := RptImagePage.NewMetafile(new Rectangle(0, 0, fWidth, fHeight), lStream) do
       using lGraphics := Graphics.FromImage(lMetaFile) do
         Draw(lGraphics);
       result := lStream.ToArray;
     end;
end;

{$ENDREGION}

{$REGION DexiEvalChart}

constructor DexiEvalChart(aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
begin
  inherited constructor (aWidth, aHeight);
  fModel := aModel;
  fParameters := aParameters;
  fDrawing := new WinChartDrawing(fModel);
  fAttCount := fParameters.AttCount;
  fAltCount := fModel.AltCount;
  fAltOrder :=
    if aAltOrder = nil then Utils.RangeArray(fAltCount, 0)
    else aAltOrder;
end;

method DexiEvalChart.AllocateResources;
begin
  inherited AllocateResources;
  fAttFont := fParameters.AttFont;
  fAltFont := fParameters.AltFont;
  fValFont := fParameters.ValFont;
end;

method DexiEvalChart.DisposeResources;

  method DisposeOf(var aFont: Font);
  begin
    if aFont = nil then
      exit;
    aFont.Dispose;
    aFont := nil;
  end;

begin
  DisposeOf(var fAttFont);
  DisposeOf(var fAltFont);
  DisposeOf(var fValFont);
  inherited DisposeResources;
end;

method DexiEvalChart.Measure;
const
  MeasureText = 'Tj';
begin
  inherited Measure;
  fChartRect := new Rectangle(Border.Left, Border.Top, Width - Border.Left - Border.Right, Height - Border.Top - Border.Bottom);
  if fChartRect.Width < MinChartRectWidth then
    fChartRect.Width := MinChartRectWidth;
  if fChartRect.Height < MinChartRectHeight then
    fChartRect.Height := MinChartRectHeight;
  fChartArea := fChartRect;
  fGridArea := fChartArea;
  fAttTextHeight := MeasureHeight(MeasureText, AttFont);
  fAltTextHeight := MeasureHeight(MeasureText, AltFont);
  fValTextHeight := MeasureHeight(MeasureText, ValFont);
end;

method DexiEvalChart.CalculateAttTextWidth: Integer;
begin
  result := 0;
  for i := 0 to fParameters.AttCount - 1 do
    result := Math.Max(result, MeasureWidth(fParameters.SelectedAttributes[i].Name, AttFont));
end;

method DexiEvalChart.CalculateAltTextWidth: Integer;
begin
  result := 0;
  for each lAlt in AltOrder do
    if fParameters.IsSelected(lAlt) then
      result := Math.Max(result, MeasureWidth(Model.AltNames[lAlt].Name, AltFont));
end;

method DexiEvalChart.ValuePen(aScale: DexiScale; aValue: Float): Pen;
begin
  result :=
    if aScale.IsBad(aValue) then Drawing.BadPenData.NewPen
    else if aScale.IsGood(aValue) then Drawing.GoodPenData.Newpen
    else Drawing.NeutralPenData.NewPen;
end;

method DexiEvalChart.ValueBrushData(aScale: DexiScale; aValue: Float): BrushData;
begin
  result :=
    if aScale.IsBad(aValue) then Drawing.BadBrushData
    else if aScale.IsGood(aValue) then Drawing.GoodBrushData
    else Drawing.NeutralBrushData;
end;

method DexiEvalChart.ValueBrush(aScale: DexiScale; aValue: Float): Brush;
begin
  result :=
    if aScale.IsBad(aValue) then Drawing.BadBrushData.NewBrush
    else if aScale.IsGood(aValue) then Drawing.GoodBrushData.NewBrush
    else Drawing.NeutralBrushData.NewBrush;
end;

method DexiEvalChart.ValueBackgroundBrush(aScale: DexiScale; aValue: Float): Brush;
begin
  result :=
    if aScale.IsBad(aValue) then Drawing.BadBackgroundBrushData.NewBrush
    else if aScale.IsGood(aValue) then Drawing.GoodBackgroundBrushData.NewBrush
    else Drawing.NeutralBackgroundBrushData.NewBrush;
end;

method DexiEvalChart.ValueInfo(aAlt: Integer; aAtt: DexiAttribute): AltValueInfo;
begin
  result := nil;
  if aAtt:Scale = nil then
    exit;
  var lValue := Model.AltValue[aAlt, aAtt];
  if not DexiValue.ValueIsDefined(lValue) then
    exit;
  result :=
    if aAtt.Scale.IsContinuous then new AltValueInfo(lValue.AsFloat)
    else new AltValueInfo(lValue.AsDistribution, aAtt.Scale.Count);
end;

method DexiEvalChart.TransparentColor(aColor: Color): Color;
begin
  result := Color.FromArgb(TransparentAlpha, aColor.R, aColor.G, aColor.B);
end;

method DexiEvalChart.PointColor(aPoint: ScatterPoint): Color;
begin
  result := Color.Black;
  var lFirst := Model:First;
  if (aPoint = nil) or (aPoint.Alternatives.Count = 0) or (lFirst = nil) then
    exit;
  var lNone := 0;
  var lBad := 0;
  var lNeutral := 0;
  var lGood := 0;
  var lMixed := 0;
  for each lAlt in aPoint.Alternatives do
    begin
      var lValue := Model.AltValue[lAlt.Alternative, lFirst];
      var lClass :=
        if lFirst.Scale = nil then ValueCategoryType.None
        else lFirst.Scale.ValueCategory(lValue);
      case lClass of
        ValueCategoryType.None:    inc(lNone);
        ValueCategoryType.Bad:     inc(lBad);
        ValueCategoryType.Neutral: inc(lNeutral);
        ValueCategoryType.Good:    inc(lGood);
        ValueCategoryType.Mixed:   inc(lMixed);
      end;
    end;
  result := GraphicsUtils.MixColors([
      Color.Black,
      Color.FromArgb(Model.Settings.BadColor.ARGB),
      Color.LightGray,
      Color.FromArgb(Model.Settings.GoodColor.ARGB),
      Color.Blue
    ],
    [Float(lNone), lBad, lNeutral, lGood, lMixed]);
end;

method DexiEvalChart.DrawAreaBackground;
begin
  using lBrush := new SolidBrush(AreaColor) do
    Graphics.FillRectangle(lBrush, fChartArea);
end;

method DexiEvalChart.DrawChart;
begin
  inherited DrawChart;
  using lBrush := new SolidBrush(BackgroundColor) do
    Graphics.FillRectangle(lBrush, 0, 0, Width, Height);
  DrawAreaBackground;
end;

{$ENDREGION}

{$REGION DexiBarChart}

constructor DexiBarChart(aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
begin
  inherited constructor (aWidth, aHeight, aModel, aParameters, aAltOrder);
  fAttribute :=
    if aParameters.AttCount <= 0 then Model.First
    else aParameters.SelectedAttributes[0];
end;

method DexiBarChart.BarY(aIdx: Integer; aPos: HorizontalAlignment := HorizontalAlignment.Left): Integer;
begin
  result := ChartRect.Y + aIdx * fBarHeight;
  if aPos = HorizontalAlignment.Center then
    result := result + fBarHeight div 2
  else if aPos = HorizontalAlignment.Right then
    result := result + fBarHeight;
end;

method DexiBarChart.AllocateResources;
begin
  inherited AllocateResources;
  fValueRange := new DexiAltValueRange(fAttribute, Model);
end;

method DexiBarChart.Measure;
begin
  inherited Measure;
  AltTextWidth := Math.Min(CalculateAltTextWidth, ChartRect.Width div 2 - AltGap);
  var lAllBarsHeight := ChartRect.Height - (AttTextHeight + ValTextHeight + ScaleGap + ValGap + AttGap);
  fBarHeight := Math.Max(4, lAllBarsHeight div Math.Max(1, AltCount));
  fBarBarHeight := Utils.RoundUp(BarExtent * fBarHeight);
  var lLeftOffset := AltTextWidth + AltGap + ScaleGap;
  var lRadiusOffset := fBarBarHeight div 2 + ValGap;
  var lBottomOffset := AttTextHeight + ValTextHeight + ScaleGap + ValGap + AttGap;
  ChartArea := new Rectangle(ChartRect.X + lLeftOffset, ChartRect.Y, ChartRect.Width - lLeftOffset, ChartRect.Height - lBottomOffset);
  GridArea := new Rectangle(ChartArea.X + lRadiusOffset, ChartArea.Y, ChartArea.Width - 2 * lRadiusOffset, ChartArea.Height);
end;

method DexiBarChart.DrawAltNames;
begin
  var lBar := 0;
  for each lAlt in AltOrder do
    if Parameters.IsSelected(lAlt) then
      begin
        var lName := Model.AltNames[lAlt].Name;
        DrawText(lName, AltFont, ChartRect.X + AltTextWidth, BarY(lBar, HorizontalAlignment.Center),
          HorizontalAlignment.Right, HorizontalAlignment.Center);
        inc(lBar);
      end;
end;

method DexiBarChart.DrawAttName;
begin
  DrawText(fAttribute.Name, AttFont,
    ChartArea.X + ChartArea.Width div 2,
    ChartArea.Bottom + ScaleGap + ValGap + ValTextHeight,
    HorizontalAlignment.Center, HorizontalAlignment.Left);
end;

method DexiBarChart.DrawChartArea;
begin
  using lPen := Drawing.BorderPenData.NewPen do
    Graphics.DrawRectangle(lPen, ChartArea);
end;

method DexiBarChart.DrawScale;
begin
  var lErrMsg :=
    if fAttribute.Scale = nil then DexiString.CUndefinedScale
    else if not fValueRange.Defined then DexiString.CUndefinedScaleBorders
    else nil;
  if lErrMsg <> nil then
    begin
      DrawText(lErrMsg, ValFont, ChartArea.X + ChartArea.Width div 2, ChartArea.Bottom + ScaleGap,
        HorizontalAlignment.Center, HorizontalAlignment.Left);
      exit;
    end;
  var lXmin := GridArea.X;
  var lXmax := GridArea.Right;
  var lY := GridArea.Bottom;
  for i := 0 to fValueRange.TickCount - 1 do
    using lScalePen := Drawing.ScalePenData.NewPen do
    using lGridPen := Drawing.GridPenData.NewPen do
      begin
        var lValue := fValueRange.MinValue + i * fValueRange.TickSpacing;
        var lX := Math.Round(Utils.LinMap(lValue, fValueRange.MinValue, fValueRange.MaxValue, lXmin, lXmax));
        Graphics.DrawLine(lScalePen, lX, lY, lX, lY + ScaleGap);
        DrawText(fValueRange.Ticks[i], ValFont, lX, lY + ScaleGap, HorizontalAlignment.Center, HorizontalAlignment.Left);
        Graphics.DrawLine(lGridPen, lX, GridArea.Top, lX, lY);
      end;
end;

method DexiBarChart.DrawValue(aValue: Float; aBarY: Integer);
begin
  if (fValueRange = nil) or not fValueRange.Defined then
    exit;
  var lXmin := GridArea.X;
  var lXmax := GridArea.Right;
  var lScale := DexiContinuousScale(fAttribute.Scale);
  var lPrevX := ChartArea.X;
  var lX := Math.Round(Utils.LinMap(aValue, fValueRange.MinValue, fValueRange.MaxValue, lXmin, lXmax));
  using lBrush := ValueBackgroundBrush(lScale, aValue) do
    Graphics.FillRectangle(lBrush, lPrevX, aBarY - fBarBarHeight div 2, lX - lPrevX, fBarBarHeight);
  using lBrush := ValueBrush(lScale, aValue) do
    begin
      var lPen := Pens.Black;
      var lRadius := fBarBarHeight div 2;
      Graphics.FillEllipse(lBrush, lX - lRadius, aBarY - lRadius, 2 * lRadius, 2 * lRadius);
      Graphics.DrawEllipse(lPen, lX - lRadius, aBarY - lRadius, 2 * lRadius, 2 * lRadius);
    end;
end;

method DexiBarChart.DrawValue(aValue: Distribution; aBarY: Integer);
begin
  var lXmin := GridArea.X;
  var lXmax := GridArea.Right;
  var lScale := DexiDiscreteScale(fAttribute.Scale);
  var lPrevX := ChartArea.X;
  // draw background first
  for lIdx := lScale.LowInt to lScale.HighInt do
    begin
      var lMem := Values.GetDistribution(aValue, lIdx);
      if lMem > 0.0 then
        using lBrush := ValueBackgroundBrush(lScale, lIdx) do
          begin
            var lX := Math.Round(Utils.LinMap(lIdx, lScale.LowInt, lScale.HighInt, lXmin, lXmax));
            Graphics.FillRectangle(lBrush, lPrevX, aBarY - fBarBarHeight div 2, lX - lPrevX, fBarBarHeight);
            lPrevX := lX;
          end;
     end;
  // draw points
  for lIdx := lScale.LowInt to lScale.HighInt do
    begin
      var lMem := Values.GetDistribution(aValue, lIdx);
      if lMem > 0.0 then
        using lBrush := ValueBrush(lScale, lIdx) do
          begin
            var lPen := Pens.Black;
            var lRadius := Math.Sqrt(lMem) * (fBarBarHeight div 2);
            var lX := Math.Round(Utils.LinMap(lIdx, lScale.LowInt, lScale.HighInt, lXmin, lXmax));
            Graphics.FillEllipse(lBrush, lX - lRadius, aBarY - lRadius, 2 * lRadius, 2 * lRadius);
            Graphics.DrawEllipse(lPen, lX - lRadius, aBarY - lRadius, 2 * lRadius, 2 * lRadius);
          end;
    end;
end;

method DexiBarChart.DrawValues;
begin
  if fAttribute.Scale = nil then
    exit;
  var lContinuous := fAttribute.Scale.IsContinuous;
  var lBar := 0;
  for each lAlt in AltOrder do
    if Parameters.IsSelected(lAlt) then
      begin
        var lY := BarY(lBar, HorizontalAlignment.Center);
        var lValue := Model.AltValue[lAlt, fAttribute];
        if DexiValue.ValueIsDefined(lValue) then
          if lContinuous then DrawValue(lValue.AsFloat, lY)
          else DrawValue(lValue.AsDistribution, lY);
        inc(lBar);
      end;
end;

method DexiBarChart.DrawChart;
begin
  inherited DrawChart;
  DrawChartArea;
  DrawAltNames;
  DrawAttName;
  DrawScale;
  DrawValues;
end;

{$ENDREGION}

{$REGION DexiScatterChart}

constructor DexiScatterChart(aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
require
  aParameters <> nil;
  aParameters.AttCount = 2;
begin
  inherited constructor (aWidth, aHeight, aModel, aParameters, aAltOrder);
  fAttributeX := aParameters.SelectedAttributes[0];
  fAttributeY := aParameters.SelectedAttributes[1];
end;

method DexiScatterChart.ScaleYWidth: Integer;
begin
  if not fValueRangeY.Defined then
    exit MeasureHeight('Tj', ValFont); // rotated "undefined scale"
  result := 0;
  for i := 0 to fValueRangeY.TickCount - 1 do
    result := Math.Max(result, MeasureWidth(fValueRangeY.Ticks[i], ValFont));
end;

method DexiScatterChart.AllocateResources;
begin
  inherited AllocateResources;
  fValueRangeX := new DexiAltValueRange(fAttributeX, Model);
  fValueRangeY := new DexiAltValueRange(fAttributeY, Model);
end;

method DexiScatterChart.Measure;
begin
  inherited Measure;
  fValTextWidth := ScaleYWidth;
  var lLeftOffset := AttTextHeight + fValTextWidth + ScaleGap + ValGap + AttGap;
  var lBottomOffset := AttTextHeight + ValTextHeight + ScaleGap + ValGap + AttGap;
  ChartArea := new Rectangle(ChartRect.X + lLeftOffset, ChartRect.Y, ChartRect.Width - lLeftOffset, ChartRect.Height - lBottomOffset);
  GridArea := ChartArea;
end;

method DexiScatterChart.GridX(aValue: Float): Integer;
begin
  var lXmin := GridArea.X;
  var lXmax := GridArea.Right;
  var lTickWidth := Math.Max((lXmax - lXmin) / fValueRangeX.TickCount, 2);
  var lTickWidthHalf := lTickWidth div 2;
  result := Math.Round((Utils.LinMap(aValue, fValueRangeX.MinValue, fValueRangeX.MaxValue, lXmin + lTickWidthHalf, lXmax - lTickWidthHalf)));
end;

method DexiScatterChart.GridY(aValue: Float): Integer;
begin
  var lYmin := GridArea.Y;
  var lYmax := GridArea.Bottom;
  var lTickWidth := Math.Max((lYmax - lYmin) / fValueRangeY.TickCount, 2);
  var lTickWidthHalf := lTickWidth div 2;
  result := Math.Round((Utils.LinMap(aValue, fValueRangeY.MinValue, fValueRangeY.MaxValue, lYmax - lTickWidthHalf, lYmin + lTickWidthHalf)));
end;

method DexiScatterChart.DrawAttXName;
begin
  DrawText(fAttributeX.Name, AttFont,
    ChartArea.X + ChartArea.Width div 2,
    ChartArea.Bottom + ScaleGap + ValGap + ValTextHeight,
    HorizontalAlignment.Center, HorizontalAlignment.Left);
end;

method DexiScatterChart.DrawAttYName;
begin
  DrawText(fAttributeY.Name, 270.0, AttFont,
    ChartRect.X,
    ChartArea.Y + ChartArea.Height div 2,
    HorizontalAlignment.Center, HorizontalAlignment.Left);
end;

method DexiScatterChart.DrawScaleX;
begin
  var lErrMsg :=
    if fAttributeX.Scale = nil then DexiString.CUndefinedScale
    else if not fValueRangeX.Defined then DexiString.CUndefinedScaleBorders
    else nil;
  if lErrMsg <> nil then
    begin
      DrawText(lErrMsg, ValFont, ChartArea.X + ChartArea.Width div 2, ChartArea.Bottom + ScaleGap,
        HorizontalAlignment.Center, HorizontalAlignment.Left);
      exit;
    end;
  var lY := GridArea.Bottom;
  for i := 0 to fValueRangeX.TickCount - 1 do
    using lScalePen := Drawing.ScalePenData.NewPen do
    using lGridPen := Drawing.GridPenData.NewPen do
      begin
        var lValue := fValueRangeX.MinValue + i * fValueRangeX.TickSpacing;
        var lX := GridX(lValue);
        Graphics.DrawLine(lScalePen, lX, lY, lX, lY + ScaleGap);
        DrawText(fValueRangeX.Ticks[i], ValFont, lX, lY + ScaleGap, HorizontalAlignment.Center, HorizontalAlignment.Left);
        Graphics.DrawLine(lGridPen, lX, GridArea.Top, lX, lY);
      end;
end;

method DexiScatterChart.DrawScaleY;
begin
  var lErrMsg :=
    if fAttributeY.Scale = nil then DexiString.CUndefinedScale
    else if not fValueRangeY.Defined then DexiString.CUndefinedScaleBorders
    else nil;
  if lErrMsg <> nil then
    begin
      DrawText(lErrMsg, 270.0, ValFont,
        ChartArea.X - (ScaleGap + ValTextHeight), ChartArea.Y + ChartArea.Height div 2,
        HorizontalAlignment.Center, HorizontalAlignment.Left);
      exit;
    end;
  for i := 0 to fValueRangeY.TickCount - 1 do
    using lScalePen := Drawing.ScalePenData.NewPen do
    using lGridPen := Drawing.GridPenData.NewPen do
      begin
        var lValue := fValueRangeY.MinValue + i * fValueRangeY.TickSpacing;
        var lY := GridY(lValue);
        Graphics.DrawLine(lScalePen, ChartArea.X, lY, ChartArea.X - ScaleGap, lY);
        DrawText(fValueRangeY.Ticks[i], ValFont, ChartArea.X - ScaleGap - ValGap, lY, HorizontalAlignment.Right, HorizontalAlignment.Center);
        Graphics.DrawLine(lGridPen, GridArea.X, lY, GridArea.Right, lY);
      end;
end;

method DexiScatterChart.DrawChartArea;
begin
  using lPen := Drawing.BorderPenData.NewPen do
    Graphics.DrawRectangle(lPen, ChartArea);
end;

method DexiScatterChart.DrawExtent(aAlt: Integer; aValueInfoX, aValueInfoY: AltValueInfo);
begin
  if ((aValueInfoX = nil) or (aValueInfoX.Count <= 1)) and ((aValueInfoY = nil) or (aValueInfoY.Count <= 1)) then
    exit;
  var lMinX := GridX(aValueInfoX.Values[0]);
  var lMinY := GridY(aValueInfoY.Values[0]);
  var lMaxX := GridX(aValueInfoX.Values.Last);
  var lMaxY := GridY(aValueInfoY.Values.Last);
  var lRect := new Rectangle(lMinX, lMaxY, lMaxX - lMinX, lMinY - lMaxY);
  if lRect.Width = 0 then
    begin
      lRect.X := lRect.X - PointRadius;
      lRect.Width := lRect.Width + 2 * PointRadius;
    end;
  if lRect.Height = 0 then
    begin
      lRect.Y := lRect.Y - PointRadius;
      lRect.Height := lRect.Height + 2 * PointRadius;
    end;
  var lColor := TransparentColor(Palette[aAlt mod length(Palette)]);
  using lBrush := new SolidBrush(lColor) do
    Graphics.FillRectangle(lBrush, lRect);
end;

method DexiScatterChart.DrawAlternatives;
begin
  fPoints := new ScatterPoints;
  if not (fValueRangeX.Defined and fValueRangeY.Defined) then
    exit;
  for each lAlt in AltOrder do
    if Parameters.IsSelected(lAlt) then
      begin
        var lAltValInfoX := ValueInfo(lAlt, fAttributeX);
        var lAltValInfoY := ValueInfo(lAlt, fAttributeY);
        if (lAltValInfoX = nil) or (lAltValInfoY = nil) then
          continue;
        DrawExtent(lAlt, lAltValInfoX, lAltValInfoY);
        var lPt := 0;
        if (lAltValInfoX.Count > 0) and (lAltValInfoY.Count > 0) then
          begin
            for i := 0 to lAltValInfoX.Count - 1 do
              for j := lAltValInfoY.Count - 1 downto 0 do
                begin
                  fPoints.IncludePoint(lAltValInfoX.Values[i], lAltValInfoY.Values[j], lAlt, lPt);
                  inc(lPt);
                end;
          end;
      end;
end;

method DexiScatterChart.DrawPoints;
begin
  var lDiameter := 2 * PointRadius;
  for each lPoint in fPoints.PointList do
    begin
      var lX := GridX(lPoint.ValueX);
      var lY := GridY(lPoint.ValueY);
      using lBrush := new SolidBrush(PointColor(lPoint)) do
        Graphics.FillEllipse(lBrush, lX - PointRadius, lY - PointRadius, lDiameter, lDiameter);
      Graphics.DrawEllipse(Pens.Black, lX - PointRadius, lY - PointRadius, lDiameter, lDiameter);
      lY := lY - PointRadius - LineGap;
      for i := lPoint.Alternatives.Count - 1 downto 0 do
        begin
          var lAlt := lPoint.Alternatives[i];
          if lAlt.PointIndex = 0 then
            begin
              DrawText(Model.AltNames[lAlt.Alternative].Name, AltFont, lX, lY, HorizontalAlignment.Center, HorizontalAlignment.Right);
              lY := lY - AltTextHeight - LineGap;
            end;
        end;
    end;
end;

method DexiScatterChart.DrawChart;
begin
  inherited DrawChart;
  DrawChartArea;
  DrawAttXName;
  DrawAttYName;
  DrawScaleX;
  DrawScaleY;
  DrawAlternatives;
  DrawPoints;
end;

{$ENDREGION}

{$REGION AxisPoint}

constructor AxisPoint(aCoord: Point; aBrushData: BrushData; aText: String := '');
begin
  inherited constructor;
  Coord := aCoord;
  Brush := aBrushData;
  Text := aText;
end;

{$ENDREGION}

{$REGION AxisPoints}

constructor AxisPoints;
begin
  inherited constructor;
  fPoints := new List<AxisPoint>;
end;

method AxisPoints.AddPoint(aPoint: AxisPoint);
begin
  fPoints.Add(aPoint);
end;

method AxisPoints.AddPoint(aCoord: Point; aBrushData: BrushData; aText: String := '');
begin
  fPoints.Add(new AxisPoint(aCoord, aBrushData, aText));
end;

{$ENDREGION}

{$REGION DexiRadarChart}

constructor DexiRadarChart(aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil; aAltSubset: IntArray := nil);
require
  aParameters <> nil;
  aParameters.AttCount > 2;
begin
  inherited constructor (aWidth, aHeight, aModel, aParameters, aAltOrder);
  var lInts := aParameters.SelectedAlternatives:Ints;
  fAltSubset :=
    if aAltSubset <> nil then  Utils.CopyIntArray(aAltSubset)
    else if lInts = nil then Utils.RangeArray(Model.AltCount, 0)
    else Utils.CopyIntArray(lInts);
end;

method DexiRadarChart.RadarPoint(aIdx: Integer; aValue: Float := 1.0): Point;
begin
  var lAngle0 := Consts.PI / 2.0;
  var lDiff := 2.0 * Consts.Pi / Parameters.AttCount;
  var lAngle := lAngle0 - aIdx * lDiff;
  var lUnitX := aValue * Math.Cos(lAngle);
  var lUnitY := aValue * Math.Sin(lAngle);
  var lX := Math.Round(fGridCenter.X + (lUnitX * fGridRadius));
  var lY := Math.Round(fGridCenter.Y - (lUnitY * fGridRadius));
  result := new Point(lX, lY);
end;

method DexiRadarChart.ValuePoint(aIdx: Integer; aValue: Float): Point;
begin
  var lOffX := Math.Round(aValue * (fChartPoints[aIdx].X - fGridCenter.X));
  var lOffY := Math.Round(aValue * (fChartPoints[aIdx].Y - fGridCenter.Y));
  result := new Point(fGridCenter.X + lOffX, fGridCenter.Y + lOffY);
end;

method DexiRadarChart.Measure;
const
  MinGrid = 100;
begin
  inherited Measure;
  var lLegendWidth :=
    if Single then 0
    else LegendWidth + LegendGap;
  var lXOffsetRight := AttTextWidth + 2 * (AttGap + PointRadius);
  var lXOffsetLeft := Math.Max(AltTextWidth + lLegendWidth, lXOffsetRight);
  var lYOffsetBottom := AttTextHeight + AttGap + PointRadius;
  var lYOffsetTop := Math.Max(SubCount * (AltTextHeight + AltGap), lYOffsetBottom);
  fGridDiameter := Math.Min(ChartRect.Width - lXOffsetLeft - lXOffsetRight, ChartRect.Height - lYOffsetTop - lYOffsetBottom);
  fGridDiameter := Math.Max(fGridDiameter, MinGrid);
  fGridRadius := fGridDiameter div 2;
  GridArea := new Rectangle(ChartRect.X + lXOffsetLeft, ChartRect.Y + lYOffsetTop, fGridDiameter, fGridDiameter);
  fGridCenter := new Point(GridArea.X + GridArea.Width div 2, GridArea.Y + GridArea.Height div 2);
  fChartPoints := new List<Point>;
  fValueRanges := new List<DexiAltValueRange>;
  for i := 0 to Parameters.AttCount - 1 do
    begin
      fChartPoints.Add(RadarPoint(i));
      fValueRanges.Add(new DexiAltValueRange(Parameters.SelectedAttributes[i], Model));
    end;
end;

method DexiRadarChart.AlternativeColor(aAlt: Integer): Color;
begin
  if SubCount > 1 then
    result := Palette[aAlt mod length(Palette)]
  else
    begin
      result := Color.Black;
      var lFirst := Model:First;
      var lValue := Model.AltValue[aAlt, lFirst];
      var lClass :=
        if lFirst.Scale = nil then ValueCategoryType.None
        else lFirst.Scale.ValueCategory(lValue);
      result :=
        case lClass of
          ValueCategoryType.None:    Color.Black;
          ValueCategoryType.Bad:     Color.FromArgb(Model.Settings.BadColor.ARGB);
          ValueCategoryType.Neutral: Color.Gray;
          ValueCategoryType.Good:    Color.FromArgb(Model.Settings.GoodColor.ARGB);
          ValueCategoryType.Mixed:   Color.Blue;
        end;
    end;
end;

method DexiRadarChart.DrawAreaBackground;
begin
  using lBrush := new SolidBrush(AreaColor) do
    Graphics.FillPolygon(lBrush, fChartPoints.ToArray);
end;

method DexiRadarChart.DrawAltNames;
begin
  var lX := ChartRect.X;
  var lY := ChartRect.Y;
  for i := low(fAltSubset) to high(fAltSubset) do
    begin
      var lTextLeft := lX;
      if SubCount > 1 then
        begin
          var lColor := AlternativeColor(fAltSubset[i]);
          using lBrush := new SolidBrush(lColor) do
            begin
              var lRect := new Rectangle(lX, lY + AltTextHeight div 2 - LegendHeight div 2, LegendWidth, LegendHeight);
              Graphics.FillRectangle(lBrush, lRect);
              Graphics.DrawRectangle(Pens.Black, lRect);
              lTextLeft := lTextLeft + LegendWidth + LegendGap;
            end;
        end;
      var lName := Model.AltNames[fAltSubset[i]].Name;
      DrawText(lName, AltFont, lTextLeft, lY, HorizontalAlignment.Left, HorizontalAlignment.Left);
      lY := lY + AltTextHeight + AltGap;
    end;
end;

method DexiRadarChart.DrawRadar;
begin
  using lPen := Drawing.BorderPenData.NewPen do
    begin
      for i := 0 to fChartPoints.Count - 2 do
        Graphics.DrawLine(lPen, fChartPoints[i], fChartPoints[i + 1]);
      Graphics.DrawLine(lPen, fChartPoints.Last, fChartPoints[0]);
    end;
end;

method DexiRadarChart.DrawGrid;
begin
  using lPen := Drawing.GridPenData.NewPen do
    begin
      for i := 0 to fChartPoints.Count - 1 do
        Graphics.DrawLine(lPen, fGridCenter, fChartPoints[i]);
    end;
end;

method DexiRadarChart.DrawAttNames;

  method HAlign(aIdx: Integer; aMid: Float): HorizontalAlignment;
  begin
    result :=
      if (aIdx = 0) or (Utils.FloatEq(aMid, aIdx)) then HorizontalAlignment.Center
      else if aIdx < aMid then HorizontalAlignment.Left
      else HorizontalAlignment.Right;
  end;

  method VAlign(aIdx: Integer; aMid: Float): HorizontalAlignment;
  begin
    result :=
      if aIdx = 0 then HorizontalAlignment.Right
      else if Utils.FloatEq(aMid, aIdx) then HorizontalAlignment.Left
      else HorizontalAlignment.Center;
  end;

  method HDiff(aIdx: Integer; aMid: Float): Integer;
  begin
    result :=
      if (aIdx = 0) or (Utils.FloatEq(aMid, aIdx)) then 0
      else if aIdx < aMid then AttGap + PointRadius
      else -AttGap - PointRadius;
  end;

  method VDiff(aIdx: Integer; aMid: Float): Integer;
  begin
    result :=
      if aIdx = 0 then -AttGap - PointRadius
      else if Utils.FloatEq(aMid, aIdx) then AttGap + PointRadius
      else 0;
  end;

begin
  var lMid := Parameters.AttCount / 2.0;
  for i := 0 to Parameters.AttCount - 1 do
    begin
      var lPoint := fChartPoints[i];
      var lAtt := Parameters.SelectedAttributes[i];
      DrawText(lAtt.Name, AttFont, lPoint.X + HDiff(i, lMid), lPoint.Y + VDiff(i, lMid), HAlign(i, lMid), VAlign(i, lMid));
    end;
end;

method DexiRadarChart.PrepareValue(aValue: Float; aAtt: Integer);
begin
  var lValueRange := fValueRanges[aAtt];
  if (lValueRange = nil) or not lValueRange.Defined then
    exit;
  var lAtt := Parameters.SelectedAttributes[aAtt];
  var lScale := DexiContinuousScale(lAtt.Scale);
  var lValue := Utils.LinMap(aValue,lValueRange.MinValue, lValueRange.MaxValue, 0.0, 1.0);
  var lValPt := ValuePoint(aAtt, lValue);
  var lText :=
    if (Utils.FloatEq(aValue, lValueRange.MinValue) or Utils.FloatEq(aValue, lValueRange.MaxValue)) then ''
    else Utils.FloatToStr(aValue);
  fAltPoints.Last.AddPoint(lValPt, ValueBrushData(lScale, aValue), lText);
end;

method DexiRadarChart.PrepareValue(aValue: Distribution; aAtt: Integer);
begin
  var lAtt := Parameters.SelectedAttributes[aAtt];
  if lAtt.Scale = nil then
    exit;
  var lScale := DexiDiscreteScale(lAtt.Scale);
  for lIdx := lScale.LowInt to lScale.HighInt do
    begin
      var lMem := Values.GetDistribution(aValue, lIdx);
      if lMem > 0.0 then
        begin
          var lValue := Utils.LinMap(lIdx, lScale.LowInt, lScale.HighInt, 0.0, 1.0);
          var lValPt := ValuePoint(aAtt, lValue);
          var lText :=
            if (lIdx = lScale.LowInt) or (lIdx = lScale.HighInt) then ''
            else lScale.Names[lIdx];
          fAltPoints.Last.AddPoint(lValPt, ValueBrushData(lScale, lIdx), lText);
        end;
    end;
end;

method DexiRadarChart.PrepareValues(aAlt, aAtt: Integer);
begin
  var lAtt := Parameters.SelectedAttributes[aAtt];
  if lAtt.Scale = nil then
    exit;
  var lContinuous := lAtt.Scale.IsContinuous;
  var lValue := Model.AltValue[aAlt, lAtt];
  if DexiValue.ValueIsDefined(lValue) then
    if lContinuous then PrepareValue(lValue.AsFloat, aAtt)
    else PrepareValue(lValue.AsDistribution, aAtt);
end;

method DexiRadarChart.PrepareValues(aAlt: Integer);
begin
  fAltPoints := new List<AxisPoints>;
  for lIdx := 0 to Parameters.AttCount - 1 do
    begin
      fAltPoints.Add(new AxisPoints);
      PrepareValues(aAlt, lIdx);
    end;
end;

method DexiRadarChart.DrawValues(aAlt, aAtt: Integer);
begin
  var lAxisPoints := fAltPoints[aAtt];
  for i := 0 to lAxisPoints.Count - 1 do
    begin
      var lAxisPoint := lAxisPoints.Points[i];
      var lValPt := lAxisPoint.Coord;
      using lBrush := lAxisPoint.Brush.NewBrush do
        begin
          var lPen := Pens.Black;
          var lRect := new Rectangle(lValPt.X - PointRadius, lValPt.Y - PointRadius, 2 * PointRadius, 2 * PointRadius);
          Graphics.FillEllipse(lBrush, lRect);
          Graphics.DrawEllipse(lPen, lRect);
          if not String.IsNullOrEmpty(lAxisPoint.Text) then
            DrawText(lAxisPoint.Text, ValFont, lValPt.X, lValPt.Y - ValGap, HorizontalAlignment.Center, HorizontalAlignment.Right);
        end;
      end;
end;

method DexiRadarChart.DrawValues(aAlt: Integer);
begin
  for lIdx := 0 to Parameters.AttCount - 1 do
    DrawValues(aAlt, lIdx);
end;

method DexiRadarChart.DrawConnection(aAlt: Integer; aFrom, aTo: AxisPoints);
begin
  if (aFrom.Count = 0) or (aTo.Count = 0) then
    exit;
  var lColor := AlternativeColor(aAlt);
  var lBrushColor := TransparentColor(lColor);
  using lPen := new Pen(lColor, Parameters.LineWidth) do
    begin
      Graphics.DrawLine(lPen, aFrom.Points[0].Coord, aTo.Points[0].Coord);
      if (aFrom.Count > 1) or (aTo.Count > 1) then
        begin
          using lBrush := new SolidBrush(lBrushColor) do
            Graphics.FillPolygon(lBrush,
              [aFrom.Points[0].Coord, aFrom.Points.Last.Coord, aTo.Points.Last.Coord, aTo.Points[0].Coord]);
          Graphics.DrawLine(lPen, aFrom.Points.Last.Coord, aTo.Points.Last.Coord);
        end;
    end;
end;

method DexiRadarChart.DrawConnections(aAlt: Integer);
begin
  for lFromIdx := 0 to fAltPoints.Count - 1 do
    begin
      var lToIdx := lFromIdx + 1;
      if lToIdx >= fAltPoints.Count then
        lToIdx := 0;
      var lFrom := fAltPoints[lFromIdx];
      var lTo := fAltPoints[lToIdx];
      DrawConnection(aAlt, lFrom, lTo);
    end;
end;

method DexiRadarChart.DrawValues;
begin
  for lIdx := low(fAltSubset) to high(fAltSubset) do
    begin
      var lAlt := fAltSubset[lIdx];
      PrepareValues(lAlt);
      DrawConnections(lAlt);
      DrawValues(lAlt);
    end;
end;

method DexiRadarChart.DrawChart;
begin
  inherited DrawChart;
  DrawAltNames;
  DrawRadar;
  DrawGrid;
  DrawAttNames;
  DrawValues;
end;

{$ENDREGION}

{$REGION DexiRadarGrid}

constructor DexiRadarGrid(aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
require
  aParameters <> nil;
  aParameters.GridX >= 1;
  aParameters.GridY >= 1;
begin
  inherited constructor(aWidth, aHeight, aModel, aParameters, aAltOrder);
  fGridWidth := Math.Max(aWidth div GridX, 100);
  fGridHeight := Math.Max(aHeight div GridY, 100);
end;

method DexiRadarGrid.DrawChart;
begin
  inherited DrawChart;
  var lIdxX := 0;
  var lIdxY := 0;
  for each lAlt in AltOrder do
    if Parameters.IsSelected(lAlt) then
      begin
        var lChart := new DexiRadarChart(fGridWidth, fGridHeight, Model, Parameters, AltOrder, [lAlt]);
        lChart.Border := Parameters.Border;
        Graphics.TranslateTransform(lIdxX * fGridWidth, lIdxY * fGridHeight);
        lChart.Draw(Graphics);
        Graphics.ResetTransform;
        inc(lIdxX);
        if lIdxX >= GridX then
          begin
            lIdxX := 0;
            inc(lIdxY);
            if lIdxY >= GridY then
              exit;
          end;
      end;
end;

{$ENDREGION}

{$REGION DexiAbaconChart}

constructor DexiAbaconChart(aWidth, aHeight: Integer; aModel: DexiModel; aParameters: DexiChartParameters; aAltOrder: IntArray := nil);
begin
  inherited constructor (aWidth, aHeight, aModel, aParameters, aAltOrder);
end;

method DexiAbaconChart.AllocateResources;
begin
  inherited AllocateResources;
  fValueRanges := new List<DexiAltValueRange>;
  for i := 0 to Parameters.AttCount - 1 do
    fValueRanges.Add(new DexiAltValueRange(Parameters.SelectedAttributes[i], Model));
end;

method DexiAbaconChart.Measure;
begin
  inherited Measure;
  var lSideGap := MinSideGap;
  for each lValueRange in fValueRanges do
    for i := 0 to lValueRange.TickCount - 1 do
      lSideGap := Math.Max(lSideGap, MeasureWidth(lValueRange.Ticks[i], ValFont) div 2 + 2 * ValGap);
  var lAllLinesHeight := ChartRect.Height;
  fLineGap := Math.Max(4, lAllLinesHeight div Math.Max(1, AttCount));
  var lLeftOffset := AttTextWidth + AttGap + TickLength;
  var lRightOffset := AltTextWidth + 2 * AltGap + LegendWidth + LegendGap;
  ChartArea := new Rectangle(ChartRect.X + lLeftOffset, ChartRect.Y, ChartRect.Width - lLeftOffset - lRightOffset, ChartRect.Height);
  GridArea := new Rectangle(ChartArea.X + lSideGap, ChartArea.Y, ChartArea.Width - 2 * lSideGap, ChartArea.Height);
end;

method DexiAbaconChart.AttY(aIdx: Integer): Integer;
begin
  result := Math.Round((aIdx + 0.5) * fLineGap);
end;

method DexiAbaconChart.AlternativeColor(aAlt: Integer): Color;
begin
  result := Palette[aAlt mod length(Palette)];
end;

method DexiAbaconChart.DrawChartArea;
begin
  using lPen := Drawing.BorderPenData.NewPen do
    Graphics.DrawRectangle(lPen, ChartArea);
end;

method DexiAbaconChart.DrawAttNames;
begin
  for i := 0 to AttCount - 1 do
    begin
      var lX := ChartArea.X - TickLength - AttGap;
      var lY := AttY(i);
      DrawText(Parameters.SelectedAttributes[i].Name, AttFont, lX, lY, HorizontalAlignment.Right, HorizontalAlignment.Center);
    end;
end;

method DexiAbaconChart.DrawAltNames;
begin
  var lX := ChartArea.Right + AltGap;
  var lY := ChartArea.Y;
  for each lAlt in AltOrder do
    if Parameters.IsSelected(lAlt) then
      begin
        var lColor := AlternativeColor(lAlt);
        using lBrush := new SolidBrush(lColor) do
          begin
            var lRect := new Rectangle(lX, lY + AltTextHeight div 2 - LegendHeight div 2, LegendWidth, LegendHeight);
            Graphics.FillRectangle(lBrush, lRect);
            Graphics.DrawRectangle(Pens.Black, lRect);
          end;
        var lTextLeft := lX + LegendWidth + LegendGap;
        var lName := Model.AltNames[lAlt].Name;
        DrawText(lName, AltFont, lTextLeft, lY, HorizontalAlignment.Left, HorizontalAlignment.Left);
        lY := lY + AltTextHeight + AltGap;
      end;
end;

method DexiAbaconChart.DrawGrid;
begin
  for i := 0 to AttCount - 1 do
    begin
      var lLeft := ChartArea.X - TickLength;
      var lRight := ChartArea.Right;
      var lY := AttY(i);
      using lPen := Drawing.GridPenData.NewPen do
        Graphics.DrawLine(lPen, lLeft, lY, lRight, lY);
    end;
end;

method DexiAbaconChart.DrawScale(aIdx: Integer; aTicks: Boolean; aValues: Boolean);
begin
  var lValueRange := fValueRanges[aIdx];
  var lAtt := Parameters.SelectedAttributes[aIdx];
  var lY := AttY(aIdx);
  var lErrMsg :=
    if lAtt.Scale = nil then DexiString.CUndefinedScale
    else if not lValueRange.Defined then DexiString.CUndefinedScaleBorders
    else nil;
  if lErrMsg <> nil then
    begin
      DrawText(lErrMsg, ValFont, GridArea.X + GridArea.Width div 2, lY + ValGap,
        HorizontalAlignment.Center, HorizontalAlignment.Left);
      exit;
    end;
  var lXmin := GridArea.X;
  var lXmax := GridArea.Right;
  for i := 0 to lValueRange.TickCount - 1 do
    using lGridPen := Drawing.GridPenData.NewPen do
      begin
        var lValue := lValueRange.MinValue + i * lValueRange.TickSpacing;
        var lX := Math.Round(Utils.LinMap(lValue, lValueRange.MinValue, lValueRange.MaxValue, lXmin, lXmax));
        if aTicks then
          Graphics.DrawLine(lGridPen, lX, lY - TickLength div 2, lX, lY + TickLength div 2);
        if aValues then
          DrawText(lValueRange.Ticks[i], ValFont, lX, lY + TickLength + ValGap, HorizontalAlignment.Center, HorizontalAlignment.Left);
      end;
end;

method DexiAbaconChart.DrawScales(aTicks: Boolean; aValues: Boolean);
begin
  for i := 0 to AttCount - 1 do
    DrawScale(i, aTicks, aValues);
end;

method DexiAbaconChart.PrepareValue(aValue: Float; aAtt: Integer);
begin
  var lValueRange := fValueRanges[aAtt];
  if (lValueRange = nil) or not lValueRange.Defined then
    exit;
  var lAtt := Parameters.SelectedAttributes[aAtt];
  var lScale := DexiContinuousScale(lAtt.Scale);
  var lX := Math.Round(Utils.LinMap(aValue,lValueRange.MinValue, lValueRange.MaxValue, GridArea.X, GridArea.Right));
  fAltPoints.Last.AddPoint(new Point(lX, AttY(aAtt)), ValueBrushData(lScale, aValue));
end;

method DexiAbaconChart.PrepareValue(aValue: Distribution; aAtt: Integer);
begin
  var lAtt := Parameters.SelectedAttributes[aAtt];
  if lAtt.Scale = nil then
    exit;
  var lScale := DexiDiscreteScale(lAtt.Scale);
  for lIdx := lScale.LowInt to lScale.HighInt do
    begin
      var lMem := Values.GetDistribution(aValue, lIdx);
      if lMem > 0.0 then
        begin
          var lX := Math.Round(Utils.LinMap(lIdx, lScale.LowInt, lScale.HighInt, GridArea.X, GridArea.Right));
          fAltPoints.Last.AddPoint(new Point(lX, AttY(aAtt)), ValueBrushData(lScale, lIdx));
        end;
    end;
end;

method DexiAbaconChart.PrepareValues(aAlt, aAtt: Integer);
begin
  var lAtt := Parameters.SelectedAttributes[aAtt];
  if lAtt.Scale = nil then
    exit;
  var lContinuous := lAtt.Scale.IsContinuous;
  var lValue := Model.AltValue[aAlt, lAtt];
  if DexiValue.ValueIsDefined(lValue) then
    if lContinuous then PrepareValue(lValue.AsFloat, aAtt)
    else PrepareValue(lValue.AsDistribution, aAtt);
end;

method DexiAbaconChart.PrepareValues(aAlt: Integer);
begin
  fAltPoints := new List<AxisPoints>;
  for lIdx := 0 to Parameters.AttCount - 1 do
    begin
      fAltPoints.Add(new AxisPoints);
      PrepareValues(aAlt, lIdx);
    end;
end;

method DexiAbaconChart.DrawValues(aAlt, aAtt: Integer);
begin
  var lAxisPoints := fAltPoints[aAtt];
  for i := 0 to lAxisPoints.Count - 1 do
    begin
      var lAxisPoint := lAxisPoints.Points[i];
      var lValPt := lAxisPoint.Coord;
      using lBrush := lAxisPoint.Brush.NewBrush do
        begin
          var lPen := Pens.Black;
          var lRect := new Rectangle(lValPt.X - PointRadius, lValPt.Y - PointRadius, 2 * PointRadius, 2 * PointRadius);
          Graphics.FillEllipse(lBrush, lRect);
          Graphics.DrawEllipse(lPen, lRect);
        end;
      end;
end;

method DexiAbaconChart.DrawValues(aAlt: Integer);
begin
  for lIdx := 0 to Parameters.AttCount - 1 do
    DrawValues(aAlt, lIdx);
end;

method DexiAbaconChart.DrawConnection(aIdx, aAlt: Integer; aFrom, aTo: AxisPoints);

  method AltShift(aWidth: Integer): Integer;
  begin
    var lShift := aIdx - (AltCount - 1) div 2;
    result := lShift * aWidth;
  end;

begin
  if (aFrom.Count = 0) or (aTo.Count = 0) then
    exit;
  var lColor := AlternativeColor(aAlt);
  var lBrushColor := TransparentColor(lColor);
  using lPen := new Pen(lColor, Parameters.LineWidth) do
    begin
      var lShift := AltShift(3);
      Graphics.TranslateTransform(lShift, 0);
      Graphics.DrawLine(lPen, aFrom.Points[0].Coord, aTo.Points[0].Coord);
      Graphics.ResetTransform;
      if (aFrom.Count > 1) or (aTo.Count > 1) then
        begin
          using lBrush := new SolidBrush(lBrushColor) do
            Graphics.FillPolygon(lBrush,
              [aFrom.Points[0].Coord, aFrom.Points.Last.Coord, aTo.Points.Last.Coord, aTo.Points[0].Coord]);
          Graphics.TranslateTransform(lShift, 0);
          Graphics.DrawLine(lPen, aFrom.Points.Last.Coord, aTo.Points.Last.Coord);
          Graphics.ResetTransform;
        end;
    end;
end;

method DexiAbaconChart.DrawConnections(aIdx, aAlt: Integer);
begin
  for lFromIdx := 0 to fAltPoints.Count - 2 do
    begin
      var lToIdx := lFromIdx + 1;
      var lFrom := fAltPoints[lFromIdx];
      var lTo := fAltPoints[lToIdx];
      DrawConnection(aIdx, aAlt, lFrom, lTo);
    end;
end;

method DexiAbaconChart.DrawValues;
begin
  var lIdx := 0;
  for each lAlt in AltOrder do
    if Parameters.IsSelected(lAlt) then
      begin
        PrepareValues(lAlt);
        DrawConnections(lIdx, lAlt);
        DrawValues(lAlt);
        inc(lIdx);
      end;
end;

method DexiAbaconChart.DrawChart;
begin
  inherited DrawChart;
  DrawChartArea;
  DrawAttNames;
  DrawAltNames;
  DrawGrid;
  DrawChartArea;
  DrawScales(true, false);
  DrawValues;
  DrawScales(false, true);
end;

{$ENDREGION}

{$REGION MapRangeToRectangle}

constructor MapRangeToRectangle(aRect: Rectangle);
begin
  inherited constructor;
  SetRectangle(aRect);
end;

constructor MapRangeToRectangle(aRect: Rectangle; aDefHorizontal: Float; aDefVertical: Float);
begin
  inherited constructor (aDefHorizontal, aDefVertical);
  SetRectangle(aRect);
end;

method MapRangeToRectangle.SetHorizontalRotation(aDegrees: Float);
begin
  inherited SetHorizontalRotation(aDegrees);
  ReMap;
end;

method MapRangeToRectangle.SetVerticalRotation(aDegrees: Float);
begin
  inherited SetVerticalRotation(aDegrees);
  ReMap;
end;

method MapRangeToRectangle.SetRotation(aHorizontal, aVertical: Float);
begin
  inherited SetRotation(aHorizontal, aVertical);
  ReMap;
end;

method MapRangeToRectangle.ResetRotation;
begin
  inherited ResetRotation;
  ReMap;
end;

method MapRangeToRectangle.ReMap;

  method MeasurePoint(x, y, z: Float);
  begin
    var pX := ProjX(x, y, z);
    var pY := ProjY(x, y, z);
    fMinX := Math.Min(fMinX, pX);
    fMaxX := Math.Max(fMaxX, pX);
    fMinY := Math.Min(fMinY, pY);
    fMaxY := Math.Max(fMaxY, pY);
  end;

begin
  fMinX := Consts.PositiveInfinity;
  fMinY := Consts.PositiveInfinity;
  fMaxX := Consts.NegativeInfinity;
  fMaxY := Consts.NegativeInfinity;
  for x in [fLowX, fHighX] do
    for y in [fLowY, fHighY] do
      for z in [fLowZ, fHighZ] do
        MeasurePoint(x, y, z);
end;

method MapRangeToRectangle.SetRectangle(aRect: Rectangle);
begin
  fRect := aRect;
  ReMap;
end;

method MapRangeToRectangle.RectX(x, y, z: Float): Integer;
begin
  var lProj := ProjX(x, y, z);
  result := Math.Round(Utils.LinMap(lProj, fMaxX, fMinX, fRect.Left, fRect.Right));
end;

method MapRangeToRectangle.RectY(x, y, z: Float): Integer;
begin
  var lProj := ProjY(x, y, z);
  result := Math.Round(Utils.LinMap(lProj, fMaxY, fMinY, fRect.Top, fRect.Bottom));
end;

method MapRangeToRectangle.RectProj(x, y, z: Float): ChartPoint;
begin
  result := new ChartPoint(RectX(x, y, z), RectY(x, y, z));
end;

method MapRangeToRectangle.SetXRange(aFrom, aTo: Float);
begin
  fLowX := aFrom;
  fHighX := aTo;
  ReMap;
end;

method MapRangeToRectangle.SetYRange(aFrom, aTo: Float);
begin
  fLowY := aFrom;
  fHighY := aTo;
  ReMap;
end;

method MapRangeToRectangle.SetZRange(aFrom, aTo: Float);
begin
  fLowZ := aFrom;
  fHighZ := aTo;
  ReMap;
end;

{$ENDREGION}

{$REGION DexiFunct3DChart}

constructor DexiFunct3DChart(aWidth, aHeight: Integer;
      aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction; aParameters: DexiFunct3DChartParameters);
begin
  inherited constructor (aWidth, aHeight);
  fModel := aModel;
  fAttribute := aAttribute;
  fDrawing := new WinChartDrawing(fModel);
  fFunct := aFunct;
  fParameters := aParameters;
end;

method DexiFunct3DChart.AllocateResources;
begin
  inherited AllocateResources;
  fAttFont := fParameters.AttFont;
  fValFont := fParameters.ValFont;
end;

method DexiFunct3DChart.DisposeResources;

  method DisposeOf(var aFont: Font);
  begin
    if aFont = nil then
      exit;
    aFont.Dispose;
    aFont := nil;
  end;

begin
  DisposeOf(var fAttFont);
  DisposeOf(var fValFont);
  inherited DisposeResources;
end;

method DexiFunct3DChart.GetML: DexiMultilinearModel;
begin
  if fML = nil then
    fML := new DexiMultilinearModel(fFunct);
  result := fML;
end;

method DexiFunct3DChart.GetQQ1: DexiQQ1Model;
begin
  if fQQ1 = nil then
    fQQ1 := new DexiQQ1Model(fFunct);
  result := fQQ1;
end;

method DexiFunct3DChart.GetQQ2: DexiQQ2Model;
begin
  if fQQ2 = nil then
    fQQ2 := new DexiQQ2Model(fFunct);
  result := fQQ2;
end;

method DexiFunct3DChart.ProjX(x, y, z: Float): Integer;
begin
  result := fMap3D.RectX(x, y, z);
end;

method DexiFunct3DChart.ProjY(x, y, z: Float): Integer;
begin
  result := fMap3D.RectY(x, y, z);
end;

method DexiFunct3DChart.ProjPoint(x, y, z: Float): Point;
begin
  var lRect := fMap3D.RectProj(x, y, z);
  result := new Point(lRect.IntX, lRect.IntY);
end;

method DexiFunct3DChart.DrawLine(aPoint1, aPoint2: Point; aPen: Pen);
begin
   Graphics.DrawLine(aPen, aPoint1, aPoint2);
end;

method DexiFunct3DChart.DrawLine(ax1, ay1, az1: Float; ax2, ay2, az2: Float; aPen: Pen);
begin
  DrawLine(ProjPoint(ax1, ay1, az1), ProjPoint(ax2, ay2, az2), aPen);
end;

method DexiFunct3DChart.MapAndDrawLine(ax1, ay1, az1: Float; ax2, ay2, az2: Float; aPen: Pen);
begin
  if Consts.IsNaN(az1) or Consts.IsNaN(az2) then
    exit;
  ax1 := FromDexiToDrawCoordinates(ax1, 1);
  ay1 := FromDexiToDrawCoordinates(ay1, 2);
  az1 := FromDexiToDrawCoordinates(az1, 0);
  ax2 := FromDexiToDrawCoordinates(ax2, 1);
  ay2 := FromDexiToDrawCoordinates(ay2, 2);
  az2 := FromDexiToDrawCoordinates(az2, 0);
  DrawLine(ProjPoint(ax1, ay1, az1), ProjPoint(ax2, ay2, az2), aPen);
end;

method DexiFunct3DChart.LinearApproximation(aArgs: FltArray): Float;
begin
  result := QQ1.Regression(aArgs);
end;

method DexiFunct3DChart.MultilinearInterpolation(aArgs: FltArray): Float;
begin
  result := ML.Evaluate(aArgs);
end;

method  DexiFunct3DChart.EvaluateFunct(aFunct: FunctToDraw3D; ax1, ax2: Float): Float;
begin
  var lArgs := Utils.IntToFltArray(fParameters.Match);
  lArgs[fParameters.Att1Idx] := ax1;
  lArgs[fParameters.Att2Idx] := ax2;
  result := aFunct(lArgs);
end;

method DexiFunct3DChart.EvaluateModel(aModel: DexiQModel; aClass: Integer; ax1, ax2: Float): Float;
begin
  var lArgs := Utils.IntToFltArray(fParameters.Match);
  lArgs[fParameters.Att1Idx] := ax1;
  lArgs[fParameters.Att2Idx] := ax2;
  result := aModel.Evaluate(lArgs, aClass);
end;

method DexiFunct3DChart.DrawFunct(aFunct: FunctToDraw3D; ax1f, ax1t, ax2f, ax2t: Float; aStep: Float; aPenMain, aPenSide: Pen);
var x1, x2, xn, f1, f2: Float;
begin
  if ax1f > ax1t then
    Utils.Swap(var ax1f, var ax1t);
  if ax2f > ax2t then
    Utils.Swap(var ax2f, var ax2t);
  x1 := ax1f;
  while (x1 <= ax1t + Utils.FloatEpsilon) do
    begin
      var lPen := if Utils.FloatEq(Math.Round(x1), x1) then aPenMain else aPenSide;
      x2 := ax2f;
      f1 := EvaluateFunct(aFunct, x1, x2);
      while (x2 + aStep <= ax2t + Utils.FloatEpsilon) do
        begin
          xn := x2 + aStep;
          f2 := EvaluateFunct(aFunct, x1, xn);
          MapAndDrawLine(x1, x2, f1, x1, xn, f2, lPen);
          f1 := f2;
          x2 := xn;
        end;
      x1 := x1 + aStep;
    end;

  x2 := ax2f;
  while (x2 <= ax2t + Utils.FloatEpsilon) do
    begin
      var lPen := if Utils.FloatEq(Math.Round(x2), x2) then aPenMain else aPenSide;
      x1 := ax1f;
      f1 := EvaluateFunct(aFunct, x1, x2);
      while (x1 + aStep <= ax1t + Utils.FloatEpsilon) do
        begin
          xn := x1 + aStep;
          f2 := EvaluateFunct(aFunct, xn, x2);
          MapAndDrawLine(x1, x2, f1, xn, x2, f2, lPen);
          f1 := f2;
          x1 := xn;
        end;
      x2 := x2 + aStep;
    end;
end;

method DexiFunct3DChart.DrawModelPoint(aModel: DexiQModel; aArgs: IntArray; aClass: Integer; aPenBorder, aPenInternal: Pen);
var x1, x2, xn, f1, f2: Float;
begin
  const lStep = 0.5 - Utils.FloatEpsilon;
  x1 := aArgs[fParameters.Att1Idx] - lStep;
  for i := 1 to 3 do
    begin
      x2 := aArgs[fParameters.Att2Idx] - lStep;
      f1 := EvaluateModel(aModel, aClass, x1, x2);
      var lPen := if i = 2 then aPenInternal else aPenBorder;
      for j := 1 to 2 do
        begin
          xn := x2 + lStep;
          f2 := EvaluateModel(aModel, aClass, x1, xn);
          MapAndDrawLine(x1, x2, f1, x1, xn, f2, lPen);
          f1 := f2;
          x2 := xn;
        end;
      x1 := x1 + lStep;
    end;

  x2 := aArgs[fParameters.Att2Idx] - lStep;
  for i := 1 to 3 do
    begin
      x1 := aArgs[fParameters.Att1Idx] - lStep;
      f1 := EvaluateModel(aModel, aClass, x1, x2);
      var lPen := if i = 2 then aPenInternal else aPenBorder;
      for j := 1 to 2 do
        begin
          xn := x1 + lStep;
          f2 := EvaluateModel(aModel, aClass, xn, x2);
          MapAndDrawLine(x1, x2, f1, xn, x2, f2, lPen);
          f1 := f2;
          x1 := xn;
        end;
      x2 := x2 + lStep;
    end;
end;

method DexiFunct3DChart.RevIndex(aIdx, aSize: Integer; aRev: Boolean): Integer;
begin
  result :=
    if aRev then aSize - aIdx - 1
    else aIdx;
end;

method DexiFunct3DChart.RevIndex(aIdx: Integer; aDimIdx: Integer): Integer;
begin
  result :=
    if aDimIdx <= 0 then RevIndex(aIdx, fAttribute.Scale.Count, fParameters.Rev0)
    else if aDimIdx = 1 then RevIndex(aIdx, fParameters.Dimension[fParameters.Att1Idx], fParameters.Reversed[fParameters.Att1Idx])
    else if aDimIdx = 2 then RevIndex(aIdx, fParameters.Dimension[fParameters.Att2Idx], fParameters.Reversed[fParameters.Att2Idx])
    else aIdx;
end;

method DexiFunct3DChart.RevValue(aValue: Float; aSize: Integer; aRev: Boolean): Float;
begin
  result :=
    if aRev then aSize - aValue - 1
    else aValue;
end;

method DexiFunct3DChart.RevValue(aValue: Float; aDimIdx: Integer): Float;
begin
  result :=
    if aDimIdx <= 0 then RevValue(aValue, fAttribute.Scale.Count, fParameters.Rev0)
    else if aDimIdx = 1 then RevValue(aValue, fParameters.Dimension[fParameters.Att1Idx], fParameters.Reversed[fParameters.Att1Idx])
    else if aDimIdx = 2 then RevValue(aValue, fParameters.Dimension[fParameters.Att2Idx], fParameters.Reversed[fParameters.Att2Idx])
    else aValue;
end;

method DexiFunct3DChart.FromDexiToDrawCoordinates(aValue: Float; aSize: Integer; aRev: Boolean): Float;
begin
  aValue := RevValue(aValue, aSize, aRev);
  result := aValue / (aSize - 1.0);
end;

method DexiFunct3DChart.FromDexiToDrawCoordinates(aValue: Float; aDimIdx: Integer): Float;
begin
  result :=
    if aDimIdx <= 0 then FromDexiToDrawCoordinates(aValue, fAttribute.Scale.Count, fParameters.Rev0)
    else if aDimIdx = 1 then FromDexiToDrawCoordinates(aValue, fParameters.Dimension[fParameters.Att1Idx], fParameters.Reversed[fParameters.Att1Idx])
    else if aDimIdx = 2 then FromDexiToDrawCoordinates(aValue, fParameters.Dimension[fParameters.Att2Idx], fParameters.Reversed[fParameters.Att2Idx])
    else aValue;
end;

method DexiFunct3DChart.MakeMap: MapRangeToRectangle;
begin
  if not (fParameters.OverlayLinear or fParameters.OverlayMultilinear or fParameters.OverlayQQ or fParameters.OverlayQQ2) then
    exit new MapRangeToRectangle(ChartArea, fParameters.HorizontalRotation, fParameters.VerticalRotation);
  var lMap := new MapRangeToRectangle(ChartArea, fParameters.HorizontalRotation, fParameters.VerticalRotation);
  if fParameters.OverlayQQ or fParameters.OverlayQQ2 then
    begin
      var lDim := fParameters.Dimension[fParameters.Att1Idx];
      var lFrom := Math.Min(lMap.LowX, -0.5/(lDim - 1));
      var lTo := Math.Max(lMap.HighX, (lDim - 0.5)/(lDim - 1));
      lMap.SetXRange(lFrom, lTo);
      lDim := fParameters.Dimension[fParameters.Att2Idx];
      lFrom := Math.Min(lMap.LowY, -0.5/(lDim - 1));
      lTo := Math.Max(lMap.HighY, (lDim - 0.5)/(lDim - 1));
      lMap.SetYRange(lFrom, lTo);
      lDim := fAttribute.Scale.Count;
      lFrom := Math.Min(lMap.LowZ, -0.5/(lDim - 1));
      lTo := Math.Max(lMap.HighZ, (lDim - 0.5)/(lDim - 1));
      lMap.SetZRange(lFrom, lTo);
    end;
  if fParameters.OverlayLinear then
    begin
      var lLowZ := lMap.LowZ;
      var lHighZ := lMap.HighZ;
      var lDim := fAttribute.Scale.Count;
      for r := 0 to fFunct.Count - 1 do
        begin
          var lArgs := fFunct.ArgValues[r];
          var lValue := QQ1.Regression(lArgs)/(lDim - 1);
          lLowZ := Math.Min(lLowZ, lValue);
          lHighZ := Math.Max(lHighZ, lValue);
        end;
      lMap.SetZRange(lLowZ, lHighZ);
    end;
  result := lMap;
end;

method DexiFunct3DChart.Measure;
const
  MeasureText = 'Tj';
begin
  inherited Measure;
  fChartRect := new Rectangle(Border.Left, Border.Top, Width - Border.Left - Border.Right, Height - Border.Top - Border.Bottom);
  if fChartRect.Width < MinChartRectWidth then
    fChartRect.Width := MinChartRectWidth;
  if fChartRect.Height < MinChartRectHeight then
    fChartRect.Height := MinChartRectHeight;
  fAttTextHeight := MeasureHeight(MeasureText, AttFont);
  fValTextHeight := MeasureHeight(MeasureText, ValFont);
  var lHorizontalOffset := AttValTextWidth;
  var lTopOffset := fAttTextHeight + 2 * AttGap + PointRadius + 1;
  var lBottomOffset := fValTextHeight + Math.Max(PointRadius + 1, ValGap);
  ChartArea := new Rectangle(ChartRect.X + lHorizontalOffset, ChartRect.Y + lTopOffset, ChartRect.Width - 2 * lHorizontalOffset, ChartRect.Height - lTopOffset - lBottomOffset);
  GridArea := ChartArea;
  fMap3D := MakeMap;
end;

method DexiFunct3DChart.CalculateAttValTextWidth: Integer;
begin
  var lGap := Math.Max(ValGap, AttGap);
  result := PointRadius + 1;
  for i := 0 to fAttribute.InpCount - 1 do
    if (i = fParameters.Att1Idx) or (i = fParameters.Att2Idx) then
      begin
        result := Math.Max(result, MeasureWidth(fAttribute.Inputs[i].Name, AttFont));
        var lScale := DexiDiscreteScale(fAttribute.Inputs[i].Scale);
        if lScale <> nil then
          for v := 0 to lScale.Count - 1 do
            result := Math.Max(result, MeasureWidth(lScale.Names[v], ValFont));
      end;
  result := result + lGap;
end;

method DexiFunct3DChart.DrawChartArea;
begin
end;

method DexiFunct3DChart.DrawAttNames;
begin
  var lPoint := ProjPoint(1, 1, 1);
  DrawText(fAttribute.Name, AttFont, lPoint.X, ChartRect.Y + AttGap, HorizontalAlignment.Center, HorizontalAlignment.Left);
  lPoint := ProjPoint(0.5, 0, 0);
  DrawText(fAttribute.Inputs[fParameters.Att1Idx].Name, AttFont,
    ChartRect.X + AttTextHeight, lPoint.Y, HorizontalAlignment.Left, HorizontalAlignment.Center);
  lPoint := ProjPoint(0, 0.5, 0);
  DrawText(fAttribute.Inputs[fParameters.Att2Idx].Name, AttFont,
    ChartRect.Right - AttTextHeight, lPoint.Y, HorizontalAlignment.Right, HorizontalAlignment.Center);
end;

method DexiFunct3DChart.DrawGrid;
begin
  using lPen := Drawing.GridPenData.NewPen do
    begin
      // X1 grid
      var lCount := fParameters.Dimension[fParameters.Att1Idx];
      if lCount > 1 then
        begin
          var lStep := 1.0 / (lCount - 1);
          for i := 1 to lCount - 2 do
            DrawLine(i * lStep, 0, 0, i * lStep, 1, 0, lPen);
        end;
      // X2 grid
      lCount := fParameters.Dimension[fParameters.Att2Idx];
      if lCount > 1 then
        begin
          var lStep := 1.0 / (lCount - 1);
          for i := 1 to lCount - 2 do
            DrawLine(0, i * lStep, 0, 1, i * lStep, 0, lPen);
        end;
      // X2 grid
      lCount := fAttribute.Scale.Count;
      if lCount > 1 then
        begin
          var lStep := 1.0 / (lCount - 1);
          for i := 1 to lCount - 2 do
            begin
              DrawLine(1, 0, i * lStep, 1, 1, i * lStep, lPen);
              DrawLine(0, 1, i * lStep, 1, 1, i * lStep, lPen);
            end;
        end;
    end;
  using lPen := Drawing.BorderPenData.NewPen do
    begin
      DrawLine(0, 0, 0, 1, 0, 0, lPen);
      DrawLine(0, 0, 0, 0, 1, 0, lPen);
      DrawLine(1, 0, 0, 1, 0, 1, lPen);
      DrawLine(0, 1, 0, 0, 1, 1, lPen);
      DrawLine(1, 1, 0, 1, 1, 1, lPen);
      DrawLine(1, 0, 0, 1, 1, 0, lPen);
      DrawLine(0, 1, 0, 1, 1, 0, lPen);
      DrawLine(1, 0, 1, 1, 1, 1, lPen);
      DrawLine(0, 1, 1, 1, 1, 1, lPen);
    end;
end;

method DexiFunct3DChart.DrawScales;
begin
  // X1 scale
  var lScale := DexiDiscreteScale(fAttribute.Inputs[fParameters.Att1Idx].Scale);
  var lCount := lScale.Count;
  if lCount > 1 then
    begin
      var lStep := 1.0 / (lCount - 1);
      for i := 0 to lCount - 1 do
        begin
          var x := RevIndex(i, 1);
          var lPoint := ProjPoint(i * lStep, 0, 0);
          DrawText(lScale.Names[x], ValFont, lPoint.X - TickLength - ScaleGap, lPoint.Y, HorizontalAlignment.Right, HorizontalAlignment.Left);
        end;
    end;
  // X2 scale
  lScale := DexiDiscreteScale(fAttribute.Inputs[fParameters.Att2Idx].Scale);
  lCount := lScale.Count;
  if lCount > 1 then
    begin
      var lStep := 1.0 / (lCount - 1);
      for i := 0 to lCount - 1 do
        begin
          var x := RevIndex(i, 2);
          var lPoint := ProjPoint(0, i * lStep, 0);
          DrawText(lScale.Names[x], ValFont, lPoint.X + TickLength + ScaleGap, lPoint.Y, HorizontalAlignment.Left, HorizontalAlignment.Left);
        end;
    end;
  // Y scale
  lScale := AttScale;
  lCount := lScale.Count;
  if lCount > 1 then
    begin
      var lStep := 1.0 / (lCount - 1);
      for i := 0 to lCount - 1 do
        begin
          var x := RevIndex(i, 0);
          var lPoint := ProjPoint(0, 1, i * lStep);
          if i = 0 then
            lPoint.Y := lPoint.Y - ValTextHeight div 2;
          DrawText(lScale.Names[x], ValFont, lPoint.X + TickLength + ScaleGap, lPoint.Y, HorizontalAlignment.Left, HorizontalAlignment.Right);
        end;
    end;
end;

method DexiFunct3DChart.DrawPoints(aPoints: Boolean);
begin
  var lArgs := Utils.CopyIntArray(fParameters.Match);
  var lScale := AttScale;
  for i1 := 0 to fParameters.Dimension[fParameters.Att1Idx] - 1 do
    for i2 := 0 to fParameters.Dimension[fParameters.Att2Idx] - 1 do
      begin
        var x1 := RevIndex(i1, 1);
        var x2 := RevIndex(i2, 2);
        lArgs[fParameters.Att1Idx] := x1;
        lArgs[fParameters.Att2Idx] := x2;
        var lX1 := i1 / (fParameters.Dimension[fParameters.Att1Idx] - 1.0);
        var lX2 := i2 / (fParameters.Dimension[fParameters.Att2Idx] - 1.0);
        var lRule := fFunct.IndexOfRule(lArgs);
        var lValue := fFunct.RuleValue[lRule];
        if not fFunct.RuleDefined[lRule] then
          continue;
        if lValue.IsFloat then
          continue;
        if aPoints then
          begin
            var lSet := lValue.AsIntSet;
            for vx := low(lSet) to high(lSet) do
              begin
                var v := lSet[vx];
                var lColorInfo :=
                  if not fFunct.RuleEntered[lRule] then Model.ChartParameters.UndefColorInfo
                  else if lScale.IsBad(v) then Model.Settings.BadColor
                  else if lScale.IsGood(v) then Model.Settings.GoodColor
                  else Model.Settings.NeutralColor;
                var lColor := Color.FromArgb(lColorInfo.ARGB);
                using lBrush := new SolidBrush(lColor) do
                  begin
                    var y := RevIndex(v, 0);
                    var lY := y / (lScale.Count - 1.0);
                    var lPoint := ProjPoint(lX1, lX2, lY);
                    Graphics.FillEllipse(lBrush, lPoint.X - PointRadius, lPoint.Y - PointRadius, 2 * PointRadius, 2 * PointRadius);
                  end;
              end
          end
        else
          begin
            if lValue.IsSingle then
              continue;
            var lLow := fFunct.RuleValLow[lRule];
            var lHigh := fFunct.RuleValHigh[lRule];
            var y1 := RevIndex(lLow, 0);
            var y2 := RevIndex(lHigh, 0);
            var lY1 := y1 / (lScale.Count - 1.0);
            var lY2 := y2 / (lScale.Count - 1.0);
            var lPt1 := ProjPoint(lX1, lX2, lY1);
            var lPt2 := ProjPoint(lX1, lX2, lY2);
            using lPen := new Pen(Color.LightGray, PillarWidth) do
              DrawLine(lPt1, lPt2, lPen);
          end;
      end;
end;

method DexiFunct3DChart.DrawConnection(a1f, a1t, a2f, a2t: Integer);
begin
  var lX1f := a1f / (fParameters.Dimension[fParameters.Att1Idx] - 1.0);
  var lX2f := a2f / (fParameters.Dimension[fParameters.Att2Idx] - 1.0);
  var lArgs1 := Utils.CopyIntArray(fParameters.Match);
  lArgs1[fParameters.Att1Idx] := RevIndex(a1f, 1);
  lArgs1[fParameters.Att2Idx] := RevIndex(a2f, 2);
  var lX1t := a1t / (fParameters.Dimension[fParameters.Att1Idx] - 1.0);
  var lX2t := a2t / (fParameters.Dimension[fParameters.Att2Idx] - 1.0);
  var lArgs2 := Utils.CopyIntArray(fParameters.Match);
  lArgs2[fParameters.Att1Idx] := RevIndex(a1t, 1);
  lArgs2[fParameters.Att2Idx] := RevIndex(a2t, 2);
  var lRule1 := fFunct.IndexOfRule(lArgs1);
  var lRule2 := fFunct.IndexOfRule(lArgs2);
  if not fFunct.RuleDefined[lRule1] or not fFunct.RuleDefined[lRule2] then
    exit;
  var lLow1 := fFunct.RuleValLow[lRule1];
  var lLow2 := fFunct.RuleValLow[lRule2];
  var lHigh1 := fFunct.RuleValHigh[lRule1];
  var lHigh2 := fFunct.RuleValHigh[lRule2];
  using lPen := Drawing.ConnectionPenData.NewPen do
    begin
      var y1 := RevIndex(lLow1, 0);
      var y2 := RevIndex(lLow2, 0);
      var lY1 := y1 / (AttScale.Count - 1.0);
      var lY2 := y2 / (AttScale.Count - 1.0);
      DrawLine(ProjPoint(lX1f, lX2f, lY1), ProjPoint(lX1t, lX2t, lY2), lPen);
      if (lLow1 <> lHigh1) or (lLow2 <> lHigh2) then
        begin
          y1 := RevIndex(lHigh1, 0);
          y2 := RevIndex(lHigh2, 0);
          lY1 := y1 / (AttScale.Count - 1.0);
          lY2 := y2 / (AttScale.Count - 1.0);
          DrawLine(ProjPoint(lX1f, lX2f, lY1), ProjPoint(lX1t, lX2t, lY2), lPen);
        end;
    end;
end;

method DexiFunct3DChart.DrawConnections;
begin
  for i1 := 0 to fParameters.Dimension[fParameters.Att1Idx] - 1 do
    for i2 := 1 to fParameters.Dimension[fParameters.Att2Idx] - 1 do
      DrawConnection(i1, i1, i2 - 1, i2);
  for i2 := 0 to fParameters.Dimension[fParameters.Att2Idx] - 1 do
    for i1 := 1 to fParameters.Dimension[fParameters.Att1Idx] - 1 do
      DrawConnection(i1, i1 - 1, i2, i2);
end;

method DexiFunct3DChart.DrawLinearApproximation;
begin
  using lPenWide := new Pen(fParameters.LinearColor, 2) do
  using lPenNarrow := new Pen(fParameters.LinearColor, 1) do
    DrawFunct(@LinearApproximation,
      0, fParameters.Dimension[fParameters.Att1Idx] - 1, 0, fParameters.Dimension[fParameters.Att2Idx] - 1, 0.5, lPenWide, lPenNarrow);
end;

method DexiFunct3DChart.DrawMultilinearInterpolation;
begin
  using lPenWide := new Pen(fParameters.MultilinearColor, 2) do
  using lPenNarrow := new Pen(fParameters.MultilinearColor, 1) do
    DrawFunct(@MultilinearInterpolation,
      0, fParameters.Dimension[fParameters.Att1Idx] - 1, 0, fParameters.Dimension[fParameters.Att2Idx] - 1, 0.25, lPenWide, lPenNarrow);
end;

method DexiFunct3DChart.DrawQ(aModel: DexiQModel; aPenBorder, aPenInternal: Pen);
begin
  for r := 0 to fFunct.Count - 1 do
    if fFunct.RuleDefined[r] then
      begin
        var lArgs := fFunct.ArgValues[r];
        if fParameters.ArgsMatch(lArgs) then
          for c := fFunct.RuleValLow[r] to fFunct.RuleValHigh[r] do
            DrawModelPoint(aModel, fFunct.ArgValues[r], c, aPenBorder, aPenInternal);
      end;
end;

method DexiFunct3DChart.DrawQQ1;
begin
  using lPenFront := new Pen(fParameters.QQColor, 2) do
  using lPenBack := new Pen(fParameters.QQColor, 1) do
    DrawQ(QQ1, lPenFront, lPenBack);
end;

method DexiFunct3DChart.DrawQQ2;
begin
  using lPenFront := new Pen(fParameters.QPColor, 2) do
  using lPenBack := new Pen(fParameters.QPColor, 1) do
    DrawQ(QQ2, lPenFront, lPenBack);
end;

method DexiFunct3DChart.DrawOverlays;
begin
  if fParameters.OverlayLinear and fFunct.CanUseWeights then
    DrawLinearApproximation;
  if fParameters.OverlayMultilinear and fFunct.CanUseMultilinear then
    DrawMultilinearInterpolation;
  if fParameters.OverlayQQ and fFunct.CanUseWeights then
    DrawQQ1;
  if fParameters.OverlayQQ2 then
    DrawQQ2;
end;

method DexiFunct3DChart.DrawFunct;
begin
  DrawPoints(false);
  DrawConnections;
  DrawOverlays;
  DrawPoints(true);
end;

method DexiFunct3DChart.DrawChart;
begin
  inherited DrawChart;
  using lBrush := new SolidBrush(BackgroundColor) do
    Graphics.FillRectangle(lBrush, 0, 0, Width, Height);
  DrawChartArea;
  DrawGrid;
  DrawScales;
  DrawFunct;
  DrawAttNames;
end;

{$ENDREGION}

end.
