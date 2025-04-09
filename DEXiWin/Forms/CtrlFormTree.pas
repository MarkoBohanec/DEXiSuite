// CtrlFormTree.pas is part of
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
// CtrlFormTree.pas implements a 'CtrlForm' for displaying trees of attributes produced
// by DexiTreeDraw.pas.
// ----------

namespace DexiWin;

interface

uses
  System.IO,
  System.Drawing,
  System.Drawing.Imaging,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel,
  RemObjects.Elements.RTL,
  DexiUtils,
  DexiLibrary;

// TODO:
// Add tree to reports as a graphic
// Saving/loading trees as part of model XML

type
  /// <summary>
  /// Summary description for CtrlFormTree.
  /// </summary>
  CtrlFormTree = public partial class(CtrlForm)
  private
    method ItemMenuAddReport_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopPageWidth_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopFullPage_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopActualSize_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyMetafile_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
    method BtnTextFont_Click(sender: System.Object; e: System.EventArgs);
    method BtnFontColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnResetFormat_Click(sender: System.Object; e: System.EventArgs);
    method BtnShape_Click(sender: System.Object; e: System.EventArgs);
    method LblPos_Click(sender: System.Object; e: System.EventArgs);
    method EditFormat_ValueChanged(sender: System.Object; e: System.EventArgs);
    method EditNodeFormat_DrawItem(sender: System.Object; e: System.Windows.Forms.DrawItemEventArgs);
    method EditNodeFormat_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method EditNodeFormat_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
    method BtnExpand_Click(sender: System.Object; e: System.EventArgs);
    method BtnCollapse_Click(sender: System.Object; e: System.EventArgs);
    method BtnBackgroundColor_Click(sender: System.Object; e: System.EventArgs);
    method EditTree_ValueChanged(sender: System.Object; e: System.EventArgs);
    method TreePicture_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method CtrlFormTree_Resize(sender: System.Object; e: System.EventArgs);
    method ItemToolZoom_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
    method ItemToolAlgorithm_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
    method ItemToolDirection_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
    method CtrlFormTree_VisibleChanged(sender: System.Object; e: System.EventArgs);
    fModel: DexiModel;
    fModelStatistics: DexiModelStatistics;
    fSelectedFormat: TreeNodeFormat;
    fSelectedFormatIndex: Integer;
    fLastSelectedFormatIndex: Integer;
    fDrawing: DexiTreeDrawingAlgorithm;
    fZoomMode: PreviewZoomMode;
    fZoom: Float;
    fZoomFactor: Float;
    fTextPosIndex: Integer;
    fTextPosLabels: array of System.Windows.Forms.Label;
    fUpdateLevel := 0;
  protected
    class const NodeFormatClasses = ['', 'all', 'aggregate', 'basic', 'discrete', 'continuous', 'link', 'root', 'pruned'];
    method Dispose(disposing: Boolean); override;
    method SetModel(aModel: DexiModel);
    method SetZoomMode(aZoomMode: PreviewZoomMode);
    method SetZoom(aZoom: Float);
    method UpdateForm;
    method ReDraw(aRestructure: Boolean := true);
    method ZoomChanged;
    method DrawingToData;
    method DataToDrawing;
    method CanCollapseAnySelected: Boolean;
    method CanExpandAnySelected: Boolean;
    method CollapseSelected;
    method ExpandSelected;
    method NodeFormatClassEnabled(aIdx: Integer): Boolean;
    method SelectFirstEnabledFormat;
    method UpdateNodeFormat;
    method SelectFormat(lIdx: Integer);
    method FormatToData;
    method DataToFormat;
    method UpdatePosLabels;
    method OnMouseWheel(e: MouseEventArgs); override;
  public
    constructor;
    method Init;
    method DoEnter;
    property Model: DexiModel read fModel write SetModel;
    property ZoomMode: PreviewZoomMode read fZoomMode write SetZoomMode;
    property Zoom: Float read fZoom write SetZoom;
  end;

type ZoomablePanel = public class (Panel)
protected
    method OnMouseWheel(e: MouseEventArgs); override;
