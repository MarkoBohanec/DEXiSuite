// CtrlFormEvaluation.pas is part of
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
// CtrlFormEvaluation.pas implements a 'CtrlForm' aimed at displaying results of alternatives'
// evaluation in a tree-structured form. Additionally, 'CtrlFormEvaluation' supports editing of
// alternatives' input data and provides decision-analysis commands.
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
  /// Summary description for CtrlFormEvaluation.
  /// </summary>
  CtrlFormEvaluation = public partial class(CtrlForm)
  private
    method ItemToolEvaluateQQ_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuResizeColumns_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolTarget_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPlusMinus_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSelExpl_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCompare_Click(sender: System.Object; e: System.EventArgs);
    method ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method CtrlFormEvaluation_VisibleChanged(sender: System.Object; e: System.EventArgs);
    method EvaluationMenu_Opening(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    method ItemMenuCollapseAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCollapseOne_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuExpandAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuExpandOne_Click(sender: System.Object; e: System.EventArgs);
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
    method TreeViewEvaluation_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method TreeViewEvaluation_CellEditValidating(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method TreeViewEvaluation_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method TreeViewEvaluation_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method TreeViewEvaluation_Click(sender: System.Object; e: System.EventArgs);
    method TreeViewEvaluation_Collapsed(sender: System.Object; e: BrightIdeasSoftware.TreeBranchCollapsedEventArgs);
    method TreeViewEvaluation_Expanded(sender: System.Object; e: BrightIdeasSoftware.TreeBranchExpandedEventArgs);
    method TreeViewEvaluation_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
    method TreeViewEvaluation_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method TreeViewEvaluation_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method TreeViewEvaluation_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method TreeViewEvaluation_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method TreeViewEvaluation_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method TreeViewEvaluation_ColumnClick(sender: System.Object; e: System.Windows.Forms.ColumnClickEventArgs);
    method TreeViewEvaluation_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method EditCell_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method EditCell_PreviewKeyDown(sender: System.Object; e: System.Windows.Forms.PreviewKeyDownEventArgs);
   private
    fModel: DexiModel;
    fSelectedNode: DexiAttribute;
    fLastSelectedNode: DexiAttribute;
    fSelectedAlternative: Integer;
    fEditingParameters: ValueEditingParameters;
    fStartEditString: String;
    fUpdateLevel := 0;
    fEditKeyPressed := false;
    fMouseHitOut := false;
    fCollapseSelect := true;
    class const NonAltColumns = 3;
  protected
    method Dispose(disposing: Boolean); override;
    method ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method SetModel(aModel: DexiModel);
    method GetAltColumn(aAlt: Integer): OLVColumn;
    method GetAltColCount: Integer;
    method AltColumnIndex(aCol: OLVColumn): Integer;
    method SelectRootIfUnselected(lNode: DexiAttribute);
    method SelectNode(aNode: Object);
    method CollapseNode(aAtt: DexiAttribute; aCollapseSelect: Boolean := true);
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
    method CanEditName: Boolean;
    method CanAddLeft: Boolean;
    method CanAddRight: Boolean;
    method CanDelete: Boolean;
    method CanDuplicate: Boolean;
    method CanEditValue: Boolean;
    method CanOpenValueEditor: Boolean;
    method CanSelectiveExplanation: Boolean;
    method CanPlusMinusAnalysis: Boolean;
    method CanTargetAnalysis: Boolean;
    method CanCompareAlternatives: Boolean;
    method CanEvaluateQQ: Boolean;
    method UpdateForm;
    method SelectionChanged;
    method VisibilityChanged;
    method UncollapseAttributes;
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
constructor CtrlFormEvaluation;
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
  TreeViewEvaluation.SelectedForeColor := TreeViewEvaluation.ForeColor;
  TreeViewEvaluation.SelectedBackColor := AppSettings.SelectedColor;
  TreeViewEvaluation.SmallImageList := AppData:ModelImages;

  TreeViewEvaluation.CanExpandGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then DexiAttribute(x).IsAggregate
        else false;
    end;

  TreeViewEvaluation.ChildrenGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then DexiAttribute(x).AllInputs
        else nil;
    end;

  ColName.ImageGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then 'ImgAtt' + DexiAttribute(x).NodeStatus.ToString
        else nil;
    end;

end;

method CtrlFormEvaluation.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    TreeViewEvaluation.SmallImageList := nil;
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlFormEvaluation.SetModel(aModel: DexiModel);
begin
  fModel := aModel;
  ColScale.Renderer := new CompositeModelScaleRenderer(Settings := fModel:Settings);
end;

method CtrlFormEvaluation.GetAltColumn(aAlt: Integer): OLVColumn;
begin
  result :=
    if 0 <= aAlt < AltColCount then TreeViewEvaluation.AllColumns[aAlt + NonAltColumns]
    else nil;
end;

method CtrlFormEvaluation.GetAltColCount: Integer;
begin
  result := TreeViewEvaluation.AllColumns.Count - NonAltColumns;
end;

method CtrlFormEvaluation.AltColumnIndex(aCol: OLVColumn): Integer;
begin
  var lIdx := TreeViewEvaluation.AllColumns.IndexOf(aCol);
  result :=
    if lIdx >= NonAltColumns then lIdx - NonAltColumns
    else -1;
end;

method CtrlFormEvaluation.SelectRootIfUnselected(lNode: DexiAttribute);
begin
  if lNode = nil then
    begin
      var lFirstNode := Model:First;
      if lFirstNode <> nil then
        TreeViewEvaluation.SelectObject(lFirstNode, true);
    end
  else
    while lNode <> nil do
      begin
        if lNode.Parent = Model.Root then
          begin
            TreeViewEvaluation.SelectObject(lNode, true);
            break;
          end;
        lNode := lNode.Parent;
      end;
  fSelectedNode := DexiAttribute(TreeViewEvaluation.SelectedObject);
end;

method CtrlFormEvaluation.SelectNode(aNode: Object);
begin
  if fLastSelectedNode <> nil then
    TreeViewEvaluation.RefreshObject(fLastSelectedNode);
  TreeViewEvaluation.SelectObject(aNode, true);
  TreeViewEvaluation.RefreshObject(aNode);
  SelectionChanged;
end;

method CtrlFormEvaluation.CollapseNode(aAtt: DexiAttribute; aCollapseSelect: Boolean := true);
begin
  fCollapseSelect := aCollapseSelect;
  TreeViewEvaluation.Collapse(aAtt);
  fCollapseSelect := true;
end;

method CtrlFormEvaluation.SelectAlternative(aNext: Boolean);

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

method CtrlFormEvaluation.SelectAlternative(aIdx: Integer; aNext: Boolean := true);
begin
  fSelectedAlternative := aIdx;
  SelectAlternative(aNext);
end;

method CtrlFormEvaluation.UpdateColumnHeaders;
begin
  for lIdx := 0 to AltColCount - 1 do
    begin
      var lCol := AltColumn[lIdx];
      lCol.Text := fModel.AltNames[lIdx].Name;
      lCol.ToolTipText := fModel.AltNames[lIdx].Description;
      lCol.Tag := lIdx;
    end;
end;

method CtrlFormEvaluation.UpdateColumnVisibility;
begin
  var lChanged := false;
  var lVisibility := AltVisibility.EvaluationVisibility;
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
      TreeViewEvaluation.RebuildColumns;
      OrderColumns;
    end;
end;

method CtrlFormEvaluation.MakeAltColumns;
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
            TreeViewEvaluation.AllColumns.Add(lAltCol);
          end
      else if AltColCount > fModel.AltCount then
        begin
          var lDiff := AltColCount - fModel.AltCount;
          var lIdx := TreeViewEvaluation.AllColumns.Count;
          for i := 1 to lDiff do
            begin
              dec(lIdx);
              TreeViewEvaluation.AllColumns[lIdx].Renderer := nil;
              TreeViewEvaluation.AllColumns.RemoveAt(lIdx);
            end;
        end;
      TreeViewEvaluation.RebuildColumns;
    end;
  assert(fModel.AltCount = AltColCount);
  UpdateColumnVisibility;
  UpdateColumnHeaders;
end;

method CtrlFormEvaluation.MakeAltViewMenu;
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
      lMenuItems.RemoveAt(lMenuItems.Count - 1);
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

method CtrlFormEvaluation.MakeContextMenu;
begin
  EvaluationMenu.SuspendLayout;
  try
    // Clean previous items
    var lPos := -1;
    for i := 0 to EvaluationMenu.Items.Count - 1 do
      if EvaluationMenu.Items[i] is ToolStripSeparator then
        begin
          lPos := i;
          break;
        end;
    for i := lPos - 1 downto 0 do
      begin
        EvaluationMenu.Items[i].Click -= ItemPopDefinedValue_Click;
        EvaluationMenu.Items.RemoveAt(i);
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
            EvaluationMenu.Items.Insert(0, lItem);
          end;
      end;
  finally
    EvaluationMenu.ResumeLayout;
    fMouseHitOut := false;
  end;
end;

method CtrlFormEvaluation.OrderColumns;
begin
  for i := TreeViewEvaluation.AllColumns.Count - 1 downto 0 do
    TreeViewEvaluation.AllColumns[i].DisplayIndex := 0;
end;

method CtrlFormEvaluation.Init;
begin
  TreeViewEvaluation.SetObjects(Model:Root:AllInputs);
  MakeAltColumns;
  if TreeViewEvaluation.SelectedObject = nil then
    SelectRootIfUnselected(nil);
  TreeViewEvaluation.ExpandAll;
  fLastSelectedNode := SelectedNode;
  fSelectedAlternative := 0;
  UpdateForm;
end;

method CtrlFormEvaluation.UncollapseAttributes;
begin
  var lInputs := Model.Root.CollectInputs(false);
  var lExpanded := new List<DexiAttribute>;
  for each lElement in TreeViewEvaluation.ExpandedObjects do
    lExpanded.Add(DexiAttribute(lElement));
  for each lAtt in lExpanded do
    if not lInputs.Contains(lAtt) or not lAtt.IsAggregate then
      CollapseNode(lAtt, false);
end;

method CtrlFormEvaluation.DoEnter;
begin
  CancelEditMode;
  if fModel.NeedsEvaluation then
    fModel.Evaluate;
  TreeViewEvaluation.DeselectAll;
  UncollapseAttributes;
  TreeViewEvaluation.SetObjects(fModel:Root:AllInputs);
  MakeAltColumns;
  MakeAltViewMenu;
  if TreeViewEvaluation.SelectedObject = nil then
    SelectRootIfUnselected(nil);
  TreeViewEvaluation.Focus;
  fLastSelectedNode := SelectedNode;
  SelectAlternative(false);
  UpdateForm;
end;

method CtrlFormEvaluation.CanMoveLeft: Boolean;
begin
  result := (0 < fSelectedAlternative < Model.AltCount) and (Model.AltCount > 1);
end;

method CtrlFormEvaluation.CanMoveRight: Boolean;
begin
  result := (0 <= fSelectedAlternative < Model.AltCount - 1) and (Model.AltCount > 1);
end;

method CtrlFormEvaluation.CanEditName: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormEvaluation.CanAddLeft: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormEvaluation.CanAddRight: Boolean;
begin
  result := -1 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormEvaluation.CanDelete: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormEvaluation.CanDuplicate: Boolean;
begin
  result := 0 <= fSelectedAlternative < Model.AltCount;
end;

method CtrlFormEvaluation.CanEditValue: Boolean;
begin
  result :=
    (0 <= fSelectedAlternative < Model.AltCount) and
    DexiAttribute.AttributeIsBasicNonLinked(SelectedNode) and
    (SelectedNode.Scale <> nil);
end;

method CtrlFormEvaluation.CanOpenValueEditor: Boolean;
begin
  result := CanEditValue and SelectedNode.Scale.IsDiscrete;
end;

method CtrlFormEvaluation.CanSelectiveExplanation: Boolean;
begin
  result := Model.AltCount > 0;
end;

method CtrlFormEvaluation.CanPlusMinusAnalysis: Boolean;
begin
  result :=
    (0 <= fSelectedAlternative < Model.AltCount) and
    DexiPlusMinusReport.ValidAttribute(fSelectedNode) and
    fSelectedNode.IsAggregate;
end;

method CtrlFormEvaluation.CanTargetAnalysis: Boolean;
begin
  result :=
    (0 <= fSelectedAlternative < Model.AltCount) and
    DexiTargetReport.ValidAttribute(fSelectedNode) and
    fSelectedNode.IsAggregate;
end;

method CtrlFormEvaluation.CanCompareAlternatives: Boolean;
begin
  result := Model.AltCount > 1;
end;

method CtrlFormEvaluation.CanEvaluateQQ: Boolean;
begin
  result := Model.AltCount > 0;
end;

method CtrlFormEvaluation.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  TreeViewEvaluation.Refresh;
  var lFirst := Model:First;
  if lFirst <> nil then
    if not TreeViewEvaluation.IsExpanded(lFirst) then
      TreeViewEvaluation.RefreshObject(lFirst);
  inc(fUpdateLevel);
  try
    ItemMenuViewDescription.Checked := ColDescription.IsVisible;
    ItemMenuViewScale.Checked := ColScale.IsVisible;
  finally
    dec(fUpdateLevel);
  end;
  AppUtils.Enable(CanMoveLeft, ItemToolMoveLeft, ItemMenuMoveLeft, ItemPopMoveLeft);
  AppUtils.Enable(CanMoveRight, ItemToolMoveRight, ItemMenuMoveRight, ItemPopMoveRight);
  AppUtils.Enable(CanEditName, ItemToolAltDescr, ItemMenuAltDescr, ItemPopAltDescr);
  AppUtils.Enable(CanAddLeft, ItemToolAddAlternativeLeft, ItemMenuAddAlternativeLeft, ItemPopAddAlternativeLeft);
  AppUtils.Enable(CanAddRight, ItemToolAddAlternativeRight, ItemMenuAddAlternativeRight, ItemPopAddAlternativeRight);
  AppUtils.Enable(CanDelete, ItemToolDeleteAlternative, ItemMenuDeleteAlternative, ItemPopDeleteAlternative);
  AppUtils.Enable(CanDuplicate, ItemToolDuplicateAlternative, ItemMenuDuplicateAlternative, ItemPopDuplicateAlternative);
  AppUtils.Enable(CanEditValue, ItemToolEditValue, ItemMenuEditValue, ItemPopEditValue);
  AppUtils.Enable(CanOpenValueEditor, ItemToolValueEditor, ItemMenuValueEditor, ItemPopValueEditor);
  AppUtils.Enable(CanCompareAlternatives, ItemToolCompare, ItemMenuCompare);
  AppUtils.Enable(CanSelectiveExplanation, ItemToolSelExpl, ItemMenuSelExpl);
  AppUtils.Enable(CanPlusMinusAnalysis, ItemToolPlusMinus, ItemMenuPlusMinus);
  AppUtils.Enable(CanTargetAnalysis, ItemToolTarget, ItemMenuTarget);
  AppUtils.Enable(CanEvaluateQQ, ItemToolEvaluateQQ, ItemMenuEvaluateQQ);
  TreeViewEvaluation.Dock := DockStyle.Fill;
  AppUtils.UpdateModelForm(self);
  AppData.AppForm.UpdateForm;
end;

method CtrlFormEvaluation.SelectionChanged;
begin
  fSelectedNode := DexiAttribute(TreeViewEvaluation:SelectedObject);
  UpdateForm;
  fLastSelectedNode := SelectedNode;
end;

method CtrlFormEvaluation.VisibilityChanged;
begin
  TreeViewEvaluation.RebuildColumns;
  OrderColumns;
  UpdateColumnHeaders;
  UpdateColumnVisibility;
  SelectAlternative(false);
  MakeAltViewMenu;
  UpdateForm;
end;

method CtrlFormEvaluation.EditAlternativeValue(aAtt: DexiAttribute; aAlt: Integer);
begin
  TreeViewEvaluation.StartCellEdit(TreeViewEvaluation.ModelToItem(aAtt), AltColumn[aAlt].Index);
end;

method CtrlFormEvaluation.AlternativeValueChanged(aAlt: Integer);
begin
  Model.EvaluateNoLinking(aAlt); // implicit Model.Modify;
  SaveState;
  TreeViewEvaluation.RefreshAllObjects;
  UpdateForm;
end;

method CtrlFormEvaluation.OpenValueEditor;
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

method CtrlFormEvaluation.CancelEditMode;
begin
  if TreeViewEvaluation.IsCellEditing then
    TreeViewEvaluation.FinishCellEdit;
end;

method CtrlFormEvaluation.DoKeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  TreeViewEvaluation_KeyDown(sender, e);
end;

method CtrlFormEvaluation.ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
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

method CtrlFormEvaluation.ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if fEditKeyPressed then
    fEditKeyPressed := false
  else
    TreeViewEvaluation.FinishCellEdit;
end;

method CtrlFormEvaluation.CtrlFormEvaluation_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  DoEnter;
end;

method CtrlFormEvaluation.EvaluationMenu_Opening(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  MakeContextMenu;
end;

method CtrlFormEvaluation.ItemMenuCollapseAll_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  inc(fUpdateLevel);
  try
    var lPreCollapseSelected := DexiAttribute(TreeViewEvaluation.SelectedObject);
    TreeViewEvaluation.CollapseAll;
    SelectRootIfUnselected(lPreCollapseSelected);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormEvaluation.ItemMenuCollapseOne_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  inc(fUpdateLevel);
  try
    TreeViewEvaluation.CollapseOne;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormEvaluation.ItemMenuExpandAll_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  inc(fUpdateLevel);
  try
    TreeViewEvaluation.ExpandAll;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormEvaluation.ItemMenuExpandOne_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  inc(fUpdateLevel);
  try
    TreeViewEvaluation.ExpandOne;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormEvaluation.ItemMenuModelDescr_Click(sender: System.Object; e: System.EventArgs);
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

method CtrlFormEvaluation.ItemMenuViewAlt_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  if sender is not ToolStripMenuItem then
    exit;
  var lItem := ToolStripMenuItem(sender);
  var lColIndex := Integer(lItem.Tag);
  var lVisibility := AltVisibility.EvaluationVisibility;
  if lVisibility.Contains(lColIndex) then
    lVisibility.Exclude(lColIndex)
  else
    lVisibility.Include(lColIndex);
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemMenuViewDescription_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  ColDescription.IsVisible := not ColDescription.IsVisible;
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemMenuViewScale_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  ColScale.IsVisible := not ColScale.IsVisible;
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemPopFullRange_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not CanEditValue then
    exit;
  SelectedNode.AltValue[fSelectedAlternative] := DexiDiscreteScale(SelectedNode.Scale).FullValue;
  AlternativeValueChanged(fSelectedAlternative);
end;

method CtrlFormEvaluation.ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not CanEditValue then
    exit;
  SelectedNode.AltValue[fSelectedAlternative] := new DexiUndefinedValue;
  AlternativeValueChanged(fSelectedAlternative);
end;

method CtrlFormEvaluation.ItemToolAddAlternativeLeft_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanAddLeft) then
    exit;
  var lAlt := Model.InsertAlternative(fSelectedAlternative, DexiString.SDexiNewAlternative);
  Model.EvaluateNoLinking(lAlt); // implicit Model.Modify;
  AltVisibility.AddAlternative(lAlt);
  SaveState;
  MakeAltColumns;
  VisibilityChanged;
  ItemToolAltDescr_Click(sender, e);
end;

method CtrlFormEvaluation.ItemToolAddAlternativeRight_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanAddRight) then
    exit;
  var lAlt := Model.InsertAlternative(fSelectedAlternative + 1, DexiString.SDexiNewAlternative);
  fSelectedAlternative := fSelectedAlternative + 1;
  Model.EvaluateNoLinking(lAlt); // implicit Model.Modify;
  AltVisibility.AddAlternative(lAlt);
  SaveState;
  MakeAltColumns;
  VisibilityChanged;
  ItemToolAltDescr_Click(sender, e);
end;

method CtrlFormEvaluation.ItemToolAltDescr_Click(sender: System.Object; e: System.EventArgs);
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

method CtrlFormEvaluation.ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not Visible then
    exit;
  var lTable := new DexiAlternativesTable(Model);
  lTable.LoadFromModel(Model);
  var lList := lTable.SaveToStringList;
  Clipboard.SetText(String.Join(Environment.LineBreak, lList));
end;

method CtrlFormEvaluation.ItemToolPaste_Click(sender: System.Object; e: System.EventArgs);
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

method CtrlFormEvaluation.ItemToolDeleteAlternative_Click(sender: System.Object; e: System.EventArgs);
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

method CtrlFormEvaluation.ItemToolDuplicateAlternative_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanDuplicate) then
    exit;
  Model.DuplicateAlternative(fSelectedAlternative);
  fSelectedAlternative := fSelectedAlternative + 1;
  Model.AltNames[fSelectedAlternative].Name := Model.AltNames[fSelectedAlternative - 1].Name + "*";
  Model.EvaluateNoLinking(fSelectedAlternative); // implicit Model.Modify;
  AltVisibility.AddAlternative(fSelectedAlternative);
  SaveState;
  MakeAltColumns;
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemToolEditValue_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanEditValue) then
    exit;
  fStartEditString := nil;
  EditAlternativeValue(SelectedNode, fSelectedAlternative);
