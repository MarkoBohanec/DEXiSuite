// FormFunctChart.pas is part of
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
// FormFunctChart.pas implements a form for displaying a DexiTabularFunction in 3D form.
// Uses 'CtrlFormFunctChart'.
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
  /// Summary description for FormFunctChart.
  /// </summary>
  FormFunctChart = partial class(System.Windows.Forms.Form)
  private
    method FormFunctChart_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
    method FormFunctChart_Shown(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    property Model: DexiModel read FunctViewer:Model;
    property Attribute: DexiAttribute read FunctViewer:Attribute;
    property Funct: DexiTabularFunction read FunctViewer:Funct;
    method SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction);
  end;

implementation

{$REGION Construction and Disposition}
constructor FormFunctChart;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method FormFunctChart.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    FunctViewer := nil;
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormFunctChart.SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction);
begin
  Text := String.Format(DexiStrings.TitleFunctChart, aAttribute.Name);
  FunctViewer.SetForm(aModel, aAttribute, aFunct);
end;

method FormFunctChart.FormFunctChart_Shown(sender: System.Object; e: System.EventArgs);
begin
  WindowState := AppSettings.FunctChartWindowState;
end;

method FormFunctChart.FormFunctChart_FormClosing(sender: System.Object; e: System.Windows.Forms.FormClosingEventArgs);
begin
  AppSettings.FunctChartWindowState := WindowState;
end;

end.