// FormFunctEditDiscretize.pas is part of
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
// FormFunctEditDiscretize.pas implements a form for editing a DexiDiscretizeFunction.
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
  /// Summary description for FormFunctEditDiscrete.
  /// </summary>
  FormFunctEditDiscretize = partial public class(System.Windows.Forms.Form)
  private
    method BtnRedo_Click(sender: System.Object; e: System.EventArgs);
    method BtnUndo_Click(sender: System.Object; e: System.EventArgs);
    
    method ItemToolPasteFunct_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCopyFunct_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolShowFunction_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDeleteBound_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolAddBound_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolEdit_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDeleteInterval_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopIntervalStatus_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopEnterSingle_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopEnterTable_Click(sender: System.Object; e: System.EventArgs);
    method ItemAutoUseDominance_Click(sender: System.Object; e: System.EventArgs);
    method ViewFunct_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewFunct_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewFunct_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method ViewFunct_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method ViewFunct_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method ViewFunct_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ViewFunct_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewFunct_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method ViewFunct_FormatCell(sender: System.Object; e: FormatCellEventArgs);
    method ItemToolFunctDescr_Click(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fModel: DexiModel;
    fAttribute: DexiAttribute;
    fInpAttribute: DexiAttribute;
    fScale: DexiDiscreteScale;
    fScaleNames: List<String>;
    fInpScale: DexiContinuousScale;
    fScaleStrings := new DexiScaleStrings;
    fFunct: DexiDiscretizeFunction;
    fIntervals: List<DexiIntervalObject>;
    fAutomation: Boolean;
    fCanUseDominance: Boolean;
    fLastSelected: DexiIntervalObject;
    fUpdateLevel: Integer;
    fSelectableColumns: List<OLVColumn>;
    fSelectedColumn: OLVColumn;
    fSelectedEditedValue: Integer;
    fUndoRedo: FunctionDiscretizeUndoRedo;
  protected
    method Dispose(aDisposing: Boolean); override;
    method NumberToIndex(aNumber: Integer): Integer;
    method IndexToNumber(aIndex: Integer): Integer;
    method IndexToNumber(aIndices: IntArray): IntArray;
    method NumberToIndex(aNumbers: IntArray): IntArray;
    method BoundIndex(aIntervalIndex: Integer; aColumn: OLVColumn): Integer;
    method MakeIntervals;
    method UpdateIntervals;
    method MakeColumns;
    method MakeContextMenu;
    method UpdateConsistency;
    method SelectionChanged;
    method ConsistencyStatus(aInterval: DexiIntervalObject);
    method SelectBound(aSelectBound: Float);
    method FunctionValueChanged(aSaveState: Boolean := true; aSelectBound: Float := Consts.NaN);
    method FunctionIntervalsChanged(aSaveState: Boolean := true; aSelectBound: Float := Consts.NaN);
    method CheckFunctionValue(aIndex: Integer; aValue: DexiValue): Boolean;
    method SetFunctionValue(aIndex: Integer; aValue: DexiValue);
    method DeleteFunctionValue(aIndex: Integer);
    method UndefineFunctionValue(aIndex: Integer);
    method CanEditCell(aColumn: OLVColumn := nil): Boolean;
    method EditCell;
    method SaveState;
  public
    constructor;
    method SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiDiscretizeFunction);
    method UpdateForm;
    method GetFunctionState: FunctionDiscretizeEditState;
    method SetFunctionState(aState: FunctionDiscretizeEditState);
    property Model: DexiModel read fModel;
    property Attribute: DexiAttribute read fAttribute;
    property InpAttribute: DexiAttribute read fInpAttribute;
    property Scale: DexiDiscreteScale read fScale;
    property InpScale: DexiContinuousScale read fInpScale;
    property Funct: DexiFunction read fFunct;
    property SelectedInterval: DexiIntervalObject read DexiIntervalObject(ViewFunct:SelectedObject);
  end;

