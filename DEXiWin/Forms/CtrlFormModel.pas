// CtrlFormModel.pas is part of
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
// CtrlFormModel.pas implements a 'CtrlForm' for editing a DEXi model.
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
  RemObjects.Elements.RTL,
  BrightIdeasSoftware,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for CtrlFormModel.
  /// </summary>
  CtrlFormModel = public partial class(CtrlForm)
  private
    method BtnEditScale_Click(sender: System.Object; e: System.EventArgs);
    method BtnError_Click(sender: System.Object; e: System.EventArgs);
    method BtnSelectScale_Click(sender: System.Object; e: System.EventArgs);
    method FormSplit_DoubleClick(sender: System.Object; e: System.EventArgs);
    method TextDescription_TextChanged(sender: System.Object; e: System.EventArgs);
    method TextName_TextChanged(sender: System.Object; e: System.EventArgs);
    method Text_Leave(sender: System.Object; e: System.EventArgs);
    method TreeViewModel_Enter(sender: System.Object; e: System.EventArgs);
    method TreeViewModel_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method TreeViewModel_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method TreeViewModel_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method TreeViewModel_Click(sender: System.Object; e: System.EventArgs);
    method TreeViewModel_Collapsing(sender: System.Object; e: BrightIdeasSoftware.TreeBranchCollapsingEventArgs);
    method TreeViewModel_Collapsed(sender: System.Object; e: BrightIdeasSoftware.TreeBranchCollapsedEventArgs);
    method TreeViewModel_Expanded(sender: System.Object; e: BrightIdeasSoftware.TreeBranchExpandedEventArgs);
    method TreeViewModel_ModelCanDrop(sender: System.Object; e: BrightIdeasSoftware.ModelDropEventArgs);
    method TreeViewModel_ModelDropped(sender: System.Object; e: BrightIdeasSoftware.ModelDropEventArgs);
    method ItemMenuCollapseAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCollapseOne_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuExpandAll_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuExpandOne_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuSearch_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuFindNext_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewAttributePanel_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewDescription_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewFunction_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewScale_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewTree_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuModelDescr_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAttDescr_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddAttribute_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDeleteAttribute_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDuplicateAttribute_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddChild_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuDeleteScale_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuReverseScale_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuEditFunction_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuDeleteFunction_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCut_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPaste_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuResizeColumns_Click(sender: System.Object; e: System.EventArgs);
  protected
    method Dispose(disposing: Boolean); override;
    method SetupForm;
    method SetModel(aModel: DexiModel);
    method SelectRootIfUnselected(lNode: DexiAttribute);
    method SetNameDesc(aName: String; aDesc: String);
    method MakeScaleForEditing(aAtt: DexiAttribute): DexiScale;
    method GetVisibleElements: String;
    method SetVisibleElements(aElements: String);
    method GetColumnWidths: IntArray;
    method SetColumnWidths(aWidths: IntArray);
  private
    fModel: DexiModel;
    fUpdateLevel := 0;
    fSelectedNode: DexiAttribute;
    fLastSelected: DexiAttribute;
    fCollapsingObject: Object := nil;
    fPreCollapseSelected: Object := nil;
    fAttPanelVisible: Boolean := true;
    fDescrVisible: Boolean := true;
    fScaleVisible: Boolean := true;
    fFunctVisible: Boolean := true;
    fAttInserted: Boolean := false;
    fEditChanged: Boolean := false;
    // DEBUGGING
    fModelCheck: DexiObjectStrings;
    property SelectedNode: DexiAttribute read fSelectedNode;
    method CanCopySubtree(aAtt: DexiAttribute): Boolean;
    method CopySubtree(aAtt: DexiAttribute): DexiAttribute;
    method CanDeleteSubtree(aAtt: DexiAttribute): Boolean;
    method CutSubtreeDeletes(aAtt: DexiAttribute): DexiObjectList;
    method CanCutSubtree(aAtt: DexiAttribute): Boolean;
    method CanPasteFromApp: Boolean;
    method CanPasteFromClipboard: Boolean;
    method CanPasteSubtree(aAtt: DexiAttribute): Boolean;
  public
    constructor;
    method Init;
    method UpdateForm;
    method SelectionChanged;
    method FindNext;
    method UpdateAfterRestructure(aSelect: DexiObject := nil);
    method SelectNameEdit;
    method CanImportFunct: Boolean;
    method CanExportFunct: Boolean;
    method ImportFunct(aFileName: String);
    method ExportFunct(aFileName: String);
    method SaveState;
    method ModelChanged;
    method ResizeColumns;
    property Model: DexiModel read fModel write SetModel;
    property VisibleElements: String read GetVisibleElements write SetVisibleElements;
    property ColumnWidths: IntArray read GetColumnWidths write SetColumnWidths;
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormModel;
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
  TextName.Anchor := TextName.Anchor or AnchorStyles.Right;
  TextDescription.Anchor := TextDescription.Anchor or AnchorStyles.Right;
  ScaleText.Anchor := ScaleText.Anchor or AnchorStyles.Right;
  FunctionText.Anchor := FunctionText.Anchor or AnchorStyles.Right;
  TreeViewModel.SmallImageList := AppData:ModelImages;

  TreeViewModel.CanExpandGetter :=
    method(x: Object)
    begin
      result :=
        if (x is DexiAttribute) then DexiAttribute(x).IsAggregate
        else false;
    end;

  TreeViewModel.ChildrenGetter :=
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

method CtrlFormModel.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    TreeViewModel.SmallImageList := nil;
    fModel := nil;
    fSelectedNode := nil;
    fLastSelected := nil;
  end;
  inherited Dispose(disposing);
end;

{$ENDREGION}

