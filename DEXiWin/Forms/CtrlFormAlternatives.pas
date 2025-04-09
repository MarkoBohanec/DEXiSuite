// CtrlFormAlternatives.pas is part of
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
// CtrlFormAlternatives.pas implements a 'CtrlForm' aimed at editing alternatives and their input data.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows,
  System.Windows.Forms,
  System.ComponentModel,
  BrightIdeasSoftware,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for CtrlFormAlternatives.
  /// </summary>
  CtrlFormAlternatives = public partial class(CtrlForm)
  private
    method ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuResetVertical_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuResizeColumns_Click(sender: System.Object; e: System.EventArgs);
    method ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method CtrlFormAlternatives_VisibleChanged(sender: System.Object; e: System.EventArgs);
    method AlternativesMenu_Opening(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    method ItemMenuModelDescr_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewAlt_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewDescription_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewScale_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopFullRange_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddAlternativeLeft_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddAlternativeRight_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAltDescr_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPaste_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDeleteAlternative_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDuplicateAlternative_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolEditValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveLeft_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveRight_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolValueEditor_Click(sender: System.Object; e: System.EventArgs);
    method ItemViewAltHideAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemViewAltShowAll_Click(sender: System.Object; e: System.EventArgs);
    method ViewAlternatives_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
    method ViewAlternatives_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewAlternatives_CellEditValidating(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewAlternatives_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewAlternatives_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewAlternatives_Click(sender: System.Object; e: System.EventArgs);
    method ViewAlternatives_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
    method ViewAlternatives_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ViewAlternatives_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method ViewAlternatives_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewAlternatives_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewAlternatives_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewAlternatives_ColumnClick(sender: System.Object; e: System.Windows.Forms.ColumnClickEventArgs);
    method ViewAlternatives_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method EditCell_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method EditCell_PreviewKeyDown(sender: System.Object; e: System.Windows.Forms.PreviewKeyDownEventArgs);
   private
    fModel: DexiModel;
    fInputAttributes: DexiAttributeList;
    fSelectedNode: DexiAttribute;
    fLastSelectedNode: DexiAttribute;
    fSelectedAlternative: Integer;
    fEditingParameters: ValueEditingParameters;
    fStartEditString: String;
    fUpdateLevel := 0;
    fEditKeyPressed := false;
    fMouseHitOut := false;
    class const NonAltColumns = 3;
  protected
    method Dispose(disposing: Boolean); override;
    method ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method SetModel(aModel: DexiModel);
    method GetAltColumn(aAlt: Integer): OLVColumn;
    method GetAltColCount: Integer;
    method AltColumnIndex(aCol: OLVColumn): Integer;
    method SelectNode(aNode: Object);
    method SelectAlternative(aNext: Boolean);
    method SelectAlternative(aIdx: Integer; aNext: Boolean := true);
    method UpdateColumnHeaders;
    method UpdateColumnVisibility;
    method MakeAltColumns;
    method MakeAltViewMenu;
    method MakeContextMenu;
    method OrderColumns;
    method CanMoveLeft: Boolean;
    method CanMoveRight: Boolean;
    method CanMoveUp: Boolean;
    method CanMoveDown: Boolean;
    method CanEditName: Boolean;
    method CanAddLeft: Boolean;
    method CanAddRight: Boolean;
    method CanDelete: Boolean;
    method CanDuplicate: Boolean;
    method CanEditValue: Boolean;
    method CanOpenValueEditor: Boolean;
    method UpdateForm;
    method SelectionChanged;
    method VisibilityChanged;
    method EditAlternativeValue(aAtt: DexiAttribute; aAlt: Integer);
    method AlternativeValueChanged(aAlt: Integer);
    method OpenValueEditor;
    method CancelEditMode;
    property SelectedNode: DexiAttribute read fSelectedNode;
    property AltVisibility: AlternativesVisibility read AppUtils.ModelForm(self).AltVisibility;
    property AltColumn[aAlt: Integer]: OLVColumn read GetAltColumn;
    property AltColCount: Integer read GetAltColCount;
  public
    constructor;
    method Init;
    method DoEnter;
    method DoKeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method SaveState;
    method DataChanged;
    method ResizeColumns;
    property Model: DexiModel read fModel write SetModel;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormAlternatives;
begin
  //
  // Required for Windows Control Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //

  CtrlMenu := FormMenu;
  CtrlTool := FormTool;
  ViewAlternatives.SelectedForeColor := ViewAlternatives.ForeColor;
  ViewAlternatives.SelectedBackColor := AppSettings.SelectedColor;
  ViewAlternatives.SmallImageList := AppData:ModelImages;

  ColName.ImageGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then 'ImgAtt' + DexiAttribute(x).NodeStatus.ToString
        else nil;
    end;

end;

method CtrlFormAlternatives.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    ViewAlternatives.SmallImageList := nil;
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlFormAlternatives.SetModel(aModel: DexiModel);
begin
  fModel := aModel;
  ColScale.Renderer := new CompositeModelScaleRenderer(Settings := fModel:Settings);
end;

method CtrlFormAlternatives.GetAltColumn(aAlt: Integer): OLVColumn;
begin
  result :=
    if 0 <= aAlt < AltColCount then ViewAlternatives.AllColumns[aAlt + NonAltColumns]
    else nil;
end;

method CtrlFormAlternatives.GetAltColCount: Integer;
begin
  result := ViewAlternatives.AllColumns.Count - NonAltColumns;
end;

method CtrlFormAlternatives.AltColumnIndex(aCol: OLVColumn): Integer;
begin
  var lIdx := ViewAlternatives.AllColumns.IndexOf(aCol);
  result :=
    if lIdx >= NonAltColumns then lIdx - NonAltColumns
    else -1;
end;

method CtrlFormAlternatives.SelectNode(aNode: Object);
begin
  if fLastSelectedNode <> nil then
    ViewAlternatives.RefreshObject(fLastSelectedNode);
  ViewAlternatives.SelectObject(aNode, true);
  ViewAlternatives.RefreshObject(aNode);
  SelectionChanged;
end;

method CtrlFormAlternatives.SelectAlternative(aNext: Boolean);

  method SelectionOK(aAlt: Integer): Boolean;
  begin
    var lAltColumn := AltColumn[aAlt];
    result := (aAlt >= 0) and (lAltColumn <> nil) and lAltColumn.IsVisible;
  end;

  method SearchBackward(aFrom: Integer): Integer;
  begin
    result := -1;
    for lIdx := aFrom downto 0 do
      if SelectionOK(lIdx) then
        exit lIdx;
  end;

  method SearchForward(aFrom: Integer): Integer;
  begin
    result := -1;
    for lIdx := aFrom to AltColCount - 1 do
      if SelectionOK(lIdx) then
        exit lIdx;
  end;

  method Search(aFrom: Integer; aNext: Boolean): Integer;
  begin
    result :=
      if aNext then SearchForward(aFrom + 1)
      else SearchBackward(aFrom - 1);
  end;

begin
  if SelectionOK(fSelectedAlternative) then
    exit;
  var lFound := Search(fSelectedAlternative, aNext);
  if lFound >= 0 then
    begin
      fSelectedAlternative := lFound;
      exit;
    end;
  lFound := Search(fSelectedAlternative, not aNext);
  if lFound >= 0 then
    begin
      fSelectedAlternative := lFound;
      exit;
    end;
  fSelectedAlternative := -1;
end;

method CtrlFormAlternatives.SelectAlternative(aIdx: Integer; aNext: Boolean := true);
begin
  fSelectedAlternative := aIdx;
  SelectAlternative(aNext);
end;

method CtrlFormAlternatives.UpdateColumnHeaders;
begin
  for lIdx := 0 to AltColCount - 1 do
    begin
      var lCol := AltColumn[lIdx];
      lCol.Text := fModel.AltNames[lIdx].Name;
      lCol.ToolTipText := fModel.AltNames[lIdx].Description;
      lCol.Tag := lIdx;
    end;
end;

method CtrlFormAlternatives.UpdateColumnVisibility;
begin
  var lChanged := false;
  var lVisibility := AltVisibility.AlternativeVisibility;
  for lIdx := 0 to AltColCount - 1 do
    begin
      var lCol := AltColumn[lIdx];
      if lCol.IsVisible <> lVisibility.Contains(lIdx) then
        begin
          lCol.IsVisible := lVisibility.Contains(lIdx);
          lChanged := true;
        end;
    end;
  if lChanged then
    begin
      ViewAlternatives.RebuildColumns;
      OrderColumns;
    end;
end;

method CtrlFormAlternatives.MakeAltColumns;
begin
  if fModel.AltCount <> AltColCount then
    begin
      if AltColCount < fModel.AltCount then
        for i := AltColCount to fModel.AltCount - 1 do
          begin
            var lAltCol := new OLVColumn('', 'Alt', Tag := i, DisplayIndex := NonAltColumns + i + 1,
              IsEditable := false, Groupable := false, Hideable := true, MinimumWidth := 65, Searchable := false, Sortable := false, UseFiltering := false,
              Width := 65);
            lAltCol.Renderer := new CompositeAlternativeValueRenderer(i, Settings := fModel:Settings);
            ViewAlternatives.AllColumns.Add(lAltCol);
          end
      else if AltColCount > fModel.AltCount then
        begin
          var lDiff := AltColCount - fModel.AltCount;
          var lIdx := ViewAlternatives.AllColumns.Count;
          for i := 1 to lDiff do
            begin
              dec(lIdx);
              ViewAlternatives.AllColumns[lIdx].Renderer := nil;
              ViewAlternatives.AllColumns.RemoveAt(lIdx);
            end;
        end;
      ViewAlternatives.RebuildColumns;
    end;
  assert(fModel.AltCount = AltColCount);
  UpdateColumnVisibility;
  UpdateColumnHeaders;
end;

method CtrlFormAlternatives.MakeAltViewMenu;
const NonViewItems = 3;
begin
  if fUpdateLevel > 0 then
    exit;
  inc(fUpdateLevel);
  try
    var lMenuItems := ItemMenuViewAlternatives.DropDownItems;
    var lNeededItems := AltColCount + NonViewItems;
    while lMenuItems.Count < lNeededItems do
      begin
        var lItem := new ToolStripMenuItem;
        lItem.Click += ItemMenuViewAlt_Click;
        lMenuItems.Add(lItem);
      end;
    while lMenuItems.Count > lNeededItems do
      begin
        lMenuItems.Item[lMenuItems.Count - 1].Click -= ItemMenuViewAlt_Click;
        lMenuItems.RemoveAt(lMenuItems.Count - 1);
      end;
    assert(lMenuItems.Count - NonViewItems = AltColCount);
    for i := 0 to AltColCount - 1 do
      begin
        var lMenuItem := ToolStripMenuItem(lMenuItems[i + NonViewItems]);
        lMenuItem.Text := AltColumn[i].Text;
        lMenuItem.Tag := i;
        lMenuItem.Checked := AltColumn[i].IsVisible;
      end;
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlFormAlternatives.MakeContextMenu;
begin
  AlternativesMenu.SuspendLayout;
  try
    // Clean previous items
    var lPos := -1;
    for i := 0 to AlternativesMenu.Items.Count - 1 do
      if AlternativesMenu.Items[i] is ToolStripSeparator then
        begin
          lPos := i;
          break;
        end;
    for i := lPos - 1 downto 0 do
      begin
        AlternativesMenu.Items[i].Click -= ItemPopDefinedValue_Click;
        AlternativesMenu.Items.RemoveAt(i);
      end;

    // Handle editing items
    var lCanEdit := CanOpenValueEditor and not fMouseHitOut;
    AppUtils.Show(lCanEdit, ItemPopFullRange, ItemPopUndefinedValue, ItemPopEditSeparator1, ItemPopEditSeparator2);
    if lCanEdit then
      begin
        // Add directly selectable values
        var lScale := DexiDiscreteScale(SelectedNode.Scale);
        var lScaleNames := lScale.NameList;
        for i := lScaleNames.Count - 1 downto 0 do
          begin
            var lItem := new ToolStripMenuItem;
            var lCode := AppUtils.IntToExtVal(i);
            var lActCode :=
              if String.IsNullOrEmpty(lCode) then ''
              else lCode + ' ';
            lItem.Tag := i;
            lItem.Text := lActCode + lScaleNames[i];
            lItem.Click += ItemPopDefinedValue_Click;
            AlternativesMenu.Items.Insert(0, lItem);
          end;
      end;
  finally
    AlternativesMenu.ResumeLayout;
    fMouseHitOut := false;
  end;
end;

method CtrlFormAlternatives.OrderColumns;
begin
  for i := ViewAlternatives.AllColumns.Count - 1 downto 0 do
    ViewAlternatives.AllColumns[i].DisplayIndex := 0;
end;

method CtrlFormAlternatives.Init;
begin
  MakeAltColumns;
  if ViewAlternatives.SelectedObject = nil then
  fLastSelectedNode := SelectedNode;
  fSelectedAlternative := 0;
  SelectNode(fLastSelectedNode);
  UpdateForm;
end;

method CtrlFormAlternatives.DoEnter;
begin
  CancelEditMode;
  MakeAltColumns;
  fInputAttributes := Model.OrderedInputAttributes;
  ViewAlternatives.SetObjects(fInputAttributes);
  MakeAltViewMenu;
  ViewAlternatives.Focus;
  fLastSelectedNode := SelectedNode;
  if (SelectedNode = nil) or not fInputAttributes.Contains(SelectedNode) then
    if (fInputAttributes <> nil) and (fInputAttributes.Count > 0) then
      ViewAlternatives.SelectObject(fInputAttributes[0]);
  SelectAlternative(false);
  SelectNode(fLastSelectedNode);
  UpdateForm;
end;

method CtrlFormAlternatives.DoKeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  ViewAlternatives_KeyDown(sender, e);
end;

method CtrlFormAlternatives.SaveState;
begin
  AppUtils.ModelForm(self).SaveState;
end;

method CtrlFormAlternatives.DataChanged;
begin
  DoEnter;
end;

method CtrlFormAlternatives.ResizeColumns;
begin
  var lAtts := fInputAttributes;
  if ColName.IsVisible then
    begin
      var lWidth := TextRenderer.MeasureText(ColScale.Text, ViewAlternatives.Font).Width + 10;
      for each lAtt in lAtts do
        begin
          var lStr := lAtt.Name;
          lWidth := Math.Max(lWidth, TextRenderer.MeasureText(lStr, ViewAlternatives.Font).Width + 20);
        end;
      ColName.Width := lWidth;
    end;
  if ColDescription.IsVisible then
    ColDescription.AutoResize(ColumnHeaderAutoResizeStyle.ColumnContent);
  if ColScale.IsVisible then
    begin
      var lWidth := TextRenderer.MeasureText(ColScale.Text, ViewAlternatives.Font).Width;
      lWidth := Math.Max(lWidth, TextRenderer.MeasureText('Undefined', ViewAlternatives.Font).Width);
      for each lAtt in lAtts do
        if lAtt.Scale <> nil then
          begin
            var lStr := lAtt.Scale.ScaleText;
            lWidth := Math.Max(lWidth, Integer(1.06 * TextRenderer.MeasureText(lStr, ViewAlternatives.Font).Width));
          end;
      ColScale.Width := lWidth;
    end;
  for each lColumn in ViewAlternatives.Columns do
    with lCol :=  OLVColumn(lColumn) do
      if lCol.IsVisible and (lCol.AspectName = 'Alt') and (Integer(lCol.Tag) >= 0) then
        begin
          var lWidth := TextRenderer.MeasureText(lCol.Text, ViewAlternatives.Font).Width + 10;
          var lAlt := Integer(lCol.Tag);
          var lScaleStrings := CompositeAlternativeValueRenderer(lCol.Renderer).ScaleStrings;
          for each lAtt in lAtts do
            begin
              var lValue := fModel.AltValue[lAlt, lAtt];
              var lText := lScaleStrings.ValueOnScaleString(lValue, lAtt.Scale);
              lWidth := Math.Max(lWidth, Integer(1.06 * TextRenderer.MeasureText(lText, ViewAlternatives.Font).Width));
            end;
          lCol.Width := Math.Max(lWidth, lCol.MinimumWidth);
        end;
end;

method CtrlFormAlternatives.CanMoveLeft: Boolean;
begin
  result := (0 < fSelectedAlternative < Model.AltCount) and (Model.AltCount > 1);
end;

method CtrlFormAlternatives.CanMoveRight: Boolean;
begin
  result := (0 <= fSelectedAlternative < Model.AltCount - 1) and (Model.AltCount > 1);
end;

method CtrlFormAlternatives.CanMoveUp: Boolean;
begin
  result := (fSelectedNode <> nil) and (fInputAttributes.IndexOf(fSelectedNode) > 0);
end;

method CtrlFormAlternatives.CanMoveDown: Boolean;
begin
  result := (fSelectedNode <> nil) and (fInputAttributes.IndexOf(fSelectedNode) < (fInputAttributes.Count - 1));
end;

method CtrlFormAlternatives.CanEditName: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormAlternatives.CanAddLeft: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormAlternatives.CanAddRight: Boolean;
begin
  result := -1 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormAlternatives.CanDelete: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormAlternatives.CanDuplicate: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormAlternatives.CanEditValue: Boolean;
begin
  result := (0 <= fSelectedAlternative < Model.AltCount) and DexiAttribute.AttributeIsBasic(SelectedNode) and (SelectedNode.Scale <> nil);
end;

method CtrlFormAlternatives.CanOpenValueEditor: Boolean;
begin
  result := CanEditValue and SelectedNode.Scale.IsDiscrete;
end;

method CtrlFormAlternatives.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  for each lAtt in fInputAttributes do
    ViewAlternatives.RefreshObject(lAtt);
  inc(fUpdateLevel);
  try
    ItemMenuViewDescription.Checked := ColDescription.IsVisible;
    ItemMenuViewScale.Checked := ColScale.IsVisible;
  finally
    dec(fUpdateLevel);
  end;
  AppUtils.Enable(CanMoveLeft, ItemToolMoveLeft, ItemMenuMoveLeft, ItemPopMoveLeft);
  AppUtils.Enable(CanMoveRight, ItemToolMoveRight, ItemMenuMoveRight, ItemPopMoveRight);
  AppUtils.Enable(CanMoveUp, ItemToolMoveUp, ItemMenuMoveUp, ItemPopMoveUp);
  AppUtils.Enable(CanMoveDown, ItemToolMoveDown, ItemMenuMoveDown, ItemPopMoveDown);
  AppUtils.Enable(CanEditName, ItemToolAltDescr, ItemMenuAltDescr, ItemPopAltDescr);
  AppUtils.Enable(CanAddLeft, ItemToolAddAlternativeLeft, ItemMenuAddAlternativeLeft, ItemPopAddAlternativeLeft);
  AppUtils.Enable(CanAddRight, ItemToolAddAlternativeRight, ItemMenuAddAlternativeRight, ItemPopAddAlternativeRight);
  AppUtils.Enable(CanDelete, ItemToolDeleteAlternative, ItemMenuDeleteAlternative, ItemPopDeleteAlternative);
  AppUtils.Enable(CanDuplicate, ItemToolDuplicateAlternative, ItemMenuDuplicateAlternative, ItemPopDuplicateAlternative);
  AppUtils.Enable(CanEditValue, ItemToolEditValue, ItemMenuEditValue, ItemPopEditValue);
  AppUtils.Enable(CanOpenValueEditor, ItemToolValueEditor, ItemMenuValueEditor, ItemPopValueEditor);
  ViewAlternatives.Dock := DockStyle.Fill;
  AppUtils.UpdateModelForm(self);
  AppData.AppForm.UpdateForm;
end;

method CtrlFormAlternatives.SelectionChanged;
begin
  fSelectedNode := DexiAttribute(ViewAlternatives.SelectedObject);
  UpdateForm;
  fLastSelectedNode := SelectedNode;
end;

method CtrlFormAlternatives.VisibilityChanged;
begin
  ViewAlternatives.RebuildColumns;
  OrderColumns;
  UpdateColumnHeaders;
  UpdateColumnVisibility;
  SelectAlternative(false);
  MakeAltViewMenu;
  UpdateForm;
end;

method CtrlFormAlternatives.EditAlternativeValue(aAtt: DexiAttribute; aAlt: Integer);
begin
  ViewAlternatives.StartCellEdit(ViewAlternatives.ModelToItem(aAtt), AltColumn[aAlt].Index);
end;

method CtrlFormAlternatives.AlternativeValueChanged(aAlt: Integer);
begin
  Model.Modify;
  SaveState;
  UpdateForm;
end;

method CtrlFormAlternatives.OpenValueEditor;
begin
  if not (Visible and CanOpenValueEditor) then
    exit;
  using lForm := new FormValueEditor do
    begin
      lForm.SetForm(SelectedNode, Model.AltNames[fSelectedAlternative].Name, SelectedNode.AltValue[fSelectedAlternative]);
      if lForm.ShowDialog = DialogResult.OK then
        begin
          SelectedNode.AltValue[fSelectedAlternative] := lForm.Value;
          AlternativeValueChanged(fSelectedAlternative);
        end;
     end;
  UpdateForm;
end;

method CtrlFormAlternatives.CancelEditMode;
begin
  if ViewAlternatives.IsCellEditing then
    ViewAlternatives.FinishCellEdit;
end;

method CtrlFormAlternatives.ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not CanEditValue then
    exit;
  if sender is ToolStripMenuItem then
    begin
      SelectedNode.AltValue[fSelectedAlternative] := new DexiIntSingle(Integer(ToolStripMenuItem(sender).Tag));
      AlternativeValueChanged(fSelectedAlternative);
    end;
end;

method CtrlFormAlternatives.ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fEditKeyPressed then
    fEditKeyPressed := false
  else
    ViewAlternatives.FinishCellEdit;
end;

method CtrlFormAlternatives.CtrlFormAlternatives_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  DoEnter;
end;

method CtrlFormAlternatives.AlternativesMenu_Opening(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  MakeContextMenu;
end;

method CtrlFormAlternatives.ItemMenuModelDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  var lModelDescrForm := AppData.NameEditForm;
  lModelDescrForm.SetForm(DexiStrings.TitleModelNameEdit, DexiStrings.LabelModelNameEdit, DexiStrings.LabelModelDescrEdit);
  lModelDescrForm.SetTexts(Model.Name, Model.Description);
  if lModelDescrForm.ShowDialog = DialogResult.OK then
    begin
      Model.Name := lModelDescrForm.NameText;
      Model.Description := lModelDescrForm.DescriptionText;
      Model.Modify;
      SaveState;
      UpdateForm;
    end;
end;

method CtrlFormAlternatives.ItemMenuViewAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  if sender is not ToolStripMenuItem then
    exit;
  CancelEditMode;
  var lItem := ToolStripMenuItem(sender);
  var lColIndex := Integer(lItem.Tag);
  var lVisibility := AltVisibility.AlternativeVisibility;
  if lVisibility.Contains(lColIndex) then
    lVisibility.Exclude(lColIndex)
  else
    lVisibility.Include(lColIndex);
  SaveState;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemMenuViewDescription_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  ColDescription.IsVisible := not ColDescription.IsVisible;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemMenuViewScale_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  ColScale.IsVisible := not ColScale.IsVisible;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemPopFullRange_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not CanEditValue then
    exit;
  SelectedNode.AltValue[fSelectedAlternative] := DexiDiscreteScale(SelectedNode.Scale).FullValue;
  AlternativeValueChanged(fSelectedAlternative);
end;

method CtrlFormAlternatives.ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not CanEditValue then
    exit;
  SelectedNode.AltValue[fSelectedAlternative] := new DexiUndefinedValue;
  AlternativeValueChanged(fSelectedAlternative);
end;

method CtrlFormAlternatives.ItemToolAddAlternativeLeft_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanAddLeft) then
    exit;
  var lAlt := Model.InsertAlternative(fSelectedAlternative, DexiString.SDexiNewAlternative);
  Model.Modify;
  AltVisibility.AddAlternative(lAlt);
  SaveState;
  MakeAltColumns;
  VisibilityChanged;
  ItemToolAltDescr_Click(sender, e);
end;

method CtrlFormAlternatives.ItemToolAddAlternativeRight_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanAddRight) then
    exit;
  var lAlt := Model.InsertAlternative(fSelectedAlternative + 1, DexiString.SDexiNewAlternative);
  fSelectedAlternative := fSelectedAlternative + 1;
  Model.Modify;
  AltVisibility.AddAlternative(lAlt);
  SaveState;
  MakeAltColumns;
  VisibilityChanged;
  ItemToolAltDescr_Click(sender, e);
end;

method CtrlFormAlternatives.ItemToolAltDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if fSelectedAlternative < 0 then
    exit;
  var lAltName := fModel.AltNames[fSelectedAlternative];
  var lAttDescrForm := AppData.NameEditForm;
  lAttDescrForm.SetForm(DexiStrings.TitleAltNameEdit, DexiStrings.LabelAltNameEdit, DexiStrings.LabelAltDescrEdit);
  lAttDescrForm.SetTexts(lAltName.Name, lAltName.Description);
  if lAttDescrForm.ShowDialog = DialogResult.OK then
    begin
      lAltName.Name := lAttDescrForm.NameText;
      lAltName.Description := lAttDescrForm.DescriptionText;
      Model.Modify;
      SaveState;
      UpdateColumnHeaders;
      UpdateForm;
    end;
end;

method CtrlFormAlternatives.ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not Visible then
    exit;
  var lTable := new DexiAlternativesTable(Model);
  lTable.LoadFromModel(Model);
  var lList := lTable.SaveToStringList;
  Clipboard.SetText(String.Join(Environment.LineBreak, lList));
end;

method CtrlFormAlternatives.ItemToolPaste_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not Visible then
    exit;
  var lText := Clipboard.GetText;
  var lList := Utils.BreakToLines(lText);
  var lTable := new DexiAlternativesTable(Model);
  lTable.LoadFromStringList(lList, Model);
  lTable.SaveToModel(false);
  var lUnmatched := lTable.UnmatchedAttributes;
  if not String.IsNullOrEmpty(lUnmatched) then
    MessageBox.Show(String.Format(DexiStrings.MsgUnmatchedAttributes, lUnmatched),
      'Warning', MessageBoxButtons.OK, MessageBoxIcon.Warning);
  AltVisibility.AddAlternatives(lTable.AddedAlternatives);
  var lModelForm := AppUtils.ModelForm(Model);
  if lModelForm = nil then
    DataChanged
  else
    lModelForm.SignalDataChanged;
  UpdateForm;
end;

method CtrlFormAlternatives.ItemToolDeleteAlternative_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanDelete) then
    exit;
  Model.DeleteAlternative(fSelectedAlternative);
  AltVisibility.DeleteAlternative(fSelectedAlternative);
  Model.Modify;
  SaveState;
  fSelectedAlternative := fSelectedAlternative - 1;
  MakeAltColumns;
  SelectAlternative(false);
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemToolDuplicateAlternative_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanDuplicate) then
    exit;
  Model.DuplicateAlternative(fSelectedAlternative);
  fSelectedAlternative := fSelectedAlternative + 1;
  Model.AltNames[fSelectedAlternative].Name := Model.AltNames[fSelectedAlternative - 1].Name + "*";
  Model.Modify;
  AltVisibility.AddAlternative(fSelectedAlternative);
  SaveState;
  MakeAltColumns;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemToolEditValue_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanEditValue) then
    exit;
  fStartEditString := nil;
  EditAlternativeValue(SelectedNode, fSelectedAlternative);
