// CtrlFormFunctChart.pas is part of
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
// CtrlFormFunctChart.pas implements a 'CtrlForm' for diplaying DEXi tabular functions
// in three dimensions.
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

type
  /// <summary>
  /// Summary description for CtrlFormFunct.
  /// </summary>
  CtrlFormFunctChart = public partial class(CtrlForm)
  private
    method ChkLinear_CheckedChanged(sender: System.Object; e: System.EventArgs);
    method ItemMenuAddReport_Click(sender: System.Object; e: System.EventArgs);
    method BtnValFont_Click(sender: System.Object; e: System.EventArgs);
    method BtnAttFont_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewResetRotation_Click(sender: System.Object; e: System.EventArgs);
    method ChartPicture_MouseUp(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ChartPicture_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method EditChart_ValueChanged(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewNext_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewPrev_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuViewFirst_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyMetafile_Click(sender: System.Object; e: System.EventArgs);
    method ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
    method CtrlFormFunct_Resize(sender: System.Object; e: System.EventArgs);
    method CtrlFormFunct_VisibleChanged(sender: System.Object; e: System.EventArgs);
    fModel: DexiModel;
    fAttribute: DexiAttribute;
    fFunct: DexiTabularFunction;
    fChartParameters: DexiFunct3DChartParameters;
    fDimList: List<CtrlDimItem>;
    fChart: DexiFunct3DChart;
    fUpdateLevel := 0;
    fMouseDown: Point;
    const MinMouseMove = 5;
  protected
    class const NodeFormatClasses = ['', 'all', 'aggregate', 'basic', 'discrete', 'continuous', 'link', 'root', 'pruned'];
    method Dispose(disposing: Boolean); override;
    method DimListCount: Integer;
    method PrepareDimList;
    method UpdateDimList;
    method UpdateForm;
    method ReDraw(aRestructure: Boolean := true);
    method ParametersToData;
    method DataToParameters;
    method OnDirectionClick(sender: System.Object; e: System.EventArgs);
    method OnCheckClick(sender: System.Object; e: System.EventArgs);
    method OnRadioClick(sender: System.Object; e: System.EventArgs);
    method OnTextClick(sender: System.Object; e: System.EventArgs);
  public
    constructor;
    method SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction);
    method Init;
    method DoEnter;
    property Model: DexiModel read fModel;
    property Attribute: DexiAttribute read fAttribute;
    property Funct: DexiTabularFunction read fFunct;
    property ChartParameters: DexiFunct3DChartParameters read fChartParameters;
    property Chartable: Boolean read (fChartParameters.Att1Idx >= 0) and (fChartParameters.Att2Idx >= 0);
  end;

implementation

{$REGION Construction and Disposition}
constructor CtrlFormFunctChart;
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
  ChartPicture.Dock := DockStyle.Fill;
  LblMessage.Dock := DockStyle.Fill;
  fDimList := new List<CtrlDimItem>;
end;

method CtrlFormFunctChart.Dispose(disposing: Boolean);
begin
  if disposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
//    GraphicsUtils.SetShapePicture(PicNode, nil);

  end;
  inherited Dispose(disposing);
end;
{$ENDREGION}

method CtrlFormFunctChart.SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction);
require
  aModel <> nil;
  aAttribute <> nil;
  aFunct <> nil;
begin
  fModel := aModel;
  fAttribute := aAttribute;
  fFunct := aFunct;
  fChartParameters := new DexiFunct3DChartParameters(fAttribute.Dimension);
  ChkLinear.Enabled := fFunct.CanUseWeights;
  ChkMultilinear.Enabled := fFunct.CanUseMultilinear;
  ChkQQ.Enabled := fFunct.CanUseWeights;
  UpdateDimList;
  ParametersToData;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.DimListCount: Integer;
begin
  result := 1; // output attribute
  var lDimension := fChartParameters.Dimension;
  for i := low(lDimension) to high(lDimension) do
    begin
      inc(result); // input attribute
      if (i <> fChartParameters.Att1Idx) and (i <> fChartParameters.Att2Idx) then // values
        result := result + lDimension[i];
    end;
