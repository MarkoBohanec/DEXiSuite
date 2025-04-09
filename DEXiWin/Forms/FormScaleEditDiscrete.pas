// FormScaleEditDiscrete.pas is part of
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
// FormScaleEditDiscrete.pas implements a form for editing 'DexiDiscreteScale'.
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
  /// Summary description for FormScaleEditDiscrete.
  /// </summary>
  FormScaleEditDiscrete = partial public class(System.Windows.Forms.Form)
  private
    method ViewValues_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewValues_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ViewValues_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewValues_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method ViewValues_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
    method ItemToolSetGood_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSetNeutral_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSetBad_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDuplicateValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolValueDescr_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDeleteValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddValueUp_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddValueDown_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolType_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method ItemToolOrder_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method ItemToolScaleDescr_Click(sender: System.Object; e: System.EventArgs);
    method ViewValues_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fModel: DexiModel;
    fAttribute: DexiAttribute;
    fScale: DexiDiscreteScale;
    fFunct: DexiTabularFunction;
    fParentFunct: DexiTabularFunction;
    fUpdateLevel: Integer;
    fLastSelected: DexiScaleValue;
    fSelectedColumn: OLVColumn;
  protected
    method Dispose(aDisposing: Boolean); override;
    method OrderIndexOf(aOrder: DexiOrder): Integer;
    method IndexToOrder: DexiOrder;
    method TypeIndexOf(aType: Boolean): Integer;
    method IndexToType: Boolean;
    method AddValue(aIdx: Integer);
    method DeleteValue(aIdx: Integer);
    method DuplicateValue;
    method MoveValue(aTo: Integer);
    method SetCategory(aCtg: Integer);
    method EditCell;
  public
    constructor;
    method SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aScale: DexiDiscreteScale);
    method UpdateForm;
    property Scale: DexiDiscreteScale read fScale;
    property Values: DexiScaleValueList read fScale:ValueList;
    property Attribute: DexiAttribute read fAttribute;
    property Funct: DexiFunction read fFunct;
    property ParentFunct: DexiFunction read fParentFunct;
    property SelectedValue: DexiScaleValue read DexiScaleValue(ViewValues.SelectedObject);
    property SelectedIndex: Integer read fScale.ValueIndex(SelectedValue);
  end;

implementation

{$REGION Construction and Disposition}
constructor FormScaleEditDiscrete;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
  fFormText := self.Text;
  ViewValues.FullRowSelect := true;
  ViewValues.SelectedBackColor := AppSettings.SelectedColor;
  ViewValues.SelectedForeColor := ViewValues.ForeColor;
  ViewValues.SmallImageList := AppData:ValueImages;
  ColValue.CellEditUseWholeCell := true;
  ColDescription.CellEditUseWholeCell := true;

  ColValue.ImageGetter :=
    method(x: Object)
    begin
      result := nil;
      if x is not DexiScaleValue then
        exit;
      var lIdx := fScale.ValueIndex(DexiScaleValue(x));
      if lIdx < 0 then
        exit;
      result :=
        if fScale.IsBad(lIdx) then'ImgValueBad'
        else if fScale.IsGood(lIdx) then'ImgValueGood'
        else 'ImgValue';
    end;

end;

method FormScaleEditDiscrete.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    ViewValues.SmallImageList := nil;
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormScaleEditDiscrete.SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aScale: DexiDiscreteScale);
begin
  Font := AppData.CurrentAppFont;
  fModel := aModel;
  fAttribute := aAttribute;
  fScale := aScale;
  fFunct :=
    if (fAttribute:Funct <> nil) and (fAttribute.Funct is DexiTabularFunction) then
      DexiTabularFunction(fAttribute.Funct.CopyFunction)
    else nil;
  fParentFunct :=
    if (fAttribute:Parent:Funct <> nil) and (fAttribute.Parent.Funct is DexiTabularFunction) then
      DexiTabularFunction(fAttribute.Parent.Funct.CopyFunction)
    else nil;
  fUpdateLevel := 0;
  fSelectedColumn := ColValue;
  inc(fUpdateLevel);
  try
    Text := String.Format(fFormText, fAttribute:Name);
    var lValues := Values;
    ViewValues.SetObjects(lValues);
    ActiveControl := ViewValues;
    ViewValues.Focus;
    fLastSelected := if lValues.Count > 0 then lValues[0] else nil;
    ViewValues.SelectObject(fLastSelected);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method FormScaleEditDiscrete.OrderIndexOf(aOrder: DexiOrder): Integer;
begin
  result :=
    case aOrder of
      DexiOrder.Ascending: 0;
      DexiOrder.Descending: 1;
      DexiOrder.None: 2;
    end;
end;

method FormScaleEditDiscrete.IndexToOrder: DexiOrder;
begin
  result :=
    if ItemToolOrder.SelectedIndex = 0 then DexiOrder.Ascending
    else if ItemToolOrder.SelectedIndex = 1 then DexiOrder.Descending
    else DexiOrder.None;
