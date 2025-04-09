// FormReportManager.pas is part of
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
// FormReportManager.pas implements a form for editing/managing a collection of DEXi reports.
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
  BrightIdeasSoftware,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormFunctEditDiscrete.
  /// </summary>
  FormReportManager = partial public class(System.Windows.Forms.Form)
  private
    method ItemToolAddFnc_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddScales_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddAttDescr_Click(sender: System.Object; e: System.EventArgs);
    method ViewReports_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ItemToolAddAlt_Click(sender: System.Object; e: System.EventArgs);
    method FormReportManager_Activated(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveNewTab_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCopyNewTab_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolShow_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDuplicate_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddEval_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddWeights_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddFncSum_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddAttTree_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddAttInfo_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddModel_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddStat_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSettings_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDelete_Click(sender: System.Object; e: System.EventArgs);
    method ImgToolUnSelectAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSelectAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
    method ViewReports_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewReports_SelectionChanged(sender: System.Object; e: System.EventArgs);
  private
    fModel: DexiModel;
    fReports: DexiReportGroup;
    fLastSelected: DexiReport;
    fUpdateLevel: Integer;
    method CopyToTab(sender: System.Object; e: System.EventArgs);
    method MoveToTab(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
    method SelectionChanged;
    method ReportSettings;
    method AddReport(aReport: DexiReport);
    method UpdateReportTabs;
  public
    constructor;
    method SetForm(aReports: DexiReportGroup);
    method UpdateForm;
    property SelectedReport: DexiReport read DexiReport(ViewReports:SelectedObject);
    property SelectedReportIndex: Integer read fReports.ReportIndex(SelectedReport);
    property Format: DexiReportFormat read CtrlFormat.Format;
    property ReportTitle: String read CtrlFormat.ReportTitle;
    property SelectedFont: Font read CtrlFormat.SelectedFont;
    property ChangedFont: Boolean read CtrlFormat.ChangedFont;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormReportManager;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  ViewReports.FullRowSelect := true;
  ViewReports.CellEditUseWholeCell := true;
  ViewReports.SelectedBackColor := AppSettings.SelectedColor;
  ViewReports.SelectedForeColor := ViewReports.ForeColor;

  ViewReports.BooleanCheckStateGetter :=
    method(x: Object): Boolean
    begin
      result :=
        if (x is DexiReport) then DexiReport(x).Selected
        else false;
    end;

  ViewReports.BooleanCheckStatePutter :=
    method(x: Object; chk: Boolean)
    begin
      if (x is DexiReport) then
        begin
          DexiReport(x).Selected := chk;
          fModel.Modified := true;
        end;
    end;
end;

method FormReportManager.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    fModel := nil;
    fReports := nil;
    fLastSelected := nil;
  end;
  inherited Dispose(aDisposing);
end;

{$ENDREGION}

method FormReportManager.SelectionChanged;
begin
  if fUpdateLevel > 0 then
    exit;
  if ViewReports = nil then
    exit;
  inc(fUpdateLevel);
  try
    var lSelectedReport := SelectedReport;
    if SelectedReport = nil then
      if fLastSelected <> nil then
        ViewReports.SelectObject(fLastSelected)
      else if fReports.RptCount > 0 then
        ViewReports.SelectObject(fReports[0]);
    lSelectedReport := SelectedReport;
    if lSelectedReport <> nil then
      ViewReports.RefreshObject(lSelectedReport);
    fLastSelected := SelectedReport;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method FormReportManager.ReportSettings;
begin
  if fUpdateLevel > 0 then
    exit;
  var lReport := SelectedReport;
  if lReport = nil then
    exit;
  using lParamForm := new FormReportParameters do
    begin
      lParamForm.SetForm(lReport, true);
      if lParamForm.ShowDialog = DialogResult.OK then
        begin
          lReport.Parameters := lParamForm.Parameters;
          if lReport.ChartParameters <> nil then
            lReport.ChartParameters.AssignSelection(lReport.Parameters);
          lReport.Title := lParamForm.ReportTitle;
          ViewReports.RefreshObjects(fReports.Reports);
        end;
    end;
end;

method FormReportManager.SetForm(aReports: DexiReportGroup);
require
  aReports <> nil;
  aReports.Model <> nil;
begin
  fModel := aReports.Model;
  fReports := aReports;
  fReports.UpdateAttributeSelection;
  ViewReports.SetObjects(fReports.Reports);
  if fReports.RptCount > 0 then
    ViewReports.SelectObject(fReports[0]);
  CtrlFormat.SetForm(aReports, nil);
  CtrlFormat.CanEditTitle := not fModel.ReportIsPrimary(aReports);
  UpdateReportTabs;
  UpdateForm;
end;

method FormReportManager.UpdateReportTabs;
begin
  for i := ItemToolCopy.DropDownItems.Count - 1 downto 1 do
    ItemToolCopy.DropDownItems.RemoveAt(i);
  for i := ItemToolMove.DropDownItems.Count - 1 downto 1 do
    ItemToolMove.DropDownItems.RemoveAt(i);
  for each lRpt in fModel.Reports do
    if lRpt <> fReports then
      begin
        var lRptItem := new ToolStripMenuItem;
        lRptItem.Text := lRpt.Title;
        lRptItem.Tag := lRpt;
        lRptItem.Click += new System.EventHandler(CopyToTab);
        ItemToolCopy.DropDownItems.Add(lRptItem);
        lRptItem := new ToolStripMenuItem;
        lRptItem.Text := lRpt.Title;
        lRptItem.Tag := lRpt;
        lRptItem.Click += new System.EventHandler(MoveToTab);
        ItemToolMove.DropDownItems.Add(lRptItem);
      end;
end;

method FormReportManager.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  inc(fUpdateLevel);
  try
    var lIsSelected := SelectedReport <> nil;
    var lSelectedIndex := fReports.ReportIndex(SelectedReport);
    AppUtils.Enable(lIsSelected, ItemToolSettings, ItemToolDelete, ItemToolDuplicate, ItemToolOpen);
    AppUtils.Enable(lIsSelected, ItemPopSettings, ItemPopShow, ItemPopDelete, ItemPopDuplicate);
    AppUtils.Enable(lIsSelected, ItemToolShow, ItemToolCopy, ItemToolMove);
    AppUtils.Enable(lIsSelected and (lSelectedIndex > 0), ItemToolMoveUp, ItemPopMoveUp);
    AppUtils.Enable(lIsSelected and (lSelectedIndex < fReports.RptCount - 1), ItemToolMoveDown, ItemPopMoveDown);
  finally
    dec(fUpdateLevel);
  end;
end;

method FormReportManager.ViewReports_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method FormReportManager.ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lSelRpt := SelectedReport;
  var lSelIdx := SelectedReportIndex;
  if (lSelRpt = nil) or (lSelIdx < 0) or (lSelIdx >= fReports.RptCount - 1) then
    exit;
  fReports.MoveReportNext(lSelIdx);
  ViewReports.SetObjects(fReports.Reports);
  ViewReports.SelectObject(lSelRpt);
  UpdateForm;
end;

method FormReportManager.ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lSelRpt := SelectedReport;
  var lSelIdx := SelectedReportIndex;
  if (lSelRpt = nil) or (lSelIdx <= 0) then
    exit;
  fReports.MoveReportPrev(lSelIdx);
  ViewReports.SetObjects(fReports.Reports);
  ViewReports.SelectObject(lSelRpt);
  UpdateForm;
end;

method FormReportManager.ItemToolSelectAll_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lRpt in fReports.Reports do
    lRpt.Selected := true;
  fModel.Modified := true;
  ViewReports.RefreshObjects(fReports.Reports);
  UpdateForm;
end;

method FormReportManager.ImgToolUnSelectAll_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lRpt in fReports.Reports do
    lRpt.Selected := false;
  fModel.Modified := true;
  ViewReports.RefreshObjects(fReports.Reports);
  UpdateForm;
end;

method FormReportManager.ItemToolDelete_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  var lSelIdx := SelectedReportIndex;
  fReports.RemoveReport(lSelIdx);
  ViewReports.SetObjects(fReports.Reports);
  dec(lSelIdx);
  if (lSelIdx < 0) and (fReports.RptCount > 0) then
    lSelIdx := 0;
  if 0 <= lSelIdx < fReports.RptCount then
    ViewReports.SelectObject(fReports[lSelIdx]);
  SelectionChanged;
end;

method FormReportManager.ItemToolSettings_Click(sender: System.Object; e: System.EventArgs);
begin
  ReportSettings;
  UpdateForm;
end;

method FormReportManager.ViewReports_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  ReportSettings;
  UpdateForm;
end;

method FormReportManager.AddReport(aReport: DexiReport);
begin
  fReports.AddReport(aReport);
  ViewReports.SetObjects(fReports.Reports);
  ViewReports.SelectObject(aReport);
  SelectionChanged;
end;

method FormReportManager.ItemToolAddModel_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewModelReport);
end;

method FormReportManager.ItemToolAddStat_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewStatisticsReport);
end;

