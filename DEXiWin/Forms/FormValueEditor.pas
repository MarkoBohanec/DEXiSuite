// FormValueEditor.pas is part of
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
// FormValueEditor.pas implements a form for editing a 'DexiValue'. There are four distinct
// types of DEXi values: undefined value, single value, value set, and value distribution.
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
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormWeights.
  /// </summary>
  FormValueEditor = partial public class(System.Windows.Forms.Form)
  private
    method ComboValueType_SelectionChangeCommitted(sender: System.Object; e: System.EventArgs);
    method ViewDistribution_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method ViewDistribution_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
    method BtnNullRange_Click(sender: System.Object; e: System.EventArgs);
    method BtnMax1_Click(sender: System.Object; e: System.EventArgs);
    method BtnSum1_Click(sender: System.Object; e: System.EventArgs);
    method BtnFullRange_Click(sender: System.Object; e: System.EventArgs);
    method ViewDistribution_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
    method ViewDistribution_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewDistribution_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewDistribution_CellEditValidating(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewDistribution_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ViewDistribution_DoubleClick(sender: System.Object; e: System.EventArgs);
    method BtnOK_Click(sender: System.Object; e: System.EventArgs);
    method FormValueEditor_Shown(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fAttribute: DexiAttribute;
    fScale: DexiDiscreteScale;
    fAltName: String;
    fValue: DexiValue;
    fCategories: List<CategoryObject>;
    fLastEditCategory: EditCategories;
    fLastChangedIndex: Integer;
    fSingleMode: Boolean;
    property SelectedCategory: EditCategories read EditCategories(ComboValueType.SelectedIndex);

  protected
    method Dispose(aDisposing: Boolean); override;
    method MakeCategories: List<CategoryObject>;
    method UpdateCategories(aValue: DexiValue);
    method SetValueType(aValue: DexiValue);
    method SingleIndex: Integer;
    method Singlify;
    method Multify;
    method Distrify;
    method SelectionChanged;
    method GetIntSet: IntSet;
    method GetMemberships: FltArray;
    method SetMemberships(aMem: FltArray);
    method NormalizeSum;
    method NormalizeMax;
    method MakeValue: DexiValue;
  public
    constructor;
    method SetForm(aAttribute: DexiAttribute; aAltName: String; aValue: DexiValue := nil);
    property Value: DexiValue read fValue;
  end;

type
  CategoryObject = public class
  private
    class const Rounding = 4;
  public
    property &Index: Integer;
    property Name: String;
    property Checked: Boolean;
    property Membership: Float;
    property MembString: String read Utils.FltToStr(Math.Round(Membership, Rounding), false);
  end;

type
  EditCategories = enum (Undef, Single, Multiple, Distrib) of Integer;

implementation

{$REGION Construction and Disposition}
constructor FormValueEditor;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
  ColMembership.CellEditUseWholeCell := true;
  ViewDistribution.FullRowSelect := true;
  ViewDistribution.SelectedBackColor := AppSettings.SelectedColor;
  ViewDistribution.SelectedForeColor := ViewDistribution.ForeColor;
end;

method FormValueEditor.Dispose(aDisposing: Boolean);
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

method FormValueEditor.UpdateCategories(aValue: DexiValue);
require
  fCategories <> nil;
  fCategories.Count = fScale.Count;
begin
  var lSet :=
    if DexiValue.ValueIsUndefined(aValue) then Values.EmptySet
    else aValue.AsIntSet;
  var lDistribution :=
    if DexiValue.ValueIsUndefined(aValue) then Values.EmptyDistr
    else aValue.AsDistribution;
  for lIdx := 0 to fCategories.Count - 1 do
    begin
      var lCategory := fCategories[lIdx];
      lCategory.Checked := Values.IntSetMember(lSet, lIdx);
      lCategory.Membership := Values.GetDistribution(lDistribution, lIdx);
    end;
end;

method FormValueEditor.MakeCategories: List<CategoryObject>;
begin
  result := new List<CategoryObject>;
  var lNameList := fScale.NameList;
  for lIdx := 0 to lNameList.Count - 1 do
    result.Add(new CategoryObject(&Index := lIdx, Name := lNameList[lIdx]));
end;

method FormValueEditor.SetValueType(aValue: DexiValue);
begin
  var lTypeIndex: Integer :=
    if not DexiValue.ValueIsDefined(aValue) then EditCategories.Undef
    else if aValue.IsSingle then EditCategories.Single
    else if aValue.IsSet then EditCategories.Multiple
    else EditCategories.Distrib;
  ComboValueType.SelectedIndex := lTypeIndex;
end;

method FormValueEditor.SingleIndex: Integer;
begin
  result := fLastChangedIndex;
  if (result < 0) or not fCategories[result].Checked then
    for lIdx := 0 to fCategories.Count - 1 do
      if fCategories[lIdx].Checked then
        begin
          result := lIdx;
          break;
        end;
  if result < 0 then
    result := 0;
end;

method FormValueEditor.Singlify;
begin
  var lSingle := SingleIndex;
  for lIdx := 0 to fCategories.Count - 1 do
    begin
      fCategories[lIdx].Checked := lIdx = lSingle;
      fCategories[lIdx].Membership := if fCategories[lIdx].Checked then 1.0 else 0.0;
    end;
end;

method FormValueEditor.Multify;
begin
  for lIdx := 0 to fCategories.Count - 1 do
    fCategories[lIdx].Checked := not Utils.FloatZero(fCategories[lIdx].Membership);
end;

method FormValueEditor.Distrify;
begin
  for lIdx := 0 to fCategories.Count - 1 do
    if fCategories[lIdx].Checked then
      begin
        if Utils.FloatZero(fCategories[lIdx].Membership) then
          fCategories[lIdx].Membership := 1.0;
      end
    else
      if not Utils.FloatZero(fCategories[lIdx].Membership) then
          fCategories[lIdx].Membership := 0.0;
end;

method FormValueEditor.SelectionChanged;
begin
  fSingleMode := SelectedCategory = EditCategories.Single;
  AppUtils.Show(SelectedCategory <> EditCategories.Undef, PanelMain);
  AppUtils.Show((SelectedCategory = EditCategories.Multiple) or (SelectedCategory = EditCategories.Distrib), BtnFullRange, BtnNullRange);
  ViewDistribution.CheckBoxes := (SelectedCategory = EditCategories.Single) or (SelectedCategory = EditCategories.Multiple);
  GrpNormalize.Visible := SelectedCategory = EditCategories.Distrib;
  case SelectedCategory of
    EditCategories.Undef: {nothing};
    EditCategories.Single:
      begin
        if fLastEditCategory = EditCategories.Distrib then
          Multify;
        Singlify;
      end;
    EditCategories.Multiple:
      Multify;
    EditCategories.Distrib:
      Distrify;
  end;
  if SelectedCategory <> EditCategories.Undef then
    fLastEditCategory := SelectedCategory;
  var lMemVisible := SelectedCategory = EditCategories.Distrib;
  if lMemVisible <> ColMembership.IsVisible then
    begin
      ColMembership.IsVisible := lMemVisible;
      ViewDistribution.RebuildColumns;
    end;
  ViewDistribution.RefreshObjects(fCategories);
end;

method FormValueEditor.GetIntSet: IntSet;
begin
  result := Values.EmptySet;
  for lIdx := 0 to fCategories.Count - 1 do
    if fCategories[lIdx].Checked then
      Values.IntSetInclude(var result, lIdx);
end;

method FormValueEditor.GetMemberships: FltArray;
begin
  result := new Float[fCategories.Count];
  for lIdx := 0 to fCategories.Count - 1 do
    result[lIdx] := fCategories[lIdx].Membership;
end;

method FormValueEditor.SetMemberships(aMem: FltArray);
require
  length(aMem) = fCategories.Count;
begin
  for lIdx := 0 to fCategories.Count - 1 do
    fCategories[lIdx].Membership := aMem[lIdx];
end;

method FormValueEditor.NormalizeSum;
begin
  var lMem := GetMemberships;
  Values.NormSum(var lMem, 1.0);
  SetMemberships(lMem);
end;

method FormValueEditor.NormalizeMax;
begin
  var lMem := GetMemberships;
  Values.NormMax(var lMem, 1.0);
  SetMemberships(lMem);
end;

method FormValueEditor.MakeValue: DexiValue;
begin
  result :=
    case SelectedCategory of
      EditCategories.Undef: new DexiUndefinedValue;
      EditCategories.Single: new DexiIntSingle(SingleIndex);
      EditCategories.Multiple: new DexiIntSet(GetIntSet);
      EditCategories.Distrib: new DexiDistribution(0, GetMemberships);
    end;
end;

method FormValueEditor.SetForm(aAttribute: DexiAttribute; aAltName: String; aValue: DexiValue := nil);
require
  DexiValue.ValueIsUndefined(aValue) or DexiValue.ValueIsInteger(aValue);
begin
  fAttribute := aAttribute;
  fScale := DexiDiscreteScale(fAttribute:Scale);
  fAltName := aAltName;
  fValue := aValue;
  if fValue = nil then
    fValue := new DexiUndefinedValue;
  Text := String.Format(fFormText, fAttribute:Name, fAltName);
  fCategories := MakeCategories;
  UpdateCategories(fValue);
  fLastChangedIndex := -1;
  ViewDistribution.SetObjects(fCategories);
  SetValueType(fValue);
  fLastEditCategory := SelectedCategory;
  SelectionChanged;
end;

method FormValueEditor.FormValueEditor_Shown(sender: System.Object; e: System.EventArgs);
begin
  ViewDistribution.Focus;
end;

method FormValueEditor.BtnOK_Click(sender: System.Object; e: System.EventArgs);
begin
  fValue := MakeValue;
end;

method FormValueEditor.ViewDistribution_DoubleClick(sender: System.Object; e: System.EventArgs);
begin
  if ViewDistribution.SelectedObject = nil then
    exit;
  ViewDistribution.StartCellEdit(ViewDistribution.ModelToItem(ViewDistribution.SelectedObject), ColMembership.Index);
end;

method FormValueEditor.ViewDistribution_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if ViewDistribution.SelectedObject = nil then
    exit;
  if e.KeyCode = Keys.F2 then
    ViewDistribution.StartCellEdit(ViewDistribution.ModelToItem(ViewDistribution.SelectedObject), ColMembership.Index);
end;

method FormValueEditor.ViewDistribution_CellEditValidating(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  var lText := TextBox(e.Control).Text;
  var lValue := AppUtils.EditedFloatNumber(lText);
  if not assigned(lValue) or Consts.IsInfinity(lValue) or Consts.IsNaN(lValue) then
    e.Cancel := true;
end;

method FormValueEditor.ViewDistribution_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if e.Cancel or (e.RowObject = nil) or (e.Column <> ColMembership) then
    exit;
  ViewDistribution.RefreshObject(e.RowObject);
end;

method FormValueEditor.ViewDistribution_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if e.Cancel or (e.RowObject = nil) or (e.Column <> ColMembership) then
    exit;
  var lCategory := CategoryObject(e.RowObject);
  var lValue := Float(AppUtils.EditedFloatNumber(TextBox(e.Control).Text));
  lCategory.Membership := lValue;
  if lValue <> 0.0 then
    fLastChangedIndex := lCategory.Index;
end;

method FormValueEditor.ViewDistribution_ItemChecked(sender: System.Object; e: System.Windows.Forms.ItemCheckedEventArgs);
begin
  var lIdx := e.Item.Index;
  fLastChangedIndex := lIdx;
  if fSingleMode then
    begin
      Singlify;
      ViewDistribution.RefreshObjects(fCategories);
    end;
end;

method FormValueEditor.BtnFullRange_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lCategory in fCategories do
    begin
      lCategory.Checked := true;
      lCategory.Membership := 1.0;
    end;
  ViewDistribution.RefreshObjects(fCategories);
end;

method FormValueEditor.BtnNullRange_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lCategory in fCategories do
    begin
      lCategory.Checked := false;
      lCategory.Membership := 0.0;
    end;
  ViewDistribution.RefreshObjects(fCategories);
end;

method FormValueEditor.BtnSum1_Click(sender: System.Object; e: System.EventArgs);
begin
  NormalizeSum;
  ViewDistribution.RefreshObjects(fCategories);
end;

method FormValueEditor.BtnMax1_Click(sender: System.Object; e: System.EventArgs);
begin
  NormalizeMax;
  ViewDistribution.RefreshObjects(fCategories);
end;

method FormValueEditor.ViewDistribution_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
begin
  if (e.RowIndex = ViewDistribution.SelectedIndex) and (e.Column = ColMembership) then
    begin
      var cbd := new CellBorderDecoration;
      cbd.BoundsPadding := new Size(0, -1);
      cbd.BorderPen := AppSettings.EditPen;
      cbd.FillBrush := nil;
      cbd.CornerRounding := 0;
      e.SubItem.Decoration := cbd;
    end;
end;

method FormValueEditor.ViewDistribution_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  ViewDistribution.RefreshObjects(fCategories);
end;

method FormValueEditor.ComboValueType_SelectionChangeCommitted(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

end.