method CtrlFormModel.SetupForm;
begin
  var lSettings := fModel.AppModSettings;
  if lSettings = nil then
    exit;
  var lMainWindowState :=
    if lSettings.MainFormMaximized then FormWindowState.Maximized
    else FormWindowState.Normal;
  if AppData.AppForm.Size.Width <> lSettings.MainFormSize.Width then
    AppData.AppForm.Size.Width := lSettings.MainFormSize.Width;
  if AppData.AppForm.Size.Height <> lSettings.MainFormSize.Height then
    AppData.AppForm.Size.Height := lSettings.MainFormSize.Height;
  if AppData.AppForm.WindowState <> lMainWindowState then
    AppData.AppForm.WindowState := lMainWindowState;
  VisibleElements := lSettings.ModelFormVisibleElements;
  ColumnWidths := lSettings.ModelFormColumnWidths;
  AppUtils.Show(fDescrVisible, ColDescription);
  AppUtils.Show(fScaleVisible, ColScale);
  AppUtils.Show(fFunctVisible, ColFunction);
  TreeViewModel.RebuildColumns;
end;

method CtrlFormModel.SetModel(aModel: DexiModel);
begin
  fModel := aModel;
  ColScale.Renderer := new CompositeModelScaleRenderer(Settings := fModel:Settings);
  ColFunction.Renderer := new CompositeModelFunctRenderer(Settings := fModel:Settings);
  SetupForm;
end;

method CtrlFormModel.SelectRootIfUnselected(lNode: DexiAttribute);
begin
  if lNode = nil then
    begin
      var lFirstNode := Model:First;
      if lFirstNode <> nil then
        TreeViewModel.SelectObject(lFirstNode);
    end
  else
    while lNode <> nil do
      begin
        if lNode.Parent = Model.Root then
          begin
            TreeViewModel.SelectObject(lNode);
            break;
          end;
        lNode := lNode.Parent;
      end;
  fSelectedNode := DexiAttribute(TreeViewModel:SelectedObject);
end;

method CtrlFormModel.SetNameDesc(aName: String; aDesc: String);
begin
  inc(fUpdateLevel);
  try
    TextName.Text := aName;
    TextDescription.Text :=  aDesc;
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlFormModel.MakeScaleForEditing(aAtt: DexiAttribute): DexiScale;
begin
  result := nil;
  if aAtt = nil then
    exit
  else if aAtt.Scale <> nil then
    result := aAtt.Scale.CopyScale
  else
    begin
      var lDiscrete := true;
      var lParent := SelectedNode.Parent;
      if aAtt.IsBasic and (lParent <> nil) and (lParent.Funct = nil) and (lParent.InpCount = 1) then // may choose scale type
        using lForm := new FormScaleCreate do
          begin
            lForm.SetForm(aAtt);
            if lForm.ShowDialog <> DialogResult.OK then
              exit;
            lDiscrete := lForm.Discrete;
          end;
       result :=
         if lDiscrete then DexiScale.NewDiscreteScale
         else DexiScale.NewContinuousScale;
    end;
end;

method CtrlFormModel.GetVisibleElements: String;
begin
  if fAttPanelVisible and fDescrVisible and fScaleVisible and fFunctVisible then
    exit nil;
  result := '';
  if fAttPanelVisible then
    result := result + 'A';
  if fDescrVisible then
    result := result + 'D';
  if fScaleVisible then
    result := result + 'S';
  if fFunctVisible then
    result := result + 'F';
end;

method CtrlFormModel.SetVisibleElements(aElements: String);
begin
  fAttPanelVisible := (aElements = nil) or (aElements.Contains('A'));
  fDescrVisible := (aElements = nil) or (aElements.Contains('D'));
  fScaleVisible := (aElements = nil) or (aElements.Contains('S'));
  fFunctVisible := (aElements = nil) or (aElements.Contains('F'));
end;

method CtrlFormModel.GetColumnWidths: IntArray;
begin
  result := Utils.NewIntArray(4);
  result[0] := ColName.Width;
  result[1] := ColDescription.Width;
  result[2] := ColScale.Width;
  result[3] := ColFunction.Width;
end;

method CtrlFormModel.SetColumnWidths(aWidths: IntArray);

  method SetColWidth(aIdx: Integer; aCol: OLVColumn);
  begin
    if aIdx > high(aWidths) then
      exit;
    var lWidth := aWidths[aIdx];
    if lWidth <= 0 then
      exit;
    aCol.Width := lWidth;
  end;

begin
  if length(aWidths) = 0 then
    exit;
  SetColWidth(0, ColName);
  SetColWidth(1, ColDescription);
  SetColWidth(2, ColScale);
  SetColWidth(3, ColFunction);
end;

method CtrlFormModel.CanCopySubtree(aAtt: DexiAttribute): Boolean;
begin
  result := (SelectedNode <> nil) and TreeViewModel.Focused;
end;

method CtrlFormModel.CopySubtree(aAtt: DexiAttribute): DexiAttribute;
begin
  if CanCopySubtree(aAtt) then
    begin
      var aList := new List<String>;
      Model.SaveToStringList(aAtt, var aList);
      result := Model.LoadFromStringList(aList);
      AppData.SubtreeCopy := result;
      Clipboard.SetText(String.Join(' ', aList), TextDataFormat.Html);
    end;
end;

method CtrlFormModel.CanDeleteSubtree(aAtt: DexiAttribute): Boolean;
begin
  result := Model.CanDeleteBasic(aAtt) or Model.CanDeleteSubtree(aAtt);
end;

method CtrlFormModel.CutSubtreeDeletes(aAtt: DexiAttribute): DexiObjectList;
begin
  result := nil;
  if CanCutSubtree(aAtt) and (aAtt:Parent:Funct <> nil) then
    begin
      result := new DexiObjectList;
      result.Add(aAtt.Parent.Funct);
    end;
end;

method CtrlFormModel.CanCutSubtree(aAtt: DexiAttribute): Boolean;
begin
  result := (aAtt <> nil) and (aAtt.Parent <> nil) and (aAtt.Parent <> Model.Root) and TreeViewModel.Focused;
end;

method CtrlFormModel.CanPasteFromApp: Boolean;
begin
  result := (AppData.SubtreeCopy <> nil) and TreeViewModel.Focused;
end;

