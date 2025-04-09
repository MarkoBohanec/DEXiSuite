// FormSettings.pas is part of
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
// FormSettings.pas implements a configurable form for editing user's settings
// ('DexiSettings' and 'DexiChartParameters').
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormSettings.
  /// </summary>
  FormSettings = partial public class(System.Windows.Forms.Form)
  private
    method BtnGoodColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnBadColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnRptFont_Click(sender: System.Object; e: System.EventArgs);
    method EditRptFont_ValueChanged(sender: System.Object; e: System.EventArgs);
    method EditSettings_ValueChanged(sender: System.Object; e: System.EventArgs);
    method BtnUndefinedPoint_Click(sender: System.Object; e: System.EventArgs);
    method BtnNeutralPoint_Click(sender: System.Object; e: System.EventArgs);
    method BtnAreaColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnBackgroundColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnValFont_Click(sender: System.Object; e: System.EventArgs);
    method BtnChartResetFonts_Click(sender: System.Object; e: System.EventArgs);
    method BtnChartAttFont_Click(sender: System.Object; e: System.EventArgs);
    method EditChart_ValueChanged(sender: System.Object; e: System.EventArgs);
    method BtnAltFont_Click(sender: System.Object; e: System.EventArgs);
    method FormSettings_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
  private
    fModel: DexiModel;
    fSettings: DexiSettings;
    fChartParameters: DexiChartParameters;
    fUpdateLevel: Integer;
    fRptFont: Font;
    fBadFont: Font;
    fGoodFont: Font;
    fBadColor: Color;
    fGoodColor: Color;
    fAltFont: Font;
    fAttFont: Font;
    fValFont: Font;
    fBackgroundColor: Color;
    fAreaColor: Color;
    fNeutralColor: Color;
    fUndefinedColor: Color;
  protected
    method Dispose(aDisposing: Boolean); override;
    method DisposeFonts(aFonts: array of Font);
    method BreakToIndex(aBreak: Integer): Integer;
    method IndexToBreak(aBreak, aNumber: Integer): Integer;
    method SettingsToRptFonts;
    method SettingsToChartFontsAndColors;
    method SettingsToData;
    method DataToSettings;
    method ChartParametersToData;
    method DataToChartParameters;
    method UpdateForm;
  public
    constructor;
    method SetForm(aModel: DexiModel);
    property Model: DexiModel read fModel;
    property Settings: DexiSettings read fSettings;
    property ChartParameters: DexiChartParameters read fChartParameters;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormSettings;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fUpdateLevel := 0;

end;

method FormSettings.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormSettings.DisposeFonts(aFonts: array of Font);
begin
  for each lFont in aFonts do
    if lFont <> nil then
      lFont.Dispose;
end;

method FormSettings.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  inc(fUpdateLevel);
  try
    AppUtils.Enable(fSettings.JsonSettings.StructureFormat = DexiJsonStructureFormat.Flat, GrpJsonAttTypes);
    AppUtils.Enable(fSettings.JsonSettings.IncludeModel, GrpJsonModElements, EditJsonModInputs);
    AppUtils.Enable(fSettings.JsonSettings.IncludeAlternatives, GrpJsonAltElements, EditJsonAltInputs);
  finally
    dec(fUpdateLevel);
  end;
end;

method FormSettings.SettingsToRptFonts;
begin
    var lFontData := new FontData(fSettings.ReportFontInfo);
    fRptFont := lFontData.NewFont;
    lFontData.Style := fSettings.BadStyle;
    ChkBadBold.Checked := lFontData.Bold;
    ChkBadItalic.Checked := lFontData.Italic;
    ChkBadUnderline.Checked := lFontData.Underline;
    fBadFont := lFontData.NewFont;
    lFontData.Style := fSettings.GoodStyle;
    ChkGoodBold.Checked := lFontData.Bold;
    ChkGoodItalic.Checked := lFontData.Italic;
    ChkGoodUnderline.Checked := lFontData.Underline;
    fGoodFont := lFontData.NewFont;
    LblRptFont.Font := fRptFont;
    LblRptFont.Text := $'{fRptFont.Name} [{fRptFont.Size}]';
    LblRptBadFont.Font := fBadFont;
    LblRptGoodFont.Font := fGoodFont;
    fBadColor := new ColorData(fSettings.BadColor).NewColor;
    LblRptBadFont.ForeColor := fBadColor;
    fGoodColor := new ColorData(fSettings.GoodColor).NewColor;
    LblRptGoodFont.ForeColor := fGoodColor;
