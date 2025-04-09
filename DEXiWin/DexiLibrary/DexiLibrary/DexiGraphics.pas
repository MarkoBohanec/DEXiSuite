// DexiGraphics.pas is part of
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
// DexiGraphics.pas implements platform-independent classess needed for handling charts and
// chart components in platform-dependent GUIs:
// - DexiChartParameters: extension of DexiSelection that defines chart parameters, such as:
//   chart borders, colors, line widths, fonts, minimal gaps between chart elements, etc.
// - DexiAltValueRange: determining scale ranges from data about alternatives.
// - AltValueInfo: summarizes attribute value extent in a form suitable for chart display.
// - ScatterAlternative and ScatterPoint: helper classes for scatter charts.
// - DexiFunct3DChartParameters: parameters for 3D-drawings of DexiTabularFunction.
// ----------

namespace DexiLibrary;

interface

 uses
  RemObjects.Elements.RTL,
  DexiUtils;

type
  DexiMultiAttChartType = public enum (Radar, RadarGrid, Linear);

type
  DexiChartParameters = public class (DexiSelection)
  private
    fMultiChartType: DexiMultiAttChartType;
    fGridX: Integer;
    fGridY: Integer;
    fBorder: ImgBorder;
    fBackgroundColorInfo: ColorInfo;
    fAreaColorInfo: ColorInfo;
    fLightNeutralColorInfo: ColorInfo;
    fUndefColorInfo: ColorInfo;
    fAttFontInfo: FontInfo;
    fAltFontInfo: FontInfo;
    fValFontInfo: FontInfo;
    fLineWidth: Float;
    fTransparentAlpha: Byte;
    fAltGap: Integer;
    fAttGap: Integer;
    fScaleGap: Integer;
    fValGap: Integer;
    fLineGap: Integer;
    fTickLength: Integer;
    fLegendWidth: Integer;
    fLegendHeight: Integer;
    fLegendGap: Integer;
    fMinSideGap: Integer;
    fBarExtent: Float;
    fScatterPointRadius: Integer;
    fRadarPointRadius: Integer;
    fAbaconPointRadius: Integer;
  public
    constructor (aSettings: DexiSettings := nil);
    constructor (aParameters: DexiChartParameters);
    property MultiChartType: DexiMultiAttChartType read fMultiChartType write fMultiChartType;
    property GridX: Integer read fGridX write fGridX;
    property GridY: Integer read fGridY write fGridY;
    property GridSize: Integer read fGridX * fGridY;
    property Border: ImgBorder read fBorder write fBorder;
    property BackgroundColorInfo: ColorInfo read fBackgroundColorInfo write fBackgroundColorInfo;
    property AreaColorInfo: ColorInfo read fAreaColorInfo write fAreaColorInfo;
    property LightNeutralColorInfo: ColorInfo read fLightNeutralColorInfo write fLightNeutralColorInfo;
    property UndefColorInfo: ColorInfo read fUndefColorInfo write fUndefColorInfo;
    property AttFontInfo: FontInfo read fAttFontInfo write fAttFontInfo;
    property AltFontInfo: FontInfo read fAltFontInfo write fAltFontInfo;
    property ValFontInfo: FontInfo read fValFontInfo write fValFontInfo;
    property LineWidth: Float read fLineWidth write fLineWidth;
    property TransparentAlpha: Byte read fTransparentAlpha write fTransparentAlpha;
    property AltGap: Integer read fAltGap write fAltGap;
    property AttGap: Integer read fAttGap write fAttGap;
    property ScaleGap: Integer read fScaleGap write fScaleGap;
    property ValGap: Integer read fValGap write fValGap;
    property LineGap: Integer read fLineGap write fLineGap;
    property TickLength: Integer read fTickLength write fTickLength;
    property LegendWidth: Integer read fLegendWidth write fLegendWidth;
    property LegendHeight: Integer read fLegendHeight write fLegendHeight;
    property LegendGap: Integer read fLegendGap write fLegendGap;
    property MinSideGap: Integer read fMinSideGap write fMinSideGap;
    property BarExtent: Float read fBarExtent write fBarExtent;
    property ScatterPointRadius: Integer read fScatterPointRadius write fScatterPointRadius;
    property RadarPointRadius: Integer read fRadarPointRadius write fRadarPointRadius;
    property AbaconPointRadius: Integer read fAbaconPointRadius write fAbaconPointRadius;
  end;