type
  FunctionDiscretizeEditState = public class
    public
      property SelectedIndex: Integer;
      property Funct: DexiDiscretizeFunction;
  end;

type
  FunctionDiscretizeUndoRedo = public class (UndoRedo<FunctionDiscretizeEditState>)
    private fForm: weak FormFunctEditDiscretize;
    protected
    public
      method GetObjectState: FunctionDiscretizeEditState; override;
      method SetObjectState(aState: FunctionDiscretizeEditState); override;
      constructor (aForm: FormFunctEditDiscretize);
  end;

implementation

{$REGION Construction and Disposition}
constructor FormFunctEditDiscretize;
begin
  //
  // Required for Windows Form Designer support
  //
  InitializeComponent();

  //
  // TODO: Add any constructor code after InitializeComponent call
  //
  fFormText := self.Text;
  ViewFunct.FullRowSelect := true;
  ViewFunct.SelectedBackColor := AppSettings.SelectedColor;
  ViewFunct.SelectedForeColor := ViewFunct.ForeColor;
  HeaderFormat.Normal.BackColor := AppSettings.SelectedColor;
//  fSelectableColumns := new List<OLVColumn>([ColInpLowAssoc, ColInpLow, ColInpHigh, ColInpHighAssoc, ColOutput]);
  fSelectableColumns := new List<OLVColumn>([ColInpLow, ColInpHigh, ColOutput]);

//  ColStatus.AspectGetter :=
//    method(x: Object)
//    begin
//      result := DexiIntervalObject(x);
//    end;
//
//  ColStatus.AspectToStringConverter :=
//    method(x: Object)
//    begin
//      result := String.Empty;
//    end;
//

  ColStatus.ImageGetter :=
    method(x: Object)
    begin
      result := nil;
      if x is DexiIntervalObject then
        begin
          var lDiscr := DexiIntervalObject(x);
          result :=
            if not lDiscr.Consistent then
                if lDiscr.Entered then 'ImgIntervalEnteredInconsist'
                else 'ImgIntervalInconsist'
            else if lDiscr.Entered then 'ImgIntervalEntered'
        end;
    end;

end;

method FormFunctEditDiscretize.Dispose(aDisposing: Boolean);
begin
  if aDisposing then begin
    if assigned(components) then
      components.Dispose();

    //
    // TODO: Add custom disposition code here
    //
    ViewFunct.SmallImageList := nil;
    AppDisposeHandler.DisposeUndisposed(0);
  end;
  inherited Dispose(aDisposing);
end;

{$ENDREGION}

{$REGION FunctionDiscretizeUndoRedo}

constructor FunctionDiscretizeUndoRedo(aForm: FormFunctEditDiscretize);
begin
  inherited constructor;
  fForm := aForm;
end;

method FunctionDiscretizeUndoRedo.GetObjectState: FunctionDiscretizeEditState;
begin
  result := fForm.GetFunctionState;
end;

method FunctionDiscretizeUndoRedo.SetObjectState(aState: FunctionDiscretizeEditState);
begin
  fForm.SetFunctionState(aState);
end;

{$ENDREGION}

method FormFunctEditDiscretize.GetFunctionState: FunctionDiscretizeEditState;
begin
  result := new FunctionDiscretizeEditState(SelectedIndex := ViewFunct.SelectedIndex, Funct := fFunct.CopyFunction);
end;

method FormFunctEditDiscretize.SetFunctionState(aState: FunctionDiscretizeEditState);
begin
  inc(fUpdateLevel);
  try
    fFunct := aState.Funct;
    MakeIntervals;
    ViewFunct.SetObjects(fIntervals);
    ViewFunct.SelectedIndex := aState.SelectedIndex;
    SelectionChanged;
  finally
    dec(fUpdateLevel);
  end;
  FunctionValueChanged(false);
end;

method FormFunctEditDiscretize.SaveState;
begin
  fUndoRedo.AddState;
end;