end;

method CtrlFormFunctChart.PrepareDimList;
begin
  var lListCount := DimListCount;
  if fDimList.Count = lListCount then
    exit;
  PanelDimControl.SuspendLayout;
  while fDimList.Count < lListCount do
    begin
      var lDimItem := new CtrlDimItem;
      fDimList.Add(lDimItem);
      PanelDimControl.Controls.Add(lDimItem);
      lDimItem.Dock := DockStyle.Top;
      lDimItem.DirectionClick += new EventHandler(OnDirectionClick);
      lDimItem.CheckClick += new EventHandler(OnCheckClick);
      lDimItem.RadioClick += new EventHandler(OnRadioClick);
      lDimItem.TextClick += new EventHandler(OnTextClick);
    end;
  while fDimList.Count > lListCount do
    begin
      var lCtrl := fDimList.Last;
      PanelDimControl.Controls.Remove(lCtrl);
      fDimList.Remove(lCtrl);
    end;
  PanelDimControl.ResumeLayout;
end;

method CtrlFormFunctChart.UpdateDimList;
var lDimIdx: Integer;

  method Configure(aText: String; aAttIndex, aArgIndex, aValIndex: Integer; aChecked, aReversed: Boolean);
  begin
    var lCtrl := fDimList[fDimList.Count - 1 - lDimIdx];
    lCtrl.Configure(aText, aAttIndex, aArgIndex, aValIndex, aChecked, aReversed);
    inc(lDimIdx);
  end;

begin
  PrepareDimList;
  lDimIdx := 0;
  Configure(fAttribute.Name, -1, 0, -1, false, fChartParameters.Rev0);
  var lDimension := fChartParameters.Dimension;
  var lMatch := fChartParameters.Match;
  for i := low(lDimension) to high(lDimension) do
    begin
      var lArgIndex :=
        if i = fChartParameters.Att1Idx then 1
        else if i = fChartParameters.Att2Idx then 2
        else 0;
      Configure(fAttribute.Inputs[i].Name, i, lArgIndex, -1, lArgIndex > 0, fChartParameters.Reversed[i]);
      if lArgIndex = 0 then
        for v := 0 to lDimension[i] - 1 do
          Configure(DexiDiscreteScale(fAttribute.Inputs[i].Scale).Names[v], i, 0, v, v = lMatch[i], false);
    end;
end;

method CtrlFormFunctChart.ParametersToData;
begin
  inc(fUpdateLevel);
  try
    if fChartParameters.HorizontalRotation < 0 then fChartParameters.HorizontalRotation := 0
    else if fChartParameters.HorizontalRotation > 359 then fChartParameters.HorizontalRotation := 359;
    if fChartParameters.VerticalRotation < 0 then fChartParameters.VerticalRotation := 0
    else if fChartParameters.VerticalRotation > 90 then fChartParameters.VerticalRotation := 90;
    EditHorizontal.Value := Math.Round(fChartParameters.HorizontalRotation);
    EditVertical.Value := Math.Round(fChartParameters.VerticalRotation);
    EditBorderTop.Value := fChartParameters.Border.Top;
    EditBorderBottom.Value := fChartParameters.Border.Bottom;
    EditBorderLeft.Value := fChartParameters.Border.Left;
    EditBorderRight.Value := fChartParameters.Border.Right;
    ChkLinear.Checked := fChartParameters.OverlayLinear;
    ChkMultilinear.Checked := fChartParameters.OverlayMultilinear;
    ChkQQ.Checked := fChartParameters.OverlayQQ;
    ChkQQ2.Checked := fChartParameters.OverlayQQ2;
  finally
    dec(fUpdateLevel);
  end;
end;