type
  DexiAltValueRange = public class
  private
    fAttribute: DexiAttribute;
    fDefined: Boolean;
    fMinValue: Float;
    fMaxValue: Float;
    fTicks: List<String>;
    fTickSpacing: Float;
  public
    constructor (aAttribute: DexiAttribute; aAlternatives: IDexiAlternatives);
    property Attribute: DexiAttribute read fAttribute;
    property Defined: Boolean read fDefined;
    property MinValue: Float read fMinValue;
    property MaxValue: Float read fMaxValue;
    property Ticks: ImmutableList<String> read fTicks;
    property TickCount: Integer read fTicks.Count;
    property TickSpacing: Float read fTickSpacing;
  end;

type
  AltValueInfo = public class
  public
    Indices: IntArray;
    Values: FltArray;
    Memberships: FltArray;
    constructor (aFloat: Float);
    constructor (aDistr: Distribution; aCount: Integer);
    property Count: Integer read length(Indices);
  end;

type
  ScatterAlternative = public class
  private
    fAlternative: Integer;
    fPointIndex: Integer;
  public
    constructor (aAlt: Integer; aPoint: Integer);
    property Alternative: Integer read fAlternative;
    property PointIndex: Integer read fPointIndex;
  end;

type
  ScatterPoint = public class
  private
    fValueX: Float;
    fValueY: Float;
    fAlternatives: List<ScatterAlternative>;
  public
    constructor (aValueX, aValueY: Float);
    method AddAlternative(aAlt: Integer;  aPoint: Integer);
    property ValueX: Float read fValueX;
    property ValueY: Float read fValueY;
    property Alternatives: ImmutableList<ScatterAlternative> read fAlternatives;
  end;

type
  ScatterPoints = public class
  private
    fPointList: List<ScatterPoint>;
  public
    constructor;
    method FindPoint(aValueX, aValueY: Float): ScatterPoint;
    method IncludePoint(aValueX, aValueY: Float; aAlt: Integer; aPoint: Integer);
    property PointList: ImmutableList<ScatterPoint> read fPointList;
    property Tolerance: Float := Utils.FloatEpsilon;
  end;