end;

method FormSettings.SettingsToChartFontsAndColors;
begin
    var lFontData := new FontData(fChartParameters.AltFont);
    fAltFont := lFontData.NewFont;
    lFontData := new FontData(fChartParameters.AttFont);
    fAttFont := lFontData.NewFont;
    lFontData := new FontData(fChartParameters.ValFont);
    fValFont := lFontData.NewFont;
    LblAltFont.Font := fAltFont;
    LblAttFont.Font := fAttFont;
    LblValFont.Font := fValFont;
    fBackgroundColor := new ColorData(fChartParameters.BackgroundColorInfo).NewColor;
    fAreaColor := new ColorData(fChartParameters.AreaColorInfo).NewColor;
    fNeutralColor := new ColorData(fChartParameters.LightNeutralColorInfo).NewColor;
    fUndefinedColor := new ColorData(fChartParameters.UndefColorInfo).NewColor;
    PanelBackgroundColor.BackColor := fBackgroundColor;
    PanelAreaColor.BackColor := fAreaColor;
    PanelNeutralPoint.BackColor := fNeutralColor;
    PanelUndefinedPoint.BackColor := fUndefinedColor;
end;

method FormSettings.BreakToIndex(aBreak: Integer): Integer;
begin
  result :=
    case aBreak of
      RptSection.BreakNone: 1;
      RptSection.BreakAll:  2;
      RptSection.BreakUncond: 3;
      else 0;
    end;
end;

method FormSettings.IndexToBreak(aBreak, aNumber: Integer): Integer;
begin
  result :=
    if aBreak = 1 then RptSection.BreakNone
    else if aBreak = 2 then RptSection.BreakAll
    else if aBreak = 3 then RptSection.BreakUncond
    else aNumber;
end;

method FormSettings.SettingsToData;
begin
  inc(fUpdateLevel);
  try
    // Evaluation
    EditEvalType.SelectedIndex := Math.Max(ord(fSettings.EvalType) - 1, 0);
    EditEvalUndefined.SelectedIndex := if fSettings.ExpandEmpty then 1 else 0;
    ChkEvalCheckBounds.Checked := fSettings.CheckBounds;
    ChkEvalWarnings.Checked := fSettings.Warnings;

    // Reports
    SettingsToRptFonts;

    ChkHeader.Checked := fSettings.UseReportHeader;
    EditTree.SelectedIndex := ord(fSettings.TreePattern);
    EditSection.SelectedIndex := BreakToIndex(fSettings.SectionBreak);
    AppUtils.Show(EditSection.SelectedIndex = 0, NumSection, LblSecLines);
    if fSettings.SectionBreak > 0 then
      NumSection.Value := fSettings.SectionBreak;
    EditTable.SelectedIndex := BreakToIndex(fSettings.TableBreak);
    AppUtils.Show(EditTable.SelectedIndex = 0, NumTable, LblTabLines);
    if fSettings.TableBreak > 0 then
      NumTable.Value := fSettings.TableBreak;
    NumColumns.Value := fSettings.MaxColumns;

    NumFloat.Value := fSettings.FltDecimals;
    NumWeights.Value := fSettings.WeiDecimals;
    NumDistrib.Value := fSettings.MemDecimals;
    NumDefDet.Value := fSettings.DefDetDecimals;