method CtrlFormModel.CanPasteFromClipboard: Boolean;
begin
  result := false;
  if not TreeViewModel.Focused then
    exit;
  if not Clipboard.ContainsText(TextDataFormat.Html) then
    exit;
  var lText := Clipboard.GetText;
  result := lText.StartsWith('<SUBTREE>') and lText.EndsWith('</SUBTREE>');
end;

method CtrlFormModel.CanPasteSubtree(aAtt: DexiAttribute): Boolean;
begin
  result := false;
  if (CanPasteFromApp or CanPasteFromClipboard) and DexiAttribute.AttributeIsBasic(aAtt) and (aAtt.Parent <> nil) then
    begin
      var lScalesCompatible :=
        if CanPasteFromApp then DexiScale.AssignmentCompatibleScales(aAtt.Scale, AppData.SubtreeCopy.Scale)
        else (aAtt.Scale = nil);
      result := lScalesCompatible and (aAtt.Funct = nil);
    end;
end;

method CtrlFormModel.Init;

  method AlignField(aX1, aX2: Integer): Integer;
  const Diff = 6;
  begin
    result := aX2 - aX1 - Diff;
  end;

begin
  TreeViewModel.SetObjects(Model:Root:AllInputs);
  if TreeViewModel.SelectedObject = nil then
    SelectRootIfUnselected(nil);
  TreeViewModel.ExpandAll;
  TreeViewModel.Focus;
  fLastSelected := SelectedNode;
  TextName.Size.Width := AlignField(TextName.Location.X, BtnAttDescr.Location.X);
  ScaleText.Size.Width := AlignField(ScaleText.Location.X, BtnSelectScale.Location.X);
  FunctionText.Size.Width := AlignField(FunctionText.Location.X, BtnEditFunct.Location.X);
  TextDescription.Size.Width := BtnAttDescr.Location.X + BtnAttDescr.Size.Width - TextDescription.Location.X;
  UpdateForm;
end;

method CtrlFormModel.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  ItemMenuViewAttributePanel.Checked := fAttPanelVisible;
  ItemMenuViewDescription.Checked := fDescrVisible;
  ItemMenuViewScale.Checked := fScaleVisible;
  ItemMenuViewFunction.Checked := fFunctVisible;
  TreeViewModel.Refresh;
  var lSelectedAttribute := SelectedNode;
  var lReadOnly := Model.Settings.ModelProtect;
  AppUtils.Show(fAttPanelVisible, FormSplit, AttPanel);
  AppUtils.Show(fDescrVisible, ColDescription);
  AppUtils.Show(fScaleVisible, ColScale);
  AppUtils.Show(fFunctVisible, ColFunction);
  AppUtils.Enable(not lReadOnly, ItemToolModelDescr, TextName, TextDescription);
  AppUtils.Enable((lSelectedAttribute <> nil) and not lReadOnly,
    ItemToolAttDescr, ItemMenuAttDescr, ItemPopAttDescr, BtnAttDescr);
  AppUtils.Enable(Model.CanMoveNext(lSelectedAttribute) and not lReadOnly, 
    ItemToolMoveDown, ItemMenuMoveDown, ItemPopMoveDown);
  AppUtils.Enable(Model.CanMovePrev(lSelectedAttribute) and not lReadOnly,
    ItemToolMoveUp, ItemMenuMoveUp, ItemPopMoveUp);
  AppUtils.Enable(Model.CanAddInputTo(lSelectedAttribute) and not lReadOnly,
    ItemToolAddChild, ItemMenuAddChild, ItemPopAddChild);
  AppUtils.Enable(Model.CanAddSibling(lSelectedAttribute) and not lReadOnly,
    ItemToolAddAttribute, ItemMenuAddAttribute, ItemPopAddAttribute);
  AppUtils.Enable(CanDeleteSubtree(lSelectedAttribute) and not lReadOnly,
    ItemToolDeleteAttribute, ItemMenuDeleteAttribute, ItemPopDeleteAttribute);
  AppUtils.Enable(Model.CanDuplicateSubtree(lSelectedAttribute) and not lReadOnly, ItemToolDuplicateAttribute, ItemMenuDuplicateAttribute, ItemPopDuplicateAttribute);
  AppUtils.Enable(CanCopySubtree(lSelectedAttribute) and not lReadOnly,
    ItemToolCopy, ItemMenuCopy, ItemPopCopy);
  AppUtils.Enable(CanCutSubtree(lSelectedAttribute) and not lReadOnly,
    ItemToolCut, ItemMenuCut, ItemPopCut);
  AppUtils.Enable(CanPasteSubtree(lSelectedAttribute) and not lReadOnly,
    ItemToolPaste, ItemMenuPaste, ItemPopPaste);
  AppUtils.Enable(not String.IsNullOrEmpty(AppData.SearchParams.SearchString), ItemMenuFindNext, ItemPopFindNext);
  AppUtils.Enable((lSelectedAttribute <> nil) and not lReadOnly,
    ItemMenuEditScale, ItemPopEditScale, BtnEditScale, ItemMenuSelectScale, ItemPopSelectScale, BtnSelectScale);
  AppUtils.Enable((lSelectedAttribute:Scale <> nil) and not lReadOnly,
    ItemMenuDeleteScale, ItemPopDeleteScale);
  AppUtils.Enable((lSelectedAttribute:Scale <> nil) and (lSelectedAttribute.Scale.Order <> DexiOrder.None) and not lReadOnly,
    ItemMenuReverseScale);
  AppUtils.Enable((lSelectedAttribute:Funct <> nil) and not lReadOnly,
    ItemMenuDeleteFunction, ItemPopDeleteFunction);
  AppUtils.Show(DexiAttribute.AttributeIsAggregate(lSelectedAttribute), FunctionText, LblFunction, BtnEditFunct);
  AppUtils.Enable((lSelectedAttribute:Funct <> nil) or DexiFunction.CanCreateAnyFunctionOn(lSelectedAttribute) and not lReadOnly,
    ItemMenuEditFunction, ItemPopEditFunction, BtnEditFunct);
  TreeViewModel.Dock := if fAttPanelVisible then DockStyle.Left else DockStyle.Fill;
  AppUtils.UpdateModelForm(self);
  if AppData:AppForm <> nil then
    AppData.AppForm.UpdateForm;

  fModelCheck := nil;
  {$IFDEF DEBUG}
  fModelCheck := Model.CheckModelStructure;
  {$ENDIF}
  AppUtils.Show(fModelCheck <> nil, BtnError);
