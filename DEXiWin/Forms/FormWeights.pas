// FormWeights.pas is part of
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
// FormWeights.pas implements a form for editing attribute weights in the context of
// a single DEXi aggregation function.
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
  BrightIdeasSoftware,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormWeights.
  /// </summary>
  FormWeights = partial public class(System.Windows.Forms.Form)
  private
    method BtnApply_Click(sender: System.Object; e: System.EventArgs);
    method BtnOK_Click(sender: System.Object; e: System.EventArgs);
    method BtnMax100_Click(sender: System.Object; e: System.EventArgs);
    method BtnSum100_Click(sender: System.Object; e: System.EventArgs);
    method ViewWeights_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method FormWeights_Shown(sender: System.Object; e: System.EventArgs);
    method ViewWeights_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method ViewWeights_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewWeights_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ViewWeights_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewWeights_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
    fFormText: String;
    fFunctEditForm: FormFunctEditTabular;
    fAttribute: DexiAttribute;
    fFunct: DexiTabularFunction;
    fRequiredWeights: FltArray;
    fActualWeights: FltArray;
    fWeights: List<WeightObject>;
    fLastSelected: WeightObject;
    fUpdateLevel: Integer;
  protected
    method Dispose(aDisposing: Boolean); override;
    method WeightFltToInt(aFlt: Float): Integer;
    method UpdateActualWeights;
    method WeightsToTable;
    method TableToWeights;
    method GetActFromFunct;
    method GetReqFromFunct;
    method GetReqFromTable;
    method SetReqToFunct;
    method SelectionChanged;
  public
    constructor;
    method SetForm(aFunctEditForm: FormFunctEditTabular);
    method EditCell;
    property SelectedWeight: WeightObject read WeightObject(ViewWeights:SelectedObject);
  end;

type
  WeightObject = public class
  public
    property Name: String;
    property Required: Integer;
    property Actual: Integer;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormWeights;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
  ColRequired.CellEditUseWholeCell := true;
  ViewWeights.FullRowSelect := true;
  ViewWeights.SelectedBackColor := AppSettings.SelectedColor;
  ViewWeights.SelectedForeColor := ViewWeights.ForeColor;
end;

method FormWeights.Dispose(aDisposing: Boolean);
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

method FormWeights.WeightFltToInt(aFlt: Float): Integer;
begin
  result := Integer(Math.Round(Math.Min(100, Math.Max(0, aFlt))));
end;

method FormWeights.WeightsToTable;
begin
  for lArg := 0 to fWeights.Count - 1 do
    begin
      fWeights[lArg].Required := WeightFltToInt(fRequiredWeights[lArg]);
      fWeights[lArg].Actual := WeightFltToInt(fActualWeights[lArg]);
    end;
end;

method FormWeights.TableToWeights;
begin
  for lArg := 0 to fWeights.Count - 1 do
    begin
      fRequiredWeights[lArg] := fWeights[lArg].Required;
      fActualWeights[lArg] := fWeights[lArg].Actual;
    end;
end;

method FormWeights.GetActFromFunct;
begin
  fActualWeights := Utils.CopyFltArray(fFunct.ActualWeights);
end;

method FormWeights.GetReqFromFunct;
begin
  fRequiredWeights := Utils.CopyFltArray(fFunct.RequiredWeights);
end;

method FormWeights.GetReqFromTable;
begin
  for lArg := 0 to fWeights.Count - 1 do
    fRequiredWeights[lArg] := fWeights[lArg].Required;
end;

method FormWeights.UpdateActualWeights;
begin
  fFunct.CalcActualWeights(true);
end;

method FormWeights.SetReqToFunct;
begin
  fFunct.Rounding :=
    if RBtnDown.Checked then -1
    else if RBtnUp.Checked then 1
    else 0;
  fFunct.UseWeights := true;
  fFunct.RequiredWeights := Utils.CopyFltArray(fRequiredWeights);
  fFunct.ReviseFunction(true);
end;

method FormWeights.SelectionChanged;
begin
  if fUpdateLevel > 0 then
    exit;
  ViewWeights.RefreshObject(fLastSelected);
  inc(fUpdateLevel);
  try
    var lSelectedWeight := SelectedWeight;
    if lSelectedWeight = nil then
      if fLastSelected <> nil then
        ViewWeights.SelectObject(fLastSelected)
      else if fWeights.Count > 0 then
        ViewWeights.SelectObject(fWeights[0]);
    lSelectedWeight := SelectedWeight;
    if lSelectedWeight <> nil then
      ViewWeights.RefreshObject(lSelectedWeight);
  finally
    dec(fUpdateLevel);
  end;
  fLastSelected := SelectedWeight;