//    EditFunctRepresentation.SelectedIndex := if fSettings.FncComplex then 1 else 0;
    EditFunctRepresentation.SelectedIndex := ord(fSettings.Representation);
    ChkFunctNumbers.Checked := fSettings.FncShowNumbers;
    ChkFunctWeights.Checked := fSettings.FncShowWeights;
    ChkFunctNumericValues.Checked := fSettings.FncShowNumericValues;
    ChkFunctMarginals.Checked := fSettings.FncShowMarginals;
    ChkFunctNormWeight.Checked := fSettings.FncNormalizedWeights;
    ChkFunctEntered.Checked := fSettings.FncEnteredOnly;
    ChkFunctStatus.Checked := fSettings.FncStatus;

    ChkWeiLocal.Checked := fSettings.WeightsLocal;
    ChkWeiGlobal.Checked := fSettings.WeightsGlobal;
    ChkWeiLocalNormalized.Checked := fSettings.WeightsLocalNormalized;
    ChkWeiGlobalNormalized.Checked := fSettings.WeightsGlobalNormalized;

    // Import/Export
    EditAltValues.SelectedIndex :=
      if fSettings.UseDexiStringValues then 3
      else ord(fSettings.ValueType);
    EditAltAttributes.SelectedIndex := if fSettings.AltDataAll then 0 else 1;
    EditAltAttId.SelectedIndex := ord(fSettings.AttId);
    EditAltOrientation.SelectedIndex := if fSettings.AltTranspose then 1 else 0;
    EditAltIndent.SelectedIndex := if fSettings.AltLevels then 0 else 1;
    EditCsvFormat.SelectedIndex := if fSettings.CsvInvariant then 1 else 0;

    EditFncValues.SelectedIndex := ord(fSettings.FncDataType);
    EditFncRules.SelectedIndex := if fSettings.FncDataAll then 0 else 1;

    // Json
    with jSettings := fSettings.JsonSettings do
      begin
        EditJsonStructure.SelectedIndex :=
          if jSettings.StructureFormat = nil then 0
          else ord(DexiJsonStructureFormat(jSettings.StructureFormat));
        EditJsonValues.SelectedIndex :=
          if jSettings.ValueFormat = nil then ValueStringType.Text
          else ord(ValueStringType(jSettings.ValueFormat));
        EditJsonInclude.SelectedIndex :=
          if jSettings.IncludeAlternatives = nil then 2
          else if jSettings.IncludeAlternatives then
            if jSettings.IncludeModel then 0
            else 2
          else
            if jSettings.IncludeModel then 1
            else 0;
        ChkJsonAttBasic.Checked := jSettings.IncludesAttributeType(DexiJsonAttributeType.Basic);
        ChkJsonAttAggregate.Checked := jSettings.IncludesAttributeType(DexiJsonAttributeType.Aggregate);
        ChkJsonAttLinked.Checked := jSettings.IncludesAttributeType(DexiJsonAttributeType.Linked);
        if not (ChkJsonAttBasic.Checked or ChkJsonAttAggregate.Checked or ChkJsonAttLinked.Checked) then
          ChkJsonAttBasic.Checked := true;
        ChkJsonModName.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Name);
        ChkJsonModDescr.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Description);
        ChkJsonModId.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Id);
        ChkJsonModPath.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Path);
        ChkJsonModIndices.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Indices);
        ChkJsonModIndent.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Indent);
        ChkJsonModLevel.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Level);
        ChkJsonModType.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Type);
        ChkJsonModScale.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Scale);
        ChkJsonModFunct.Checked := jSettings.IncludesElement(jSettings.ModelElements, DexiJsonAttributeElement.Funct);
        ChkJsonAltName.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Name);
        ChkJsonAltDescr.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Description);
        ChkJsonAltId.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Id);
        ChkJsonAltPath.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Path);
        ChkJsonAltIndices.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Indices);
        ChkJsonAltIndent.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Indent);
        ChkJsonAltLevel.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Level);
        ChkJsonAltType.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Type);
        ChkJsonAltAsString.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.AsString);
        ChkJsonAltAsValue.Checked := jSettings.IncludesElement(jSettings.AlternativeElements, DexiJsonAttributeElement.AsValue);
        EditJsonModInputs.SelectedIndex :=
          if jSettings.ModelInputs = nil then DexiJsonInputs.None
          else ord(DexiJsonInputs(jSettings.ModelInputs));
        EditJsonAltInputs.SelectedIndex :=
          if jSettings.AlternativeInputs = nil then DexiJsonInputs.None
          else ord(DexiJsonInputs(jSettings.AlternativeInputs));
        ChkJsonUseDexiStrings.Checked := jSettings.UseDexiStringValues;
        ChkJsonDistrArray.Checked := jSettings.DistributionFormat <> DexiJsonDistributionFormat.Dict;
        ChkJsonIndent.Checked := jSettings.JsonIndent;
        ChkJsonTimeInfo.Checked := jSettings.IncludeTimeInfo;
        EditJsonFloatDecimals.Value := jSettings.FloatDecimals;
        EditJsonMemDecimals.Value := jSettings.MembershipDecimals;
      end;

    // Advanced
    ChkLinking.Checked := fSettings.Linking;
    ChkUndo.Checked := fSettings.Undoing;
    ChkHtmlReports.Checked := fSettings.RptHtml;
    ChkBrowser.Checked := fSettings.DefBrowser;
    ChkBrowser.Visible := fSettings.RptHtml;
    ChkModelProtect.Checked := fSettings.ModelProtect;
    ChkCanMoveTabs.Checked := fSettings.CanMoveTabs;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method FormSettings.DataToSettings;