type
  DexiFunct3DChartParameters = public class
  private
    fDefHorizontal: Float := 225.0;
    fDefVertical: Float := 15.0;
    fDimension: IntArray;
    fAtt1Idx: Integer;
    fAtt2Idx: Integer;
    fRev0: Boolean;
    fReversed: array of Boolean;
    fMatch: IntArray;
    fHorizontalRotation: Float;
    fVerticalRotation: Float;
    fBorder: ImgBorder;
    fBackgroundColorInfo: ColorInfo;
    fAreaColorInfo: ColorInfo;
    fBadColorInfo: ColorInfo;
    fNeutralColorInfo: ColorInfo;
    fGoodColorInfo: ColorInfo;
    fNotEnteredColorInfo: ColorInfo;
    fAttFontInfo: FontInfo;
    fValFontInfo: FontInfo;
    fLineWidth: Float;
    fAttGap: Integer;
    fScaleGap: Integer;
    fValGap: Integer;
    fTickLength: Integer;
    fPointRadius: Integer;
    fPillarWidth: Integer;
    fOverlayLinear: Boolean;
    fOverlayMultilinear: Boolean;
    fOverlayQQ: Boolean;
    fOverlayQQ2: Boolean;
  private
    method SetAtt1Idx(aIdx: Integer);
    method SetAtt2Idx(aIdx: Integer);
  public
    constructor (aDimension: IntArray);
    constructor (aParameters: DexiFunct3DChartParameters);
    method SetAttIndices(aIdx1, aIdx2: Integer);
    method SetRotation(aHorizontal, aVertical: Float);
    method ResetRotation;
    method ResetMatch;
    method NextChart;
    method PrevChart;
    method ExchangeArguments;
    method ArgsMatch(aArgs: IntArray): Boolean;
    property Dimension: IntArray read fDimension;
    property Args: Integer read length(fDimension);
    property Att1Idx: Integer read fAtt1Idx write SetAtt1Idx;
    property Att2Idx: Integer read fAtt2Idx write SetAtt2Idx;
    property Rev0: Boolean read fRev0 write fRev0;
    property Reversed: array of Boolean read fReversed;
    property Match: IntArray read fMatch write fMatch;
    property HorizontalRotation: Float read fHorizontalRotation write fHorizontalRotation;
    property VerticalRotation: Float read fVerticalRotation write fVerticalRotation;
    property Border: ImgBorder read fBorder write fBorder;
    property BackgroundColorInfo: ColorInfo read fBackgroundColorInfo write fBackgroundColorInfo;
    property AreaColorInfo: ColorInfo read fAreaColorInfo write fAreaColorInfo;
    property BadColorInfo: ColorInfo read fBadColorInfo write fBadColorInfo;
    property NeutralColorInfo: ColorInfo read fNeutralColorInfo write fNeutralColorInfo;
    property GoodColorInfo: ColorInfo read fGoodColorInfo write fGoodColorInfo;
    property NotEnteredColorInfo: ColorInfo read fNotEnteredColorInfo write fNotEnteredColorInfo;
    property AttFontInfo: FontInfo read fAttFontInfo write fAttFontInfo;
    property ValFontInfo: FontInfo read fValFontInfo write fValFontInfo;
    property LineWidth: Float read fLineWidth write fLineWidth;
    property AttGap: Integer read fAttGap write fAttGap;
    property ScaleGap: Integer read fScaleGap write fScaleGap;
    property ValGap: Integer read fValGap write fValGap;
    property TickLength: Integer read fTickLength write fTickLength;
    property PointRadius: Integer read fPointRadius write fPointRadius;
    property PillarWidth: Integer read fPillarWidth write fPillarWidth;
    property OverlayLinear: Boolean read fOverlayLinear write fOverlayLinear;
    property OverlayMultilinear: Boolean read fOverlayMultilinear write fOverlayMultilinear;
    property OverlayQQ: Boolean read fOverlayQQ write fOverlayQQ;
    property OverlayQQ2: Boolean read fOverlayQQ2 write fOverlayQQ2;
  end;

implementation

{$IFDEF JAVA}
  {$HIDE W0}
{$ENDIF}

{$REGION DexiChartParameters}

constructor DexiChartParameters(aSettings: DexiSettings := nil);
begin
  inherited constructor;
  fMultiChartType := DexiMultiAttChartType.Radar;
  fGridX := 1;
  fGridY := 1;
  fBorder := new ImgBorder(10, 10, 10, 10);
  fBackgroundColorInfo := new ColorInfo('FFFFFF');
  fAreaColorInfo := new ColorInfo('FFFFFF');
  fLightNeutralColorInfo := new ColorInfo('909090');
  fUndefColorInfo := new ColorInfo('808080');
  fAttFontInfo := FontInfo.DefaultFont;
  fAltFontInfo := FontInfo.DefaultFont;
  fValFontInfo := FontInfo.DefaultFont;
  fLineWidth := 2;
  fTransparentAlpha := 50;
  fAltGap := 5;
  fAttGap := 5;
  fScaleGap := 5;
  fValGap := 5;
  fLineGap := 2;
  fTickLength := 5;
  fLegendWidth := 12;
  fLegendHeight := 8;
  fLegendGap := 5;
  fMinSideGap := 20;
  fBarExtent := 0.5;
  fScatterPointRadius := 10;
  fRadarPointRadius := 3;
  fAbaconPointRadius := 5;
end;