end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormTree;
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
  AutoScroll := false;
  AutoScroll := true;
  fTextPosLabels := [LblTL, LblTC, LblTR, LblML, LblMC, LblMR, LblBL, LblBC, LblBR];
end;

method CtrlFormTree.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    GraphicsUtils.SetShapePicture(PicNode, nil);
  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlFormTree.SetModel(aModel: DexiModel);
begin
  if aModel = nil then
    exit;
  fModel := aModel;
  var lModelForm := AppUtils.ModelForm(fModel);
  fDrawing :=
    if (fModel = nil) or (lModelForm = nil) then nil
    else lModelForm.DrawingAlgorithm;
  DrawingToData;
  SetZoomMode(PreviewZoomMode.FullPage);
  ZoomChanged;
  UpdateForm;
end;

method CtrlFormTree.SetZoomMode(aZoomMode: PreviewZoomMode);
begin
  if aZoomMode <> fZoomMode then
    fZoomMode := aZoomMode;
end;

method CtrlFormTree.SetZoom(aZoom: Float);
begin
  if (aZoom <> fZoom) or (fZoomMode <> PreviewZoomMode.Custom) then
    begin
      fZoomMode := PreviewZoomMode.Custom;
      fZoom := aZoom;
    end;
end;

method CtrlFormTree.ZoomChanged;
begin
  if (fDrawing = nil) or (fUpdateLevel > 0) then
    exit;
  var lWidth := fDrawing.BoxWidth;
  var lHeight := fDrawing.BoxHeight;
  case fZoomMode of
    PreviewZoomMode.ActualSize:
      fZoomFactor := 1.0;
    PreviewZoomMode.FullPage:
      begin
        var lHFact := Float(TreePanel.Width) / lWidth;
        var lVFact := Float(TreePanel.Height) / lHeight;
        fZoomFactor := Math.Min(lHFact, lVFact);
      end;
    PreviewZoomMode.PageWidth:
      fZoomFactor := Float(TreePanel.Width) / lWidth;
    else
      fZoomFactor := fZoom;
  end;
  var nWidth := Math.Round(fZoomFactor * lWidth);
  var nHeight := Math.Round(fZoomFactor * lHeight);
  TreePicture.Width := nWidth;
  TreePicture.Height := nHeight;
end;

method CtrlFormTree.DrawingToData;
begin
  TabTree.Enabled := fDrawing <> nil;
  if fDrawing = nil then
    exit;
  inc(fUpdateLevel);
  try
    EditStretchX.Value := Math.Round(100 * fDrawing.XStretch);
    EditStretchY.Value := Math.Round(100 * fDrawing.YStretch);
    EditBorderTop.Value := fDrawing.Border.Top;
    EditBorderBottom.Value := fDrawing.Border.Bottom;
    EditBorderLeft.Value := fDrawing.Border.Left;
    EditBorderRight.Value := fDrawing.Border.Right;
    EditNodeSep.Value := Math.Round(fDrawing.NodeSeparation);
    EditLevelSep.Value := Math.Round(fDrawing.LevelSeparation);
    EditMinLevelSep.Value := Math.Round(fDrawing.MinLevelSeparation);
    ChkMirror.Checked := fDrawing.XMirror;
    ChkAlignLevels.Checked := fDrawing.AlignLevels;
    ChkAlignParents.Checked := fDrawing.AlignParents = TreeAlignParents.Subtree;
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlFormTree.DataToDrawing;
begin
  if fUpdateLevel > 0 then
    exit;
  fDrawing.XStretch := Float(EditStretchX.Value) / 100.0;
  fDrawing.YStretch := Float(EditStretchY.Value) / 100.0;
  fDrawing.Border.Left := Integer(EditBorderLeft.Value);
  fDrawing.Border.Right := Integer(EditBorderRight.Value);
  fDrawing.Border.Top := Integer(EditBorderTop.Value);
  fDrawing.Border.Bottom := Integer(EditBorderBottom.Value);
  fDrawing.NodeSeparation := Float(EditNodeSep.Value);
  fDrawing.LevelSeparation := Float(EditLevelSep.Value);
  fDrawing.MinLevelSeparation := Float(EditMinLevelSep.Value);
  fDrawing.XMirror := ChkMirror.Checked;
  fDrawing.AlignLevels := ChkAlignLevels.Checked;
  fDrawing.AlignParents := if ChkAlignParents.Checked then TreeAlignParents.Subtree else TreeAlignParents.Descendants;
  ReDraw;
  Model.Modified := true;
