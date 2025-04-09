// CtrlRptFormat.pas is part of
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
// CtrlRptFormat.pas implements a user control for editing of 'DexiReportFormat' and
// 'DexiReportParameters'.
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
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for CtrlRptFormat.
  /// </summary>
  CtrlRptFormat = public partial class(System.Windows.Forms.UserControl)
  private
    method NumDistrib_ValueChanged(sender: System.Object; e: System.EventArgs);
    method NumDefDet_ValueChanged(sender: System.Object; e: System.EventArgs);
    method NumWeights_ValueChanged(sender: System.Object; e: System.EventArgs);
    method NumFloat_ValueChanged(sender: System.Object; e: System.EventArgs);
    method EditTree_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method EditTitle_TextChanged(sender: System.Object; e: System.EventArgs);
    method BtnFont_Click(sender: System.Object; e: System.EventArgs);
    method BtnResetFont_Click(sender: System.Object; e: System.EventArgs);
    fReport: DexiReport;
    fFormat: DexiReportFormat;
    fParameters: DexiReportParameters;
    fReportTitle: String;
    fOriginalFont: Font;
    fOriginalFontName: String;
    fOriginalFontSize: Float;
    fFont: Font;
    fUpdateLevel: Integer;
  protected
    method Dispose(disposing: Boolean); override;
  public
    constructor;
    method SetForm(aReport: DexiReport; aParameters: DexiReportParameters := nil; aParametersOnly: Boolean := false);
    method UpdateForm;
    property Format: DexiReportFormat read fFormat;
    property SelectedFont: Font read fFont;
    property ChangedFont: Boolean read fFont <> fOriginalFont;
    property ReportTitle: String read fReportTitle;
    property CanEditTitle: Boolean read EditTitle.Enabled write EditTitle.Enabled;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlRptFormat;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fUpdateLevel := 0;
end;

method CtrlRptFormat.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    fReport := nil;
    fFormat := nil;
    fParameters := nil;
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlRptFormat.SetForm(aReport: DexiReport; aParameters: DexiReportParameters := nil; aParametersOnly: Boolean := false);
require
  aReport <> nil;
begin
  fReport := aReport;
  inc(fUpdateLevel);
  try
    fFormat := new DexiReportFormat(fReport.Format);
    fOriginalFont := ReportManager.ReportFont(fFormat);
    fOriginalFontName := fFormat.FontName;
    fOriginalFontSize := fFormat.FontSize;
    fFont := fOriginalFont;
    fReportTitle := aReport.Title;
    EditTitle.Text := fReportTitle;
    fParameters := aParameters;
    if fParameters = nil then
      PanelDecimals.Visible := false
    else
      begin
        PanelDecimals.Visible := true;
        NumFloat.Value := fParameters.FltDecimals;
        NumWeights.Value := fParameters.WeiDecimals;
        NumDefDet.Value := fParameters.DefDetDecimals;
        NumDistrib.Value := fParameters.MemDecimals;
      end;
    if aParametersOnly then
      begin
        PanelFont.Visible := false;
      end;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlRptFormat.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  LblFont.Font := fFont;
  LblFont.Text := $'{fFont.Name} [{fFont.Size}]';
end;

method CtrlRptFormat.BtnFont_Click(sender: System.Object; e: System.EventArgs);
begin
  using lFontDlg := new FontDialog(Font := fFont) do
    if lFontDlg.ShowDialog =  DialogResult.OK then
      begin
        fFont := lFontDlg.Font;
        fFormat.FontName := fFont.Name;
        fFormat.FontSize := fFont.Size;
        UpdateForm;
      end;
end;

method CtrlRptFormat.BtnResetFont_Click(sender: System.Object; e: System.EventArgs);
begin
  fFont := fOriginalFont;
  fFormat.FontName := fOriginalFontName;
  fFormat.FontSize := fOriginalFontSize;
  UpdateForm;
end;

method CtrlRptFormat.EditTitle_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  fReportTitle := EditTitle.Text;
end;

method CtrlRptFormat.EditTree_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
//  fFormat.TreePattern := RptTreePattern(EditTree.SelectedIndex);
end;

method CtrlRptFormat.NumFloat_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fParameters = nil) or (fUpdateLevel > 0) then
    exit;
  fParameters.FltDecimals := Integer(NumFloat.Value);
end;

method CtrlRptFormat.NumWeights_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fParameters = nil) or (fUpdateLevel > 0) then
    exit;
  fParameters.WeiDecimals := Integer(NumWeights.Value);
end;

method CtrlRptFormat.NumDefDet_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fParameters = nil) or (fUpdateLevel > 0) then
    exit;
  fParameters.DefDetDecimals := Integer(NumDefDet.Value);
end;

method CtrlRptFormat.NumDistrib_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fParameters = nil) or (fUpdateLevel > 0) then
    exit;
  fParameters.MemDecimals := Integer(NumDistrib.Value);
end;

end.