end;

method CtrlFormAlternatives.ItemToolMoveLeft_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanMoveLeft) then
    exit;
  Model.MoveAlternativePrev(fSelectedAlternative);
  AltVisibility.MoveAlternativePrev(fSelectedAlternative);
  SaveState;
  fSelectedAlternative := fSelectedAlternative - 1;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemToolMoveRight_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanMoveRight) then
    exit;
  Model.MoveAlternativeNext(fSelectedAlternative);
  AltVisibility.MoveAlternativeNext(fSelectedAlternative);
  SaveState;
  fSelectedAlternative := fSelectedAlternative + 1;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemToolValueEditor_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  OpenValueEditor;
end;

method CtrlFormAlternatives.ItemViewAltHideAll_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  AltVisibility.AlternativeVisibility.Clear;
  SaveState;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ItemViewAltShowAll_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  AltVisibility.AlternativeVisibility.All(0, AltColCount - 1);
  SaveState;
  VisibilityChanged;
end;

method CtrlFormAlternatives.ViewAlternatives_CellToolTipShowing(sender: System.Object; e: BrightIdeasSoftware.ToolTipShowingEventArgs);
begin
  if e.ColumnIndex = 0 then
    if e.Model is DexiAttribute then
      e.Text := DexiAttribute(e.Model).ParentPath;