end;

method FormScaleEditDiscrete.TypeIndexOf(aType: Boolean): Integer;
begin
  result := if aType then 0 else 1;
end;

method FormScaleEditDiscrete.IndexToType: Boolean;
begin
  result := ItemToolType.SelectedIndex = 0;
end;

method FormScaleEditDiscrete.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  for each lValue in Values do
    ViewValues.RefreshObject(lValue);
  AppUtils.Enable(fScale.Count >= 2, BtnOK);
  AppUtils.Enable(SelectedValue <> nil,
    ItemToolValueDescr, ItemPopValueDescr, ItemToolSetBad, ItemToolSetNeutral, ItemToolSetGood, ItemPopSetBad, ItemPopSetNeutral, ItemPopSetGood);
  AppUtils.Enable(0 <= SelectedIndex < fScale.Count - 1, ItemToolMoveDown, ItemPopMoveDown);
  AppUtils.Enable(1 <= SelectedIndex < fScale.Count , ItemToolMoveUp, ItemPopMoveUp);
  AppUtils.Enable((SelectedValue <> nil) and fModel.CanAddValue(fAttribute, fScale, fParentFunct),
    ItemToolAddValueDown, ItemToolAddValueUp, ItemToolDuplicateValue, ItemPopAddValueDown, ItemPopAddValueUp, ItemPopDuplicateValue);
  AppUtils.Enable((SelectedValue <> nil) and fModel.CanDeleteValue(fScale),
    ItemToolDeleteValue, ItemPopDeleteValue);
  inc(fUpdateLevel);
  try
    ItemToolOrder.SelectedIndex := OrderIndexOf(fScale.Order);
    ItemToolType.SelectedIndex := TypeIndexOf(fScale.IsInterval);
  finally
    dec(fUpdateLevel);
  end;
end;

method FormScaleEditDiscrete.ViewValues_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  UpdateForm;
end;

method FormScaleEditDiscrete.ItemToolScaleDescr_Click(sender: System.Object; e: System.EventArgs);
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

method FormScaleEditDiscrete.ItemToolValueDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedValue = nil then
    exit;
  var lValueDescrForm := AppData.NameEditForm;
  lValueDescrForm.SetForm(DexiStrings.TitleValNameEdit, DexiStrings.LabelValNameEdit, DexiStrings.LabelValDescrEdit);
  lValueDescrForm.SetTexts(SelectedValue.Name, SelectedValue.Description);
  if lValueDescrForm.ShowDialog = DialogResult.OK then
    begin
      fScale.Names[SelectedIndex] := lValueDescrForm.NameText;
      fScale.Descriptions[SelectedIndex] := lValueDescrForm.DescriptionText;
      UpdateForm;
    end;
end;

method FormScaleEditDiscrete.ItemToolOrder_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fScale.Order := IndexToOrder;
  UpdateForm;
end;

method FormScaleEditDiscrete.ItemToolType_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fScale.IsInterval := IndexToType;
  UpdateForm;
end;

method FormScaleEditDiscrete.AddValue(aIdx: Integer);
begin
  fScale.InsertValue(aIdx, DexiString.SDexiNewScaleValue, '');
  fAttribute.InsertScaleValue(aIdx);
  if fFunct <> nil then
    fFunct.InsertFunctionValue(aIdx);
  if fParentFunct <> nil then
    fParentFunct.InsertArgValue(fAttribute.Parent.InpIndex(fAttribute), aIdx);
  ViewValues.SetObjects(Values);
  ViewValues.SelectObject(fScale.Values[aIdx]);
  UpdateForm;
end;

method FormScaleEditDiscrete.ItemToolAddValueDown_Click(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel > 0) or (SelectedValue = nil) or not fModel.CanAddValue(fAttribute, fScale, fParentFunct) then
    exit;
  AddValue(SelectedIndex + 1)
end;

method FormScaleEditDiscrete.ItemToolAddValueUp_Click(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel > 0) or (SelectedValue = nil) or not fModel.CanAddValue(fAttribute, fScale, fParentFunct) then
    exit;
  AddValue(SelectedIndex)
end;

method FormScaleEditDiscrete.DeleteValue(aIdx: Integer);
begin
  fScale.DeleteValue(aIdx);
  fAttribute.DeleteScaleValue(aIdx);
  if fFunct <> nil then
    fFunct.DeleteFunctionValue(aIdx);
  if fParentFunct <> nil then
    fParentFunct.DeleteArgValue(fAttribute.Parent.InpIndex(fAttribute), aIdx);
  ViewValues.SetObjects(Values);
  UpdateForm;
end;

method FormScaleEditDiscrete.ItemToolDeleteValue_Click(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel > 0) or (SelectedValue = nil) or not fModel.CanDeleteValue(fScale) then
    exit;
  DeleteValue(SelectedIndex)
end;

