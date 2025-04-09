// FormBoundEdit.pas is part of
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
// FormBoundEdit.pas implements a form for editing bounds of 'DexiDiscretizationFunction'.
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
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormBoundEdit.
  /// </summary>
  FormBoundEdit = partial public class(System.Windows.Forms.Form)
  private
    method RBtnHigher_Click(sender: System.Object; e: System.EventArgs);
    method RBtnLower_Click(sender: System.Object; e: System.EventArgs);
    method EditBound_Validated(sender: System.Object; e: System.EventArgs);
    method EditBound_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    fBound: DexiBound;
    fBoundValue: Float;
    fBoundAssociation: DexiBoundAssociation;
    fCheck: Predicate<Float>;
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method SetForm(aTitle: String; aBound: DexiBound; aCheck: Predicate<Float> := nil);
    property BoundValue: Float read fBoundValue;
    property BoundAssociation: DexiBoundAssociation read fBoundAssociation;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormBoundEdit;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
end;

method FormBoundEdit.Dispose(aDisposing: Boolean);
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


method FormBoundEdit.SetForm(aTitle: String; aBound: DexiBound; aCheck: Predicate<Float> := nil);
begin
  Text := aTitle;
  fBound := aBound;
  if fBound = nil then
    begin
      fBoundValue := Consts.NaN;
      fBoundAssociation := DexiBoundAssociation.Down;
      EditBound.Text := '';
    end
  else
    begin
      fBoundValue := fBound.Bound;
      fBoundAssociation := fBound.Association;
      EditBound.Text := Utils.FltToStr(fBoundValue, true);
    end;
  fCheck := aCheck;
  RBtnLower.Checked := fBoundAssociation = DexiBoundAssociation.Down;
  RBtnHigher.Checked := fBoundAssociation = DexiBoundAssociation.Up;
  EditBound.Focus;
  EditBound.Select;
end;

method FormBoundEdit.EditBound_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  var lText := EditBound.Text;
  var lValue := AppUtils.EditedFloatNumber(lText);
  if not assigned(lValue) or Consts.IsInfinity(lValue) or Consts.IsNaN(lValue) or ((fCheck <> nil) and not fCheck(lValue)) then
    e.Cancel := true;
  BtnOK.Enabled := not e.Cancel;
end;

method FormBoundEdit.EditBound_Validated(sender: System.Object; e: System.EventArgs);
begin
  fBoundValue := AppUtils.EditedFloatNumber(EditBound.Text);
end;

method FormBoundEdit.RBtnLower_Click(sender: System.Object; e: System.EventArgs);
begin
  fBoundAssociation := DexiBoundAssociation.Down;
end;

method FormBoundEdit.RBtnHigher_Click(sender: System.Object; e: System.EventArgs);
begin
  fBoundAssociation := DexiBoundAssociation.Up;
end;

end.