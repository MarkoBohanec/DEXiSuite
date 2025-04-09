// CtrlFormBrowse.pas is part of
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
// CtrlFormBrowse.pas implements a 'CtrlForm' aimed at displaying HTML reports internally
// in DEXiWin. It uses WinForm's WebBrowser control.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Drawing.Printing,
  System.Drawing.Imaging,
  System.Collections,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows,
  System.Windows.Forms,
  System.ComponentModel,
  BrightIdeasSoftware,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for CtrlFormBrowse.
  /// </summary>
  CtrlFormBrowse = public partial class(CtrlForm, ITabReportCtrlForm)
  private
    method ItemMenuEditAddReport_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSettings_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopPrint_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolBrowse_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolZoomReset_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolZoomOut_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolZoomIn_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPrintPreview_Click(sender: System.Object; e: System.EventArgs);
    method CtrlFormBrowse_VisibleChanged(sender: System.Object; e: System.EventArgs);
    method ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
  private
    fReport: DexiReport;
    fFileName: String;
    fParamForm: FormReportParameters;
    fManagerForm: FormReportManager;
    fFormMode: Boolean := false;
  protected
    method Dispose(disposing: Boolean); override;
    method SetReport(aReport: DexiReport);
    method SetHtml(aHtml: String);
    method MakeHtml;
    method RemakeReport;
    method UpdateForm;
  public
    constructor;
    method Init;
    method DataChanged;
    method SettingsChanged;
    property Report: DexiReport read fReport write SetReport;
    property FormMode: Boolean read fFormMode write fFormMode;
    property Html: String read Browser.DocumentText write SetHtml;
    property FileName: String read fFileName write fFileName;
    property ParamForm: FormReportParameters read fParamForm write fParamForm;
    property ManagerForm: FormReportManager read fManagerForm write fManagerForm;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormBrowse;
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
  FontDlg.Font := SystemFonts.DefaultFont;
  Browser.Focus;
end;

method CtrlFormBrowse.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    if fParamForm <> nil then
      begin
        if not fParamForm.IsDisposed then
          fParamForm.Dispose;
        fParamForm := nil;
      end;
    if fManagerForm <> nil then
      begin
        if not fManagerForm.IsDisposed then
          fManagerForm.Dispose;
        fManagerForm := nil;
      end;
  end;
  inherited Dispose(disposing);
end;

{$ENDREGION}

method CtrlFormBrowse.SetReport(aReport: DexiReport);
begin
  if aReport = nil then
    exit;
  Text := aReport.Title;
  fFileName := aReport.Model.FileName;
  fReport := aReport;
  ItemMenuEditAddReport.Visible := aReport is not DexiReportGroup;
  RemakeReport;
end;

method CtrlFormBrowse.MakeHtml;
begin
  var lHtmlParams := new DexiHtmlParameters(Report:Model);
  if (fParamForm <> nil) and fParamForm.ChangedFont then
    begin
      lHtmlParams.FontName := fParamForm.SelectedFont.Name;
      lHtmlParams.FontSize := Integer(fParamForm.SelectedFont.Size);
    end;
  if (fManagerForm <> nil) and fManagerForm.ChangedFont then
    begin
      lHtmlParams.FontName := fManagerForm.SelectedFont.Name;
      lHtmlParams.FontSize := Integer(fManagerForm.SelectedFont.Size);
    end;
  using lHtmlWriter := new RptHtmlWriter(Report.Report, lHtmlParams) do
    SetHtml(lHtmlWriter.AsString);
end;

method CtrlFormBrowse.SetHtml(aHtml: String);
begin
  if Browser.Document = nil then
    Browser.DocumentText := aHtml
  else
    begin
      Browser.Document.OpenNew(true);
      Browser.Document.Write(aHtml);
      Browser.Refresh;
    end;
  UpdateForm;
end;

method CtrlFormBrowse.Init;
begin
  UpdateForm;
end;

method CtrlFormBrowse.UpdateForm;
begin
  FirstEditSeparator.Visible := not fFormMode;
  FirstFileSeparator.Visible := not fFormMode;
  AppUtils.Enable((fParamForm <> nil) or (fManagerForm <> nil), ItemToolSettings, ItemMenuSettings, ItemPopSettings);
  AppUtils.UpdateModelForm(self);
  var lAppForm := AppData:AppForm;
  if lAppForm <> nil then
    lAppForm.UpdateForm;
end;

method CtrlFormBrowse.CtrlFormBrowse_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  Update;
end;

method CtrlFormBrowse.ItemToolPrintPreview_Click(sender: System.Object; e: System.EventArgs);
begin
  Browser.ShowPrintPreviewDialog;
end;

method CtrlFormBrowse.ItemPopPrint_Click(sender: System.Object; e: System.EventArgs);
begin
  Browser.ShowPrintDialog;
end;

method CtrlFormBrowse.ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
begin
  SaveHtmlDialog.FileName := fFileName;
  if SaveHtmlDialog.ShowDialog = DialogResult.OK then
    begin
      fFileName := SaveHtmlDialog.FileName;
      File.WriteText(fFileName, Html);
    end;
end;

method CtrlFormBrowse.ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
begin
  Clipboard.SetText(Html);
end;

method CtrlFormBrowse.ItemToolZoomIn_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Browser.IsBusy then
    SendKeys.Send('^{+}');
end;

method CtrlFormBrowse.ItemToolZoomOut_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Browser.IsBusy then
    SendKeys.Send('^{-}');
end;

method CtrlFormBrowse.ItemToolZoomReset_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Browser.IsBusy then
    SendKeys.Send('^{0}');
end;

method CtrlFormBrowse.ItemToolBrowse_Click(sender: System.Object; e: System.EventArgs);
begin
  BrowserManager.OpenInBrowser(Html);
end;

method CtrlFormBrowse.ItemToolSettings_Click(sender: System.Object; e: System.EventArgs);
begin
  if fParamForm <> nil then
    begin
      if fParamForm.ShowDialog = DialogResult.OK then
        begin
          Report.Parameters := fParamForm.Parameters;
          Report.Format := fParamForm.Format;
          RemakeReport;
        end;
    end;
  if fManagerForm <> nil then
    begin
      fManagerForm.SetForm(DexiReportGroup(Report));
      if fManagerForm.ShowDialog = DialogResult.OK then
        begin
          Report.Format := fManagerForm.Format;
          if not Report.Model.ReportIsPrimary(Report) and (Report is DexiReportGroup) then
            begin
              Report.Title := fManagerForm.ReportTitle;
              var lTabPage := AppUtils.ReportTabPage(Report.Model, DexiReportGroup(Report));
              if lTabPage <> nil then
                lTabPage.Text := Report.Title;
            end;
          RemakeReport;
        end;
    end;
end;

method CtrlFormBrowse.RemakeReport;
begin
  Text := Report.Title;
  Report.MakeReport(true);
  MakeHtml;
end;

method CtrlFormBrowse.DataChanged;
begin
  MakeHtml;
end;

method CtrlFormBrowse.SettingsChanged;
begin
  fReport.SettingsChanged;
  MakeHtml;
end;

method CtrlFormBrowse.ItemMenuEditAddReport_Click(sender: System.Object; e: System.EventArgs);
begin
  if fReport is DexiReportGroup then
    exit;
  if Report.Model.RptCount <= 0 then
    exit;
  Report.Model.Reports[0].AddReport(fReport.Copy);
end;

end.