end;

method CtrlFormTree.CanCollapseAnySelected: Boolean;
begin
  result := false;
  for each lAtt in fDrawing.SelectedAttributes do
    if (lAtt.InpCount > 0) and not fDrawing.PrunedAttributes.Contains(lAtt) then
      exit true;
end;

method CtrlFormTree.CanExpandAnySelected: Boolean;
begin
  result := false;
  for each lAtt in fDrawing.SelectedAttributes do
    if fDrawing.PrunedAttributes.Contains(lAtt) then
      exit true;
end;

method CtrlFormTree.CollapseSelected;
begin
  for each lAtt in fDrawing.SelectedAttributes do
    if (lAtt.InpCount > 0) and not fDrawing.PrunedAttributes.Contains(lAtt) then
      fDrawing.PrunedAttributes.Add(lAtt);
end;

method CtrlFormTree.ExpandSelected;
begin
  for each lAtt in fDrawing.SelectedAttributes do
    if fDrawing.PrunedAttributes.Contains(lAtt) then
      fDrawing.PrunedAttributes.Remove(lAtt);
end;

method CtrlFormTree.Init;
begin
  UpdateForm;
end;

method CtrlFormTree.DoEnter;
begin
  if fModel = nil then
    exit;
  fModelStatistics := fModel.Statistics;
  SelectFirstEnabledFormat;
  EditNodeFormat.SelectedIndex := fSelectedFormatIndex;
  ReDraw;
  UpdateForm;
end;

method CtrlFormTree.UpdateForm;
begin
  AppUtils.Enable(fDrawing <> nil, ItemMenuAddReport);
  if fDrawing = nil then exit;
  ItemToolDirection.Image :=
    case fDrawing.Orientation of
      TreeOrientation.TopDown:    ItemToolDirTopDown.Image;
      TreeOrientation.LeftRight:  ItemToolDirLeftRight.Image;
      TreeOrientation.BottomUp:   ItemToolDirBottomUp.Image;
      TreeOrientation.RightLeft:  ItemToolDirRightLeft.Image;
    end;
  ItemToolAlgorithm.Image :=
    case fDrawing.DrawMethod of
      TreeDrawMethod.BottomUp: if fDrawing.AlignTerminals then ItemToolAlgAlign.Image else ItemToolAlgDistribute.Image;
      TreeDrawMethod.Walker:   ItemToolAlgWalker.Image;
      TreeDrawMethod.QP:       ItemToolAlgQP.Image;
    end;
  AppUtils.Enable(CanCollapseAnySelected, BtnCollapse);
  AppUtils.Enable(CanExpandAnySelected, BtnExpand);
  AppUtils.Enable(ChkTrim.Checked, EditTrim);
end;

method CtrlFormTree.ReDraw(aRestructure: Boolean := true);
begin
  if fDrawing = nil then
    exit;
  if aRestructure then
    fDrawing.Restructure;
  TreePicture.Image := fDrawing.MakeMetafile;
  ZoomChanged;
end;

method CtrlFormTree.CtrlFormTree_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  DoEnter;
end;

method CtrlFormTree.ItemToolDirection_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
begin
  if (fUpdateLevel > 0) or (fDrawing = nil) then
    exit;
  if e.ClickedItem = ItemToolDirLeftRight then
    fDrawing.Orientation := TreeOrientation.LeftRight
  else if e.ClickedItem = ItemToolDirTopDown then
    fDrawing.Orientation := TreeOrientation.TopDown
  else if e.ClickedItem = ItemToolDirRightLeft then
    fDrawing.Orientation := TreeOrientation.RightLeft
  else if e.ClickedItem = ItemToolDirBottomUp then
    fDrawing.Orientation := TreeOrientation.BottomUp;
  ReDraw;
  UpdateForm;