constructor DexiChartParameters(aParameters: DexiChartParameters);
begin
  inherited constructor;
  fSelectedAttributes :=
    if aParameters.SelectedAttributes = nil then nil
    else new List<DexiAttribute>(aParameters.SelectedAttributes);
  fSelectedAlternatives :=
    if aParameters.SelectedAlternatives = nil then nil
    else new SetOfInt(aParameters.SelectedAlternatives);
  fMultiChartType := aParameters.MultiChartType;
  fGridX := aParameters.GridX;
  fGridY := aParameters.GridY;
  fBorder := new ImgBorder(aParameters.Border);
  fBackgroundColorInfo := new ColorInfo(aParameters.BackgroundColorInfo);
  fAreaColorInfo := new ColorInfo(aParameters.AreaColorInfo);
  fLightNeutralColorInfo := new ColorInfo(aParameters.LightNeutralColorInfo);
  fUndefColorInfo := new ColorInfo(aParameters.UndefColorInfo);
  fAttFontInfo := new FontInfo(aParameters.AttFontInfo);
  fAltFontInfo := new FontInfo(aParameters.AltFontInfo);
  fValFontInfo := new FontInfo(aParameters.ValFontInfo);
  fLineWidth := aParameters.LineWidth;
  fTransparentAlpha := aParameters.TransparentAlpha;
  fAltGap := aParameters.AltGap;
  fAttGap := aParameters.AttGap;
  fScaleGap := aParameters.ScaleGap;
  fValGap := aParameters.ValGap;
  fLineGap := aParameters.LineGap;
  fTickLength := aParameters.TickLength;
  fLegendWidth := aParameters.LegendWidth;
  fLegendHeight := aParameters.LegendHeight;
  fLegendGap := aParameters.LegendGap;
  fMinSideGap := aParameters.MinSideGap;
  fBarExtent := aParameters.BarExtent;
  fScatterPointRadius := aParameters.ScatterPointRadius;
  fRadarPointRadius := aParameters.RadarPointRadius;
  fAbaconPointRadius := aParameters.AbaconPointRadius;
end;

{$ENDREGION}

{$REGION DexiAltValueRange}

constructor DexiAltValueRange(aAttribute: DexiAttribute; aAlternatives: IDexiAlternatives);
begin
  fDefined := false;
  fAttribute := aAttribute;
  if (fAttribute:Scale = nil) or (aAlternatives = nil) or (aAlternatives.AltCount = 0) then
    exit;
  if fAttribute.Scale is DexiDiscreteScale then
    begin
      var lScale := DexiDiscreteScale(fAttribute.Scale);
      if lScale.Count > 0 then
        begin
          fMinValue := lScale.LowInt;
          fMaxValue := lScale.HighInt;
          fTicks := lScale.NameList;
          fTickSpacing := 1.0;
          fDefined := true;
        end;
    end
  else if fAttribute.Scale is DexiContinuousScale then
    begin
//      var lScale := DexiContinuousScale(fAttribute.Scale);
      var lMinValue := Consts.PositiveInfinity;
      var lMaxValue := Consts.NegativeInfinity;
      for lAlt := 0 to aAlternatives.AltCount - 1 do
        begin
          var lValue := aAlternatives.AltValue[lAlt, aAttribute];
          if DexiValue.ValueIsDefined(lValue) then
            begin
              lMinValue := Math.Min(lMinValue, lValue.LowFloat);
              lMaxValue := Math.Max(lMaxValue, lValue.HighFloat);
            end;
        end;
      fDefined := not Consts.IsInfinity(lMinValue) and not Consts.IsInfinity(lMaxValue) and
                  not Consts.IsNaN(lMinValue) and not Consts.IsNaN(lMaxValue);
      if fDefined then
        begin
          var lScaleMaker := new ScaleMaker(lMinValue, lMaxValue);
          fMinValue := lScaleMaker.NiceMin;
          fMaxValue := lScaleMaker.NiceMax;
          fTickSpacing := lScaleMaker.TickSpacing;
          fTicks := new List<String>;
          var lNum := fMinValue;
          while lNum < fMaxValue + Utils.FloatEpsilon do
            begin
              fTicks.Add(Utils.FltToStr(lNum, 2));
              lNum := lNum + fTickSpacing;
            end;
        end;
    end;
end;

{$ENDREGION}

{$REGION AltValueInfo}

constructor AltValueInfo(aFloat: Float);
begin
  Indices := Utils.NewIntArray(1, 0);
  Values := Utils.NewFltArray(1, aFloat);
  Memberships := Utils.NewFltArray(1, 1.0);