method FormFunctEditDiscretize.NumberToIndex(aNumber: Integer): Integer;
begin
  result := aNumber - 1;
end;

method FormFunctEditDiscretize.IndexToNumber(aIndex: Integer): Integer;
begin
  result := aIndex + 1;
end;

method FormFunctEditDiscretize.IndexToNumber(aIndices: IntArray): IntArray;
begin
  result := Utils.CopyIntArray(aIndices);
  for i := low(result) to high(result) do
    result[i] := IndexToNumber(result[i]);
end;

method FormFunctEditDiscretize.NumberToIndex(aNumbers: IntArray): IntArray;
begin
  result := Utils.CopyIntArray(aNumbers);
  for i := low(result) to high(result) do
    result[i] := NumberToIndex(result[i]);
end;

method FormFunctEditDiscretize.BoundIndex(aIntervalIndex: Integer; aColumn: : OLVColumn): Integer;
begin
  result :=
    if aColumn = ColInpLow then fFunct.IntervalLowBoundIndex[aIntervalIndex]
    else fFunct.IntervalHighBoundIndex[aIntervalIndex];
end;

method FormFunctEditDiscretize.UpdateConsistency;
begin
  for each lInterval in fIntervals do
    lInterval.SetConsistency(fFunct);
end;

method FormFunctEditDiscretize.MakeIntervals;
begin
  fIntervals := new List<DexiIntervalObject>;
  for lIdx := 0 to fFunct.IntervalCount - 1 do
    fIntervals.Add(new DexiIntervalObject(lIdx + 1, fFunct.ValueCell[lIdx], fFunct.IntervalLowBound[lIdx], fFunct.IntervalHighBound[lIdx]));
  UpdateConsistency;
end;

method FormFunctEditDiscretize.UpdateIntervals;
begin
  for each lInterval in fIntervals do
    lInterval.Update(fFunct);
end;

method FormFunctEditDiscretize.MakeColumns;
begin
  ColInpLow.Text := fInpAttribute:Name;
  ColInpLow.ToolTipText := fInpAttribute.Description;
  ColInpLow.Renderer := new CompositeModelBoundRenderer(fInpScale, DexiBoundAssociation.Down);

  ColInpHigh.Renderer := new CompositeModelBoundRenderer(fInpScale, DexiBoundAssociation.Up);
  ColInpHigh.Text := '';

  ColOutput.Text := fAttribute.Name;
  ColOutput.ToolTipText := fAttribute.Description;
  ColOutput.Renderer := new CompositeModelValueRenderer(fScale, Settings := fModel:Settings);
end;

method FormFunctEditDiscretize.MakeContextMenu;
begin
  FunctMenu.SuspendLayout;
  for i := fScaleNames.Count - 1 downto 0 do
    begin
      var lItem := new ToolStripMenuItem;
      var lCode := DexiTabularFunction.IntToExtVal(i);
      var lActCode :=
        if String.IsNullOrEmpty(lCode) then ''
        else lCode + ' ';
      lItem.Tag := i;
      lItem.Text := lActCode + fScaleNames[i];
      lItem.Click += ItemPopDefinedValue_Click;
      FunctMenu.Items.Insert(0, lItem);
    end;
  FunctMenu.ResumeLayout;
end;

method FormFunctEditDiscretize.SelectionChanged;
begin
  if fUpdateLevel > 0 then
    exit;
  ViewFunct.RefreshObject(fLastSelected);
  inc(fUpdateLevel);
  try
    var lSelectedInterval := SelectedInterval;
    if SelectedInterval = nil then
      if fLastSelected <> nil then
        ViewFunct.SelectObject(fLastSelected)
      else if fIntervals.Count > 0 then
        ViewFunct.SelectObject(fIntervals[0]);
    lSelectedInterval := SelectedInterval;
    if lSelectedInterval <> nil then
      ViewFunct.RefreshObject(lSelectedInterval);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
  fLastSelected := SelectedInterval;
end;

