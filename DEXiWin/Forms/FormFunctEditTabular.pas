// FormFunctEditTabular.pas is part of
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
// FormFunctEditTabular.pas implements a form for editing a DexiTabulatFunction.
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
  RemObjects.Elements.RTL,
  BrightIdeasSoftware,
  DexiUtils,
  DexiLibrary;

type
  /// <summary>
  /// Summary description for FormFunctEditDiscrete.
  /// </summary>
  FormFunctEditTabular = partial public class(System.Windows.Forms.Form)
  private
    method ItemToolSymmetricity_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopResetColumns_Click(sender: System.Object; e: System.EventArgs);
    method ViewFunct_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method ItemPopResizeColumns_Click(sender: System.Object; e: System.EventArgs);
    method BtnRedo_Click(sender: System.Object; e: System.EventArgs);
    method BtnUndo_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolsChart_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolPasteFunct_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolCopyFunct_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolShowFunction_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolWeights_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopEnterSingle_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopEnterTable_Click(sender: System.Object; e: System.EventArgs);
    method ItemAutoUseWeights_Click(sender: System.Object; e: System.EventArgs);
    method ItemAutoUseDominance_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolEditRule_Click(sender: System.Object; e: System.EventArgs);
    method ViewFunct_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewFunct_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ViewFunct_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
    method ViewFunct_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
    method ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
    method ItemPopRuleStatus_Click(sender: System.Object; e: System.EventArgs);
    method ItemToolDeleteRule_Click(sender: System.Object; e: System.EventArgs);
    method ViewFunct_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
    method ViewFunct_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
    method ViewFunct_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
    method ViewFunct_SelectionChanged(sender: System.Object; e: System.EventArgs);
    method ViewFunct_FormatCell(sender: System.Object; e: FormatCellEventArgs);
    method ItemToolFunctDescr_Click(sender: System.Object; e: System.EventArgs);
    fFormText: String;
    fModel: DexiModel;
    fAttribute: DexiAttribute;
    fScale: DexiDiscreteScale;
    fScaleNames: List<String>;
    fScaleStrings := new DexiScaleStrings;
    fFunct: DexiTabularFunction;
    fRules: List<DexiRuleObject>;
    fAutomation: Boolean;
    fLastSelected: DexiRuleObject;
    fUpdateLevel: Integer;
    fOutColumn: OLVColumn;
    fSelectedEditedValue: Integer;
    fUndoRedo: FunctionTabularUndoRedo;
    fDefaultTableState: array of Byte;
  protected
    method Dispose(aDisposing: Boolean); override;
    method NumberToIndex(aNumber: Integer): Integer;
    method IndexToNumber(aIndex: Integer): Integer;
    method IndexToNumber(aIndices: IntArray): IntArray;
    method NumberToIndex(aNumbers: IntArray): IntArray;
    method MakeRules;
    method MakeColumns;
    method MakeContextMenu;
    method UpdateConsistency;
    method SelectionChanged;
    method ConsistencyStatus(aRule: DexiRuleObject);
    method CheckFunctionValue(aNumber: Integer; aValue: DexiValue): Boolean;
    method SetFunctionValue(aNumber: Integer; aValue: DexiValue);
    method DeleteFunctionValue(aNumber: Integer);
    method UndefineFunctionValue(aNumber: Integer);
    method EditFunctionValue(aNumber: Integer);
    method SaveState;
  public
    constructor;
    method SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction);
    method FormatForm(aFunct: DexiFunction);
    method SaveFormFormat(aOldFunct, aNewFunct: DexiFunction);
    method UpdateForm;
    method FunctionValueChanged(aSaveState: Boolean := true);
    method GetFunctionState: FunctionTabularEditState;
    method SetFunctionState(aState: FunctionTabularEditState);
    property Attribute: DexiAttribute read fAttribute;
    property Scale: DexiDiscreteScale read fScale;
    property InpScale[aIdx: Integer]: DexiDiscreteScale read DexiDiscreteScale(fAttribute.Inputs[aIdx]:Scale);
    property Funct: DexiTabularFunction read fFunct;
    property SelectedRule: DexiRuleObject read DexiRuleObject(ViewFunct:SelectedObject);
  end;