method FormScaleEditDiscrete.DuplicateValue;
begin
  var lIdx := SelectedIndex;
  if lIdx < 0 then
    exit;
  fScale.InsertValue(lIdx + 1, fScale.Names[lIdx], fScale.Descriptions[lIdx]);
  fAttribute.DuplicateScaleValue(lIdx);
  if fFunct <> nil then
    fFunct.DuplicateFunctionValue(lIdx);
  if fParentFunct <> nil then
    fParentFunct.DuplicateArgValue(fAttribute.Parent.InpIndex(fAttribute), lIdx);
  ViewValues.SetObjects(Values);
  ViewValues.SelectObject(fScale.Values[lIdx + 1]);
  UpdateForm;
end;

method FormScaleEditDiscrete.ItemToolDuplicateValue_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedValue = nil then
    exit;
  DuplicateValue;
end;

method FormScaleEditDiscrete.MoveValue(aTo: Integer);
begin
  var lSel := SelectedIndex;
  if (lSel < 0) or (aTo = lSel) or not (0 <= aTo < fScale.Count) then
    exit;
  fScale.ValueList.Move(lSel, aTo);
  fAttribute.MoveScaleValue(lSel, aTo);
  ViewValues.SetObjects(Values);
  ViewValues.SelectObject(fScale.Values[aTo]);
  UpdateForm;
end;

method FormScaleEditDiscrete.ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel > 0) or (SelectedValue = nil) then
    exit;
  MoveValue(SelectedIndex + 1);
end;

method FormScaleEditDiscrete.ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel > 0) or (SelectedValue = nil) then
    exit;
  MoveValue(SelectedIndex - 1);
end;

method FormScaleEditDiscrete.SetCategory(aCtg: Integer);
begin
  var lSel := SelectedIndex;
  if lSel < 0 then
    exit;
  fScale.SetCategory(lSel, aCtg);
  UpdateForm;
end;

method FormScaleEditDiscrete.EditCell;
begin
  if (SelectedValue = nil) or (fSelectedColumn = nil) then
    exit;
  ViewValues.StartCellEdit(ViewValues.ModelToItem(SelectedValue), fSelectedColumn.Index);
end;

method FormScaleEditDiscrete.ItemToolSetBad_Click(sender: System.Object; e: System.EventArgs);
begin
  SetCategory(DexiScale.BadCategory);
end;

method FormScaleEditDiscrete.ItemToolSetNeutral_Click(sender: System.Object; e: System.EventArgs);
begin
  SetCategory(DexiScale.NeutralCategory);
end;

method FormScaleEditDiscrete.ItemToolSetGood_Click(sender: System.Object; e: System.EventArgs);
begin
  SetCategory(DexiScale.GoodCategory);
end;

method FormScaleEditDiscrete.ViewValues_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
begin
  if e.Column = fSelectedColumn then
    begin
      if e.RowIndex = ViewValues.SelectedIndex then
        begin
          e.SubItem.BackColor := AppSettings.SelectedColor;
          var cbd := new CellBorderDecoration;
          cbd.BoundsPadding := new Size(0, -1);
          cbd.BorderPen := AppSettings.EditPen;
          cbd.FillBrush := nil;
          cbd.CornerRounding := 0;
          e.SubItem.Decoration := cbd;
        end;
    end;
end;

method FormScaleEditDiscrete.ViewValues_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  ViewValues.RefreshObject(fLastSelected);
  inc(fUpdateLevel);
  try
    var lSelectedValue := SelectedValue;
    if lSelectedValue = nil then
      if fLastSelected <> nil then
        ViewValues.SelectObject(fLastSelected)
      else if Values.Count > 0 then
        ViewValues.SelectObject(Values[0]);
    lSelectedValue := SelectedValue;
    if lSelectedValue <> nil then
      ViewValues.RefreshObject(lSelectedValue);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
  fLastSelected := SelectedValue;
end;

method FormScaleEditDiscrete.ViewValues_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if sender = ViewValues then
    begin
      var ht := ViewValues.OlvHitTest(e.Location.X, e.Location.Y);
      if ht:Column <> nil then
        begin
          fSelectedColumn := ht.Column;
          ViewValues.RefreshObject(fLastSelected);
          UpdateForm;
        end;
    end;
end;

method FormScaleEditDiscrete.ViewValues_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if SelectedValue = nil then
    exit;
  if e.KeyCode = Keys.F2 then
    begin
      EditCell;
      e.Handled := true;
    end
  else if e.KeyCode = Keys.Left then
    begin
      if fSelectedColumn = ColDescription then
        begin
          fSelectedColumn := ColValue;
          ViewValues.RefreshObject(fLastSelected);
          UpdateForm;
        end;
      e.Handled := true;
    end
  else if e.KeyCode = Keys.Right then
    begin
      if fSelectedColumn = ColValue then
        begin
          fSelectedColumn := ColDescription;
          ViewValues.RefreshObject(fLastSelected);
          UpdateForm;
        end;
      e.Handled := true;
    end;
end;

method FormScaleEditDiscrete.ViewValues_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  EditCell;
end;

end.