end;

constructor AltValueInfo(aDistr: Distribution; aCount: Integer);
begin
  var lCount := 0;
  for lIdx := 0 to aCount - 1 do
    begin
      var lMem := DexiUtils.Values.GetDistribution(aDistr, lIdx);
      if lMem > 0.0 then
        inc(lCount);
    end;
  Indices := new Integer[lCount];
  Values := new Float[lCount];
  Memberships := new Float[lCount];
  var lOutIdx := 0;
  for lIdx := 0 to aCount - 1 do
    begin
      var lMem := DexiUtils.Values.GetDistribution(aDistr, lIdx);
      if lMem > 0.0 then
        begin
          Indices[lOutIdx] := lIdx;
          Values[lOutIdx] := lIdx;
          Memberships[lOutIdx] := lMem;
          inc(lOutIdx);
        end;
    end;
end;

{$ENDREGION}

{$REGION ScatterAlternative}

constructor ScatterAlternative(aAlt: Integer; aPoint: Integer);
begin
  inherited constructor;
  fAlternative := aAlt;
  fPointIndex := aPoint;
end;

{$ENDREGION}

{$REGION ScatterPoint}

constructor ScatterPoint(aValueX, aValueY: Float);
begin
  fValueX := aValueX;
  fValueY := aValueY;
  fAlternatives := new List<ScatterAlternative>;
end;

method ScatterPoint.AddAlternative(aAlt: Integer; aPoint: Integer);
begin
  fAlternatives.Add(new ScatterAlternative(aAlt, aPoint));
end;

{$ENDREGION}

{$REGION ScatterPoints}

constructor ScatterPoints;
begin
  inherited constructor;
  fPointList := new List<ScatterPoint>;
end;

method ScatterPoints.FindPoint(aValueX, aValueY: Float): ScatterPoint;
begin
  result := nil;
  for each lPoint in fPointList do
    if (Math.Abs(lPoint.ValueX - aValueX) < Tolerance) and (Math.Abs(lPoint.ValueY - aValueY) < Tolerance) then
      exit lPoint;
end;

method ScatterPoints.IncludePoint(aValueX, aValueY: Float; aAlt: Integer; aPoint: Integer);
begin
  var lPoint := FindPoint(aValueX, aValueY);
  if lPoint = nil then
    begin
      lPoint := new ScatterPoint(aValueX, aValueY);
      fPointList.Add(lPoint);
    end;
  lPoint.AddAlternative(aAlt, aPoint);
end;

{$ENDREGION}

{$REGION DexiFunct3DChartParameters}

constructor DexiFunct3DChartParameters(aDimension: IntArray);
require
  length(aDimension) >= 2;
begin
  inherited constructor;
  fDimension := aDimension;
  fAtt1Idx := 0;
  fAtt2Idx := 1;
  ResetMatch;
  fRev0 := false;
  fReversed := Utils.NewBoolArray(length(aDimension));
  ResetRotation;
  fBorder := new ImgBorder(10, 10, 10, 10);
  fBackgroundColorInfo := new ColorInfo('FFFFFF');
  fAreaColorInfo := new ColorInfo('FFFFFF');
  fBadColorInfo := new ColorInfo('FF0000');
  fNeutralColorInfo := new ColorInfo('000080');
  fGoodColorInfo := new ColorInfo('008000');
  fNotEnteredColorInfo := new ColorInfo('808080');
  fAttFontInfo := FontInfo.DefaultFont;
  fValFontInfo := FontInfo.DefaultFont;
  fLineWidth := 2;
  fAttGap := 5;
  fScaleGap := 5;
  fValGap := 5;
  fTickLength := 5;
  fPointRadius := 5;
  fPillarWidth := 3;
  fOverlayLinear := false;
  fOverlayMultilinear := false;
  fOverlayQQ := false;
  fOverlayQQ2 := false;
end;