type
  FunctionTabularEditState = public class
    public
      property SelectedIndex: Integer;
      property Funct: DexiTabularFunction;
  end;

type
  FunctionTabularUndoRedo = public class (UndoRedo<FunctionTabularEditState>)
    private fForm: weak FormFunctEditTabular;
    protected
    public
      method GetObjectState: FunctionTabularEditState; override;
      method SetObjectState(aState: FunctionTabularEditState); override;
      constructor (aForm: FormFunctEditTabular);
  end;

implementation

{$REGION Construction and Disposition}
constructor FormFunctEditTabular;
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

  ColStatus.AspectGetter :=
    method(x: Object)
    begin
      result := DexiRuleObject(x);
    end;

  ColStatus.AspectToStringConverter :=
    method(x: Object)
    begin
      result := String.Empty;
    end;

  ColStatus.ImageGetter :=
    method(x: Object)
    begin
      result := nil;
      if x is DexiRuleObject then
        begin
          var lRule := DexiRuleObject(x);
          result :=
            if not lRule.Consistent then
                if lRule.Entered then 'ImgRuleEnteredInconsist'
                else 'ImgRuleInconsist'
            else if lRule.Entered then 'ImgRuleEntered';
        end;
    end;
end;

method FormFunctEditTabular.Dispose(aDisposing: Boolean);
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

{$REGION FunctionTabularUndoRedo}

constructor FunctionTabularUndoRedo(aForm: FormFunctEditTabular);
begin
  inherited constructor;
  fForm := aForm;
end;

method FunctionTabularUndoRedo.GetObjectState: FunctionTabularEditState;
begin
  result := fForm.GetFunctionState;
end;

method FunctionTabularUndoRedo.SetObjectState(aState: FunctionTabularEditState);
begin
  fForm.SetFunctionState(aState);
end;

{$ENDREGION}

method FormFunctEditTabular.GetFunctionState: FunctionTabularEditState;
begin
  result := new FunctionTabularEditState(SelectedIndex := ViewFunct.SelectedIndex, Funct := fFunct.CopyFunction);
end;

method FormFunctEditTabular.SetFunctionState(aState: FunctionTabularEditState);
begin
  inc(fUpdateLevel);
  try
    fFunct := aState.Funct;
    MakeRules;
    ViewFunct.SetObjects(fRules);
    ViewFunct.SelectedIndex := aState.SelectedIndex;
    SelectionChanged;
  finally
    dec(fUpdateLevel);
  end;
  FunctionValueChanged(false);
end;

method FormFunctEditTabular.SaveState;
begin
  fUndoRedo.AddState;
end;

method FormFunctEditTabular.NumberToIndex(aNumber: Integer): Integer;
begin
  result := aNumber - 1;
end;

method FormFunctEditTabular.IndexToNumber(aIndex: Integer): Integer;
begin
  result := aIndex + 1;
end;

method FormFunctEditTabular.IndexToNumber(aIndices: IntArray): IntArray;
begin
  result := Utils.CopyIntArray(aIndices);
  for i := low(result) to high(result) do
    result[i] := IndexToNumber(result[i]);
end;

method FormFunctEditTabular.NumberToIndex(aNumbers: IntArray): IntArray;
begin
  result := Utils.CopyIntArray(aNumbers);
  for i := low(result) to high(result) do
    result[i] := NumberToIndex(result[i]);
end;

method FormFunctEditTabular.MakeRules;
begin
  fRules := new List<DexiRuleObject>;
  for each lRule in fFunct.Rules index x do
    fRules.Add(new DexiRuleObject(x + 1, lRule));
  UpdateConsistency;
end;

