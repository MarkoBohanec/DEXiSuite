// CtrlFormCharts.pas is part of
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
// CtrlFormCharts.pas implements a 'CtrlForm' for designing and displaying charts that
// show results of evaluation of decision alternatives.
// Chart types (Bar, Scatter, Radar, RadarGrid, Linear) are determined from user-defined
// selection of attributes and other chart parameters.
// ----------

namespace DexiWin;

interface

uses
  System.IO,
  System.Drawing,
  System.Drawing.Imaging,
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
  /// Summary description for CtrlFormCharts.
  /// </summary>
  CtrlFormCharts = public partial class(CtrlForm)
  private
    method ItemPopResetAltOrder_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopMoveDown_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopMoveUp_Click(sender: System.Object; e: System.EventArgs);
    method AltList_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method ItemMenuEditAddReport_Click(sender: System.Object; e: System.EventArgs);
    method MenuSelectLevel3_Click(sender: System.Object; e: System.EventArgs);
    method MenuSelectLevel2_Click(sender: System.Object; e: System.EventArgs);
    method MenuSelectLevel1_Click(sender: System.Object; e: System.EventArgs);
    method MenuSelectRoots_Click(sender: System.Object; e: System.EventArgs);
    method MenuSelectBasicAttributes_Click(sender: System.Object; e: System.EventArgs);
    method MenuSelectAllAttributes_Click(sender: System.Object; e: System.EventArgs);
    method BtnAreaColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnValFont_Click(sender: System.Object; e: System.EventArgs);
    method BtnAttFont_Click(sender: System.Object; e: System.EventArgs);
    method BtnAltFont_Click(sender: System.Object; e: System.EventArgs);
    method EditChart_ValueChanged(sender: System.Object; e: System.EventArgs);
    method BtnUnselectAllAlt_Click(sender: System.Object; e: System.EventArgs);
    method BtnSelectAllAlt_Click(sender: System.Object; e: System.EventArgs);
    method BtnUnselectAllAtt_Click(sender: System.Object; e: System.EventArgs);
    method AltList_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
    method AttList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
    method AltList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
    method ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyMetafile_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
    method BtnBackgroundColor_Click(sender: System.Object; e: System.EventArgs);
    method EditTree_ValueChanged(sender: System.Object; e: System.EventArgs);
    method CtrlFormCharts_Resize(sender: System.Object; e: System.EventArgs);
    method CtrlFormCharts_VisibleChanged(sender: System.Object; e: System.EventArgs);
    fModel: DexiModel;
    fParameters: DexiChartParameters;
    fChart: DexiEvalChart;
    fAttList: DexiAttributeList;
    fAltList: List<AlternativeObject>;
    fAltOrder: IntArray;
    fUpdateLevel := 0;
  protected
    class const NodeFormatClasses = ['', 'all', 'aggregate', 'basic', 'discrete', 'continuous', 'link', 'root', 'pruned'];
    class method MakeChart(aModel: DexiModel; aParameters: DexiChartParameters; aWidth, aHeight: Integer; aAltOrder: IntArray := nil): DexiEvalChart;
    method MakeChartImage(aModel: DexiModel; aParameters: DexiChartParameters; aWidth, aHeight: Integer): IRptImage;
    method Dispose(disposing: Boolean); override;
    method SetModel(aModel: DexiModel);
    method SelAttCount: Integer;
    method SelAltCount: Integer;
    method GetChartable: Boolean;
    method UpdateAltOrder(aFrom: IntArray): IntArray;
    method AltListFromOrder(aAltOrder: IntArray): List<AlternativeObject>;
    method OrderFromAltList(aAltList: List<AlternativeObject>): IntArray;
    method AltSelection: IntArray;
    method UpdateForm;
    method ReDraw;
    method ParametersToData;
    method DataToParameters;
    method SelectLevel(aLevel: Integer);
    method SelectedAlternativeIndex: Integer;
    method AltListChanged(lSelect: Integer);
  public
    constructor;
    method Init;
    method DoEnter;
    property Model: DexiModel read fModel write SetModel;
    method SaveState;
    method DataChanged;
    method SettingsChanged;
    property Chartable: Boolean read GetChartable;
    property AltCount: Integer;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormCharts;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  CtrlMenu := FormMenu;
  CtrlTool := FormTool;
  AutoScroll := false;
  AutoScroll := true;
  ChartPicture.Dock := DockStyle.Fill;
  LblMessage.Dock := DockStyle.Fill;

  AttList.SmallImageList := AppData:ModelImages;

  AttList.CanExpandGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then DexiAttribute(x).IsAggregate
        else false;
    end;

  AttList.ChildrenGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then DexiAttribute(x).AllInputs
        else nil;
    end;

  ColAttribute.ImageGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then 'ImgAtt' + DexiAttribute(x).NodeStatus.ToString
        else nil;
    end;

  AttList.BooleanCheckStateGetter:=
    method(x: Object): Boolean
    begin
      result :=
        if (x is DexiAttribute) then fParameters.IsExplicitlySelected(DexiAttribute(x))
        else false;
    end;

  AttList.BooleanCheckStatePutter :=
    method(x: Object; chk: Boolean)
    begin
      if (x is DexiAttribute) then
        if chk then fParameters.SelectAttribute(DexiAttribute(x))
        else fParameters.UnSelectAttribute(DexiAttribute(x));
    end;

  AltList.BooleanCheckStateGetter :=
    method(x: Object): Boolean
    begin
      result :=
        if (x is AlternativeObject) then fParameters.IsSelected(AlternativeObject(x).Index)
        else false;
    end;

  AltList.BooleanCheckStatePutter :=
    method(x: Object; chk: Boolean)
    begin
      if (x is AlternativeObject) then
        if chk then fParameters.SelectAlternative(AlternativeObject(x).Index)
        else fParameters.UnSelectAlternative(AlternativeObject(x).Index, Model.AltCount);
    end;