end;

method CtrlFormTree.ItemToolAlgorithm_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
begin
  if (fUpdateLevel > 0) or (fDrawing = nil) then
    exit;
  fDrawing.AlignTerminals := false;
  if e.ClickedItem = ItemToolAlgDistribute then
    fDrawing.DrawMethod := TreeDrawMethod.BottomUp
  else if e.ClickedItem = ItemToolAlgAlign then
    begin
      fDrawing.DrawMethod := TreeDrawMethod.BottomUp;
      fDrawing.AlignTerminals := true;
    end
  else if e.ClickedItem = ItemToolAlgWalker then
    fDrawing.DrawMethod := TreeDrawMethod.Walker
  else if e.ClickedItem = ItemToolAlgQP then
    fDrawing.DrawMethod := TreeDrawMethod.QP;
  ReDraw;
  UpdateForm;
end;

method CtrlFormTree.ItemToolZoom_DropDownItemClicked(sender: System.Object; e: System.Windows.Forms.ToolStripItemClickedEventArgs);
begin
  if (fUpdateLevel > 0) or (fDrawing = nil) then
    exit;
  if (e.ClickedItem = ItemToolZoomActualSize) or (e.ClickedItem = ItemMenuZoomActualSize) then
    ZoomMode := PreviewZoomMode.ActualSize
  else if (e.ClickedItem = ItemToolZoomFullPage) or (e.ClickedItem = ItemMenuZoomFullPage) then
    ZoomMode := PreviewZoomMode.FullPage
  else if (e.ClickedItem = ItemToolZoomPageWidth) or (e.ClickedItem = ItemMenuZoomPageWidth) then
    ZoomMode := PreviewZoomMode.PageWidth
  else if (e.ClickedItem = ItemToolZoom10) or (e.ClickedItem = ItemMenuZoom10) then
    Zoom := 0.1
  else if (e.ClickedItem = ItemToolZoom25) or (e.ClickedItem = ItemMenuZoom25) then
    Zoom := 0.25
  else if (e.ClickedItem = ItemToolZoom50) or (e.ClickedItem = ItemMenuZoom50) then
    Zoom := 0.5
  else if (e.ClickedItem = ItemToolZoom75) or (e.ClickedItem = ItemMenuZoom75) then
    Zoom := 0.75
  else if (e.ClickedItem = ItemToolZoom100) or (e.ClickedItem = ItemMenuZoom100) then
    Zoom := 1.0
  else if (e.ClickedItem = ItemToolZoom150) or (e.ClickedItem = ItemMenuZoom150) then
    Zoom := 1.5
  else if (e.ClickedItem = ItemToolZoom200) or (e.ClickedItem = ItemMenuZoom200) then
    Zoom := 2.0
  else if (e.ClickedItem = ItemToolZoom500) or (e.ClickedItem = ItemMenuZoom500) then
    Zoom := 5.0;
  ZoomChanged;
  UpdateForm;
end;

method CtrlFormTree.CtrlFormTree_Resize(sender: System.Object; e: System.EventArgs);
begin
  if (ZoomMode = PreviewZoomMode.FullPage) or (ZoomMode = PreviewZoomMode.PageWidth) then
    ZoomChanged;
end;

method CtrlFormTree.TreePicture_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if fZoomFactor <= 0.0 then
    exit;
  var X := Math.Round(e.Location.X / fZoomFactor);
  var Y := Math.Round(e.Location.Y / fZoomFactor);
  var lNode := fDrawing.HitTest(X, Y) as DexiTreeDrawNode;
  if ModifierKeys.HasFlag(Keys.Control) then
    begin
      if lNode = nil then // nothing
      else if fDrawing.SelectedAttributes.Contains(lNode.Attribute) then
        fDrawing.SelectedAttributes.Remove(lNode.Attribute)
      else
        fDrawing.SelectedAttributes.Add(lNode.Attribute);
    end
  else
    begin
      fDrawing.SelectedAttributes.RemoveAll;
      if lNode <> nil then
        fDrawing.SelectedAttributes.Add(lNode.Attribute);
    end;
  ReDraw;
  if fDrawing.SelectedAttributes.Count > 0 then
    SelectFormat(0)
  else
    UpdateNodeFormat;
  FormatToData;
  EditNodeFormat.SelectedIndex := fSelectedFormatIndex;
  UpdateForm;
