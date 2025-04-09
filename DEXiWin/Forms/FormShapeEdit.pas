// FormShapeEdit.pas is part of
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
// FormShapeEdit.pas implements a form for editing a graphic shape element.
// ----------

namespace DexiWin;

interface

uses
  System.Drawing,
  System.Drawing.Drawing2D,
  System.Collections,
  System.Collections.Generic,
  System.Linq,
  System.Windows.Forms,
  System.ComponentModel,
  RemObjects.Elements.RTL,
  DexiUtils;

type
  /// <summary>
  /// Summary description for FormShapeEdit.
  /// </summary>
  FormShapeEdit = public partial class(System.Windows.Forms.Form)
  private
    method BtnNodeLineColor_Click(sender: System.Object; e: System.EventArgs);
    method Edit_ValueChanged(sender: System.Object; e: System.EventArgs);
    method BtnHatchColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnFillColor_Click(sender: System.Object; e: System.EventArgs);
    method BtnLineColor_Click(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fFormatText: String;
    fLinePen: PenData;
    fNodePen: PenData;
    fNodeBrush: BrushData;
    fRoundEdge: Anchor;
    fDrawing: WinTreeDrawingAlgorithm;
    fFormat: TreeNodeFormat;
    fUpdateLevel := 0;
  protected
    method Dispose(aDisposing: Boolean); override;
    method FormatToData;
    method DataToFormat;
    method GetFormat: TreeNodeFormat;
    method UpdateForm;
  public
    constructor;
    method SetForm(aDrawing: WinTreeDrawingAlgorithm; aFormat: TreeNodeFormat; aFormatText: String);
    property Format: TreeNodeFormat read fFormat;
  end;

implementation

{$REGION Construction and Disposition}
constructor FormShapeEdit;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();
  fFormText := Text;
  //
  // TODO: Add any constructor code after InitializeComponent call
  //

end;

method FormShapeEdit.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    GraphicsUtils.SetShapePicture(PicNode, nil);
  end;
  inherited Dispose(aDisposing);
end;
{$ENDREGION}

method FormShapeEdit.SetForm(aDrawing: WinTreeDrawingAlgorithm; aFormat: TreeNodeFormat; aFormatText: String);
require
  aDrawing <> nil;
  aFormat <> nil;
begin
  fDrawing := aDrawing;
  fFormat := new TreeNodeFormat;
  fFormat.Assign(aFormat);
  fFormatText := aFormatText;
  fLinePen := new PenData(fFormat.LinePen);
  fNodePen := new PenData(fFormat.NodePen);
  fNodeBrush := new BrushData(fFormat.NodeBrush);
  fRoundEdge := new Anchor(fFormat.RoundEdge);
  FormatToData;
  UpdateForm;
end;

method FormShapeEdit.UpdateForm;
begin
  Text := String.Format(fFormText, fFormatText);
  DataToFormat;
  AppUtils.Enable(fFormat.Shape = ShapeType.RoundRect, GrpRounded);
  AppUtils.Enable(not fNodeBrush.IsSolid, BtnHatchColor);
  fFormat.LinePen := fLinePen;
  fFormat.NodePen := fNodePen;
  fFormat.NodeBrush := fNodeBrush;
  fFormat.RoundEdge := fRoundEdge;
  GraphicsUtils.SetShapePicture(PicNode,
    fDrawing.ShapePicture(fFormat, new Rectangle(0, 0, PicNode.Width, PicNode.Height)));
end;

method FormShapeEdit.FormatToData;
begin
  if fUpdateLevel > 0 then
    exit;
  inc(fUpdateLevel);
  try
    case fFormat.Shape of
      ShapeType.Ellipse: RadEllipse.Checked := true;
      ShapeType.RoundRect: RadRounded.Checked := true;
      else RadRectangle.Checked := true;
    end;
    EditRoundEdgeHorizontal.Value := fRoundEdge.X;
    EditRoundEdgeVertical.Value := fRoundEdge.Y;
    EditRoundEdgeUnitsHorizontal.SelectedIndex := ord(fRoundEdge.UnitX);
    EditRoundEdgeUnitsVertical.SelectedIndex := ord(fRoundEdge.UnitY);
    EditLineStyle.SelectedIndex := ord(fLinePen.DashStyle);
    EditLineWidth.Value := Math.Round(fLinePen.Width);
    EditNodeLineStyle.SelectedIndex := ord(fNodePen.DashStyle);
    EditNodeLineWidth.Value := Math.Round(fNodePen.Width);
    EditNodeFillStyle.SelectedIndex := fNodeBrush.HatchIndex + 1;
  finally
    dec(fUpdateLevel);
  end;
end;

method FormShapeEdit.DataToFormat;

  method MakeAnchor(aHoriz, aVert: NumericUpDown; aHUnit, aVUnit: ComboBox): Anchor;
  begin
    result := new Anchor(
      Integer(aHoriz.Value), AnchorUnit(aHUnit.SelectedIndex),
      Integer(aVert.Value), AnchorUnit(aVUnit.SelectedIndex));
  end;

begin
  fLinePen.Width := Integer(EditLineWidth.Value);
  fLinePen.DashStyle := DashStyle(EditLineStyle.SelectedIndex);
  fNodePen.Width := Integer(EditNodeLineWidth.Value);
  fNodePen.DashStyle := DashStyle(EditNodeLineStyle.SelectedIndex);
  fFormat.Shape :=
    if RadEllipse.Checked then ShapeType.Ellipse
    else if RadRounded.Checked then ShapeType.RoundRect
    else ShapeType.Rectangle;
  var lHatchIndex := EditNodeFillStyle.SelectedIndex - 1;
  fNodeBrush.HatchStyle :=
    if lHatchIndex < 0 then nil
    else HatchStyle(lHatchIndex);
  fRoundEdge :=
    MakeAnchor(EditRoundEdgeHorizontal, EditRoundEdgeVertical, EditRoundEdgeUnitsHorizontal, EditRoundEdgeUnitsVertical);
end;

method FormShapeEdit.GetFormat: TreeNodeFormat;
begin
  DataToFormat;
  fFormat.LinePen := fLinePen;
  fFormat.NodePen := fNodePen;
  fFormat.NodeBrush := fNodeBrush;
  fFormat.RoundEdge := fRoundEdge;
  result := fFormat;
end;

method FormShapeEdit.BtnLineColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fLinePen.Color;
  if DlgColor.ShowDialog = DialogResult.OK then
    fLinePen.Color := DlgColor.Color;
  UpdateForm;
end;

method FormShapeEdit.BtnFillColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fNodeBrush.Color;
  if DlgColor.ShowDialog = DialogResult.OK then
    fNodeBrush.Color := DlgColor.Color;
  UpdateForm;
end;

method FormShapeEdit.BtnHatchColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fNodeBrush.HatchColor;
  if DlgColor.ShowDialog = DialogResult.OK then
    fNodeBrush.HatchColor := DlgColor.Color;
  UpdateForm;
end;

method FormShapeEdit.Edit_ValueChanged(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  UpdateForm;
end;

method FormShapeEdit.BtnNodeLineColor_Click(sender: System.Object; e: System.EventArgs);
begin
  DlgColor.Color := fNodePen.Color;
  if DlgColor.ShowDialog = DialogResult.OK then
    fNodePen.Color := DlgColor.Color;
  UpdateForm;
end;

end.