method FormReportManager.ItemToolAddAttInfo_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAttributeReport);
end;

method FormReportManager.ItemToolAddAttTree_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAttributeTreeReport);
end;

method FormReportManager.ItemToolAddAttDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAttributeDescriptionReport);
end;

method FormReportManager.ItemToolAddScales_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAttributeScaleReport);
end;

method FormReportManager.ItemToolAddFncSum_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAttributeFunctionSummaryReport);
end;

method FormReportManager.ItemToolAddFnc_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAttributeFunctionReport);
end;

method FormReportManager.ItemToolAddWeights_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewWeightsReport);
end;

method FormReportManager.ItemToolAddAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewAlternativesReport);
end;

method FormReportManager.ItemToolAddEval_Click(sender: System.Object; e: System.EventArgs);
begin
  AddReport(fModel.NewEvaluationReport);
end;

method FormReportManager.ItemToolDuplicate_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  var lReport := SelectedReport.Copy;
  fReports.InsertReport(SelectedReportIndex + 1, lReport);
  ViewReports.SetObjects(fReports.Reports);
  ViewReports.SelectObject(lReport);
  SelectionChanged;
end;

method FormReportManager.ItemToolShow_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  fLastSelected := SelectedReport;
  ReportManager.OpenReport(SelectedReport);
  ViewReports.FocusedObject := fLastSelected;
  ViewReports.SelectObject(fLastSelected);
  UpdateForm;