end;

method CtrlFormModel.SelectionChanged;
begin
  inc(fUpdateLevel);
  try
    fSelectedNode := DexiAttribute(TreeViewModel:SelectedObject);
    if SelectedNode = nil then
      SelectRootIfUnselected(nil);
    if SelectedNode = nil then
      begin
        TextName.Clear;
        TextDescription.Clear;
        ScaleText.Clear;
        FunctionText.Clear;
        AttPanel.Visible := false;
      end
    else
      begin
        SetNameDesc(SelectedNode.Name, SelectedNode.Description);
        ScaleText.Clear;
        FunctionText.Clear;
        ScaleText.SetScaleText(SelectedNode:Scale, ScaleText.BackColor, true);
        FunctionText.Text := if SelectedNode.Funct = nil then DexiString.MStrFunctionUndef else SelectedNode.Funct.FunctString;
        AttPanel.Visible := fAttPanelVisible;
        if fAttInserted then
          SelectNameEdit;
      end;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
  fLastSelected := SelectedNode;
  fAttInserted := false;
end;

method CtrlFormModel.FindNext;
var fAllList := new DexiAttributeList;

  method TextCompare(aString: String): Boolean;
  begin
    result :=
      if AppData.SearchParams.MatchCase then aString.Contains(AppData.SearchParams.SearchString)
      else aString.ToUpper.Contains(AppData.SearchParams.SearchStringUpper);
  end;

  method TextFound(aAtt: DexiAttribute): Boolean;
  begin
    result := false;
    if AppData.SearchParams.SearchName and TextCompare(aAtt.Name) then
      exit true;
    if AppData.SearchParams.SearchDescr and TextCompare(aAtt.Description) then
      exit true;
    if AppData.SearchParams.SearchScale and (aAtt.Scale <> nil) then
      if TextCompare(aAtt.Scale.ScaleString) then
         exit true;
  end;

  method FindInRange(aFrom, aTo: Integer): DexiAttribute;
  begin
    result := nil;
    for lIdx := aFrom to aTo do
      begin
        var lAtt := fAllList[lIdx];
        if TextFound(lAtt) then
          exit lAtt;
      end;
  end;

begin
  if SelectedNode = nil then
    exit;
  Model.Root.CollectInputs(fAllList);
  var lIdx := fAllList.IndexOf(SelectedNode);
  if lIdx < 0 then
    exit;
  var lFound := FindInRange(lIdx + 1, fAllList.Count - 1);
  if lFound = nil then
    lFound := FindInRange(0, lIdx - 1);
  if lFound <> nil then
    begin
      var lPar := lFound.Parent;
      while (lPar <> nil) and (lPar <> Model.Root) do
        begin
         TreeViewModel.Expand(lPar);
         lPar := lPar.Parent;
        end;
      TreeViewModel.SelectObject(lFound);
      UpdateForm;
    end;
end;

method CtrlFormModel.UpdateAfterRestructure(aSelect: DexiObject := nil);
begin
  inc(fUpdateLevel);
  try
    try
      TreeViewModel.SetObjects(Model:Root:AllInputs);
    except on NullReferenceException do
      begin
        TreeViewModel.ClearObjects;
        TreeViewModel.SetObjects(Model:Root:AllInputs);
        TreeViewModel.ExpandAll;
      end;
    end;
    TreeViewModel.RebuildAll(true);
    if aSelect <> nil then
      TreeViewModel.SelectObject(aSelect);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormModel.SelectNameEdit;
begin
  if SelectedNode = nil then
    exit;
  if TextName.Visible then
    begin
      TextName.Focus;
      TextName.SelectAll;
    end
  else
    begin
      TreeViewModel.Focus;
      TreeViewModel.FocusedObject := SelectedNode;
    end;
 end;

method CtrlFormModel.CanImportFunct: Boolean;
begin
  result :=
    (SelectedNode <> nil) and
    ((SelectedNode.Funct <> nil) or DexiFunction.CanCreateAnyFunctionOn(SelectedNode));
end;

method CtrlFormModel.CanExportFunct: Boolean;
begin
  result := SelectedNode:Funct <> nil;
end;