begin
  if fUpdateLevel > 0 then
    exit;

  // Evaluation
  fSettings.EvalType := EvaluationType(EditEvalType.SelectedIndex + 1);
  fSettings.ExpandEmpty := EditEvalUndefined.SelectedIndex = 1;
  fSettings.CheckBounds := ChkEvalCheckBounds.Checked;
  fSettings.Warnings := ChkEvalWarnings.Checked;

  // Reports
  fSettings.UseReportHeader := ChkHeader.Checked;
  fSettings.TreePattern := RptTreePattern(EditTree.SelectedIndex);
  fSettings.SectionBreak := IndexToBreak(EditSection.SelectedIndex, Integer(NumSection.Value));
  AppUtils.Show(EditSection.SelectedIndex = 0, NumSection, LblSecLines);
  fSettings.TableBreak := IndexToBreak(EditTable.SelectedIndex, Integer(NumTable.Value));
  AppUtils.Show(EditTable.SelectedIndex = 0, NumSection, LblSecLines);
  fSettings.MaxColumns := Integer(NumColumns.Value);

  fSettings.FltDecimals := Integer(NumFloat.Value);
  fSettings.WeiDecimals := Integer(NumWeights.Value);
  fSettings.MemDecimals := Integer(NumDistrib.Value);
  fSettings.DefDetDecimals := Integer(NumDefDet.Value);

  fSettings.Representation := DexiRptFunctionRepresentation(EditFunctRepresentation.SelectedIndex);
  fSettings.FncComplex := EditFunctRepresentation.SelectedIndex = 1;
  fSettings.FncShowNumbers := ChkFunctNumbers.Checked;
  fSettings.FncShowWeights := ChkFunctWeights.Checked;
  fSettings.FncShowNumericValues := ChkFunctNumericValues.Checked;
  fSettings.FncShowMarginals := ChkFunctMarginals.Checked;
  fSettings.FncNormalizedWeights := ChkFunctNormWeight.Checked;
  fSettings.FncEnteredOnly := ChkFunctEntered.Checked;
  fSettings.FncStatus := ChkFunctStatus.Checked;

  fSettings.WeightsLocal := ChkWeiLocal.Checked;
  fSettings.WeightsGlobal := ChkWeiGlobal.Checked;
  fSettings.WeightsLocalNormalized := ChkWeiLocalNormalized.Checked;
  fSettings.WeightsGlobalNormalized := ChkWeiGlobalNormalized.Checked;

  // Import/Export
  fSettings.UseDexiStringValues := EditAltValues.SelectedIndex >= 3;
  fSettings.ValueType :=
    if fSettings.UseDexiStringValues then ValueStringType.Text
    else ValueStringType(EditAltValues.SelectedIndex);
  fSettings.AltDataAll := EditAltAttributes.SelectedIndex = 0;
  fSettings.AttId := AttributeIdentification(EditAltAttId.SelectedIndex);
  fSettings.AltTranspose := EditAltOrientation.SelectedIndex = 1;
  fSettings.AltLevels := EditAltIndent.SelectedIndex = 0;
  fSettings.CsvInvariant := EditCsvFormat.SelectedIndex = 1;

  fSettings.FncDataType := ValueStringType(EditFncValues.SelectedIndex);
  fSettings.FncDataAll := EditFncRules.SelectedIndex = 0;

  // Json
  with jSettings := fSettings.JsonSettings do
    begin
      jSettings.StructureFormat := DexiJsonStructureFormat(EditJsonStructure.SelectedIndex);
      jSettings.ValueFormat := ValueStringType(EditJsonValues.SelectedIndex);
      jSettings.IncludeModel := EditJsonInclude.SelectedIndex <> 2;
      jSettings.IncludeAlternatives := EditJsonInclude.SelectedIndex <> 1;
      jSettings.AttributeTypes := 0;
      if ChkJsonAttBasic.Checked then
        jSettings.AddType(DexiJsonAttributeType.Basic);
      if ChkJsonAttAggregate.Checked then
        jSettings.AddType(DexiJsonAttributeType.Aggregate);
      if ChkJsonAttLinked.Checked then
        jSettings.AddType(DexiJsonAttributeType.Linked);
      jSettings.ModelElements := 0;
      if ChkJsonModName.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Name);
      if ChkJsonModDescr.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Description);
      if ChkJsonModId.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Id);
      if ChkJsonModPath.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Path);
      if ChkJsonModIndices.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Indices);
      if ChkJsonModIndent.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Indent);
      if ChkJsonModLevel.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Level);
      if ChkJsonModType.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Type);
      if ChkJsonModScale.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Scale);
      if ChkJsonModFunct.Checked then
        jSettings.ModelElements := jSettings.AddElement(jSettings.ModelElements, DexiJsonAttributeElement.Funct);
      jSettings.AlternativeElements := 0;
      if ChkJsonAltName.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Name);
      if ChkJsonAltDescr.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Description);
      if ChkJsonAltId.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Id);
      if ChkJsonAltPath.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Path);
      if ChkJsonAltIndices.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Indices);
      if ChkJsonAltIndent.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Indent);
      if ChkJsonAltLevel.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Level);
      if ChkJsonAltType.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.Type);
      if ChkJsonAltAsString.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.AsString);
      if ChkJsonAltAsValue.Checked then
        jSettings.AlternativeElements := jSettings.AddElement(jSettings.AlternativeElements, DexiJsonAttributeElement.AsValue);
      jSettings.ModelInputs := DexiJsonInputs(EditJsonModInputs.SelectedIndex);
      jSettings.AlternativeInputs := DexiJsonInputs(EditJsonAltInputs.SelectedIndex);
      jSettings.UseDexiStringValues := ChkJsonUseDexiStrings.Checked;
      jSettings.DistributionFormat :=
        if ChkJsonDistrArray.Checked then DexiJsonDistributionFormat.Distr
        else DexiJsonDistributionFormat.Dict;
      jSettings.JsonIndent := ChkJsonIndent.Checked;
      jSettings.IncludeTimeInfo := ChkJsonTimeInfo.Checked;
      jSettings.FloatDecimals := Integer(EditJsonFloatDecimals.Value);
      jSettings.MembershipDecimals := Integer(EditJsonMemDecimals.Value);
    end;

  // Advanced
  fSettings.Linking := ChkLinking.Checked;
  fSettings.Undoing := ChkUndo.Checked;
  fSettings.RptHtml := ChkHtmlReports.Checked;
  fSettings.DefBrowser := ChkBrowser.Checked;
  fSettings.ModelProtect := ChkModelProtect.Checked;
  fSettings.CanMoveTabs := ChkCanMoveTabs.Checked;