end;

method CtrlFormAlternatives.ViewAlternatives_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if (e.RowObject = nil) or (AltColumnIndex(e.Column) < 0) then
    exit;
  var lAttribute := DexiAttribute(e.RowObject);
  var lAlternative := Integer(e.Column.Tag);
  var lValue := Model.Alternative[lAlternative].Value[lAttribute];
  if lValue = nil then
    lValue := new DexiUndefinedValue;
  fEditingParameters := new ValueEditingParameters(lAttribute, lAlternative);
  if lAttribute:Scale is DexiDiscreteScale then
    begin
      var lScale := DexiDiscreteScale(lAttribute.Scale);
      if not lValue.IsDefined or lValue.HasIntSingle then
        begin
          var lCtrl := new ComboBox;
          lCtrl.DropDownStyle := ComboBoxStyle.DropDownList;
          lCtrl.Items.AddRange(lScale.NameList.ToArray);
          lCtrl.Items.Add(DexiString.SDexiUndefinedValue);
          lCtrl.Bounds := e.CellBounds;
          lCtrl.SelectedIndex :=
            if lValue.IsDefined then lValue.AsInteger
            else lScale.Count;
          lCtrl.SelectedIndexChanged += ComboEdit_SelectedIndexChanged;
          lCtrl.PreviewKeyDown += EditCell_PreviewKeyDown;
          lCtrl.KeyDown += EditCell_KeyDown;
          AppDisposeHandler.HandleUndisposed(e.Control);
          e.Control := lCtrl;
          // WARNING: Disposing editor controls here or leaving e.AutoDispose = true
          // causes unpredictable system crashes deep in system code.
          // Thus the need to delay disposing thru HandleUndisposedControl
          e.AutoDispose := false;
          fEditingParameters.EditMode := CellEditMode.Discrete;
        end
      else
        begin
          OpenValueEditor;
          e.Cancel := true;
        end;
    end
  else if lAttribute:Scale is DexiContinuousScale  then
    begin
      if e.Control is TextBox then
        begin
          var lCtrl := TextBox(e.Control);
