// CtrlNameEdit.pas is part of
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
// CtrlNameEdit.pas implements a user control for editing the name and description
// of various DEXiLibrary classes, particularly models, attributes and alternatives.
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
  /// Summary description for CtrlNameEdit.
  /// </summary>
  CtrlNameEdit = public partial class(System.Windows.Forms.UserControl)
  private
    method TextName_TextChanged(sender: System.Object; e: System.EventArgs);
    method TextDescription_TextChanged(sender: System.Object; e: System.EventArgs);
  private
    fMultiline := true;
    fEditLevel := 0;
  protected
    method Dispose(disposing: Boolean); override;
    method SetMultiline(aMultiline: Boolean);
    method OnEditChanged(e: EventArgs); virtual;
  public
    constructor;
    property Multiline: Boolean read fMultiline write SetMultiline;
    method SetLabels(aName: String := nil; aDescription: String := nil);
    method SetTexts(aName: String := nil; aDescription: String := nil);
    property NameText: String read TextName.Text write TextName.Text;
    property DescriptionText: String read TextDescription.Text write TextDescription.Text;
    event EditChanged: EventHandler;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlNameEdit;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  if fMultiline <> TextDescription.Multiline then
    Multiline := fMultiline;
end;

method CtrlNameEdit.Dispose(disposing: Boolean);
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

method CtrlNameEdit.SetMultiline(aMultiline: Boolean);
begin
  fMultiline := aMultiline;
  if TextDescription <> nil then
    TextDescription.Multiline := fMultiline;
end;

method CtrlNameEdit.SetLabels(aName: String := nil; aDescription: String := nil);
begin
  if aName <> nil then
    LblName.Text := aName;
  if aDescription <> nil then
    LblDescription.Text := aDescription;
end;

method CtrlNameEdit.SetTexts(aName: String := nil; aDescription: String := nil);
begin
  inc(fEditLevel);
  try
    if aName <> nil then
      TextName.Text := aName;
    if aDescription <> nil then
      TextDescription.Text := aDescription;
  finally
    dec(fEditLevel);
  end;
end;

method CtrlNameEdit.OnEditChanged(e: EventArgs);
begin
  if assigned(EditChanged) then
    EditChanged.Invoke(self, e);
end;

method CtrlNameEdit.TextDescription_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fEditLevel <= 0) and (ActiveControl = TextDescription)  then
    OnEditChanged(EventArgs.Empty);
  if not Multiline then
    exit;
  var lRect := TextRenderer.MeasureText(TextDescription.Text, TextDescription.Font,
                new Size(TextDescription.Width, high(Integer)), TextFormatFlags.WordBreak or TextFormatFlags.TextBoxControl);
  try
    TextDescription.ScrollBars :=
      if lRect.Height > TextDescription.Height then ScrollBars.Vertical
      else ScrollBars.None;
  except
  end;
end;

method CtrlNameEdit.TextName_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fEditLevel <= 0) and (ActiveControl = TextName) then
    OnEditChanged(EventArgs.Empty);
end;

end.