end;

method CtrlFormTree.EditTree_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  DataToDrawing;
end;

method CtrlFormTree.BtnBackgroundColor_Click(sender: System.Object; e: System.EventArgs);
begin
  using lColorDlg := new ColorDialog do
    begin
      lColorDlg.Color := fDrawing.BackgroundColor;
      if lColorDlg.ShowDialog = DialogResult.OK then
        begin
          fDrawing.BackgroundColor := lColorDlg.Color;
          ReDraw;
          Model.Modified := true;
        end;
    end;
end;

method CtrlFormTree.BtnCollapse_Click(sender: System.Object; e: System.EventArgs);
begin
  CollapseSelected;
  ReDraw(true);
  UpdateForm;
  UpdateNodeFormat;
end;

method CtrlFormTree.BtnExpand_Click(sender: System.Object; e: System.EventArgs);
begin
  ExpandSelected;
  ReDraw(true);
  UpdateForm;
  UpdateNodeFormat;
end;

method CtrlFormTree.NodeFormatClassEnabled(aIdx: Integer): Boolean;
begin
  result :=
    case aIdx of
      0: fDrawing.SelectedAttributes.Count > 0;
      1, 2, 3, 7: true;
      4: fModelStatistics.DiscrScales > 0;
      5: fModelStatistics.ContScales > 0;
      6: fModelStatistics.LinkedAttributes > 0;
      8: fDrawing.PrunedAttributes.Count > 0;
      else false;
    end;
end;

method CtrlFormTree.SelectFirstEnabledFormat;
begin
  for lIdx := low(NodeFormatClasses) to high(NodeFormatClasses) do
    if NodeFormatClassEnabled(lIdx) then
      begin
        SelectFormat(lIdx);
        exit;
      end;
end;

method CtrlFormTree.UpdateNodeFormat;
begin
  if not NodeFormatClassEnabled(EditNodeFormat.SelectedIndex) then
    if NodeFormatClassEnabled(fLastSelectedFormatIndex) then
      SelectFormat(fLastSelectedFormatIndex)
    else
      SelectFirstEnabledFormat;
end;

method CtrlFormTree.SelectFormat(lIdx: Integer);
begin
  if fUpdateLevel > 0 then
    exit;
  var lFmtName := NodeFormatClasses[lIdx];
  if String.IsNullOrEmpty(lFmtName) then
    begin
      fSelectedFormat := new TreeNodeFormat;
      fSelectedFormat.Assign(fDrawing.CommonFormat(fDrawing.SelectedAttributes));
    end
  else
    fSelectedFormat := fDrawing.Formats.Find(lFmtName);
  fSelectedFormatIndex := lIdx;
end;

method CtrlFormTree.EditNodeFormat_Validating(sender: System.Object; e: System.ComponentModel.CancelEventArgs);
begin
  if not NodeFormatClassEnabled(EditNodeFormat.SelectedIndex) then
    e.Cancel := true;
end;

method CtrlFormTree.EditNodeFormat_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  if not NodeFormatClassEnabled(EditNodeFormat.SelectedIndex) then
    EditNodeFormat.SelectedIndex := fLastSelectedFormatIndex
  else
    begin
      fLastSelectedFormatIndex := EditNodeFormat.SelectedIndex;
      SelectFormat(EditNodeFormat.SelectedIndex);
      FormatToData;
    end;
end;

