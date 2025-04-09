// FormScaleEditContinuous.pas is part of
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
// FormScaleEditContinuous.pas implements a form for editing 'DexiContinuousScale'.
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
  /// Summary description for FormScaleEditContinuous.
  /// </summary>
  FormScaleEditContinuous = partial public class(System.Windows.Forms.Form)
  private
    method EditDecimals_ValueChanged(sender: System.Object; e: System.EventArgs);
    method ItemToolScaleDescr_Click(sender: System.Object; e: System.EventArgs);
    method TextHP_Validated(sender: System.Object; e: System.EventArgs);
    method TextLP_Validated(sender: System.Object; e: System.EventArgs);
    method TextHP_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    method TextLP_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    method ItemToolOrder_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method TextUnit_TextChanged(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fAttribute: DexiAttribute;
    fScale: DexiContinuousScale;
    fUpdateLevel: Integer;
    fPanelColor: Color;

  protected
    method Dispose(aDisposing: Boolean); override;
    method UpdateForm;
    method OrderIndexOf(aOrder: DexiOrder): Integer;
    method IndexToOrder: DexiOrder;
  public
    constructor;
    method SetForm(aAttribute: DexiAttribute; aScale: DexiContinuousScale);
    property Scale: DexiContinuousScale read fScale;
    property Attribute: DexiAttribute read fAttribute;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormScaleEditContinuous;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
  fPanelColor := PanelNeutral.BackColor;
  PanelUnordered.Location.Y := PanelLow.Location.Y;
end;

method FormScaleEditContinuous.Dispose(aDisposing: Boolean);
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

method FormScaleEditContinuous.SetForm(aAttribute: DexiAttribute; aScale: DexiContinuousScale);
begin
  Font := AppData.CurrentAppFont;
  fAttribute := aAttribute;
  fScale := aScale;
  Text := String.Format(fFormText, fAttribute:Name);
  fUpdateLevel := 0;
  UpdateForm;
end;

method FormScaleEditContinuous.OrderIndexOf(aOrder: DexiOrder): Integer;
begin
  result :=
    case aOrder of
      DexiOrder.Ascending: 0;
      DexiOrder.Descending: 1;
      DexiOrder.None: 2;
    end;
end;

method FormScaleEditContinuous.IndexToOrder: DexiOrder;
begin
  result :=
    if ItemToolOrder.SelectedIndex = 0 then DexiOrder.Ascending
    else if ItemToolOrder.SelectedIndex = 1 then DexiOrder.Descending
    else DexiOrder.None;
end;

method FormScaleEditContinuous.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  inc(fUpdateLevel);
  try
    TextUnit.Text := fScale.ScaleUnit;
    EditDecimals.Value := fScale.FltDecimals;
    ItemToolOrder.SelectedIndex := OrderIndexOf(fScale.Order);
    TextLP.Text :=
      if Double.IsNegativeInfinity(fScale.BGLow) then ''
      else Utils.FltToStr(fScale.BGLow, false);
    TextHP.Text :=
      if Double.IsPositiveInfinity(fScale.BGHigh) then ''
      else Utils.FltToStr(fScale.BGHigh, false);
    AppUtils.Show(fScale.Order <> DexiOrder.None, PanelLow, PanelNeutral, PanelHigh, TextLP, TextHP, LabelLowBG, LabelHighBG);
    AppUtils.Show(fScale.Order = DexiOrder.None, PanelUnordered);
    case fScale.Order of
      DexiOrder.Ascending:
        begin
          LblLowBound.ForeColor := AppData.BadColor;
          LblUpBound.ForeColor := AppData.GoodColor;
          PanelLow.BackColor :=
            if Double.IsNegativeInfinity(fScale.BGLow) then fPanelColor
            else AppData.BadColor;
          PanelHigh.BackColor :=
            if Double.IsPositiveInfinity(fScale.BGHigh) then fPanelColor
            else AppData.GoodColor;
          LabelLowBG.Text := DexiStrings.BadThreshold;
          LabelHighBG.Text := DexiStrings.GoodThreshold;
        end;
      DexiOrder.Descending:
        begin
          LblLowBound.ForeColor := AppData.GoodColor;
          LblUpBound.ForeColor := AppData.BadColor;
          PanelLow.BackColor :=
            if Double.IsNegativeInfinity(fScale.BGLow) then fPanelColor
            else AppData.GoodColor;
          PanelHigh.BackColor :=
            if Double.IsPositiveInfinity(fScale.BGHigh) then fPanelColor
            else AppData.BadColor;
          LabelLowBG.Text := DexiStrings.GoodThreshold;
          LabelHighBG.Text := DexiStrings.BadThreshold;
        end;
      DexiOrder.None:
        begin
          LblLowBound.ForeColor := LblUnit.ForeColor;
          LblUpBound.ForeColor := LblUnit.ForeColor;
        end;
    end;
  finally
    dec(fUpdateLevel);
  end;
end;

method FormScaleEditContinuous.TextUnit_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fScale.ScaleUnit := TextUnit.Text;
end;

method FormScaleEditContinuous.EditDecimals_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fScale.FltDecimals := Integer(EditDecimals.Value);
end;

method FormScaleEditContinuous.ItemToolOrder_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fScale.Order := IndexToOrder;
  if fScale.Order = DexiOrder.None then
    begin
      fScale.BGLow := Double.NegativeInfinity;
      fScale.BGHigh := Double.PositiveInfinity;
    end;
  UpdateForm;
end;

method FormScaleEditContinuous.TextLP_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lText := TextLP.Text.Trim;
  if not String.IsNullOrEmpty(lText) then
    begin
      var lValue := AppUtils.EditedFloatNumber(lText);
      if not assigned(lValue) or (lValue > fScale.BGHigh) then
        begin
          e.Cancel := true;
          BtnOK.Enabled := false;
        end;
    end;
end;

method FormScaleEditContinuous.TextHP_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lText := TextHP.Text.Trim;
  if not String.IsNullOrEmpty(lText) then
    begin
      var lValue := AppUtils.EditedFloatNumber(lText);
      if not assigned(lValue) or (lValue < fScale.BGLow) then
        begin
          e.Cancel := true;
          BtnOK.Enabled := false;
        end;
    end;
end;

method FormScaleEditContinuous.TextLP_Validated(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lText := TextLP.Text.Trim;
  fScale.BGLow :=
    if String.IsNullOrEmpty(lText) then Double.NegativeInfinity
    else AppUtils.EditedFloatNumber(lText);
  BtnOK.Enabled := true;
  UpdateForm;
end;

method FormScaleEditContinuous.TextHP_Validated(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  var lText := TextHP.Text.Trim.Replace(',', '.');
  fScale.BGHigh :=
    if String.IsNullOrEmpty(lText) then Double.PositiveInfinity
    else AppUtils.EditedFloatNumber(lText);
  BtnOK.Enabled := true;
  UpdateForm;
end;

method FormScaleEditContinuous.ItemToolScaleDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  var lScaleDescrForm := AppData.NameEditForm;
  lScaleDescrForm.SetForm(DexiStrings.TitleSclNameEdit, DexiStrings.LabelSclNameEdit, DexiStrings.LabelSclDescrEdit);
  lScaleDescrForm.SetTexts(fScale.Name, fScale.Description);
  if lScaleDescrForm.ShowDialog = DialogResult.OK then
    begin
      fScale.Name := lScaleDescrForm.NameText;
      fScale.Description := lScaleDescrForm.DescriptionText;
      UpdateForm;
    end;
end;

end.