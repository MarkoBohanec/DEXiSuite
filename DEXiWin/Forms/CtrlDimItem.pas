// CtrlDimItem.pas is part of
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
// CtrlDimItem.pas implements a user control used to select dimensions for displaying tabular
// finctions in CtrlFormFunctChart.pas.
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
  /// Summary description for CtrlDimItem.
  /// </summary>
  CtrlDimItem = public partial class(System.Windows.Forms.UserControl)
  private
    method LblText_Click(sender: System.Object; e: System.EventArgs);
    method RadioBtn_Click(sender: System.Object; e: System.EventArgs);
    method ChkBox_Click(sender: System.Object; e: System.EventArgs);
    method LblImage_Click(sender: System.Object; e: System.EventArgs);
    fAttIndex: Integer; // -1 for output
    fArgIndex: Integer; //  0: non-dimension arg; 1: first dimension arg; 2: second dimension arg
    fValIndex: Integer;
    fReversed: Boolean;
    fUpdateLevel: Integer := 0;
  protected
    method Dispose(disposing: Boolean); override;
    method GetChecked: Boolean;
    method SetChecked(aChecked: Boolean);
    method SetReversed(aReversed: Boolean);
    method SetupControls;
  public
    constructor;
    method Configure(aText: String; aAttIndex, aArgIndex, aValIndex: Integer; aChecked, aReversed: Boolean);
    property IndentWidth: Integer read PanelIndent.Width write PanelIndent.Width;
    property ShowIndent: Boolean read PanelIndent.Visible write PanelIndent.Visible;
    property ShowCheck: Boolean read ChkBox.Visible write ChkBox.Visible;
    property ShowRadio: Boolean read RadioBtn.Visible write RadioBtn.Visible;
    property AttIndex: Integer read fAttIndex;
    property ArgIndex: Integer read fArgIndex;
    property ValIndex: Integer read fValIndex;
    property Checked: Boolean read GetChecked write SetChecked;
    property Text: String read LblText.Text write LblText.Text; reintroduce;
    property Reversed: Boolean read fReversed write SetReversed;
    event DirectionClick: EventHandler;
    event CheckClick: EventHandler;
    event RadioClick: EventHandler;
    event TextClick: EventHandler;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlDimItem;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method CtrlDimItem.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlDimItem.GetChecked: Boolean;
begin
  result :=
    if ShowCheck then ChkBox.Checked
    else RadioBtn.Checked;
end;

method CtrlDimItem.SetChecked(aChecked: Boolean);
begin
  inc(fUpdateLevel);
  try
    ChkBox.Checked := aChecked;
    RadioBtn.Checked := aChecked;
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlDimItem.SetReversed(aReversed: Boolean);
begin
  fReversed := aReversed;
  inc(fUpdateLevel);
  try
    LblImage.ImageKey :=
      if fAttIndex < 0 then
        if fReversed then "ImgDimDown"
        else "ImgDimUp"
      else if fArgIndex = 1 then
        if fReversed then "ImgDimLD"
        else "ImgDimLU"
      else if fArgIndex = 2 then
        if fReversed then "ImgDimRD"
        else "ImgDimRU"
      else "ImgDimEmpty";
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlDimItem.SetupControls;
begin
  inc(fUpdateLevel);
  try
    PanelIndent.Visible := (fArgIndex = 0) and (fValIndex >= 0);
    ChkPanel.Width := ChkBox.Width;
    if fAttIndex < 0 then
      begin
        ChkPanel.Show;
        ChkBox.Hide;
        RadioBtn.Hide;
      end
    else
      begin
        ChkPanel.Hide;
        var lChkBoxVisible := (fAttIndex >= 0) and (fValIndex < 0);
        if lChkBoxVisible then
          begin
            ChkBox.Show;
            RadioBtn.Hide;
          end
        else
          begin
            ChkBox.Hide;
            RadioBtn.Show;
          end;
      end;
    LblImage.Visible := fValIndex < 0;
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlDimItem.Configure(aText: String; aAttIndex, aArgIndex, aValIndex: Integer; aChecked, aReversed: Boolean);
begin
  Text := aText;
  fAttIndex := aAttIndex;
  fArgIndex := aArgIndex;
  fValIndex := aValIndex;
  SetupControls;
  Checked := aChecked;
  Reversed := aReversed;
end;

method CtrlDimItem.LblImage_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if LblImage.ImageKey = "ImgDimEmpty" then
    exit;
  if assigned(DirectionClick) then
    DirectionClick(self, e);
end;

method CtrlDimItem.ChkBox_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if assigned(CheckClick) then
    CheckClick(self, e);
end;

method CtrlDimItem.RadioBtn_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if assigned(RadioClick) then
    RadioClick(self, e);
end;

method CtrlDimItem.LblText_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if assigned(TextClick) then
    TextClick(self, e);
end;

end.