end;

method FormSettings.ChartParametersToData;
begin
  inc(fUpdateLevel);
  try
    SettingsToChartFontsAndColors;
    EditChartType.SelectedIndex := ord(fChartParameters.MultiChartType);
    EditGridX.Value := fChartParameters.GridX;
    EditGridY.Value := fChartParameters.GridY;

    EditTextGaps.Value := fChartParameters.AttGap;
    EditLineWidth.Value := Integer(fChartParameters.LineWidth);
    EditBarWidth.Value := Math.Round(100 * fChartParameters.BarExtent);
    EditScatterPoint.Value := fChartParameters.ScatterPointRadius;
    EditRadarPoint.Value := fChartParameters.RadarPointRadius;
    EditLinearPoint.Value := fChartParameters.AbaconPointRadius;

    EditBorderTop.Value := fChartParameters.Border.Top;
    EditBorderBottom.Value := fChartParameters.Border.Bottom;
    EditBorderLeft.Value := fChartParameters.Border.Left;
    EditBorderRight.Value := fChartParameters.Border.Right;

    EditTransparency.Value := 100 - Math.Round(100.0 * fChartParameters.TransparentAlpha / 255.0);

  finally
    dec(fUpdateLevel);
  end;
end;

method FormSettings.DataToChartParameters;
begin
  if fUpdateLevel > 0 then
    exit;
  fChartParameters.MultiChartType := DexiMultiAttChartType(EditChartType.SelectedIndex);
  fChartParameters.GridX := Integer(EditGridX.Value);
  fChartParameters.GridY := Integer(EditGridY.Value);

  var lGaps := Integer(EditTextGaps.Value);
  fChartParameters.AltGap := lGaps;
  fChartParameters.AttGap := lGaps;
  fChartParameters.ScaleGap := lGaps;
  fChartParameters.ValGap := lGaps;

  fChartParameters.LineWidth := Integer(EditLineWidth.Value);
  fChartParameters.BarExtent := Integer(EditBarWidth.Value) / 100.0;
  fChartParameters.ScatterPointRadius := Integer(EditScatterPoint.Value);
  fChartParameters.RadarPointRadius := Integer(EditRadarPoint.Value);
  fChartParameters.AbaconPointRadius := Integer(EditLinearPoint.Value);
  fChartParameters.TransparentAlpha := 255 - (255 * Integer(EditTransparency.Value) div 100);

  fChartParameters.Border.Left := Integer(EditBorderLeft.Value);
  fChartParameters.Border.Right := Integer(EditBorderRight.Value);
  fChartParameters.Border.Top := Integer(EditBorderTop.Value);
  fChartParameters.Border.Bottom := Integer(EditBorderBottom.Value);