end;

method CtrlFormCharts.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    GraphicsUtils.SetShapePicture(ChartPicture, nil);
    AttList.SmallImageList := nil;
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlFormCharts.SelAttCount: Integer;
begin
  result := Math.Max(fParameters.AttCount, 0);
end;

method CtrlFormCharts.SelAltCount: Integer;
begin
  result := fParameters.AltCount;
  if result < 0 then
    result := fModel.AltCount;
end;

method CtrlFormCharts.GetChartable: Boolean;
begin
  result := (SelAltCount > 0) and (SelAttCount > 0);
end;

method CtrlFormCharts.SetModel(aModel: DexiModel);
begin
  fModel := aModel;
  fParameters := fModel.ChartParameters;
  ParametersToData;
  UpdateForm;
end;

method CtrlFormCharts.ParametersToData;
begin
  if fParameters = nil then
    exit;
  inc(fUpdateLevel);
  try
    EditBorderTop.Value := fParameters.Border.Top;
    EditBorderBottom.Value := fParameters.Border.Bottom;
    EditBorderLeft.Value := fParameters.Border.Left;
    EditBorderRight.Value := fParameters.Border.Right;
    EditChartType.SelectedIndex := ord(fParameters.MultiChartType);
    EditGridX.Value := fParameters.GridX;
    EditGridY.Value := fParameters.GridY;
    EditTextGaps.Value := fParameters.AttGap;
    EditLineWidth.Value := Integer(fParameters.LineWidth);
    EditBarWidth.Value := Math.Round(100 * fParameters.BarExtent);
    EditScatterPoint.Value := fParameters.ScatterPointRadius;
    EditRadarPoint.Value := fParameters.RadarPointRadius;
    EditLinearPoint.Value := fParameters.AbaconPointRadius;
    EditTransparency.Value := 100 - Math.Round(100.0 * fParameters.TransparentAlpha / 255.0);
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlFormCharts.DataToParameters;
begin
  if fUpdateLevel > 0 then
    exit;
  if fParameters = nil then
    exit;
  fParameters.Border.Left := Integer(EditBorderLeft.Value);
  fParameters.Border.Right := Integer(EditBorderRight.Value);
  fParameters.Border.Top := Integer(EditBorderTop.Value);
  fParameters.Border.Bottom := Integer(EditBorderBottom.Value);
  fParameters.MultiChartType := DexiMultiAttChartType(EditChartType.SelectedIndex);
  fParameters.GridX := Integer(EditGridX.Value);
  fParameters.GridY := Integer(EditGridY.Value);
  var lGaps := Integer(EditTextGaps.Value);
  fParameters.AltGap := lGaps;
  fParameters.AttGap := lGaps;
  fParameters.ScaleGap := lGaps;
  fParameters.ValGap := lGaps;
  fParameters.LineWidth := Integer(EditLineWidth.Value);
  fParameters.BarExtent := Integer(EditBarWidth.Value) / 100.0;
  fParameters.ScatterPointRadius := Integer(EditScatterPoint.Value);
  fParameters.RadarPointRadius := Integer(EditRadarPoint.Value);
  fParameters.AbaconPointRadius := Integer(EditLinearPoint.Value);
  fParameters.TransparentAlpha := 255 - (255 * Integer(EditTransparency.Value) div 100);
  Model.Modified := true;
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.Init;
begin
  UpdateForm;