method FormFunctEditTabular.MakeColumns;
begin
  for lIdx := 0 to fFunct.ArgCount - 1 do
    begin
      var lArgCol := new OLVColumn(fAttribute.Inputs[lIdx]:Name, 'Arg',
        Tag := lIdx, IsEditable := false, Groupable := false, Hideable := false, MinimumWidth := 60, Searchable := false, Sortable := true, UseFiltering := true,
        ToolTipText := fAttribute.Inputs[lIdx].Description,  Width := 60, FillsFreeSpace := false);
      lArgCol.AspectGetter := method(x: Object)
        begin
          result :=
            if (x is DexiRuleObject) then DexiRuleObject(x).Arg[lIdx]
            else '';
        end;
      var lScale := InpScale[lIdx];
      lArgCol.Renderer := new CompositeModelArgRenderer(lScale, lIdx, Settings := fModel:Settings);
      var lClusteringStrategy := new ArgClusteringStrategy(lScale);
      lArgCol.ClusteringStrategy := lClusteringStrategy;
      ViewFunct.AllColumns.Add(lArgCol);
    end;
  fOutColumn := new OLVColumn(fAttribute:Name, 'Value',
     Groupable := false, IsEditable := false, Hideable := false, MinimumWidth := 100, Searchable := false, Sortable := false, UseFiltering := false,
     ToolTipText := fAttribute.Description, Width := 100, FillsFreeSpace := false);
  fOutColumn.Renderer := new CompositeModelValueRenderer(fScale, Settings := fModel:Settings);
  fOutColumn.HeaderFormatStyle := HeaderFormat;
  ViewFunct.AllColumns.Add(fOutColumn);
  ViewFunct.RebuildColumns;
end;

method FormFunctEditTabular.MakeContextMenu;
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

method FormFunctEditTabular.UpdateConsistency;
begin
  for each lRule in fRules do
    lRule.SetConsistency(fFunct);
end;

method FormFunctEditTabular.SelectionChanged;
begin
  if fUpdateLevel > 0 then
    exit;
  ViewFunct.RefreshObject(fLastSelected);
  inc(fUpdateLevel);
  try
    var lSelectedRule := SelectedRule;
    if SelectedRule = nil then
      if fLastSelected <> nil then
        ViewFunct.SelectObject(fLastSelected)
      else if fRules.Count > 0 then
        ViewFunct.SelectObject(fRules[0]);
    lSelectedRule := SelectedRule;
    if lSelectedRule <> nil then
      ViewFunct.RefreshObject(lSelectedRule);
  finally
    dec(fUpdateLevel);
  end;
  UpdateForm;
  fLastSelected := SelectedRule;
end;

method FormFunctEditTabular.FunctionValueChanged(aSaveState: Boolean := true);
begin
  fFunct.AffectsWeights;
  fFunct.ReviseFunction(fAutomation);
  UpdateConsistency;
  ViewFunct.RefreshObjects(fRules);
  UpdateForm;
  if aSaveState then
    SaveState;
end;

method FormFunctEditTabular.CheckFunctionValue(aNumber: Integer; aValue: DexiValue): Boolean;
begin
  result := true;
  var lIdx := NumberToIndex(aNumber);
  if DexiValue.ValueIsDefined(aValue) and fFunct.UseConsist and fFunct.IsConsistent then
    begin
      var lPrevValue := fFunct.RuleValue[lIdx];
      fFunct.RuleValue[lIdx] := aValue;
      try
        var lInconsist := IndexToNumber(fFunct.RuleInconsistentWith(lIdx));
        if length(lInconsist) > 0 then
          begin
            var lMsg := String.Format(DexiStrings.MsgInconsistEntry,
              aNumber,
              fScaleStrings.ValueOnScaleString(aValue, fScale),
              Utils.IntArrayToStr(lInconsist),
              fScaleStrings.ValueOnScaleString(lPrevValue, fScale));
            result := MessageBox.Show(lMsg, 'Warning', MessageBoxButtons.YesNoCancel, MessageBoxIcon.Warning) = DialogResult.Yes;
          end;
      finally
        fFunct.RuleValue[lIdx] := lPrevValue;
      end;
    end;
end;

method FormFunctEditTabular.SetFunctionValue(aNumber: Integer; aValue: DexiValue);
begin
  if not CheckFunctionValue(aNumber, aValue) then
    exit;
  fFunct.RuleValue[NumberToIndex(aNumber)] := aValue;
  FunctionValueChanged;