constructor DexiFunct3DChartParameters(aParameters: DexiFunct3DChartParameters);
begin
  inherited constructor;
  fDimension := Utils.CopyIntArray(aParameters.Dimension);
  fAtt1Idx := aParameters.Att1Idx;
  fAtt2Idx := aParameters.Att2Idx;
  ResetMatch;
  fRev0 := aParameters.Rev0;
  fReversed := Utils.CopyBoolArray(aParameters.Reversed);
  ResetRotation;
  fBorder := new ImgBorder(aParameters.Border);
  fBackgroundColorInfo := new ColorInfo(aParameters.BackgroundColorInfo);
  fAreaColorInfo := new ColorInfo(aParameters.AreaColorInfo);
  fBadColorInfo := new ColorInfo(aParameters.BadColorInfo);
  fNeutralColorInfo := new ColorInfo(aParameters.NeutralColorInfo);
  fGoodColorInfo := new ColorInfo(aParameters.GoodColorInfo);
  fNotEnteredColorInfo := new ColorInfo(aParameters.NotEnteredColorInfo);
  fAttFontInfo := new FontInfo(aParameters.AttFontInfo);
  fValFontInfo := new FontInfo(aParameters.ValFontInfo);
  fLineWidth := aParameters.LineWidth;
  fAttGap := aParameters.AttGap;
  fScaleGap := aParameters.ScaleGap;
  fValGap := aParameters.ValGap;
  fTickLength := aParameters.TickLength;
  fPointRadius := aParameters.PointRadius;
  fPillarWidth := aParameters.PillarWidth;
  fOverlayLinear := aParameters.OverlayLinear;
  fOverlayMultilinear := aParameters.OverlayMultilinear;
  fOverlayQQ := aParameters.OverlayQQ;
  fOverlayQQ2 := aParameters.OverlayQQ2;
end;

method DexiFunct3DChartParameters.SetAtt1Idx(aIdx: Integer);
begin
  fAtt1Idx := aIdx;
  ResetMatch;
end;

method DexiFunct3DChartParameters.SetAtt2Idx(aIdx: Integer);
begin
  fAtt2Idx := aIdx;
  ResetMatch;
end;

method DexiFunct3DChartParameters.SetAttIndices(aIdx1, aIdx2: Integer);
begin
  fAtt1Idx := aIdx1;
  fAtt2Idx := aIdx2;
  ResetMatch;
end;

method DexiFunct3DChartParameters.SetRotation(aHorizontal, aVertical: Float);
begin
  fHorizontalRotation := aHorizontal;
  fVerticalRotation := aVertical;
end;

method DexiFunct3DChartParameters.ResetRotation;
begin
  SetRotation(fDefHorizontal, fDefVertical);
end;

method DexiFunct3DChartParameters.ResetMatch;
begin
  fMatch := Utils.NewIntArray(Args);
  if 0 <= fAtt1Idx < Args then
    fMatch[fAtt1Idx] := -1;
  if 0 <= fAtt2Idx < Args then
    fMatch[fAtt2Idx] := -2;
end;

method DexiFunct3DChartParameters.NextChart;
begin
  for i := low(fMatch) to high(fMatch) do
    if fMatch[i] >= 0 then
      begin
        inc(fMatch[i]);
        if fMatch[i] >= fDimension[i] then
          fMatch[i] := 0
        else
          exit;
      end;
end;

method DexiFunct3DChartParameters.PrevChart;
begin
  for i := low(fMatch) to high(fMatch) do
    if fMatch[i] >= 0 then
      begin
        dec(fMatch[i]);
        if fMatch[i] < 0 then
          fMatch[i] := Math.Max(0, fDimension[i] - 1)
        else
          exit;
      end;
end;

method DexiFunct3DChartParameters.ExchangeArguments;
begin
  Utils.SwapInt(var fAtt1Idx, var fAtt2Idx);
end;

method  DexiFunct3DChartParameters.ArgsMatch(aArgs: IntArray): Boolean;
begin
  result := false;
  if length(aArgs) <> length(fMatch) then
    exit;
  for i := low(aArgs) to high(aArgs) do
    if (fMatch[i] >= 0) and (fMatch[i] <> aArgs[i]) then
      exit;
  result := true;
end;

{$ENDREGION}

end.