method CtrlFormTree.EditNodeFormat_DrawItem(sender: System.Object; e: System.Windows.Forms.DrawItemEventArgs);
begin
   var lCombo := sender as ComboBox;
    if NodeFormatClassEnabled(e.Index) then
      begin
        e.DrawBackground;
        var lBrush := if e.State and DrawItemState.Selected > 0 then SystemBrushes.HighlightText else SystemBrushes.ControlText;
        e.Graphics.DrawString(lCombo.Items[e.Index].ToString, lCombo.Font, lBrush, e.Bounds);
        e.DrawFocusRectangle;
      end
    else
      begin
        e.Graphics.FillRectangle(SystemBrushes.Window, e.Bounds);
        e.Graphics.DrawString(lCombo.Items[e.Index].ToString, lCombo.Font, SystemBrushes.GrayText, e.Bounds);
      end;
end;

method CtrlFormTree.UpdatePosLabels;
begin
  for each lLbl in fTextPosLabels do
    lLbl.Text :=
      if Utils.StrToInt(lLbl.Tag.ToString) = fTextPosIndex then 'TEXT'
      else '-';
end;

method CtrlFormTree.FormatToData;
begin
  if (fSelectedFormat = nil) or (fUpdateLevel > 0) then
    exit;
  inc(fUpdateLevel);
  try
    EditMinWidth.Value := fSelectedFormat.MinWidth;
    EditMaxWidth.Value := fSelectedFormat.MaxWidth;
    EditMinHeight.Value := fSelectedFormat.MinHeight;
    EditMaxHeight.Value := fSelectedFormat.MaxHeight;
    case fSelectedFormat.NodeAlign of
      HorizontalAlignment.Left: RadTop.Checked := true;
      HorizontalAlignment.Center: RadMiddle.Checked := true;
      HorizontalAlignment.Right: RadBottom.Checked := true;
    end;
    EditTopAnchorHorizontal.Value := fSelectedFormat.UpAnchor.X;
    EditTopAnchorVertical.Value := fSelectedFormat.UpAnchor.Y;
    EditTopAnchorUnitsHorizontal.SelectedIndex := ord(fSelectedFormat.UpAnchor.UnitX);
    EditTopAnchorUnitsVertical.SelectedIndex := ord(fSelectedFormat.UpAnchor.UnitY);
    EditBottomAnchorHorizontal.Value := fSelectedFormat.DownAnchor.X;
    EditBottomAnchorVertical.Value := fSelectedFormat.DownAnchor.Y;
    EditBottomAnchorUnitsHorizontal.SelectedIndex := ord(fSelectedFormat.DownAnchor.UnitX);
    EditBottomAnchorUnitsVertical.SelectedIndex := ord(fSelectedFormat.DownAnchor.UnitY);
    EditTextBorderTop.Value := fSelectedFormat.TextBorder.Top;
    EditTextBorderBottom.Value := fSelectedFormat.TextBorder.Bottom;
    EditTextBorderLeft.Value := fSelectedFormat.TextBorder.Left;
    EditTextBorderRight.Value := fSelectedFormat.TextBorder.Right;
    ChkWrap.Checked := fSelectedFormat.TextWrap;
    ChkClip.Checked := fSelectedFormat.TextClip;
    ChkTrim.Checked := fSelectedFormat.TextTrim >= 0;
    EditTrim.Enabled := ChkTrim.Checked;
    if ChkTrim.Checked then
      EditTrim.Value := fSelectedFormat.TextTrim;
    EditLineSpace.Value := Math.Round(100 * fSelectedFormat.LineSpacing);
    fTextPosIndex := 3 * ord(fSelectedFormat.TextYAlign) + ord(fSelectedFormat.TextXAlign);
    UpdatePosLabels;
    GraphicsUtils.SetShapePicture(PicNode,
      fDrawing.ShapePicture(fSelectedFormat, new Rectangle(0, 0, PicNode.Width, PicNode.Height)));
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlFormTree.DataToFormat;

  method MakeAnchor(aHoriz, aVert: NumericUpDown; aHUnit, aVUnit: ComboBox): Anchor;
  begin
    result := new Anchor(
      Integer(aHoriz.Value), AnchorUnit(aHUnit.SelectedIndex),
      Integer(aVert.Value), AnchorUnit(aVUnit.SelectedIndex));
  end;

  method AssignSelectedFormat(aNode: DexiTreeDrawNode);
  begin
    if aNode.IsSelected then
      aNode.NodeFormat := fSelectedFormat;
    for i := 0 to aNode.Count - 1 do
      AssignSelectedFormat(aNode.Item[i] as DexiTreeDrawNode);
  end;

  method AssignFormatToSelectedNodes;
  begin
    AssignSelectedFormat(fDrawing.Root as DexiTreeDrawNode);
  end;