end;

method FormWeights.SetForm(aFunctEditForm: FormFunctEditTabular);
begin
  Font := AppData.CurrentAppFont;
  fFunctEditForm := aFunctEditForm;
  fAttribute := fFunctEditForm.Attribute;
  Text := String.Format(fFormText, fAttribute:Name);
  fUpdateLevel := 0;
  fLastSelected := nil;
  fFunct := fFunctEditForm.Funct;
  UpdateActualWeights;
  GetActFromFunct;
  GetReqFromFunct;
  fWeights := new List<WeightObject>;
  for lArg := 0 to fFunct.ArgCount - 1 do
    fWeights.Add(new WeightObject(Name := fAttribute.Inputs[lArg].Name));
  WeightsToTable;
  ViewWeights.SetObjects(fWeights);
  RBtnDown.Checked := fFunct.Rounding = -1;
  RBtnNone.Checked := fFunct.Rounding = 0;
  RBtnUp.Checked := fFunct.Rounding = 1;
  SelectionChanged;
end;

method FormWeights.EditCell;
begin
  if SelectedWeight = nil then
    exit;
  ViewWeights.StartCellEdit(ViewWeights.ModelToItem(SelectedWeight), ColRequired.Index);
end;

method FormWeights.ViewWeights_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
begin
  if e.RowIndex = ViewWeights.SelectedIndex then
    begin
      e.SubItem.BackColor := AppSettings.SelectedColor;
      if e.Column = ColRequired then
        begin
          var cbd := new CellBorderDecoration;
          cbd.BoundsPadding := new Size(0, -1);
          cbd.BorderPen := AppSettings.EditPen;
          cbd.FillBrush := nil;
          cbd.CornerRounding := 0;
          e.SubItem.Decoration := cbd;
        end;
    end;
end;

method FormWeights.ViewWeights_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if sender = ViewWeights then
    begin
      var ht := ViewWeights.OlvHitTest(e.Location.X, e.Location.Y);
      if ht <> nil then
        begin
          if ht.RowObject <> nil then
            begin
              ViewWeights.SelectObject(ht.RowObject)
            end;
        end;
      ViewWeights.RefreshObjects(fWeights);
    end;

end;

method FormWeights.ViewWeights_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if SelectedWeight = nil then
    exit;
  if e.KeyCode = Keys.F2 then
    begin
      EditCell;
      e.Handled := true;
    end
end;

method FormWeights.ViewWeights_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if SelectedWeight = nil then
    exit;
  if e.Column <> ColRequired then
    exit;
  if e.Control is IntUpDown then
    begin
      var lCtrl := IntUpDown(e.Control);
      lCtrl.Minimum := 0;
      lCtrl.Maximum := 100;
      lCtrl.Select(0, lCtrl.Text.Length);
    end;
end;

method FormWeights.ViewWeights_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method FormWeights.FormWeights_Shown(sender: System.Object; e: System.EventArgs);
begin
  ViewWeights.Focus;
end;

method FormWeights.ViewWeights_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if (SelectedWeight = nil) or (SelectedWeight = fWeights.Last) then
    exit;
  ViewWeights.SelectedIndex := ViewWeights.SelectedIndex + 1;
  ViewWeights.Focus;
  ViewWeights.RefreshObjects(fWeights);
end;

method FormWeights.BtnSum100_Click(sender: System.Object; e: System.EventArgs);
begin
  GetReqFromTable;
  GetActFromFunct;
  Values.NormSum(var fRequiredWeights);
  Values.NormSum(var fActualWeights);
  WeightsToTable;
  ViewWeights.RefreshObjects(fWeights);
end;

method FormWeights.BtnMax100_Click(sender: System.Object; e: System.EventArgs);
begin
  GetReqFromTable;
  GetActFromFunct;
  Values.NormMax(var fRequiredWeights);
  Values.NormMax(var fActualWeights);
  WeightsToTable;
  ViewWeights.RefreshObjects(fWeights);
end;

method FormWeights.BtnOK_Click(sender: System.Object; e: System.EventArgs);
begin
  GetReqFromTable;
  SetReqToFunct;
  fFunctEditForm.FunctionValueChanged;
end;

method FormWeights.BtnApply_Click(sender: System.Object; e: System.EventArgs);
begin
  GetReqFromTable;
  SetReqToFunct;
  fFunctEditForm.FunctionValueChanged;
  UpdateActualWeights;
  GetReqFromFunct;
  GetActFromFunct;
  WeightsToTable;
  ViewWeights.RefreshObjects(fWeights);
end;

end.