end;

method CtrlFormCharts.DoEnter;
begin
  if fModel = nil then
    exit;
  if fModel.NeedsEvaluation then
    fModel.Evaluate;
  fAttList := fModel.Root.CollectInputs(false);
  AttList.CollapseAll;
  AttList.SetObjects(Model:Root:AllInputs);
  AttList.ExpandAll;
  fAltOrder := UpdateAltOrder(fAltOrder);
  fAltList := AltListFromOrder(fAltOrder);
  AltList.SetObjects(fAltList);
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.UpdateAltOrder(aFrom: IntArray): IntArray;
begin
  var lAlternatives := Utils.RangeArray(Model.AltCount, 0);
  if aFrom = nil then
    exit lAlternatives;
  result := Utils.NewIntArray(Model.AltCount);
  var pos := 0;
  for i := low(aFrom) to high(aFrom) do
    begin
      var lAlt := aFrom[i];
      if (low(lAlternatives) <= lAlt <= high(lAlternatives)) and (lAlternatives[lAlt] = lAlt) then
        begin
          result[pos] := lAlt;
          inc(pos);
          lAlternatives[lAlt] := -1;
        end;
    end;
  for each lAlt in lAlternatives do
    if lAlt >= 0 then
      begin
        result[pos] := lAlt;
        inc(pos);
      end;
end;

method CtrlFormCharts.AltListFromOrder(aAltOrder: IntArray): List<AlternativeObject>;
begin
  result := new List<AlternativeObject>;
  for each lAlt in aAltOrder do
    result.Add(new AlternativeObject(
      &Index := lAlt,
      Name := Model.Alternative[lAlt].Name,
      Description := Model.Alternative[lAlt].Description));
end;

method CtrlFormCharts.OrderFromAltList(aAltList: List<AlternativeObject>): IntArray;
begin
  if aAltList = nil then
    exit nil;
  result := Utils.NewIntArray(aAltList.Count);
  for i := 0 to aAltList.Count - 1 do
    result[i] := aAltList[i].Index;
end;

method CtrlFormCharts.AltSelection: IntArray;
begin
  var lSelAlt := AltList.SelectedIndex;
  if not (0 <= lSelAlt < fAltList.Count) or (fParameters.AttCount <= 2) or (fParameters.MultiChartType <> DexiMultiAttChartType.RadarGrid) then
    exit fAltOrder;
  var lAlts := Utils.NewIntArray(fAltList.Count);
  var lSelCount := 0;
  for i := low(fAltOrder) to high(fAltOrder) do
    begin
      var lAlt := fAltOrder[i];
      if fParameters.IsSelected(lAlt) then
        begin
          lAlts[i] := lAlt;
          inc(lSelCount);
        end
      else
        lAlts[i] := -1;
    end;
  for i := low(lAlts) to high(lAlts) do
    begin
      if lSelCount <= fParameters.GridSize then
        break;
      if i >= lSelAlt then
        break;
      if lAlts[i] >= 0 then
        begin
          lAlts[i] := -1;
          dec(lSelCount);
        end;
    end;
  result := Utils.NewIntArray(lSelCount);
  var lPos := 0;
  for i := low(lAlts) to high(lAlts) do
    if lAlts[i] >= 0 then
      begin
        result[lPos] := lAlts[i];
        inc(lPos);
      end;
end;

method CtrlFormCharts.UpdateForm;
begin
  AppUtils.Enable(fChart <> nil,
    ItemMenuSave, ItemMenuCopyMetafile, ItemMenuCopyBitmap, ItemPopCopyMetafile, ItemPopCopyBitmap, ItemMenuEditAddReport,
    ItemToolCopy, ItemToolSave);
  var lSelAlt := AltList.SelectedIndex;
  var CanMoveAlternative := 0 <= lSelAlt < fAltList.Count;
  AppUtils.Enable(CanMoveAlternative and (lSelAlt > 0), ItemPopMoveUp);
  AppUtils.Enable(CanMoveAlternative and (lSelAlt < fAltList.Count - 1), ItemPopMoveDown);
  AppUtils.UpdateModelForm(self);
  AppData.AppForm.UpdateForm;
end;