method FormFunctEditDiscretize.SelectBound(aSelectBound: Float);
begin
  for i := 1 to fFunct.BoundCount - 2 do
    if aSelectBound = fFunct.Bound[i].Bound then
      begin
        fSelectedColumn := ColInpLow;
        ViewFunct.SelectObject(fIntervals[i]);
        exit;
      end;
end;

method FormFunctEditDiscretize.FunctionValueChanged(aSaveState: Boolean := true; aSelectBound: Float := Consts.NaN);
begin
  fFunct.ReviseFunction(fAutomation);
  UpdateIntervals;
  if not Consts.IsNaN(aSelectBound) then
    SelectBound(aSelectBound);
  ViewFunct.RefreshObjects(fIntervals);
  UpdateForm;
  if aSaveState then
    SaveState;
end;

method FormFunctEditDiscretize.FunctionIntervalsChanged(aSaveState: Boolean := true; aSelectBound: Float := Consts.NaN);
begin
  fFunct.ReviseFunction(fAutomation);
  MakeIntervals;
  ViewFunct.SetObjects(fIntervals);
  if not Consts.IsNaN(aSelectBound) then
    SelectBound(aSelectBound);
  if (SelectedInterval = nil) and (fIntervals.Count > 0) then
    ViewFunct.SelectObject(fIntervals[0]);
  if aSaveState then
    SaveState;
  UpdateForm;
end;

method FormFunctEditDiscretize.CheckFunctionValue(aIndex: Integer; aValue: DexiValue): Boolean;
begin
  result := true;
  if DexiValue.ValueIsDefined(aValue) and fFunct.UseConsist and fFunct.IsConsistent then
    begin
      var lPrevValue := fFunct.IntervalValue[aIndex];
      fFunct.IntervalValue[aIndex] := aValue;
      try
        var lInconsist := IndexToNumber(fFunct.IntervalInconsistentWith(aIndex));
        if length(lInconsist) > 0 then
          begin
            var lMsg := String.Format(DexiStrings.MsgInconsistInterval,
              aIndex + 1,
              fScaleStrings.ValueOnScaleString(aValue, fScale),
              Utils.IntArrayToStr(lInconsist),
              fScaleStrings.ValueOnScaleString(lPrevValue, fScale));
            result := MessageBox.Show(lMsg, 'Warning', MessageBoxButtons.YesNoCancel, MessageBoxIcon.Warning) = DialogResult.Yes;
          end;
      finally
        fFunct.IntervalValue[aIndex] := lPrevValue;
      end;
    end;
end;

method FormFunctEditDiscretize.SetFunctionValue(aIndex: Integer; aValue: DexiValue);
begin
  if not CheckFunctionValue(aIndex, aValue) then
    exit;
  fFunct.IntervalValue[aIndex] := aValue;
  fFunct.IntervalEntered[aIndex] := true;
  FunctionValueChanged;
end;

method FormFunctEditDiscretize.DeleteFunctionValue(aIndex: Integer);
begin
  fFunct.ClearCell(aIndex);
  FunctionValueChanged;
end;

method FormFunctEditDiscretize.UndefineFunctionValue(aIndex: Integer);
begin
  fFunct.UndefineInterval(aIndex);
  FunctionValueChanged;
end;

method FormFunctEditDiscretize.CanEditCell(aColumn: OLVColumn := nil): Boolean;
begin
  result := false;
  if SelectedInterval = nil then
    exit;
  if aColumn = nil then
    aColumn := fSelectedColumn;
  if aColumn = ColOutput then
    result := true
  else if (aColumn = ColInpLow) or (aColumn = ColInpHigh) then
    begin
      var lBoundIndex := BoundIndex(SelectedInterval.Index, aColumn);
      result := 0 < lBoundIndex < fFunct.BoundCount - 1;
    end;
end;

method FormFunctEditDiscretize.EditCell;
begin
  ViewFunct.FinishCellEdit;
  if SelectedInterval = nil then
    exit;
  ViewFunct.StartCellEdit(ViewFunct.ModelToItem(SelectedInterval), fSelectedColumn.Index);