end;

method FormFunctEditTabular.DeleteFunctionValue(aNumber: Integer);
begin
  fFunct.ClearValue(NumberToIndex(aNumber));
  FunctionValueChanged;
end;

method FormFunctEditTabular.UndefineFunctionValue(aNumber: Integer);
begin
  fFunct.UndefineValue(NumberToIndex(aNumber));
  FunctionValueChanged;
end;

method FormFunctEditTabular.EditFunctionValue(aNumber: Integer);
begin
  if SelectedRule = nil then
    exit;
  ViewFunct.StartCellEdit(ViewFunct.ModelToItem(SelectedRule), fOutColumn.Index);
end;

method FormFunctEditTabular.SetForm(aModel: DexiModel; aAttribute: DexiAttribute; aFunct: DexiTabularFunction);
begin
  Font := AppData.CurrentAppFont;
  fAutomation := false;
  fModel := aModel;
  fAttribute := aAttribute;
  fScale := DexiDiscreteScale(fAttribute:Scale);
  fScaleNames := fScale.NameList;
  fFunct := aFunct;
  fUndoRedo := new FunctionTabularUndoRedo(self);
  fUndoRedo.Active := aModel.Settings.Undoing;
  BtnOK.Visible := not aModel.Settings.ModelProtect;

  fUpdateLevel := 0;

  inc(fUpdateLevel);
  MakeContextMenu;
  MakeRules;
  MakeColumns;
  try
    Text := String.Format(fFormText, fAttribute:Name);
    ViewFunct.SmallImageList := RuleImages;
    ViewFunct.ContextMenuStrip := FunctMenu;
    ViewFunct.SetObjects(fRules);
    ViewFunct.Sort(ColNumber, SortOrder.Ascending);
    ActiveControl := ViewFunct;
    fLastSelected := SelectedRule;
    if fRules.Count > 0 then
      ViewFunct.SelectObject(fRules[0]);
    ItemToolRuleDescr.Visible := false; //TODO implement description functionality
    ItemToolWeights.Visible := fFunct.CanUseWeights;
    ItemToolChart.Visible := fFunct.ArgCount >= 2; // TODO
    ItemToolAutoSettings.Visible := fFunct.CanUseDominance or fFunct.CanUseWeights;
  finally
    dec(fUpdateLevel);
  end;
  FunctionValueChanged(false);
  fUndoRedo.AddState;
  fDefaultTableState := ViewFunct.SaveState;
end;

method FormFunctEditTabular.FormatForm(aFunct: DexiFunction);
begin
  var lContext := AppData.ModelContext[fModel];
  var lTableState := lContext:FunctionTableStates[aFunct];
  if lTableState <> nil then
    ViewFunct.RestoreState(lTableState);
end;

method FormFunctEditTabular.SaveFormFormat(aOldFunct, aNewFunct: DexiFunction);
begin
  var lContext := AppData.ModelContext[fModel];
  if lContext <> nil then
    begin
      lContext.FunctionTableStates.Remove(aOldFunct);
      lContext.FunctionTableStates[aNewFunct] := ViewFunct.SaveState;
    end;
end;

