// FormSymmetricity.pas is part of
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
// FormSymetricity.pas implements a form that allows the user to select two attributes to be checked
// for symmetricity and displays the current symmetricity status of those attributes.
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
  /// Summary description for FormSymmetricity.
  /// </summary>
  FormSymmetricity = partial public class(System.Windows.Forms.Form)
  private
    method BtnEnforce_Click(sender: System.Object; e: System.EventArgs);
    method Att1Edit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fFunctEditForm: FormFunctEditTabular;
    fAttribute: DexiAttribute;
    fFunct: DexiTabularFunction;
    fStatus: DexiSymmetricityStatus;
    fUpdateLevel: Integer;
  protected
    method Dispose(aDisposing: Boolean); override;
  public
    constructor;
    method SetForm(aFunctEditForm: FormFunctEditTabular);
    method CheckSymmetricity;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormSymmetricity;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
end;

method FormSymmetricity.Dispose(aDisposing: Boolean);
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

method FormSymmetricity.SetForm(aFunctEditForm: FormFunctEditTabular);
begin
  Font := AppData.CurrentAppFont;
  fFunctEditForm := aFunctEditForm;
  fAttribute := fFunctEditForm.Attribute;
  Text := String.Format(fFormText, fAttribute:Name);
  fFunct := fFunctEditForm.Funct;
  fUpdateLevel := 1;
  Att1Edit.Items.Clear;
  Att2Edit.Items.Clear;
  for i := 0 to fAttribute.InpCount - 1 do
    begin
      Att1Edit.Items.Add(fAttribute.Inputs[i].Name);
      Att2Edit.Items.Add(fAttribute.Inputs[i].Name);
    end;
  Att1Edit.SelectedIndex := 0;
  fUpdateLevel := 0;
  Att2Edit.SelectedIndex := 1;
end;

method FormSymmetricity.CheckSymmetricity;
begin
  fStatus := nil;
  BtnEnforce.Enabled := false;
  var lArg1 := Att1Edit.SelectedIndex;
  var lArg2 := Att2Edit.SelectedIndex;
  if lArg1 = lArg2 then
    begin
      StatusBox.Text := DexiStrings.MsgSameAttributes;
      exit;
    end;
  fStatus := fFunct.SymmetricityStatus(lArg1, lArg2);
  if not fStatus.ArgsCompatible then
    begin
      StatusBox.Text := DexiStrings.MsgAsymmetricAttributes;
      exit;
    end;
  if fStatus.Asymmetric.Count = 0 then
    StatusBox.Text := DexiStrings.MsgSymmetricAttributes
  else
    begin
      StatusBox.Text := DexiStrings.MsgAsymmetricRules;
      StatusBox.AppendText(Environment.LineBreak);
      for each lPair in fStatus.Asymmetric do
        StatusBox.AppendText($'{lPair.I1 + 1} : {lPair.I2 + 1}' + Environment.LineBreak);
    end;
  if fStatus.CanEnforce.Count > 0 then
    begin
      StatusBox.AppendText(Environment.LineBreak);
      StatusBox.AppendText(DexiStrings.MsgCanEnforce + Environment.LineBreak);
      for each lPair in fStatus.CanEnforce do
        StatusBox.AppendText($'Rule {lPair.I1 + 1} --> {lPair.I2 + 1}' + Environment.LineBreak);
      BtnEnforce.Enabled := true;
    end;
end;

method FormSymmetricity.Att1Edit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CheckSymmetricity;
end;

method FormSymmetricity.BtnEnforce_Click(sender: System.Object; e: System.EventArgs);
begin
  if Utils.ListCount(fStatus:CanEnforce) = 0 then
    exit;
  for each lPair in fStatus.CanEnforce do
    begin
      fFunct.RuleValue[lPair.I2] := fFunct.RuleValue[lPair.I1];
      fFunct.RuleEntered[lPair.I2] := fFunct.RuleEntered[lPair.I1];
    end;
  fFunctEditForm.FunctionValueChanged;
  CheckSymmetricity;
end;

end.