method CtrlFormModel.ImportFunct(aFileName: String);
begin
  if not CanImportFunct then
    exit;
  var lFunct := SelectedNode:Funct;
  if lFunct = nil then
    begin
      lFunct := DexiFunction.CreateOn(SelectedNode);
      SelectedNode.Funct := lFunct;
    end;
  if lFunct = nil then
    exit;
  var lLoaded: Integer;
  var lChanged: Integer;
  lFunct.LoadFromFile(aFileName, Model.Settings, out lLoaded, out lChanged);
  Model.Modify;
  SaveState;
  UpdateForm;
  var lMessage :=
    if lFunct is DexiDiscretizeFunction then DexiString.SDexiDiscrFncImport
    else DexiString.SDexiTabFncImport;
  MessageBox.Show(String.Format(lMessage, lLoaded, lChanged),
         "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
end;

method CtrlFormModel.ExportFunct(aFileName: String);
begin
  if not CanExportFunct then
    exit;
  var lFunct := SelectedNode:Funct;
  lFunct.SaveToFile(aFileName, Model.Settings);
end;

method CtrlFormModel.SaveState;
begin
  AppUtils.ModelForm(self).SaveState;
end;

method CtrlFormModel.ModelChanged;
begin
  UpdateAfterRestructure(SelectedNode);
end;

method CtrlFormModel.ResizeColumns;
begin
  ColName.AutoResize(ColumnHeaderAutoResizeStyle.ColumnContent);
  if ColDescription.IsVisible then
    ColDescription.AutoResize(ColumnHeaderAutoResizeStyle.ColumnContent);
  var lAtts := fModel.Root.CollectInputs;
  if ColScale.IsVisible then
    begin
      var lWidth := TextRenderer.MeasureText(ColScale.Text, TreeViewModel.Font).Width;
      lWidth := Math.Max(lWidth, TextRenderer.MeasureText('Undefined', TreeViewModel.Font).Width);
      for each lAtt in lAtts do
        if lAtt.Scale <> nil then
          begin
            var lStr := lAtt.Scale.ScaleText;
            lWidth := Math.Max(lWidth, Integer(1.06 * TextRenderer.MeasureText(lStr, TreeViewModel.Font).Width));
          end;
      ColScale.Width := lWidth;
    end;
  if ColFunction.IsVisible then
    begin
      var lWidth := TextRenderer.MeasureText(ColFunction.Text, TreeViewModel.Font).Width;
      for each lAtt in lAtts do
        if lAtt.Funct <> nil then
          begin
            var lStr := lAtt.Funct.FunctString;
            lWidth := Math.Max(lWidth, TextRenderer.MeasureText(lStr, TreeViewModel.Font).Width);
          end;
      ColFunction.Width := lWidth;
    end;
end;

method CtrlFormModel.BtnEditScale_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedNode = nil then
    exit;
  if Model.Settings.Warnings then
    begin
      var lFunct := Model.EditScaleAffects(SelectedNode);
      if lFunct <> nil then
        begin
          var lMsg :=
            case lFunct.Count of
              1: String.Format(DexiString.SDexiEditScaleFunction, SelectedNode.Name, lFunct[0].Str);
              2: String.Format(DexiString.SDexiEditScaleFunctions, SelectedNode.Name, lFunct[0].Str, lFunct[1].Str);
              else '';
            end;
         if MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
           exit;
        end;
    end;
  var lScale := MakeScaleForEditing(SelectedNode);
  if lScale = nil then
    exit
  else if lScale is DexiDiscreteScale then
    using lForm := new FormScaleEditDiscrete do
      begin
        lForm.SetForm(Model, SelectedNode, DexiDiscreteScale(lScale));
        if lForm.ShowDialog = DialogResult.OK then
          begin
            if lForm.ParentFunct <> nil then
              SelectedNode.Parent.Funct := lForm.ParentFunct;
            if lForm.Funct <> nil then
              SelectedNode.Funct := lForm.Funct;
            SelectedNode.Scale := lForm.Scale;
            Model.LinkAttributes;
            Model.Modify;
            SaveState;
            SelectionChanged;
            UpdateForm;
          end;
      end
  else if lScale is DexiContinuousScale then
    using lForm := new FormScaleEditContinuous do
      begin
        lForm.SetForm(SelectedNode, DexiContinuousScale(lScale));
        if lForm.ShowDialog = DialogResult.OK then
          begin
            SelectedNode.Scale := lForm.Scale;
            Model.LinkAttributes;
            Model.Modify;
            SaveState;
            SelectionChanged;
            UpdateForm;
          end;
      end;
end;

method CtrlFormModel.BtnError_Click(sender: System.Object; e: System.EventArgs);
begin
  {$IFDEF DEBUG}
  if fModelCheck <> nil then
     MessageBox.Show('Tree structure error(s): ' + Environment.LineBreak + String.Join(Environment.LineBreak, fModelCheck.ToStrings),
       "Internal Error", MessageBoxButtons.OK, MessageBoxIcon.Error)
  {$ENDIF}
end;

method CtrlFormModel.BtnSelectScale_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedNode = nil then
    exit;
  var lScales :=  Model.GetScalesFor(SelectedNode);
  using lForm := new FormScaleSelect do
    begin
      lForm.SetForm(SelectedNode, lScales, Model.DefaultScale);
      if lForm.ShowDialog = DialogResult.OK then
        begin
          Model.DefaultScale := lForm.DefaultScale;
          var lScl := lForm.SelectedScale;
          if SelectedNode.CanSetScale(lScl) then
            begin
              SelectedNode.Scale :=
                if lScl = nil then nil
                else lScl.CopyScale;
              Model.LinkAttributes;
              Model.Modify;
              SaveState;
              TreeViewModel.RefreshObject(SelectedNode);
              SelectionChanged;
              UpdateForm;
            end;
        end;
    end;
end;

method CtrlFormModel.FormSplit_DoubleClick(sender: System.Object; e: System.EventArgs);
begin
  TreeViewModel.Width := TreeViewModel.TotalWidth + 2;
end;

method CtrlFormModel.TextName_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel <= 0) and (ActiveControl = TextName) and (SelectedNode <> nil) then
    begin
      SelectedNode.Name := TextName.Text;
      Model.LinkAttributes;
      Model.Modify;
      fEditChanged := true;
    end;
end;

method CtrlFormModel.TextDescription_TextChanged(sender: System.Object; e: System.EventArgs);
begin
  if (fUpdateLevel <= 0) and (ActiveControl = TextDescription) and (SelectedNode <> nil) then
    begin
      SelectedNode.Description := TextDescription.Text;
      Model.Modify;
      fEditChanged := true;
    end;
end;

method CtrlFormModel.Text_Leave(sender: System.Object; e: System.EventArgs);
begin
  if not fEditChanged then
    exit;
  SaveState;
//  UpdateAfterRestructure(SelectedNode);
  UpdateForm;
  fEditChanged := false;
end;

method CtrlFormModel.TreeViewModel_Enter(sender: System.Object; e: System.EventArgs);
begin
  fEditChanged := false;
  UpdateForm;
end;

method CtrlFormModel.TreeViewModel_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  // correcting TreeViewModel bugs
  TreeViewModel.SelectObject(e.RowObject);
  TreeViewModel.FocusedObject := e.RowObject;
  if e.Column = ColName then
    begin
      e.Control.Width := ColName.Width - e.Control.Location.X;
    end
  else if e.Column = ColDescription then
    begin
      e.Control.Location.X := ColName.Width;
      e.Control.Width := ColDescription.Width;
    end;
end;