method FormFunctEditTabular.UpdateForm;
begin
  if fUpdateLevel > 0 then
    exit;
  LblStatus.Text := fFunct.FunctString;
  var lIsSelected := SelectedRule <> nil;
  AppUtils.Enable(lIsSelected, ItemToolRuleDescr, ItemToolEditRule, ItemToolDeleteRule, ItemPopUndefinedValue, ItemPopRuleStatus);
  AppUtils.Enable(fFunct.EntCount < fFunct.Count, ItemPopEnter);
  AppUtils.Enable(fUndoRedo.CanUndo, BtnUndo);
  AppUtils.Enable(fUndoRedo.CanRedo, BtnRedo);
  inc(fUpdateLevel);
  try
    fAutomation := fFunct.UseConsist or fFunct.UseWeights;
    if ItemToolAutoSettings.Visible then
      begin
        ItemAutoUseDominance.Enabled := fFunct.CanUseDominance;
        ItemAutoUseWeights.Enabled := fFunct.CanUseWeights;
        ItemAutoUseDominance.Checked := ItemAutoUseDominance.Enabled and fFunct.UseConsist {and (fFunct.CstState >= 0)};
        ItemAutoUseWeights.Checked := ItemAutoUseWeights.Enabled and fFunct.UseWeights {and (fFunct.KNState >= 0)};
        var lImgName :=
          if ItemAutoUseDominance.Checked and ItemAutoUseDominance.Enabled then
            if ItemAutoUseWeights.Checked and ItemAutoUseWeights.Enabled then 'ImgAutoAll'
            else 'ImgAutoDominance'
          else
            if ItemAutoUseWeights.Checked and ItemAutoUseWeights.Enabled then 'ImgAutoWeights'
            else 'ImgAutoNone';
        ItemToolAutoSettings.Image := AutoImages.Images[lImgName];
      end;
  finally
    dec(fUpdateLevel);
  end;
end;

method FormFunctEditTabular.ItemToolFunctDescr_Click(sender: System.Object; e: System.EventArgs);
begin
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

method FormFunctEditTabular.ViewFunct_FormatCell(sender: System.Object; e: FormatCellEventArgs);
begin
  if e.Column = fOutColumn then
    begin
      e.SubItem.BackColor := AppSettings.SelectedColor;
      if e.RowIndex = ViewFunct.SelectedIndex then
        begin
          var cbd := new CellBorderDecoration;
          cbd.BoundsPadding := new Size(0, -1);
          cbd.BorderPen := AppSettings.EditPen;
          cbd.FillBrush := nil;
          cbd.CornerRounding := 0;
          e.SubItem.Decoration := cbd;
        end;
    end;
end;

method FormFunctEditTabular.ViewFunct_SelectionChanged(sender: System.Object; e: System.EventArgs);
begin
  SelectionChanged;
end;

method FormFunctEditTabular.ConsistencyStatus(aRule: DexiRuleObject);
begin
  var lIdx := aRule.Index;
  var lInConsist :=
    if not aRule.Consistent then DexiUtils.Utils.IntArrayToStr(IndexToNumber(fFunct.RuleInconsistentWith(lIdx)))
    else '';
  var lMessage :=
    if aRule.Consistent then
      if aRule.Entered then String.Format(DexiStrings.MsgRuleEntered, aRule.Number)
      else String.Format(DexiStrings.MsgRuleNotEntered, aRule.Number)
    else
      if aRule.Entered then String.Format(DexiStrings.MsgRuleEnteredInconsist, aRule.Number, lInConsist)
      else String.Format(DexiStrings.MsgRuleNotEnteredInconsist, aRule.Number, lInConsist);
  MessageBox.Show(lMessage,
    if aRule.Consistent then "Status" else 'Warning',
    MessageBoxButtons.OK,
    if aRule.Consistent then MessageBoxIcon.Information else  MessageBoxIcon.Warning);
end;

method FormFunctEditTabular.ViewFunct_MouseClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if sender = ViewFunct then
    begin
      var ht := ViewFunct.OlvHitTest(e.Location.X, e.Location.Y);
      if ht <> nil then
        begin
          if ht.Column = ColStatus then
            begin
              var lRule := DexiRuleObject(ht.RowObject);
              if lRule <> nil then
                begin
                  ViewFunct.RefreshObject(fLastSelected);
                  ConsistencyStatus(lRule);
                end;
            end;
        end;
    end;
end;

method FormFunctEditTabular.ViewFunct_KeyDown(sender: System.Object; e: System.Windows.Forms.KeyEventArgs);
begin
  if SelectedRule = nil then
    exit;
  if e.KeyCode = Keys.Delete then
    begin
      DeleteFunctionValue(SelectedRule.Number);
      e.Handled := true;
    end
  else if e.KeyCode = Keys.F2 then
    begin
      EditFunctionValue(SelectedRule.Number);
      e.Handled := true;
    end
end;