end;

method FormFunctEditDiscretize.SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiDiscretizeFunction);
begin
  Font := AppData.CurrentAppFont;
  fAutomation := false;
  fModel := aModel;
  fAttribute := aAttribute;
  fInpAttribute := fAttribute.Inputs[0];
  fScale := DexiDiscreteScale(fAttribute:Scale);
  fScaleNames := fScale.NameList;
  fInpScale := DexiContinuousScale(fInpAttribute:Scale);
  fFunct := aFunct;
  fUpdateLevel := 0;
  fSelectedColumn := ColOutput;
  fCanUseDominance := fFunct.CanUseDominance;
  inc(fUpdateLevel);
  MakeContextMenu;
  MakeIntervals;
  MakeColumns;
  fUndoRedo := new FunctionDiscretizeUndoRedo(self);
  fUndoRedo.Active := aModel.Settings.Undoing;
  BtnOK.Visible := not aModel.Settings.ModelProtect;
  try
    Text := String.Format(fFormText, fAttribute:Name);
    ViewFunct.SmallImageList := BoundImages;
    ViewFunct.ContextMenuStrip := FunctMenu;
    ViewFunct.SetObjects(fIntervals);
    ActiveControl := ViewFunct;
    fLastSelected := SelectedInterval;
    if fIntervals.Count > 0 then
      ViewFunct.SelectObject(fIntervals[0]);
    ItemToolIntervalDescr.Visible := false; //TODO implement description functionality
  finally
    dec(fUpdateLevel);
  end;
  fUndoRedo.AddState;
  UpdateForm;
end;

method FormFunctEditDiscretize.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  LblStatus.Text := fFunct.FunctString;
  var lIsEditing := ViewFunct.IsCellEditing;
  var lCanEdit := CanEditCell and not lIsEditing;
  var lIsSelected := SelectedInterval <> nil;
  if fCanUseDominance and not ItemToolAutoSettings.Visible then
    ItemToolAutoSettings.Visible := fCanUseDominance;
  AppUtils.Enable(lIsSelected and not lIsEditing, ItemToolIntervalDescr, ItemToolDeleteValue, ItemPopUndefinedValue, ItemPopIntervalStatus);
  AppUtils.Enable(lCanEdit, ItemToolEdit);
  AppUtils.Enable(lCanEdit and (fSelectedColumn <> ColOutput), ItemToolDeleteBound);
  AppUtils.Enable((fFunct.EntCount < fFunct.Count) and not lIsEditing, ItemPopEnter);
  AppUtils.Enable(fUndoRedo.CanUndo and not lIsEditing, BtnUndo);
  AppUtils.Enable(fUndoRedo.CanRedo and not lIsEditing, BtnRedo);
  inc(fUpdateLevel);
  try
    fAutomation := fFunct.UseConsist;
    if ItemToolAutoSettings.Visible then
      begin
        ItemAutoUseDominance.Enabled := fFunct.CanUseDominance;
        ItemAutoUseDominance.Checked := ItemAutoUseDominance.Enabled and fFunct.UseConsist {and (fFunct.CstState >= 0)};
        var lImgName :=
          if ItemAutoUseDominance.Checked and ItemAutoUseDominance.Enabled then 'ImgAutoDominance'
          else 'ImgAutoNone';
        ItemToolAutoSettings.Image := AutoImages.Images[lImgName];
      end;
  finally
    dec(fUpdateLevel);
  end;
end;

method FormFunctEditDiscretize.ItemToolFunctDescr_Click(sender: System.Object; e: System.EventArgs);
begin
  ViewFunct.FinishCellEdit;
  var lFunctDescrForm := AppData.NameEditForm;
  lFunctDescrForm.SetForm(DexiStrings.TitleFncNameEdit, DexiStrings.LabelFncNameEdit, DexiStrings.LabelFncDescrEdit);
  lFunctDescrForm.SetTexts(fFunct.Name, fFunct.Description);
  if lFunctDescrForm.ShowDialog = DialogResult.OK then
    begin
      fFunct.Name := lFunctDescrForm.NameText;
      fFunct.Description := lFunctDescrForm.DescriptionText;
      SaveState;
      UpdateForm;
    end;
