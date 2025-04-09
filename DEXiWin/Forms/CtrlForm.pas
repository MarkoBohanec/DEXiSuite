// CtrlForm.pas is part of
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
// CtrlForm.pas implements the basic class 'CtrlForm' for "DEXiWin Control-Forms".
// A DEXiWin control form is essentially a form that is not displayed autonomously as a normal form,
// but rather as a part of some parent control, typically a "real" form or a page of a tab control.
// 'CtrlForm' defines properties 'CtrlMenu' and 'CtrlTool', i.e., menu items and toolbar components
// that are in a logical sense bound to this 'CtrlForm' and operate on its components, but are
// displayed in (i.e., merged with) the main DEXiWin's menu and toolbar.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel;

type
  /// <summary>
  /// Summary description for CtrlForm.
  /// </summary>
  CtrlForm = public partial class(System.Windows.Forms.UserControl)
  private
    method CtrlForm_VisibleChanged(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(disposing: Boolean); override;
    method MergeMenuTool(aMenu: MenuStrip; aTool: ToolStrip); virtual;
  public
    constructor;
    method Activate;
    property CtrlMenu: MenuStrip := nil;
    property CtrlTool: ToolStrip := nil;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlForm;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  Dock := DockStyle.Fill;
end;

method CtrlForm.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();
    //
    // TODO: Add custom disposition code here
    //
    AppDisposeHandler.DisposeUndisposed(0);
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlForm.MergeMenuTool(aMenu: MenuStrip; aTool: ToolStrip);
begin
  var lModForm := AppUtils.ModelForm(self);
  AppUtils.Show(lModForm = nil, [aMenu, aTool]);
  if lModForm <> nil then
    lModForm.Merge(aMenu, aTool);
end;

method CtrlForm.Activate;
begin
  if Visible then
    MergeMenuTool(CtrlMenu, CtrlTool)
  else
    MergeMenuTool(nil, nil);
end;

method CtrlForm.CtrlForm_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  Activate;
end;

end.