class method CtrlFormCharts.MakeChart(aModel: DexiModel; aParameters: DexiChartParameters; aWidth, aHeight: Integer; aAltOrder: IntArray := nil): DexiEvalChart;
begin
  result :=
    if aParameters.AttCount <= 0 then nil
    else if aParameters.AttCount = 1 then new DexiBarChart(aWidth, aHeight, aModel, aParameters, aAltOrder)
    else if aParameters.AttCount = 2 then new DexiScatterChart(aWidth, aHeight, aModel, aParameters, aAltOrder)
    else if aParameters.MultiChartType = DexiMultiAttChartType.Radar then
      new DexiRadarChart(aWidth, aHeight, aModel, aParameters, aAltOrder)
    else if aParameters.MultiChartType = DexiMultiAttChartType.RadarGrid then
      new DexiRadarGrid(aWidth, aHeight, aModel, aParameters, aAltOrder)
    else if aParameters.MultiChartType = DexiMultiAttChartType.Linear then
      new DexiAbaconChart(aWidth, aHeight, aModel, aParameters, aAltOrder)
    else nil;
end;

method CtrlFormCharts.MakeChartImage(aModel: DexiModel; aParameters: DexiChartParameters; aWidth, aHeight: Integer): IRptImage;
begin
  result := nil;
  var lAltOrder := AltSelection;
  var lChart := MakeChart(aModel, aParameters, aWidth, aHeight, lAltOrder);
  if lChart = nil then
    exit;
  result := new WinImage(lChart.MakeMetafile);
end;

method CtrlFormCharts.ReDraw;
begin
  if fModel = nil then
    exit;
  var lChartable := Chartable;
  ChartPicture.Visible := lChartable;
  LblMessage.Visible := not lChartable;
  fChart := nil;
  if not lChartable then
    exit;
  var lAltOrder := AltSelection;
  fChart := MakeChart(fModel, fParameters, ChartPicture.Width, ChartPicture.Height, lAltOrder);
  if fChart <> nil then
    begin
      fChart.Border := new ImgBorder(fParameters.Border);
      GraphicsUtils.SetShapePicture(ChartPicture, fChart.MakeMetafile);
    end;
end;

method CtrlFormCharts.CtrlFormCharts_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  DoEnter;
end;

method CtrlFormCharts.CtrlFormCharts_Resize(sender: System.Object; e: System.EventArgs);
begin
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.EditTree_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  DataToParameters;
end;

method CtrlFormCharts.ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
begin
  if fChart = nil then
    exit;
  using lBitmap := fChart.MakeBitmap do
    Clipboard.SetImage(lBitmap);
end;

method CtrlFormCharts.ItemMenuCopyMetafile_Click(sender: System.Object; e: System.EventArgs);
begin
  if fChart = nil then
    exit;
  using lMetafile := fChart.MakeMetafile do
    ClipboardMetafileHelper.PutEnhMetafileOnClipboard(Handle, lMetafile);
end;

method CtrlFormCharts.ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
begin
  if fChart = nil then
    exit;
  if SaveChartDialog.ShowDialog = DialogResult.OK then
    begin
      var lFileName := SaveChartDialog.FileName;
      case SaveChartDialog.FilterIndex of
        1: // metafile
          begin
            var lData := fChart.MakeMetafileData;
            File.WriteBytes(lFileName, lData);
          end;
        2: // bitmap
          using lBitmap := fChart.MakeBitmap do
            lBitmap.Save(lFileName, ImageFormat.Png);
      end;
    end;
end;

method CtrlFormCharts.AltList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.AttList_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.AltList_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
begin
  if e.Model is AlternativeObject then
    e.Text := Model.Alternative[AlternativeObject(e.Model).Index].Description;
end;

method CtrlFormCharts.BtnUnselectAllAtt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.UnSelectAllAttributes;
  AttList.Refresh;
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.BtnSelectAllAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.SelectAllAlternatives;
  AltList.RefreshObjects(fAltList);
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.BtnUnselectAllAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  fParameters.UnSelectAllAlternatives;
  AltList.RefreshObjects(fAltList);
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.EditChart_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  DataToParameters;
end;