end;

method FormFunctEditDiscretize.ViewFunct_FormatCell(sender: System.Object; e: FormatCellEventArgs);
begin
  if e.Column = ColOutput then
    e.SubItem.BackColor := AppSettings.SelectedColor;
  if e.Column = fSelectedColumn then
    begin
      if e.RowIndex = ViewFunct.SelectedIndex then
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

method FormFunctEditDiscretize.ViewFunct_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method FormFunctEditDiscretize.ConsistencyStatus(aInterval: DexiIntervalObject);
begin
  var lIdx := aInterval.Index;
  var lInConsist :=
    if not aInterval.Consistent then DexiUtils.Utils.IntArrayToStr(IndexToNumber(fFunct.IntervalInconsistentWith(lIdx)))
    else '';
  var lMessage :=
    if aInterval.Consistent then
      if aInterval.Entered then String.Format(DexiStrings.MsgIntervalEntered, aInterval.Number)
      else String.Format(DexiStrings.MsgIntervalNotEntered, aInterval.Number)
    else
      if aInterval.Entered then String.Format(DexiStrings.MsgIntervalEnteredInconsist, aInterval.Number, lInConsist)
      else String.Format(DexiStrings.MsgIntervalNotEnteredInconsist, aInterval.Number, lInConsist);
  MessageBox.Show(lMessage,
    if aInterval.Consistent then "Status" else 'Warning',
    MessageBoxButtons.OK,
    if aInterval.Consistent then MessageBoxIcon.Information else  MessageBoxIcon.Warning);
end;

method FormFunctEditDiscretize.ViewFunct_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if sender = ViewFunct then
    begin
      var ht := ViewFunct.OlvHitTest(e.Location.X, e.Location.Y);
      if ht <> nil then
        begin
          if fSelectableColumns.Contains(ht.Column) then
            begin
              fSelectedColumn := ht.Column;
              ViewFunct.RefreshObject(fLastSelected);
              UpdateForm;
            end;
          if ht.Column = ColStatus then
            begin
              var lInterval := DexiIntervalObject(ht.RowObject);
              if lInterval <> nil then
                begin
                  ViewFunct.RefreshObject(fLastSelected);
                  ConsistencyStatus(lInterval);
                end;
            end;
        end;
    end;
end;

method FormFunctEditDiscretize.ViewFunct_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if SelectedInterval = nil then
    exit;
  if e.KeyCode = Keys.Delete then
    begin
      if fSelectedColumn = ColOutput then
        DeleteFunctionValue(SelectedInterval.Index);
      e.Handled := true;
    end
  else if e.KeyCode = Keys.F2 then
    begin
      EditCell;
      e.Handled := true;
    end
  else if e.KeyCode = Keys.Left then
    begin
      var lIdx := fSelectableColumns.IndexOf(fSelectedColumn);
      if lIdx > 0 then
        begin
          fSelectedColumn := fSelectableColumns[lIdx - 1];
          ViewFunct.RefreshObject(fLastSelected);
          UpdateForm;
         end;
      e.Handled := true;
    end
  else if e.KeyCode = Keys.Right then
    begin
      var lIdx := fSelectableColumns.IndexOf(fSelectedColumn);
      if lIdx < fSelectableColumns.Count - 1 then
        begin
          fSelectedColumn := fSelectableColumns[lIdx + 1];
          ViewFunct.RefreshObject(fLastSelected);
          UpdateForm;
        end;
      e.Handled := true;
    end;
end;