method CtrlFormFunctChart.DataToParameters;
begin
  if fUpdateLevel > 0 then
    exit;
  fChartParameters.HorizontalRotation := Float(EditHorizontal.Value);
  fChartParameters.VerticalRotation := Float(EditVertical.Value);
  fChartParameters.Border.Left := Integer(EditBorderLeft.Value);
  fChartParameters.Border.Right := Integer(EditBorderRight.Value);
  fChartParameters.Border.Top := Integer(EditBorderTop.Value);
  fChartParameters.Border.Bottom := Integer(EditBorderBottom.Value);
  fChartParameters.OverlayLinear := ChkLinear.Checked;
  fChartParameters.OverlayMultilinear := ChkMultilinear.Checked;
  fChartParameters.OverlayQQ := ChkQQ.Checked;
  fChartParameters.OverlayQQ2 := ChkQQ2.Checked;
  ReDraw;
  Model.Modified := true;
  UpdateForm;
end;

method CtrlFormFunctChart.Init;
begin
  UpdateForm;
end;

method CtrlFormFunctChart.DoEnter;
begin
  if fModel = nil then
    exit;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.UpdateForm;
begin
  if (fModel = nil) or (fAttribute = nil) or (fFunct = nil) then
    exit;
  var lChartable := Chartable;
  AppUtils.Enable(lChartable, [ItemMenuSave, ItemToolSave, ItemMenuAddReport,
    ItemToolCopy, ItemMenuCopyMetafile, ItemMenuCopyBitmap, ItemPopCopyMetafile, ItemPopCopyBitmap, ItemMenuViewReports]);
  AppUtils.Enable(lChartable and (fAttribute.InpCount > 2),
    [ItemMenuToolFirst, ItemMenuToolPrev, ItemMenuToolNext, ItemMenuViewFirst, ItemMenuViewPrev, ItemMenuViewNext]);
end;

method CtrlFormFunctChart.ReDraw(aRestructure: Boolean := true);
begin
  if fChartParameters = nil then
    exit;
  var lChartable := Chartable;
  ChartPicture.Visible := lChartable;
  LblMessage.Visible := not lChartable;
  fChart := nil;
  if not Chartable then
    exit;
  fChart := new DexiFunct3DChart(ChartPicture.Width, ChartPicture.Height, fModel, fAttribute, fFunct, fChartParameters);
  fChart.Border := new ImgBorder(fChartParameters.Border);
  GraphicsUtils.SetShapePicture(ChartPicture, fChart.MakeMetafile);
end;

method CtrlFormFunctChart.CtrlFormFunct_VisibleChanged(sender: System.Object; e: System.EventArgs);
begin
  DoEnter;
end;

method CtrlFormFunctChart.CtrlFormFunct_Resize(sender: System.Object; e: System.EventArgs);
begin
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.ItemMenuCopyBitmap_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Chartable or (fChart = nil) then
    exit;
  using lBitmap := fChart.MakeBitmap do
    Clipboard.SetImage(lBitmap);
end;

method CtrlFormFunctChart.ItemMenuCopyMetafile_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Chartable or (fChart = nil) then
    exit;
  using lMetafile := fChart.MakeMetafile do
    ClipboardMetafileHelper.PutEnhMetafileOnClipboard(Handle, lMetafile);
end;

method CtrlFormFunctChart.ItemToolSave_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Chartable or (fChart = nil) then
    exit;
  if SaveChartDialog.ShowDialog = DialogResult.OK then
    begin
      var lFileName := SaveChartDialog.FileName;
      case SaveChartDialog.FilterIndex of
        1: // metafile
          begin
            var lData := fChart.MakeMetafileData;
            File.WriteBytes(lFileName, lData);
          end;
        2: // bitmap
          using lBitmap := fChart.MakeBitmap do
            lBitmap.Save(lFileName, ImageFormat.Png);
      end;
    end;
end;