method CtrlFormModel.TreeViewModel_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  var lStr := e.NewValue.ToString;
  if e.Column = ColName then
    begin
      if SelectedNode <> nil then
        begin
          SelectedNode.Name := lStr;
          Model.LinkAttributes;
          Model.Modify;
          SaveState;
        end;
    end
  else if e.Column = ColDescription then
    begin
      if SelectedNode <> nil then
        begin
          SelectedNode.Description := lStr;
          Model.Modify;
          SaveState;
        end;
    end;
  SelectionChanged;
end;

method CtrlFormModel.TreeViewModel_Click(sender: System.Object; e: System.EventArgs);
begin
  if (TreeViewModel.SelectedObject = nil) and (fLastSelected <> nil) then
    TreeViewModel.SelectObject(fLastSelected);
end;

method CtrlFormModel.TreeViewModel_Collapsing(sender: System.Object; e: BrightIdeasSoftware.TreeBranchCollapsingEventArgs);
begin
  fCollapsingObject := e.Model;
  fPreCollapseSelected := TreeViewModel.SelectedObject;
end;

method CtrlFormModel.TreeViewModel_Collapsed(sender: System.Object; e: BrightIdeasSoftware.TreeBranchCollapsedEventArgs);

  method CurrentNodeOnPath: Boolean;
  begin
    result := false;
    var lNode := DexiAttribute(fPreCollapseSelected):Parent;
    while lNode <> nil do
      begin
        if lNode = fCollapsingObject then
          exit true;
        lNode := lNode:Parent;
      end;
  end;

begin
  if (e.Model = fCollapsingObject) and (fPreCollapseSelected <> nil) then
    begin
      var lPostCollapseSelected := TreeViewModel.SelectedObject;
      if (lPostCollapseSelected = nil) and CurrentNodeOnPath then
        TreeViewModel.SelectObject(fCollapsingObject);
    end;
  fCollapsingObject := nil;
  fPreCollapseSelected := nil;
  UpdateForm;
end;

method CtrlFormModel.TreeViewModel_Expanded(sender: System.Object; e: BrightIdeasSoftware.TreeBranchExpandedEventArgs);
begin
  UpdateForm;
end;

method CtrlFormModel.TreeViewModel_ModelCanDrop(sender: System.Object; e: BrightIdeasSoftware.ModelDropEventArgs);
begin
  e.Effect := DragDropEffects.None;
  if Model.Settings.ModelProtect then
    exit;
  if (e.SourceListView <> TreeViewModel) or (e.TargetModel is not DexiAttribute) or
     (e.SourceModels.Count <> 1) or (e.SourceModels[0] is not DexiAttribute) then
    exit;
  var lSource := DexiAttribute(e.SourceModels[0]);
  var lDest := DexiAttribute(e.TargetModel);
  if Model.CanJoinAttributes(lSource, lDest) or Model.CanMoveSubtree(lSource, lDest) then
    e.Effect := DragDropEffects.Move;
end;

method CtrlFormModel.TreeViewModel_ModelDropped(sender: System.Object; e: BrightIdeasSoftware.ModelDropEventArgs);
begin
  if (e.SourceListView <> TreeViewModel) or (e.TargetModel is not DexiAttribute) or
     (e.SourceModels.Count <> 1) or (e.SourceModels[0] is not DexiAttribute) then
    exit;
  var lSource := DexiAttribute(e.SourceModels[0]);
  var lDest := DexiAttribute(e.TargetModel);
  var lSrcParent := lSource.Parent;
  if lSrcParent = nil then
   exit;
  if Model.Settings.Warnings then
    begin
      var lFunct := Model.MoveSubtreeDeletes(lSource, lDest);
      if lFunct <> nil then
        begin
          var lMsg :=
            case lFunct.Count of
              1: String.Format(DexiString.SDexiMovingAttFunction, lSource.Name, lDest.Name, lFunct[0].Str);
              2: String.Format(DexiString.SDexiMovingAttFunctions, lSource.Name, lDest.Name, lFunct[0].Str, lFunct[1].Str);
              else '';
            end;
          if MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
            exit;
        end;
    end;
  if (lSrcParent <> nil) and (lSrcParent.InpCount = 1) then
    TreeViewModel.Collapse(lSrcParent);
  if Model.CanJoinAttributes(lSource, lDest) then
    Model.JoinAttributes(lSource, lDest)
  else if Model.CanMoveSubtree(lSource, lDest) then
    Model.MoveSubtree(lSource, lDest);
  TreeViewModel.Expand(lDest);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(lSource);
end;

method CtrlFormModel.TreeViewModel_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method CtrlFormModel.ItemMenuCollapseAll_Click(sender: System.Object; e: System.EventArgs);
begin
  inc(fUpdateLevel);
  try
    var lPreCollapseSelected := DexiAttribute(TreeViewModel.SelectedObject);
    TreeViewModel.CollapseAll;
    SelectRootIfUnselected(lPreCollapseSelected);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuCollapseOne_Click(sender: System.Object; e: System.EventArgs);
begin
  inc(fUpdateLevel);
  try
    TreeViewModel.CollapseOne;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuExpandAll_Click(sender: System.Object; e: System.EventArgs);
begin
  inc(fUpdateLevel);
  try
    TreeViewModel.ExpandAll;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuExpandOne_Click(sender: System.Object; e: System.EventArgs);
begin
  inc(fUpdateLevel);
  try
    TreeViewModel.ExpandOne;
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuSearch_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Visible then
    exit;
  AppData.SearchForm.SearchParams := AppData.SearchParams;
  if AppData.SearchForm.ShowDialog = DialogResult.OK then
    begin
      AppData.SearchParams := AppData.SearchForm.SearchParams;
      FindNext;
    end;
end;

method CtrlFormModel.ItemMenuFindNext_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Visible then
    exit;
  FindNext;
end;

method CtrlFormModel.ItemMenuViewAttributePanel_Click(sender: System.Object; e: System.EventArgs);
begin
  fAttPanelVisible := not fAttPanelVisible;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuViewDescription_Click(sender: System.Object; e: System.EventArgs);