method FormFunctEditDiscretize.ViewFunct_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
  if SelectedInterval = nil then
    exit;
  if fSelectedColumn <> ColOutput then
    exit;
  var lValue := DexiTabularFunction.ExtToIntVal(Char.ToUpper(e.KeyChar));
  if 0 <= lValue < fScale.Count then
    begin
      SetFunctionValue(SelectedInterval.Index, new DexiIntSingle(lValue));
      e.Handled := true;
    end;
end;

method FormFunctEditDiscretize.ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedInterval = nil then
    exit;
  UndefineFunctionValue(SelectedInterval.Index);
end;

method FormFunctEditDiscretize.ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedInterval = nil then
    exit;
  if sender is ToolStripMenuItem then
    SetFunctionValue(SelectedInterval.Index, new DexiIntSingle(Integer(ToolStripMenuItem(sender).Tag)));
end;

method FormFunctEditDiscretize.ViewFunct_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if SelectedInterval = nil then
    exit;
  if not CanEditCell(e.Column) then
    begin
      e.Cancel := true;
      exit;
    end;
  if e.Column = ColOutput then
    begin
      var lIndex := SelectedInterval.Index;
      var lCtrl := new ComboBox;
      lCtrl.DropDownStyle := ComboBoxStyle.DropDownList;
      lCtrl.Items.AddRange(fScaleNames.ToArray);
      lCtrl.Items.Add(DexiString.SDexiUndefinedValue);
      lCtrl.Bounds := e.CellBounds;
      lCtrl.SelectedIndex :=
        if fFunct.IntervalDefined[lIndex] then fFunct.IntervalValLow[lIndex]
        else fScale.Count;
      lCtrl.SelectedIndexChanged += ComboEdit_SelectedIndexChanged;
      e.Control := lCtrl;
    end
  else if (e.Column = ColInpLow) or (e.Column = ColInpHigh) then
    begin
      var lBoundIndex := BoundIndex(SelectedInterval.Index, e.Column);
      var lBound := fFunct.Bound[lBoundIndex];
      using lBoundEditForm := new FormBoundEdit do
        begin
          lBoundEditForm.SetForm(DexiStrings.TitleBoundEdit, lBound,
            method (aValue: Float)
              begin
                result := fFunct.CanChangeBound(lBoundIndex, aValue)
              end
           );
          if lBoundEditForm.ShowDialog = DialogResult.OK then
            begin
              fFunct.ChangeBound(lBoundIndex, lBoundEditForm.BoundValue, lBoundEditForm.BoundAssociation);
              FunctionValueChanged(true, lBoundEditForm.BoundValue);
            end;
        end;
      e.Cancel := true;  // already done all editing
    end;
end;

method FormFunctEditDiscretize.ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  ViewFunct.FinishCellEdit;
end;

method FormFunctEditDiscretize.ViewFunct_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  fSelectedEditedValue := -1;
  if e.Cancel then
    exit;
  if (e.Column = ColOutput) and (e.Control is ComboBox) then
    fSelectedEditedValue := ComboBox(e.Control).SelectedIndex;
end;

method FormFunctEditDiscretize.ViewFunct_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if SelectedInterval = nil then
    exit;
  if (e.Column = ColOutput) and (e.Control is ComboBox) then
    begin
      if not e.Cancel then
        if 0 <= fSelectedEditedValue < fScale.Count then
          SetFunctionValue(SelectedInterval.Index, new DexiIntSingle(fSelectedEditedValue))
        else if fSelectedEditedValue = fScale.Count then
          UndefineFunctionValue(SelectedInterval.Index);
      AppDisposeHandler.HandleUndisposed(e.Control);
//      e.Control.Dispose;
//      e.Control := nil;
    end;
end;

method FormFunctEditDiscretize.ViewFunct_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if SelectedInterval = nil then
    exit;
  EditCell;
end;

method FormFunctEditDiscretize.ItemAutoUseDominance_Click(sender: System.Object; e: System.EventArgs);
begin
  ViewFunct.FinishCellEdit;
  fFunct.UseConsist := not fFunct.UseConsist;
  fAutomation := fFunct.UseConsist;
  FunctionValueChanged;