method FormFunctEditTabular.ViewFunct_KeyPress(sender: System.Object; e: System.Windows.Forms.KeyPressEventArgs);
begin
  if SelectedRule = nil then
    exit;
  var lValue := DexiTabularFunction.ExtToIntVal(Char.ToUpper(e.KeyChar));
  if 0 <= lValue < fScale.Count then
    begin
      SetFunctionValue(SelectedRule.Number, new DexiIntSingle(lValue));
      e.Handled := true;
    end;
end;

method FormFunctEditTabular.ItemToolDeleteRule_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedRule = nil then
    exit;
  DeleteFunctionValue(SelectedRule.Number);
end;

method FormFunctEditTabular.ItemPopRuleStatus_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedRule = nil then
    exit;
  ConsistencyStatus(SelectedRule);
end;

method FormFunctEditTabular.ItemPopUndefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedRule = nil then
    exit;
  UndefineFunctionValue(SelectedRule.Number);
end;

method FormFunctEditTabular.ItemPopDefinedValue_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedRule = nil then
    exit;
  if sender is ToolStripMenuItem then
    SetFunctionValue(SelectedRule.Number, new DexiIntSingle(Integer(ToolStripMenuItem(sender).Tag)));
end;

method FormFunctEditTabular.ViewFunct_CellEditStarting(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if SelectedRule = nil then
    exit;
  if e.Column = fOutColumn then
    begin
      var lRuleIndex := SelectedRule.Index;
      var lCtrl := new ComboBox;
      lCtrl.DropDownStyle := ComboBoxStyle.DropDownList;
      lCtrl.Items.AddRange(fScaleNames.ToArray);
      lCtrl.Items.Add(DexiString.SDexiUndefinedValue);
      lCtrl.Bounds := e.CellBounds;
      lCtrl.SelectedIndex :=
        if fFunct.RuleDefined[lRuleIndex] then fFunct.RuleValLow[lRuleIndex]
        else fScale.Count;
      lCtrl.SelectedIndexChanged += ComboEdit_SelectedIndexChanged;
      e.Control := lCtrl;
    end;
end;

method FormFunctEditTabular.ComboEdit_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  ViewFunct.FinishCellEdit;
end;

method FormFunctEditTabular.ViewFunct_CellEditFinishing(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  fSelectedEditedValue := -1;
  if not e.Cancel and  (e.Column = fOutColumn) and (e.Control is ComboBox) then
    fSelectedEditedValue := ComboBox(e.Control).SelectedIndex;
end;

method FormFunctEditTabular.ViewFunct_CellEditFinished(sender: System.Object; e: BrightIdeasSoftware.CellEditEventArgs);
begin
  if SelectedRule = nil then
    exit;
  if (e.Column = fOutColumn) and (e.Control is ComboBox) then
    begin
      if not e.Cancel then
        if 0 <= fSelectedEditedValue < fScale.Count then
          SetFunctionValue(SelectedRule.Number, new DexiIntSingle(fSelectedEditedValue))
        else if fSelectedEditedValue = fScale.Count then
          UndefineFunctionValue(SelectedRule.Number);
      AppDisposeHandler.HandleUndisposed(e.Control);
//      e.Control.Dispose;
//      e.Control := nil;
    end;
end;

method FormFunctEditTabular.ViewFunct_MouseDoubleClick(sender: System.Object; e: System.Windows.Forms.MouseEventArgs);
begin
  if SelectedRule = nil then
    exit;
  EditFunctionValue(SelectedRule.Number);
end;

method FormFunctEditTabular.ItemToolEditRule_Click(sender: System.Object; e: System.EventArgs);
begin
  if SelectedRule = nil then
    exit;
  EditFunctionValue(SelectedRule.Number);
end;

method FormFunctEditTabular.ItemAutoUseDominance_Click(sender: System.Object; e: System.EventArgs);
begin
  fFunct.UseConsist := not fFunct.UseConsist;
  fAutomation := fFunct.UseConsist or fFunct.UseWeights;
  FunctionValueChanged;
end;

method FormFunctEditTabular.ItemAutoUseWeights_Click(sender: System.Object; e: System.EventArgs);
begin
  fFunct.UseWeights := not fFunct.UseWeights;
  fAutomation := fFunct.UseConsist or fFunct.UseWeights;
  FunctionValueChanged;
end;

method FormFunctEditTabular.ItemPopEnterTable_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fFunct.SetRulesEntered(true);
  FunctionValueChanged;
end;

method FormFunctEditTabular.ItemPopEnterSingle_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fFunct.SetRulesEntered(false);
  FunctionValueChanged;
end;

method FormFunctEditTabular.ItemToolWeights_Click(sender: System.Object; e: System.EventArgs);
begin
  using lForm := new FormWeights do
    begin
      lForm.SetForm(self);
      lForm.ShowDialog; // FormWeight performs all changes on fFunct
    end;
  UpdateForm;
end;

method FormFunctEditTabular.ItemToolShowFunction_Click(sender: System.Object; e: System.EventArgs);
begin
  ReportManager.OpenFunctionReport(fModel, fAttribute, fFunct);
end;

method FormFunctEditTabular.ItemToolCopyFunct_Click(sender: System.Object; e: System.EventArgs);
begin
  var lList := fFunct.SaveToStringList(fModel.Settings);
  var lText := String.Join(Environment.LineBreak, lList);
  Clipboard.SetText(lText);
end;

method FormFunctEditTabular.ItemToolPasteFunct_Click(sender: System.Object; e: System.EventArgs);
begin
  var lText := Clipboard.GetText;
  var lList := Utils.BreakToLines(lText);
  var lLoaded: Integer;
  var lChanged: Integer;
  fFunct.LoadFromStringList(lList, fModel.Settings, out lLoaded, out lChanged);
  FunctionValueChanged;
  MessageBox.Show(String.Format(DexiString.SDexiTabFncImport, lLoaded, lChanged),
         "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
end;

method FormFunctEditTabular.ItemToolsChart_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  using lForm := new FormFunctChart do
    begin
      lForm.SetForm(fModel, fAttribute, fFunct);
      lForm.ShowDialog;
    end;
end;

method FormFunctEditTabular.BtnUndo_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fUndoRedo.Undo;
end;

method FormFunctEditTabular.BtnRedo_Click(sender: System.Object; e: System.EventArgs);
begin
  if fUpdateLevel > 0 then
    exit;
  fUndoRedo.Redo;
end;

method FormFunctEditTabular.ItemPopResizeColumns_Click(sender: System.Object; e: System.EventArgs);
begin
  for each lColumn in ViewFunct.Columns do
    with lCol :=  OLVColumn(lColumn) do
      if (lCol.AspectName = 'Arg') and (Integer(lCol.Tag) >= 0) then
        begin
          var lWidth := TextRenderer.MeasureText(lCol.Text, ViewFunct.Font).Width + 10;
          var lArg := Integer(lCol.Tag);
          var lScale := DexiDiscreteScale(InpScale[lArg]);
          for i := 0 to lScale.Count - 1 do
            begin
              var lText := lScale.Names[i];
              lWidth := Math.Max(lWidth, Integer(1.05 * TextRenderer.MeasureText(lText, ViewFunct.Font).Width));
            end;
          lCol.Width := Math.Max(lWidth, lCol.MinimumWidth);
        end;
end;

method FormFunctEditTabular.ViewFunct_SelectedIndexChanged(sender: System.Object; e: System.EventArgs);
begin
  ViewFunct.FinishCellEdit;
end;

method FormFunctEditTabular.ItemPopResetColumns_Click(sender: System.Object; e: System.EventArgs);
begin
  if fDefaultTableState <> nil then
    ViewFunct.RestoreState(fDefaultTableState);
end;

method FormFunctEditTabular.ItemToolSymmetricity_Click(sender: System.Object; e: System.EventArgs);
begin
  using lForm := new FormSymmetricity do
    begin
      lForm.SetForm(self);
      lForm.ShowDialog; // FormWeight performs all changes on fFunct
    end;
  UpdateForm;
end;

end.