begin
  fDescrVisible := not fDescrVisible;
  AppUtils.Show(fDescrVisible, ColDescription);
  TreeViewModel.RebuildColumns;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuViewScale_Click(sender: System.Object; e: System.EventArgs);
begin
  fScaleVisible := not fScaleVisible;
  AppUtils.Show(fScaleVisible, ColScale);
  TreeViewModel.RebuildColumns;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuViewFunction_Click(sender: System.Object; e: System.EventArgs);
begin
  fFunctVisible := not fFunctVisible;
  AppUtils.Show(fFunctVisible, ColFunction);
  TreeViewModel.RebuildColumns;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuViewTree_Click(sender: System.Object; e: System.EventArgs);
begin
  var lForm := AppUtils.ModelForm(self);
  if lForm <> nil then
    lForm.OpenTreeGraphic;
end;

method CtrlFormModel.ItemMenuModelDescr_Click(sender: System.Object; e: System.EventArgs);
begin
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

method CtrlFormModel.ItemToolAttDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedNode = nil then
    exit;
  var lAttDescrForm := AppData.NameEditForm;
  lAttDescrForm.SetForm(DexiStrings.TitleAttNameEdit, DexiStrings.LabelAttNameEdit, DexiStrings.LabelAttDescrEdit);
  lAttDescrForm.SetTexts(SelectedNode.Name, SelectedNode.Description);
  if lAttDescrForm.ShowDialog = DialogResult.OK then
    begin
      SelectedNode.Name := lAttDescrForm.NameText;
      SelectedNode.Description := lAttDescrForm.DescriptionText;
      SetNameDesc(lAttDescrForm.NameText, lAttDescrForm.DescriptionText);
      Model.LinkAttributes;
      Model.Modify;
      SaveState;
      UpdateForm;
    end;
end;

method CtrlFormModel.ItemToolAddAttribute_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and Model.CanAddSibling(SelectedNode)) then
    exit;
  if Model.Settings.Warnings then
    begin
     var lFunct := Model.AddSiblingDeletes(SelectedNode);
     if lFunct <> nil then
       if MessageBox.Show(String.Format(DexiString.SDexiAddBasic, SelectedNode:Parent:Name),
         "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
         exit;
    end;
  var lNewAtt := Model.AddSibling(SelectedNode);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(lNewAtt);
  fAttInserted := true;
end;

method CtrlFormModel.ItemToolDeleteAttribute_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Visible then
    exit;
  var lSelect: DexiAttribute := nil;
  if SelectedNode = nil then
    exit;
  if SelectedNode.IsBasic then
    begin
      if not Model.CanDeleteBasic(SelectedNode) then
        exit;
      if Model.Settings.Warnings then
        begin
          var lMsg := String.Format(DexiString.SDexiDelBasic, SelectedNode.Name);
          var lFunct := Model.DeleteBasicDeletes(SelectedNode);
          if lFunct <> nil then
            lMsg := lMsg + Environment.LineBreak + String.Format(DexiString.SDexiDeletingAttFunction, SelectedNode:Parent:Name);
          if MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
            exit;
        end;
      with lParent := SelectedNode.Parent do
        begin
          if lParent = Model.Root then
            lParent := Model.First;
          if (lParent <> nil) and (lParent.InpCount = 1) then
            TreeViewModel.Collapse(lParent);
        end;
      lSelect := Model.DeleteBasic(SelectedNode);
      if lSelect = Model.Root then
        lSelect := Model.First;
    end
  else if SelectedNode.IsAggregate then
    begin
      if not Model.CanDeleteSubtree(SelectedNode) then
        exit;
      if Model.Settings.Warnings then
        if MessageBox.Show(String.Format(DexiString.SDexiDelChildren, SelectedNode.Name),
          "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
          exit;
      lSelect := Model.DeleteSubtree(SelectedNode);
      if lSelect <> nil then
        TreeViewModel.Collapse(lSelect);
    end;
  if lSelect = nil then
    exit;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(lSelect);
end;

method CtrlFormModel.ItemToolDuplicateAttribute_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and Model.CanDuplicateSubtree(SelectedNode)) then
    exit;
  var lSubtree := Model.DuplicateSubtree(SelectedNode);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(lSubtree);
end;

method CtrlFormModel.ItemToolAddChild_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and Model.CanAddInputTo(SelectedNode)) then
    exit;
  if Model.Settings.Warnings then
    begin
     var lFunct := Model.AddInputToDeletes(SelectedNode);
     if lFunct <> nil then
       if MessageBox.Show(String.Format(DexiString.SDexiAddBasic, SelectedNode:Name),
         "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
         exit;
    end;
  var lNewAtt := Model.AddInputTo(SelectedNode);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(nil);
  TreeViewModel.Expand(SelectedNode);
  UpdateAfterRestructure(lNewAtt);
  fAttInserted := true;
end;

method CtrlFormModel.ItemToolMoveDown_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and Model.CanMoveNext(SelectedNode)) then
    exit;
  Model.MoveNext(SelectedNode);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(SelectedNode);
end;

method CtrlFormModel.ItemToolMoveUp_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and Model.CanMovePrev(SelectedNode)) then
    exit;
  Model.MovePrev(SelectedNode);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(SelectedNode);
end;

method CtrlFormModel.ItemMenuDeleteScale_Click(sender: System.Object; e: System.EventArgs);
begin
  if (SelectedNode = nil) or (SelectedNode.Scale = nil) then
    exit;
  if Model.Settings.Warnings then
    begin
      var lFunct := Model.DeleteScaleDeletes(SelectedNode);
      if lFunct <> nil then
        begin
          var lMsg :=
            case lFunct.Count of
              1: String.Format(DexiString.SDexiDelScaleFunction, SelectedNode.Name, lFunct[0].Str);
              2: String.Format(DexiString.SDexiDelScaleFunctions, SelectedNode.Name, lFunct[0].Str, lFunct[1].Str);
              else '';
            end;
         if MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
           exit;
        end;
    end;
  if SelectedNode.Parent <> nil then
    SelectedNode.Parent.Funct := nil;
  SelectedNode.Funct := nil;
  SelectedNode.Scale := nil;
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  TreeViewModel.RefreshObject(SelectedNode:Parent);
  TreeViewModel.RefreshObject(SelectedNode);
  SelectionChanged;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuReverseScale_Click(sender: System.Object; e: System.EventArgs);