//        lCtrl.TextAlign := HorizontalAlignment.Right;
          lCtrl.Text :=
            if fStartEditString <> nil then fStartEditString
            else if lValue.IsDefined then lValue.AsString
            else DexiString.SDexiUndefinedValue;
          if fStartEditString <> nil then
            lCtrl.SelectionStart := fStartEditString.Length
          else
            lCtrl.SelectAll;
          fEditingParameters.EditMode := CellEditMode.Continuous;
        end;
    end;
end;

method CtrlFormAlternatives.ViewAlternatives_CellEditValidating(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if fEditingParameters = nil then
    begin
      e.Cancel := true;
      exit;
    end;
  if fEditingParameters.EditMode <> CellEditMode.Continuous then
    exit;
  if e.Cancel or not (e.Control is TextBox) then
    exit;
  var lValue := AppUtils.EditedFloatValue(TextBox(e.Control).Text);
  if lValue = nil then
    e.Cancel := true
  else
    fEditingParameters.EditedValue := lValue;
end;

method CtrlFormAlternatives.ViewAlternatives_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if e.Cancel then
    exit;
  if fEditingParameters = nil then
    begin
      e.Cancel := true;
      exit;
    end;
  case fEditingParameters.EditMode of
    CellEditMode.None: ;
    CellEditMode.Discrete:
      if e.Control is ComboBox then
        begin
          var lIdx := ComboBox(e.Control).SelectedIndex;
          if 0 <= lIdx < fEditingParameters.Attribute.Scale.Count then
            fEditingParameters.EditedValue := new DexiIntSingle(lIdx)
          else if lIdx = fEditingParameters.Attribute.Scale.Count then
            fEditingParameters.EditedValue := new DexiUndefinedValue;
        end;
    CellEditMode.Continuous: ;  // already done through validation
    CellEditMode.Edit: ;
  end;
end;

method CtrlFormAlternatives.ViewAlternatives_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if fEditingParameters = nil then
    begin
      e.Cancel := true;
      exit;
    end;
  var lChanged := false;
  case fEditingParameters.EditMode of
    CellEditMode.None: ;
    CellEditMode.Discrete:
     begin
       if not e.Cancel then
         if fEditingParameters.EditedValue <> nil then
           begin
             fEditingParameters.Attribute.AltValue[fEditingParameters.Alternative] := fEditingParameters.EditedValue;
             lChanged := true;
           end;
        AppDisposeHandler.HandleUndisposed(e.Control);
        // WARNING: Disposing editor controls here or leaving e.AutoDispose = true
        // causes unpredictable system crashes deep in system code.
        // Thus the need to delay disposing thru HandleUndisposedControl
        // e.Control.Dispose; // may cause crash
        // e.Control := nil; // may cause crash
      end;
    CellEditMode.Continuous:
      begin
         if not e.Cancel then
         if fEditingParameters.EditedValue <> nil then
           begin
             fEditingParameters.Attribute.AltValue[fEditingParameters.Alternative] := fEditingParameters.EditedValue;
             lChanged := true;
           end;
      end;
    CellEditMode.Edit: ;
  end;
  if lChanged then
    AlternativeValueChanged(fEditingParameters.Alternative);
  fEditingParameters := nil;
  UpdateForm;
end;

method CtrlFormAlternatives.ViewAlternatives_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if (ViewAlternatives.SelectedObject = nil) and (fLastSelectedNode <> nil) then
    ViewAlternatives.SelectObject(fLastSelectedNode, true);
end;

method CtrlFormAlternatives.ViewAlternatives_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
begin
  if e.RowIndex = ViewAlternatives.SelectedIndex then
    e.SubItem.BackColor := AppSettings.SelectedColor;
  var lAltColIdx := AltColumnIndex(e.Column);
  if lAltColIdx < 0 then
    exit;
  if lAltColIdx = fSelectedAlternative then
    begin
      e.SubItem.BackColor := AppSettings.SelectedColor;
      if e.RowIndex = ViewAlternatives.SelectedIndex then
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

method CtrlFormAlternatives.ViewAlternatives_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  CancelEditMode;
  if SelectedNode = nil then
    exit;
  if e.KeyCode = Keys.Left then
    begin
      var lToSelect := -1;
      for lCol := fSelectedAlternative - 1 downto 0 do
        begin
          var lAltCol := AltColumn[lCol];
          if lAltCol.IsVisible then
            begin
              lToSelect := lCol;
              break;
            end;
        end;
      if lToSelect >= 0 then
        begin
          fSelectedAlternative := lToSelect;
          SelectionChanged;
        end;
      e.Handled := true;
    end
  else if e.KeyCode = Keys.Right then
    begin
      var lToSelect := -1;
      for lCol := fSelectedAlternative + 1 to fModel.AltCount - 1 do
        begin
          var lAltCol := AltColumn[lCol];
          if lAltCol.IsVisible then
            begin
              lToSelect := lCol;
              break;
            end;
        end;
      if lToSelect >= 0 then
        begin
          fSelectedAlternative := lToSelect;
          SelectionChanged;
        end;
      e.Handled := true;
    end;
end;

method CtrlFormAlternatives.ViewAlternatives_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
  CancelEditMode;
  fStartEditString := nil;
  if (SelectedNode = nil) or not CanEditValue then
    exit;
  var lKeyValue := AppUtils.ExtToIntVal(Char.ToUpper(e.KeyChar));
  var lAttribute := SelectedNode;
  var lAlternative := fSelectedAlternative;
  if lAttribute:Scale is DexiDiscreteScale then
    begin
      if e.KeyChar = '*' then
        begin
          lAttribute.AltValue[lAlternative] := DexiDiscreteScale(lAttribute.Scale).FullValue;
          AlternativeValueChanged(lAlternative);
          e.Handled := true;
        end
      else if 0 <= lKeyValue < lAttribute.Scale.Count then
        begin
          lAttribute.AltValue[lAlternative] := new DexiIntSingle(lKeyValue);
          AlternativeValueChanged(lAlternative);
          e.Handled := true;
        end;
    end
  else if lAttribute:Scale is DexiContinuousScale  then
    begin
      if Char.IsDigit(e.KeyChar) or (e.KeyChar in ['-', '+', '.', ',']) then
        begin
          fStartEditString := e.KeyChar;
          EditAlternativeValue(lAttribute, lAlternative);
        end;
    end;
end;

method CtrlFormAlternatives.ViewAlternatives_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if e.Button = MouseButtons.Right then
    ViewAlternatives_MouseClick(sender, e);
end;

method CtrlFormAlternatives.ViewAlternatives_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  CancelEditMode;
  if sender = ViewAlternatives then
    begin
      var ht := ViewAlternatives.OlvHitTest(e.Location.X, e.Location.Y);
      if ht <> nil then
        begin
          var lAltColIdx := AltColumnIndex(ht.Column);
          if lAltColIdx >= 0 then
            fSelectedAlternative := lAltColIdx;
          fMouseHitOut := ht.RowObject = nil;
          SelectNode(ht.RowObject);
        end;
    end;
end;

method CtrlFormAlternatives.ViewAlternatives_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  CancelEditMode;
  if not (Visible and CanEditValue) then
    exit;
  fStartEditString := nil;
  EditAlternativeValue(SelectedNode, fSelectedAlternative);
end;

method CtrlFormAlternatives.ViewAlternatives_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method CtrlFormAlternatives.ViewAlternatives_ColumnClick(sender: System.Object; e: System.Windows.Forms.ColumnClickEventArgs);
begin
  CancelEditMode;
  if sender = ViewAlternatives then
    begin
      var lColumn := ViewAlternatives.GetColumn(e.Column);
      var lAltColIdx := AltColumnIndex(lColumn);
      if lAltColIdx >= 0 then
        fSelectedAlternative := lAltColIdx;
      SelectNode(SelectedNode);
    end;
end;

method CtrlFormAlternatives.EditCell_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if e.KeyCode = Keys.Tab then
    ViewAlternatives.FinishCellEdit
  else
    fEditKeyPressed :=
      (e.KeyCode = Keys.Up) or (e.KeyCode = Keys.Down) or
      (e.KeyCode = Keys.Home) or (e.KeyCode = Keys.End) or
      (e.KeyCode = Keys.PageUp) or (e.KeyCode = Keys.PageDown);
end;

method CtrlFormAlternatives.EditCell_PreviewKeyDown(sender: System.Object; e: System.Windows.Forms.PreviewKeyDownEventArgs);
begin
  if e.KeyCode = Keys.Tab then
    e.IsInputKey := true;
end;

method CtrlFormAlternatives.ItemMenuResizeColumns_Click(sender: System.Object; e: System.EventArgs);
begin
  ResizeColumns;
end;

method CtrlFormAlternatives.ItemMenuResetVertical_Click(sender: System.Object; e: System.EventArgs);
begin
  Model.InputAttributeOrder := nil;
  DoEnter;
end;

method CtrlFormAlternatives.ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
begin
  var lIdx := fInputAttributes.IndexOf(fSelectedNode);
  if 0 < lIdx < fInputAttributes.Count then
    begin
      fInputAttributes.Move(lIdx, lIdx - 1);
      Model.SetInputAttributeOrder(fInputAttributes);
      DoEnter;
    end;
end;

method CtrlFormAlternatives.ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
begin
  var lIdx := fInputAttributes.IndexOf(fSelectedNode);
  if 0 <= lIdx < (fInputAttributes.Count - 1) then
    begin
      fInputAttributes.Move(lIdx, lIdx + 1);
      Model.SetInputAttributeOrder(fInputAttributes);
      DoEnter;
    end;

end;

end.