end;

method FormSettings.SetForm(aModel: DexiModel);
begin
  fModel := aModel;
  fSettings :=
    if fModel = nil then nil
    else new DexiSettings(fModel.Settings);
  if (fSettings <> nil) and (fSettings.JsonSettings = nil) then
    begin
      fSettings.JsonSettings := new DexiJsonSettings;
      fSettings.JsonSettings.SetDefaults;
    end;
  fChartParameters :=
    if fModel = nil then nil
    else new DexiChartParameters(fModel.ChartParameters);
  if fSettings <> nil then
    SettingsToData
  else
    begin
      TabsSettings.TabPages.Remove(PageEvaluation);
      TabsSettings.TabPages.Remove(PageReports);
      TabsSettings.TabPages.Remove(PageImportExport);
      TabsSettings.TabPages.Remove(PageAdvanced);
    end;
  if fChartParameters <> nil then
    ChartParametersToData
  else
    TabsSettings.TabPages.Remove(PageCharts);
end;

method FormSettings.FormSettings_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
begin
  DisposeFonts([fRptFont, fBadFont, fGoodFont, fAltFont, fAttFont, fValFont]);
end;

method FormSettings.BtnAltFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fAltFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.AltFont := DlgFont.Font;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.BtnChartAttFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fAttFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.AttFont := DlgFont.Font;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.BtnValFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fValFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.ValFont := DlgFont.Font;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.BtnChartResetFonts_Click(sender: System.Object; e: System.EventArgs);
begin
  var lFontInfo := new FontData(SystemFonts.DefaultFont);
  fChartParameters.AltFontInfo := lFontInfo;;
  fChartParameters.AttFontInfo := new FontInfo(lFontInfo);
  fChartParameters.ValFontInfo := new FontInfo(lFontInfo);
  SettingsToChartFontsAndColors;
end;

method FormSettings.BtnBackgroundColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fBackgroundColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.BackgroundColor := DlgColor.Color;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.BtnAreaColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fAreaColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.AreaColor := DlgColor.Color;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.BtnNeutralPoint_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fNeutralColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.NeutralColor := DlgColor.Color;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.BtnUndefinedPoint_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fUndefinedColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.UndefinedColor := DlgColor.Color;
      SettingsToChartFontsAndColors;
    end;
end;

method FormSettings.EditChart_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  DataToChartParameters;
  ChartParametersToData;
end;

method FormSettings.EditSettings_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  DataToSettings;
  SettingsToData;
end;

method FormSettings.EditRptFont_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fSettings.BadStyle := FontInfo.StyleString(ChkBadBold.Checked, ChkBadItalic.Checked, ChkBadUnderline.Checked);
  fSettings.GoodStyle := FontInfo.StyleString(ChkGoodBold.Checked, ChkGoodItalic.Checked, ChkGoodUnderline.Checked);
  SettingsToRptFonts;
end;

method FormSettings.BtnRptFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fRptFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fSettings.ReportFontInfo := new FontData(DlgFont.Font);
      SettingsToRptFonts;
    end;
end;

method FormSettings.BtnBadColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fBadColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fSettings.BadColor := new ColorData(DlgColor.Color);
      SettingsToRptFonts;
    end;
end;

method FormSettings.BtnGoodColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fGoodColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fSettings.GoodColor := new ColorData(DlgColor.Color);
      SettingsToRptFonts;
    end;
end;

end.