begin
  if (fSelectedFormat = nil) or (fUpdateLevel > 0) then
    exit;
  fSelectedFormat.MinWidth := Integer(EditMinWidth.Value);
  fSelectedFormat.MaxWidth := Integer(EditMaxWidth.Value);
  fSelectedFormat.MinHeight := Integer(EditMinHeight.Value);
  fSelectedFormat.MaxHeight := Integer(EditMaxHeight.Value);
  fSelectedFormat.NodeAlign :=
    if RadTop.Checked then HorizontalAlignment.Left
    else if RadMiddle.Checked then HorizontalAlignment.Center
    else if RadBottom.Checked then HorizontalAlignment.Right
    else HorizontalAlignment.Left;
  fSelectedFormat.UpAnchor :=
    MakeAnchor(EditTopAnchorHorizontal, EditTopAnchorVertical, EditTopAnchorUnitsHorizontal, EditTopAnchorUnitsVertical);
  fSelectedFormat.DownAnchor :=
    MakeAnchor(EditBottomAnchorHorizontal, EditBottomAnchorVertical, EditBottomAnchorUnitsHorizontal, EditBottomAnchorUnitsVertical);
  fSelectedFormat.TextBorderTop := Integer(EditTextBorderTop.Value);
  fSelectedFormat.TextBorderBottom := Integer(EditTextBorderBottom.Value);
  fSelectedFormat.TextBorderLeft := Integer(EditTextBorderLeft.Value);
  fSelectedFormat.TextBorderRight := Integer(EditTextBorderRight.Value);
  fSelectedFormat.TextWrap := ChkWrap.Checked;
  fSelectedFormat.TextClip := ChkClip.Checked;
  fSelectedFormat.TextTrim :=
    if ChkTrim.Checked then Integer(EditTrim.Value)
    else -1;
  fSelectedFormat.LineSpacing := Float(EditLineSpace.Value) / 100.0;
  var lXPosIndex := fTextPosIndex mod 3;
  var lYPosIndex := fTextPosIndex / 3;
  fSelectedFormat.TextXAlign := HorizontalAlignment(lXPosIndex);
  fSelectedFormat.TextYAlign := HorizontalAlignment(lYPosIndex);
  if (fSelectedFormatIndex = 0) and (fDrawing.SelectedAttributes.Count > 0) then
    AssignFormatToSelectedNodes;
  ReDraw;
  UpdateForm;
  Model.Modified := true;
end;

method CtrlFormTree.EditFormat_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  DataToFormat;
end;

method CtrlFormTree.LblPos_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fTextPosIndex := Utils.StrToInt(Label(sender).Tag.ToString);
  UpdatePosLabels;
  DataToFormat;
end;

method CtrlFormTree.BtnShape_Click(sender: System.Object; e: System.EventArgs);
begin
  var lForm := AppData.ShapeForm;
  lForm.SetForm(fDrawing, fSelectedFormat, EditNodeFormat.Text);
  if lForm.ShowDialog = DialogResult.OK then
    begin
      var lFormat := lForm.Format;
      fSelectedFormat.Shape := lFormat.Shape;
      fSelectedFormat.LinePen := lFormat.LinePen;
      fSelectedFormat.NodePen := lFormat.NodePen;
      fSelectedFormat.NodeBrush := lFormat.NodeBrush;
      fSelectedFormat.RoundEdge := lFormat.RoundEdge;
      FormatToData;
      DataToFormat;
    end;
