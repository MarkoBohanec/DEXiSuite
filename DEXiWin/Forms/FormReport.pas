// FormReport.pas is part of
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
// FormReport.pas implements a stand-alone form for displaying DEXi reports.
// Uses 'CtrlFormReport'.
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
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormReport.
  /// </summary>
  FormReport = partial public class(System.Windows.Forms.Form)
  private
    method FormReport_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
    method FormReport_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
    method FormReport_Shown(sender: System.Object; e: System.EventArgs);
    fReport: DexiReport;
  protected
    method Dispose(aDisposing: Boolean); override;
    method SetReport(aReport: DexiReport);
    method RemakeReport;
  public
    constructor;
    property Report: DexiReport read Reporter.Report write SetReport;
    property ParamForm: FormReportParameters read Reporter.ParamForm write Reporter.ParamForm;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormReport;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  Reporter.Init;
  Reporter.Focus;

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  Reporter.OnRemake :=
  method
  begin
    RemakeReport;
  end
end;

method FormReport.Dispose(aDisposing: Boolean);
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

method FormReport.SetReport(aReport: DexiReport);
begin
  Text := aReport.Title;
  fReport := aReport;
end;

method FormReport.RemakeReport;
begin
  Text := fReport.Title;
end;

method FormReport.FormReport_Shown(sender: System.Object; e: System.EventArgs);
begin
  WindowState := AppSettings.ReportWindowState;
  Reporter.Report := fReport;
  Reporter.StartPage := 0;
  Reporter.FormMode := true;
  StartPosition := FormStartPosition.Manual;
end;

method FormReport.FormReport_FormClosed(sender: System.Object; e: System.Windows.Forms.FormClosedEventArgs);
begin
  Reporter.DoLeave;
end;

method FormReport.FormReport_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
begin
  AppSettings.ReportWindowState := WindowState;
end;

end.