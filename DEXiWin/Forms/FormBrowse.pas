// FormBrowse.pas is part of
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
// FormBrowse.pas implements an internal browser form. Uses 'CtrlFormBrowse'.
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
  /// Summary description for FormBrowse.
  /// </summary>
  FormBrowse = partial public class(System.Windows.Forms.Form)
  private
    method FormBrowse_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
    method FormBrowse_Shown(sender: System.Object; e: System.EventArgs);
  private
  protected
    method Dispose(aDisposing: Boolean); override;
    method SetReport(aReport: DexiReport);
  public
    constructor;
    property Report: DexiReport read Browser.Report write SetReport;
    property ParamForm: FormReportParameters read Browser.ParamForm write Browser.ParamForm;
    property ManagerForm: FormReportManager read Browser.ManagerForm write Browser.ManagerForm;
    property Browser: CtrlFormBrowse read Browser;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormBrowse;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method FormBrowse.Dispose(aDisposing: Boolean);
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

method FormBrowse.SetReport(aReport: DexiReport);
begin
  if aReport = nil then
    exit;
  Text := aReport.Title;
  Browser.FormMode := true;
  Browser.Report := aReport;
end;

method FormBrowse.FormBrowse_Shown(sender: System.Object; e: System.EventArgs);
begin
  WindowState := AppSettings.BrowseWindowState;
end;

method FormBrowse.FormBrowse_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
begin
  AppSettings.BrowseWindowState := WindowState;
end;

end.