begin
  if (SelectedNode = nil) or (SelectedNode.Scale = nil) or (SelectedNode.Scale.Order = DexiOrder.None) then
    exit;
  if Model.Settings.Warnings then
    begin
      var lFunct := Model.ReverseScaleAffects(SelectedNode);
      if lFunct <> nil then
        begin
          var lMsg :=
            case lFunct.Count of
              1: String.Format(DexiString.SDexiReverseScaleFunction, SelectedNode.Name, lFunct[0].Str);
              2: String.Format(DexiString.SDexiReverseScaleFunctions, SelectedNode.Name, lFunct[0].Str, lFunct[1].Str);
              else '';
            end;
         if MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
           exit;
        end;
    end;
  SelectedNode.Scale.Reverse;
  if SelectedNode.Funct <> nil then
    SelectedNode.Funct.ReverseClass;
  var lParentNode := SelectedNode.Parent;
  var lParentFunct := lParentNode:Funct;
  if lParentFunct <> nil then
    if lParentFunct is DexiTabularFunction then
      DexiTabularFunction(lParentFunct).ReverseAttr(lParentNode.InpIndex(SelectedNode));
  SelectedNode.ReverseAltValues;
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  TreeViewModel.RefreshObject(SelectedNode);
  SelectionChanged;
  UpdateForm;
end;

method CtrlFormModel.ItemMenuEditFunction_Click(sender: System.Object; e: System.EventArgs);
begin
  if (SelectedNode = nil) or (SelectedNode:Scale = nil) then
    exit;
  var lFunct := SelectedNode:Funct;
  if lFunct = nil then
    if DexiTabularFunction.CanCreateOn(SelectedNode) then
      lFunct := new DexiTabularFunction(SelectedNode, Rounding := -1)
    else if DexiDiscretizeFunction.CanCreateOn(SelectedNode) then
      begin
        lFunct := new DexiDiscretizeFunction(SelectedNode);
        DexiDiscretizeFunction(lFunct).AdaptIntervalsToInputScale;
      end
    else
      exit;
  if lFunct is DexiTabularFunction then
    using lForm := new FormFunctEditTabular do
      begin
        var lEditFunct := DexiTabularFunction(lFunct).CopyFunction;
        lForm.SetForm(Model, SelectedNode, lEditFunct);
        lForm.FormatForm(lFunct);
        if lForm.ShowDialog = DialogResult.OK then
          begin
            if lForm.Funct <> nil then
              begin
                SelectedNode.Funct := lForm.Funct;
                lForm.SaveFormFormat(lFunct, lForm.Funct);
              end;
            Model.Modify;
            SaveState;
            SelectionChanged;
            UpdateForm;
          end;
      end
  else if lFunct is DexiDiscretizeFunction then
    using lForm := new FormFunctEditDiscretize do
      begin
        var lEditFunct := DexiDiscretizeFunction(lFunct).CopyFunction;
        lForm.SetForm(Model, SelectedNode, lEditFunct);
        if lForm.ShowDialog = DialogResult.OK then
          begin
            if lForm.Funct <> nil then
              SelectedNode.Funct := lForm.Funct;
            Model.Modify;
            SaveState;
            SelectionChanged;
            UpdateForm;
          end;
      end;
end;

method CtrlFormModel.ItemMenuDeleteFunction_Click(sender: System.Object; e: System.EventArgs);
begin
  if (SelectedNode = nil) or (SelectedNode.Funct = nil) then
    exit;
  SelectedNode.Funct := nil;
  Model.Modify;
  SaveState;
  TreeViewModel.RefreshObject(SelectedNode);
  SelectionChanged;
  UpdateForm;
end;

method CtrlFormModel.ItemToolCopy_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and CanCopySubtree(SelectedNode)) then
    exit;
  CopySubtree(SelectedNode);
end;

method CtrlFormModel.ItemToolCut_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and CanCutSubtree(SelectedNode)) then
    exit;
  if Model.Settings.Warnings then
    begin
      var lMsg := String.Format(DexiString.SDexiCutAtt, SelectedNode.Name);
      var lFunct := CutSubtreeDeletes(SelectedNode);
      if lFunct <> nil then
        lMsg := lMsg + Environment.LineBreak + String.Format(DexiString.SDexiDeletingAttFunction, SelectedNode:Parent:Name);
      if MessageBox.Show(lMsg, "Confirm", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question) <> DialogResult.Yes then
        exit;
    end;
  CopySubtree(SelectedNode);
  var lParent := SelectedNode.Parent;
  lParent.DeleteInput(SelectedNode);
  lParent.Funct := nil;
  if lParent.InpCount = 0 then
    TreeViewModel.Collapse(lParent);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(lParent);
end;

method CtrlFormModel.ItemToolPaste_Click(sender: System.Object; e: System.EventArgs);
begin
  if not (Visible and CanPasteSubtree(SelectedNode)) then
    exit;
  var lSubtree: DexiAttribute := nil;
  if CanPasteFromClipboard then
    begin
      var lList := new List<String>;
      lList.Add(Clipboard.GetText);
     lSubtree := Model.LoadFromStringList(lList);
    end
  else if CanPasteFromApp then
    lSubtree := Model.CloneSubtree(AppData.SubtreeCopy);
  if lSubtree = nil then
    exit;
  DexiAttribute.ReplaceAttribute(SelectedNode, lSubtree);
  Model.LinkAttributes;
  Model.Modify;
  SaveState;
  UpdateAfterRestructure(lSubtree);
end;

method CtrlFormModel.ItemMenuResizeColumns_Click(sender: System.Object; e: System.EventArgs);
begin
  ResizeColumns;
end;

end.