end;

method FormReportManager.ItemToolCopyNewTab_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  var lModelForm := AppUtils.ModelForm(fModel);
  if lModelForm = nil then
    exit;
  var lFormat := new DexiReportFormat(fReports.Format);
  var lParameters := new DexiReportParameters(fReports.Parameters);
  var lReports := new DexiReportGroup(lParameters, lFormat);
  lReports.Title := SelectedReport.Title;
  fModel.Reports.Add(lReports);
  lReports.AddReport(SelectedReport.Copy);
  lModelForm.AddReportTab(lReports, true);
  UpdateReportTabs;
  UpdateForm;
end;

method FormReportManager.ItemToolMoveNewTab_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  ItemToolCopyNewTab_Click(sender, e);
  ItemToolDelete_Click(sender, e);
end;

method FormReportManager.CopyToTab(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  if sender is not ToolStripMenuItem then
    exit;
  var lItem := ToolStripMenuItem(sender);
  if lItem.Tag is not DexiReportGroup then
    exit;
  var lReports := DexiReportGroup(lItem.Tag);
  lReports.AddReport(SelectedReport.Copy);
end;

method FormReportManager.MoveToTab(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if SelectedReport = nil then
    exit;
  if sender is not ToolStripMenuItem then
    exit;
  var lItem := ToolStripMenuItem(sender);
  if lItem.Tag is not DexiReportGroup then
    exit;
  var lReports := DexiReportGroup(lItem.Tag);
  lReports.AddReport(SelectedReport.Copy);
  ItemToolDelete_Click(sender, e);
end;

method FormReportManager.FormReportManager_Activated(sender: System.Object; e: System.EventArgs);
begin
  ViewReports.SetObjects(fReports.Reports);
end;

method FormReportManager.ViewReports_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
    if e.KeyCode = Keys.Enter then
      if SelectedReport <> nil then
        ItemToolSettings_Click(sender, e);
end;

end.