end;

method CtrlFormEvaluation.ItemToolMoveLeft_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanMoveLeft) then
    exit;
  Model.MoveAlternativePrev(fSelectedAlternative);
  AltVisibility.MoveAlternativePrev(fSelectedAlternative);
  fSelectedAlternative := fSelectedAlternative - 1;
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemToolMoveRight_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if not (Visible and CanMoveRight) then
    exit;
  Model.MoveAlternativeNext(fSelectedAlternative);
  AltVisibility.MoveAlternativeNext(fSelectedAlternative);
  fSelectedAlternative := fSelectedAlternative + 1;
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemToolValueEditor_Click(sender: System.Object; e: System.EventArgs);
begin
  OpenValueEditor;
end;

method CtrlFormEvaluation.ItemViewAltHideAll_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  AltVisibility.EvaluationVisibility.Clear;
  VisibilityChanged;
end;

method CtrlFormEvaluation.ItemViewAltShowAll_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  AltVisibility.EvaluationVisibility.All(0, AltColCount - 1);
  VisibilityChanged;
end;

method CtrlFormEvaluation.TreeViewEvaluation_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
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
          // Thus the need to delay disposing thru AppDisposeHandler
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

method CtrlFormEvaluation.TreeViewEvaluation_CellEditValidating(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
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

method CtrlFormEvaluation.TreeViewEvaluation_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
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

method CtrlFormEvaluation.TreeViewEvaluation_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
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
        AppDisposeHandler.HandleUndisposed(e.Control)
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

method CtrlFormEvaluation.TreeViewEvaluation_Click(sender: System.Object; e: System.EventArgs);
begin
  CancelEditMode;
  if (TreeViewEvaluation.SelectedObject = nil) and (fLastSelectedNode <> nil) then
    TreeViewEvaluation.SelectObject(fLastSelectedNode, true);
end;

method CtrlFormEvaluation.TreeViewEvaluation_Collapsed(sender: System.Object; e: BrightIdeasSoftware.TreeBranchCollapsedEventArgs);
begin
  if fCollapseSelect then
    if e.Model <> nil then
      SelectNode(e.Model);
end;

method CtrlFormEvaluation.TreeViewEvaluation_Expanded(sender: System.Object; e: BrightIdeasSoftware.TreeBranchExpandedEventArgs);
begin
  if e.Model <> nil then
    SelectNode(e.Model);
end;

method CtrlFormEvaluation.TreeViewEvaluation_FormatCell(sender: System.Object; e: BrightIdeasSoftware.FormatCellEventArgs);
begin
  if e.RowIndex = TreeViewEvaluation.SelectedIndex then
    e.SubItem.BackColor := AppSettings.SelectedColor;
  var lAltColIdx := AltColumnIndex(e.Column);
  if lAltColIdx < 0 then
    exit;
  if lAltColIdx = fSelectedAlternative then
    begin
      e.SubItem.BackColor := AppSettings.SelectedColor;
      if e.RowIndex = TreeViewEvaluation.SelectedIndex then
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

method CtrlFormEvaluation.TreeViewEvaluation_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
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

method CtrlFormEvaluation.TreeViewEvaluation_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
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

method CtrlFormEvaluation.TreeViewEvaluation_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if e.Button = MouseButtons.Right then
    TreeViewEvaluation_MouseClick(sender, e);
end;

method CtrlFormEvaluation.TreeViewEvaluation_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  CancelEditMode;
  if sender = TreeViewEvaluation then
    begin
      var ht := TreeViewEvaluation.OlvHitTest(e.Location.X, e.Location.Y);
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

method CtrlFormEvaluation.TreeViewEvaluation_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  CancelEditMode;
  if not (Visible and CanEditValue) then
    exit;
  fStartEditString := nil;
  EditAlternativeValue(SelectedNode, fSelectedAlternative);
end;

method CtrlFormEvaluation.TreeViewEvaluation_ColumnClick(sender: System.Object; e: System.Windows.Forms.ColumnClickEventArgs);
begin
  CancelEditMode;
  if sender = TreeViewEvaluation then
    begin
      var lColumn := TreeViewEvaluation.GetColumn(e.Column);
      var lAltColIdx := AltColumnIndex(lColumn);
      if lAltColIdx >= 0 then
        fSelectedAlternative := lAltColIdx;
      SelectNode(SelectedNode);
    end;
end;

method CtrlFormEvaluation.TreeViewEvaluation_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method CtrlFormEvaluation.ItemToolCompare_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  if not CanCompareAlternatives then
    exit;
  ReportManager.OpenComparisonReport(fModel, fSelectedAlternative);
end;

method CtrlFormEvaluation.ItemToolSelExpl_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  if not CanSelectiveExplanation then
    exit;
  ReportManager.OpenSelectiveExplanationReport(fModel);
end;

method CtrlFormEvaluation.ItemToolPlusMinus_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  if not CanPlusMinusAnalysis then
    exit;
  ReportManager.OpenPlusMinusReport(fModel, fSelectedNode, fSelectedAlternative);
end;

method CtrlFormEvaluation.ItemToolTarget_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  if not CanTargetAnalysis then
    exit;
  ReportManager.OpenTargetReport(fModel, fSelectedNode, fSelectedAlternative);
end;

method CtrlFormEvaluation.ItemToolEvaluateQQ_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  CancelEditMode;
  if not CanEvaluateQQ then
    exit;
  ReportManager.OpenEvaluateQQReport(fModel);
end;

method CtrlFormEvaluation.SaveState;
begin
  AppUtils.ModelForm(self).SaveState;
end;

method CtrlFormEvaluation.DataChanged;
begin
  DoEnter;
end;

method CtrlFormEvaluation.EditCell_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if e.KeyCode = Keys.Tab then
    TreeViewEvaluation.FinishCellEdit
  else
    fEditKeyPressed :=
      (e.KeyCode = Keys.Up) or (e.KeyCode = Keys.Down) or
      (e.KeyCode = Keys.Home) or (e.KeyCode = Keys.End) or
      (e.KeyCode = Keys.PageUp) or (e.KeyCode = Keys.PageDown);
end;

method CtrlFormEvaluation.EditCell_PreviewKeyDown(sender: System.Object; e: System.Windows.Forms.PreviewKeyDownEventArgs);
begin
  if e.KeyCode = Keys.Tab then
    e.IsInputKey := true;
end;

method CtrlFormEvaluation.ResizeColumns;
begin
  ColName.AutoResize(ColumnHeaderAutoResizeStyle.ColumnContent);
  if ColDescription.IsVisible then
    ColDescription.AutoResize(ColumnHeaderAutoResizeStyle.ColumnContent);
  var lAtts := fModel.Root.CollectInputs;
  if ColScale.IsVisible then
    begin
      var lWidth := TextRenderer.MeasureText(ColScale.Text, TreeViewEvaluation.Font).Width;
      lWidth := Math.Max(lWidth, TextRenderer.MeasureText('Undefined', TreeViewEvaluation.Font).Width);
      for each lAtt in lAtts do
        if lAtt.Scale <> nil then
          begin
            var lStr := lAtt.Scale.ScaleText;
            lWidth := Math.Max(lWidth, Integer(1.06 * TextRenderer.MeasureText(lStr, TreeViewEvaluation.Font).Width));
          end;
      ColScale.Width := lWidth;
    end;
  for each lColumn in TreeViewEvaluation.Columns do
    with lCol :=  OLVColumn(lColumn) do
      if lCol.IsVisible and (lCol.AspectName = 'Alt') and (Integer(lCol.Tag) >= 0) then
        begin
          var lWidth := TextRenderer.MeasureText(lCol.Text, TreeViewEvaluation.Font).Width + 10;
          var lAlt := Integer(lCol.Tag);
          var lScaleStrings := CompositeAlternativeValueRenderer(lCol.Renderer).ScaleStrings;
          for each lAtt in lAtts do
            begin
              var lValue := fModel.AltValue[lAlt, lAtt];
              var lText := lScaleStrings.ValueOnScaleString(lValue, lAtt.Scale);
              lWidth := Math.Max(lWidth, Integer(1.06 * TextRenderer.MeasureText(lText, TreeViewEvaluation.Font).Width));
            end;
          lCol.Width := Math.Max(lWidth, lCol.MinimumWidth);
        end;
end;

method CtrlFormEvaluation.ItemMenuResizeColumns_Click(sender: System.Object; e: System.EventArgs);
begin
  ResizeColumns;
end;

end.