method CtrlFormCharts.BtnBackgroundColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fParameters.BackgroundColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fParameters.BackgroundColor := DlgColor.Color;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormCharts.BtnAltFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fParameters.AltFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fParameters.AltFont := DlgFont.Font;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormCharts.BtnAttFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fParameters.AttFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fParameters.AttFont := DlgFont.Font;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormCharts.BtnValFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fParameters.ValFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fParameters.ValFont := DlgFont.Font;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormCharts.BtnAreaColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fParameters.AreaColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      fParameters.AreaColor := DlgColor.Color;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormCharts.MenuSelectAllAttributes_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.SelectAllAttributesExplicitly(fAttList);
  AttList.SetObjects(Model:Root:AllInputs);
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.MenuSelectBasicAttributes_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.UnSelectAllAttributes;
  var lList := Model.Root.CollectBasicNonLinked;
  fParameters.SelectAttributes(lList);
  AttList.SetObjects(Model:Root:AllInputs);
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.SelectLevel(aLevel: Integer);
begin
  if fUpdateLevel > 0 then
    exit;
  fParameters.UnSelectAllAttributes;
  var lList := Model.Root.CollectLevelIntersection(aLevel + 1);
  fParameters.SelectAttributes(lList);
  AttList.SetObjects(Model:Root:AllInputs);
  SaveState;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.SelectedAlternativeIndex: Integer;
begin
  result := AltList.SelectedIndex;
end;

method CtrlFormCharts.MenuSelectRoots_Click(sender: System.Object; e: System.EventArgs);
begin
  SelectLevel(0);
end;

method CtrlFormCharts.MenuSelectLevel1_Click(sender: System.Object; e: System.EventArgs);
begin
  SelectLevel(1);
end;

method CtrlFormCharts.MenuSelectLevel2_Click(sender: System.Object; e: System.EventArgs);
begin
  SelectLevel(2);
end;

method CtrlFormCharts.MenuSelectLevel3_Click(sender: System.Object; e: System.EventArgs);
begin
  SelectLevel(3);
end;

method CtrlFormCharts.SaveState;
begin
  AppUtils.ModelForm(self).SaveState;
end;

method CtrlFormCharts.SettingsChanged;
begin
  SetModel(Model);
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.DataChanged;
begin
  DoEnter;
end;

method CtrlFormCharts.ItemMenuEditAddReport_Click(sender: System.Object; e: System.EventArgs);
begin
  if Model.RptCount <= 0 then
    exit;
  if not Chartable then
    exit;
  var lParameters := new DexiReportParameters(fModel);
  var lFormat := new DexiReportFormat(fModel);
  var lReport := new DexiChartReport(lParameters, lFormat);
  lReport.Title := DexiString.RChart;
  lReport.ChartParameters := fParameters;
  lReport.MakeImage := @MakeChartImage;
  lReport.Width := ChartPicture.Width;
  lReport.Height := ChartPicture.Height;
  lReport.AutoScale := true;
  Model.Reports[0].AddReport(lReport);
  SaveState;
  UpdateForm;
end;

method CtrlFormCharts.AltList_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  UpdateForm;
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.AltListChanged(lSelect: Integer);
begin
  AltList.SetObjects(fAltList);
  if 0 <= lSelect < fAltList.Count then
    AltList.SelectedIndex := lSelect;
  var lOrder := OrderFromAltList(fAltList);
  fAltOrder := UpdateAltOrder(lOrder);
  ReDraw;
  UpdateForm;
end;

method CtrlFormCharts.ItemPopMoveUp_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lSelAlt := AltList.SelectedIndex;
  if 0 < lSelAlt < fAltList.Count then
    begin
      inc(fUpdateLevel);
      try
        Utils.MoveList(fAltList, lSelAlt, lSelAlt - 1);
        AltListChanged(lSelAlt - 1);
      finally
        dec(fUpdateLevel);
      end;
    end;
end;

method CtrlFormCharts.ItemPopMoveDown_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lSelAlt := AltList.SelectedIndex;
  if 0 <= lSelAlt < (fAltList.Count - 1) then
    begin
      inc(fUpdateLevel);
      try
        Utils.MoveList(fAltList, lSelAlt, lSelAlt + 1);
        AltListChanged(lSelAlt + 1);
      finally
        dec(fUpdateLevel);
      end;
    end;
end;

method CtrlFormCharts.ItemPopResetAltOrder_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lSelIdx := AltList.SelectedIndex;
  var lSelAlt :=
    if 0 <= lSelIdx < fAltList.Count  then fAltList[lSelIdx].Index
    else -1;
  inc(fUpdateLevel);
  try
    fAltOrder := UpdateAltOrder(nil);
    fAltList := AltListFromOrder(fAltOrder);
    AltListChanged(Utils.IntArrayIndex(fAltOrder, lSelAlt));
  finally
    dec(fUpdateLevel);
  end;
end;

end.