end;

method CtrlFormTree.BtnResetFormat_Click(sender: System.Object; e: System.EventArgs);
begin
  fSelectedFormat.Assign(TreeNodeFormat.DefaultFormat);
  fSelectedFormat.PropagateToChildren;
  FormatToData;
  DataToFormat;
end;

method CtrlFormTree.BtnFontColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fSelectedFormat.FontBrush.Color;
  if DlgColor.ShowDialog = DialogResult.OK then
    begin
      var lBrushData := new BrushData(fSelectedFormat.FontBrush);
      lBrushData.Color := DlgColor.Color;
      fSelectedFormat.FontBrush := lBrushData;
      EditFormat_ValueChanged(sender, e);
    end;
end;

method CtrlFormTree.BtnTextFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fSelectedFormat.Font;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fSelectedFormat.Font := DlgFont.Font;
      EditFormat_ValueChanged(sender, e);
    end;
end;

method CtrlFormTree.ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
begin
  var lDrawSelected := fDrawing.DrawSelected;
  fDrawing.DrawSelected := false;
  try
    using lBitmap := fDrawing.MakeBitmap(false) do
      Clipboard.SetImage(lBitmap);
  finally
    fDrawing.DrawSelected := lDrawSelected;
  end;
end;

method CtrlFormTree.ItemMenuCopyMetafile_Click(sender: System.Object; e: System.EventArgs);
begin
  var lDrawSelected := fDrawing.DrawSelected;
  fDrawing.DrawSelected := false;
  try
    using lMetafile := fDrawing.MakeMetafile(false) do
      ClipboardMetafileHelper.PutEnhMetafileOnClipboard(Handle, lMetafile);
  finally
    fDrawing.DrawSelected := lDrawSelected;
  end;
end;

method CtrlFormTree.ItemPopActualSize_Click(sender: System.Object; e: System.EventArgs);
begin
  fZoomMode := PreviewZoomMode.ActualSize;
  ZoomChanged;
end;

method CtrlFormTree.ItemPopFullPage_Click(sender: System.Object; e: System.EventArgs);
begin
  fZoomMode := PreviewZoomMode.FullPage;
  ZoomChanged;
end;

method CtrlFormTree.ItemPopPageWidth_Click(sender: System.Object; e: System.EventArgs);
begin
  fZoomMode := PreviewZoomMode.PageWidth;
  ZoomChanged;
end;

method CtrlFormTree.OnMouseWheel(e: MouseEventArgs);
begin
  if (Control.ModifierKeys and Keys.Control) <> 0 then
    begin
      var lZoom := fZoomFactor * (if e.Delta > 0 then (1.1) else (0.9));
      SetZoom(Math.Min(5, Math.Max(0.1, lZoom)));
      ZoomChanged;
    end
  else
    inherited OnMouseWheel(e);
end;

method ZoomablePanel.OnMouseWheel(e: MouseEventArgs);
begin
  if (Control.ModifierKeys and Keys.Control) <> 0 then
    // nothing, handle event in CtrlFormTree
  else
    inherited OnMouseWheel(e);
end;

method CtrlFormTree.ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
begin
  if SaveTreeDialog.ShowDialog = DialogResult.OK then
    begin
      var lFileName := SaveTreeDialog.FileName;
      var lDrawSelected := fDrawing.DrawSelected;
      fDrawing.DrawSelected := false;
      try
        case SaveTreeDialog.FilterIndex of
          1: // metafile
            begin
              var lData := fDrawing.MakeMetafileData;
              File.WriteBytes(lFileName, lData);
            end;
          2: // bitmap
            using lBitmap := fDrawing.MakeBitmap(false) do
              lBitmap.Save(lFileName, ImageFormat.Png);
        end;
      finally
        fDrawing.DrawSelected := lDrawSelected;
      end;
    end;
end;

method CtrlFormTree.ItemMenuAddReport_Click(sender: System.Object; e: System.EventArgs);
begin
  if fDrawing = nil then exit;
  MessageBox.Show('Not implemented yet, sorry');
end;

end.