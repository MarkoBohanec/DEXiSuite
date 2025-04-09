// FormNameEdit.pas is part of
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
// FormNameEdit.pas implements a form for editing names and descriptions of various DEXi objects.
// Uses 'CtrlFormNameEdit'.
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
  /// Summary description for FormNameEdit.
  /// </summary>
  FormNameEdit = partial public class(System.Windows.Forms.Form)
  private
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method SetForm(aTitle: String := nil; aName: String := nil; aDescription: String := nil);
    method SetTexts(aName: String := nil; aDescription: String := nil);
    property NameText: String read NameEdit.NameText;
    property DescriptionText: String read NameEdit.DescriptionText;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormNameEdit;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  NameEdit.SetLabels('Model &name', 'Model &description');
end;

method FormNameEdit.Dispose(aDisposing: Boolean);
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

method FormNameEdit.SetForm(aTitle: String := nil; aName: String := nil; aDescription: String := nil);
begin
  Font := AppData.CurrentAppFont;
  Text := aTitle;
  NameEdit.SetLabels(aName, aDescription);
end;

method FormNameEdit.SetTexts(aName: String := nil; aDescription: String := nil);
begin
  NameEdit.SetTexts(aName, aDescription);
end;

end.