method CtrlFormFunctChart.OnDirectionClick(sender: System.Object; e: System.EventArgs);
begin
  var lCtrl := sender as CtrlDimItem;
  if lCtrl.AttIndex < 0 then
    fChartParameters.Rev0 := not fChartParameters.Rev0
  else
    fChartParameters.Reversed[lCtrl.AttIndex] := not fChartParameters.Reversed[lCtrl.AttIndex];
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.OnCheckClick(sender: System.Object; e: System.EventArgs);
begin
  var lCtrl := sender as CtrlDimItem;
  if lCtrl.Checked then // uncheck
    begin
      if lCtrl.AttIndex = fChartParameters.Att1Idx then
        begin
          fChartParameters.Att1Idx := -1;
          fChartParameters.ExchangeArguments;
        end
      else if lCtrl.AttIndex = fChartParameters.Att2Idx then
        fChartParameters.Att2Idx := -1
      else
        exit;
    end
  else // check
    begin
      if fChartParameters.Att1Idx < 0 then
        fChartParameters.Att1Idx := lCtrl.AttIndex
      else
        fChartParameters.Att2Idx := lCtrl.AttIndex;
    end;
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.OnRadioClick(sender: System.Object; e: System.EventArgs);
begin
  var lCtrl := sender as CtrlDimItem;
  fChartParameters.Match[lCtrl.AttIndex] := lCtrl.ValIndex;
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.OnTextClick(sender: System.Object; e: System.EventArgs);
begin
  var lCtrl := sender as CtrlDimItem;
  if lCtrl.ValIndex >= 0 then
    OnRadioClick(sender, e)
  else if lCtrl.AttIndex = fChartParameters.Att2Idx then
    fChartParameters.ExchangeArguments
  else
    exit;
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.ItemMenuViewFirst_Click(sender: System.Object; e: System.EventArgs);
begin
  fChartParameters.ResetMatch;
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.ItemMenuViewPrev_Click(sender: System.Object; e: System.EventArgs);
begin
  fChartParameters.PrevChart;
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.ItemMenuViewNext_Click(sender: System.Object; e: System.EventArgs);
begin
  fChartParameters.NextChart;
  UpdateDimList;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.EditChart_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  Model.Modified := true;
  DataToParameters;
end;

method CtrlFormFunctChart.ChartPicture_MouseDown(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  fMouseDown := new Point(e.Location.X, e.Location.Y);
end;

method CtrlFormFunctChart.ChartPicture_MouseUp(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  var fMouseUp := new Point(e.Location.X, e.Location.Y);
  var lHDiff := fMouseUp.X - fMouseDown.X;
  var lVDiff := fMouseUp.Y - fMouseDown.Y;
  var lAbsHDiff := Math.Abs(lHDiff);
  var lAbsVDiff := Math.Abs(lVDiff);
  if (lAbsHDiff < MinMouseMove) and (lAbsVDiff < MinMouseMove) then
    exit;
  if lAbsHDiff > lAbsVDiff then // rotate horizontally
    begin
      var lMove := 90.0 * lHDiff / ChartPanel.Width;
      fChartParameters.HorizontalRotation := fChartParameters.HorizontalRotation + Math.Round(lMove);
    end
  else // rotate vertically;
    begin
      var lMove := 90.0 * lVDiff / ChartPanel.Height;
      fChartParameters.VerticalRotation := fChartParameters.VerticalRotation + Math.Round(lMove);
    end;
  ParametersToData;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.ItemMenuViewResetRotation_Click(sender: System.Object; e: System.EventArgs);
begin
  fChartParameters.ResetRotation;
  ParametersToData;
  ReDraw;
  UpdateForm;
end;

method CtrlFormFunctChart.BtnAttFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fChartParameters.AttFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.AttFont := DlgFont.Font;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormFunctChart.BtnValFont_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgFont.Font := fChartParameters.ValFont;
  if DlgFont.ShowDialog = DialogResult.OK then
    begin
      fChartParameters.ValFont := DlgFont.Font;
      EditChart_ValueChanged(sender, e);
    end;
end;

method CtrlFormFunctChart.ItemMenuAddReport_Click(sender: System.Object; e: System.EventArgs);
begin
  if not Chartable then exit;
  MessageBox.Show('Not implemented yet, sorry');
end;

method CtrlFormFunctChart.ChkLinear_CheckedChanged(sender: System.Object; e: System.EventArgs);
begin
  DataToParameters;
end;

end.