end;

method FormFunctEditDiscretize.ItemPopEnterTable_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fFunct.SetIntervalsEntered(true);
  FunctionValueChanged;
end;

method FormFunctEditDiscretize.ItemPopEnterSingle_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fFunct.SetIntervalsEntered(false);
  FunctionValueChanged;
end;

method FormFunctEditDiscretize.ItemPopIntervalStatus_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedInterval = nil then
    exit;
  ConsistencyStatus(SelectedInterval);
end;

method FormFunctEditDiscretize.ItemToolDeleteInterval_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedInterval = nil then
    exit;
  ViewFunct.FinishCellEdit;
  DeleteFunctionValue(SelectedInterval.Index);
end;

method FormFunctEditDiscretize.ItemToolEdit_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedInterval = nil then
    exit;
  EditCell;
end;

method FormFunctEditDiscretize.ItemToolAddBound_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedInterval = nil then
    exit;
  ViewFunct.FinishCellEdit;
  using lBoundEditForm := new FormBoundEdit do
    begin
      lBoundEditForm.SetForm(DexiStrings.TitleBoundAdd, nil,
        method (aValue: Float)
          begin
            result := fFunct.CanAddBound(aValue)
          end
        );
      if lBoundEditForm.ShowDialog = DialogResult.OK then
        begin
          fFunct.AddBound(lBoundEditForm.BoundValue, lBoundEditForm.BoundAssociation);
          FunctionIntervalsChanged(true, lBoundEditForm.BoundValue);
        end;
    end;
end;

method FormFunctEditDiscretize.ItemToolDeleteBound_Click(sender: System.Object; e: System.EventArgs);
begin
  ViewFunct.FinishCellEdit;
  if SelectedInterval = nil then
    exit;
  if (fSelectedColumn <> ColInpLow) and (fSelectedColumn <> ColInpHigh) then
    exit;
  var lBoundIndex :=
    if fSelectedColumn = ColInpLow then fFunct.IntervalLowBoundIndex[SelectedInterval.Index]
    else fFunct.IntervalHighBoundIndex[SelectedInterval.Index];
  if not fFunct.CanDeleteBound(lBoundIndex) then
    exit;
  var lNextBound :=
    if lBoundIndex < fFunct.BoundCount - 2 then fFunct.Bound[lBoundIndex + 1].Bound
    else if lBoundIndex > 1 then fFunct.Bound[lBoundIndex - 1].Bound
    else Consts.NaN;
  fFunct.DeleteBound(lBoundIndex);
  FunctionIntervalsChanged(true, lNextBound);
end;

method FormFunctEditDiscretize.ItemToolShowFunction_Click(sender: System.Object; e: System.EventArgs);
begin
  ReportManager.OpenFunctionReport(fModel, fAttribute, fFunct);
end;

method FormFunctEditDiscretize.ItemToolCopyFunct_Click(sender: System.Object; e: System.EventArgs);
begin
  var lList := fFunct.SaveToStringList(fModel.Settings);
  var lText := String.Join(Environment.LineBreak, lList);
  Clipboard.SetText(lText);
end;

method FormFunctEditDiscretize.ItemToolPasteFunct_Click(sender: System.Object; e: System.EventArgs);
begin
  var lText := Clipboard.GetText;
  var lList := Utils.BreakToLines(lText);
  var lLoaded: Integer;
  var lChanged: Integer;
  fFunct.LoadFromStringList(lList, fModel.Settings, out lLoaded, out lChanged);
  FunctionValueChanged;
  MessageBox.Show(String.Format(DexiString.SDexiDiscrFncImport, lLoaded, lChanged),
         "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
end;

method FormFunctEditDiscretize.BtnUndo_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fUndoRedo.Undo;
end;

method FormFunctEditDiscretize.BtnRedo_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fUndoRedo.Redo;
end;

end.